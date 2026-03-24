import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.service.dart';

/// v7 API 에러를 사용자 친화적으로 표현하는 예외
class ApiException implements Exception {
  final String message;
  final String code;
  final String title;
  final dynamic originalError;

  ApiException(this.code, this.title, this.message, [this.originalError]);

  /// 서버 에러 코드 → 한글 메시지 매핑
  static const _errorMessages = <String, String>{
    'NICKNAME_REQUIRED': '닉네임을 먼저 설정해주세요',
    'LOGIN_REQUIRED': '로그인이 필요합니다',
    'PERMISSION_DENIED': '권한이 없습니다',
    'POST_NOT_FOUND': '게시글을 찾을 수 없습니다',
    'COMMENT_NOT_FOUND': '댓글을 찾을 수 없습니다',
    'ALREADY_REPORTED': '이미 신고한 글입니다',
    'TITLE_REQUIRED': '제목을 입력해주세요',
    'CONTENT_REQUIRED': '내용을 입력해주세요',
    'HAS_COMMENTS': '댓글이 있는 글은 삭제할 수 없습니다',
    'HAS_CHILDREN': '답글이 있는 댓글은 삭제할 수 없습니다',
  };

  /// 서버 에러 코드를 한글 메시지로 변환. 매핑이 없으면 원본 반환.
  static String translateError(String serverMessage) {
    return _errorMessages[serverMessage] ?? serverMessage;
  }

  @override
  String toString() => message;
}

/// v7 공통 API 서비스
///
/// v7 API 호출에 필요한 공통 로직을 제공한다.
/// - Firebase ID Token 자동 첨부
/// - Dio 인스턴스 생성 (디버그 모드에서 자체 서명 SSL 허용)
/// - v7 에러 판별 및 예외 발생
class ApiService {
  static ApiService instance = ApiService._();
  ApiService._();

  final String _endpoint = Config.v7ApiEndpoint;

  /// Firebase ID Token을 data 맵에 추가한다.
  ///
  /// 로그인 상태일 때만 `id_token` 키를 추가하며,
  /// 토큰 획득 실패 시 빈 문자열을 사용한다.
  static Future<void> _patchToken(Map<String, dynamic> data) async {
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
  Future<T> v7api<T>(
    String method, {
    Map<String, dynamic>? data,
    bool debug = false,
  }) async {
    data = data ?? {};
    data['method'] = method;

    await _patchToken(data);

    if (debug) {
      // data를 쿼리 파라미터로 빌드하여 완전한 GET URL 생성
      final queryParams = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      final fullUri = Uri.parse(
        _endpoint,
      ).replace(queryParameters: queryParams);
      log('GET URL: $fullUri', name: 'v7api::');
    }

    final dio = _createDio();

    final response = await dio.post(_endpoint, data: data);

    final responseData = response.data;

    Map<String, dynamic> json;
    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is List) {
      return responseData as T;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw ApiException(
        'unexpected_response_type',
        '예상치 못한 응답 타입',
        '예상치 못한 응답 타입: ${responseData.runtimeType}',
      );
    }

    // v7 에러 판별: success == false일 때만 에러
    if (json['success'] == false) {
      final serverMessage = json['message'] ?? '알 수 없는 오류';
      throw ApiException(
        'api_error',
        'API 오류',
        ApiException.translateError(serverMessage.toString()),
      );
    }

    return json as T;
  }

  /// 파일 업로드
  ///
  /// API: `upload.upload` (인증 필요)
  ///
  /// [filePath] 업로드할 로컬 파일 경로 (필수)
  /// [module] 모듈명 (선택, 예: 'company', 'post', 'user')
  /// [code] 세부 분류 (선택, 예: 'main_photo', 'gallery', 'profile_photo')
  /// [extraData] FormData에 추가할 임의 필드 (선택)
  /// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
  Future<Map<String, dynamic>> fileUpload({
    required String filePath,
    String? module,
    String? code,
    Map<String, dynamic>? extraData,
    void Function(double progress)? onProgress,
  }) async {
    final dio = _createDio();
    final fileName = filePath.split('/').last;

    String idToken = '';
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        idToken = await user.getIdToken() ?? '';
      } catch (_) {}
    }

    final formData = FormData.fromMap({
      'method': 'upload.upload',
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
      if (idToken.isNotEmpty) 'id_token': idToken,
      if (module != null) 'module': module,
      if (code != null) 'code': code,
      ...?extraData,
    });

    final response = await dio.post(
      _endpoint,
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

    Map<String, dynamic> json;
    if (response.data is Map<String, dynamic>) {
      json = response.data;
    } else if (response.data is String) {
      json = jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw ApiException(
        'unexpected_response_type',
        '예상치 못한 응답 타입',
        '예상치 못한 응답 타입: ${response.data.runtimeType}',
      );
    }

    if (json['success'] == false) {
      final e = ApiException(
        'file_upload_error',
        '파일 업로드 오류',
        json['message'] ?? '파일 업로드에 실패했습니다.',
      );
      showError(e);
      throw e;
    }

    return json;
  }

  /// 파일 삭제
  ///
  /// API: `upload.delete` (인증 필요, 본인 파일만 삭제 가능)
  ///
  /// [idx] 삭제할 파일의 idx
  Future<void> fileDelete(int idx) async {
    await v7api('upload.delete', data: {'idx': idx});
  }

  /// URL로 파일 삭제
  ///
  /// API: `upload.deleteByUrl` (인증 필요, 본인 파일만 삭제 가능)
  ///
  /// [url] 삭제할 파일의 상대경로 URL (예: /uploads/123/abc.webp)
  Future<void> fileDeleteByUrl(String url) async {
    final path = Uri.tryParse(url)?.path ?? url;
    await v7api('upload.deleteByUrl', data: {'url': path});
  }

  /// 안전한 int 변환
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// DioException 등 에러를 사용자 친화적 메시지로 변환한다.
  static String friendlyErrorMessage(dynamic error) {
    if (error is ApiException) return error.message;

    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode;
        switch (statusCode) {
          case 500:
            return '서버 내부 오류가 발생했습니다. (500)';
          case 502:
            return '서버에 접속할 수 없습니다. (502)';
          case 503:
            return '서버가 일시적으로 사용할 수 없습니다. (503)';
          case 504:
            return '서버가 응답하지 않습니다. 잠시 후 다시 시도해주세요. (504)';
          default:
            if (statusCode != null && statusCode >= 400 && statusCode < 500) {
              return '잘못된 요청입니다. ($statusCode)';
            }
            return '서버 오류가 발생했습니다. ($statusCode)';
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return '서버 연결 시간이 초과되었습니다. 네트워크를 확인해주세요.';
        case DioExceptionType.connectionError:
          return '서버에 연결할 수 없습니다. 네트워크를 확인해주세요.';
        default:
          return '네트워크 오류가 발생했습니다.';
      }
    }

    final msg = error.toString();
    // "Exception: ..." 접두사 제거
    if (msg.startsWith('Exception: ')) {
      return msg.substring('Exception: '.length);
    }
    return msg;
  }

  /// 에러를 SnackBar로 화면에 표시한다.
  static void showError(dynamic error) {
    ScaffoldMessenger.of(
      AppService.instance.context,
    ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
  }
}
