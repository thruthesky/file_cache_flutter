import 'package:firebase_database/firebase_database.dart';
import 'package:philgo/util/util.functions.dart';

class UserFirebaseModel {
  final String uid;
  final int? idx;
  final String nickname;
  final String nicknameLowerCase;
  final String name;
  final String gender;
  String? photoUrl;
  final int? level;
  final int? point;
  final int? noOfPost;
  final int? noOfComment;
  final int birthDay;
  final int birthMonth;
  final int birthYear;
  int get birthDate => birthYear * 10000 + birthMonth * 100 + birthDay;

  UserFirebaseModel({
    required this.uid,
    this.idx,
    required this.nickname,
    required this.nicknameLowerCase,
    this.photoUrl,
    this.level,
    this.point,
    this.noOfComment,
    this.noOfPost,
    this.name = '',
    this.gender = '',
    this.birthDay = 0,
    this.birthMonth = 0,
    this.birthYear = 0,
  });

  factory UserFirebaseModel.fromJson(Map<String, dynamic> json) {
    // log('userFirebaseModel fromJson: $json');
    return UserFirebaseModel(
      uid: json['uid'] ?? json['firebase_uid'] ?? '',
      idx: json['idx'] != null
          ? safeParseInt(json['idx'])
          : null, // idx가 없으면 null 반환
      nickname: json['nickname'] ?? '',
      nicknameLowerCase: json['nicknameLowerCase'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      level: json['level'],
      point: json['point'] ?? 0,
      noOfComment: json['no_of_comment'] ?? 0,
      noOfPost: json['no_of_post'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      // 생년월일 값들을 안전하게 int로 변환
      // 서버에서 String으로 전송될 수 있으므로 타입 체크 후 변환
      birthDay: safeParseInt(json['birth_day']),
      birthMonth: safeParseInt(json['birth_month']),
      birthYear: safeParseInt(json['birth_year']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'idx': idx, // 사용자 인덱스 번호
      'nickname': nickname,
      'nickname_lower_case': nicknameLowerCase,
      'photo_url': photoUrl,
      'level': level,
      'name': name,
      'gender': gender,
    };
  }

  factory UserFirebaseModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return UserFirebaseModel(
      uid: snapshot.key!,
      idx: data['idx'], // 사용자 인덱스 번호 (선택적)
      nickname: data['nickname'] ?? '',
      nicknameLowerCase: data['nickname_lower_case'] ?? '',
      photoUrl: data['photo_url'],
      level: data['level'],
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      birthDay: data['birth_day'] ?? 0,
      birthMonth: data['birth_month'] ?? 0,
      birthYear: data['birth_year'] ?? 0,
    );
  }
}
