/// 위키피디아 정보를 활용해 travel_spots.json 아이템들을 병렬로 업데이트합니다.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'travel_spots_utils.dart';

Future<void> main(List<String> args) async {
  final options = parseArgs(args);
  final travelSpotsPath = options['file'] ?? defaultTravelSpotsPath;
  final statePath = options['state'] ?? defaultStatePath;
  final logPath = options['log'] ?? defaultLogPath;
  final rawConcurrency = parseIntArg(options, 'max-concurrency') ?? 10;
  final maxConcurrency = rawConcurrency.clamp(1, 20).toInt();
  final startIndex = parseIntArg(options, 'start-index') ?? 0;
  final endIndex = parseIntArg(options, 'end-index');
  final limit = parseIntArg(options, 'limit');
  final dryRun = options['dry-run'] == 'true';
  final decorateOffset = parseIntArg(options, 'decorate-offset') ?? 0;

  final spots = await loadTravelSpots(travelSpotsPath);
  final state = await loadState(statePath);

  final lastIndex = spots.length - 1;
  final cappedEndIndex =
      endIndex == null ? lastIndex : endIndex.clamp(0, lastIndex);

  final pending = <int>[];
  for (var i = startIndex; i <= cappedEndIndex; i++) {
    if (!state.isProcessed(i) && !state.isReserved(i)) {
      pending.add(i);
      if (limit != null && pending.length >= limit) {
        break;
      }
    }
  }

  if (pending.isEmpty) {
    stdout.writeln('처리할 항목이 없습니다.');
    return;
  }

  stdout.writeln(
    '${pending.length}개 항목을 동시 처리 수 $maxConcurrency로 처리합니다.',
  );

  final executor = SerialExecutor();
  final semaphore = AsyncSemaphore(maxConcurrency);
  final futures = <Future<void>>[];

  for (final index in pending) {
    await semaphore.acquire();
    futures.add(() async {
      try {
        await processIndex(
          index: index,
          spots: spots,
          state: state,
          travelSpotsPath: travelSpotsPath,
          statePath: statePath,
          logPath: logPath,
          executor: executor,
          dryRun: dryRun,
          decorateOffset: decorateOffset,
        );
      } finally {
        semaphore.release();
      }
    }());
  }

  await Future.wait(futures);
  stdout.writeln('완료.');
}

Future<void> processIndex({
  required int index,
  required List<dynamic> spots,
  required TravelSpotsState state,
  required String travelSpotsPath,
  required String statePath,
  required String logPath,
  required SerialExecutor executor,
  required bool dryRun,
  required int decorateOffset,
}) async {
  final spot = Map<String, dynamic>.from(spots[index] as Map);
  final info = buildIndexInfo(spot, index);

  await executor.run(() async {
    final now = DateTime.now().toUtc().toIso8601String();
    state.reserve({...info, 'reservedAt': now});
    state.updatedAt = now;
    await saveState(statePath, state);
    await appendLog(logPath, {
      'timestamp': now,
      'status': 'reserved',
      ...info,
    });
  });

  try {
    final wiki = await fetchWikiInfo(
      name: spot['name']?.toString() ?? '',
      englishName: spot['english name']?.toString() ?? '',
      city: spot['city']?.toString(),
      province: spot['province']?.toString(),
    );
    final updated = buildUpdatedSpot(spot, wiki, decorateOffset);

    await executor.run(() async {
      if (!dryRun) {
        spots[index] = updated;
        await saveTravelSpots(travelSpotsPath, spots);
      }
      final now = DateTime.now().toUtc().toIso8601String();
      state.markProcessed(index);
      state.updatedAt = now;
      await saveState(statePath, state);
      await appendLog(logPath, {
        'timestamp': now,
        'status': dryRun ? 'dry-run' : 'updated',
        ...info,
        'wiki': wiki == null
            ? null
            : {
                'lang': wiki.lang,
                'title': wiki.title,
                'url': wiki.url,
              },
      });
    });

    stdout.writeln('업데이트 완료: index $index (${info['name']}).');
  } catch (error) {
    await executor.run(() async {
      final now = DateTime.now().toUtc().toIso8601String();
      final failure = <String, dynamic>{
        'timestamp': now,
        'status': 'failed',
        'error': error.toString(),
        ...info,
      };
      state.markFailed(index, failure);
      state.updatedAt = now;
      await saveState(statePath, state);
      await appendLog(logPath, failure);
    });
    stderr.writeln('업데이트 실패: index $index: $error');
  }
}

class AsyncSemaphore {
  int _available;
  final Queue<Completer<void>> _waiters = Queue<Completer<void>>();

  AsyncSemaphore(this._available);

  Future<void> acquire() {
    if (_available > 0) {
      _available--;
      return Future.value();
    }
    final completer = Completer<void>();
    _waiters.add(completer);
    return completer.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
      return;
    }
    _available++;
  }
}
