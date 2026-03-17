import 'package:philgo/api/api.service.dart';
import 'post.model.dart';

/// 게시글 목록 조회 결과 모델
class PostListResult {
  final List<Post> posts;
  final int total;
  final int page;
  final int limit;

  PostListResult({
    required this.posts,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PostListResult.fromJson(Map<String, dynamic> json) {
    final items = (json['posts'] as List<dynamic>?) ?? [];
    final posts = items
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();

    return PostListResult(
      posts: posts,
      total: ApiService.toInt(json['total']),
      page: ApiService.toInt(json['page']),
      limit: ApiService.toInt(json['limit']),
    );
  }
}
