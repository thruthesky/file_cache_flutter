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
  final String? thumbnail1000;
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
    this.thumbnail1000,
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
      imageUrl: json['varchar_17']?.toString(),
      videoUrl: json['varchar_18']?.toString(),
      thumbnail400x400: json['varchar_10']?.toString(),
      thumbnail800x800: json['varchar_11']?.toString(),
      thumbnail1000: json['varchar_12']?.toString(),
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
    );
  }

  Post copyWith({int? noOfComment, int? good}) {
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
      thumbnail1000: thumbnail1000,
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
    );
  }

  /// 안전한 int 변환
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
