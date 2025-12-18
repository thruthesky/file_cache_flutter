import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'cache_entry.dart';

/// 범용 파일 캐시 서비스 (Generic File Cache Service)
///
/// 제네릭 타입 T를 지원하며, fromJson/toJson 콜백을 통해
/// 모든 데이터 타입을 캐싱할 수 있습니다.
///
/// ### 핵심 특징 (Key Features):
/// - 완전히 독립적: API 호출/fetch 로직 없음
/// - 순수 캐시만: 저장, 조회, 삭제만 담당
/// - 메모리 + 파일 이중 캐싱
/// - TTL (Time-To-Live) 지원
/// - 키-값 기반 저장
///
/// ### 사용 예시 (Usage Example):
/// ```dart
/// // 캐시 인스턴스 생성
/// final cache = FileCache<MyData>(
///   cacheName: 'my_data',
///   defaultTtl: Duration(minutes: 30),
///   fromJson: MyData.fromJson,
///   toJson: (d) => d.toJson(),
/// );
///
/// // 저장
/// await cache.set('key1', myData);
///
/// // 조회 (만료 시 null 반환)
/// final data = await cache.get('key1');
///
/// // 삭제
/// await cache.remove('key1');
///
/// // 전체 삭제
/// await cache.clear();
/// ```
class FileCache<T> {
  /// 캐시 이름 (저장 디렉토리명)
  /// Cache name (used as directory name)
  final String cacheName;

  /// 기본 TTL (Time-To-Live)
  /// Default time-to-live for cached entries
  final Duration defaultTtl;

  /// JSON → T 변환 함수 (JSON to T converter)
  final T Function(Map<String, dynamic> json) fromJson;

  /// T → JSON 변환 함수 (T to JSON converter)
  final Map<String, dynamic> Function(T data) toJson;

  /// 메모리 캐시 사용 여부 (Whether to use memory cache)
  final bool useMemoryCache;

  /// 디버그 로그 출력 여부 (Whether to print debug logs)
  final bool enableLogging;

  /// 캐시 루트 디렉토리 이름 (Cache root directory name)
  /// 기본값: 'file_cache'
  final String cacheRootName;

  /// 메모리 캐시 저장소 (In-memory cache storage)
  final Map<String, CacheEntry<T>> _memoryCache = {};

  /// 생성자 (Constructor)
  ///
  /// [cacheName] 캐시 이름 (디렉토리명으로 사용)
  /// [fromJson] JSON을 T로 변환하는 함수
  /// [toJson] T를 JSON으로 변환하는 함수
  /// [defaultTtl] 기본 TTL (기본값: 30분)
  /// [useMemoryCache] 메모리 캐시 사용 여부 (기본값: true)
  /// [enableLogging] 디버그 로그 출력 여부 (기본값: false)
  /// [cacheRootName] 캐시 루트 디렉토리 이름 (기본값: 'file_cache')
  FileCache({
    required this.cacheName,
    required this.fromJson,
    required this.toJson,
    this.defaultTtl = const Duration(minutes: 30),
    this.useMemoryCache = true,
    this.enableLogging = false,
    this.cacheRootName = 'file_cache',
  });

  /// 디버그 로그 출력 (Print debug log)
  void _log(String message) {
    if (enableLogging) {
      debugPrint('FileCache[$cacheName]: $message');
    }
  }

  /// 캐시 디렉토리 경로 반환 (Get cache directory path)
  ///
  /// 임시 디렉토리 하위에 {cacheRootName}/{cacheName} 디렉토리 생성
  Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/$cacheRootName/$cacheName');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// 캐시 파일 경로 반환 (Get cache file path)
  ///
  /// [key] 캐시 키
  /// 특수문자를 언더스코어로 치환하여 안전한 파일명 생성
  Future<File> _getCacheFile(String key) async {
    final cacheDir = await _getCacheDirectory();
    // 특수문자를 언더스코어로 치환하여 안전한 파일명 생성
    final safeKey = key.replaceAll(RegExp(r'[^\w\-.]'), '_');
    return File('${cacheDir.path}/$safeKey.json');
  }

  /// 캐시에서 데이터 가져오기 (Get data from cache)
  ///
  /// [key] 캐시 키
  ///
  /// 반환값:
  /// - 캐시 히트 시: 저장된 데이터
  /// - 캐시 미스 또는 만료 시: null
  ///
  /// 조회 순서:
  /// 1. 메모리 캐시 확인
  /// 2. 파일 캐시 확인
  /// 3. 만료 체크
  Future<T?> get(String key) async {
    // 1. 메모리 캐시 확인 (Check memory cache first)
    if (useMemoryCache && _memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        _log('메모리 캐시 히트 - $key');
        return entry.data;
      }
      // 만료된 메모리 캐시 제거
      _memoryCache.remove(key);
    }

    // 2. 파일 캐시 확인 (Check file cache)
    try {
      final file = await _getCacheFile(key);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final entry = CacheEntry.fromJson(json, fromJson);

        // 3. 만료 체크 (Check expiry)
        if (!entry.isExpired) {
          // 메모리 캐시에 저장
          if (useMemoryCache) {
            _memoryCache[key] = entry;
          }
          _log('파일 캐시 히트 - $key');
          return entry.data;
        }

        // 만료된 파일 삭제
        _log('캐시 만료, 파일 삭제 - $key');
        await file.delete();
      }
    } catch (e) {
      _log('캐시 로드 실패 - $key, $e');
    }

    return null;
  }

  /// 캐시에 데이터 저장 (Save data to cache)
  ///
  /// [key] 캐시 키
  /// [data] 저장할 데이터
  /// [ttl] 개별 TTL (없으면 defaultTtl 사용)
  Future<void> set(String key, T data, {Duration? ttl}) async {
    final entry = CacheEntry<T>(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
      createdAt: DateTime.now(),
    );

    // 메모리 캐시에 저장 (Save to memory cache)
    if (useMemoryCache) {
      _memoryCache[key] = entry;
    }

    // 파일 캐시에 저장 (Save to file cache)
    try {
      final file = await _getCacheFile(key);
      final json = entry.toJson(toJson);
      await file.writeAsString(jsonEncode(json));
      _log('캐시 저장 완료 - $key');
    } catch (e) {
      _log('캐시 저장 실패 - $key, $e');
    }
  }

  /// 캐시 존재 여부 확인 (Check if cache exists)
  ///
  /// [key] 캐시 키
  /// 만료된 캐시는 없는 것으로 처리
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// 특정 키의 캐시 삭제 (Remove specific cache entry)
  ///
  /// [key] 삭제할 캐시 키
  Future<void> remove(String key) async {
    // 메모리 캐시에서 제거
    _memoryCache.remove(key);

    // 파일 캐시에서 제거
    try {
      final file = await _getCacheFile(key);
      if (await file.exists()) {
        await file.delete();
        _log('캐시 삭제 완료 - $key');
      }
    } catch (e) {
      _log('캐시 삭제 실패 - $key, $e');
    }
  }

  /// 모든 캐시 삭제 (Clear all cache)
  ///
  /// 메모리 캐시와 파일 캐시 모두 삭제
  Future<void> clear() async {
    // 메모리 캐시 삭제
    _memoryCache.clear();

    // 파일 캐시 디렉토리 삭제
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        _log('전체 캐시 삭제 완료');
      }
    } catch (e) {
      _log('전체 캐시 삭제 실패 - $e');
    }
  }

  /// 만료된 캐시 정리 (Cleanup expired cache entries)
  ///
  /// 주기적으로 호출하여 만료된 캐시 파일 정리
  Future<void> cleanup() async {
    // 메모리 캐시 정리
    _memoryCache.removeWhere((_, entry) => entry.isExpired);

    // 파일 캐시 정리
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return;

      int deletedCount = 0;
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.json')) {
          try {
            final contents = await entity.readAsString();
            final json = jsonDecode(contents) as Map<String, dynamic>;
            final expiresAt = DateTime.parse(json['expiresAt'] as String);
            if (DateTime.now().isAfter(expiresAt)) {
              await entity.delete();
              deletedCount++;
            }
          } catch (_) {
            // 손상된 파일 삭제
            await entity.delete();
            deletedCount++;
          }
        }
      }

      if (deletedCount > 0) {
        _log('만료된 캐시 $deletedCount개 정리 완료');
      }
    } catch (e) {
      _log('캐시 정리 실패 - $e');
    }
  }

  /// 캐시된 항목 개수 (Get cached entry count)
  ///
  /// 메모리 캐시에 있는 항목 수 반환 (만료된 항목 포함)
  int get memoryCacheCount => _memoryCache.length;

  /// 메모리 캐시에서 특정 키의 만료 시간 조회 (Get expiry time for key)
  ///
  /// [key] 캐시 키
  /// 메모리 캐시에 없으면 null 반환
  DateTime? getExpiryTime(String key) {
    return _memoryCache[key]?.expiresAt;
  }

  /// 메모리 캐시에서 특정 키의 남은 시간 조회 (Get remaining time for key)
  ///
  /// [key] 캐시 키
  /// 메모리 캐시에 없으면 null 반환
  Duration? getRemainingTime(String key) {
    return _memoryCache[key]?.remainingTime;
  }
}
