# v7 TODO — 앞으로 해야 할 작업 목록

## 목차

- [1. Firebase PHP SDK 버전 업데이트 (class T 충돌 해결)](#1-firebase-php-sdk-버전-업데이트-class-t-충돌-해결)

---

## 1. Firebase PHP SDK 버전 업데이트 (class T 충돌 해결)

### 상태: ✅ 해결 완료 (2026-03-08)

### 문제 요약

`composer update` 실행 시 `kreait/firebase-php`가 `7.16.1` → `7.24.1`로 업데이트되면서
v6 홈페이지의 **테스트 계정 로그인(A, B, C)이 실패**한다.

### 근본 원인

| 항목 | 내용 |
|------|------|
| **충돌 대상** | v6 번역 클래스 `class T` (`etc/translations/t.php`) |
| **충돌 상대** | Kreait Firebase SDK 7.21.0+에서 도입된 **Valinor** 라이브러리의 `@template T` 제네릭 타입 파라미터 |
| **충돌 메커니즘** | Valinor가 PHPDoc의 `@template T of object`를 분석할 때, PHP에 전역으로 정의된 `class T`를 실제 타입으로 해석하여 `SnakeCaseToCamelCaseConverter`의 `registerConverter()`가 올바르게 적용되지 않음 |
| **영향** | Firebase ServiceAccount JSON 파일의 `project_id` → `projectId` (snake_case → camelCase) 변환이 실패하여 "Could not map type Kreait\Firebase\ServiceAccount: projectId missing" 에러 발생 |

### 에러 메시지

```
Could not map type `Kreait\Firebase\ServiceAccount`:
- `projectId`: Value *missing* is not a valid non-empty string.
- `clientEmail`: Value *missing* is not a valid non-empty string.
- `privateKey`: Value *missing* is not a valid non-empty string.
```

### 영향 범위

- v6 홈페이지의 **모든 Firebase 인증 관련 기능** (로그인, 토큰 검증 등)
- v6 `verifyFirebaseToken()` → `firebase_auth_admin()` → `getFactory()` → `withServiceAccount()` 경로
- v7 API(`api.php`)는 `FirebaseService::verifyIdToken()`을 사용하므로 **v7도 동일하게 영향 받음**

### 해결 방법 (적용 완료)

`class T` → `class Trans`로 이름 변경하여 해결:

1. **`etc/translations/t.php`에서 `class T` → `class Trans` 변경**
   - `function load(): T` → `function load(): Trans`
   - `function params(): T` → `function params(): Trans`
   - `function t(): T` + `new T()` → `function t(): Trans` + `new Trans()`
   - `t()` 함수명과 `t()->키` 사용법은 **그대로 유지** (하위 호환성 100% 보장)

2. **검증 완료**
   - Firebase Factory/Auth 생성 성공
   - `t()` 함수 정상 동작 (`Trans` 클래스 반환)
   - v6 `login-success.php` ServiceAccount 에러 해소

### 버전 고정이 불가능한 이유

| 제약 | 설명 |
|------|------|
| **PHP 8.5 호환성** | Kreait 7.20.0 이하는 PHP `~8.4.0`까지만 지원 (로컬 PHP 8.5.3 비호환) |
| **보안 취약점** | Kreait 7.20.0 이하는 `firebase/php-jwt` v6.x 의존 → 보안 취약점 (PKSA-y2cr-5h3j-g3ys) |
| **Valinor 도입 시점** | 7.21.0에서 Valinor 도입, 7.22.0에서 PHP 8.5 지원 추가 → Valinor 없이 PHP 8.5 지원 버전은 존재하지 않음 |

### 관련 파일

| 파일 | 역할 |
|------|------|
| `etc/translations/t.php` | `class T` 정의 (번역 클래스) — **충돌 원인** |
| `lib/firebase/firebase.functions.php` | `getFactory()`, `firebase_auth_admin()` — 에러 발생 지점 |
| `composer.json` | `kreait/firebase-php` 버전 명시 |
| `composer.lock` | 실제 설치된 버전 (현재 7.24.1) |
| `vendor/kreait/firebase-php/src/Firebase/Valinor/Converter/SnakeCaseToCamelCaseConverter.php` | `@template T of object` — 충돌 상대 |

### 분석 일자

- 2026-03-08: 문제 발견 및 근본 원인 분석 완료
