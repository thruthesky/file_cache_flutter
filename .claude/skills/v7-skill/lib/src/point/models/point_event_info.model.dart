/// 포인트 이벤트 정보 모델 (Point Event Info Model)
///
/// PhilGo API의 `get_point_event_info` 응답을 담는 모델 클래스입니다.
/// This model class contains the response from `get_point_event_info` API.
///
/// API 응답 예시 (API Response Example):
/// ```json
/// {
///   "dates": [[20260210, 20260220], [20260301, 20260311]],
///   "in_event": true
/// }
/// ```
class PointEventInfo {
  /// 이벤트 기간 배열 (Event Period Array)
  ///
  /// 각 요소는 [시작일, 종료일] 형식의 배열입니다.
  /// Each element is an array in [startDate, endDate] format.
  /// 날짜 형식: YYYYMMDD (예: 20260210 = 2026년 2월 10일)
  /// Date format: YYYYMMDD (e.g., 20260210 = February 10, 2026)
  final List<List<int>> dates;

  /// 현재 이벤트 기간 여부 (Is Currently in Event Period)
  ///
  /// true: 현재 포인트 이벤트 진행 중
  /// false: 현재 포인트 이벤트 진행 중이 아님
  final bool inEvent;

  PointEventInfo({
    required this.dates,
    required this.inEvent,
  });

  /// JSON 데이터로부터 PointEventInfo 인스턴스 생성
  /// Create PointEventInfo instance from JSON data
  factory PointEventInfo.fromJson(Map<String, dynamic> json) {
    // dates 파싱: List<dynamic> -> List<List<int>>
    // Parse dates: List<dynamic> -> List<List<int>>
    final List<List<int>> parsedDates = [];
    if (json['dates'] != null) {
      for (final dateRange in json['dates'] as List) {
        if (dateRange is List) {
          parsedDates.add(
            dateRange.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList(),
          );
        }
      }
    }

    return PointEventInfo(
      dates: parsedDates,
      inEvent: json['in_event'] == true,
    );
  }

  /// JSON으로 변환
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dates': dates,
      'in_event': inEvent,
    };
  }

  @override
  String toString() {
    return 'PointEventInfo(dates: $dates, inEvent: $inEvent)';
  }
}
