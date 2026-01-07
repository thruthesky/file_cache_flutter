import 'package:philgo_api/philgo_api.dart';

/// 포인트 이벤트 정보를 가져옵니다. (Get Point Event Info)
///
/// PhilGo API의 `get_point_event_info` 함수를 호출하여
/// 현재 포인트 이벤트 기간인지 확인합니다.
///
/// Calls the `get_point_event_info` function of PhilGo API
/// to check if it's currently a point event period.
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
  final response = await func<Map<String, dynamic>>('get_point_event_info');

  // API 에러 응답 처리
  // Handle API error response
  if (response['error'] != null) {
    // 에러 발생 시 기본값 반환 (이벤트 아님)
    // Return default value on error (not in event)
    return PointEventInfo(dates: [], inEvent: false);
  }

  return PointEventInfo.fromJson(response);
}
