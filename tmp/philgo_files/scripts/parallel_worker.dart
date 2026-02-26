// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'parallel_lock_utils.dart';

/// 병렬 처리 Worker 스크립트
///
/// 여러 인스턴스를 동시에 실행하여 여행 정보를 병렬로 업데이트합니다.
/// Lock 메커니즘을 통해 동일한 항목을 중복 처리하지 않습니다.
///
/// 사용법:
/// ```shell
/// # 터미널 1
/// dart run lib/philgo_files/scripts/parallel_worker.dart --worker-id 1
///
/// # 터미널 2
/// dart run lib/philgo_files/scripts/parallel_worker.dart --worker-id 2
///
/// # ... 최대 10개까지 동시 실행
/// dart run lib/philgo_files/scripts/parallel_worker.dart --worker-id 10
/// ```
///
/// 옵션:
/// --worker-id n   : Worker 식별자 (1-10, 필수)
/// --province name : 특정 지역만 처리
/// --type type     : 처리 유형 (texts, imageUrl, metadata)
/// --max-items n   : 최대 처리 항목 수
/// --dry-run       : 실제 수정 없이 미리보기

/// JSON 파일 경로
const String jsonFilePath = 'lib/philgo_files/travel/travel_spots.json';

void main(List<String> args) async {
  //  print('=' * 60);
  //  print('🔧 Travel Spots 병렬 Worker');
  //  print('=' * 60);

  // 명령줄 인자 파싱
  String? workerId;
  String? provinceFilter;
  String? processType;
  int? maxItems;
  bool isDryRun = false;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--worker-id' && i + 1 < args.length) {
      workerId = 'worker_${args[i + 1]}';
    } else if (args[i] == '--province' && i + 1 < args.length) {
      provinceFilter = args[i + 1];
    } else if (args[i] == '--type' && i + 1 < args.length) {
      processType = args[i + 1];
    } else if (args[i] == '--max-items' && i + 1 < args.length) {
      maxItems = int.tryParse(args[i + 1]);
    } else if (args[i] == '--dry-run') {
      isDryRun = true;
    }
  }

  // Worker ID 필수 확인
  if (workerId == null) {
    //    print('');
    //    print('❌ 오류: --worker-id 옵션이 필요합니다.');
    //    print('');
    //    print('사용법:');
    //    print('  dart run lib/philgo_files/scripts/parallel_worker.dart --worker-id 1');
    //    print('');
    //    print('옵션:');
    //    print('  --worker-id n   : Worker 식별자 (1-10, 필수)');
    //    print('  --province name : 특정 지역만 처리 (예: Palawan)');
    //    print('  --type type     : 처리 유형 (texts, imageUrl, metadata)');
    //    print('  --max-items n   : 최대 처리 항목 수');
    //    print('  --dry-run       : 실제 수정 없이 미리보기');
    exit(1);
  }

  //  print('');
  //  print('📌 Worker 설정:');
  //  print('   Worker ID: $workerId');
  if (provinceFilter != null) // print('   지역 필터: $provinceFilter');
    if (processType != null) // print('   처리 유형: $processType');
      if (maxItems != null) // print('   최대 항목: $maxItems');
        if (isDryRun) // print('   🔍 Dry-run 모드');
          //  print('');
          // 디렉토리 초기화
          initializeDirectories();

  // JSON 파일 읽기
  final jsonFile = File(jsonFilePath);
  if (!jsonFile.existsSync()) {
    //    print('❌ 오류: $jsonFilePath 파일을 찾을 수 없습니다.');
    exit(1);
  }

  final jsonString = jsonFile.readAsStringSync();
  final List<dynamic> travelSpots = jsonDecode(jsonString);

  //  print('📋 총 여행지 수: ${travelSpots.length}개');

  // 처리 대상 인덱스 필터링
  List<int> targetIndices = [];

  for (int i = 0; i < travelSpots.length; i++) {
    final spot = travelSpots[i];
    final province = spot['province']?.toString() ?? '';
    final texts = spot['texts'] as List<dynamic>? ?? [];
    final imageUrl = spot['imageUrl']?.toString() ?? '';
    final description = spot['description']?.toString() ?? '';

    // 지역 필터
    if (provinceFilter != null &&
        !province.toLowerCase().contains(provinceFilter.toLowerCase())) {
      continue;
    }

    // 처리 유형 필터
    bool needsProcessing = false;

    if (processType == null) {
      // 기본: 모든 문제 있는 항목
      needsProcessing =
          texts.isEmpty || imageUrl.isEmpty || description.length < 50;
    } else if (processType == 'texts') {
      needsProcessing = texts.isEmpty;
    } else if (processType == 'imageUrl') {
      needsProcessing = imageUrl.isEmpty;
    } else if (processType == 'metadata') {
      final city = spot['city']?.toString() ?? '';
      final englishName = spot['english name']?.toString() ?? '';
      needsProcessing = city.isEmpty || englishName.isEmpty;
    }

    if (needsProcessing) {
      targetIndices.add(i);
    }
  }

  // 인덱스 셔플 (여러 Worker가 동시에 시작해도 분산되도록)
  targetIndices.shuffle(Random(workerId.hashCode));

  //  print('🎯 처리 대상: ${targetIndices.length}개');
  //  print('');

  // 진행 상황 출력
  //  printProgress(travelSpots.length);

  // Worker 로그 시작
  logWorker(workerId, 'Worker 시작 - 대상: ${targetIndices.length}개');

  int processedCount = 0;
  int successCount = 0;
  int skipCount = 0;
  int failCount = 0;

  // 메인 처리 루프
  for (final index in targetIndices) {
    // 최대 처리 수 확인
    if (maxItems != null && processedCount >= maxItems) {
      //      print('');
      //      print('⏹️  최대 처리 수($maxItems)에 도달. 종료합니다.');
      break;
    }

    // Lock 획득 시도
    final spot = travelSpots[index];
    final name = spot['name']?.toString() ?? '(이름 없음)';
    final englishName = spot['english name']?.toString() ?? '';

    final status = checkLockStatus(index);

    if (status == LockStatus.completed) {
      // 이미 완료됨
      skipCount++;
      continue;
    }

    if (status == LockStatus.locked) {
      // 다른 Worker가 처리 중
      continue;
    }

    if (status == LockStatus.failed) {
      // 이전에 실패함 (재시도 하려면 clearFailedItems() 호출)
      skipCount++;
      continue;
    }

    // Lock 획득
    if (!tryAcquireLock(index, workerId, spotName: name)) {
      // 다른 Worker가 먼저 획득함
      continue;
    }

    processedCount++;

    //    print('');
    //    print('🔄 [$workerId] 처리 중 [$index]: $name');
    logWorker(workerId, '처리 시작: [$index] $name');

    try {
      // 실제 처리 로직 (여기서 구현)
      if (isDryRun) {
        // Dry-run: 미리보기만
        //        print('   📝 이름: $name');
        //        print('   📝 영문: $englishName');
        //        print('   📝 지역: ${spot['province']}');

        final texts = spot['texts'] as List<dynamic>? ?? [];
        //        print('   📝 texts 상태: ${texts.isEmpty ? "비어있음" : "${texts.length}개"}');

        // 처리 시뮬레이션 (1-2초 대기)
        await Future.delayed(
          Duration(milliseconds: 500 + Random().nextInt(500)),
        );

        // 완료 표시
        markCompleted(
          index,
          metadata: {'name': name, 'workerId': workerId, 'dryRun': true},
        );

        successCount++;
        //        print('   ✅ 완료 (dry-run)');
      } else {
        // 실제 처리
        // TODO: 실제 데이터 업데이트 로직 구현
        // - Wikipedia API로 이미지 검색
        // - AI로 texts 콘텐츠 생성
        // - 메타데이터 보강

        // 임시: 시뮬레이션
        await Future.delayed(
          Duration(milliseconds: 1000 + Random().nextInt(1000)),
        );

        // 완료 표시
        markCompleted(index, metadata: {'name': name, 'workerId': workerId});

        successCount++;
        //        print('   ✅ 완료');
      }

      logWorker(workerId, '처리 완료: [$index] $name');
    } catch (e) {
      // 실패 처리
      markFailed(
        index,
        e.toString(),
        metadata: {'name': name, 'workerId': workerId},
      );

      failCount++;
      //      print('   ❌ 실패: $e');
      logWorker(workerId, '처리 실패: [$index] $name - $e');
    }

    // Rate limiting (API 호출 제한 대응)
    await Future.delayed(const Duration(milliseconds: 200));

    // 주기적으로 진행 상황 저장 (10개 처리마다)
    if (processedCount % 10 == 0) {
      saveProgress(travelSpots.length);
    }
  }

  // 최종 진행 상황 저장
  saveProgress(travelSpots.length);

  // 결과 출력
  //  print('');
  //  print('=' * 60);
  //  print('📊 $workerId 작업 결과');
  //  print('=' * 60);
  //  print('  처리 시도: $processedCount개');
  //  print('  ✅ 성공: $successCount개');
  //  print('  ⏭️  건너뜀: $skipCount개');
  //  print('  ❌ 실패: $failCount개');
  //  print('=' * 60);

  // 전체 진행 상황 출력
  //  printProgress(travelSpots.length);

  logWorker(
    workerId,
    'Worker 종료 - 처리: $processedCount, 성공: $successCount, 실패: $failCount',
  );
}
