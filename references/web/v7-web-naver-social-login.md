# 네이버 소셜 로그인 (v7 웹)

네이버 소셜 로그인의 웹 리다이렉트(Authorization Code) 방식 구현 문서이다.
v7 홈페이지(`v7/` 폴더)에서 네이버 OAuth 2.0을 통해 Firebase Custom Token으로 로그인하는 전체 흐름을 다룬다.
카카오톡 소셜 로그인과 동일한 아키텍처 패턴을 따른다.

> **참고**: 카카오톡 소셜 로그인 문서 → [v7-web-kakoatalk-social-login.md](v7-web-kakoatalk-social-login.md)

---

## 목차

1. [핵심 원리: 네이버 → Firebase Custom Token 방식](#1-핵심-원리-네이버--firebase-custom-token-방식)
2. [전체 동작 흐름 (5단계)](#2-전체-동작-흐름-5단계)
3. [네이버 앱 키 정보](#3-네이버-앱-키-정보)
4. [네이버 디벨로퍼스 콘솔 설정](#4-네이버-디벨로퍼스-콘솔-설정)
5. [파일 구조](#5-파일-구조)
6. [PHP 백엔드 구현 — NaverLoginService](#6-php-백엔드-구현--naverloginservice)
7. [OAuth 시작 — start.php](#7-oauth-시작--startphp)
8. [OAuth 콜백 — callback.php](#8-oauth-콜백--callbackphp)
9. [Firebase 로그인 완료 — complete.php](#9-firebase-로그인-완료--completephp)
10. [로그인 페이지 UI — login.php](#10-로그인-페이지-ui--loginphp)
11. [CSS 스타일 — login.css](#11-css-스타일--logincss)
12. [Config 설정 메서드](#12-config-설정-메서드)
13. [네이버 로그인 API 상세 (공식 문서 기반)](#13-네이버-로그인-api-상세-공식-문서-기반)
14. [카카오톡 로그인과의 비교](#14-카카오톡-로그인과의-비교)
15. [Google 로그인과의 비교](#15-google-로그인과의-비교)
16. [보안 설계](#16-보안-설계)
17. [트러블슈팅](#17-트러블슈팅)
18. [로그아웃](#18-로그아웃)
19. [관련 파일 목록](#19-관련-파일-목록)

---

## 1. 핵심 원리: 네이버 → Firebase Custom Token 방식

### 1.1 최종 목표

네이버에서 로그인하고 Firebase Auth에 Custom Token으로 로그인하는 것이 최종 목표이다.

- 네이버에서 별도 회원 정보를 가져올 필요 없음 (네이버 고유 사용자 ID만 필요)
- Firebase Custom Token을 서버(PHP)에서 발급하여 클라이언트에서 Firebase Auth 로그인 수행
- 이후 흐름은 Google/카카오 로그인과 동일: `v7api('user.socialLogin')` → 세션 쿠키 생성 → 홈 리다이렉트

### 1.2 왜 Custom Token인가

네이버는 Firebase에서 직접 지원하는 인증 제공자가 아니다.
Google이나 Apple처럼 `signInWithPopup()`으로 바로 로그인할 수 없으므로,
서버에서 Firebase Custom Token을 발급하여 `signInWithCustomToken()`으로 Firebase에 로그인한다.

> 이 방식은 카카오톡 소셜 로그인과 **100% 동일한 아키텍처**이다.

### 1.3 Firebase UID 형식

```
naver:{네이버사용자ID}
```

예시: `naver:87654321`

이 UID는 Firebase Auth에 자동으로 사용자를 생성하거나 기존 사용자를 참조한다.

### 1.4 카카오톡과의 UID 차이

| 소셜 로그인 | Firebase UID 형식 | 예시 |
|------------|-------------------|------|
| 카카오톡 | `kakao:{id}` | `kakao:454835416` |
| **네이버** | **`naver:{id}`** | **`naver:87654321`** |
| Google | Google 자동 생성 | `Abc123def456...` |

---

## 2. 전체 동작 흐름 (5단계)

```
[1] /user/login 네이버 버튼 클릭
    → window.location.href = '/auth/naver/start'

[2] v7/auth/naver/start.php
    → state 생성 (CSRF 방지) → $_SESSION에 저장
    → 302 리다이렉트 → nid.naver.com/oauth2.0/authorize

[3] 네이버 로그인 (사용자 인증)
    → 302 리다이렉트 → /auth/naver/callback?code=XXX&state=YYY

[4] v7/auth/naver/callback.php
    → state 검증 (CSRF 방지)
    → code → access_token 교환 (네이버 API)
    → access_token → 네이버 사용자 ID 조회
    → Firebase Custom Token 발급 (naver:{id})
    → $_SESSION에 Custom Token 저장
    → 302 리다이렉트 → /auth/naver/complete

[5] v7/auth/naver/complete.php (v7 레이아웃 안에서 실행)
    → 세션에서 Custom Token 꺼내기 (1회용 삭제)
    → Firebase signInWithCustomToken() → Firebase 로그인
    → getIdToken() → Firebase ID Token 획득
    → v7api('user.socialLogin') → PHP 세션 쿠키 생성
    → window.location.href = '/' (홈 리다이렉트)
```

### 흐름 다이어그램

```
브라우저            v7 서버(PHP)           네이버 서버           Firebase
  │                    │                     │                    │
  │─ 네이버 버튼 클릭 ─→│                     │                    │
  │                    │                     │                    │
  │←─ 302 Redirect ───│                     │                    │
  │  (nid.naver.com)   │                     │                    │
  │                    │                     │                    │
  │─ 네이버 로그인 ────────────────────────→│                    │
  │                    │                     │                    │
  │←─ 302 Redirect ──────────────────────│                    │
  │  (/auth/naver/callback?code=XXX)       │                    │
  │                    │                     │                    │
  │─────────────────→│                     │                    │
  │                    │─ code→token ──────→│                    │
  │                    │  (+ client_secret)  │                    │
  │                    │←─ access_token ───│                    │
  │                    │                     │                    │
  │                    │─ 사용자 ID 조회 ──→│                    │
  │                    │  (Bearer token)     │                    │
  │                    │←─ naver user id ──│                    │
  │                    │                     │                    │
  │                    │─ Custom Token 발급 ───────────────────→│
  │                    │←─ JWT (custom token) ─────────────────│
  │                    │                     │                    │
  │←─ 302 Redirect ───│                     │                    │
  │  (/auth/naver/complete)                  │                    │
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

## 3. 네이버 앱 키 정보

| 항목 | 값 | 용도 |
|------|-----|------|
| 앱 URL | `https://developers.naver.com/apps/` | 네이버 디벨로퍼스 콘솔 |
| Client ID | `bE3wy5X71Z8aDgGMyEU6` | OAuth 인가 요청 + 토큰 교환 |
| Client Secret | `oLxNCMKImw` | 토큰 교환 시 필수 (서버 전용) |

이 키들은 `V7\Utils\Config` 클래스에서 정적 메서드로 제공한다.

### 카카오톡과의 키 구성 차이

| 항목 | 카카오톡 | 네이버 |
|------|---------|--------|
| 키 종류 | REST API, JavaScript, 네이티브 앱 (3개) | Client ID, Client Secret (2개) |
| Secret 키 | 선택 (콘솔에서 활성화한 경우만) | **필수** (토큰 교환 시 반드시 필요) |
| Config 메서드 | `kakaoRestApiKey()`, `kakaoJavascriptKey()`, `kakaoNativeKey()` | `naverClientId()`, `naverClientSecret()` |

---

## 4. 네이버 디벨로퍼스 콘솔 설정

> **공식 문서**: https://developers.naver.com/docs/login/api/api.md

### 4.1 필수 설정 체크리스트

| 순서 | 설정 항목 | 위치 | 설명 |
|------|----------|------|------|
| 1 | 애플리케이션 등록 | 네이버 디벨로퍼스 → 애플리케이션 등록 | 사용 API: "네이버 로그인" 선택 |
| 2 | 서비스 URL 등록 | 애플리케이션 설정 → API 설정 → 서비스 URL | 서비스 도메인 등록 |
| 3 | Callback URL 등록 | 애플리케이션 설정 → API 설정 → Callback URL | 서버 환경에 맞는 콜백 URL 등록 |
| 4 | 필수/선택 동의항목 설정 | 애플리케이션 설정 → API 설정 → 로그인 오픈 API 서비스 환경 | 웹, 모바일 등 선택 |

### 4.2 환경별 Callback URL

| 환경 | Callback URL |
|------|-------------|
| 로컬 개발 | `https://v7-local.philgo.com/auth/naver/callback` |
| 프로덕션 | `https://philgo.net/auth/naver/callback` |

### 4.3 서비스 URL

| 환경 | 서비스 URL |
|------|-----------|
| 로컬 개발 | `https://v7-local.philgo.com` |
| 프로덕션 | `https://philgo.net` |

> 네이버 디벨로퍼스 콘솔에 등록한 Callback URL과 코드에서 생성하는 URI가 100% 일치해야 한다.
> `Config::naverRedirectUri()`가 현재 서버의 scheme + host를 기반으로 동적으로 URI를 생성한다.

### 4.4 동의항목 설정

네이버 로그인 시 사용자에게 정보 제공 동의를 요청할 수 있다.
Firebase Custom Token 방식에서는 **네이버 고유 ID만 필요**하므로 추가 동의항목은 선택사항이다.

| 동의항목 | 필수 여부 | 설명 |
|----------|----------|------|
| 회원이름 | 선택 | 사용자 실명 |
| 이메일 | 선택 | 네이버 이메일 주소 |
| 프로필 사진 | 선택 | 프로필 이미지 URL |
| 별명 | 선택 | 네이버 닉네임 |
| 성별 | 선택 | F(여)/M(남)/U(미설정) |
| 생일 | 선택 | MM-DD 형식 |
| 출생연도 | 선택 | YYYY 형식 |
| 휴대전화번호 | 선택 | 010-XXXX-XXXX 형식 |

> 현재 구현에서는 네이버 고유 ID(`response.id`)만 사용하므로 추가 동의항목 없이도 동작한다.

---

## 5. 파일 구조

```
lib/user/
  └── NaverLoginService.php           # 네이버 OAuth + Firebase Custom Token 서비스

v7/auth/naver/
  ├── start.php                       # [Step 2] OAuth 인가 시작
  ├── callback.php                    # [Step 4] 콜백 처리
  └── complete.php                    # [Step 5] Firebase 로그인 완료

v7/user/
  ├── login.php                       # 로그인 페이지 (네이버 버튼 추가)
  └── login.css                       # 네이버 브랜드 색상 CSS 추가

v7/utils/
  └── Config.php                      # 네이버 키 메서드 (naverClientId 등) 추가
```

---

## 6. PHP 백엔드 구현 -- NaverLoginService

**소스 파일**: `lib/user/NaverLoginService.php`
**네임스페이스**: `Philgo\User`
**PSR-4 매핑**: `Philgo\User\` → `lib/user/`

### 핵심 결정: 기존 `Philgo\User` 네임스페이스 활용

`NaverLoginService`는 `KakaoLoginService`와 동일하게 기존 `lib/user/` 폴더에 배치한다.
이미 PSR-4 매핑이 `"Philgo\\User\\": "lib/user/"`로 설정되어 있기 때문이다.

### 4개 정적 메서드

```php
<?php
namespace Philgo\User;

use Kreait\Firebase\Factory;
use V7\Utils\Config;

class NaverLoginService
{
    /**
     * 네이버 OAuth authorize URL 생성
     *
     * 네이버 인가 엔드포인트: https://nid.naver.com/oauth2.0/authorize
     *
     * @param string $state CSRF 방지용 state 값
     * @return string 네이버 인가 페이지 URL
     */
    public static function getAuthorizeUrl(string $state): string
    {
        $params = http_build_query([
            'response_type' => 'code',
            'client_id' => Config::naverClientId(),
            'redirect_uri' => Config::naverRedirectUri(),
            'state' => $state,
        ]);
        return 'https://nid.naver.com/oauth2.0/authorize?' . $params;
    }

    /**
     * 인가 코드를 access_token으로 교환 (cURL POST/GET)
     *
     * 네이버 토큰 교환 API: https://nid.naver.com/oauth2.0/token
     *
     * ★ 카카오와의 차이점: client_secret이 필수이다.
     * 네이버는 client_id + client_secret을 토큰 교환 파라미터로 직접 전달한다.
     *
     * @param string $code 네이버 인가 코드
     * @param string $state state 값 (토큰 교환 시에도 전달)
     * @return string access_token
     * @throws \RuntimeException 토큰 교환 실패 시
     */
    public static function exchangeCodeForToken(string $code, string $state): string
    {
        $tokenUrl = 'https://nid.naver.com/oauth2.0/token';

        $ch = curl_init($tokenUrl);
        if ($ch === false) {
            throw new \RuntimeException('cURL 초기화 실패');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'authorization_code',
                'client_id' => Config::naverClientId(),
                'client_secret' => Config::naverClientSecret(),
                'code' => $code,
                'state' => $state,
            ]),
            CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_TIMEOUT => 10,
        ]);

        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if ($response === false) {
            throw new \RuntimeException('네이버 토큰 교환 요청 실패: ' . $curlError);
        }
        if ($httpCode !== 200) {
            throw new \RuntimeException('네이버 토큰 교환 실패: HTTP ' . $httpCode);
        }

        /** @var array<string, mixed>|null $data */
        $data = json_decode((string) $response, true);
        if (!is_array($data) || !isset($data['access_token'])) {
            $errorDesc = is_array($data) ? ($data['error_description'] ?? $data['error'] ?? '알 수 없는 오류') : '응답 파싱 실패';
            throw new \RuntimeException('네이버 토큰 교환 실패: ' . $errorDesc);
        }

        return (string) $data['access_token'];
    }

    /**
     * access_token으로 네이버 사용자 ID 조회 (cURL GET)
     *
     * 네이버 프로필 API: GET https://openapi.naver.com/v1/nid/me
     *
     * ★ 카카오와의 차이점: 응답이 { response: { id, ... } } 중첩 구조이다.
     * 카카오는 최상위에 id가 있지만, 네이버는 response 객체 안에 id가 있다.
     *
     * @param string $accessToken 네이버 access_token
     * @return string 네이버 사용자 ID
     * @throws \RuntimeException 사용자 정보 조회 실패 시
     */
    public static function getNaverUserId(string $accessToken): string
    {
        $ch = curl_init('https://openapi.naver.com/v1/nid/me');
        if ($ch === false) {
            throw new \RuntimeException('cURL 초기화 실패');
        }

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
            ],
            CURLOPT_TIMEOUT => 10,
        ]);

        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($response === false || $httpCode !== 200) {
            throw new \RuntimeException('네이버 사용자 정보 조회 실패: HTTP ' . $httpCode);
        }

        /** @var array<string, mixed>|null $data */
        $data = json_decode((string) $response, true);

        // ★ 네이버는 response 중첩 구조: { resultcode, message, response: { id, ... } }
        if (!is_array($data) || !isset($data['response']['id'])) {
            $errorMsg = is_array($data) ? ($data['message'] ?? '알 수 없는 오류') : '응답 파싱 실패';
            throw new \RuntimeException('네이버 사용자 ID 조회 실패: ' . $errorMsg);
        }

        return (string) $data['response']['id'];
    }

    /**
     * Firebase Custom Token 발급
     *
     * Kreait Firebase SDK를 사용하여 서비스 계정 JSON으로 Custom Token 발급.
     * UID 형식: naver:{네이버사용자ID}
     *
     * 이 메서드는 KakaoLoginService::createFirebaseCustomToken()과 동일한 로직이다.
     * UID 프리픽스만 'kakao:' → 'naver:'로 변경.
     *
     * @param string $naverUserId 네이버 사용자 ID
     * @return string Firebase Custom Token (JWT)
     * @throws \RuntimeException Custom Token 발급 실패 시
     */
    public static function createFirebaseCustomToken(string $naverUserId): string
    {
        try {
            $factory = (new Factory)
                ->withServiceAccount(ROOT_DIR . '/etc/philgo-firebase-service-account.json');
            $auth = $factory->createAuth();
            $customToken = $auth->createCustomToken('naver:' . $naverUserId);
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
| `NaverLoginService`를 별도 클래스로 분리 | 네이버 OAuth 로직을 UserService에 섞지 않고 독립적으로 관리하기 위함 |
| `Kreait\Firebase\Factory` 직접 사용 | `FirebaseService`는 토큰 검증 전용이므로, Custom Token 발급은 별도로 Factory를 초기화한다 |
| `KakaoLoginService`와 동일한 패턴 | 코드 일관성 유지, 유지보수 용이 |

### 카카오 vs 네이버 NaverLoginService 차이점

| 항목 | KakaoLoginService | NaverLoginService |
|------|-------------------|-------------------|
| `exchangeCodeForToken()` 파라미터 | `code` 만 | `code` + `state` (네이버는 state도 전달) |
| `exchangeCodeForToken()` 에서 secret | 미사용 | `client_secret` **필수** |
| `getUserId()` 응답 파싱 | `$data['id']` (최상위) | `$data['response']['id']` (중첩 구조) |
| Firebase UID 프리픽스 | `kakao:` | `naver:` |
| 메서드명 | `getKakaoUserId()` | `getNaverUserId()` |

---

## 7. OAuth 시작 -- start.php

**소스 파일**: `v7/auth/naver/start.php`
**접속 URL**: `https://v7-local.philgo.com/auth/naver/start`

이 파일은 HTML을 출력하지 않고 리다이렉트만 수행한다.
카카오 `start.php`와 동일한 구조이다.

```php
<?php
/**
 * v7/auth/naver/start.php - 네이버 OAuth 인가 시작
 *
 * CSRF 방지용 state를 생성하여 세션에 저장한 후,
 * 네이버 OAuth 인가 페이지로 302 리다이렉트한다.
 *
 * 접속 URL: https://v7-local.philgo.com/auth/naver/start
 * 라우팅: /auth/naver/start → v7.php → layout.php → v7/auth/naver/start.php
 *
 * @see lib/user/NaverLoginService.php
 */

use Philgo\User\NaverLoginService;

// 세션 시작 (state 저장용)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// CSRF 방지용 state 생성 → 세션에 저장
$state = bin2hex(random_bytes(16));
$_SESSION['naver_state'] = $state;

// 네이버 OAuth 인가 페이지로 리다이렉트
$authorizeUrl = NaverLoginService::getAuthorizeUrl($state);
header('Location: ' . $authorizeUrl);
exit;
```

### 동작 설명

1. CSRF 방지용 `state` 값을 랜덤 생성하여 `$_SESSION['naver_state']`에 저장
2. `NaverLoginService::getAuthorizeUrl($state)`로 네이버 인가 URL 생성
3. `302` 리다이렉트로 네이버 로그인 페이지로 이동
4. `exit`으로 v7 레이아웃 렌더링을 건너뜀

### 생성되는 네이버 인가 URL 예시

```
https://nid.naver.com/oauth2.0/authorize
    ?response_type=code
    &client_id=bE3wy5X71Z8aDgGMyEU6
    &redirect_uri=https://v7-local.philgo.com/auth/naver/callback
    &state=a1b2c3d4e5f6...
```

---

## 8. OAuth 콜백 -- callback.php

**소스 파일**: `v7/auth/naver/callback.php`
**접속 URL**: `https://v7-local.philgo.com/auth/naver/callback?code=XXX&state=YYY`

네이버 서버에서 자동 리다이렉트되는 페이지이다. HTML을 출력하지 않는다.

```php
<?php
/**
 * v7/auth/naver/callback.php - 네이버 OAuth 콜백 처리
 *
 * 네이버 로그인 완료 후 리다이렉트되는 페이지.
 * 인가 코드를 access_token으로 교환하고, 네이버 사용자 ID를 조회하여
 * Firebase Custom Token을 발급한다.
 *
 * ★ 카카오와의 차이점:
 *   - 토큰 교환 시 client_secret 필수
 *   - 토큰 교환 시 state도 함께 전달
 *   - 에러 응답 형식이 다름 (error, error_description 쿼리 파라미터)
 *
 * 접속 URL: https://v7-local.philgo.com/auth/naver/callback?code=XXX&state=YYY
 *
 * @see lib/user/NaverLoginService.php
 * @see v7/auth/naver/complete.php (리다이렉트 대상)
 */

use Philgo\User\NaverLoginService;

// 세션 시작 (state 검증 및 Custom Token 저장용)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

try {
    // 네이버에서 에러 응답이 온 경우 (사용자가 로그인 거부 등)
    if (!empty($_GET['error'])) {
        $errorDesc = $_GET['error_description'] ?? $_GET['error'];
        throw new \RuntimeException('네이버 로그인 거부: ' . $errorDesc);
    }

    // state 검증 (CSRF 방지)
    $sessionState = $_SESSION['naver_state'] ?? '';
    $requestState = $_GET['state'] ?? '';
    if (empty($sessionState) || !hash_equals($sessionState, $requestState)) {
        throw new \RuntimeException('잘못된 요청입니다 (state 불일치)');
    }
    unset($_SESSION['naver_state']);

    // 인가 코드 확인
    $code = $_GET['code'] ?? '';
    if (empty($code)) {
        throw new \RuntimeException('인가 코드가 없습니다');
    }

    // Step 1: code → access_token 교환 (★ state도 함께 전달)
    $accessToken = NaverLoginService::exchangeCodeForToken($code, $requestState);

    // Step 2: 네이버 사용자 ID 조회
    $naverUserId = NaverLoginService::getNaverUserId($accessToken);

    // Step 3: Firebase Custom Token 발급
    $customToken = NaverLoginService::createFirebaseCustomToken($naverUserId);

    // 세션에 Custom Token 저장 (complete 페이지에서 1회용으로 사용)
    $_SESSION['naver_custom_token'] = $customToken;

    // complete 페이지로 리다이렉트
    header('Location: /auth/naver/complete');
    exit;

} catch (\RuntimeException $e) {
    // 에러 시 로그인 페이지로 리다이렉트 (에러 메시지를 세션에 저장)
    $_SESSION['naver_login_error'] = $e->getMessage();
    header('Location: /user/login');
    exit;
}
```

### 동작 설명

1. `state` 파라미터를 세션에 저장된 값과 `hash_equals()`로 비교 (CSRF 방지)
2. 인가 코드(`code`)와 `state`를 네이버 API로 전송하여 `access_token`으로 교환
3. `access_token`으로 네이버 사용자 ID 조회 (`response.id` 중첩 구조)
4. 네이버 사용자 ID로 Firebase Custom Token 발급 (`naver:{id}`)
5. Custom Token을 세션에 저장하고 `/auth/naver/complete`로 리다이렉트
6. 에러 발생 시 에러 메시지를 세션에 저장하고 `/user/login`으로 리다이렉트

### 카카오 callback.php와의 차이점

| 항목 | 카카오 | 네이버 |
|------|--------|--------|
| 세션 키 (state) | `$_SESSION['kakao_state']` | `$_SESSION['naver_state']` |
| 세션 키 (token) | `$_SESSION['kakao_custom_token']` | `$_SESSION['naver_custom_token']` |
| 세션 키 (에러) | `$_SESSION['kakao_login_error']` | `$_SESSION['naver_login_error']` |
| 토큰 교환 | `exchangeCodeForToken($code)` | `exchangeCodeForToken($code, $state)` |
| 사용자 ID 조회 | `getKakaoUserId($token)` | `getNaverUserId($token)` |
| complete 경로 | `/auth/kakao/complete` | `/auth/naver/complete` |

---

## 9. Firebase 로그인 완료 -- complete.php

**소스 파일**: `v7/auth/naver/complete.php`
**접속 URL**: `https://v7-local.philgo.com/auth/naver/complete`

이 파일은 v7 레이아웃 안에서 실행되며, JavaScript로 Firebase 로그인을 완료한다.
카카오 `complete.php`와 동일한 구조이며, 세션 키와 로딩 UI 색상만 다르다.

```php
<?php
/**
 * v7/auth/naver/complete.php - 네이버 로그인 완료 처리
 *
 * callback.php에서 발급받은 Firebase Custom Token으로
 * Firebase 로그인을 완료하고 v7 세션을 생성한다.
 *
 * 접속 URL: https://v7-local.philgo.com/auth/naver/complete
 *
 * @see lib/user/NaverLoginService.php
 * @see v7/user/login.php (Google/카카오 소셜 로그인 참조)
 */

// 세션 시작
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// 세션에서 Custom Token 꺼내기 (1회용 삭제)
$customToken = $_SESSION['naver_custom_token'] ?? '';
unset($_SESSION['naver_custom_token']);

// Custom Token이 없으면 로그인 페이지로 리다이렉트
if (empty($customToken)) {
    header('Location: /user/login');
    exit;
}

$pageTitle = '네이버 로그인 처리중...';
?>

<!-- Firebase SDK (Auth만 로드) -->
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-app-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-auth-compat.js"></script>

<div id="naver-complete-app" style="text-align: center; padding: 3rem;">
    <wa-spinner style="font-size: 3rem; --indicator-color: #03C75A;"></wa-spinner>
    <p style="margin-top: 1rem; color: var(--wa-color-text-quiet);">네이버 로그인 처리중...</p>
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
                if (typeof firebase === 'undefined') {
                    throw new Error('Firebase SDK가 로드되지 않았습니다');
                }
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
                    login_provider: 'naver'
                });

                // 홈으로 리다이렉트
                window.location.href = '/';
            } catch (err) {
                console.error('[Naver-Login] 완료 처리 실패:', err);
                this.error = err.message || '네이버 로그인 처리 중 오류가 발생했습니다.';
                setTimeout(() => { window.location.href = '/user/login'; }, 3000);
            }
        }
    }).mount('#naver-complete-app');
});
</script>
```

### 카카오 complete.php와의 차이점

| 항목 | 카카오 | 네이버 |
|------|--------|--------|
| 세션 키 | `naver_custom_token` → `kakao_custom_token` | `naver_custom_token` |
| 스피너 색상 | `#FEE500` (카카오 노란색) | `#03C75A` (네이버 초록색) |
| 로딩 텍스트 | 카카오 로그인 처리중... | 네이버 로그인 처리중... |
| Vue mount ID | `#kakao-complete-app` | `#naver-complete-app` |
| `login_provider` | `'kakaotalk'` | `'naver'` |
| 콘솔 로그 태그 | `[Kakao-Login]` | `[Naver-Login]` |

### 핵심: `login_provider: 'naver'`

`v7api('user.socialLogin')` 호출 시 `login_provider`를 `'naver'`로 전달한다.
이 값은 `sf_member` 테이블의 `login_provider` 컬럼에 저장되어 네이버 로그인 사용자를 식별한다.

---

## 10. 로그인 페이지 UI -- login.php

**소스 파일**: `v7/user/login.php`
**접속 URL**: `https://v7-local.philgo.com/user/login`

### 네이버 버튼 HTML

기존 카카오 버튼 아래에 네이버 버튼을 추가한다.

```html
<!-- 네이버 아이디 로그인 -->
<wa-button
    class="social-btn social-btn-naver"
    variant="neutral"
    appearance="accent"
    size="large"
    :loading="loading === 'naver' || null"
    :disabled="loading !== '' || null"
    @click="loginWithNaver"
>
    <i slot="start" class="fa-solid fa-n"></i>
    네이버 아이디 로그인
</wa-button>
```

### loginWithNaver() Vue 메서드

```javascript
loginWithNaver() {
    this.loading = 'naver';
    this.error = '';
    this.success = '';
    // 네이버 OAuth 인가 페이지로 리다이렉트 (서버 측 처리)
    window.location.href = '/auth/naver/start';
}
```

카카오/Google 로그인과 달리 클라이언트에서 Firebase SDK를 직접 호출하지 않는다.
`/auth/naver/start`로 페이지를 이동시키면 서버 측에서 전체 OAuth 흐름을 처리한다.

### 네이버 에러 메시지 처리

```php
// 네이버 로그인 실패 시 세션에 저장된 에러 메시지 읽기 (1회용)
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
$naverLoginError = $_SESSION['naver_login_error'] ?? '';
unset($_SESSION['naver_login_error']);
```

```javascript
data() {
    return {
        loading: '',
        error: <?= json_encode($naverLoginError) ?> || <?= json_encode($kakaoLoginError) ?> || '',
        success: '',
    };
}
```

> 카카오와 네이버 에러를 모두 처리하기 위해 `||` 체이닝으로 연결한다.
> 동시에 두 에러가 발생할 수 없으므로 이 방식이 안전하다.

---

## 11. CSS 스타일 -- login.css

**소스 파일**: `v7/user/login.css`

### 네이버 버튼 브랜드 색상

```css
/* 네이버 버튼 브랜드 색상 */
.social-btn-naver {
    --wa-color-neutral-on-loud: #FFFFFF;
    --wa-color-neutral-fill-loud: #03C75A;
    --wa-color-neutral-fill-loud-hover: #02B350;
    --wa-color-neutral-fill-loud-active: #029E46;
}
```

| CSS 변수 | 값 | 설명 |
|----------|-----|------|
| `--wa-color-neutral-on-loud` | `#FFFFFF` | 버튼 텍스트/아이콘 색상 (흰색) |
| `--wa-color-neutral-fill-loud` | `#03C75A` | 네이버 공식 브랜드 초록색 |
| `--wa-color-neutral-fill-loud-hover` | `#02B350` | hover 시 약간 어두운 초록색 |
| `--wa-color-neutral-fill-loud-active` | `#029E46` | active(클릭) 시 더 어두운 초록색 |

Web Awesome Pro의 `wa-button` 컴포넌트에서 `variant="neutral"` + `appearance="accent"`와 함께 사용한다.

### 카카오 vs 네이버 브랜드 색상 비교

| 항목 | 카카오 | 네이버 |
|------|--------|--------|
| 기본 배경 | `#FEE500` (노란색) | `#03C75A` (초록색) |
| 텍스트 색상 | `#191919` (검정) | `#FFFFFF` (흰색) |
| hover | `#F0D800` | `#02B350` |
| active | `#E0CA00` | `#029E46` |

---

## 12. Config 설정 메서드

**소스 파일**: `v7/utils/Config.php`

네이버 키는 별도 config 파일 대신 `V7\Utils\Config` 클래스에 통합한다.
카카오 키 메서드와 동일한 패턴을 따른다.

```php
// ===================================================================
// 네이버 로그인 설정
// ===================================================================

/** 네이버 클라이언트 ID (OAuth 인가 요청 + 토큰 교환 시 사용) */
public static function naverClientId(): string
{
    return 'bE3wy5X71Z8aDgGMyEU6';
}

/** 네이버 클라이언트 시크릿 (토큰 교환 시 필수 — 서버 전용) */
public static function naverClientSecret(): string
{
    return 'oLxNCMKImw';
}

/**
 * 네이버 OAuth Redirect URI 동적 생성
 * 현재 서버의 scheme + host 기반으로 자동 결정.
 * 네이버 디벨로퍼스 콘솔에 등록한 Callback URL과 100% 일치해야 한다.
 */
public static function naverRedirectUri(): string
{
    $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'] ?? 'v7-local.philgo.com';
    return $scheme . '://' . $host . '/auth/naver/callback';
}
```

### naverRedirectUri() 동적 생성 이유

Redirect URI를 하드코딩하지 않고 현재 서버의 `scheme + host`에서 동적으로 생성한다.
이렇게 하면 로컬 개발(`v7-local.philgo.com`)과 프로덕션(`philgo.net`)에서 별도 설정 없이 동작한다.
단, 네이버 디벨로퍼스 콘솔에 각 환경의 Callback URL을 모두 등록해야 한다.

---

## 13. 네이버 로그인 API 상세 (공식 문서 기반)

> **공식 문서**: https://developers.naver.com/docs/login/api/api.md

### 13.1 OAuth 2.0 엔드포인트

| 엔드포인트 | URL | 설명 |
|-----------|-----|------|
| **Authorization** | `https://nid.naver.com/oauth2.0/authorize` | 사용자 인가 요청 (로그인 페이지) |
| **Token** | `https://nid.naver.com/oauth2.0/token` | 인가 코드 → 액세스 토큰 교환 |
| **Profile** | `https://openapi.naver.com/v1/nid/me` | 사용자 프로필 정보 조회 |

### 13.2 인가 코드 요청 (Authorization)

**URL**: `GET https://nid.naver.com/oauth2.0/authorize`

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `response_type` | string | ✅ | `code` 고정 |
| `client_id` | string | ✅ | 네이버 클라이언트 ID |
| `redirect_uri` | string | ✅ | 콜솔에 등록한 Callback URL |
| `state` | string | ✅ | CSRF 방지용 상태 값 (임의 문자열) |

**요청 예시:**
```
https://nid.naver.com/oauth2.0/authorize
    ?response_type=code
    &client_id=bE3wy5X71Z8aDgGMyEU6
    &redirect_uri=https://v7-local.philgo.com/auth/naver/callback
    &state=abc123def456
```

**성공 응답** (콜백으로 리다이렉트):
```
https://v7-local.philgo.com/auth/naver/callback
    ?code=AUTHORIZATION_CODE
    &state=abc123def456
```

**에러 응답** (사용자가 로그인 거부 시):
```
https://v7-local.philgo.com/auth/naver/callback
    ?error=access_denied
    &error_description=사용자가+로그인을+거부했습니다
    &state=abc123def456
```

### 13.3 액세스 토큰 발급 (Token)

**URL**: `POST https://nid.naver.com/oauth2.0/token`

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `grant_type` | string | ✅ | `authorization_code` 고정 |
| `client_id` | string | ✅ | 네이버 클라이언트 ID |
| `client_secret` | string | ✅ | 네이버 클라이언트 시크릿 (**카카오와 달리 필수**) |
| `code` | string | ✅ | 인가 코드 |
| `state` | string | ✅ | state 값 |

**성공 응답:**
```json
{
    "access_token": "AAAAOLtP40eH_GIRM...",
    "refresh_token": "c8ceMEJisO4Se7uGCE...",
    "token_type": "bearer",
    "expires_in": "3600"
}
```

**에러 응답:**
```json
{
    "error": "invalid_request",
    "error_description": "no valid data in session"
}
```

### 13.4 프로필 조회 (Profile)

**URL**: `GET https://openapi.naver.com/v1/nid/me`

**헤더:**
```
Authorization: Bearer {access_token}
```

**성공 응답:**
```json
{
    "resultcode": "00",
    "message": "success",
    "response": {
        "id": "87654321",
        "email": "user@naver.com",
        "name": "홍길동",
        "nickname": "길동이",
        "gender": "M",
        "age": "30-39",
        "birthday": "01-01",
        "birthyear": "1990",
        "mobile": "010-1234-5678",
        "profile_image": "https://phinf.pstatic.net/.../image.jpg"
    }
}
```

> **★ 중요**: 카카오와 달리 네이버는 `response` 객체 안에 사용자 정보가 중첩되어 있다.
> `$data['id']`가 아니라 `$data['response']['id']`로 접근해야 한다.

### 13.5 프로필 응답 필드 상세

| 필드 | 타입 | 동의항목 | 설명 |
|------|------|---------|------|
| `id` | string | 기본 (항상 제공) | 네이버 고유 사용자 ID (숫자 또는 영문 혼합) |
| `email` | string | 선택 | 네이버 이메일 주소 |
| `name` | string | 선택 | 사용자 실명 |
| `nickname` | string | 선택 | 네이버 닉네임 |
| `gender` | string | 선택 | `F`(여성), `M`(남성), `U`(미설정) |
| `age` | string | 선택 | 나이대 (예: `"30-39"`) |
| `birthday` | string | 선택 | 생일 `MM-DD` (예: `"01-01"`) |
| `birthyear` | string | 선택 | 출생연도 `YYYY` (예: `"1990"`) |
| `mobile` | string | 선택 | 휴대전화번호 (예: `"010-1234-5678"`) |
| `profile_image` | string | 선택 | 프로필 이미지 URL |

> 현재 구현에서는 `id` 필드만 사용하여 Firebase Custom Token을 생성한다.

### 13.6 에러 코드

| 에러 코드 | HTTP 상태 | 설명 |
|----------|-----------|------|
| `invalid_request` | 400 | 잘못된 요청 파라미터 |
| `unauthorized_client` | 401 | 인증되지 않은 클라이언트 |
| `access_denied` | 403 | 사용자가 로그인 거부 |
| `unsupported_response_type` | 400 | 지원하지 않는 response_type |
| `server_error` | 500 | 네이버 서버 오류 |

### 13.7 PHP cURL 호출 패턴

네이버 API 호출에 사용하는 cURL 패턴은 카카오와 동일하다.

**토큰 교환 (POST):**
```php
$ch = curl_init('https://nid.naver.com/oauth2.0/token');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST => true,
    CURLOPT_POSTFIELDS => http_build_query([
        'grant_type' => 'authorization_code',
        'client_id' => Config::naverClientId(),
        'client_secret' => Config::naverClientSecret(),  // ★ 네이버는 필수
        'code' => $code,
        'state' => $state,                                // ★ 네이버는 state도 전달
    ]),
    CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
    CURLOPT_TIMEOUT => 10,
]);
$response = curl_exec($ch);
// ...
```

**프로필 조회 (GET):**
```php
$ch = curl_init('https://openapi.naver.com/v1/nid/me');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => [
        'Authorization: Bearer ' . $accessToken,
    ],
    CURLOPT_TIMEOUT => 10,
]);
$response = curl_exec($ch);
// ...

$data = json_decode($response, true);
$userId = $data['response']['id'];  // ★ response 중첩 구조
```

---

## 14. 카카오톡 로그인과의 비교

| 구분 | 카카오톡 로그인 | 네이버 로그인 |
|------|--------------|-------------|
| 인가 URL | `kauth.kakao.com/oauth/authorize` | `nid.naver.com/oauth2.0/authorize` |
| 토큰 URL | `kauth.kakao.com/oauth/token` | `nid.naver.com/oauth2.0/token` |
| 프로필 URL | `kapi.kakao.com/v2/user/me` | `openapi.naver.com/v1/nid/me` |
| Client Secret | 선택 | **필수** |
| 토큰 교환 시 state | 불필요 | **필요** |
| 프로필 응답 구조 | `{ id: "..." }` (최상위) | `{ response: { id: "..." } }` (중첩) |
| Firebase UID | `kakao:{id}` | `naver:{id}` |
| `login_provider` | `'kakaotalk'` | `'naver'` |
| 브랜드 색상 | `#FEE500` (노란색) | `#03C75A` (초록색) |
| 버튼 텍스트 색상 | `#191919` (검정) | `#FFFFFF` (흰색) |
| 서비스 클래스 | `KakaoLoginService` | `NaverLoginService` |

### 공통점

| 항목 | 설명 |
|------|------|
| OAuth 방식 | 둘 다 Authorization Code Grant 방식 |
| Custom Token 방식 | 둘 다 Firebase Custom Token 방식 (동일 아키텍처) |
| 최종 API 호출 | 둘 다 `v7api('user.socialLogin', { id_token, login_provider })` 호출 |
| 서버 처리 | 둘 다 `UserService::socialLogin()` → `AuthService::loginUser()` |
| 세션 생성 | 둘 다 동일한 세션 쿠키 생성 메커니즘 사용 |
| 사용자 생성 | 둘 다 Firebase UID로 sf_member 검색 → 없으면 자동 생성 |
| CSRF 방지 | 둘 다 `state` 파라미터 + `hash_equals()` 검증 |
| 파일 구조 | `v7/auth/{provider}/start.php`, `callback.php`, `complete.php` 동일 패턴 |

---

## 15. Google 로그인과의 비교

| 구분 | Google 로그인 | 네이버 로그인 |
|------|-------------|-------------|
| Firebase 지원 | 직접 지원 (`signInWithPopup`) | 직접 지원 안 함 → Custom Token 필요 |
| 인증 흐름 | 팝업 1단계 (클라이언트 완결) | 리다이렉트 5단계 (서버 경유) |
| 서버 역할 | 없음 | 필수 (code→token→userId→customToken) |
| UI 패턴 | 팝업 → 즉시 결과 | 페이지 이동 → 네이버 → 콜백 → 완료 |
| 로딩 표시 | 팝업 대기 중 로딩 | 로딩 페이지(complete.php) |
| `login_provider` | `'google'` | `'naver'` |
| Firebase UID 형식 | Google 자동 생성 | `naver:{네이버ID}` (커스텀) |
| 에러 처리 | 팝업 닫기 → 즉시 복귀 | 세션 에러 → 로그인 페이지 리다이렉트 |

---

## 16. 보안 설계

### 16.1 CSRF 방지 (state 파라미터)

| 단계 | 동작 |
|------|------|
| start.php | `$state = bin2hex(random_bytes(16))` 생성 → `$_SESSION['naver_state']` 저장 |
| callback.php | `hash_equals($_SESSION['naver_state'], $_GET['state'])` 비교 |
| 검증 후 | `unset($_SESSION['naver_state'])` (1회용 삭제) |

### 16.2 토큰 보안

| 토큰 | 노출 범위 | 설명 |
|------|----------|------|
| 네이버 Client ID | 인가 URL에 포함 (공개) | 클라이언트 식별용 — 노출되어도 무방 |
| 네이버 Client Secret | 서버 전용 | `Config::naverClientSecret()` — PHP 소스코드에서만 사용, 절대 프론트에 노출 금지 |
| 네이버 access_token | 서버 전용 | callback.php에서만 사용, 프론트에 전달하지 않음 |
| Firebase Custom Token | 세션 → 프론트 (1회용) | complete.php에서 세션에서 꺼낸 후 즉시 삭제 |
| Firebase ID Token | 프론트 → 서버 | 기존 socialLogin 흐름과 동일 |

### 16.3 세션 기반 토큰 전달

Custom Token을 URL 파라미터가 아닌 PHP 세션으로 전달한다.
이렇게 하면 URL에 토큰이 노출되지 않고, 1회용으로 사용 후 즉시 삭제된다.

### 16.4 Client Secret 보호

> **⚠️ Client Secret은 절대로 프론트엔드(JavaScript, HTML)에 노출해서는 안 된다.**

카카오와 달리 네이버는 `client_secret`이 토큰 교환 시 **필수**이므로,
이 값은 반드시 서버 측(PHP)에서만 사용해야 한다.
`Config::naverClientSecret()`은 PHP 코드에서만 호출되며, JavaScript에 전달하지 않는다.

---

## 17. 트러블슈팅

### 17.1 "state 불일치" 에러

| 원인 | 해결 |
|------|------|
| 세션 쿠키 미설정 | PHP 세션이 제대로 시작되는지 확인. `session_start()` 호출 확인 |
| 다른 탭에서 로그인 시도 | 세션에 저장된 state가 덮어씌워짐. 동시에 여러 탭에서 로그인하면 안 됨 |
| 너무 오래 걸린 경우 | PHP 세션 GC로 세션이 삭제됨. 재시도 |

### 17.2 "네이버 토큰 교환 실패" 에러

| 원인 | 해결 |
|------|------|
| Callback URL 불일치 | 네이버 콘솔에 등록된 URL과 `Config::naverRedirectUri()` 결과가 100% 일치하는지 확인 |
| Client Secret 오류 | `Config::naverClientSecret()` 값이 올바른지 확인 |
| 인가 코드 만료 | 인가 코드는 유효시간이 짧음. 콜백이 즉시 처리되는지 확인 |
| Client ID 오류 | `Config::naverClientId()` 값이 올바른지 확인 |

### 17.3 "Firebase Custom Token 발급 실패" 에러

| 원인 | 해결 |
|------|------|
| 서비스 계정 파일 없음 | `etc/philgo-firebase-service-account.json` 파일 존재 확인 |
| 서비스 계정 권한 부족 | Firebase 콘솔에서 서비스 계정에 "Firebase Admin SDK" 권한 확인 |
| Kreait SDK 미설치 | `composer require kreait/firebase-php` 확인 |

### 17.4 complete.php에서 "Firebase SDK가 로드되지 않았습니다" 에러

| 원인 | 해결 |
|------|------|
| CDN 로딩 실패 | `<script defer>` 태그가 정상적으로 로딩되는지 네트워크 탭 확인 |
| defer 로딩 순서 | `DOMContentLoaded` 이벤트 리스너 안에서 실행되므로 SDK 로딩 완료 후 실행됨 |

### 17.5 "네이버 사용자 ID 조회 실패" 에러

| 원인 | 해결 |
|------|------|
| access_token 만료 | access_token의 유효시간은 3600초(1시간). 콜백 즉시 처리 확인 |
| 응답 구조 불일치 | 네이버는 `response.id` 중첩 구조. `$data['response']['id']` 확인 |
| API 호출 실패 | `https://openapi.naver.com/v1/nid/me` 네트워크 접근 확인 |

---

## 18. 로그아웃

네이버 로그인도 Firebase Auth 기반이므로 로그아웃은 기존과 동일하다.

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

## 19. 관련 파일 목록

| 파일 | 용도 | 주요 함수/메서드 |
|------|------|--------------------|
| `lib/user/NaverLoginService.php` | 네이버 OAuth + Firebase Custom Token 서비스 | `getAuthorizeUrl()`, `exchangeCodeForToken()`, `getNaverUserId()`, `createFirebaseCustomToken()` |
| `v7/auth/naver/start.php` | 네이버 OAuth 인가 시작 | state 생성, 네이버 리다이렉트 |
| `v7/auth/naver/callback.php` | 콜백: code→token→userId→customToken | state 검증, 토큰 교환, Custom Token 발급 |
| `v7/auth/naver/complete.php` | Firebase 로그인 완료 | `signInWithCustomToken()`, `v7api('user.socialLogin')` |
| `v7/user/login.php` | 로그인 페이지 (네이버 버튼 + Vue.js) | `loginWithNaver()`, `loginWithKakao()`, `loginWithGoogle()` |
| `v7/user/login.css` | 로그인 페이지 CSS | `.social-btn-naver` (네이버 브랜드 색상) |
| `v7/utils/Config.php` | 네이버 키 설정 | `naverClientId()`, `naverClientSecret()`, `naverRedirectUri()` |
| `lib/user/UserService.php` | 소셜 로그인 공통 처리 | `socialLogin()` (네이버/카카오/Google 공통) |
| `lib/utils/AuthService.php` | 인증 서비스 | `getLoginUser()`, `loginUser()` |
| `lib/utils/FirebaseService.php` | Firebase 토큰 검증 | `verifyIdTokenWithClaims()` |
| `etc/philgo-firebase-service-account.json` | Firebase 서비스 계정 | Custom Token 발급에 사용 |

### 참고 문서

| 문서 | 설명 |
|------|------|
| [v7-web-kakoatalk-social-login.md](v7-web-kakoatalk-social-login.md) | 카카오톡 소셜 로그인 (동일 아키텍처) |
| [v7-web-login.md](v7-web-login.md) | v7 웹 로그인 통합 문서 |
| https://developers.naver.com/docs/login/api/api.md | 네이버 로그인 API 공식 문서 |
| https://developers.naver.com/docs/login/profile/profile.md | 네이버 프로필 조회 API 공식 문서 |
