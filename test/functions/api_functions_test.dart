/// apiCall() 함수 Unit Test
///
/// 이 테스트는 최소 의존성 API 호출 함수인 apiCall()을 검증합니다.
/// 실제 PhilGo API를 호출하여 데이터가 올바르게 파싱되는지 확인합니다.
///
/// 테스트 항목:
/// 1. 기본 API 호출 테스트 (setting API)
/// 2. tokenId 파라미터 테스트
/// 3. tokenPatcher 동작 테스트
/// 4. Mock 토큰 패처 테스트
/// 5. 디버그 모드 테스트
///
/// 실행 방법:
/// ```bash
/// flutter test test/functions/api_functions_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:philgo/functions/api.functions.dart';

/// PhilGo API 기본 URL
const String philgoApiUrl = 'https://philgo.com/func.php';

void main() {
  /// apiCall() 함수 테스트 그룹
  group('apiCall() 테스트', () {
    /// 테스트 1: setting API 호출 및 응답 검증
    /// Test 1: Call setting API and verify response
    test('setting API 호출 성공', () async {
      // Act: API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
      );

      // Assert: 응답이 Map인지 확인
      expect(result, isA<Map<String, dynamic>>());

      // Assert: 'point' 필드가 있는지 확인
      expect(result.containsKey('point'), isTrue);
    });

    /// 테스트 2: tokenId 파라미터로 직접 토큰 전달 테스트
    /// Test 2: Verify tokenId parameter works correctly
    test('tokenId 파라미터로 직접 토큰 전달', () async {
      // Act: tokenId 파라미터와 함께 API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        tokenId: 'test_token_123',
      );

      // Assert: API 응답이 유효한지 확인
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('point'), isTrue);
    });

    /// 테스트 3: tokenPatcher로 동적 토큰 추가 테스트
    /// Test 3: Verify tokenPatcher works correctly
    test('tokenPatcher로 동적 토큰 추가', () async {
      // Arrange: 토큰 패처가 호출되었는지 확인하기 위한 플래그
      bool tokenPatcherCalled = false;
      String? addedToken;

      // Act: 토큰 패처와 함께 API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        tokenPatcher: (data) async {
          tokenPatcherCalled = true;
          data['id_token'] = 'dynamic_token_456';
          addedToken = data['id_token'] as String?;
          return data;
        },
      );

      // Assert: 토큰 패처가 호출되었는지 확인
      expect(tokenPatcherCalled, isTrue);
      expect(addedToken, equals('dynamic_token_456'));

      // Assert: API 응답이 여전히 유효한지 확인
      expect(result, isA<Map<String, dynamic>>());
    });

    /// 테스트 4: createMockTokenPatcher() 함수 테스트
    /// Test 4: Test createMockTokenPatcher() helper function
    test('createMockTokenPatcher() 헬퍼 함수 동작', () async {
      // Act: createMockTokenPatcher로 생성한 패처 사용
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        tokenPatcher: createMockTokenPatcher('my_custom_token'),
      );

      // Assert: API 응답이 유효한지 확인
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('point'), isTrue);
    });

    /// 테스트 5: 디버그 모드 테스트
    /// Test 5: Test debug mode logging
    test('디버그 모드 활성화 시 로그 출력', () async {
      // Act: 디버그 모드로 API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        debug: true,
      );

      // Assert: 디버그 모드에서도 정상 응답
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('point'), isTrue);
    });

    /// 테스트 6: 추가 데이터 전송 테스트
    /// Test 6: Test sending additional data
    test('추가 데이터와 함께 API 호출', () async {
      // Act: 추가 데이터와 함께 API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        data: {'extra_param': 'test_value'},
      );

      // Assert: API 응답이 유효한지 확인
      expect(result, isA<Map<String, dynamic>>());
    });

    /// 테스트 7: 잘못된 URL로 API 호출 시 예외 발생
    /// Test 7: API call with invalid URL throws exception
    test('잘못된 URL로 호출 시 예외 발생', () async {
      // Act & Assert: 잘못된 URL로 호출 시 예외 발생 확인
      expect(
        () async => apiCall(
          'setting',
          apiServerUrl: 'https://invalid.domain.that.does.not.exist.com/api',
        ),
        throwsException,
      );
    });
  });

  /// TokenPatcher 타입 테스트 그룹
  group('TokenPatcher 타입 테스트', () {
    /// 테스트 8: TokenPatcher가 async 함수로 동작하는지 확인
    /// Test 8: Verify TokenPatcher works as async function
    test('TokenPatcher가 비동기로 토큰 추가', () async {
      // Arrange: 비동기 토큰 패처 생성
      Future<Map<String, dynamic>> asyncTokenPatcher(
        Map<String, dynamic> data,
      ) async {
        // 비동기 작업 시뮬레이션
        await Future.delayed(const Duration(milliseconds: 10));
        data['id_token'] = 'async_token';
        return data;
      }

      // Act: 비동기 토큰 패처와 함께 API 호출
      final result = await apiCall(
        'setting',
        apiServerUrl: philgoApiUrl,
        tokenPatcher: asyncTokenPatcher,
      );

      // Assert: API 응답이 유효한지 확인
      expect(result, isA<Map<String, dynamic>>());
    });
  });
}
