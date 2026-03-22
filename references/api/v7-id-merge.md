# v7 아이디 병합 (ID Merge) API

## 1. 개요

v7 소셜 로그인 계정(Google/Kakao/Naver/Apple)을 v6 전화번호 계정과 병합하는 기능.
병합 후 소셜 로그인 시 자동으로 v6 계정(기존 게시글, 포인트, 레벨 보유)으로 접속된다.

### 핵심 판별 기준

- `sf_member.login_provider`에 값 있음 → v7에서 로그인한 계정
- `sf_member.login_provider`이 비어있음 → v4 또는 v6 계정

### 병합 방향

```
v7 계정 (새로 생성됨) ──→ v6 계정 (기존 사용자, 데이터 많음)
                              ↑
                      firebase_uid가 여기로 이전됨
```

---

## 2. API 엔드포인트

### user.mergeAccount

v7 소셜 계정의 firebase_uid를 v6 전화번호 계정으로 이전한다.

**URL**: `POST /api.php`

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|:---:|------|
| `phone_id_token` | string | O | Phone Auth ID Token (별도 Firebase App에서 인증) |
| `preview` | string | X | `'true'`이면 v6 계정 정보만 반환 (병합 실행 안함) |

**응답 (preview 모드)**:

```json
{
  "nickname": "길동이",
  "stamp": "1609459200",
  "idx": 50
}
```

**응답 (실행 모드)**:

```json
{
  "success": true,
  "message": "아이디가 성공적으로 합쳐졌습니다.",
  "merged_into_idx": 50,
  "v6_nickname": "길동이"
}
```

**에러 응답**:

| 상황 | 에러 메시지 |
|------|-----------|
| 비로그인 | `로그인이 필요합니다.` |
| v6 계정으로 로그인 | `이미 v6 계정으로 로그인되어 있습니다. 병합이 필요하지 않습니다.` |
| 이미 병합된 v7 계정 | `이미 아이디 병합이 완료된 계정입니다.` |
| v6 계정 못 찾음 | `해당 전화번호로 가입된 기존 계정을 찾을 수 없습니다.` |
| v6 이미 병합됨 | `해당 전화번호 계정은 이미 다른 계정과 병합된 이력이 있습니다.` |
| 자기 자신 | `현재 로그인한 계정과 동일한 계정입니다.` |

---

## 3. 핵심 설계 결정

### 3.1 v6 계정 검색: firebase_uid 방식 (전화번호 아님)

v6 전화번호 로그인 시 Firebase Phone Auth의 UID가 `sf_member.firebase_uid`에 이미 저장됨.
전화번호로 검색하지 않는 이유:

- Firebase는 E.164 형식(`+821012345678`) 반환, DB에는 다양한 포맷 혼재
- firebase_uid는 고유 문자열이므로 포맷 불일치 문제 없음
- UNIQUE 인덱스로 검색 성능 우수

```php
// MergeAccountRepository — firebase_uid로 v6 계정 검색
public static function findV6AccountByFirebaseUid(string $phoneFirebaseUid): ?array
{
    $row = Db::fetch(
        "SELECT * FROM sf_member WHERE firebase_uid = ? AND (login_provider IS NULL OR login_provider = '')",
        [$phoneFirebaseUid]
    );
    return ($row !== false) ? $row : null;
}
```

### 3.2 UNIQUE 제약 대응: merged_ 접두사

`sf_member.firebase_uid`에 UNIQUE 제약이 있어 두 레코드에 같은 값 불가.
빈 문자열(`''`)도 이미 존재할 수 있으므로, v7 계정의 firebase_uid를 `merged_{원래UID}`로 변경.

```sql
-- 트랜잭션 내 순서 (UNIQUE 충돌 방지)
-- 1단계: v7 계정의 firebase_uid를 merged_ 접두사로 변경
UPDATE sf_member SET firebase_uid = CONCAT('merged_', firebase_uid), ...  WHERE idx = {v7Idx};
-- 2단계: v6 계정에 v7의 원래 firebase_uid 저장
UPDATE sf_member SET firebase_uid = '{v7FirebaseUid}', ...  WHERE idx = {v6Idx};
```

### 3.3 중복 병합 방지: varchar_1 접두사

| 계정 | varchar_1 값 | 의미 |
|------|-------------|------|
| v7 (비활성화) | `v7-id-merge-into:50` | 이 계정은 idx:50으로 병합됨 |
| v6 (활성 계정) | `v7-id-merge-from:200` | idx:200에서 병합해온 계정 |

양쪽 계정 모두 `str_starts_with($varchar1, 'v7-id-merge-')` 체크로 중복 병합 방지.

### 3.4 병합 전후 DB 상태 예시

**병합 전**:

| 필드 | v7 계정 (idx:200) | v6 계정 (idx:50) |
|------|-------------------|-----------------|
| firebase_uid | `google_abc123` | `phone_xyz789` |
| login_provider | `google` | (비어있음) |
| varchar_1 | (비어있음) | (비어있음) |

**병합 후**:

| 필드 | v7 계정 (idx:200) | v6 계정 (idx:50) |
|------|-------------------|-----------------|
| firebase_uid | `merged_google_abc123` | `google_abc123` |
| login_provider | (비어있음) | `google` |
| varchar_1 | `v7-id-merge-into:50` | `v7-id-merge-from:200` |

---

## 4. 파일 구조 및 계층 분리

```
lib/user/MergeAccountRepository.php  — Repository (SQL 쿼리 — 유일하게 DB 직접 접근)
lib/user/MergeAccountService.php     — Service (비즈니스 로직 — SQL 절대 금지)
lib/user/UserController.php          — Controller (mergeAccount 메서드)
v7/user/merge-account.php            — View (PHP + Vue.js + Firebase Phone Auth)
v7/user/merge-account.css            — CSS
v7/user/settings.php                 — 아이디 합치기 버튼
tests/Unit/MergeAccountTest.php      — PEST 유닛 테스트 11개
```

---

## 5. 핵심 소스코드

### 5.1 MergeAccountRepository (SQL 계층)

```php
namespace Philgo\User;
use Philgo\Utils\Db;

class MergeAccountRepository
{
    private const TABLE = 'sf_member';
    private const POST_TABLE = 'sf_post_data';

    // firebase_uid로 v6 계정 검색 (login_provider 비어있는 계정만)
    public static function findV6AccountByFirebaseUid(string $phoneFirebaseUid): ?array
    {
        $row = Db::fetch(
            "SELECT * FROM " . self::TABLE . " WHERE firebase_uid = ? AND (login_provider IS NULL OR login_provider = '')",
            [$phoneFirebaseUid]
        );
        return ($row !== false) ? $row : null;
    }

    // 트랜잭션 병합: Db::execute() 사용 (P1006 방지)
    public static function executeMergeTransaction(int $v7Idx, int $v6Idx, string $v7FirebaseUid, string $v7LoginProvider): void
    {
        $pdo = Db::pdo();
        $pdo->beginTransaction();
        try {
            // 1. v7 계정: firebase_uid를 merged_ 접두사로 변경 (UNIQUE 충돌 방지)
            Db::execute(
                "UPDATE " . self::TABLE . " SET firebase_uid = CONCAT('merged_', firebase_uid), login_provider = '', varchar_1 = ? WHERE idx = ?",
                ["v7-id-merge-into:{$v6Idx}", $v7Idx]
            );
            // 2. v6 계정: v7의 firebase_uid, login_provider 저장
            Db::execute(
                "UPDATE " . self::TABLE . " SET firebase_uid = ?, login_provider = ?, varchar_1 = ? WHERE idx = ?",
                [$v7FirebaseUid, $v7LoginProvider, "v7-id-merge-from:{$v7Idx}", $v6Idx]
            );
            // 3. v7 계정의 게시글 소유권을 v6으로 이전
            Db::execute(
                "UPDATE " . self::POST_TABLE . " SET idx_member = ? WHERE idx_member = ?",
                [$v6Idx, $v7Idx]
            );
            $pdo->commit();
        } catch (\Throwable $e) {
            $pdo->rollBack();
            throw new \RuntimeException('아이디 병합 중 오류가 발생했습니다: ' . $e->getMessage());
        }
    }
}
```

### 5.2 MergeAccountService (비즈니스 로직 계층)

```php
namespace Philgo\User;
use Philgo\Utils\AuthService;
use Philgo\Utils\FirebaseService;

class MergeAccountService
{
    public static function merge(array $input): array
    {
        // 1. v7 로그인 확인 (login_provider 필수)
        $v7User = AuthService::getLoginUser();
        $v7Raw = UserRepository::findRawByIdx($v7User->idx);

        // 2. 중복 병합 방지 (varchar_1 접두사 확인)
        $v7Varchar1 = trim((string)($v7Raw['varchar_1'] ?? ''));
        if (str_starts_with($v7Varchar1, 'v7-id-merge-into:') || str_starts_with($v7Varchar1, 'v7-id-merge-from:')) {
            throw new \RuntimeException('이미 아이디 병합이 완료된 계정입니다.');
        }

        // 3. Phone Auth ID Token → firebase_uid 추출
        $phoneFirebaseUid = FirebaseService::verifyIdToken($input['phone_id_token']);

        // 4. firebase_uid로 v6 계정 검색 (Repository 호출)
        $v6User = MergeAccountRepository::findV6AccountByFirebaseUid($phoneFirebaseUid);

        // 5. preview 모드: v6 정보만 반환
        if (($input['preview'] ?? '') === 'true') {
            return ['nickname' => $v6User['nickname'] ?? '', 'stamp' => $v6User['stamp'] ?? '', 'idx' => (int)$v6User['idx']];
        }

        // 6. 트랜잭션 병합 실행 (Repository 호출)
        MergeAccountRepository::executeMergeTransaction($v7User->idx, (int)$v6User['idx'], (string)$v7Raw['firebase_uid'], (string)$v7Raw['login_provider']);

        // 7. Firebase RTDB 동기화 + 세션 쿠키 갱신
        UserService::syncUserToFirebase((string)$v7Raw['firebase_uid'], (string)($v6User['nickname'] ?? ''), (string)($v6User['photo_url'] ?? ''));
        $updatedV6 = UserRepository::findRawByIdx((int)$v6User['idx']);
        if ($updatedV6 !== false) AuthService::loginUser($updatedV6);

        return ['success' => true, 'message' => '아이디가 성공적으로 합쳐졌습니다.', 'merged_into_idx' => (int)$v6User['idx']];
    }
}
```

### 5.3 UserController (API 엔드포인트)

```php
// lib/user/UserController.php에 추가된 메서드
public function mergeAccount(array $input): array
{
    return MergeAccountService::merge($input);
}
```

### 5.4 Vue.js 별도 Firebase App 인스턴스 Phone Auth

```javascript
// v7/user/merge-account.php — 핵심 JS 패턴
// 메인 앱의 소셜 로그인 세션에 영향 없이 별도 인스턴스로 Phone Auth
const firebaseConfig = window._v7fb.config;
this.phoneApp = firebase.initializeApp(firebaseConfig, 'phone-verify-' + Date.now());
const phoneAuth = this.phoneApp.auth();

// RecaptchaVerifier + SMS 전송
const recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', { size: 'invisible' }, phoneAuth);
this.confirmationResult = await phoneAuth.signInWithPhoneNumber(phoneNumber, recaptchaVerifier);

// SMS 확인 → ID Token → 서버 전송
const userCredential = await this.confirmationResult.confirm(smsCode);
const phoneIdToken = await userCredential.user.getIdToken();

// preview 모드로 v6 계정 정보 확인
const result = await v7api('user.mergeAccount', { phone_id_token: phoneIdToken, preview: 'true' }, { alertOnError: false });

// 실제 병합 실행
await v7api('user.mergeAccount', { phone_id_token: phoneIdToken }, { alertOnError: false });

// 사용 후 별도 앱 정리
await this.phoneApp.delete();
```

### 5.5 Web Awesome 커스텀 엘리먼트 바인딩 패턴

Web Awesome의 `wa-input`, `wa-button`은 커스텀 엘리먼트이므로 Vue.js에서 특수 바인딩 필요:

```html
<!-- ❌ 잘못된 방법: boolean attribute가 항상 true로 설정됨 -->
<wa-input :disabled="loading"></wa-input>
<wa-button :loading="loading"></wa-button>

<!-- ✅ 올바른 방법: .prop 수정자 사용 -->
<wa-input :disabled.prop="loading"></wa-input>
<wa-button :loading.prop="loading"></wa-button>

<!-- ❌ 잘못된 방법: v-model 미동작 (커스텀 엘리먼트) -->
<wa-input v-model="phoneNumber"></wa-input>

<!-- ✅ 올바른 방법: :value + @wa-input 이벤트 사용 -->
<wa-input :value="phoneNumber" @wa-input="phoneNumber = $event.target.value"></wa-input>
```

---

## 6. 페이지 흐름 (UI/UX)

```
[설정 페이지]                    [아이디 합치기 페이지]
┌──────────────┐              ┌───────────────────────────┐
│ 로그인 방식   │              │ step='phone-input'         │
│  Google      │   클릭       │ 전화번호 입력 + SMS 전송    │
│ 아이디 합치기 │ ──────────→ │                           │
│  [버튼]      │              │ step='sms-verify'          │
└──────────────┘              │ SMS 코드 입력 + 인증 확인    │
                              │                           │
                              │ step='confirm-merge'       │
                              │ v6 계정 정보 + 병합 실행     │
                              │                           │
                              │ step='complete'            │
                              │ 완료 → 자동 새로고침         │
                              └───────────────────────────┘
```

### PHP 페이지 사전 체크

```php
// v7/user/merge-account.php — PHP 부분
$loginUser = AuthService::getLoginUser();
$v7Raw = UserRepository::findRawByIdx($loginUser->idx);
$loginProvider = (string)($v7Raw['login_provider'] ?? '');
$varchar1 = (string)($v7Raw['varchar_1'] ?? '');

// 이미 병합 완료?
$alreadyMerged = str_starts_with($varchar1, 'v7-id-merge-into:') || str_starts_with($varchar1, 'v7-id-merge-from:');
// v6 계정이면 병합 불필요
$isV6Account = empty($loginProvider);
```

---

## 7. 테스트

**테스트 파일**: `tests/Unit/MergeAccountTest.php` (11개 테스트)

| 테스트 | 검증 항목 |
|--------|---------|
| findV6AccountByFirebaseUid | firebase_uid로 v6 계정 검색 성공 |
| v7 계정은 검색 안됨 | login_provider가 있는 계정 제외 |
| 존재하지 않는 UID | null 반환 |
| 비로그인 병합 시도 | RuntimeException |
| v6 계정으로 병합 시도 | RuntimeException |
| phone_id_token 누락 | RuntimeException |
| 이미 병합된 v7 계정 | RuntimeException (중복 방지) |
| preview 모드 | v6 계정 정보 반환 (병합 미실행) |
| 병합 실행 성공 | DB 상태 검증 (firebase_uid 이전, varchar_1 설정) |
| 이미 병합된 v6 계정 | RuntimeException (중복 방지) |
| v6 계정 없음 | RuntimeException |

---

## 8. 참조 파일 목록

| 파일 | 역할 |
|------|------|
| `lib/user/MergeAccountRepository.php` | SQL 쿼리 (검색, 트랜잭션 병합) |
| `lib/user/MergeAccountService.php` | 비즈니스 로직 (검증, Firebase 호출, 중복 방지) |
| `lib/user/UserController.php` | API `user.mergeAccount` 엔드포인트 |
| `v7/user/merge-account.php` | 아이디 합치기 페이지 (PHP + Vue.js) |
| `v7/user/merge-account.css` | 페이지 CSS |
| `v7/user/settings.php` | 설정 페이지 (아이디 합치기 버튼) |
| `tests/Unit/MergeAccountTest.php` | PEST 유닛 테스트 11개 |
