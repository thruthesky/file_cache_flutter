# v7 위젯 시스템

## 목차

1. [개요](#1-개요)
2. [폴더 구조](#2-폴더-구조)
3. [위젯 목록](#3-위젯-목록)
4. [레이아웃 위젯 (layout 모듈)](#4-레이아웃-위젯-layout-모듈)
5. [공유 위젯 (shared 모듈 — DRY 패턴)](#5-공유-위젯-shared-모듈--dry-패턴)
6. [콘텐츠 위젯 (home 모듈)](#6-콘텐츠-위젯-home-모듈)
7. [layout.php 핵심 소스코드](#7-layoutphp-핵심-소스코드)
8. [index.php 공유 위젯 사용](#8-indexphp-공유-위젯-사용)
9. [위젯 CSS 관리](#9-위젯-css-관리)
10. [위젯 추가 방법](#10-위젯-추가-방법)
11. [날씨+환율 통합 위젯 (shared.weather-currency)](#11-날씨환율-통합-위젯-sharedweather-currency)

---

## 1. 개요

v7 홈페이지는 **PHP include 기반 위젯 시스템**을 사용한다.
`v7/widgets/` 폴더 아래에 **모듈별 하위 폴더**로 위젯을 분리하여 재사용성과 DRY 원칙을 확보한다.

| 항목 | 내용 |
|------|------|
| **위젯 루트** | `v7/widgets/` |
| **모듈 폴더** | `layout/`, `home/`, `shared/` |
| **파일 네이밍** | `<module>/<module>.<name>.php` (예: `layout/layout.topbar.php`) |
| **총 위젯 수** | 18개 (layout 8 + home 5 + shared 5) |
| **사용 방식** | `<?php include __DIR__ . '/widgets/<module>/<module>.<name>.php'; ?>` |
| **CSS 관리** | 모듈별 하나의 CSS 파일 (`layout-widget.css`, `home-widget.css`) |
| **공유 위젯** | 4개 (사이드바 + 모바일 양쪽에서 재사용) |
| **반응형** | CSS 클래스(`v7-lg`, `v7-xl`, `v7-mobile-only`)로 표시/숨김 제어 |

### 설계 원칙

- **모듈별 폴더 관리**: 위젯을 기능별 모듈(`layout`, `home`, `shared`)로 분류하여 폴더에 그룹화한다
- **하나의 위젯 = 하나의 PHP 파일**: 각 위젯은 독립적인 HTML 블록
- **파일 네이밍 규칙**: `<module>.<name>.php` — 모듈명을 접두사로 사용하여 파일명만으로 소속 모듈을 알 수 있다
- **모듈별 CSS 통합**: 각 모듈의 위젯 CSS는 해당 모듈 폴더에 하나의 CSS 파일로 통합 관리한다
- **`<style>` 태그 금지**: PHP 파일 안에 `<style>` 태그로 CSS를 인라인 작성하지 않는다
- **외부 변수 의존 최소화**: 위젯 내부에서 필요한 데이터를 직접 처리
- **Bootstrap 미사용**: 반응형은 `v7/css/responsive.css`의 커스텀 클래스 사용
- **중복 제거**: 데스크톱 사이드바와 모바일 본문에서 동일 위젯을 `include`로 공유

### 🔴🔴🔴 위젯 데이터 접근 규칙 — 절대 규칙 🔴🔴🔴

> **⛔ 위젯에서 `Db::` 클래스를 직접 사용하여 DB에 접근하는 것은 엄격히 금지한다. ⛔**
> **모든 DB 접근은 반드시 Service → Repository → Db 3계층 아키텍처를 통해야 한다.**

| 규칙 | 설명 |
|------|------|
| **Db:: 직접 사용 금지** | 위젯 PHP 파일에서 `Db::fetchAll()`, `Db::fetch()`, `Db::execute()` 등을 직접 호출하지 않는다 |
| **Service 클래스 필수** | 데이터 조회는 반드시 해당 도메인의 Service 클래스 메서드를 통해 수행한다 |
| **Repository 캡슐화** | SQL 쿼리는 Repository 클래스에만 존재해야 하며, Service가 Repository를 호출한다 |
| **메서드 부재 시 추가** | 필요한 Service 메서드가 없으면 Repository → Service 순으로 새 메서드를 추가한 후 위젯에서 호출한다 |

**데이터 흐름:**

```
위젯 (PHP include) → Service::method() → Repository::method() → Db::fetchAll/fetch/execute
```

**올바른 사용법:**

```php
// ✅ Service를 통한 데이터 조회
use Philgo\Post\PostService;

$_popularRows = PostService::listPopular(30, 20);
$_freetalkRows = PostService::listLatestSimple('freetalk', null, 5, ['idx', 'subject', 'no_of_comment']);
$latestPhotos = PostService::listLatestPhotos(9);
$comments = PostService::listRecentComments(20);
```

**잘못된 사용법 (절대 금지):**

```php
// ❌ 위젯에서 Db:: 직접 사용
use Philgo\Utils\Db;

$_popularRows = Db::fetchAll("SELECT idx, subject FROM sf_post_data WHERE ...", [...]);
```

**위젯에서 사용 가능한 주요 Service 메서드:**

| Service 메서드 | 용도 | 사용 위젯 |
|---|---|---|
| `PostService::listPopular($days, $limit)` | 인기 게시글 (댓글순) | home.popular-posts |
| `PostService::listReported($limit)` | 신고된 글 | home.admin-reminder |
| `PostService::listLatestSimple($postId, $category, $limit, $columns)` | 최신 게시글 (유연한 컬럼) | home.news-tabs, home.latest-posts |
| `PostService::listLatestPhotos($limit)` | 이미지 있는 최신 글 | layout.sidebar-left.latest-photos |
| `PostService::listRecentComments($limit)` | 최근 댓글 (회원 JOIN) | layout.sidebar-left.recent-comments |
| `UserService::listRecent($limit)` | 최근 가입 회원 | home.admin-reminder |
| `CompanyService::listPending($limit)` | 미승인 업소 | home.admin-reminder |

---

## 2. 폴더 구조

```
v7/
├── layout.php                  ← 전체 HTML 레이아웃 (위젯 include만)
├── index.php                   ← 홈페이지 본문 콘텐츠
│
├── css/
│   ├── layout.css              ← 레이아웃 구조 CSS (5-column flex, CSS 변수)
│   ├── responsive.css          ← 반응형 유틸리티 CSS
│   └── utilities.css           ← 공통 유틸리티 CSS
│
└── widgets/
    ├── layout/                         ← 레이아웃 뼈대 위젯 (8개)
    │   ├── layout-widget.css               ← ★ layout 모듈 전체 위젯 CSS
    │   ├── layout.topbar.php
    │   ├── layout.header-mobile.php
    │   ├── layout.header-desktop.php
    │   ├── layout.sidebar-left.php
    │   ├── layout.sidebar-right.php
    │   ├── layout.wing-left.php
    │   ├── layout.wing-right.php
    │   └── layout.footer.php
    │
    ├── home/                           ← 홈페이지 콘텐츠 위젯 (5개)
    │   ├── home-widget.css                 ← ★ home 모듈 전체 위젯 CSS
    │   ├── home.mobile-top-banners.php
    │   ├── home.news-tabs.php
    │   ├── home.mobile-wing-banners.php
    │   ├── home.latest-posts.php
    │   └── home.popular-posts.php
    │
    └── shared/                         ← 공유 위젯 (5개 — 사이드바 + 모바일 공용)
        ├── shared.weather-currency.php    ← ★ 날씨+환율 통합 위젯 (API + 파일 캐시)
        ├── shared.weather-currency.css    ← ★ 날씨+환율 위젯 전용 CSS
        ├── shared.exchange-rate.php       ← (레거시 — weather-currency로 대체)
        ├── shared.company-categories.php
        ├── shared.latest-companies.php
        └── shared.stats.php
```

---

## 3. 위젯 목록

### layout 모듈 — 레이아웃 위젯 (layout.php에서 include)

| 파일 | 용도 | 표시 조건 | CSS 클래스 |
|------|------|----------|-----------|
| `layout/layout.topbar.php` | 최상단 고정 바 (카테고리, 광고문의 등) | 데스크톱(>=992px) | `v7-topbar`, `v7-lg` |
| `layout/layout.header-mobile.php` | 모바일 헤더 (메뉴 링크, 검색/햄버거) | 모바일(<992px) | `v7-header-mobile`, `v7-mobile-only` |
| `layout/layout.header-desktop.php` | 데스크톱 헤더 (로고, 검색, 4열 메뉴) | 데스크톱(>=992px) | `v7-header-desktop`, `v7-lg` |
| `layout/layout.sidebar-left.php` | 왼쪽 사이드바 (로그인, 최신댓글, 최신사진) | 데스크톱(>=992px) | `v7-sidebar`, `v7-lg` |
| `layout/layout.sidebar-right.php` | 오른쪽 사이드바 (shared 위젯 4개 포함) | XL(>=1200px), 홈만 | `v7-sidebar`, `v7-xl` |
| `layout/layout.wing-left.php` | 왼쪽 날개 배너 (광고 3개) | 데스크톱(>=992px) | `v7-wing`, `v7-lg` |
| `layout/layout.wing-right.php` | 오른쪽 날개 배너 (광고 3개) | 데스크톱(>=992px) | `v7-wing`, `v7-lg` |
| `layout/layout.footer.php` | 4열 푸터 (소개, 광고, 바로가기, 정책) | 공통 | `v7-footer` |

### shared 모듈 — 공유 위젯 (사이드바 + 모바일 공유)

| 파일 | 용도 | 데스크톱 위치 | 모바일 위치 |
|------|------|-------------|------------|
| `shared/shared.weather-currency.php` | **날씨+환율 통합** (Open-Meteo + Frankfurter API, 40분 파일 캐시) | 오른쪽 사이드바 | 본문 하단 |
| `shared/shared.exchange-rate.php` | 환율 계산기 (레거시 — weather-currency로 대체됨) | — | — |
| `shared/shared.company-categories.php` | 업소 카테고리 목록 | 오른쪽 사이드바 | 본문 하단 |
| `shared/shared.latest-companies.php` | 최신 등록 업소 | 오른쪽 사이드바 | 본문 하단 |
| `shared/shared.stats.php` | 사이트 통계 (회원수, 글수 등) | 오른쪽 사이드바 | 본문 하단 |

### home 모듈 — 콘텐츠 위젯 (index.php에서 include)

| 파일 | 용도 | 표시 조건 |
|------|------|----------|
| `home/home.mobile-top-banners.php` | 모바일 상단 배너 슬라이드 | 모바일만 |
| `home/home.news-tabs.php` | 뉴스/여행/정보/필독/팁 탭 | 공통 |
| `home/home.mobile-wing-banners.php` | 모바일 날개 배너 그리드 | 모바일만 |
| `home/home.latest-posts.php` | 최신 게시글 2열 카드 | 공통 |
| `home/home.popular-posts.php` | 인기 게시글 순위 | 공통 |

---

## 4. 레이아웃 위젯 (layout 모듈)

### 5-column 레이아웃 구조

```
[왼쪽날개] [왼쪽사이드바] [메인콘텐츠] [오른쪽사이드바] [오른쪽날개]
  120px      240px         유동          240px          120px
```

### layout.php에서의 위젯 배치

```php
<!-- 탑바 -->
<?php include __DIR__ . '/widgets/layout/layout.topbar.php'; ?>

<div class="v7-page-wrapper">
    <div class="v7-layout">
        <!-- 왼쪽 날개 -->
        <?php include __DIR__ . '/widgets/layout/layout.wing-left.php'; ?>

        <div class="v7-center">
            <!-- 헤더 -->
            <header class="v7-header">
                <?php include __DIR__ . '/widgets/layout/layout.header-mobile.php'; ?>
                <?php include __DIR__ . '/widgets/layout/layout.header-desktop.php'; ?>
            </header>

            <!-- 본문 -->
            <div class="v7-body">
                <?php include __DIR__ . '/widgets/layout/layout.sidebar-left.php'; ?>
                <main class="v7-main"><?= $content ?></main>
                <?php if ($isHomePage): ?>
                    <?php include __DIR__ . '/widgets/layout/layout.sidebar-right.php'; ?>
                <?php endif; ?>
            </div>
        </div>

        <!-- 오른쪽 날개 -->
        <?php include __DIR__ . '/widgets/layout/layout.wing-right.php'; ?>
    </div>
</div>

<!-- 푸터 -->
<?php include __DIR__ . '/widgets/layout/layout.footer.php'; ?>
```

---

## 5. 공유 위젯 (shared 모듈 — DRY 패턴)

4개 위젯(환율, 업소 카테고리, 최신 업소, 통계)은 **데스크톱 오른쪽 사이드바**와 **모바일 본문 하단** 양쪽에서 동일하게 표시된다.

### 데스크톱: layout.sidebar-right.php에서 include

사이드바에서는 **래퍼 패턴**을 사용한다. `layout.sidebar-right.*.php` 래퍼 파일이 shared 위젯을 include하여 일관된 네이밍을 제공한다.

```php
<!-- 오른쪽 사이드바 (xl 이상, 홈에서만) -->
<aside class="v7-sidebar v7-xl" id="right-sidebar">
    <?php include __DIR__ . '/layout.sidebar-right.weather-currency.php'; ?>
    <?php include __DIR__ . '/layout.sidebar-right.company-categories.php'; ?>
    <?php include __DIR__ . '/layout.sidebar-right.latest-companies.php'; ?>
    <?php include __DIR__ . '/layout.sidebar-right.stats.php'; ?>
</aside>
```

각 래퍼 파일은 shared 위젯을 단순히 include한다:

```php
// layout.sidebar-right.weather-currency.php
include __DIR__ . '/../shared/shared.weather-currency.php';
```

### 모바일: index.php에서 include

```php
<!-- 모바일 전용 위젯 블록 (모바일만) — shared 위젯 include -->
<data class="v7-mobile-only">
    <?php include __DIR__ . '/widgets/shared/shared.weather-currency.php'; ?>
    <?php include __DIR__ . '/widgets/shared/shared.company-categories.php'; ?>
    <?php include __DIR__ . '/widgets/shared/shared.latest-companies.php'; ?>
    <?php include __DIR__ . '/widgets/shared/shared.stats.php'; ?>
</data>
```

---

## 6. 콘텐츠 위젯 (home 모듈)

콘텐츠 위젯은 `v7/index.php`(홈페이지 본문)에서 사용하는 위젯이다.

### 사용 예시 (index.php)

```php
<div class="v7-home-content v7-content-pad">
    <?php include __DIR__ . '/widgets/home/home.mobile-top-banners.php'; ?>
    <?php include __DIR__ . '/widgets/home/home.news-tabs.php'; ?>
    <?php include __DIR__ . '/widgets/home/home.mobile-wing-banners.php'; ?>
    <?php include __DIR__ . '/widgets/home/home.latest-posts.php'; ?>
    <?php include __DIR__ . '/widgets/home/home.popular-posts.php'; ?>

    <data class="v7-mobile-only">
        <?php include __DIR__ . '/widgets/shared/shared.weather-currency.php'; ?>
        <?php include __DIR__ . '/widgets/shared/shared.company-categories.php'; ?>
        <?php include __DIR__ . '/widgets/shared/shared.latest-companies.php'; ?>
        <?php include __DIR__ . '/widgets/shared/shared.stats.php'; ?>
    </data>
</div>
```

---

## 7. layout.php 핵심 소스코드

`v7/layout.php`는 위젯 분리 후 **~140줄**로 유지된다.

### CSS 로딩 구조

```php
<head>
    <!-- 공통 CSS 3파일 (레이아웃 구조 + 반응형 + 유틸리티) -->
    <link rel="stylesheet" href="/v7/css/layout.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/responsive.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/utilities.css?v=<?= CACHE_VERSION ?>">

    <!-- 위젯 모듈별 CSS -->
    <link rel="stylesheet" href="/v7/widgets/layout/layout-widget.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/widgets/home/home-widget.css?v=<?= CACHE_VERSION ?>">
</head>
```

---

## 8. index.php 공유 위젯 사용

`v7/index.php`는 홈페이지 본문 콘텐츠를 담당한다.
layout.php의 `$content` 변수에 캡처되어 `<main>` 태그 안에 렌더링된다.

모바일 전용 위젯 블록에서 4개 shared 위젯을 include하여 사이드바 내용을 모바일에서도 표시한다.

---

## 9. 위젯 CSS 관리

### 모듈별 통합 CSS 파일

각 모듈의 **모든 위젯 CSS**를 해당 모듈 폴더의 **하나의 CSS 파일**에 모아 관리한다.
위젯별로 개별 CSS 파일을 만들지 않고, 모듈 단위로 통합한다.

| 모듈 | CSS 파일 | 내용 |
|------|----------|------|
| **layout** | `v7/widgets/layout/layout-widget.css` | 탑바, 헤더, 사이드바, 푸터, 댓글, 업소, 카테고리 등 layout 위젯 전체 CSS |
| **home** | `v7/widgets/home/home-widget.css` | 뉴스 탭, 최신 게시글, 인기 게시글, 모바일 배너 등 home 위젯 전체 CSS |
| **shared** | `v7/widgets/shared/shared.weather-currency.css` (위젯 자체 로드) | 날씨+환율 위젯은 자체 CSS 파일을 `define()` 가드로 한 번만 동적 로드. 나머지 shared 위젯 CSS는 layout-widget.css에 포함 |

### CSS 분리 규칙

| 규칙 | 설명 |
|------|------|
| **모듈별 하나의 CSS** | 각 모듈의 위젯 CSS는 해당 폴더의 `<module>-widget.css` 파일 하나에 통합 |
| **`<style>` 태그 금지** | 위젯 PHP 파일 내 `<style>...</style>` 인라인 CSS 작성 금지 |
| **layout.php에서 로드** | 모듈 CSS 파일은 `layout.php`의 `<head>`에서 `<link>` 태그로 로드 |
| **layout.css 역할 축소** | `v7/css/layout.css`는 레이아웃 구조(flex, CSS 변수, 그리드)만 담당 |

### CSS 파일 역할 분담

| CSS 파일 | 역할 | 위치 |
|----------|------|------|
| `v7/css/layout.css` | 5-column flex 구조, CSS 변수, 전역 스타일 | 공통 |
| `v7/css/responsive.css` | 반응형 브레이크포인트, 표시/숨김 유틸리티 | 공통 |
| `v7/css/utilities.css` | 텍스트 유틸리티, 폰트 크기, 패딩 등 | 공통 |
| `v7/widgets/layout/layout-widget.css` | layout 모듈 위젯 스타일 전체 | 위젯 |
| `v7/widgets/home/home-widget.css` | home 모듈 위젯 스타일 전체 | 위젯 |

### 새 모듈 CSS 추가

새 모듈(예: `post`, `user`)을 추가할 때:

1. `v7/widgets/<module>/` 폴더 생성
2. `v7/widgets/<module>/<module>-widget.css` 파일 생성
3. `layout.php`의 `<head>`에 `<link>` 태그 추가:
   ```html
   <link rel="stylesheet" href="/v7/widgets/<module>/<module>-widget.css?v=<?= CACHE_VERSION ?>">
   ```

---

## 10. 위젯 추가 방법

새 위젯을 추가할 때:

1. **모듈 선택**: 위젯의 성격에 따라 적절한 모듈(`layout`, `home`, `shared`) 선택
   - 새 모듈이 필요하면 `v7/widgets/<새모듈>/` 폴더 생성
2. **파일 생성**: `v7/widgets/<module>/<module>.<name>.php` 파일 생성
3. **독립적 HTML**: 외부 변수 의존 최소화한 독립 HTML 블록으로 작성
4. **CSS 추가**: 해당 모듈의 통합 CSS 파일(`<module>-widget.css`)에 스타일 추가
5. **반응형**: `v7-lg`, `v7-xl`, `v7-mobile-only` 클래스 활용
6. **include 추가**: `layout.php` 또는 페이지 파일에서 include
   ```php
   <?php include __DIR__ . '/widgets/<module>/<module>.<name>.php'; ?>
   ```
7. **공유 위젯**: 데스크톱과 모바일 양쪽에서 사용하면 `shared/` 모듈에 배치

### 모듈 선택 기준

| 모듈 | 사용 시점 |
|------|----------|
| `layout` | 레이아웃 뼈대를 구성하는 위젯 (탑바, 헤더, 사이드바, 날개, 푸터) |
| `home` | 홈페이지 본문에서만 사용하는 콘텐츠 위젯 |
| `shared` | 여러 위치(사이드바 + 모바일 등)에서 동일하게 재사용하는 위젯 |
| `<새모듈>` | 특정 기능(예: `post`, `user`, `company`)에 속하는 위젯 |

### 시각적 include 계층 구조

```
v7/layout.php (메인 레이아웃)
├── widgets/layout/layout.topbar.php
├── widgets/layout/layout.wing-left.php
├── widgets/layout/layout.wing-right.php
├── widgets/layout/layout.header-mobile.php
├── widgets/layout/layout.header-desktop.php
├── widgets/layout/layout.sidebar-left.php
├── widgets/layout/layout.sidebar-right.php (← 컴포지트 위젯)
│   ├── layout.sidebar-right.weather-currency.php → widgets/shared/shared.weather-currency.php
│   ├── layout.sidebar-right.company-categories.php → widgets/shared/shared.company-categories.php
│   ├── layout.sidebar-right.latest-companies.php → widgets/shared/shared.latest-companies.php
│   └── layout.sidebar-right.stats.php → widgets/shared/shared.stats.php
└── widgets/layout/layout.footer.php

v7/index.php (홈페이지 본문)
├── widgets/home/home.mobile-top-banners.php
├── widgets/home/home.news-tabs.php
├── widgets/home/home.mobile-wing-banners.php
├── widgets/home/home.latest-posts.php
├── widgets/home/home.popular-posts.php
└── [모바일 전용 블록]
    ├── widgets/shared/shared.weather-currency.php (공유)
    ├── widgets/shared/shared.company-categories.php (공유)
    ├── widgets/shared/shared.latest-companies.php (공유)
    └── widgets/shared/shared.stats.php (공유)
```

---

## 11. 날씨+환율 통합 위젯 (shared.weather-currency)

### 11.1 개요

필리핀 마닐라의 현재 날씨와 페소/달러→원 환율을 **하나의 컴팩트 위젯**에 표시한다.
왼쪽에 날씨(아이콘 + 온도), 오른쪽에 환율(₱→원 큰 글씨 + $→원 작은 글씨)을 보여준다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/widgets/shared/shared.weather-currency.php` |
| **CSS** | `v7/widgets/shared/shared.weather-currency.css` |
| **캐시** | `var/cache/v7_weather_currency.json` (파일 기반, 40분 TTL) |
| **v6 의존성** | 없음 — v7 독립 구현 |
| **공유 패턴** | 데스크톱 사이드바 + 모바일 본문 양쪽에서 include (DRY) |

### 11.2 위젯 레이아웃

```
┌─────────────────────────────────────┐
│   v7-widget-box  wc-widget          │
│ ┌───────────┬─┬───────────────────┐ │
│ │  wc-left  │ │     wc-right      │ │
│ │           │d│                   │ │
│ │  [label]  │i│     [label]       │ │
│ │  날씨     │v│     환율          │ │
│ │           │i│                   │ │
│ │  [icon]   │d│  ₱24.9 (큰 글씨) │ │
│ │  ☀️       │e│                   │ │
│ │           │r│  $1=1432원        │ │
│ │  32.5°C   │ │  (작은 회색)      │ │
│ └───────────┴─┴───────────────────┘ │
└─────────────────────────────────────┘
```

### 11.3 API 엔드포인트

| API | 엔드포인트 | 용도 |
|-----|-----------|------|
| **Open-Meteo** | `api.open-meteo.com/v1/forecast?latitude=14.5995&longitude=120.9842&current=temperature_2m,weather_code,is_day&timezone=Asia/Manila` | 마닐라 현재 날씨 (온도, WMO 날씨 코드, 낮/밤 여부) |
| **Frankfurter** | `api.frankfurter.dev/v1/latest?base=USD&symbols=KRW,PHP` | USD 기준 KRW, PHP 환율 (ECB 데이터) |

**환율 계산 로직:**

```
API 응답: USD→KRW = 1432, USD→PHP = 57.5
1 PHP = KRW / PHP = 1432 / 57.5 = 24.9원
```

하나의 API 호출로 두 통화를 모두 가져와 `KRW / PHP`로 페소 환율을 계산한다.

### 11.4 파일 기반 캐시 시스템

v7 시스템은 v6의 `get_cache()`/`set_cache()`를 사용할 수 없으므로, **파일 기반 캐시**를 자체 구현한다.

| 항목 | 값 |
|------|-----|
| **캐시 파일** | `ROOT_DIR . '/var/cache/v7_weather_currency.json'` |
| **TTL** | 2400초 (40분) |
| **형식** | `{"expires_at": 1710000000, "value": {...}}` |
| **갱신 조건** | 파일 없거나 `expires_at` 초과 시 API 재호출 |
| **HTTP 타임아웃** | 5초 (`stream_context_create`) |

```php
// 캐시 파일 구조
{
    "expires_at": 1710000000,
    "value": {
        "weather": {
            "temperature_2m": 32.5,
            "weather_code": 0,
            "is_day": 1
        },
        "rates": {
            "KRW": 1432.0,
            "PHP": 57.5
        }
    }
}
```

### 11.5 이중 include 보호 패턴

이 위젯은 데스크톱 사이드바와 모바일 본문 양쪽에서 include되므로, 3가지 이중 실행 방지 메커니즘을 사용한다.

| 보호 대상 | 메커니즘 | 코드 |
|-----------|---------|------|
| **CSS 로딩** | `define()` 상수 가드 | `if (!defined('WC_WIDGET_CSS_LOADED'))` |
| **헬퍼 함수** | `function_exists()` 가드 | `if (!function_exists('_v7_wc_load_data'))` |
| **데이터 로딩** | `$GLOBALS` 캐싱 | `if (!isset($GLOBALS['_v7_wc_data']))` |

```php
// 1. CSS — define() 가드로 한 번만 <link> 태그 출력
if (!defined('WC_WIDGET_CSS_LOADED')) {
    define('WC_WIDGET_CSS_LOADED', true);
    echo '<link rel="stylesheet" href="/v7/widgets/shared/shared.weather-currency.css?v=...">';
}

// 2. 함수 — function_exists()로 한 번만 정의
if (!function_exists('_v7_wc_load_data')) {
    function _v7_wc_load_data(): array { /* ... */ }
    function _v7_wc_get_icon(int $code, int $isDay): string { /* ... */ }
    function _v7_wc_get_icon_color(int $code, int $isDay): string { /* ... */ }
}

// 3. 데이터 — $GLOBALS로 같은 요청에서 한 번만 로드
if (!isset($GLOBALS['_v7_wc_data'])) {
    $GLOBALS['_v7_wc_data'] = _v7_wc_load_data();
}
```

### 11.6 WMO 날씨 코드 → Font Awesome Pro 7 아이콘 매핑

| WMO 코드 | 날씨 | 아이콘 클래스 (낮) | 아이콘 클래스 (밤) | 색상 |
|----------|------|-------------------|-------------------|------|
| 0 | 맑음 | `fa-solid fa-sun` | `fa-solid fa-moon` | 낮 `#f59e0b` / 밤 `#818cf8` |
| 1~2 | 약간 흐림 | `fa-solid fa-cloud-sun` | `fa-solid fa-cloud-moon` | `#64748b` |
| 3 | 흐림 | `fa-solid fa-cloud` | `fa-solid fa-cloud` | `#64748b` |
| 4~48 | 안개/연무 | `fa-solid fa-smog` | `fa-solid fa-smog` | `#94a3b8` |
| 51~57 | 이슬비 | `fa-solid fa-cloud-rain` | `fa-solid fa-cloud-rain` | `#3b82f6` |
| 61~67 | 비 | `fa-solid fa-cloud-showers-heavy` | `fa-solid fa-cloud-showers-heavy` | `#3b82f6` |
| 71~77 | 눈 | `fa-solid fa-snowflake` | `fa-solid fa-snowflake` | `#93c5fd` |
| 80~86 | 소나기 | `fa-solid fa-cloud-showers-water` | `fa-solid fa-cloud-showers-water` | `#60a5fa` |
| 95~99 | 뇌우 | `fa-solid fa-cloud-bolt` | `fa-solid fa-cloud-bolt` | `#eab308` |

### 11.7 CSS 클래스

| 클래스 | 역할 | 주요 스타일 |
|--------|------|-----------|
| `.wc-widget` | 위젯 루트 | `margin-top: var(--v7-gap)` |
| `.wc-content` | 2열 flex 컨테이너 | `display: flex; align-items: stretch` |
| `.wc-left` | 왼쪽 날씨 영역 | `flex: 1; text-align: center; padding: 0.5rem 0.625rem` |
| `.wc-right` | 오른쪽 환율 영역 | `flex: 1; text-align: center; padding: 0.5rem 0.625rem` |
| `.wc-divider` | 수직 구분선 | `width: 1px; background: var(--wa-color-neutral-border-normal)` |
| `.wc-label` | 상단 라벨 (날씨/환율) | `font-size: 0.7em; text-transform: uppercase; color: var(--wa-color-text-quiet)` |
| `.wc-icon` | 날씨 아이콘 | `font-size: 1.75em` |
| `.wc-temp` | 온도 텍스트 | `font-size: 0.8em; font-weight: 600` |
| `.wc-peso` | 페소 환율 (큰 글씨) | `font-size: 1.5em; font-weight: 700` |
| `.wc-dollar` | 달러 환율 (작은 글씨) | `font-size: 0.7em; color: var(--wa-color-text-quiet)` |

### 11.8 환율 표시 형식

| 통화 | 표시 형식 | 소수점 | 예시 |
|------|----------|--------|------|
| 페소(₱) | `₱` + 소수점 1자리 | `number_format($val, 1)` | ₱24.9 |
| 달러($) | `$1=` + 소수점 없음 + `원` | `number_format($val, 0)` | $1=1,432원 |

### 11.9 헬퍼 함수

| 함수명 | 반환 타입 | 용도 |
|--------|----------|------|
| `_v7_wc_load_data()` | `array{weather: ?array, rates: ?array}` | 캐시에서 로드 또는 API 호출 후 캐시 저장 |
| `_v7_wc_get_icon(int $code, int $isDay)` | `string` | WMO 코드 → Font Awesome 아이콘 클래스 |
| `_v7_wc_get_icon_color(int $code, int $isDay)` | `string` | WMO 코드 → CSS 색상 코드 |

> 모든 함수명은 `_v7_wc_` 접두사로 글로벌 네임스페이스 충돌을 방지한다.

### 11.10 사이드바 래퍼 파일

데스크톱 사이드바에서는 래퍼 패턴으로 shared 위젯을 include한다.

```php
// v7/widgets/layout/layout.sidebar-right.weather-currency.php
<?php
/**
 * 오른쪽 사이드바 날씨+환율 위젯 — shared 위젯 래퍼
 */
include __DIR__ . '/../shared/shared.weather-currency.php';
```

### 11.11 데이터 흐름

```
1. 위젯 include (사이드바 또는 모바일)
   │
2. $GLOBALS 체크 → 이미 로드됨? → 캐시된 데이터 사용
   │                                    ↓
3. _v7_wc_load_data() 호출
   │
4. var/cache/v7_weather_currency.json 존재 + 미만료?
   │  YES → 파일 캐시 반환
   │  NO  ↓
5. Open-Meteo API + Frankfurter API 동시 호출 (타임아웃 5초)
   │
6. 캐시 파일 저장 (TTL 40분)
   │
7. HTML 렌더링 (날씨 왼쪽 + 환율 오른쪽)
```
