/// 포인트 광고 모델
/// Point Advertisement Model
///
/// 게시판 상단에 표시되는 포인트 광고 게시글을 나타냅니다.
/// int_5 > 현재시간 인 게시글만 point_advertisements에 포함됩니다.
///
/// ### 핵심 필드
/// - [adEndTime] (int_5): 광고 종료 시간 (Unix timestamp) - 핵심 필드
/// - [files]: 첨부 이미지 URL 목록
/// - [link]: 클릭 시 이동할 외부 URL (선택)
///
/// ### 사용법 (Usage)
/// ```dart
/// // API 응답에서 파싱
/// final ad = PointAdvertisement.fromJson(json);
///
/// // 남은 광고 일수 확인
/// print('D-${ad.remainingDays}');
///
/// // 클릭 URL 가져오기 (link 또는 viewUrl)
/// final url = ad.clickUrl;
/// ```
class PointAdvertisement {
  // ========================================
  // 필수 필드 (Required fields)
  // ========================================

  /// 게시글 고유 번호
  final int idx;

  /// 작성자 회원 번호 (idx_member)
  final int idxMember;

  /// 게시판 ID (post_id)
  final String postId;

  /// 게시글 제목
  final String subject;

  /// 광고 종료 시간 (int_5, Unix timestamp) - 핵심 필드
  /// 이 값이 현재 시간보다 크면 광고가 활성 상태입니다.
  final int adEndTime;

  /// 첨부 파일 URL 목록
  final List<String> files;

  /// 조회수 (no_of_view)
  final int noOfView;

  /// 게시글 작성 시간 (Unix timestamp)
  final int stamp;

  /// 콘텐츠 타입 (content_type: text/html)
  final String contentType;

  /// 작성 시간 (time_string: 포맷된 문자열)
  final String timeString;

  // ========================================
  // 선택 필드 (Optional fields)
  // ========================================

  /// 서브 카테고리 (선택)
  final String? category;

  /// 광고 시작 시간 (int_6, Unix timestamp)
  final int? adStartTime;

  /// 광고 기간 일수 (int_7)
  final int? adDays;

  /// 사용 포인트 (int_8)
  final int? adPoints;

  /// 클릭 URL (외부 URL로 이동 시 사용)
  /// 값이 있으면 광고 클릭 시 이 URL로 이동합니다.
  final String? link;

  // ========================================
  // 생성자 (Constructor)
  // ========================================
  const PointAdvertisement({
    required this.idx,
    required this.idxMember,
    required this.postId,
    required this.subject,
    required this.adEndTime,
    required this.files,
    required this.noOfView,
    required this.stamp,
    required this.contentType,
    required this.timeString,
    this.category,
    this.adStartTime,
    this.adDays,
    this.adPoints,
    this.link,
  });

  // ========================================
  // JSON 직렬화 (Serialization)
  // ========================================

  /// JSON에서 PointAdvertisement 객체 생성
  /// Create PointAdvertisement from JSON
  factory PointAdvertisement.fromJson(Map<String, dynamic> json) {
    return PointAdvertisement(
      idx: json['idx'] as int,
      idxMember: json['idx_member'] as int? ?? 0,
      postId: json['post_id'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      adEndTime: json['int_5'] as int? ?? 0,
      files: json['files'] == null
          ? []
          : (json['files'] as List<dynamic>).cast<String>(),
      noOfView: json['no_of_view'] as int? ?? 0,
      stamp: json['stamp'] as int? ?? 0,
      contentType: json['content_type'] as String? ?? 'text',
      timeString: json['time_string'] as String? ?? '',
      category: json['category'] as String?,
      adStartTime: json['int_6'] as int?,
      adDays: json['int_7'] as int?,
      adPoints: json['int_8'] as int?,
      link: json['link'] as String?,
    );
  }

  /// PointAdvertisement 객체를 JSON으로 변환
  /// Convert PointAdvertisement to JSON
  Map<String, dynamic> toJson() {
    return {
      'idx': idx,
      'idx_member': idxMember,
      'post_id': postId,
      'subject': subject,
      'int_5': adEndTime,
      'files': files,
      'no_of_view': noOfView,
      'stamp': stamp,
      'content_type': contentType,
      'time_string': timeString,
      if (category != null) 'category': category,
      if (adStartTime != null) 'int_6': adStartTime,
      if (adDays != null) 'int_7': adDays,
      if (adPoints != null) 'int_8': adPoints,
      if (link != null) 'link': link,
    };
  }

  // ========================================
  // 계산 속성 (Computed properties)
  // ========================================

  /// 광고 진행 여부 (현재 시간보다 종료 시간이 미래인지 확인)
  /// Returns true if ad is still active
  bool get isActive =>
      adEndTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 남은 광고 일수 계산
  /// Calculate remaining ad days
  int get remainingDays {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (adEndTime <= now) return 0;
    return ((adEndTime - now) / 86400).ceil();
  }

  /// 첫 번째 이미지 URL (썸네일용)
  /// First image URL for thumbnail
  String? get firstImageUrl => files.isNotEmpty ? files.first : null;

  /// 게시글 보기 URL 생성
  /// Generate post view URL
  String get viewUrl => 'https://philgo.com/post/view.php?idx=$idx';

  /// 클릭 시 이동할 URL (link가 있으면 link, 없으면 viewUrl)
  /// URL to navigate on click
  String get clickUrl => (link != null && link!.isNotEmpty) ? link! : viewUrl;

  @override
  String toString() =>
      'PointAdvertisement(idx: $idx, subject: $subject, D-$remainingDays)';
}
