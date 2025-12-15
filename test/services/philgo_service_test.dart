/// PhilgoService.loadSetting() 유닛 테스트
/// Unit Test for PhilgoService.loadSetting() method
///
/// 이 테스트는 PhilgoSetting 모델이 올바르게 파싱되는지 확인합니다.
/// 실제 API 호출 테스트는 scripts/test_philgo_setting.dart를 참조하세요.
///
/// This test verifies that the PhilgoSetting model is correctly parsed.
/// For actual API call tests, see scripts/test_philgo_setting.dart.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:philgo/services/philgo/philgo.setting.model.dart';

void main() {

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
}
