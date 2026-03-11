# v7 레이아웃 시스템 완전 레퍼런스

> **이 문서의 목적**: v7 홈페이지의 5-column flex 레이아웃 구조, CSS 규칙, 반응형 전략을 완전히 문서화한다.
> **작업 시 이 문서를 반드시 참조하여 레이아웃이 흐트러지지 않도록 한다.**

## 목차

1. [설계 원칙](#1-설계-원칙)
2. [CSS 변수 (디자인 토큰)](#2-css-변수-디자인-토큰)
3. [실행 흐름](#3-실행-흐름)
4. [DOM 트리 구조](#4-dom-트리-구조)
5. [5-Column 레이아웃 상세](#5-5-column-레이아웃-상세)
6. [각 영역별 CSS 규칙](#6-각-영역별-css-규칙)
7. [반응형 브레이크포인트](#7-반응형-브레이크포인트)
8. [색상 팔레트](#8-색상-팔레트)
9. [폰트 크기 체계](#9-폰트-크기-체계)
10. [위젯 포함 관계도](#10-위젯-포함-관계도)
11. [layout.php 핵심 소스코드](#11-layoutphp-핵심-소스코드)
12. [CSS 파일별 핵심 코드](#12-css-파일별-핵심-코드)
13. [레이아웃 수정 시 절대 규칙](#13-레이아웃-수정-시-절대-규칙)
14. [새 페이지 추가 시 체크리스트](#14-새-페이지-추가-시-체크리스트)

---

## 1. 설계 원칙

| 원칙 | 설명 |
|------|------|
| **Bootstrap 완전 배제** | v7은 Bootstrap CSS를 사용하지 않는다. Web Awesome Pro + 커스텀 CSS 3파일로 구현 |
| **v6 구조 재현** | v6의 5-column 레이아웃 구조, 색상, 간격을 정확히 재현 |
| **CSS 변수 기반** | 핵심 치수는 모두 CSS 변수(`--v7-*`)로 관리하여 유지보수 용이 |
| **3파일 분리** | `layout.css`(구조) + `responsive.css`(반응형) + `utilities.css`(유틸리티) 명확 분리 |
| **모바일 대응** | 992px(lg) 기준 모바일/데스크톱 전환, 1200px(xl) 기준 오른쪽 사이드바 표시 |

---

## 2. CSS 변수 (디자인 토큰)

### v7 커스텀 변수 (`layout.css :root`)

```css
:root {
    color-scheme: light;            /* v7은 라이트 모드 전용 (다크 모드 미적용) */
    --v7-sidebar-width: 240px;      /* 좌/우 사이드바 너비 */
    --v7-wing-width: 120px;         /* 좌/우 날개 배너 너비 */
    --v7-gap: 16px;                 /* 모든 컬럼/섹션 간격 */
    --v7-max-width: 1320px;         /* 페이지 최대 너비 */
    --v7-topbar-height: 2.25rem;    /* 탑바 높이 (~36px) */
}
```

> **⛔ 절대 규칙**: v7 홈페이지는 **다크 모드를 적용하지 않는다.** `color-scheme`은 `light`만 지정하며, `@media (prefers-color-scheme: dark)` 미디어 쿼리를 작성하지 않는다. Web Awesome의 다크 테마 클래스(`wa-theme-dark`)도 적용하지 않는다.

### Web Awesome 변수 (폴백 값 포함)

| 변수 | 폴백 | 용도 |
|------|------|------|
| `--wa-color-text` | `#212529` | 본문 텍스트 |
| `--wa-color-surface-default` | `#fff` | 기본 배경 |
| `--wa-color-neutral-fill-quiet` | `#f0f0f0` | 약한 배경 (위젯 제목, 배너) |
| `--wa-color-neutral-border-normal` | `#e0e0e0` | 테두리 |
| `--wa-color-text-quiet` | `#999` | 약한 텍스트 (날짜, 설명) |
| `--wa-color-surface-lowered` | `#f8f8f8` | 낮은 배경 (푸터) |

> **⛔ 절대 규칙**: 이 변수들의 값을 임의로 변경하면 전체 레이아웃이 깨진다. 변경 시 반드시 모든 영역에서 영향을 확인할 것.

---

## 3. 실행 흐름

```
HTTP 요청 → Nginx rewrite → v7.php (프론트 컨트롤러)
    ├─ include v7/boot.php
    │   ├─ 타임존 설정 (Asia/Seoul)
    │   ├─ ROOT_DIR 상수 정의
    │   ├─ Composer PSR-4 오토로더 (vendor/autoload.php)
    │   └─ 설정 상수 (constants.php, app.config.php)
    │
    └─ include v7/layout.php
        ├─ cache-version.php (CACHE_VERSION 상수)
        ├─ Route::getInstance() → URI 파싱, 페이지 파일 결정
        ├─ $isHomePage 판단
        ├─ ob_start() → include $pageFile → $content = ob_get_clean()
        └─ HTML 출력 (head + body + 위젯 include + $content 삽입)
```

**개발 환경 접속 URL**: `https://v7-local.philgo.com`

---

## 4. DOM 트리 구조

```
<body>
│
├── [탑바] .v7-topbar.v7-lg (position: fixed, top: 0)
│   └── .v7-topbar-outer (max-width: 1320px)
│       ├── .v7-topbar-spacer (120px, xl에서만 표시)
│       ├── .v7-topbar-inner (flex-grow: 1, border, border-radius)
│       │   ├── <nav> 좌측 메뉴 (홈, 질문답변, 커뮤니티, 채팅)
│       │   └── <nav> 우측 메뉴 (디자인, WebAwesome, 문의하기, 메뉴)
│       └── .v7-topbar-spacer (120px, xl에서만 표시)
│
└── .v7-page-wrapper (max-width: 1320px, margin: 0 auto)
    └── .v7-layout (display: flex, gap: 16px)
        │
        ├── [A] .v7-wing.v7-lg (120px) ← wing-left.php
        │
        ├── [B] .v7-center (flex: 1, min-width: 0)
        │   │
        │   ├── [B-1] <header class="v7-header"> (padding-top: 탑바 높이)
        │   │   ├── header-mobile.php (.v7-mobile-only)
        │   │   └── header-desktop.php (.v7-lg)
        │   │       ├── .v7-logo-area (로고+검색+배너)
        │   │       └── .v7-main-menu (4열 grid 메뉴)
        │   │
        │   └── [B-2] .v7-body (display: flex, gap: 16px)
        │       ├── [B-2-a] .v7-sidebar.v7-lg (240px) ← sidebar-left.php
        │       ├── [B-2-b] <main class="v7-main"> (flex: 1) ← $content
        │       └── [B-2-c] .v7-sidebar.v7-xl (240px, 홈만) ← sidebar-right.php
        │
        └── [C] .v7-wing.v7-lg (120px) ← wing-right.php

[D] .v7-footer ← footer.php (v7-page-wrapper 바깥)
```

---

## 5. 5-Column 레이아웃 상세

### 데스크톱 (≥ 992px) — ASCII 다이어그램

```
┌──────────────────────────────────────────────────────────────────┐
│                    .v7-topbar (fixed, z:1030)                     │
├──────────────────────────────────────────────────────────────────┤
│ .v7-page-wrapper (max-width: 1320px, margin: 0 auto)            │
│ ┌──────────────────────────────────────────────────────────────┐ │
│ │ .v7-layout (display: flex; gap: 16px)                        │ │
│ │                                                               │ │
│ │ ┌─────┐ ┌─────────────────────────────────────────┐ ┌─────┐ │ │
│ │ │ 120 │ │ .v7-center (flex: 1)                    │ │ 120 │ │ │
│ │ │ px  │ │                                          │ │ px  │ │ │
│ │ │     │ │ ┌── .v7-header ──────────────────────┐  │ │     │ │ │
│ │ │  L  │ │ │ 로고 + 검색 + 배너                  │  │ │  R  │ │ │
│ │ │  Wing│ │ │ 4열 메인 메뉴                       │  │ │ Wing│ │ │
│ │ │     │ │ └────────────────────────────────────┘  │ │     │ │ │
│ │ │     │ │                                          │ │     │ │ │
│ │ │     │ │ ┌── .v7-body (flex) ─────────────────┐  │ │     │ │ │
│ │ │     │ │ │ ┌─────┐ ┌────────────┐ ┌─────┐    │  │ │     │ │ │
│ │ │     │ │ │ │240px│ │ .v7-main   │ │240px│    │  │ │     │ │ │
│ │ │     │ │ │ │L-   │ │ (flex: 1)  │ │R-   │    │  │ │     │ │ │
│ │ │     │ │ │ │side │ │ 콘텐츠     │ │side │    │  │ │     │ │ │
│ │ │     │ │ │ │bar  │ │            │ │bar  │    │  │ │     │ │ │
│ │ │     │ │ │ │     │ │            │ │(홈만)│    │  │ │     │ │ │
│ │ │     │ │ │ └─────┘ └────────────┘ └─────┘    │  │ │     │ │ │
│ │ │     │ │ └────────────────────────────────────┘  │ │     │ │ │
│ │ └─────┘ └─────────────────────────────────────────┘ └─────┘ │ │
│ └──────────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────┤
│ .v7-footer (전폭)                                                │
└──────────────────────────────────────────────────────────────────┘
```

### 각 컬럼 CSS 속성

| 컬럼 | CSS 클래스 | 너비 | flex 속성 | 가시성 |
|------|-----------|------|----------|-------|
| 왼쪽 날개 | `.v7-wing.v7-lg` | 120px | `flex-shrink: 0` | lg+ |
| 왼쪽 사이드바 | `.v7-sidebar.v7-lg` | 240px | `flex-shrink: 0` | lg+ |
| 메인 콘텐츠 | `.v7-main` | 유동 | `flex: 1; min-width: 0` | 항상 |
| 오른쪽 사이드바 | `.v7-sidebar.v7-xl` | 240px | `flex-shrink: 0` | xl+ & 홈만 |
| 오른쪽 날개 | `.v7-wing.v7-lg` | 120px | `flex-shrink: 0` | lg+ |

### 모바일 (< 992px) 레이아웃

```css
/* responsive.css */
@media (max-width: 991.98px) {
    .v7-layout { flex-direction: column; gap: 0; }
    .v7-body   { flex-direction: column; gap: 0; margin-top: 0; }
    .v7-main   { padding: 0 8px; }
}
```

모바일에서는 `.v7-lg`, `.v7-xl` 클래스가 `display: none`이므로 날개/사이드바가 모두 숨겨지고, 메인 콘텐츠만 전폭으로 표시된다.

---

## 6. 각 영역별 CSS 규칙

### 6.1 탑바 (.v7-topbar)

```css
.v7-topbar {
    position: fixed;
    top: 0; left: 0; right: 0;
    z-index: 1030;
    height: var(--v7-topbar-height);    /* 2.25rem = ~36px */
    display: flex;
    align-items: stretch;               /* inner가 전체 높이 차지 */
    justify-content: center;
    font-size: 0.8em;                   /* 12.8px (v6 동일) */
}

.v7-topbar-outer {
    display: flex;
    align-items: stretch;
    width: 100%;
    max-width: var(--v7-max-width);     /* 1320px */
}

.v7-topbar-spacer {
    width: var(--v7-wing-width);        /* 120px */
    flex-shrink: 0;
    display: none;                      /* 기본 숨김, xl 이상에서 표시 */
}

.v7-topbar-inner {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-grow: 1;
    background-color: #fff;
    border: 1px solid #c4c8cb;
    border-top: 0;                      /* 상단 border 없음 — 브라우저 엣지에 붙음 */
    border-radius: 0 0 6px 6px;         /* 하단만 둥근 모서리 */
}
```

**핵심 포인트**:
- `align-items: stretch`로 inner가 탑바 전체 높이를 채움 (상단 간격 방지)
- `border-top: 0`으로 상단 엣지에 붙음
- `z-index: 1030`으로 모든 콘텐츠 위에 표시
- xl(1200px) 이상에서만 좌우 spacer(120px) 표시

### 6.2 헤더 (.v7-header)

```css
.v7-header {
    padding-top: var(--v7-topbar-height);  /* 탑바 높이만큼 밀어냄 */
}
```

**로고 영역 (.v7-logo-area)**:
```css
.v7-logo-area {
    display: flex;
    align-items: flex-end;
    justify-content: center;
    gap: 0;
    margin-top: 2.25rem;       /* 탑바와의 시각적 간격 */
}

.v7-top-banner {
    min-width: 252px;
    max-width: 252px;          /* 좌우 배너 고정 252px */
    flex-shrink: 0;
}

.v7-logo-center img {
    max-width: 240px;          /* 로고 최대 너비 */
}

.v7-search-form {
    max-width: 500px;          /* 검색폼 최대 너비 */
    border: 1px solid #dee2e6;
    border-radius: 0.375rem;
}
```

### 6.3 메인 메뉴 (.v7-main-menu)

```css
.v7-main-menu {
    margin-top: var(--v7-gap);
    border: 1px solid #dee2e6;
    border-radius: 6px;
    overflow: hidden;
}

.v7-main-menu .menu-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr 3fr;  /* 4열: 동일3 + 넓은1 */
}

.v7-main-menu .menu-col-header {
    background-color: #7f1d1d;   /* 어두운 빨강 */
    color: white;
    height: 38px;
    font-weight: 600;
}

.v7-main-menu .menu-col-nav {
    height: 60px;
    overflow: hidden;            /* 높이 초과 시 숨김 */
    border-left: 1px solid #dee2e6;
}

/* 첫 번째 열 왼쪽 테두리 제거 (컨테이너 border와 중복 방지) */
.v7-main-menu .menu-grid > div:first-child .menu-col-nav {
    border-left: none;
}
```

### 6.4 사이드바 (.v7-sidebar)

```css
.v7-sidebar {
    width: var(--v7-sidebar-width);  /* 240px */
    flex-shrink: 0;
}
```

**위젯 박스 (.v7-widget-box)**:
```css
.v7-widget-box {
    margin-bottom: var(--v7-gap);            /* 16px */
    border: 1px solid var(--wa-color-neutral-border-normal, #e0e0e0);
    border-radius: 6px;
    overflow: hidden;
}

.v7-widget-box .widget-title {
    padding: 0.5rem 0.75rem;
    font-size: 0.85em;
    font-weight: 600;
    background: var(--wa-color-neutral-fill-quiet, #f5f5f5);
    border-bottom: 1px solid var(--wa-color-neutral-border-normal, #e0e0e0);
}

.v7-widget-box .widget-body {
    padding: 0.5rem 0.75rem;
    font-size: 0.85em;
}
```

### 6.5 날개 (.v7-wing)

```css
.v7-wing {
    width: var(--v7-wing-width);   /* 120px */
    flex-shrink: 0;
    margin-top: 236px;            /* 헤더 높이만큼 내림 (v6 동일) */
}

.v7-wing .wing-item {
    width: 100%;
    margin-bottom: 8px;
    background: var(--wa-color-neutral-fill-quiet, #f0f0f0);
    border-radius: 4px;
    overflow: hidden;
}
```

> **⚠️ 주의**: `margin-top: 236px`은 헤더 영역 높이에 맞춘 하드코딩 값이다. 헤더 높이가 변경되면 이 값도 반드시 함께 수정해야 한다.

### 6.6 메인 콘텐츠 (.v7-main)

```css
.v7-main {
    flex: 1;
    min-width: 0;     /* flex item 오버플로우 방지 필수 */
}
```

**본문 영역 (.v7-body)**:
```css
.v7-body {
    display: flex;
    gap: var(--v7-gap);          /* 16px */
    margin-top: var(--v7-gap);   /* 헤더와의 간격 */
}
```

### 6.7 푸터 (.v7-footer)

```css
.v7-footer {
    margin-top: 2rem;
    padding: 1.5rem var(--v7-gap);
    border-top: 1px solid var(--wa-color-neutral-border-normal, #e0e0e0);
    background: var(--wa-color-surface-lowered, #f8f8f8);
}

.v7-footer-inner {
    max-width: var(--v7-max-width);  /* 1320px */
    margin: 0 auto;
    font-size: 0.8em;
}

.v7-footer-links {
    display: flex;
    flex-wrap: wrap;
    gap: 2rem;
}
```

---

## 7. 반응형 브레이크포인트

### 3단계 브레이크포인트 체계

| 이름 | 조건 | CSS 클래스 | 레이아웃 | 표시 영역 |
|------|------|-----------|---------|----------|
| **모바일** | < 992px | `.v7-mobile-only` 표시 | 1-column, 세로 쌓기 | 모바일 헤더 + 메인만 |
| **데스크톱** | ≥ 992px | `.v7-lg` 표시 | 5-column flex | 탑바 + 헤더 + 좌사이드바 + 메인 + 날개 |
| **와이드** | ≥ 1200px | `.v7-xl` 표시 | 5-column 완전 | 위 + 우사이드바 + 탑바 spacer |

### responsive.css 핵심 코드

```css
/* 기본: 모바일 (숨김/표시) */
.v7-hide         { display: none !important; }
.v7-mobile-only  { display: block; }
.v7-lg           { display: none; }
.v7-lg-flex      { display: none; }
.v7-xl           { display: none; }

/* 모바일 레이아웃 (< 992px) */
@media (max-width: 991.98px) {
    .v7-layout { flex-direction: column; gap: 0; }
    .v7-body   { flex-direction: column; gap: 0; margin-top: 0; }
    .v7-main   { padding: 0 8px; }
}

/* 데스크톱 (≥ 992px) */
@media (min-width: 992px) {
    .v7-mobile-only { display: none !important; }
    .v7-lg          { display: block; }
    .v7-lg-flex     { display: flex; }
    .v7-body        { gap: var(--v7-gap); }
}

/* 와이드 데스크톱 (≥ 1200px) */
@media (min-width: 1200px) {
    .v7-xl              { display: block; }
    .v7-topbar-spacer   { display: block; }   /* 탑바 날개 spacer */
    .v7-topbar-outer    { padding-left: 1rem; padding-right: 1rem; }
}
```

### v6 Bootstrap ↔ v7 클래스 매핑

| v6 Bootstrap | v7 커스텀 | 용도 |
|-------------|----------|------|
| `d-none d-lg-block` | `.v7-lg` | 데스크톱에서만 표시 |
| `d-none d-lg-flex` | `.v7-lg-flex` | 데스크톱에서 flex 표시 |
| `d-none d-xl-block` | `.v7-xl` | 와이드에서만 표시 |
| `d-lg-none` | `.v7-mobile-only` | 모바일에서만 표시 |
| `d-none` | `.v7-hide` | 항상 숨김 |

---

## 8. 색상 팔레트

### 🔴 v7 색상 테마: 블루 기본 + 메인 메뉴 헤더만 빨간색

> **v7 홈페이지의 기본 테마 색상은 블루(Blue)이다.**
> Web Awesome Pro의 기본 default theme 색상(Blue)을 그대로 사용하며, `--wa-color-brand-*` 변수를 오버라이드하지 않는다.
> **유일한 예외: 데스크탑 상단 메인 메뉴 1차 카테고리 헤더(`.v7-main-menu .menu-col-header`)만 빨간색(`#7f1d1d`) 배경을 유지한다.**

### 테마 색상 (Primary — 블루)

| 용도 | 색상 | 사용 위치 |
|------|------|----------|
| **Primary (블루)** | Web Awesome 기본 `--wa-color-brand-*` | 버튼, 링크, 탭 active, 페이지네이션 active, 배지, 글쓰기 버튼, 섹션 제목 언더라인, 인기글 순위 뱃지 등 **모든 UI 요소** |

### 예외 색상 (메인 메뉴 헤더만)

| 용도 | 색상 코드 | 사용 위치 |
|------|----------|----------|
| **🔴 메인 메뉴 헤더 배경** | `#7f1d1d` (딥 와인 레드) | `.v7-main-menu .menu-col-header` — **이 영역만 빨간색 허용** |

### 중립 색상

| 용도 | 색상 코드 | 사용 위치 |
|------|----------|----------|
| **본문 텍스트** | `#212529` | body color, 메뉴 링크, 위젯 텍스트 |
| **탑바 hover** | `#000` | 탑바 링크 hover |
| **약한 텍스트** | `#999` | 날짜, 설명, 약한 정보 |
| **탑바 배경** | `#fff` | topbar-inner 배경 |
| **탑바 테두리** | `#c4c8cb` | topbar-inner border |
| **일반 테두리** | `#dee2e6` | 검색폼, 메뉴, 구분선 |
| **위젯 테두리** | `#e0e0e0` | 위젯박스, 푸터 상단, 모바일 헤더 |
| **약한 구분선** | `#f0f0f0` | 위젯 아이템 하단 보더 |
| **위젯 배경** | `#f5f5f5` | 위젯 제목 배경 |
| **푸터 배경** | `#f8f8f8` | 푸터 배경 |
| **배너 배경** | `#f0f0f0` | 배너 플레이스홀더, 날개 아이템 |
| **hover 배경** | `#f8f9fa` | 댓글/업소 hover |

> **⛔ 절대 규칙**: 메인 메뉴 헤더(`.v7-main-menu .menu-col-header`)를 제외하고 빨간색(`#7f1d1d`, `#dc2626`, `#991b1b`)을 사용하지 않는다. 기존에 빨간색이 하드코딩된 UI 요소는 블루 테마(Web Awesome `--wa-color-brand-*` 변수)로 전환해야 한다.

---

## 9. 폰트 크기 체계

| 크기명 | 값 | 실제 px (base 16px) | 사용 위치 |
|--------|-----|-------------------|----------|
| **xs** | `0.8em` | 12.8px | 탑바, 푸터, 댓글 날짜 |
| **sm** | `0.85em` | 13.6px | 위젯 제목/본문, 게시글 아이템, 모바일 링크, 카테고리 |
| **검색/메뉴** | `0.875em` | 14px | 메뉴 서브링크, 검색 addon |
| **0.9em** | `0.9em` | 14.4px | 검색 입력, 카드 헤더, 푸터 섹션 제목 |
| **기본** | `1em` | 16px | 본문 텍스트 |

**유틸리티 클래스**:
```css
.xs { font-size: 0.8em; }
.sm { font-size: 0.9em; }
```

---

## 10. 위젯 포함 관계도

```
v7/layout.php
├── widgets/topbar.php                      (.v7-topbar.v7-lg)
│
├── <header class="v7-header">
│   ├── widgets/header-mobile.php           (.v7-mobile-only)
│   └── widgets/header-desktop.php          (.v7-lg)
│       ├── .v7-logo-area (로고+검색+배너)
│       └── .v7-main-menu (4열 grid)
│
├── widgets/wing-left.php                   (.v7-wing.v7-lg)
│
├── <div class="v7-body">
│   ├── widgets/sidebar-left.php            (.v7-sidebar.v7-lg)
│   │   ├── 로그인 박스 (wa-button)
│   │   ├── 포인트 랭킹 50
│   │   ├── 최근 댓글 (.v7-comment-item)
│   │   └── 최신 사진 (3열 grid)
│   │
│   ├── <main class="v7-main">
│   │   └── $content (페이지별 콘텐츠)
│   │       └── [홈] v7/index.php
│   │           ├── widgets/mobile-top-banners.php     (.v7-mobile-only)
│   │           ├── widgets/news-tabs.php
│   │           ├── widgets/mobile-wing-banners.php    (.v7-mobile-only)
│   │           ├── widgets/latest-posts.php           (2열 grid)
│   │           ├── widgets/popular-posts.php
│   │           └── [모바일 전용 공유 위젯]
│   │               ├── widgets/exchange-rate.php
│   │               ├── widgets/company-categories.php
│   │               ├── widgets/latest-companies.php
│   │               └── widgets/stats.php
│   │
│   └── [홈만] widgets/sidebar-right.php    (.v7-sidebar.v7-xl)
│       ├── widgets/exchange-rate.php
│       ├── widgets/company-categories.php
│       ├── widgets/latest-companies.php
│       └── widgets/stats.php
│
├── widgets/wing-right.php                  (.v7-wing.v7-lg)
│
└── widgets/footer.php                      (.v7-footer)
```

**공유 위젯 패턴**: `exchange-rate.php`, `company-categories.php`, `latest-companies.php`, `stats.php`는 데스크톱에서는 오른쪽 사이드바(sidebar-right.php)에서, 모바일에서는 index.php 하단에서 동일 파일을 include하여 DRY 원칙을 적용한다.

---

## 11. layout.php 핵심 소스코드

```php
<?php
// v7/layout.php — v6의 page.header.php + page.footer.php 통합
require_once __DIR__ . '/etc/cache-version.php';

use V7\Utils\Route;
use V7\Utils\Env;

$route = Route::getInstance();
$isHomePage = ($route->getUri() === '/' || $route->getUri() === '');

// 페이지 콘텐츠를 먼저 실행하여 캡처
ob_start();
$pageFile = $route->getPageFile();
if ($pageFile) {
    include $pageFile;
} else {
    http_response_code(404);
    echo '<div>404 - 페이지를 찾을 수 없습니다</div>';
}
$content = ob_get_clean();
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle) ?></title>
    <!-- Web Awesome Pro -->
    <link rel="stylesheet" href="/v7/etc/dist-cdn/styles/webawesome.css">
    <script type="module" src="/v7/etc/dist-cdn/webawesome.loader.js" ...></script>
    <!-- Font Awesome 7.2.0 -->
    <link rel="stylesheet" href="/v7/etc/font-awesome/css/all.min.css">
    <!-- v7 커스텀 CSS — 캐시 버스팅 -->
    <link rel="stylesheet" href="/v7/css/layout.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/responsive.css?v=<?= CACHE_VERSION ?>">
    <link rel="stylesheet" href="/v7/css/utilities.css?v=<?= CACHE_VERSION ?>">
    <!-- Vue.js CDN -->
    <script defer src="/v7/etc/vue/vue.global.prod.js"></script>
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

                    <main class="v7-main">
                        <?= $content ?>
                    </main>

                    <?php if ($isHomePage): ?>
                        <?php include __DIR__ . '/widgets/sidebar-right.php'; ?>
                    <?php endif; ?>
                </div>
            </div>

            <?php include __DIR__ . '/widgets/wing-right.php'; ?>
        </div>
    </div>

    <?php include __DIR__ . '/widgets/footer.php'; ?>

    <?php if (Env::isDev()): ?>
        <?php include __DIR__ . '/../etc/v7-hot-reload-client-code.php'; ?>
    <?php endif; ?>
</body>
</html>
```

---

## 12. CSS 파일별 핵심 코드

### 파일 목록 및 역할

| 파일 | 역할 | 줄 수 |
|------|------|------|
| `v7/css/layout.css` | 5-column 구조, 탑바, 헤더, 사이드바, 메인, 푸터, 위젯, 카드, 댓글, 업소 등 모든 컴포넌트 | ~714줄 |
| `v7/css/responsive.css` | 반응형 유틸리티 클래스 + 미디어 쿼리 | ~101줄 |
| `v7/css/utilities.css` | 텍스트 클리핑, 폰트 크기, 패딩, 섹션 제목 등 범용 유틸리티 | ~88줄 |

### layout.css — 전역 기본 스타일

```css
* { box-sizing: border-box; }

body {
    margin: 0; padding: 0;
    font-family: system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
    font-size: 16px;
    line-height: 1.5;
    color: var(--wa-color-text, #212529);
    background-color: var(--wa-color-surface-default, #fff);
}

a { color: inherit; text-decoration: none; }
a:hover { text-decoration: underline; }
```

### layout.css — 페이지 래퍼

```css
.v7-page-wrapper {
    max-width: var(--v7-max-width);  /* 1320px */
    margin: 0 auto;
    padding: 0;
}

.v7-layout {
    display: flex;
    gap: var(--v7-gap);              /* 16px */
}

.v7-center {
    flex: 1;
    min-width: 0;                    /* 오버플로우 방지 */
}
```

### utilities.css — 텍스트 클리핑

```css
.line-clamp-1 {
    height: 1.4em;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.line-clamp-2 {
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
}
```

### utilities.css — 콘텐츠 패딩

```css
.v7-content-pad { padding: 0 8px; }

@media (min-width: 992px) {
    .v7-content-pad { padding: 0; }  /* 데스크톱: 패딩 제거 */
}
```

### utilities.css — 섹션 제목

```css
.v7-section-title {
    padding: 0.4rem 0;
    margin-bottom: 0.5rem;
    border-bottom: 2px solid #7f1d1d;  /* 브랜드색 하단 보더 */
    font-weight: 600;
    font-size: 0.9em;
}
```

---

## 13. 레이아웃 수정 시 절대 규칙

### ⛔ 절대 변경 금지 항목

| 항목 | 이유 |
|------|------|
| `.v7-layout`의 `display: flex` | 5-column 레이아웃 근간. grid로 변경하면 전체 구조 붕괴 |
| `.v7-sidebar`의 `width: 240px` | 사이드바 너비 변경 시 내부 위젯 디자인 모두 깨짐 |
| `.v7-wing`의 `width: 120px` | 날개 배너 규격. 광고 이미지 사이즈와 연동 |
| `.v7-topbar`의 `position: fixed` | 고정 탑바 해제 시 헤더 padding-top 체계 무너짐 |
| `.v7-topbar-inner`의 `border-radius: 0 0 6px 6px` | v6 동일 디자인 |
| `.v7-main`의 `min-width: 0` | 제거 시 flex 오버플로우 발생 |
| 메인 메뉴 `grid-template-columns: 1fr 1fr 1fr 3fr` | 4열 비율이 v6과 동일해야 함 |

### ⚠️ 수정 시 연쇄 확인 필요 항목

| 수정 항목 | 영향 범위 | 확인 사항 |
|----------|----------|----------|
| `--v7-topbar-height` 변경 | `.v7-header` padding-top | 헤더 시작 위치 어긋남 확인 |
| `--v7-gap` 변경 | 모든 컬럼 간격, body 여백 | 전체 레이아웃 간격 확인 |
| `--v7-max-width` 변경 | 탑바, 푸터, 페이지 래퍼 | 모든 영역 최대 너비 동기화 확인 |
| `.v7-wing`의 `margin-top: 236px` | 날개 배너 시작 위치 | 헤더 높이 변경 시 함께 수정 |
| `.v7-logo-area`의 `margin-top` | 로고와 탑바 간격 | 탑바 높이 변경 시 함께 확인 |
| `#7f1d1d` 브랜드색 변경 | 메뉴, 탭, 순위, 섹션 제목 | 모든 사용 위치 일괄 변경 |

### ✅ 안전하게 수정 가능한 항목

| 항목 | 설명 |
|------|------|
| 위젯 내부 콘텐츠 | `.widget-body` 안의 HTML은 자유롭게 수정 가능 |
| 페이지 콘텐츠 | `.v7-main` 안에 삽입되는 콘텐츠는 레이아웃에 영향 없음 |
| 새 위젯 추가 | `.v7-widget-box` 패턴을 따르면 안전 |
| 색상 미세 조정 | 테두리/배경 색상은 영향 범위가 좁음 |

---

## 14. 새 페이지 추가 시 체크리스트

1. **파일 생성**: `v7/[path].php` (layout.php의 `<main>` 안에 삽입됨)
2. **v6 코드 사용 금지**: `boot.php`, `page.header.php`, `pdo()`, `login()` 등 절대 금지
3. **레이아웃 클래스 사용**: `.v7-content-pad` 래퍼로 모바일 패딩 적용
4. **반응형 확인**: lg(992px), xl(1200px) 브레이크포인트에서 테스트
5. **탑바 오버랩 확인**: 콘텐츠가 탑바 아래에 가려지지 않는지 확인
6. **사이드바 간격**: `.v7-body`의 gap(16px)이 유지되는지 확인
7. **CSS 캐시**: 새 CSS 추가 시 `?v=<?= CACHE_VERSION ?>` 적용
8. **Chrome DevTools MCP 테스트**: `https://v7-local.philgo.com/[path]` 접속하여 확인

---

## 관련 문서

- 위젯 상세 → [v7-widgets.md](v7-widgets.md)
- 전체 아키텍처 → [v7-overview.md](v7-overview.md)
- 폰트 전략 → [v7-fonts.md](v7-fonts.md)
- 반응형 SEO → [v7-seo.md](v7-seo.md)
- **코멘트 디자인 시스템** → [v7-post.md 코멘트 디자인 시스템](../api/v7-post.md#코멘트-디자인-시스템) (wa-avatar, wa-relative-time, wa-badge 컴포넌트, 블루 테마, 대댓글 연결선, 모바일 반응형)

---

## 소스 파일 경로

| 파일 | 경로 |
|------|------|
| 메인 레이아웃 | `v7/layout.php` |
| 프론트 컨트롤러 | `v7.php` |
| 부팅 파일 | `v7/boot.php` |
| 레이아웃 CSS | `v7/css/layout.css` |
| 반응형 CSS | `v7/css/responsive.css` |
| 유틸리티 CSS | `v7/css/utilities.css` |
| 캐시 버전 | `v7/etc/cache-version.php` |
| Route 클래스 | `v7/utils/Route.php` |
| Env 클래스 | `v7/utils/Env.php` |
| 위젯 폴더 | `v7/widgets/*.php` (17개) |
