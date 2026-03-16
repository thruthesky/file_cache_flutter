# v7 부동산 게시판 (real_estate)

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [목록 — Masonry 위젯](#3-목록--masonry-위젯)
4. [상세보기 — 부동산 정보 + 지도 위젯](#4-상세보기--부동산-정보--지도-위젯)
5. [글쓰기/수정 — 커스텀 필드 폼](#5-글쓰기수정--커스텀-필드-폼)
6. [커스텀 필드 매핑 (15개)](#6-커스텀-필드-매핑-15개)
7. [CSS (real-estate.css)](#7-css-real-estatecss)

---

## 1. 개요

부동산 게시판은 `buyandsell` 게시판의 `real_estate` 카테고리로 운영된다.
일반 게시글과 달리 매물 형태, 가격, 침실, 욕실, 면적, 주차, 거래 형태, 위치 정보 등
**15개 커스텀 필드**를 `sf_post_data` 테이블의 범용 컬럼(`varchar_*`, `int_*`, `char_*`, `region`)에 저장한다.

| 항목 | 내용 |
|------|------|
| **게시판 ID** | `buyandsell` |
| **카테고리** | `real_estate` |
| **목록 위젯** | `post-list-real-estate-masonry.php` (Masonry 레이아웃) |
| **상세보기 위젯** | `post-view-real-estate-info.php` (기본 정보/가격/위치 텍스트) + `post-view-real-estate-map.php` (Google Maps 지도) |
| **폼** | `post-form.js`의 `isRealEstate` computed 프로퍼티로 분기 |
| **CSS** | `v7/post/real-estate.css` (별도 파일) |
| **필드 상수** | `lib/post/post.fields.php`의 `RealEstateFields` 클래스 |
| **지역 데이터** | `etc/data/compact.locations.php`의 `COMPACT_LOCATIONS` 상수 |
| **지도 API** | Google Maps Embed API (`Config::googleMapsEmbeddingApiKey()`) |

---

## 2. 파일 구조

```
v7/
├── post/
│   ├── list.php                 ← $isRealEstateMasonry 조건으로 부동산 masonry 위젯 분기
│   ├── view.php                 ← post-view-default.php를 include (부동산 위젯은 default 내부에서 조건부 include)
│   ├── create.php               ← post-form.js 사용 (부동산 폼 포함)
│   ├── update.php               ← post-form.js 사용 (부동산 폼 포함)
│   └── real-estate.css          ← 부동산 전용 CSS (필터, masonry 오버레이, 상세 필드, 지도, 폼)
│
├── widgets/post/
│   ├── list/
│   │   └── post-list-real-estate-masonry.php  ← 부동산 전용 Masonry 목록 위젯
│   └── view/
│       ├── post-view-real-estate-info.php     ← 부동산 기본 정보/가격/위치 텍스트 위젯 (본문 앞)
│       ├── post-view-real-estate-map.php       ← 부동산 Google Maps 지도 위젯 (액션 버튼 앞)
│       └── post-view-real-estate.php          ← 기존 통합 위젯 (참고용, 현재 미사용)
│
├── js/
│   └── post-form.js             ← 부동산 커스텀 필드 15개 Vue.js data/computed/submit 로직
│
lib/post/
└── post.fields.php              ← RealEstateFields 상수 클래스 (DB 컬럼 매핑)
```

---

## 3. 목록 -- Masonry 위젯

### 파일

| 항목 | 내용 |
|------|------|
| **위젯 파일** | `v7/widgets/post/list/post-list-real-estate-masonry.php` |
| **CSS** | `v7/post/real-estate.css` (위젯 내부에서 `<link>` 로드) |
| **라이브러리** | `masonry.pkgd.min.js`, `imagesloaded.pkgd.min.js` |
| **호출 조건** | `list.php`에서 `$isRealEstateMasonry = ($category === 'real_estate')` |

### 분기 로직 (list.php)

```php
$isRealEstateMasonry = ($category === 'real_estate');

<?php if ($isRealEstateMasonry): ?>
    <?php include __DIR__ . '/../widgets/post/list/post-list-real-estate-masonry.php'; ?>
<?php elseif ($isMasonryLayout): ?>
    <?php include __DIR__ . '/../widgets/post/list/post-list-masonry.php'; ?>
<?php else: ?>
    <?php include __DIR__ . '/../widgets/post/list/post-list-widget.php'; ?>
<?php endif; ?>
```

### 필수 변수 (include 전 설정)

| 변수 | 타입 | 설명 |
|------|------|------|
| `$_wPosts` | `array` | 게시글 배열 (`PostService::list()['items']`) |
| `$_wPostId` | `string` | 게시판 ID (`'buyandsell'`) |
| `$_wCategory` | `string\|null` | 카테고리 (`'real_estate'`) |
| `$_wPage` | `int` | 현재 페이지 번호 |
| `$_wTotalPages` | `int` | 총 페이지 수 |
| `$_isAdmin` | `bool` | 관리자 여부 |
| `$_blockedMemberIds` | `array` | 차단된 회원 ID 배열 |
| `$_wPaginationUrlCallback` | `callable` | 페이지 번호 -> URL 변환 콜백 |

### 부동산 필터

위젯 상단에 2개 필터를 제공한다:

| 필터 | 파라미터 | 옵션 |
|------|----------|------|
| **지역** | `region` | `COMPACT_LOCATIONS` 상수 기반 |
| **판매 유형** | `char_1` | `R`=임대, `S`=매매, `E`=기타 |

필터 선택 시 `onchange="this.form.submit()"`으로 즉시 페이지 갱신된다.

### Masonry 카드 오버레이

| 오버레이 | 위치 | 표시 내용 |
|----------|------|----------|
| **상단 정보** (`.re-info-overlay`) | 이미지 상단 | 지역, 건물명, 침실 수 |
| **가격 배지** (`.re-price-badge`) | 이미지 좌측 하단 | 가격 (임대시 `/월` 표시) |
| **제목** (`.v7-masonry-overlay`) | 이미지 하단 그라디언트 | 제목, 작성자, 날짜, 조회수, 댓글수 |

### 썸네일 우선순위

1. `thumbnail_1000` > `thumbnail_800x800` > `thumbnail_400x400`
2. `varchar_17` (대표 이미지 URL) -> 썸네일 변환
3. `files` 필드에서 첫 이미지 추출 -> 썸네일 변환
4. `gid`로 v4 파일 테이블(`sf_data`) 일괄 조회 -> 썸네일 변환

---

## 4. 상세보기 -- 부동산 정보 + 지도 위젯

### 위젯 분리 구조

부동산 상세보기 위젯은 **2개 파일로 분리**되어 `post-view-default.php` 내부에서 조건부로 include된다.
기존에는 `view.php`에서 별도로 `post-view-real-estate.php`를 include하는 구조였으나,
현재는 `post-view-default.php` 내부에서 적절한 위치에 각각 삽입된다.

| 위젯 파일 | 역할 | 삽입 위치 |
|-----------|------|----------|
| `post-view-real-estate-info.php` | 기본 정보, 가격/공간, 위치 텍스트 (뱃지) | **글 헤더 뒤, 본문 앞** |
| `post-view-real-estate-map.php` | Google Maps 임베드 지도 | **첨부파일 뒤, 액션 버튼 앞** |
| `post-view-real-estate.php` | 기존 통합 위젯 (참고용, 현재 미사용) | - |

### 표시 순서

```
제목/작성자/날짜 (헤더)
    ↓
[부동산 기본 정보 — post-view-real-estate-info.php]
  - 매물 형태, 거래 형태, 매물 상태, 분양 형태 (뱃지)
  - 가격, 침실, 욕실, 면적, 주차, 준공 연도 (뱃지)
  - 위치 텍스트 (주소)
    ↓
글 본문 (content)
    ↓
첨부파일
    ↓
[Google Maps 지도 — post-view-real-estate-map.php]
    ↓
액션 버튼 (좋아요/수정/삭제/차단/목록)
```

### 파일

| 항목 | 내용 |
|------|------|
| **기본 정보 위젯** | `v7/widgets/post/view/post-view-real-estate-info.php` |
| **지도 위젯** | `v7/widgets/post/view/post-view-real-estate-map.php` |
| **CSS** | `v7/post/real-estate.css` |
| **호출 위치** | `post-view-default.php` 내부에서 조건부 include |

### 분기 로직 (post-view-default.php)

`view.php`에서 별도로 include하지 않고, `post-view-default.php` 내부에서 2곳에 조건부로 삽입된다:

```php
<!-- 글 헤더 뒤 -->
</header>

<!-- 부동산 기본 정보 (본문 앞에 표시) -->
<?php if ($post->category === 'real_estate'): ?>
    <?php include __DIR__ . '/post-view-real-estate-info.php'; ?>
<?php endif; ?>

<!-- 글 본문 -->
...

<!-- 부동산 지도 (액션 버튼 앞에 표시) -->
<?php if ($post->category === 'real_estate'): ?>
    <?php include __DIR__ . '/post-view-real-estate-map.php'; ?>
<?php endif; ?>

<!-- 액션 버튼 (좋아요/수정/삭제/차단/목록) -->
```

### 위젯 간 데이터 공유

`post-view-real-estate-info.php`에서 조합한 주소 배열을 `$GLOBALS['_reAddressParts']`에 저장하고,
`post-view-real-estate-map.php`에서 이 값을 읽어 Google Maps 지도를 렌더링한다.

```php
// post-view-real-estate-info.php 내부
$GLOBALS['_reAddressParts'] = $addressParts;

// post-view-real-estate-map.php 내부
$addressParts = $GLOBALS['_reAddressParts'] ?? [];
if (empty($addressParts)) return;
```

### 표시 그룹

위젯은 부동산 필드가 하나라도 존재할 때만 렌더링되며, 정보를 3개 그룹으로 나누어 표시한다:

#### post-view-real-estate-info.php (기본 정보 + 가격/공간 + 위치 텍스트)

| 그룹 | 표시 내용 | CSS 클래스 |
|------|----------|-----------|
| **기본 정보** | 매물 형태, 거래 형태, 매물 상태, 분양 형태 (뱃지) | `.re-detail-group`, `.re-badge-*` |
| **가격 및 공간** | 가격, 침실, 욕실, 면적, 주차, 준공 연도 (뱃지) | `.re-badge-danger`, `.re-badge-neutral` |
| **위치 텍스트** | 주소 텍스트 | `.re-address-text` |

#### post-view-real-estate-map.php (Google Maps 지도)

| 그룹 | 표시 내용 | CSS 클래스 |
|------|----------|-----------|
| **지도** | Google Maps 임베드 지도 | `.re-map-section`, `.re-map-container` |

### 뱃지 색상 체계

| 뱃지 | CSS 클래스 | 배경색 | 텍스트색 | 용도 |
|------|-----------|--------|---------|------|
| Primary | `.re-badge-primary` | `#eff6ff` | `#1e40af` | 매물 형태 |
| Success | `.re-badge-success` | `#f0fdf4` | `#166534` | 거래 형태 |
| Info | `.re-badge-info` | `#ecfeff` | `#155e75` | 매물 상태 |
| Warning | `.re-badge-warning` | `#fffbeb` | `#92400e` | 분양 형태 |
| Danger | `.re-badge-danger` | `#fef2f2` | `#991b1b` | 가격 |
| Neutral | `.re-badge-neutral` | `#f1f5f9` | `#334155` | 침실/욕실/면적/주차/준공 |

### 라벨 매핑

| 필드 | 코드 -> 한글 |
|------|------------|
| **매물 형태** (`varchar_1`) | `Condominum / Apartment`=콘도, `Office`=사무실, `Town House`=주택/빌리지, `Lot`=땅, `Others`=기타 |
| **거래 형태** (`char_1`) | `S`=매매, `R`=렌트, `W`=공유, `E`=기타 |
| **매물 상태** (`char_2`) | `N`=신축, `T`=임대중, `R`=리모델링 중, `E`=빈 공간, `O`=기타 |
| **분양 형태** (`char_3`) | `B`=사전 분양, `A`=준공 후 분양 |

### Google Maps 임베드

주소 부품이 2개 이상인 경우 Google Maps Embed API로 지도를 표시한다.

```php
$mapsApiKey = Config::googleMapsEmbeddingApiKey();
$mapUrl = "https://www.google.com/maps/embed/v1/place?key={$mapsApiKey}&q={$encodedAddress}&zoom=18&language=ko";
```

| 조건 | 동작 |
|------|------|
| 주소 부품 2개 이상 | Google Maps iframe 표시 (16:9 비율, `loading="lazy"`) |
| 주소 부품 0~1개 | "지도 정보가 없습니다" 플레이스홀더 |

---

## 5. 글쓰기/수정 -- 커스텀 필드 폼

### 파일

| 항목 | 내용 |
|------|------|
| **JS 파일** | `v7/js/post-form.js` |
| **CSS** | `v7/post/real-estate.css`의 `.re-form-*` 섹션 |
| **사용 페이지** | `v7/post/create.php`, `v7/post/update.php` |

### 분기 조건

`post-form.js`의 Vue.js computed 프로퍼티로 카테고리 판별:

```javascript
isRealEstate: function () {
    return this.category === 'real_estate';
}
```

`v-if="isRealEstate"`로 부동산 폼 섹션을 조건부 렌더링한다.

### 폼 레이아웃 (3개 섹션 카드)

폼은 3개의 카드 섹션으로 나뉘며, 각 카드는 `.re-form-section` 클래스로 구분된다.
전체를 `.re-form-wrapper`가 감싸고, 섹션 간 `gap: 0.75rem`으로 구분된다.

```
┌─────────────── 섹션 1: 매물 기본 정보 ────────────────┐
│  🏗 매물 기본 정보                                     │
│ ┌──────────────────┬──────────────────┐               │
│ │ 🏠 매물 형태 *    │ 🤝 거래 형태 *    │               │
│ ├──────────────────┼──────────────────┤               │
│ │ ⭐ 매물 상태 *    │ 📋 분양 형태      │               │
│ └──────────────────┴──────────────────┘               │
└───────────────────────────────────────────────────────┘

┌─────────────── 섹션 2: 가격 및 세부 정보 ──────────────┐
│  ₱ 가격 및 세부 정보                                   │
│ ┌─────────────────────────────────────┐               │
│ │ 💰 가격 * (full width)               │               │
│ ├──────────────────┬──────────────────┤               │
│ │ 🛏 침실 수 *      │ 🛁 욕실 수 *      │               │
│ ├──────────────────┼──────────────────┤               │
│ │ 📏 바닥 면적 *    │ 🚗 주차 공간 *    │               │
│ ├─────────────────────────────────────┤               │
│ │ 📅 준공 연도 (full width, select)    │               │
│ └─────────────────────────────────────┘               │
└───────────────────────────────────────────────────────┘

┌─────────────── 섹션 3: 위치 정보 ──────────────────────┐
│  📍 위치 정보                                          │
│ ┌─────────────────────────────────────┐               │
│ │ 📍 지역 * (full width, select)       │               │
│ │   힌트: 필리핀 주요 도시 및 지역      │               │
│ ├──────────────────┬──────────────────┤               │
│ │ 🏛 건물명 *       │ 🚪 호수/동 *      │               │
│ ├──────────────────┼──────────────────┤               │
│ │ 🛣 거리 *         │ 🏙 바랑가이 *      │               │
│ └──────────────────┴──────────────────┘               │
└───────────────────────────────────────────────────────┘
```

### 디자인 특징

| 항목 | 설명 |
|------|------|
| **3개 섹션 카드** | 매물 기본 정보, 가격 및 세부 정보, 위치 정보로 분리 |
| **섹션 배경** | `linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%)` 그라데이션 |
| **포커스 효과** | 섹션 내 입력 시 `:focus-within`으로 테두리 색상 변경 (`brand-300`) |
| **아이콘** | 각 필드 라벨에 Font Awesome Light 아이콘 표시 (`fa-light` 스타일) |
| **필수/선택 표시** | `*` 빨간색 표시 (`.re-required`) 또는 "선택 (생략 가능)" 플레이스홀더 |
| **select 드롭다운** | 커스텀 화살표 SVG, `appearance: none` |
| **number 스피너** | 숨김 처리 (깔끔한 디자인) |
| **2열 그리드** | `grid-template-columns: 1fr 1fr`, 모바일 640px 이하 1열 |
| **full width 필드** | 가격, 준공 연도, 지역은 `.re-form-full` 클래스로 전체 너비 |

### 지역(Region) 필드 -- COMPACT_LOCATIONS 기반 select

지역 필드는 기존 텍스트 입력에서 **COMPACT_LOCATIONS 상수 기반 `<select>` 드롭다운**으로 변경되었다.
Vue.js `data`의 `reLocationOptions` 객체에 43개 필리핀 주요 도시 목록이 정의되어 있다.

```javascript
reLocationOptions: {
    "Angeles City": "Angeles City (Pampanga) - 앙헬레스",
    "Makati City": "Makati City (Metropolitan Manila) - 마카티",
    "Cebu City": "Cebu City (Cebu) - 세부",
    // ... 총 43개 도시
}
```

- key: DB에 저장되는 값 (영문 도시명)
- value: 사용자에게 표시되는 라벨 (영문 + 지역 + 한글)
- `v-for="(label, key) in reLocationOptions"` 로 렌더링

### 준공 연도 필드 -- select 드롭다운

준공 연도는 기존 number 입력에서 **1990~2035 범위의 `<select>` 드롭다운**으로 변경되었다.
Vue.js `data`의 `reYearOptions` 배열이 IIFE로 2035부터 1990까지 내림차순으로 생성된다.

```javascript
reYearOptions: (function () {
    var years = [];
    for (var y = 2035; y >= 1990; y--) years.push(y);
    return years;
})(),
```

### 필수 필드 검증 (15개, v6 validate_post_form과 동일)

글 제출 시 `submitPost()` 메서드에서 부동산 필수 필드를 v6 `validate_post_form` 함수와 동일하게 검증한다.
검증 실패 시 `this.error`에 한국어 메시지가 설정되고 제출이 중단된다.

| # | 검증 대상 | Vue.js 변수 | 에러 메시지 | 조건 |
|---|----------|------------|-----------|------|
| 1 | 매물 형태 | `reUnitType` | "매물 형태를 선택하세요." | 빈 값 |
| 2 | 거래 형태 | `reSellingType` | "거래 형태를 선택하세요." | 빈 값 |
| 3 | 매물 상태 | `reCondition` | "매물 상태를 선택하세요." | 빈 값 |
| 4 | 건물명 | `reBuildingName` | "건물 이름을 입력하세요." | trim 후 빈 값 |
| 5 | 호수/동 | `reUnitNumber` | "유닛 번호(호수/동)를 입력하세요." | trim 후 빈 값 |
| 6 | 지역 | `reRegion` | "지역을 선택하세요." | 빈 값 |
| 7 | 바랑가이 | `reBarangay` | "바랑가이를 입력하세요." | trim 후 빈 값 |
| 8 | 거리 | `reStreet` | "거리 이름을 입력하세요." | trim 후 빈 값 |
| 9 | 가격 | `rePrice` | "가격을 입력하세요." | parseInt <= 0 |
| 10 | 침실 수 | `reBedroom` | "침실 수를 입력하세요." | isNaN 또는 < 0 |
| 11 | 욕실 수 | `reBathroom` | "욕실 수를 입력하세요." | isNaN 또는 < 0 |
| 12 | 바닥 면적 | `reFloorArea` | "바닥 면적을 입력하세요." | parseInt <= 0 |
| 13 | 주차 공간 | `reParking` | "주차 공간 개수를 입력하세요 (0 가능)." | 빈 값 또는 isNaN 또는 < 0 |

> **참고**: 분양 형태(`reCompleted`)와 준공 연도(`reOpeningYear`)는 필수가 아니다 (선택 사항).

```javascript
// 검증 코드 구조 (submitPost 내)
if (this.isRealEstate) {
    if (!this.reUnitType) { this.error = '매물 형태를 선택하세요.'; return; }
    if (!this.reSellingType) { this.error = '거래 형태를 선택하세요.'; return; }
    // ... 13개 필수 필드 순차 검증
}
```

### 샘플 데이터 주입 (개발 환경 전용)

개발 환경(`Env::isDev()`)에서만 부동산 글쓰기 폼에 샘플 데이터를 한 번에 채워넣는 기능이다.
v6의 `widgets/post/form/real-estate.php`에 있던 `inject_sample_data()` 함수를 v7에서 Vue.js 메서드로 재구현하였다.

#### 동작 흐름

1. **PHP 페이지**: `create.php`와 `update.php`에서 `data-is-dev="<?= Env::isDev() ? '1' : '0' ?>"` attribute를 렌더링
2. **post-form.js 초기화**: `el.dataset.isDev === '1'`로 파싱하여 Vue.js `data`의 `isDev` 프로퍼티에 저장
3. **버튼 표시 조건**: `v-if="isDev && isRealEstate"` -- 개발 환경이면서 부동산 카테고리일 때만 버튼 표시
4. **클릭 시**: `@click="injectSampleData"`로 Vue.js data 프로퍼티를 직접 설정하여 폼 필드를 자동 채움

#### create.php / update.php의 data attribute

```php
<!-- create.php -->
<div id="post-form-app"
     data-mode="create"
     data-category="<?= htmlspecialchars($category) ?>"
     data-is-dev="<?= Env::isDev() ? '1' : '0' ?>">

<!-- update.php -->
<div id="post-form-app"
     data-mode="update"
     data-idx="<?= $idx ?>"
     data-is-dev="<?= Env::isDev() ? '1' : '0' ?>">
```

#### post-form.js의 isDev 초기화

```javascript
var isDev = el.dataset.isDev === '1';
// ...
data: {
    isDev: isDev,
    // ...
}
```

#### injectSampleData() 메서드

`post-form.js`의 Vue.js `methods`에 정의된 메서드로, Vue.js data를 직접 설정하여 폼을 채운다:

```javascript
injectSampleData: function () {
    // 제목 (난수 포함하여 중복 방지)
    this.subject = '고급 콘도미니엄 매물 - 마카티 시티 중심부: ' + Math.floor(Math.random() * 1000);

    // 매물 기본 정보
    this.reUnitType = 'Condominum / Apartment';
    this.reSellingType = 'S';
    this.reCondition = 'N';
    this.reCompleted = 'A';

    // 가격 및 세부 정보
    this.rePrice = '15000000';
    this.reBedroom = '3';
    this.reBathroom = '2';
    this.reFloorArea = '85';
    this.reParking = '1';
    this.reOpeningYear = '2020';

    // 위치 정보
    this.reRegion = 'Makati City';
    this.reBuildingName = 'DMCI The Magnolia Residences';
    this.reUnitNumber = '1205';
    this.reStreet = 'Ayala Avenue';
    this.reBarangay = 'Poblacion';

    // 부동산 설명 (content)
    this.content = '마카티 중심부 ... (상세 설명)';
}
```

#### 주입 버튼 HTML 템플릿

```html
<div v-if="isDev && isRealEstate" style="margin-bottom: 0.5rem;">
    <button type="button" @click="injectSampleData"
            style="padding: 0.25rem 0.75rem; font-size: 0.8rem;
                   border: 1px solid #94a3b8; border-radius: 6px;
                   background: #f1f5f9; color: #475569; cursor: pointer;">
        <i class="fa-solid fa-wand-magic-sparkles" style="margin-right: 0.25rem;"></i>
        샘플 데이터 주입
    </button>
</div>
```

#### 주입되는 샘플 데이터 요약

| 필드 | Vue.js 변수 | 샘플 값 |
|------|------------|--------|
| 제목 | `subject` | `고급 콘도미니엄 매물 - 마카티 시티 중심부: {난수}` |
| 매물 형태 | `reUnitType` | `Condominum / Apartment` |
| 거래 형태 | `reSellingType` | `S` (매매) |
| 매물 상태 | `reCondition` | `N` (신축) |
| 분양 형태 | `reCompleted` | `A` (준공 후 분양) |
| 가격 | `rePrice` | `15000000` (1,500만 PHP) |
| 침실 수 | `reBedroom` | `3` |
| 욕실 수 | `reBathroom` | `2` |
| 면적 | `reFloorArea` | `85` (sqm) |
| 주차 | `reParking` | `1` |
| 준공 연도 | `reOpeningYear` | `2020` |
| 지역 | `reRegion` | `Makati City` |
| 건물명 | `reBuildingName` | `DMCI The Magnolia Residences` |
| 호수 | `reUnitNumber` | `1205` |
| 거리 | `reStreet` | `Ayala Avenue` |
| 바랑가이 | `reBarangay` | `Poblacion` |
| 설명 | `content` | 마카티 콘도 상세 설명 (특징, 위치, 시설) |

> **참고**: 프로덕션 환경(`Env::isDev() === false`)에서는 `data-is-dev="0"`이 되어 `isDev`가 `false`이므로 버튼이 표시되지 않는다.

### 제출 시 필드 전송

부동산 카테고리에서 글 작성/수정 시 빈 값이 아닌 필드만 API 파라미터에 추가된다:

```javascript
if (this.isRealEstate) {
    if (this.reUnitType) params.varchar_1 = this.reUnitType;
    if (this.rePrice) params.int_1 = parseInt(this.rePrice, 10) || 0;
    if (this.reBedroom) params.int_2 = parseInt(this.reBedroom, 10) || 0;
    // ... (15개 필드)
    if (this.reRegion) params.region = this.reRegion;
}
```

### 수정 모드 필드 로드

수정 모드에서 기존 글을 로드할 때 부동산 필드를 Vue.js data에 매핑:

```javascript
if (this.category === 'real_estate' || data.category === 'real_estate') {
    this.reUnitType = data.varchar_1 || '';
    this.rePrice = data.int_1 || '';
    this.reBedroom = data.int_2 || '';
    // ... (15개 필드)
    this.reRegion = data.region || '';
}
```

---

## 6. 커스텀 필드 매핑 (15개)

부동산 커스텀 필드는 `sf_post_data` 테이블의 범용 컬럼에 저장된다.
`lib/post/post.fields.php`의 `RealEstateFields` 클래스에 상수로 정의되어 있다.

| # | Vue.js 변수 | DB 컬럼 | 타입 | 설명 | 옵션 |
|---|------------|---------|------|------|------|
| 1 | `reUnitType` | `varchar_1` | string | 매물 형태 | Condominum / Apartment, Office, Town House, Lot, Others |
| 2 | `rePrice` | `int_1` | int | 가격 (PHP) | 숫자 |
| 3 | `reBedroom` | `int_2` | int | 침실 수 | 숫자 |
| 4 | `reBathroom` | `int_3` | int | 욕실 수 | 숫자 |
| 5 | `reFloorArea` | `int_4` | int | 면적 (sqm) | 숫자 |
| 6 | `reParking` | `int_6` | int | 주차 대수 | 숫자 |
| 7 | `reOpeningYear` | `int_7` | int | 준공 연도 | 숫자 (YYYYMMDD 또는 YYYY) |
| 8 | `reSellingType` | `char_1` | char | 거래 형태 | S=매매, R=렌트, W=공유, E=기타 |
| 9 | `reCondition` | `char_2` | char | 매물 상태 | N=신축, T=임대중, R=리모델링, E=빈공간, O=기타 |
| 10 | `reCompleted` | `char_3` | char | 분양 형태 | B=사전분양, A=준공후분양 |
| 11 | `reUnitNumber` | `varchar_12` | string | 호수 | 텍스트 |
| 12 | `reBuildingName` | `varchar_2` | string | 건물명 | 텍스트 |
| 13 | `reStreet` | `varchar_13` | string | 거리 | 텍스트 |
| 14 | `reBarangay` | `varchar_14` | string | 바랑가이 | 텍스트 |
| 15 | `reRegion` | `region` | string | 지역 | `COMPACT_LOCATIONS` 기반 select |

> **참고**: `int_5` 컬럼은 사용하지 않는다 (건너뜀).

---

## 7. CSS (real-estate.css)

### 파일

| 항목 | 내용 |
|------|------|
| **경로** | `v7/post/real-estate.css` |
| **로딩** | masonry 위젯과 상세보기 위젯 내부에서 `<link>` 태그로 동적 로드 |
| **Bootstrap** | 미사용 |
| **CSS 변수** | Web Awesome CSS 변수 (`--wa-color-*`) 활용 |

### CSS 클래스 체계

| 분류 | 주요 클래스 | 용도 |
|------|-----------|------|
| **필터** | `.re-filter-nav`, `.re-filter-form`, `.re-filter-group`, `.re-filter-select` | 목록 상단 지역/유형 필터 |
| **Masonry 오버레이** | `.re-info-overlay`, `.re-info-item`, `.re-price-badge` | 카드 위 부동산 정보 오버레이 |
| **상세 필드** | `.re-detail-section`, `.re-detail-group`, `.re-badge-row`, `.re-badge` | 상세보기 부동산 정보 뱃지 |
| **주소** | `.re-address-text` | 위치 정보 텍스트 |
| **지도** | `.re-map-section`, `.re-map-container`, `.re-map-placeholder` | Google Maps 임베드 |
| **폼 래퍼** | `.re-form-wrapper` | 3개 섹션 카드를 감싸는 flex 컨테이너 |
| **폼 섹션** | `.re-form-section` | 개별 카드 (그라데이션 배경, 포커스 테두리) |
| **폼 타이틀** | `.re-form-title` | 섹션 제목 (아이콘 + 텍스트, 하단 구분선) |
| **폼 그리드** | `.re-form-grid` | 2열 그리드 레이아웃 |
| **폼 필드** | `.re-form-field`, `.re-form-full` | 필드 래퍼, 전체 너비 |
| **필수 표시** | `.re-required` | `*` 빨간색 표시 |
| **힌트 텍스트** | `.re-form-hint` | 필드 아래 보조 설명 |

### 폼 CSS 주요 스타일

| 요소 | CSS | 설명 |
|------|-----|------|
| **섹션 배경** | `linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%)` | 미세한 그라데이션 |
| **섹션 포커스** | `:focus-within { border-color: brand-300 }` | 입력 중 테두리 하이라이트 |
| **타이틀 아이콘** | `color: brand-600`, `font-size: 1rem` | 블루 아이콘 |
| **타이틀 구분선** | `border-bottom: 1px solid neutral-200` | 섹션 내 타이틀/콘텐츠 구분 |
| **라벨 아이콘** | `fa-light` 스타일, `color: brand-500`, `width: 14px` | 작은 블루 아이콘 |
| **입력 포커스** | `box-shadow: 0 0 0 3px rgba(59,130,246, 0.12)` | 미세한 글로우 |
| **select 화살표** | SVG data URL, `appearance: none` | 커스텀 드롭다운 화살표 |
| **number 스피너** | `-webkit-appearance: none` | 숨김 처리 |

### 반응형

| 브레이크포인트 | 동작 |
|--------------|------|
| 640px 이하 | `.re-form-grid`가 1열로 전환 (`grid-template-columns: 1fr`), `gap: 0.7rem` |
