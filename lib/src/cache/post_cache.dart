import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// Post Cache Utility (게시글 캐시 유틸리티)
///
/// This utility provides file-based caching for the first page of posts.
/// It enables "cache-first" pattern: show cached data immediately,
/// then fetch from server and update both display and cache.
///
/// 이 유틸리티는 게시글 첫 페이지를 파일 기반으로 캐시합니다.
/// "캐시 우선" 패턴을 지원합니다: 캐시된 데이터를 먼저 표시하고,
/// 서버에서 데이터를 가져온 후 화면과 캐시를 모두 업데이트합니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// // 캐시에서 게시글 로드
/// final cached = await getPostsFromCache('freetalk', 'discussion');
///
/// // 캐시에 게시글 저장
/// await savePostsToCache('freetalk', 'discussion', postList);
///
/// // 특정 캐시 삭제
/// await clearPostCacheFor('freetalk', 'discussion');
///
/// // 전체 캐시 삭제
/// await clearPostCache();
/// ```

/// FileCache instance for PostList (PostList용 FileCache 인스턴스)
///
/// - cacheName: 'philgo_post_cache' (캐시 디렉토리명)
/// - TTL 없음: 게시글 캐시는 만료 없이 유지 (서버에서 새 데이터 가져오면 덮어씀)
/// - 메모리 캐시 사용: 빠른 접근을 위해 활성화
final _postCache = FileCache<PostList>(
  cacheName: 'philgo_post_cache',
  fromJson: PostList.fromJson,
  toJson: (data) => data.toJson(),
  defaultTtl: Duration(days: 365), // 실질적으로 만료 없음 (서버 데이터로 덮어씀)
  useMemoryCache: true,
  cacheRootName: 'philgo_cache',
);

/// Generate cache key from postId and category
/// postId와 category로 캐시 키 생성
///
/// Example keys:
/// - 'all_all' (no postId, no category)
/// - 'freetalk_all' (freetalk category, no subcategory)
/// - 'freetalk_discussion' (freetalk with discussion subcategory)
String _getCacheKey(String? postId, String? category) {
  final safePostId = postId ?? 'all';
  final safeCategory = category ?? 'all';
  return '${safePostId}_$safeCategory';
}

/// Load first page posts from cache
/// 캐시에서 첫 페이지 게시글 로드
///
/// Returns null if cache doesn't exist or is invalid.
/// 캐시가 없거나 유효하지 않으면 null 반환
Future<PostList?> getPostsFromCache(String? postId, String? category) async {
  final cacheKey = _getCacheKey(postId, category);
  return await _postCache.get(cacheKey);
}

/// Save first page posts to cache
/// 첫 페이지 게시글을 캐시에 저장
///
/// This is called after fetching data from server to update the cache.
/// 서버에서 데이터를 가져온 후 캐시를 업데이트하기 위해 호출됩니다.
Future<void> savePostsToCache(
  String? postId,
  String? category,
  PostList data,
) async {
  final cacheKey = _getCacheKey(postId, category);
  await _postCache.set(cacheKey, data);
}

/// Clear all post caches
/// 모든 게시글 캐시 삭제
///
/// Call this when user logs out or when cache needs to be invalidated.
/// 사용자 로그아웃 시 또는 캐시 무효화가 필요할 때 호출합니다.
Future<void> clearPostCache() async {
  await _postCache.clear();
}

/// Clear cache for specific postId and category
/// 특정 postId와 category의 캐시만 삭제
Future<void> clearPostCacheFor(String? postId, String? category) async {
  final cacheKey = _getCacheKey(postId, category);
  await _postCache.remove(cacheKey);
}

/// Check if cache exists for specific postId and category
/// 특정 postId와 category의 캐시 존재 여부 확인
Future<bool> hasPostCache(String? postId, String? category) async {
  final cacheKey = _getCacheKey(postId, category);
  return await _postCache.has(cacheKey);
}

/// Get memory cache count (for debugging)
/// 메모리 캐시 항목 수 조회 (디버깅용)
int get postCacheCount => _postCache.memoryCacheCount;
