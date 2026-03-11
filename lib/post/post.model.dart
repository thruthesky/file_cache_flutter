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
  final String files;

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
    this.files = '',
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
      files: json['files']?.toString() ?? '',
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
