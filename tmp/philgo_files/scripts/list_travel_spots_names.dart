// ignore_for_file: avoid_print

/// travel_spots.json 파일에서 각 여행지의 name과 english name을 추출하여 표시하는 스크립트
///
/// 사용법:
///   dart run lib/philgo_files/scripts/list_travel_spots_names.dart
///
/// 출력 형식:
///   1. 한글이름 (English Name)
///   2. 한글이름 (English Name)
///   ...

import 'dart:convert';
import 'dart:io';

/// JSON 파일 경로
const String jsonPath = 'lib/philgo_files/travel/travel_spots.json';

void main() async {
  // JSON 파일 읽기
  final file = File(jsonPath);

  // 파일 존재 확인
  if (!await file.exists()) {
    //    print('오류: 파일을 찾을 수 없습니다: $jsonPath');
    exit(1);
  }

  // JSON 파싱
  final content = await file.readAsString();
  final List<dynamic> items = json.decode(content);

  //  print('=' * 80);
  //  print('여행지 목록 (총 ${items.length}개)');
  //  print('=' * 80);
  //  print('');

  // 각 항목의 name과 english name 출력
  for (var i = 0; i < items.length; i++) {
    final item = items[i] as Map<String, dynamic>;
    final name = item['name'] ?? '(이름 없음)';
    final englishName = item['english name'] ?? '(영문 이름 없음)';

    //    print('${i + 1}. $name ($englishName)');
  }

  //  print('');
  //  print('=' * 80);
  //  print('총 ${items.length}개의 여행지');
  //  print('=' * 80);
}
