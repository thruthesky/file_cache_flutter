# Settings API - 앱 설정 조회 (레거시 func.php)

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. API 엔드포인트](#3-api-엔드포인트)
  - [3.1 get_app_settings - 앱 설정 조회](#31-get_app_settings---앱-설정-조회)
- [4. 응답 데이터 구조 상세](#4-응답-데이터-구조-상세)
  - [4.1 bank_info - 은행 입금 정보](#41-bank_info---은행-입금-정보)
  - [4.2 point - 포인트 광고 설정](#42-point---포인트-광고-설정)
  - [4.3 admin_uids - 관리자 목록](#43-admin_uids---관리자-목록)
- [5. 파일 구조](#5-파일-구조)
  - [5.1 백엔드 (PHP)](#51-백엔드-php)
  - [5.2 Flutter 앱](#52-flutter-앱)
- [6. Flutter 앱 연동 상세](#6-flutter-앱-연동-상세)
  - [6.1 초기화 흐름](#61-초기화-흐름)
  - [6.2 PhilgoSetting 모델 계층](#62-philgosetting-모델-계층)
  - [6.3 PhilgoState 상태 관리](#63-philgostate-상태-관리)
  - [6.4 앱 내 사용 예시](#64-앱-내-사용-예시)
- [7. 테스트](#7-테스트)
- [8. 레거시 시스템과의 관계](#8-레거시-시스템과의-관계)

---

## 1. 개요

앱 설정(Settings) API는 **레거시 func.php 시스템**을 통해 호출되는 API이다.
Flutter 앱이 시작할 때 서버에서 앱 운영에 필요한 설정 정보를 한 번에 가져온다.

> **주의**: 이 API는 v7 시스템(`api.php`)이 아니라 **레거시 시스템(`func.php`)**을 통해 호출된다.
> `AllowedFunctions::get_app_settings()` → `get_app_settings()` 함수 호출 구조이다.
>
> v7 시스템의 Settings API는 → [v7-settings.md](../api/v7-settings.md) 참조.

- **API 엔트리포인트**: `func.php` (레거시)
- **함수명**: `get_app_settings`
- **함수 정의**: `lib/functions/app.config.functions.php`
- **설정 상수 정의**: `etc/app.config.php`
- **API 래핑 클래스**: `AllowedFunctions` (`lib/api/api.allowed_functions.php`)
- **인증**: 불필요 (공개 API)
- **Flutter 모델**: `PhilgoSetting` (`packages/philgo_api/lib/src/models/philgo.setting.model.dart`)

---

## 2. 아키텍처

```
[앱 설정 로딩 흐름 — 전체]

Flutter App
    │
    ▼ main() → PhilgoState() 생성자
    │
    ▼ PhilgoState._init()
    │  ├─ [병렬 1] FirebaseAuth.authStateChanges() 리스너 등록
    │  └─ [병렬 2] PhilgoService.instance.loadSetting()
    │              │
    │              ▼ apiCall('get_app_settings', PhilgoConfig.phpApiUrl)
    │              │
    │              ▼ POST https://philgo.com/func.php
    │              │  Content-Type: application/x-www-form-urlencoded
    │              │  Body: func=get_app_settings
    │              │
    │              ▼ PHP 서버 (func.php)
    │              │  ├─ AllowedFunctions::get_app_settings([])
    │              │  └─ get_app_settings() 함수 호출
    │              │     ├─ etc/app.config.php 상수 참조
    │              │     │  ├─ KB_NAME, KB_ACCOUNT_NO, KB_ACCOUNT_NAME
    │              │     │  ├─ BDO_NAME, BDO_ACCOUNT_NO, BDO_ACCOUNT_NAME
    │              │     │  ├─ POINT_ADVERTISEMENT_DAYS
    │              │     │  ├─ PointConfig::$advertising_post_categories
    │              │     │  ├─ PointConfig::$point_adv_cost_per_hour
    │              │     │  └─ ADMINS (Firebase UID 배열)
    │              │     └─ 배열 조합 → JSON 응답
    │              │
    │              ▼ JSON 응답 수신
    │              │
    │              ▼ PhilgoSetting.fromJson(json) → 모델 파싱
    │                 ├─ PhilgoSettingBankInfo.fromJson(json['bank_info'])
    │                 │  └─ BankAccount.fromJson() × N개 은행
    │                 ├─ PhilgoSettingPoint.fromJson(json['point'])
    │                 └─ adminUids = List<String>.from(json['admin_uids'])
    │
    ▼ PhilgoState.setting = loadedSetting
    │
    ▼ notifyListeners() → UI 갱신
```

---

## 3. API 엔드포인트

### 3.1 get_app_settings - 앱 설정 조회

| 항목 | 값 |
|------|-----|
| **함수명** | `get_app_settings` |
| **HTTP** | `GET https://philgo.com/func.php?func=get_app_settings` 또는 `POST` |
| **인증** | 불필요 |
| **파라미터** | 없음 |
| **응답** | `{ bank_info: {...}, point: {...}, admin_uids: [...] }` |

**curl 예시**:
```bash
# GET 방식
curl -s "https://philgo.com/func.php?func=get_app_settings"

# POST 방식
curl -s -X POST "https://philgo.com/func.php" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "func=get_app_settings"
```

**JavaScript 호출 예시**:
```javascript
const settings = await func('get_app_settings');
console.log(settings.admin_uids);                 // 관리자 Firebase UID 배열
console.log(settings.bank_info.kb.account_no);     // 국민은행 계좌번호
console.log(settings.point.adv_cost_per_hour);     // 시간당 광고 비용 (240)
```

**Flutter 호출 예시**:
```dart
final json = await apiCall(
  'get_app_settings',
  apiServerUrl: PhilgoConfig.phpApiUrl,  // https://philgo.com/func.php
);
final setting = PhilgoSetting.fromJson(json);
```

**전체 응답 형식**:
```json
{
    "bank_info": {
        "kb": {
            "name": "국민은행",
            "account_no": "655-601-04-1644-08",
            "account_name": "송재호"
        },
        "bdo": {
            "name": "BDO",
            "account_no": "008-018-022-138",
            "account_name": "JAEHO SONG"
        }
    },
    "point": {
        "advertising_post_categories": ["임대", "매매", "구인", "구직"],
        "advertisement_days": [3, 5, 7, 10, 15, 30, 60, 90, 180, 365],
        "adv_cost_per_hour": 240
    },
    "admin_uids": [
        "OSXtfcfdJkcLBovnQAC6Q1WMa2x1",
        "xG3UczB56qazt2fMLH97154Cda62",
        "RaHIcr45pvPzYdcDIv6JoW8DnSH2",
        "eo4kPM2cbia9nhuGrD7aZjzrwGu2"
    ]
}
```

---

## 4. 응답 데이터 구조 상세

### 4.1 bank_info - 은행 입금 정보

| 키 | 타입 | 설명 | 상수 출처 (`etc/app.config.php`) |
|-----|------|------|------|
| `bank_info.kb.name` | string | 국민은행 이름 | `KB_NAME` ("국민은행") |
| `bank_info.kb.account_no` | string | 국민은행 계좌번호 | `KB_ACCOUNT_NO` ("655-601-04-1644-08") |
| `bank_info.kb.account_name` | string | 국민은행 예금주 | `KB_ACCOUNT_NAME` ("송재호") |
| `bank_info.bdo.name` | string | BDO 은행 이름 | `BDO_NAME` ("BDO") |
| `bank_info.bdo.account_no` | string | BDO 계좌번호 | `BDO_ACCOUNT_NO` ("008-018-022-138") |
| `bank_info.bdo.account_name` | string | BDO 예금주 | `BDO_ACCOUNT_NAME` ("JAEHO SONG") |

> **용도**: 앱 내 입금 안내 화면에서 은행 정보 표시

### 4.2 point - 포인트 광고 설정

| 키 | 타입 | 설명 | 상수 출처 |
|-----|------|------|------|
| `point.advertising_post_categories` | string[] | 광고 가능 게시판 카테고리 목록 | `PointConfig::$advertising_post_categories` |
| `point.advertisement_days` | int[] | 광고 기간 옵션 (일 단위) | `POINT_ADVERTISEMENT_DAYS` |
| `point.adv_cost_per_hour` | int | 시간당 광고 비용 (포인트) | `PointConfig::$point_adv_cost_per_hour` (기본값: `240`) |

> **광고 비용 계산**: 일일 비용 = `adv_cost_per_hour × 24` = 5,760 포인트/일
> 예: 7일 광고 = 5,760 × 7 = 40,320 포인트

### 4.3 admin_uids - 관리자 목록

| 키 | 타입 | 설명 | 상수 출처 |
|-----|------|------|------|
| `admin_uids` | string[] | 관리자 Firebase UID 배열 | `ADMINS` (`etc/app.config.php`) |

> **용도**: 앱에서 현재 사용자가 관리자인지 판별.
> **관리자 확인 방식**: `ADMINS` 상수 배열에 사용자의 `firebase_uid`가 포함되어 있는지 확인.
> 자세한 관리자 확인 로직은 → [v7-settings.md의 관리자 확인 섹션](../api/v7-settings.md#관리자-확인-로직-isadmin) 참조.

---

## 5. 파일 구조

### 5.1 백엔드 (PHP)

```
/www/
├─ func.php                                     # 레거시 API 엔트리포인트
├─ etc/
│  └─ app.config.php                            # 설정 상수 정의
│     ├─ KB_NAME, KB_ACCOUNT_NO, KB_ACCOUNT_NAME
│     ├─ BDO_NAME, BDO_ACCOUNT_NO, BDO_ACCOUNT_NAME
│     ├─ ADMINS (Firebase UID 배열)
│     ├─ POINT_ADVERTISEMENT_DAYS
│     └─ class PointConfig
│        ├─ $advertising_post_categories
│        └─ $point_adv_cost_per_hour = 240
├─ lib/
│  ├─ api/
│  │  └─ api.allowed_functions.php              # AllowedFunctions::get_app_settings()
│  └─ functions/
│     └─ app.config.functions.php               # get_app_settings() 함수 정의
└─ tests/Unit/
   └─ ApiSettingTest.php                        # PEST 유닛 테스트 (14개 테스트)
```

### 5.2 Flutter 앱

```
philgo_app/
├─ lib/
│  ├─ main.dart                                 # 앱 진입점 — PhilgoState 초기화
│  └─ screens/
│     ├─ home/sections/forum.home.dart          # isAdmin 사용 — 글쓰기 제한
│     └─ post/widgets/
│        └─ post_view_option_menu.dart          # setting.point 사용 — 광고 비용 계산
└─ packages/philgo_api/lib/src/
   ├─ philgo.config.dart                        # PhilgoConfig.phpApiUrl (func.php URL)
   ├─ models/
   │  └─ philgo.setting.model.dart              # PhilgoSetting, PhilgoSettingBankInfo,
   │                                            #   PhilgoSettingPoint, BankAccount 모델
   ├─ services/
   │  └─ philgo.service.dart                    # PhilgoService.loadSetting()
   ├─ state/
   │  └─ philgo_state.dart                      # PhilgoState._init(), isAdmin
   └─ functions/
      └─ api.functions.dart                     # apiCall() — HTTP POST 요청
```

---

## 6. Flutter 앱 연동 상세

### 6.1 초기화 흐름

```
main()
  │
  ├─ WidgetsFlutterBinding.ensureInitialized()
  ├─ Firebase.initializeApp()
  │
  ▼ runApp(MultiProvider(providers: [PhilgoState()]))
      │
      ▼ PhilgoState() 생성자
          │
          ▼ _init() (async)
              ├─ [병렬 1] Firebase authStateChanges() 리스너 등록
              │  └─ firebaseUser != null → philgoApiUserVerify() → user 설정
              │
              └─ [병렬 2] PhilgoService.instance.loadSetting()
                 │
                 ▼ apiCall('get_app_settings', PhilgoConfig.phpApiUrl)
                 │  POST https://philgo.com/func.php
                 │  Body: func=get_app_settings
                 │
                 ▼ PhilgoSetting.fromJson(json)
                 │
                 ▼ PhilgoState.setting = loadedSetting
                 │
                 ▼ notifyListeners() → UI 갱신
```

**핵심 특징**:
- Firebase 인증 확인과 설정 로드가 **비동기 병렬** 실행
- 앱 실행 중 메모리에 유지 — 재시작 시 다시 로드 (캐싱 없음)
- `setting`이 null일 수 있으므로 사용 시 null 체크 필요

### 6.2 PhilgoSetting 모델 계층

```
PhilgoSetting                           ← 최상위 모델
├─ bankInfo: PhilgoSettingBankInfo       ← 은행 정보 컬렉션
│  └─ banks: Map<String, BankAccount>   ← 은행 코드 → 계좌 정보
│     ├─ 'kb' → BankAccount(name, accountNo, accountName)
│     └─ 'bdo' → BankAccount(name, accountNo, accountName)
├─ point: PhilgoSettingPoint            ← 포인트/광고 설정
│  ├─ advertisingPostCategories: List<String>
│  ├─ advertisementDays: List<int>
│  └─ advCostPerHour: int
└─ adminUids: List<String>              ← 관리자 Firebase UID 목록
```

### 6.3 PhilgoState 상태 관리

```dart
class PhilgoState extends ChangeNotifier {
  PhilgoSetting? setting;   // null → 로딩 중 또는 실패
  User? user;
  bool loading = true;

  /// 현재 사용자가 관리자인지 확인
  /// setting.adminUids에 user.uid가 포함되면 관리자
  bool get isAdmin {
    if (user == null || setting == null) return false;
    return setting!.adminUids.contains(user!.uid);
  }
}
```

### 6.4 앱 내 사용 예시

**1) 관리자 글쓰기 제한**:
```dart
final philgoState = PhilgoState.of(context);
if (philgoState.isAdmin) {
  // "운영자는 글을 작성할 수 없습니다." 알림 표시
  return;
}
```

**2) 포인트 광고 비용 계산**:
```dart
final state = PhilgoState.of(context, listen: false);
final setting = state.setting;
if (setting == null) return;

PointSelectionBottomSheet(
  pointSetting: setting.point,
  userPoints: state.user?.point ?? 0,
);
```

**3) 은행 정보 접근**:
```dart
final setting = PhilgoState.of(context).setting;
if (setting != null) {
  final kb = setting.bankInfo.kb;
  print('국민은행: ${kb?.accountNo}');
}
```

---

## 7. 테스트

**테스트 파일**: `tests/Unit/ApiSettingTest.php`
**실행 명령**: `./vendor/bin/pest tests/Unit/ApiSettingTest.php`

14개 테스트: 반환 타입, 필수 키 존재, 값 유효성, 배열/숫자 타입 검증.

---

## 8. 레거시 시스템과의 관계

| 항목 | 설명 |
|------|------|
| **API 시스템** | 레거시 `func.php` 시스템 (v7 `api.php` 아님) |
| **호출 경로** | `func.php` → `AllowedFunctions::get_app_settings()` → `get_app_settings()` |
| **설정 소스** | `etc/app.config.php`의 PHP 상수/클래스 (`ADMINS`, `PointConfig` 등) |
| **DB 의존성** | 없음 — 모든 설정이 PHP 상수/정적 변수에 하드코딩 |
| **v7 Settings와 차이** | v7은 DB(`sf_config`) 기반, 레거시는 PHP 상수 기반 |

> v7 시스템의 Settings 모듈 (DB 기반 동적 설정)은 → [v7-settings.md](../api/v7-settings.md) 참조.
