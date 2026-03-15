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
| **상세보기 위젯** | `post-view-real-estate.php` (부동산 필드 + Google Maps) |
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
│   ├── view.php                 ← $post->category === 'real_estate' 조건으로 부동산 상세 위젯 include
│   ├── create.php               ← post-form.js 사용 (부동산 폼 포함)
│   ├── update.php               ← post-form.js 사용 (부동산 폼 포함)
│   └── real-estate.css          ← 부동산 전용 CSS (필터, masonry 오버레이, 상세 필드, 지도, 폼)
│
├── widgets/post/
│   ├── list/
│   │   └── post-list-real-estate-masonry.php  ← 부동산 전용 Masonry 목록 위젯
│   └── view/
│       └── post-view-real-estate.php          ← 부동산 전용 상세보기 위젯
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

### 파일

| 항목 | 내용 |
|------|------|
| **위젯 파일** | `v7/widgets/post/view/post-view-real-estate.php` |
| **CSS** | `v7/post/real-estate.css` |
| **호출 조건** | `view.php`에서 `$post->category === 'real_estate'` |
| **포함 위치** | `post-view-default.php` 뒤에 include |

### 분기 로직 (view.php)

```php
<?php if (!$post->isInfoPost()): ?>
    <?php include __DIR__ . '/../widgets/post/view/post-view-default.php'; ?>

    <?php if ($post->category === 'real_estate'): ?>
        <?php include __DIR__ . '/../widgets/post/view/post-view-real-estate.php'; ?>
    <?php endif; ?>
<?php endif; ?>
```

### 표시 구조

위젯은 부동산 필드가 하나라도 존재할 때만 렌더링되며, 3개 그룹으로 정보를 표시한다:

| 그룹 | 표시 내용 | CSS 클래스 |
|------|----------|-----------|
| **기본 정보** | 매물 형태, 거래 형태, 매물 상태, 분양 형태 (뱃지) | `.re-detail-group`, `.re-badge-*` |
| **가격 및 공간** | 가격, 침실, 욕실, 면적, 주차, 준공 연도 (뱃지) | `.re-badge-danger`, `.re-badge-neutral` |
| **위치 정보** | 주소 텍스트 + Google Maps 임베드 지도 | `.re-address-text`, `.re-map-container` |

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

### 폼 레이아웃

```
┌─────────────────────────────────────────┐
│  [i] 부동산 정보                         │
│ ┌──────────────┬──────────────┐          │
│ │ 매물 형태     │ 거래 형태     │          │
│ ├──────────────┼──────────────┤          │
│ │ 가격          │ 매물 상태     │          │
│ ├──────────────┼──────────────┤          │
│ │ 침실          │ 욕실          │          │
│ ├──────────────┼──────────────┤          │
│ │ 면적 (sqm)    │ 주차          │          │
│ ├──────────────┼──────────────┤          │
│ │ 분양 형태     │ 준공 연도     │          │
│ ├──────────────┴──────────────┤          │
│ │ 건물명 (full width)          │          │
│ ├──────────────┬──────────────┤          │
│ │ 호수          │ 거리          │          │
│ ├──────────────┼──────────────┤          │
│ │ 바랑가이      │ 지역 (select) │          │
│ └──────────────┴──────────────┘          │
└─────────────────────────────────────────┘
```

- 2열 그리드 (`grid-template-columns: 1fr 1fr`)
- 모바일 640px 이하에서 1열 전환
- 건물명은 `.re-form-full` 클래스로 전체 너비 사용
- 지역은 `COMPACT_LOCATIONS` 상수 기반 `<select>` 드롭다운

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
| **폼** | `.re-form-section`, `.re-form-title`, `.re-form-grid`, `.re-form-field` | 글쓰기/수정 커스텀 필드 |

### 반응형

| 브레이크포인트 | 동작 |
|--------------|------|
| 640px 이하 | `.re-form-grid`가 1열로 전환 (`grid-template-columns: 1fr`) |
