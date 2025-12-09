import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:philgo_api/philgo_api.dart';

/// 이 함수는 PhilGo PHP API 서버의 /func.php 로 접속해서,
/// 데이터를 송/수신 한다.
///
/// [functionName] 호출할 함수 이름
/// [data] 전송할 데이터
/// [debug] 디버그 모드
/// [alertOnError] 에러 발생 시 알림 여부
Future<T> func<T>(
  String functionName, {
  RecordType? data,
  bool debug = false,
  bool alertOnError = true,
  Map<String, String>? headers,
}) async {
  // 기본 옵션 설정
  data = data ?? <String, dynamic>{};
  data['func'] = functionName;

  final url = PhilgoConfig.phpApiUrl;

  try {
    // Firebase ID Token 추가
    data = await patchToken(data);

    if (debug) {
      // queryParameters는 모든 값이 String이어야 하므로 변환
      final stringParams = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      log(
        'GET URL: $url?${Uri(queryParameters: stringParams).query}',
        name: "$functionName::",
      );
    }

    // Create Dio instance
    final dio = createDio();

    // Override headers if provided
    if (headers != null) {
      dio.options.headers.addAll(headers);
    }

    // HTTP 요청
    final response = await dio.post(url, data: data);

    final responseData = response.data;
    Map<String, dynamic> json;

    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is List) {
      // If the response is a list, wrap it in a map with a key 'data'
      return responseData as T;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw Exception(
        'Unexpected response data type: ${responseData.runtimeType}',
      );
    }

    // API 가 소프트 에러를 응답한 경우, Exception 을 throw 하지 않고, 데이터를 리턴한다.
    if (json['error'] != null) {
      return json as T;
    }

    // 에러 없음! 정상 응답! 성공!
    return json as T;
  } on DioException catch (dioError) {
    // ================================================================
    // 에러 발생 : Handle Dio-specific errors
    // ================================================================

    // ===============================================================
    // Handshake 에러 (서버 접속 실패, SSL 인증서 검증 실패, 인터넷 미연결) 체크
    // 클라이언트에서 서버로 접속할 수 없는 경우를 처리합니다.
    // ===============================================================
    if (dioError.message?.contains('Handshake') ?? false) {
      final userMessage =
          '서버와 접속이 안됩니다. 인터넷이 연결되었는지, 서버 접속 도메인이 올바른지 확인을 해 주세요';
      log('Handshake 에러 발생: ${dioError.message}, 원인: ${dioError.error}');

      // 사용자에게 명확한 메시지 표시
      if (alertOnError) {
        showSafeErrorDialog(userMessage);
      }
      throw Exception(userMessage);
    }

    final data = dioError.response?.data;
    log('philgoApi() DioException: $data, $dioError');

    // ===============================================================
    // DioException의 error가 FormatException인 경우 source 출력
    // FormatException는 주로 JSON 파싱 에러 등에서 발생하며, 특히, 서버에서
    // PHP 에러가 발생 했을 가능성이 매우 높다.
    // ===============================================================
    if (dioError.error is FormatException) {
      final formatError = dioError.error as FormatException;

      // source를 텍스트로 변환하여 출력
      String sourceText = '';
      if (formatError.source != null) {
        if (formatError.source is List<int>) {
          // List<int>인 경우 UTF-8로 디코딩 시도
          try {
            sourceText = utf8.decode(formatError.source as List<int>);
          } catch (e) {
            // 디코딩 실패 시 원본 데이터 출력
            sourceText = 'Raw bytes: ${formatError.source}';
          }
        } else if (formatError.source is String) {
          // 이미 String인 경우
          sourceText = formatError.source as String;
        } else {
          // 기타 타입인 경우
          sourceText = formatError.source.toString();
        }
      }

      log('FormatException source (as text): $sourceText');
      log('FormatException message: ${formatError.message}');
      log('FormatException offset: ${formatError.offset}');

      // 에러 다이얼로그 표시
      if (alertOnError) {
        showSafeErrorDialog('서버 응답을 처리하는 중에 오류가 발생했습니다.\n\n$sourceText');
      }
      rethrow;
    }
    // ================================================================
    // 여기까지 도달했다면, DioException이지만 FormatException은 아니다.
    // 즉, JSON 파싱 에러는 아닐 가능성이 높고, PHP 에러가 아닐 가능성이 높다.
    // 즉, PHP 가 {'error': '...', 'message': '...'} 형태로 응답했을 가능성이 높다.
    // ================================================================
    // DioException 자체의 상세 정보 출력
    log('DioException type: ${dioError.type}');
    log('DioException message: ${dioError.message}');
    log('DioException response: ${dioError.response?.data}');
    log('DioException requestOptions: ${dioError.requestOptions.uri}');

    final errorPrefix = '에러: ';
    String serverMessage = '';

    try {
      // 서버 에러 메시지 파싱 시도
      final responseData = dioError.response?.data;

      if (dioError.response?.statusCode == 403) {
        serverMessage = '403: 접근이 거부되었습니다. 권한이 없을 수 있습니다.';
      } else if (responseData is Map<String, dynamic>) {
        if (responseData['message'] != null) {
          serverMessage =
              '${responseData['message']} (코드: ${responseData['error'] ?? 'UNKNOWN'})';
        } else if (responseData['error'] != null) {
          serverMessage = '(코드: ${responseData['error']}) No specific message.';
        } else {
          serverMessage = responseData.toString();
        }
      } else if (responseData is String) {
        try {
          final errorJson = jsonDecode(responseData) as Map<String, dynamic>;
          if (errorJson['message'] != null) {
            serverMessage =
                '${errorJson['message']} (코드: ${errorJson['error'] ?? 'UNKNOWN'})';
          } else if (errorJson['error'] != null) {
            serverMessage = '(코드: ${errorJson['error']}) No specific message.';
          } else {
            serverMessage = responseData;
          }
        } catch (e) {
          // JSON 파싱 실패 시 원본 텍스트 사용
          serverMessage = responseData;
        }
      } else {
        serverMessage = responseData.toString();
      }
    } catch (e) {
      serverMessage = 'Failed to read error response body.';
    }

    final slimErrorMessage = serverMessage;
    if (alertOnError) {
      showSafeErrorDialog('서버와 통신하는 중에 오류가 발생했습니다.\n\n$slimErrorMessage');
    }

    final errorMessage =
        '$errorPrefix ${httpStatusCode(dioError.response?.statusCode ?? 0)} ${dioError.response?.statusMessage ?? ''} $serverMessage';
    throw Exception(errorMessage);
  } catch (e) {
    debugLog('philgoApi() 에러: catch(e) $e');
    // 요청에서 에러가 발생한 경우
    if (alertOnError) {
      debugLog('ALERT: url: $url');
      debugLog('ALERT: data: $data');
      debugLog('ALERT: error message: ${e.toString()}');
      showSafeErrorDialog('서버와 통신하는 중에 오류가 발생했습니다.\n\n(2) ${e.toString()}');
    }
    rethrow; // re-throw the error to be handled by the caller
  }
}

/// Dio 인스턴스 생성
///
/// 디버그 모드일 때 SSL 인증서 검증을 무시하도록 설정:
/// 왜?
/// 개발 환경에서 MkCert 를 통해서 자체 서명된 SSL 인증서를 사용하는데, Simulator 에서 macOS 로 접속 할 때, SSL 인증서 검증이 실패할 수 있기 때문.
Dio createDio() {
  final dio = Dio();

  if (kDebugMode) {
    // 디버그일 때만 SSL 무시 (자체 서명 인증서 허용)
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return httpClient;
    };
  }

  return dio;
}

///
Future<RecordType> patchToken(RecordType data) async {
  final auth = fb_auth.FirebaseAuth.instance;
  if (auth.currentUser == null) {
    return data;
  }

  try {
    final token = await auth.currentUser!.getIdToken();
    data['id_token'] = token ?? '';
  } catch (e) {
    debugLog('Error getting Firebase ID token: $e');
    data['id_token'] = '';
  }
  return data;
}

/// HTTP status code messages
String httpStatusCode(int statusCode) {
  switch (statusCode) {
    case 200:
      return 'OK';
    case 201:
      return 'Created';
    case 400:
      return 'Bad Request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not Found';
    case 500:
      return 'Internal Server Error';
    default:
      return 'HTTP $statusCode';
  }
}

/// 현재 로그인한 사용자 정보 가져오기
///
/// API 엔드포인트: user.my
/// 인증 필요: 예 (Firebase ID Token 필수)
///
/// 이 함수는 현재 로그인한 사용자의 정보를 가져옵니다.
/// Firebase Authentication으로 로그인된 상태여야 하며,
/// 자동으로 Firebase ID Token을 포함하여 서버에 요청합니다.
///
/// ```
Future<User> philgoApiUserMy() async {
  // user.my 엔드포인트 호출 - 인증 필수
  final response = await func('user.my');

  // 성공적으로 사용자 정보 반환
  return User.fromJson(response);
}

Future<User> philgoApiUserVerify() async {
  // user.verify 엔드포인트 호출 - 인증 필수
  final response = await func('get_my_data');

  // 성공적으로 사용자 정보 반환
  return User.fromJson(response);
}

Future<User> philgoApiUserUpdate(Map<String, dynamic> userData) async {
  // user.update 엔드포인트 호출 - 인증 필수
  final response = await func('update_my_profile', data: userData);
  return User.fromJson(response);
}

/// 파일을 PhilGo 파일 서버에 업로드합니다.
///
/// [filePath] 업로드할 파일의 경로
/// [onProgress] 업로드 진행률 콜백 (0.0 ~ 1.0)
/// [deleteFile] 기존 파일 삭제 URL (옵션)
/// [qrCode] QR 코드 스캔 여부 (기본값: false)
///
/// 반환값: 업로드된 파일 정보를 담은 FileUploadResponse 객체
///   - url: 업로드된 파일의 URL
///   - qr_code: QR 코드가 있는 경우 디코딩된 문자열
///   - deleted: 기존 파일 삭제 여부
Future<FileUploadResponse?> philgoApiFileUpload(
  String filePath, {
  void Function(double progress)? onProgress,
  String? deleteFile,
  bool qrCode = false,
}) async {
  try {
    // Dio 인스턴스 생성
    final dio = Dio();

    // 파일 객체 생성
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    // FormData 생성
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      'uid': fb_auth.FirebaseAuth.instance.currentUser?.uid,
      if (deleteFile != null) 'deleteFile': deleteFile,
      if (qrCode) 'decodeQrCode': 'Y',
    });

    // 파일 서버 URL
    final uploadUrl = PhilgoConfig.fileUploadUrl;

    // 파일 업로드 요청
    final response = await dio.post(
      uploadUrl,
      data: formData,
      onSendProgress: (sent, total) {
        if (onProgress != null) {
          final progress = sent / total;
          onProgress(progress);
        }
      },
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    // 응답 처리
    if (response.statusCode == 200) {
      final responseData = response.data;
      Map<String, dynamic> json;

      // 응답이 문자열인 경우 JSON 파싱
      if (responseData is String) {
        try {
          json = jsonDecode(responseData) as Map<String, dynamic>;
        } catch (e) {
          // JSON 파싱 실패 시, URL 문자열로 간주
          json = {'url': responseData};
        }
      } else if (responseData is Map<String, dynamic>) {
        json = responseData;
      } else {
        // 예상치 못한 응답 형식
        debugLog('파일 업로드 - 예상치 못한 응답 형식: ${responseData.runtimeType}');
        return null;
      }

      // 에러 체크
      if (json['error'] != null) {
        debugLog('파일 업로드 오류: ${json['error']} - ${json['message']}');
        throw Exception('파일 업로드 실패: ${json['message'] ?? json['error']}');
      }

      // FileUploadResponse 객체 생성 및 반환
      final philgoFile = FileUploadResponse.fromJson(json);
      debugLog('philgo upload response: $philgoFile');
      return philgoFile;
    } else {
      debugLog('파일 업로드 실패 - HTTP ${response.statusCode}');
      return null;
    }
  } on DioException catch (e) {
    debugLog('파일 업로드 DioException: ${e.message}');
    if (e.response != null) {
      debugLog('응답 데이터: ${e.response?.data}');
    }
    rethrow;
  } catch (e) {
    debugLog('파일 업로드 오류: $e');
    rethrow;
  }
}

Future<void> philgoApiFileDelete(String? fileUrl) async {
  // URL 유효성 검사
  if (fileUrl == null || fileUrl.isEmpty) {
    throw Exception('URL이 비어있습니다');
  }

  try {
    // Dio 인스턴스 생성
    final dio = Dio();

    // Firebase 토큰 가져오기
    final auth = fb_auth.FirebaseAuth.instance;
    final uid = auth.currentUser?.uid;

    // UID 검증 - 인증된 사용자만 파일 삭제 가능
    if (uid == null) {
      throw Exception('인증되지 않은 사용자입니다. 로그인이 필요합니다.');
    }

    // PhilgoConfig.fileDeleteUrl 사용 - URL 파라미터 방식
    final deleteUrl = PhilgoConfig.fileDeleteUrl(uid, fileUrl);

    // 디버깅용 요청 정보 로깅
    debugLog('파일 삭제 요청:');
    debugLog('  - URL: $deleteUrl');
    debugLog('  - 삭제할 파일: $fileUrl');
    debugLog('  - UID: $uid');

    // GET 요청으로 파일 삭제 (URL 파라미터 방식)
    final response = await dio.get(deleteUrl);

    // 응답 상태 확인
    if (response.statusCode != 200) {
      debugLog('파일 삭제 실패 - HTTP ${response.statusCode}');
      debugLog('응답 데이터: ${response.data}');
      throw Exception('파일 삭제 실패: HTTP ${response.statusCode}');
    }

    // 응답 데이터 검사 (서버가 에러 응답을 200 OK로 보낼 수도 있음)
    if (response.data != null) {
      debugLog('파일 삭제 응답: ${response.data}');

      // 응답이 JSON인 경우 에러 체크
      if (response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        if (json['error'] != null) {
          final errorMsg = '파일 삭제 실패: ${json['message'] ?? json['error']}';
          debugLog(errorMsg);
          throw Exception(errorMsg);
        }
      }
    }

    debugLog('파일 삭제 성공: $fileUrl');
  } on DioException catch (dioError) {
    // DioException 상세 로깅
    debugLog('=== DioException 발생 ===');
    debugLog('에러 타입: ${dioError.type}');
    debugLog('에러 메시지: ${dioError.message}');
    debugLog('요청 URL: ${dioError.requestOptions.uri}');
    debugLog('요청 메서드: ${dioError.requestOptions.method}');
    debugLog('요청 데이터: ${dioError.requestOptions.data}');

    // 응답 정보 로깅 (있는 경우)
    if (dioError.response != null) {
      debugLog('응답 상태 코드: ${dioError.response?.statusCode}');
      debugLog('응답 상태 메시지: ${dioError.response?.statusMessage}');
      debugLog('응답 헤더: ${dioError.response?.headers}');
      debugLog('응답 데이터: ${dioError.response?.data}');

      // 응답 데이터 파싱 시도
      try {
        final responseData = dioError.response?.data;
        if (responseData is Map<String, dynamic>) {
          if (responseData['error'] != null) {
            debugLog('서버 에러 코드: ${responseData['error']}');
            debugLog('서버 에러 메시지: ${responseData['message'] ?? "없음"}');
          }
        } else if (responseData is String) {
          debugLog('서버 응답 (문자열): $responseData');
        }
      } catch (e) {
        debugLog('응답 데이터 파싱 실패: $e');
      }
    } else {
      debugLog('응답 없음 (네트워크 오류 또는 타임아웃 가능성)');
    }

    // 상세 에러 메시지 생성
    String detailedError = '파일 삭제 실패: ';
    if (dioError.response != null) {
      detailedError +=
          'HTTP ${dioError.response?.statusCode} - ${dioError.response?.statusMessage ?? ""}';
      if (dioError.response?.data != null) {
        detailedError += '\n응답: ${dioError.response?.data}';
      }
    } else {
      detailedError += dioError.message ?? '알 수 없는 네트워크 오류';
    }

    debugLog('=== DioException 로깅 종료 ===');
    throw Exception(detailedError);
  } catch (e) {
    // 기타 예외 처리
    debugLog('파일 삭제 중 예기치 않은 오류: $e');
    debugLog('오류 타입: ${e.runtimeType}');
    rethrow;
  }
}

Future<String> philgoApiGetAdminUserUid() async {
  // app.admins
  final response = await func('get_admins');

  final chatAdmin = response['chat_admin'] as String?;
  // log('Admin user uid: $chatAdmin', name: 'Got admin user uid from philgo API');

  // 성공적으로 사용자 정보 반환
  return chatAdmin ?? '';
}

Future<String> philgoApiGetTermsAndConditions() async {
  final response = await func('get_terms_and_conditions');

  return response['data'] as String? ?? '';
}

Future<String> philgoApiGetPrivacyPolicy() async {
  final response = await func('get_privacy_policy');

  return response['data'] as String? ?? '';
}
