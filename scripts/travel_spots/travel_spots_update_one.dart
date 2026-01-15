/// 위키피디아 정보를 활용해 travel_spots.json의 특정 아이템 1개를 업데이트합니다.
library;

import 'dart:io';

import 'travel_spots_utils.dart';

Future<void> main(List<String> args) async {
  final options = parseArgs(args);
  final travelSpotsPath = options['file'] ?? defaultTravelSpotsPath;
  final statePath = options['state'] ?? defaultStatePath;
  final logPath = options['log'] ?? defaultLogPath;
  final dryRun = options['dry-run'] == 'true';
  final decorateOffset = parseIntArg(options, 'decorate-offset') ?? 0;

  final spots = await loadTravelSpots(travelSpotsPath);
  final state = await loadState(statePath);

  var index = parseIntArg(options, 'index');
  final startIndex = parseIntArg(options, 'start-index') ?? 0;

  if (index == null && options['next'] == 'true') {
    index = pickNextIndex(state, spots.length, startIndex: startIndex);
    if (index != null) {
      final info =
          buildIndexInfo(spots[index] as Map<String, dynamic>, index);
      final now = DateTime.now().toUtc().toIso8601String();
      state.reserve({...info, 'reservedAt': now});
      state.updatedAt = now;
      await saveState(statePath, state);
      await appendLog(logPath, {
        'timestamp': now,
        'status': 'reserved',
        ...info,
      });
    }
  }

  if (index == null) {
    stderr.writeln(
      '사용법: dart run scripts/travel_spots/travel_spots_update_one.dart --index=3\n'
      '   또는: dart run scripts/travel_spots/travel_spots_update_one.dart --next',
    );
    exitCode = 64;
    return;
  }

  if (index < 0 || index >= spots.length) {
    stderr.writeln('인덱스 $index 범위 오류 (0..${spots.length - 1}).');
    exitCode = 64;
    return;
  }

  final spot = Map<String, dynamic>.from(spots[index] as Map);
  final info = buildIndexInfo(spot, index);

  try {
    final wiki = await fetchWikiInfo(
      name: spot['name']?.toString() ?? '',
      englishName: spot['english name']?.toString() ?? '',
      city: spot['city']?.toString(),
      province: spot['province']?.toString(),
    );
    final updated = buildUpdatedSpot(spot, wiki, decorateOffset);

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

    stdout.writeln('업데이트 완료: index $index (${info['name']}).');
  } catch (error) {
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
    stderr.writeln('업데이트 실패: index $index: $error');
    exitCode = 1;
  }
}

int? pickNextIndex(
  TravelSpotsState state,
  int total, {
  int startIndex = 0,
}) {
  for (var i = startIndex; i < total; i++) {
    if (!state.isProcessed(i) && !state.isReserved(i)) {
      return i;
    }
  }
  return null;
}
