# v7 Settings API 문서

## 개요

시스템 설정을 관리하는 v7 API 모듈이다.
기존 `sf_config` 테이블(key-value)을 사용하여 앱 버전, 이벤트 On/Off 등의 설정을 저장/조회한다.
기존 `config_get()`/`config_set()` 함수(lib/config.functions.php)와 100% 호환된다.

> **레거시 앱 설정 API** (`func.php` 기반 `get_app_settings`)는 → [v7-app-settings.md](../app/v7-app-settings.md) 참조.

## 목차

- [아키텍처](#아키텍처)
- [설정 키 정의](#설정-키-정의)
- [API 엔드포인트](#api-엔드포인트)
  - [settings.get](#settingsget)
  - [settings.get 관리자 목록 조회](#settingsget-관리자-목록-조회)
  - [settings.update](#settingsupdate)
  - [settings.appVersion](#settingsappversion)
- [관리자 확인 로직 (isAdmin)](#관리자-확인-로직-isadmin)
- [관리자 페이지](#관리자-페이지)
- [다른 모듈에서 사용하기](#다른-모듈에서-사용하기)
- [PEST 테스트](#pest-테스트)
- [발견된 이슈 및 해결](#발견된-이슈-및-해결)

## 아키텍처

```
클라이언트 → api.php → SettingsController → SettingsService → SettingsRepository → sf_config 테이블
```

| 파일 | 네임스페이스 | 역할 |
|------|-------------|------|
| `lib/settings/SettingsEntity.php` | `Philgo\Settings` | key-value 데이터 구조체 |
| `lib/settings/SettingsRepository.php` | `Philgo\Settings` | sf_config 테이블 CRUD |
| `lib/settings/SettingsService.php` | `Philgo\Settings` | 비즈니스 로직, 키 상수, 기본값 |
| `lib/settings/SettingsController.php` | `Philgo\Settings` | API 엔드포인트 |
| `page/admin/system-settings.php` | - | 관리자 설정 UI |

## 설정 키 정의

| 키 | 상수 | 타입 | 기본값 | 설명 |
|---|------|------|--------|------|
| `app_version_android` | `KEY_APP_VERSION_ANDROID` | string | `'2.0.16'` | Android 앱 최소 버전 |
| `app_version_android_build` | `KEY_APP_VERSION_ANDROID_BUILD` | string | `'46'` | Android 빌드 번호 |
| `app_version_ios` | `KEY_APP_VERSION_IOS` | string | `'2.0.16'` | iOS 앱 최소 버전 |
| `app_version_ios_build` | `KEY_APP_VERSION_IOS_BUILD` | string | `'46'` | iOS 빌드 번호 |
| `company_qr_event_enabled` | `KEY_COMPANY_QR_EVENT_ENABLED` | Y/N | `'Y'` | 업소록 QR 이벤트 On/Off |
| `event_entry_enabled` | `KEY_EVENT_ENTRY_ENABLED` | Y/N | `'Y'` | 이벤트 응모 On/Off |

## API 엔드포인트

### settings.get

설정 조회 (공개 API). 인증 불필요.
전체 조회 시 관리자 목록(admins)도 함께 반환한다.

**요청:**
```
GET /api.php?method=settings.get
GET /api.php?method=settings.get&key=app_version_android
GET /api.php?method=settings.get&key=admins
```

**응답 (전체 - 관리자 목록 포함):**
```json
{
  "app_version_android": "2.0.16",
  "app_version_android_build": "46",
  "app_version_ios": "2.0.16",
  "app_version_ios_build": "46",
  "company_qr_event_enabled": "Y",
  "event_entry_enabled": "Y",
  "admins": {
    "admins": [
      "OSXtfcfdJkcLBovnQAC6Q1WMa2x1",
      "xG3UczB56qazt2fMLH97154Cda62"
    ],
    "chat_admin": "RaHIcr45pvPzYdcDIv6JoW8DnSH2"
  }
}
```

**응답 (특정 키):**
```json
{
  "key": "app_version_android",
  "value": "2.0.16"
}
```

### settings.get 관리자 목록 조회

`key=admins`로 관리자 목록만 단독 조회할 수 있다. 인증 불필요.
`etc/app.config.php`의 `ADMINS` 상수(Firebase UID 배열)와 채팅 관리자 UID를 반환한다.
기존 `get_admins()` 함수와 동일한 형태이다.

**요청:**
```
GET /api.php?method=settings.get&key=admins
```

**응답:**
```json
{
  "admins": [
    "OSXtfcfdJkcLBovnQAC6Q1WMa2x1",
    "xG3UczB56qazt2fMLH97154Cda62"
  ],
  "chat_admin": "RaHIcr45pvPzYdcDIv6JoW8DnSH2"
}
```

> **참고**: `admins` 데이터는 DB(`sf_config` 테이블)가 아닌 PHP 상수(`etc/app.config.php`의 `ADMINS`)에서 가져온다.
> 따라서 `settings.update`로 변경할 수 없고, 소스 코드 수정을 통해서만 변경 가능하다.
```

### settings.update

설정 업데이트 (관리자 전용). 인증 필수.

**요청:**
```
POST /api.php
Content-Type: application/json

{
  "method": "settings.update",
  "session_id": "xxx",
  "settings": {
    "app_version_android": "2.0.17",
    "app_version_android_build": "47",
    "company_qr_event_enabled": "N"
  }
}
```

> **인증 방식**: `session_id`를 JSON body에 포함하거나, 쿠키의 `session_id`를 사용한다.
> 관리자 확인은 `ADMINS` 상수 배열 기반이다. 상세 → [관리자 확인 로직](#관리자-확인-로직-isadmin) 참조.

**성공 응답:**
```json
{
  "app_version_android": "2.0.17",
  "app_version_android_build": "47",
  "app_version_ios": "2.0.16",
  "app_version_ios_build": "46",
  "company_qr_event_enabled": "N",
  "event_entry_enabled": "Y"
}
```

**에러 응답:**
```json
{"success": false, "message": "관리자 권한이 필요합니다."}
{"success": false, "message": "허용되지 않은 설정 키입니다: invalid_key"}
```

### settings.appVersion

앱 버전 정보 조회 (공개 API). 인증 불필요.
기존 `FLUTTER_APP_VERSION` 상수와 동일한 형태를 반환한다.

**요청:**
```
GET /api.php?method=settings.appVersion
```

**응답:**
```json
{
  "android": {
    "version": "2.0.16",
    "build_number": 46
  },
  "ios": {
    "version": "2.0.16",
    "build_number": 46
  }
}
```

## 관리자 확인 로직 (isAdmin)

### 핵심 원칙: ADMINS 상수 배열 기반 확인

> **v7 시스템에서 관리자 확인은 반드시 `ADMINS` 상수 배열에 사용자의 `firebase_uid`가 포함되어 있는지로 판단해야 한다.**
> **절대로 `sf_member.admin` 컬럼을 사용하면 안 된다.**

### 관리자 확인 방식 비교

| 방식 | 코드 | 올바른 사용 |
|------|------|-------------|
| **ADMINS 배열 (올바름)** | `in_array($user['firebase_uid'], ADMINS)` | v7 및 레거시 모두 사용 |
| **admin 컬럼 (잘못됨)** | `$user['admin'] === 'Y'` | **절대 사용 금지** |

### ADMINS 상수 정의

`etc/app.config.php`에 정의된 `ADMINS` 상수는 관리자 Firebase UID 배열이다:

```php
// etc/app.config.php
const ADMINS = [
    "OSXtfcfdJkcLBovnQAC6Q1WMa2x1",  // 로컬 테스트 관리자
    "xG3UczB56qazt2fMLH97154Cda62",    // 로컬 테스트 관리자 for philgo
    // ... 기타 관리자
];
```

### v7 Controller에서의 올바른 관리자 확인 구현

```php
// lib/settings/SettingsController.php

use Philgo\Utils\AuthService;

/**
 * 현재 사용자가 관리자인지 확인한다.
 *
 * 레거시 is_admin_user()와 동일한 로직:
 * ADMINS 상수 배열(etc/app.config.php)에 사용자의 firebase_uid가 포함되어 있는지 확인.
 *
 * @return bool 관리자이면 true
 * @see lib/functions.php:239 is_admin_user()
 * @see etc/app.config.php ADMINS 상수
 */
private function isAdmin(): bool
{
    $user = AuthService::getLoginUser();
    if ($user === null) {
        return false;
    }
    if (empty($user['firebase_uid'])) {
        return false;
    }
    return in_array($user['firebase_uid'], ADMINS);
}

/**
 * 관리자 권한을 요구한다. 관리자가 아니면 예외를 던진다.
 *
 * @throws RuntimeException 관리자가 아닌 경우
 */
private function requireAdmin(): void
{
    if (!$this->isAdmin()) {
        throw new RuntimeException('관리자 권한이 필요합니다.');
    }
}
```

### 레거시 관리자 확인 함수 (참고)

```php
// lib/functions.php:239-263

function is_admin_user(array $login_user): bool
{
    if (empty($login_user) || empty($login_user[IDX])) return false;
    if (!isset($login_user[FIREBASE_UID])) return false;
    if (!in_array($login_user[FIREBASE_UID], ADMINS)) return false;
    return true;
}

function is_admin(): bool
{
    if (!login()) return false;
    return is_admin_user(login()->toArray());
}
```

### 관리자 확인 흐름도

```
[v7 관리자 확인 흐름]

settings.update 요청
    │
    ▼ SettingsController::update($input)
    │
    ▼ $this->requireAdmin()
    │
    ▼ $this->isAdmin()
    │
    ▼ AuthService::getLoginUser()
    │  ├─ 경로 1: 쿠키/파라미터의 session_id → getUserBySessionId()
    │  │  └─ session_id 파싱 → DB 조회 → 해시 검증 → 사용자 반환
    │  └─ 경로 2: id_token 파라미터 → getUserByIdToken()
    │     └─ Firebase 토큰 검증 → firebase_uid → DB 조회 → 사용자 반환
    │
    ▼ $user['firebase_uid'] 추출
    │
    ▼ in_array($user['firebase_uid'], ADMINS)
    │  ├─ true → 관리자 확인 완료 → 설정 저장 진행
    │  └─ false → RuntimeException('관리자 권한이 필요합니다.')
```

### 다른 v7 Controller에서 관리자 확인 패턴 재사용

새로운 v7 Controller에서 관리자 확인이 필요한 경우, **반드시** 아래 패턴을 따른다:

```php
// 새 Controller에서 관리자 확인 패턴
use Philgo\Utils\AuthService;
use RuntimeException;

private function isAdmin(): bool
{
    $user = AuthService::getLoginUser();
    if ($user === null) return false;
    if (empty($user['firebase_uid'])) return false;
    return in_array($user['firebase_uid'], ADMINS);
}

private function requireAdmin(): void
{
    if (!$this->isAdmin()) {
        throw new RuntimeException('관리자 권한이 필요합니다.');
    }
}
```

## 관리자 페이지

### 기본 정보

- **URL**: `https://local.philgo.com/page/admin/system-settings.php`
- **메뉴 위치**: 관리자 대시보드 → 메뉴 → "설정"
- **기능**: 앱 버전 편집, 업소록 QR 이벤트 토글, 이벤트 응모 토글
- **기술**: Vue.js Options API + axios + api.php AJAX 호출
- **다국어**: `inject_admin_system_settings_language()` 함수 (ko, en, ja, zh)

### 페이지 구조

```
page/admin/system-settings.php
├─ page.header.php (레거시 include)
├─ vendor/autoload.php (v7 autoloader)
├─ is_admin() 체크 (레거시 SSR 권한 확인)
├─ SettingsService::getAll() (v7 SSR 초기 데이터 로드)
├─ Vue.js 앱 (Options API)
│  ├─ data: settings (SSR에서 주입), sessionId (쿠키에서 추출)
│  └─ methods:
│     └─ save() → axios.post('/api.php', {
│           method: 'settings.update',
│           session_id: this.sessionId,
│           settings: this.settings
│        })
├─ Bootstrap 5.3 카드 레이아웃
│  ├─ 앱 버전 설정 (Android/iOS 버전, 빌드 번호)
│  ├─ 업소록 QR 이벤트 (토글 스위치)
│  └─ 이벤트 응모 (토글 스위치)
└─ page.footer.php (레거시 include)
```

### 인증 이중 구조

관리자 설정 페이지는 **레거시 SSR 인증**과 **v7 API 인증**이 모두 필요하다:

| 단계 | 시스템 | 코드 | 설명 |
|------|--------|------|------|
| 1. 페이지 로드 | 레거시 | `is_admin()` | SSR 단계에서 관리자 확인 (관리자 아니면 페이지 접근 차단) |
| 2. 설정 저장 | v7 | `SettingsController::requireAdmin()` | API 호출 시 관리자 확인 (ADMINS 배열 기반) |

> **중요**: `page.header.php`를 include한 후 `vendor/autoload.php`를 require해야 한다.
> `ROOT_DIR` 상수가 `boot.php`에서 정의되기 때문이다.

### session_id 전달 방식

관리자 페이지에서 v7 API 호출 시, 인증을 위해 `session_id`를 명시적으로 전달해야 한다:

```php
// PHP SSR
$currentSessionId = $_COOKIE[SESSION_ID] ?? '';
```

```javascript
// Vue.js
data() {
    return {
        sessionId: '<?= addslashes($currentSessionId) ?>',
    };
},
methods: {
    async save() {
        const res = await axios.post('/api.php', {
            method: 'settings.update',
            session_id: this.sessionId,  // 명시적 전달
            settings: this.settings
        });
    }
}
```

> `AuthService::getLoginUser()`는 쿠키의 `session_id`와 파라미터의 `session_id`를 모두 확인한다.
> 따라서 body에 명시적으로 포함하면 쿠키 전달 실패 시에도 인증이 가능하다.

## 다른 모듈에서 사용하기

### v7 모듈 (Service 레벨)

```php
use Philgo\Settings\SettingsService;

// QR 이벤트 활성화 확인
if (!SettingsService::isCompanyQrEventEnabled()) {
    throw new RuntimeException('QR 이벤트가 비활성화되어 있습니다.');
}

// 이벤트 응모 활성화 확인
if (!SettingsService::isEventEntryEnabled()) {
    throw new RuntimeException('이벤트 응모가 비활성화되어 있습니다.');
}

// 앱 버전 정보
$version = SettingsService::getAppVersion();
// ['android' => ['version' => '2.0.16', 'build_number' => 46], 'ios' => [...]]

// 관리자 목록 조회
$admins = SettingsService::getAdmins();
// ['admins' => ['OSXtfcfdJkcLBovnQAC6Q1WMa2x1', ...], 'chat_admin' => 'RaHIcr45pvPzYdcDIv6JoW8DnSH2']
```
```

### 기존 레거시 페이지

```php
require_once ROOT_DIR . '/vendor/autoload.php';
use Philgo\Settings\SettingsService;

$enabled = SettingsService::isCompanyQrEventEnabled();
```

## PEST 테스트

```bash
./vendor/bin/pest tests/Unit/SettingsTest.php
```

37개 테스트, 101개 assertions:
- SettingsEntity: fromArray, toArray, toBool, toJson
- SettingsRepository: CRUD, findByKeys, setMultiple, 기존 config 호환성
- SettingsService: getAll, get, update (권한 검증), getAppVersion, On/Off 토글, **getAdmins**
- SettingsController: get (전체/특정키/**admins**), update, appVersion

## 발견된 이슈 및 해결

### 이슈 1: 관리자 확인 로직 불일치 (v7 vs 레거시)

**증상**: 관리자로 로그인했음에도 `settings.update` API 호출 시 "관리자 권한이 필요합니다." 에러 발생.

**원인 분석**:

| 항목 | 잘못된 v7 구현 | 올바른 레거시 구현 |
|------|---------------|-------------------|
| **확인 방식** | `$user['admin'] === 'Y'` | `in_array($user['firebase_uid'], ADMINS)` |
| **데이터 소스** | `sf_member.admin` 컬럼 | `etc/app.config.php`의 `ADMINS` 상수 |
| **문제** | 대부분의 관리자 계정에서 `admin` 컬럼이 비어있음 | `ADMINS` 배열에 Firebase UID가 정확히 등록되어 있음 |

**근본 원인**: 필고 시스템에서 관리자 여부는 `sf_member` 테이블의 `admin` 컬럼이 아니라, `etc/app.config.php`의 `ADMINS` 상수 배열에 해당 사용자의 Firebase UID가 포함되어 있는지로 결정된다. v7 초기 구현에서 이를 잘못 구현하여 `$user['admin'] === 'Y'`로 체크했다.

**해결**: `SettingsController::isAdmin()` 메서드를 `ADMINS` 배열 기반으로 수정:

```php
// 수정 전 (잘못됨)
private function isAdmin(): bool
{
    $user = AuthService::getLoginUser();
    if ($user === null) return false;
    return ($user['admin'] ?? '') === 'Y';
}

// 수정 후 (올바름)
private function isAdmin(): bool
{
    $user = AuthService::getLoginUser();
    if ($user === null) return false;
    if (empty($user['firebase_uid'])) return false;
    return in_array($user['firebase_uid'], ADMINS);
}
```

**교훈**:
- v7 시스템에서 관리자 확인이 필요한 모든 Controller는 반드시 `ADMINS` 배열을 사용해야 한다.
- `sf_member.admin` 컬럼은 사용하면 안 된다.
- 레거시 `is_admin_user()` 함수(`lib/functions.php:239`)의 로직을 정확히 따라야 한다.

### 이슈 2: v7 API 인증 시 session_id 전달

**증상**: 관리자 설정 페이지에서 axios POST로 `api.php`를 호출할 때, 쿠키의 `session_id`만으로 인증이 불안정할 수 있다.

**해결**: PHP SSR 단계에서 쿠키의 `session_id`를 JavaScript 변수로 주입하고, axios POST body에 명시적으로 포함:

```php
// PHP SSR
$currentSessionId = $_COOKIE[SESSION_ID] ?? '';
```

```javascript
// Vue.js — axios POST body에 session_id 명시적 포함
const res = await axios.post('/api.php', {
    method: 'settings.update',
    session_id: this.sessionId,
    settings: this.settings
});
```

> `AuthService::getLoginUser()`는 쿠키의 `session_id`와 파라미터의 `session_id`를 모두 확인한다.
> 따라서 body에 명시적으로 포함하면 쿠키 전달 실패 시에도 인증이 가능하다.
