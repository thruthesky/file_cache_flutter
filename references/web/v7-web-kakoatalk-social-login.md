# 카카오톡 소셜 로그인 (v7 웹)

카카오톡 소셜 로그인의 웹 리다이렉트(Authorization Code) 방식 구현 문서이다.
v7 홈페이지(`v7/` 폴더)에서 카카오 OAuth를 통해 Firebase Custom Token으로 로그인하는 전체 흐름을 다룬다.

---

## 목차

1. [핵심 원리: 카카오 → Firebase Custom Token 방식](#1-핵심-원리-카카오--firebase-custom-token-방식)
2. [전체 동작 흐름 (5단계)](#2-전체-동작-흐름-5단계)
3. [카카오톡 앱 키 정보](#3-카카오톡-앱-키-정보)
4. [카카오 디벨로퍼스 콘솔 설정](#4-카카오-디벨로퍼스-콘솔-설정)
5. [파일 구조](#5-파일-구조)
6. [PHP 백엔드 구현 — KakaoLoginService](#6-php-백엔드-구현--kakaologinservice)
7. [OAuth 시작 — start.php](#7-oauth-시작--startphp)
8. [OAuth 콜백 — callback.php](#8-oauth-콜백--callbackphp)
9. [Firebase 로그인 완료 — complete.php](#9-firebase-로그인-완료--completephp)
10. [로그인 페이지 UI — login.php](#10-로그인-페이지-ui--loginphp)
11. [CSS 스타일 — login.css](#11-css-스타일--logincss)
12. [Config 설정 메서드](#12-config-설정-메서드)
13. [Google 로그인과의 비교](#13-google-로그인과의-비교)
14. [보안 설계](#14-보안-설계)
15. [트러블슈팅](#15-트러블슈팅)
16. [로그아웃](#16-로그아웃)
17. [관련 파일 목록](#17-관련-파일-목록)

---

## 1. 핵심 원리: 카카오 → Firebase Custom Token 방식

### 1.1 최종 목표

카카오톡에서 로그인하고 Firebase Auth에 Custom Token으로 로그인하는 것이 최종 목표이다.

- 카카오톡에서 별도 회원 정보를 가져올 필요 없음 (카카오 고유 사용자 ID만 필요)
- Firebase Custom Token을 서버(PHP)에서 발급하여 클라이언트에서 Firebase Auth 로그인 수행
- 이후 흐름은 Google 로그인과 동일: `v7api('user.socialLogin')` → 세션 쿠키 생성 → 홈 리다이렉트

### 1.2 왜 Custom Token인가

카카오는 Firebase에서 직접 지원하는 인증 제공자가 아니다.
Google이나 Apple처럼 `signInWithPopup()`으로 바로 로그인할 수 없으므로,
서버에서 Firebase Custom Token을 발급하여 `signInWithCustomToken()`으로 Firebase에 로그인한다.

### 1.3 Firebase UID 형식

```
kakao:{카카오사용자ID}
```

예시: `kakao:454835416`

이 UID는 Firebase Auth에 자동으로 사용자를 생성하거나 기존 사용자를 참조한다.

---

## 2. 전체 동작 흐름 (5단계)

```
[1] /user/login 카카오 버튼 클릭
    → window.location.href = '/auth/kakao/start'

[2] v7/auth/kakao/start.php
    → state 생성 (CSRF 방지) → $_SESSION에 저장
    → 302 리다이렉트 → kauth.kakao.com/oauth/authorize

[3] 카카오 로그인 (사용자 인증)
    → 302 리다이렉트 → /auth/kakao/callback?code=XXX&state=YYY

[4] v7/auth/kakao/callback.php
    → state 검증 (CSRF 방지)
    → code → access_token 교환 (카카오 API)
    → access_token → 카카오 사용자 ID 조회
    → Firebase Custom Token 발급 (kakao:{id})
    → $_SESSION에 Custom Token 저장
    → 302 리다이렉트 → /auth/kakao/complete

[5] v7/auth/kakao/complete.php (v7 레이아웃 안에서 실행)
    → 세션에서 Custom Token 꺼내기 (1회용 삭제)
    → Firebase signInWithCustomToken() → Firebase 로그인
    → getIdToken() → Firebase ID Token 획득
    → v7api('user.socialLogin') → PHP 세션 쿠키 생성
    → window.location.href = '/' (홈 리다이렉트)
```

### 흐름 다이어그램

```
브라우저            v7 서버(PHP)           카카오 서버           Firebase
  │                    │                     │                    │
  │─ 카카오 버튼 클릭 ─→│                     │                    │
  │                    │                     │                    │
  │←─ 302 Redirect ───│                     │                    │
  │  (kauth.kakao.com) │                     │                    │
  │                    │                     │                    │
  │─ 카카오 로그인 ────────────────────────→│                    │
  │                    │                     │                    │
  │←─ 302 Redirect ──────────────────────│                    │
  │  (/auth/kakao/callback?code=XXX)       │                    │
  │                    │                     │                    │
  │─────────────────→│                     │                    │
  │                    │─ code→token ──────→│                    │
  │                    │←─ access_token ───│                    │
  │                    │                     │                    │
  │                    │─ 사용자 ID 조회 ──→│                    │
  │                    │←─ kakao user id ──│                    │
  │                    │                     │                    │
  │                    │─ Custom Token 발급 ───────────────────→│
  │                    │←─ JWT (custom token) ─────────────────│
  │                    │                     │                    │
  │←─ 302 Redirect ───│                     │                    │
  │  (/auth/kakao/complete)                  │                    │
  │                    │                     │                    │
  │  signInWithCustomToken() ──────────────────────────────────→│
  │←─ Firebase User ─────────────────────────────────────────│
  │                    │                     │                    │
  │  getIdToken() ─────────────────────────────────────────────→│
  │←─ ID Token ────────────────────────────────────────────────│
  │                    │                     │                    │
  │─ v7api('user.socialLogin') ──→│          │                    │
  │                    │  verifyIdToken()     │                    │
  │                    │  세션 쿠키 생성       │                    │
  │←─ JSON + Set-Cookie ────────│          │                    │
  │                    │                     │                    │
  │  홈(/) 리다이렉트    │                     │                    │
```

---

## 3. 카카오톡 앱 키 정보

| 항목 | 값 | 용도 |
|------|-----|------|
| 앱 URL | `https://developers.kakao.com/console/app/136610` | 카카오 디벨로퍼스 콘솔 |
| 앱 이름 | `SONUB` | 비즈앱 |
| REST API 키 | `f5b07b420c2eb86be485058cc4dab56a` | OAuth 토큰 교환 (서버 전용) |
| JavaScript 키 | `46155a5c4b32a68ca0ec643ec6efd150` | 웹 SDK용 |
| 네이티브 앱 키 | `cf75184c7c72f507d6bb5e39627925d3` | Flutter/iOS/Android용 |

이 키들은 `V7\Utils\Config` 클래스에서 정적 메서드로 제공한다.

---

## 4. 카카오 디벨로퍼스 콘솔 설정

### 4.1 필수 설정 체크리스트

| 순서 | 설정 항목 | 위치 | 설명 |
|------|----------|------|------|
| 1 | 카카오 로그인 활성화 | 앱 설정 → 카카오 로그인 | ON으로 설정 |
| 2 | Redirect URI 등록 | 앱 → 플랫폼 키 → REST API → 카카오 로그인 리다이렉트 URI | 서버 환경에 맞는 URI 등록 |
| 3 | 웹 플랫폼 등록 | 앱 설정 → 플랫폼 → Web | 사이트 도메인 등록 |

### 4.2 환경별 Redirect URI

| 환경 | Redirect URI |
|------|-------------|
| 로컬 개발 | `https://v7-local.philgo.com/auth/kakao/callback` |
| 테스트 서버 | `https://philgo.net/auth/kakao/callback` |
| 프로덕션 | `https://philgo.com/auth/kakao/callback` |

### 4.3 웹 플랫폼 도메인

| 환경 | 도메인 |
|------|--------|
| 로컬 개발 | `https://v7-local.philgo.com` |
| 테스트 서버 | `https://philgo.net` |
| 프로덕션 | `https://philgo.com` |

> 카카오 디벨로퍼스 콘솔에 등록한 Redirect URI와 코드에서 생성하는 URI가 100% 일치해야 한다.
> `Config::kakaoRedirectUri()`가 현재 서버의 scheme + host를 기반으로 동적으로 URI를 생성한다.

---

## 5. 파일 구조

```
lib/user/
  └── KakaoLoginService.php          # 카카오 OAuth + Firebase Custom Token 서비스

v7/auth/kakao/
  ├── start.php                       # [Step 2] OAuth 인가 시작
  ├── callback.php                    # [Step 4] 콜백 처리
  └── complete.php                    # [Step 5] Firebase 로그인 완료

v7/user/
  ├── login.php                       # 로그인 페이지 (카카오 버튼 포함)
  └── login.css                       # 카카오 브랜드 색상 CSS

v7/utils/
  └── Config.php                      # 카카오 키 메서드 (kakaoRestApiKey 등)
```

---

## 6. PHP 백엔드 구현 -- KakaoLoginService

**소스 파일**: `lib/user/KakaoLoginService.php`
**네임스페이스**: `Philgo\User`
**PSR-4 매핑**: `Philgo\User\` → `lib/user/`

### 핵심 결정: 기존 `Philgo\User` 네임스페이스 활용

`KakaoLoginService`는 별도 모듈을 만들지 않고 기존 `lib/user/` 폴더에 배치한다.
이미 PSR-4 매핑이 `"Philgo\\User\\": "lib/user/"`로 설정되어 있기 때문이다.

### 4개 정적 메서드

```php
<?php
namespace Philgo\User;

use Kreait\Firebase\Factory;
use V7\Utils\Config;

class KakaoLoginService
{
    /**
     * 카카오 OAuth authorize URL 생성
     *
     * @param string $state CSRF 방지용 state 값
     * @return string 카카오 인가 페이지 URL
     */
    public static function getAuthorizeUrl(string $state): string
    {
        $params = http_build_query([
            'client_id' => Config::kakaoRestApiKey(),
            'redirect_uri' => Config::kakaoRedirectUri(),
            'response_type' => 'code',
            'state' => $state,
        ]);
        return 'https://kauth.kakao.com/oauth/authorize?' . $params;
    }

    /**
     * 인가 코드를 access_token으로 교환 (cURL POST)
     *
     * 카카오 토큰 교환 API: POST https://kauth.kakao.com/oauth/token
     *
     * @param string $code 카카오 인가 코드
     * @return string access_token
     * @throws \RuntimeException 토큰 교환 실패 시
     */
    public static function exchangeCodeForToken(string $code): string
    {
        $ch = curl_init('https://kauth.kakao.com/oauth/token');
        if ($ch === false) {
            throw new \RuntimeException('cURL 초기화 실패');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'authorization_code',
                'client_id' => Config::kakaoRestApiKey(),
                'redirect_uri' => Config::kakaoRedirectUri(),
                'code' => $code,
            ]),
            CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_TIMEOUT => 10,
        ]);

        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            throw new \RuntimeException('카카오 토큰 교환 요청 실패: ' . $curlError);
        }
        if ($httpCode !== 200) {
            throw new \RuntimeException('카카오 토큰 교환 실패: HTTP ' . $httpCode);
        }

        /** @var array<string, mixed>|null $data */
        $data = json_decode((string) $response, true);
        if (!is_array($data) || !isset($data['access_token'])) {
            $errorDesc = is_array($data) ? ($data['error_description'] ?? '알 수 없는 오류') : '응답 파싱 실패';
            throw new \RuntimeException('카카오 토큰 교환 실패: ' . $errorDesc);
        }

        return (string) $data['access_token'];
    }

    /**
     * access_token으로 카카오 사용자 ID 조회 (cURL GET)
     *
     * 카카오 사용자 정보 API: GET https://kapi.kakao.com/v2/user/me
     *
     * @param string $accessToken 카카오 access_token
     * @return string 카카오 사용자 ID (숫자 문자열)
     * @throws \RuntimeException 사용자 정보 조회 실패 시
     */
    public static function getKakaoUserId(string $accessToken): string
    {
        $ch = curl_init('https://kapi.kakao.com/v2/user/me');
        if ($ch === false) {
            throw new \RuntimeException('cURL 초기화 실패');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/x-www-form-urlencoded;charset=utf-8',
            ],
            CURLOPT_TIMEOUT => 10,
        ]);

        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($response === false || $httpCode !== 200) {
            throw new \RuntimeException('카카오 사용자 정보 조회 실패: HTTP ' . $httpCode);
        }

        /** @var array<string, mixed>|null $data */
        $data = json_decode((string) $response, true);
        if (!is_array($data) || !isset($data['id'])) {
            throw new \RuntimeException('카카오 사용자 ID 조회 실패');
        }

        return (string) $data['id'];
    }

    /**
     * Firebase Custom Token 발급
     *
     * Kreait Firebase SDK를 사용하여 서비스 계정 JSON으로 Custom Token 발급.
     * UID 형식: kakao:{카카오사용자ID}
     *
     * @param string $kakaoUserId 카카오 사용자 ID
     * @return string Firebase Custom Token (JWT)
     * @throws \RuntimeException Custom Token 발급 실패 시
     */
    public static function createFirebaseCustomToken(string $kakaoUserId): string
    {
        try {
            $factory = (new Factory)
                ->withServiceAccount(ROOT_DIR . '/etc/philgo-firebase-service-account.json');
            $auth = $factory->createAuth();
            $customToken = $auth->createCustomToken('kakao:' . $kakaoUserId);
            return $customToken->toString();
        } catch (\Throwable $e) {
            throw new \RuntimeException('Firebase Custom Token 발급 실패: ' . $e->getMessage());
        }
    }
}
```

### 핵심 설계 결정

| 결정 | 이유 |
|------|------|
| `UserService::socialLogin()` 수정 불필요 | Custom Token으로 Firebase에 로그인하면 Firebase ID Token이 생성되고, 기존 socialLogin 흐름(`verifyIdTokenWithClaims`)을 그대로 탄다. 빈 email/name인 경우도 이미 처리되어 있다. |
| `KakaoLoginService`를 별도 클래스로 분리 | 카카오 OAuth 로직을 UserService에 섞지 않고 독립적으로 관리하기 위함 |
| `Kreait\Firebase\Factory` 직접 사용 | `FirebaseService`는 토큰 검증 전용이므로, Custom Token 발급은 별도로 Factory를 초기화한다 |

---

## 7. OAuth 시작 -- start.php

**소스 파일**: `v7/auth/kakao/start.php`
**접속 URL**: `https://v7-local.philgo.com/auth/kakao/start`

이 파일은 HTML을 출력하지 않고 리다이렉트만 수행한다.

```php
<?php
use Philgo\User\KakaoLoginService;

// 세션 시작 (state 저장용)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// CSRF 방지용 state 생성 → 세션에 저장
$state = bin2hex(random_bytes(16));
$_SESSION['kakao_state'] = $state;

// 카카오 OAuth 인가 페이지로 리다이렉트
$authorizeUrl = KakaoLoginService::getAuthorizeUrl($state);
header('Location: ' . $authorizeUrl);
exit;
```

### 동작 설명

1. CSRF 방지용 `state` 값을 랜덤 생성하여 `$_SESSION['kakao_state']`에 저장
2. `KakaoLoginService::getAuthorizeUrl($state)`로 카카오 인가 URL 생성
3. `302` 리다이렉트로 카카오 로그인 페이지로 이동
4. `exit`으로 v7 레이아웃 렌더링을 건너뜀

---

## 8. OAuth 콜백 -- callback.php

**소스 파일**: `v7/auth/kakao/callback.php`
**접속 URL**: `https://v7-local.philgo.com/auth/kakao/callback?code=XXX&state=YYY`

카카오 서버에서 자동 리다이렉트되는 페이지이다. HTML을 출력하지 않는다.

```php
<?php
use Philgo\User\KakaoLoginService;

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

try {
    // 카카오에서 에러 응답이 온 경우
    if (!empty($_GET['error'])) {
        throw new \RuntimeException('카카오 로그인 거부: ' . ($_GET['error_description'] ?? $_GET['error']));
    }

    // state 검증 (CSRF 방지)
    $sessionState = $_SESSION['kakao_state'] ?? '';
    $requestState = $_GET['state'] ?? '';
    if (empty($sessionState) || !hash_equals($sessionState, $requestState)) {
        throw new \RuntimeException('잘못된 요청입니다 (state 불일치)');
    }
    unset($_SESSION['kakao_state']);

    // 인가 코드 확인
    $code = $_GET['code'] ?? '';
    if (empty($code)) {
        throw new \RuntimeException('인가 코드가 없습니다');
    }

    // Step 1: code → access_token 교환
    $accessToken = KakaoLoginService::exchangeCodeForToken($code);

    // Step 2: 카카오 사용자 ID 조회
    $kakaoUserId = KakaoLoginService::getKakaoUserId($accessToken);

    // Step 3: Firebase Custom Token 발급
    $customToken = KakaoLoginService::createFirebaseCustomToken($kakaoUserId);

    // 세션에 Custom Token 저장 (complete 페이지에서 1회용으로 사용)
    $_SESSION['kakao_custom_token'] = $customToken;

    // complete 페이지로 리다이렉트
    header('Location: /auth/kakao/complete');
    exit;

} catch (\RuntimeException $e) {
    // 에러 시 로그인 페이지로 리다이렉트 (에러 메시지를 세션에 저장)
    $_SESSION['kakao_login_error'] = $e->getMessage();
    header('Location: /user/login');
    exit;
}
```

### 동작 설명

1. `state` 파라미터를 세션에 저장된 값과 `hash_equals()`로 비교 (CSRF 방지)
2. 인가 코드(`code`)를 카카오 API로 전송하여 `access_token`으로 교환
3. `access_token`으로 카카오 사용자 ID 조회
4. 카카오 사용자 ID로 Firebase Custom Token 발급 (`kakao:{id}`)
5. Custom Token을 세션에 저장하고 `/auth/kakao/complete`로 리다이렉트
6. 에러 발생 시 에러 메시지를 세션에 저장하고 `/user/login`으로 리다이렉트

---

## 9. Firebase 로그인 완료 -- complete.php

**소스 파일**: `v7/auth/kakao/complete.php`
**접속 URL**: `https://v7-local.philgo.com/auth/kakao/complete`

이 파일은 v7 레이아웃 안에서 실행되며, JavaScript로 Firebase 로그인을 완료한다.

```php
<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// 세션에서 Custom Token 꺼내기 (1회용 삭제)
$customToken = $_SESSION['kakao_custom_token'] ?? '';
unset($_SESSION['kakao_custom_token']);

// Custom Token이 없으면 로그인 페이지로 리다이렉트
if (empty($customToken)) {
    header('Location: /user/login');
    exit;
}

$pageTitle = '카카오 로그인 처리중...';
?>

<!-- Firebase SDK (Auth만 로드) -->
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-app-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-auth-compat.js"></script>

<div id="kakao-complete-app" style="text-align: center; padding: 3rem;">
    <wa-spinner style="font-size: 3rem; --indicator-color: #FEE500;"></wa-spinner>
    <p style="margin-top: 1rem; color: var(--wa-color-text-quiet);">카카오 로그인 처리중...</p>
    <wa-callout v-if="error" variant="danger" size="small" style="max-width: 400px; margin: 1rem auto;">
        <i slot="icon" class="fa-solid fa-triangle-exclamation"></i>
        {{ error }}
    </wa-callout>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const customToken = <?= json_encode($customToken) ?>;

    Vue.createApp({
        data() {
            return { error: '' };
        },
        async mounted() {
            try {
                // Firebase 초기화
                const firebaseConfig = <?= firebase_config_json() ?>;
                if (!firebase.apps.length) {
                    firebase.initializeApp(firebaseConfig);
                }

                // Custom Token으로 Firebase 로그인
                const result = await firebase.auth().signInWithCustomToken(customToken);

                // Firebase ID Token 획득
                const idToken = await result.user.getIdToken();

                // v7 API로 소셜 로그인 (세션 쿠키 생성)
                await v7api('user.socialLogin', {
                    id_token: idToken,
                    login_provider: 'kakaotalk'
                });

                // 홈으로 리다이렉트
                window.location.href = '/';
            } catch (err) {
                console.error('[Kakao-Login] 완료 처리 실패:', err);
                this.error = err.message || '카카오 로그인 처리 중 오류가 발생했습니다.';
                setTimeout(() => { window.location.href = '/user/login'; }, 3000);
            }
        }
    }).mount('#kakao-complete-app');
});
</script>
```

### 동작 설명

1. 세션에서 Custom Token을 꺼내고 즉시 삭제 (1회용)
2. Custom Token이 없으면 로그인 페이지로 리다이렉트
3. Vue.js 앱이 마운트되면 Firebase 초기화 → `signInWithCustomToken()` 호출
4. Firebase ID Token 획득 후 `v7api('user.socialLogin')` 호출
5. 서버에서 `UserService::socialLogin()`이 실행되어 세션 쿠키 생성
6. 홈(`/`)으로 리다이렉트
7. 에러 발생 시 에러 메시지를 표시하고 3초 후 로그인 페이지로 이동

### 핵심: `login_provider: 'kakaotalk'`

`v7api('user.socialLogin')` 호출 시 `login_provider`를 `'kakaotalk'`으로 전달한다.
이 값은 `sf_member` 테이블의 `login_provider` 컬럼에 저장되어 카카오 로그인 사용자를 식별한다.

---

## 10. 로그인 페이지 UI -- login.php

**소스 파일**: `v7/user/login.php`
**접속 URL**: `https://v7-local.philgo.com/user/login`

### 카카오 버튼 HTML

```html
<!-- 카카오톡 아이디 로그인 -->
<wa-button
    class="social-btn social-btn-kakao"
    variant="neutral"
    appearance="accent"
    size="large"
    :loading="loading === 'kakao' || null"
    :disabled="loading !== '' || null"
    @click="loginWithKakao"
>
    <i slot="start" class="fa-solid fa-comment"></i>
    카카오톡 아이디 로그인
</wa-button>
```

### loginWithKakao() Vue 메서드

```javascript
loginWithKakao() {
    this.loading = 'kakao';
    this.error = '';
    this.success = '';
    // 카카오 OAuth 인가 페이지로 리다이렉트 (서버 측 처리)
    window.location.href = '/auth/kakao/start';
}
```

Google 로그인과 달리 클라이언트에서 Firebase SDK를 직접 호출하지 않는다.
`/auth/kakao/start`로 페이지를 이동시키면 서버 측에서 전체 OAuth 흐름을 처리한다.

### 카카오 에러 메시지 처리

```php
// 카카오 로그인 실패 시 세션에 저장된 에러 메시지 읽기 (1회용)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
$kakaoLoginError = $_SESSION['kakao_login_error'] ?? '';
unset($_SESSION['kakao_login_error']);
```

```javascript
data() {
    return {
        loading: '',
        error: <?= json_encode($kakaoLoginError) ?> || '',
        success: '',
    };
}
```

`callback.php`에서 에러가 발생하면 세션에 에러 메시지를 저장하고 `/user/login`으로 리다이렉트한다.
`login.php`는 세션에서 에러 메시지를 읽어 Vue 앱의 `error` 데이터에 주입한다.

---

## 11. CSS 스타일 -- login.css

**소스 파일**: `v7/user/login.css`

### 카카오 버튼 브랜드 색상

```css
/* 카카오 버튼 브랜드 색상 */
.social-btn-kakao {
    --wa-color-neutral-on-loud: #191919;
    --wa-color-neutral-fill-loud: #FEE500;
    --wa-color-neutral-fill-loud-hover: #F0D800;
    --wa-color-neutral-fill-loud-active: #E0CA00;
}
```

| CSS 변수 | 값 | 설명 |
|----------|-----|------|
| `--wa-color-neutral-on-loud` | `#191919` | 버튼 텍스트/아이콘 색상 (검정에 가까운 진회색) |
| `--wa-color-neutral-fill-loud` | `#FEE500` | 카카오 공식 브랜드 노란색 |
| `--wa-color-neutral-fill-loud-hover` | `#F0D800` | hover 시 약간 어두운 노란색 |
| `--wa-color-neutral-fill-loud-active` | `#E0CA00` | active(클릭) 시 더 어두운 노란색 |

Web Awesome Pro의 `wa-button` 컴포넌트에서 `variant="neutral"` + `appearance="accent"`와 함께 사용한다.

---

## 12. Config 설정 메서드

**소스 파일**: `v7/utils/Config.php`

카카오 키는 별도 config 파일 대신 `V7\Utils\Config` 클래스에 통합되어 있다.

```php
// 카카오 REST API 키 (서버에서 OAuth 토큰 교환 시 사용)
public static function kakaoRestApiKey(): string
{
    return 'f5b07b420c2eb86be485058cc4dab56a';
}

// 카카오 JavaScript 키 (웹 SDK용)
public static function kakaoJavascriptKey(): string
{
    return '46155a5c4b32a68ca0ec643ec6efd150';
}

// 카카오 네이티브 앱 키 (Flutter/iOS/Android용)
public static function kakaoNativeKey(): string
{
    return 'cf75184c7c72f507d6bb5e39627925d3';
}

// 카카오 OAuth Redirect URI 동적 생성
public static function kakaoRedirectUri(): string
{
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'v7-local.philgo.com';
    return $scheme . '://' . $host . '/auth/kakao/callback';
}
```

### kakaoRedirectUri() 동적 생성 이유

Redirect URI를 하드코딩하지 않고 현재 서버의 `scheme + host`에서 동적으로 생성한다.
이렇게 하면 로컬 개발(`v7-local.philgo.com`), 테스트 서버(`philgo.net`), 프로덕션(`philgo.com`)에서 별도 설정 없이 동작한다.
단, 카카오 디벨로퍼스 콘솔에 각 환경의 URI를 모두 등록해야 한다.

---

## 13. Google 로그인과의 비교

| 구분 | Google 로그인 | 카카오톡 로그인 |
|------|-------------|--------------|
| Firebase 지원 | 직접 지원 (`signInWithPopup`) | 직접 지원 안 함 → Custom Token 필요 |
| 인증 흐름 | 팝업 1단계 (클라이언트 완결) | 리다이렉트 5단계 (서버 경유) |
| 서버 역할 | 없음 | 필수 (code→token→userId→customToken) |
| UI 패턴 | 팝업 → 즉시 결과 | 페이지 이동 → 카카오 → 콜백 → 완료 |
| 로딩 표시 | 팝업 대기 중 로딩 | 로딩 페이지(complete.php) |
| `login_provider` | `'google'` | `'kakaotalk'` |
| Firebase UID 형식 | Google 자동 생성 | `kakao:{카카오ID}` (커스텀) |
| 에러 처리 | 팝업 닫기 → 즉시 복귀 | 세션 에러 → 로그인 페이지 리다이렉트 |

### 공통점

| 항목 | 설명 |
|------|------|
| 최종 API 호출 | 둘 다 `v7api('user.socialLogin', { id_token, login_provider })` 호출 |
| 서버 처리 | 둘 다 `UserService::socialLogin()` → `AuthService::loginUser()` |
| 세션 생성 | 둘 다 동일한 세션 쿠키 생성 메커니즘 사용 |
| 사용자 생성 | 둘 다 Firebase UID로 sf_member 검색 → 없으면 자동 생성 |

---

## 14. 보안 설계

### 14.1 CSRF 방지 (state 파라미터)

| 단계 | 동작 |
|------|------|
| start.php | `$state = bin2hex(random_bytes(16))` 생성 → `$_SESSION['kakao_state']` 저장 |
| callback.php | `hash_equals($_SESSION['kakao_state'], $_GET['state'])` 비교 |
| 검증 후 | `unset($_SESSION['kakao_state'])` (1회용 삭제) |

### 14.2 토큰 보안

| 토큰 | 노출 범위 | 설명 |
|------|----------|------|
| 카카오 REST API 키 | 서버 전용 | `Config::kakaoRestApiKey()` — PHP 소스코드에서만 사용 |
| 카카오 access_token | 서버 전용 | callback.php에서만 사용, 프론트에 전달하지 않음 |
| Firebase Custom Token | 세션 → 프론트 (1회용) | complete.php에서 세션에서 꺼낸 후 즉시 삭제 |
| Firebase ID Token | 프론트 → 서버 | 기존 socialLogin 흐름과 동일 |

### 14.3 세션 기반 토큰 전달

Custom Token을 URL 파라미터가 아닌 PHP 세션으로 전달한다.
이렇게 하면 URL에 토큰이 노출되지 않고, 1회용으로 사용 후 즉시 삭제된다.

---

## 15. 트러블슈팅

### 15.1 "state 불일치" 에러

| 원인 | 해결 |
|------|------|
| 세션 쿠키 미설정 | PHP 세션이 제대로 시작되는지 확인. `session_start()` 호출 확인 |
| 다른 탭에서 로그인 시도 | 세션에 저장된 state가 덮어씌워짐. 동시에 여러 탭에서 로그인하면 안 됨 |
| 너무 오래 걸린 경우 | PHP 세션 GC로 세션이 삭제됨. 재시도 |

### 15.2 "카카오 토큰 교환 실패" 에러

| 원인 | 해결 |
|------|------|
| Redirect URI 불일치 | 카카오 콘솔에 등록된 URI와 `Config::kakaoRedirectUri()` 결과가 100% 일치하는지 확인 |
| 인가 코드 만료 | 인가 코드는 유효시간이 짧음 (수분). 콜백이 즉시 처리되는지 확인 |
| REST API 키 오류 | `Config::kakaoRestApiKey()` 값이 올바른지 확인 |

### 15.3 "Firebase Custom Token 발급 실패" 에러

| 원인 | 해결 |
|------|------|
| 서비스 계정 파일 없음 | `etc/philgo-firebase-service-account.json` 파일 존재 확인 |
| 서비스 계정 권한 부족 | Firebase 콘솔에서 서비스 계정에 "Firebase Admin SDK" 권한 확인 |
| Kreait SDK 미설치 | `composer require kreait/firebase-php` 확인 |

### 15.4 complete.php에서 "Firebase SDK가 로드되지 않았습니다" 에러

| 원인 | 해결 |
|------|------|
| CDN 로딩 실패 | `<script defer>` 태그가 정상적으로 로딩되는지 네트워크 탭 확인 |
| defer 로딩 순서 | `DOMContentLoaded` 이벤트 리스너 안에서 실행되므로 SDK 로딩 완료 후 실행됨 |

---

## 16. 로그아웃

카카오 로그인도 Firebase Auth 기반이므로 로그아웃은 기존과 동일하다.

```javascript
// v7/widgets/layout/layout.topbar.php
function v7DevLogout() {
    document.cookie = 'session_id=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
    location.reload();
}
```

세션 쿠키를 삭제하면 SSR/CSR 모두에서 비로그인 상태가 된다.
Firebase Auth의 `signOut()`도 호출하면 Firebase 측 로그인도 해제된다.

---

## 17. 관련 파일 목록

| 파일 | 용도 | 주요 함수/메서드 |
|------|------|-----------------|
| `lib/user/KakaoLoginService.php` | 카카오 OAuth + Firebase Custom Token 서비스 | `getAuthorizeUrl()`, `exchangeCodeForToken()`, `getKakaoUserId()`, `createFirebaseCustomToken()` |
| `v7/auth/kakao/start.php` | 카카오 OAuth 인가 시작 | state 생성, 카카오 리다이렉트 |
| `v7/auth/kakao/callback.php` | 콜백: code→token→userId→customToken | state 검증, 토큰 교환, Custom Token 발급 |
| `v7/auth/kakao/complete.php` | Firebase 로그인 완료 | `signInWithCustomToken()`, `v7api('user.socialLogin')` |
| `v7/user/login.php` | 로그인 페이지 (카카오 버튼 + Vue.js) | `loginWithKakao()`, `loginWithGoogle()` |
| `v7/user/login.css` | 로그인 페이지 CSS | `.social-btn-kakao` (카카오 브랜드 색상) |
| `v7/utils/Config.php` | 카카오 키 설정 | `kakaoRestApiKey()`, `kakaoJavascriptKey()`, `kakaoNativeKey()`, `kakaoRedirectUri()` |
| `lib/user/UserService.php` | 소셜 로그인 공통 처리 | `socialLogin()` (카카오/Google 공통) |
| `lib/utils/AuthService.php` | 인증 서비스 | `getLoginUser()`, `loginUser()` |
| `lib/utils/FirebaseService.php` | Firebase 토큰 검증 | `verifyIdTokenWithClaims()` |
| `etc/philgo-firebase-service-account.json` | Firebase 서비스 계정 | Custom Token 발급에 사용 |
