/// v6 계정 미리보기 데이터 모델
///
/// user.findV6Account API 응답을 매핑한다.
class V6AccountPreview {
  final String nickname;
  final int point;
  final int stamp;

  const V6AccountPreview({
    required this.nickname,
    required this.point,
    required this.stamp,
  });

  factory V6AccountPreview.fromJson(Map<String, dynamic> json) {
    return V6AccountPreview(
      nickname: json['nickname']?.toString() ?? '',
      point: _toInt(json['point']),
      stamp: _toInt(json['stamp']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
