// extract_incomplete.dart
// texts 배열이 없는 항목을 추출하는 스크립트
//
// 사용법:
//   dart run tmp/scripts/extract_incomplete.dart
//   dart run tmp/scripts/extract_incomplete.dart --limit 10
//   dart run tmp/scripts/extract_incomplete.dart --province "세부"
//   dart run tmp/scripts/extract_incomplete.dart --category "해변/섬"
//
// 출력: tmp/incomplete_items.json

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // 명령줄 인자 파싱
  int? limit;
  String? filterProvince;
  String? filterCategory;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--limit' && i + 1 < args.length) {
      limit = int.tryParse(args[i + 1]);
    } else if (args[i] == '--province' && i + 1 < args.length) {
      filterProvince = args[i + 1];
    } else if (args[i] == '--category' && i + 1 < args.length) {
      filterCategory = args[i + 1];
    }
  }

  // JSON 파일 경로
  final jsonPath = 'lib/philgo_files/travel/travel_spots.json';
  final outputPath = 'tmp/incomplete_items.json';

  // JSON 파일 읽기
  final file = File(jsonPath);
  if (!file.existsSync()) {
    print('오류: $jsonPath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> items = jsonDecode(jsonString);

  print('========================================');
  print('Travel Spots 미완료 항목 추출');
  print('========================================');
  print('총 항목 수: ${items.length}개\n');

  // 완료/미완료 분류
  final List<Map<String, dynamic>> completeItems = [];
  final List<Map<String, dynamic>> incompleteItems = [];

  for (int i = 0; i < items.length; i++) {
    final item = items[i] as Map<String, dynamic>;
    final hasImageUrl =
        item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty;
    final hasTexts =
        item['texts'] != null &&
        item['texts'] is List &&
        (item['texts'] as List).isNotEmpty;

    // 필터 적용
    if (filterProvince != null && item['province'] != filterProvince) continue;
    if (filterCategory != null && item['category'] != filterCategory) continue;

    if (hasImageUrl && hasTexts) {
      completeItems.add({
        'index': i,
        'name': item['name'],
        'city': item['city'],
        'province': item['province'],
        'textsCount': (item['texts'] as List).length,
      });
    } else {
      // 검색 쿼리 자동 생성
      final englishName = item['english name'] ?? item['name'];
      final city = item['city'] ?? '';
      final searchQuery = '$englishName $city Philippines travel';

      incompleteItems.add({
        'index': i,
        'name': item['name'],
        'english_name': item['english name'],
        'title': item['title'],
        'description': item['description'],
        'city': item['city'],
        'province': item['province'],
        'category': item['category'],
        'icon': item['icon'],
        'search_query': searchQuery,
        'missing_fields': [
          if (!hasImageUrl) 'imageUrl',
          if (!hasTexts) 'texts',
        ],
      });
    }
  }

  // 통계 출력
  final total = completeItems.length + incompleteItems.length;
  final completePercent =
      total > 0 ? (completeItems.length / total * 100).toStringAsFixed(1) : '0';
  final incompletePercent =
      total > 0
          ? (incompleteItems.length / total * 100).toStringAsFixed(1)
          : '0';

  print('필터 조건:');
  if (filterProvince != null) print('  - 지역: $filterProvince');
  if (filterCategory != null) print('  - 카테고리: $filterCategory');
  if (filterProvince == null && filterCategory == null) print('  - 없음 (전체)');
  print('');

  print('분석 결과:');
  print('  - 완료된 항목: ${completeItems.length}개 ($completePercent%)');
  print('  - 미완료 항목: ${incompleteItems.length}개 ($incompletePercent%)');
  print('');

  // 미완료 항목 출력 (상위 N개)
  final displayLimit = limit ?? 20;
  final displayItems = incompleteItems.take(displayLimit).toList();

  print('[미완료 항목 목록 - 상위 $displayLimit개]');
  for (final item in displayItems) {
    final missing = (item['missing_fields'] as List).join(', ');
    print('  ❌ ${item['name']} (${item['city']}) - 누락: $missing');
  }

  if (incompleteItems.length > displayLimit) {
    print('  ... 외 ${incompleteItems.length - displayLimit}개');
  }
  print('');

  // 지역별 통계
  print('[지역별 미완료 항목 수]');
  final provinceStats = <String, int>{};
  for (final item in incompleteItems) {
    final province = item['province'] as String? ?? '알 수 없음';
    provinceStats[province] = (provinceStats[province] ?? 0) + 1;
  }
  final sortedProvinces =
      provinceStats.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
  for (final entry in sortedProvinces.take(10)) {
    print('  - ${entry.key}: ${entry.value}개');
  }
  print('');

  // 출력 파일 생성
  final outputItems = limit != null ? incompleteItems.take(limit).toList() : incompleteItems;

  final output = {
    'generated_at': DateTime.now().toIso8601String(),
    'total_items': items.length,
    'total_complete': completeItems.length,
    'total_incomplete': incompleteItems.length,
    'filter': {
      'province': filterProvince,
      'category': filterCategory,
      'limit': limit,
    },
    'items': outputItems,
  };

  final outputFile = File(outputPath);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(output),
  );

  print('========================================');
  print('출력 파일: $outputPath');
  print('추출된 항목 수: ${outputItems.length}개');
  print('========================================');
}
