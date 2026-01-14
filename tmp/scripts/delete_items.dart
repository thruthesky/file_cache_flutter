// delete_items.dart
// travel_spots.json 파일에서 특정 항목들을 삭제하는 스크립트

import 'dart:convert';
import 'dart:io';

void main() {
  // 삭제할 항목 목록 (name 기준)
  // 인터넷 검색 결과 관광지로서 인기가 없는 산들 (2026-01-14 조사)
  final itemsToDelete = [
    'Gantung 산', // Palawan - Peakery에만 등재, 트레킹/관광 블로그 언급 없음
    'Gap 산', // Cotabato - 검색 결과 없음, 관광 사이트 언급 없음
    'Gatas (Gata) 산', // Zambales - Peakery에만 등재, 트레킹 블로그 없음
    'Gate Mountains', // Sorsogon - AllTrails 등록되어 있으나 리뷰/블로그 없음
    'Gayad 산', // Leyte - PeakVisor에만 등재, 트레킹 블로그 없음
  ];

  // JSON 파일 경로
  final jsonPath = 'lib/philgo_files/travel/travel_spots.json';
  final backupPath =
      'tmp/backups/travel_spots_${DateTime.now().millisecondsSinceEpoch}.json';

  // JSON 파일 읽기
  final file = File(jsonPath);
  if (!file.existsSync()) {
    print('오류: $jsonPath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> items = jsonDecode(jsonString);

  print('========================================');
  print('Travel Spots 항목 삭제');
  print('========================================');
  print('삭제 대상: ${itemsToDelete.length}개');
  print('');

  // 삭제 전 항목 수
  final beforeCount = items.length;
  print('삭제 전 총 항목 수: $beforeCount');
  print('');

  // 삭제할 항목 찾기 및 정보 출력
  final indicesToDelete = <int>[];
  for (final nameToDelete in itemsToDelete) {
    for (int i = 0; i < items.length; i++) {
      final item = items[i] as Map<String, dynamic>;
      if (item['name'] == nameToDelete) {
        indicesToDelete.add(i);
        print('찾음: ${item["name"]} (${item["province"]}) - 인덱스: $i');
        break;
      }
    }
  }

  if (indicesToDelete.isEmpty) {
    print('삭제할 항목을 찾지 못했습니다.');
    exit(0);
  }

  print('');
  print('삭제할 항목 수: ${indicesToDelete.length}');

  // 백업 생성
  final backupDir = Directory('tmp/backups');
  if (!backupDir.existsSync()) {
    backupDir.createSync(recursive: true);
  }
  File(backupPath).writeAsStringSync(jsonString);
  print('백업 생성: $backupPath');
  print('');

  // 역순으로 정렬하여 삭제 (인덱스 변동 방지)
  indicesToDelete.sort((a, b) => b.compareTo(a));

  for (final index in indicesToDelete) {
    final item = items[index] as Map<String, dynamic>;
    print('삭제 중: ${item["name"]} (인덱스: $index)');
    items.removeAt(index);
  }

  // 삭제 후 항목 수
  final afterCount = items.length;
  print('');
  print('삭제 후 총 항목 수: $afterCount');
  print('삭제된 항목 수: ${beforeCount - afterCount}');

  // JSON 파일 저장
  final encoder = JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(items);
  file.writeAsStringSync(updatedJsonString);

  print('');
  print('========================================');
  print('삭제 완료!');
  print('========================================');
  print('수정된 파일: $jsonPath');
  print('백업 파일: $backupPath');
  print('');

  // 업데이트 후 검증
  final verifyFile = File(jsonPath);
  try {
    jsonDecode(verifyFile.readAsStringSync());
    print('JSON 유효성 검증: 통과');
  } catch (e) {
    print('경고: JSON 유효성 검증 실패!');
    print('백업 파일에서 복원하세요: $backupPath');
    exit(1);
  }
}
