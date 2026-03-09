/// v7 포인트 로그 데이터 모델
///
/// sf_point_log 테이블의 한 행을 나타내는 모델 클래스.
/// pointLog.history API 응답의 각 아이템을 타입 안전하게 다루기 위해 사용한다.
///
/// 사용 예시:
/// ```dart
/// final logs = await PointLogApi.history(page: 1);
/// for (final log in logs) {
///   print('${log.module}/${log.action}: ${log.point}P');
/// }
/// ```
class PointLog {
  /// 로그 고유 ID
  final int idx;

  /// 포인트를 변경한(보낸) 회원 ID
  final int idxMemberFrom;

  /// 포인트를 받은 회원 ID
  final int idxMemberTo;

  /// 변경 전 포인트
  final int pointBefore;

  /// 변경 포인트 (양수=증가, 음수=감소)
  final int point;

  /// 변경 후 포인트
  final int pointAfter;

  /// 모듈명 (예: post, comment, event, company)
  final String module;

  /// 액션명 (예: create, delete, spin, revisit)
  final String action;

  /// 관련 게시글 ID (없으면 0)
  final int idxPost;

  /// 기타 정보 (사유 등)
  final String etc;

  /// Unix 타임스탬프
  final int stamp;

  /// 사용자 IP 주소
  final String ip;

  /// 포인트가 양수인지 여부
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

  /// JSON Map에서 PointLog 생성
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

  /// 서버 응답 값을 안전하게 int로 변환
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  String toString() =>
      'PointLog(idx: $idx, module: $module, action: $action, point: $point)';
}
