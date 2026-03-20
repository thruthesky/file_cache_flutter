import 'package:philgo/api/api.service.dart';
import 'package:philgo/point/point_advertisement.model.dart';
import 'post.model.dart';

/// 게시글 목록 조회 결과 모델
class PostListResult {
  final List<Post> posts;
  final int total;
  final int page;
  final int limit;

  /// 포인트 광고 목록 (1페이지에서만 반환)
  final List<PointAdvertisement> pointAdvertisements;

  PostListResult({
    required this.posts,
    required this.total,
    required this.page,
    required this.limit,
    this.pointAdvertisements = const [],
  });

  factory PostListResult.fromJson(Map<String, dynamic> json) {
    final items = (json['posts'] as List<dynamic>?) ?? [];
    final posts = items
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();

    final adItems = (json['point_advertisements'] as List<dynamic>?) ?? [];
    final ads = adItems
        .whereType<Map<String, dynamic>>()
        .map(PointAdvertisement.fromJson)
        .toList();

    return PostListResult(
      posts: posts,
      total: ApiService.toInt(json['total']),
      page: ApiService.toInt(json['page']),
      limit: ApiService.toInt(json['limit']),
      pointAdvertisements: ads,
    );
  }
}
