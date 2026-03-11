import 'package:philgo/api/api.service.dart';
import 'package:philgo/app.config.dart';

import 'post.model.dart';

// ---------------------------------------------------------------------------
// 미디어 타입 판별 유틸리티 (display_thumbnail.dart 와 post view 에서 공유)
// ---------------------------------------------------------------------------

enum MediaType { image, video, youtube, unknown }

MediaType getMediaType(String? url) {
  if (url == null || url.isEmpty) return MediaType.unknown;
  final lower = url.toLowerCase();

  if (lower.contains('youtube.com') || lower.contains('youtu.be')) {
    return MediaType.youtube;
  }

  final path = Uri.tryParse(url)?.path.toLowerCase() ?? lower;

  if (path.endsWith('.mp4') ||
      path.endsWith('.mov') ||
      path.endsWith('.avi') ||
      path.endsWith('.mkv') ||
      path.endsWith('.webm')) {
    return MediaType.video;
  }

  if (path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.png') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp') ||
      path.endsWith('.bmp') ||
      path.endsWith('.svg') ||
      path.endsWith('.avif')) {
    return MediaType.image;
  }

  return MediaType.unknown;
}

/// YouTube URL 에서 비디오 ID 추출
String? getYouTubeVideoId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) return uri.pathSegments.firstOrNull;
  return uri.queryParameters['v'];
}

/// 상대 URL → 절대 URL 변환
String toAbsoluteUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return '$v7BaseUrl$url';
}

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
    final result = await ApiService.v7api(
      'post.list',
      data: {
        'post_id': postId,
        if (category != null) 'category': category,
        if (orderby != null) 'orderby': orderby,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      },
    );

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
    final result = await ApiService.v7api(
      'post.get',
      data: {'idx': idx},
      debug: true,
    );
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
    final result = await ApiService.v7api(
      'post.create',
      data: {
        'post_id': postId,
        'subject': subject,
        'content': content,
        if (category != null) 'category': category,
      },
    );
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
    final result = await ApiService.v7api(
      'post.update',
      data: {
        'idx': idx,
        if (subject != null) 'subject': subject,
        if (content != null) 'content': content,
      },
    );
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

  /// 게시글 좋아요 토글
  ///
  /// API: post.like (인증 필수)
  ///
  /// [idx] 게시글 고유번호
  /// 반환: 업데이트된 good(좋아요 수)와 liked(내가 좋아요 했는지 여부)
  static Future<({int good, bool liked})> like(int idx) async {
    final result = await ApiService.v7api('post.like', data: {'idx': idx});
    final good = ApiService.toInt(result['good']);
    final liked = result['liked'] == true || result['liked'] == 1;
    return (good: good, liked: liked);
  }

  /// 댓글 목록 조회
  ///
  /// API: post.commentList (인증 불필요)
  ///
  /// [idxRoot] 원글 idx
  /// 반환: 댓글 Post 목록 (list_order DESC)
  static Future<List<Post>> listComments(int idxRoot) async {
    final result = await ApiService.v7api(
      'post.commentList',
      data: {'idx_root': idxRoot},
    );
    final raw = result['items'] ?? [];
    final items = raw is List ? raw : [];
    return items.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  /// 댓글 생성
  ///
  /// API: post.commentCreate (인증 필수)
  ///
  /// [idxRoot] 원글 idx
  /// [content] 댓글 내용
  /// [idxParent] 부모 댓글 idx (대댓글 시, 기본값: idxRoot)
  /// 반환: 생성된 댓글 Post 객체
  static Future<Post> createComment({
    required int idxRoot,
    required String content,
    int? idxParent,
  }) async {
    final result = await ApiService.v7api(
      'post.commentCreate',
      data: {
        'idx_root': idxRoot,
        'content': content,
        if (idxParent != null) 'idx_parent': idxParent,
      },
    );
    return Post.fromJson(result);
  }

  /// 댓글 수정
  ///
  /// API: post.commentUpdate (인증 필수, 작성자 또는 관리자)
  /// 자식 댓글이 있으면 수정 불가
  ///
  /// [idx] 댓글 idx
  /// [content] 수정할 내용
  /// 반환: 수정된 댓글 Post 객체
  static Future<Post> updateComment({
    required int idx,
    required String content,
  }) async {
    final result = await ApiService.v7api(
      'post.commentUpdate',
      data: {
        'idx': idx,
        'content': content,
      },
    );
    return Post.fromJson(result);
  }

  /// 댓글 삭제
  ///
  /// API: post.commentDelete (인증 필수, 작성자 또는 관리자)
  /// 자식 댓글이 있으면 삭제 불가
  ///
  /// [idx] 댓글 idx
  static Future<void> deleteComment(int idx) async {
    await ApiService.v7api('post.commentDelete', data: {'idx': idx});
  }
}
