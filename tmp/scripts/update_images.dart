// update_images.dart
// travel_spots.json 파일의 특정 항목 또는 여러 항목의 imageUrl을 업데이트하는 스크립트
//
// 사용법:
//   # 단일 항목 업데이트 (이름으로 검색)
//   dart run tmp/scripts/update_images.dart \
//     --name "Boracay 섬" \
//     --imageUrl "https://example.com/new-image.jpg"
//
//   # 인덱스로 업데이트
//   dart run tmp/scripts/update_images.dart \
//     --index 204 \
//     --imageUrl "https://example.com/new-image.jpg"
//
//   # JSON 파일에서 일괄 업데이트
//   dart run tmp/scripts/update_images.dart \
//     --batch-file tmp/image_updates.json
//
//   # 빈 URL만 표시
//   dart run tmp/scripts/update_images.dart --list-empty
//
//   # 검증 결과 파일에서 404 에러만 추출
//   dart run tmp/scripts/update_images.dart --list-404

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // 명령줄 인자 파싱
  String? name;
  String? city;
  int? index;
  String? imageUrl;
  String? batchFile;
  bool listEmpty = false;
  bool list404 = false;
  bool dryRun = false;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--name':
        if (i + 1 < args.length) name = args[++i];
        break;
      case '--city':
        if (i + 1 < args.length) city = args[++i];
        break;
      case '--index':
        if (i + 1 < args.length) index = int.tryParse(args[++i]);
        break;
      case '--imageUrl':
      case '--image-url':
        if (i + 1 < args.length) imageUrl = args[++i];
        break;
      case '--batch-file':
        if (i + 1 < args.length) batchFile = args[++i];
        break;
      case '--list-empty':
        listEmpty = true;
        break;
      case '--list-404':
        list404 = true;
        break;
      case '--dry-run':
        dryRun = true;
        break;
      case '--help':
      case '-h':
        //        printUsage();
        exit(0);
    }
  }

  // JSON 파일 경로
  final jsonPath = 'lib/philgo_files/travel/travel_spots.json';
  final backupPath =
      'tmp/backups/travel_spots_${DateTime.now().millisecondsSinceEpoch}.json';

  // JSON 파일 읽기
  final file = File(jsonPath);
  if (!file.existsSync()) {
    //    print('오류: $jsonPath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> items = jsonDecode(jsonString);

  // 빈 URL 목록 표시
  if (listEmpty) {
    _listEmptyUrls(items);
    exit(0);
  }

  // 404 에러 목록 표시
  if (list404) {
    _list404Errors();
    exit(0);
  }

  // 일괄 업데이트 모드
  if (batchFile != null) {
    _batchUpdate(items, batchFile, jsonPath, backupPath, dryRun);
    exit(0);
  }

  // 단일 업데이트 모드
  if (imageUrl == null) {
    //    print('오류: --imageUrl은 필수입니다.');
    //    printUsage();
    exit(1);
  }

  if (name == null && index == null) {
    //    print('오류: --name 또는 --index 중 하나는 필수입니다.');
    //    printUsage();
    exit(1);
  }

  //  print('=' * 60);
  //  print('Travel Spots 이미지 URL 업데이트');
  //  print('=' * 60);

  // 항목 찾기
  int? targetIndex;
  Map<String, dynamic>? targetItem;

  if (index != null) {
    // 인덱스로 찾기
    if (index < 0 || index >= items.length) {
      //      print('오류: 인덱스 $index가 범위를 벗어났습니다. (0-${items.length - 1})');
      exit(1);
    }
    targetIndex = index;
    targetItem = Map<String, dynamic>.from(items[index]);
  } else {
    // 이름으로 찾기
    for (int i = 0; i < items.length; i++) {
      final item = items[i] as Map<String, dynamic>;
      final itemName = item['name'] as String? ?? '';
      final itemCity = item['city'] as String? ?? '';

      bool nameMatch = itemName == name || itemName.contains(name!);
      bool cityMatch =
          city == null || itemCity == city || itemCity.contains(city);

      if (nameMatch && cityMatch) {
        targetIndex = i;
        targetItem = Map<String, dynamic>.from(item);
        break;
      }
    }
  }

  if (targetIndex == null || targetItem == null) {
    //    print('오류: 해당 조건에 맞는 항목을 찾을 수 없습니다.');
    //    print('');

    // 유사한 항목 제안
    if (name != null) {
      //      print('[유사한 항목 검색]');
      for (int i = 0; i < items.length; i++) {
        final item = items[i] as Map<String, dynamic>;
        final itemName = item['name'] as String? ?? '';
        if (itemName.toLowerCase().contains(name.toLowerCase())) {
          //          print('  [$i] ${item['name']} (${item['city']})');
        }
      }
    }
    exit(1);
  }

  //  print('찾은 항목:');
  //  print('  - 인덱스: $targetIndex');
  //  print('  - 이름: ${targetItem['name']}');
  //  print('  - 도시: ${targetItem['city']}');
  //  print('  - 지역: ${targetItem['province']}');
  //  print('');

  final oldImageUrl = targetItem['imageUrl'] as String? ?? '';
  //  print('[업데이트 내용]');
  //  print('  - 이전 URL: ${oldImageUrl.isEmpty ? "(없음)" : oldImageUrl}');
  //  print('  - 새 URL: $imageUrl');
  //  print('');

  if (dryRun) {
    //    print('========================================');
    //    print('DRY RUN 모드: 실제 파일은 수정되지 않았습니다.');
    //    print('========================================');
    exit(0);
  }

  // 백업 생성
  final backupDir = Directory('tmp/backups');
  if (!backupDir.existsSync()) {
    backupDir.createSync(recursive: true);
  }
  File(backupPath).writeAsStringSync(jsonString);
  //  print('백업 생성: $backupPath');

  // 항목 업데이트
  targetItem['imageUrl'] = imageUrl;
  items[targetIndex] = targetItem;

  // JSON 파일 저장
  final encoder = JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(items);
  file.writeAsStringSync(updatedJsonString);

  //  print('');
  //  print('========================================');
  //  print('업데이트 완료!');
  //  print('========================================');
  //  print('수정된 파일: $jsonPath');
  //  print('백업 파일: $backupPath');

  // JSON 유효성 검증
  try {
    jsonDecode(File(jsonPath).readAsStringSync());
    //    print('JSON 유효성 검증: 통과');
  } catch (e) {
    //    print('경고: JSON 유효성 검증 실패!');
    //    print('백업 파일에서 복원하세요: $backupPath');
    exit(1);
  }
}

/// 빈 URL 목록 표시
void _listEmptyUrls(List<dynamic> items) {
  //  print('=' * 60);
  //  print('빈 imageUrl 항목 목록');
  //  print('=' * 60);
  //  print('');

  int count = 0;
  for (int i = 0; i < items.length; i++) {
    final item = items[i] as Map<String, dynamic>;
    final imageUrl = item['imageUrl'] as String? ?? '';

    if (imageUrl.isEmpty) {
      count++;
      //      print('[$i] ${item['name']}');
      //      print('    도시: ${item['city'] ?? "없음"}');
      //      print('    지역: ${item['province'] ?? "없음"}');
      //      print('    영문명: ${item['english name'] ?? "없음"}');
      //      print('');
    }
  }

  //  print('=' * 60);
  //  print('총 ${count}개의 빈 imageUrl 항목');
  //  print('=' * 60);
}

/// 404 에러 목록 표시 (검증 결과 파일에서)
void _list404Errors() {
  final resultFile = File('tmp/image_check_results.json');
  if (!resultFile.existsSync()) {
    //    print('오류: tmp/image_check_results.json 파일을 찾을 수 없습니다.');
    //    print('먼저 check_images.dart를 실행하세요.');
    exit(1);
  }

  final resultJson = jsonDecode(resultFile.readAsStringSync());
  final failedItems = resultJson['failedItems'] as List<dynamic>;

  //  print('=' * 60);
  //  print('HTTP 404 에러 항목 목록');
  //  print('=' * 60);
  //  print('');

  int count = 0;
  for (final item in failedItems) {
    final statusCode = item['statusCode'] as int;
    if (statusCode == 404) {
      count++;
      //      print('[${count}] ${item['name']} (${item['city']})');
      //      print('    URL: ${item['imageUrl']}');
      //      print('');
    }
  }

  //  print('=' * 60);
  //  print('총 ${count}개의 HTTP 404 에러 항목');
  //  print('=' * 60);
}

/// 일괄 업데이트
void _batchUpdate(
  List<dynamic> items,
  String batchFile,
  String jsonPath,
  String backupPath,
  bool dryRun,
) {
  final batchFileObj = File(batchFile);
  if (!batchFileObj.existsSync()) {
    //    print('오류: $batchFile 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final batchData = jsonDecode(batchFileObj.readAsStringSync());
  final updates = batchData['updates'] as List<dynamic>;

  //  print('=' * 60);
  //  print('Travel Spots 이미지 URL 일괄 업데이트');
  //  print('=' * 60);
  //  print('배치 파일: $batchFile');
  //  print('업데이트 항목 수: ${updates.length}');
  //  print('');

  int successCount = 0;
  int failCount = 0;

  for (final update in updates) {
    final updateName = update['name'] as String?;
    final updateCity = update['city'] as String?;
    final updateIndex = update['index'] as int?;
    final newImageUrl = update['imageUrl'] as String;

    int? targetIndex;

    if (updateIndex != null) {
      if (updateIndex >= 0 && updateIndex < items.length) {
        targetIndex = updateIndex;
      }
    } else if (updateName != null) {
      for (int i = 0; i < items.length; i++) {
        final item = items[i] as Map<String, dynamic>;
        final itemName = item['name'] as String? ?? '';
        final itemCity = item['city'] as String? ?? '';

        bool nameMatch = itemName == updateName;
        bool cityMatch = updateCity == null || itemCity == updateCity;

        if (nameMatch && cityMatch) {
          targetIndex = i;
          break;
        }
      }
    }

    if (targetIndex != null) {
      final item = items[targetIndex] as Map<String, dynamic>;
      final oldUrl = item['imageUrl'] as String? ?? '';

      //      print('✅ [$targetIndex] ${item['name']}');
      //      print('   이전: ${oldUrl.isEmpty ? "(없음)" : _truncateUrl(oldUrl)}');
      //      print('   새로: ${_truncateUrl(newImageUrl)}');

      if (!dryRun) {
        item['imageUrl'] = newImageUrl;
        items[targetIndex] = item;
      }
      successCount++;
    } else {
      //      print('❌ 찾을 수 없음: ${updateName ?? "index=$updateIndex"}');
      failCount++;
    }
  }

  //  print('');
  //  print('=' * 60);
  //  print('결과: 성공 $successCount, 실패 $failCount');
  //  print('=' * 60);

  if (dryRun) {
    //    print('');
    //    print('DRY RUN 모드: 실제 파일은 수정되지 않았습니다.');
    exit(0);
  }

  if (successCount > 0) {
    // 백업 생성
    final backupDir = Directory('tmp/backups');
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    final originalJson = File(jsonPath).readAsStringSync();
    File(backupPath).writeAsStringSync(originalJson);
    //    print('백업 생성: $backupPath');

    // JSON 파일 저장
    final encoder = JsonEncoder.withIndent('    ');
    final updatedJsonString = encoder.convert(items);
    File(jsonPath).writeAsStringSync(updatedJsonString);

    //    print('수정된 파일: $jsonPath');

    // JSON 유효성 검증
    try {
      jsonDecode(File(jsonPath).readAsStringSync());
      //      print('JSON 유효성 검증: 통과');
    } catch (e) {
      //      print('경고: JSON 유효성 검증 실패!');
      //      print('백업 파일에서 복원하세요: $backupPath');
      exit(1);
    }
  }
}

/// URL 길이 제한
String _truncateUrl(String url) {
  if (url.length > 60) {
    return '${url.substring(0, 57)}...';
  }
  return url;
}

/// 사용법 출력
void printUsage() {
  print('''
사용법:
  dart run tmp/scripts/update_images.dart [옵션]

설명:
  travel_spots.json 파일의 imageUrl을 업데이트합니다.

단일 업데이트 옵션:
  --name <이름>           여행지 이름으로 검색
  --city <도시>           도시로 추가 필터링 (선택)
  --index <번호>          인덱스로 직접 지정
  --imageUrl <URL>        새 이미지 URL (필수)

일괄 업데이트 옵션:
  --batch-file <파일>     JSON 형식의 배치 파일

목록 표시 옵션:
  --list-empty            빈 imageUrl 항목 목록 표시
  --list-404              HTTP 404 에러 항목 목록 표시

기타 옵션:
  --dry-run               실제 저장 없이 미리보기만 수행
  --help, -h              이 도움말 표시

배치 파일 형식 (image_updates.json):
  {
    "updates": [
      { "name": "Boracay 섬", "imageUrl": "https://..." },
      { "index": 204, "imageUrl": "https://..." },
      { "name": "El Nido", "city": "El", "imageUrl": "https://..." }
    ]
  }

예시:
  # 이름으로 단일 업데이트
  dart run tmp/scripts/update_images.dart \\
    --name "Boracay 섬" \\
    --imageUrl "https://example.com/boracay.jpg"

  # 인덱스로 단일 업데이트
  dart run tmp/scripts/update_images.dart \\
    --index 204 \\
    --imageUrl "https://example.com/boracay.jpg"

  # 일괄 업데이트
  dart run tmp/scripts/update_images.dart \\
    --batch-file tmp/image_updates.json

  # 빈 URL 항목 확인
  dart run tmp/scripts/update_images.dart --list-empty

  # 404 에러 항목 확인
  dart run tmp/scripts/update_images.dart --list-404
''');
}
