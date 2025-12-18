import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// 테스트용 데이터 모델 (Test data model)
class TestData {
  final String name;
  final int value;

  TestData({required this.name, required this.value});

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      name: json['name'] as String,
      value: json['value'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestData && other.name == name && other.value == value;
  }

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}

/// Mock PathProvider for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;

  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async {
    return tempPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return tempPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return tempPath;
  }
}

void main() {
  late Directory tempDir;
  late FileCache<TestData> cache;

  setUp(() async {
    // 테스트용 임시 디렉토리 생성 (Create temp directory for testing)
    tempDir = await Directory.systemTemp.createTemp('file_cache_test_');

    // Mock PathProvider 설정 (Setup mock PathProvider)
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);

    // FileCache 인스턴스 생성 (Create FileCache instance)
    cache = FileCache<TestData>(
      cacheName: 'test_cache',
      fromJson: TestData.fromJson,
      toJson: (data) => data.toJson(),
      defaultTtl: const Duration(minutes: 30),
      enableLogging: false,
    );
  });

  tearDown(() async {
    // 테스트 후 임시 디렉토리 삭제 (Clean up temp directory after test)
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FileCache', () {
    test('should store and retrieve data correctly', () async {
      // given
      final testData = TestData(name: 'test', value: 123);

      // when
      await cache.set('key1', testData);
      final retrieved = await cache.get('key1');

      // then
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'test');
      expect(retrieved.value, 123);
    });

    test('should return null for non-existent key', () async {
      // when
      final result = await cache.get('non_existent_key');

      // then
      expect(result, isNull);
    });

    test('should store data in memory cache', () async {
      // given
      final testData = TestData(name: 'memory_test', value: 456);

      // when
      await cache.set('memory_key', testData);

      // then
      expect(cache.memoryCacheCount, 1);
    });

    test('should remove specific cache entry', () async {
      // given
      final testData = TestData(name: 'to_remove', value: 789);
      await cache.set('remove_key', testData);

      // verify it exists
      expect(await cache.get('remove_key'), isNotNull);

      // when
      await cache.remove('remove_key');

      // then
      expect(await cache.get('remove_key'), isNull);
      expect(cache.memoryCacheCount, 0);
    });

    test('should clear all cache entries', () async {
      // given
      await cache.set('key1', TestData(name: 'test1', value: 1));
      await cache.set('key2', TestData(name: 'test2', value: 2));
      await cache.set('key3', TestData(name: 'test3', value: 3));

      expect(cache.memoryCacheCount, 3);

      // when
      await cache.clear();

      // then
      expect(cache.memoryCacheCount, 0);
      expect(await cache.get('key1'), isNull);
      expect(await cache.get('key2'), isNull);
      expect(await cache.get('key3'), isNull);
    });

    test('should check if cache exists with has()', () async {
      // given
      await cache.set('exists_key', TestData(name: 'exists', value: 100));

      // then
      expect(await cache.has('exists_key'), true);
      expect(await cache.has('not_exists_key'), false);
    });

    test('should support custom TTL for individual entries', () async {
      // given
      final testData = TestData(name: 'custom_ttl', value: 999);

      // when
      await cache.set('custom_ttl_key', testData,
          ttl: const Duration(hours: 2));

      // then
      final expiryTime = cache.getExpiryTime('custom_ttl_key');
      expect(expiryTime, isNotNull);

      final remaining = cache.getRemainingTime('custom_ttl_key');
      expect(remaining, isNotNull);
      expect(remaining!.inMinutes, greaterThan(100)); // 약 2시간
    });

    test('should return null for expired cache', () async {
      // given - 매우 짧은 TTL로 캐시 생성
      final shortTtlCache = FileCache<TestData>(
        cacheName: 'short_ttl_cache',
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        defaultTtl: const Duration(milliseconds: 1),
        useMemoryCache: false, // 파일 캐시만 테스트
      );

      final testData = TestData(name: 'expire_test', value: 111);
      await shortTtlCache.set('expire_key', testData);

      // 만료 대기 (Wait for expiration)
      await Future.delayed(const Duration(milliseconds: 10));

      // then
      final result = await shortTtlCache.get('expire_key');
      expect(result, isNull);
    });

    test('should handle special characters in cache key', () async {
      // given
      final testData = TestData(name: 'special', value: 222);

      // when - 특수문자가 포함된 키 사용
      await cache.set('key/with/special:chars?query=1', testData);
      final retrieved = await cache.get('key/with/special:chars?query=1');

      // then
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'special');
    });

    test('should cleanup expired entries', () async {
      // given - 짧은 TTL로 캐시 생성
      final cleanupCache = FileCache<TestData>(
        cacheName: 'cleanup_cache',
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        defaultTtl: const Duration(milliseconds: 1),
      );

      await cleanupCache.set('expire1', TestData(name: 'e1', value: 1));
      await cleanupCache.set('expire2', TestData(name: 'e2', value: 2));

      // 만료 대기
      await Future.delayed(const Duration(milliseconds: 10));

      // when
      await cleanupCache.cleanup();

      // then - 메모리 캐시가 정리되어야 함
      expect(cleanupCache.memoryCacheCount, 0);
    });

    test('should work without memory cache', () async {
      // given
      final noMemoryCache = FileCache<TestData>(
        cacheName: 'no_memory_cache',
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        useMemoryCache: false,
      );

      final testData = TestData(name: 'file_only', value: 333);

      // when
      await noMemoryCache.set('file_key', testData);

      // then - 메모리 캐시에는 저장되지 않음
      expect(noMemoryCache.memoryCacheCount, 0);

      // 파일에서 읽어와야 함
      final retrieved = await noMemoryCache.get('file_key');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'file_only');
    });

    test('should return correct expiry and remaining time', () async {
      // given
      final testData = TestData(name: 'time_test', value: 444);

      // when
      await cache.set('time_key', testData, ttl: const Duration(hours: 1));

      // then
      final expiryTime = cache.getExpiryTime('time_key');
      final remainingTime = cache.getRemainingTime('time_key');

      expect(expiryTime, isNotNull);
      expect(remainingTime, isNotNull);
      expect(remainingTime!.inMinutes, greaterThanOrEqualTo(59));
    });

    test('should return null for expiry/remaining time of non-existent key',
        () {
      // then
      expect(cache.getExpiryTime('non_existent'), isNull);
      expect(cache.getRemainingTime('non_existent'), isNull);
    });

    test('should use custom cache root name', () async {
      // given
      final customRootCache = FileCache<TestData>(
        cacheName: 'custom_root_test',
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheRootName: 'my_app_cache',
      );

      final testData = TestData(name: 'root_test', value: 555);

      // when
      await customRootCache.set('root_key', testData);

      // then
      final retrieved = await customRootCache.get('root_key');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'root_test');
    });
  });
}
