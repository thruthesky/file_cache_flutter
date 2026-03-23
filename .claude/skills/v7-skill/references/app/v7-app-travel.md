# Flutter 앱 여행 명소 연동 — v7 Travel API

## 목차

1. [개요](#1-개요)
2. [파일 구조 및 역할](#2-파일-구조-및-역할)
3. [TravelApi — v7 API 래퍼](#3-travelapi--v7-api-래퍼)
4. [TravelSpot 모델](#4-travelspot-모델)
5. [TravelSpotService — 캐싱 및 데이터 로드](#5-travelspotservice--캐싱-및-데이터-로드)
6. [TravelSpotViewScreen — 상세 화면 API 연동](#6-travelspotviewscreen--상세-화면-api-연동)
7. [데이터 흐름 다이어그램](#7-데이터-흐름-다이어그램)
8. [CoT/ToT 핵심 결정 사항](#8-cottot-핵심-결정-사항)

---

## 1. 개요

Flutter 앱의 여행 명소 기능은 v7 Travel API를 통해 데이터를 가져온다.
앱과 웹(필고 홈페이지)이 **동일한 JSON 파일을 공유**하여 일관된 콘텐츠를 제공한다.

### 핵심 특징

| 항목 | 설명 |
|------|------|
| **데이터 소스** | v7 `travel.list` / `travel.get` API |
| **캐시** | FileCache 3일 TTL + 메모리 캐시 |
| **오프라인 폴백** | 번들 JSON (`lib/philgo_files/travel/travel_spots.json`) |
| **texts 분리** | 목록에서는 texts 제외, 상세 화면에서만 API로 로드 |
| **인증** | 불필요 (공개 API) |

---

## 2. 파일 구조 및 역할

```
lib/
├── v7_api/
│   └── travel_api.dart                    ← v7 Travel API 래퍼 (list, get, filters)
├── models/
│   └── travel_spot.model.dart             ← TravelSpot + TravelSpotsData 모델
├── services/travel/
│   └── travel_spot.service.dart           ← 싱글톤 서비스 (캐시 + API + 번들 폴백)
└── screens/guide/
    ├── travel_spots.screen.dart           ← 목록 화면 (전체 로드 + 클라이언트 필터)
    └── travel_spot.view.screen.dart       ← 상세 화면 (API로 texts 로드)
```

---

## 3. TravelApi — v7 API 래퍼

**파일**: `lib/v7_api/travel_api.dart`

```dart
import 'v7_api.dart';

class TravelApi {
  TravelApi._();

  /// 목록 조회 (texts 제외, 경량화)
  /// 앱에서는 limit=9999로 전체 로드
  static Future<Map<String, dynamic>> list({
    String? province,
    String? city,
    String? category,
    String? search,
    int page = 1,
    int limit = 9999,
  }) async {
    return await v7api('travel.list', data: {
      if (province != null) 'province': province,
      if (city != null) 'city': city,
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'page': page,
      'limit': limit,
    });
  }

  /// 상세 조회 (texts 포함)
  static Future<Map<String, dynamic>> get({required int index}) async {
    return await v7api('travel.get', data: {'index': index});
  }

  /// 필터 옵션 목록
  static Future<Map<String, dynamic>> filters() async {
    return await v7api('travel.filters');
  }
}
```

### 사용법

```dart
/// 전체 목록 로드
final result = await TravelApi.list();
final items = result['items'] as List<dynamic>;

/// 특정 명소 상세 조회 (texts 포함)
final spot = await TravelApi.get(index: 42);
print(spot['texts']); // 마크다운 배열

/// 필터 옵션
final filters = await TravelApi.filters();
print(filters['provinces']); // ["네그로스 옥시덴탈", "보홀", "세부", ...]
```

---

## 4. TravelSpot 모델

**파일**: `lib/models/travel_spot.model.dart`

### v7 API 대응 필드

| 필드 | 타입 | 기본값 | v7 API 키 | 설명 |
|------|------|--------|-----------|------|
| `index` | int | 0 | `index` | JSON 배열 인덱스 (v7 식별자) |
| `name` | String | '' | `name` | 한글 이름 |
| `englishName` | String | '' | `english name` 또는 `english_name` | 영문 이름 |
| `title` | String | '' | `title` | 제목/부제목 |
| `description` | String | '' | `description` | 간단 설명 |
| `city` | String | '' | `city` | 도시 |
| `province` | String | '' | `province` | 지역/주 |
| `icon` | String | '📍' | `icon` | 이모지 |
| `category` | String | '' | `category` | 분류 |
| `imageUrl` | String? | null | `imageUrl` 또는 `image_url` | CDN 이미지 |
| `texts` | List\<String\>? | null | `texts` | 마크다운 상세 (travel.get만) |
| `hasTextsFlag` | bool | false | `has_texts` | texts 존재 여부 플래그 |

### JSON 키 호환성

원본 JSON과 v7 API 응답 모두에서 파싱 가능하도록 **이중 키를 지원**:

```dart
factory TravelSpot.fromJson(Map<String, dynamic> json) {
  return TravelSpot(
    index: json['index'] as int? ?? 0,
    /// 원본 JSON: "english name" (공백), API 정규화: "english_name" (언더스코어)
    englishName: (json['english name'] ?? json['english_name']) as String? ?? '',
    /// 원본 JSON: "imageUrl" (camelCase), API 정규화: "image_url" (snake_case)
    imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
    hasTextsFlag: json['has_texts'] as bool? ?? false,
    texts: (json['texts'] as List<dynamic>?)?.cast<String>(),
    // ... 나머지 필드
  );
}
```

### TravelSpotsData (캐시 래퍼)

```dart
/// FileCache가 단일 객체를 캐싱하도록 설계되어 있어,
/// 리스트를 캐싱하려면 래퍼 클래스가 필요
class TravelSpotsData {
  final List<TravelSpot> spots;
  final DateTime fetchedAt;
}
```

---

## 5. TravelSpotService — 캐싱 및 데이터 로드

**파일**: `lib/services/travel/travel_spot.service.dart`
**패턴**: 싱글톤 (`TravelSpotService.instance`)

### 캐시 전략

```
요청 → 캐시 확인 (3일 TTL)
         │
    ┌────┴────┐
    │ 캐시 유효 │ → 캐시 데이터 반환 (즉시)
    └─────────┘
         │ 캐시 없음
         ▼
    번들 JSON 로드 (오프라인 폴백, 즉시 표시)
         │
         ▼ 백그라운드
    v7 API 호출 (travel.list, limit=9999)
         │
         ▼
    캐시 저장 + onRemoteDataUpdated 콜백
```

### 핵심 구현

```dart
class TravelSpotService {
  static TravelSpotService get instance => _instance ??= TravelSpotService._();

  /// 3일 캐시 TTL
  static const Duration cacheTtl = Duration(days: 3);

  /// FileCache — 메모리 + 파일 이중 캐싱
  late final FileCache<TravelSpotsData> _cache = FileCache<TravelSpotsData>(
    cacheName: 'travel_spots',
    defaultTtl: cacheTtl,
    fromJson: TravelSpotsData.fromJson,
    toJson: (data) => data.toJson(),
    useMemoryCache: true,
  );

  /// 목록 로드 (캐시 → 번들 → API 백그라운드)
  Future<List<TravelSpot>> loadTravelSpots({
    OnRemoteDataUpdated? onRemoteDataUpdated,
  }) async { ... }

  /// 상세 조회 — v7 travel.get API 호출
  Future<TravelSpot> getSpotDetail(int index) async { ... }

  /// 필터 옵션 — v7 travel.filters API 호출
  Future<Map<String, dynamic>> getFilters() async { ... }

  /// 강제 새로고침 (캐시 무시)
  Future<List<TravelSpot>> forceRefresh() async { ... }
}
```

### 3가지 데이터 조회 메서드

| 메서드 | API | 용도 |
|--------|-----|------|
| `loadTravelSpots()` | `travel.list` (limit=9999) | 전체 목록 로드 (texts 제외) |
| `getSpotDetail(index)` | `travel.get` | 단건 상세 (texts 포함) |
| `getFilters()` | `travel.filters` | 필터 드롭다운 옵션 |

### 번들 JSON 폴백

v7 API 호출 실패 시 또는 최초 로드 시 번들 JSON을 사용:

```dart
/// 번들 파일 경로
static const String _bundlePath = 'lib/philgo_files/travel/travel_spots.json';

/// Isolate에서 JSON 파싱 (메인 스레드 차단 방지)
static Future<List<TravelSpot>> _parseJsonInIsolate(String jsonString) {
  return Isolate.run(() {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TravelSpot.fromJson(e as Map<String, dynamic>)).toList();
  });
}
```

---

## 6. TravelSpotViewScreen — 상세 화면 API 연동

**파일**: `lib/screens/guide/travel_spot.view.screen.dart`

### texts 로딩 전략

```
상세 화면 진입 (widget.spot 전달)
    │
    ▼
_spot = widget.spot (기본 정보 즉시 표시)
    │
    ├── _spot.hasTexts == true → texts 이미 있음 (번들 또는 캐시)
    │
    └── _spot.hasTexts == false → v7 API로 texts 로드
        │
        ▼
    _loadTextsFromApi()
        │
        ├── 로딩 중: CircularProgressIndicator 표시
        │
        └── 로드 완료: setState → _spot = detailSpot (texts 포함)
```

### 핵심 코드

```dart
class _TravelSpotViewScreenState extends State<TravelSpotViewScreen> {
  /// 목록에서 전달받은 spot → API 응답으로 업데이트되는 상태 변수
  late TravelSpot _spot;
  bool _isLoadingTexts = false;

  @override
  void initState() {
    super.initState();
    _spot = widget.spot;
    if (!_spot.hasTexts) {
      _loadTextsFromApi();
    }
  }

  /// v7 travel.get API로 texts 로드
  Future<void> _loadTextsFromApi() async {
    setState(() => _isLoadingTexts = true);
    try {
      final detailSpot = await TravelSpotService.instance.getSpotDetail(_spot.index);
      if (mounted) {
        setState(() {
          _spot = detailSpot;
          _isLoadingTexts = false;
        });
      }
    } catch (e) {
      debugPrint('texts 로드 실패 - $e');
      if (mounted) setState(() => _isLoadingTexts = false);
    }
  }
}
```

### UX 최적화

| 상태 | 표시 |
|------|------|
| 기본 정보 | **즉시 표시** (이름, 이미지, 카테고리, 위치 등) |
| texts 로딩 중 | `CircularProgressIndicator` |
| texts 로드 완료 | 마크다운 섹션 애니메이션으로 표시 |
| texts 로드 실패 | `description` 필드로 폴백 |

---

## 7. 데이터 흐름 다이어그램

### 목록 화면 (TravelSpotsScreen)

```
TravelSpotsScreen.initState()
    │
    ▼
TravelSpotService.instance.loadTravelSpots(
  onRemoteDataUpdated: (spots) => setState(...)
)
    │
    ├── [1] 캐시 확인 → 3일 이내 → 캐시 데이터 반환 ✅
    │
    └── [2] 캐시 없음
        │
        ├── 번들 JSON 로드 → Isolate 파싱 → 즉시 반환 ✅
        │
        └── 백그라운드: v7 travel.list API 호출
            │
            ├── 성공 → 캐시 저장 → onRemoteDataUpdated 콜백 → setState
            └── 실패 → debugPrint (번들 데이터로 계속 사용)
```

### 상세 화면 (TravelSpotViewScreen)

```
TravelSpotViewScreen(spot: listSpot)  ← texts 없는 spot
    │
    ├── 기본 정보 즉시 표시 (name, image, category 등)
    │
    └── _loadTextsFromApi()
        │
        ▼
    TravelSpotService.instance.getSpotDetail(spot.index)
        │
        ▼
    TravelApi.get(index: spot.index)  ← v7 travel.get API
        │
        ▼
    TravelSpot.fromJson(response)  ← texts 포함
        │
        ▼
    setState(() => _spot = detailSpot)  ← 마크다운 섹션 표시
```

---

## 8. CoT/ToT 핵심 결정 사항

### CoT — 왜 이렇게 구현했는가

| 결정 | 근거 |
|------|------|
| **전체 로드 (limit=9999)** | 1,045개 × texts 제외, 기존 클라이언트 검색/필터 UX 유지 |
| **3일 캐시** | 여행 정보 변경 빈도 매우 낮음, 네트워크 호출 최소화 |
| **번들 폴백 유지** | 오프라인 지원, 최초 로드 시 즉시 표시 |
| **texts 분리** | 목록 응답 경량화 (~500KB), 상세 진입 시에만 마크다운 로드 |
| **_spot 상태 변수** | widget.spot은 immutable, API 응답으로 texts가 추가된 새 spot을 반영 |

### ToT — 대안 비교

| 분기 | 선택 | 대안 (미선택) | 이유 |
|------|------|-------------|------|
| 목록 로드 | 전체 로드 (B) | 서버 페이징 (A) | 1,045개 규모에서 전체 로드가 더 단순 |
| 식별자 | 배열 index | slug id 필드 | 추가 필드 불필요, 향후 도입 검토 |
| 캐싱 | 단일 FileCache | 목록/상세 분리 캐시 | 목록만 캐싱, 상세는 매번 API 호출로 단순화 |
| 번들 | 유지 | 제거 | 오프라인 UX > 앱 크기 절약 |

### JSON 키 호환성 결정

원본 JSON의 키 형식(`"english name"` 공백, `"imageUrl"` camelCase)과
v7 API의 키 형식(`"english_name"` snake_case, `"image_url"` snake_case)이 다를 수 있으므로,
`TravelSpot.fromJson()`에서 **양쪽 모두 지원**:

```dart
englishName: (json['english name'] ?? json['english_name']) as String? ?? '',
imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
```

> **현재 v7 API는 원본 JSON 키를 그대로 전달** (`"english name"` 공백 포함)
> 향후 서버에서 키를 정규화할 경우에도 앱이 깨지지 않음
