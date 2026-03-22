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

**URL**: `POST /api.php`

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|:---:|------|
| `phone_id_token` | string | O | Phone Auth ID Token (별도 Firebase App에서 인증) |
| `preview` | string | X | `'true'`이면 v6 계정 정보만 반환 (병합 실행 안함) |

**응답 (preview 모드)**:

```json
{"nickname": "길동이", "stamp": "1609459200", "idx": 50, "phone_number": "+821012345678", "point": 15000}
```

**응답 (실행 모드)**:

```json
{"success": true, "message": "아이디가 성공적으로 합쳐졌습니다.", "merged_into_idx": 50, "v6_nickname": "길동이"}
```

**에러 응답**:

| 상황 | 에러 메시지 |
|------|-----------|
| 비로그인 | `로그인이 필요합니다.` |
| v6 계정으로 로그인 | `이미 v6 계정으로 로그인되어 있습니다.` |
| 이미 병합된 v7 계정 | `이미 아이디 병합이 완료된 계정입니다.` |
| v6 계정 못 찾음 | `해당 전화번호로 가입된 기존 계정을 찾을 수 없습니다.` |
| v6 탈퇴 계정 | `해당 전화번호 계정은 탈퇴한 계정입니다.` |
| v6 이미 병합됨 | `해당 전화번호 계정은 이미 다른 계정과 병합된 이력이 있습니다.` |
| 자기 자신 | `현재 로그인한 계정과 동일한 계정입니다.` |

---

## 3. 핵심 설계 결정

### 3.1 v6 계정 검색: firebase_uid 방식 (전화번호 아님)

전화번호로 검색하지 않는 이유:
- Firebase는 E.164 형식 반환, DB에는 다양한 포맷 혼재
- firebase_uid는 고유 문자열이므로 포맷 불일치 문제 없음
- UNIQUE 인덱스로 검색 성능 우수

### 3.2 UNIQUE 제약 대응: firebase_uid + id 모두 merged_ 접두사

`sf_member`에 `firebase_uid`와 `id` 모두 UNIQUE 제약이 있음.
병합 시 v7 계정의 **두 컬럼 모두** `merged_` 접두사로 변경해야 함.

**`id`도 변경하는 이유**: `socialLogin`의 `createOrUpdate`가 `INSERT ... ON DUPLICATE KEY UPDATE`를 사용하는데,
`id`(이메일) UNIQUE 충돌이 먼저 발생하면 비활성화된 v7 계정이 반환되어 병합이 무효화됨.

```sql
-- 트랜잭션 내 순서
-- 1단계: v7 계정의 firebase_uid와 id를 모두 merged_ 접두사로 변경
UPDATE sf_member SET
  firebase_uid = CONCAT('merged_', firebase_uid),
  id = CONCAT('merged_', id),
  login_provider = '',
  varchar_1 = 'v7-id-merge-into:{v6Idx}'
WHERE idx = {v7Idx};

-- 2단계: v6 계정에 v7의 원래 firebase_uid, login_provider 저장
UPDATE sf_member SET
  firebase_uid = '{v7FirebaseUid}',
  login_provider = '{v7LoginProvider}',
  varchar_1 = 'v7-id-merge-from:{v7Idx}'
WHERE idx = {v6Idx};

-- 3단계: v7 계정의 게시글 소유권을 v6으로 이전
UPDATE sf_post_data SET idx_member = {v6Idx} WHERE idx_member = {v7Idx};
```

### 3.3 중복 병합 방지: varchar_1 접두사

| 계정 | varchar_1 값 | 의미 |
|------|-------------|------|
| v7 (비활성화) | `v7-id-merge-into:50` | idx:50으로 병합됨 |
| v6 (활성 계정) | `v7-id-merge-from:200` | idx:200에서 병합해온 계정 |

### 3.4 탈퇴 계정 병합 방지

`UserService::isResignedUser()` (`password=RESIGNED && name=RESIGNED`)로 체크.
탈퇴 계정과 병합하면 로그인 시 "탈퇴한 회원입니다" 에러 발생.

### 3.5 Firebase RTDB 채팅 데이터 마이그레이션

병합 시 v6 계정의 이전 Phone Auth UID로 저장된 RTDB 데이터를 새 소셜 로그인 UID로 복사:

| RTDB 경로 | 작업 |
|-----------|------|
| `chat/joins/{oldUid}/*` | → `chat/joins/{newUid}/*` 복사 (채팅방 목록) |
| `users/{oldUid}/nickname,photoUrl` | → `users/{newUid}/` 복사 (프로필) |
| `user-private/{oldUid}/*` | → `user-private/{newUid}/*` 복사 (차단 목록) |

**한계**: 1:1 채팅방 roomId(`{uid1}---{uid2}`)에 이전 UID가 포함되어 변경 불가.
하지만 joins 데이터가 복사되므로 채팅 목록 표시는 정상 동작.

### 3.6 v6 전화번호 로그인 시 병합 무효화 주의

병합 후 v6 사이트에서 전화번호로 로그인하면 `firebase_login()` 함수가
`firebase_uid`를 Phone Auth UID로 덮어써서 병합이 무효화됨. (v6 코드 수정 불가)

---

## 4. 파일 구조

```
lib/user/MergeAccountRepository.php  — Repository (SQL 쿼리)
lib/user/MergeAccountService.php     — Service (비즈니스 로직 + RTDB 마이그레이션)
lib/user/UserController.php          — Controller (mergeAccount 메서드)
v7/user/merge-account.php            — View (PHP + Vue.js + 네이티브 HTML 폼)
v7/user/merge-account.css            — CSS (네이티브 폼 요소 스타일)
v7/user/settings.php                 — 설정 페이지 (아이디 합치기 버튼)
v7/menu/index.php                    — 메뉴 페이지 (아이디 합치기 메뉴)
tests/Unit/MergeAccountTest.php      — PEST 유닛 테스트 11개
data/porting/4225-rtdb-porting.php   — RTDB 수동 마이그레이션 스크립트
```

---

## 5. 핵심 소스코드

### 5.1 Repository — executeMergeTransaction

```php
// firebase_uid와 id 모두 merged_ 접두사로 변경 (UNIQUE 충돌 방지)
Db::execute(
    "UPDATE sf_member SET firebase_uid = CONCAT('merged_', firebase_uid), id = CONCAT('merged_', id), login_provider = '', varchar_1 = ? WHERE idx = ?",
    ["v7-id-merge-into:{$v6Idx}", $v7Idx]
);
// v6 계정에 v7의 firebase_uid, login_provider 저장
Db::execute(
    "UPDATE sf_member SET firebase_uid = ?, login_provider = ?, varchar_1 = ? WHERE idx = ?",
    [$v7FirebaseUid, $v7LoginProvider, "v7-id-merge-from:{$v7Idx}", $v6Idx]
);
// v7 계정의 게시글 소유권을 v6으로 이전
Db::execute(
    "UPDATE sf_post_data SET idx_member = ? WHERE idx_member = ?",
    [$v6Idx, $v7Idx]
);
```

### 5.2 Service — merge() 검증 흐름

```php
// 1. v7 로그인 확인 (login_provider 필수)
// 2. 중복 병합 방지 (varchar_1 접두사 확인)
// 3. Phone Auth ID Token → firebase_uid 추출
// 4. firebase_uid로 v6 계정 검색
// 5. 탈퇴 계정 방지 (isResignedUser 체크)
// 6. v6 중복 병합 방지
// 7. preview 모드: v6 정보(nickname, stamp, phone_number, point) 반환
// 8. 트랜잭션 병합 실행 (Repository 호출)
// 9. Firebase RTDB 채팅 데이터 마이그레이션
// 10. RTDB 사용자 프로필 동기화
// 11. 세션 쿠키 갱신
```

### 5.3 Service — migrateFirebaseRtdbData

```php
private static function migrateFirebaseRtdbData(string $oldUid, string $newUid): void
{
    $database = FirebaseService::getDatabase();
    // 1. chat/joins 복사
    $oldJoins = $database->getReference('chat/joins/' . $oldUid)->getValue();
    if (!empty($oldJoins)) $database->getReference('chat/joins/' . $newUid)->update($oldJoins);
    // 2. users 프로필 복사 (nickname, photoUrl만)
    // 3. user-private 복사 (차단 목록)
    // 실패 시 병합 롤백하지 않고 로그만 기록
}
```

### 5.4 Vue.js — 네이티브 HTML 폼 + Phone Auth

**Web Awesome 커스텀 엘리먼트(wa-select, wa-input, wa-button)는 Vue.js v-model과 호환 문제가 심각하여 네이티브 HTML로 대체:**

```html
<!-- 네이티브 select + v-model (안정적) -->
<select v-model="countryCode" class="merge-select">
    <option value="+82">+82</option>
    <option value="+63">+63</option>
</select>
<input v-model="phoneNumber" type="tel" class="merge-input" />
<button @click="sendSmsCode" class="merge-btn-primary">인증</button>
```

**Phone Auth — 별도 Firebase App + 메인 앱 RecaptchaVerifier:**

```javascript
// 별도 앱으로 Phone Auth (메인 소셜 로그인 세션 보호)
this.phoneApp = firebase.initializeApp(firebaseConfig, 'phone-verify-' + Date.now());
const phoneAuth = this.phoneApp.auth();

// RecaptchaVerifier는 메인 앱 기반 (compat SDK 제약)
// 재시도 시 clear() + DOM 초기화 필수
if (this.recaptchaVerifier) {
    try { this.recaptchaVerifier.clear(); } catch (e) {}
}
const rc = document.getElementById('recaptcha-container');
if (rc) rc.innerHTML = '';
this.recaptchaVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', { size: 'invisible' });

// SMS 전송 (별도 앱의 auth + 메인 앱의 recaptcha)
this.confirmationResult = await phoneAuth.signInWithPhoneNumber(e164Phone, this.recaptchaVerifier);
```

**"전화번호 다시 입력" 시 상태 초기화:**

```javascript
resetToPhoneInput() {
    this.step = 'phone-input';
    this.smsCode = '';
    this.confirmationResult = null;
    if (this.recaptchaVerifier) {
        try { this.recaptchaVerifier.clear(); } catch (e) {}
        this.recaptchaVerifier = null;
    }
    if (this.phoneApp) {
        this.phoneApp.delete().catch(() => {});
        this.phoneApp = null;
    }
}
```

---

## 6. 주의사항 및 알려진 한계

### Web Awesome + Vue.js 호환 문제

| 문제 | 해결 |
|------|------|
| wa-select v-model 미동작 | 네이티브 `<select v-model>` 사용 |
| wa-input @wa-input 이벤트 미발생 | 네이티브 `<input v-model>` 사용 |
| wa-button :loading 항상 true | 네이티브 `<button :disabled>` 사용 |
| wa-select 값 리셋 (리렌더링) | 네이티브 select는 문제 없음 |

### RecaptchaVerifier 재시도 에러

| 에러 | 원인 | 해결 |
|------|------|------|
| `already been rendered` | 같은 DOM에 RecaptchaVerifier 중복 생성 | `clear()` + `innerHTML = ''` 후 재생성 |
| `client element has been removed` | step 전환으로 DOM 재생성 | `resetToPhoneInput()`에서 verifier null 초기화 |

### v6 전화번호 로그인 시 병합 무효화

병합 후 v6에서 전화번호 로그인 → `firebase_login()`이 firebase_uid를 Phone Auth UID로 덮어씀
→ v7 구글 로그인 시 새 계정 생성 → 병합 무효화. v6 코드 수정 불가이므로 구조적 한계.

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
| 이미 병합된 v7 계정 | RuntimeException |
| preview 모드 | v6 계정 정보 반환 |
| 병합 실행 성공 | DB 상태 검증 |
| 이미 병합된 v6 계정 | RuntimeException |
| v6 계정 없음 | RuntimeException |
