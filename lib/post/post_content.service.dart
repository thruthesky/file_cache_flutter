import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:philgo/api/api.service.dart';
import 'package:philgo/info/info_post.model.dart';
import 'package:philgo/post/post.model.dart';

/// 게시글 콘텐츠 서비스 (Post Content Service)
///
/// 게시글과 Info 콘텐츠를 로드하고 캐싱하는 서비스.
/// 메모리 + 파일 이중 캐싱으로 네트워크 호출을 최소화한다.
///
/// - TTL: 48시간 (정보성 글은 자주 변경되지 않음)
/// - 메모리 캐시: 앱 실행 중 빠른 접근
/// - 파일 캐시: 앱 재시작 후에도 데이터 유지
///
/// 사용법:
/// ```dart
/// // 게시글 로드 (캐시 우선)
/// final post = await PostContentService.instance.loadPost(1275694642);
///
/// // Info 콘텐츠 로드 (캐시 우선)
/// final info = await PostContentService.instance.loadInfo('info:contact:embassy');
///
/// // 캐시 무시하고 새로 로드
/// final fresh = await PostContentService.instance.loadPost(123, forceRefresh: true);
/// ```
class PostContentService {
  static PostContentService? _instance;
  static PostContentService get instance => _instance ??= PostContentService._();
  PostContentService._();

  /// 캐시 TTL (48시간)
  static const Duration cacheTtl = Duration(hours: 48);

  /// 캐시 디렉토리명
  static const String _cacheDirName = 'post_content_cache';

  // ═══════════════════════════════════════════════
  // 메모리 캐시
  // ═══════════════════════════════════════════════

  /// Post 메모리 캐시 (key: 'post_{idx}')
  final Map<String, _CacheEntry<Post>> _postCache = {};

  /// InfoPost 메모리 캐시 (key: 'info_{accessCode}')
  final Map<String, _CacheEntry<InfoPost>> _infoCache = {};

  // ═══════════════════════════════════════════════
  // Post 로드 (by idx)
  // ═══════════════════════════════════════════════

  /// 게시글 로드 (캐시 우선)
  ///
  /// 1. 메모리 캐시 확인
  /// 2. 파일 캐시 확인
  /// 3. API 호출 (`post.get`)
  ///
  /// [idx] 게시글 고유번호
  /// [forceRefresh] true이면 캐시 무시
  Future<Post> loadPost(int idx, {bool forceRefresh = false}) async {
    final key = 'post_$idx';

    if (!forceRefresh) {
      // 메모리 캐시 확인
      final memEntry = _postCache[key];
      if (memEntry != null && memEntry.isValid) {
        debugPrint('PostContentService: 메모리 캐시에서 로드 (idx: $idx)');
        return memEntry.data;
      }

      // 파일 캐시 확인
      final fileData = await _loadFromFileCache(key);
      if (fileData != null) {
        final post = Post.fromJson(fileData);
        _postCache[key] = _CacheEntry(post, DateTime.now());
        debugPrint('PostContentService: 파일 캐시에서 로드 (idx: $idx)');
        return post;
      }
    }

    // API 호출
    debugPrint('PostContentService: API에서 로드 중... (idx: $idx)');
    final result = await ApiService.instance.v7api(
      'post.get',
      data: {'idx': idx},
    );
    final post = Post.fromJson(result);

    // 캐시 저장
    _postCache[key] = _CacheEntry(post, DateTime.now());
    await _saveToFileCache(key, result);
    debugPrint('PostContentService: 캐시 저장 완료 (idx: $idx)');

    return post;
  }

  // ═══════════════════════════════════════════════
  // InfoPost 로드 (by access_code)
  // ═══════════════════════════════════════════════

  /// Info 콘텐츠 로드 (캐시 우선)
  ///
  /// 1. 메모리 캐시 확인
  /// 2. 파일 캐시 확인
  /// 3. API 호출 (`info.getByAccessCode`)
  ///
  /// [accessCode] Info 접근 코드 (예: 'info:contact:embassy')
  /// [forceRefresh] true이면 캐시 무시
  Future<InfoPost> loadInfo(String accessCode, {bool forceRefresh = false}) async {
    final key = 'info_${accessCode.replaceAll(':', '_')}';

    if (!forceRefresh) {
      // 메모리 캐시 확인
      final memEntry = _infoCache[key];
      if (memEntry != null && memEntry.isValid) {
        debugPrint('PostContentService: 메모리 캐시에서 Info 로드 ($accessCode)');
        return memEntry.data;
      }

      // 파일 캐시 확인
      final fileData = await _loadFromFileCache(key);
      if (fileData != null) {
        final info = InfoPost.fromJson(fileData);
        _infoCache[key] = _CacheEntry(info, DateTime.now());
        debugPrint('PostContentService: 파일 캐시에서 Info 로드 ($accessCode)');
        return info;
      }
    }

    // API 호출
    debugPrint('PostContentService: API에서 Info 로드 중... ($accessCode)');
    final result = await ApiService.instance.v7api<Map<String, dynamic>>(
      'info.getByAccessCode',
      data: {'access_code': accessCode},
    );
    final info = InfoPost.fromJson(result);

    // 캐시 저장
    _infoCache[key] = _CacheEntry(info, DateTime.now());
    await _saveToFileCache(key, result);
    debugPrint('PostContentService: Info 캐시 저장 완료 ($accessCode)');

    return info;
  }

  // ═══════════════════════════════════════════════
  // 캐시 관리
  // ═══════════════════════════════════════════════

  /// 특정 게시글 캐시 삭제
  Future<void> clearPostCache(int idx) async {
    final key = 'post_$idx';
    _postCache.remove(key);
    await _deleteFileCache(key);
    debugPrint('PostContentService: 캐시 삭제 완료 (idx: $idx)');
  }

  /// 특정 Info 캐시 삭제
  Future<void> clearInfoCache(String accessCode) async {
    final key = 'info_${accessCode.replaceAll(':', '_')}';
    _infoCache.remove(key);
    await _deleteFileCache(key);
    debugPrint('PostContentService: Info 캐시 삭제 완료 ($accessCode)');
  }

  /// 전체 캐시 초기화
  Future<void> clearAll() async {
    _postCache.clear();
    _infoCache.clear();
    final dir = await _cacheDir;
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    debugPrint('PostContentService: 전체 캐시 삭제 완료');
  }

  // ═══════════════════════════════════════════════
  // 파일 캐시 내부 메서드
  // ═══════════════════════════════════════════════

  Future<Directory> get _cacheDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_cacheDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Map<String, dynamic>?> _loadFromFileCache(String key) async {
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      if (!await file.exists()) return null;

      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // TTL 확인
      final cachedAtStr = json['cachedAt'] as String?;
      if (cachedAtStr == null) return null;

      final cachedAt = DateTime.parse(cachedAtStr);
      if (DateTime.now().difference(cachedAt) > cacheTtl) {
        // 만료된 캐시 삭제
        await file.delete();
        return null;
      }

      return json['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToFileCache(String key, Map<String, dynamic> data) async {
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      final json = {
        'cachedAt': DateTime.now().toIso8601String(),
        'data': data,
      };
      await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // 파일 캐시 저장 실패는 무시
    }
  }

  Future<void> _deleteFileCache(String key) async {
    try {
      final dir = await _cacheDir;
      final file = File('${dir.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // 파일 삭제 실패는 무시
    }
  }
}

/// 캐시 엔트리 (메모리 캐시용)
class _CacheEntry<T> {
  final T data;
  final DateTime cachedAt;

  _CacheEntry(this.data, this.cachedAt);

  bool get isValid =>
      DateTime.now().difference(cachedAt) <= PostContentService.cacheTtl;
}
