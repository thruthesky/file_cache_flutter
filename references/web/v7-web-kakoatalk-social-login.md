# 카카오톡 소셜 로그인 (웹)

카카오톡 소셜 로그인의 웹 리다이렉트(Authorization Code) 방식 구현 가이드입니다.

---

## 목차

1. [핵심 원리: 카카오 → Firebase Custom Token 방식](#1-핵심-원리-카카오--firebase-custom-token-방식)
2. [카카오톡 앱 (프로젝트) 정보](#2-카카오톡-앱-프로젝트-정보)
3. [카카오 디벨로퍼스 콘솔 설정 체크리스트](#3-카카오-디벨로퍼스-콘솔-설정-체크리스트)
4. [전체 동작 흐름 (웹 리다이렉트)](#4-전체-동작-흐름-웹-리다이렉트)
5. [센터 프로젝트 파일 구조](#5-센터-프로젝트-파일-구조)
6. [PHP 백엔드 구현](#6-php-백엔드-구현)
7. [JavaScript 프론트엔드 구현](#7-javascript-프론트엔드-구현)
8. [Firebase Custom Token 발급 상세](#8-firebase-custom-token-발급-상세)
9. [가맹사별 앱 설정 페이지](#9-가맹사별-앱-설정-페이지)
10. [실전 트러블슈팅 (자주 터지는 포인트)](#10-실전-트러블슈팅-자주-터지는-포인트)
11. [로그아웃 / 연결끊기 (탈퇴)](#11-로그아웃--연결끊기-탈퇴)
12. [Flutter 앱용 카카오 로그인 API](#12-flutter-앱용-카카오-로그인-api)
13. [관련 파일 목록](#13-관련-파일-목록)

---

## 1. 핵심 원리: 카카오 → Firebase Custom Token 방식

### 1.1 최종 목표

**카카오톡에서 로그인만 하고** → **Firebase Auth에 Custom Token으로 로그인**하는 것이 최종 목표입니다.

- 카카오톡에서 별도 회원 정보를 가져올 필요 **없음** (카카오 고유 사용자 ID만 필요)
- Firebase Custom Token을 서버(PHP)에서 발급하여 클라이언트에서 Firebase Auth 로그인 수행
- 이후 흐름은 Google 로그인과 동일: `syncDatabaseUser()` → `analyzeUserType()` → 리다이렉트

### 1.2 Google 로그인과의 차이

| 구분 | Google 로그인 | 카카오톡 로그인 |
|------|-------------|--------------|
| **Firebase 지원** | 직접 지원 (`signInWithPopup`) | 직접 지원 안 함 → Custom Token 필요 |
| **인증 흐름** | 팝업 1단계 | 리다이렉트 2단계 (카카오 → 콜백 → Custom Token → Firebase) |
| **서버 역할** | 없음 (클라이언트에서 직접 처리) | **필수** (code→token 교환 + Custom Token 발급) |
| **토큰 교환** | Firebase SDK가 자동 처리 | PHP 서버에서 카카오 API 호출 |
| **client_secret** | 불필요 | 서버에서만 사용 (프론트 노출 금지) |

### 1.3 다중 가맹사 로그인 동작

**동일한 카카오톡 계정으로 여러 가맹사에 로그인해도 동일한 사용자로 로그인됩니다.**

| 항목 | 동작 |
|------|------|
| **Firebase UID** | 카카오 사용자 ID 기반 (`kakao:454835416`) → **모든 가맹사에서 동일** |
| **가맹사 구분** | `syncDatabaseUser()` (my API)에서 `domain` 파라미터로 처리 |
| **PostgreSQL 사용자** | `branch_id`가 다르더라도 Firebase UID 기준으로 동일 사용자 |

이는 Google 로그인과 동일한 동작입니다. Firebase UID는 카카오 고유 사용자 ID에서 파생되므로 (`kakao:{카카오사용자ID}`), 어느 가맹사에서 로그인하든 같은 Firebase 사용자가 됩니다. 가맹사별 사용자 데이터 분리는 센터 프로젝트의 `my` API에서 `domain` 파라미터를 통해 자동으로 처리됩니다.

### 1.4 보안 원칙

- **client_secret/토큰 교환은 반드시 PHP 서버에서 수행** (프론트에서 절대 하지 않음)
- **state 파라미터로 CSRF 방지** (세션에 저장 후 콜백에서 검증)
- **카카오 access_token은 프론트에 전달하지 않음** (서버에서만 사용)
- **Firebase Custom Token만 프론트에 전달** (1시간 유효, 1회용)

---

## 2. 카카오톡 앱 (프로젝트) 정보

| 항목 | 값 |
|------|-----|
| 앱 URL | `https://developers.kakao.com/console/app/136610` |
| 앱 이름 | `SONUB` |
| 특징 | 비즈앱 |
| REST API 키 | **본사 도메인**: `key.config.php`의 `KAKAOTALK_LOGIN_REST_API_KEY` 상수 사용 / **가맹사 도메인**: `branch_meta` 테이블에서 동적 로드 (키: `kakao_rest_api_key`) |
| JavaScript 키 | `branch_meta` 테이블에서 동적 로드 (키: `kakao_javascript_key`) |
| 네이티브 앱 키 | `branch_meta` 테이블에서 동적 로드 (키: `kakao_native_key`) |

> **🔥 REST API 키 로드 우선순위:**
> 1. **본사 도메인** (sonub.com, localhost, 127.0.0.1) → `etc/config/key.config.php`의 `KAKAOTALK_LOGIN_REST_API_KEY` 상수 사용
> 2. **가맹사 도메인** → `branch_meta` 테이블에서 동적 로드 (운영자가 `/admin/app-settings`에서 설정)
>
> `KakaoConfig` 클래스가 `isHeadOfficeDomain()`으로 도메인을 확인한 후 적절한 키를 로드합니다.

---

## 3. 카카오 디벨로퍼스 콘솔 설정 체크리스트

### 3.1 필수 설정

| 순서 | 설정 항목 | 위치 | 설명 |
|------|----------|------|------|
| 1 | **카카오 로그인 활성화** | 앱 설정 → 카카오 로그인 | ON으로 설정 |
| 2 | **Redirect URI 등록** | 앱 → 일반 → 플랫폼 키 → REST API → 수정 → 카카오 로그인 리다이렉트 URI | 카카오가 인가코드를 돌려보내는 URL. **등록된 URI로만** 인가코드 전달 |
| 3 | **웹 플랫폼 등록** | 앱 설정 → 플랫폼 → Web | 사이트 도메인 등록 |

> **⚠️ 2025년 12월 3일 개편:** 카카오 디벨로퍼스 콘솔 UI가 개편되어, Redirect URI 등록 위치가 변경되었습니다.
> - **개편 전:** 앱 설정 → 카카오 로그인 → Redirect URI (모든 앱 키에 일괄 적용)
> - **개편 후:** **앱 → 일반 → 플랫폼 키 → REST API → 수정 → 카카오 로그인 리다이렉트 URI** (앱 키별 개별 설정)
>
> 기존 설정은 자동 마이그레이션되어 별도 조치 없이 동작하지만, 수정 시 새 위치에서 해야 합니다.

### 3.2 Redirect URI 등록 방법

**카카오 디벨로퍼스 콘솔** (https://developers.kakao.com) 에서:

1. **내 애플리케이션** → 해당 앱 선택
2. **앱** → **일반** → **플랫폼 키** 섹션
3. **REST API** 키의 **수정** 버튼 클릭
4. **카카오 로그인 리다이렉트 URI** 항목에 콜백 URL 등록

### 3.3 Redirect URI 등록 예시

```
# 본사 (프로덕션)
https://sonub.com/auth/kakao/callback.php

# 가맹사 (프로덕션)
https://banana.sonub.com/auth/kakao/callback.php

# 로컬 개발
http://127.0.0.1:8080/auth/kakao/callback.php
http://localhost:3000/auth/kakao/callback.php
```

> **🚨 중요:** `http` ↔ `https`, 포트 번호, path, trailing slash까지 **100% 일치**해야 합니다. 하나라도 다르면 `KOE006 (redirect_uri mismatch)` 에러가 발생합니다.

### 3.4 선택/권장 설정

| 설정 항목 | 설명 |
|----------|------|
| **Client Secret 사용** | 보안 강화를 위해 token 요청 시 client_secret을 요구하게 설정 가능 |
| **동의항목** | 카카오에서 회원 정보를 가져올 필요가 없으므로 기본 동의항목만으로 충분 |

---

## 4. 전체 동작 흐름 (웹 리다이렉트)

### 4.1 흐름 다이어그램

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    카카오톡 소셜 로그인 전체 흐름                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

[1] /user/login 페이지에서 "카카오 로그인" 버튼 클릭
        │
        ▼
[2] loginWithKakao() 호출 (js/social-auth.js)
        │
        ├── 로딩 스피너 표시
        └── window.location.href = '/auth/kakao/start.php'
                │
                ▼
[3] /auth/kakao/start.php (PHP 서버)
        │
        ├── bootstrap.php 로드 → branch_meta에서 REST API 키 동적 로드
        ├── state 난수 생성 → $_SESSION에 저장
        └── 302 리다이렉트 → https://kauth.kakao.com/oauth/authorize?
                                 response_type=code&
                                 client_id=REST_API_KEY&
                                 redirect_uri=콜백URL&
                                 state=난수
                │
                ▼
[4] 카카오 로그인 페이지 (사용자가 카카오 계정으로 로그인)
        │
        └── 인증 성공 → 302 리다이렉트 → 콜백URL?code=인가코드&state=난수
                │
                ▼
[5] /auth/kakao/callback.php (PHP 서버) ★ 핵심 ★
        │
        ├── (a) state 검증 (CSRF 방지)
        │
        ├── (b) code → access_token 교환
        │       POST https://kauth.kakao.com/oauth/token
        │
        ├── (c) 카카오 사용자 ID 확보
        │       GET https://kapi.kakao.com/v2/user/me
        │       → 카카오 고유 사용자 ID만 사용 (회원 정보 불필요)
        │
        ├── (d) Firebase Custom Token 발급
        │       firebase_auth_admin()->createCustomToken('kakao:' . $kakaoId)
        │
        └── (e) Custom Token을 세션에 저장하여 complete.php로 리다이렉트
                $_SESSION['kakao_custom_token'] = $customTokenString
                │
                ▼
[6] /auth/kakao/complete.php (브라우저에서 실행)
        │
        ├── 세션에서 Custom Token 꺼내기 (1회용, 즉시 삭제)
        │
        ├── firebase.auth().signInWithCustomToken(customToken)
        │   └── Firebase Auth에 로그인 완료 → firebaseUser 반환
        │
        ├── my API 호출 (func: 'my') → PostgreSQL 사용자 생성/업데이트
        │   └── provider='kakao', social_id=카카오사용자ID 전달
        │
        ├── 사용자 유형에 따라 분기
        │   ├── is_root=true       → /root/dashboard
        │   ├── is_branch_admin    → /admin/dashboard 또는 /admin/my-sites
        │   └── 일반 사용자         → /
        │
        └── window.location.href = redirectTo
```

### 4.2 단계별 요약

| 단계 | 위치 | 동작 | 카카오 API |
|------|------|------|-----------|
| **Step A** | 브라우저 → 카카오 | 로그인 시작 (authorize 리다이렉트) | `kauth.kakao.com/oauth/authorize` |
| **Step B** | 카카오 → PHP 서버 | 콜백에서 code 수신 | - |
| **Step C** | PHP 서버 → 카카오 | code → access_token 교환 | `kauth.kakao.com/oauth/token` |
| **Step D** | PHP 서버 → 카카오 | 사용자 ID 확보 | `kapi.kakao.com/v2/user/me` |
| **Step E** | PHP 서버 | Firebase Custom Token 발급 | - (Firebase Admin SDK) |
| **Step F** | 브라우저 | Custom Token → Firebase 로그인 → DB 동기화 | - |

---

## 5. 센터 프로젝트 파일 구조

```
/auth/kakao/
    ├── start.php          # state 생성 + 카카오 authorize 리다이렉트
    ├── callback.php        # code→token 교환 + 카카오 사용자 ID + Custom Token 발급
    └── complete.php        # Custom Token → Firebase 로그인 + my API + 리다이렉트

/js/
    └── social-auth.js      # loginWithKakao() 함수 (start.php로 리다이렉트)

/widgets/user/
    └── social-login.php    # 카카오 로그인 버튼 UI

/etc/config/
    ├── key.config.php      # KAKAOTALK_LOGIN_REST_API_KEY 상수 (본사 도메인 전용)
    └── kakao.config.php    # KakaoConfig 클래스 (본사: 상수, 가맹사: branch_meta에서 동적 로드)

/pages/admin/
    └── app-settings.php    # 가맹사 운영자용 앱 설정 페이지 (카카오/네이버 키 관리)
```

> **참고:** 센터 프로젝트는 Front Controller 패턴(`pages/` 폴더)을 사용하지만, `/auth/kakao/` 경로는 OAuth 콜백 전용이므로 별도 PHP 파일로 구성합니다.

---

## 6. PHP 백엔드 구현

### 6.1 카카오 설정 파일: `etc/config/kakao.config.php`

```php
<?php
/**
 * 카카오 OAuth 설정
 *
 * REST API 키 로드 우선순위:
 *   1. 본사 도메인(sonub.com, localhost, 127.0.0.1) → key.config.php의 KAKAOTALK_LOGIN_REST_API_KEY 상수 사용
 *   2. 가맹사 도메인 → branch_meta 테이블에서 동적 로드 (앱 설정 페이지에서 설정)
 *
 * Client Secret: 보안 강화용 (콘솔에서 활성화한 경우에만 사용)
 *
 * 주의: 이 파일 로드 전에 반드시 bootstrap.php가 로드되어야 합니다.
 *       (BranchRepository, BranchMetaRepository 사용을 위해)
 *
 * 파일: etc/config/kakao.config.php
 */
class KakaoConfig
{
    /** 카카오 REST API 키 (본사: 상수, 가맹사: branch_meta에서 동적 로드) */
    public string $rest_api_key = '';

    /** Client Secret (콘솔에서 사용 설정한 경우) */
    public string $client_secret = '';

    /** Redirect URI (카카오 콘솔에 등록한 것과 100% 일치해야 함) */
    public string $redirect_uri = '';

    /** 본사 도메인 목록 */
    private const HEAD_OFFICE_DOMAINS = ['sonub.com', 'localhost', '127.0.0.1'];

    public function __construct()
    {
        // 환경에 따라 Redirect URI 자동 결정
        $scheme = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'] ?? 'sonub.com';
        $this->redirect_uri = $scheme . '://' . $host . '/auth/kakao/callback.php';

        // 카카오 REST API 키 로드 (본사 도메인 우선, 가맹사는 branch_meta)
        $this->loadRestApiKey();
    }

    /**
     * 카카오 REST API 키를 로드합니다.
     *
     * 본사 도메인(sonub.com, localhost, 127.0.0.1)인 경우:
     *   → key.config.php의 KAKAOTALK_LOGIN_REST_API_KEY 상수 사용
     *
     * 가맹사 도메인인 경우:
     *   → branch_meta 테이블에서 'kakao_rest_api_key' 값을 동적 로드
     */
    private function loadRestApiKey(): void
    {
        // 본사 도메인인 경우 상수 사용
        if ($this->isHeadOfficeDomain()) {
            if (defined('KAKAOTALK_LOGIN_REST_API_KEY') && !empty(KAKAOTALK_LOGIN_REST_API_KEY)) {
                $this->rest_api_key = KAKAOTALK_LOGIN_REST_API_KEY;
            }
            return;
        }

        // 가맹사 도메인인 경우 branch_meta에서 로드
        $this->loadRestApiKeyFromBranchMeta();
    }

    /**
     * 현재 도메인이 본사 도메인인지 확인합니다.
     * 포트 번호를 제거한 호스트명으로 비교합니다.
     */
    private function isHeadOfficeDomain(): bool
    {
        $host = $_SERVER['HTTP_HOST'] ?? '';
        $hostname = strtolower(explode(':', $host)[0]);
        return in_array($hostname, self::HEAD_OFFICE_DOMAINS);
    }

    /**
     * branch_meta 테이블에서 카카오 REST API 키를 로드합니다.
     */
    private function loadRestApiKeyFromBranchMeta(): void
    {
        if (!class_exists('Center\Repository\BranchRepository')) {
            return;
        }

        $branch = \Center\Repository\BranchRepository::getByCurrentDomain();
        if (!$branch) {
            return;
        }

        $branchMetaRepo = new \Center\Repository\BranchMetaRepository();
        $restApiKey = $branchMetaRepo->getValue($branch->getId(), 'kakao_rest_api_key');
        if (!empty($restApiKey)) {
            $this->rest_api_key = $restApiKey;
        }
    }
}
```

> **🔥 REST API 키 로드 우선순위:**
> 1. `isHeadOfficeDomain()`으로 본사 도메인 여부 확인 → 본사면 `KAKAOTALK_LOGIN_REST_API_KEY` 상수 사용
> 2. 가맹사 도메인이면 `BranchRepository::getByCurrentDomain()` + `BranchMetaRepository::getValue()`로 `kakao_rest_api_key` 동적 로드
>
> 본사 도메인 목록은 `HEAD_OFFICE_DOMAINS` 상수로 관리: `sonub.com`, `localhost`, `127.0.0.1`
> 포트 번호는 자동으로 제거됩니다 (예: `localhost:3000` → `localhost`)

### 6.2 인가코드 요청: `/auth/kakao/start.php`

```php
<?php
/**
 * 카카오 로그인 시작
 *
 * 역할:
 * 1. CSRF 방지용 state 난수 생성 → 세션에 저장
 * 2. 카카오 authorize 엔드포인트로 리다이렉트
 *
 * 파일: auth/kakao/start.php
 */
session_start();

// bootstrap.php를 먼저 로드하여 BranchRepository, BranchMetaRepository 사용 가능하게 함
// → KakaoConfig가 branch_meta에서 REST API 키를 동적으로 로드하기 위해 필요
require_once __DIR__ . '/../../bootstrap.php';
require_once __DIR__ . '/../../etc/config/kakao.config.php';
$kakao = new KakaoConfig();

// CSRF 방지용 state 생성 (16바이트 = 32자리 16진수)
$state = bin2hex(random_bytes(16));
$_SESSION['kakao_oauth_state'] = $state;

// 카카오 authorize 엔드포인트로 리다이렉트
$params = http_build_query([
    'response_type' => 'code',
    'client_id'     => $kakao->rest_api_key,
    'redirect_uri'  => $kakao->redirect_uri,
    'state'         => $state,
]);

header('Location: https://kauth.kakao.com/oauth/authorize?' . $params);
exit;
```

> **🔥 핵심:** `bootstrap.php`를 `kakao.config.php`보다 **먼저** 로드해야 합니다. `KakaoConfig` 생성자에서 `BranchRepository`와 `BranchMetaRepository`를 사용하기 때문입니다.

### 6.3 콜백 처리: `/auth/kakao/callback.php`

```php
<?php
/**
 * 카카오 로그인 콜백
 *
 * 역할:
 * 1. state 검증 (CSRF 방지)
 * 2. 인가코드(code) → access_token 교환
 * 3. 카카오 사용자 ID 확보 (/v2/user/me)
 * 4. Firebase Custom Token 발급
 * 5. complete.php로 리다이렉트 (Custom Token은 세션에 저장)
 *
 * 파일: auth/kakao/callback.php
 */
session_start();

// bootstrap.php를 먼저 로드하여 BranchRepository, BranchMetaRepository 사용 가능하게 함
// → KakaoConfig가 branch_meta에서 REST API 키를 동적으로 로드하기 위해 필요
require_once __DIR__ . '/../../bootstrap.php';
require_once __DIR__ . '/../../etc/config/kakao.config.php';

$kakao = new KakaoConfig();

$code  = $_GET['code'] ?? null;
$state = $_GET['state'] ?? null;
$error = $_GET['error'] ?? null;

// 카카오에서 에러 반환 시 (사용자가 로그인 취소 등)
if ($error) {
    $errorDescription = $_GET['error_description'] ?? '카카오 로그인이 취소되었습니다.';
    header('Location: /user/login?error=' . urlencode($errorDescription));
    exit;
}

if (!$code) {
    header('Location: /user/login?error=' . urlencode('인가코드가 없습니다.'));
    exit;
}

// ────────────────────────────────────────────────
// 1) state 검증 (CSRF 방지)
// ────────────────────────────────────────────────
$expected = $_SESSION['kakao_oauth_state'] ?? null;
unset($_SESSION['kakao_oauth_state']); // 1회용이므로 즉시 삭제

if (!$expected || !$state || !hash_equals($expected, $state)) {
    header('Location: /user/login?error=' . urlencode('잘못된 요청입니다. (state 불일치)'));
    exit;
}

// ────────────────────────────────────────────────
// 2) code → access_token 교환
//    POST https://kauth.kakao.com/oauth/token
// ────────────────────────────────────────────────
$postData = [
    'grant_type'   => 'authorization_code',
    'client_id'    => $kakao->rest_api_key,
    'redirect_uri' => $kakao->redirect_uri,
    'code'         => $code,
];

// Client Secret을 활성화한 경우 포함
if (!empty($kakao->client_secret)) {
    $postData['client_secret'] = $kakao->client_secret;
}

$ch = curl_init('https://kauth.kakao.com/oauth/token');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => http_build_query($postData),
    CURLOPT_HTTPHEADER     => ['Content-Type: application/x-www-form-urlencoded'],
    CURLOPT_TIMEOUT        => 10,
]);
$tokenRes = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($tokenRes === false || $httpCode !== 200) {
    header('Location: /user/login?error=' . urlencode('카카오 토큰 교환에 실패했습니다.'));
    exit;
}

$tokenData = json_decode($tokenRes, true);
if (!isset($tokenData['access_token'])) {
    header('Location: /user/login?error=' . urlencode('카카오 access_token을 받지 못했습니다.'));
    exit;
}

$accessToken = $tokenData['access_token'];

// ────────────────────────────────────────────────
// 3) 카카오 사용자 ID 확보
//    GET https://kapi.kakao.com/v2/user/me
//    → 카카오 고유 사용자 ID만 사용 (회원 정보 불필요)
// ────────────────────────────────────────────────
$ch = curl_init('https://kapi.kakao.com/v2/user/me');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER     => [
        'Authorization: Bearer ' . $accessToken,
        'Content-Type: application/x-www-form-urlencoded;charset=utf-8',
    ],
    CURLOPT_TIMEOUT        => 10,
]);
$meRes = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($meRes === false || $httpCode !== 200) {
    header('Location: /user/login?error=' . urlencode('카카오 사용자 정보 조회에 실패했습니다.'));
    exit;
}

$me = json_decode($meRes, true);
if (!isset($me['id'])) {
    header('Location: /user/login?error=' . urlencode('카카오 사용자 ID를 확인할 수 없습니다.'));
    exit;
}

$kakaoUserId = (string) $me['id']; // 카카오 고유 사용자 ID (숫자)

// ────────────────────────────────────────────────
// 4) Firebase Custom Token 발급
//    센터 프로젝트의 kreait/firebase-php 사용
//    UID 형식: 'kakao:{카카오사용자ID}'
// ────────────────────────────────────────────────
try {
    $firebaseAuth = firebase_auth_admin();
    // Firebase UID는 'kakao:12345678' 형식으로 생성
    // → 다른 소셜 로그인(Google 등)과 UID 충돌 방지
    $firebaseUid = 'kakao:' . $kakaoUserId;
    $customToken = $firebaseAuth->createCustomToken($firebaseUid);
    $customTokenString = $customToken->toString();
} catch (Exception $e) {
    error_log('[카카오 로그인] Custom Token 발급 실패: ' . $e->getMessage());
    header('Location: /user/login?error=' . urlencode('로그인 처리 중 오류가 발생했습니다.'));
    exit;
}

// ────────────────────────────────────────────────
// 5) complete.php로 리다이렉트 (Custom Token은 세션에 저장하여 URL 노출 방지)
// ────────────────────────────────────────────────
$_SESSION['kakao_custom_token'] = $customTokenString;
$_SESSION['kakao_provider'] = 'kakao';
$_SESSION['kakao_social_id'] = $kakaoUserId;

header('Location: /auth/kakao/complete.php');
exit;
```

> **🔥 핵심 변경사항:**
> - `etc/autoload.php` 대신 `bootstrap.php`를 사용합니다 (센터 프로젝트 표준)
> - `bootstrap.php`를 `kakao.config.php`보다 **먼저** 로드해야 합니다

### 6.4 Firebase 로그인 완료 페이지: `/auth/kakao/complete.php`

```php
<?php
/**
 * 카카오 로그인 완료 (Custom Token → Firebase Auth 로그인)
 *
 * 역할:
 * 1. 세션에서 Custom Token 꺼내기 (1회용)
 * 2. Firebase signInWithCustomToken() 실행
 * 3. my API 호출 → PostgreSQL 사용자 생성/업데이트 → 리다이렉트
 *
 * 파일: auth/kakao/complete.php
 */
session_start();

$customToken = $_SESSION['kakao_custom_token'] ?? null;
$provider = $_SESSION['kakao_provider'] ?? null;
$socialId = $_SESSION['kakao_social_id'] ?? null;

// 세션에서 즉시 삭제 (1회용)
unset($_SESSION['kakao_custom_token']);
unset($_SESSION['kakao_provider']);
unset($_SESSION['kakao_social_id']);

if (!$customToken) {
    header('Location: /user/login?error=' . urlencode('로그인 토큰이 만료되었습니다. 다시 시도해 주세요.'));
    exit;
}

// Firebase SDK 설정을 위해 센터 프로젝트의 config 사용
require_once __DIR__ . '/../../bootstrap.php';
$firebaseConfig = config()->firebase;
?>
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>로그인 처리 중...</title>
    <!-- Firebase SDK -->
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js"></script>
    <script src="https://www.gstatic.com/firebasejs/8.10.1/firebase-auth.js"></script>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f8f9fa;
        }
        .loading {
            text-align: center;
        }
        .spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #dee2e6;
            border-top-color: #FEE500;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 16px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }
    </style>
</head>
<body>
    <div class="loading">
        <div class="spinner"></div>
        <p>카카오 로그인 처리 중...</p>
    </div>

    <script>
        // Firebase 초기화
        firebase.initializeApp(<?= $firebaseConfig->client_sdk_json ?>);

        (async function() {
            try {
                const customToken = <?= json_encode($customToken) ?>;

                // 1) Firebase Custom Token으로 로그인
                const result = await firebase.auth().signInWithCustomToken(customToken);

                // 2) my API 호출 (PostgreSQL 사용자 생성/업데이트)
                //    🔥 센터 API는 'func' 파라미터를 사용 ('function' 아님!)
                const idToken = await result.user.getIdToken();
                const response = await fetch('/api.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: new URLSearchParams({
                        func: 'my',
                        token: idToken,
                        auth: '1',
                        display_name: result.user.displayName || '',
                        domain: window.location.hostname,
                        provider: <?= json_encode($provider) ?>,
                        social_id: <?= json_encode($socialId) ?>,
                        alertOnError: '0'
                    })
                });
                const user = await response.json();

                if (user && user.id && !user.error) {
                    // 3) session_id 쿠키가 설정되었으므로 리다이렉트
                    //    사용자 유형에 따라 분기
                    if (user.is_root === true) {
                        window.location.href = '/root/dashboard';
                    } else if (user.is_branch_admin === true) {
                        // 본사 도메인이면 my-sites, 가맹사면 dashboard
                        const hostname = window.location.hostname;
                        const isHead = (hostname === 'sonub.com' || hostname === 'localhost' || hostname === '127.0.0.1');
                        window.location.href = isHead ? '/admin/my-sites' : '/admin/dashboard';
                    } else {
                        window.location.href = '/';
                    }
                } else {
                    throw new Error(user?.message || '사용자 정보를 가져올 수 없습니다.');
                }
            } catch (error) {
                console.error('[카카오 로그인 실패]', error);
                window.location.href = '/user/login?error=' + encodeURIComponent(
                    error.message || '카카오 로그인에 실패했습니다. 다시 시도해 주세요.'
                );
            }
        })();
    </script>
</body>
</html>
```

> **🔥 핵심 변경사항:**
> - `etc/autoload.php` 대신 `bootstrap.php`를 사용합니다
> - API 호출 시 `func: 'my'`를 사용합니다 (센터 API 표준). **`function`이 아님!**
> - `provider: 'kakao'`와 `social_id: 카카오사용자ID`를 my API에 전달하여 사용자 소셜 정보를 저장합니다

---

## 7. JavaScript 프론트엔드 구현

### 7.1 loginWithKakao() 함수

**파일:** `js/social-auth.js` 에 추가

```javascript
// ============================================
// 카카오 로그인 (웹 리다이렉트 방식)
//
// Google/Apple: Firebase Auth 직접 로그인 (signInWithPopup)
// Kakao:       서버에서 code→token 교환 → Custom Token 발급 → Firebase 로그인
//
// 흐름:
// 1. loginWithKakao() → /auth/kakao/start.php 리다이렉트
// 2. start.php → 카카오 authorize 리다이렉트
// 3. 카카오 인증 → callback.php (code→token→사용자ID→Custom Token)
// 4. callback.php → complete.php (Custom Token→Firebase 로그인→DB 동기화→리다이렉트)
// ============================================
function loginWithKakao() {
    showSocialLoginLoading(true);
    hideSocialLoginError();
    // PHP 서버로 이동 (서버에서 state 생성 후 카카오로 리다이렉트)
    window.location.href = '/auth/kakao/start.php';
}
```

### 7.2 카카오 로그인 버튼

**파일:** `widgets/user/social-login.php` 에 추가

```php
<!-- 카카오 로그인 -->
<button onclick="loginWithKakao()" class="btn btn-lg w-100 d-flex align-items-center justify-content-center gap-2"
    style="background-color: #FEE500; color: #191919; border: none;"
    id="btn-kakao-login">
    <!-- 카카오 아이콘 (SVG) -->
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
        <path fill-rule="evenodd" clip-rule="evenodd"
            d="M10 2C5.029 2 1 5.216 1 9.158c0 2.538 1.675 4.769 4.198 6.044l-1.07 3.926c-.094.346.302.618.601.414l4.667-3.108c.197.015.397.024.604.024 4.971 0 9-3.216 9-7.3S14.971 2 10 2z"
            fill="#191919"/>
    </svg>
    <?= __('카카오 로그인') ?>
</button>
```

### 7.3 에러 파라미터 처리

`/user/login` 페이지에서 카카오 콜백의 에러 메시지를 표시합니다.

```javascript
// widgets/user/social-login.php 하단에 포함
// URL 파라미터에서 에러 메시지 확인
const urlParams = new URLSearchParams(window.location.search);
const errorMsg = urlParams.get('error');
if (errorMsg) {
    showSocialLoginError(decodeURIComponent(errorMsg));
    // URL에서 에러 파라미터 제거 (새로고침 시 에러 반복 방지)
    window.history.replaceState({}, '', window.location.pathname);
}
```

---

## 8. Firebase Custom Token 발급 상세

### 8.1 센터 프로젝트에서의 Custom Token 발급

센터 프로젝트는 `kreait/firebase-php` 패키지를 사용하고 있어, Custom Token 발급이 가능합니다.

```php
// firebase_auth_admin()는 lib/firebase/firebase.functions.php에 정의
// → Kreait\Firebase\Contract\Auth 인스턴스 반환
$auth = firebase_auth_admin();

// Custom Token 발급 (기본 유효시간: 1시간)
$customToken = $auth->createCustomToken('kakao:12345678');
$tokenString = $customToken->toString(); // JWT 문자열
```

### 8.2 Firebase UID 규칙

| 소셜 로그인 | Firebase UID 형식 | 예시 |
|-----------|-------------------|------|
| Google | Google에서 자동 할당 | `abc123def456...` |
| Apple | Apple에서 자동 할당 | `000123.abc456...` |
| **카카오** | **`kakao:{카카오사용자ID}`** | `kakao:454835416` |

> **중요:** 카카오 UID에 `kakao:` 접두사를 붙여 다른 소셜 로그인과의 UID 충돌을 방지합니다.

> **참고:** Firebase Auth 콘솔에서 카카오 Custom Token으로 생성된 사용자의 **Identifier(식별자)가 비어 있는 것은 정상**입니다. Custom Token 사용자는 이메일/전화번호가 설정되지 않으므로 UID(`kakao:454835416`)만 표시됩니다.

### 8.3 Custom Token의 특성

| 속성 | 값 |
|------|-----|
| 유효시간 | 1시간 (기본값) |
| 사용 횟수 | 1회용 (signInWithCustomToken 후 무효화) |
| 발급 주체 | Firebase 서비스 계정 (`etc/config/withcenter-firebase-adminsdk.json`) |
| 대상 | 클라이언트에서 `firebase.auth().signInWithCustomToken(token)` 호출용 |

### 8.4 서비스 계정 요구사항

Custom Token 발급에는 Firebase 서비스 계정 키 JSON이 필수입니다.

- **파일 경로:** `etc/config/withcenter-firebase-adminsdk.json`
- **설정 위치:** `etc/config/firebase.config.php` → `$service_account` 속성
- **사용 함수:** `firebase_auth_admin()` → `getFactory()` → `(new Factory)->withServiceAccount(...)`

---

## 9. 가맹사별 앱 설정 페이지

### 9.1 개요

가맹사 운영자가 `/admin/app-settings` 페이지에서 카카오톡/네이버 API 키를 직접 설정할 수 있습니다. 설정된 키는 `branch_meta` 테이블에 키-값 쌍으로 저장되며, `KakaoConfig` 클래스가 로그인 시 동적으로 로드합니다.

### 9.2 저장되는 branch_meta 키

| branch_meta 키 | 카테고리 | 용도 | 사용 위치 |
|----------------|---------|------|----------|
| `kakao_rest_api_key` | `kakao` | REST API 키 (서버에서 토큰 교환 시 사용) | `KakaoConfig::loadRestApiKey()` (가맹사 도메인에서만 사용, 본사 도메인은 상수) |
| `kakao_javascript_key` | `kakao` | JavaScript 키 (웹 SDK용) | 추후 사용 |
| `kakao_native_key` | `kakao` | 네이티브 앱 키 (Flutter/iOS/Android) | 추후 사용 |
| `naver_client_id` | `naver` | 네이버 로그인 Client ID | 추후 사용 |

### 9.3 동적 키 로드 흐름

```
1. 사용자가 "카카오 로그인" 클릭
   │
   ▼
2. /auth/kakao/start.php 실행
   │
   ├── bootstrap.php 로드 (BranchRepository, BranchMetaRepository 사용 가능)
   ├── kakao.config.php 로드
   │
   ▼
3. KakaoConfig 생성자 호출
   │
   ├── Redirect URI 자동 결정 (현재 도메인 기반)
   ├── loadRestApiKey() 호출
   │     │
   │     ├── isHeadOfficeDomain() 확인 (sonub.com, localhost, 127.0.0.1)
   │     │     │
   │     │     ├── 본사 도메인 → KAKAOTALK_LOGIN_REST_API_KEY 상수 사용 (key.config.php)
   │     │     └── 가맹사 도메인 → loadRestApiKeyFromBranchMeta() 호출
   │     │           │
   │     │           ├── BranchRepository::getByCurrentDomain() → 현재 도메인의 Branch 조회
   │     │           ├── BranchMetaRepository::getValue(branchId, 'kakao_rest_api_key') → REST API 키 조회
   │     │           └── $this->rest_api_key에 저장
   │     │
   │     └── $this->rest_api_key에 저장
   │
   ▼
4. 카카오 authorize 리다이렉트 (로드된 REST API 키 사용)
```

### 9.4 앱 설정 페이지 핵심 구현

**파일:** `pages/admin/app-settings.php`

| 항목 | 구현 |
|------|------|
| **프레임워크** | Vue.js 3 (Composition API) |
| **권한** | 가맹사 운영자만 접근 가능 (`is_branch_admin` 또는 `is_root`) |
| **데이터 로드** | `get_branch_meta` API로 각 키별 개별 조회 |
| **데이터 저장** | `update_branch_meta` API로 순차 저장 |
| **다국어** | 4개 국어 지원 (ko/en/ja/zh) |

```javascript
// 카카오톡 설정 로드 (branch_meta에서 조회)
const loadKakaoSettings = async () => {
    const keys = ['kakao_rest_api_key', 'kakao_javascript_key', 'kakao_native_key', 'naver_client_id'];
    for (const key of keys) {
        const result = await api('get_branch_meta', {
            branch_id: myBranch.value.id,
            key: key,
            alertOnError: false
        });
        if (result && !result.error && result.value) {
            // 해당 Vue ref에 값 설정
        }
    }
};

// 카카오톡 설정 저장
const saveKakaoSettings = async () => {
    const settings = [
        { key: 'kakao_rest_api_key', value: kakaoRestApiKey.value.trim() },
        { key: 'kakao_javascript_key', value: kakaoJavascriptKey.value.trim() },
        { key: 'kakao_native_key', value: kakaoNativeKey.value.trim() },
    ];
    for (const setting of settings) {
        await api('update_branch_meta', {
            branch_id: myBranch.value.id,
            key: setting.key,
            value: setting.value || null,
            category: 'kakao',
            auth: true,
            alertOnError: false
        });
    }
};
```

---

## 10. 실전 트러블슈팅 (자주 터지는 포인트)

### 10.1 Redirect URI 불일치 (`KOE006`)

**원인:** 카카오 콘솔에 등록한 Redirect URI와 실제 요청 URI가 다름

**확인사항:**
- `http` ↔ `https` 일치 여부
- 포트 번호 (`8080`, `3000` 등) 포함 여부
- path 정확한 일치 (trailing slash `/` 주의)
- 대소문자 일치

```
# 등록: https://sonub.com/auth/kakao/callback.php
# 요청: https://sonub.com/auth/kakao/callback.php  ← ✅ 일치
# 요청: https://sonub.com/auth/kakao/callback.php/ ← ❌ trailing slash
# 요청: http://sonub.com/auth/kakao/callback.php   ← ❌ http vs https
```

### 10.2 state 검증 실패

**원인:** 세션이 유지되지 않음 (PHP 세션 설정 문제)

**확인사항:**
- `session_start()`가 출력 전에 호출되는지 확인
- PHP 세션 저장 디렉토리 권한 확인
- 도메인 간 세션 공유 문제 (다른 도메인에서 콜백 받는 경우)

> **참고:** 센터 프로젝트는 일반적으로 `session_id` 쿠키 + API 토큰 방식을 사용하지만, 카카오 OAuth 흐름에서는 짧은 시간 내 state/token 전달을 위해 `$_SESSION`을 사용합니다. OAuth 콜백 전후의 짧은 수명 동안만 사용하므로 문제없이 동작합니다.

### 10.3 토큰 교환 실패

**원인:** REST API 키 또는 code가 잘못됨

**확인사항:**
- REST API 키 (≠ JavaScript 키) 사용 여부
- **branch_meta에 `kakao_rest_api_key`가 설정되어 있는지** 확인 (`/admin/app-settings` 페이지)
- 인가코드(code)는 1회용이므로 새로고침하면 실패
- Client Secret 설정을 활성화했다면 `client_secret` 파라미터 포함 여부

### 10.4 Custom Token 발급 실패

**원인:** Firebase 서비스 계정 키 문제

**확인사항:**
- `etc/config/withcenter-firebase-adminsdk.json` 파일 존재 확인
- 서비스 계정에 `Firebase Auth` 권한이 있는지 확인
- JSON 파일의 `private_key` 필드가 올바른지 확인

### 10.5 "func 파라미터가 필요합니다" 에러

**원인:** `complete.php`에서 API 호출 시 `function` 파라미터를 사용한 경우

**해결:** 센터 API는 `func` 파라미터를 사용합니다. `function: 'my'`가 아닌 `func: 'my'`로 설정해야 합니다.

```javascript
// ❌ 잘못된 예시
body: new URLSearchParams({ function: 'my', ... })

// ✅ 올바른 예시
body: new URLSearchParams({ func: 'my', ... })
```

### 10.6 Firebase Auth 콘솔에서 Identifier가 비어 있음

**원인:** Custom Token으로 생성된 Firebase 사용자는 이메일/전화번호가 없음

**해결:** 이것은 **정상 동작**입니다. Custom Token 사용자는 UID(`kakao:454835416`)만 설정되고 Identifier(이메일/전화번호)는 비어 있습니다. 센터 프로젝트에서는 PostgreSQL `users` 테이블에 사용자 정보를 별도 관리하므로 문제되지 않습니다.

### 10.7 동의항목 관련

**주의:** 카카오톡에서는 로그인만 하면 되므로 동의항목을 추가 설정할 필요가 없습니다. 만약 `/v2/user/me`에서 추가 정보가 필요해지면 카카오 콘솔에서 동의항목을 설정해야 합니다.

### 10.8 도메인이 여러 개인 경우

센터 프로젝트는 가맹사별 도메인이 다르므로:
- 기본적으로 카카오에 사이트 도메인 **10개까지** 등록 가능
- Redirect URI도 각 도메인별로 등록 필요
- 또는 공통 도메인(sonub.com)으로 콜백 받은 뒤, 원래 가맹사 도메인으로 리다이렉트하는 방식 고려

---

## 11. 로그아웃 / 연결끊기 (탈퇴)

### 11.1 로그아웃

카카오 로그인 시 Firebase Auth에 로그인되므로, 기존 `logout()` 함수(`js/app.js`)로 처리됩니다.
별도의 카카오 로그아웃 API 호출은 불필요합니다.

```javascript
// 기존 logout() 함수가 그대로 동작
// 1. logout API 호출 (session_id 쿠키 삭제)
// 2. firebase.auth().signOut()
// 3. 리다이렉트
await logout();
```

### 11.2 연결끊기 (회원 탈퇴 시)

회원 탈퇴 시 카카오 연결끊기가 필요한 경우 (선택):

```php
// 서버에서 카카오 연결끊기 API 호출
// POST https://kapi.kakao.com/v1/user/unlink
// 단, 이 시점에서 카카오 access_token이 필요함
// → 회원 탈퇴 시 카카오 연결끊기는 선택사항
```

> **참고:** 센터 프로젝트의 회원 탈퇴는 Hard Delete 방식(`user-withdrawal.md` 참조)이며, Firebase Auth에서 사용자를 삭제하면 됩니다. 카카오 연결끊기는 필수가 아닙니다.

---

## 12. Flutter 앱용 카카오 로그인 API

### 12.1 개요

Flutter 앱에서는 웹 리다이렉트 방식 대신 **Kakao SDK → API 호출** 방식으로 카카오 로그인을 처리합니다.
Flutter에서 Kakao SDK로 로그인하여 `access_token`을 획득한 뒤, PHP 서버의 `kakao_firebase_token` API를 호출하여 Firebase Custom Token을 발급받습니다.

### 12.2 웹 vs Flutter 앱 비교

| 구분 | 웹 (리다이렉트 방식) | Flutter 앱 (API 방식) |
|------|---------------------|----------------------|
| **카카오 로그인** | 브라우저 리다이렉트 (`auth/kakao/start.php`) | Kakao SDK `loginWithKakaoTalk()` |
| **토큰 교환** | PHP 서버 (`auth/kakao/callback.php`) | 불필요 (SDK가 직접 처리) |
| **Custom Token 발급** | `callback.php`에서 직접 처리 | `kakao_firebase_token` API 호출 |
| **Firebase 로그인** | `complete.php`에서 `signInWithCustomToken()` | Flutter에서 `signInWithCustomToken()` |
| **DB 동기화** | `complete.php`에서 `my` API 호출 | Flutter에서 `apiUserMy()` 호출 |

### 12.3 Flutter 앱 로그인 흐름

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    Flutter 카카오톡 로그인 전체 흐름                                │
└─────────────────────────────────────────────────────────────────────────────────┘

[1] Flutter: Kakao SDK로 로그인
        │
        ├── UserApi.instance.loginWithKakaoTalk()
        │   또는 UserApi.instance.loginWithKakaoAccount()
        └── 카카오 access_token 획득
                │
                ▼
[2] Flutter: kakao_firebase_token API 호출
        │
        ├── POST /api.php
        │   {"func": "kakao_firebase_token", "kakao_access_token": "..."}
        │
        ▼
[3] PHP 서버: kakao_firebase_token 함수 실행
        │
        ├── (a) 카카오 API로 사용자 ID 확인
        │       GET https://kapi.kakao.com/v2/user/me
        │       → 카카오 고유 사용자 ID 확보
        │
        ├── (b) Firebase Custom Token 발급
        │       firebase_auth_admin()->createCustomToken('kakao:' . $kakaoId)
        │
        └── (c) 응답 반환
                {
                    "custom_token": "eyJ...",
                    "kakao_user_id": "454835416",
                    "firebase_uid": "kakao:454835416"
                }
                │
                ▼
[4] Flutter: Firebase Auth 로그인
        │
        ├── FirebaseAuth.instance.signInWithCustomToken(customToken)
        │   → Firebase Auth에 로그인 완료
        │
        ├── apiUserMy() 호출 → PostgreSQL 사용자 생성/업데이트
        │   → provider='kakao', social_id=카카오사용자ID 전달
        │
        └── 로그인 완료 → 홈 화면 이동
```

### 12.4 `kakao_firebase_token` API 상세

**파일:** `lib/api/api.allowed_functions.php`

```php
/**
 * 카카오 access_token으로 Firebase Custom Token 발급
 *
 * Flutter 앱에서 Kakao SDK로 로그인 후 받은 access_token을 전달하면,
 * 서버에서 카카오 사용자 ID를 확인하고 Firebase Custom Token을 발급합니다.
 *
 * 인증 불필요: 아직 Firebase 로그인 전이므로 token 파라미터 없이 호출합니다.
 *
 * @param array $input 입력 데이터
 *   - kakao_access_token: 카카오 SDK에서 받은 access_token (필수)
 * @return array Firebase Custom Token 정보
 *   - custom_token: Firebase Custom Token (signInWithCustomToken()에 사용)
 *   - kakao_user_id: 카카오 고유 사용자 ID
 *   - firebase_uid: Firebase UID ('kakao:{카카오사용자ID}' 형식)
 */
public function kakao_firebase_token(array $input): array
{
    $kakaoAccessToken = $input['kakao_access_token'] ?? '';
    if (empty($kakaoAccessToken)) {
        error('kakao/access-token-required', '카카오 access_token이 필요합니다.');
    }

    // ── 1) 카카오 API로 사용자 ID 확인 ──
    $ch = curl_init('https://kapi.kakao.com/v2/user/me');
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER     => [
            'Authorization: Bearer ' . $kakaoAccessToken,
            'Content-Type: application/x-www-form-urlencoded;charset=utf-8',
        ],
        CURLOPT_TIMEOUT        => 10,
    ]);
    $meRes = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($meRes === false || $httpCode !== 200) {
        error('kakao/user-info-failed', '카카오 사용자 정보 조회에 실패했습니다. (HTTP ' . $httpCode . ')');
    }

    $me = json_decode($meRes, true);
    if (!isset($me['id'])) {
        error('kakao/user-id-not-found', '카카오 사용자 ID를 확인할 수 없습니다.');
    }

    $kakaoUserId = (string) $me['id'];

    // ── 2) Firebase Custom Token 발급 ──
    $firebaseUid = 'kakao:' . $kakaoUserId;

    try {
        $firebaseAuth = firebase_auth_admin();
        $customToken = $firebaseAuth->createCustomToken($firebaseUid);
        $customTokenString = $customToken->toString();
    } catch (\Exception $e) {
        error_log('[카카오 Firebase Token] Custom Token 발급 실패: ' . $e->getMessage());
        error('kakao/custom-token-failed', 'Firebase Custom Token 발급에 실패했습니다.');
    }

    return [
        'custom_token'  => $customTokenString,
        'kakao_user_id' => $kakaoUserId,
        'firebase_uid'  => $firebaseUid,
    ];
}
```

### 12.5 API 에러 코드

| 에러 코드 | HTTP | 원인 | 해결 방법 |
|----------|------|------|----------|
| `kakao/access-token-required` | 400 | `kakao_access_token` 파라미터 누락 | 카카오 SDK 로그인 후 access_token 전달 |
| `kakao/user-info-failed` | 400 | 카카오 API에서 사용자 정보 조회 실패 | access_token 유효성 확인 (만료/잘못된 토큰) |
| `kakao/user-id-not-found` | 400 | 카카오 응답에 사용자 ID 없음 | 카카오 앱 설정 확인 |
| `kakao/custom-token-failed` | 400 | Firebase Custom Token 발급 실패 | Firebase 서비스 계정 키 확인 (`withcenter-firebase-adminsdk.json`) |

### 12.6 Flutter 앱 구현 예시 (Dart)

```dart
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 카카오 로그인 → Firebase Custom Token → Firebase Auth 로그인
Future<void> loginWithKakao() async {
  // 1) Kakao SDK로 로그인
  OAuthToken token;
  if (await isKakaoTalkInstalled()) {
    token = await UserApi.instance.loginWithKakaoTalk();
  } else {
    token = await UserApi.instance.loginWithKakaoAccount();
  }

  // 2) PHP 서버에서 Firebase Custom Token 발급
  final response = await apiRequest('kakao_firebase_token', {
    'kakao_access_token': token.accessToken,
  });

  if (response['error'] != null) {
    throw Exception(response['message']);
  }

  final customToken = response['custom_token'] as String;

  // 3) Firebase Auth 로그인
  await FirebaseAuth.instance.signInWithCustomToken(customToken);

  // 4) 센터 DB 사용자 동기화 (기존 my API 호출)
  await apiUserMy();
}
```

> **참고:** `apiRequest()`와 `apiUserMy()`는 센터 프로젝트 Flutter 앱의 기존 API 호출 함수입니다. 실제 구현은 앱의 API 모듈에 맞게 조정하세요.

### 12.7 다중 가맹사 로그인 동작 (Flutter 앱)

웹과 동일하게 동작합니다:

| 항목 | 동작 |
|------|------|
| **Firebase UID** | `kakao:{카카오사용자ID}` → 모든 가맹사에서 동일 |
| **가맹사 구분** | `apiUserMy()`에서 `branch_id` 파라미터로 처리 |
| **사용자 데이터** | Firebase UID 기준 동일 사용자, `branch_id`로 가맹사별 분리 |

### 12.8 PHP 유닛 테스트 (PEST + CURL API)

`kakao_firebase_token` API의 에러 처리와 동작을 검증하는 유닛 테스트입니다.

**테스트 파일:** `tests/Api/KakaoFirebaseTokenApiTest.php`

**실행 방법:**
```bash
./vendor/bin/pest tests/Api/KakaoFirebaseTokenApiTest.php
```

#### 12.8.1 테스트 항목

| 테스트 케이스 | 검증 내용 | 기대 결과 |
|-------------|----------|----------|
| `kakao_access_token` 파라미터 누락 | 필수 파라미터 검증 | `kakao/access-token-required` 에러 (400) |
| 빈 문자열 `kakao_access_token` | 빈 값 필터링 | `kakao/access-token-required` 에러 (400) |
| 잘못된 access_token | 카카오 API 401 응답 처리 | `kakao/user-info-failed` 에러 (400) |
| 만료된 형식의 access_token | 만료 토큰 처리 | `kakao/user-info-failed` 에러 (400) |
| 인증 불필요 확인 | `token` 없이 호출 가능 | `assert-token` 에러가 아닌 `kakao/` 에러 반환 |
| function_list 포함 확인 | API 함수 목록에 존재 | `kakao_firebase_token`이 `functions` 배열에 포함 |
| 에러 응답 형식 검증 | 에러 응답 구조 | `error`/`message` 필드 존재, `kakao/` 접두사 |

> **참고:** 정상 케이스(유효한 카카오 토큰으로 Custom Token 발급)는 실제 카카오 계정과 access_token이 필요하므로 에러 케이스 중심으로 테스트합니다.

#### 12.8.2 테스트 핵심 패턴

```php
// CURL 기반 API 직접 호출 테스트 (센터 프로젝트 표준 패턴)
test('kakao_access_token 파라미터 없이 호출 시 에러', function () {
    $res = callKakaoApi([
        'func' => 'kakao_firebase_token',
        // kakao_access_token 누락
    ]);

    expect($res['httpCode'])->toBe(400)
        ->and($res['result']['error'])->toBe('kakao/access-token-required')
        ->and($res['result']['message'])->toBe('카카오 access_token이 필요합니다.');
})->group('api', 'integration', 'kakao');
```

#### 12.8.3 에러 코드 체계

모든 카카오 관련 에러 코드는 `kakao/` 접두사를 사용합니다:

| 에러 코드 | HTTP 상태 | 발생 시점 |
|----------|----------|----------|
| `kakao/access-token-required` | 400 | `kakao_access_token` 파라미터 누락 또는 빈 값 |
| `kakao/user-info-failed` | 400 | 카카오 API (`/v2/user/me`) 호출 실패 (401/403 등) |
| `kakao/user-id-not-found` | 400 | 카카오 응답에 `id` 필드 없음 |
| `kakao/custom-token-failed` | 400 | Firebase Custom Token 발급 예외 |

---

## 13. 관련 파일 목록

### 13.1 카카오 로그인 관련 (신규)

| 파일 | 핵심 기능 |
|------|----------|
| `etc/config/key.config.php` | `KAKAOTALK_LOGIN_REST_API_KEY` 상수 (본사 도메인 전용 REST API 키) |
| `etc/config/kakao.config.php` | KakaoConfig 클래스 - 본사 도메인: 상수 사용, 가맹사: branch_meta에서 동적 로드, Redirect URI 자동 결정 |
| `auth/kakao/start.php` | bootstrap.php 로드 + state 생성 + 카카오 authorize 리다이렉트 |
| `auth/kakao/callback.php` | bootstrap.php 로드 + code→token 교환 + 사용자 ID 확보 + Custom Token 발급 + 세션 저장 |
| `auth/kakao/complete.php` | 세션에서 Custom Token 꺼내기 + Firebase 로그인 + my API(`func: 'my'`) + 리다이렉트 |
| `pages/admin/app-settings.php` | 가맹사 운영자용 앱 설정 페이지 (카카오/네이버 API 키 관리, Vue.js) |

### 13.2 기존 공유 파일

| 파일 | 핵심 기능 |
|------|----------|
| `js/social-auth.js` | `loginWithKakao()` 함수 추가 |
| `widgets/user/social-login.php` | 카카오 로그인 버튼 UI 추가 |
| `lib/firebase/firebase.functions.php` | `firebase_auth_admin()` → Custom Token 발급에 사용 |
| `etc/config/firebase.config.php` | Firebase 서비스 계정 키 경로 |
| `etc/config/withcenter-firebase-adminsdk.json` | Firebase Admin SDK 서비스 계정 키 |
| `js/app.js` | `syncDatabaseUser()`, `logout()` |
| `js/auth.js` | `analyzeUserType()` |
| `lib/Entity/User.php` | `provider` 필드(`'kakao'`), `socialId` 필드 |
| `lib/Repository/BranchMetaRepository.php` | `getValue()` → 카카오 REST API 키 조회에 사용 |
| `lib/Repository/BranchRepository.php` | `getByCurrentDomain()` → 현재 도메인의 가맹사 조회 |
| `widgets/admin/sidebar.php` | 가맹사 관리 사이드바 (앱 설정 메뉴 추가) |

### 13.3 Flutter 앱 카카오 로그인 관련 (신규)

| 파일 | 핵심 기능 |
|------|----------|
| `lib/api/api.allowed_functions.php` | `kakao_firebase_token()` API 함수 - 카카오 access_token → Firebase Custom Token 발급 |
| `tests/Api/KakaoFirebaseTokenApiTest.php` | `kakao_firebase_token` API 유닛 테스트 (7개 테스트 케이스, CURL 기반) |

### 13.4 관련 문서

| 문서 | 설명 |
|------|------|
| [user-login.md](../user-login.md) | 전체 로그인 시스템 (소셜 + 이메일), syncDatabaseUser 상세 |
| [user.md](../user.md) | 사용자 시스템, Firebase Token 인증 |
| [user-token.md](../user-token.md) | API TOKEN, session_id 쿠키 |
| [user-withdrawal.md](../user-withdrawal.md) | 회원 탈퇴 (Hard Delete) |
| [development.md](../development.md) | `api()` 함수, `ready()`, `firebase_ready()` |
