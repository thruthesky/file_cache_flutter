# 아이디 합치기 (ID Merge) v2

v7 소셜 로그인 계정을 v6 전화번호 계정으로 병합하는 기능이다. v2 방식은 `sf_member.varchar_1`에 `id_merged_to:<v6 firebase_uid>` 마커만 저장하고, 이후 소셜 로그인 시 Custom Token을 발급하여 v6 계정으로 자동 전환한다.

---

## 목차

1. [핵심 개념](#1-핵심-개념)
2. [전체 흐름도](#2-전체-흐름도)
3. [DB 구조](#3-db-구조)
4. [API 엔드포인트](#4-api-엔드포인트)
5. [백엔드 핵심 소스코드](#5-백엔드-핵심-소스코드)
6. [프론트엔드 핵심 소스코드](#6-프론트엔드-핵심-소스코드)
7. [소셜 로그인 complete 페이지 merged 분기](#7-소셜-로그인-complete-페이지-merged-분기)
8. [되돌리기](#8-되돌리기)
9. [파일 목록](#9-파일-목록)
10. [엣지 케이스](#10-엣지-케이스)

---

## 1. 핵심 개념

### 1.1 설계 원리

- Firebase의 Provider link 기능을 **사용하지 않는다**
- 별도 테이블을 **생성하지 않는다**
- v6 계정의 `firebase_uid`를 **변경하지 않는다** → RTDB 채팅 데이터 이전 불필요
- `sf_member.varchar_1` 필드에 병합 마커만 저장한다
- 소셜 로그인 시 Custom Token을 발급하여 v6 계정으로 동적 전환한다
- SMS 인증은 Firebase Phone Auth를 사용한다 (별도 SMS API 불필요)

### 1.2 병합 전후 DB 상태

```
병합 전:
┌────────┬───────────────┬──────────────────┬───────────────┐
│  idx   │ firebase_uid  │ login_provider   │ varchar_1     │
├────────┼───────────────┼──────────────────┼───────────────┤
│  1000  │ BBB           │ (NULL)           │ (비어있음)     │  ← v6 전화번호 계정
│  2000  │ kakao:12345   │ kakaotalk        │ (비어있음)     │  ← v7 소셜 계정
└────────┴───────────────┴──────────────────┴───────────────┘

병합 후:
┌────────┬───────────────┬──────────────────┬──────────────────────┐
│  idx   │ firebase_uid  │ login_provider   │ varchar_1            │
├────────┼───────────────┼──────────────────┼──────────────────────┤
│  1000  │ BBB           │ (NULL)           │ (비어있음)            │  ← v6 변경 없음
│  2000  │ kakao:12345   │ kakaotalk        │ id_merged_to:BBB     │  ← varchar_1만 변경
└────────┴───────────────┴──────────────────┴──────────────────────┘

+ sf_post_data: idx_member가 2000 → 1000으로 이전됨
```

### 1.3 이후 소셜 로그인 동작

1. 카카오 로그인 → `firebase_uid = kakao:12345`로 sf_member 조회
2. `varchar_1 = 'id_merged_to:BBB'` 발견
3. PHP에서 `createCustomToken('BBB')` 발급 → 클라이언트에 반환
4. 클라이언트에서 `signInWithCustomToken(custom_token)` → v6 UID(BBB)로 Firebase 인증
5. v6 계정으로 `socialLogin()` 재호출 → 정상 로그인 (세션 생성)

**무한 루프 방지**: v6 계정(BBB)의 `varchar_1`에는 `id_merged_to:` 접두사가 없으므로 Custom Token 재발급 루프에 빠지지 않는다.

---

## 2. 전체 흐름도

### 2.1 아이디 합치기 실행 흐름

```
[클라이언트]                    [PHP 서버]                    [Firebase Auth]
    │                              │                              │
    │  1. 소셜 로그인 상태           │                              │
    │                              │                              │
    │  2. 전화번호 입력              │                              │
    │  ─────────────────────────>  │                              │
    │  v7api('user.findV6Account') │                              │
    │                              │  3. sf_member 전화번호 검색    │
    │                              │     → 없으면 에러             │
    │                              │     → 있으면 미리보기 반환     │
    │  <─────────────────────────  │                              │
    │  "홍길동님(1,234P) 맞나요?"   │                              │
    │                              │                              │
    │  4. Firebase Phone Auth      │                              │
    │     SMS 전송 + 코드 입력      │                              │
    │     → phone_id_token 획득    │                              │
    │                              │                              │
    │  5. 합치기 실행               │                              │
    │  ─────────────────────────>  │                              │
    │  v7api('user.mergeAccount',  │                              │
    │   { phone_id_token })        │                              │
    │                              │  6. Admin SDK로 token 검증    │
    │                              │     → 전화번호 추출            │
    │                              │     → v6 계정 검색            │
    │                              │  7. varchar_1 저장            │
    │                              │     'id_merged_to:<v6 UID>'  │
    │                              │  8. 게시글 소유권 이전         │
    │  <─────────────────────────  │                              │
    │  9. 자동 로그아웃              │                              │
    │     firebase.auth().signOut() │                              │
```

### 2.2 이후 소셜 로그인 자동 전환 흐름

```
[클라이언트]                    [PHP 서버]                    [Firebase Auth]
    │                              │                              │
    │  1. 소셜 로그인               │                              │
    │  → id_token 획득             │                              │
    │                              │                              │
    │  2. v7api('user.socialLogin') │                              │
    │  ─────────────────────────>  │                              │
    │                              │  3. varchar_1 확인            │
    │                              │     = 'id_merged_to:BBB'     │
    │                              │  4. createCustomToken('BBB') │
    │  <─────────────────────────  │                              │
    │  { status:'merged',          │                              │
    │    custom_token:'...' }      │                              │
    │                              │                              │
    │  5. signOut() → signInWithCustomToken()                      │
    │  → UID: BBB (v6 계정)                                       │
    │                              │                              │
    │  6. v7api('user.socialLogin') │                              │
    │  ─────────────────────────>  │                              │
    │                              │  7. BBB → varchar_1 없음     │
    │                              │     → 정상 로그인 + 세션 생성  │
    │  <─────────────────────────  │                              │
    │  → v6 계정으로 로그인 완료    │                              │
```

---

## 3. DB 구조

| 테이블 | 컬럼 | 용도 |
|--------|------|------|
| `sf_member` | `varchar_1` | `id_merged_to:<v6 firebase_uid>` 저장 |
| `sf_post_data` | `idx_member` | v7 → v6으로 소유권 이전 |

```sql
-- 병합 실행 (트랜잭션)
UPDATE sf_member SET varchar_1 = 'id_merged_to:{v6FirebaseUid}' WHERE idx = {v7Idx};
UPDATE sf_post_data SET idx_member = {v6Idx} WHERE idx_member = {v7Idx};
```

---

## 4. API 엔드포인트

### 4.1 `user.findV6Account`

```
POST /api.php
{ method: 'user.findV6Account', phone_number: '+821012345678' }

성공: { nickname: '홍길동', point: 1234, stamp: '1743660884' }
실패: { success: false, message: '해당 전화번호로 가입된 기존 계정이 없습니다.' }
```

### 4.2 `user.mergeAccount`

```
POST /api.php
{ method: 'user.mergeAccount', phone_id_token: '<Firebase Phone Auth ID Token>' }

성공: { status: 'merged', message: '아이디 합치기가 완료되었습니다.' }
실패: { success: false, message: '에러 메시지' }
```

### 4.3 `user.socialLogin` (병합 감지 시)

```
POST /api.php
{ method: 'user.socialLogin', id_token: '<Firebase ID Token>' }

일반: UserEntity { idx, nickname, firebase_uid, ... }
병합: { status: 'merged', custom_token: '<Firebase Custom Token>' }
```

---

## 5. 백엔드 핵심 소스코드

### 5.1 socialLogin() 병합 감지 — `lib/user/UserService.php`

```php
public static function socialLogin(array $input): UserEntity|array
{
    // ... Firebase ID Token 검증 ...
    $firebaseUid = $claims['uid'];
    $existingRaw = UserRepository::findRawByFirebaseUid($firebaseUid);

    // ★ 아이디 합치기 확인: varchar_1에 id_merged_to:가 있으면 Custom Token 발급
    if ($existingRaw !== false) {
        $varchar1 = trim((string)($existingRaw['varchar_1'] ?? ''));
        if (str_starts_with($varchar1, 'id_merged_to:')) {
            $v6FirebaseUid = substr($varchar1, strlen('id_merged_to:'));
            $auth = FirebaseService::getAuth();
            $customToken = $auth->createCustomToken($v6FirebaseUid);
            return [
                'status' => 'merged',
                'custom_token' => $customToken->toString(),
            ];
            // 세션 생성하지 않음! 클라이언트가 Custom Token으로 재로그인해야 함.
        }
    }
    // ... 일반 로그인 로직 (UserEntity 반환) ...
}
```

### 5.2 mergeAccount() 병합 실행 — `lib/user/UserService.php`

```php
public static function mergeAccount(array $input): array
{
    $loginUser = AuthService::getLoginUser();
    $v7Idx = (int)$loginUser->idx;

    // 중복 병합 방지
    $v7Raw = UserRepository::findRawByIdx($v7Idx);
    if (str_starts_with(trim($v7Raw['varchar_1'] ?? ''), 'id_merged_to:')) {
        throw new RuntimeException('이미 아이디 합치기가 완료된 계정입니다.');
    }

    // Phone Auth ID Token 검증 → 전화번호 추출
    $auth = FirebaseService::getAuth();
    $verifiedToken = $auth->verifyIdToken($input['phone_id_token']);
    $phoneUid = $verifiedToken->claims()->get('sub');
    $phoneNumber = $auth->getUser($phoneUid)->phoneNumber;

    // 전화번호로 v6 계정 검색
    $v6 = UserRepository::findV6ByPhoneNumber($phoneNumber);
    $v6FirebaseUid = (string)$v6['firebase_uid'];

    // 트랜잭션 — 반드시 Db::pdo() 사용 (api.php에서 pdo() 미정의)
    $pdo = Db::pdo();
    $pdo->beginTransaction();
    try {
        $pdo->prepare("UPDATE sf_member SET varchar_1 = ? WHERE idx = ?")
            ->execute(["id_merged_to:{$v6FirebaseUid}", $v7Idx]);
        $pdo->prepare("UPDATE sf_post_data SET idx_member = ? WHERE idx_member = ?")
            ->execute([(int)$v6['idx'], $v7Idx]);
        $pdo->commit();
    } catch (\Throwable $e) {
        $pdo->rollBack();
        throw new RuntimeException('아이디 합치기 실패: ' . $e->getMessage());
    }

    return ['status' => 'merged', 'message' => '아이디 합치기가 완료되었습니다.'];
}
```

### 5.3 findV6ByPhoneNumber() — `lib/user/UserRepository.php`

DB의 전화번호가 E.164 포맷(`+821012345678`)이므로, 입력값을 여러 포맷으로 변환하여 OR 검색한다.

```php
public static function findV6ByPhoneNumber(string $phoneNumber): array|false
{
    $digits = (string) preg_replace('/[^0-9]/', '', $phoneNumber);
    // 국가코드 82 제거, 앞에 0 추가 등 포맷 변환 후
    // 원본, 01012345678, +821012345678, 010-1234-5678 네 가지 포맷으로 OR 검색
    return Db::fetch($sql, $params);
}
```

### 5.4 Controller 반환 타입

```php
// socialLogin은 병합 시 array를 반환하므로 union type 필수
public function socialLogin(array $input): UserEntity|array { ... }
```

---

## 6. 프론트엔드 핵심 소스코드

### 6.1 merge-account.php — 4단계 Vue.js

**1단계: 전화번호 검색** (SMS 전송 전 v6 계정 확인)
```javascript
async searchAccount() {
    const e164 = this.formatE164(this.countryCode, this.phoneNumber.trim());
    this.v6Account = await v7api('user.findV6Account', { phone_number: e164 }, { alertOnError: false });
    this.step = 'preview';
}
```

**2단계: Firebase Phone Auth SMS 전송** (별도 App 인스턴스)
```javascript
async sendSmsCode() {
    this.phoneApp = firebase.initializeApp(window._v7fb.config, 'phone-verify-' + Date.now());
    const phoneAuth = this.phoneApp.auth();
    this.recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', { size: 'invisible' });
    this.confirmationResult = await phoneAuth.signInWithPhoneNumber(e164Phone, this.recaptchaVerifier);
    this.step = 'sms-verify';
}
```

**3단계: SMS 인증 + 합치기**
```javascript
async verifySmsAndMerge() {
    const userCredential = await this.confirmationResult.confirm(this.smsCode.trim());
    const phoneIdToken = await userCredential.user.getIdToken();
    await v7api('user.mergeAccount', { phone_id_token: phoneIdToken }, { alertOnError: false });
    this.step = 'complete';
    setTimeout(async () => {
        await firebase.auth().signOut();
        location.href = '/user/login';
    }, 3000);
}
```

---

## 7. 소셜 로그인 merged 분기 — 공통 패턴

모든 소셜 로그인 포인트에서 동일한 패턴을 사용한다.

```javascript
const loginResult = await v7api('user.socialLogin', { id_token, login_provider });

// ★ 병합된 계정: Custom Token으로 v6 전환
if (loginResult && loginResult.status === 'merged' && loginResult.custom_token) {
    await firebase.auth().signOut();
    const v6Cred = await firebase.auth().signInWithCustomToken(loginResult.custom_token);
    const v6IdToken = await v6Cred.user.getIdToken();
    await v7api('user.socialLogin', { id_token: v6IdToken });
}
location.href = '/';
```

적용 파일: `v7/auth/kakao/complete.php`, `v7/auth/naver/complete.php`, `v7/user/login.php` (Google + 자동동기화)

---

## 8. 되돌리기

```sql
UPDATE sf_member SET varchar_1 = '' WHERE idx = {v7Idx};
```

Firebase나 RTDB 조작 불필요. varchar_1 초기화만으로 복구된다.

---

## 9. 파일 목록

| 파일 | 역할 |
|------|------|
| `lib/user/UserService.php` | socialLogin() 병합 감지, findV6Account(), mergeAccount() |
| `lib/user/UserController.php` | API 엔드포인트 |
| `lib/user/UserRepository.php` | findV6ByPhoneNumber() |
| `v7/user/merge-account.php` | 프론트엔드 4단계 UI |
| `v7/user/merge-account.css` | 스타일시트 |
| `v7/auth/kakao/complete.php` | 카카오 merged 분기 |
| `v7/auth/naver/complete.php` | 네이버 merged 분기 |
| `v7/user/login.php` | 구글/애플 merged 분기 |

---

## 10. 엣지 케이스

| 상황 | 처리 |
|------|------|
| 전화번호가 DB에 없음 | findV6Account에서 에러. SMS 발송 안 함 |
| 이미 병합된 계정 | mergeAccount에서 "이미 합치기 완료" 에러 |
| 자기 자신과 병합 | mergeAccount에서 에러 |
| 여러 소셜 → 같은 v6 | 허용. 각 소셜 varchar_1에 동일한 `id_merged_to:BBB` |
| 전화번호 포맷 불일치 | findV6ByPhoneNumber에서 4가지 포맷 OR 검색 |

### 플러터 앱에서의 구현

동일한 API를 호출한다:
1. `v7api('user.socialLogin')` 호출 후 `status == 'merged'` 확인
2. `FirebaseAuth.instance.signOut()` → `signInWithCustomToken(custom_token)`
3. 새 ID Token으로 `v7api('user.socialLogin')` 재호출
4. 합치기 UI: `findV6Account` → SMS 인증 → `mergeAccount({phone_id_token})`

### 주의사항

- **`Db::pdo()` 사용 필수**: v7의 `api.php`는 `etc/boot.php`를 로드하지 않으므로 전역 `pdo()` 함수가 정의되지 않는다.
- **Controller 반환 타입**: `socialLogin()`은 `UserEntity|array` union type이어야 한다.
- **api.php catch**: `\Throwable`로 catch해야 Error도 잡힌다 (Exception만으로는 부족).
