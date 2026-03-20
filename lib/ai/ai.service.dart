import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:philgo/app.config.dart';

/// v7 AI 답변 서비스
///
/// `/ai-api.php` 전용 엔드포인트를 통해 SSE 스트리밍으로 AI 답변을 생성한다.
/// 서버가 자동으로 text_7 필드에 답변을 저장하므로 별도 저장 API 호출이 불필요하다.
class AiService {
  AiService._();

  /// AI API 엔드포인트 (ai-api.php)
  static String get _aiEndpoint => '${Config.v7BaseUrl}/ai-api.php';

  /// AI 답변 스트리밍 생성
  ///
  /// SSE(Server-Sent Events)로 AI 답변을 실시간 수신한다.
  /// 각 청크의 텍스트를 Stream<String>으로 반환한다.
  ///
  /// [idx] 게시글 번호
  /// [onChunk] 각 텍스트 청크가 도착할 때마다 호출되는 콜백
  /// [onDone] 스트리밍 완료 시 호출되는 콜백
  /// [onError] 에러 발생 시 호출되는 콜백
  static Future<void> answerPost({
    required int idx,
    required void Function(String chunk) onChunk,
    required void Function() onDone,
    required void Function(String error) onError,
  }) async {
    try {
      // Firebase ID Token 획득
      String idToken = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          idToken = await user.getIdToken() ?? '';
        } catch (_) {}
      }

      // POST 요청 body 구성
      final body = 'method=ai.answerPost&idx=$idx'
          '${idToken.isNotEmpty ? '&id_token=${Uri.encodeComponent(idToken)}' : ''}';

      final client = HttpClient();
      if (kDebugMode) {
        client.badCertificateCallback = (_, _, _) => true;
      }

      final request = await client.postUrl(Uri.parse(_aiEndpoint));
      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.write(body);

      final response = await request.close();

      if (response.statusCode != 200) {
        // 에러 응답 읽기
        final errorBody = await response.transform(utf8.decoder).join();
        // JSON 에러 메시지 파싱 시도
        try {
          final json = jsonDecode(errorBody);
          if (json is Map && json['message'] != null) {
            onError(json['message'].toString());
            client.close();
            return;
          }
        } catch (_) {}
        onError('서버 오류가 발생했습니다. (${response.statusCode})');
        client.close();
        return;
      }

      // SSE 스트림 파싱
      String buffer = '';
      await response.transform(utf8.decoder).forEach((data) {
        buffer += data;
        // 줄 단위로 처리
        while (buffer.contains('\n')) {
          final newlineIdx = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIdx).trim();
          buffer = buffer.substring(newlineIdx + 1);

          if (line.isEmpty) continue;

          // SSE 형식: "data: {...}"
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            final text = _extractTextFromGeminiChunk(jsonStr);
            if (text != null && text.isNotEmpty) {
              onChunk(text);
            }
          }
          // 에러 응답 확인 (JSON 형식)
          else if (line.startsWith('{')) {
            try {
              final json = jsonDecode(line);
              if (json is Map && json['success'] == false) {
                onError(json['message']?.toString() ?? '알 수 없는 오류');
                return;
              }
            } catch (_) {}
          }
        }
      });

      // 버퍼에 남은 데이터 처리
      if (buffer.trim().isNotEmpty) {
        final line = buffer.trim();
        if (line.startsWith('data: ')) {
          final jsonStr = line.substring(6);
          final text = _extractTextFromGeminiChunk(jsonStr);
          if (text != null && text.isNotEmpty) {
            onChunk(text);
          }
        } else if (line.startsWith('{')) {
          try {
            final json = jsonDecode(line);
            if (json is Map && json['success'] == false) {
              onError(json['message']?.toString() ?? '알 수 없는 오류');
              client.close();
              return;
            }
          } catch (_) {}
        }
      }

      onDone();
      client.close();
    } catch (e) {
      onError(e.toString());
    }
  }

  /// Gemini SSE 청크에서 텍스트 추출
  ///
  /// 형식: {"candidates":[{"content":{"parts":[{"text":"안녕"}]}}]}
  static String? _extractTextFromGeminiChunk(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      if (json is! Map) return null;
      final candidates = json['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final content = candidates[0]['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List || parts.isEmpty) return null;
      return parts[0]['text']?.toString();
    } catch (_) {
      return null;
    }
  }
}
