/// v7 포인트 로그 데이터 모델
///
/// sf_point_log 테이블의 한 행을 나타내는 모델 클래스.
class PointLog {
  final int idx;
  final int idxMemberFrom;
  final int idxMemberTo;
  final int pointBefore;
  final int point;
  final int pointAfter;
  final String module;
  final String action;
  final int idxPost;
  final String etc;
  final int stamp;
  final String ip;

  bool get isPositive => point >= 0;

  const PointLog({
    required this.idx,
    required this.idxMemberFrom,
    required this.idxMemberTo,
    required this.pointBefore,
    required this.point,
    required this.pointAfter,
    required this.module,
    required this.action,
    required this.idxPost,
    required this.etc,
    required this.stamp,
    required this.ip,
  });

  factory PointLog.fromJson(Map<String, dynamic> json) {
    return PointLog(
      idx: _toInt(json['idx']),
      idxMemberFrom: _toInt(json['idx_member_from']),
      idxMemberTo: _toInt(json['idx_member_to']),
      pointBefore: _toInt(json['point_before']),
      point: _toInt(json['point']),
      pointAfter: _toInt(json['point_after']),
      module: json['module']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      idxPost: _toInt(json['idx_post']),
      etc: json['etc']?.toString() ?? '',
      stamp: _toInt(json['stamp']),
      ip: json['ip']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}
