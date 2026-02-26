// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// travel_spots.json 파일의 JSON 유효성을 검증하는 스크립트
///
/// 검증 항목:
/// 1. JSON 구문 유효성
/// 2. 필수 필드 존재 여부
/// 3. 필드 타입 검증
/// 4. 중복 항목 체크
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run lib/philgo_files/scripts/validate_json.dart
/// ```

/// JSON 파일 경로
const String jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

/// 필수 필드 목록
const List<String> requiredFields = [
  'name',
  'english name',
  'title',
  'description',
  'city',
  'province',
  'category',
];

/// 선택 필드 목록
const List<String> optionalFields = ['icon', 'imageUrl', 'texts'];

void main() async {
  //  print('======================================');
  //  print('✅ Travel Spots JSON 유효성 검증 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  if (!file.existsSync()) {
    //    print('❌ 오류: $jsonFilePath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();

  // 1. JSON 구문 유효성 검사
  //  print('1️⃣ JSON 구문 유효성 검사...');
  List<dynamic> travelSpots;
  try {
    travelSpots = jsonDecode(jsonString);
    //    print('   ✅ JSON 구문 유효');
  } catch (e) {
    //    print('   ❌ JSON 구문 오류: $e');
    exit(1);
  }

  //  print('   📋 총 항목 수: ${travelSpots.length}개\n');

  // 검증 결과 카운터
  int validCount = 0;
  int invalidCount = 0;
  final List<Map<String, dynamic>> invalidItems = [];

  // 중복 체크용 Set
  final Set<String> nameSet = {};
  final List<Map<String, dynamic>> duplicateItems = [];

  // 2. 각 항목 검증
  //  print('2️⃣ 필드 유효성 검사...');

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final List<String> errors = [];

    // Map 타입 검증
    if (spot is! Map<String, dynamic>) {
      errors.add('항목이 객체(Map) 타입이 아님');
      invalidCount++;
      invalidItems.add({'index': i, 'errors': errors});
      continue;
    }

    // 필수 필드 존재 여부 검증
    for (final field in requiredFields) {
      if (!spot.containsKey(field)) {
        errors.add('필수 필드 누락: $field');
      } else if (spot[field] == null) {
        errors.add('필수 필드가 null: $field');
      } else if (spot[field] is String && (spot[field] as String).isEmpty) {
        errors.add('필수 필드가 비어있음: $field');
      }
    }

    // 필드 타입 검증
    final name = spot['name'];
    final englishName = spot['english name'];
    final title = spot['title'];
    final description = spot['description'];
    final city = spot['city'];
    final province = spot['province'];
    final category = spot['category'];
    final icon = spot['icon'];
    final imageUrl = spot['imageUrl'];
    final texts = spot['texts'];

    if (name != null && name is! String) {
      errors.add('name 필드가 문자열이 아님');
    }
    if (englishName != null && englishName is! String) {
      errors.add('english name 필드가 문자열이 아님');
    }
    if (title != null && title is! String) {
      errors.add('title 필드가 문자열이 아님');
    }
    if (description != null && description is! String) {
      errors.add('description 필드가 문자열이 아님');
    }
    if (city != null && city is! String) {
      errors.add('city 필드가 문자열이 아님');
    }
    if (province != null && province is! String) {
      errors.add('province 필드가 문자열이 아님');
    }
    if (category != null && category is! String) {
      errors.add('category 필드가 문자열이 아님');
    }
    if (icon != null && icon is! String) {
      errors.add('icon 필드가 문자열이 아님');
    }
    if (imageUrl != null && imageUrl is! String) {
      errors.add('imageUrl 필드가 문자열이 아님');
    }
    if (texts != null && texts is! List) {
      errors.add('texts 필드가 배열이 아님');
    }

    // texts 배열 내부 타입 검증
    if (texts is List) {
      for (int j = 0; j < texts.length; j++) {
        if (texts[j] is! String) {
          errors.add('texts[$j]가 문자열이 아님');
        }
      }
    }

    // 중복 체크
    final nameStr = name?.toString() ?? '';
    if (nameStr.isNotEmpty) {
      if (nameSet.contains(nameStr.toLowerCase())) {
        duplicateItems.add({
          'index': i,
          'name': nameStr,
          'province': province?.toString() ?? '',
        });
      } else {
        nameSet.add(nameStr.toLowerCase());
      }
    }

    // 결과 기록
    if (errors.isNotEmpty) {
      invalidCount++;
      invalidItems.add({
        'index': i,
        'name': name?.toString() ?? '(이름 없음)',
        'errors': errors,
      });
    } else {
      validCount++;
    }
  }

  // 결과 출력
  //  print('   ✅ 유효한 항목: $validCount개');
  //  print('   ❌ 유효하지 않은 항목: $invalidCount개');

  // 3. 중복 항목 결과
  //  print('\n3️⃣ 중복 항목 검사...');
  if (duplicateItems.isEmpty) {
    //    print('   ✅ 중복 항목 없음');
  } else {
    //    print('   ⚠️  중복 항목 발견: ${duplicateItems.length}개');
    for (final item in duplicateItems.take(10)) {
      //      print('      [${item['index']}] ${item['name']} (${item['province']})');
    }
    if (duplicateItems.length > 10) {
      //      print('      ... 외 ${duplicateItems.length - 10}개');
    }
  }

  // 4. 유효하지 않은 항목 상세
  if (invalidItems.isNotEmpty) {
    //    print('\n4️⃣ 유효하지 않은 항목 상세 (상위 10개):');
    for (final item in invalidItems.take(10)) {
      //      print('   [${item['index']}] ${item['name'] ?? '(이름 없음)'}');
      for (final error in item['errors'] as List) {
        //        print('      - $error');
      }
    }
    if (invalidItems.length > 10) {
      //      print('   ... 외 ${invalidItems.length - 10}개');
    }
  }

  // 최종 결과
  //  print('\n======================================');
  //  print('📊 검증 결과 요약');
  //  print('======================================');

  final isValid = invalidCount == 0 && duplicateItems.isEmpty;

  if (isValid) {
    //    print('🎉 모든 검증 통과!');
    //    print('   ✅ JSON 구문: 유효');
    //    print('   ✅ 필수 필드: 모두 존재');
    //    print('   ✅ 필드 타입: 모두 올바름');
    //    print('   ✅ 중복 항목: 없음');
  } else {
    //    print('⚠️  일부 검증 실패');
    //    print('   ${invalidCount > 0 ? "❌" : "✅"} 필드 검증: ${invalidCount > 0 ? "$invalidCount개 문제" : "통과"}');
    //    print('   ${duplicateItems.isNotEmpty ? "⚠️ " : "✅"} 중복 검사: ${duplicateItems.isNotEmpty ? "${duplicateItems.length}개 중복" : "통과"}');
  }

  //  print('======================================');

  // 종료 코드 반환
  exit(isValid ? 0 : 1);
}
