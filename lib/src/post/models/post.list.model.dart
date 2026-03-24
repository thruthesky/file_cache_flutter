import 'package:philgo_api/philgo_api.dart';

class PostList {
  int page = 1; // 현재 페이지 번호
  int post_count = 0;
  String duration = ""; // API 응답 시간
  List<Post> posts = []; // 게시글 목록
  Map<String, dynamic> config = {}; // 메타 정보

  /// 포인트 광고 목록
  /// Point advertisement list
  ///
  /// post_list API 응답의 point_advertisements 필드에서 파싱됩니다.
  /// 1페이지에서만 반환되며, 광고 종료 시간(int_5) 기준으로 정렬됩니다.
  List<PointAdvertisement> pointAdvertisements = [];

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

    /// 포인트 광고 파싱
    /// Parse point advertisements from API response
    if (json['point_advertisements'] != null) {
      pointAdvertisements = (json['point_advertisements'] as List<dynamic>)
          .map((e) => PointAdvertisement.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'post_count': post_count,
      'duration': duration,
      'posts': posts.map((e) => e.toJson()).toList(),
      'config': config,

      /// 포인트 광고 직렬화
      'point_advertisements':
          pointAdvertisements.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'PostList{page: $page, post_count: $post_count, duration: $duration, posts: $posts, config: $config, pointAds: ${pointAdvertisements.length}}';
  }
}
