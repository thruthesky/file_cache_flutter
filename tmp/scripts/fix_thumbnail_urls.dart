// fix_thumbnail_urls.dart
// 잘못된 Wikipedia thumbnail URL을 원본 URL로 변환하는 스크립트
//
// 문제: /thumb/.../800px-filename.jpg 형식은 Wikipedia에서 유효하지 않음
// 해결: /thumb/ 경로와 크기 접두사를 제거하여 원본 URL로 변환
//
// 사용법:
//   dart run tmp/scripts/fix_thumbnail_urls.dart
//   dart run tmp/scripts/fix_thumbnail_urls.dart --dry-run

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  final isDryRun = args.contains('--dry-run');

  //  print('=' * 60);
  //  print('Wikipedia Thumbnail URL 수정');
  //  print('=' * 60);

  if (isDryRun) {
    //    print('🔍 DRY RUN 모드 - 실제 파일 수정 없음');
  }
  //  print('');

  // JSON 파일 읽기
  final jsonFile = File('lib/philgo_files/travel/travel_spots.json');
  if (!await jsonFile.exists()) {
    //    print('❌ 파일을 찾을 수 없습니다: ${jsonFile.path}');
    exit(1);
  }

  final jsonString = await jsonFile.readAsString();
  final List<dynamic> spots = jsonDecode(jsonString);

  // 수정할 항목 찾기
  int fixedCount = 0;
  final List<Map<String, dynamic>> fixedItems = [];

  // 잘못된 thumbnail URL 패턴
  // 예: .../thumb/a/a9/filename.jpg/800px-filename.jpg
  final thumbPattern = RegExp(
    r'^(https://upload\.wikimedia\.org/wikipedia/commons/)thumb/([a-z0-9]/[a-z0-9]{2})/([^/]+)/\d+px-.*$',
    caseSensitive: false,
  );

  for (int i = 0; i < spots.length; i++) {
    final spot = spots[i];
    final imageUrl = spot['imageUrl'] as String? ?? '';

    if (imageUrl.isEmpty) continue;

    // thumbnail URL인지 확인
    if (imageUrl.contains('/thumb/') && RegExp(r'/\d+px-').hasMatch(imageUrl)) {
      final match = thumbPattern.firstMatch(imageUrl);

      if (match != null) {
        // 원본 URL 생성
        final baseUrl = match.group(
          1,
        )!; // https://upload.wikimedia.org/wikipedia/commons/
        final path = match.group(2)!; // a/a9
        final filename = match.group(3)!; // filename.jpg

        final newUrl = '$baseUrl$path/$filename';

        // 수정
        spots[i]['imageUrl'] = newUrl;
        fixedCount++;

        fixedItems.add({
          'index': i,
          'name': spot['name'],
          'oldUrl': imageUrl,
          'newUrl': newUrl,
        });

        // 처음 10개만 출력
        if (fixedCount <= 10) {
          //          print('✅ [$i] ${spot['name']}');
          //          print('   이전: ${_truncate(imageUrl, 70)}');
          //          print('   새로: ${_truncate(newUrl, 70)}');
        } else if (fixedCount == 11) {
          //          print('   ... (더 많은 항목)');
        }
      }
    }
  }

  //  print('');
  //  print('=' * 60);
  //  print('수정 대상: $fixedCount개');
  //  print('=' * 60);

  if (fixedCount == 0) {
    //    print('수정할 항목이 없습니다.');
    return;
  }

  if (isDryRun) {
    //    print('');
    //    print('DRY RUN 완료. 실제 수정하려면 --dry-run 옵션을 제거하세요.');
    return;
  }

  // 백업 생성
  final backupDir = Directory('tmp/backups');
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final backupFile = File(
    '${backupDir.path}/travel_spots_thumb_fix_$timestamp.json',
  );
  await backupFile.writeAsString(jsonString);
  //  print('백업 생성: ${backupFile.path}');

  // 수정된 JSON 저장
  final encoder = JsonEncoder.withIndent('  ');
  final newJsonString = encoder.convert(spots);
  await jsonFile.writeAsString(newJsonString);
  //  print('수정된 파일: ${jsonFile.path}');

  // JSON 유효성 검증
  try {
    jsonDecode(await jsonFile.readAsString());
    //    print('JSON 유효성 검증: 통과');
  } catch (e) {
    //    print('❌ JSON 유효성 검증 실패: $e');
    // 백업에서 복원
    await jsonFile.writeAsString(jsonString);
    //    print('백업에서 복원됨');
    exit(1);
  }

  // 수정 내역 저장
  final logFile = File('tmp/thumbnail_fixes_$timestamp.json');
  await logFile.writeAsString(
    encoder.convert({
      'timestamp': DateTime.now().toIso8601String(),
      'fixedCount': fixedCount,
      'items': fixedItems,
    }),
  );
  //  print('수정 내역: ${logFile.path}');
}

String _truncate(String s, int maxLen) {
  if (s.length <= maxLen) return s;
  return '${s.substring(0, maxLen)}...';
}
