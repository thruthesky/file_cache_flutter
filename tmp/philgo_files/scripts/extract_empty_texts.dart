// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// travel_spots.json 파일에서 texts 배열이 비어있는 항목을 추출하는 스크립트
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run lib/philgo_files/scripts/extract_empty_texts.dart
/// dart run lib/philgo_files/scripts/extract_empty_texts.dart --province "Palawan"
/// dart run lib/philgo_files/scripts/extract_empty_texts.dart --limit 50
/// ```

/// JSON 파일 경로
const String jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

/// 출력 파일 경로
const String outputFilePath = 'lib/philgo_files/scripts/empty_texts_items.json';

void main(List<String> args) async {
  //  print('======================================');
  //  print('📝 texts 비어있는 항목 추출 도구');
  //  print('======================================\n');

  // 명령줄 인자 파싱
  String? provinceFilter;
  int? limitCount;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--province' && i + 1 < args.length) {
      provinceFilter = args[i + 1];
    } else if (args[i] == '--limit' && i + 1 < args.length) {
      limitCount = int.tryParse(args[i + 1]);
    }
  }

  if (provinceFilter != null) {
    //    print('📍 지역 필터: $provinceFilter');
  }
  if (limitCount != null) {
    //    print('🔢 제한 개수: $limitCount');
  }
  //  print('');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  if (!file.existsSync()) {
    //    print('❌ 오류: $jsonFilePath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('📋 총 항목 수: ${travelSpots.length}개\n');

  // texts가 비어있는 항목 추출
  final List<Map<String, dynamic>> emptyTextsItems = [];

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final texts = spot['texts'] as List<dynamic>? ?? [];

    // texts가 비어있는 경우만 추출
    if (texts.isEmpty) {
      final name = spot['name']?.toString() ?? '';
      final englishName = spot['english name']?.toString() ?? '';
      final title = spot['title']?.toString() ?? '';
      final description = spot['description']?.toString() ?? '';
      final city = spot['city']?.toString() ?? '';
      final province = spot['province']?.toString() ?? '';
      final category = spot['category']?.toString() ?? '';
      final icon = spot['icon']?.toString() ?? '';

      // 지역 필터 적용
      if (provinceFilter != null &&
          !province.toLowerCase().contains(provinceFilter.toLowerCase())) {
        continue;
      }

      emptyTextsItems.add({
        'index': i,
        'name': name,
        'englishName': englishName,
        'title': title,
        'description': description,
        'city': city,
        'province': province,
        'category': category,
        'icon': icon,
        'searchQuery': '$englishName $city Philippines travel',
      });

      // 제한 개수 체크
      if (limitCount != null && emptyTextsItems.length >= limitCount) {
        break;
      }
    }
  }

  // 결과 출력
  //  print('======================================');
  //  print('📊 추출 결과');
  //  print('======================================\n');
  //  print('  texts 비어있는 항목: ${emptyTextsItems.length}개');

  // 지역별 분포
  final Map<String, int> provinceDistribution = {};
  for (final item in emptyTextsItems) {
    final province = item['province'] as String? ?? '(지역 없음)';
    provinceDistribution[province] = (provinceDistribution[province] ?? 0) + 1;
  }

  //  print('\n📍 지역별 분포:');
  final sortedProvinces = provinceDistribution.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sortedProvinces.take(10)) {
    //    print('  ${entry.key}: ${entry.value}개');
  }

  // 상위 20개 항목 출력
  //  print('\n📝 추출된 항목 (상위 20개):');
  for (final item in emptyTextsItems.take(20)) {
    //    print('  [${item['index']}] ${item['name']} (${item['province']})');
  }

  if (emptyTextsItems.length > 20) {
    //    print('  ... 외 ${emptyTextsItems.length - 20}개');
  }

  // 결과를 JSON 파일로 저장
  final result = {
    'generated_at': DateTime.now().toIso8601String(),
    'filter': {'province': provinceFilter, 'limit': limitCount},
    'total_empty_texts': emptyTextsItems.length,
    'province_distribution': provinceDistribution,
    'items': emptyTextsItems,
  };

  final outputFile = File(outputFilePath);
  final encoder = const JsonEncoder.withIndent('    ');
  outputFile.writeAsStringSync(encoder.convert(result));

  //  print('\n======================================');
  //  print('📁 결과가 $outputFilePath에 저장되었습니다.');
  //  print('======================================');

  // 작업 안내
  //  print('\n💡 다음 단계:');
  //  print('   1. 추출된 항목에 대해 인터넷 검색으로 정보 수집');
  //  print('   2. texts 배열에 마크다운 형식으로 콘텐츠 작성');
  //  print('   3. JSON 파일 업데이트');
}
