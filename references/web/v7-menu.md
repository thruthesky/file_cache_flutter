# v7 전체 메뉴 페이지

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [접속 URL](#3-접속-url)
4. [메뉴 섹션 구성](#4-메뉴-섹션-구성)
5. [각 섹션 상세](#5-각-섹션-상세)
6. [URL 헬퍼 사용](#6-url-헬퍼-사용)
7. [CSS 구조](#7-css-구조)
8. [로그인 상태별 메뉴 분기](#8-로그인-상태별-메뉴-분기)

---

## 1. 개요

v7 전체 메뉴 페이지는 v6 `page/menu/all.php`를 v7 시스템으로 이식한 페이지이다.
Web Awesome Pro + Font Awesome Pro + 커스텀 CSS로 구현하며, 모든 주요 링크를 카드 형태의 그리드로 배치한다.

| 항목 | 내용 |
|------|------|
| **파일** | `v7/menu/index.php` |
| **CSS** | `v7/menu/index.css` |
| **접속 URL** | `https://v7-local.philgo.com/menu` |
| **렌더링** | SSR (PHP) |
| **v6 원본** | `page/menu/all.php` (수정 금지) |
| **URL 헬퍼** | `url()` 함수 사용 (`V7\Utils\Url`) |
| **SEO** | `Seo::title()`, `Seo::description()`, `Seo::canonical()` |

---

## 2. 파일 구조

```
v7/menu/
├── index.php     ← 전체 메뉴 페이지 (PHP SSR)
└── index.css     ← 메뉴 페이지 전용 CSS
```

---

## 3. 접속 URL

| 환경 | URL |
|------|-----|
| 개발 | `https://v7-local.philgo.com/menu` |
| 프로덕션 | `https://philgo.net/menu` |

---

## 4. 메뉴 섹션 구성

메뉴 페이지는 6개 섹션으로 구성된 그리드 레이아웃이다.

| 섹션 | 아이콘 | 메뉴 항목 수 | 설명 |
|------|--------|-------------|------|
| **커뮤니티** | `fa-users` | 5 | 채팅, 업소록, 즐겨찾기, 인기글, 최근 댓글 |
| **광고 서비스** | `fa-bullhorn` | 4 | 배너 광고, 포인트 광고, 게시판별 포인트 안내, 마사지 광고 |
| **내 정보** | `fa-user-circle` | 6 | 프로필, 공개 프로필, 포인트 기록, 차단 사용자, 설정, 계정 관리 요청 |
| **도움말** | `fa-circle-question` | 4 | 이용 안내, 이용약관, 개인정보처리방침, 포인트 이벤트 |
| **계정관리** | `fa-user-cog` | 1~2 | 로그인/로그아웃 (로그인 상태에 따라 분기) |
| **유틸리티** | `fa-toolbox` | 3 | 검색, 날씨, 환율 계산기 |

---

## 5. 각 섹션 상세

### 5.1 커뮤니티 섹션

| 메뉴 항목 | URL 헬퍼 | 아이콘 | 아이콘 색상 |
|-----------|---------|--------|-----------|
| 채팅 | `url()->chat->openChatRooms` | `fa-comments` | blue |
| 업소록 | `url()->company->home` | `fa-building` | green |
| 즐겨찾기 | `url()->bookmark->home` | `fa-bookmark` | amber |
| 인기글 | `url()->post->popular` | `fa-fire` | red |
| 최근 댓글 | `url()->post->recentComments` | `fa-comment-dots` | cyan |

### 5.2 광고 서비스 섹션

| 메뉴 항목 | URL 헬퍼 | 아이콘 | 아이콘 색상 |
|-----------|---------|--------|-----------|
| 배너 광고 | `url()->adv->banner` | `fa-rectangle-ad` | amber |
| 포인트 광고 | `url()->adv->point` | `fa-coins` | red |
| 게시판별 포인트 안내 | `url()->help->pointGuideline` | `fa-list-check` | blue |
| 마사지 광고 | `url()->adv->massage` | `fa-spa` | green |

### 5.3 내 정보 섹션

| 메뉴 항목 | URL 헬퍼 | 아이콘 | 아이콘 색상 |
|-----------|---------|--------|-----------|
| 프로필 수정 | `url()->user->profile` | `fa-id-card` | cyan |
| 공개 프로필 | `url()->user->publicProfile()` | `fa-user-check` | green |
| 포인트 기록 보기 | `url()->point->history` | `fa-coins` | amber |
| 차단한 사용자 | `url()->user->blocked` | `fa-ban` | red |
| 설정 | `url()->user->settings` | `fa-gear` | blue |
| 계정 관리 요청 | `url()->user->accountDelete` | `fa-user-xmark` | red |

### 5.4 도움말 섹션

| 메뉴 항목 | URL 헬퍼 | 아이콘 | 아이콘 색상 |
|-----------|---------|--------|-----------|
| 이용 안내 | `url()->help->guideline` | `fa-book` | green |
| 이용약관 | `url()->help->terms` | `fa-file-contract` | blue |
| 개인정보처리방침 | `url()->help->privacy` | `fa-shield-halved` | neutral |
| 포인트 이벤트 | `url()->help->pointEvent` | `fa-gift` | red |

### 5.5 계정관리 섹션

로그인 상태에 따라 표시 항목이 달라진다.

| 조건 | 메뉴 항목 | URL 헬퍼 | 아이콘 |
|------|-----------|---------|--------|
| 로그인 상태 | 로그아웃 | `url()->user->logout` | `fa-right-from-bracket` (amber) |
| 로그인 상태 | 회원 탈퇴 | `url()->user->resign` | `fa-user-xmark` (red, `.menu-name-danger`) |
| 비로그인 상태 | 로그인 | `url()->user->login` | `fa-right-to-bracket` (blue, `.menu-name-primary`) |

### 5.6 유틸리티 섹션

| 메뉴 항목 | URL 헬퍼 | 아이콘 | 아이콘 색상 |
|-----------|---------|--------|-----------|
| 검색 | `url()->search` | `fa-magnifying-glass` | blue |
| 날씨 | `url()->weather` | `fa-cloud-sun` | cyan |
| 환율 계산기 | `url()->currency` | `fa-money-bill-transfer` | green |

---

## 6. URL 헬퍼 사용

메뉴 페이지에서 사용하는 모든 URL은 `url()` 함수를 통해 생성한다. 하드코딩은 금지.

```php
<!-- 올바른 사용법 -->
<a href="<?= url()->chat->openChatRooms ?>">채팅</a>
<a href="<?= url()->bookmark->home ?>">즐겨찾기</a>
<a href="<?= url()->post->popular ?>">인기글</a>
<a href="<?= url()->post->recentComments ?>">최근 댓글</a>
<a href="<?= url()->adv->massage ?>">마사지 광고</a>
<a href="<?= url()->search ?>">검색</a>
<a href="<?= url()->weather ?>">날씨</a>
<a href="<?= url()->currency ?>">환율 계산기</a>
```

### 메뉴 페이지에서 사용하는 URL 프로퍼티 전체 목록

| URL 프로퍼티 | 경로 | 소속 클래스 |
|-------------|------|-----------|
| `url()->chat->openChatRooms` | `/chat` | `ChatUrl` |
| `url()->company->home` | `/company` | `CompanyUrl` |
| `url()->bookmark->home` | `/bookmark` | `BookmarkUrl` |
| `url()->post->popular` | `/post/popular` | `PostUrl` |
| `url()->post->recentComments` | `/post/comments` | `PostUrl` |
| `url()->adv->banner` | `/adv/banner` | `AdvUrl` |
| `url()->adv->point` | `/adv/point` | `AdvUrl` |
| `url()->adv->massage` | `/adv/massage` | `AdvUrl` |
| `url()->help->pointGuideline` | `/help/point-guideline` | `HelpUrl` |
| `url()->user->profile` | `/user/profile` | `UserUrl` |
| `url()->user->publicProfile()` | `/user/public-profile` | `UserUrl` |
| `url()->point->history` | `/point/history` | `PointUrl` |
| `url()->user->blocked` | `/user/blocked` | `UserUrl` |
| `url()->user->settings` | `/user/settings` | `UserUrl` |
| `url()->user->accountDelete` | `/user/account-delete` | `UserUrl` |
| `url()->help->guideline` | `/help/guideline` | `HelpUrl` |
| `url()->help->terms` | `/help/terms` | `HelpUrl` |
| `url()->help->privacy` | `/help/privacy` | `HelpUrl` |
| `url()->help->pointEvent` | `/help/point-event` | `HelpUrl` |
| `url()->user->logout` | `/user/logout` | `UserUrl` |
| `url()->user->resign` | `/user/resign` | `UserUrl` |
| `url()->user->login` | `/user/login` | `UserUrl` |
| `url()->search` | `/post/search` | `Url` (루트) |
| `url()->weather` | `/weather` | `Url` (루트) |
| `url()->currency` | `/currency` | `Url` (루트) |

---

## 7. CSS 구조

메뉴 페이지 전용 CSS는 `v7/menu/index.css`에 분리되어 있다 (PHP 내 `<style>` 태그 사용 금지).

### 주요 CSS 클래스

| 클래스 | 역할 |
|--------|------|
| `.v7-menu-page` | 페이지 루트 컨테이너 |
| `.menu-page-header` | 페이지 타이틀 영역 |
| `.menu-page-title` | 페이지 제목 (`h1`) |
| `.menu-page-desc` | 페이지 설명 텍스트 |
| `.menu-grid` | 섹션 그리드 컨테이너 (CSS Grid) |
| `.menu-section` | 개별 섹션 카드 |
| `.menu-section-header` | 섹션 헤더 (아이콘 + 섹션명) |
| `.menu-list` | 메뉴 항목 리스트 (`ul`) |
| `.menu-item` | 개별 메뉴 항목 (`li`) |
| `.menu-link` | 메뉴 링크 (`a`, flex 레이아웃) |
| `.menu-icon` | 아이콘 컨테이너 (둥근 배경 + 색상) |
| `.menu-text` | 텍스트 영역 |
| `.menu-name` | 메뉴 이름 |
| `.menu-desc` | 메뉴 설명 (작은 회색 텍스트) |
| `.menu-name-danger` | 위험 항목 강조 (빨간색, 예: 회원 탈퇴) |
| `.menu-name-primary` | 주요 항목 강조 (파란색, 예: 로그인) |

### 메뉴 아이콘 색상 패턴

각 메뉴 아이콘은 Web Awesome CSS 변수로 배경색과 아이콘 색상을 지정한다.

```html
<div class="menu-icon" style="background: var(--wa-color-blue-95); color: var(--wa-color-blue-50);">
    <i class="fa-solid fa-comments"></i>
</div>
```

| 색상 계열 | 배경 CSS 변수 | 아이콘 CSS 변수 | 사용 예 |
|----------|-------------|---------------|---------|
| blue | `--wa-color-blue-95` | `--wa-color-blue-50` | 채팅, 설정, 검색 |
| green | `--wa-color-green-95` | `--wa-color-green-50` | 업소록, 마사지, 환율 |
| amber | `--wa-color-amber-95` | `--wa-color-amber-50` | 즐겨찾기, 배너 광고, 로그아웃 |
| red | `--wa-color-red-95` | `--wa-color-red-50` | 인기글, 포인트 광고, 차단 |
| cyan | `--wa-color-cyan-95` | `--wa-color-cyan-50` | 최근 댓글, 프로필, 날씨 |
| neutral | `--wa-color-neutral-95` | `--wa-color-neutral-50` | 개인정보처리방침 |

---

## 8. 로그인 상태별 메뉴 분기

`AuthService::getLoginUser()`로 로그인 사용자를 확인하여 계정관리 섹션을 분기한다.

```php
$loginUser = AuthService::getLoginUser();

<?php if ($loginUser): ?>
    <!-- 로그인 상태: 로그아웃 + 회원 탈퇴 -->
<?php else: ?>
    <!-- 비로그인 상태: 로그인 -->
<?php endif; ?>
```

| 로그인 상태 | 표시 메뉴 |
|------------|----------|
| 로그인 | 로그아웃, 회원 탈퇴 |
| 비로그인 | 로그인 |
