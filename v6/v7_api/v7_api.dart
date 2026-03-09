import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:philgo_api/philgo_api.dart';

import 'models/v7_upload_model.dart';

/// v7 API 호출 함수
///
/// 필고 v7 서버(api.php)에 HTTP POST 요청을 보내고 응답을 반환한다.
/// 기존 func() 함수의 createDio(), patchToken() 헬퍼를 그대로 재사용하여
/// SSL 처리, Firebase ID Token 등을 동일하게 적용한다.
///
/// [method] - "모듈.액션" 형식 (예: "user.count", "post.create")
/// [data] - 전송할 데이터 (method 필드는 자동 추가됨)
/// [debug] - 디버그 모드 (GET URL 로깅)
/// [alertOnError] - 에러 발생 시 사용자에게 다이얼로그 표시
///
/// v7 서버 응답 규칙:
/// - 성공: Controller 리턴값 그대로 (예: {"count": 188186})
/// - 에러: {"success": false, "message": "에러 설명"}
///
/// 사용 예시:
/// ```dart
/// final result = await v7api('user.count');
/// print(result['count']); // 188186
/// ```
Future<Map<String, dynamic>> v7api(
  String method, {
  Map<String, dynamic>? data,
  bool debug = false,
  bool alertOnError = false,
}) async {
  data = data ?? <String, dynamic>{};
  data['method'] = method;

  final url = PhilgoConfig.v7ApiEndpoint;

  try {
    // Firebase ID Token 자동 추가 (기존 patchToken() 재사용)
    data = await patchToken(data);

    if (debug) {
      final stringParams = data.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
      log(
        'v7 GET URL: $url?${Uri(queryParameters: stringParams).query}',
        name: 'v7api::$method',
      );
    }

    // Dio 인스턴스 생성 (기존 createDio() 재사용 — 디버그 SSL 무시 포함)
    final dio = createDio();

    // HTTP POST 요청
    final response = await dio.post(url, data: data);

    final responseData = response.data;
    Map<String, dynamic> json;

    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw Exception(
        'v7api($method) 예상치 못한 응답 타입: ${responseData.runtimeType}',
      );
    }

    // v7 에러 판별: success == false일 때만 에러
    if (json['success'] == false) {
      final errorMessage = json['message'] ?? '알 수 없는 오류';
      if (alertOnError) {
        showSafeErrorDialog('v7 API 오류: $errorMessage');
      }
      throw Exception('v7api($method): $errorMessage');
    }

    return json;
  } on DioException catch (dioError) {
    // DioException 상세 로깅
    log('========== v7 API 에러 발생 ==========', name: 'v7API:ERROR');
    log('method: $method', name: 'v7API:ERROR');
    log('요청 데이터: $data', name: 'v7API:ERROR');
    log('요청 URL: $url', name: 'v7API:ERROR');
    log('에러 타입: ${dioError.type}', name: 'v7API:ERROR');
    log('에러 메시지: ${dioError.message}', name: 'v7API:ERROR');
    log('==========================================', name: 'v7API:ERROR');

    // Handshake 에러 (서버 접속 실패, SSL 인증서 검증 실패)
    if (dioError.message?.contains('Handshake') ?? false) {
      final userMessage = '서버와 접속이 안됩니다. 인터넷 연결을 확인해 주세요.';
      if (alertOnError) showSafeErrorDialog(userMessage);
      throw Exception(userMessage);
    }

    if (alertOnError) {
      showSafeErrorDialog('v7 서버와 통신 중 오류가 발생했습니다.');
    }
    rethrow;
  } catch (e) {
    // 일반 에러 로깅
    log('========== v7 API 일반 에러 ==========', name: 'v7API:ERROR');
    log('method: $method', name: 'v7API:ERROR');
    log('에러: $e', name: 'v7API:ERROR');
    log('==========================================', name: 'v7API:ERROR');
    rethrow;
  }
}

/// v7 API 파일 업로드 함수
///
/// 필고 v7 서버(api.php)에 multipart/form-data로 파일을 업로드한다.
/// upload.upload 엔드포인트를 사용하며, 기존 createDio(), patchToken()을 재사용.
///
/// [filePath] - 업로드할 로컬 파일 경로
/// [idxMember] - 회원번호 (필수)
/// [module] - 모듈명 (선택, 예: 'receipt')
/// [code] - 코드 (선택)
/// [extraData] - FormData에 추가할 임의의 필드 (예: company_idx, receipt_name 등)
/// [onProgress] - 업로드 진행률 콜백 (0.0 ~ 1.0)
/// [debug] - 디버그 모드
///
/// 반환값: v7 upload.upload 응답 Map
/// - 성공: {idx, idx_member, name, size, type, module, code, url, ...}
/// - 에러: Exception throw
///
/// 사용 예시:
/// ```dart
/// final result = await v7apiFileUpload(
///   filePath: '/path/to/receipt.jpg',
///   idxMember: '123',
///   module: 'receipt',
///   extraData: {'company_idx': '456', 'receipt_name': 'ABC'},
///   onProgress: (p) => print('${(p * 100).toInt()}%'),
/// );
/// print(result['url']); // /uploads/123/unique_file.jpg
/// ```
Future<V7UploadModel> v7apiFileUpload({
  required String filePath,
  required String idxMember,
  String method = 'upload.upload',
  String? module,
  String? code,
  Map<String, dynamic>? extraData,
  void Function(double progress)? onProgress,
  bool debug = false,
}) async {
  final url = PhilgoConfig.v7ApiEndpoint;

  try {
    // Firebase ID Token 추출 (patchToken 재사용)
    final tokenData = await patchToken(<String, dynamic>{});
    final idToken = tokenData['id_token']?.toString() ?? '';

    // 파일 객체 생성
    final file = File(filePath);
    final fileName = file.path.split('/').last;

    // FormData 생성 (multipart/form-data)
    final formData = FormData.fromMap({
      'method': method,
      'idx_member': idxMember,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
      if (idToken.isNotEmpty) 'id_token': idToken,
      if (module != null) 'module': module,
      if (code != null) 'code': code,
      ...?extraData,
    });

    if (debug) {
      log(
        'v7 업로드: $url (파일: $fileName, 회원: $idxMember, 모듈: $module)',
        name: 'v7apiFileUpload',
      );
    }

    // Dio 인스턴스 생성 (기존 createDio() 재사용 — 디버그 SSL 무시 포함)
    final dio = createDio();

    // multipart/form-data POST 요청
    final response = await dio.post(
      url,
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

    // 응답 파싱
    final responseData = response.data;
    Map<String, dynamic> json;

    if (responseData is Map<String, dynamic>) {
      json = responseData;
    } else if (responseData is String) {
      json = jsonDecode(responseData) as Map<String, dynamic>;
    } else {
      throw Exception(
        'v7apiFileUpload 예상치 못한 응답 타입: ${responseData.runtimeType}',
      );
    }

    // v7 에러 판별: success == false일 때만 에러
    if (json['success'] == false) {
      final errorMessage = json['message'] ?? '알 수 없는 업로드 오류';
      throw Exception('v7apiFileUpload: $errorMessage');
    }

    final result = V7UploadModel.fromJson(json);

    if (debug) {
      log('v7 업로드 성공: ${result.url}', name: 'v7apiFileUpload');
    }

    return result;
  } on DioException catch (dioError) {
    log('v7 파일 업로드 DioException: ${dioError.message}',
        name: 'v7apiFileUpload:ERROR');
    rethrow;
  } catch (e) {
    log('v7 파일 업로드 에러: $e', name: 'v7apiFileUpload:ERROR');
    rethrow;
  }
}
