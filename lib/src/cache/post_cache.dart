import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Post Cache Utility (게시글 캐시 유틸리티)
///
/// This utility provides file-based caching for the first page of posts.
/// It enables "cache-first" pattern: show cached data immediately,
/// then fetch from server and update both display and cache.
///
/// 이 유틸리티는 게시글 첫 페이지를 파일 기반으로 캐시합니다.
/// "캐시 우선" 패턴을 지원합니다: 캐시된 데이터를 먼저 표시하고,
/// 서버에서 데이터를 가져온 후 화면과 캐시를 모두 업데이트합니다.

/// Generate cache key from postId and category
/// postId와 category로 캐시 키 생성
///
/// Example keys:
/// - posts_freetalk_all.json (freetalk category, no subcategory)
/// - posts_freetalk_discussion.json (freetalk with discussion subcategory)
String _getCacheKey(String? postId, String? category) {
  final safePostId = postId ?? 'all';
  final safeCategory = category ?? 'all';
  return 'posts_${safePostId}_$safeCategory.json';
}

/// Get cache directory path
/// 캐시 디렉토리 경로 반환
Future<Directory> _getCacheDirectory() async {
  final tempDir = await getTemporaryDirectory();
  final cacheDir = Directory('${tempDir.path}/philgo_post_cache');

  // Create cache directory if not exists
  // 캐시 디렉토리가 없으면 생성
  if (!await cacheDir.exists()) {
    await cacheDir.create(recursive: true);
  }

  return cacheDir;
}

/// Get cache file for given postId and category
/// postId와 category에 해당하는 캐시 파일 반환
Future<File> _getCacheFile(String? postId, String? category) async {
  final cacheDir = await _getCacheDirectory();
  final cacheKey = _getCacheKey(postId, category);
  return File('${cacheDir.path}/$cacheKey');
}

/// Load first page posts from cache
/// 캐시에서 첫 페이지 게시글 로드
///
/// Returns null if cache doesn't exist or is invalid.
/// 캐시가 없거나 유효하지 않으면 null 반환
Future<PostList?> getPostsFromCache(String? postId, String? category) async {
  try {
    final cacheFile = await _getCacheFile(postId, category);

    // Check if cache file exists
    // 캐시 파일 존재 여부 확인
    if (!await cacheFile.exists()) {
      return null;
    }

    // Read and parse cache file
    // 캐시 파일 읽기 및 파싱
    final jsonString = await cacheFile.readAsString();
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    return PostList.fromJson(jsonData);
  } catch (e) {
    // If any error occurs, return null (cache miss)
    // 오류 발생 시 null 반환 (캐시 미스)
    return null;
  }
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
  try {
    final cacheFile = await _getCacheFile(postId, category);

    // Convert PostList to JSON and save
    // PostList를 JSON으로 변환하여 저장
    final jsonString = jsonEncode(data.toJson());
    await cacheFile.writeAsString(jsonString);
  } catch (e) {
    // Silently fail - cache is optional
    // 조용히 실패 처리 - 캐시는 선택적 기능
  }
}

/// Clear all post caches
/// 모든 게시글 캐시 삭제
///
/// Call this when user logs out or when cache needs to be invalidated.
/// 사용자 로그아웃 시 또는 캐시 무효화가 필요할 때 호출합니다.
Future<void> clearPostCache() async {
  try {
    final cacheDir = await _getCacheDirectory();
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  } catch (e) {
    // Silently fail
    // 조용히 실패 처리
  }
}

/// Clear cache for specific postId and category
/// 특정 postId와 category의 캐시만 삭제
Future<void> clearPostCacheFor(String? postId, String? category) async {
  try {
    final cacheFile = await _getCacheFile(postId, category);
    if (await cacheFile.exists()) {
      await cacheFile.delete();
    }
  } catch (e) {
    // Silently fail
    // 조용히 실패 처리
  }
}
