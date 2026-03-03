# v7 Travel API — 여행 명소 공유 시스템

## 목차

1. [개요 및 CoT/ToT 분석](#1-개요-및-cottot-분석)
2. [아키텍처](#2-아키텍처)
3. [JSON 데이터 관리](#3-json-데이터-관리)
4. [PHP 백엔드 (TravelController + TravelService)](#4-php-백엔드)
5. [API 엔드포인트 상세](#5-api-엔드포인트-상세)
6. [PEST 테스트](#6-pest-테스트)
7. [배포 체크리스트](#7-배포-체크리스트)

---

## 1. 개요 및 CoT/ToT 분석

### CoT (Chain-of-Thought) — 문제 해결 흐름

```
문제 인식
  → 여행 명소 데이터가 앱(Flutter)에만 존재, 웹(홈페이지)에서 사용 불가
  → AI가 JSON 파일로 콘텐츠 관리 중, DB 불필요 (1천 개 규모)

핵심 결정
  → JSON 파일을 Single Source of Truth로 유지
  → v7 TravelController가 JSON을 읽어 앱과 웹에 동일 API 제공
  → DB를 사용하지 않음 — JSON 파일 직접 파싱

해결 전략
  → texts(마크다운 상세 콘텐츠)를 목록/상세 분리하여 API 응답 경량화
  → 서버: PHP static 변수로 동일 요청 내 1회만 JSON 로드
  → 앱: FileCache 3일 TTL + 번들 JSON 오프라인 폴백
```

### ToT (Tree-of-Thought) — 핵심 분기 결정

| 분기 | 선택 | 근거 |
|------|------|------|
| 데이터 저장 | JSON 파일 (DB 미사용) | AI 관리, ~1천 개, Git 버전 관리 |
| 식별자 | JSON 배열 `index` | 추가 필드 불필요, 향후 slug `id` 도입 검토 |
| 앱 목록 로드 | 전체 로드 (`limit=9999`, texts 제외) | ~500KB, 기존 클라이언트 검색/필터 UX 유지 |
| 캐싱 | 앱 3일 TTL / 서버 static 메모리 | 여행 정보 변경 빈도 낮음 |
| 번들 JSON | 유지 (오프라인 폴백) | 네트워크 없이도 목록+상세 표시 |

> 상세 CoT/ToT 분석은 → [plan/travel-spot-plan.md](../../plan/travel-spot-plan.md) 참조

---

## 2. 아키텍처

```
AI (콘텐츠 생성/수정/삭제)
    │
    ▼
www/data/travel/travel_spots.json  ← Single Source of Truth
    │
    ├── v7 TravelController (PHP) ← 인증 불필요 (공개 API)
    │   ├── travel.list   → texts 제외, 필터/검색/페이징
    │   ├── travel.get    → texts 포함, 단건 상세
    │   └── travel.filters → province/city/category 고유값 목록
    │
    ├── Flutter 앱
    │   ├── TravelApi         → v7 API 래퍼 (lib/v7_api/travel_api.dart)
    │   ├── TravelSpotService → 3일 캐시 + 번들 폴백 (lib/services/travel/)
    │   └── TravelSpotViewScreen → 상세 진입 시 travel.get 호출
    │
    └── 웹 페이지 (향후)
        ├── travel/index.php → PHP에서 TravelService::list() 직접 호출 (SEO)
        └── travel/view.php  → PHP에서 TravelService::get() 직접 호출 (SEO)
```

### 파일 구조

```
www/
├── data/travel/
│   └── travel_spots.json          ← JSON 데이터 파일 (Source of Truth)
├── lib/travel/
│   ├── TravelController.php       ← API 엔드포인트 (Philgo\Travel)
│   └── TravelService.php          ← JSON 로드 + 비즈니스 로직
├── tests/Unit/
│   └── TravelControllerTest.php   ← PEST v4 테스트 (20개)
└── composer.json                  ← PSR-4: "Philgo\\Travel\\": "lib/travel/"
```

---

## 3. JSON 데이터 관리

### 3.1 파일 경로

| 항목 | 값 |
|------|-----|
| 서버 경로 | `www/data/travel/travel_spots.json` |
| PHP 참조 | `__DIR__ . '/../../data/travel/travel_spots.json'` (TravelService 기준) |
| 앱 번들 | `lib/philgo_files/travel/travel_spots.json` (Flutter assets) |
| 파일 크기 | ~3.2MB (약 19,000행) |
| 항목 수 | ~1,000개 |

### 3.2 JSON 구조

```json
[
  {
    "name": "가와산 폭포",
    "english name": "Kawasan Falls",
    "title": "세부의 캐녀닝 명소",
    "description": "맑고 신비로운 옥색 폭포...",
    "city": "바디안",
    "province": "세부",
    "icon": "💧",
    "category": "폭포",
    "imageUrl": "https://cdn.example.com/kawasan.jpg",
    "texts": [
      "# 💧 가와산 폭포\n\n## 📌 한눈에 보기...",
      "## ✨ 핵심 포인트...",
      "## 📚 추가 정보..."
    ]
  }
]
```

### 3.3 필드 정의

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `name` | string | ✅ | 한글 이름 |
| `english name` | string | ✅ | 영문 이름 (주의: 공백 포함 키) |
| `title` | string | ✅ | 제목/부제목 |
| `description` | string | ✅ | 간단 설명 |
| `city` | string | ✅ | 도시명 |
| `province` | string | ✅ | 지역/주 |
| `icon` | string | ✅ | 이모지 아이콘 |
| `category` | string | ✅ | 분류 (폭포, 해변, 동굴 등) |
| `imageUrl` | string | - | CDN 이미지 URL (선택) |
| `texts` | string[] | - | 마크다운 상세 콘텐츠 배열 (선택) |

### 3.4 JSON 관리 규칙

| 규칙 | 설명 |
|------|------|
| **Source of Truth** | `www/data/travel/travel_spots.json`이 유일한 원본 |
| **AI 관리** | AI 스크립트가 콘텐츠를 생성/수정/삭제 |
| **앱 번들 동기화** | 앱 빌드 시 서버 JSON을 `lib/philgo_files/travel/travel_spots.json`에 복사 |
| **키 형식 주의** | `"english name"` (공백 포함) — 원본 JSON의 키 형식 유지 |
| **texts 분리** | `travel.list`는 texts 제외, `travel.get`만 texts 포함 |
| **index 식별자** | JSON 배열의 0-based 인덱스를 식별자로 사용 |

### 3.5 JSON 업데이트 흐름

```
1. AI가 www/data/travel/travel_spots.json 수정
2. 서버에서 즉시 반영 (TravelService는 매 요청마다 JSON 로드)
3. 앱은 3일 캐시 만료 후 자동 갱신
4. 앱 빌드 시 최신 JSON을 번들에 복사 (수동)
```

### 3.6 앱 번들 동기화 명령

```bash
## 서버 JSON → 앱 번들 복사
cp www/data/travel/travel_spots.json \
   flutter_app/lib/philgo_files/travel/travel_spots.json
```

> 앱 빌드 전에 실행하여 최신 데이터를 번들에 포함시킨다.

---

## 4. PHP 백엔드

### 4.1 TravelService.php

**위치**: `www/lib/travel/TravelService.php`
**네임스페이스**: `Philgo\Travel`

핵심 메서드:

| 메서드 | 역할 |
|--------|------|
| `loadAllSpots()` | JSON 파일 로드 + static 메모리 캐시 |
| `list()` | 필터/검색/페이징 (texts 제외, index/has_texts 추가) |
| `get(int $index)` | 단건 조회 (texts 포함) |
| `filters()` | province/city/category 고유값 목록 (가나다순 정렬) |

핵심 구현 포인트:

```php
/// JSON 경로 — www/data/travel/ 하위
private static string $jsonPath = __DIR__ . '/../../data/travel/travel_spots.json';

/// 메모리 캐시 — 동일 PHP 요청 내 1회만 파일 로드
private static ?array $spotsCache = null;

/// list() — texts 제외, index/has_texts 추가
$item['index'] = $index;                    // 배열 인덱스 추가
$item['has_texts'] = isset($spot['texts']); // texts 존재 여부 플래그
unset($item['texts']);                      // texts 제거 (경량화)

/// 검색 — mb_strtolower/mb_strpos로 한글 지원
$lowerSearch = mb_strtolower($search);
$searchFields = [
    mb_strtolower($spot['name'] ?? ''),
    mb_strtolower($spot['english name'] ?? ''),
    // ... 7개 필드 검색
];
```

### 4.2 TravelController.php

**위치**: `www/lib/travel/TravelController.php`
**네임스페이스**: `Philgo\Travel`
**인증**: 불필요 (공개 API)

| 액션 | URL | 설명 |
|------|-----|------|
| `list` | `api.php?method=travel.list` | 목록 조회 (texts 제외) |
| `get` | `api.php?method=travel.get&index=42` | 상세 조회 (texts 포함) |
| `filters` | `api.php?method=travel.filters` | 필터 옵션 목록 |

### 4.3 PSR-4 매핑

`composer.json`에 추가:

```json
"Philgo\\Travel\\": "lib/travel/"
```

추가 후 반드시 실행:

```bash
composer dump-autoload
```

---

## 5. API 엔드포인트 상세

### 5.1 travel.list

**목록 조회** — texts 제외, 필터/검색/페이징 지원

```
GET api.php?method=travel.list
GET api.php?method=travel.list&province=세부&category=폭포&search=가와산&page=1&limit=50
```

**파라미터**:

| 이름 | 타입 | 필수 | 기본값 | 설명 |
|------|------|------|--------|------|
| `province` | string | - | - | 주(Province) 필터 |
| `city` | string | - | - | 도시(City) 필터 |
| `category` | string | - | - | 분류(Category) 필터 |
| `search` | string | - | - | 검색어 (7개 필드 검색) |
| `page` | int | - | 1 | 페이지 번호 |
| `limit` | int | - | 50 | 페이지당 항목 수 |

**응답**:

```json
{
    "items": [
        {
            "index": 0,
            "name": "가와산 폭포",
            "english name": "Kawasan Falls",
            "title": "세부의 캐녀닝 명소",
            "description": "맑고 신비로운 옥색...",
            "city": "바디안",
            "province": "세부",
            "icon": "💧",
            "category": "폭포",
            "imageUrl": "https://...",
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

> **주의**: 응답에 `texts` 필드가 **포함되지 않음** (목록 경량화)
> `has_texts` 플래그로 상세 콘텐츠 존재 여부 확인 가능

### 5.2 travel.get

**상세 조회** — texts 포함

```
GET api.php?method=travel.get&index=42
```

**파라미터**:

| 이름 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `index` | int | ✅ | JSON 배열 인덱스 |

**응답**:

```json
{
    "index": 42,
    "name": "10000 장미 카페",
    "english name": "10000 Roses Cafe",
    "title": "코르도바의 인스타 명소",
    "description": "...",
    "city": "코르도바",
    "province": "세부",
    "icon": "🌹",
    "category": "꽃 정원",
    "imageUrl": "https://...",
    "has_texts": true,
    "texts": [
        "# 🌹 10000 장미 카페\n\n...",
        "## ✨ 핵심 포인트\n\n...",
        "## 📚 추가 정보\n\n..."
    ]
}
```

**에러**:

| 조건 | 응답 |
|------|------|
| `index` 파라미터 누락 | `{"success": false, "message": "index 파라미터가 필요합니다."}` |
| 유효하지 않은 index | `{"success": false, "message": "유효하지 않은 인덱스입니다: -1"}` |

### 5.3 travel.filters

**필터 옵션 목록** — 드롭다운 UI용

```
GET api.php?method=travel.filters
```

**응답**:

```json
{
    "provinces": ["네그로스 옥시덴탈", "네그로스 오리엔탈", "보홀", "세부"],
    "cities": ["바디안", "코르도바", "오슬롭"],
    "categories": ["꽃 정원", "동굴", "산/화산", "해변/섬", "폭포"]
}
```

> 모든 값이 **가나다순 정렬**되어 반환됨

---

## 6. PEST 테스트

**파일**: `tests/Unit/TravelControllerTest.php`
**실행**: `./vendor/bin/pest tests/Unit/TravelControllerTest.php`

### 테스트 항목 (20개)

| 카테고리 | 테스트 | 검증 |
|----------|--------|------|
| TravelService | `loadAllSpots()` JSON 로드 | 배열, 1개 이상 |
| TravelService | 필수 필드 존재 | name, english name, title, description 등 8개 |
| TravelService | `list()` 기본 조회 | items + pagination 구조 |
| TravelService | `list()` texts 제외 확인 | texts 없음, index/has_texts 있음 |
| TravelService | `list()` province 필터 | 세부 필터 → 결과 검증 |
| TravelService | `list()` city 필터 | 바디안 필터 → 결과 검증 |
| TravelService | `list()` category 필터 | 폭포 필터 → 결과 검증 |
| TravelService | `list()` search 검색 | "가와산" → 가와산 폭포 포함 |
| TravelService | `list()` 페이징 | page1 ≠ page2 |
| TravelService | `list()` 빈 결과 | 존재하지 않는 필터 → 0건 |
| TravelService | `get()` index 조회 | index=0 → 정상 반환 |
| TravelService | `get()` texts 포함 | texts 배열 존재 |
| TravelService | `get()` 잘못된 index | -1, 999999 → RuntimeException |
| TravelService | `filters()` 옵션 목록 | provinces/cities/categories 존재 |
| TravelService | `filters()` 정렬 확인 | 가나다순 정렬 |
| TravelController | `list()` 엔드포인트 | items + pagination |
| TravelController | `list()` 필터 전달 | province + category 조합 |
| TravelController | `get()` 엔드포인트 | name + texts + index 포함 |
| TravelController | `get()` index 누락 | RuntimeException |
| TravelController | `filters()` 엔드포인트 | provinces/cities/categories |

---

## 7. 배포 체크리스트

### 신규 배포 시 필수 작업

```
□ 1. www/data/travel/ 폴더 생성
□ 2. travel_spots.json 파일 배치
□ 3. lib/travel/TravelController.php 배포
□ 4. lib/travel/TravelService.php 배포
□ 5. composer.json PSR-4 매핑 확인 ("Philgo\\Travel\\": "lib/travel/")
□ 6. 서버에서 composer dump-autoload 실행  ← 🔴 필수
□ 7. curl 테스트: api.php?method=travel.list
□ 8. curl 테스트: api.php?method=travel.get&index=0
□ 9. curl 테스트: api.php?method=travel.filters
```

### JSON 업데이트 시

```
□ 1. www/data/travel/travel_spots.json 교체
□ 2. 서버에서 즉시 반영 확인 (PHP는 매 요청마다 JSON 로드)
□ 3. (선택) 앱 번들 동기화: cp → lib/philgo_files/travel/travel_spots.json
□ 4. (선택) 앱 캐시 강제 갱신: TravelSpotService.instance.clearCache()
```

### 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| "Controller 클래스를 찾을 수 없습니다" | `composer dump-autoload` 미실행 | 서버에서 `composer dump-autoload` 실행 |
| JSON 파일 로드 실패 | 파일 경로 불일치 | `www/data/travel/travel_spots.json` 존재 확인 |
| 검색 결과 없음 | `mb_string` 확장 미설치 | PHP `mbstring` 확장 설치 확인 |
| 앱에서 구 데이터 표시 | 3일 캐시 미만료 | `forceRefresh()` 또는 `clearCache()` 호출 |
