import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:philgo/app.config.dart';
import 'file_upload.model.dart';

/// 파일 업로드 API 서비스
///
/// v7 upload.upload API를 통해 파일을 업로드한다.
/// multipart/form-data 방식으로 전송하며 Firebase ID Token 인증을 자동 처리한다.
///
/// 사용 예시:
/// ```dart
/// final model = await FileUploadService.upload(
///   filePath: '/path/to/photo.jpg',
///   module: 'company',
///   code: 'main_photo',
///   onProgress: (p) => print('${(p * 100).toInt()}%'),
/// );
/// print(model.url); // https://philgo.com/uploads/123/abc.webp
/// ```
class FileUploadService {
  FileUploadService._();

  /// 파일 업로드
  ///
  /// API: `upload.upload` (인증 필요)
  ///
  /// [filePath] 업로드할 로컬 파일 경로 (필수)
  /// [module] 모듈명 (선택, 예: 'company', 'post', 'user')
  /// [code] 세부 분류 (선택, 예: 'main_photo', 'gallery', 'profile_photo')
  /// [extraData] FormData에 추가할 임의 필드 (선택)
  /// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
  static Future<FileUploadModel> upload({
    required String filePath,
    String? module,
    String? code,
    Map<String, dynamic>? extraData,
    void Function(double progress)? onProgress,
  }) async {
    final dio = _createDio();

    final idToken = await _getIdToken();
    final fileName = filePath.split('/').last;

    final formData = FormData.fromMap({
      'method': 'upload.upload',
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (idToken.isNotEmpty) 'id_token': idToken,
      if (module != null) 'module': module,
      if (code != null) 'code': code,
      ...?extraData,
    });

    final response = await dio.post(
      v7ApiEndpoint,
      data: formData,
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) {
          onProgress(sent / total);
        }
      },
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    final json = _parseResponse(response.data);

    if (json['success'] == false) {
      throw Exception(json['message'] ?? '파일 업로드에 실패했습니다.');
    }

    return FileUploadModel.fromJson(json);
  }

  /// 파일 삭제
  ///
  /// API: `upload.delete` (인증 필요, 본인 파일만 삭제 가능)
  ///
  /// [idx] 삭제할 파일의 idx
  static Future<void> delete(int idx) async {
    final dio = _createDio();

    final data = <String, dynamic>{'method': 'upload.delete', 'idx': idx};

    final idToken = await _getIdToken();
    if (idToken.isNotEmpty) data['id_token'] = idToken;

    final response = await dio.post(v7ApiEndpoint, data: data);
    final json = _parseResponse(response.data);

    if (json['success'] == false) {
      throw Exception(json['message'] ?? '파일 삭제에 실패했습니다.');
    }
  }

  /// Firebase ID Token 획득 (로그인 상태일 때만)
  static Future<String> _getIdToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return '';
      return await user.getIdToken() ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Dio 인스턴스 생성 (디버그 모드에서 자체 서명 SSL 허용)
  static Dio _createDio() {
    final dio = Dio();
    if (kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (_, _, _) => true;
        return client;
      };
    }
    return dio;
  }

  /// 응답 데이터를 Map으로 파싱
  static Map<String, dynamic> _parseResponse(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    throw Exception('예상치 못한 응답 타입: ${data.runtimeType}');
  }
}
