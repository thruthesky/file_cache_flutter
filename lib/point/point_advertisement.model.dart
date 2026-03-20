import 'package:philgo/api/api.service.dart';

/// 포인트 광고 모델
///
/// 게시판 상단에 표시되는 포인트 광고 게시글.
/// int_5 > 현재시간 인 게시글만 API에서 반환된다.
class PointAdvertisement {
  final int idx;
  final int idxMember;
  final String postId;
  final String subject;

  /// 광고 종료 시간 (int_5, Unix timestamp) - 핵심 필드
  final int adEndTime;

  final String resolvedThumbnail;
  final int noOfView;
  final int noOfComment;
  final int stamp;
  final String link;
  final String category;

  const PointAdvertisement({
    required this.idx,
    required this.idxMember,
    required this.postId,
    required this.subject,
    required this.adEndTime,
    required this.resolvedThumbnail,
    required this.noOfView,
    required this.noOfComment,
    required this.stamp,
    this.link = '',
    this.category = '',
  });

  factory PointAdvertisement.fromJson(Map<String, dynamic> json) {
    return PointAdvertisement(
      idx: ApiService.toInt(json['idx']),
      idxMember: ApiService.toInt(json['idx_member']),
      postId: json['post_id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      adEndTime: ApiService.toInt(json['int_5']),
      resolvedThumbnail: json['resolved_thumbnail']?.toString() ?? '',
      noOfView: ApiService.toInt(json['no_of_view']),
      noOfComment: ApiService.toInt(json['no_of_comment']),
      stamp: ApiService.toInt(json['stamp']),
      link: json['link']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
    );
  }

  /// 광고 활성 여부
  bool get isActive =>
      adEndTime > DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 남은 광고 일수
  int get remainingDays {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (adEndTime <= now) return 0;
    return ((adEndTime - now) / 86400).ceil();
  }

  /// 클릭 시 이동 URL (link가 있으면 link, 없으면 글 보기)
  String get clickUrl =>
      link.isNotEmpty ? link : 'https://philgo.com/post/view.php?idx=$idx';
}
