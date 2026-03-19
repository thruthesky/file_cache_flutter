/// v7 차단된 사용자 데이터 모델
///
/// v7 API(user.blockedList) 응답의 sf_member_blocks 테이블 데이터를 매핑한다.
class BlockedUserModel {
  final int idx;
  final int idxBlockee;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  const BlockedUserModel({
    required this.idx,
    required this.idxBlockee,
    required this.nickname,
    required this.photoUrl,
    required this.createdAt,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) {
    return BlockedUserModel(
      idx: _toInt(json['idx']),
      idxBlockee: _toInt(json['idx_blockee']),
      nickname: json['nickname']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
