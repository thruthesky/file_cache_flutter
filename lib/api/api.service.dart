import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:philgo/app.config.dart';

/// v7 공통 API 서비스
///
/// v7 API 호출에 필요한 공통 로직을 제공한다.
/// - Firebase ID Token 자동 첨부
/// - Dio 인스턴스 생성 (디버그 모드에서 자체 서명 SSL 허용)
/// - v7 에러 판별 및 예외 발생
class ApiService {
  ApiService._();

  static const String _endpoint = v7ApiEndpoint;

  /// Firebase ID Token을 data 맵에 추가한다.
  ///
  /// 로그인 상태일 때만 `id_token` 키를 추가하며,
  /// 토큰 획득 실패 시 빈 문자열을 사용한다.
  static Future<void> patchToken(Map<String, dynamic> data) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        data['id_token'] = await user.getIdToken() ?? '';
      } catch (_) {
        data['id_token'] = '';
      }
    }
  }

  /// Dio 인스턴스를 생성한다.
  ///
  /// 디버그 모드에서는 자체 서명 SSL 인증서를 허용한다.
  static Dio _createDio() {
    final dio = Dio();
    if (kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final httpClient = HttpClient();
        httpClient.badCertificateCallback = (_, _, _) => true;
        return httpClient;
      };
    }
    return dio;
  }

  /// v7 API 내부 호출 헬퍼
  ///
  /// Firebase ID Token을 자동으로 추가하고, v7 서버에 HTTP POST 요청을 보낸다.
  /// 에러 발생 시 Exception을 throw한다.
  static Future<Map<String, dynamic>> v7api(
    String method, {
    Map<String, dynamic>? data,
  }) async {
    data = data ?? {};
    data['method'] = method;

    await patchToken(data);

    final dio = _createDio();

    try {
      final response = await dio.post(_endpoint, data: data);

      Map<String, dynamic> json;
      if (response.data is Map<String, dynamic>) {
        json = response.data;
      } else if (response.data is String) {
        json = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        throw Exception('예상치 못한 응답 타입: ${response.data.runtimeType}');
      }

      // v7 에러 판별: success == false일 때만 에러
      if (json['success'] == false) {
        throw Exception(json['message'] ?? '알 수 없는 오류');
      }

      return json;
    } catch (e, stackTrace) {
      debugPrint('[ApiService] v7api error — method: $method');
      debugPrint('[ApiService] error: $e');
      debugPrint('[ApiService] stackTrace: $stackTrace');
    }
  }

  /// 안전한 int 변환
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
