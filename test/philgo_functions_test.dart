/// parsePhilgoUrl 함수 Unit Test
/// Unit Test for parsePhilgoUrl function
///
/// 참고: https://docs.flutter.dev/cookbook/testing/unit/introduction
/// Reference: https://docs.flutter.dev/cookbook/testing/unit/introduction
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:philgo_api/src/philgo.functions.dart';

void main() {
  /// parsePhilgoUrl 함수 테스트 그룹
  /// Test group for parsePhilgoUrl function
  group('parsePhilgoUrl', () {
    /// 테스트 1: 모든 파라미터가 있는 일반 URL 파싱
    /// Test 1: Parse normal URL with all parameters
    test('모든 파라미터가 있는 URL 파싱', () {
      final url =
          'https://philgo.com/post/view.php?idx=1275688865&post_id=freetalk&page=1';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 1275688865);
      expect(result.postId, 'freetalk');
      expect(result.page, 1);
      expect(result.category, isNull);
    });

    /// 테스트 2: category가 포함된 URL 파싱
    /// Test 2: Parse URL with category parameter
    test('category가 포함된 URL 파싱', () {
      final url =
          'https://philgo.com/post/view.php?idx=1275674044&post_id=freetalk&category=%EC%B7%A8%EB%AF%B8&page=1';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 1275674044);
      expect(result.postId, 'freetalk');

      /// URL 인코딩된 '취미'가 자동으로 디코딩됨
      /// URL encoded '취미' is automatically decoded
      expect(result.category, '취미');
      expect(result.page, 1);
    });

    /// 테스트 3: 특수 패턴 URL 파싱 (?뒤에 숫자만 있는 경우)
    /// Test 3: Parse special pattern URL (only digits after ?)
    test('특수 패턴 URL 파싱 (?숫자)', () {
      final url = 'https://philgo.com/?1275666415';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 1275666415);
      expect(result.postId, isNull);
      expect(result.category, isNull);
      expect(result.page, isNull);
    });

    /// 테스트 4: idx만 있는 URL 파싱
    /// Test 4: Parse URL with only idx parameter
    test('idx만 있는 URL 파싱', () {
      final url = 'https://philgo.com/post/view.php?idx=12345';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 12345);
      expect(result.postId, isNull);
      expect(result.category, isNull);
      expect(result.page, isNull);
    });

    /// 테스트 5: post_id만 있는 URL 파싱
    /// Test 5: Parse URL with only post_id parameter
    test('post_id만 있는 URL 파싱', () {
      final url = 'https://philgo.com/post/list.php?post_id=qna';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, isNull);
      expect(result.postId, 'qna');
      expect(result.category, isNull);
      expect(result.page, isNull);
    });

    /// 테스트 6: page만 있는 URL 파싱
    /// Test 6: Parse URL with only page parameter
    test('page만 있는 URL 파싱', () {
      final url = 'https://philgo.com/some/page.php?page=5';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, isNull);
      expect(result.postId, isNull);
      expect(result.category, isNull);
      expect(result.page, 5);
    });

    /// 테스트 7: 쿼리 파라미터가 없는 URL 파싱
    /// Test 7: Parse URL without query parameters
    test('쿼리 파라미터가 없는 URL 파싱', () {
      final url = 'https://philgo.com/post/view.php';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, isNull);
      expect(result.postId, isNull);
      expect(result.category, isNull);
      expect(result.page, isNull);
    });

    /// 테스트 8: 빈 문자열 URL 파싱
    /// Test 8: Parse empty string URL
    test('빈 문자열 URL 파싱', () {
      final url = '';
      final result = parsePhilgoUrl(url);

      /// 빈 문자열도 유효한 URI로 파싱됨 (모든 필드 null)
      /// Empty string is also parsed as valid URI (all fields null)
      expect(result, isNotNull);
      expect(result!.idx, isNull);
      expect(result.postId, isNull);
      expect(result.category, isNull);
      expect(result.page, isNull);
    });

    /// 테스트 9: 숫자가 아닌 idx 값 처리
    /// Test 9: Handle non-numeric idx value
    test('숫자가 아닌 idx 값 처리', () {
      final url = 'https://philgo.com/post/view.php?idx=abc&post_id=freetalk';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// int.tryParse가 null 반환
      /// int.tryParse returns null
      expect(result!.idx, isNull);
      expect(result.postId, 'freetalk');
    });

    /// 테스트 10: 숫자가 아닌 page 값 처리
    /// Test 10: Handle non-numeric page value
    test('숫자가 아닌 page 값 처리', () {
      final url = 'https://philgo.com/post/view.php?page=abc';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// int.tryParse가 null 반환
      /// int.tryParse returns null
      expect(result!.page, isNull);
    });

    /// 테스트 11: 여러 개의 동일한 파라미터 처리
    /// Test 11: Handle multiple same parameters (uses last value)
    test('여러 개의 동일한 파라미터 처리', () {
      final url = 'https://philgo.com/post/view.php?idx=111&idx=222';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// queryParameters는 마지막 값을 반환
      /// queryParameters returns the last value
      expect(result!.idx, 222);
    });

    /// 테스트 12: URL 인코딩된 한글 category 파싱
    /// Test 12: Parse URL encoded Korean category
    test('URL 인코딩된 한글 category 파싱', () {
      final url =
          'https://philgo.com/post/list.php?post_id=buyandsell&category=%ED%98%B8%ED%85%94';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.postId, 'buyandsell');

      /// URL 인코딩된 '호텔'이 자동으로 디코딩됨
      /// URL encoded '호텔' is automatically decoded
      expect(result.category, '호텔');
    });

    /// 테스트 13: 상대 경로 URL 파싱
    /// Test 13: Parse relative path URL
    test('상대 경로 URL 파싱', () {
      final url = '/post/view.php?idx=12345&post_id=freetalk';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 12345);
      expect(result.postId, 'freetalk');
    });

    /// 테스트 14: 특수 패턴과 일반 파라미터가 섞인 경우
    /// Test 14: Mixed special pattern with normal parameters (normal takes priority)
    test('idx 파라미터가 있으면 특수 패턴 무시', () {
      final url = 'https://philgo.com/?idx=999&post_id=test';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// idx= 파라미터가 우선
      /// idx= parameter takes priority
      expect(result!.idx, 999);
      expect(result.postId, 'test');
    });

    /// 테스트 15: 매우 큰 숫자 idx 처리
    /// Test 15: Handle very large number idx
    test('매우 큰 숫자 idx 처리', () {
      final url = 'https://philgo.com/?9999999999';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);
      expect(result!.idx, 9999999999);
    });

    /// 테스트 16: 음수 idx 처리 (특수 패턴에서는 무시됨)
    /// Test 16: Handle negative idx (ignored in special pattern)
    test('음수 idx는 특수 패턴으로 인식 안됨', () {
      final url = 'https://philgo.com/?-12345';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// 음수는 ^\d+$ 패턴에 매칭되지 않음
      /// Negative numbers don't match ^\d+$ pattern
      expect(result!.idx, isNull);
    });

    /// 테스트 17: 일반 idx 파라미터에서 음수 처리
    /// Test 17: Handle negative idx in normal parameter
    test('일반 idx 파라미터에서 음수 처리', () {
      final url = 'https://philgo.com/post/view.php?idx=-12345';
      final result = parsePhilgoUrl(url);

      expect(result, isNotNull);

      /// int.tryParse는 음수도 파싱 가능
      /// int.tryParse can parse negative numbers
      expect(result!.idx, -12345);
    });
  });
}
