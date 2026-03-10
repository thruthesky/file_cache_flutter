import 'package:philgo/api/api.service.dart';

import 'post.model.dart';

/// v7 Post API 서비스
///
/// 게시글 관련 모든 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final result = await PostService.list(postId: 'freetalk');
/// final post = await PostService.get(123);
/// ```
class PostService {
  PostService._();

  /// 게시글 목록 조회
  ///
  /// API: post.list (인증 불필요)
  ///
  /// [postId] 게시판 ID (필수, 예: 'freetalk', 'qna')
  /// [category] 카테고리 필터 (선택)
  /// [orderby] 정렬 기준 (선택, 예: 'stamp DESC', 'no_of_view DESC')
  /// [limit] 최대 조회 수 (선택, 기본 20, 최대 100)
  /// [offset] 오프셋 (선택, 기본 0)
  ///
  /// 반환: posts 목록과 total 전체 개수
  static Future<({List<Post> posts, int total})> list({
    required String postId,
    String? category,
    String? orderby,
    int? limit,
    int? offset,
  }) async {
    final result = await ApiService.v7api('post.list', data: {
      'post_id': postId,
      if (category != null) 'category': category,
      if (orderby != null) 'orderby': orderby,
      if (limit != null) 'limit': limit,
      if (offset != null) 'offset': offset,
    });

    final items = (result['posts'] as List<dynamic>?) ?? [];
    final posts = items
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
    final total = ApiService.toInt(result['total']);

    return (posts: posts, total: total);
  }

  /// 게시글 단건 조회
  ///
  /// API: post.get (인증 불필요)
  ///
  /// [idx] 게시글 고유번호
  /// 반환: Post 객체
  static Future<Post> get(int idx) async {
    final result = await ApiService.v7api('post.get', data: {'idx': idx});
    return Post.fromJson(result);
  }

  /// 게시글 생성
  ///
  /// API: post.create (인증 필수)
  ///
  /// [postId] 게시판 ID
  /// [subject] 제목
  /// [content] 내용
  /// [category] 카테고리 (선택)
  /// 반환: 생성된 Post 객체
  static Future<Post> create({
    required String postId,
    required String subject,
    required String content,
    String? category,
  }) async {
    final result = await ApiService.v7api('post.create', data: {
      'post_id': postId,
      'subject': subject,
      'content': content,
      if (category != null) 'category': category,
    });
    return Post.fromJson(result);
  }

  /// 게시글 수정
  ///
  /// API: post.update (인증 필수, 작성자 또는 관리자)
  ///
  /// [idx] 게시글 고유번호
  /// [subject] 제목 (선택)
  /// [content] 내용 (선택)
  /// 반환: 수정된 Post 객체
  static Future<Post> update({
    required int idx,
    String? subject,
    String? content,
  }) async {
    final result = await ApiService.v7api('post.update', data: {
      'idx': idx,
      if (subject != null) 'subject': subject,
      if (content != null) 'content': content,
    });
    return Post.fromJson(result);
  }

  /// 게시글 삭제
  ///
  /// API: post.delete (인증 필수, 작성자 또는 관리자)
  /// 댓글이 있는 게시글은 삭제 불가
  ///
  /// [idx] 게시글 고유번호
  static Future<void> delete(int idx) async {
    await ApiService.v7api('post.delete', data: {'idx': idx});
  }

}
