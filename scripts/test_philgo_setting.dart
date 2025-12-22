/// PhilgoService.loadSetting() API 호출 테스트
/// API call test for PhilgoService.loadSetting()
///
/// 이 스크립트는 실제 PhilGo API를 호출하여 setting 데이터를 가져오고
/// PhilgoSetting 모델로 올바르게 파싱되는지 검증합니다.
///
/// This script calls the actual PhilGo API to fetch setting data
/// and verifies it is correctly parsed into the PhilgoSetting model.
///
/// 실행 방법 (How to run):
/// ```bash
/// dart scripts/test_philgo_setting.dart
/// ```
library;

import 'dart:convert';
import 'dart:io';

/// PhilgoSettingPoint 모델 (테스트용 복사본)
/// PhilgoSettingPoint model (copy for testing)
class PhilgoSettingPoint {
  late final List<String> advertising_post_categories;

  PhilgoSettingPoint(Map<dynamic, dynamic> point) {
    advertising_post_categories = List<String>.from(
      point['advertising_post_categories'],
    );
  }
}

/// PhilgoSetting 모델 (테스트용 복사본)
/// PhilgoSetting model (copy for testing)
class PhilgoSetting {
  late final PhilgoSettingPoint point;

  PhilgoSetting(Map<dynamic, dynamic> json) {
    point = PhilgoSettingPoint(json['point']);
  }
}

/// 테스트 결과 출력 헬퍼 함수
/// Helper function to print test results
void printResult(String testName, bool passed, [String? details]) {
  final status = passed ? '✅ PASS' : '❌ FAIL';
  // print('$status: $testName');
  if (details != null) {
    // print('   $details');
  }
}

/// 메인 테스트 함수
/// Main test function
Future<void> main() async {
  // print('=' * 60);
  // print('PhilgoService.loadSetting() API 테스트');
  // print('=' * 60);
  // print('');

  int passCount = 0;
  int failCount = 0;

  try {
    // API 호출
    // Call API
    // print('🔄 API 호출 중... (https://philgo.com/func.php)');

    final client = HttpClient();
    final request = await client.postUrl(
      Uri.parse('https://philgo.com/func.php'),
    );

    // Content-Type 설정
    // Set Content-Type
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
    );

    // 요청 본문 작성
    // Write request body
    request.write('func=setting');

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    // print('');

    // 테스트 1: HTTP 응답 상태 코드 확인
    // Test 1: Verify HTTP response status code
    final test1Passed = response.statusCode == 200;
    printResult(
      'HTTP 응답 상태 코드 확인',
      test1Passed,
      'Expected: 200, Actual: ${response.statusCode}',
    );
    test1Passed ? passCount++ : failCount++;

    if (!test1Passed) {
      // print('\n❌ API 호출 실패. 테스트 중단.');
      // print('응답 본문: $responseBody');
      exit(1);
    }

    // JSON 파싱
    // Parse JSON
    final json = jsonDecode(responseBody) as Map<String, dynamic>;

    // 테스트 2: JSON에 'point' 필드가 있는지 확인
    // Test 2: Verify JSON has 'point' field
    final test2Passed = json.containsKey('point');
    printResult(
      "JSON에 'point' 필드 존재 여부",
      test2Passed,
      'Keys: ${json.keys.toList()}',
    );
    test2Passed ? passCount++ : failCount++;

    if (!test2Passed) {
      // print('\n❌ JSON 구조가 예상과 다릅니다. 테스트 중단.');
      // print('응답 JSON: $json');
      exit(1);
    }

    // 테스트 3: PhilgoSetting 모델로 파싱
    // Test 3: Parse to PhilgoSetting model
    PhilgoSetting? setting;
    bool test3Passed = false;
    String? test3Error;

    try {
      setting = PhilgoSetting(json);
      test3Passed = true;
    } catch (e) {
      test3Error = e.toString();
    }

    printResult(
      'PhilgoSetting 모델 파싱',
      test3Passed,
      test3Passed ? '파싱 성공' : '에러: $test3Error',
    );
    test3Passed ? passCount++ : failCount++;

    if (!test3Passed || setting == null) {
      // print('\n❌ 모델 파싱 실패. 테스트 중단.');
      exit(1);
    }

    // 테스트 4: PhilgoSettingPoint 타입 확인
    // Test 4: Verify PhilgoSettingPoint type
    final test4Passed =
        setting.point.runtimeType.toString() == 'PhilgoSettingPoint';
    printResult(
      'PhilgoSettingPoint 타입 확인',
      test4Passed,
      'Type: ${setting.point.runtimeType}',
    );
    test4Passed ? passCount++ : failCount++;

    // 테스트 5: advertising_post_categories가 List<String>인지 확인
    // Test 5: Verify advertising_post_categories is List<String>
    final categories = setting.point.advertising_post_categories;
    final test5Passed = categories.runtimeType.toString().contains(
      'List<String>',
    );
    printResult(
      'advertising_post_categories 타입 확인',
      test5Passed,
      'Type: ${categories.runtimeType}',
    );
    test5Passed ? passCount++ : failCount++;

    // 테스트 6: advertising_post_categories가 비어있지 않은지 확인
    // Test 6: Verify advertising_post_categories is not empty
    final test6Passed = categories.isNotEmpty;
    printResult(
      'advertising_post_categories 비어있지 않음 확인',
      test6Passed,
      'Length: ${categories.length}',
    );
    test6Passed ? passCount++ : failCount++;

    // 테스트 7: 각 항목이 유효한 String인지 확인 (비어있지 않은 문자열)
    // Test 7: Verify each item is valid String (non-empty)
    bool test7Passed = true;
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      if (category.isEmpty) {
        test7Passed = false;
        break;
      }
    }
    printResult('각 카테고리 항목이 비어있지 않은 String인지 확인', test7Passed, '모든 항목 검증 완료');
    test7Passed ? passCount++ : failCount++;

    // 결과 출력
    // Print results
    // print('');
    // print('-' * 60);
    // print('📋 advertising_post_categories 내용:');
    for (int i = 0; i < categories.length; i++) {
      // print('   [$i] ${categories[i]}');
    }

    // print('');
    // print('=' * 60);
    // print('📊 테스트 결과 요약');
    // print('=' * 60);
    // print('✅ 통과: $passCount');
    // print('❌ 실패: $failCount');
    // print('📈 총계: ${passCount + failCount}');
    // print('');

    client.close();

    if (failCount == 0) {
      // print('🎉 모든 테스트 통과!');
      exit(0);
    } else {
      // print('⚠️ 일부 테스트 실패');
      exit(1);
    }
  } catch (e, stackTrace) {
    // print('');
    // print('❌ 테스트 중 예외 발생:');
    // print('   에러: $e');
    // print('   스택트레이스: $stackTrace');
    exit(1);
  }
}
