# v7 홈페이지 광고 표시 문서

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [광고 배너 위치 전체 구조](#3-광고-배너-위치-전체-구조)
4. [상단 탑 배너 (Top Banner) — 데스크톱](#4-상단-탑-배너-top-banner--데스크톱)
5. [왼쪽/오른쪽 날개 배너 (Wing Banner) — 데스크톱](#5-왼쪽오른쪽-날개-배너-wing-banner--데스크톱)
6. [모바일 상단 배너 (Top Banner — 모바일)](#6-모바일-상단-배너-top-banner--모바일)
7. [모바일 날개 배너 (Wing Banner — 모바일)](#7-모바일-날개-배너-wing-banner--모바일)
8. [게시판 사각 배너 (Square Banner)](#8-게시판-사각-배너-square-banner)
9. [게시판 작은 배너 (Small Banner)](#9-게시판-작은-배너-small-banner)
10. [배너 로테이션 JavaScript](#10-배너-로테이션-javascript)
11. [CSS 전체 코드 (advertisement.css)](#11-css-전체-코드-advertisementcss)
12. [layout.php 통합](#12-layoutphp-통합)
13. [카테고리 변수 전달 패턴](#13-카테고리-변수-전달-패턴)
14. [반응형 디자인](#14-반응형-디자인)
15. [이미지 에러 처리](#15-이미지-에러-처리)
16. [v6 → v7 매핑 테이블](#16-v6--v7-매핑-테이블)

---

## 1. 개요

v7 홈페이지의 광고 표시는 **v6 홈페이지와 100% 동일한 배치와 동작**을 구현한다.
광고 데이터는 `AdvertisementService` (PHP SSR)로 조회하여 서버 사이드에서 렌더링한다.

### 핵심 원칙

| 원칙 | 설명 |
|------|------|
| **SSR 렌더링** | 광고 배너는 PHP에서 `AdvertisementService` 메서드로 조회하여 서버 사이드에서 HTML을 생성한다 |
| **v6 100% 동일** | v6 홈페이지의 광고 배치, 크기, 로테이션 로직을 100% 동일하게 구현한다 |
| **Web Awesome Pro** | Bootstrap 대신 Web Awesome Pro CSS 유틸리티를 사용한다 (**Bootstrap 완전 배제**) |
| **data 속성 로테이션** | `data-adv-group`, `data-adv-fixed` HTML 속성으로 JS 로테이션을 제어한다 |
| **CSS 분리** | 광고 CSS는 `v7/css/advertisement.css` 파일로 분리한다 |

### 배너 4가지 유형 요약

| 타입 | 크기 | 데스크톱 위치 | 모바일 위치 |
|------|------|-------------|------------|
| **Top** | 252×84px (3:1) | 헤더 좌/우 (`layout.header-desktop.php`) | 콘텐츠 상단 2열 (`home.mobile-top-banners.php`) |
| **Wing** | 정사각형 (1:1) | 좌/우 날개 (`layout.wing-left/right.php`) | 4열 그리드 (`home.mobile-wing-banners.php`) |
| **Square** | 정사각형 (1:1) | 게시판 상단 (`square-banners.php`) | 게시판 상단 (동일 위젯) |
| **Small** | 92×46px + 텍스트 | 사각 배너 아래 (`small-banners.php`) | 사각 배너 아래 (동일 위젯) |

---

## 2. 파일 구조

### 2.1 위젯 파일

```
v7/widgets/
├── layout/                              # 레이아웃 위젯 (광고 포함)
│   ├── layout.header-desktop.php        # 데스크톱 헤더 (Top 배너 좌/우 포함)
│   ├── layout.wing-left.php             # 왼쪽 날개 배너
│   └── layout.wing-right.php            # 오른쪽 날개 배너
├── home/                                # 홈페이지 전용 위젯 (모바일 광고)
│   ├── home.mobile-top-banners.php      # 모바일 상단 배너 (2열)
│   └── home.mobile-wing-banners.php     # 모바일 날개 배너 (4열)
└── advertisement/                       # 광고 전용 위젯 (게시판)
    ├── square-banners.php               # 게시판 사각 배너
    └── small-banners.php                # 게시판 작은 배너
```

### 2.2 CSS / JS 파일

```
v7/css/advertisement.css                 # 광고 전용 CSS (모든 배너 스타일)
v7/js/advertisement.js                   # 9초 로테이션 타이머 + data-adv-group 처리
```

### 2.3 레이아웃 / 페이지 파일

```
v7/layout.php                            # advertisement.css + advertisement.js 로드
v7/index.php                             # 홈페이지 (모바일 배너 위젯 include)
v7/post/list.php                         # 게시판 목록 (사각/작은 배너 위젯 include)
```

---

## 3. 광고 배너 위치 전체 구조

### 3.1 데스크톱 레이아웃 (≥ 992px)

```
┌─────────────────────────────────────────────────────────┐
│                       [탑바]                              │
├─────┬───────────────────────────────────────────┬───────┤
│     │  [데스크톱 헤더]                            │       │
│     │  ┌──────────┐              ┌──────────┐    │       │
│     │  │ Top 배너  │   로고/검색   │ Top 배너  │    │       │
│ 왼  │  │ (왼쪽)    │              │ (오른쪽)   │    │  오   │
│ 쪽  │  └──────────┘              └──────────┘    │  른   │
│ 날  ├───────────────────────────────────────────┤  쪽   │
│ 개  │  [본문 영역]                                │  날   │
│ 배  │  ┌──────────────────────────────────┐      │  개   │
│ 너  │  │ [Square 배너] (게시판 1페이지만)   │      │  배   │
│     │  │ [Small 배너] (게시판 1페이지만)    │      │  너   │
│ W   │  │ [게시판 콘텐츠]                    │      │      │
│ i   │  └──────────────────────────────────┘      │  W   │
│ n   │                                            │  i   │
│ g   │                                            │  n   │
│     │                                            │  g   │
└─────┴────────────────────────────────────────────┴──────┘
```

### 3.2 모바일 레이아웃 (< 992px)

```
┌──────────────────────────┐
│        [탑바]             │
├──────────────────────────┤
│     [모바일 헤더]          │
├──────────────────────────┤
│ ┌──────────┬───────────┐ │
│ │ Top 배너  │ Top 배너   │ │  ← home.mobile-top-banners.php
│ │ (왼쪽)    │ (오른쪽)    │ │
│ └──────────┴───────────┘ │
├──────────────────────────┤
│ [뉴스 탭/콘텐츠]           │
├──────────────────────────┤
│ ┌─────┬─────┬─────┬────┐│
│ │Wing │Wing │Wing │Wing││  ← home.mobile-wing-banners.php
│ │ 1   │ 2   │ 3   │ 4  ││
│ └─────┴─────┴─────┴────┘│
├──────────────────────────┤
│ [게시판 목록]              │
│ ┌──────────────────────┐ │
│ │ [Square 배너]         │ │  ← square-banners.php
│ │ [Small 배너]          │ │  ← small-banners.php
│ │ [글 목록]              │ │
│ └──────────────────────┘ │
└──────────────────────────┘
```

---

## 4. 상단 탑 배너 (Top Banner) — 데스크톱

### 4.1 위치 및 사양

- **위젯 파일**: `v7/widgets/layout/layout.header-desktop.php`
- **크기**: 너비 252px × 높이 84px (비율 3:1)
- **위치**: 데스크톱 헤더 양측 (로고/검색 좌우)
- **로테이션**: 9초마다 배너 교체 (`data-adv-group` 속성 사용)
- **CSS 클래스**: `.v7-top-banner`

### 4.2 실제 구현 코드

```php
<!-- v7/widgets/layout/layout.header-desktop.php (핵심 부분) -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_adCategory = $v7_ad_category ?? $_GET['category'] ?? $_GET['post_id'] ?? null;
$_topBanners = AdvertisementService::getTopBanners($_adCategory);
?>
<div class="v7-lg">
    <div class="v7-logo-area">
        <!-- 왼쪽 배너 -->
        <div class="v7-top-banner">
            <?php if (!empty($_topBanners['left'])): ?>
                <?php foreach ($_topBanners['left'] as $_i => $_tb): ?>
                    <a href="<?= htmlspecialchars($_tb->clickUrl) ?>"
                       <?= $_tb->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>
                       data-adv-group="top-left-desktop"
                       data-adv-fixed="<?= $_topBanners['left_fixed'] ? 'true' : 'false' ?>"
                       <?= $_i > 0 ? 'class="adv-hidden"' : '' ?>>
                        <img src="<?= htmlspecialchars($_tb->imageUrl) ?>"
                             alt="필고 상단 배너"
                             onerror="this.onerror=null; this.src='/res/img/x.webp';">
                    </a>
                <?php endforeach; ?>
            <?php else: ?>
                <div class="v7-banner-placeholder" style="height:80px; width:252px;">상단 배너 L</div>
            <?php endif; ?>
        </div>

        <!-- 로고 + 검색 -->
        <div class="v7-logo-center">
            <!-- ... 로고, 검색 폼 ... -->
        </div>

        <!-- 오른쪽 배너 -->
        <div class="v7-top-banner">
            <?php if (!empty($_topBanners['right'])): ?>
                <?php foreach ($_topBanners['right'] as $_i => $_tb): ?>
                    <a href="<?= htmlspecialchars($_tb->clickUrl) ?>"
                       <?= $_tb->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>
                       data-adv-group="top-right-desktop"
                       data-adv-fixed="<?= $_topBanners['right_fixed'] ? 'true' : 'false' ?>"
                       <?= $_i > 0 ? 'class="adv-hidden"' : '' ?>>
                        <img src="<?= htmlspecialchars($_tb->imageUrl) ?>"
                             alt="필고 상단 배너"
                             onerror="this.onerror=null; this.src='/res/img/x.webp';">
                    </a>
                <?php endforeach; ?>
            <?php else: ?>
                <div class="v7-banner-placeholder" style="height:80px; width:252px;">상단 배너 R</div>
            <?php endif; ?>
        </div>
    </div>
</div>
```

### 4.3 핵심 HTML 속성

| 속성 | 값 | 설명 |
|------|-----|------|
| `data-adv-group` | `"top-left-desktop"` / `"top-right-desktop"` | 배너 그룹 식별자 (JS 로테이션 대상) |
| `data-adv-fixed` | `"true"` / `"false"` | 고정 배너 여부 (`true`이면 로테이션 제외) |
| `class="adv-hidden"` | — | 첫 번째 이후 배너에 적용 (CSS `display:none`) |

---

## 5. 왼쪽/오른쪽 날개 배너 (Wing Banner) — 데스크톱

### 5.1 위치 및 사양

- **위젯 파일**: `v7/widgets/layout/layout.wing-left.php`, `layout.wing-right.php`
- **크기**: 120px 너비 × 정사각형 (1:1 비율, `aspect-ratio: 1`)
- **위치**: 페이지 양측 날개 (데스크톱 ≥ 992px만, `v7-lg` 클래스)
- **로테이션**: 없음 (정적 표시)
- **CSS 클래스**: `.v7-wing`, `.wing-item`

### 5.2 왼쪽 날개 배너 실제 코드

```php
<!-- v7/widgets/layout/layout.wing-left.php -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_adCategory = $v7_ad_category ?? $_GET['category'] ?? $_GET['post_id'] ?? null;
$_wingBanners = AdvertisementService::getWingBanners($_adCategory);
$_leftWings = $_wingBanners['left'] ?? [];
?>
<aside class="v7-wing v7-lg" id="left-wing">
    <?php if (!empty($_leftWings)): ?>
        <?php foreach ($_leftWings as $_wb): ?>
            <div class="wing-item">
                <a href="<?= htmlspecialchars($_wb->clickUrl) ?>"
                   <?= $_wb->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>>
                    <img src="<?= htmlspecialchars($_wb->imageUrl) ?>"
                         alt="필고 왼쪽 날개 배너"
                         loading="lazy"
                         onerror="this.onerror=null; this.src='/res/img/x.webp';">
                </a>
            </div>
        <?php endforeach; ?>
    <?php else: ?>
        <div class="wing-item"><div class="v7-banner-placeholder" style="height:120px;"></div></div>
        <div class="wing-item"><div class="v7-banner-placeholder" style="height:120px;"></div></div>
        <div class="wing-item"><div class="v7-banner-placeholder" style="height:120px;"></div></div>
    <?php endif; ?>
</aside>
```

### 5.3 오른쪽 날개 배너

`layout.wing-right.php`는 왼쪽과 동일한 구조이며, `$_wingBanners['right']`를 사용하고 `id="right-wing"`이다.

---

## 6. 모바일 상단 배너 (Top Banner — 모바일)

### 6.1 위치 및 사양

- **위젯 파일**: `v7/widgets/home/home.mobile-top-banners.php`
- **위치**: 홈페이지 콘텐츠 최상단 (모바일 `< 992px`만, `v7-mobile-only` 클래스)
- **로테이션**: 9초마다 배너 교체 (`data-adv-group` 사용)
- **CSS 클래스**: `.v7-mobile-banners`

### 6.2 실제 구현 코드

```php
<!-- v7/widgets/home/home.mobile-top-banners.php -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_topBanners = AdvertisementService::getTopBanners(null);
$_leftBanners = $_topBanners['left'] ?? [];
$_rightBanners = $_topBanners['right'] ?? [];
?>
<div class="v7-mobile-only">
    <div class="v7-mobile-banners" style="margin-top:8px;">
        <?php if (!empty($_leftBanners)): ?>
            <?php foreach ($_leftBanners as $_i => $_mb): ?>
                <a href="<?= htmlspecialchars($_mb->clickUrl) ?>"
                   <?= $_mb->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>
                   data-adv-group="top-left-mobile"
                   data-adv-fixed="<?= $_topBanners['left_fixed'] ? 'true' : 'false' ?>"
                   <?= $_i > 0 ? 'class="adv-hidden"' : '' ?>>
                    <img src="<?= htmlspecialchars($_mb->imageUrl) ?>"
                         alt="필고 모바일 배너"
                         onerror="this.onerror=null; this.src='/res/img/x.webp';">
                </a>
            <?php endforeach; ?>
        <?php else: ?>
            <div class="v7-banner-placeholder" style="height:80px;"></div>
        <?php endif; ?>

        <?php if (!empty($_rightBanners)): ?>
            <?php foreach ($_rightBanners as $_i => $_mb): ?>
                <a href="<?= htmlspecialchars($_mb->clickUrl) ?>"
                   <?= $_mb->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>
                   data-adv-group="top-right-mobile"
                   data-adv-fixed="<?= $_topBanners['right_fixed'] ? 'true' : 'false' ?>"
                   <?= $_i > 0 ? 'class="adv-hidden"' : '' ?>>
                    <img src="<?= htmlspecialchars($_mb->imageUrl) ?>"
                         alt="필고 모바일 배너"
                         onerror="this.onerror=null; this.src='/res/img/x.webp';">
                </a>
            <?php endforeach; ?>
        <?php else: ?>
            <div class="v7-banner-placeholder" style="height:80px;"></div>
        <?php endif; ?>
    </div>
</div>
```

### 6.3 홈페이지 전용 (category=null)

모바일 상단 배너는 홈페이지(`v7/index.php`)에서만 사용되므로, `AdvertisementService::getTopBanners(null)`로 호출한다.
카테고리가 null이면 all_page 배너만 표시된다.

---

## 7. 모바일 날개 배너 (Wing Banner — 모바일)

### 7.1 위치 및 사양

- **위젯 파일**: `v7/widgets/home/home.mobile-wing-banners.php`
- **위치**: 홈페이지 뉴스 탭 아래 (모바일 `< 992px`만)
- **레이아웃**: 좌우 날개 배너를 합쳐서 4열 그리드
- **CSS 클래스**: `.v7-mobile-wing-banners`

### 7.2 실제 구현 코드

```php
<!-- v7/widgets/home/home.mobile-wing-banners.php -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_wingResult = AdvertisementService::getWingBanners(null);
$_allWings = array_merge($_wingResult['left'] ?? [], $_wingResult['right'] ?? []);
?>
<div class="v7-mobile-only">
    <div class="v7-mobile-wing-banners">
        <?php if (!empty($_allWings)): ?>
            <?php foreach ($_allWings as $_mw): ?>
                <a href="<?= htmlspecialchars($_mw->clickUrl) ?>"
                   <?= $_mw->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>>
                    <img src="<?= htmlspecialchars($_mw->imageUrl) ?>"
                         alt="필고 모바일 날개 배너"
                         loading="lazy"
                         onerror="this.onerror=null; this.src='/res/img/x.webp';">
                </a>
            <?php endforeach; ?>
        <?php else: ?>
            <div class="v7-banner-placeholder">광고1</div>
            <div class="v7-banner-placeholder">광고2</div>
            <div class="v7-banner-placeholder">광고3</div>
            <div class="v7-banner-placeholder">광고4</div>
        <?php endif; ?>
    </div>
</div>
```

---

## 8. 게시판 사각 배너 (Square Banner)

### 8.1 위치 및 사양

- **위젯 파일**: `v7/widgets/advertisement/square-banners.php`
- **크기**: 정사각형 (1:1 비율)
- **위치**: 게시판 글 목록 상단 (`v7/post/list.php`에서 include)
- **표시 조건**: 1페이지에서만 표시
- **반응형**: 데스크톱 5열, 모바일 4열 (배너 3개 이하면 3열)
- **CSS 클래스**: `.v7-square-banners`, `.sq-cols-3`

### 8.2 실제 구현 코드

```php
<!-- v7/widgets/advertisement/square-banners.php -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_adCategory = $v7_ad_category ?? $_GET['category'] ?? $_GET['post_id'] ?? null;
$_squareBanners = AdvertisementService::getSquareBanners($_adCategory);

if (empty($_squareBanners)): ?>
<?php return; endif; ?>

<?php
$_sqCount = count($_squareBanners);
$_sqColClass = $_sqCount <= 3 ? 'sq-cols-3' : '';
?>
<div class="v7-square-banners <?= $_sqColClass ?>">
    <?php foreach ($_squareBanners as $_sqBanner): ?>
        <a href="<?= htmlspecialchars($_sqBanner->clickUrl) ?>"
           <?= $_sqBanner->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>>
            <img src="<?= htmlspecialchars($_sqBanner->imageUrl) ?>"
                 alt="필고 사각 배너"
                 loading="lazy"
                 onerror="this.onerror=null; this.src='/res/img/x.webp';">
        </a>
    <?php endforeach; ?>
</div>
```

### 8.3 열 수 규칙

| 조건 | 모바일 열 | 데스크톱 열 | CSS 클래스 |
|------|----------|-----------|-----------|
| 배너 ≤ 3개 | 3열 | 5열 | `.sq-cols-3` 추가 |
| 배너 > 3개 | 4열 | 5열 | (기본) |

---

## 9. 게시판 작은 배너 (Small Banner)

### 9.1 위치 및 사양

- **위젯 파일**: `v7/widgets/advertisement/small-banners.php`
- **크기**: 이미지 92×46px + primary/secondary 텍스트
- **위치**: 사각 배너 아래 (`v7/post/list.php`에서 include)
- **표시 조건**: 1페이지에서만 표시
- **텍스트 절단**: `mb_strimwidth()`로 45자 초과 시 `...` 표시
- **CSS 클래스**: `.v7-small-banners`, `.small-banner-text`, `.small-banner-primary`, `.small-banner-secondary`

### 9.2 실제 구현 코드

```php
<!-- v7/widgets/advertisement/small-banners.php -->
<?php
use Philgo\Advertisement\AdvertisementService;

$_adCategory = $v7_ad_category ?? $_GET['category'] ?? $_GET['post_id'] ?? null;
$_smallBanners = AdvertisementService::getSmallBanners($_adCategory);

if (empty($_smallBanners)): ?>
<?php return; endif; ?>

<div class="v7-small-banners">
    <?php foreach ($_smallBanners as $_smBanner): ?>
        <a href="<?= htmlspecialchars($_smBanner->clickUrl) ?>"
           <?= $_smBanner->target ? 'target="_blank" rel="noopener noreferrer"' : '' ?>>
            <img src="<?= htmlspecialchars($_smBanner->imageUrl) ?>"
                 alt="필고 작은 배너"
                 loading="lazy"
                 onerror="this.onerror=null; this.src='/res/img/x.webp';">
            <div class="small-banner-text">
                <?php if (!empty($_smBanner->primary)): ?>
                    <div class="small-banner-primary">
                        <?= htmlspecialchars(mb_strimwidth($_smBanner->primary, 0, 45, '...')) ?>
                    </div>
                <?php endif; ?>
                <?php if (!empty($_smBanner->secondary)): ?>
                    <div class="small-banner-secondary">
                        <?= htmlspecialchars(mb_strimwidth($_smBanner->secondary, 0, 45, '...')) ?>
                    </div>
                <?php endif; ?>
            </div>
        </a>
    <?php endforeach; ?>
</div>
```

---

## 10. 배너 로테이션 JavaScript

### 10.1 파일 위치

`v7/js/advertisement.js` — `layout.php`에서 `defer`로 로드

### 10.2 전체 코드

```javascript
(function () {
    'use strict';

    let counter = 0;

    // 9초마다 adv:tick 이벤트 발생
    setInterval(function () {
        counter++;
        document.dispatchEvent(new CustomEvent('adv:tick', {
            detail: { counter: counter }
        }));
    }, 9000);

    // adv:tick 이벤트 처리: data-adv-group으로 배너 그룹 식별
    document.addEventListener('adv:tick', function (e) {
        var tickCounter = e.detail.counter;

        // 모든 배너 그룹을 찾아서 로테이션
        var groups = document.querySelectorAll('[data-adv-group]');
        var processed = {};

        groups.forEach(function (el) {
            var group = el.getAttribute('data-adv-group');
            if (processed[group]) return;
            processed[group] = true;

            // 고정 배너는 로테이션 제외
            var isFixed = el.getAttribute('data-adv-fixed') === 'true';
            if (isFixed) return;

            // 같은 그룹의 모든 배너를 찾아서 순환
            var banners = document.querySelectorAll('[data-adv-group="' + group + '"]');
            if (banners.length <= 1) return;

            banners.forEach(function (banner, index) {
                if (index === tickCounter % banners.length) {
                    banner.classList.remove('adv-hidden');
                } else {
                    banner.classList.add('adv-hidden');
                }
            });
        });
    });
})();
```

### 10.3 로테이션 동작 원리

1. **타이머**: 9초마다 `counter++` → `adv:tick` CustomEvent 발행
2. **그룹 탐색**: `document.querySelectorAll('[data-adv-group]')`로 모든 배너 요소 탐색
3. **중복 방지**: `processed` 객체로 동일 그룹 중복 처리 방지
4. **고정 배너 제외**: `data-adv-fixed="true"` 속성이면 로테이션 건너뜀
5. **순환 표시**: `counter % banners.length`로 현재 표시할 인덱스 결정 → `adv-hidden` 클래스 토글

### 10.4 배너 그룹 목록

| data-adv-group 값 | 위젯 | 설명 |
|-------------------|------|------|
| `top-left-desktop` | `layout.header-desktop.php` | 데스크톱 헤더 왼쪽 배너 |
| `top-right-desktop` | `layout.header-desktop.php` | 데스크톱 헤더 오른쪽 배너 |
| `top-left-mobile` | `home.mobile-top-banners.php` | 모바일 상단 왼쪽 배너 |
| `top-right-mobile` | `home.mobile-top-banners.php` | 모바일 상단 오른쪽 배너 |

### 10.5 CSS 숨김 클래스

```css
/* 로테이션 대상 배너 중 현재 표시되지 않는 배너 */
.adv-hidden {
    display: none;
}
```

이 클래스는 `.v7-top-banner .adv-hidden`과 `.v7-mobile-banners .adv-hidden`에 정의되어 있다.

### 10.6 v6과의 차이

| 항목 | v6 | v7 |
|------|-----|-----|
| **로테이션 방식** | 각 위젯에 인라인 `<script>` | `data-adv-group` 속성 + 별도 JS 파일 |
| **그룹 식별** | CSS 클래스 + 인라인 querySelector | `data-adv-group` HTML 속성 |
| **고정 제어** | PHP → JS 변수 직접 주입 | `data-adv-fixed` HTML 속성 |
| **이벤트** | `adv:tick` CustomEvent | 동일 (`adv:tick`) |
| **간격** | 9초 | 동일 (9초) |

---

## 11. CSS 전체 코드 (advertisement.css)

**파일**: `v7/css/advertisement.css`

```css
/* ===== 상단 탑 배너 (데스크톱 헤더 내) ===== */
.v7-top-banner a {
    display: block;
}
.v7-top-banner img {
    width: 100%;
    max-height: 84px;
    object-fit: fill;
    border-radius: 4px;
    display: block;
}
.v7-top-banner .adv-hidden {
    display: none;
}

/* ===== 날개 배너 (데스크톱 좌/우) ===== */
.v7-wing .wing-item a {
    display: block;
}
.v7-wing .wing-item img {
    width: 100%;
    height: auto;
    aspect-ratio: 1;
    object-fit: fill;
    display: block;
    border-radius: 4px;
}

/* ===== 모바일 상단 배너 ===== */
.v7-mobile-banners {
    display: flex;
    gap: 4px;
    padding: 0 8px;
}
.v7-mobile-banners a {
    flex: 1;
    display: block;
}
.v7-mobile-banners img {
    width: 100%;
    height: auto;
    max-height: 80px;
    object-fit: fill;
    border-radius: 4px;
    display: block;
}
.v7-mobile-banners .adv-hidden {
    display: none;
}

/* ===== 모바일 날개 배너 (4열 그리드) ===== */
.v7-mobile-wing-banners {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 4px;
    padding: 0 8px;
    margin-top: 16px;
    margin-bottom: 16px;
}
.v7-mobile-wing-banners a {
    display: block;
}
.v7-mobile-wing-banners img {
    width: 100%;
    aspect-ratio: 1;
    object-fit: fill;
    border-radius: 4px;
    display: block;
}

/* ===== 사각 배너 (게시판 상단) ===== */
.v7-square-banners {
    display: grid;
    gap: 4px;
    margin-bottom: 16px;
}
@media (min-width: 992px) {
    .v7-square-banners {
        grid-template-columns: repeat(5, 1fr);  /* 데스크톱: 5열 */
    }
}
@media (max-width: 991.98px) {
    .v7-square-banners {
        grid-template-columns: repeat(4, 1fr);  /* 모바일: 4열 */
        padding: 0 4px;
    }
    .v7-square-banners.sq-cols-3 {
        grid-template-columns: repeat(3, 1fr);  /* 배너 ≤ 3개: 3열 */
    }
}
.v7-square-banners a {
    display: block;
}
.v7-square-banners img {
    width: 100%;
    aspect-ratio: 1;
    object-fit: fill;
    border-radius: 4px;
    display: block;
}

/* ===== 작은 배너 (게시판, 사각 배너 아래) ===== */
.v7-small-banners {
    margin-bottom: 16px;
}
.v7-small-banners a {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 6px 0;
    text-decoration: none;
    color: var(--wa-color-text, inherit);
}
.v7-small-banners a:hover {
    opacity: 0.85;
}
.v7-small-banners img {
    width: 92px;
    height: 46px;
    object-fit: cover;
    border-radius: 4px;
    flex-shrink: 0;
}
.v7-small-banners .small-banner-text {
    overflow: hidden;
    min-width: 0;
}
.v7-small-banners .small-banner-primary {
    font-size: 0.85em;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.v7-small-banners .small-banner-secondary {
    font-size: 0.75em;
    color: var(--wa-color-text-quiet, #666);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
@media (max-width: 991.98px) {
    .v7-small-banners {
        padding: 0 8px;
    }
}
```

---

## 12. layout.php 통합

### 12.1 CSS 로드

`v7/layout.php`에서 광고 CSS를 로드한다:

```php
<link rel="stylesheet" href="/v7/css/advertisement.css?v=<?= CACHE_VERSION ?>">
```

위치: 다른 CSS 파일들 뒤에 추가 (pagination.css 다음)

### 12.2 JS 로드

`v7/layout.php`에서 광고 JS를 `defer`로 로드한다:

```php
<script defer src="/v7/js/advertisement.js?v=<?= CACHE_VERSION ?>"></script>
```

위치: `v7api.js` 다음에 추가

---

## 13. 카테고리 변수 전달 패턴

### 13.1 $v7_ad_category 변수

배너 위젯이 현재 페이지의 카테고리(게시판)를 인식하도록 `$v7_ad_category` PHP 변수를 사용한다.

### 13.2 설정 위치

**게시판 목록** (`v7/post/list.php`):

```php
<?php
// 광고 카테고리 설정 (배너 위젯에서 사용)
$v7_ad_category = $category ?? $postId;
?>
<div class="v7-post-list-page">
    <?php if ($page <= 1): ?>
        <?php include __DIR__ . '/../widgets/advertisement/square-banners.php'; ?>
        <?php include __DIR__ . '/../widgets/advertisement/small-banners.php'; ?>
    <?php endif; ?>
    <!-- ... 게시판 글 목록 ... -->
```

### 13.3 위젯 내부에서 읽기

모든 광고 위젯에서 동일한 패턴으로 카테고리를 읽는다:

```php
$_adCategory = $v7_ad_category ?? $_GET['category'] ?? $_GET['post_id'] ?? null;
```

우선순위:
1. `$v7_ad_category` (PHP 변수로 명시적 설정)
2. `$_GET['category']` (URL 파라미터)
3. `$_GET['post_id']` (URL 파라미터)
4. `null` (카테고리 없음 → all_page 배너만 표시)

### 13.4 위젯별 카테고리 설정

| 위젯 | 카테고리 전달 | 설명 |
|------|-------------|------|
| `layout.header-desktop.php` | `$v7_ad_category` 또는 `$_GET` | 모든 페이지 |
| `layout.wing-left.php` | `$v7_ad_category` 또는 `$_GET` | 모든 페이지 |
| `layout.wing-right.php` | `$v7_ad_category` 또는 `$_GET` | 모든 페이지 |
| `home.mobile-top-banners.php` | `null` 고정 | 홈페이지 전용 |
| `home.mobile-wing-banners.php` | `null` 고정 | 홈페이지 전용 |
| `square-banners.php` | `$v7_ad_category` 또는 `$_GET` | 게시판 목록 |
| `small-banners.php` | `$v7_ad_category` 또는 `$_GET` | 게시판 목록 |

---

## 14. 반응형 디자인

### 14.1 브레이크포인트 (v7 커스텀, Bootstrap 미사용)

| 클래스 | 조건 | 설명 |
|--------|------|------|
| `v7-mobile-only` | `< 992px` | 모바일에서만 표시 |
| `v7-lg` | `≥ 992px` | 데스크톱에서만 표시 |
| `v7-xl` | `≥ 1200px` | 대형 데스크톱에서만 표시 |

### 14.2 배너별 반응형 동작

| 배너 | 데스크톱 (≥ 992px) | 모바일 (< 992px) |
|------|-------------------|------------------|
| **Top** | 헤더 좌/우 252×84px | 콘텐츠 상단 flex 2열 |
| **Wing** | 좌/우 날개 120px (1:1) | 4열 grid (`repeat(4, 1fr)`) |
| **Square** | 5열 grid | 4열 (3개 이하면 3열) |
| **Small** | 이미지(92×46)+텍스트 가로 배치 | 동일 (padding 8px 추가) |

---

## 15. 이미지 에러 처리

v7 광고 배너에서는 이미지 로드 실패 시 **대체 이미지**(`/res/img/x.webp`)를 표시한다:

```html
<img src="..."
     onerror="this.onerror=null; this.src='/res/img/x.webp';">
```

- `this.onerror=null`: 대체 이미지도 실패 시 무한 루프 방지
- `/res/img/x.webp`: 기본 대체 이미지 (v6 `attr_onerror_xbox()` 대신 인라인 사용)

---

## 16. v6 → v7 매핑 테이블

### 16.1 위젯 파일 매핑

| v6 파일 | v7 파일 |
|---------|---------|
| `widgets/advertisement/top-banner.php` | `v7/widgets/layout/layout.header-desktop.php` (데스크톱 헤더에 통합) |
| `widgets/advertisement/mobile-top-banners.php` | `v7/widgets/home/home.mobile-top-banners.php` |
| `widgets/advertisement/square-banners.php` | `v7/widgets/advertisement/square-banners.php` |
| `widgets/advertisement/small-banners.php` | `v7/widgets/advertisement/small-banners.php` |
| `widgets/advertisement/mobile-home-wing-banners.php` | `v7/widgets/home/home.mobile-wing-banners.php` |
| `widgets/wing/philgo-left-wing.php` | `v7/widgets/layout/layout.wing-left.php` |
| `widgets/wing/philgo-right-wing.php` | `v7/widgets/layout/layout.wing-right.php` |

### 16.2 함수/클래스 매핑

| v6 함수 | v7 클래스/메서드 |
|---------|-----------------|
| `get_top_banners()` | `AdvertisementService::getTopBanners()` |
| `get_wing_banners()` | `AdvertisementService::getWingBanners()` |
| `get_square_banners()` | `AdvertisementService::getSquareBanners()` |
| `get_small_banners()` | `AdvertisementService::getSmallBanners()` |
| `get_all_active_advertisements()` | `AdvertisementRepository::findAllActiveBanners()` |
| `filter_banners()` | `AdvertisementService::filterBanners()` (private) |
| `get_advertisement_url()` | `BannerEntity::resolveClickUrl()` |
| `get_advertisement_target()` | `BannerEntity::resolveTarget()` |
| `BannerModel` | `BannerEntity` |
| `create_advertisement()` | `AdvertisementService::update()` |
| `add_banner()` | `AdvertisementService::addBanner()` |
| `update_banner()` | `AdvertisementService::updateBanner()` |
| `delete_banner_from_user_input()` | `AdvertisementService::deleteBanner()` |

### 16.3 CSS 클래스 매핑 (Bootstrap → v7 커스텀)

| v6 (Bootstrap) | v7 (커스텀 CSS) |
|----------------|----------------|
| `d-none d-lg-block` | `v7-lg` |
| `d-lg-none` | `v7-mobile-only` |
| `col-6` | `flex: 1` (모바일 배너) |
| `col-3` | `grid-template-columns: repeat(4, 1fr)` |
| `row g-1` | `display: flex; gap: 4px;` |
| `ratio ratio-1x1` | `aspect-ratio: 1` |
| `d-flex align-items-center gap-3` | `display: flex; align-items: center; gap: 12px;` |
| `text-truncate` | `overflow: hidden; text-overflow: ellipsis; white-space: nowrap;` |
| `rounded` | `border-radius: 4px` |

### 16.4 JavaScript 매핑

| v6 | v7 |
|----|-----|
| 각 위젯 내부 인라인 `<script>` | `v7/js/advertisement.js` 별도 파일 (defer 로드) |
| CSS 클래스 기반 querySelector | `data-adv-group` 속성 기반 querySelector |
| `isFixed` PHP → JS 변수 주입 | `data-adv-fixed` HTML 속성 |
| `display:none` / `display:''` 인라인 스타일 | `.adv-hidden` CSS 클래스 토글 |

### 16.5 페이지 include 순서

**홈페이지 (`v7/index.php`)**:
```php
<?php include __DIR__ . '/widgets/home/home.mobile-top-banners.php'; ?>   <!-- [1] 모바일 상단 배너 -->
<?php include __DIR__ . '/widgets/home/home.news-tabs.php'; ?>            <!-- [2] 뉴스 탭 -->
<?php include __DIR__ . '/widgets/home/home.mobile-wing-banners.php'; ?>  <!-- [3] 모바일 날개 배너 -->
<?php include __DIR__ . '/widgets/home/home.latest-posts.php'; ?>         <!-- [4] 최신 게시글 -->
<?php include __DIR__ . '/widgets/home/home.popular-posts.php'; ?>        <!-- [5] 인기 게시글 -->
```

**게시판 목록 (`v7/post/list.php`)**:
```php
<?php $v7_ad_category = $category ?? $postId; ?>
<?php if ($page <= 1): ?>
    <?php include __DIR__ . '/../widgets/advertisement/square-banners.php'; ?>  <!-- [1] 사각 배너 -->
    <?php include __DIR__ . '/../widgets/advertisement/small-banners.php'; ?>   <!-- [2] 작은 배너 -->
<?php endif; ?>
<!-- [3] 게시판 헤더 -->
<!-- [4] 글 목록 -->
```
