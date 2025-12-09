import 'package:philgo_api/philgo_v6_flutter.dart';

class PostList {
  int page = 1; // 현재 페이지 번호
  int post_count = 0;
  String duration = ""; // API 응답 시간
  List<Post> posts = []; // 게시글 목록
  Map<String, dynamic> config = {}; // 메타 정보

  PostList.fromJson(Map<String, dynamic> json) {
    page = json['page'] as int;
    if (json['posts'] != null) {
      posts = (json['posts'] as List<dynamic>)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    duration = json['duration'] as String? ?? '';
    post_count = json['post_count'] as int? ?? 0;
    config = Map<String, dynamic>.from((json['config'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'post_count': post_count,
      'duration': duration,
      'posts': posts.map((e) => e.toJson()).toList(),
      'config': config,
    };
  }

  @override
  String toString() {
    return 'PostList{page: $page, post_count: $post_count, duration: $duration, posts: $posts, config: $config}';
  }
}
