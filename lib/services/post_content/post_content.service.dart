import 'package:flutter/foundation.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 콘텐츠 서비스 (Post Content Service)
///
/// 필고 게시글을 로드하고 캐싱하는 서비스입니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// ### 캐시 관리 (Cache Management):
/// FileCache를 사용하여 게시글 데이터를 캐싱합니다.
/// - TTL: 1시간 (자주 변경되지 않는 정보성 글에 적합)
/// - 메모리 + 파일 이중 캐싱
///
/// ### 사용법 (Usage):
/// ```dart
/// // 게시글 로드
/// final post = await PostContentService.instance.loadPost(1275694642);
///
/// // 캐시 초기화
/// await PostContentService.instance.clearCache();
///
/// // 특정 게시글 캐시만 삭제
/// await PostContentService.instance.clearPostCache(1275694642);
/// ```
class PostContentService {
  /// 싱글톤 인스턴스 (Singleton instance)
  static PostContentService? _instance;

  /// 싱글톤 인스턴스 접근자 (Singleton instance accessor)
  static PostContentService get instance =>
      _instance ??= PostContentService._();

  /// 비공개 생성자 (Private constructor)
  PostContentService._();

  /// 캐시 TTL (1시간) (Cache TTL - 1 hour)
  ///
  /// 정보성 글은 자주 변경되지 않으므로 1시간 캐시가 적절합니다.
  static const Duration cacheTtl = Duration(hours: 1);

  /// 게시글 데이터 전용 캐시 (File cache for post data)
  ///
  /// FileCache를 사용하여 게시글 데이터를 캐싱합니다.
  /// - cacheName: 캐시 디렉토리명
  /// - defaultTtl: 1시간
  /// - fromJson/toJson: 직렬화 함수
  late final FileCache<Post> _cache = FileCache<Post>(
    cacheName: 'post_content',
    defaultTtl: cacheTtl,
    fromJson: Post.fromJson,
    toJson: (post) => post.toJson(),
    useMemoryCache: true,
  );

  /// 게시글 로드 (Load post)
  ///
  /// 1. 캐시에서 먼저 로드 시도
  /// 2. 캐시가 없거나 만료되면 API 호출
  /// 3. 새 데이터를 캐시에 저장
  ///
  /// [postId] 게시글 번호 (idx)
  /// [forceRefresh] true이면 캐시 무시하고 API에서 새로 로드
  ///
  /// Returns [Post] 게시글 데이터
  /// Throws [Exception] API 호출 실패 시
  Future<Post> loadPost(int postId, {bool forceRefresh = false}) async {
    final cacheKey = 'post_$postId';

    /// forceRefresh가 아니면 캐시에서 먼저 로드 시도
    if (!forceRefresh) {
      final cachedPost = await _cache.get(cacheKey);
      if (cachedPost != null) {
        debugPrint('PostContentService: 캐시에서 게시글 로드 완료 (idx: $postId)');
        return cachedPost;
      }
    }

    /// 캐시가 없거나 만료되었거나 forceRefresh이면 API 호출
    debugPrint('PostContentService: API에서 게시글 로드 중... (idx: $postId)');
    final post = await getPost(postId);

    /// 캐시에 저장
    await _cache.set(cacheKey, post);
    debugPrint('PostContentService: 게시글 캐시 저장 완료 (idx: $postId)');

    return post;
  }

  /// 특정 게시글 캐시 삭제 (Clear specific post cache)
  ///
  /// [postId] 삭제할 게시글 번호
  Future<void> clearPostCache(int postId) async {
    final cacheKey = 'post_$postId';
    await _cache.remove(cacheKey);
    debugPrint('PostContentService: 게시글 캐시 삭제 완료 (idx: $postId)');
  }

  /// 전체 캐시 초기화 (Clear all cache)
  ///
  /// 테스트 또는 강제 새로고침 시 사용
  Future<void> clearCache() async {
    await _cache.clear();
    debugPrint('PostContentService: 전체 캐시 삭제 완료');
  }

  /// 특정 게시글의 캐시 남은 시간 조회 (Get remaining cache time for specific post)
  ///
  /// [postId] 게시글 번호
  /// 캐시가 없으면 null 반환
  Duration? getCacheRemainingTime(int postId) {
    final cacheKey = 'post_$postId';
    return _cache.getRemainingTime(cacheKey);
  }
}
