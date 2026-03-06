# v7 위젯 시스템

## 목차

1. [개요](#1-개요)
2. [폴더 구조](#2-폴더-구조)
3. [위젯 목록](#3-위젯-목록)
4. [레이아웃 위젯](#4-레이아웃-위젯)
5. [공유 위젯 (DRY 패턴)](#5-공유-위젯-dry-패턴)
6. [콘텐츠 위젯](#6-콘텐츠-위젯)
7. [layout.php 핵심 소스코드](#7-layoutphp-핵심-소스코드)
8. [index.php 공유 위젯 사용](#8-indexphp-공유-위젯-사용)
9. [위젯 추가 방법](#9-위젯-추가-방법)

---

## 1. 개요

v7 홈페이지는 **PHP include 기반 위젯 시스템**을 사용한다.
`v7/widgets/` 폴더에 독립적인 PHP 파일로 위젯을 분리하여 재사용성과 DRY 원칙을 확보한다.

| 항목 | 내용 |
|------|------|
| **위젯 폴더** | `v7/widgets/` |
| **총 위젯 수** | 17개 |
| **사용 방식** | `<?php include __DIR__ . '/widgets/파일명.php'; ?>` |
| **공유 위젯** | 4개 (사이드바 + 모바일 양쪽에서 재사용) |
| **반응형** | CSS 클래스(`v7-lg`, `v7-xl`, `v7-mobile-only`)로 표시/숨김 제어 |

### 설계 원칙

- **하나의 위젯 = 하나의 PHP 파일**: 각 위젯은 독립적인 HTML 블록
- **외부 변수 의존 최소화**: 위젯 내부에서 필요한 데이터를 직접 처리
- **Bootstrap 미사용**: 반응형은 `v7/css/responsive.css`의 커스텀 클래스 사용
- **중복 제거**: 데스크톱 사이드바와 모바일 본문에서 동일 위젯을 `include`로 공유

---

## 2. 폴더 구조

```
v7/
├── layout.php              ← 전체 HTML 레이아웃 (~130줄, 위젯 include만)
├── index.php               ← 홈페이지 본문 콘텐츠
│
└── widgets/
    ├── topbar.php              ← 최상단 고정 바 (데스크톱)
    ├── header-mobile.php       ← 모바일 헤더
    ├── header-desktop.php      ← 데스크톱 헤더
    ├── sidebar-left.php        ← 왼쪽 사이드바
    ├── sidebar-right.php       ← 오른쪽 사이드바 (공유 위젯 4개 include)
    ├── wing-left.php           ← 왼쪽 날개 배너
    ├── wing-right.php          ← 오른쪽 날개 배너
    ├── footer.php              ← 푸터
    │
    ├── exchange-rate.php       ← [공유] 환율 계산기
    ├── company-categories.php  ← [공유] 업소 카테고리
    ├── latest-companies.php    ← [공유] 최신 업소
    ├── stats.php               ← [공유] 통계
    │
    ├── mobile-top-banners.php  ← 모바일 상단 배너
    ├── news-tabs.php           ← 뉴스 탭
    ├── mobile-wing-banners.php ← 모바일 날개 배너
    ├── latest-posts.php        ← 최신 게시글 카드
    └── popular-posts.php       ← 인기 게시글 순위
```

---

## 3. 위젯 목록

### 레이아웃 위젯 (layout.php에서 include)

| 파일 | 용도 | 표시 조건 | CSS 클래스 |
|------|------|----------|-----------|
| `topbar.php` | 최상단 고정 바 (카테고리, 광고문의 등) | 데스크톱(≥992px) | `v7-topbar`, `v7-lg` |
| `header-mobile.php` | 모바일 헤더 (메뉴 링크, 검색/햄버거) | 모바일(<992px) | `v7-header-mobile`, `v7-mobile-only` |
| `header-desktop.php` | 데스크톱 헤더 (로고, 검색, 4열 메뉴) | 데스크톱(≥992px) | `v7-header-desktop`, `v7-lg` |
| `sidebar-left.php` | 왼쪽 사이드바 (로그인, 최신댓글, 최신사진) | 데스크톱(≥992px) | `v7-sidebar`, `v7-lg` |
| `sidebar-right.php` | 오른쪽 사이드바 (공유 위젯 4개 포함) | XL(≥1200px), 홈만 | `v7-sidebar`, `v7-xl` |
| `wing-left.php` | 왼쪽 날개 배너 (광고 3개) | 데스크톱(≥992px) | `v7-wing`, `v7-lg` |
| `wing-right.php` | 오른쪽 날개 배너 (광고 3개) | 데스크톱(≥992px) | `v7-wing`, `v7-lg` |
| `footer.php` | 4열 푸터 (소개, 광고, 바로가기, 정책) | 공통 | `v7-footer` |

### 공유 위젯 (사이드바 + 모바일 공유)

| 파일 | 용도 | 데스크톱 위치 | 모바일 위치 |
|------|------|-------------|------------|
| `exchange-rate.php` | 환율 계산기 | 오른쪽 사이드바 | 본문 하단 |
| `company-categories.php` | 업소 카테고리 목록 | 오른쪽 사이드바 | 본문 하단 |
| `latest-companies.php` | 최신 등록 업소 | 오른쪽 사이드바 | 본문 하단 |
| `stats.php` | 사이트 통계 (회원수, 글수 등) | 오른쪽 사이드바 | 본문 하단 |

### 콘텐츠 위젯 (index.php에서 include)

| 파일 | 용도 | 표시 조건 |
|------|------|----------|
| `mobile-top-banners.php` | 모바일 상단 배너 슬라이드 | 모바일만 |
| `news-tabs.php` | 뉴스/여행/정보/필독/팁 탭 | 공통 |
| `mobile-wing-banners.php` | 모바일 날개 배너 그리드 | 모바일만 |
| `latest-posts.php` | 최신 게시글 2열 카드 | 공통 |
| `popular-posts.php` | 인기 게시글 순위 | 공통 |

---

## 4. 레이아웃 위젯

### 5-column 레이아웃 구조

```
[왼쪽날개] [왼쪽사이드바] [메인콘텐츠] [오른쪽사이드바] [오른쪽날개]
  120px      240px         유동          240px          120px
```

### layout.php에서의 위젯 배치

```php
<!-- 탑바 -->
<?php include __DIR__ . '/widgets/topbar.php'; ?>

<div class="v7-page-wrapper">
    <div class="v7-layout">
        <!-- 왼쪽 날개 -->
        <?php include __DIR__ . '/widgets/wing-left.php'; ?>

        <div class="v7-center">
            <!-- 헤더 -->
            <header class="v7-header">
                <?php include __DIR__ . '/widgets/header-mobile.php'; ?>
                <?php include __DIR__ . '/widgets/header-desktop.php'; ?>
            </header>

            <!-- 본문 -->
            <div class="v7-body">
                <?php include __DIR__ . '/widgets/sidebar-left.php'; ?>
                <main class="v7-main"><?= $content ?></main>
                <?php if ($isHomePage): ?>
                    <?php include __DIR__ . '/widgets/sidebar-right.php'; ?>
                <?php endif; ?>
            </div>
        </div>

        <!-- 오른쪽 날개 -->
        <?php include __DIR__ . '/widgets/wing-right.php'; ?>
    </div>
</div>

<!-- 푸터 -->
<?php include __DIR__ . '/widgets/footer.php'; ?>
```

---

## 5. 공유 위젯 (DRY 패턴)

4개 위젯(환율, 업소 카테고리, 최신 업소, 통계)은 **데스크톱 오른쪽 사이드바**와 **모바일 본문 하단** 양쪽에서 동일하게 표시된다.

### 데스크톱: sidebar-right.php에서 include

```php
<!-- 오른쪽 사이드바 (xl 이상, 홈에서만) -->
<aside class="v7-sidebar v7-xl" id="right-sidebar">
    <?php include __DIR__ . '/exchange-rate.php'; ?>
    <?php include __DIR__ . '/company-categories.php'; ?>
    <?php include __DIR__ . '/latest-companies.php'; ?>
    <?php include __DIR__ . '/stats.php'; ?>
</aside>
```

### 모바일: index.php에서 include

```php
<!-- 모바일 전용 위젯 블록 (모바일만) -->
<data class="v7-mobile-only">
    <?php include __DIR__ . '/widgets/exchange-rate.php'; ?>
    <?php include __DIR__ . '/widgets/company-categories.php'; ?>
    <?php include __DIR__ . '/widgets/latest-companies.php'; ?>
    <?php include __DIR__ . '/widgets/stats.php'; ?>
</data>
```

> **주의**: sidebar-right.php에서는 `__DIR__ . '/exchange-rate.php'` (같은 widgets/ 폴더),
> index.php에서는 `__DIR__ . '/widgets/exchange-rate.php'` (v7/ 기준 경로) — 상대 경로가 다르다.

### 중복 제거 효과

| 위젯 | 변경 전 (중복) | 변경 후 (공유) |
|------|---------------|---------------|
| 환율 계산기 | layout.php + index.php (2곳) | exchange-rate.php (1곳) |
| 업소 카테고리 | layout.php + index.php (2곳) | company-categories.php (1곳) |
| 최신 업소 | layout.php + index.php (2곳) | latest-companies.php (1곳) |
| 통계 | layout.php + index.php (2곳) | stats.php (1곳) |

---

## 6. 콘텐츠 위젯

콘텐츠 위젯은 `v7/index.php`(홈페이지 본문)에서 사용하는 위젯이다.

### 사용 예시 (index.php)

```php
<div class="v7-home-content v7-content-pad">
    <!-- 모바일 상단 배너 -->
    <div class="v7-mobile-only">
        <?php include __DIR__ . '/widgets/mobile-top-banners.php'; ?>
    </div>

    <!-- 뉴스 탭 (공통) -->
    <?php include __DIR__ . '/widgets/news-tabs.php'; ?>

    <!-- 모바일 날개 배너 -->
    <div class="v7-mobile-only">
        <?php include __DIR__ . '/widgets/mobile-wing-banners.php'; ?>
    </div>

    <!-- 최신 게시글 (공통) -->
    <?php include __DIR__ . '/widgets/latest-posts.php'; ?>

    <!-- 인기 게시글 (공통) -->
    <?php include __DIR__ . '/widgets/popular-posts.php'; ?>

    <!-- 모바일 전용 공유 위젯 -->
    <data class="v7-mobile-only">
        <?php include __DIR__ . '/widgets/exchange-rate.php'; ?>
        <?php include __DIR__ . '/widgets/company-categories.php'; ?>
        <?php include __DIR__ . '/widgets/latest-companies.php'; ?>
        <?php include __DIR__ . '/widgets/stats.php'; ?>
    </data>
</div>
```

---

## 7. layout.php 핵심 소스코드

`v7/layout.php`는 위젯 분리 후 **~130줄**로 축소되었다. (분리 전 373줄)

### 핵심 구조

```php
<?php
require_once __DIR__ . '/etc/cache-version.php';

use V7\Utils\Route;

$route = Route::getInstance();
$isHomePage = ($route->getUri() === '/' || $route->getUri() === '');
$pageTitle = '필고 v7';

// 페이지 콘텐츠 캡처
ob_start();
$pageFile = $route->getPageFile();
if ($pageFile) {
    include $pageFile;
} else {
    http_response_code(404);
    // ... 404 페이지
}
$content = ob_get_clean();
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <!-- Web Awesome Pro + Font Awesome Pro -->
    <!-- 커스텀 CSS 3파일 (CACHE_VERSION 상수로 캐시 버스팅) -->
    <link rel="stylesheet" href="/v7/css/layout.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/responsive.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/utilities.css?v=<?= CACHE_VERSION ?>">
    <!-- Google Fonts: Apple 기기가 아닌 경우에만 로드 -->
    <!-- Vue.js CDN -->
</head>
<body>
    <?php include __DIR__ . '/widgets/topbar.php'; ?>
    <div class="v7-page-wrapper">
        <div class="v7-layout">
            <?php include __DIR__ . '/widgets/wing-left.php'; ?>
            <div class="v7-center">
                <header class="v7-header">
                    <?php include __DIR__ . '/widgets/header-mobile.php'; ?>
                    <?php include __DIR__ . '/widgets/header-desktop.php'; ?>
                </header>
                <div class="v7-body">
                    <?php include __DIR__ . '/widgets/sidebar-left.php'; ?>
                    <main class="v7-main"><?= $content ?></main>
                    <?php if ($isHomePage): ?>
                        <?php include __DIR__ . '/widgets/sidebar-right.php'; ?>
                    <?php endif; ?>
                </div>
            </div>
            <?php include __DIR__ . '/widgets/wing-right.php'; ?>
        </div>
    </div>
    <?php include __DIR__ . '/widgets/footer.php'; ?>
</body>
</html>
```

---

## 8. index.php 공유 위젯 사용

`v7/index.php`는 홈페이지 본문 콘텐츠를 담당한다.
layout.php의 `$content` 변수에 캡처되어 `<main>` 태그 안에 렌더링된다.

모바일 전용 위젯 블록에서 4개 공유 위젯을 include하여 사이드바 내용을 모바일에서도 표시한다.

```php
<!-- [6] 모바일 전용 위젯 블록 (모바일만) — 공유 위젯 include -->
<data class="v7-mobile-only">
    <?php include __DIR__ . '/widgets/exchange-rate.php'; ?>
    <?php include __DIR__ . '/widgets/company-categories.php'; ?>
    <?php include __DIR__ . '/widgets/latest-companies.php'; ?>
    <?php include __DIR__ . '/widgets/stats.php'; ?>
</data>
```

---

## 9. 위젯 추가 방법

새 위젯을 추가할 때:

1. `v7/widgets/새위젯.php` 파일 생성
2. 독립적인 HTML 블록으로 작성 (외부 변수 의존 최소화)
3. 반응형이 필요하면 `v7-lg`, `v7-xl`, `v7-mobile-only` 클래스 활용
4. `layout.php` 또는 페이지 파일에서 `<?php include __DIR__ . '/widgets/새위젯.php'; ?>` 추가
5. 데스크톱과 모바일 양쪽에서 사용하면 **공유 위젯 패턴** 적용
