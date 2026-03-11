# file_cache_flutter

[![pub package](https://img.shields.io/pub/v/file_cache_flutter.svg)](https://pub.dev/packages/file_cache_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A generic file cache library for Flutter applications with memory + file dual caching, TTL (Time-To-Live) support, and key-value storage.

## Features

- **Dual Caching**: Memory cache + file cache for fast access
- **TTL Support**: Configurable expiration time (default: 30 minutes)
- **Generic Types**: Cache any data type with `fromJson`/`toJson` callbacks
- **Key-Value Storage**: Simple key-value based API
- **Auto Cleanup**: Automatic removal of expired cache entries

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  file_cache_flutter: ^0.0.3
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:file_cache_flutter/file_cache_flutter.dart';

// Define your data model
class UserData {
  final String name;
  final int age;

  UserData({required this.name, required this.age});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      name: json['name'] as String,
      age: json['age'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

// Create cache instance
final cache = FileCache<UserData>(
  cacheName: 'user_data',
  fromJson: UserData.fromJson,
  toJson: (data) => data.toJson(),
  defaultTtl: Duration(minutes: 30),
);

// Store data
await cache.set('user_123', UserData(name: 'John', age: 25));

// Retrieve data (returns null if expired)
final user = await cache.get('user_123');

// Remove specific entry
await cache.remove('user_123');

// Clear all cache
await cache.clear();
```

### Custom TTL per Entry

```dart
await cache.set(
  'important_data',
  userData,
  ttl: Duration(hours: 2),  // Override default TTL
);
```

### Check Cache Existence

```dart
final exists = await cache.has('user_123');
```

### Cache Information

```dart
// Memory cache entry count
print('Cached entries: ${cache.memoryCacheCount}');

// Get expiry time
final expiryTime = cache.getExpiryTime('user_123');

// Get remaining time
final remaining = cache.getRemainingTime('user_123');
if (remaining != null) {
  print('Expires in: ${remaining.inMinutes} minutes');
}
```

### Cleanup Expired Entries

```dart
// Periodically call to remove expired cache files
await cache.cleanup();
```

### Advanced Configuration

```dart
final cache = FileCache<MyData>(
  cacheName: 'my_cache',
  fromJson: MyData.fromJson,
  toJson: (d) => d.toJson(),
  defaultTtl: Duration(hours: 1),
  useMemoryCache: true,       // Enable/disable memory cache (default: true)
  enableLogging: true,        // Enable debug logs (default: false)
  cacheRootName: 'app_cache', // Custom root directory (default: 'file_cache')
);
```

## API Reference

### FileCache\<T\>

| Method | Description |
|--------|-------------|
| `Future<T?> get(String key)` | Retrieve data from cache (returns null if expired) |
| `Future<void> set(String key, T data, {Duration? ttl})` | Store data in cache |
| `Future<bool> has(String key)` | Check if valid cache exists |
| `Future<void> remove(String key)` | Remove specific cache entry |
| `Future<void> clear()` | Clear all cache entries |
| `Future<void> cleanup()` | Remove expired cache files |
| `int get memoryCacheCount` | Get memory cache entry count |
| `DateTime? getExpiryTime(String key)` | Get expiry time for key |
| `Duration? getRemainingTime(String key)` | Get remaining time for key |

### CacheEntry\<T\>

| Property | Description |
|----------|-------------|
| `T data` | Cached data |
| `DateTime expiresAt` | Expiry time |
| `DateTime createdAt` | Creation time |
| `bool isExpired` | Whether cache is expired |
| `Duration remainingTime` | Time until expiry |

## Real-World Example

### Caching API Response with Cache-First Strategy

```dart
class WeatherData {
  final double temperature;
  final String description;

  WeatherData({required this.temperature, required this.description});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'temperature': temperature,
    'description': description,
  };
}

class WeatherService {
  static WeatherService? _instance;
  static WeatherService get instance => _instance ??= WeatherService._();
  WeatherService._();

  final _cache = FileCache<WeatherData>(
    cacheName: 'weather',
    defaultTtl: Duration(minutes: 20),
    fromJson: WeatherData.fromJson,
    toJson: (data) => data.toJson(),
  );

  Future<WeatherData> getWeather(String cityId) async {
    // Try cache first
    final cached = await _cache.get(cityId);
    if (cached != null) return cached;

    // Fetch from API
    final data = await _fetchFromApi(cityId);

    // Store in cache
    await _cache.set(cityId, data);

    return data;
  }

  Future<void> clearCache() async {
    await _cache.clear();
  }

  Duration? getCacheRemainingTime(String cityId) {
    return _cache.getRemainingTime(cityId);
  }

  Future<WeatherData> _fetchFromApi(String cityId) async {
    // Your API call implementation
    throw UnimplementedError();
  }
}
```

## Testing

This package includes 23 unit tests.

```bash
flutter test
```

### Mock Setup for Testing

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String tempPath;
  MockPathProviderPlatform(this.tempPath);

  @override
  Future<String?> getTemporaryPath() async => tempPath;
}

void main() {
  late Directory tempDir;
  late FileCache<TestData> cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cache_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);

    cache = FileCache<TestData>(
      cacheName: 'test',
      fromJson: TestData.fromJson,
      toJson: (d) => d.toJson(),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('stores and retrieves data', () async {
    await cache.set('key', TestData(name: 'test', value: 123));
    final result = await cache.get('key');

    expect(result, isNotNull);
    expect(result!.name, 'test');
  });
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
