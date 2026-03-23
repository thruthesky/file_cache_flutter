# Flutter 앱 날씨(Weather) 기능 가이드

## 개요

필고 앱의 날씨 기능은 **Open-Meteo API**를 사용하여 필리핀 5개 주요 도시의 6일 날씨 예보를 표시한다.
v7 API(`api.php`)를 사용하지 않고, Open-Meteo 공개 API를 직접 호출하는 독립 기능이다.

### 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **Open-Meteo API 사용** | 무료 공개 날씨 API, 인증 불필요 |
| **싱글톤 서비스** | `WeatherService.instance`로 앱 전체에서 동일 인스턴스 사용 |
| **메모리 캐시** | TTL 20분, 불필요한 API 재호출 방지 |
| **병렬 API 호출** | 5개 도시 데이터를 `Future.wait()`으로 동시 조회 |
| **v7 모듈 구조** | `lib/weather/` 폴더에 Model, Service, Screen 파일 배치 |

---

## 1. 파일 구조

```
lib/weather/
├── weather.model.dart    # 데이터 모델 (PhilippineCity, HourlyWeather, WeatherCodeHelper 등)
├── weather.service.dart  # Open-Meteo API 호출, 캐시 관리
└── weather.screen.dart   # 날씨 화면 UI (테이블 형식)
```

---

## 2. 데이터 모델 (`weather.model.dart`)

### 2.1 PhilippineCity — 도시 정보

5개 필리핀 도시의 좌표와 이름을 정의한다.

```dart
class PhilippineCity {
  final String id;
  final String nameKo;
  final String nameEn;
  final double latitude;
  final double longitude;

  const PhilippineCity({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });

  /// 5개 도시 목록
  static const List<PhilippineCity> cities = [
    PhilippineCity(id: 'manila', nameKo: '마닐라', nameEn: 'Manila', latitude: 14.5995, longitude: 120.9842),
    PhilippineCity(id: 'cebu', nameKo: '세부', nameEn: 'Cebu', latitude: 10.3157, longitude: 123.8854),
    PhilippineCity(id: 'angeles', nameKo: '앙헬레스', nameEn: 'Angeles', latitude: 15.1450, longitude: 120.5887),
    PhilippineCity(id: 'boracay', nameKo: '보라카이', nameEn: 'Boracay', latitude: 11.9674, longitude: 121.9248),
    PhilippineCity(id: 'baguio', nameKo: '바기오', nameEn: 'Baguio', latitude: 16.4023, longitude: 120.5960),
  ];

  /// ID로 도시 찾기
  static PhilippineCity? findById(String id) {
    try {
      return cities.firstWhere((city) => city.id == id);
    } catch (_) {
      return null;
    }
  }
}
```

### 2.2 HourlyWeather — 시간별 날씨 데이터

```dart
class HourlyWeather {
  final DateTime time;
  final double temperature;  // 섭씨(°C)
  final int weatherCode;     // WMO 날씨 코드

  const HourlyWeather({required this.time, required this.temperature, required this.weatherCode});

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'temperature': temperature,
    'weatherCode': weatherCode,
  };
}
```

### 2.3 CityWeatherData — 도시별 날씨 데이터

```dart
class CityWeatherData {
  final String cityId;
  final List<HourlyWeather> hourlyData;

  const CityWeatherData({required this.cityId, required this.hourlyData});

  factory CityWeatherData.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 2.4 WeatherData — 전체 날씨 데이터 (캐시용)

```dart
class WeatherData {
  final Map<String, CityWeatherData> cities;  // 키: 도시 ID
  final DateTime fetchedAt;

  const WeatherData({required this.cities, required this.fetchedAt});

  factory WeatherData.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### 2.5 WeatherCodeHelper — WMO 날씨 코드 변환

WMO 표준 날씨 코드를 한글 텍스트, 영문 텍스트, Font Awesome 아이콘, 색상으로 변환한다.

```dart
class WeatherCodeHelper {
  static String getDescription(int code) { ... }    // 한글 설명
  static String getDescriptionEn(int code) { ... }  // 영문 설명
  static IconData getIcon(int code) { ... }          // Font Awesome Light 아이콘
  static Color getColor(int code) { ... }            // 아이콘 색상
}
```

#### WMO 날씨 코드 참조표

| 코드 | 한글 | 영문 | 아이콘 | 색상 |
|------|------|------|--------|------|
| 0 | 맑음 | Clear | `lightSun` | orange |
| 1-2 | 대체로 맑음 | Partly Cloudy | `lightCloudSun` | amber |
| 3 | 흐림 | Cloudy | `lightCloud` | grey |
| 45, 48 | 안개 | Fog | `lightSmog` | blueGrey |
| 51, 53, 55 | 이슬비 | Drizzle | `lightCloudDrizzle` | lightBlue |
| 56, 57 | 어는 이슬비 | Freezing Drizzle | `lightCloudDrizzle` | lightBlue |
| 61, 63, 65 | 비 | Rain | `lightCloudRain` | blue |
| 66, 67 | 어는 비 | Freezing Rain | `lightCloudRain` | blue |
| 71, 73, 75 | 눈 | Snow | `lightSnowflake` | cyan |
| 77 | 싸락눈 | Snow Grains | `lightSnowflake` | cyan |
| 80, 81, 82 | 소나기 | Showers | `lightCloudShowersHeavy` | indigo |
| 85, 86 | 눈소나기 | Snow Showers | `lightCloudSnow` | teal |
| 95 | 뇌우 | Thunderstorm | `lightCloudBolt` | purple |
| 96, 99 | 우박 뇌우 | Hail Storm | `lightCloudBolt` | purple |

---

## 3. WeatherService (`weather.service.dart`)

### 핵심 설계

- **싱글톤 패턴**: `WeatherService.instance`
- **메모리 캐시**: TTL 20분, `_isCacheValid()` 메서드로 만료 판단
- **병렬 API 호출**: `Future.wait()`으로 5개 도시 동시 조회
- **외부 API 전용**: v7 API(`api.php`)를 사용하지 않고 Open-Meteo 직접 호출

### 메서드 목록

| 메서드 | 반환 타입 | 설명 |
|--------|----------|------|
| `loadWeatherData()` | `Future<WeatherData>` | 5개 도시 6일 예보 로드 (캐시 우선) |
| `loadManilaCurrentWeather()` | `Future<HourlyWeather>` | 마닐라 현재 날씨 (Entry 화면용) |
| `getWeatherAt(cityId, time)` | `HourlyWeather?` | 특정 도시+시간의 날씨 조회 |
| `getDisplayTimeSlots()` | `List<DateTime>` | 표시할 시간 슬롯 생성 |
| `clearCache()` | `Future<void>` | 캐시 초기화 |
| `cacheRemainingTime` | `Duration?` | 캐시 남은 시간 |

### 핵심 소스코드

#### Open-Meteo API 호출

```dart
static const String _apiBaseUrl = 'https://api.open-meteo.com/v1/forecast';

Future<CityWeatherData> _fetchCityWeather(PhilippineCity city) async {
  final url = Uri.parse(
    '$_apiBaseUrl?'
    'latitude=${city.latitude}&'
    'longitude=${city.longitude}&'
    'hourly=temperature_2m,weather_code&'
    'timezone=Asia/Manila&'
    'forecast_days=6',
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final hourly = json['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List).cast<String>();
    final temperatures = (hourly['temperature_2m'] as List).cast<num>();
    final weatherCodes = (hourly['weather_code'] as List).cast<int>();
    // ... HourlyWeather 리스트 생성
  }
}
```

#### 병렬 호출 + 캐시

```dart
Future<WeatherData> _fetchFromApi() async {
  final futures = PhilippineCity.cities.map(_fetchCityWeather);
  final results = await Future.wait(futures);
  // ... WeatherData 생성
}

Future<WeatherData> loadWeatherData() async {
  if (_weatherData != null && _isCacheValid(_weatherDataFetchedAt)) {
    return _weatherData!;
  }
  final data = await _fetchFromApi();
  _weatherData = data;
  _weatherDataFetchedAt = DateTime.now();
  return data;
}
```

#### 시간 슬롯 생성

```dart
List<DateTime> getDisplayTimeSlots() {
  // 오늘: 현재 시간 이후 2시간 간격 (짝수 시간)
  // 내일~5일: 4시간 간격 (0, 4, 8, 12, 16, 20시)
}
```

#### 마닐라 현재 날씨 (Entry 화면용)

```dart
Future<HourlyWeather> loadManilaCurrentWeather() async {
  // Open-Meteo API current 파라미터 사용
  // URL: ...&current=temperature_2m,weather_code&timezone=Asia/Manila
  // 별도 캐시 (_manilaCurrentWeather, _manilaFetchedAt)
}
```

---

## 4. WeatherScreen (`weather.screen.dart`)

### 화면 정보

| 항목 | 값 |
|------|-----|
| **클래스** | `WeatherScreen` |
| **routeName** | `/weather` |
| **네비게이션** | `WeatherScreen.push(context)` |
| **라우트 파일** | `lib/router.dart` |

### UI 구조

```
┌──────────────────────────────────────────┐
│  AppBar: "필리핀 날씨" + 새로고침 버튼      │
├──────────────────────────────────────────┤
│  [가로/세로 스크롤 테이블]                  │
│                                          │
│  시간  마닐라  세부  앙헬레스 보라카이 바기오  │
│  ─── 오늘 ───                             │
│  14:00  ☀28°  ☁27°  ☀29°  ☁28°  ☀26°    │
│  16:00  ☀28°  ☁27°  ☀28°  ☁28°  ☀25°    │
│  ...                                     │
│  ─── 내일 ───                             │
│  00:00  ☀26°  ☁23°  ☀21°  ☁26°  ☀20°    │
│  04:00  ...                              │
└──────────────────────────────────────────┘
```

### 핵심 UI 패턴

- **글로벌 접근자 사용**: `color` (ColorScheme), `text` (TextTheme) — `lib/globals.dart`
- **Font Awesome Pro Light 아이콘**: 날씨 아이콘, 앱바 아이콘 모두 Light 스타일
- **flutter_animate**: 테이블 fadeIn + slideY 애니메이션
- **날짜 구분선**: "오늘", "내일", "MM/dd (요일)" 형식

### 핵심 소스코드

#### 날씨 셀 렌더링

```dart
Widget _buildWeatherCell(HourlyWeather? weather) {
  final icon = WeatherCodeHelper.getIcon(weather.weatherCode);
  final iconColor = WeatherCodeHelper.getColor(weather.weatherCode);
  final description = WeatherCodeHelper.getDescription(weather.weatherCode);
  final temp = weather.temperature.round();

  return _buildCell(
    width: 80,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text('$temp°', style: text.bodyMedium?.copyWith(
          color: color.onSurface, fontWeight: FontWeight.w600,
        )),
        Text(description, style: text.labelSmall?.copyWith(
          color: color.onSurfaceVariant, fontSize: 10,
        )),
      ],
    ),
  );
}
```

#### 새로고침

```dart
IconButton(
  onPressed: _isLoading ? null : () async {
    await _weatherService.clearCache();
    await _loadWeatherData();
  },
)
```

---

## 5. 라우팅

### GoRouter 라우트 (`lib/router.dart`)

```dart
import 'package:philgo/weather/weather.screen.dart';

GoRoute(
  path: WeatherScreen.routeName,  // '/weather'
  name: WeatherScreen.routeName,
  builder: (context, state) => const WeatherScreen(),
),
```

### 화면 이동

```dart
// 날씨 화면으로 이동
WeatherScreen.push(context);

// 또는 GoRouter로 직접
context.push('/weather');
```

---

## 6. Open-Meteo API 참조

### 6일 예보 API

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=14.5995
  &longitude=120.9842
  &hourly=temperature_2m,weather_code
  &timezone=Asia/Manila
  &forecast_days=6
```

**응답 구조:**
```json
{
  "hourly": {
    "time": ["2026-03-20T00:00", "2026-03-20T01:00", ...],
    "temperature_2m": [26.5, 26.0, ...],
    "weather_code": [0, 1, ...]
  }
}
```

### 현재 날씨 API (마닐라 전용)

```
GET https://api.open-meteo.com/v1/forecast
  ?latitude=14.5995
  &longitude=120.9842
  &current=temperature_2m,weather_code
  &timezone=Asia/Manila
```

**응답 구조:**
```json
{
  "current": {
    "time": "2026-03-20T13:45",
    "temperature_2m": 28.5,
    "weather_code": 0
  }
}
```

---

## 7. 사용 예시

### 날씨 화면 열기

```dart
// 메뉴나 홈 화면에서
WeatherScreen.push(context);
```

### Entry 화면에서 마닐라 현재 날씨 표시

```dart
final weather = await WeatherService.instance.loadManilaCurrentWeather();
print('마닐라 현재: ${weather.temperature}°C, ${WeatherCodeHelper.getDescription(weather.weatherCode)}');
```

### 특정 도시 특정 시간 날씨 조회

```dart
await WeatherService.instance.loadWeatherData();
final weather = WeatherService.instance.getWeatherAt('cebu', DateTime.now());
if (weather != null) {
  print('세부: ${weather.temperature}°C');
}
```
