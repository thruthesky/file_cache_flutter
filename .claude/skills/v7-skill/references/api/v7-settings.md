# v7 Settings API 문서

## 개요

시스템 설정을 관리하는 v7 API 모듈이다.
기존 `sf_config` 테이블(key-value)을 사용하여 앱 버전, 이벤트 On/Off 등의 설정을 저장/조회한다.
기존 `config_get()`/`config_set()` 함수(lib/config.functions.php)와 100% 호환된다.

> **레거시 앱 설정 API** (`func.php` 기반 `get_app_settings`)는 → [v7-app-settings.md](../app/v7-app-settings.md) 참조.

## 목차

- [아키텍처](#아키텍처)
- [설정 키 정의](#설정-키-정의)
- [포인트 이벤트 기간 설정](#포인트-이벤트-기간-설정)
- [API 엔드포인트](#api-엔드포인트)
  - [settings.get](#settingsget)
  - [settings.get 관리자 목록 조회](#settingsget-관리자-목록-조회)
  - [settings.update](#settingsupdate)
  - [settings.appVersion](#settingsappversion)
- [관리자 확인 로직 (isAdmin)](#관리자-확인-로직-isadmin)
- [관리자 페이지](#관리자-페이지)
- [다른 모듈에서 사용하기](#다른-모듈에서-사용하기)
- [Flutter 앱 연동 (settings.get 전체 응답)](#flutter-앱-연동-settingsget-전체-응답)
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
| `event_spin_weights` | `KEY_EVENT_SPIN_WEIGHTS` | JSON | `'{"0":379,"1":80,...,"8":2}'` | 스피닝 휠 섹션별 weight (합계 1000) |
| `event_starbucks_24h_weight` | `KEY_EVENT_STARBUCKS_24H_WEIGHT` | int | `'1'` | 24시간 이내 스타벅스 재당첨 weight |
| `event_spin_cost` | `KEY_EVENT_SPIN_COST` | int | `'200'` | 스피닝 휠 1회 참가비 (포인트) |
| `point_event_dates` | `KEY_POINT_EVENT_DATES` | JSON | `'[]'` | 포인트 이벤트 기간 목록 (DB 기반 관리) |

## 포인트 이벤트 기간 설정

### 개요

포인트 이벤트 기간을 DB(`sf_config` 테이블)에서 JSON 배열로 관리한다.
v6의 `PointConfig::$point_event_dates` 하드코딩 방식에서 전환되어, 관리자 페이지(`/admin/point-event`)에서 실시간으로 추가/삭제할 수 있다.

### 설정 키: point_event_dates

JSON 배열 형태로 이벤트 기간 목록을 저장한다. 각 항목은 `start`(시작일)와 `end`(종료일) 필드를 가진 객체이다.

**JSON 형식:**
```json
[
  {"start": 20260107, "end": 20260111},
  {"start": 20260210, "end": 20260220},
  {"start": 20260301, "end": 20260311}
]
```

- 날짜는 `YYYYMMDD` 정수 형식
- 추가 시 `start` 기준 오름차순 자동 정렬

### 핵심 Service 메서드

```php
// SettingsService — 포인트 이벤트 기간 관리
SettingsService::getPointEventDates(): array
// DB에서 JSON 파싱 → [['start' => 20260107, 'end' => 20260111], ...], 잘못된 JSON이면 빈 배열

SettingsService::addPointEventDate(int $start, int $end): void
// 이벤트 기간 추가 후 start 기준 오름차순 자동 정렬

SettingsService::deletePointEventDate(int $index): void
// 인덱스 기반 이벤트 기간 삭제

SettingsService::isInPointEventDate(?int $Ymd = null): bool
// 오늘(또는 지정 날짜)이 이벤트 기간인지 DB 기반 판별
```

### 관리자 페이지

`/admin/point-event` 경로에서 이벤트 기간을 관리할 수 있다.
상세 → [web/v7-admin.md](../web/v7-admin.md) 20장 참조

### 관련 문서

- 포인트 이벤트 전체 → [v7-point.md](../v7-point.md) 9장
- 이벤트 통합 개요 → [event/v7-event-overview.md](../event/v7-event-overview.md)

## API 엔드포인트

### settings.get

설정 조회 (공개 API). 인증 불필요.
전체 조회 시 관리자 목록(admins), 스피닝 휠 구조화 정보(spin_sections), 게임 참가비(spin_cost),
스타벅스 쿠폰 잔여 수량(available_starbucks_coupons)도 함께 반환한다.

> **Flutter 앱 연동**: Flutter 앱은 실행 시 `v7api('settings.get')`을 호출하여 이 전체 응답을 받아 사용한다.
> 상세 → [Flutter 앱 연동](#flutter-앱-연동-settingsget-전체-응답) 참조.

**요청:**
```
GET /api.php?method=settings.get
GET /api.php?method=settings.get&key=app_version_android
GET /api.php?method=settings.get&key=admins
```

**응답 (전체 - 모든 부가 정보 포함):**
```json
{
  "app_version_android": "2.0.16",
  "app_version_android_build": "46",
  "app_version_ios": "2.0.16",
  "app_version_ios_build": "46",
  "company_qr_event_enabled": "Y",
  "event_entry_enabled": "Y",
  "event_spin_weights": "{\"0\":379,\"1\":80,\"2\":70,\"3\":60,\"4\":50,\"5\":40,\"6\":15,\"7\":4,\"8\":2}",
  "event_starbucks_24h_weight": "1",
  "event_spin_cost": "200",
  "admins": {
    "admins": [
      "OSXtfcfdJkcLBovnQAC6Q1WMa2x1",
      "xG3UczB56qazt2fMLH97154Cda62"
    ],
    "chat_admin": "RaHIcr45pvPzYdcDIv6JoW8DnSH2"
  },
  "available_starbucks_coupons": 5,
  "spin_sections": [
    {"section_index": 0, "points": 50, "weight": 379, "prize_type": "point"},
    {"section_index": 1, "points": 100, "weight": 80, "prize_type": "point"},
    {"section_index": 2, "points": 200, "weight": 70, "prize_type": "point"},
    {"section_index": 3, "points": 300, "weight": 60, "prize_type": "point"},
    {"section_index": 4, "points": 400, "weight": 50, "prize_type": "point"},
    {"section_index": 5, "points": 500, "weight": 40, "prize_type": "point"},
    {"section_index": 6, "points": 1000, "weight": 15, "prize_type": "point"},
    {"section_index": 7, "points": 2000, "weight": 4, "prize_type": "point"},
    {"section_index": 8, "points": 0, "weight": 2, "prize_type": "starbucks"},
    {"section_index": 9, "points": 0, "weight": 300, "prize_type": "miss"}
  ],
  "spin_cost": 200
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

## 스피닝 휠 확률 설정

### 개요

관리자가 실시간으로 스피닝 휠의 당첨 확률을 조정할 수 있다.
`sf_config` 테이블에 JSON 형태로 저장하며, `SettingsService`와 `EventService`가 연동한다.

### 설정 키 상세

#### event_spin_weights (섹션별 weight)

10개 섹션의 weight를 JSON 형태로 저장한다. 합계가 1000이 되어야 한다 (0.1% 단위 확률).

| 섹션 | 인덱스 | 포인트 | 기본 weight | 확률 |
|------|--------|--------|-------------|------|
| 50P | 0 | 50 | 379 | 37.9% |
| 100P | 1 | 100 | 80 | 8.0% |
| 200P | 2 | 200 | 70 | 7.0% |
| 300P | 3 | 300 | 60 | 6.0% |
| 400P | 4 | 400 | 50 | 5.0% |
| 500P | 5 | 500 | 40 | 4.0% |
| 1000P | 6 | 1000 | 15 | 1.5% |
| 2000P | 7 | 2000 | 4 | 0.4% |
| 스타벅스 | 8 | - | 2 | 0.2% |
| 꽝 | 9 | 0 | 자동 계산 | 나머지 |

- 섹션 0~8의 weight 합이 1000을 초과하면 꽝(섹션 9)의 weight가 0이 된다.
- 꽝 weight = `max(0, 1000 - sum(섹션 0~8))`

**JSON 형식:**
```json
{"0":379,"1":80,"2":70,"3":60,"4":50,"5":40,"6":15,"7":4,"8":2}
```

#### event_spin_cost (1회 참가비)

스피닝 휠을 한 번 돌릴 때 차감되는 포인트를 설정한다.
기본값은 `200` (200P)이다. 관리자가 실시간으로 변경 가능하다.

**동작 흐름:**
1. `EventService::spin()` 호출 시 `SettingsService::getSpinCost()`로 현재 참가비 조회
2. 사용자 잔액이 참가비 미만이면 게임 진행 불가 (`RuntimeException`)
3. `PointLogService::changePoints()`로 참가비 차감
4. `event_spin_history.points_cost`에 차감된 금액 기록

> **주의**: `EventService::SPIN_COST = 200` 상수는 기본값 참조용으로 유지되지만,
> 실제 런타임에서는 DB 설정(`event_spin_cost`)을 사용한다.

#### event_starbucks_24h_weight (24시간 재당첨 weight)

24시간 이내에 스타벅스 쿠폰에 당첨된 사용자의 재당첨 확률을 제어한다.
기본값은 `1` (0.1%)이며, `0`으로 설정하면 24시간 이내 재당첨이 불가능하다.

**동작 흐름:**
1. `EventService::hasWonStarbucksWithin24Hours($idxMember)` — `event_spin_history` 테이블에서 24시간 이내 `prize_type='starbucks'` 확인
2. 해당하면 `sections[8]['weight']`를 `event_starbucks_24h_weight` 값으로 교체
3. 꽝 weight가 자동으로 재계산됨

### API 호출 예시

**스피닝 휠 확률 업데이트:**
```
POST /api.php
{
  "method": "settings.update",
  "session_id": "xxx",
  "settings": {
    "event_spin_weights": "{\"0\":400,\"1\":80,\"2\":70,\"3\":60,\"4\":50,\"5\":40,\"6\":15,\"7\":4,\"8\":1}",
    "event_starbucks_24h_weight": "0",
    "event_spin_cost": "300"
  }
}
```

**확률 조회 (settings.get 전체 응답에 포함):**
```json
{
  "event_spin_weights": "{\"0\":379,\"1\":80,\"2\":70,\"3\":60,\"4\":50,\"5\":40,\"6\":15,\"7\":4,\"8\":2}",
  "event_starbucks_24h_weight": "1",
  "event_spin_cost": "200",
  ...
}
```

### 핵심 Service 메서드

```php
// SettingsService
SettingsService::getSpinWeights(): array
// DB에서 JSON 파싱 → ['0' => 379, '1' => 80, ...], 잘못된 JSON이면 기본값 폴백

SettingsService::getStarbucks24hWeight(): int
// DB에서 정수값 반환, 기본값 1

SettingsService::getSpinCost(): int
// DB에서 1회 참가비 조회, 기본값 200

// EventService
EventService::getSections(?int $idxMember = null): array
// DB weight 읽기 + 24시간 재당첨 로직 적용 → 10개 섹션 배열

EventService::hasWonStarbucksWithin24Hours(int $idxMember): bool
// event_spin_history 테이블에서 24시간 이내 스타벅스 당첨 확인

EventService::calculateSpinResult(bool $hasStarbucksCoupon, ?int $idxMember = null): array
// 확률 계산 → 당첨 결과 반환
```

### 관리자 UI

`page/admin/system-settings.php`에 다음 섹션이 추가되어 있다:

1. **스피닝 휠 확률 설정 카드** — 섹션별 weight 입력 (숫자 입력란)
2. **회전판 돌리기 일회 차감 비용** — 1회 참가비 포인트 입력란 (기본값 200P)
3. **24시간 재당첨 확률** — 별도 입력란
4. **꽝 자동 계산** — `1000 - 섹션합`으로 실시간 표시
5. **저장 버튼** — `settings.update` API 호출 (`event_spin_cost` 포함)

### PEST 테스트

스피닝 휠 확률 관련 테스트 (SettingsTest.php):

- SettingsService 테스트 (15개):
  - MANAGED_KEYS 포함 확인 (spin_weights, starbucks_24h_weight, spin_cost)
  - DEFAULTS 기본값 검증
  - getSpinWeights() — 기본값/DB값/잘못된 JSON 폴백
  - getStarbucks24hWeight() — 기본값/DB값
  - getSpinCost() — 기본값 200/DB값 반영
  - update() 라운드트립 (spin_weights + spin_cost)

- EventService 테스트 (15개):
  - getSections() — 기본 weight/DB weight/10개 섹션 구조/weight 비음수/prize_type/section_points
  - hasWonStarbucksWithin24Hours() — 이력없음/24시간이내/24시간이전
  - getSections() 24시간 재당첨 — 기본값/DB값 적용
  - calculateSpinResult() — 결과 구조/쿠폰없음/24시간 weight=0
  - 상수 검증/DB 변경 즉시 반영

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

## 관리자 목록 조회 (getAdmins)

### 핵심 로직

`SettingsService::getAdmins()`는 `etc/app.config.php`의 `ADMINS` 상수(Firebase UID 배열)와
채팅 관리자 UID를 반환한다. 기존 레거시 `get_admins()` 함수와 동일한 형태이다.
DB 기반이 아닌 PHP 상수 기반이므로 `settings.update`로 변경할 수 없다.

### 핵심 소스코드

```php
// lib/settings/SettingsService.php

/**
 * 관리자 목록을 반환한다.
 *
 * etc/app.config.php의 ADMINS 상수(Firebase UID 배열)와
 * 채팅 관리자 UID를 포함한 배열을 반환한다.
 * 기존 get_admins() 함수와 동일한 형태이다.
 *
 * @return array ['admins' => string[], 'chat_admin' => string]
 */
public static function getAdmins(): array
{
    return [
        'admins' => \ADMINS,
        'chat_admin' => \get_chat_admin_firebase_uid(),
    ];
}
```

### Controller에서의 전체 설정 반환 로직

```php
// lib/settings/SettingsController.php — get() 메서드

use Philgo\Event\EventCouponService;
use Philgo\Event\EventService;

public function get(array $input): array
{
    $key = $input['key'] ?? '';

    // 관리자 목록 조회
    if ($key === 'admins') {
        return SettingsService::getAdmins();
    }

    // 특정 키 조회
    if (!empty($key)) {
        return [
            'key' => $key,
            'value' => SettingsService::getValue($key),
        ];
    }

    // 전체 설정 조회
    $all = SettingsService::getAll();

    // 관리자 목록
    $all['admins'] = SettingsService::getAdmins();

    // 스타벅스 쿠폰 잔여 수량
    $all['available_starbucks_coupons'] = EventCouponService::getAvailableCount('starbucks');

    // 스피닝 휠 구조화 정보 (Flutter 앱에서 바로 사용 가능)
    $all['spin_sections'] = EventService::getSections();
    $all['spin_cost'] = EventService::SPIN_COST;

    return $all;
}
```

> **주의: 네임스페이스 전역 참조**
> `Philgo\Settings` 네임스페이스 내에서 전역 상수/함수를 참조할 때는
> 반드시 `\ADMINS`, `\get_chat_admin_firebase_uid()`와 같이 백슬래시(`\`)를 붙여
> 전역 네임스페이스를 명시해야 한다. PHP 8에서 네임스페이스 내 미정의 상수 참조 시 에러가 발생한다.

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
│  ├─ 이벤트 응모 (토글 스위치)
│  └─ 스피닝 휠 확률 설정 (섹션별 weight + 24시간 재당첨 weight)
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

## Flutter 앱 연동 (settings.get 전체 응답)

### 개요

Flutter 앱은 실행 시 `v7api('settings.get')`을 호출하여 모든 설정을 한 번에 가져온다.
전체 조회 응답에는 기본 설정 키-값 외에 다음 부가 정보가 포함된다:

| 필드 | 타입 | 설명 |
|------|------|------|
| `admins` | object | 관리자 목록 (`admins`: Firebase UID 배열, `chat_admin`: 채팅 관리자 UID) |
| `available_starbucks_coupons` | int | 사용 가능한 스타벅스 쿠폰 잔여 수량 |
| `spin_sections` | array | 스피닝 휠 10개 섹션 구조화 배열 (아래 참조) |
| `spin_cost` | int | 스피닝 휠 게임 참가비 (포인트, DB 설정 `event_spin_cost`에서 조회, 기본 200) |

### spin_sections 구조

`spin_sections`는 10개 섹션 객체의 배열이다. 각 섹션은 다음 필드를 포함한다:

| 필드 | 타입 | 설명 |
|------|------|------|
| `section_index` | int | 섹션 인덱스 (0~9) |
| `points` | int | 당첨 포인트 (꽝/스타벅스는 0) |
| `weight` | int | 당첨 가중치 (전체 합계 1000) |
| `prize_type` | string | 상품 유형: `"point"`, `"starbucks"`, `"miss"` |

- 섹션 0~7: 포인트 당첨 (`prize_type: "point"`)
- 섹션 8: 스타벅스 쿠폰 (`prize_type: "starbucks"`)
- 섹션 9: 꽝 (`prize_type: "miss"`, weight = `1000 - sum(섹션 0~8)`)

### Flutter 사용 예시

```dart
// Flutter 앱 시작 시 설정 로드
final settings = await v7api('settings.get');

// 앱 버전 확인
final androidVersion = settings['app_version_android'];

// 관리자 확인
final admins = settings['admins']['admins'] as List;
final isAdmin = admins.contains(currentUser.firebaseUid);

// 스피닝 휠 정보
final sections = settings['spin_sections'] as List;
final spinCost = settings['spin_cost'] as int;
final availableCoupons = settings['available_starbucks_coupons'] as int;

// 이벤트 활성화 확인
final eventEnabled = settings['event_entry_enabled'] == 'Y';
```

### 생성 소스

- `SettingsController::get()` — [lib/settings/SettingsController.php](../../../lib/settings/SettingsController.php)
- `EventService::getSections()` — [lib/event/EventService.php](../../../lib/event/EventService.php)
- `EventCouponService::getAvailableCount()` — [lib/event/EventCouponService.php](../../../lib/event/EventCouponService.php)

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

73개 테스트, 328 assertions:
- SettingsEntity: fromArray, toArray, toBool, toJson
- SettingsRepository: CRUD, findByKeys, setMultiple, 기존 config 호환성
- SettingsService: getAll, get, update (권한 검증), getAppVersion, On/Off 토글, **getAdmins**
- SettingsController: get (전체/특정키/**admins**), update, appVersion, **spin weights/24h weight 포함 확인**
- **SettingsController::get() 전체 응답 검증** (3개 추가):
  - `spin_sections` — 10개 섹션, 구조화 필드 검증, weight 합계 1000
  - `spin_cost` — 200 포인트 확인
  - `available_starbucks_coupons` — 0 이상의 정수 확인
- **스피닝 휠 확률 - SettingsService** (10개): MANAGED_KEYS, DEFAULTS, getSpinWeights, getStarbucks24hWeight, update 라운드트립
- **스피닝 휠 확률 - EventService** (15개): getSections, hasWonStarbucksWithin24Hours, calculateSpinResult, 24시간 재당첨 로직, DB 즉시 반영

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
