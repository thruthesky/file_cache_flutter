# PhilGo 앱 전화번호 로그인 시스템 (v7 API 연동 관점)

## 개요

PhilGo 앱은 **Firebase Phone Authentication** 기반의 전화번호 로그인을 사용합니다.
로그인 후 Firebase ID Token을 v7 API에 전달하여 서버 인증을 수행합니다.

이 문서는 v7 시스템 관점에서 전화번호 로그인과 API 인증의 연관관계를 다룹니다.
Flutter 앱 UI/위젯 상세는 → [philgo-skill 문서](../../philgo-skill/references/app/philgo-app-phone-login.md) 참조.

---

## 인증 아키텍처

```
[Flutter 앱]                          [v7 API 서버]
    │                                     │
    ├─ Firebase Phone Auth                │
    │   ├─ 전화번호 입력                    │
    │   ├─ SMS 코드 수신                   │
    │   └─ signInWithCredential()         │
    │                                     │
    ├─ Firebase ID Token 획득             │
    │   └─ getIdToken()                   │
    │                                     │
    └─ v7api() 호출 ──────────────────→  api.php
        (Authorization: Bearer <token>)    ├─ AuthService::getLoginUser()
                                           │   ├─ 세션 인증 (웹)
                                           │   └─ Firebase ID Token 검증 (앱)
                                           │       └─ FirebaseService::verifyIdToken()
                                           └─ Controller → Service → DB
```

---

## 전화번호 로그인 흐름 (Flutter 앱)

### 파일 구조

| 파일 | 역할 |
|------|------|
| `lib/screens/entry/entry.login.screen.dart` | 로그인 화면 |
| `packages/easy_phone_sign_in/lib/src/phone_sign_in.dart` | 핵심 위젯 |
| `packages/easy_phone_sign_in/lib/src/special_accounts.dart` | 리뷰/테스트 계정 |

### 전체 흐름

```
사용자 전화번호 입력
    ↓
onCompletePhoneNumber() — E.164 국제 형식으로 변환
    │  한국: '10' → '+82...'
    │  필리핀: '9' → '+63...'
    │  '+' 시작: 변환 없음
    ↓
onValidatePhoneNumber() — 전화번호 허용/차단 검증
    │  +82 (한국): 허용
    │  +63 (필리핀): 허용
    │  +1 (미국/캐나다): 화이트리스트만 허용
    │  그 외: 차단
    ↓
Firebase verifyPhoneNumber()
    ↓
SMS 코드 전송 → 사용자 코드 입력
    ↓
signInWithCredential()
    ↓
로그인 성공 → HomeScreen 이동
    ↓
이후 v7api() 호출 시 Firebase ID Token 자동 첨부
```

---

## 전화번호 검증 (화이트리스트)

### 검증 규칙

| 전화번호 유형 | 국가 코드 | 처리 |
|-------------|----------|------|
| 한국 | `+82` | 무조건 허용 |
| 필리핀 | `+63` | 무조건 허용 |
| 미국/캐나다 | `+1` | **화이트리스트에 등록된 번호만 허용** |
| 기타 모든 국가 | 그 외 | 차단 |

### +1 화이트리스트 (허용된 번호)

| 번호 | 용도 |
|------|------|
| `+11234567890` | 앱 리뷰 계정 (SpecialAccounts) |
| `+11111111111` | 테스트 계정 |
| `+12222222222` | 테스트 계정 |
| `+13333333333` | 테스트 계정 |
| `+14444444444` | 테스트 계정 |
| `+15555555555` | 테스트 계정 |
| `+16666666666` | 테스트 계정 |
| `+17777777777` | 테스트 계정 |

### 검증 코드 위치

`lib/screens/entry/entry.login.screen.dart` 의 `_validatePhoneNumber()` 메서드:

```dart
static String? _validatePhoneNumber(BuildContext context, String phoneNumber) {
  if (phoneNumber.startsWith('+82')) return null;  // 한국 허용
  if (phoneNumber.startsWith('+63')) return null;  // 필리핀 허용
  if (phoneNumber.startsWith('+1')) {
    const allowedNumbers = {
      '+11234567890', '+11111111111', '+12222222222', '+13333333333',
      '+14444444444', '+15555555555', '+16666666666', '+17777777777',
    };
    if (allowedNumbers.contains(phoneNumber)) return null;
    return Lo.of(context)!.phoneNumberNotAllowed;
  }
  return Lo.of(context)!.phoneNumberNotAllowed;
}
```

### 화이트리스트 변경 방법

`_validatePhoneNumber()`의 `allowedNumbers` Set을 수정합니다.

---

## v7 API 인증 연동

### Flutter 앱 → v7 API 인증 흐름

전화번호 로그인이 완료되면 `FirebaseAuth.instance.currentUser`가 설정됩니다.
이후 v7 API 호출 시 `v7api()` 함수가 자동으로 Firebase ID Token을 첨부합니다.

```dart
// lib/v7_api/v7_api.dart
final result = await v7api(
  module: 'user',
  action: 'profile',
);
// 내부적으로: Authorization: Bearer <firebase_id_token> 헤더 자동 첨부
```

### v7 서버 인증 처리

`Philgo\Utils\AuthService::getLoginUser()` 에서 2경로 인증:

1. **세션 인증 (웹)**: `$_SESSION` 기반 — 기존 레거시 웹에서 사용
2. **Firebase ID Token (앱)**: `Authorization: Bearer <token>` 헤더 — Flutter 앱에서 사용
   - `FirebaseService::verifyIdToken()` 으로 토큰 검증
   - 토큰에서 `uid`, `phone_number` 추출
   - `sf_member` 테이블에서 `firebase_uid` 로 사용자 조회

### 주요 DB 컬럼

`sf_member` 테이블에서 전화번호 로그인 관련 컬럼:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `firebase_uid` | varchar | Firebase Auth UID |
| `phone_number` | varchar | E.164 형식 전화번호 (예: `+821012345678`) |
| `session_id` | varchar | 세션 기반 인증용 ID |

---

## 특수 계정 (앱 리뷰/테스트)

### SpecialAccounts 설정

```dart
specialAccounts: const SpecialAccounts(
  reviewEmail: 'review@email.com',
  reviewPassword: '12345zB,*c',
  reviewPhoneNumber: '+11234567890',
  reviewSmsCode: '123456',
  emailLogin: true,
),
```

### 리뷰 계정 동작

리뷰 계정(`+11234567890`)은 실제 Firebase Phone Auth를 사용하지 않고,
Firebase Email Auth(`review@email.com`)로 대체 로그인합니다.
따라서 v7 서버에서는 이 계정의 `firebase_uid`가 이메일 인증 기반입니다.

---

## 다국어 메시지

전화번호 검증 실패 시 표시되는 다국어 에러 메시지:

| 언어 | 메시지 |
|------|--------|
| 영어 | This phone number is not allowed. Only Korean or Philippine phone numbers are supported. |
| 한국어 | 이 전화번호는 사용할 수 없습니다. 한국 또는 필리핀 전화번호만 지원합니다. |
| 일본어 | この電話番号は使用できません。韓国またはフィリピンの電話番号のみ対応しています。 |
| 중국어 | 此电话号码不可用。仅支持韩国或菲律宾电话号码。 |

i18n 키: `phoneNumberNotAllowed` (ARB 파일: `lib/l10n/app_*.arb`)
