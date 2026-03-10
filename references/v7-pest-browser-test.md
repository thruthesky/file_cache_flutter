# PEST 브라우저 테스트 (Playwright 기반) 완벽 가이드

> **✅ 설치 완료** — `pestphp/pest-plugin-browser ^4.2`, `playwright@latest`, 브라우저 드라이버 설치됨

## 목차

- [1. 개요](#1-개요)
- [2. 설치 및 설정](#2-설치-및-설정)
- [3. Pest.php 설정 (전역 브라우저 설정)](#3-pestphp-설정-전역-브라우저-설정)
- [4. 테스트 실행](#4-테스트-실행)
- [5. 기본 사용법](#5-기본-사용법)
- [6. 네비게이션](#6-네비게이션)
- [7. 브라우저 및 디바이스 설정](#7-브라우저-및-디바이스-설정)
- [8. 요소 선택자](#8-요소-선택자)
- [9. 클릭 및 버튼](#9-클릭-및-버튼)
- [10. 텍스트 입력](#10-텍스트-입력)
- [11. 키보드 입력](#11-키보드-입력)
- [12. 폼 요소 (드롭다운, 라디오, 체크박스)](#12-폼-요소-드롭다운-라디오-체크박스)
- [13. 파일 업로드 및 폼 제출](#13-파일-업로드-및-폼-제출)
- [14. 드래그, 호버, 값 조회](#14-드래그-호버-값-조회)
- [15. JavaScript 실행 및 페이지 정보](#15-javascript-실행-및-페이지-정보)
- [16. iframe 상호작용](#16-iframe-상호작용)
- [17. 대기 및 창 크기 조정](#17-대기-및-창-크기-조정)
- [18. Assertions — 텍스트/요소 검증](#18-assertions--텍스트요소-검증)
- [19. Assertions — URL 검증](#19-assertions--url-검증)
- [20. Assertions — 폼 상태 검증](#20-assertions--폼-상태-검증)
- [21. Assertions — 속성/가시성/DOM 검증](#21-assertions--속성가시성dom-검증)
- [22. Assertions — 콘솔/접근성/스모크 검증](#22-assertions--콘솔접근성스모크-검증)
- [23. 스크린샷](#23-스크린샷)
- [24. 디버깅](#24-디버깅)
- [25. 여러 페이지 동시 테스트](#25-여러-페이지-동시-테스트)
- [26. 필고 프로젝트 전용 패턴](#26-필고-프로젝트-전용-패턴)
  - [26.8 v7 관리자 대시보드 인증 패턴](#268-v7-관리자-대시보드-인증-패턴-2차-인증-쿠키)
  - [26.9 Playwright 타임아웃 방지 — script()로 폼 제출](#269-playwright-타임아웃-방지--script로-폼-제출)
  - [26.10 Vue.js v-model 입력값 조작](#2610-vuejs-v-model-입력값-조작--nativeinputvaluesetter-패턴)
  - [26.11 Vue.js v-model DOM 속성 — placeholder 셀렉터](#2611-vuejs-v-model-dom-속성--placeholder-셀렉터-사용)
  - [26.12 script() 메서드의 return 키워드 주의사항](#2612-script-메서드의-return-키워드-주의사항)
- [27. CI/CD 설정 (GitHub Actions)](#27-cicd-설정-github-actions)

---

## 1. 개요

PEST 브라우저 테스트는 **PEST PHP 테스트 프레임워크**의 브라우저 플러그인으로, **Playwright**를 기반으로 실제 브라우저에서 E2E(End-to-End) 테스트를 수행한다.

| 항목 | 설명 |
|------|------|
| **프레임워크** | PEST v4 + pestphp/pest-plugin-browser |
| **브라우저 엔진** | Playwright (Chromium, Firefox, Safari 지원) |
| **테스트 파일 위치** | `tests/Browser/*.php` |
| **설정 파일** | `tests/Pest.php` |
| **공식 문서** | https://pestphp.com/docs/browser-testing |

> **🔴 `./tests` 폴더 용도 — v7 전용 🔴**
> `./tests` 폴더는 오직 v7 용 코드를 위한 테스트만 저장한다. v6(레거시) 테스트는 `tests/old-tests/`에 보관되며 새로 작성하지 않는다.
> 테스트 대상: `v7/` 폴더 하위 코드, `lib/` 폴더의 v7 Controller/Service/Repository/Entity 클래스.

---

## 2. 설치 및 설정

### 2.1 설치 (이미 완료됨)

```bash
# PEST 브라우저 플러그인 설치
composer require pestphp/pest-plugin-browser --dev

# Playwright 설치
npm install playwright@latest

# 브라우저 드라이버 설치
npx playwright install
```

### 2.2 .gitignore 추가

```
tests/Browser/Screenshots
```

---

## 3. Pest.php 설정 (전역 브라우저 설정)

**파일**: `tests/Pest.php`

### 3.1 현재 필고 프로젝트 설정

```php
// 브라우저 테스트 타임아웃 15초로 설정
uses()
    ->beforeEach(function () {
        if (method_exists($this, 'setTimeout')) {
            $this->setTimeout(15000);
        }
    })
    ->in('Browser');
```

### 3.2 Pest.php에서 사용 가능한 전역 브라우저 설정

```php
// 기본 브라우저를 Firefox로 변경 (기본: Chromium)
pest()->browser()->inFirefox();

// 기본 브라우저를 Safari로 변경
pest()->browser()->inSafari();

// 기본 타임아웃 설정 (밀리초)
pest()->browser()->timeout(10000);

// 기본 User Agent 설정
pest()->browser()->userAgent('CustomUserAgent');

// 기본 호스트 설정
pest()->browser()->withHost('some-subdomain.localhost');

// 헤드리스 모드 비활성화 (브라우저 창 표시)
pest()->browser()->headed();
```

---

## 4. 테스트 실행

```bash
# 전체 테스트 실행
./vendor/bin/pest

# 브라우저 테스트만 실행
./vendor/bin/pest tests/Browser/

# 특정 파일 실행
./vendor/bin/pest tests/Browser/PostViewTest.php

# 병렬 실행 (권장 — 여러 브라우저 인스턴스 동시 실행)
./vendor/bin/pest --parallel

# 헤드리스 모드 비활성화 (브라우저 창 표시 — 디버깅용)
./vendor/bin/pest tests/Browser/PostViewTest.php --headed

# 특정 브라우저로 실행
./vendor/bin/pest --browser firefox
./vendor/bin/pest --browser safari

# 디버그 모드 (상세 로그 출력)
./vendor/bin/pest --debug

# 그룹별 실행
./vendor/bin/pest --group=browser
./vendor/bin/pest --group=smoke

# 특정 테스트만 필터링
./vendor/bin/pest tests/Browser/ --filter="게시글"
```

---

## 5. 기본 사용법

### 5.1 가장 기본적인 테스트

```php
<?php
test('홈페이지에 접근할 수 있다', function () {
    $page = $this->visit('https://local.philgo.com');
    $page->assertSee('Welcome');
});
```

### 5.2 `visit()` 함수

`visit()` 함수는 테스트의 시작점이다. URL을 방문하여 `PendingAwaitablePage` 객체를 반환한다.

```php
// 전체 URL 방문
$page = $this->visit('https://local.philgo.com/post/list.php');

// 상대 경로 방문 (호스트 설정이 필요)
$page = $this->visit('/post/list.php');
```

### 5.3 메서드 체이닝

모든 상호작용 메서드와 assertion은 체이닝이 가능하다:

```php
test('로그인 후 대시보드로 이동한다', function () {
    $page = $this->visit('https://local.philgo.com/user/login.php');

    $page->click('로그인')
         ->assertUrlIs('https://local.philgo.com/login')
         ->assertSee('로그인')
         ->type('email', 'test@example.com')
         ->type('password', 'password123')
         ->click('Submit')
         ->assertSee('Dashboard');
});
```

---

## 6. 네비게이션

### 6.1 페이지 방문

```php
$page = $this->visit('https://local.philgo.com');
```

### 6.2 페이지 내 네비게이션

```php
$page = $this->visit('https://local.philgo.com');

// 다른 페이지로 이동
$page->navigate('/about')
     ->assertSee('About Us');
```

---

## 7. 브라우저 및 디바이스 설정

### 7.1 브라우저 지정

```php
// Firefox로 테스트
$page = $this->visit('/')->inFirefox();

// Safari로 테스트
$page = $this->visit('/')->inSafari();
```

### 7.2 모바일 디바이스 에뮬레이션

```php
// 일반 모바일
$page = $this->visit('/')->on()->mobile();

// 특정 디바이스
$page = $this->visit('/')->on()->iPhone14Pro();
$page = $this->visit('/')->on()->macbook14();
```

### 7.3 다크 모드

```php
$page = $this->visit('/')->inDarkMode();
```

### 7.4 로케일 (언어) 설정

```php
$page = $this->visit('/')->withLocale('ko-KR');
$page->assertSee('안녕하세요');
```

### 7.5 타임존 설정

```php
$page = $this->visit('/')->withTimezone('Asia/Seoul');
$page->assertSee('KST');
```

### 7.6 User Agent 설정

```php
$page = $this->visit('/')->withUserAgent('Googlebot');
$page->assertSee('Welcome, bot!');
```

### 7.7 호스트 설정

```php
$page = $this->visit('/dashboard')->withHost('banana.philgo.com');
$page->assertSee('패밀리사이트');
```

### 7.8 지리적 위치 설정

```php
$page = $this->visit('/')
     ->geolocation(37.5665, 126.9780);  // 서울 좌표
```

---

## 8. 요소 선택자

PEST 브라우저 테스트에서 요소를 찾는 4가지 방법:

| 방법 | 문법 | 예시 |
|------|------|------|
| **텍스트** | 문자열 그대로 | `$page->click('로그인')` |
| **CSS 선택자** | `.class`, `#id` | `$page->click('.btn-primary')` |
| **Data 속성** | `@이름` | `$page->click('@login-btn')` → `data-testid="login-btn"` |
| **ID 선택자** | `#id` | `$page->click('#submit-button')` |

```php
// 텍스트로 클릭
$page->click('로그인');

// CSS 클래스 선택자
$page->click('.btn-primary');

// Data 속성 (data-testid)
$page->click('@login');

// ID 선택자
$page->click('#submit-button');
```

---

## 9. 클릭 및 버튼

### 9.1 일반 클릭

```php
$page->click('로그인');
$page->click('#button');
```

### 9.2 더블 클릭

```php
$page->click('#button', options: ['clickCount' => 2]);
```

### 9.3 오른쪽 클릭

```php
$page->rightClick('메뉴 항목');
```

### 9.4 버튼 누르기

```php
// 버튼 텍스트로 클릭
$page->press('Submit');

// 버튼 클릭 후 대기
$page->pressAndWaitFor('Submit', 2);  // 2초 대기
```

---

## 10. 텍스트 입력

### 10.1 type() — 즉시 입력

```php
$page->type('email', 'test@example.com');
```

### 10.2 typeSlowly() — 천천히 입력 (실제 타이핑처럼)

```php
$page->typeSlowly('email', 'test@example.com');
```

### 10.3 append() — 기존 값에 추가

```php
$page->append('description', ' 추가 정보.');
```

### 10.4 fill() — type()의 별칭

`fill()`은 내부적으로 `type()`을 호출하는 별칭 메서드이다. 공식 문서에서 사용되는 패턴:

```php
$page->fill('email', 'nuno@laravel.com');
$page->fill('password', 'password');
```

### 10.5 clear() — 입력 필드 비우기

```php
$page->clear('search');
```

---

## 11. 키보드 입력

### 11.1 keys() — 키보드 키 입력

```php
// 문자열 입력
$page->keys('input[name=password]', 'secret');

// 특수 키 입력 (Ctrl+A)
$page->keys('input[name=password]', ['{Control}', 'a']);
```

### 11.2 withKeyDown() — 키를 누른 채로 입력

```php
$page->withKeyDown('Shift', function () use ($page): void {
    $page->keys('#input', ['KeyA', 'KeyB', 'KeyC']);
});
```

---

## 12. 폼 요소 (드롭다운, 라디오, 체크박스)

### 12.1 드롭다운 (select)

```php
// 단일 선택
$page->select('country', 'KR');

// 다중 선택
$page->select('interests', ['music', 'sports']);
```

### 12.2 라디오 버튼

```php
$page->radio('size', 'large');
```

### 12.3 체크박스

```php
// 체크
$page->check('terms');
$page->check('color', 'blue');

// 체크 해제
$page->uncheck('newsletter');
$page->uncheck('color', 'red');
```

---

## 13. 파일 업로드 및 폼 제출

### 13.1 파일 업로드

```php
$page->attach('avatar', '/path/to/image.jpg');
```

### 13.2 폼 제출

```php
$page->submit();
```

---

## 14. 드래그, 호버, 값 조회

### 14.1 드래그

```php
$page->drag('#item', '#target');
```

### 14.2 호버

```php
$page->hover('#item');
```

### 14.3 값 가져오기

```php
// input 필드의 value 조회
$value = $page->value('input[name=email]');

// 요소의 텍스트 조회
$text = $page->text('.header');

// 요소의 속성 조회
$alt = $page->attribute('img', 'alt');
```

---

## 15. JavaScript 실행 및 페이지 정보

### 15.1 JavaScript 실행

```php
$result = $page->script('document.title');
```

### 15.2 페이지 HTML 가져오기

```php
$html = $page->content();
```

### 15.3 현재 URL 가져오기

```php
$currentUrl = $page->url();
```

---

## 16. iframe 상호작용

```php
use Pest\Browser\Api\PendingAwaitablePage;

$page->withinIframe('.iframe-container', function (PendingAwaitablePage $page) {
    $page->type('frame-input', 'Hello iframe')
        ->click('frame-button');
});
```

---

## 17. 대기 및 창 크기 조정

### 17.1 대기

```php
// 초 단위 대기
$page->wait(2);

// 디버깅용: 키 입력 대기 (브라우저가 열린 상태에서 대기)
$page->waitForKey();
```

### 17.2 waitForEvent() — 페이지 로드 상태 대기

페이지 네비게이션(폼 제출, 리다이렉트 등) 후 로드 완료를 기다릴 때 사용한다.

```php
// 폼 제출 후 페이지 로드 대기
$page->script("document.querySelector('form').submit()");
$page->waitForEvent('load');

// 네비게이션 완료 대기
$page->waitForEvent('networkidle');
```

| 상태 | 설명 |
|------|------|
| `'load'` | `window.onload` 이벤트 대기 (DOMContentLoaded + 리소스 로드) |
| `'domcontentloaded'` | DOMContentLoaded 이벤트 대기 |
| `'networkidle'` | 네트워크 요청이 500ms 이상 없을 때까지 대기 |

> **주의**: `waitForEvent()`는 Playwright의 `page.waitForLoadState()`를 내부적으로 호출한다.

### 17.3 창 크기 조정

```php
$page->resize(1280, 720);
```

---

## 18. Assertions — 텍스트/요소 검증

### 18.1 제목 검증

```php
$page->assertTitle('홈페이지');
$page->assertTitleContains('홈');
```

### 18.2 텍스트 검증

```php
// 페이지에 텍스트가 보이는지
$page->assertSee('Welcome');
$page->assertDontSee('Error');

// 특정 요소 내 텍스트 검증
$page->assertSeeIn('.header', 'Welcome');
$page->assertDontSeeIn('.error-container', 'Error');

// 특정 요소 내 텍스트 존재 여부
$page->assertSeeAnythingIn('.content');
$page->assertSeeNothingIn('.empty-container');
```

### 18.3 링크 검증

```php
$page->assertSeeLink('About Us');
$page->assertDontSeeLink('Admin Panel');
```

### 18.4 요소 개수

```php
$page->assertCount('.item', 5);
```

### 18.5 소스 코드 검증

```php
$page->assertSourceHas('<h1>Welcome</h1>');
$page->assertSourceMissing('<div class="error">');
```

### 18.6 JavaScript 검증

```php
$page->assertScript('document.title', '홈페이지');
$page->assertScript('document.querySelector(".btn").disabled', true);
```

---

## 19. Assertions — URL 검증

```php
// 전체 URL 일치
$page->assertUrlIs('https://local.philgo.com/home');

// 스킴 검증
$page->assertSchemeIs('https');
$page->assertSchemeIsNot('http');

// 호스트 검증
$page->assertHostIs('local.philgo.com');
$page->assertHostIsNot('wrong-domain.com');

// 포트 검증
$page->assertPortIs('443');
$page->assertPortIsNot('8080');

// 경로 검증
$page->assertPathBeginsWith('/post');
$page->assertPathEndsWith('/list.php');
$page->assertPathContains('post');
$page->assertPathIs('/dashboard');
$page->assertPathIsNot('/login');

// 쿼리 스트링 검증
$page->assertQueryStringHas('page');
$page->assertQueryStringHas('page', '2');
$page->assertQueryStringMissing('page');

// 프래그먼트(해시) 검증
$page->assertFragmentIs('section-2');
$page->assertFragmentBeginsWith('section');
$page->assertFragmentIsNot('wrong-section');
```

---

## 20. Assertions — 폼 상태 검증

### 20.1 체크박스 상태

```php
$page->assertChecked('terms');
$page->assertChecked('color', 'blue');
$page->assertNotChecked('newsletter');
$page->assertNotChecked('color', 'red');
$page->assertIndeterminate('partial-selection');
```

### 20.2 라디오 버튼 상태

```php
$page->assertRadioSelected('size', 'large');
$page->assertRadioNotSelected('size', 'small');
```

### 20.3 드롭다운 선택 상태

```php
$page->assertSelected('country', 'KR');
$page->assertNotSelected('country', 'US');
```

### 20.4 필드 값

```php
$page->assertValue('input[name=email]', 'test@example.com');
$page->assertValueIsNot('input[name=email]', 'invalid@example.com');
```

### 20.5 활성화/비활성화

```php
$page->assertEnabled('email');
$page->assertDisabled('submit');
$page->assertButtonEnabled('Save');
$page->assertButtonDisabled('Submit');
```

---

## 21. Assertions — 속성/가시성/DOM 검증

### 21.1 속성 검증

```php
$page->assertAttribute('img', 'alt', 'Profile Picture');
$page->assertAttributeMissing('button', 'disabled');
$page->assertAttributeContains('div', 'class', 'container');
$page->assertAttributeDoesntContain('div', 'class', 'hidden');
```

### 21.2 ARIA 속성

```php
$page->assertAriaAttribute('button', 'label', 'Close');
```

### 21.3 Data 속성

```php
$page->assertDataAttribute('div', 'id', '123');
```

### 21.4 가시성 검증

```php
$page->assertVisible('.alert');
$page->assertMissing('.hidden-element');
```

### 21.5 DOM 존재 여부

```php
$page->assertPresent('form');          // DOM에 존재
$page->assertNotPresent('.error-message');  // DOM에 없음
```

> **`assertPresent()` vs `assertVisible()`**:
> - `assertPresent()`: DOM에 요소가 존재하는지 (display:none이어도 통과)
> - `assertVisible()`: 사용자에게 보이는지 (display:none이면 실패)

---

## 22. Assertions — 콘솔/접근성/스모크 검증

### 22.1 스모크 테스트 (종합)

```php
// JavaScript 에러, 콘솔 로그, 접근성 문제를 한 번에 검증
$page->assertNoSmoke();
```

`assertNoSmoke()`는 다음 3개 assertion을 한꺼번에 실행하는 편의 메서드이다:

### 22.2 개별 검증

```php
// 콘솔 로그가 없는지 검증
$page->assertNoConsoleLogs();

// JavaScript 에러가 없는지 검증
$page->assertNoJavaScriptErrors();

// 접근성 문제가 없는지 검증
$page->assertNoAccessibilityIssues();
```

### 22.3 접근성 레벨 (0-3)

| 레벨 | 설명 |
|------|------|
| 0 | 심각한 접근성 문제만 검사 |
| 1 | 심각한 문제 포함 (기본값) |
| 2 | 중간 정도 문제까지 검사 |
| 3 | 모든 경미한 문제까지 검사 |

---

## 23. 스크린샷

```php
// 기본 스크린샷 (뷰포트 영역)
$page->screenshot();

// 전체 페이지 스크린샷
$page->screenshot(fullPage: true);

// 파일명 지정
$page->screenshot(filename: 'custom-name');

// 특정 요소만 스크린샷
$page->screenshotElement('#my-element');

// 스크린샷 비교 (Visual Regression Testing)
$page->assertScreenshotMatches();
$page->assertScreenshotMatches(true, true);  // 전체 페이지, diff 표시
```

> 스크린샷 저장 위치: `tests/Browser/Screenshots/`

---

## 24. 디버깅

### 24.1 debug() — 브라우저에서 중단

```php
// 테스트 중단 후 브라우저를 열어 현재 상태 확인
$page->debug();
```

### 24.2 screenshot() — 스크린샷 캡처

```php
$page->screenshot();
```

### 24.3 tinker() — Tinker 세션

```php
// 대화형 PHP 세션 열기
$page->tinker();
```

### 24.4 waitForKey() — 키 입력 대기

```php
// 아무 키를 누를 때까지 브라우저를 열어둠 (디버깅용)
$page->waitForKey();
```

---

## 25. 여러 페이지 동시 테스트

```php
// 여러 페이지를 동시에 방문
$pages = $this->visit(['/', '/about']);

// 모든 페이지에 대해 스모크 테스트 실행
$pages->assertNoSmoke()
    ->assertNoAccessibilityIssues()
    ->assertNoConsoleLogs()
    ->assertNoJavaScriptErrors();

// 개별 페이지 접근
[$homePage, $aboutPage] = $pages;

$homePage->assertSee('Welcome');
$aboutPage->assertSee('About Us');
```

---

## 26. 필고 프로젝트 전용 패턴

### 🔴🔴🔴 26.0 테스트 계정 및 세션 ID (필수) 🔴🔴🔴

> **⛔ 브라우저 테스트에서 로그인이 필요한 경우, 반드시 아래 테스트 계정을 사용한다. ⛔**
> 상세 정보: → [v7-accounts.md](v7-accounts.md) 참조

#### 로컬 관리자 세션 ID

PEST 브라우저 테스트에서 관리자 권한이 필요한 경우 아래 session_id를 쿠키에 설정한다:

| 항목 | 값 |
|------|-----|
| **관리자 session_id** | `090e2895f9280a7d7d6ec11d3f0ce483-186619` |
| **관리자 대시보드 인증** | `Config.php`의 `adminDashboardId()`와 `adminDashboardPassword()` 참조, md5 해시 값으로 쿠키 저장 필요 |

#### Durian 테스트 계정 (일반 사용자)

테스트 전용 계정으로, 로그인/프로필/글 작성 등 일반 사용자 기능 테스트에 사용한다:

| 항목 | 값 |
|------|-----|
| **닉네임** | Durian |
| **session_id** | `2278018daa75e0ab879d8791fb0e2b2d-190076` |
| **sf_member.idx** | `190076` |

#### Poster 계정 (글 쓰기 전용)

API로 글 쓰기 테스트를 할 때 사용하는 계정:

| 항목 | 값 |
|------|-----|
| **로그인** | `poster@philgo.com:12345a,*` |
| **session_id** | `d87e7374e22f1bf1aaebbbb97d280115-193824` |
| **sf_member.idx** | `193824` |

#### 브라우저 테스트에서 세션 ID로 로그인 설정

```php
test('관리자 대시보드 접근 테스트', function () {
    $page = $this->visit(TEST_BASE_URL . '/user/login.php');

    // JavaScript로 세션 쿠키 설정 후 페이지 이동
    $page->script("document.cookie = 'session_id=090e2895f9280a7d7d6ec11d3f0ce483-186619; path=/'")
         ->navigate('/page/admin/dashboard.php')
         ->assertSee('관리자');
})->group('browser', 'admin');
```

#### 브라우저 테스트에서 이메일/비밀번호로 로그인

```php
test('이메일 비밀번호로 로그인', function () {
    $page = $this->visit(TEST_BASE_URL . '/user/login.php');

    // 필고 테스트 로그인: 이메일:비밀번호 형식으로 전화번호 필드에 입력
    $page->type('phone_number', 'banana@test.com:12345a,*')
         ->click('SMS 코드 전송')
         ->assertSee('프로필');
})->group('browser', 'auth');
```

#### 테스트용 이미지 파일

| 파일 경로 | 설명 |
|-----------|------|
| `./tmp/sample-files/receipt-{n}.jpeg` | 영수증 이미지 |
| `./tmp/sample-files/사과.jpg` | 업로드 테스트용 과일 이미지 |
| `./tmp/sample-files/바나나.jpg` | 업로드 테스트용 과일 이미지 |
| `./tmp/sample-files/체리.jpg` | 업로드 테스트용 과일 이미지 |
| `./tmp/sample-files/두리안.jpg` | 업로드 테스트용 과일 이미지 |

### 🔴 26.1 브라우저 테스트 파일 경로 — 반드시 `tests/Browser/` (절대 규칙) 🔴

> **⛔ PEST Browser Plugin은 `tests/Browser/` 경로만 인식한다. 다른 경로에 브라우저 테스트를 배치하면 Playwright 서버가 시작되지 않아 "WebSocket client is not connected" 에러가 발생한다. 모든 테스트(유닛/브라우저/Feature)는 반드시 `tests/` 폴더 하위에 저장한다. ⛔**
>
> 이는 `vendor/pestphp/pest-plugin-browser/src/Support/BrowserTestIdentifier.php`의 `usesBrowserFolder()` 메서드가 `{rootPath}/tests/Browser/` 경로를 하드코딩으로 체크하기 때문이다.

| 규칙 | 설명 |
|------|------|
| **✅ 브라우저 테스트** | `tests/Browser/*.php` — 반드시 이 경로에 배치 |
| **✅ 유닛 테스트** | `tests/Unit/*.php` — 모든 유닛 테스트는 이 경로에 배치 |
| **❌ 금지** | `v7/tests/` — 더 이상 사용하지 않음. 모든 테스트는 `tests/`에 통합 |
| **v7 구분** | `->group('v7')` 태그로 v7 테스트를 구분하여 `--group=v7`로 실행 |

```
tests/
├── Pest.php                     ← PEST 설정 & 헬퍼 (브라우저 타임아웃 15초)
├── Browser/                     ← PEST 브라우저(E2E) 테스트 — v7 전용
│   ├── HomepageTest.php         ← v7 홈페이지 테스트
│   ├── PostListTest.php         ← v7 게시판 목록 테스트
│   ├── PostViewTest.php         ← v7 게시글 보기 테스트
│   ├── PostCreateTest.php       ← v7 게시글 작성 테스트 (비로그인)
│   ├── CompanyIndexTest.php     ← v7 업소록 목록 테스트
│   ├── CompanyRegisterTest.php  ← v7 업소록 등록 테스트
│   ├── LoginTest.php            ← v7 로그인 페이지 테스트
│   └── Screenshots/             ← 스크린샷 저장 (.gitignore)
├── Unit/                        ← PEST 유닛 테스트 (v7 포함 모든 유닛 테스트 통합)
│   ├── UrlTest.php              ← v7 URL 유틸리티 유닛 테스트
│   └── ...
└── Feature/                     ← Feature 테스트
```

### 26.1.1 v7 레이아웃 CSS 선택자 (테스트용)

모든 v7 페이지에서 공통으로 사용되는 레이아웃 CSS 선택자:

| 선택자 | 설명 |
|--------|------|
| `footer.v7-footer` | v7 푸터 (페이지 로드 확인용) |
| `.v7-page-wrapper` | 전체 페이지 래퍼 |
| `.v7-header` | 헤더 영역 |
| `.v7-main` | 메인 콘텐츠 영역 |
| `.v7-body` | 바디 영역 (사이드바 + 메인) |
| `.v7-layout` | 5-column 레이아웃 컨테이너 |

> **주의: v6의 `#site-footer`는 v7에서 `footer.v7-footer`로 변경되었다.**

### 26.2 필고 v7 브라우저 테스트 기본 템플릿

```php
<?php

/** @noinspection PhpUndefinedMethodInspection */
/** @noinspection PhpUndefinedFunctionInspection */

/**
 * @file tests/Browser/XxxTest.php
 * @brief v7 Xxx 페이지 브라우저 테스트
 *
 * PEST v4 Browser Plugin (Playwright 기반)을 사용하여
 * 실제 브라우저에서 v7 Xxx 페이지를 테스트한다.
 *
 * @note browserTest() 래퍼 함수를 사용하여 test()->group() P1006 타입 에러를 방지한다.
 *       browserTest()는 tests/Pest.php에 정의되어 있으며, 반환 타입을 TestCall로 명시한다.
 *
 * 실행 방법:
 * ./vendor/bin/pest tests/Browser/XxxTest.php
 * ./vendor/bin/pest tests/Browser/XxxTest.php --headed
 */

// ==================== 테스트 상수 ====================

if (!defined('V7_TEST_BASE_URL')) {
    define('V7_TEST_BASE_URL', 'https://v7-local.philgo.com');
}

// ==================== 테스트 케이스 ====================

browserTest('v7 Xxx 페이지에 접근할 수 있다', function () {
    /** @var \Pest\Browser\Api\PendingAwaitablePage $page */
    $page = $this->visit(V7_TEST_BASE_URL . '/xxx');

    // v7 레이아웃 필수 요소 확인
    $page->assertPresent('footer.v7-footer');
})->group('browser', 'v7', 'xxx', 'smoke');
```

### 26.3 v6 테스트 URL (기존 필고)

```php
// v6 기본 URL
define('TEST_BASE_URL', 'https://local.philgo.com');

// 게시글 보기
$page = $this->visit(TEST_BASE_URL . '/post/view.php?idx=123&post_id=massage');

// 업소록
$page = $this->visit(TEST_BASE_URL . '/company/index.php');

// 회원 프로필
$page = $this->visit(TEST_BASE_URL . '/user/profile.php');
```

### 26.4 v7 테스트 URL (신규 필고)

```php
// v7 기본 URL
define('V7_TEST_BASE_URL', 'https://v7-local.philgo.com');

// v7 홈페이지
$page = $this->visit(V7_TEST_BASE_URL . '/');

// v7 게시판 목록
$page = $this->visit(V7_TEST_BASE_URL . '/post/list?post_id=freetalk');

// v7 게시글 보기
$page = $this->visit(V7_TEST_BASE_URL . '/post/view?id=123');

// v7 게시글 작성
$page = $this->visit(V7_TEST_BASE_URL . '/post/create?post_id=freetalk');

// v7 업소록 목록
$page = $this->visit(V7_TEST_BASE_URL . '/company');

// v7 업소록 등록
$page = $this->visit(V7_TEST_BASE_URL . '/company/register');

// v7 로그인
$page = $this->visit(V7_TEST_BASE_URL . '/user/login');
```

> **v7 URL은 `.php` 확장자 없이 라우팅된다.** v6는 `/post/list.php`, v7은 `/post/list`.

### 26.5 그룹(Group) 사용 패턴

```php
// 여러 그룹을 지정하여 선택적 실행 가능
browserTest('게시글 페이지 필수 요소 확인', function () {
    // ...
})->group('browser', 'post', 'view', 'smoke');

// 실행 시 그룹 필터링
// ./vendor/bin/pest --group=smoke          ← smoke 테스트만
// ./vendor/bin/pest --group=post           ← post 관련만
// ./vendor/bin/pest --group=browser        ← 브라우저 테스트만
```

### 🔴🔴🔴 26.6 PHP 타입 안전성 — intelephense P1006 에러 완전 해결 (필수) 🔴🔴🔴

> **⛔⛔⛔ PEST 브라우저 테스트 코드에서 P1006 에러가 발생하지 않도록 반드시 타입 안전한 코드를 작성해야 한다. ⛔⛔⛔**

#### 문제: `test()->group()` P1006 에러

PEST의 `test()` 함수는 `TestCall|null|true|false` union type을 반환한다.
`->group()` 체이닝 시 intelephense가 P1006 에러를 표시한다:

```
Expected type 'object'. Found 'Pest\PendingCalls\TestCall|null|true|false'. intelephense(P1006)
```

#### 해결: `browserTest()` 래퍼 함수 (tests/Pest.php에 정의)

`tests/Pest.php`에 반환 타입을 `TestCall`로 명시한 래퍼 함수를 정의하여 P1006을 완전히 해결한다:

```php
// tests/Pest.php에 정의된 래퍼 함수
/**
 * @param string $description 테스트 설명
 * @param \Closure|null $closure 테스트 본문
 * @return \Pest\PendingCalls\TestCall
 */
function browserTest(string $description, ?\Closure $closure = null): \Pest\PendingCalls\TestCall
{
    /** @var \Pest\PendingCalls\TestCall $testCall */
    $testCall = test($description, $closure);
    return $testCall;
}
```

#### 사용법: `test()` 대신 `browserTest()` 사용

```php
// ✅ 올바른 방식 — browserTest() 사용으로 P1006 에러 없음
browserTest('v7 홈페이지에 접근할 수 있다', function () {
    /** @var \Pest\Browser\Api\PendingAwaitablePage $page */
    $page = $this->visit(V7_TEST_BASE_URL . '/');
    $page->assertPresent('footer.v7-footer');
})->group('browser', 'v7', 'smoke');  // ← P1006 에러 없음!

// ❌ 잘못된 방식 — test() 직접 사용 시 P1006 발생
test('v7 홈페이지에 접근할 수 있다', function () {
    // ...
})->group('browser', 'v7', 'smoke');  // ← P1006 에러 발생!
```

#### `$this->visit()` 반환값 타입 힌트 (필수)

`$this->visit()` 반환값은 반드시 `@var` PHPDoc으로 타입을 명시해야 한다:

```php
// ✅ 올바른 방식 — @var 타입 힌트 필수
/** @var \Pest\Browser\Api\PendingAwaitablePage $page */
$page = $this->visit($url);
$page->assertPresent('footer.v7-footer');  // P1006 에러 없음

// ❌ 잘못된 방식 — 타입 힌트 누락 시 P1006 발생
$page = $this->visit($url);
$page->assertPresent('footer.v7-footer');  // ⚠️ P1006: Expected type 'object'
```

#### P1006 해결 요약

| 위치 | 해결 방법 |
|------|-----------|
| `test()->group()` 체이닝 | **`browserTest()` 래퍼 사용** (tests/Pest.php에 정의) |
| `$this->visit()` 반환값 | `/** @var \Pest\Browser\Api\PendingAwaitablePage $page */` 추가 |

#### 파일 상단 필수 `@noinspection` 주석

모든 PEST 브라우저 테스트 파일 상단에 반드시 다음 주석을 추가한다:

```php
<?php

/** @noinspection PhpUndefinedMethodInspection */
/** @noinspection PhpUndefinedFunctionInspection */
```

### 26.7 로그인이 필요한 테스트

```php
test('로그인 후 프로필 페이지 접근', function () {
    $page = $this->visit(TEST_BASE_URL . '/user/login.php');

    // 필고 테스트 로그인: 이메일:비밀번호 형식으로 입력
    $page->type('phone_number', 'banana@test.com:12345a,*')
         ->click('SMS 코드 전송')
         ->assertSee('프로필');
})->group('browser', 'auth');
```

### 26.8 v7 관리자 대시보드 인증 패턴 (2차 인증 쿠키)

v7 관리자 페이지는 2단계 인증이 필요하다: (1) session_id 쿠키, (2) 대시보드 2차 인증 쿠키.

```php
// 관리자 인증 상수 정의
if (!defined('V7_ADMIN_SESSION_ID')) {
    define('V7_ADMIN_SESSION_ID', '090e2895f9280a7d7d6ec11d3f0ce483-186619');
}
if (!defined('V7_ADMIN_COOKIE_KEY')) {
    define('V7_ADMIN_COOKIE_KEY', md5('admin-dashboard-credentials'));
}
if (!defined('V7_ADMIN_COOKIE_VALUE')) {
    define('V7_ADMIN_COOKIE_VALUE', md5('Wc~8603,*'));
}

browserTest('v7 관리자 대시보드에 접근할 수 있다', function () {
    /** @var \Pest\Browser\Api\PendingAwaitablePage $page */
    $page = $this->visit(V7_TEST_BASE_URL . '/admin');

    // 1단계: session_id 쿠키 설정
    $page->script("document.cookie = 'session_id=" . V7_ADMIN_SESSION_ID . "; path=/'");

    // 2단계: 2차 인증 쿠키 설정
    $page->script("document.cookie = '" . V7_ADMIN_COOKIE_KEY . "=" . V7_ADMIN_COOKIE_VALUE . "; path=/'");

    // 쿠키 적용을 위해 페이지 새로고침
    $page->navigate(V7_TEST_BASE_URL . '/admin');

    // 관리자 대시보드 확인
    $page->assertPresent('.admin-nav');
    $page->assertSee('대시보드');
})->group('browser', 'v7', 'admin', 'smoke');
```

### 26.9 Playwright 타임아웃 방지 — script()로 폼 제출

Playwright의 `click()`/`press()`는 5초 내에 클릭 액션이 완료되지 않으면 타임아웃 에러가 발생한다.
**폼 제출로 페이지 네비게이션이 발생하는 경우**, `script()`로 폼을 직접 제출하고 `waitForEvent('load')`로 대기해야 한다.

```php
// ❌ 잘못된 방식 — Playwright 타임아웃 발생 가능
$page->press('인증');  // 페이지 이동 발생 시 타임아웃!

// ✅ 올바른 방식 — script()로 직접 제출 + load 대기
$page->script("document.querySelector('.admin-access-denied form').submit()");
$page->waitForEvent('load');

// 제출 후 결과 확인
$page->assertPresent('.admin-nav');
$page->assertSee('대시보드');
```

> **규칙**: 폼 제출 후 **같은 페이지에 머무는 경우**(AJAX 제출)는 `press()`를 사용하고,
> **페이지가 이동/리다이렉트되는 경우**(서버 사이드 POST → redirect)는 `script("form.submit()")` + `waitForEvent('load')`를 사용한다.

### 26.10 Vue.js v-model 입력값 조작 — nativeInputValueSetter 패턴

Vue.js의 `v-model` 바인딩된 input에 값을 설정할 때, 단순히 `.value`를 변경하면 Vue가 감지하지 못한다.
**nativeInputValueSetter + input 이벤트 dispatch** 패턴을 사용해야 한다.

```php
$testVersion = '99.0.' . (time() % 1000);
$page->script(
    "(() => {" .
    "  var input = document.querySelector('input[placeholder=\"예: 2.0.16\"]');" .
    "  var nativeInputValueSetter = Object.getOwnPropertyDescriptor(" .
    "    window.HTMLInputElement.prototype, 'value').set;" .
    "  nativeInputValueSetter.call(input, '{$testVersion}');" .
    "  input.dispatchEvent(new Event('input', { bubbles: true }));" .
    "})()"
);
```

> **핵심**: `Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set`을 사용하면
> Vue.js의 getter/setter 프록시를 우회하여 네이티브 value를 설정하고, `input` 이벤트를 dispatch하여 Vue가 변경을 감지하게 한다.

### 26.11 Vue.js v-model DOM 속성 — placeholder 셀렉터 사용

Vue.js는 `v-model` 디렉티브를 컴파일 시 DOM에서 제거한다.
따라서 `document.querySelector('input[v-model="settings.xxx"]')`는 **항상 null을 반환**한다.

```php
// ❌ 잘못된 방식 — v-model은 DOM 속성이 아님 (항상 null 반환)
$page->script("document.querySelector('input[v-model=\"settings.app_version_android\"]').value");

// ✅ 올바른 방식 — placeholder, class, id 등 실제 DOM 속성으로 선택
$page->script("document.querySelector('input[placeholder=\"예: 2.0.16\"]').value");
```

| 셀렉터 | 사용 가능 여부 | 설명 |
|--------|---------------|------|
| `input[v-model="..."]` | ❌ 사용 불가 | Vue.js가 컴파일 시 제거 |
| `input[placeholder="..."]` | ✅ 사용 가능 | HTML 표준 속성 유지 |
| `input[type="text"]` | ✅ 사용 가능 | HTML 표준 속성 유지 |
| `input.class-name` | ✅ 사용 가능 | CSS 클래스로 선택 |
| `#element-id` | ✅ 사용 가능 | ID 셀렉터 |

### 26.12 script() 메서드의 return 키워드 주의사항

PEST의 `script()` 메서드는 Playwright의 `page.evaluate()`를 내부 호출한다.
**Playwright evaluate에서는 최상위 `return`을 사용하지 않고, 마지막 표현식의 값이 자동 반환된다.**

```php
// ❌ 잘못된 방식 — SyntaxError: Illegal return statement
$title = $page->script("return document.title");

// ✅ 올바른 방식 — 표현식 값이 자동 반환됨
$title = $page->script("document.title");
$value = $page->script("document.querySelector('#input').value");
$count = $page->script("document.querySelectorAll('.item').length");
```

### 26.13 패밀리사이트 테스트

```php
test('패밀리사이트 홈페이지 접근', function () {
    $page = $this->visit('https://banana.philgo.com');

    $page->assertPresent('#site-footer')
         ->assertSee('banana');
})->group('browser', 'family-site');
```

---

## 27. CI/CD 설정 (GitHub Actions)

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: lts/*

- name: Install dependencies
  run: npm ci

- name: Install Playwright Browsers
  run: npx playwright install --with-deps
```

---

## 핵심 메서드 요약 (Quick Reference)

### 상호작용 메서드

| 메서드 | 설명 | 예시 |
|--------|------|------|
| `visit()` | 페이지 방문 | `$this->visit($url)` |
| `navigate()` | 다른 페이지로 이동 | `$page->navigate('/about')` |
| `click()` | 요소 클릭 | `$page->click('로그인')` |
| `press()` | 버튼 누르기 | `$page->press('Submit')` |
| `type()` | 텍스트 즉시 입력 | `$page->type('email', 'a@b.com')` |
| `typeSlowly()` | 텍스트 천천히 입력 | `$page->typeSlowly('email', 'a@b.com')` |
| `append()` | 기존 값에 추가 | `$page->append('desc', ' 추가')` |
| `clear()` | 입력 필드 비우기 | `$page->clear('search')` |
| `keys()` | 키보드 키 입력 | `$page->keys('#input', 'text')` |
| `select()` | 드롭다운 선택 | `$page->select('country', 'KR')` |
| `radio()` | 라디오 버튼 선택 | `$page->radio('size', 'large')` |
| `check()` | 체크박스 체크 | `$page->check('terms')` |
| `uncheck()` | 체크박스 해제 | `$page->uncheck('newsletter')` |
| `attach()` | 파일 업로드 | `$page->attach('file', '/path')` |
| `submit()` | 폼 제출 | `$page->submit()` |
| `drag()` | 드래그 | `$page->drag('#a', '#b')` |
| `hover()` | 호버 | `$page->hover('#item')` |
| `resize()` | 창 크기 조정 | `$page->resize(1280, 720)` |
| `wait()` | 대기 (초) | `$page->wait(2)` |
| `script()` | JS 실행 | `$page->script('document.title')` |

### Assertion 메서드

| 메서드 | 설명 |
|--------|------|
| `assertSee()` | 텍스트 보임 |
| `assertDontSee()` | 텍스트 안 보임 |
| `assertSeeIn()` | 특정 요소 내 텍스트 보임 |
| `assertPresent()` | DOM에 요소 존재 |
| `assertMissing()` | 요소 안 보임 |
| `assertVisible()` | 요소가 보임 |
| `assertTitle()` | 페이지 제목 일치 |
| `assertUrlIs()` | URL 일치 |
| `assertPathIs()` | 경로 일치 |
| `assertChecked()` | 체크박스 체크됨 |
| `assertSelected()` | 드롭다운 선택됨 |
| `assertEnabled()` | 필드 활성화 |
| `assertDisabled()` | 필드 비활성화 |
| `assertAttribute()` | 속성 값 일치 |
| `assertNoSmoke()` | JS 에러/콘솔/접근성 종합 |
| `assertNoJavaScriptErrors()` | JS 에러 없음 |
| `assertNoConsoleLogs()` | 콘솔 로그 없음 |
| `assertNoAccessibilityIssues()` | 접근성 문제 없음 |
| `assertScreenshotMatches()` | 스크린샷 비교 일치 |

### 설정 메서드

| 메서드 | 설명 |
|--------|------|
| `inFirefox()` | Firefox로 테스트 |
| `inSafari()` | Safari로 테스트 |
| `inDarkMode()` | 다크 모드 |
| `on()->mobile()` | 모바일 에뮬레이션 |
| `on()->iPhone14Pro()` | iPhone 14 Pro 에뮬레이션 |
| `withLocale()` | 로케일 설정 |
| `withTimezone()` | 타임존 설정 |
| `withUserAgent()` | User Agent 설정 |
| `withHost()` | 호스트 설정 |
| `geolocation()` | 위치 설정 |
