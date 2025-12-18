# file_cache_flutter

Flutter 애플리케이션을 위한 범용 파일 캐시 라이브러리입니다. 메모리 + 파일 이중 캐싱, TTL(Time-To-Live) 지원, 키-값 기반 저장을 제공합니다.

## 주요 기능

- **이중 캐싱**: 메모리 캐시와 파일 캐시를 동시에 사용하여 빠른 접근 속도 제공
- **TTL 지원**: 캐시 만료 시간 설정 가능 (기본값: 30분)
- **제네릭 타입**: 모든 데이터 타입을 캐싱 가능 (fromJson/toJson 콜백 사용)
- **키-값 저장**: 간단한 키-값 기반 API
- **자동 정리**: 만료된 캐시 자동 삭제

## 설치

`pubspec.yaml` 파일에 다음을 추가하세요:

```yaml
dependencies:
  file_cache_flutter: ^0.0.2
```

그런 다음 패키지를 설치합니다:

```bash
flutter pub get
```

## 사용법

### 기본 사용법

```dart
import 'package:file_cache_flutter/file_cache_flutter.dart';

// 데이터 모델 정의
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

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age};
  }
}

// 캐시 인스턴스 생성
final cache = FileCache<UserData>(
  cacheName: 'user_data',           // 캐시 디렉토리명
  fromJson: UserData.fromJson,      // JSON → 객체 변환 함수
  toJson: (data) => data.toJson(),  // 객체 → JSON 변환 함수
  defaultTtl: Duration(minutes: 30), // 기본 TTL (선택사항)
);

// 데이터 저장
await cache.set('user_123', UserData(name: '홍길동', age: 25));

// 데이터 조회 (만료 시 null 반환)
final user = await cache.get('user_123');
if (user != null) {
  print('사용자: ${user.name}, 나이: ${user.age}');
}

// 데이터 삭제
await cache.remove('user_123');

// 전체 캐시 삭제
await cache.clear();
```

### 개별 TTL 설정

```dart
// 특정 항목에 대해 개별 TTL 설정
await cache.set(
  'important_data',
  userData,
  ttl: Duration(hours: 2),  // 이 항목만 2시간 TTL 적용
);
```

### 캐시 존재 여부 확인

```dart
// 캐시가 존재하고 만료되지 않았는지 확인
final exists = await cache.has('user_123');
if (exists) {
  print('캐시가 유효합니다.');
}
```

### 캐시 정보 조회

```dart
// 메모리 캐시 항목 수
print('캐시된 항목 수: ${cache.memoryCacheCount}');

// 특정 키의 만료 시간 조회
final expiryTime = cache.getExpiryTime('user_123');
if (expiryTime != null) {
  print('만료 시간: $expiryTime');
}

// 특정 키의 남은 시간 조회
final remaining = cache.getRemainingTime('user_123');
if (remaining != null) {
  print('남은 시간: ${remaining.inMinutes}분');
}
```

### 만료된 캐시 정리

```dart
// 만료된 캐시 파일 정리 (주기적으로 호출 권장)
await cache.cleanup();
```

### 고급 설정

```dart
final cache = FileCache<MyData>(
  cacheName: 'my_cache',
  fromJson: MyData.fromJson,
  toJson: (d) => d.toJson(),
  defaultTtl: Duration(hours: 1),    // 기본 TTL: 1시간
  useMemoryCache: true,               // 메모리 캐시 사용 여부 (기본: true)
  enableLogging: true,                // 디버그 로그 출력 (기본: false)
  cacheRootName: 'my_app_cache',     // 캐시 루트 디렉토리명 (기본: 'file_cache')
);
```

## API 레퍼런스

### FileCache\<T\>

| 메서드 | 설명 |
|--------|------|
| `Future<T?> get(String key)` | 캐시에서 데이터 조회 (만료 시 null) |
| `Future<void> set(String key, T data, {Duration? ttl})` | 캐시에 데이터 저장 |
| `Future<bool> has(String key)` | 캐시 존재 여부 확인 |
| `Future<void> remove(String key)` | 특정 캐시 삭제 |
| `Future<void> clear()` | 전체 캐시 삭제 |
| `Future<void> cleanup()` | 만료된 캐시 정리 |
| `int get memoryCacheCount` | 메모리 캐시 항목 수 |
| `DateTime? getExpiryTime(String key)` | 만료 시간 조회 |
| `Duration? getRemainingTime(String key)` | 남은 시간 조회 |

### CacheEntry\<T\>

| 속성 | 설명 |
|------|------|
| `T data` | 캐시된 데이터 |
| `DateTime expiresAt` | 만료 시간 |
| `DateTime createdAt` | 생성 시간 |
| `bool isExpired` | 만료 여부 |
| `Duration remainingTime` | 남은 시간 |

## 테스트

이 패키지는 23개의 유닛 테스트를 포함합니다.

### 테스트 실행

```bash
cd packages/file_cache_flutter
flutter test
```

### 테스트 커버리지

#### CacheEntry 테스트 (8개)
- 올바른 속성으로 CacheEntry 생성
- 만료되지 않은 항목의 `isExpired` 확인
- 만료된 항목의 `isExpired` 확인
- 남은 시간(`remainingTime`) 계산
- JSON 직렬화 (`toJson`)
- JSON 역직렬화 (`fromJson`)
- `toString` 포맷 확인
- 커스텀 데이터 타입 지원

#### FileCache 테스트 (15개)
- 데이터 저장 및 조회
- 존재하지 않는 키 조회 시 null 반환
- 메모리 캐시 저장 확인
- 특정 캐시 항목 삭제
- 전체 캐시 삭제
- `has()` 메서드로 존재 여부 확인
- 개별 TTL 설정 지원
- 만료된 캐시 null 반환
- 특수문자가 포함된 키 처리
- 만료된 항목 정리 (`cleanup`)
- 메모리 캐시 비활성화 모드
- 만료 시간 및 남은 시간 조회
- 존재하지 않는 키의 시간 정보 null 반환
- 커스텀 캐시 루트 디렉토리 사용

### 테스트 코드 예시

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// 테스트용 데이터 모델
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

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

// Mock PathProvider
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
    tempDir = await Directory.systemTemp.createTemp('file_cache_test_');
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);

    cache = FileCache<TestData>(
      cacheName: 'test_cache',
      fromJson: TestData.fromJson,
      toJson: (data) => data.toJson(),
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('should store and retrieve data', () async {
    final testData = TestData(name: 'test', value: 123);

    await cache.set('key1', testData);
    final retrieved = await cache.get('key1');

    expect(retrieved, isNotNull);
    expect(retrieved!.name, 'test');
    expect(retrieved.value, 123);
  });

  test('should return null for expired cache', () async {
    final shortTtlCache = FileCache<TestData>(
      cacheName: 'short_ttl',
      fromJson: TestData.fromJson,
      toJson: (data) => data.toJson(),
      defaultTtl: Duration(milliseconds: 1),
      useMemoryCache: false,
    );

    await shortTtlCache.set('key', TestData(name: 'expire', value: 1));
    await Future.delayed(Duration(milliseconds: 10));

    final result = await shortTtlCache.get('key');
    expect(result, isNull);
  });
}
```

## 실제 사용 예시

### 환율 데이터 캐싱

```dart
class ExchangeRateData {
  final Map<String, double> rates;
  final String date;

  ExchangeRateData({required this.rates, required this.date});

  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      rates: Map<String, double>.from(json['rates']),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'rates': rates, 'date': date};
}

class CurrencyService {
  final _cache = FileCache<ExchangeRateData>(
    cacheName: 'exchange_rate',
    defaultTtl: Duration(minutes: 25),
    fromJson: ExchangeRateData.fromJson,
    toJson: (data) => data.toJson(),
  );

  Future<ExchangeRateData> loadExchangeRates() async {
    // 캐시에서 먼저 로드 시도
    final cached = await _cache.get('latest_rates');
    if (cached != null) return cached;

    // API 호출
    final data = await _fetchFromApi();

    // 캐시에 저장
    await _cache.set('latest_rates', data);

    return data;
  }

  Future<ExchangeRateData> _fetchFromApi() async {
    // API 호출 로직...
  }
}
```

### 날씨 데이터 캐싱

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
  final _cache = FileCache<WeatherData>(
    cacheName: 'weather',
    defaultTtl: Duration(minutes: 20),
    fromJson: WeatherData.fromJson,
    toJson: (data) => data.toJson(),
    enableLogging: true,  // 디버그 로그 활성화
  );

  Future<WeatherData?> getWeather(String cityId) async {
    return await _cache.get(cityId);
  }

  Future<void> saveWeather(String cityId, WeatherData data) async {
    await _cache.set(cityId, data);
  }

  Duration? getRemainingCacheTime(String cityId) {
    return _cache.getRemainingTime(cityId);
  }
}
```

## 라이센스

이 프로젝트는 MIT 라이센스를 따릅니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.
