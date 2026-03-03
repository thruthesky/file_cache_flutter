# v7 Travel API — 여행 명소 공유 시스템

## 목차

1. [개요 및 CoT/ToT 분석](#1-개요-및-cottot-분석)
2. [아키텍처](#2-아키텍처)
3. [데이터 구조 — 인덱스 JSON + 마크다운 콘텐츠](#3-데이터-구조--인덱스-json--마크다운-콘텐츠)
4. [PHP 백엔드 (TravelController + TravelService)](#4-php-백엔드)
5. [API 엔드포인트 상세](#5-api-엔드포인트-상세)
6. [PEST 테스트](#6-pest-테스트)
7. [배포 체크리스트](#7-배포-체크리스트)
8. [테스트 검증 결과](#8-테스트-검증-결과)

---

## 1. 개요 및 CoT/ToT 분석

### CoT (Chain-of-Thought) — 문제 해결 흐름

```
문제 인식
  → 여행 명소 데이터가 앱(Flutter)에만 존재, 웹(홈페이지)에서 사용 불가
  → AI가 콘텐츠를 관리하는데, 단일 JSON(3.1MB, 19,032행)이 너무 커서 관리 곤란
  → DB 불필요 (1천 개 규모, AI 관리, Git 버전 관리)

핵심 결정
  → travel_index.json(목록 메타데이터) + content/{index}.md(상세 콘텐츠) 분리
  → 인덱스 JSON을 Single Source of Truth로 사용 (604KB, 81% 경량화)
  → 마크다운 파일은 AI가 개별 편집 가능 (추가/수정/삭제 용이)
  → v7 TravelController가 인덱스 JSON + 마크다운을 읽어 앱과 웹에 동일 API 제공

해결 전략
  → 목록(list)은 인덱스 JSON만 로드 — texts 불필요
  → 상세(get)는 인덱스 JSON + 해당 마크다운 파일 읽기
  → 서버: PHP static 변수로 동일 요청 내 1회만 인덱스 로드
  → 앱: FileCache 3일 TTL + 번들 JSON 오프라인 폴백
```

### ToT (Tree-of-Thought) — 핵심 분기 결정

| 분기 | 선택 | 근거 |
|------|------|------|
| 데이터 저장 | 인덱스 JSON + 마크다운 파일 (DB 미사용) | AI 관리 용이, 개별 파일 편집 가능, Git 버전 관리 |
| 파일 분리 | texts만 분리 → `content/{index}.md` | 목록 JSON 81% 경량화, 마크다운 개별 관리 |
| 식별자 | JSON 배열 `index` | 추가 필드 불필요, 파일명과 일치 |
| 마크다운 구분자 | `\n\n---\n\n` | texts 배열 ↔ 마크다운 상호 변환 용이 |
| 앱 목록 로드 | 전체 로드 (`limit=9999`, texts 제외) | 604KB 경량 데이터, 기존 클라이언트 검색/필터 UX 유지 |
| 캐싱 | 앱 3일 TTL / 서버 static 메모리 | 여행 정보 변경 빈도 낮음 |
| 원본 JSON | `travel_spots.json` 보관 (백업/레퍼런스) | 데이터 무결성 검증, 앱 번들 폴백 |

---

## 2. 아키텍처

```
AI (콘텐츠 생성/수정/삭제)
    │
    ├── www/data/travel/travel_index.json   ← 목록 메타데이터 (604KB)
    ├── www/data/travel/content/{index}.md  ← 개별 마크다운 콘텐츠
    │
    ├── v7 TravelController (PHP) ← 인증 불필요 (공개 API)
    │   ├── travel.list   → 인덱스 JSON만 사용, texts 제외
    │   ├── travel.get    → 인덱스 JSON + 마크다운 파일 → texts + content 반환
    │   └── travel.filters → 인덱스 JSON에서 고유값 추출
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
│   ├── travel_index.json         ← 목록용 인덱스 (texts 제외, 604KB)
│   ├── content/
│   │   ├── 0.md                  ← 여행 명소 #0 마크다운
│   │   ├── 1.md                  ← 여행 명소 #1 마크다운
│   │   ├── ...
│   │   └── 1044.md               ← 여행 명소 #1044 마크다운
│   ├── travel_spots.json         ← 원본 JSON (백업/레퍼런스, 3.1MB)
│   ├── images/                   ← 이미지 파일
│   └── split_travel_data.php     ← 분리 스크립트 (1회성)
├── lib/travel/
│   ├── TravelController.php      ← API 엔드포인트 (Philgo\Travel)
│   └── TravelService.php         ← 인덱스 로드 + 마크다운 로드 + 비즈니스 로직
├── tests/Unit/
│   └── TravelControllerTest.php  ← PEST v4 테스트 (32개)
└── composer.json                 ← PSR-4: "Philgo\\Travel\\": "lib/travel/"
```

---

## 3. 데이터 구조 — 인덱스 JSON + 마크다운 콘텐츠

### 3.1 파일 경로

| 항목 | 값 |
|------|-----|
| **인덱스 JSON** | `www/data/travel/travel_index.json` (604KB) |
| **마크다운 콘텐츠** | `www/data/travel/content/{index}.md` (1,045개 파일) |
| 원본 JSON (Source of Truth) | `www/data/travel/travel_spots.json` (3.1MB) |
| 앱 번들 | Flutter 앱 내 `lib/philgo_files/travel/travel_spots.json` (오프라인 폴백) |
| 콘텐츠 관리 스킬 | `.claude/skills/philgo-content/` (여행 콘텐츠 생성/보강 가이드) |
| 항목 수 | 1,045개 (2026-03-03 기준) |

### 3.2 인덱스 JSON 구조 (travel_index.json)

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
    "imageUrl": "https://cdn.example.com/kawasan.jpg"
  }
]
```

> **주의**: 인덱스 JSON에는 `texts` 필드가 **포함되지 않는다**.

### 3.3 마크다운 콘텐츠 구조 (content/{index}.md)

각 마크다운 파일은 원본 JSON의 `texts` 배열을 `\n\n---\n\n` 구분자로 합친 것이다.

```markdown
# 💧 가와산 폭포 (Kawasan Falls)

## 📌 한눈에 보기
- 🏷️ 한 줄 소개: 세부의 캐녀닝 명소
...

---

## ✨ 핵심 포인트
- ✨ 가와산 폭포는 세부 섬 정글에 위치...

---

## 📚 추가 정보
...
```

### 3.4 필드 정의

| 필드 | 타입 | 필수 | 인덱스 JSON | 상세 API | 설명 |
|------|------|------|:-----------:|:--------:|------|
| `name` | string | ✅ | ✅ | ✅ | 한글 이름 |
| `english name` | string | ✅ | ✅ | ✅ | 영문 이름 (공백 포함 키) |
| `title` | string | ✅ | ✅ | ✅ | 제목/부제목 |
| `description` | string | ✅ | ✅ | ✅ | 간단 설명 |
| `city` | string | ✅ | ✅ | ✅ | 도시명 |
| `province` | string | ✅ | ✅ | ✅ | 지역/주 |
| `icon` | string | ✅ | ✅ | ✅ | 이모지 아이콘 |
| `category` | string | ✅ | ✅ | ✅ | 분류 (폭포, 해변, 동굴 등) |
| `imageUrl` | string | - | ✅ | ✅ | CDN 이미지 URL |
| `index` | int | - | ❌ | ✅ | API 응답에서 추가되는 배열 인덱스 |
| `has_texts` | bool | - | ❌ | ✅ | 마크다운 파일 존재 여부 |
| `texts` | string[] | - | ❌ | ✅ | 마크다운 섹션 배열 (get만) |
| `content` | string | - | ❌ | ✅ | 마크다운 원본 전체 (get만) |

### 3.5 데이터 관리 규칙

| 규칙 | 설명 |
|------|------|
| **Source of Truth** | `travel_index.json` + `content/*.md`가 운영 데이터 |
| **AI 관리** | AI가 인덱스 JSON과 마크다운 파일을 개별 관리 |
| **마크다운 개별 편집** | 특정 명소의 콘텐츠만 `content/{index}.md` 수정 |
| **명소 추가** | 인덱스 JSON에 항목 추가 + `content/{새index}.md` 생성 |
| **명소 삭제** | 인덱스 JSON에서 제거 + 해당 마크다운 파일 삭제 |
| **키 형식 주의** | `"english name"` (공백 포함) — 원본 키 형식 유지 |
| **index 식별자** | JSON 배열의 0-based 인덱스 = 마크다운 파일명 |
| **texts ↔ 마크다운** | `\n\n---\n\n` 구분자로 상호 변환 |

### 3.6 데이터 업데이트 흐름

```
콘텐츠 수정 시:
  1. content/{index}.md 파일 수정 (AI 또는 수동)
  2. 서버에서 즉시 반영 (TravelService는 매 요청마다 파일 로드)

목록 메타데이터 수정 시:
  1. travel_index.json 수정 (이름, 카테고리, 설명 등)
  2. 서버에서 즉시 반영

명소 추가 시:
  1. travel_index.json 배열 끝에 항목 추가
  2. content/{새index}.md 파일 생성
  3. (선택) travel_spots.json 동기화

앱 번들 동기화:
  1. travel_index.json → 앱 번들 복사 (빌드 시)
  2. 앱은 3일 캐시 만료 후 자동 갱신
```

### 3.7 분리 스크립트

`data/travel/split_travel_data.php`를 실행하면 `travel_spots.json`에서 분리한다.

```bash
php data/travel/split_travel_data.php
```

---

## 4. PHP 백엔드

### 4.1 TravelService.php

**위치**: `www/lib/travel/TravelService.php`
**네임스페이스**: `Philgo\Travel`

핵심 메서드:

| 메서드 | 역할 |
|--------|------|
| `loadAllSpots()` | `travel_index.json` 로드 + static 메모리 캐시 |
| `loadContent(int $index)` | `content/{index}.md` 파일 읽기 → 문자열 반환 |
| `markdownToTexts(string $md)` | 마크다운 → texts 배열 변환 (`---` 구분자) |
| `list()` | 필터/검색/페이징 (인덱스 JSON만 사용) |
| `get(int $index)` | 인덱스 + 마크다운 → texts + content 포함 반환 |
| `filters()` | province/city/category 고유값 목록 (가나다순 정렬) |
| `clearCache()` | 메모리 캐시 초기화 (테스트용) |

핵심 구현 포인트:

```php
/// 인덱스 JSON 경로 — www/data/travel/ 하위
private static string $indexPath = __DIR__ . '/../../data/travel/travel_index.json';

/// 마크다운 콘텐츠 폴더 경로
private static string $contentDir = __DIR__ . '/../../data/travel/content';

/// list() — 인덱스 JSON만 사용, has_texts는 마크다운 파일 존재 여부
$item['index'] = $index;
$item['has_texts'] = file_exists(self::$contentDir . '/' . $index . '.md');

/// get() — 인덱스 + 마크다운 로드
$markdown = self::loadContent($index);
$spot['texts'] = self::markdownToTexts($markdown);  // 앱 호환 배열
$spot['content'] = $markdown;                         // 웹 렌더링용 원본

/// markdownToTexts() — 마크다운 → texts 배열 변환
$sections = preg_split('/\n\n---\n\n/', $markdown);
```

### 4.2 TravelController.php

**위치**: `www/lib/travel/TravelController.php`
**네임스페이스**: `Philgo\Travel`
**인증**: 불필요 (공개 API)

| 액션 | URL | 설명 |
|------|-----|------|
| `list` | `api.php?method=travel.list` | 목록 조회 (인덱스 JSON만) |
| `get` | `api.php?method=travel.get&index=42` | 상세 조회 (texts + content 포함) |
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

> **주의**: 응답에 `texts`, `content` 필드가 **포함되지 않음** (목록 경량화)
> `has_texts` 플래그로 마크다운 콘텐츠 존재 여부 확인 가능

### 5.2 travel.get

**상세 조회** — texts + content 포함

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
    ],
    "content": "# 🌹 10000 장미 카페\n\n...\n\n---\n\n## ✨ 핵심 포인트\n\n...\n\n---\n\n## 📚 추가 정보\n\n..."
}
```

> **`texts`**: 마크다운 섹션 배열 — 기존 앱 호환 (`---` 구분자로 분리)
> **`content`**: 마크다운 원본 전체 문자열 — 웹에서 직접 렌더링용

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

### 테스트 항목 (32개)

| 카테고리 | 테스트 | 검증 |
|----------|--------|------|
| 인덱스 로드 | `loadAllSpots()` 로드 | travel_index.json 로드 성공 |
| 인덱스 로드 | texts 미포함 확인 | 인덱스에 texts 없음 |
| 인덱스 로드 | 필수 필드 존재 | name, english name 등 8개 |
| 마크다운 콘텐츠 | `loadContent()` 파일 읽기 | 마크다운 문자열 반환 |
| 마크다운 콘텐츠 | `loadContent()` 존재하지 않는 인덱스 | null 반환 |
| 마크다운 콘텐츠 | `markdownToTexts()` 변환 | 배열 반환, 1개 이상 |
| 마크다운 콘텐츠 | `markdownToTexts()` --- 구분자 분리 | 3개 섹션 정확 분리 |
| 마크다운 콘텐츠 | 원본 데이터와 일치 | texts 배열 개수 및 첫 줄 일치 |
| list() | 기본 조회 | items + pagination 구조 |
| list() | texts/content 미포함 | texts, content 없음, index/has_texts 있음 |
| list() | has_texts 마크다운 파일 반영 | 파일 존재 여부 = has_texts |
| list() | province 필터 | 세부 → 결과 검증 |
| list() | city 필터 | 바디안 → 결과 검증 |
| list() | category 필터 | 폭포 → 결과 검증 |
| list() | search 검색 | "가와산" → 가와산 폭포 포함 |
| list() | 페이징 | page1 ≠ page2 |
| list() | 빈 결과 | 존재하지 않는 필터 → 0건 |
| get() | index 조회 | index=0 → 정상 반환 |
| get() | texts 배열 포함 | texts 배열 존재, 1개 이상 |
| get() | content 마크다운 원본 | 마크다운 문자열, loadContent와 일치 |
| get() | 잘못된 index | -1, 999999 → RuntimeException |
| filters() | 옵션 목록 | provinces/cities/categories 존재 |
| filters() | 정렬 확인 | 가나다순 정렬 |
| Controller | list() 엔드포인트 | items + pagination |
| Controller | list() 필터 전달 | province + category 조합 |
| Controller | get() 엔드포인트 | name + texts + content + index |
| Controller | get() index 누락 | RuntimeException |
| Controller | filters() 엔드포인트 | provinces/cities/categories |
| 데이터 무결성 | 항목 수 일치 | index JSON = 원본 JSON |
| 데이터 무결성 | 마크다운 파일 전수 존재 | 1,045개 모두 존재 |
| 데이터 무결성 | name 필드 일치 | 인덱스와 원본 name 동일 |
| 데이터 무결성 | 마크다운 파일 비어있지 않음 | 10자 이상 |

---

## 7. 배포 체크리스트

### 신규 배포 시 필수 작업

```
□ 1. www/data/travel/ 폴더 생성
□ 2. travel_index.json 파일 배치
□ 3. www/data/travel/content/ 폴더 + 마크다운 파일 배치 (1,045개)
□ 4. lib/travel/TravelController.php 배포
□ 5. lib/travel/TravelService.php 배포
□ 6. composer.json PSR-4 매핑 확인 ("Philgo\\Travel\\": "lib/travel/")
□ 7. 서버에서 composer dump-autoload 실행  ← 🔴 필수
□ 8. curl 테스트: api.php?method=travel.list
□ 9. curl 테스트: api.php?method=travel.get&index=0
□ 10. curl 테스트: api.php?method=travel.filters
```

### 콘텐츠 업데이트 시

```
마크다운 수정 시:
□ 1. content/{index}.md 파일 수정
□ 2. 서버에서 즉시 반영 확인

목록 메타데이터 수정 시:
□ 1. travel_index.json 수정
□ 2. 서버에서 즉시 반영 확인

명소 추가 시:
□ 1. travel_index.json 배열에 항목 추가
□ 2. content/{새index}.md 파일 생성
□ 3. (선택) travel_spots.json 동기화

앱 번들 동기화 시:
□ 1. cp travel_index.json → flutter_app/lib/philgo_files/travel/
□ 2. (선택) 앱 캐시 강제 갱신: TravelSpotService.instance.clearCache()
```

### 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| "Controller 클래스를 찾을 수 없습니다" | `composer dump-autoload` 미실행 | 서버에서 `composer dump-autoload` 실행 |
| 인덱스 JSON 로드 실패 | 파일 경로 불일치 | `www/data/travel/travel_index.json` 존재 확인 |
| 상세 조회 시 texts 빈 배열 | 마크다운 파일 없음 | `www/data/travel/content/{index}.md` 존재 확인 |
| 검색 결과 없음 | `mb_string` 확장 미설치 | PHP `mbstring` 확장 설치 확인 |
| 앱에서 구 데이터 표시 | 3일 캐시 미만료 | `forceRefresh()` 또는 `clearCache()` 호출 |

---

## 8. 테스트 검증 결과

### 8.1 PEST 단위 테스트 (2026-03-03 기준)

**실행 명령**: `./vendor/bin/pest tests/Unit/TravelControllerTest.php`

| 결과 | 값 |
|------|-----|
| **전체 테스트** | 32개 |
| **통과** | 32개 ✅ |
| **실패** | 0개 |
| **Assertion** | 201개 |
| **실행 시간** | 0.16s |

### 8.2 데이터 현황

| 항목 | 값 |
|------|-----|
| 전체 여행 명소 | 1,045건 |
| **인덱스 JSON** | **604KB** (travel_index.json) |
| 마크다운 파일 | 1,045개 (content/*.md) |
| 원본 JSON (백업) | 3.1MB (travel_spots.json) |
| **크기 절감** | **81.2%** (목록 응답 기준) |
| index 범위 | 0~1044 |
| texts 보유 항목 | 1,045건 (100%) |
