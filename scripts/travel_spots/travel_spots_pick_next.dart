/// 다음 여행지 아이템 인덱스를 예약(reserve)하고 기본 정보를 로그로 남깁니다.
library;

import 'dart:io';

import 'travel_spots_utils.dart';

Future<void> main(List<String> args) async {
  final options = parseArgs(args);
  final travelSpotsPath = options['file'] ?? defaultTravelSpotsPath;
  final statePath = options['state'] ?? defaultStatePath;
  final logPath = options['log'] ?? defaultLogPath;
  final startIndex = parseIntArg(options, 'start-index') ?? 0;

  final spots = await loadTravelSpots(travelSpotsPath);
  final state = await loadState(statePath);

  final index = pickNextIndex(state, spots.length, startIndex: startIndex);
  if (index == null) {
    stdout.writeln('예약 가능한 항목이 없습니다.');
    return;
  }

  final info = buildIndexInfo(spots[index] as Map<String, dynamic>, index);
  final now = DateTime.now().toUtc().toIso8601String();
  state.reserve({...info, 'reservedAt': now});
  state.updatedAt = now;
  await saveState(statePath, state);
  await appendLog(logPath, {
    'timestamp': now,
    'status': 'reserved',
    ...info,
  });

  stdout.writeln('예약 완료: index $index (${info['name']}).');
  stdout.writeln(info);
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
