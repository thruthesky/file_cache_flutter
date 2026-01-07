# Flutter 메모리 캐시 서비스

TTL + LRU 기반의 간단한 싱글톤 메모리 캐시입니다.

```dart
import 'dart:collection';

class _CacheEntry {
  _CacheEntry(this.value, this.expiresAt);
  final dynamic value;
  final DateTime? expiresAt;
  bool get isExpired => expiresAt != null && expiresAt!.isBefore(DateTime.now());
}

class MemoryCache {
  MemoryCache._();
  static final instance = MemoryCache._();

  final _map = LinkedHashMap<String, _CacheEntry>();
  int maxEntries = 200;
  Duration? defaultTtl;

  /// 조회
  T? get<T>(String key) {
    final entry = _map.remove(key);
    if (entry == null || entry.isExpired) return null;
    _map[key] = entry;
    return entry.value as T?;
  }

  /// 저장
  void set(String key, dynamic value, {Duration? ttl}) {
    final expires = (ttl ?? defaultTtl) != null
        ? DateTime.now().add(ttl ?? defaultTtl!)
        : null;
    _map.remove(key);
    _map[key] = _CacheEntry(value, expires);
    while (_map.length > maxEntries) {
      _map.remove(_map.keys.first);
    }
  }

  void remove(String key) => _map.remove(key);
  void clear() => _map.clear();
}
```

## 사용 예시

```dart
// 저장
MemoryCache.instance.set('user:123', {'id': '123', 'name': 'JaeHo'});
MemoryCache.instance.set('token', 'abc123', ttl: Duration(minutes: 5));

// 조회
final user = MemoryCache.instance.get<Map<String, dynamic>>('user:123');
final token = MemoryCache.instance.get<String>('token');

// 삭제
MemoryCache.instance.remove('user:123');
MemoryCache.instance.clear();
```
