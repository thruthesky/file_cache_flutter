# v7 웹 로그인 인증 시스템

## 목차

1. [개요](#1-개요)
2. [인증 아키텍처 다이어그램](#2-인증-아키텍처-다이어그램)
3. [SSR 인증 — 서버 사이드 렌더링에서의 로그인 확인](#3-ssr-인증--서버-사이드-렌더링에서의-로그인-확인)
4. [CSR 인증 — 클라이언트 사이드 JavaScript API 호출](#4-csr-인증--클라이언트-사이드-javascript-api-호출)
5. [API 인증 — api.php 엔드포인트 호출](#5-api-인증--apiphp-엔드포인트-호출)
6. [소셜 로그인 전체 흐름 (Google)](#6-소셜-로그인-전체-흐름)
7. [카카오톡 소셜 로그인](#7-카카오톡-소셜-로그인)
8. [네이버 소셜 로그인](#8-네이버-소셜-로그인)
9. [세션 ID 생성 및 쿠키 관리](#9-세션-id-생성-및-쿠키-관리)
10. [관리자 권한 확인](#10-관리자-권한-확인)
11. [Firebase ID Token 검증](#11-firebase-id-token-검증)
12. [SSR 페이지에서의 실제 사용 사례](#12-ssr-페이지에서의-실제-사용-사례)
13. [개발 환경 테스트 로그인](#13-개발-환경-테스트-로그인)
14. [캐싱 메커니즘](#14-캐싱-메커니즘)
15. [보안 특징](#15-보안-특징)
16. [소스코드 파일 경로 목록](#16-소스코드-파일-경로-목록)

---

## 1. 개요

v7 웹 시스템은 **Firebase Auth + 서버 세션 쿠키** 기반의 하이브리드 인증 방식을 사용한다.

| 인증 경로 | 사용 시점 | 인증 수단 | 검증 방식 |
|-----------|----------|----------|----------|
| **경로 1: 세션 쿠키** | SSR 페이지 로드, 일반 HTTP 요청 | `session_id` 쿠키 | MD5 해시 재계산 비교 |
| **경로 2: Firebase ID Token** | API 호출 (로그인 시) | `id_token` 파라미터 | Kreait Firebase SDK 검증 |

### 핵심 원칙

- **`session_start()` 미사용**: PHP 네이티브 세션을 사용하지 않음
- **`$_SESSION` 미사용**: 세션 정보를 쿠키에만 저장
- **DB에 세션 미저장**: 세션 ID는 결정론적 해시이므로 DB 저장 불필요
- **v6 코드 미사용**: `login()`, `pdo()`, `in()` 등 레거시 함수 사용 금지

---

## 2. 인증 아키텍처 다이어그램

### 2.1 전체 인증 흐름

```
┌──────────────────────────────────────────────────────────────────────┐
│                    v7 웹 인증 시스템 전체 구조                         │
└──────────────────────────────────────────────────────────────────────┘

                    ┌──────────────────┐
                    │   웹 브라우저      │
                    │   (클라이언트)      │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         SSR 요청         CSR 요청       API 요청
     (페이지 로드)     (v7api() 호출)   (직접 호출)
              │              │              │
              │              │              │
    ┌─────────▼──┐   ┌──────▼──────┐   ┌──▼──────────┐
    │  v7.php     │   │ v7/js/v7api.js │   │ Flutter 앱   │
    │  ↓          │   │ axios.post  │   │ v7api()     │
    │  v7/boot.php│   │ ('/api.php')│   │             │
    │  ↓          │   └──────┬──────┘   └──┬──────────┘
    │  layout.php │          │              │
    │  ↓          │          │              │
    │  페이지 PHP  │          │              │
    └─────────┬───┘          │              │
              │              │              │
              └──────────────┼──────────────┘
                             │
                             ▼
              ┌──────────────────────────────┐
              │  AuthService::getLoginUser()  │
              │  (2경로 인증)                  │
              └──────────────┬───────────────┘
                             │
              ┌──────────────┼──────────────┐
              │                             │
     ┌────────▼────────┐          ┌─────────▼─────────┐
     │ 경로 1: 세션     │          │ 경로 2: Firebase   │
     │ $_COOKIE 확인    │          │ id_token 확인      │
     │ ↓               │          │ ↓                  │
     │ 형식 검증        │          │ Kreait SDK 검증     │
     │ ↓               │          │ ↓                  │
     │ DB 조회 (idx)   │          │ DB 조회 (uid)      │
     │ ↓               │          │ ↓                  │
     │ 해시 재검증      │          │ 세션 쿠키 저장       │
     └────────┬────────┘          └─────────┬─────────┘
              │                             │
              └──────────────┬──────────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │ UserEntity|null  │
                    │ (sf_member)      │
                    └──────────────────┘
```

### 2.2 SSR 인증 흐름 (세션 쿠키 기반)

```
브라우저                              서버 (v7.php → layout.php → 페이지)
   │                                    │
   │── HTTP 요청 ──────────────────────→│
   │   Cookie: session_id=HASH-IDX      │
   │                                    │
   │                        AuthService::getLoginUser()
   │                                    │
   │                        $_COOKIE['session_id'] 확인
   │                                    │
   │                        세션 ID 파싱: "HASH-IDX" → idx 추출
   │                                    │
   │                        DB 조회: SELECT * FROM sf_member WHERE idx = ?
   │                                    │
   │                        firebase_uid 존재 확인
   │                                    │
   │                        해시 재계산: md5(SALT+idx+uid+phone) == HASH ?
   │                                    │
   │                        ✅ 검증 성공 → $user 배열 반환
   │                                    │
   │                        PHP에서 로그인 상태에 따라 HTML 렌더링
   │                                    │
   │←── HTML 응답 (로그인 UI 포함) ──────│
   │                                    │
```

### 2.3 CSR 인증 흐름 (JavaScript v7api 호출)

```
브라우저 (JavaScript)                  서버 (api.php)
   │                                    │
   │── v7api('post.list', {...}) ──────→│
   │   axios.post('/api.php', params)   │
   │   Cookie: session_id=HASH-IDX      │  ← 브라우저가 자동 전송
   │                                    │
   │                        api.php: Controller 동적 로드
   │                        AuthService::getLoginUser()
   │                        (쿠키의 session_id로 인증)
   │                                    │
   │←── JSON 응답 ──────────────────────│
   │                                    │
```

### 2.4 소셜 로그인 흐름 (Firebase ID Token)

```
브라우저                   Firebase        서버 (api.php)
   │                        │               │
   │── Google Sign-In ────→│               │
   │   signInWithPopup()    │               │
   │                        │               │
   │←── Firebase User ─────│               │
   │                        │               │
   │── getIdToken() ───────→│               │
   │                        │               │
   │←── ID Token (JWT) ────│               │
   │                        │               │
   │── v7api('user.socialLogin', ──────────→│
   │      { id_token, login_provider })     │
   │                                        │
   │                    FirebaseService::verifyIdTokenWithClaims()
   │                    (Kreait SDK로 JWT 검증)
   │                                        │
   │                    DB 조회: firebase_uid로 sf_member 검색
   │                    (없으면 자동 생성)
   │                                        │
   │                    AuthService::loginUser($user)
   │                    → setcookie('session_id', ...)  ← 세션 쿠키 생성
   │                                        │
   │←── JSON 응답 + Set-Cookie 헤더 ────────│
   │                                        │
   │    브라우저: 쿠키 저장                    │
   │    이후 모든 요청에 자동 전송             │
   │                                        │
```

---

## 3. SSR 인증 — 서버 사이드 렌더링에서의 로그인 확인

### 핵심 코드

**소스 파일**: `lib/utils/AuthService.php`

```php
<?php
use Philgo\Utils\AuthService;

// SSR 페이지에서 로그인 확인
$user = AuthService::getLoginUser();  // ?UserEntity

if ($user === null) {
    // 비로그인 상태
    echo '<a href="' . url()->user->login . '">로그인</a>';
} else {
    // 로그인 상태 — UserEntity 프로퍼티로 접근
    echo htmlspecialchars($user->nickname ?: $user->name ?: '내정보');
}
```

### getLoginUser() 메서드 전체 코드

**소스 파일**: `lib/utils/AuthService.php` (라인 46-79)

```php
public static function getLoginUser(): ?UserEntity
{
    // 이미 확인 완료된 경우 캐시된 결과 반환
    if (self::$checked) {
        return self::$cachedUser;
    }
    self::$checked = true;

    // === 경로 1: 세션 기반 인증 (SSR용 - 쿠키 또는 파라미터의 session_id) ===
    $sessionId = $_COOKIE[self::SESSION_KEY] ?? RequestUtils::get(self::SESSION_KEY);

    if (!empty($sessionId)) {
        $entity = self::getUserBySessionId($sessionId);
        if ($entity !== null) {
            self::$cachedUser = $entity;
            return self::$cachedUser;
        }
    }

    // === 경로 2: Firebase ID Token 인증 (API용 - id_token 파라미터) ===
    $idToken = RequestUtils::get('id_token');

    if (!empty($idToken)) {
        $entity = self::getUserByIdToken($idToken);
        if ($entity !== null) {
            self::setSessionCookie($entity->toArray());
            self::$cachedUser = $entity;
            return self::$cachedUser;
        }
    }

    return null;
}
```

### 반환값 구조

`getLoginUser()`는 `UserEntity` 객체를 반환한다 (sf_member 테이블 기반):

```php
// 성공 시 — UserEntity 프로퍼티로 접근
$user = AuthService::getLoginUser();  // ?UserEntity
$user->idx;              // int — 사용자 고유 ID
$user->firebase_uid;     // string — Firebase UID
$user->email;            // string
$user->name;             // string
$user->nickname;         // string
$user->photo_url;        // string
$user->phone_number;     // string
$user->admin;            // string ('Y' = 관리자)
$user->login_provider;   // string
$user->point;            // int — 포인트
$user->level;            // int — 레벨 (동적 계산)
$user->level_progress;   // int — 레벨 진행률 0~100 (동적 계산)
$user->no_of_post;       // int — 글 수
$user->no_of_comment;    // int — 댓글 수

// 비로그인 시
null
```

> **⚠️ 이전 버전과의 차이**: 기존 배열 접근(`$user['idx']`)이 아니라 프로퍼티 접근(`$user->idx`)을 사용한다.

---

## 4. CSR 인증 — 클라이언트 사이드 JavaScript API 호출

### v7api() 함수

**소스 파일**: `v7/js/v7api.js` (라인 16-43)

```javascript
async function v7api(method, params = {}, options = {}) {
    const alertOnError = options.alertOnError !== undefined ? options.alertOnError : true;
    params.method = method;

    try {
        const res = await axios.post('/api.php', params);
        if (res.data && res.data.success === false) {
            throw new Error(res.data.message || 'API 호출 실패');
        }
        return res.data;
    } catch (error) {
        let message = '';
        if (error.response && error.response.data && error.response.data.message) {
            message = error.response.data.message;
        } else if (error.message) {
            message = error.message;
        } else {
            message = 'API 호출 중 오류가 발생했습니다.';
        }
        if (alertOnError) {
            alert(message);
        }
        throw error;
    }
}
```

### 쿠키 자동 전송 메커니즘

- `axios.post('/api.php', params)` 호출 시 **동일 도메인(same-origin)이므로 쿠키가 자동 전송**됨
- `withCredentials` 설정이 별도로 필요하지 않음
- 서버에서 `$_COOKIE['session_id']`로 즉시 접근 가능
- **CSR에서 별도의 인증 토큰 전달이 불필요** — 쿠키가 자동 전송

### CSR에서의 인증된 API 호출 예시

```javascript
// 로그인 상태에서 API 호출 — 쿠키 자동 전송
const myData = await v7api('user.me');  // 현재 로그인한 사용자 정보

const posts = await v7api('post.list', {
    post_id: 'freetalk',
    limit: 20
});
```

---

## 5. API 인증 — api.php 엔드포인트 호출

### api.php 엔트리포인트

**소스 파일**: `api.php`

```php
<?php
const ROOT_DIR = __DIR__;
require_once ROOT_DIR . '/vendor/autoload.php';
require_once ROOT_DIR . '/lib/constants.php';
require_once ROOT_DIR . '/etc/app.config.php';

// boot.php를 포함하지 않음 (경량 설계)

// method 파싱: "user.socialLogin" → ["user", "socialLogin"]
[$module, $action] = RequestUtils::parseMethod();

// Controller 동적 로드: "user" → Philgo\User\UserController
$className = "Philgo\\{$pascalModule}\\{$pascalModule}Controller";
$ctrl = new $className();

// 멤버 함수 호출
$input = RequestUtils::all();
$res = $ctrl->$action($input);

// JSON 응답
echo json_encode($res->toArray(), JSON_UNESCAPED_UNICODE);
```

### Controller에서 인증 확인

```php
// lib/user/UserController.php
public function me(array $input): UserEntity
{
    $user = AuthService::getLoginUser();
    if ($user === null) {
        throw new \RuntimeException('로그인이 필요합니다.');
    }
    return UserService::getMe($user);
}
```

---

## 6. 소셜 로그인 전체 흐름

### 클라이언트: Firebase Google Sign-In

**소스 파일**: `v7/user/login.php` (라인 133-188)

```javascript
async loginWithGoogle() {
    this.loading = 'google';
    try {
        // 1. Firebase Google Sign-In Popup
        const provider = new firebase.auth.GoogleAuthProvider();
        const result = await firebase.auth().signInWithPopup(provider);

        // 2. Firebase ID Token 획득
        const idToken = await result.user.getIdToken();

        // 3. v7 API 호출 (서버에 토큰 전송)
        const data = await v7api('user.socialLogin',
            { id_token: idToken, login_provider: 'google' },
            { alertOnError: false }
        );

        // 4. 성공 → 홈으로 이동 (세션 쿠키는 서버에서 자동 설정됨)
        this.success = '환영합니다, ' + (data.nickname || data.name || '회원') + '님!';
        setTimeout(() => { window.location.href = '/'; }, 1000);
    } catch (err) {
        if (err.code === 'auth/popup-closed-by-user') {
            this.loading = '';
            return;
        }
        this.error = err.message || '로그인 중 오류가 발생했습니다.';
    }
}
```

### 서버: UserService::socialLogin()

**소스 파일**: `lib/user/UserService.php` (라인 193-257)

```php
public static function socialLogin(array $input): UserEntity
{
    $idToken = (string)($input['id_token'] ?? '');
    $loginProvider = (string)($input['login_provider'] ?? '');

    // 1. Firebase ID Token 검증 → uid, email, name, picture 추출
    $claims = FirebaseService::verifyIdTokenWithClaims($idToken);
    $firebaseUid = $claims['uid'];

    // 2. Firebase UID로 DB 조회
    $user = Db::fetch("SELECT * FROM sf_member WHERE firebase_uid = ?", [$firebaseUid]);

    if ($user === false || empty($user)) {
        // 3a. 신규 사용자 → 자동 생성
        $idx = Db::insert(
            "INSERT INTO sf_member (id, firebase_uid, login_provider, email, name, nickname, photo_url, stamp)
             VALUES (:id, :firebase_uid, :login_provider, :email, :name, :nickname, :photo_url, :stamp)",
            [/* ... */]
        );
        $user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [$idx]);
        if ($user === false) {
            throw new RuntimeException('사용자 생성 후 조회에 실패했습니다.');
        }
    } else {
        // 3b. 기존 사용자 → login_provider 업데이트
        if ($loginProvider !== '') {
            Db::execute("UPDATE sf_member SET login_provider = :login_provider WHERE idx = :idx",
                ['login_provider' => $loginProvider, 'idx' => $user['idx']]);
        }
    }

    // 4. 세션 쿠키 저장 (핵심!)
    AuthService::loginUser($user);

    unset($user['password']);
    return new UserEntity($user);
}
```

---

## 7. 카카오톡 소셜 로그인

카카오는 Firebase에서 직접 지원하지 않으므로 Firebase Custom Token 방식을 사용한다.
서버 측에서 카카오 OAuth Authorization Code 흐름을 처리하고, Firebase Custom Token을 발급하여
기존 `socialLogin` 흐름에 합류시킨다.

> **상세 구현 문서**: [v7-web-kakoatalk-social-login.md](v7-web-kakoatalk-social-login.md)

### 전체 흐름 (5단계)

```
[1] /user/login 카카오 버튼 클릭 → window.location.href = '/auth/kakao/start'
[2] v7/auth/kakao/start.php → state 생성 → 302 → kauth.kakao.com/oauth/authorize
[3] 카카오 로그인 (사용자 인증) → 302 → /auth/kakao/callback?code=XXX&state=YYY
[4] v7/auth/kakao/callback.php → state 검증 → code→token→ID→Custom Token → 302 → /auth/kakao/complete
[5] v7/auth/kakao/complete.php → signInWithCustomToken → v7api('user.socialLogin') → 홈 리다이렉트
```

### Google 로그인과의 차이

| 구분 | Google 로그인 | 카카오톡 로그인 |
|------|-------------|--------------|
| Firebase 지원 | 직접 지원 (`signInWithPopup`) | Custom Token 필요 |
| 인증 흐름 | 팝업 1단계 (클라이언트 완결) | 리다이렉트 5단계 (서버 경유) |
| 서버 역할 | 없음 | 필수 (code→token→userId→customToken) |
| `login_provider` | `'google'` | `'kakaotalk'` |
| Firebase UID | Google 자동 생성 | `kakao:{카카오ID}` (커스텀) |

### 관련 파일

| 파일 | 용도 |
|------|------|
| `lib/user/KakaoLoginService.php` | 카카오 OAuth + Firebase Custom Token 서비스 (namespace: `Philgo\User`) |
| `v7/auth/kakao/start.php` | OAuth 인가 시작 (세션에 state 저장 → 카카오 리다이렉트) |
| `v7/auth/kakao/callback.php` | 콜백: code→access_token→kakaoUserId→Firebase Custom Token |
| `v7/auth/kakao/complete.php` | Firebase signInWithCustomToken → v7api('user.socialLogin') → 홈 |
| `v7/user/login.php` | 카카오 버튼 + loginWithKakao() Vue 메서드 |
| `v7/user/login.css` | 카카오 브랜드 색상 (#FEE500) |
| `v7/utils/Config.php` | `kakaoRestApiKey()`, `kakaoJavascriptKey()`, `kakaoNativeKey()`, `kakaoRedirectUri()` |

### 핵심 설계 결정

- **UserService::socialLogin() 수정 불필요**: Custom Token으로 Firebase에 로그인하면 Firebase ID Token이 생성되고, 기존 socialLogin 흐름을 그대로 탄다
- **KakaoLoginService를 lib/user/에 배치**: 기존 `Philgo\User\` PSR-4 매핑 활용
- **카카오 키를 Config 클래스에 통합**: 별도 config 파일 불필요

---

## 8. 네이버 소셜 로그인

네이버도 카카오와 마찬가지로 Firebase에서 직접 지원하지 않으므로 Firebase Custom Token 방식을 사용한다.
카카오톡과 **100% 동일한 아키텍처 패턴**을 따르며, 서버 측에서 네이버 OAuth Authorization Code 흐름을 처리한다.

> **상세 구현 문서**: [v7-web-naver-social-login.md](v7-web-naver-social-login.md)

### 전체 흐름 (5단계)

```
[1] /user/login 네이버 버튼 클릭 → window.location.href = '/auth/naver/start'
[2] v7/auth/naver/start.php → state 생성 → 302 → nid.naver.com/oauth2.0/authorize
[3] 네이버 로그인 (사용자 인증) → 302 → /auth/naver/callback?code=XXX&state=YYY
[4] v7/auth/naver/callback.php → state 검증 → code+state→token→ID→Custom Token → 302 → /auth/naver/complete
[5] v7/auth/naver/complete.php → signInWithCustomToken → v7api('user.socialLogin') → 홈 리다이렉트
```

### 카카오톡 로그인과의 핵심 차이점

| 구분 | 카카오톡 | 네이버 |
|------|---------|--------|
| Client Secret | 선택 | **필수** (토큰 교환 시 반드시 전달) |
| 토큰 교환 시 state | 불필요 | **필요** (state도 함께 전달) |
| 프로필 응답 구조 | `{ id: "..." }` (최상위) | `{ response: { id: "..." } }` (중첩 구조) |
| Firebase UID | `kakao:{카카오ID}` | `naver:{네이버ID}` |
| `login_provider` | `'kakaotalk'` | `'naver'` |
| 브랜드 색상 | `#FEE500` (노란색) | `#03C75A` (초록색) |
| 서비스 클래스 | `KakaoLoginService` | `NaverLoginService` |

### 관련 파일

| 파일 | 용도 |
|------|------|
| `lib/user/NaverLoginService.php` | 네이버 OAuth + Firebase Custom Token 서비스 (namespace: `Philgo\User`) |
| `v7/auth/naver/start.php` | OAuth 인가 시작 (세션에 state 저장 → 네이버 리다이렉트) |
| `v7/auth/naver/callback.php` | 콜백: code+state→access_token→naverUserId→Firebase Custom Token |
| `v7/auth/naver/complete.php` | Firebase signInWithCustomToken → v7api('user.socialLogin') → 홈 |
| `v7/user/login.php` | 네이버 버튼 + loginWithNaver() Vue 메서드 |
| `v7/user/login.css` | 네이버 브랜드 색상 `.social-btn-naver` (#03C75A) |
| `v7/utils/Config.php` | `naverClientId()`, `naverClientSecret()`, `naverRedirectUri()` |

### 핵심 설계 결정

- **UserService::socialLogin() 수정 불필요**: Custom Token으로 Firebase에 로그인하면 Firebase ID Token이 생성되고, 기존 socialLogin 흐름을 그대로 탄다
- **NaverLoginService를 lib/user/에 배치**: 기존 `Philgo\User\` PSR-4 매핑 활용
- **네이버 키를 Config 클래스에 통합**: `naverClientId()`, `naverClientSecret()`, `naverRedirectUri()` 3개 정적 메서드

### 3사 소셜 로그인 비교 요약

| 구분 | Google | 카카오톡 | 네이버 |
|------|--------|---------|--------|
| Firebase 지원 | 직접 지원 (`signInWithPopup`) | Custom Token 필요 | Custom Token 필요 |
| 인증 흐름 | 팝업 1단계 (클라이언트 완결) | 리다이렉트 5단계 (서버 경유) | 리다이렉트 5단계 (서버 경유) |
| 서버 역할 | 없음 | 필수 | 필수 |
| `login_provider` | `'google'` | `'kakaotalk'` | `'naver'` |
| Firebase UID | Google 자동 생성 | `kakao:{ID}` | `naver:{ID}` |
| 브랜드 색상 | `#4285f4` (파란색) | `#FEE500` (노란색) | `#03C75A` (초록색) |

---

## 9. 세션 ID 생성 및 쿠키 관리

### 세션 ID 생성 알고리즘

**소스 파일**: `lib/utils/AuthService.php` (라인 166-175)

```php
private static function generateSessionId(array $user): string
{
    $hash = md5(
        LOGIN_SALT                        // 서버 비밀 솔트 상수
        . $user['idx']                    // 사용자 고유 ID
        . $user['firebase_uid']           // Firebase UID
        . ($user['phone_number'] ?? '')   // 전화번호 (선택)
    );
    return $hash . '-' . $user['idx'];    // 형식: "해시-idx"
}
```

**세션 ID 형식**:
```
a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6-12345
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^  ^^^^^
         MD5 해시 (32자)           idx
```

### 쿠키 저장

**소스 파일**: `lib/utils/AuthService.php` (라인 185-189)

```php
private static function setSessionCookie(array $user): void
{
    $sessionId = self::generateSessionId($user);
    setcookie(self::SESSION_KEY, $sessionId, time() + (86400 * 365 * 3), "/");
}
```

| 속성 | 값 | 설명 |
|------|-----|------|
| **이름** | `session_id` | `self::SESSION_KEY` 상수 |
| **값** | `{MD5해시}-{idx}` | 결정론적 해시 |
| **유효기간** | 3년 | `86400 * 365 * 3` 초 |
| **경로** | `/` | 전체 도메인 |

### loginUser() 메서드

**소스 파일**: `lib/utils/AuthService.php` (라인 199-204)

```php
public static function loginUser(array $user): void
{
    self::setSessionCookie($user);                        // 쿠키 저장
    self::$cachedUser = UserEntity::fromArray($user);    // UserEntity로 변환 후 캐시
    self::$checked = true;                                // 캐시 플래그
}
```

### 세션 ID 검증 (getUserBySessionId)

**소스 파일**: `lib/utils/AuthService.php` (라인 94-126)

```php
private static function getUserBySessionId(string $sessionId): ?UserEntity
{
    // 1. 세션 ID 형식 검증: "해시-idx" 분리
    $parts = explode('-', $sessionId);
    if (count($parts) !== 2) return null;

    $idx = (int) $parts[1];
    if ($idx <= 0) return null;

    // 2. DB에서 사용자 조회
    $user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [$idx]);
    if ($user === false || empty($user)) return null;

    // 3. firebase_uid 존재 확인
    if (empty($user['firebase_uid'])) return null;

    // 4. 세션 ID 해시 재생성 및 비교 (위변조 방지)
    $generated = self::generateSessionId($user);
    if ($generated !== $sessionId) return null;

    return UserEntity::fromArray($user);
}
```

### 로그아웃

클라이언트 측에서 쿠키를 삭제하여 로그아웃 처리한다:

```javascript
// v7/widgets/layout/layout.topbar.php
function v7DevLogout() {
    document.cookie = 'session_id=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    location.reload();
}
```

---

## 10. 관리자 권한 확인

### AuthService::isAdmin() 메서드

**소스 파일**: `lib/utils/AuthService.php`

```php
/**
 * 현재 로그인한 사용자가 관리자인지 확인한다.
 *
 * ADMINS 상수(Firebase UID 배열)와 대조하여 관리자 여부를 판단한다.
 * 비로그인 상태이면 false를 반환한다.
 *
 * @return bool 관리자이면 true, 비로그인 또는 비관리자이면 false
 */
public static function isAdmin(): bool
{
    $user = self::getLoginUser();
    if ($user === null) {
        return false;
    }
    $firebaseUid = $user->firebase_uid;
    return in_array($firebaseUid, ADMINS, true);
}
```

### 사용 예시

```php
<?php
use Philgo\Utils\AuthService;

// 관리자 페이지에서 권한 확인
if (!AuthService::isAdmin()) {
    echo '<p>접근 권한이 없습니다.</p>';
    return;
}

// 관리자 전용 기능
echo '<h1>관리자 대시보드</h1>';
```

### ADMINS 상수

**소스 파일**: `etc/app.config.php`

`ADMINS` 상수는 관리자 Firebase UID 배열이며, `api.php`와 `v7/boot.php` 모두에서 `etc/app.config.php`를 로드하므로 어디서든 접근 가능하다.

**소스 파일**: `v7/utils/Config.php`

`V7\Utils\Config::admins()` 메서드는 동일한 `ADMINS` 상수를 래핑하여 반환한다:

```php
public static function admins(): array
{
    return ADMINS;
}
```

---

## 11. Firebase ID Token 검증

### FirebaseService::verifyIdToken()

**소스 파일**: `lib/utils/FirebaseService.php` (라인 54-69)

```php
public static function verifyIdToken(string $token): string
{
    // 테스트 토큰 확인 (개발/테스트 환경용)
    if (isset(self::TEST_TOKENS[$token])) {
        return self::TEST_TOKENS[$token];
    }

    // 실제 Firebase 토큰 검증 (Kreait SDK)
    try {
        $auth = self::getAuth();
        $verifiedIdToken = $auth->verifyIdToken($token, leewayInSeconds: 360);
        return $verifiedIdToken->claims()->get('sub');  // Firebase UID
    } catch (FailedToVerifyToken $e) {
        throw new \RuntimeException('Firebase 토큰 검증 실패: ' . $e->getMessage());
    }
}
```

### verifyIdTokenWithClaims()

**소스 파일**: `lib/utils/FirebaseService.php` (라인 81-107)

```php
public static function verifyIdTokenWithClaims(string $token): array
{
    // 테스트 토큰인 경우 더미 정보 반환
    if (isset(self::TEST_TOKENS[$token])) {
        return [
            'uid' => self::TEST_TOKENS[$token],
            'email' => '',
            'name' => 'Test User',
            'picture' => '',
        ];
    }

    // 실제 토큰 검증 후 claims 추출
    $auth = self::getAuth();
    $verifiedIdToken = $auth->verifyIdToken($token, leewayInSeconds: 360);
    $claims = $verifiedIdToken->claims();
    return [
        'uid' => $claims->get('sub'),
        'email' => $claims->get('email', ''),
        'name' => $claims->get('name', ''),
        'picture' => $claims->get('picture', ''),
    ];
}
```

### 테스트 토큰

**소스 파일**: `lib/utils/FirebaseService.php` (라인 29-37)

```php
private const TEST_TOKENS = [
    'LOCAL_APPLE_TOKEN'  => 'OSXtfcfdJkcLBovnQAC6Q1WMa2x1',
    'LOCAL_BANANA_TOKEN' => 'DA76oHESU0YnHo7i9lzu85vdirA2',
    'LOCAL_CHERRY_TOKEN' => 'jrCM6IwsuDMxY2t30pgzfRIjAil2',
    'LIVE_ONE_TOKEN'     => 'RaHIcr45pvPzYdcDIv6JoW8DnSH2',
];
```

---

## 12. SSR 페이지에서의 실제 사용 사례

### 패턴 1: 탑바 로그인/프로필 분기

**소스 파일**: `v7/widgets/layout/layout.topbar.php`

```php
use Philgo\Utils\AuthService;

$v7LoginUser = AuthService::getLoginUser();  // ?UserEntity

<?php if ($v7LoginUser === null): ?>
    <a href="<?= url()->user->login ?>">로그인</a>
<?php else: ?>
    <a href="<?= url()->user->profile ?>">
        <?= htmlspecialchars($v7LoginUser->nickname ?: $v7LoginUser->name ?: '내정보') ?>
    </a>
<?php endif; ?>
```

### 패턴 2: 사이드바 프로필 위젯

**소스 파일**: `v7/widgets/layout/layout.sidebar-left.login.php`

```php
$v7SidebarLoginUser = AuthService::getLoginUser();  // ?UserEntity

<?php if ($v7SidebarLoginUser !== null): ?>
    <?php if (!empty($v7SidebarLoginUser->photo_url)): ?>
        <img src="<?= htmlspecialchars($v7SidebarLoginUser->photo_url) ?>"
             alt="" style="width:48px; height:48px; border-radius:50%;">
    <?php endif; ?>
    <div><?= htmlspecialchars($v7SidebarLoginUser->nickname ?: '(닉네임 없음)') ?></div>
<?php endif; ?>
```

### 패턴 3: 글 읽기 권한 체크

**소스 파일**: `v7/post/view.php`

```php
$v7LoginUser = AuthService::getLoginUser();  // ?UserEntity
$loginIdxMember = $v7LoginUser ? $v7LoginUser->idx : 0;
$loginIsAdmin = $v7LoginUser && $v7LoginUser->admin === 'Y';
```

### 패턴 4: 관리자 페이지 인증

**소스 파일**: `v7/admin/admin-layout.php`

```php
use Philgo\Utils\AuthService;

$loginUser = AuthService::getLoginUser();
$isAdmin = AuthService::isAdmin();

<?php if (!$isAdmin): ?>
    <div class="admin-access-denied">
        <h2>접근 권한이 없습니다</h2>
        <?php if (!$loginUser): ?>
            <p>관리자 계정으로 로그인해 주세요.</p>
        <?php else: ?>
            <p>관리자 권한이 있는 계정으로 로그인해 주세요.</p>
        <?php endif; ?>
    </div>
<?php endif; ?>
```

### 패턴 5: 메뉴 분기

**소스 파일**: `v7/menu/index.php`

```php
$loginUser = AuthService::getLoginUser();

<?php if ($loginUser): ?>
    <li><a href="<?= url()->user->logout ?>">로그아웃</a></li>
    <li><a href="<?= url()->user->resign ?>">회원 탈퇴</a></li>
<?php else: ?>
    <li><a href="<?= url()->user->login ?>">로그인</a></li>
<?php endif; ?>
```

---

## 13. 개발 환경 테스트 로그인

### 테스트 사용자 목록

**소스 파일**: `v7/utils/Config.php` — `Config::devUsers()`

| 키 | 이메일 | 비밀번호 |
|----|--------|---------|
| A | apple@test.com | `Config::devPassword()` (`12345a,*`) |
| B | banana@test.com | 동일 |
| C | cherry@test.com | 동일 |
| D | durian@test.com | 동일 |
| E | elderberry@test.com | 동일 |
| F | fig@test.com | 동일 |

### 개발 환경 테스트 로그인 코드

**소스 파일**: `v7/widgets/layout/layout.topbar.php` (라인 63-99)

```javascript
async function v7DevLogin(email) {
    try {
        var cred = await firebase.auth()
            .signInWithEmailAndPassword(email, '<?= Config::devPassword() ?>');
        var idToken = await cred.user.getIdToken();
        await v7api('user.socialLogin', { id_token: idToken }, { alertOnError: false });
        location.reload();
    } catch (e) {
        alert('로그인 실패: ' + e.message);
    }
}

function v7DevLogout() {
    document.cookie = 'session_id=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    location.reload();
}
```

---

## 14. 캐싱 메커니즘

### 정적 캐시 변수

**소스 파일**: `lib/utils/AuthService.php` (라인 30-33)

```php
private static ?UserEntity $cachedUser = null;
private static bool $checked = false;
```

### 동작 흐름

```
동일 요청 내:
  1회 호출: $checked=false → DB 조회 → $cachedUser 저장 → $checked=true
  2회 호출: $checked=true → $cachedUser 즉시 반환 (DB 조회 없음)
  3회 호출: $checked=true → $cachedUser 즉시 반환 (DB 조회 없음)
```

탑바, 사이드바, 메뉴 등 여러 위젯에서 동시에 `getLoginUser()`를 호출해도 **DB 조회는 1회만** 수행된다.

### 테스트용 캐시 초기화

```php
// PEST 테스트에서 요청 간 상태 격리
AuthService::reset();

// 테스트 사용자 직접 설정 (DB 조회 없이, 배열 → 내부에서 UserEntity 변환)
AuthService::setTestUser(['idx' => 123, 'firebase_uid' => 'test_uid']);
```

---

## 15. 보안 특징

### 세션 위변조 방지

세션 ID는 **결정론적 해시**이므로, 서버에서 매번 재계산하여 검증한다.

```
공격자가 idx만 변경: "original_hash-99999"
→ 서버: idx=99999 사용자 조회 → 해시 재계산
→ md5(SALT+99999+other_uid+phone) ≠ original_hash
→ 검증 실패 → null 반환
```

### 보안 속성 요약

| 항목 | 현재 상태 | 설명 |
|------|---------|------|
| 세션 위변조 방지 | ✅ 안전 | MD5 해시 + LOGIN_SALT 기반 검증 |
| Firebase 토큰 검증 | ✅ 안전 | Kreait SDK + 6분 leeway |
| password 필드 보호 | ✅ 안전 | socialLogin() 응답에서 unset |
| 쿠키 유효기간 | 3년 | `86400 * 365 * 3` |
| HttpOnly 플래그 | ❌ 미설정 | JavaScript에서 쿠키 접근 가능 (로그아웃 처리를 위해 의도적) |
| Secure 플래그 | ❌ 미설정 | 로컬 개발 환경 고려 |

---

## 16. 소스코드 파일 경로 목록

| 파일 | 용도 | 주요 함수/메서드 |
|------|------|-----------------|
| `lib/utils/AuthService.php` | 인증 서비스 (세션 + Firebase) | `getLoginUser()`, `isAdmin()`, `loginUser()`, `generateSessionId()`, `setSessionCookie()` |
| `lib/utils/FirebaseService.php` | Firebase ID Token 검증 | `verifyIdToken()`, `verifyIdTokenWithClaims()` |
| `lib/user/UserService.php` | 사용자 비즈니스 로직 | `socialLogin()` |
| `lib/user/UserController.php` | 사용자 API 컨트롤러 | `socialLogin()`, `me()` |
| `lib/utils/RequestUtils.php` | HTTP 입력 파라미터 처리 | `all()`, `get()`, `parseMethod()` |
| `lib/utils/Db.php` | DB 연결 (PDO) | `fetch()`, `insert()`, `execute()` |
| `v7/js/v7api.js` | v7 API 호출 래퍼 (JavaScript) | `v7api()` |
| `v7/user/login.php` | 로그인 UI (Vue.js + Firebase) | `loginWithGoogle()`, `loginWithKakao()`, `loginWithNaver()` |
| `v7/user/login.css` | 로그인 페이지 CSS | `.social-btn-kakao`, `.social-btn-naver` (소셜 브랜드 색상) |
| `lib/user/KakaoLoginService.php` | 카카오 OAuth + Firebase Custom Token | `getAuthorizeUrl()`, `exchangeCodeForToken()`, `getKakaoUserId()`, `createFirebaseCustomToken()` |
| `v7/auth/kakao/start.php` | 카카오 OAuth 인가 시작 | state 생성, 카카오 리다이렉트 |
| `v7/auth/kakao/callback.php` | 카카오 OAuth 콜백 | state 검증, 토큰 교환, Custom Token 발급 |
| `v7/auth/kakao/complete.php` | 카카오 Firebase 로그인 완료 | `signInWithCustomToken()`, `v7api('user.socialLogin')` |
| `lib/user/NaverLoginService.php` | 네이버 OAuth + Firebase Custom Token | `getAuthorizeUrl()`, `exchangeCodeForToken()`, `getNaverUserId()`, `createFirebaseCustomToken()` |
| `v7/auth/naver/start.php` | 네이버 OAuth 인가 시작 | state 생성, 네이버 리다이렉트 |
| `v7/auth/naver/callback.php` | 네이버 OAuth 콜백 | state 검증, 토큰 교환 (client_secret 필수), Custom Token 발급 |
| `v7/auth/naver/complete.php` | 네이버 Firebase 로그인 완료 | `signInWithCustomToken()`, `v7api('user.socialLogin')` |
| `v7/boot.php` | v7 부팅 (PSR-4 + 설정) | — |
| `v7/layout.php` | v7 전체 레이아웃 | — |
| `api.php` | API 엔트리포인트 | — |
| `v7/utils/Config.php` | v7 설정 래퍼 | `admins()`, `devUsers()`, `devPassword()`, `kakaoRestApiKey()`, `kakaoRedirectUri()`, `naverClientId()`, `naverClientSecret()`, `naverRedirectUri()` |
| `v7/widgets/layout/layout.topbar.php` | 탑바 (로그인 상태 표시 + 테스트 로그인) | — |
| `v7/widgets/layout/layout.sidebar-left.login.php` | 사이드바 로그인 위젯 | — |
| `v7/widgets/layout/layout.header-mobile.php` | 모바일 헤더 | — |
| `v7/admin/admin-layout.php` | 관리자 레이아웃 (권한 검증) | — |
| `v7/post/view.php` | 글 읽기 (권한 체크) | — |
| `v7/menu/index.php` | 전체 메뉴 (로그인 분기) | — |
