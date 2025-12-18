/// 범용 캐시 서비스 (Generic Cache Service)
///
/// 파일 기반 캐싱과 메모리 캐싱을 지원하는 범용 캐시 서비스입니다.
///
/// ### 주요 클래스 (Main Classes):
/// - [FileCache] - 범용 파일 캐시 서비스
/// - [CacheEntry] - 캐시 엔트리 래퍼
///
/// ### 사용 예시 (Usage Example):
/// ```dart
/// import 'package:file_cache_flutter/file_cache_flutter.dart';
///
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
/// // 조회
/// final data = await cache.get('key1');
/// ```
library;

export 'src/cache_entry.dart';
export 'src/file_cache.dart';
