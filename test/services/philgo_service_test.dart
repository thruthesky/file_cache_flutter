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
import 'package:philgo_api/philgo_api.dart';

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

    /// 테스트 3: advertisingPostCategories 필드 검증 (camelCase 사용)
    /// Test 3: Verify advertisingPostCategories field (using camelCase)
    test('advertisingPostCategories 필드가 List<String>인지 확인', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advertisingPostCategories가 List<String>인지 확인
      expect(setting.point.advertisingPostCategories, isA<List<String>>());
    });

    /// 테스트 4: advertisingPostCategories가 비어있지 않은지 확인
    /// Test 4: Verify advertisingPostCategories is not empty
    test('advertisingPostCategories가 비어있지 않음', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advertisingPostCategories가 비어있지 않은지 확인
      expect(setting.point.advertisingPostCategories, isNotEmpty);
    });

    /// 테스트 5: 각 카테고리 항목이 유효한 String인지 확인
    /// Test 5: Verify each category item is valid String
    test('각 카테고리 항목이 비어있지 않은 String', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: 모든 항목이 비어있지 않은 String인지 확인
      for (final category in setting.point.advertisingPostCategories) {
        expect(category, isA<String>());
        expect(category, isNotEmpty);
      }
    });

    /// 테스트 6: PhilgoSettingBankInfo 객체 검증
    /// Test 6: Verify PhilgoSettingBankInfo object
    test('PhilgoSettingBankInfo 객체 검증', () async {
      // Act: loadSetting() 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: bankInfo 필드가 PhilgoSettingBankInfo 타입인지 확인
      expect(setting.bankInfo, isA<PhilgoSettingBankInfo>());
    });
  });

  /// PhilgoSetting 모델 파싱 테스트 그룹
  /// Test group for PhilgoSetting model parsing
  group('PhilgoSetting 모델 파싱', () {
    /// 테스트 7: 유효한 JSON 데이터로 PhilgoSetting 생성 (fromJson 사용)
    /// Test 7: Create PhilgoSetting from valid JSON data (using fromJson)
    test('유효한 JSON 데이터로 PhilgoSetting 생성', () {
      // Arrange: 테스트용 JSON 데이터 생성 (실제 모델 구조에 맞게)
      // Arrange: Create test JSON data (matching actual model structure)
      final json = {
        'bank_info': {
          'kb': {
            'name': '국민은행',
            'account_no': '123-456-789',
            'account_name': '테스트',
          },
        },
        'point': {
          'advertising_post_categories': ['freetalk', 'buyandsell', 'job'],
          'advertisement_days': [3, 5, 7, 10],
          'adv_cost_per_hour': 100,
        },
      };

      // Act: PhilgoSetting.fromJson() 사용하여 객체 생성
      // Act: Create PhilgoSetting object using fromJson
      final setting = PhilgoSetting.fromJson(json);

      // Assert: 데이터가 올바르게 파싱되었는지 확인
      // Assert: Verify data is correctly parsed
      expect(setting.point, isA<PhilgoSettingPoint>());
      expect(setting.point.advertisingPostCategories, hasLength(3));
      expect(
        setting.point.advertisingPostCategories,
        containsAll(['freetalk', 'buyandsell', 'job']),
      );
    });

    /// 테스트 8: 빈 배열로 PhilgoSettingPoint 생성
    /// Test 8: Create PhilgoSettingPoint with empty array
    test('빈 배열로 PhilgoSettingPoint 생성', () {
      // Arrange: 빈 배열이 포함된 JSON 데이터
      // Arrange: JSON data with empty array
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': <String>[],
          'advertisement_days': <int>[],
          'adv_cost_per_hour': 0,
        },
      };

      // Act: PhilgoSetting.fromJson() 사용하여 객체 생성
      // Act: Create PhilgoSetting object using fromJson
      final setting = PhilgoSetting.fromJson(json);

      // Assert: 빈 배열이 올바르게 파싱되는지 확인
      // Assert: Verify empty array is correctly parsed
      expect(setting.point.advertisingPostCategories, isEmpty);
    });

    /// 테스트 9: 단일 항목 배열로 PhilgoSettingPoint 생성
    /// Test 9: Create PhilgoSettingPoint with single item array
    test('단일 항목 배열로 PhilgoSettingPoint 생성', () {
      // Arrange: 단일 항목 배열이 포함된 JSON 데이터
      // Arrange: JSON data with single item array
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': ['freetalk'],
          'advertisement_days': [7],
          'adv_cost_per_hour': 50,
        },
      };

      // Act: PhilgoSetting.fromJson() 사용하여 객체 생성
      // Act: Create PhilgoSetting object using fromJson
      final setting = PhilgoSetting.fromJson(json);

      // Assert: 단일 항목이 올바르게 파싱되는지 확인
      // Assert: Verify single item is correctly parsed
      expect(setting.point.advertisingPostCategories, hasLength(1));
      expect(setting.point.advertisingPostCategories.first, 'freetalk');
    });

    /// 테스트 10: 한글 카테고리명이 포함된 데이터 파싱
    /// Test 10: Parse data with Korean category names
    test('한글 카테고리명이 포함된 데이터 파싱', () {
      // Arrange: 한글이 포함된 JSON 데이터
      // Arrange: JSON data with Korean text
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': ['자유게시판', '사고팔고', '구인구직'],
          'advertisement_days': [3, 5, 7],
          'adv_cost_per_hour': 100,
        },
      };

      // Act: PhilgoSetting.fromJson() 사용하여 객체 생성
      // Act: Create PhilgoSetting object using fromJson
      final setting = PhilgoSetting.fromJson(json);

      // Assert: 한글이 올바르게 파싱되는지 확인
      // Assert: Verify Korean text is correctly parsed
      expect(setting.point.advertisingPostCategories, hasLength(3));
      expect(
        setting.point.advertisingPostCategories,
        containsAll(['자유게시판', '사고팔고', '구인구직']),
      );
    });
  });

  /// toJson() 및 toString() 테스트 그룹
  /// Test group for toJson() and toString() methods
  group('toJson() 및 toString() 테스트', () {
    /// 테스트 11: PhilgoSettingPoint.toJson() 테스트
    /// Test 11: PhilgoSettingPoint.toJson() test
    test('PhilgoSettingPoint.toJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final pointJson = {
        'advertising_post_categories': ['freetalk', 'buyandsell'],
        'advertisement_days': [3, 5],
        'adv_cost_per_hour': 100,
      };

      // Act: PhilgoSettingPoint.fromJson() 생성 후 toJson() 호출
      final point = PhilgoSettingPoint.fromJson(pointJson);
      final result = point.toJson();

      // Assert: toJson() 결과 검증
      expect(result, isA<Map>());
      expect(result['advertising_post_categories'], isA<List<String>>());
      expect(result['advertising_post_categories'], hasLength(2));
      expect(result['advertising_post_categories'], contains('freetalk'));
      expect(result['advertising_post_categories'], contains('buyandsell'));
    });

    /// 테스트 12: PhilgoSettingPoint.toString() 테스트
    /// Test 12: PhilgoSettingPoint.toString() test
    test('PhilgoSettingPoint.toString() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final pointJson = {
        'advertising_post_categories': ['freetalk', 'buyandsell'],
        'advertisement_days': [3, 5],
        'adv_cost_per_hour': 100,
      };

      // Act: PhilgoSettingPoint.fromJson() 생성 후 toString() 호출
      final point = PhilgoSettingPoint.fromJson(pointJson);
      final result = point.toString();

      // Assert: toString() 결과가 JSON 문자열인지 검증
      expect(result, isA<String>());
      expect(result, contains('advertising_post_categories'));
      expect(result, contains('freetalk'));
      expect(result, contains('buyandsell'));
    });

    /// 테스트 13: PhilgoSetting.toJson() 테스트
    /// Test 13: PhilgoSetting.toJson() test
    test('PhilgoSetting.toJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'bank_info': {
          'kb': {
            'name': '국민은행',
            'account_no': '123-456',
            'account_name': '테스트',
          },
        },
        'point': {
          'advertising_post_categories': ['job', 'rent'],
          'advertisement_days': [7, 14],
          'adv_cost_per_hour': 200,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성 후 toJson() 호출
      final setting = PhilgoSetting.fromJson(json);
      final result = setting.toJson();

      // Assert: toJson() 결과 검증
      expect(result, isA<Map>());
      expect(result['point'], isA<Map>());
      expect(result['point']['advertising_post_categories'], hasLength(2));
      expect(result['bank_info'], isA<Map>());
    });

    /// 테스트 14: PhilgoSetting.toString() 테스트
    /// Test 14: PhilgoSetting.toString() test
    test('PhilgoSetting.toString() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': ['job', 'rent'],
          'advertisement_days': [7, 14],
          'adv_cost_per_hour': 200,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성 후 toString() 호출
      final setting = PhilgoSetting.fromJson(json);
      final result = setting.toString();

      // Assert: toString() 결과가 올바른 형식인지 검증
      expect(result, isA<String>());
      expect(result, startsWith('PhilgoSetting('));
      expect(result, contains('point'));
    });

    /// 테스트 15: 실제 API 데이터로 toJson()/toString() 테스트
    /// Test 15: toJson()/toString() test with real API data
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

    /// 테스트 16: 빈 배열로 toJson()/toString() 테스트
    /// Test 16: toJson()/toString() test with empty array
    test('빈 배열로 toJson() 및 toString() 테스트', () {
      // Arrange: 빈 배열 데이터
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': <String>[],
          'advertisement_days': <int>[],
          'adv_cost_per_hour': 0,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성
      final setting = PhilgoSetting.fromJson(json);

      // Assert: toJson() 검증
      final jsonResult = setting.toJson();
      expect(jsonResult['point']['advertising_post_categories'], isEmpty);

      // Assert: toString() 검증
      final stringResult = setting.toString();
      expect(stringResult, contains('PhilgoSetting'));
    });

    /// 테스트 17: 한글 데이터로 toJson()/toString() 테스트
    /// Test 17: toJson()/toString() test with Korean data
    test('한글 데이터로 toJson() 및 toString() 테스트', () {
      // Arrange: 한글 데이터
      final json = {
        'bank_info': {
          'kb': {
            'name': '국민은행',
            'account_no': '123-456-789',
            'account_name': '홍길동',
          },
        },
        'point': {
          'advertising_post_categories': ['자유게시판', '사고팔고'],
          'advertisement_days': [3, 7],
          'adv_cost_per_hour': 100,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성
      final setting = PhilgoSetting.fromJson(json);

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

  /// BankAccount 및 PhilgoSettingBankInfo 테스트 그룹
  /// Test group for BankAccount and PhilgoSettingBankInfo models
  group('BankAccount 및 BankInfo 테스트', () {
    /// 테스트 18: BankAccount.fromJson() 테스트
    /// Test 18: BankAccount.fromJson() test
    test('BankAccount.fromJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'name': '국민은행',
        'account_no': '123-456-789',
        'account_name': '홍길동',
      };

      // Act: BankAccount.fromJson() 생성
      final account = BankAccount.fromJson(json);

      // Assert: 데이터가 올바르게 파싱되었는지 확인
      expect(account.name, '국민은행');
      expect(account.accountNo, '123-456-789');
      expect(account.accountName, '홍길동');
    });

    /// 테스트 19: BankAccount.toJson() 테스트
    /// Test 19: BankAccount.toJson() test
    test('BankAccount.toJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'name': 'BDO',
        'account_no': '987-654-321',
        'account_name': 'John Doe',
      };

      // Act: BankAccount.fromJson() 생성 후 toJson() 호출
      final account = BankAccount.fromJson(json);
      final result = account.toJson();

      // Assert: toJson() 결과 검증
      expect(result['name'], 'BDO');
      expect(result['account_no'], '987-654-321');
      expect(result['account_name'], 'John Doe');
    });

    /// 테스트 20: PhilgoSettingBankInfo.fromJson() 테스트
    /// Test 20: PhilgoSettingBankInfo.fromJson() test
    test('PhilgoSettingBankInfo.fromJson() 정상 동작', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'kb': {
          'name': '국민은행',
          'account_no': '123-456',
          'account_name': '테스트',
        },
        'bdo': {
          'name': 'BDO',
          'account_no': '789-012',
          'account_name': 'Test',
        },
      };

      // Act: PhilgoSettingBankInfo.fromJson() 생성
      final bankInfo = PhilgoSettingBankInfo.fromJson(json);

      // Assert: 데이터가 올바르게 파싱되었는지 확인
      expect(bankInfo.banks, hasLength(2));
      expect(bankInfo.kb?.name, '국민은행');
      expect(bankInfo.bdo?.name, 'BDO');
      expect(bankInfo.getBank('kb')?.accountNo, '123-456');
    });

    /// 테스트 21: PhilgoSettingBankInfo가 빈 데이터일 때 테스트
    /// Test 21: PhilgoSettingBankInfo with empty data test
    test('PhilgoSettingBankInfo 빈 데이터 테스트', () {
      // Arrange: 빈 JSON 데이터
      final json = <String, dynamic>{};

      // Act: PhilgoSettingBankInfo.fromJson() 생성
      final bankInfo = PhilgoSettingBankInfo.fromJson(json);

      // Assert: 빈 Map인지 확인
      expect(bankInfo.banks, isEmpty);
      expect(bankInfo.kb, isNull);
      expect(bankInfo.bdo, isNull);
    });
  });

  /// 추가 필드 테스트 그룹
  /// Test group for additional fields
  group('추가 필드 테스트', () {
    /// 테스트 22: advertisementDays 필드 검증
    /// Test 22: Verify advertisementDays field
    test('advertisementDays 필드가 List<int>인지 확인', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': ['test'],
          'advertisement_days': [3, 5, 7, 10, 15, 30],
          'adv_cost_per_hour': 100,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성
      final setting = PhilgoSetting.fromJson(json);

      // Assert: advertisementDays가 List<int>인지 확인
      expect(setting.point.advertisementDays, isA<List<int>>());
      expect(setting.point.advertisementDays, hasLength(6));
      expect(setting.point.advertisementDays, contains(7));
    });

    /// 테스트 23: advCostPerHour 필드 검증
    /// Test 23: Verify advCostPerHour field
    test('advCostPerHour 필드가 int인지 확인', () {
      // Arrange: 테스트 데이터 생성
      final json = {
        'bank_info': {},
        'point': {
          'advertising_post_categories': ['test'],
          'advertisement_days': [7],
          'adv_cost_per_hour': 250,
        },
      };

      // Act: PhilgoSetting.fromJson() 생성
      final setting = PhilgoSetting.fromJson(json);

      // Assert: advCostPerHour가 int인지 확인
      expect(setting.point.advCostPerHour, isA<int>());
      expect(setting.point.advCostPerHour, 250);
    });

    /// 테스트 24: 실제 API에서 advertisementDays 검증
    /// Test 24: Verify advertisementDays from real API
    test('실제 API에서 advertisementDays 검증', () async {
      // Act: 실제 API 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advertisementDays가 비어있지 않은지 확인
      expect(setting.point.advertisementDays, isA<List<int>>());
      expect(setting.point.advertisementDays, isNotEmpty);
    });

    /// 테스트 25: 실제 API에서 advCostPerHour 검증
    /// Test 25: Verify advCostPerHour from real API
    test('실제 API에서 advCostPerHour 검증', () async {
      // Act: 실제 API 호출
      final setting = await PhilgoService.instance.loadSetting();

      // Assert: advCostPerHour가 0 이상인지 확인
      expect(setting.point.advCostPerHour, isA<int>());
      expect(setting.point.advCostPerHour, greaterThanOrEqualTo(0));
    });
  });
}
