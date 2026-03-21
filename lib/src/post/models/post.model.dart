import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// 기존 필고 DB 에서는 글과 코멘트를 하나의 테이블로 쓰고 있다. 그래서 Post 와 Comment 를 같이 쓴다.
class Post {
  /// * This is for updating the no_of_comment purposes only.
  int no_of_comment;
  String content;
  String subject;
  int good;

  // 필수 필드들
  final int idx;
  final int idx_root;
  final String post_id;
  final String category;
  final int no_of_view;
  final int stamp;
  final String timeString;
  final int no_of_attach;
  final String nickname;
  final int idx_member;
  final String photo_url;
  final String firebase_uid;
  final int level;
  final int point;

  // 옵셔널 필드들
  final String? subjectPrivate; // 블라인드 된 글의 제목
  final String? contentPrivate; // 블라인드 된 글의 내용

  // URL 목록. 기존 필고의 업로드된 파일 목록 뿐만아니라, 새로운 시스템에 업로드된 파일 목록도 포함되어 있다.
  final List<String> files;

  final List<Comment> comments;

  // 삭제 표시: 값이 존재하면 글이 삭제된 것이다.
  final dynamic deleted; // String, bool, null 타입을 모두 받을 수 있음

  // 블라인드 표시: Y 이면 블라인드 처리된 글이다.
  final String? blind; // "Y" 또는 null

  // 링크: 뉴스 링크 등
  final String? link;

  // DB 에 존재하는 것이 아니라, React.js 에서 코멘트를 재 정렬하는 것이다.
  final List<Post>? children;

  // DB 에 존재하는 필드가 아니라, 서버에서 content 가 HTML 인지 계산해서 보내져 온다.
  final bool? isHtml;

  // DB 에 존재하는 필드가 아니라, 서버에서 content 가 Markdown 인지 계산해서 보내져 온다.
  final bool? isMarkdown;

  // DB 에 존재하는 필드가 아니라, 서버에서 content 가 mixed content 인지 계산해서 보내져 온다.
  final bool? hasMixedContent;

  // 사진, 비디오, 유튜브 링크 여부
  final String? hasImage; // "y" 또는 ""
  final String? hasVideo; // "y" 또는 ""
  final String? hasYoutube; // "y" 또는 ""

  // varchar 필드들
  final String? varchar1; // 뉴스 등에서 링크가 저장됨
  final String? varchar2;
  final String? region; // 부동산 위치 정보를 저장하는 필드
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

  // 마사지 게시판의 포인트 상단 등록의 경우, 이 값이 Y 이면 승인 된 것이다.
  final String? char7;
  final String? char8;
  final String? char9;
  final String? char10;

  // text 필드들 (광고 연락처 정보 등에 사용)
  final String? text2; // 위챗 QR 이미지 URL
  final String? text3; // 라인 ID
  final String? text6; // 라인 QR 이미지 URL

  // 검열 결과
  final String? text9;

  final String? text10;

  // 검열 사유 (블라인드 처리 시 표시)
  // Moderation reason (shown when post is blinded)
  // 서버에서 text_8 필드에 검열 사유를 보냄
  final String? moderationReason;

  // 서버에서 보내는 블라인드 상태 (boolean)
  // Server sends blinded status as boolean field
  // true: 블라인드 처리된 글 (char_5가 'b' 또는 'f'인 경우)
  final bool blinded;

  // 서버에서 보내는 차단 상태 (boolean)
  // Server sends blocked status as boolean field
  // true: 차단된 글 (char_5가 'f'인 경우, 심각한 위반)
  final bool blocked;

  // 생성자
  Post({
    required this.idx,
    required this.idx_root,
    required this.post_id,
    required this.category,
    required this.subject,
    required this.content,
    required this.no_of_comment,
    required this.no_of_view,
    required this.stamp,
    required this.timeString,
    required this.good,
    required this.no_of_attach,
    required this.nickname,
    required this.idx_member,
    required this.photo_url,
    required this.firebase_uid,
    required this.level,
    required this.point,
    this.subjectPrivate,
    this.contentPrivate,
    this.files = const [],
    this.comments = const [],
    this.deleted,
    this.blind,
    this.link,
    this.children,
    this.isHtml,
    this.isMarkdown,
    this.hasMixedContent,
    this.hasImage,
    this.hasVideo,
    this.hasYoutube,
    this.varchar1,
    this.varchar2,
    this.region,
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
    this.text2,
    this.text3,
    this.text6,
    this.text9,
    this.text10,
    this.moderationReason,
    this.blinded = false,
    this.blocked = false,
  });

  // JSON 직렬화를 위한 factory 생성자
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      idx: json['idx'] as int,
      idx_root: json['idx_root'] ?? 0,
      post_id: json['post_id'] ?? '',
      category: json['category'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
      no_of_comment: json['no_of_comment'] ?? 0,
      no_of_view: json['no_of_view'] ?? 0,
      stamp: json['stamp'] ?? 0,
      timeString: json['time_string'] ?? '',
      good: json['good'] ?? 0,
      no_of_attach: json['no_of_attach'] ?? 0,
      nickname: json['nickname'] ?? '',
      idx_member: json['idx_member'] ?? 0,
      photo_url: json['photo_url'] ?? '',
      // photo_url: json['varchar_17'] ?? '',
      firebase_uid: json['firebase_uid'] ?? '',
      level: json['level'] ?? 0,
      point: json['point'] ?? 0,
      subjectPrivate: json['subject_private'] as String?,
      contentPrivate: json['content_private'] as String?,
      files: json['files'] == null
          ? []
          : (json['files'] as List<dynamic>).cast<String>(),
      comments: json['comments'] == null
          ? []
          : (json['comments'] as List<dynamic>)
                .map((e) => Comment.fromJson(e as Map<String, dynamic>))
                .toList(),
      deleted: json['deleted'],
      blind: json['blind'] as String?,
      link: json['link'] as String?,
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList(),
      isHtml: json['is_html'] as bool?,
      isMarkdown: json['is_markdown'] as bool?,
      hasMixedContent: json['has_mixed_content'] as bool?,
      hasImage: json['has_image'] as String?,
      hasVideo: json['has_video'] as String?,
      hasYoutube: json['has_youtube'] as String?,
      varchar1: json['varchar_1'] as String?,
      varchar2: json['varchar_2'] as String?,
      region: json['region'] as String?,
      varchar3: json['varchar_3'] as String?,
      varchar4: json['varchar_4'] as String?,
      varchar5: json['varchar_5'] as String?,
      varchar6: json['varchar_6'] as String?,
      varchar7: json['varchar_7'] as String?,
      varchar8: json['varchar_8'] as String?,
      varchar9: json['varchar_9'] as String?,
      varchar10: json['varchar_10'] as String?,
      varchar11: json['varchar_11'] as String?,
      varchar12: json['varchar_12'] as String?,
      varchar13: json['varchar_13'] as String?,
      varchar14: json['varchar_14'] as String?,
      varchar15: json['varchar_15'] as String?,
      varchar16: json['varchar_16'] as String?,
      varchar17: json['varchar_17'] as String?,
      varchar18: json['varchar_18'] as String?,
      varchar19: json['varchar_19'] as String?,
      varchar20: json['varchar_20'] as String?,
      int1: json['int_1'] as int?,
      int2: json['int_2'] as int?,
      int3: json['int_3'] as int?,
      int4: json['int_4'] as int?,
      int5: json['int_5'] as int?,
      int6: json['int_6'] as int?,
      int7: json['int_7'] as int?,
      int8: json['int_8'] as int?,
      int9: json['int_9'] as int?,
      int10: json['int_10'] as int?,
      char1: json['char_1'] as String?,
      char2: json['char_2'] as String?,
      char3: json['char_3'] as String?,
      char4: json['char_4'] as String?,
      char5: json['char_5'] as String?,
      char6: json['char_6'] as String?,
      char7: json['char_7'] as String?,
      char8: json['char_8'] as String?,
      char9: json['char_9'] as String?,
      char10: json['char_10'] as String?,
      text2: json['text_2'] as String?,
      text3: json['text_3'] as String?,
      text6: json['text_6'] as String?,
      text9: json['text_9'] as String?,
      text10: json['text_10'] as String?,
      // 검열 사유: text_8 필드 우선, 없으면 moderation_reason 필드 사용
      // Moderation reason: prefer text_8 field, fallback to moderation_reason
      moderationReason:
          (json['text_8'] as String?) ?? (json['moderation_reason'] as String?),
      // 서버에서 보내는 블라인드/차단 상태 (boolean)
      // Server sends blinded/blocked status as boolean fields
      blinded: json['blinded'] == true,
      blocked: json['blocked'] == true,
    );
  }

  // JSON 역직렬화를 위한 메서드
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'idx_root': idx_root,
      'post_id': post_id,
      'category': category,
      'subject': subject,
      'content': content,
      'no_of_comment': no_of_comment,
      'no_of_view': no_of_view,
      'stamp': stamp,
      'time_string': timeString,
      'good': good,
      'no_of_attach': no_of_attach,
      'nickname': nickname,
      'idx_member': idx_member,
      'photo_url': photo_url,
      'firebase_uid': firebase_uid,
      'level': level,
      'point': point,
      if (subjectPrivate != null) 'subject_private': subjectPrivate,
      if (contentPrivate != null) 'content_private': contentPrivate,
      'files': files,
      'comments': comments.map((e) => e.toJson()).toList(),
      if (deleted != null) 'deleted': deleted,
      if (blind != null) 'blind': blind,
      if (link != null) 'link': link,
      if (children != null)
        'children': children!.map((e) => e.toJson()).toList(),
      if (isHtml != null) 'is_html': isHtml,
      if (isMarkdown != null) 'is_markdown': isMarkdown,
      if (hasMixedContent != null) 'has_mixed_content': hasMixedContent,
      if (hasImage != null) 'has_image': hasImage,
      if (hasVideo != null) 'has_video': hasVideo,
      if (hasYoutube != null) 'has_youtube': hasYoutube,
      if (varchar1 != null) 'varchar_1': varchar1,
      if (varchar2 != null) 'varchar_2': varchar2,
      if (region != null) 'region': region,
      if (varchar3 != null) 'varchar_3': varchar3,
      if (varchar4 != null) 'varchar_4': varchar4,
      if (varchar5 != null) 'varchar_5': varchar5,
      if (varchar6 != null) 'varchar_6': varchar6,
      if (varchar7 != null) 'varchar_7': varchar7,
      if (varchar8 != null) 'varchar_8': varchar8,
      if (varchar9 != null) 'varchar_9': varchar9,
      if (varchar10 != null) 'varchar_10': varchar10,
      if (varchar11 != null) 'varchar_11': varchar11,
      if (varchar12 != null) 'varchar_12': varchar12,
      if (varchar13 != null) 'varchar_13': varchar13,
      if (varchar14 != null) 'varchar_14': varchar14,
      if (varchar15 != null) 'varchar_15': varchar15,
      if (varchar16 != null) 'varchar_16': varchar16,
      if (varchar17 != null) 'varchar_17': varchar17,
      if (varchar18 != null) 'varchar_18': varchar18,
      if (varchar19 != null) 'varchar_19': varchar19,
      if (varchar20 != null) 'varchar_20': varchar20,
      if (int1 != null) 'int_1': int1,
      if (int2 != null) 'int_2': int2,
      if (int3 != null) 'int_3': int3,
      if (int4 != null) 'int_4': int4,
      if (int5 != null) 'int_5': int5,
      if (int6 != null) 'int_6': int6,
      if (int7 != null) 'int_7': int7,
      if (int8 != null) 'int_8': int8,
      if (int9 != null) 'int_9': int9,
      if (int10 != null) 'int_10': int10,
      if (char1 != null) 'char_1': char1,
      if (char2 != null) 'char_2': char2,
      if (char3 != null) 'char_3': char3,
      if (char4 != null) 'char_4': char4,
      if (char5 != null) 'char_5': char5,
      if (char6 != null) 'char_6': char6,
      if (char7 != null) 'char_7': char7,
      if (char8 != null) 'char_8': char8,
      if (char9 != null) 'char_9': char9,
      if (char10 != null) 'char_10': char10,
      if (text2 != null) 'text_2': text2,
      if (text3 != null) 'text_3': text3,
      if (text6 != null) 'text_6': text6,
      if (text9 != null) 'text_9': text9,
      if (text10 != null) 'text_10': text10,
      if (moderationReason != null) 'moderation_reason': moderationReason,
      if (moderationReason != null) 'text_8': moderationReason,
      'blinded': blinded,
      'blocked': blocked,
    };
  }

  /// Create a copy of this Post with updated fields
  Post copyWith({
    int? idx,
    int? idx_root,
    String? post_id,
    String? category,
    String? subject,
    String? content,
    int? no_of_comment,
    int? no_of_view,
    int? stamp,
    String? timeString,
    int? good,
    int? no_of_attach,
    String? nickname,
    int? idx_member,
    String? photo_url,
    String? firebase_uid,
    int? level,
    int? point,
    String? subjectPrivate,
    String? contentPrivate,
    List<String>? files,
    List<Comment>? comments,
    dynamic deleted,
    String? blind,
    String? link,
    List<Post>? children,
    bool? isHtml,
    bool? isMarkdown,
    bool? hasMixedContent,
    String? hasImage,
    String? hasVideo,
    String? hasYoutube,
    String? varchar1,
    String? varchar2,
    String? region,
    String? varchar3,
    String? varchar4,
    String? varchar5,
    String? varchar6,
    String? varchar7,
    String? varchar8,
    String? varchar9,
    String? varchar10,
    String? varchar11,
    String? varchar12,
    String? varchar13,
    String? varchar14,
    String? varchar15,
    String? varchar16,
    String? varchar17,
    String? varchar18,
    String? varchar19,
    String? varchar20,
    int? int1,
    int? int2,
    int? int3,
    int? int4,
    int? int5,
    int? int6,
    int? int7,
    int? int8,
    int? int9,
    int? int10,
    String? char1,
    String? char2,
    String? char3,
    String? char4,
    String? char5,
    String? char6,
    String? char7,
    String? char8,
    String? char9,
    String? char10,
    String? text2,
    String? text3,
    String? text6,
    String? text9,
    String? text10,
    String? moderationReason,
    bool? blinded,
    bool? blocked,
  }) {
    return Post(
      idx: idx ?? this.idx,
      idx_root: idx_root ?? this.idx_root,
      post_id: post_id ?? this.post_id,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      no_of_comment: no_of_comment ?? this.no_of_comment,
      no_of_view: no_of_view ?? this.no_of_view,
      stamp: stamp ?? this.stamp,
      timeString: timeString ?? this.timeString,
      good: good ?? this.good,
      no_of_attach: no_of_attach ?? this.no_of_attach,
      nickname: nickname ?? this.nickname,
      idx_member: idx_member ?? this.idx_member,
      photo_url: photo_url ?? this.photo_url,
      firebase_uid: firebase_uid ?? this.firebase_uid,
      level: level ?? this.level,
      point: point ?? this.point,
      subjectPrivate: subjectPrivate ?? this.subjectPrivate,
      contentPrivate: contentPrivate ?? this.contentPrivate,
      files: files ?? this.files,
      comments: comments ?? this.comments,
      deleted: deleted ?? this.deleted,
      blind: blind ?? this.blind,
      link: link ?? this.link,
      children: children ?? this.children,
      isHtml: isHtml ?? this.isHtml,
      isMarkdown: isMarkdown ?? this.isMarkdown,
      hasMixedContent: hasMixedContent ?? this.hasMixedContent,
      hasImage: hasImage ?? this.hasImage,
      hasVideo: hasVideo ?? this.hasVideo,
      hasYoutube: hasYoutube ?? this.hasYoutube,
      varchar1: varchar1 ?? this.varchar1,
      varchar2: varchar2 ?? this.varchar2,
      region: region ?? this.region,
      varchar3: varchar3 ?? this.varchar3,
      varchar4: varchar4 ?? this.varchar4,
      varchar5: varchar5 ?? this.varchar5,
      varchar6: varchar6 ?? this.varchar6,
      varchar7: varchar7 ?? this.varchar7,
      varchar8: varchar8 ?? this.varchar8,
      varchar9: varchar9 ?? this.varchar9,
      varchar10: varchar10 ?? this.varchar10,
      varchar11: varchar11 ?? this.varchar11,
      varchar12: varchar12 ?? this.varchar12,
      varchar13: varchar13 ?? this.varchar13,
      varchar14: varchar14 ?? this.varchar14,
      varchar15: varchar15 ?? this.varchar15,
      varchar16: varchar16 ?? this.varchar16,
      varchar17: varchar17 ?? this.varchar17,
      varchar18: varchar18 ?? this.varchar18,
      varchar19: varchar19 ?? this.varchar19,
      varchar20: varchar20 ?? this.varchar20,
      int1: int1 ?? this.int1,
      int2: int2 ?? this.int2,
      int3: int3 ?? this.int3,
      int4: int4 ?? this.int4,
      int5: int5 ?? this.int5,
      int6: int6 ?? this.int6,
      int7: int7 ?? this.int7,
      int8: int8 ?? this.int8,
      int9: int9 ?? this.int9,
      int10: int10 ?? this.int10,
      char1: char1 ?? this.char1,
      char2: char2 ?? this.char2,
      char3: char3 ?? this.char3,
      char4: char4 ?? this.char4,
      char5: char5 ?? this.char5,
      char6: char6 ?? this.char6,
      char7: char7 ?? this.char7,
      char8: char8 ?? this.char8,
      char9: char9 ?? this.char9,
      char10: char10 ?? this.char10,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      text6: text6 ?? this.text6,
      text9: text9 ?? this.text9,
      text10: text10 ?? this.text10,
      moderationReason: moderationReason ?? this.moderationReason,
      blinded: blinded ?? this.blinded,
      blocked: blocked ?? this.blocked,
    );
  }

  @override
  String toString() {
    return "Post(${jsonEncode(toJson())})";
  }

  /// 첫 번째 이미지 URL을 반환합니다.
  String? get firstImageUrl {
    if (files.isEmpty) return null;

    // 이미지 확장자 체크
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];

    for (final file in files) {
      final lowerFile = file.toLowerCase();

      // 이미지 확장자를 가진 파일인지 확인
      final hasImageExtension = imageExtensions.any(
        (ext) => lowerFile.endsWith(ext),
      );

      if (hasImageExtension) {
        // 전체 URL인 경우
        if (file.startsWith('http://') || file.startsWith('https://')) {
          return file;
        }
        // 상대 경로인 경우 (필고 서버 URL 추가)
        else if (file.startsWith('/')) {
          return 'https://philgo.com$file';
        }
        // 파일명만 있는 경우
        else {
          return 'https://philgo.com/data/$file';
        }
      }
    }

    return null; // 이미지가 없는 경우
  }

  int get reportCounter {
    if (text10 == null) return 0;
    if (text10!.isEmpty) return 0;

    return text10!.split(',').where((e) => e.isNotEmpty).length;
  }

  bool isMine(BuildContext context) {
    return PhilgoState.of(context).user?.idx == idx_member;
  }

  /// 블라인드 처리된 글인지 확인
  ///
  /// 서버에서 AI 검열을 통해 블라인드 처리된 글의 경우 blinded 필드가 true입니다.
  /// 서버 API 응답의 blinded boolean 필드를 직접 사용합니다.
  ///
  /// 블라인드 사유 (char_5/MODERATION_STATUS):
  /// - 'b': 구인기준 미통과, 도박, 스팸 등 경미한 위반 (블라인드)
  /// - 'f': 욕설, 성적표현 등 심각한 위반 (차단)
  ///
  /// 레거시 호환 (blind 필드):
  /// - 'Y': 일반 블라인드 처리
  ///
  /// Returns true if the post is blinded by moderation
  bool get isBlinded => blinded || blind == 'Y' || blind == 'b' || blind == 'f';

  /// 차단된 글인지 확인 (심각한 위반)
  ///
  /// 욕설, 성적표현 등 심각한 커뮤니티 가이드라인 위반으로 차단된 글입니다.
  /// 차단된 글은 본인도 내용을 볼 수 없습니다.
  /// 서버 API 응답의 blocked boolean 필드를 직접 사용합니다.
  ///
  /// Returns true if the post is blocked (severe violation)
  bool get isBlocked => blocked || blind == 'f';

  /// 삭제된 글인지 확인
  ///
  /// deleted 필드에 값이 있으면 삭제된 글입니다.
  /// Returns true if the post is deleted
  bool get isDeleted => deleted != null && deleted.toString().isNotEmpty;

  /// 만료된 구인/구직 글인지 확인 (90일 규칙)
  ///
  /// 구인/구직 게시판(wanted)의 글이 작성 후 90일이 지나면 만료된 것으로 처리됩니다.
  /// 잘못된 정보(만료된 채용 공고 등)가 표시되는 것을 방지하기 위한 정책입니다.
  ///
  /// 서버에서 이미 subject/content를 대체 텍스트로 교체하여 보내지만,
  /// 클라이언트에서도 만료 여부를 확인하여 특별한 UI를 표시할 수 있습니다.
  ///
  /// Returns true if this is a job post older than 90 days
  bool get isExpiredJobPost {
    // 구인구직 게시판인지 확인
    if (post_id != 'wanted' && post_id != 'job') return false;

    // 90일 = 86400초 × 90 = 7,776,000초
    const int ninetyDaysInSeconds = 86400 * 90;
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // stamp가 현재 시간 - 90일보다 이전이면 만료
    return stamp < (currentTimestamp - ninetyDaysInSeconds);
  }

  /// Primary YouTube URL stored in varchar19 field
  /// Returns the YouTube URL from varchar19 if it exists and is not empty
  ///
  /// The varchar19 field is used by the API to store a primary/featured YouTube URL
  /// that takes precedence over URLs found in content
  String? get youtubeUrl {
    if (varchar19 != null && varchar19!.isNotEmpty) {
      return varchar19;
    }
    return null;
  }

  /// Get all YouTube URL information from this post
  ///
  /// Combines YouTube URLs from:
  /// 1. varchar19 field (primary YouTube URL - displayed first)
  /// 2. content field (URLs found within the post content)
  ///
  /// Duplicate URLs are removed based on videoId, with varchar19 URL taking precedence
  ///
  /// Returns: List of [YoutubeUrlInfo] with unique videos, varchar19 URL first
  List<YoutubeUrlInfo> getAllYoutubeUrlInfos() {
    final List<YoutubeUrlInfo> result = [];
    final Set<String> seenVideoIds = {};

    // 1. Add YouTube URL from varchar19 (primary URL - displayed first)
    if (youtubeUrl != null) {
      final varchar19Infos = extractYoutubeUrlInfos(youtubeUrl!);
      for (final info in varchar19Infos) {
        if (!seenVideoIds.contains(info.videoId)) {
          seenVideoIds.add(info.videoId);
          result.add(info);
        }
      }
    }

    // 2. Add YouTube URLs from content
    final contentInfos = extractYoutubeUrlInfos(content);
    for (final info in contentInfos) {
      // Skip if this video ID was already added from varchar19
      if (!seenVideoIds.contains(info.videoId)) {
        seenVideoIds.add(info.videoId);
        result.add(info);
      }
    }

    return result;
  }
}
