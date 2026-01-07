/// 메모리 캐시 서비스 (Memory Cache Service)
///
/// LRU(Least Recently Used) 정책을 지원하는 싱글톤 메모리 캐시입니다.
///
/// ### 사용 예시:
/// ```dart
/// // 저장
/// MemoryCache.instance.set('user:123', {'id': '123', 'name': 'JaeHo'});
///
/// // 조회
/// final user = MemoryCache.instance.get<Map<String, dynamic>>('user:123');
///
/// // 삭제
/// MemoryCache.instance.remove('user:123');
/// MemoryCache.instance.clear();
/// ```
class MemoryCache {
  MemoryCache._();

  /// 싱글톤 인스턴스 (Singleton instance)
  static final instance = MemoryCache._();

  /// 캐시 저장소 (Cache storage)
  final _map = <String, dynamic>{};

  /// 최대 캐시 항목 수 (Maximum cache entries)
  int maxEntries = 200;

  /// 캐시에서 값 조회 (Get value from cache)
  T? get<T>(String key) {
    final value = _map.remove(key);
    if (value == null) return null;

    // LRU: 최근 접근한 항목을 맨 뒤로 재삽입
    _map[key] = value;
    return value as T?;
  }

  /// 캐시에 값 저장 (Set value to cache)
  void set(String key, dynamic value) {
    _map.remove(key);
    _map[key] = value;

    // LRU: 용량 초과 시 가장 오래된 항목 제거
    while (_map.length > maxEntries) {
      _map.remove(_map.keys.first);
    }
  }

  /// 특정 키 삭제 (Remove specific key)
  void remove(String key) => _map.remove(key);

  /// 전체 캐시 삭제 (Clear all cache)
  void clear() => _map.clear();

  /// 캐시 항목 수 (Number of cached items)
  int get length => _map.length;
}
