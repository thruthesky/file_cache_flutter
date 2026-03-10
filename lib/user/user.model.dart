/// v7 사용자 데이터 모델
///
/// v7 API(user.me) 응답의 sf_member 테이블 데이터를 매핑한다.
/// level과 level_progress는 서버에서 point 기반으로 동적 계산된 값이다.
class UserModel {
  final int idx;
  final String id;
  final String name;
  final String nickname;
  final String phoneNumber;
  final String firebaseUid;
  final int point;
  final int level;
  final int levelProgress;
  final String photoUrl;
  final String gender;
  final int noOfPost;
  final int noOfComment;
  final int stamp;

  const UserModel({
    required this.idx,
    required this.id,
    required this.name,
    required this.nickname,
    required this.phoneNumber,
    required this.firebaseUid,
    required this.point,
    required this.level,
    required this.levelProgress,
    required this.photoUrl,
    required this.gender,
    required this.noOfPost,
    required this.noOfComment,
    required this.stamp,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idx: _toInt(json['idx']),
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString() ?? '',
      firebaseUid: json['firebase_uid']?.toString() ?? '',
      point: _toInt(json['point']),
      level: _toInt(json['level']),
      levelProgress: _toInt(json['level_progress']),
      photoUrl: json['photo_url']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      noOfPost: _toInt(json['no_of_post']),
      noOfComment: _toInt(json['no_of_comment']),
      stamp: _toInt(json['stamp']),
    );
  }

  /// 표시할 이름 (name > nickname > id 우선순위)
  String get displayName {
    if (name.isNotEmpty) return name;
    if (nickname.isNotEmpty) return nickname;
    return id;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
