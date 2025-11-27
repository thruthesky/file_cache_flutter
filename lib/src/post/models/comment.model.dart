import 'dart:convert';

class Comment {
  /// ! NOT MUTABLE FIELDS !
  /// * This is for updating the comment purposes only.
  String content;
  List<String> files;
  int good; // Mutable for like updates

  /// Mutable fields
  final int idx;
  final int idx_parent;
  final int stamp;
  final int idx_member;
  final String firebase_uid;
  final String nickname;
  final String photo_url;
  final int level;
  final int point;

  final int idx_root;
  final int depth;

  // 사진, 비디오, 유튜브 링크 여부
  final String? hasImage; // "y" 또는 ""
  final String? hasVideo; // "y" 또는 ""
  final String? hasYoutube; // "y" 또는 ""

  // int 필드들
  final int? int1;
  final int? int2;
  final int? int3;
  final int? int4;
  final int? int5;
  final int? int6;
  final int? int7;
  final int? int8;
  final int? int9;
  final int? int10;

  // char 필드들
  final String? char1;
  final String? char2;
  final String? char3;
  final String? char4;
  final String? char5;
  final String? char6;
  final String? char7;
  final String? char8;
  final String? char9;
  final String? char10;

  // varchar 필드들
  final String? varchar1; // 뉴스 등에서 링크가 저장됨
  final String? varchar2;
  final String? varchar3;
  final String? varchar4;
  final String? varchar5;
  final String? varchar6;
  final String? varchar7;
  final String? varchar8;
  final String? varchar9;
  final String? varchar10;
  final String? varchar11;
  final String? varchar12;
  final String? varchar13;
  final String? varchar14;
  final String? varchar15;
  final String? varchar16;
  final String? varchar17;
  final String? varchar18;
  final String? varchar19;
  final String? varchar20;

  final String? text10;

  Comment({
    required this.idx,
    required this.idx_parent,
    required this.stamp,
    required this.idx_member,
    this.firebase_uid = '',
    this.nickname = '',
    this.photo_url = '',
    this.good = 0,
    this.level = 0,
    this.point = 0,
    required this.idx_root,
    required this.depth,
    this.content = '',
    this.files = const [],
    this.hasImage,
    this.hasVideo,
    this.hasYoutube,
    this.int1,
    this.int2,
    this.int3,
    this.int4,
    this.int5,
    this.int6,
    this.int7,
    this.int8,
    this.int9,
    this.int10,
    this.char1,
    this.char2,
    this.char3,
    this.char4,
    this.char5,
    this.char6,
    this.char7,
    this.char8,
    this.char9,
    this.char10,
    this.varchar1,
    this.varchar2,
    this.varchar3,
    this.varchar4,
    this.varchar5,
    this.varchar6,
    this.varchar7,
    this.varchar8,
    this.varchar9,
    this.varchar10,
    this.varchar11,
    this.varchar12,
    this.varchar13,
    this.varchar14,
    this.varchar15,
    this.varchar16,
    this.varchar17,
    this.varchar18,
    this.varchar19,
    this.varchar20,
    this.text10,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      idx: json['idx'] as int,
      idx_parent: json['idx_parent'] ?? 0,
      stamp: json['stamp'] ?? 0,
      idx_member: json['idx_member'] ?? 0,
      firebase_uid: json['firebase_uid'] ?? '',
      nickname: json['nickname'] ?? '',
      photo_url: json['photo_url'] ?? '',
      good: json['good'] ?? 0,
      level: json['level'] ?? 0,
      point: json['point'] ?? 0,
      idx_root: json['idx_root'] ?? 0,
      depth: json['depth'] ?? 0,
      content: json['content'],
      files: json['files'] != null
          ? List<String>.from(json['files'] as List)
          : [],
      hasImage: json['hasImage'],
      hasVideo: json['hasVideo'],
      hasYoutube: json['hasYoutube'],
      int1: json['int1'] != null ? int.parse(json['int1']) : null,
      int2: json['int2'] != null ? int.parse(json['int2']) : null,
      int3: json['int3'] != null ? int.parse(json['int3']) : null,
      int4: json['int4'] != null ? int.parse(json['int4']) : null,
      int5: json['int5'] != null ? int.parse(json['int5']) : null,
      int6: json['int6'] != null ? int.parse(json['int6']) : null,
      int7: json['int7'] != null ? int.parse(json['int7']) : null,
      int8: json['int8'] != null ? int.parse(json['int8']) : null,
      int9: json['int9'] != null ? int.parse(json['int9']) : null,
      int10: json['int10'] != null ? int.parse(json['int10']) : null,
      char1: json['char1'],
      char2: json['char2'],
      char3: json['char3'],
      char4: json['char4'],
      char5: json['char5'],
      char6: json['char6'],
      char7: json['char7'],
      char8: json['char8'],
      char9: json['char9'],
      char10: json['char10'],
      varchar1: json['varchar1'],
      varchar2: json['varchar2'],
      varchar3: json['varchar3'],
      varchar4: json['varchar4'],
      varchar5: json['varchar5'],
      varchar6: json['varchar6'],
      varchar7: json['varchar7'],
      varchar8: json['varchar8'],
      varchar9: json['varchar9'],
      varchar10: json['varchar10'],
      varchar11: json['varchar11'],
      varchar12: json['varchar12'],
      varchar13: json['varchar13'],
      varchar14: json['varchar14'],
      varchar15: json['varchar15'],
      varchar16: json['varchar16'],
      varchar17: json['varchar17'],
      varchar18: json['varchar18'],
      varchar19: json['varchar19'],
      varchar20: json['varchar20'],
      text10: json['text10'],
    );
  }

  Map<String, dynamic> toJson() {
    // Comment 객체를 JSON 형식의 Map으로 변환
    // 필수 필드들과 null이 아닌 옵셔널 필드들만 포함
    final Map<String, dynamic> json = {
      'idx': idx,
      'idx_parent': idx_parent,
      'stamp': stamp,
      'idx_member': idx_member,
      'firebase_uid': firebase_uid,
      'nickname': nickname,
      'photo_url': photo_url,
      'level': level,
      'point': point,
      'idx_root': idx_root,
      'depth': depth,
      'content': content,
      'files': files,
      'text10': text10,
    };

    // 미디어 관련 필드들 - null이 아닌 경우만 추가
    if (hasImage != null) json['hasImage'] = hasImage;
    if (hasVideo != null) json['hasVideo'] = hasVideo;
    if (hasYoutube != null) json['hasYoutube'] = hasYoutube;

    // int 필드들 - null이 아닌 경우만 추가
    // API에서는 문자열로 반환되므로 문자열로 변환
    if (int1 != null) json['int1'] = int1.toString();
    if (int2 != null) json['int2'] = int2.toString();
    if (int3 != null) json['int3'] = int3.toString();
    if (int4 != null) json['int4'] = int4.toString();
    if (int5 != null) json['int5'] = int5.toString();
    if (int6 != null) json['int6'] = int6.toString();
    if (int7 != null) json['int7'] = int7.toString();
    if (int8 != null) json['int8'] = int8.toString();
    if (int9 != null) json['int9'] = int9.toString();
    if (int10 != null) json['int10'] = int10.toString();

    // char 필드들 - null이 아닌 경우만 추가
    if (char1 != null) json['char1'] = char1;
    if (char2 != null) json['char2'] = char2;
    if (char3 != null) json['char3'] = char3;
    if (char4 != null) json['char4'] = char4;
    if (char5 != null) json['char5'] = char5;
    if (char6 != null) json['char6'] = char6;
    if (char7 != null) json['char7'] = char7;
    if (char8 != null) json['char8'] = char8;
    if (char9 != null) json['char9'] = char9;
    if (char10 != null) json['char10'] = char10;

    // varchar 필드들 - null이 아닌 경우만 추가
    if (varchar1 != null) json['varchar1'] = varchar1;
    if (varchar2 != null) json['varchar2'] = varchar2;
    if (varchar3 != null) json['varchar3'] = varchar3;
    if (varchar4 != null) json['varchar4'] = varchar4;
    if (varchar5 != null) json['varchar5'] = varchar5;
    if (varchar6 != null) json['varchar6'] = varchar6;
    if (varchar7 != null) json['varchar7'] = varchar7;
    if (varchar8 != null) json['varchar8'] = varchar8;
    if (varchar9 != null) json['varchar9'] = varchar9;
    if (varchar10 != null) json['varchar10'] = varchar10;
    if (varchar11 != null) json['varchar11'] = varchar11;
    if (varchar12 != null) json['varchar12'] = varchar12;
    if (varchar13 != null) json['varchar13'] = varchar13;
    if (varchar14 != null) json['varchar14'] = varchar14;
    if (varchar15 != null) json['varchar15'] = varchar15;
    if (varchar16 != null) json['varchar16'] = varchar16;
    if (varchar17 != null) json['varchar17'] = varchar17;
    if (varchar18 != null) json['varchar18'] = varchar18;
    if (varchar19 != null) json['varchar19'] = varchar19;
    if (varchar20 != null) json['varchar20'] = varchar20;
    if (text10 != null) json['text10'] = text10;

    return json;
  }

  @override
  String toString() {
    return "Comment(${jsonEncode(toJson())})";
  }

  int get reportCounter {
    if (text10 == null) return 0;
    if (text10!.isEmpty) return 0;

    return text10!.split(',').where((e) => e.isNotEmpty).length;
  }
}
