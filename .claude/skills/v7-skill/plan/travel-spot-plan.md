# 여행 명소 웹/앱 공유 시스템 설계 계획서

## CoT (Chain-of-Thought) 분석

### 1단계: 문제의 핵심 이해

**목표**: 필고 앱(Flutter)의 여행 명소 데이터를 필고 홈페이지(v7 웹)와 공유하여,
동일한 콘텐츠를 웹과 앱 모두에서 표시한다.

**핵심 제약 조건**:
- AI가 여행 콘텐츠를 생성/수정/삭제 → **JSON 파일이 Source of Truth**
- 여행 명소는 **1천 개 내외** → DB 불필요, JSON 파일 기반 충분
- 앱 전면 수정 가능 → 기존 TravelSpotService 완전 리팩터링 허용
- v7 시스템 패턴(Controller/Service) 준수 필수

**데이터 저장 경로 규칙**:
- 필고 홈페이지의 `./data/` 폴더 하위에 모든 JSON 및 관련 정보 저장
- 서버 절대 경로: `/Users/thruthesky/apps/withcenter/philgo/www/data/`
- `data/README.md`에 명시: "웹과 앱에서 같이 사용하는 홈페이지 앱 정보"
- 여행 명소 JSON 경로: `www/data/travel/travel_spots.json`

**현재 상태 분석**:

| 구성요소 | 현재 | 비고 |
|---------|------|------|
| 데이터 소스 | `travel_spots.json` (CDN + 번들) | AI 스크립트로 관리 중 |
| 앱 서비스 | `TravelSpotService` (싱글톤, 12분 캐시) | JSON 전체 로드 → 클라이언트 검색/필터 |
| 앱 목록 화면 | `TravelSpotsScreen` (CustomScrollView + 전체 목록) | 메모리에 전체 데이터 보관 |
| 앱 상세 화면 | `TravelSpotViewScreen` (마크다운 렌더링) | 목록에서 전달받은 객체 사용 |
| 웹 표시 | **없음** | 신규 개발 필요 |
| v7 API | **없음** | 신규 개발 필요 |

---

### 2단계: 해결 방안 수립

**아키텍처 결정: JSON 파일 기반 v7 API**

```
AI (콘텐츠 생성/수정/삭제)
    │
    ▼
www/data/travel/travel_spots.json  ← Single Source of Truth
    │
    ├── v7 TravelController (PHP)
    │   ├── travel.list → JSON 파일 로드 → 필터/검색/페이징 → 응답
    │   ├── travel.get  → JSON 파일 로드 → 개별 명소 → 응답
    │   └── travel.filters → 필터 옵션 목록 → 응답
    │
    ├── 웹 페이지 (PHP + Vue.js)
    │   ├── travel/index.php → 목록 (SEO 서버 렌더링)
    │   └── travel/view.php  → 상세 (SEO 서버 렌더링)
    │
    └── Flutter 앱
        ├── TravelApi (v7 API 래퍼)
        ├── TravelSpotService (v7 API 기반 리팩터링)
        ├── TravelSpotsScreen (서버 사이드 검색/필터)
        └── TravelSpotViewScreen (API 상세 호출)
```

**핵심 결정 사항**:

| 결정 | 선택 | 근거 |
|------|------|------|
| 데이터 저장 | JSON 파일 | AI 관리, Git 버전 관리, 1천 개 규모 |
| API 계층 | v7 TravelController | 웹/앱 공통 API, SEO 지원, 서버사이드 필터 |
| DB 사용 | **안 함** | 1천 개 내외, AI 관리, 불필요한 복잡성 제거 |
| 앱 데이터 로드 | v7 API 호출 | 웹과 동일한 API, texts 분리 로드 가능 |
| 캐싱 전략 | FileCache (3일 TTL) | 여행 정보 변경 빈도 낮음, 장기 캐시 적합 |

---

### 3단계: 상세 구현 계획

#### 3.1 v7 PHP 백엔드

##### 3.1.1 파일 구조

```
www/lib/travel/
├── TravelController.php    ← API 엔드포인트
└── TravelService.php       ← JSON 로드 + 필터/검색 비즈니스 로직
```

> Repository/Entity 불필요: DB를 사용하지 않으므로 JSON 배열을 직접 다룸

##### 3.1.2 composer.json PSR-4 매핑 추가

```json
"Philgo\\Travel\\": "lib/travel/"
```

##### 3.1.3 TravelController.php

```php
namespace Philgo\Travel;

class TravelController
{
    /**
     * 여행 명소 목록 조회 (공개 API)
     *
     * GET api.php?method=travel.list&province=세부&category=폭포&search=가와산&page=1&limit=50
     *
     * 응답에서 texts 필드 제외 (목록 경량화)
     */
    public function list(array $input): array

    /**
     * 여행 명소 상세 조회 (공개 API)
     *
     * GET api.php?method=travel.get&index=42
     *
     * texts 필드 포함 (마크다운 상세 콘텐츠)
     */
    public function get(array $input): array

    /**
     * 필터 옵션 목록 조회 (공개 API)
     *
     * GET api.php?method=travel.filters
     *
     * province, city, category 고유값 목록 반환
     */
    public function filters(array $input): array
}
```

##### 3.1.4 TravelService.php

```php
namespace Philgo\Travel;

class TravelService
{
    // JSON 파일 경로 (www/data/ 폴더 하위)
    private static string $jsonPath = __DIR__ . '/../../data/travel/travel_spots.json';

    // 메모리 캐시 (동일 요청 내 재사용)
    private static ?array $spotsCache = null;

    /**
     * JSON 파일 로드 (메모리 캐시 적용)
     */
    public static function loadAllSpots(): array

    /**
     * 목록 조회 (필터/검색/페이징, texts 제외)
     *
     * @param string|null $province 주(Province) 필터
     * @param string|null $city 도시(City) 필터
     * @param string|null $category 분류(Category) 필터
     * @param string|null $search 검색어 (name, english_name, title, description, city, province, category)
     * @param int $page 페이지 번호 (1부터)
     * @param int $limit 페이지당 항목 수
     * @return array {items: [...], pagination: {page, limit, total}}
     */
    public static function list(
        ?string $province = null,
        ?string $city = null,
        ?string $category = null,
        ?string $search = null,
        int $page = 1,
        int $limit = 50
    ): array

    /**
     * 단건 조회 (texts 포함)
     *
     * @param int $index JSON 배열 인덱스
     * @return array 여행 명소 전체 데이터
     */
    public static function get(int $index): array

    /**
     * 필터 옵션 목록
     *
     * @return array {provinces: [...], cities: [...], categories: [...]}
     */
    public static function filters(): array
}
```

##### 3.1.5 API 응답 형식

**travel.list 응답** (texts 제외, 경량화):
```json
{
    "items": [
        {
            "index": 0,
            "name": "가와산 폭포",
            "english_name": "Kawasan Falls",
            "title": "세부의 캐녀닝 명소",
            "description": "맑고 신비로운 옥색...",
            "city": "바디안",
            "province": "세부",
            "icon": "💧",
            "category": "폭포",
            "image_url": "https://...",
            "has_texts": true
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 50,
        "total": 523,
        "total_pages": 11
    }
}
```

**travel.get 응답** (texts 포함):
```json
{
    "index": 0,
    "name": "가와산 폭포",
    "english_name": "Kawasan Falls",
    "title": "세부의 캐녀닝 명소",
    "description": "맑고 신비로운 옥색...",
    "city": "바디안",
    "province": "세부",
    "icon": "💧",
    "category": "폭포",
    "image_url": "https://...",
    "texts": [
        "# 💧 가와산 폭포 (Kawasan Falls)\n\n## 📌 한눈에 보기...",
        "## ✨ 핵심 포인트...",
        "## 📚 추가 정보...",
        "## 🗺️ 방문 정보...",
        "## 💡 추천 포인트..."
    ]
}
```

**travel.filters 응답**:
```json
{
    "provinces": ["네그로스 옥시덴탈", "네그로스 오리엔탈", "보홀", "세부", ...],
    "cities": ["바디안", "코르도바", "오슬롭", ...],
    "categories": ["해변/섬", "폭포", "동굴", "산/화산", "꽃 정원", ...]
}
```

##### 3.1.6 JSON 식별자 설계

> **index (JSON 배열 인덱스)**를 식별자로 사용한다.
> DB의 auto_increment idx 대신, JSON 배열에서의 위치(index)를 사용한다.
>
> **이유**:
> - DB를 사용하지 않으므로 별도 ID 컬럼이 없음
> - JSON 배열 인덱스가 자연스러운 식별자
> - AI가 JSON 편집 시 순서가 변경될 수 있으므로, name을 보조 식별자로 활용
>
> **주의사항**:
> - AI가 JSON에 항목을 추가/삭제하면 index가 변경될 수 있음
> - 상세 화면 딥링크 시 name 기반 검색을 병행하여 안정성 확보
> - 또는 JSON에 `id` 필드를 추가하여 영구 식별자 도입 검토

---

#### 3.2 Flutter 앱 수정

##### 3.2.1 파일 구조 (변경/신규)

```
lib/v7_api/
└── travel_api.dart                    ← [신규] v7 Travel API 래퍼

lib/models/
└── travel_spot.model.dart             ← [수정] index 필드 추가, has_texts 추가

lib/services/travel/
└── travel_spot.service.dart           ← [수정] v7 API 기반으로 리팩터링

lib/screens/guide/
├── travel_spots.screen.dart           ← [수정] 서버 사이드 검색/필터/페이징
└── travel_spot.view.screen.dart       ← [수정] API 상세 호출 추가
```

##### 3.2.2 travel_api.dart (신규)

```dart
/// v7 Travel API 래퍼 클래스
///
/// v7 API를 통해 여행 명소 데이터를 조회합니다.
/// TravelSpotService에서 사용되며, 캐싱은 Service 레이어에서 처리합니다.
class TravelApi {
    /// 여행 명소 목록 조회 (texts 제외)
    static Future<Map<String, dynamic>> list({
        String? province,
        String? city,
        String? category,
        String? search,
        int page = 1,
        int limit = 50,
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

    /// 여행 명소 상세 조회 (texts 포함)
    static Future<Map<String, dynamic>> get({required int index}) async {
        return await v7api('travel.get', data: {'index': index});
    }

    /// 필터 옵션 목록 조회
    static Future<Map<String, dynamic>> filters() async {
        return await v7api('travel.filters');
    }
}
```

##### 3.2.3 TravelSpot 모델 수정

```dart
class TravelSpot {
    /// JSON 배열 인덱스 (v7 API 식별자)
    final int index;

    /// 상세 텍스트 존재 여부 (목록에서 사용)
    final bool hasTextsFlag;

    // ... 기존 필드 유지

    factory TravelSpot.fromJson(Map<String, dynamic> json) {
        return TravelSpot(
            index: json['index'] as int? ?? 0,
            hasTextsFlag: json['has_texts'] as bool? ?? false,
            // ... 기존 파싱 유지
        );
    }
}
```

##### 3.2.4 TravelSpotService 리팩터링

```dart
class TravelSpotService {
    static TravelSpotService? _instance;
    static TravelSpotService get instance => _instance ??= TravelSpotService._();
    TravelSpotService._();

    /// 3일 캐시 TTL (여행 정보는 변경 빈도가 낮으므로 장기 캐시 적용)
    static const Duration cacheTtl = Duration(days: 3);

    /// 목록 캐시 (검색/필터 조건별)
    late final FileCache<TravelSpotsListResponse> _listCache = FileCache(
        cacheName: 'travel_spots_list',
        defaultTtl: cacheTtl,
        fromJson: TravelSpotsListResponse.fromJson,
        toJson: (data) => data.toJson(),
        useMemoryCache: true,
    );

    /// 상세 캐시 (index별)
    late final FileCache<TravelSpotDetailResponse> _detailCache = FileCache(
        cacheName: 'travel_spots_detail',
        defaultTtl: cacheTtl,
        fromJson: TravelSpotDetailResponse.fromJson,
        toJson: (data) => data.toJson(),
        useMemoryCache: true,
    );

    /// 필터 옵션 캐시
    late final FileCache<TravelFiltersResponse> _filtersCache = FileCache(
        cacheName: 'travel_spots_filters',
        defaultTtl: cacheTtl,
        fromJson: TravelFiltersResponse.fromJson,
        toJson: (data) => data.toJson(),
        useMemoryCache: true,
    );

    /// 목록 조회 (서버 사이드 필터/검색/페이징)
    Future<TravelSpotsListResponse> listSpots({
        String? province,
        String? city,
        String? category,
        String? search,
        int page = 1,
        int limit = 50,
    }) async {
        final cacheKey = 'list_${province ?? ''}_${city ?? ''}_${category ?? ''}_${search ?? ''}_${page}_$limit';

        // 1. 캐시 확인
        final cached = await _listCache.get(cacheKey);
        if (cached != null) return cached;

        // 2. v7 API 호출
        final result = await TravelApi.list(
            province: province, city: city,
            category: category, search: search,
            page: page, limit: limit,
        );

        final response = TravelSpotsListResponse.fromJson(result);
        await _listCache.set(cacheKey, response);
        return response;
    }

    /// 상세 조회 (texts 포함)
    Future<TravelSpot> getSpot(int index) async {
        final cacheKey = 'detail_$index';

        final cached = await _detailCache.get(cacheKey);
        if (cached != null) return cached.spot;

        final result = await TravelApi.get(index: index);
        final spot = TravelSpot.fromJson(result);

        await _detailCache.set(cacheKey, TravelSpotDetailResponse(spot: spot));
        return spot;
    }

    /// 필터 옵션 조회
    Future<TravelFiltersResponse> getFilters() async {
        final cacheKey = 'filters';

        final cached = await _filtersCache.get(cacheKey);
        if (cached != null) return cached;

        final result = await TravelApi.filters();
        final response = TravelFiltersResponse.fromJson(result);
        await _filtersCache.set(cacheKey, response);
        return response;
    }

    /// 캐시 전체 초기화
    Future<void> clearCache() async {
        await _listCache.clear();
        await _detailCache.clear();
        await _filtersCache.clear();
    }
}
```

##### 3.2.5 TravelSpotsScreen 핵심 변경

**기존 → 변경 비교**:

| 기능 | 기존 (JSON 전체 로드) | 변경 (v7 API) |
|------|---------------------|--------------|
| 초기 로드 | `loadTravelSpots()` → 전체 JSON | `listSpots(page: 1)` → 1페이지 |
| 검색 | 클라이언트 `matchesSearch()` | `listSpots(search: 키워드)` + 디바운스 |
| 필터 | 클라이언트 `where()` | `listSpots(province: ..., city: ...)` |
| 필터 옵션 | `_allSpots`에서 추출 | `getFilters()` API |
| 스크롤 | 전체 리스트 | **무한 스크롤** (페이징) |
| 정렬 | `spots.sort()` 클라이언트 | 서버에서 정렬 완료 |
| 상세 이동 | `TravelSpot` 객체 전달 | `index` 전달 → 상세 API 호출 |

**핵심 변경 사항**:

1. **디바운스 검색**: 검색어 입력 후 300ms 대기 → API 호출
2. **무한 스크롤**: `ScrollController`로 하단 감지 → 다음 페이지 로드
3. **필터 드롭다운**: `travel.filters` API에서 옵션 로드
4. **로딩 상태**: 페이지 로드 중 하단 스피너 표시
5. **Hero 애니메이션 유지**: 기존 `travel-spot-{name}` 태그 패턴 유지

##### 3.2.6 TravelSpotViewScreen 핵심 변경

**기존**: 목록에서 전달받은 `TravelSpot` 객체 (texts 포함)를 바로 표시
**변경**: 목록에서 전달받은 `TravelSpot` 객체 (texts 미포함) → `travel.get` API로 texts 로드

```dart
// 기존: extra로 전체 객체 전달
static Future<void> push = (ctx, spot) => ctx.push(routeName, extra: spot);

// 변경: index 전달 → 상세 API 호출
static Future<void> push = (ctx, TravelSpot spot) => ctx.push(routeName, extra: spot);

// 상세 화면 initState에서:
// 1. spot.hasTexts == true → texts 이미 있음 (캐시 히트)
// 2. spot.hasTexts == false → travel.get API 호출하여 texts 로드
```

**UX 최적화**:
- 기본 정보(이름, 이미지, 카테고리 등)는 목록에서 받은 데이터로 **즉시 표시**
- texts(마크다운 콘텐츠)만 API에서 비동기 로드
- 로딩 중 shimmer 또는 스피너 표시

---

#### 3.3 웹 프론트엔드

##### 3.3.1 파일 구조

```
www/travel/
├── index.php          ← 여행 명소 목록 (SEO 서버 렌더링 + Vue.js 인터랙션)
└── view.php           ← 여행 명소 상세 (SEO 서버 렌더링 + 마크다운)
```

##### 3.3.2 SEO 전략

- `index.php`: PHP에서 `TravelService::list()` 직접 호출 → HTML 서버 렌더링
- `view.php`: PHP에서 `TravelService::get()` 직접 호출 → HTML 서버 렌더링
- 검색엔진이 크롤링할 수 있는 완전한 HTML 제공
- JavaScript 비활성화 시에도 콘텐츠 표시

##### 3.3.3 클라이언트 인터랙션

- Vue.js CDN으로 검색/필터 동적 UI 제공
- 필터 변경 시 `travel.list` API 호출 → 목록 동적 업데이트
- 또는 URL 파라미터 변경 → 서버 렌더링 (SEO 우선)

---

#### 3.4 PEST 테스트

```
tests/Unit/TravelControllerTest.php
├── test: travel.list 기본 조회
├── test: travel.list province 필터
├── test: travel.list city 필터
├── test: travel.list category 필터
├── test: travel.list search 검색
├── test: travel.list 페이징
├── test: travel.list texts 미포함 확인
├── test: travel.get index로 조회
├── test: travel.get texts 포함 확인
├── test: travel.get 잘못된 index → 에러
└── test: travel.filters 목록 반환
```

---

## ToT (Tree-of-Thought) 분석

### 분기 1: JSON 식별자 전략

```
JSON 식별자 선택
├─ [A] 배열 인덱스 (index)
│   ├── 장점: 추가 필드 불필요, 자연스러운 식별
│   ├── 단점: AI 편집 시 인덱스 변경 가능
│   └── 대안: name 기반 보조 검색으로 안정성 확보
│
├─ [B] name 필드 (문자열 식별자)
│   ├── 장점: AI 편집에 안정적, 의미 있는 식별자
│   ├── 단점: 한글 URL 인코딩 문제, 중복 가능성
│   └── 대안: english_name 사용 고려
│
└─ [C] 별도 id 필드 추가 (영구 식별자)  ← ★ 권장
    ├── 장점: AI 편집에 완전 안정, 딥링크 친화적
    ├── 단점: JSON에 id 필드 추가 필요
    └── 구현: slug 형태 (예: "kawasan-falls", "10000-roses-cafe")

→ 결론: [C] slug 기반 id 필드 추가 권장
   - AI가 콘텐츠 생성 시 english_name에서 자동 생성
   - 웹 URL: /travel/kawasan-falls (SEO 친화적)
   - 앱 딥링크: philgo://travel/kawasan-falls
   - JSON 편집(추가/삭제/순서변경)에 영향 없음
```

### 분기 2: 앱 목록 로드 전략

```
앱 목록 데이터 로드 방식
├─ [A] v7 API 페이징 (서버 사이드)  ← ★ 권장
│   ├── 장점: texts 제외로 경량, 서버 검색/필터
│   ├── 단점: 네트워크 의존, 오프라인 불가
│   └── 대안: 이전 캐시로 오프라인 폴백
│
├─ [B] v7 API 전체 로드 (texts 제외)
│   ├── 장점: 클라이언트 검색/필터 유지, 1회 호출
│   ├── 단점: 1천 개 × ~500B = ~500KB (충분히 작음)
│   └── 고려: 현재 방식과 유사하되 texts만 분리
│
└─ [C] 하이브리드 (초기 전체 로드 + 상세만 API)
    ├── 장점: 기존 UX 유지 + texts 분리 이점
    ├── 단점: 앱 코드 변경 최소화
    └── 구현: list API로 전체 로드 (limit=9999) + get API로 상세

→ 결론: [B] 또는 [C] 권장
   - 1천 개 × texts 제외 = ~500KB → 1회 전체 로드 충분
   - 기존 클라이언트 검색/필터 UX 유지 가능
   - 상세 화면에서만 travel.get API로 texts 로드
   - 무한 스크롤보다 기존 전체 목록 방식이 UX 우수
```

### 분기 3: 웹 렌더링 전략

```
웹 렌더링 방식
├─ [A] PHP 서버 렌더링 + Vue.js 인터랙션  ← ★ 권장
│   ├── 장점: SEO 완벽, 초기 로드 빠름, 동적 필터
│   └── 구현: PHP로 초기 HTML + Vue.js로 필터/검색
│
├─ [B] 순수 PHP 서버 렌더링 (MPA)
│   ├── 장점: JavaScript 불필요, SEO 완벽
│   └── 단점: 필터 변경 시 페이지 새로고침
│
└─ [C] Vue.js SPA (클라이언트 렌더링)
    ├── 장점: 부드러운 UX
    └── 단점: SEO 불리, 초기 빈 페이지

→ 결론: [A] PHP 서버 렌더링 + Vue.js 인터랙션
```

### 분기 4: 캐싱 전략

```
캐싱 계층
├─ [서버 PHP]
│   ├── 메모리 캐시: 동일 요청 내 JSON 1회만 로드 (static 변수)
│   └── 파일 캐시: opcache 또는 APCu로 파싱된 JSON 배열 캐시 (선택)
│
├─ [앱 Flutter]
│   ├── 메모리 캐시: FileCache useMemoryCache: true
│   ├── 파일 캐시: FileCache (3일 TTL) — 여행 정보 변경 빈도 낮음
│   └── 번들 폴백: 제거 (v7 API 사용으로 불필요)
│       또는 유지: 최초 로드 시 번들 → 백그라운드 API 호출 (기존 패턴)
│
└─ [웹 브라우저]
    └── HTTP 캐시: Cache-Control 헤더 (5~10분)

→ 결론:
   - 서버: static 변수 메모리 캐시 (필수)
   - 앱: FileCache 3일 TTL (여행 정보 변경 빈도 낮아 장기 캐시 적합)
   - 앱 번들 폴백: 유지 (오프라인/최초 로드 지원)
   - 웹: 브라우저 HTTP 캐시
```

### 분기 5: 번들 JSON 유지 여부

```
앱 번들 JSON 전략
├─ [A] 번들 JSON 유지 (기존 패턴)  ← ★ 권장
│   ├── 장점: 오프라인 지원, 최초 로드 즉시 표시
│   ├── 구현: 기존 _loadFromBundle() 폴백 유지
│   └── 데이터 동기화: 앱 빌드 시 최신 JSON 번들에 포함
│
├─ [B] 번들 JSON 제거
│   ├── 장점: 앱 크기 감소, 코드 단순화
│   └── 단점: 오프라인 불가, 네트워크 필수
│
└─ [C] 번들은 목록만 유지 (texts 제외)
    ├── 장점: 앱 크기 절약 + 오프라인 목록 지원
    └── 구현: 별도 travel_spots_list.json 생성

→ 결론: [A] 번들 JSON 유지
   - 기존 번들 → 캐시 → 원격 3단계 폴백 전략 유지
   - 번들은 texts 포함 전체 데이터 유지 (오프라인 상세 보기 지원)
   - v7 API는 캐시 만료 시 또는 원격 갱신 시 사용
```

---

## 최종 구현 계획

### Phase 1: v7 PHP 백엔드 (서버)

| 순서 | 작업 | 파일 |
|------|------|------|
| 1-1 | composer.json에 `Philgo\Travel\` PSR-4 매핑 추가 | `composer.json` |
| 1-2 | `composer dump-autoload` 실행 | - |
| 1-3 | TravelService.php 작성 (JSON 로드, 필터, 검색, 페이징) | `lib/travel/TravelService.php` |
| 1-4 | TravelController.php 작성 (list, get, filters) | `lib/travel/TravelController.php` |
| 1-5 | PEST 테스트 작성 | `tests/Unit/TravelControllerTest.php` |
| 1-6 | curl 테스트 실행 및 검증 | - |

### Phase 2: JSON 데이터 준비

| 순서 | 작업 | 비고 |
|------|------|------|
| 2-1 | JSON에 `id` (slug) 필드 추가 검토 | 선택: english_name에서 자동 생성 |
| 2-2 | JSON 파일 서버 경로 설정 | TravelService에서 참조 |

### Phase 3: Flutter 앱 수정

| 순서 | 작업 | 파일 |
|------|------|------|
| 3-1 | `travel_api.dart` 신규 생성 | `lib/v7_api/travel_api.dart` |
| 3-2 | `TravelSpot` 모델에 index 필드 추가 | `lib/models/travel_spot.model.dart` |
| 3-3 | `TravelSpotService` v7 API 기반 리팩터링 | `lib/services/travel/travel_spot.service.dart` |
| 3-4 | `TravelSpotsScreen` 서버 검색/필터 전환 | `lib/screens/guide/travel_spots.screen.dart` |
| 3-5 | `TravelSpotViewScreen` API 상세 호출 추가 | `lib/screens/guide/travel_spot.view.screen.dart` |
| 3-6 | `flutter analyze` 실행 및 오류 수정 | - |

### Phase 4: 웹 프론트엔드

| 순서 | 작업 | 파일 |
|------|------|------|
| 4-1 | 여행 명소 목록 페이지 | `www/travel/index.php` |
| 4-2 | 여행 명소 상세 페이지 | `www/travel/view.php` |
| 4-3 | 마크다운 → HTML 렌더링 (PHP 라이브러리) | - |
| 4-4 | Vue.js 검색/필터 인터랙션 | - |

### Phase 5: v7-skill 레퍼런스 문서

| 순서 | 작업 | 파일 |
|------|------|------|
| 5-1 | Travel API 문서 작성 | `references/api/v7-travel.md` |
| 5-2 | Flutter Travel 앱 연동 문서 작성 | `references/app/v7-app-travel.md` |

---

## 리스크 및 대응

| 리스크 | 영향 | 대응 |
|--------|------|------|
| JSON 파일 로드 성능 (1천 개) | PHP 메모리 사용 ~5MB | static 변수 캐시, OPcache |
| AI 편집 시 데이터 불일치 | 캐시된 데이터와 실제 JSON 불일치 | 3일 TTL로 자동 갱신, 필요 시 수동 캐시 초기화 |
| 오프라인 사용 | API 호출 실패 | 번들 JSON 폴백 유지 |
| SEO 인덱싱 | 검색엔진 크롤링 | PHP 서버 렌더링 |
| JSON 식별자 안정성 | AI 편집으로 index 변경 | slug id 필드 도입 |

---

## 예상 작업량

| Phase | 예상 파일 수 | 비고 |
|-------|------------|------|
| Phase 1 (PHP) | 3개 (Controller, Service, Test) | v7 패턴 준수 |
| Phase 2 (JSON) | 1개 (선택적 id 추가) | AI 스크립트 수정 |
| Phase 3 (Flutter) | 5개 (API, 모델, 서비스, 화면 2개) | 기존 코드 리팩터링 |
| Phase 4 (웹) | 2~3개 (목록, 상세, 스타일) | 신규 개발 |
| Phase 5 (문서) | 2개 | 레퍼런스 문서 |
| **합계** | **13~14개** | |
