// ignore_for_file: avoid_print

/// travel_spots.json 파일의 데이터 품질을 분석하는 스크립트
///
/// 분석 항목:
/// - Type A: imageUrl 누락/무효
/// - Type B: texts 배열 비어있음
/// - Type C: description 부실 (50자 미만)
/// - Type D: city/province 누락
/// - Type E: english name 누락
/// - Type F: title 부실 (10자 미만)
///
/// 사용법:
/// ```shell
/// cd /Users/thruthesky/apps/flutter/philgo_app
/// dart run lib/philgo_files/scripts/analyze_data_quality.dart
/// ```

import 'dart:convert';
import 'dart:io';

/// JSON 파일 경로
const String jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

/// 출력 파일 경로
const String outputFilePath = 'lib/philgo_files/scripts/quality_analysis.json';

/// 품질 문제 유형 정의
class QualityIssue {
  final int index;
  final String name;
  final String englishName;
  final String province;
  final List<String> issues;

  QualityIssue({
    required this.index,
    required this.name,
    required this.englishName,
    required this.province,
    required this.issues,
  });

  Map<String, dynamic> toJson() => {
    'index': index,
    'name': name,
    'englishName': englishName,
    'province': province,
    'issues': issues,
  };
}

void main() async {
  //  print('======================================');
  //  print('📊 Travel Spots 데이터 품질 분석 도구');
  //  print('======================================\n');

  // JSON 파일 읽기
  final file = File(jsonFilePath);
  if (!file.existsSync()) {
    //    print('❌ 오류: $jsonFilePath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('📋 총 항목 수: ${travelSpots.length}개\n');

  // 품질 문제 카운터
  int typeACount = 0; // imageUrl 누락/무효
  int typeBCount = 0; // texts 비어있음
  int typeCCount = 0; // description 부실
  int typeDCount = 0; // city/province 누락
  int typeECount = 0; // english name 누락
  int typeFCount = 0; // title 부실

  // 지역별 통계
  final Map<String, int> provinceStats = {};
  final Map<String, int> provinceIssueStats = {};

  // 문제 있는 항목 목록
  final List<QualityIssue> problemItems = [];

  // 완전한 데이터 카운터
  int completeCount = 0;

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final List<String> issues = [];

    // 기본 정보 추출
    final name = spot['name']?.toString() ?? '';
    final englishName = spot['english name']?.toString() ?? '';
    final title = spot['title']?.toString() ?? '';
    final description = spot['description']?.toString() ?? '';
    final city = spot['city']?.toString() ?? '';
    final province = spot['province']?.toString() ?? '';
    final imageUrl = spot['imageUrl']?.toString() ?? '';
    final texts = spot['texts'] as List<dynamic>? ?? [];

    // 지역별 통계 수집
    final provinceName = province.isNotEmpty ? province : '(지역 없음)';
    provinceStats[provinceName] = (provinceStats[provinceName] ?? 0) + 1;

    // Type A: imageUrl 누락 체크
    if (imageUrl.isEmpty) {
      issues.add('Type A: imageUrl 누락');
      typeACount++;
    }

    // Type B: texts 비어있음 체크
    if (texts.isEmpty) {
      issues.add('Type B: texts 배열 비어있음');
      typeBCount++;
    }

    // Type C: description 부실 체크 (50자 미만)
    if (description.length < 50) {
      issues.add('Type C: description 부실 (${description.length}자)');
      typeCCount++;
    }

    // Type D: city/province 누락 체크
    if (city.isEmpty || province.isEmpty) {
      final missing = <String>[];
      if (city.isEmpty) missing.add('city');
      if (province.isEmpty) missing.add('province');
      issues.add('Type D: ${missing.join(", ")} 누락');
      typeDCount++;
    }

    // Type E: english name 누락 체크
    if (englishName.isEmpty) {
      issues.add('Type E: english name 누락');
      typeECount++;
    }

    // Type F: title 부실 체크 (10자 미만)
    if (title.length < 10) {
      issues.add('Type F: title 부실 (${title.length}자)');
      typeFCount++;
    }

    // 문제가 있는 항목 기록
    if (issues.isNotEmpty) {
      problemItems.add(
        QualityIssue(
          index: i,
          name: name,
          englishName: englishName,
          province: province,
          issues: issues,
        ),
      );
      provinceIssueStats[provinceName] =
          (provinceIssueStats[provinceName] ?? 0) + 1;
    } else {
      completeCount++;
    }
  }

  // 결과 출력
  //  print('======================================');
  //  print('📊 품질 문제 요약');
  //  print('======================================\n');

  final totalItems = travelSpots.length;
  final problemCount = problemItems.length;

  //  print('  Type A (imageUrl 누락): $typeACount개 (${(typeACount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  Type B (texts 비어있음): $typeBCount개 (${(typeBCount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  Type C (description 부실): $typeCCount개 (${(typeCCount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  Type D (city/province 누락): $typeDCount개 (${(typeDCount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  Type E (english name 누락): $typeECount개 (${(typeECount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  Type F (title 부실): $typeFCount개 (${(typeFCount / totalItems * 100).toStringAsFixed(1)}%)');

  //  print('\n======================================');
  //  print('📊 종합 결과');
  //  print('======================================\n');
  //  print('  ✅ 완전한 데이터: $completeCount개 (${(completeCount / totalItems * 100).toStringAsFixed(1)}%)');
  //  print('  ⚠️  보강 필요: $problemCount개 (${(problemCount / totalItems * 100).toStringAsFixed(1)}%)');

  // 지역별 통계 출력
  //  print('\n======================================');
  //  print('📍 지역별 통계');
  //  print('======================================\n');

  final sortedProvinces = provinceStats.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final entry in sortedProvinces.take(15)) {
    final province = entry.key;
    final total = entry.value;
    final issues = provinceIssueStats[province] ?? 0;
    final issuePercent = (issues / total * 100).toStringAsFixed(1);
    //    print('  $province: $total개 (문제: $issues개, $issuePercent%)');
  }

  if (sortedProvinces.length > 15) {
    //    print('  ... 외 ${sortedProvinces.length - 15}개 지역');
  }

  // Type B (texts 비어있음) 상위 항목 출력
  //  print('\n======================================');
  //  print('📝 texts 비어있는 항목 (상위 20개)');
  //  print('======================================\n');

  final textsEmptyItems = problemItems
      .where((item) => item.issues.any((i) => i.contains('Type B')))
      .take(20);

  for (final item in textsEmptyItems) {
    //    print('  [${item.index}] ${item.name} (${item.province})');
  }

  // 결과를 JSON 파일로 저장
  final analysisResult = {
    'generated_at': DateTime.now().toIso8601String(),
    'total_items': totalItems,
    'complete_items': completeCount,
    'problem_items': problemCount,
    'summary': {
      'type_a_imageUrl_missing': typeACount,
      'type_b_texts_empty': typeBCount,
      'type_c_description_poor': typeCCount,
      'type_d_location_missing': typeDCount,
      'type_e_english_name_missing': typeECount,
      'type_f_title_poor': typeFCount,
    },
    'province_stats': provinceStats,
    'province_issue_stats': provinceIssueStats,
    'problem_items_detail': problemItems.map((e) => e.toJson()).toList(),
  };

  final outputFile = File(outputFilePath);
  final encoder = const JsonEncoder.withIndent('    ');
  outputFile.writeAsStringSync(encoder.convert(analysisResult));

  //  print('\n======================================');
  //  print('📁 분석 결과가 $outputFilePath에 저장되었습니다.');
  //  print('======================================');
}
