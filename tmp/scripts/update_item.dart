// update_item.dart
// travel_spots.json 파일의 특정 항목을 업데이트하는 스크립트
//
// 사용법:
//   dart run tmp/scripts/update_item.dart \
//     --city "코르도바" \
//     --name "10,000 로지스 카페" \
//     --imageUrl "https://example.com/image.jpg" \
//     --texts-file "tmp/collected/roses-cafe-texts.json"
//
// texts-file 형식:
//   {
//     "texts": [
//       "# 제목\n\n내용...",
//       "## 방문 정보\n\n...",
//       "## 추천 포인트\n\n..."
//     ]
//   }
//
// 또는 --texts 옵션으로 직접 JSON 배열 전달:
//   --texts '["텍스트1", "텍스트2"]'
//
// 추가 옵션:
//   --english-name "English Name" : 영문 이름 업데이트
//   --dry-run : 실제 저장 없이 미리보기만 수행

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  // 명령줄 인자 파싱
  String? city;
  String? name;
  String? imageUrl;
  String? textsFile;
  String? textsJson;
  String? englishName;
  bool dryRun = false;

  for (int i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--city':
        if (i + 1 < args.length) city = args[++i];
        break;
      case '--name':
        if (i + 1 < args.length) name = args[++i];
        break;
      case '--imageUrl':
        if (i + 1 < args.length) imageUrl = args[++i];
        break;
      case '--texts-file':
        if (i + 1 < args.length) textsFile = args[++i];
        break;
      case '--texts':
        if (i + 1 < args.length) textsJson = args[++i];
        break;
      case '--english-name':
        if (i + 1 < args.length) englishName = args[++i];
        break;
      case '--dry-run':
        dryRun = true;
        break;
      case '--help':
        printUsage();
        exit(0);
    }
  }

  // 필수 인자 확인
  if (city == null || name == null) {
    print('오류: --city와 --name은 필수입니다.');
    printUsage();
    exit(1);
  }

  if (imageUrl == null && textsFile == null && textsJson == null && englishName == null) {
    print('오류: --imageUrl, --texts-file, --texts, --english-name 중 하나 이상이 필요합니다.');
    printUsage();
    exit(1);
  }

  // JSON 파일 경로
  final jsonPath = 'lib/philgo_files/travel/travel_spots.json';
  final backupPath = 'tmp/backups/travel_spots_${DateTime.now().millisecondsSinceEpoch}.json';

  // JSON 파일 읽기
  final file = File(jsonPath);
  if (!file.existsSync()) {
    print('오류: $jsonPath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = file.readAsStringSync();
  final List<dynamic> items = jsonDecode(jsonString);

  print('========================================');
  print('Travel Spots 항목 업데이트');
  print('========================================');
  print('검색 조건: city="$city", name="$name"');
  print('');

  // city + name으로 항목 찾기
  int? targetIndex;
  Map<String, dynamic>? targetItem;

  for (int i = 0; i < items.length; i++) {
    final item = items[i] as Map<String, dynamic>;
    if (item['city'] == city && item['name'] == name) {
      targetIndex = i;
      targetItem = Map<String, dynamic>.from(item);
      break;
    }
  }

  if (targetIndex == null || targetItem == null) {
    print('오류: 해당 조건에 맞는 항목을 찾을 수 없습니다.');
    print('');

    // 유사한 항목 제안
    print('[유사한 항목 검색]');
    for (int i = 0; i < items.length; i++) {
      final item = items[i] as Map<String, dynamic>;
      if (item['name'] == name || item['city'] == city) {
        print('  - ${item['name']} (${item['city']}, ${item['province']})');
      }
    }
    exit(1);
  }

  print('찾은 항목:');
  print('  - 이름: ${targetItem['name']}');
  print('  - 영문명: ${targetItem['english name']}');
  print('  - 도시: ${targetItem['city']}');
  print('  - 지역: ${targetItem['province']}');
  print('  - 인덱스: $targetIndex');
  print('');

  // texts 데이터 로드
  List<String>? texts;
  if (textsFile != null) {
    final textsFileObj = File(textsFile);
    if (!textsFileObj.existsSync()) {
      print('오류: texts 파일을 찾을 수 없습니다: $textsFile');
      exit(1);
    }
    final textsData = jsonDecode(textsFileObj.readAsStringSync());
    if (textsData['texts'] != null) {
      texts = List<String>.from(textsData['texts']);
    }
  } else if (textsJson != null) {
    texts = List<String>.from(jsonDecode(textsJson));
  }

  // 업데이트 내용 표시
  print('[업데이트 내용]');

  if (imageUrl != null) {
    final oldImageUrl = targetItem['imageUrl'];
    print('  - imageUrl: ${oldImageUrl ?? "(없음)"} -> $imageUrl');
    targetItem['imageUrl'] = imageUrl;
  }

  if (englishName != null) {
    final oldEnglishName = targetItem['english name'];
    print('  - english name: ${oldEnglishName ?? "(없음)"} -> $englishName');
    targetItem['english name'] = englishName;
  }

  if (texts != null) {
    final oldTexts = targetItem['texts'] as List?;
    print('  - texts: ${oldTexts?.length ?? 0}개 -> ${texts.length}개');
    targetItem['texts'] = texts;

    // texts 내용 미리보기
    print('');
    print('[texts 내용 미리보기]');
    for (int i = 0; i < texts.length; i++) {
      final preview = texts[i].length > 100
          ? '${texts[i].substring(0, 100)}...'
          : texts[i];
      print('  texts[$i]: ${preview.replaceAll('\n', '\\n')}');
    }
  }
  print('');

  if (dryRun) {
    print('========================================');
    print('DRY RUN 모드: 실제 파일은 수정되지 않았습니다.');
    print('========================================');
    exit(0);
  }

  // 백업 생성
  final backupDir = Directory('tmp/backups');
  if (!backupDir.existsSync()) {
    backupDir.createSync(recursive: true);
  }
  File(backupPath).writeAsStringSync(jsonString);
  print('백업 생성: $backupPath');

  // 항목 업데이트
  items[targetIndex] = targetItem;

  // JSON 파일 저장
  final encoder = JsonEncoder.withIndent('    ');
  final updatedJsonString = encoder.convert(items);
  file.writeAsStringSync(updatedJsonString);

  print('');
  print('========================================');
  print('업데이트 완료!');
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

void printUsage() {
  print('''
사용법:
  dart run tmp/scripts/update_item.dart [옵션]

필수 옵션:
  --city <도시명>           도시 이름 (예: "코르도바")
  --name <이름>             여행지 이름 (예: "10,000 로지스 카페")

업데이트 옵션 (하나 이상 필수):
  --imageUrl <URL>          대표 이미지 URL
  --texts-file <파일경로>   texts 배열이 포함된 JSON 파일 경로
  --texts <JSON배열>        texts 배열 직접 전달 (예: '["텍스트1", "텍스트2"]')
  --english-name <이름>     영문 이름 업데이트

기타 옵션:
  --dry-run                 실제 저장 없이 미리보기만 수행
  --help                    이 도움말 표시

예시:
  dart run tmp/scripts/update_item.dart \\
    --city "코르도바" \\
    --name "10,000 로지스 카페" \\
    --imageUrl "https://example.com/image.jpg" \\
    --texts-file "tmp/collected/roses-cafe-texts.json"
''');
}
