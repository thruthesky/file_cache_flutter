/// v7 팔로우 사용자 데이터 모델
///
/// v7 API(user.followingList) 응답의 팔로우 데이터를 매핑한다.
class FollowingUserModel {
  final int idx;
  final int idxFollowee;
  final String nickname;
  final String photoUrl;
  final String createdAt;

  const FollowingUserModel({
    required this.idx,
    required this.idxFollowee,
    required this.nickname,
    required this.photoUrl,
    required this.createdAt,
  });

  factory FollowingUserModel.fromJson(Map<String, dynamic> json) {
    return FollowingUserModel(
      idx: _toInt(json['idx']),
      idxFollowee: _toInt(json['idx_followee']),
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
