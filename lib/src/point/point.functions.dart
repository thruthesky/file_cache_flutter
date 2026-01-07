import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 포인트 이벤트 정보 캐시 (Point Event Info Cache)
///
/// 2시간 TTL로 설정되어 있으며, 메모리+파일 이중 캐싱을 사용합니다.
final _pointEventCache = FileCache<PointEventInfo>(
  cacheName: 'point_event',
  defaultTtl: Duration(hours: 2),
  fromJson: PointEventInfo.fromJson,
  toJson: (data) => data.toJson(),
  useMemoryCache: true,
);

/// 포인트 이벤트 캐시 키 (Cache key for point event info)
const _pointEventCacheKey = 'event_info';

/// 포인트 이벤트 정보를 가져옵니다. (Get Point Event Info)
///
/// PhilGo API의 `get_point_event_info` 함수를 호출하여
/// 현재 포인트 이벤트 기간인지 확인합니다.
/// 2시간 동안 캐시됩니다.
///
/// Calls the `get_point_event_info` function of PhilGo API
/// to check if it's currently a point event period.
/// Cached for 2 hours.
///
/// 반환값 (Return Value):
/// - [PointEventInfo] 객체
///   - dates: 이벤트 기간 배열 [[시작일, 종료일], ...]
///   - inEvent: 현재 이벤트 기간 여부
///
/// 사용 예시 (Usage Example):
/// ```dart
/// final eventInfo = await getPointEventInfo();
/// if (eventInfo.inEvent) {
///   // 포인트 이벤트 진행 중
///   print('현재 포인트 이벤트 진행 중입니다!');
/// }
/// ```
///
/// API 응답 예시 (API Response Example):
/// ```json
/// {
///   "dates": [[20260210, 20260220], [20260301, 20260311]],
///   "in_event": true
/// }
/// ```
Future<PointEventInfo> getPointEventInfo() async {
  // 1. 캐시에서 먼저 조회 (Try cache first)
  final cached = await _pointEventCache.get(_pointEventCacheKey);
  if (cached != null) {
    return cached;
  }

  // 2. API 호출 (Call API)
  final response = await func<Map<String, dynamic>>('get_point_event_info');

  // API 에러 응답 처리
  // Handle API error response
  if (response['error'] != null) {
    // 에러 발생 시 기본값 반환 (이벤트 아님)
    // Return default value on error (not in event)
    return PointEventInfo(dates: [], inEvent: false);
  }

  final result = PointEventInfo.fromJson(response);

  // 3. 캐시에 저장 (Save to cache)
  await _pointEventCache.set(_pointEventCacheKey, result);

  return result;
}

/// 포인트 이벤트 캐시 삭제 (Clear point event cache)
///
/// 캐시를 수동으로 갱신해야 할 때 호출합니다.
Future<void> clearPointEventCache() async {
  await _pointEventCache.clear();
}
