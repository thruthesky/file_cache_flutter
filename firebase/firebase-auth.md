Firebase Auth 개발 관련 문서
====

## 개요

이 문서는 센터 프로젝트에서 Firebase Authentication을 사용할 때 필요한 설정과 에러 처리 방법을 설명합니다.

## Email Enumeration Protection 설정

### Email Enumeration Protection이란?

Firebase에서 제공하는 보안 기능으로, 악의적인 사용자가 이메일 주소를 통해 등록된 사용자를 열거(enumerate)하는 것을 방지합니다.

### 설정에 따른 에러 코드 차이

| 설정 상태 | 에러 코드 | 설명 |
|-----------|-----------|------|
| **Protection 켜짐** (기본값) | `invalid-credential` | 모호한 에러 코드 반환. 이메일 존재 여부를 알 수 없음 |
| **Protection 꺼짐** | `user-not-found` | 해당 이메일로 등록된 계정이 없음 |
| **Protection 꺼짐** | `wrong-password` | 이메일은 존재하지만 비밀번호가 틀림 |

### Firebase Console 설정 방법

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. 프로젝트 선택
3. **Authentication** 메뉴 클릭
4. **Settings** 탭 선택
5. **User actions** 섹션으로 이동
6. **Email enumeration protection** 토글을 끔 (Disable)

```
경로: Firebase Console → Authentication → Settings → User actions → Email enumeration protection
```

### 개발/프로덕션 환경 권장 설정

| 환경 | 권장 설정 | 이유 |
|------|-----------|------|
| **개발 환경** | Protection 끄기 | 구체적인 에러 메시지로 디버깅 용이 |
| **프로덕션 환경** | Protection 켜기 | 보안 강화 (이메일 열거 공격 방지) |

## 에러 처리

### handleError() 함수

센터 프로젝트에서는 `handleError()` 함수를 통해 Firebase Auth 에러를 일관되게 처리합니다.

**소스 코드 위치**: [lib/functions/util.functions.dart](lib/functions/util.functions.dart)

### 지원되는 Firebase Auth 에러 코드

| 에러 코드 | 번역 키 | 설명 |
|-----------|---------|------|
| `invalid-email` | `errorInvalidEmail` | 이메일 형식이 올바르지 않음 |
| `invalid-credential` | `errorInvalidCredential` | 로그인 정보가 올바르지 않음 (Email enumeration protection 활성화 시) |
| `user-disabled` | `errorUserDisabled` | 계정이 비활성화됨 |
| `user-not-found` | `errorUserNotFound` | 해당 이메일로 등록된 계정이 없음 |
| `wrong-password` | `errorWrongPassword` | 비밀번호가 틀림 |
| `email-already-in-use` | `errorEmailAlreadyInUse` | 이미 등록된 이메일 |
| `operation-not-allowed` | `errorOperationNotAllowed` | 허용되지 않은 작업 |
| `weak-password` | `errorWeakPassword` | 비밀번호가 너무 약함 |

### 사용 예시

```dart
try {
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} catch (e) {
  handleError(context, e);
}
```

## 관련 소스 코드

- 에러 처리 함수: [lib/functions/util.functions.dart](lib/functions/util.functions.dart)
- 다국어 번역 (한국어): [lib/l10n/app_ko.arb](lib/l10n/app_ko.arb)
- 다국어 번역 (영어): [lib/l10n/app_en.arb](lib/l10n/app_en.arb)
- 다국어 번역 (일본어): [lib/l10n/app_ja.arb](lib/l10n/app_ja.arb)
- 다국어 번역 (중국어): [lib/l10n/app_zh.arb](lib/l10n/app_zh.arb)

## 참고 자료

- [Firebase Authentication 공식 문서](https://firebase.google.com/docs/auth)
- [Email enumeration protection 공식 문서](https://cloud.google.com/identity-platform/docs/admin/email-enumeration-protection)
