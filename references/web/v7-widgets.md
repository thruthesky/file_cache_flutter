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

---

## 1. 개요

v7 홈페이지는 **PHP include 기반 위젯 시스템**을 사용한다.
`v7/widgets/` 폴더 아래에 **모듈별 하위 폴더**로 위젯을 분리하여 재사용성과 DRY 원칙을 확보한다.

| 항목 | 내용 |
|------|------|
| **위젯 루트** | `v7/widgets/` |
| **모듈 폴더** | `layout/`, `home/`, `shared/` |
| **파일 네이밍** | `<module>/<module>.<name>.php` (예: `layout/layout.topbar.php`) |
| **총 위젯 수** | 17개 (layout 8 + home 5 + shared 4) |
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
    └── shared/                         ← 공유 위젯 (4개 — 사이드바 + 모바일 공용)
        ├── shared.exchange-rate.php
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
| `shared/shared.exchange-rate.php` | 환율 계산기 | 오른쪽 사이드바 | 본문 하단 |
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

```php
<!-- 오른쪽 사이드바 (xl 이상, 홈에서만) -->
<aside class="v7-sidebar v7-xl" id="right-sidebar">
    <?php include __DIR__ . '/../shared/shared.exchange-rate.php'; ?>
    <?php include __DIR__ . '/../shared/shared.company-categories.php'; ?>
    <?php include __DIR__ . '/../shared/shared.latest-companies.php'; ?>
    <?php include __DIR__ . '/../shared/shared.stats.php'; ?>
</aside>
```

> **경로 주의**: `layout.sidebar-right.php`는 `widgets/layout/` 폴더에 위치하므로,
> shared 위젯을 include할 때 `__DIR__ . '/../shared/shared.xxx.php'`로 한 단계 상위로 올라간다.

### 모바일: index.php에서 include

```php
<!-- 모바일 전용 위젯 블록 (모바일만) — shared 위젯 include -->
<data class="v7-mobile-only">
    <?php include __DIR__ . '/widgets/shared/shared.exchange-rate.php'; ?>
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
        <?php include __DIR__ . '/widgets/shared/shared.exchange-rate.php'; ?>
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
| **shared** | (CSS 없음 — layout-widget.css에 포함) | shared 위젯의 CSS는 사이드바에서 사용하므로 layout-widget.css에 포함 |

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
│   ├── widgets/shared/shared.exchange-rate.php
│   ├── widgets/shared/shared.company-categories.php
│   ├── widgets/shared/shared.latest-companies.php
│   └── widgets/shared/shared.stats.php
└── widgets/layout/layout.footer.php

v7/index.php (홈페이지 본문)
├── widgets/home/home.mobile-top-banners.php
├── widgets/home/home.news-tabs.php
├── widgets/home/home.mobile-wing-banners.php
├── widgets/home/home.latest-posts.php
├── widgets/home/home.popular-posts.php
└── [모바일 전용 블록]
    ├── widgets/shared/shared.exchange-rate.php (공유)
    ├── widgets/shared/shared.company-categories.php (공유)
    ├── widgets/shared/shared.latest-companies.php (공유)
    └── widgets/shared/shared.stats.php (공유)
```
