/// PhilgoService.loadSetting() 유닛 테스트
/// Unit Test for PhilgoService.loadSetting() method
///
/// 이 테스트는 PhilgoSetting 모델이 올바르게 파싱되는지 확인합니다.
///
/// This test verifies that the PhilgoSetting model is correctly parsed.
///
/// 실행 방법 (How to run):
/// ```bash
/// flutter test test/services/philgo_service_test.dart
/// ```
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:philgo/services/philgo/philgo.service.dart';
import 'package:philgo/services/philgo/philgo.setting.model.dart';

void main() {
  /// PhilgoService.loadSetting() 테스트 그룹
  /// Test group for PhilgoService.loadSetting()
  group('PhilgoService.loadSetting() 테스트', () {
    /// 테스트 1: loadSetting() API 호출 및 응답 검증
    /// Test 1: Call loadSetting() and verify response
    test('loadSetting() API 호출 성공', () async {
      // Act: PhilgoService.instance.loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: PhilgoSetting 타입인지 확인
      expect(setting, isA<PhilgoSetting>());
    });

    /// 테스트 2: PhilgoSettingPoint 객체 검증
    /// Test 2: Verify PhilgoSettingPoint object
    test('PhilgoSettingPoint 객체 검증', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: point 필드가 PhilgoSettingPoint 타입인지 확인
      expect(setting.point, isA<PhilgoSettingPoint>());
    });

    /// 테스트 3: advertising_post_categories 필드 검증
    /// Test 3: Verify advertising_post_categories field
    test('advertising_post_categories 필드가 List<String>인지 확인', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advertising_post_categories가 List<String>인지 확인
      expect(setting.point.advertising_post_categories, isA<List<String>>());
    });

    /// 테스트 4: advertising_post_categories가 비어있지 않은지 확인
    /// Test 4: Verify advertising_post_categories is not empty
    test('advertising_post_categories가 비어있지 않음', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advertising_post_categories가 비어있지 않은지 확인
      expect(setting.point.advertising_post_categories, isNotEmpty);
    });

    /// 테스트 5: 각 카테고리 항목이 유효한 String인지 확인
    /// Test 5: Verify each category item is valid String
    test('각 카테고리 항목이 비어있지 않은 String', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: 모든 항목이 비어있지 않은 String인지 확인
      for (final category in setting.point.advertising_post_categories) {
        expect(category, isA<String>());
        expect(category, isNotEmpty);
      }
    });
  });

  /// PhilgoSetting 모델 파싱 테스트 그룹
  /// Test group for PhilgoSetting model parsing
  group('PhilgoSetting 모델 파싱', () {
    /// 테스트 6: 유효한 JSON 데이터로 PhilgoSetting 생성
    /// Test 6: Create PhilgoSetting from valid JSON data
    test('유효한 JSON 데이터로 PhilgoSetting 생성', () {
      // Arrange: 테스트용 JSON 데이터 생성
      // Arrange: Create test JSON data
      final json = {
        'point': {
          'advertising_post_categories': ['freetalk', 'buyandsell', 'job'],
        },
      };

      // Act: PhilgoSetting 객체 생성
      // Act: Create PhilgoSetting object
      final setting = PhilgoSetting(json);

      // Assert: 데이터가 올바르게 파싱되었는지 확인
      // Assert: Verify data is correctly parsed
      expect(setting.point, isA<PhilgoSettingPoint>());
      expect(setting.point.advertising_post_categories, hasLength(3));
      expect(
        setting.point.advertising_post_categories,
        containsAll(['freetalk', 'buyandsell', 'job']),
      );
    });

    /// 테스트 7: 빈 배열로 PhilgoSettingPoint 생성
    /// Test 7: Create PhilgoSettingPoint with empty array
    test('빈 배열로 PhilgoSettingPoint 생성', () {
      // Arrange: 빈 배열이 포함된 JSON 데이터
      // Arrange: JSON data with empty array
      final json = {
        'point': {
          'advertising_post_categories': <String>[],
        },
      };

      // Act: PhilgoSetting 객체 생성
      // Act: Create PhilgoSetting object
      final setting = PhilgoSetting(json);

      // Assert: 빈 배열이 올바르게 파싱되는지 확인
      // Assert: Verify empty array is correctly parsed
      expect(setting.point.advertising_post_categories, isEmpty);
    });

    /// 테스트 8: 단일 항목 배열로 PhilgoSettingPoint 생성
    /// Test 8: Create PhilgoSettingPoint with single item array
    test('단일 항목 배열로 PhilgoSettingPoint 생성', () {
      // Arrange: 단일 항목 배열이 포함된 JSON 데이터
      // Arrange: JSON data with single item array
      final json = {
        'point': {
          'advertising_post_categories': ['freetalk'],
        },
      };

      // Act: PhilgoSetting 객체 생성
      // Act: Create PhilgoSetting object
      final setting = PhilgoSetting(json);

      // Assert: 단일 항목이 올바르게 파싱되는지 확인
      // Assert: Verify single item is correctly parsed
      expect(setting.point.advertising_post_categories, hasLength(1));
      expect(setting.point.advertising_post_categories.first, 'freetalk');
    });

    /// 테스트 9: 한글 카테고리명이 포함된 데이터 파싱
    /// Test 9: Parse data with Korean category names
    test('한글 카테고리명이 포함된 데이터 파싱', () {
      // Arrange: 한글이 포함된 JSON 데이터
      // Arrange: JSON data with Korean text
      final json = {
        'point': {
          'advertising_post_categories': ['자유게시판', '사고팔고', '구인구직'],
        },
      };

      // Act: PhilgoSetting 객체 생성
      // Act: Create PhilgoSetting object
      final setting = PhilgoSetting(json);

      // Assert: 한글이 올바르게 파싱되는지 확인
      // Assert: Verify Korean text is correctly parsed
      expect(setting.point.advertising_post_categories, hasLength(3));
      expect(
        setting.point.advertising_post_categories,
        containsAll(['자유게시판', '사고팔고', '구인구직']),
      );
    });
  });

  /// toJson() 및 toString() 테스트 그룹
  /// Test group for toJson() and toString() methods
  group('toJson() 및 toString() 테스트', () {
    /// 테스트 10: PhilgoSettingPoint.toJson() 테스트
    /// Test 10: PhilgoSettingPoint.toJson() test
    test('PhilgoSettingPoint.toJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final pointJson = {
        'advertising_post_categories': ['freetalk', 'buyandsell'],
      };

      // Act: PhilgoSettingPoint 생성 후 toJson() 호출
      final point = PhilgoSettingPoint(pointJson);
      final result = point.toJson();

      // Assert: toJson() 결과 검증
      expect(result, isA<Map>());
      expect(result['advertising_post_categories'], isA<List<String>>());
      expect(result['advertising_post_categories'], hasLength(2));
      expect(result['advertising_post_categories'], contains('freetalk'));
      expect(result['advertising_post_categories'], contains('buyandsell'));
    });

    /// 테스트 11: PhilgoSettingPoint.toString() 테스트
    /// Test 11: PhilgoSettingPoint.toString() test
    test('PhilgoSettingPoint.toString() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final pointJson = {
        'advertising_post_categories': ['freetalk', 'buyandsell'],
      };

      // Act: PhilgoSettingPoint 생성 후 toString() 호출
      final point = PhilgoSettingPoint(pointJson);
      final result = point.toString();

      // Assert: toString() 결과가 JSON 문자열인지 검증
      expect(result, isA<String>());
      expect(result, contains('advertising_post_categories'));
      expect(result, contains('freetalk'));
      expect(result, contains('buyandsell'));
    });

    /// 테스트 12: PhilgoSetting.toJson() 테스트
    /// Test 12: PhilgoSetting.toJson() test
    test('PhilgoSetting.toJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'point': {
          'advertising_post_categories': ['job', 'rent'],
        },
      };

      // Act: PhilgoSetting 생성 후 toJson() 호출
      final setting = PhilgoSetting(json);
      final result = setting.toJson();

      // Assert: toJson() 결과 검증
      expect(result, isA<Map>());
      expect(result['point'], isA<Map>());
      expect(result['point']['advertising_post_categories'], hasLength(2));
    });

    /// 테스트 13: PhilgoSetting.toString() 테스트
    /// Test 13: PhilgoSetting.toString() test
    test('PhilgoSetting.toString() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'point': {
          'advertising_post_categories': ['job', 'rent'],
        },
      };

      // Act: PhilgoSetting 생성 후 toString() 호출
      final setting = PhilgoSetting(json);
      final result = setting.toString();

      // Assert: toString() 결과가 올바른 형식인지 검증
      expect(result, isA<String>());
      expect(result, startsWith('PhilgoSetting('));
      expect(result, contains('point'));
    });

    /// 테스트 14: 실제 API 데이터로 toJson()/toString() 테스트
    /// Test 14: toJson()/toString() test with real API data
    test('실제 API 데이터로 toJson() 및 toString() 테스트', () async {
      // Act: 실제 API 호출
      final setting = await PhilgoService.instance.loadSetting();

      // toJson() 테스트
      final jsonResult = setting.toJson();
      expect(jsonResult, isA<Map>());
      expect(jsonResult['point'], isNotNull);

      // toString() 테스트
      final stringResult = setting.toString();
      expect(stringResult, isA<String>());
      expect(stringResult, startsWith('PhilgoSetting('));
      expect(stringResult.length, greaterThan(20));
    });

    /// 테스트 15: 빈 배열로 toJson()/toString() 테스트
    /// Test 15: toJson()/toString() test with empty array
    test('빈 배열로 toJson() 및 toString() 테스트', () {
      // Arrange: 빈 배열 데이터
      final json = {
        'point': {
          'advertising_post_categories': <String>[],
        },
      };

      // Act: PhilgoSetting 생성
      final setting = PhilgoSetting(json);

      // Assert: toJson() 검증
      final jsonResult = setting.toJson();
      expect(jsonResult['point']['advertising_post_categories'], isEmpty);

      // Assert: toString() 검증
      final stringResult = setting.toString();
      expect(stringResult, contains('PhilgoSetting'));
    });

    /// 테스트 16: 한글 데이터로 toJson()/toString() 테스트
    /// Test 16: toJson()/toString() test with Korean data
    test('한글 데이터로 toJson() 및 toString() 테스트', () {
      // Arrange: 한글 데이터
      final json = {
        'point': {
          'advertising_post_categories': ['자유게시판', '사고팔고'],
        },
      };

      // Act: PhilgoSetting 생성
      final setting = PhilgoSetting(json);

      // Assert: toJson() 검증 - 한글이 올바르게 유지되는지
      final jsonResult = setting.toJson();
      expect(
        jsonResult['point']['advertising_post_categories'],
        contains('자유게시판'),
      );

      // Assert: toString() 검증 - 한글이 포함되어 있는지
      final stringResult = setting.toString();
      expect(stringResult, isA<String>());
    });
  });
}
