import '../file/file.functions.dart';
import '../youtube/youtube.service.dart';
import '../youtube/youtube.model.dart';

/// v7 PostEntity 기반 게시글 모델
class Post {
  final int idx;
  final int idxMember;
  final int idxRoot;
  final int idxParent;
  final String postId;
  final String subject;
  final String content;
  final int stamp;
  final int stampUpdate;
  final int depth;
  final int noOfComment;
  final int noOfView;
  final int good;
  final String category;
  final int earnedPoint;
  final String secret;
  final String checked;
  final String blind;
  final String hasImage;
  final String hasVideo;
  final String? imageUrl;
  final String? videoUrl;
  final String? thumbnail400x400;
  final String? thumbnail800x800;
  final String? thumbnail600;
  final String? thumbnail1000;
  final String? resolvedThumbnail;
  final String userName;
  final String userNickname;
  final String userFirebaseUid;
  final String userPhotoUrl;
  final String files;
  final String contentType;
  final bool isMarkdown;
  final bool isHtml;
  final bool isText;
  final String hasYoutube;
  final String? youtubeUrl;
  final int deleted;
  final String report;
  final String reminder;
  final int bad;
  final int stampLastComment;
  final int listOrder;
  final String userId;
  final String userEmail;
  final String subCategory;
  final String groupId;
  final String gid;
  final String link;
  final String region;
  final String ip;
  final int noOfAttach;

  // 구인(hiring) 전용 필드
  final String varchar4; // varchar_4: 회사 이름
  final String varchar5; // varchar_5: 주소
  final String varchar6; // varchar_6: 전화번호
  final String varchar7; // varchar_7: 근무제
  final String varchar8; // varchar_8: 이메일
  final String varchar9; // varchar_9: 업무 범위
  final int int1; // int_1: 급여
  final String text1; // text_1: 회사 소개

  // 광고 연락처 필드
  final String varchar13; // varchar_13: 카카오톡 QR URL
  final String varchar14; // varchar_14: 텔레그램 ID
  final String varchar15; // varchar_15: 전화번호
  final String varchar16; // varchar_16: 위챗 ID
  final String varchar20; // varchar_20: 라인 QR URL
  final String text2; // text_2: 위챗 QR 이미지
  final String text3; // text_3: 라인 ID

  // AI 답변 필드
  final String text7; // text_7: AI 답변 내용 (마크다운)

  // 포인트 광고 관련 필드
  final int adEndTime; // int_5: 광고 종료 Unix timestamp (초)
  final int adStartTime; // int_6: 마지막 광고 등록 시간
  final int adDays; // int_7: 마지막 등록 기간 (일)
  final int adPoints; // int_8: 마지막 등록에 소비한 포인트

  // 사용자 상호작용 상태 (런타임, API 응답에서 설정)
  final bool liked;
  final bool bookmarked;
  final bool reported;
  final bool blocked;

  const Post({
    required this.idx,
    required this.idxMember,
    this.idxRoot = 0,
    this.idxParent = 0,
    required this.postId,
    required this.subject,
    required this.content,
    required this.stamp,
    required this.stampUpdate,
    required this.depth,
    required this.noOfComment,
    required this.noOfView,
    required this.good,
    required this.category,
    required this.earnedPoint,
    required this.secret,
    required this.checked,
    required this.blind,
    required this.hasImage,
    required this.hasVideo,
    this.imageUrl,
    this.videoUrl,
    this.thumbnail400x400,
    this.thumbnail800x800,
    this.thumbnail600,
    this.thumbnail1000,
    this.resolvedThumbnail,
    this.userName = '',
    this.userNickname = '',
    this.userFirebaseUid = '',
    this.userPhotoUrl = '',
    this.files = '',
    this.contentType = '',
    this.isMarkdown = false,
    this.isHtml = false,
    this.isText = true,
    this.hasYoutube = '',
    this.youtubeUrl,
    this.deleted = 0,
    this.report = '',
    this.reminder = '',
    this.bad = 0,
    this.stampLastComment = 0,
    this.listOrder = 0,
    this.userId = '',
    this.userEmail = '',
    this.subCategory = '',
    this.groupId = '',
    this.gid = '',
    this.link = '',
    this.region = '',
    this.ip = '',
    this.noOfAttach = 0,
    this.varchar4 = '',
    this.varchar5 = '',
    this.varchar6 = '',
    this.varchar7 = '',
    this.varchar8 = '',
    this.varchar9 = '',
    this.int1 = 0,
    this.text1 = '',
    this.varchar13 = '',
    this.varchar14 = '',
    this.varchar15 = '',
    this.varchar16 = '',
    this.varchar20 = '',
    this.text2 = '',
    this.text3 = '',
    this.text7 = '',
    this.adEndTime = 0,
    this.adStartTime = 0,
    this.adDays = 0,
    this.adPoints = 0,
    this.liked = false,
    this.bookmarked = false,
    this.reported = false,
    this.blocked = false,
  });

  /// 댓글 여부 (depth > 0)
  bool get isComment => depth > 0;

  /// 글 여부 (depth == 0)
  bool get isPost => depth == 0;

  /// 검열 거부 여부
  bool get isBlocked => checked == 'R';

  /// 블라인드 여부
  bool get isBlinded => blind == 'Y';

  /// 비밀글 여부
  bool get isSecret => secret == 'Y';

  /// 자식 댓글 존재 여부 (수정/삭제 가능 여부 판단용)
  bool get hasChildren => noOfComment > 0 && isComment;

  /// YouTube 포함 여부
  bool get isYoutube => hasYoutube == 'y';

  /// 게시글에서 모든 YouTube URL 정보 추출
  ///
  /// youtubeUrl(varchar_19) 우선, content에서 추가 추출, 중복 제거
  List<YoutubeUrlInfo> getAllYoutubeUrlInfos() {
    final List<YoutubeUrlInfo> result = [];
    final Set<String> seenVideoIds = {};

    // 1단계: youtubeUrl(varchar_19)에서 추출 (우선순위 1)
    if (youtubeUrl != null && youtubeUrl!.isNotEmpty) {
      final infos = extractYoutubeUrlInfos(youtubeUrl!);
      for (final info in infos) {
        if (!seenVideoIds.contains(info.videoId)) {
          seenVideoIds.add(info.videoId);
          result.add(info);
        }
      }
    }

    // 2단계: content에서 추출 (우선순위 2)
    if (content.isNotEmpty) {
      final infos = extractYoutubeUrlInfos(content);
      for (final info in infos) {
        if (!seenVideoIds.contains(info.videoId)) {
          seenVideoIds.add(info.videoId);
          result.add(info);
        }
      }
    }

    return result;
  }

  factory Post.minimal({required int idx}) =>
      Post.fromJson({'idx': idx});

  /// JSON에서 Post 객체 생성
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      idx: _toInt(json['idx']),
      idxMember: _toInt(json['idx_member']),
      idxRoot: _toInt(json['idx_root']),
      idxParent: _toInt(json['idx_parent']),
      postId: json['post_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      stamp: _toInt(json['stamp']),
      stampUpdate: _toInt(json['stamp_update']),
      depth: _toInt(json['depth']),
      noOfComment: _toInt(json['no_of_comment']),
      noOfView: _toInt(json['no_of_view']),
      good: _toInt(json['good']),
      category: json['category']?.toString() ?? '',
      earnedPoint: _toInt(json['int_10']),
      secret: json['secret']?.toString() ?? '',
      checked: json['checked']?.toString() ?? '',
      blind: json['blind']?.toString() ?? '',
      hasImage: json['has_image']?.toString() ?? '',
      hasVideo: json['has_video']?.toString() ?? '',
      imageUrl: _toAbsoluteUrlOrNull(json['varchar_17']?.toString()),
      videoUrl: json['varchar_18']?.toString(),
      thumbnail400x400: _toAbsoluteUrlOrNull(json['varchar_10']?.toString()),
      thumbnail800x800: _toAbsoluteUrlOrNull(json['varchar_11']?.toString()),
      thumbnail600: _toAbsoluteUrlOrNull(json['thumbnail_600']?.toString()),
      thumbnail1000: _toAbsoluteUrlOrNull(json['varchar_12']?.toString()),
      resolvedThumbnail: _toAbsoluteUrlOrNull(json['resolved_thumbnail']?.toString()),
      userName: json['user_name']?.toString() ?? '',
      userNickname: json['user_nickname']?.toString() ?? '',
      userFirebaseUid: json['user_firebase_uid']?.toString() ?? '',
      userPhotoUrl: json['user_photo_url']?.toString() ?? '',
      files: json['files']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      isMarkdown: json['is_markdown'] == true || json['is_markdown'] == 1,
      isHtml: json['is_html'] == true || json['is_html'] == 1,
      isText: (json['is_text'] == true || json['is_text'] == 1) ||
          (json['is_markdown'] != true &&
              json['is_markdown'] != 1 &&
              json['is_html'] != true &&
              json['is_html'] != 1),
      hasYoutube: json['has_youtube']?.toString() ?? '',
      youtubeUrl: json['varchar_19']?.toString(),
      deleted: _toInt(json['deleted']),
      report: json['report']?.toString() ?? '',
      reminder: json['reminder']?.toString() ?? '',
      bad: _toInt(json['bad']),
      stampLastComment: _toInt(json['stamp_last_comment']),
      listOrder: _toInt(json['list_order']),
      userId: json['user_id']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      subCategory: json['sub_category']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      gid: json['gid']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      noOfAttach: _toInt(json['no_of_attach']),
      varchar4: json['varchar_4']?.toString() ?? '',
      varchar5: json['varchar_5']?.toString() ?? '',
      varchar6: json['varchar_6']?.toString() ?? '',
      varchar7: json['varchar_7']?.toString() ?? '',
      varchar8: json['varchar_8']?.toString() ?? '',
      varchar9: json['varchar_9']?.toString() ?? '',
      int1: _toInt(json['int_1']),
      text1: json['text_1']?.toString() ?? '',
      varchar13: json['varchar_13']?.toString() ?? '',
      varchar14: json['varchar_14']?.toString() ?? '',
      varchar15: json['varchar_15']?.toString() ?? '',
      varchar16: json['varchar_16']?.toString() ?? '',
      varchar20: json['varchar_20']?.toString() ?? '',
      text2: json['text_2']?.toString() ?? '',
      text3: json['text_3']?.toString() ?? '',
      text7: json['text_7']?.toString() ?? '',
      adEndTime: _toInt(json['int_5']),
      adStartTime: _toInt(json['int_6']),
      adDays: _toInt(json['int_7']),
      adPoints: _toInt(json['int_8']),
      liked: json['liked'] == true,
      bookmarked: json['bookmarked'] == true,
      reported: json['reported'] == true,
      blocked: json['blocked'] == true,
    );
  }

  /// AI 답변 존재 여부
  bool get hasAiAnswer => text7.isNotEmpty;

  /// AI 답변 대상 여부 (qna/freetalk, 원글, info 제외)
  bool get isAiAnswerTarget =>
      depth == 0 &&
      (postId == 'qna' || postId == 'freetalk') &&
      groupId != 'info';

  /// 포인트 광고 활성 여부
  bool get isAdActive =>
      adEndTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 포인트 광고 남은 일수
  int get adRemainingDays {
    if (!isAdActive) return 0;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return ((adEndTime - now) / 86400).ceil();
  }

  /// 포인트 광고 만료 DateTime
  DateTime? get adEndDateTime {
    if (adEndTime <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(adEndTime * 1000);
  }

  Post copyWith({
    int? noOfComment,
    int? good,
    bool? liked,
    bool? bookmarked,
    bool? reported,
    bool? blocked,
    String? youtubeUrl,
    String? text7,
    int? adEndTime,
  }) {
    return Post(
      idx: idx,
      idxMember: idxMember,
      idxRoot: idxRoot,
      idxParent: idxParent,
      postId: postId,
      subject: subject,
      content: content,
      stamp: stamp,
      stampUpdate: stampUpdate,
      depth: depth,
      noOfComment: noOfComment ?? this.noOfComment,
      noOfView: noOfView,
      good: good ?? this.good,
      category: category,
      earnedPoint: earnedPoint,
      secret: secret,
      checked: checked,
      blind: blind,
      hasImage: hasImage,
      hasVideo: hasVideo,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      thumbnail400x400: thumbnail400x400,
      thumbnail800x800: thumbnail800x800,
      thumbnail600: thumbnail600,
      thumbnail1000: thumbnail1000,
      resolvedThumbnail: resolvedThumbnail,
      userName: userName,
      userNickname: userNickname,
      userFirebaseUid: userFirebaseUid,
      userPhotoUrl: userPhotoUrl,
      files: files,
      contentType: contentType,
      isMarkdown: isMarkdown,
      isHtml: isHtml,
      isText: isText,
      hasYoutube: hasYoutube,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      deleted: deleted,
      report: report,
      reminder: reminder,
      bad: bad,
      stampLastComment: stampLastComment,
      listOrder: listOrder,
      userId: userId,
      userEmail: userEmail,
      subCategory: subCategory,
      groupId: groupId,
      gid: gid,
      link: link,
      region: region,
      ip: ip,
      noOfAttach: noOfAttach,
      varchar4: varchar4,
      varchar5: varchar5,
      varchar6: varchar6,
      varchar7: varchar7,
      varchar8: varchar8,
      varchar9: varchar9,
      int1: int1,
      text1: text1,
      varchar13: varchar13,
      varchar14: varchar14,
      varchar15: varchar15,
      varchar16: varchar16,
      varchar20: varchar20,
      text2: text2,
      text3: text3,
      text7: text7 ?? this.text7,
      adEndTime: adEndTime ?? this.adEndTime,
      adStartTime: adStartTime,
      adDays: adDays,
      adPoints: adPoints,
      liked: liked ?? this.liked,
      bookmarked: bookmarked ?? this.bookmarked,
      reported: reported ?? this.reported,
      blocked: blocked ?? this.blocked,
    );
  }

  /// nullable String을 절대 URL로 변환 (null/빈 문자열이면 null 반환)
  static String? _toAbsoluteUrlOrNull(String? value) {
    if (value == null || value.isEmpty) return null;
    return toAbsoluteUrl(value);
  }

  /// 안전한 int 변환
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
