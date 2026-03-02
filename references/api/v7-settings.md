# v7 Settings API 문서

## 개요

시스템 설정을 관리하는 v7 API 모듈이다.
기존 `sf_config` 테이블(key-value)을 사용하여 앱 버전, 이벤트 On/Off 등의 설정을 저장/조회한다.
기존 `config_get()`/`config_set()` 함수(lib/config.functions.php)와 100% 호환된다.

## 목차

- [아키텍처](#아키텍처)
- [설정 키 정의](#설정-키-정의)
- [API 엔드포인트](#api-엔드포인트)
  - [settings.get](#settingsget)
  - [settings.update](#settingsupdate)
  - [settings.appVersion](#settingsappversion)
- [관리자 페이지](#관리자-페이지)
- [다른 모듈에서 사용하기](#다른-모듈에서-사용하기)
- [PEST 테스트](#pest-테스트)

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

**요청:**
```
GET /api.php?method=settings.get
GET /api.php?method=settings.get&key=app_version_android
```

**응답 (전체):**
```json
{
  "app_version_android": "2.0.16",
  "app_version_android_build": "46",
  "app_version_ios": "2.0.16",
  "app_version_ios_build": "46",
  "company_qr_event_enabled": "Y",
  "event_entry_enabled": "Y"
}
```

**응답 (특정 키):**
```json
{
  "key": "app_version_android",
  "value": "2.0.16"
}
```

### settings.update

설정 업데이트 (관리자 전용). 인증 필수.

**요청:**
```
POST /api.php
Content-Type: application/json

{
  "method": "settings.update",
  "settings": {
    "app_version_android": "2.0.17",
    "app_version_android_build": "47",
    "company_qr_event_enabled": "N"
  }
}
```

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

## 관리자 페이지

- **URL**: `https://local.philgo.com/page/admin/system-settings.php`
- **메뉴 위치**: 관리자 대시보드 → 메뉴 → "설정"
- **기능**: 앱 버전 편집, 업소록 QR 이벤트 토글, 이벤트 응모 토글
- **기술**: Vue.js Options API + axios + api.php AJAX 호출
- **다국어**: `inject_admin_system_settings_language()` 함수 (ko, en, ja, zh)

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

34개 테스트, 86개 assertions:
- SettingsEntity: fromArray, toArray, toBool, toJson
- SettingsRepository: CRUD, findByKeys, setMultiple, 기존 config 호환성
- SettingsService: getAll, get, update (권한 검증), getAppVersion, On/Off 토글
- SettingsController: get, update, appVersion
