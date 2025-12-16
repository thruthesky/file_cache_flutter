/// PhilGo API 호출을 위한 최소 의존성 함수
///
/// 이 파일은 Unit Test를 용이하게 하기 위해 최소한의 의존성으로
/// PhilGo PHP API 서버에 접속하여 데이터를 송/수신합니다.
///
/// 의존성:
/// - dart:io (HttpClient) - Dart 표준 라이브러리
/// - dart:convert (jsonDecode, utf8) - Dart 표준 라이브러리
///
/// 제거된 의존성:
/// - Dio 패키지 → dart:io HttpClient로 대체
/// - Firebase Auth (patchToken) → tokenId 옵션 파라미터로 대체
/// - PhilgoConfig → apiServerUrl 필수 파라미터로 대체
/// - UI 관련 함수 (showSafeErrorDialog) → 제거
///
/// 사용 예시:
/// ```dart
/// // 기본 사용 (토큰 없이)
/// final result = await apiCall(
///   'setting',
///   apiServerUrl: 'https://philgo.com/func.php',
/// );
///
/// // tokenId 파라미터로 직접 토큰 전달
/// final result = await apiCall(
///   'user.my',
///   apiServerUrl: 'https://philgo.com/func.php',
///   tokenId: await FirebaseAuth.instance.currentUser?.getIdToken(),
/// );
/// ```
library;

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

/// 토큰 패처 함수 타입 정의
///
/// 이 함수는 API 요청 데이터에 인증 토큰을 추가하는 역할을 합니다.
/// Firebase ID Token 또는 다른 인증 토큰을 추가할 때 사용합니다.
///
/// [data] 요청 데이터 맵
/// 반환값: 토큰이 추가된 요청 데이터 맵
typedef TokenPatcher = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> data,
);

/// PhilGo PHP API 서버에 최소 의존성으로 접속하여 데이터를 송/수신하는 함수
///
/// 이 함수는 Unit Test를 용이하게 하기 위해 설계되었습니다.
/// - Dio 대신 dart:io HttpClient 사용
/// - Firebase 의존성을 옵션 파라미터 [tokenId]로 대체
/// - PhilgoConfig 의존성을 필수 파라미터 [apiServerUrl]로 대체
/// - UI 관련 코드 제거 (alertOnError 옵션 제거)
///
/// [functionName] 호출할 PhilGo API 함수 이름 (예: 'setting', 'user.my')
/// [apiServerUrl] API 서버 URL (필수) - 예: 'https://philgo.com/func.php'
/// [data] 전송할 데이터 맵 (옵션)
/// [tokenId] 인증 토큰 (옵션) - Firebase ID Token 또는 다른 인증 토큰
/// [tokenPatcher] 토큰 패처 함수 (옵션) - 동적으로 토큰을 생성해야 하는 경우 사용
/// [debug] 디버그 모드 활성화 여부 (기본값: false)
///
/// 반환값: API 응답 JSON 맵
///
/// 예외:
/// - [Exception] HTTP 상태 코드가 200이 아닌 경우
/// - [Exception] JSON 파싱 실패 시
/// - [Exception] 네트워크 연결 실패 시
///
/// 사용 예시 1 - tokenId 직접 전달:
/// ```dart
/// final result = await apiCall(
///   'user.my',
///   apiServerUrl: 'https://philgo.com/func.php',
///   tokenId: await FirebaseAuth.instance.currentUser?.getIdToken(),
/// );
/// ```
///
/// 사용 예시 2 - tokenPatcher 사용:
/// ```dart
/// final result = await apiCall(
///   'user.my',
///   apiServerUrl: 'https://philgo.com/func.php',
///   tokenPatcher: (data) async {
///     data['id_token'] = await getToken();
///     return data;
///   },
/// );
/// ```
Future<Map<String, dynamic>> apiCall(
  String functionName, {
  required String apiServerUrl,
  Map<String, dynamic>? data,
  String? tokenId,
  TokenPatcher? tokenPatcher,
  bool debug = false,
}) async {
  // 1. 요청 데이터 초기화
  // 전달받은 data가 null이면 빈 맵으로 초기화
  final requestData = data ?? <String, dynamic>{};

  // API 함수 이름 추가
  requestData['func'] = functionName;

  // 2. 토큰 추가
  // tokenId가 직접 제공된 경우 우선 사용
  if (tokenId != null && tokenId.isNotEmpty) {
    requestData['id_token'] = tokenId;
  }

  // tokenPatcher가 제공된 경우 추가 토큰 처리
  // Firebase Auth 또는 다른 인증 토큰을 동적으로 추가할 수 있습니다.
  Map<String, dynamic> finalData = requestData;
  if (tokenPatcher != null) {
    finalData = await tokenPatcher(requestData);
  }

  // 3. API URL 사용
  // apiServerUrl은 필수 파라미터로 전달받음
  final url = apiServerUrl;

  // 4. 디버그 모드일 때 요청 정보 로깅
  if (debug) {
    final stringParams = finalData.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );
    log(
      'apiCall() 요청: $url?${Uri(queryParameters: stringParams).query}',
      name: 'apiCall::$functionName',
    );
  }

  // 5. HttpClient를 사용하여 HTTP POST 요청 수행
  // dart:io의 HttpClient는 Flutter 테스트 환경에서도 사용 가능
  final client = HttpClient();

  try {
    // POST 요청 생성
    final request = await client.postUrl(Uri.parse(url));

    // Content-Type 헤더 설정 (application/x-www-form-urlencoded)
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
    );

    // 요청 본문 작성 (URL 인코딩된 폼 데이터)
    // key1=value1&key2=value2 형식으로 변환
    final body = finalData.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value?.toString() ?? '')}',
        )
        .join('&');
    request.write(body);

    // 6. 요청 전송 및 응답 수신
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    // 7. HTTP 상태 코드 검증
    if (response.statusCode != 200) {
      final errorMessage =
          'HTTP ${response.statusCode}: ${response.reasonPhrase}\n'
          '응답: $responseBody';
      log(
        'apiCall() 에러: $errorMessage',
        name: 'apiCall::$functionName',
      );
      throw Exception(errorMessage);
    }

    // 8. JSON 파싱
    Map<String, dynamic> json;
    try {
      json = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      log(
        'apiCall() JSON 파싱 에러: $e\n응답: $responseBody',
        name: 'apiCall::$functionName',
      );
      throw Exception('JSON 파싱 실패: $e\n응답: $responseBody');
    }

    // 9. 디버그 모드일 때 응답 로깅
    if (debug) {
      log(
        'apiCall() 응답: $json',
        name: 'apiCall::$functionName',
      );
    }

    // 10. API 소프트 에러 처리
    // PhilGo API는 에러를 {'error': '...', 'message': '...'} 형태로 반환
    // 이 경우에도 데이터를 반환하여 호출자가 처리하도록 함
    if (json['error'] != null && debug) {
      log(
        'apiCall() API 에러: ${json['error']} - ${json['message']}',
        name: 'apiCall::$functionName',
      );
    }

    return json;
  } catch (e) {
    // 네트워크 에러, 타임아웃 등 예외 처리
    log(
      'apiCall() 예외: $e',
      name: 'apiCall::$functionName',
    );
    rethrow;
  } finally {
    // HttpClient 리소스 해제
    client.close();
  }
}

/// Mock 토큰 패처 생성 함수 (테스트용)
///
/// Unit Test에서 인증이 필요한 API를 테스트할 때 사용합니다.
/// 실제 Firebase 인증 대신 테스트용 토큰을 사용합니다.
///
/// [mockToken] 테스트용 토큰 값 (기본값: 'test_token')
///
/// 사용 예시:
/// ```dart
/// // Unit Test에서 사용
/// final result = await apiCall(
///   'user.my',
///   apiServerUrl: 'https://philgo.com/func.php',
///   tokenPatcher: createMockTokenPatcher('my_test_token'),
/// );
/// ```
TokenPatcher createMockTokenPatcher([String mockToken = 'test_token']) {
  return (data) async {
    data['id_token'] = mockToken;
    return data;
  };
}
