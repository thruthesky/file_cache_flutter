/// 스핀 API 응답 모델
///
/// event.spin API가 반환하는 결과 데이터를 담는다.
class SpinResult {
  final int sectionIndex;
  final String prizeType;
  final int availableCoupons;
  final int currentPoint;

  SpinResult({
    required this.sectionIndex,
    required this.prizeType,
    required this.availableCoupons,
    required this.currentPoint,
  });

  factory SpinResult.fromJson(Map<String, dynamic> json) {
    return SpinResult(
      sectionIndex: _toInt(json['section_index']),
      prizeType: json['prize_type']?.toString() ?? '',
      availableCoupons: _toInt(json['available_coupons']),
      currentPoint: _toInt(json['current_point']),
    );
  }

  /// 스타벅스 쿠폰 당첨 여부
  bool get isCoupon => prizeType == 'starbucks';

  /// 꽝 여부
  bool get isMiss => prizeType == 'miss' || sectionIndex == 9;

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
