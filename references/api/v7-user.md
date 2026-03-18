# User API - v7 시스템 (PSR-4)

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. API 엔드포인트](#3-api-엔드포인트)
  - [3.1 user.count](#31-usercount---총-사용자-수-조회)
  - [3.2 user.me](#32-userme---현재-로그인-사용자-정보-조회)
  - [3.3 user.socialLogin](#33-usersociallogin---소셜-로그인)
    - [3.3.1 동시 호출 Race Condition 방지 — createOrUpdate() 패턴](#331-동시-호출-race-condition-방지--createorupdate-패턴)
  - [3.4 공개 프로필 페이지 (SSR)](#34-공개-프로필-페이지-ssr)
    - [3.4.a 디자인 구조 (보더리스 디자인)](#34a-디자인-구조-보더리스-디자인)
  - [3.5 user.updateMyProfile](#35-userupdatemyprofile---회원-정보-수정)
  - [3.6 회원 정보 수정 페이지 (SSR)](#36-회원-정보-수정-페이지-ssr)
  - [3.7 user.search — 닉네임으로 사용자 검색](#37-usersearch---닉네임으로-사용자-검색)
- [4. 파일 구조](#4-파일-구조)
- [5. 인증 시스템 (AuthService)](#5-인증-시스템-authservice)
- [6. 테스트](#6-테스트)
- [7. 레벨 계산 시스템](#7-레벨-계산-시스템)
  - [7.1 핵심 원칙](#71-핵심-원칙)
  - [7.2 POINT_LEVELS 상수 (128단계)](#72-point_levels-상수-128단계)
  - [7.3 레벨 계산 알고리즘](#73-레벨-계산-알고리즘)
  - [7.4 레벨 진행률 계산 알고리즘](#74-레벨-진행률-계산-알고리즘)
  - [7.5 계산 예시](#75-계산-예시)
  - [7.6 레거시 함수와의 관계](#76-레거시-함수와의-관계)
  - [7.7 v7 API에서의 레벨 반환 규칙](#77-v7-api에서의-레벨-반환-규칙)
- [8. UserEntity](#8-userentity)
- [9. 사용자 설정 페이지 (SSR)](#9-사용자-설정-페이지-ssr)
- [10. 사용자 차단 기능](#10-사용자-차단-기능)
- [11. 사용자 신고 기능](#11-사용자-신고-기능)
- [12. UserRepository](#12-userrepository)
  - [12.1 개요](#121-개요)
  - [12.2 RepositoryInterface 필수 메서드 (4개)](#122-repositoryinterface-필수-메서드-4개)
  - [12.3 Firebase UID 기반 조회](#123-firebase-uid-기반-조회)
  - [12.4 닉네임 관련 조회](#124-닉네임-관련-조회)
  - [12.5 목록/통계 조회](#125-목록통계-조회)
  - [12.6 사용자 활동 조회](#126-사용자-활동-조회)
  - [12.7 사용자 신고 관련](#127-사용자-신고-관련)
  - [12.8 UserService와의 관계](#128-userservice와의-관계)
- [13. Firebase RTDB 사용자 정보 동기화](#13-firebase-rtdb-사용자-정보-동기화)
  - [13.1 개요](#131-개요)
  - [13.2 syncUserToFirebase() 메서드](#132-syncusertofirebase-메서드)
  - [13.3 호출 위치](#133-호출-위치)
  - [13.4 RTDB 데이터 구조](#134-rtdb-데이터-구조)
  - [13.5 에러 처리](#135-에러-처리)

---

## 1. 개요

사용자(User) 모듈의 v7 시스템 API이다.
`api.php`의 PSR-4 autoloading + Controller 기반 디스패치를 통해 호출된다.

- **DB 테이블**: `sf_member`
- **Controller**: `Philgo\User\UserController` (`lib/user/UserController.php`)
- **Service**: `Philgo\User\UserService` (`lib/user/UserService.php`)
- **Repository**: `Philgo\User\UserRepository` (`lib/user/UserRepository.php`) — `RepositoryInterface` 구현, sf_member 전체 DB 접근 중앙 집중
- **인증 유틸**: `Philgo\Utils\AuthService` (`lib/utils/AuthService.php`)
- **API 접두사**: `user.*`
- **네임스페이스**: `Philgo\User`, `Philgo\Utils`

---

## 2. 아키텍처

```
[user.count 흐름]
JavaScript: func('user.count')
    │
    ▼ POST /api.php (body: {method: "user.count"})
    │
    ▼ api.php (PSR-4 Autoloading)
    │  ├─ require vendor/autoload.php
    │  ├─ RequestUtils::parseMethod() → ["user", "count"]
    │  ├─ FQCN 생성: "Philgo\User\UserController"
    │  └─ new UserController() → count($input)
    │
    ▼ Philgo\User\UserController::count()
    │  └─ UserService::getTotalCount()
    │
    ▼ Philgo\User\UserService::getTotalCount()
    │  └─ UserRepository::countAll()
    │     └─ Db::fetchColumn() → SELECT COUNT(*) FROM sf_member
    │
    ▼ JSON 응답: {"count": 188186}


[user.me 흐름]
JavaScript: func('user.me', { id_token: 'Firebase ID Token' })
    │
    ▼ POST /api.php (body: {method: "user.me", id_token: "..."})
    │
    ▼ api.php (PSR-4 Autoloading)
    │  └─ new UserController() → me($input)
    │
    ▼ Philgo\User\UserController::me()
    │  └─ UserService::getMe()
    │
    ▼ Philgo\User\UserService::getMe()
    │  ├─ AuthService::getLoginUser()  ← 2경로 인증
    │  │  ├─ [경로1] 쿠키 session_id → 세션 ID 해시 검증 → DB 조회 (SSR용)
    │  │  └─ [경로2] id_token 파라미터 → FirebaseService::verifyIdToken()
    │  │     → Firebase UID 획득 → DB 조회 → 세션 쿠키 저장 (API용)
    │  ├─ null이면 → throw RuntimeException('로그인이 필요합니다.')
    │  └─ password 필드 제거 후 리턴
    │
    ▼ JSON 응답 (성공): {"idx": 123, "id": "user@test.com", ...}
    ▼ JSON 응답 (비로그인): {"success": false, "message": "로그인이 필요합니다."}
```

핵심 원칙:
- `boot.php` 미포함 — Composer PSR-4 autoloader 사용
- 기존 함수(`in()`, `pdo()`, `error()` 등) 사용 금지
- 네임스페이스: `Philgo\User`, `Philgo\Utils`
- 에러 시 `throw new RuntimeException()` → api.php에서 catch → `{success: false, message: "..."}`
- 성공 시 Controller 리턴값 그대로 JSON 출력 (`{success: true}` 추가 없음)

---

## 3. API 엔드포인트

### 3.1 user.count - 총 사용자 수 조회

| 항목 | 값 |
|------|-----|
| **method** | `user.count` |
| **HTTP** | `GET /api.php?method=user.count` 또는 `POST /api.php` (body: `{method: "user.count"}`) |
| **파라미터** | 없음 |
| **응답** | `{"count": 188186}` |

**curl 예시**:
```bash
# GET 방식
curl -s "https://local.philgo.com:443/api.php?method=user.count"

# POST 방식 (JSON)
curl -s -X POST "https://local.philgo.com:443/api.php" \
  -H "Content-Type: application/json" \
  -d '{"method": "user.count"}'
```

**JavaScript 호출 예시**:
```javascript
const res = await func('user.count');
console.log(res.count);  // 188186
```

**응답 형식**:
```json
{
    "count": 188186
}
```

### 3.2 user.me - 현재 로그인 사용자 정보 조회

| 항목 | 값 |
|------|-----|
| **method** | `user.me` |
| **HTTP** | `GET /api.php?method=user.me` 또는 `POST /api.php` (body: `{method: "user.me"}`) |
| **인증** | 필수 — 쿠키/파라미터 `session_id` (SSR/CURL) 또는 파라미터 `id_token` (앱/웹 API) |
| **파라미터** | `id_token` (Firebase ID Token, 앱/웹 호출 시) 또는 `session_id` (CURL 호출 시) |
| **성공 응답** | 사용자 정보 배열 (sf_member 전체 컬럼, password 제외). `point`, `level`, `level_progress` 포함 |
| **에러 응답** | `{"success": false, "message": "로그인이 필요합니다."}` |

**주요 응답 필드**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | int | 사용자 고유 ID |
| `id` | string | 사용자 아이디 (이메일) |
| `name` | string | 이름 |
| `nickname` | string | 닉네임 |
| `phone_number` | string | 전화번호 |
| `firebase_uid` | string | Firebase 인증 UID |
| `point` | int | 회원 포인트 (현재 잔액) |
| `level` | int | 회원 레벨 (**포인트 기반 동적 계산**, POINT_LEVELS 상수 기준) |
| `level_progress` | int | 다음 레벨까지 진행률 (0~100%, **동적 계산**) |
| `photo_url` | string | 프로필 사진 URL |
| `gender` | string | 성별 (M/F) |
| `no_of_post` | int | 작성한 글 수 |
| `no_of_comment` | int | 작성한 댓글 수 |
| `stamp` | int | 레코드 생성/수정 시간 (UNIX timestamp) |

> **참고**: `level`과 `level_progress`는 DB에 저장된 정적 값이 아니라, `point`에서 **매번 동적으로 계산**된다.
> `UserService::calculateLevel()`과 `UserService::calculateLevelProgress()`가 레거시 `get_user_level()`, `get_user_level_progress()`와 동일한 로직으로 계산한다.
> 레벨 기준은 `POINT_LEVELS` 상수(128단계, `etc/app.config.php`)에 정의되어 있다.

**인증 처리 흐름 (2경로)**:

경로 1 — 세션 기반 인증 (SSR/CURL용):
1. `AuthService::getLoginUser()` → 쿠키 또는 파라미터에서 `session_id` 확인
2. 세션 ID 형식 검증: `"{MD5해시}-{사용자idx}"` → `idx` 추출
3. DB에서 사용자 조회: `SELECT * FROM sf_member WHERE idx = ?`
4. 해시 검증: `md5(LOGIN_SALT + idx + firebase_uid + phone_number) + '-' + idx`
5. 모든 검증 통과 시 사용자 레코드 리턴

경로 2 — Firebase ID Token 인증 (API용):
1. `AuthService::getLoginUser()` → `id_token` 파라미터 확인
2. `FirebaseService::verifyIdToken($idToken)` → Firebase UID 획득
3. DB에서 사용자 조회: `SELECT * FROM sf_member WHERE firebase_uid = ?`
4. 세션 ID 생성 → 쿠키에 저장 (다음 요청부터 세션 기반 인증 가능)
5. 사용자 레코드 리턴 (password 필드 제거)

경로 3 — 자동 회원 가입 (Firebase ID Token이 있으나 sf_member에 레코드가 없는 경우):
1. 경로 1, 2 모두 실패 (AuthService::getLoginUser()가 null 반환)
2. `id_token` 파라미터가 존재하면 자동 회원 가입 시도
3. `FirebaseService::verifyIdTokenWithClaims($idToken)` → Firebase UID + claims 획득
4. sf_member에서 firebase_uid로 재확인 (AuthService 캐싱으로 누락 가능성 대비)
5. 레코드가 없으면 `FirebaseService::getAuth()->getUser($uid)`로 Firebase Auth에서 상세 정보 조회
6. displayName, email, photoUrl, phoneNumber, provider 정보를 기반으로 sf_member에 INSERT
7. 세션 쿠키 저장 후 UserEntity 리턴

**호출 환경별 가이드**:

| 환경 | 인증 방법 | 파라미터 |
|------|----------|---------|
| **SSR (서버 PHP)** | 쿠키의 `session_id` 자동 사용 | 없음 — `UserService::getMe()` 직접 호출 |
| **CURL (테스트/디버깅)** | `session_id` 파라미터 전달 | `&session_id={세션ID}` |
| **웹/앱 클라이언트** | Firebase ID Token 전달 | `&id_token={Firebase ID Token}` |

> **참고**: 호스트 주소는 환경에 따라 다르다.
> - 로컬 개발: `https://local.philgo.com:443/api.php`
> - 로컬 개발 (v6 포트): `https://local.philgo.com/api.php`
> - 프로덕션: `https://philgo.com/api.php`

**SSR 환경 (서버 PHP에서 직접 호출)**:
```php
// SSR에서는 UserService::getMe()를 직접 호출한다.
// 쿠키에 저장된 session_id로 자동 인증된다.
use Philgo\User\UserService;

$user = UserService::getMe();  // 쿠키 session_id → 자동 인증
echo $user['name'];
```

**CURL 테스트 (session_id 파라미터)**:
```bash
# CURL에서는 Firebase ID Token을 사용하기 어려우므로 session_id 파라미터를 사용한다.
curl -s "https://local.philgo.com:443/api.php?method=user.me&session_id={세션ID}"
# → {"idx":123,"id":"user@test.com","name":"홍길동",...}

# 테스트 토큰 사용 (개발 환경)
curl -s "https://local.philgo.com:443/api.php?method=user.me&id_token=LIVE_ONE_TOKEN"

# 비로그인 상태 → 에러
curl -s "https://local.philgo.com:443/api.php?method=user.me"
# → {"success":false,"message":"로그인이 필요합니다."}
```

**웹/앱 클라이언트 (Firebase ID Token)**:
```javascript
// 앱/웹 클라이언트는 항상 Firebase ID Token을 전달한다.
const res = await func('user.me', { id_token: firebaseIdToken });
console.log(res.idx);    // 123
console.log(res.id);     // "user@test.com"
console.log(res.name);   // "홍길동"
console.log(res.point);           // 5000 (회원 포인트)
console.log(res.level);           // 2 (포인트 기반 동적 계산)
console.log(res.level_progress);  // 37 (다음 레벨까지 진행률 0~100%)
// ※ password 필드는 응답에 포함되지 않음
```

**성공 응답 형식** (sf_member 테이블 전체 컬럼, password 제외):
```json
{
    "idx": 123,
    "id": "user@test.com",
    "name": "홍길동",
    "nickname": "닉네임",
    "phone_number": "+821012345678",
    "firebase_uid": "abc123...",
    "stamp": 1700000000,
    "point": 5000,
    "level": 2,
    "level_progress": 37,
    "photo_url": "https://file.philgo.com/...",
    "gender": "M",
    "no_of_post": 10,
    "no_of_comment": 5
}
```

**에러 응답 형식**:
```json
{
    "success": false,
    "message": "로그인이 필요합니다."
}
```

#### 3.2.1 자동 회원 가입 (Auto Registration)

`user.me` 호출 시 Firebase ID Token(`id_token`)이 있지만 `sf_member` 테이블에 해당 Firebase UID의 레코드가 없는 경우,
**자동으로 사용자 레코드를 생성**한다. 이 기능은 소셜 로그인(Google, Apple, 카카오, 네이버 등)으로 Firebase에 인증된 사용자가
별도의 회원 가입 절차 없이 바로 필고 서비스를 이용할 수 있도록 한다.

**자동 회원 가입 흐름**:

```
UserService::getMe()
    │
    ├─ AuthService::getLoginUser() → null (세션 없음, DB에 firebase_uid 없음)
    │
    ├─ id_token 파라미터 확인 → 있음
    │
    ├─ FirebaseService::verifyIdTokenWithClaims($idToken)
    │   └─ Firebase UID + claims (uid, email, name, picture) 획득
    │
    ├─ sf_member에서 firebase_uid로 재확인 (AuthService 캐싱 대비)
    │   └─ 있으면 → loginUser() + UserEntity 리턴 (자동 가입 불필요)
    │
    ├─ getFirebaseAuthUser($uid) — Firebase Auth에서 상세 정보 조회
    │   └─ displayName, email, photoUrl, phoneNumber, provider 가져옴
    │
    ├─ sf_member에 INSERT
    │   ├─ id: email 또는 'social_{firebase_uid}'
    │   ├─ firebase_uid: Firebase UID
    │   ├─ login_provider: 'google.com', 'apple.com', 'phone' 등
    │   ├─ email: Firebase Auth 또는 claims에서 가져온 이메일
    │   ├─ name: displayName
    │   ├─ nickname: displayName 또는 email 앞부분 또는 'User_{uid앞8자}'
    │   ├─ photo_url: photoUrl
    │   ├─ phone_number: phoneNumber
    │   └─ stamp: time()
    │
    └─ AuthService::loginUser($row) → 세션 쿠키 저장 → UserEntity 리턴
```

**닉네임 자동 생성 규칙** (우선순위):
1. Firebase Auth의 `displayName`이 있으면 그대로 사용
2. `email`이 있으면 `@` 앞 부분을 닉네임으로 사용
3. 둘 다 없으면 `User_{firebase_uid 앞 8자}`

**getFirebaseAuthUser() private 메서드**:
Firebase Auth Admin SDK(`FirebaseService::getAuth()->getUser($uid)`)를 호출하여
Firebase에 저장된 사용자의 상세 정보를 조회한다. ID Token의 claims보다 더 풍부한 정보를 제공한다.

| 반환 필드 | 타입 | 설명 |
|-----------|------|------|
| `email` | string | Firebase Auth에 등록된 이메일 |
| `displayName` | string | Firebase Auth에 등록된 표시 이름 |
| `photoUrl` | string | Firebase Auth에 등록된 프로필 사진 URL |
| `phoneNumber` | string | Firebase Auth에 등록된 전화번호 |
| `provider` | string | 로그인 제공자 (google.com, apple.com, phone, password 등) |

> Firebase Auth 조회가 실패해도 에러를 throw하지 않고, 빈 문자열을 기본값으로 사용하여
> claims 정보만으로도 자동 회원 가입이 진행되도록 한다.

### 3.3 user.socialLogin - 소셜 로그인

| 항목 | 값 |
|------|-----|
| **method** | `user.socialLogin` |
| **HTTP** | `POST /api.php` (body: `{method: "user.socialLogin", id_token: "...", login_provider: "google"}`) |
| **파라미터** | `id_token` (필수): Firebase ID Token, `login_provider` (선택): 소셜 로그인 제공자 |
| **응답** | `UserEntity` (로그인된 사용자 정보) |

**파라미터 상세**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `id_token` | string | 필수 | Firebase ID Token (Google/Apple/Kakao/Naver/Phone Auth) |
| `login_provider` | string | 선택 | 소셜 로그인 제공자. 값: `google`, `apple`, `kakaotalk`, `naver`, `phone_sign_in` 등 |

**login_provider 필드 (v7 홈페이지/앱 전용)**:

> `login_provider`는 **v7 홈페이지와 앱에서만 사용**하는 필드이다. v6에서는 사용하지 않는다.
> 클라이언트(웹/앱)에서 소셜 로그인 시 어떤 제공자를 사용했는지 명시적으로 전달한다.
> - 신규 사용자: INSERT 시 login_provider 저장
> - 기존 사용자: login_provider가 전달된 경우에만 UPDATE
> - login_provider가 전달되지 않으면 기존 값 유지

**JavaScript 호출 예시 (v7 홈페이지)**:
```javascript
// Google 로그인
const data = await v7api('user.socialLogin', {
    id_token: idToken,
    login_provider: 'google'
});

// Apple 로그인
const data = await v7api('user.socialLogin', {
    id_token: idToken,
    login_provider: 'apple'
});
```

**curl 예시**:
```bash
curl -s -X POST "https://local.philgo.com:443/api.php" \
  -H "Content-Type: application/json" \
  -d '{"method": "user.socialLogin", "id_token": "LOCAL_BANANA_TOKEN", "login_provider": "google"}'
```

**응답 형식**:
```json
{
    "idx": 123,
    "id": "user@gmail.com",
    "name": "홍길동",
    "nickname": "길동이",
    "firebase_uid": "abc123...",
    "login_provider": "google",
    "point": 500,
    "level": 2,
    "level_progress": 50
}
```

#### 3.3.1 동시 호출 Race Condition 방지 — createOrUpdate() 패턴

`user.socialLogin` 및 `user.me`(자동 회원 가입 경로)에서는 사용자 레코드 생성 시
**`UserRepository::createOrUpdate()`** 메서드를 사용한다.

**문제 배경 (Race Condition):**
앱 기동 직후 또는 여러 탭에서 동시에 로그인 API를 호출하면, 아직 레코드가 없는 상태에서
두 요청이 거의 동시에 `INSERT`를 실행하여 `Duplicate Key Error(1062)`가 발생한다.
기존 `UserRepository::create()` 방식은 이 오류를 처리하지 못했다.

**해결책 — `INSERT ... ON DUPLICATE KEY UPDATE` 패턴:**

```php
// lib/user/UserRepository.php
public static function createOrUpdate(array $data): int
{
    $columns = array_keys($data);
    $placeholders = array_map(fn($col) => ":$col", $columns);

    // ON DUPLICATE KEY UPDATE: idx = LAST_INSERT_ID(idx) 만 실행
    // - INSERT 성공 시: 새 AUTO_INCREMENT idx 반환
    // - UNIQUE 충돌(UPDATE) 시: 기존 idx 를 LAST_INSERT_ID 로 설정하여 정확한 idx 반환
    // 기존 사용자의 닉네임 등 변경된 데이터는 덮어쓰지 않음
    $sql = "INSERT INTO " . self::TABLE . " (" . implode(', ', $columns) . ")"
        . " VALUES (" . implode(', ', $placeholders) . ")"
        . " ON DUPLICATE KEY UPDATE idx = LAST_INSERT_ID(idx)";

    return Db::insert($sql, $data);
}
```

**동작 원리:**

| 상황 | INSERT 결과 | 반환값 |
|------|------------|--------|
| **신규 사용자** | INSERT 성공 | 새로 생성된 AUTO_INCREMENT idx |
| **기존 사용자 (단일 호출)** | UNIQUE 충돌 → UPDATE 실행 | `LAST_INSERT_ID(idx)` = 기존 idx |
| **동시 호출 (Race Condition)** | 두 번째 호출은 UNIQUE 충돌 → UPDATE 실행 | 기존 idx 반환 (에러 없음) |

**적용 위치:**

| 메서드 | 변경 전 | 변경 후 |
|--------|---------|---------|
| `UserService::socialLogin()` | `UserRepository::create()` | `UserRepository::createOrUpdate()` |
| `UserService::getMe()` (자동 회원 가입 경로) | `UserRepository::create()` | `UserRepository::createOrUpdate()` |

**주의사항:**
- `ON DUPLICATE KEY UPDATE`에서 `idx = LAST_INSERT_ID(idx)` **만** 갱신한다. 닉네임, 포인트 등 사용자가 변경한 데이터는 절대 덮어쓰지 않는다.
- UNIQUE 제약이 설정된 컬럼(`firebase_uid`, `id`)이 `$data`에 반드시 포함되어야 충돌 감지가 작동한다.
- `Db::insert()` 내부에서 `PDO::lastInsertId()`를 호출하므로, UNIQUE 충돌 시 `LAST_INSERT_ID(idx)` 덕분에 올바른 기존 idx가 반환된다.

---

### 3.4 공개 프로필 페이지 (SSR)

> 공개 프로필은 API 엔드포인트가 아니라 **v7 웹 페이지(SSR)**로 구현되어 있다.
> `UserService`와 `PostRepository` 메서드를 직접 호출하여 서버에서 렌더링한다.

| 항목 | 값 |
|------|-----|
| **URL** | `/user/public-profile` |
| **파일** | `v7/user/public-profile.php` (PHP), `v7/user/public-profile.css` (CSS) |
| **파라미터** | `idx_member` (선택): 사용자 idx, `firebase_uid` (선택): Firebase UID |
| **우선순위** | `firebase_uid` → `idx_member` → 로그인 사용자 (둘 다 없을 때) |

**URL 예시**:
```
# idx_member로 조회
https://v7-local.philgo.com/user/public-profile?idx_member=123

# firebase_uid로 조회
https://v7-local.philgo.com/user/public-profile?firebase_uid=abc123

# 파라미터 없음 → 로그인 사용자 프로필 표시
https://v7-local.philgo.com/user/public-profile
```

**사용하는 Service/Repository 메서드**:

| 메서드 | 설명 |
|--------|------|
| `UserService::getByFirebaseUid($uid)` | firebase_uid로 사용자 조회 → `UserEntity\|null` |
| `UserService::getPublicProfile($idx)` | idx로 공개 프로필 조회 → `UserEntity` (없으면 RuntimeException) |
| `PostRepository::findPostsByIdxMember($idx, $limit)` | 사용자의 최근 글 목록 조회 |
| `PostRepository::findCommentsByIdxMember($idx, $limit)` | 사용자의 최근 댓글 목록 조회 |
| `AuthService::getLoginUser()` | 로그인 사용자 확인 (본인 프로필 여부 판단) |

**페이지 구성**:

| 영역 | 설명 |
|------|------|
| **프로필 헤더** | 아바타, 닉네임, 통계(글 수/댓글 수/레벨), 액션 버튼 |
| **액션 버튼** | 본인: 회원정보 수정 / 타인: 채팅, 글 목록, 코멘트 목록 / 공통: 글, 코멘트 |
| **최근 글** | `findPostsByIdxMember()` — 최근 5개, 제목+날짜 |
| **최근 댓글** | `findCommentsByIdxMember()` — 최근 5개, 내용 미리보기+날짜 |
| **에러 상태** | 사용자 없음, 로그인 필요 시 에러 카드 표시 |

#### 3.4.a 디자인 구조 (보더리스 디자인)

v7 디자인 표준에 따라 **보더 없는 디자인**을 적용한다. `wa-card` 태그를 사용하지 않으며, 영역 구분은 연한 배경색(`#f8fafc`)으로 한다.

**아이콘 규칙**: 모든 아이콘은 Font Awesome **Light 스타일**(`fal`) 전용이다. `fa-solid`, `fa-regular` 사용 금지.

```html
<!-- ✅ 올바른 사용 -->
<i class="fal fa-pen-to-square"></i>
<i class="fal fa-comments"></i>
<i class="fal fa-star"></i>
<i class="fal fa-user-pen"></i>

<!-- ❌ 금지 -->
<i class="fa-solid fa-pen-to-square"></i>
<i class="fa-regular fa-comments"></i>
```

**디자인 요소별 구조**:

| 요소 | 구현 방식 | 핵심 CSS |
|------|----------|----------|
| **에러 상태** | `<div class="profile-error-card">` (wa-card 미사용) | `background: #f8fafc; border-radius: 16px; border 없음` |
| **프로필 헤더** | `<section class="profile-header-section">` | 보더/배경 없음, 중앙 정렬, flex-column |
| **아바타** | `<img class="profile-avatar">` 또는 `<div class="profile-avatar-placeholder">` | 120px 원형 (모바일 96px), **보더 없음**, placeholder: `background: var(--wa-color-brand-95, #e7f5ff)`, 아이콘 색: `var(--wa-color-brand-50, #3178c0)` |
| **통계** | 숫자+레이블 스타일 (`profile-stat-item`) | Instagram 스타일, 숫자 강조(1.1rem bold) + 레이블(0.7rem subtle), `flex` + `gap: 2.5rem` |
| **최근 글/댓글 섹션** | `<section class="profile-recent-section">` | `background: #f8fafc; border-radius: 12px; border 없음` |
| **글/댓글 아이템** | `<a class="profile-post-item">` / `<a class="profile-comment-item">` | hover 시 `background: #fff`, 구분선: `border-top: 1px solid #f1f5f9` (매우 연한 선) |
| **빈 상태** | `<div class="profile-empty">` | 아이콘 `opacity: 0.5`, 텍스트 `neutral-60` |

**통계 영역 핵심 코드** (Instagram 스타일 숫자+레이블):
```php
<div class="profile-stats">
    <div class="profile-stat-item">
        <span class="profile-stat-number"><?= number_format($user->no_of_post) ?></span>
        <span class="profile-stat-label">글</span>
    </div>
    <div class="profile-stat-item">
        <span class="profile-stat-number"><?= number_format($user->no_of_comment) ?></span>
        <span class="profile-stat-label">댓글</span>
    </div>
    <div class="profile-stat-item">
        <span class="profile-stat-number"><?= number_format($user->level) ?></span>
        <span class="profile-stat-label">레벨</span>
    </div>
</div>
```

**글/코멘트 목록 링크 — idx_member 기반 전체 게시판 조회**:

공개 프로필의 "글" 버튼, "코멘트" 버튼, "더보기" 링크는 `Route::url()`을 사용하여 해당 사용자의 전체 게시판 글/코멘트를 조회한다:
```php
<!-- 글 버튼 -->
<wa-button variant="neutral" appearance="outlined" size="small"
    href="<?= \V7\Utils\Route::url('/post/list', ['idx_member' => $user->idx]) ?>">
    <i slot="start" class="fal fa-list"></i> 글
</wa-button>

<!-- 코멘트 버튼 -->
<wa-button variant="neutral" appearance="outlined" size="small"
    href="<?= \V7\Utils\Route::url('/post/comments', ['idx_member' => $user->idx]) ?>">
    <i slot="start" class="fal fa-comment-lines"></i> 코멘트
</wa-button>

<!-- 더보기 링크 -->
<a href="<?= \V7\Utils\Route::url('/post/list', ['idx_member' => $user->idx]) ?>">
    더보기 <i class="fal fa-chevron-right"></i>
</a>
```

> **중요**: `url()->post->list->community`는 `post_id=freetalk`만 전달하므로, 특정 사용자의 전체 게시판 글을 조회하려면 반드시 `Route::url('/post/list', ['idx_member' => $user->idx])`를 사용해야 한다.
> 코멘트 버튼은 `/post/comments?idx_member=N` 경로로 이동하여 해당 사용자의 코멘트 목록을 조회한다.

**에러 상태 핵심 코드**:
```php
<div class="profile-error-card">
    <i class="fal fa-circle-exclamation profile-error-icon"></i>
    <h2>프로필을 볼 수 없음</h2>
    <p><?= htmlspecialchars($errorMessage) ?></p>
    <wa-button variant="brand" href="<?= url()->home ?>">
        <i slot="start" class="fal fa-house"></i>
        홈으로 돌아가기
    </wa-button>
</div>
```

**CSS 핵심 규칙**:

```css
/* 보더리스 디자인 — wa-card 미사용, 배경색으로 영역 구분 */
.profile-error-card {
    background: #f8fafc;
    border-radius: 16px;
    /* border 없음 */
}

.profile-avatar {
    border-radius: 50%;
    object-fit: cover;
    /* border 없음 */
}

.profile-avatar-placeholder {
    background: var(--wa-color-brand-95, #e7f5ff);  /* 연한 브랜드 배경 */
    color: var(--wa-color-brand-50, #3178c0);        /* 브랜드 아이콘 색상 */
}

.profile-recent-section {
    background: #f8fafc;
    border-radius: 12px;
    /* border 없음 */
}

.profile-post-item:hover,
.profile-comment-item:hover {
    background: #fff;  /* hover 시 흰색 배경 */
}
```

**통계 영역 CSS**:
```css
.profile-stats {
    display: flex;
    align-items: center;
    gap: 2.5rem;
}
.profile-stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.1rem;
}
.profile-stat-number {
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--wa-color-neutral-10, #1e293b);
}
.profile-stat-label {
    font-size: 0.7rem;
    color: var(--wa-color-neutral-60, #64748b);
}
```

**액션 버튼 구성**:

| 버튼 | 조건 | URL | 아이콘 |
|------|------|-----|--------|
| **회원정보 수정** | 본인 프로필 | `url()->user->profile` | `fal fa-user-pen` |
| **채팅** | 타인 프로필 | `/chat/index?uid={firebase_uid}` | `fal fa-comments` |
| **글** | 공통 (항상 표시) | `Route::url('/post/list', ['idx_member' => N])` | `fal fa-list` |
| **코멘트** | 공통 (항상 표시) | `Route::url('/post/comments', ['idx_member' => N])` | `fal fa-comment-lines` |
| **즐겨찾기** | 타인 + 로그인 | JavaScript `bookmarkToggle()` | `fa-regular/fa-solid fa-star` |
| **차단** | 타인 + 로그인 | JavaScript `toggleBlockMember()` | `fal fa-ban` |

> "글" 버튼 다음에 "코멘트" 버튼이 위치하며, `/post/comments?idx_member=N` 경로로 이동한다.

**반응형**: 모바일(< 992px)에서 아바타 80px, 패딩/간격 축소. 반응형 규칙은 `public-profile.css` 하단의 `@media (max-width: 991.98px)` 블록에 정의.

**URL 헬퍼**:
```php
// v7 url() 함수로 공개 프로필 링크 생성
url()->user->publicProfile(123)   // → '/user/public-profile?idx_member=123'
url()->user->publicProfile()      // → '/user/public-profile'
```

#### 3.4.1 UserService::getByFirebaseUid()

```php
/**
 * Firebase UID로 사용자를 조회한다.
 *
 * @param string $firebaseUid Firebase UID
 * @return UserEntity|null 사용자 Entity 또는 null
 */
public static function getByFirebaseUid(string $firebaseUid): ?UserEntity
```

- 빈 문자열 전달 시 `null` 반환
- 존재하지 않는 UID → `null` 반환
- 반환된 UserEntity에 `password` 미포함
- `level`, `level_progress`는 동적 계산

#### 3.4.2 PostRepository::findPostsByIdxMember()

```php
/**
 * 특정 사용자가 작성한 글 목록을 조회한다.
 *
 * @param int $idxMember 사용자 idx
 * @param int $limit 조회 개수 (기본 5)
 * @return array 글 배열 [{idx, subject, post_id, stamp, no_of_comment, good}, ...]
 */
public static function findPostsByIdxMember(int $idxMember, int $limit = 5): array
```

- `idx_parent = 0` (최상위 글만), `deleted = 0`, `blind = ''` 조건
- `stamp DESC` 정렬
- 존재하지 않는 사용자 → 빈 배열 반환

#### 3.4.3 PostRepository::findCommentsByIdxMember()

```php
/**
 * 특정 사용자가 작성한 댓글 목록을 조회한다.
 *
 * @param int $idxMember 사용자 idx
 * @param int $limit 조회 개수 (기본 5)
 * @return array 댓글 배열 [{idx, idx_root, post_id, content, stamp}, ...]
 */
public static function findCommentsByIdxMember(int $idxMember, int $limit = 5): array
```

- `idx_parent > 0` (댓글만), `deleted = 0`, `blind = ''` 조건
- `content`는 256자로 잘라서 반환 (`SUBSTRING(content, 1, 256)`)
- `stamp DESC` 정렬

#### 3.4.4 PEST 유닛 테스트

테스트 파일: `tests/Unit/PublicProfileTest.php` (15개 테스트, 30 assertions)

| describe 블록 | 테스트 수 | 검증 내용 |
|---------------|----------|----------|
| `UserService::getByFirebaseUid()` | 5 | 빈 문자열, 존재하지 않는 UID, 정상 조회, password 미포함, level 계산 |
| `UserService::getPublicProfile()` | 2 | 정상 조회, 존재하지 않는 idx → RuntimeException |
| `PostRepository::findPostsByIdxMember()` | 4 | 배열 반환, 빈 배열, limit 적용, 필수 키 포함 |
| `PostRepository::findCommentsByIdxMember()` | 4 | 배열 반환, 빈 배열, limit 적용, 필수 키 포함 |

---

### 3.5 user.updateMyProfile - 회원 정보 수정

| 항목 | 값 |
|------|-----|
| **method** | `user.updateMyProfile` |
| **HTTP** | `POST /api.php` (body: `{method: "user.updateMyProfile", ...}`) |
| **인증** | 필수 — 로그인 상태 (세션 또는 id_token) |
| **응답** | `UserEntity` (수정된 사용자 정보) |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `nickname` | string | 선택 | 닉네임 (변경 가능한 경우만 적용, 2자 이상 한글/영문/숫자/_) |
| `name` | string | 선택 | 실명 |
| `gender` | string | 선택 | 성별 (M/F/"") |
| `photo_url` | string | 선택 | 프로필 사진 URL |
| `birth_year` | int/string | 선택 | 생년 (예: 1990) |
| `birth_month` | int/string | 선택 | 생월 (1~12) |
| `birth_day` | int/string | 선택 | 생일 (1~31) |

**정수 필드 빈 문자열 변환 규칙**:

> `birth_year`, `birth_month`, `birth_day`는 DB에서 정수 컬럼(`smallint`/`tinyint`)이다.
> 프론트엔드에서 빈 문자열(`''`)이 전달될 수 있으므로(select에서 미선택 시),
> `UserService::update()`에서 **빈 문자열을 `0`으로 자동 변환**한다.
> v6의 `intval()` 호환 로직이며, 이를 통해 `SQLSTATE[22007]` 에러를 방지한다.

| 입력값 | 변환 결과 | 설명 |
|--------|----------|------|
| `''` (빈 문자열) | `0` | 미선택 상태 |
| `'2000'` (문자열 숫자) | `2000` | 폼에서 전송된 값 |
| `1990` (정수) | `1990` | 정상 정수 |

**닉네임 변경 정책**:
1. 닉네임이 비어있으면 최초 설정 가능 (자유롭게 설정)
2. 닉네임이 있고 `varchar_8`(이전 닉네임)이 비어있으면 1회 변경 가능
3. `varchar_8`이 있으면 변경 불가 (이미 1회 변경함)
4. 닉네임 변경 시 기존 닉네임이 `varchar_8` 컬럼에 저장됨

**닉네임 검증 규칙**:
- 최소 2자 이상
- 허용 문자: 한글, 영문, 숫자, 밑줄(`_`)
- 중복 닉네임 사용 불가

**JavaScript 호출 예시 (v7 홈페이지)**:
```javascript
// 프로필 업데이트
await v7api('user.updateMyProfile', {
    name: '홍길동',
    gender: 'M',
    birth_year: 1990,
    birth_month: 3,
    birth_day: 15,
});

// 닉네임 변경 (변경 가능한 경우)
await v7api('user.updateMyProfile', { nickname: '새닉네임' });

// 프로필 사진 변경
const uploadResult = await v7apiUpload(file, 'user', 'profile_photo');
await v7api('user.updateMyProfile', { photo_url: uploadResult.url });
```

**내부 처리 흐름**:
```
UserController::updateMyProfile($input)
  └─ UserService::updateMyProfile($input)
       ├─ AuthService::getLoginUser() → 로그인 사용자 확인
       ├─ $input['idx'] = $user->idx  (자동 설정)
       └─ UserService::update($input) → 실제 DB 업데이트
```

**관련 메서드**:

| 메서드 | 설명 |
|--------|------|
| `UserService::updateMyProfile(array $input)` | 로그인 사용자의 프로필 수정 (idx 자동 설정) |
| `UserService::canChangeNickname(array $user)` | 닉네임 변경 가능 여부 판단 |
| `UserService::update(array $input)` | 실제 DB 업데이트 수행 |

---

### 3.6 회원 정보 수정 페이지 (SSR)

> 회원 정보 수정은 v7 웹 페이지(SSR + Vue.js CSR)로 구현되어 있다.
> PHP에서 초기 데이터를 렌더링하고, Vue.js에서 폼 제출과 사진 업로드를 처리한다.

| 항목 | 값 |
|------|-----|
| **URL** | `/user/profile` |
| **파일** | `v7/user/profile.php` (PHP), `v7/user/profile.css` (CSS) |
| **인증** | 필수 — 비로그인 시 로그인 안내 표시 |
| **API 호출** | `v7api('user.updateMyProfile', {...})`, `v7apiUpload(file, 'user', 'profile_photo')` |

**페이지 구성**:

| 영역 | 설명 |
|------|------|
| **비로그인 안내** | `wa-callout` 경고 + 로그인 버튼 |
| **프로필 사진** | 원형 150px, 카메라 아이콘 오버레이 클릭으로 업로드 |
| **닉네임** | 변경 가능 여부에 따라 readonly/editable 전환 |
| **이름** | 텍스트 입력 |
| **성별** | 라디오 버튼 (남성/여성/선택안함) |
| **생년월일** | 3개 select (연도/월/일) |
| **저장 버튼** | `wa-button` loading 상태 지원 |
| **하단 링크** | 공개 프로필 보기 링크 |

**Vue.js 데이터 초기화** (PHP → JS):
```javascript
data() {
    return {
        photoUrl: <?= json_encode($loginUser->photo_url) ?>,
        nickname: <?= json_encode($loginUser->nickname) ?>,
        name: <?= json_encode($loginUser->name) ?>,
        gender: <?= json_encode($loginUser->gender) ?>,
        birthYear: <?= json_encode((string) ($loginUser->birth_year ?: '')) ?>,
        birthMonth: <?= json_encode((string) ($loginUser->birth_month ?: '')) ?>,
        birthDay: <?= json_encode((string) ($loginUser->birth_day ?: '')) ?>,
        canChangeNickname: <?= $canChangeNickname ? 'true' : 'false' ?>,
    };
}
```

> **주의**: 생년월일 값은 `(string)` 캐스팅 필수 — `<select>` option value는 문자열이므로 v-model과 타입 일치 필요.

**사진 업로드 흐름**:
```
1. 프로필 사진 영역 클릭 → hidden <input type="file"> 트리거
2. v7apiUpload(file, 'user', 'profile_photo') → 파일 업로드
3. v7api('user.updateMyProfile', { photo_url: url }) → URL 저장
4. photoUrl 업데이트 → 화면 반영
```

**URL 헬퍼**:
```php
url()->user->profile    // → '/user/profile'
```

**PEST 유닛 테스트**:

테스트 파일: `tests/Unit/UserProfileTest.php` (13개 테스트, 22 assertions)

| describe 블록 | 테스트 수 | 검증 내용 |
|---------------|----------|----------|
| `UserService::canChangeNickname()` | 6 | 빈 닉네임, 공백 닉네임, 변경 가능, 변경 불가, 키 누락 케이스 |
| `UserService::updateMyProfile()` | 1 | 비로그인 시 RuntimeException |
| `UserController::updateMyProfile()` | 1 | 비로그인 시 RuntimeException |
| `UserEntity 생일/이전닉네임 필드` | 5 | birth_year/month/day, previous_nickname 필드 존재, toArray() 포함, 기본값 |

---

### 3.7 user.search - 닉네임으로 사용자 검색

| 항목 | 값 |
|------|-----|
| **method** | `user.search` |
| **HTTP** | `GET /api.php?method=user.search&nickname=홍길` 또는 `POST /api.php` (body: `{method: "user.search", nickname: "홍길"}`) |
| **파라미터** | `nickname` (string, 필수) — 검색할 닉네임 키워드 |
| **인증** | 선택 — 로그인 시 본인 제외 |
| **응답** | 검색된 사용자 배열 `[{idx, nickname, firebase_uid, photo_url}, ...]` |

**파라미터 상세**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `nickname` | string | 필수 | 검색할 닉네임 키워드. 비어있으면 `RuntimeException` 발생 |

**검색 동작**:
- prefix 매칭 방식으로 검색한다 (`LIKE 'keyword%'`)
- 최대 **20건**까지 반환한다
- 로그인 상태인 경우, 본인은 검색 결과에서 제외된다

**curl 예시**:
```bash
# GET 방식
curl -s "https://v7-local.philgo.com/api.php?method=user.search&nickname=홍길"

# POST 방식 (JSON)
curl -s -X POST "https://v7-local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{"method": "user.search", "nickname": "홍길"}'
```

**JavaScript 호출 예시**:
```javascript
const users = await v7api('user.search', { nickname: '홍길' });
// users: [{idx: 123, nickname: '홍길동', firebase_uid: 'abc...', photo_url: '...'}, ...]
```

**응답 형식** (성공):
```json
[
    {
        "idx": 123,
        "nickname": "홍길동",
        "firebase_uid": "abc123...",
        "photo_url": "https://file.philgo.com/..."
    },
    {
        "idx": 456,
        "nickname": "홍길순",
        "firebase_uid": "def456...",
        "photo_url": ""
    }
]
```

**에러 응답**:
```json
{
    "success": false,
    "message": "nickname은 필수입니다."
}
```

**에러 케이스**:

| 조건 | 에러 메시지 |
|------|-----------|
| `nickname` 미전달 또는 빈 문자열 | `RuntimeException('nickname은 필수입니다.')` |

**내부 처리 흐름**:
```
UserController::search($input)
  └─ UserService::searchByNickname($input)
       ├─ nickname 빈 값 체크 → RuntimeException
       ├─ AuthService::getLoginUser() → 로그인 사용자 확인 (선택적)
       ├─ LIKE 'keyword%' 쿼리 (prefix 매칭)
       ├─ LIMIT 20
       └─ 로그인 시 본인 idx 제외
```

**관련 소스 파일**:

| 파일 | 설명 |
|------|------|
| `lib/user/UserController.php` | `search()` 메서드 — API 엔드포인트 |
| `lib/user/UserService.php` | `searchByNickname()` 메서드 — 비즈니스 로직 |
| `tests/Unit/UserSearchTest.php` | PEST 유닛 테스트 |

---

## 4. 파일 구조

```
lib/user/
├── UserController.php            # ★ Philgo\User\UserController (API 엔드포인트)
├── UserService.php               # ★ Philgo\User\UserService (비즈니스 로직)
├── UserRepository.php            # ★ Philgo\User\UserRepository (sf_member DB CRUD — RepositoryInterface 구현)
├── UserEntity.php                # ★ Philgo\User\UserEntity (사용자 엔티티)
├── user.functions.php            # ⚠️ 레거시 (새 코드에서 사용 금지)
├── user.login.functions.php      # ⚠️ 레거시
├── user.block.php                # ⚠️ 레거시
├── user.resign.functions.php     # ⚠️ 레거시
└── member-block.functions.php    # ⚠️ 레거시

v7/user/
├── profile.php                   # ★ 회원 정보 수정 페이지 (Vue.js + v7api)
├── profile.css                   # ★ 회원 정보 수정 전용 CSS
├── public-profile.php            # ★ 공개 프로필 페이지 (SSR, 보더리스 디자인, fal 아이콘, wa-tag 통계)
├── public-profile.css            # ★ 공개 프로필 전용 CSS (보더 없음, #f8fafc 배경, brand-95 placeholder)
├── login.php                     # ★ 로그인 페이지
└── login.css                     # ★ 로그인 전용 CSS

tests/Unit/
├── UserControllerTest.php        # ★ UserController PEST Unit Test
├── UserServiceTest.php           # ★ UserService PEST Unit Test (41개 테스트 — Repository 위임 검증)
├── UserRepositoryTest.php        # ★ UserRepository PEST Unit Test (33개 테스트 — CRUD, Firebase UID, 닉네임, 목록, 활동, 신고)
├── UserProfileTest.php           # ★ 프로필 수정 PEST Unit Test (canChangeNickname, updateMyProfile, Entity 필드)
├── PublicProfileTest.php         # ★ 공개 프로필 PEST Unit Test (getByFirebaseUid, getPublicProfile, PostRepository)
└── UserSearchTest.php            # ★ 닉네임 검색 PEST Unit Test (searchByNickname, prefix 매칭, 본인 제외)

lib/utils/
├── AuthService.php               # ★ Philgo\Utils\AuthService (2경로 인증: 세션 + Firebase)
├── FirebaseService.php           # ★ Philgo\Utils\FirebaseService (Firebase ID Token 검증)
├── Db.php                        # ★ Philgo\Utils\Db (DB 연결)
└── RequestUtils.php              # ★ Philgo\Utils\RequestUtils (입력 처리)
```

### 4.1 UserController

```php
// lib/user/UserController.php
namespace Philgo\User;

class UserController
{
    /**
     * 총 사용자 수 조회
     * API: method=user.count
     *
     * GET 호출 예시:
     *   https://local.philgo.com:443/api.php?method=user.count
     */
    public function count(array $input): array
    {
        $count = UserService::getTotalCount();
        return ['count' => $count];
    }

    /**
     * 현재 로그인한 회원 정보 조회
     * API: method=user.me
     *
     * GET 호출 예시:
     *   https://local.philgo.com:443/api.php?method=user.me
     *   https://local.philgo.com:443/api.php?method=user.me&id_token={Firebase ID Token}
     *
     * @param array $input 입력 파라미터 (session_id: 선택적)
     * @return array 사용자 정보 배열 (password 제외)
     * @throws \RuntimeException 비로그인 시
     */
    public function me(array $input): array
    {
        return UserService::getMe();
    }
}
```

### 4.2 UserService

```php
// lib/user/UserService.php
namespace Philgo\User;

use Philgo\Utils\AuthService;
use Philgo\Utils\Db;
use PDO;
use RuntimeException;

class UserService
{
    /**
     * 총 사용자 수를 반환한다.
     */
    public static function getTotalCount(): int
    {
        $stmt = Db::pdo()->prepare("SELECT COUNT(*) as cnt FROM sf_member");
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($row === false) {
            throw new RuntimeException('사용자 수 조회에 실패했습니다.');
        }
        return (int) $row['cnt'];
    }

    /**
     * 현재 로그인한 사용자 정보를 리턴한다.
     *
     * AuthService를 통해 세션 검증 후 사용자 레코드를 조회한다.
     * password 필드는 보안을 위해 제거하고 리턴한다.
     * point 기반으로 level과 level_progress를 동적으로 계산하여 포함한다.
     *
     * Firebase ID Token이 있으나 sf_member에 레코드가 없는 경우,
     * Firebase Auth에서 사용자 정보를 조회하여 자동으로 회원 가입을 수행한다.
     *
     * @return UserEntity 사용자 엔티티 (password 제외, level/level_progress 동적 계산)
     * @throws RuntimeException 비로그인 시
     */
    public static function getMe(): UserEntity
    {
        $user = AuthService::getLoginUser();
        if ($user !== null) {
            return $user;
        }

        // Firebase ID Token이 있으면 자동 회원 가입 시도
        $input = RequestUtils::all();
        $idToken = (string)($input['id_token'] ?? '');
        if ($idToken === '') {
            throw new RuntimeException('로그인이 필요합니다.');
        }

        // Firebase ID Token 검증
        $claims = FirebaseService::verifyIdTokenWithClaims($idToken);
        $firebaseUid = $claims['uid'];

        // sf_member에서 다시 확인 (AuthService 캐싱 대비)
        $existing = Db::fetch("SELECT * FROM sf_member WHERE firebase_uid = ?", [$firebaseUid]);
        if ($existing !== false) {
            AuthService::loginUser($existing);
            unset($existing['password']);
            return new UserEntity($existing);
        }

        // Firebase Auth에서 상세 정보 조회 후 sf_member에 INSERT (자동 회원 가입)
        $firebaseUser = self::getFirebaseAuthUser($firebaseUid);
        // ... email, displayName, photoUrl, phoneNumber, provider 조합
        // ... Db::insert() → sf_member에 레코드 생성
        // ... AuthService::loginUser() → 세션 쿠키 저장

        return new UserEntity($row);
    }

    /**
     * 포인트 기반 사용자 레벨 계산 (레거시 get_user_level()와 동일 로직)
     * POINT_LEVELS 배열에서 포인트보다 큰 첫 번째 값의 인덱스를 리턴
     */
    public static function calculateLevel(int $points): int { /* ... */ }

    /**
     * 다음 레벨까지 진행률 계산 (0~100, 레거시 get_user_level_progress()와 동일 로직)
     */
    public static function calculateLevelProgress(int $points, int $level): int { /* ... */ }

    /**
     * Firebase RTDB에 사용자 정보(닉네임, 프로필 사진)를 동기화한다.
     * v6 레거시 user.functions.php:784-804의 동일 로직을 v7 구조로 구현.
     *
     * RTDB 경로: users/{firebaseUid}
     * 동기화 필드: nickname, nicknameLowerCase(소문자 변환), photoUrl
     *
     * @param string $firebaseUid Firebase UID
     * @param string|null $nickname 닉네임 (null이면 동기화하지 않음)
     * @param string|null $photoUrl 프로필 사진 URL (null이면 동기화하지 않음)
     */
    public static function syncUserToFirebase(string $firebaseUid, ?string $nickname = null, ?string $photoUrl = null): void { /* ... */ }
}
```

### 4.3 PSR-4 Autoload 설정

```json
// composer.json
{
    "autoload": {
        "psr-4": {
            "Philgo\\Utils\\": "lib/utils/",
            "Philgo\\User\\": "lib/user/"
        }
    }
}
```

---

## 5. 인증 시스템 (AuthService + FirebaseService)

### 5.1 개요

v7 `api.php`는 `boot.php`를 포함하지 않으므로 레거시 `login()` 함수를 사용할 수 없다.
`AuthService`와 `FirebaseService`가 v6의 인증 로직을 v7에서 **독립적으로** 구현한다.

**핵심 원칙**: v7은 가능한 기존 레거시 함수를 사용하지 않고, v7 자체 코드로 독립 구현한다.

| 파일 | 네임스페이스 | 역할 |
|------|-------------|------|
| `lib/utils/AuthService.php` | `Philgo\Utils\AuthService` | 2경로 인증 (세션 + Firebase) |
| `lib/utils/FirebaseService.php` | `Philgo\Utils\FirebaseService` | Firebase ID Token 검증 |

### 5.2 2경로 인증 흐름

클라이언트(앱/웹)는 API 호출 시 항상 **Firebase ID Token**을 `id_token` 파라미터로 보낸다.
`session_id`는 서버 SSR에서 쿠키를 통해서만 사용된다.

```
AuthService::getLoginUser()
    │
    ├─ [경로 1] 세션 기반 인증 (SSR/CURL용)
    │  └─ $_COOKIE['session_id'] 또는 파라미터 session_id 확인
    │     → 세션 ID 형식 검증: "{MD5해시}-{idx}"
    │     → DB 조회: SELECT * FROM sf_member WHERE idx = ?
    │     → firebase_uid 존재 확인
    │     → 해시 검증: md5(LOGIN_SALT + idx + firebase_uid + phone_number)
    │     → 성공 시 사용자 배열 리턴
    │
    └─ [경로 2] Firebase ID Token 인증 (API용)
       └─ RequestUtils::get('id_token') 확인
          → FirebaseService::verifyIdToken($idToken) → Firebase UID 획득
          → DB 조회: SELECT * FROM sf_member WHERE firebase_uid = ?
          → 세션 ID 생성 → 쿠키 저장 (다음 요청부터 세션 기반 인증 가능)
          → 성공 시 사용자 배열 리턴
```

### 5.3 세션 ID 구조

```
세션 ID 형식: "{MD5해시}-{사용자idx}"
해시 생성: md5(LOGIN_SALT + idx + firebase_uid + phone_number) + '-' + idx

LOGIN_SALT: etc/app.config.php에서 정의 (api.php에서 require)
```

- 레거시 `generate_session_id()` 함수와 **동일한 로직**을 v7 자체 코드로 구현
- 쿠키명: `session_id` (레거시 `SESSION_ID` 상수와 동일)
- 쿠키 유효기간: 1년

### 5.4 AuthService 핵심 소스코드

```php
// lib/utils/AuthService.php
namespace Philgo\Utils;

use PDO;

class AuthService
{
    private const SESSION_KEY = 'session_id';
    private static ?array $cachedUser = null;
    private static bool $checked = false;

    /**
     * 현재 로그인한 사용자 정보를 리턴한다.
     * v6 login() 함수와 동일한 인증 흐름 (2경로).
     * 동일 요청 내에서 여러 번 호출해도 DB 조회는 1회만 수행 (static 캐싱).
     *
     * @return array|null sf_member 전체 컬럼, 비로그인 시 null
     */
    public static function getLoginUser(): ?array
    {
        if (self::$checked) return self::$cachedUser;
        self::$checked = true;

        // === 경로 1: 세션 기반 인증 (SSR/CURL용 - 쿠키 또는 파라미터의 session_id) ===
        $sessionId = $_COOKIE[self::SESSION_KEY] ?? RequestUtils::get(self::SESSION_KEY);
        if (!empty($sessionId)) {
            $user = self::getUserBySessionId($sessionId);
            if ($user !== null) {
                self::$cachedUser = $user;
                return self::$cachedUser;
            }
        }

        // === 경로 2: Firebase ID Token 인증 (API용 - id_token 파라미터) ===
        $idToken = RequestUtils::get('id_token');
        if (!empty($idToken)) {
            $user = self::getUserByIdToken($idToken);
            if ($user !== null) {
                self::setSessionCookie($user);
                self::$cachedUser = $user;
                return self::$cachedUser;
            }
        }

        return null;
    }

    /** 세션 ID로 사용자 검증 (SSR용) */
    private static function getUserBySessionId(string $sessionId): ?array
    {
        $parts = explode('-', $sessionId);
        if (count($parts) !== 2) return null;
        $idx = (int) $parts[1];
        if ($idx <= 0) return null;

        $stmt = Db::pdo()->prepare("SELECT * FROM sf_member WHERE idx = ?");
        $stmt->execute([$idx]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($user === false || empty($user)) return null;
        if (empty($user['firebase_uid'])) return null;
        if (self::generateSessionId($user) !== $sessionId) return null;
        return $user;
    }

    /** Firebase ID Token으로 사용자 검증 (API용) */
    private static function getUserByIdToken(string $idToken): ?array
    {
        $firebaseUid = FirebaseService::verifyIdToken($idToken);
        $stmt = Db::pdo()->prepare("SELECT * FROM sf_member WHERE firebase_uid = ?");
        $stmt->execute([$firebaseUid]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($user === false || empty($user)) return null;
        return $user;
    }

    /** 세션 ID 생성 (v7 자체 구현, 레거시 generate_session_id()와 동일 로직) */
    private static function generateSessionId(array $user): string
    {
        $hash = md5(
            LOGIN_SALT . $user['idx'] . $user['firebase_uid'] . ($user['phone_number'] ?? '')
        );
        return $hash . '-' . $user['idx'];
    }

    /** 세션 ID를 쿠키에 저장 (1년 유효) */
    private static function setSessionCookie(array $user): void
    {
        $sessionId = self::generateSessionId($user);
        setcookie(self::SESSION_KEY, $sessionId, time() + (86400 * 30 * 365), "/");
    }

    /** 캐시 초기화 (테스트용) */
    public static function reset(): void
    {
        self::$cachedUser = null;
        self::$checked = false;
    }
}
```

### 5.5 FirebaseService 핵심 소스코드

```php
// lib/utils/FirebaseService.php
namespace Philgo\Utils;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;

class FirebaseService
{
    /**
     * 테스트 토큰 매핑 (v6 config()->tokens와 동일)
     * Firebase 인증 없이 테스트할 수 있는 토큰 → Firebase UID 매핑
     */
    private const TEST_TOKENS = [
        'LOCAL_APPLE_TOKEN' => 'OSXtfcfdJkcLBovnQAC6Q1WMa2x1',   // apple@test.com
        'LOCAL_BANANA_TOKEN' => 'DA76oHESU0YnHo7i9lzu85vdirA2',  // banana@test.com
        'LOCAL_CHERRY_TOKEN' => 'jrCM6IwsuDMxY2t30pgzfRIjAil2',  // cherry@test.com
        'LIVE_ONE_TOKEN' => 'RaHIcr45pvPzYdcDIv6JoW8DnSH2',     // 프로덕션 테스트
    ];

    private static ?\Kreait\Firebase\Contract\Auth $authInstance = null;

    /**
     * Firebase ID Token을 검증하고 Firebase UID를 반환한다.
     *
     * 1. 테스트 토큰이면 Firebase 인증 우회하여 매핑된 UID 반환
     * 2. 실제 토큰이면 Kreait SDK로 검증 후 UID 반환
     *
     * @param string $token Firebase ID Token 또는 테스트 토큰
     * @return string Firebase UID
     * @throws \RuntimeException 토큰 검증 실패 시
     */
    public static function verifyIdToken(string $token): string
    {
        if (isset(self::TEST_TOKENS[$token])) {
            return self::TEST_TOKENS[$token];
        }

        try {
            $auth = self::getAuth();
            $verifiedIdToken = $auth->verifyIdToken($token, leewayInSeconds: 360);
            return $verifiedIdToken->claims()->get('sub');
        } catch (FailedToVerifyToken $e) {
            throw new \RuntimeException('Firebase 토큰 검증 실패: ' . $e->getMessage());
        }
    }

    /**
     * Firebase Auth 인스턴스 반환 (싱글톤)
     * 항상 philgo 프로덕션 프로젝트 사용
     */
    private static function getAuth(): \Kreait\Firebase\Contract\Auth
    {
        if (self::$authInstance === null) {
            $proj = 'philgo';
            $factory = (new Factory)
                ->withServiceAccount(ROOT_DIR . "/etc/{$proj}-firebase-service-account.json");
            self::$authInstance = $factory->createAuth();
        }
        return self::$authInstance;
    }

    /** 싱글톤 초기화 (테스트용) */
    public static function reset(): void
    {
        self::$authInstance = null;
    }
}
```

### 5.6 사용 패턴

```php
use Philgo\Utils\AuthService;

// 로그인 사용자 조회 (2경로 자동 처리)
$user = AuthService::getLoginUser();
if ($user === null) {
    throw new RuntimeException('로그인이 필요합니다.');
}
echo $user['name'];  // 사용자 이름

// 테스트 시 캐시 초기화
AuthService::reset();
```

### 5.7 테스트 토큰

개발/테스트 환경에서 Firebase 인증 없이 테스트할 수 있는 토큰:

| 테스트 토큰 | Firebase UID | 계정 |
|------------|-------------|------|
| `LOCAL_APPLE_TOKEN` | `OSXtfcfdJkcLBovnQAC6Q1WMa2x1` | apple@test.com |
| `LOCAL_BANANA_TOKEN` | `DA76oHESU0YnHo7i9lzu85vdirA2` | banana@test.com |
| `LOCAL_CHERRY_TOKEN` | `jrCM6IwsuDMxY2t30pgzfRIjAil2` | cherry@test.com |
| `LIVE_ONE_TOKEN` | `RaHIcr45pvPzYdcDIv6JoW8DnSH2` | 프로덕션 테스트 |

```bash
# 테스트 토큰으로 user.me 호출
curl -s "https://local.philgo.com:443/api.php?method=user.me&id_token=LIVE_ONE_TOKEN"
```

### 5.8 레거시 함수와의 관계

| v7 시스템 | 레거시 함수 | 파일 |
|-----------|------------|------|
| `AuthService::getLoginUser()` | `login()`, `get_user_from_session_id()` | `user.login.functions.php` |
| `AuthService::getUserBySessionId()` | `get_user_from_session_id()` | `user.login.functions.php:190-238` |
| `AuthService::getUserByIdToken()` | `verify_login()` | `user.login.functions.php:102-176` |
| `AuthService::generateSessionId()` | `generate_session_id()` | `generate_session_id.function.php` |
| `AuthService::setSessionCookie()` | `setcookie()` in `firebase_login()` | `user.login.functions.php:165` |
| `FirebaseService::verifyIdToken()` | `verifyFirebaseToken()` | `firebase.functions.php:69-79` |
| `FirebaseService::getAuth()` | `getFactory()`, `firebase_auth_admin()` | `firebase.functions.php:16-41` |
| `FirebaseService::TEST_TOKENS` | `config()->tokens` | `app.config.php:1080-1088` |

### 5.9 api.php 설정 상수 로드

`api.php`에서 인증에 필요한 설정 상수를 로드한다:

```php
// api.php
const ROOT_DIR = __DIR__;
require_once ROOT_DIR . '/vendor/autoload.php';
require_once ROOT_DIR . '/lib/constants.php';       // IDX, FIREBASE_UID 등
require_once ROOT_DIR . '/etc/app.config.php';      // LOGIN_SALT, ADMINS 등
```

---

## 6. 테스트

### 6.1 PEST Unit Test

**파일**: `tests/Unit/UserControllerTest.php`

```bash
# 실행
./vendor/bin/pest tests/Unit/UserControllerTest.php
```

**테스트 항목 (총 15개, 19 assertions)**:

| 그룹 | 테스트 | 설명 |
|------|--------|------|
| UserController | `count() - 배열을 반환한다` | Controller가 배열을 리턴하는지 확인 |
| UserController | `count() - count 키가 존재한다` | 반환값에 'count' 키 존재 확인 |
| UserController | `count() - count 값이 정수이다` | count 값의 타입 확인 |
| UserController | `count() - count 값이 0 이상이다` | count 값의 범위 확인 |
| UserService | `getTotalCount() - 정수를 반환한다` | Service 직접 호출 검증 |
| UserService | `getTotalCount() - 0 이상의 값을 반환한다` | Service 값 범위 검증 |
| UserService | `getMe() - 비로그인 시 RuntimeException 발생` | 비로그인 예외 처리 검증 |
| UserController::me() | `비로그인 시 RuntimeException 발생` | Controller 예외 전파 검증 |
| AuthService | `getLoginUser() - 비로그인 시 null 반환` | 인증 서비스 기본 동작 검증 |
| AuthService | `getLoginUser() - id_token 테스트 토큰으로 사용자 조회` | Firebase 토큰 인증 검증 |
| FirebaseService | `verifyIdToken() - LOCAL_APPLE_TOKEN` | 테스트 토큰 → UID 반환 |
| FirebaseService | `verifyIdToken() - LOCAL_BANANA_TOKEN` | 테스트 토큰 → UID 반환 |
| FirebaseService | `verifyIdToken() - LOCAL_CHERRY_TOKEN` | 테스트 토큰 → UID 반환 |
| FirebaseService | `verifyIdToken() - LIVE_ONE_TOKEN` | 테스트 토큰 → UID 반환 |
| FirebaseService | `verifyIdToken() - 유효하지 않은 토큰` | RuntimeException 발생 확인 |

**테스트 코드 핵심**:
```php
use Philgo\User\UserController;
use Philgo\User\UserService;

beforeAll(function () {
    if (!defined('ROOT_DIR')) {
        define('ROOT_DIR', dirname(dirname(__DIR__)));
    }
    require_once ROOT_DIR . '/vendor/autoload.php';
    require_once ROOT_DIR . '/lib/constants.php';
    require_once ROOT_DIR . '/etc/app.config.php';
});
```

### 6.2 curl 테스트

```bash
# 파라미터 없이 호출 → 에러
curl -s "https://local.philgo.com:443/api.php"
# → {"success":false,"message":"method 파라미터가 필요합니다."}

# user.count 호출 → 성공
curl -s "https://local.philgo.com:443/api.php?method=user.count"
# → {"count":188186}

# user.me 호출 (비로그인) → 에러
curl -s "https://local.philgo.com:443/api.php?method=user.me"
# → {"success":false,"message":"로그인이 필요합니다."}

# user.me 호출 (테스트 토큰으로 인증) → 성공
curl -s "https://local.philgo.com:443/api.php?method=user.me&id_token=LIVE_ONE_TOKEN"
# → {"idx":...,"id":"...","name":"...",...}

# user.me 호출 (쿠키로 SSR 인증) → 성공
curl -s -b "session_id={세션ID}" "https://local.philgo.com:443/api.php?method=user.me"
# → {"idx":123,"id":"user@test.com","name":"홍길동",...}
```

---

## 7. 레벨 계산 시스템

### 7.1 핵심 원칙

> **🔴🔴🔴 절대 규칙: 회원 레벨은 DB에서 가져오는 것이 아니라, 포인트에서 동적으로 계산한다 🔴🔴🔴**

| 규칙 | 설명 |
|------|------|
| **DB level 컬럼 사용 금지** | `sf_member.level` 컬럼은 **레거시 필드**이며, 업데이트되지 않는다. 이 값을 읽어서 사용하면 안 된다 |
| **항상 동적 계산** | 레벨은 `point` 값을 기반으로 **매번 동적으로 계산**한다 |
| **POINT_LEVELS 상수 기준** | `etc/app.config.php`에 정의된 `POINT_LEVELS` 상수(128단계)를 기준으로 계산한다 |
| **v7 함수 사용** | `UserService::calculateLevel(int $points)` 과 `UserService::calculateLevelProgress(int $points, int $level)` 사용 |
| **레거시 함수 참조** | v7 함수는 레거시 `get_user_level()`, `get_user_level_progress()`와 **100% 동일한 로직** |

**절대 금지 코드 예시**:
```php
// ❌ 금지: DB에서 level 필드를 읽어서 사용
$level = (int)($member['level'] ?? 0);

// ❌ 금지: DB의 level 컬럼을 직접 조회
$stmt = Db::pdo()->prepare("SELECT level FROM sf_member WHERE idx = ?");

// ✅ 올바른 방법: point에서 동적 계산
$points = (int)($member['point'] ?? 0);
$level = UserService::calculateLevel($points);
$levelProgress = UserService::calculateLevelProgress($points, $level);
```

### 7.2 POINT_LEVELS 상수 (128단계)

`etc/app.config.php`에 정의된 배열 상수이다. 인덱스가 레벨, 값이 해당 레벨에 도달하기 위한 **최소 누적 포인트**이다.

```php
// etc/app.config.php
const POINT_LEVELS = [
    0,          // 레벨 0: 0P 이상
    400,        // 레벨 1: 400P 이상
    1600,       // 레벨 2: 1,600P 이상
    3600,       // 레벨 3: 3,600P 이상
    6400,       // 레벨 4: 6,400P 이상
    10000,      // 레벨 5: 10,000P 이상
    // ... (중간 생략)
    14400,      // 레벨 6
    19600,      // 레벨 7
    25600,      // 레벨 8
    32400,      // 레벨 9
    40000,      // 레벨 10
    // ...
    1000000,    // 레벨 50: 1,000,000P 이상
    // ...
    4000000,    // 레벨 100: 4,000,000P 이상
    // ...
    20000000,   // 레벨 125: 20,000,000P 이상
    30000000,   // 레벨 126
    40000000,   // 레벨 127
];
// 총 128개 요소 (인덱스 0~127)
```

**레벨 구간 요약**:

| 레벨 구간 | 필요 포인트 범위 | 특징 |
|-----------|-----------------|------|
| 0~5 | 0 ~ 10,000P | 초급 (빠른 레벨업) |
| 6~20 | 14,400 ~ 160,000P | 중급 |
| 21~50 | 176,400 ~ 1,000,000P | 고급 |
| 51~100 | 1,040,400 ~ 4,000,000P | 상급 |
| 101~127 | 4,100,000 ~ 40,000,000P | 최상급 (느린 레벨업) |

### 7.3 레벨 계산 알고리즘

`UserService::calculateLevel(int $points): int`

POINT_LEVELS 배열을 순회하면서, 보유 포인트보다 큰 첫 번째 값의 **인덱스**를 레벨로 반환한다.

```php
// lib/user/UserService.php
public static function calculateLevel(int $points): int
{
    $level = 0;
    foreach (POINT_LEVELS as $idx => $point) {
        if ($points < $point) {
            $level = $idx;
            break;
        }
    }
    return $level;
}
```

**동작 원리**:
```
보유 포인트: 5,000P

POINT_LEVELS 순회:
  [0] = 0      → 5000 < 0?    No
  [1] = 400    → 5000 < 400?   No
  [2] = 1600   → 5000 < 1600?  No
  [3] = 3600   → 5000 < 3600?  No
  [4] = 6400   → 5000 < 6400?  Yes → level = 4 ★

결과: 레벨 4
```

### 7.4 레벨 진행률 계산 알고리즘

`UserService::calculateLevelProgress(int $points, int $level): int`

현재 레벨에서 다음 레벨까지의 진행률을 0~100 정수로 반환한다.

```php
// lib/user/UserService.php
public static function calculateLevelProgress(int $points, int $level): int
{
    $currentLevelPoints = POINT_LEVELS[$level - 1] ?? 0;  // 현재 레벨 시작점
    $nextLevelPoints = POINT_LEVELS[$level] ?? 0;          // 다음 레벨 시작점

    $pointsNeeded = $nextLevelPoints - $currentLevelPoints; // 레벨업에 필요한 총 포인트
    $pointsEarned = $points - $currentLevelPoints;          // 현재 레벨에서 획득한 포인트

    if ($pointsNeeded > 0) {
        return (int) floor(($pointsEarned / $pointsNeeded) * 100);
    }
    return 0;
}
```

**공식**:
```
진행률 = floor((보유포인트 - 현재레벨기준점) / (다음레벨기준점 - 현재레벨기준점) × 100)
```

### 7.5 계산 예시

| 보유 포인트 | 레벨 | 현재 레벨 기준점 | 다음 레벨 기준점 | 진행률 계산 | 진행률 |
|:----------:|:----:|:---------------:|:---------------:|:----------:|:-----:|
| 0 | 0 | 0 | 0 | - | 0% |
| 500 | 1 | 0 | 400 | (500-0)/(400-0)×100 | 125% → 100+ |
| 1000 | 1 | 0 | 400 | (1000-0)/(400-0)×100 | 250% → 100+ |
| 2000 | 2 | 400 | 1600 | (2000-400)/(1600-400)×100 | 133% → 100+ |
| 5000 | 4 | 3600 | 6400 | (5000-3600)/(6400-3600)×100 | **50%** |
| 8000 | 4 | 3600 | 6400 | (8000-3600)/(6400-3600)×100 | 157% → 100+ |
| 10000 | 5 | 6400 | 10000 | (10000-6400)/(10000-6400)×100 | **100%** |
| 100000 | 14 | 78400 | 90000 | (100000-78400)/(90000-78400)×100 | **186%** → 100+ |

> **참고**: 진행률이 100%를 초과할 수 있다. 이는 POINT_LEVELS 구간이 비선형이기 때문이며,
> 클라이언트에서 `min(progress, 100)`으로 캡핑하여 표시한다.

### 7.6 레거시 함수와의 관계

| v7 함수 | 레거시 함수 | 파일 위치 |
|---------|------------|----------|
| `UserService::calculateLevel(int $points)` | `get_user_level(int $points)` | `lib/point.functions.php:19-29` |
| `UserService::calculateLevelProgress(int $points, int $level)` | `get_user_level_progress(int $points)` | `lib/point.functions.php:42-57` |
| (POINT_LEVELS 상수 공유) | (POINT_LEVELS 상수 공유) | `etc/app.config.php:156-304` |

> v7과 레거시 함수는 **동일한 POINT_LEVELS 상수**를 사용하므로 결과가 항상 일치한다.
> 레거시 UserModel(`lib/models/user.model.php:87-88`)도 생성자에서 동적 계산을 수행한다.

### 7.7 v7 API에서의 레벨 반환 규칙

v7 API에서 회원 레벨을 응답에 포함할 때는 **반드시 동적 계산**해야 한다:

```php
// ✅ 올바른 패턴 (v7 API에서 레벨 반환)
$points = (int)($member['point'] ?? 0);
$level = UserService::calculateLevel($points);
$levelProgress = UserService::calculateLevelProgress($points, $level);

return [
    'point' => $points,
    'lv' => $level,
    'level_progress' => $levelProgress,
    // ...
];
```

**적용 위치**:

| API | 파일 | 레벨 반환 방식 |
|-----|------|--------------|
| `user.me` | `UserService::getMe()` | `calculateLevel($points)` + `calculateLevelProgress()` |
| `event.spin` | `EventService::spin()` | `UserService::calculateLevel($finalPoint)` + `UserService::calculateLevelProgress()` |
| `UserEntity` | `UserEntity::__construct()` | 생성자에서 `UserService::calculateLevel($this->point)` 자동 계산 |

---

## 8. UserEntity

### 8.1 개요

`Philgo\User\UserEntity` — `sf_member` 테이블의 한 행(row)을 PHP 객체로 매핑하는 Entity 클래스이다.

**핵심**: `level`과 `level_progress`는 DB에서 읽는 것이 아니라, **생성자에서 `point` 기반으로 동적 계산**한다.

**파일**: `lib/user/UserEntity.php`

### 8.2 프로퍼티

| 프로퍼티 | 타입 | DB 컬럼 | 설명 |
|---------|------|---------|------|
| `idx` | int | `sf_member.idx` | 회원 고유 ID |
| `id` | string | `sf_member.id` | 아이디 (이메일) |
| `name` | string | `sf_member.name` | 이름 |
| `nickname` | string | `sf_member.nickname` | 닉네임 |
| `phone_number` | string | `sf_member.phone_number` | 전화번호 |
| `firebase_uid` | string | `sf_member.firebase_uid` | Firebase UID |
| `login_provider` | string | `sf_member.login_provider` | 소셜 로그인 제공자 (**v7 홈페이지/앱 전용**). 값: `google`, `apple`, `kakaotalk`, `naver`, `phone_sign_in` 등 |
| `point` | int | `sf_member.point` | 보유 포인트 |
| `level` | int | ⚠️ **동적 계산** | 회원 레벨 (DB level 컬럼 미사용) |
| `level_progress` | int | ⚠️ **동적 계산** | 다음 레벨까지 진행률 (0~100%) |
| `photo_url` | string | `sf_member.photo_url` | 프로필 사진 URL |
| `gender` | string | `sf_member.gender` | 성별 (M/F) |
| `birth_year` | int | `sf_member.birth_year` | 생년 (예: 1990) |
| `birth_month` | int | `sf_member.birth_month` | 생월 (1~12) |
| `birth_day` | int | `sf_member.birth_day` | 생일 (1~31) |
| `previous_nickname` | string | `sf_member.varchar_8` | 이전 닉네임 (닉네임 1회 변경 시 저장) |
| `no_of_post` | int | `sf_member.no_of_post` | 작성 글 수 |
| `no_of_comment` | int | `sf_member.no_of_comment` | 작성 댓글 수 |
| `stamp` | int | `sf_member.stamp` | 생성/수정 시간 |

### 8.3 사용 예시

```php
use Philgo\User\UserEntity;

// DB 조회 결과에서 Entity 생성
$stmt = Db::pdo()->prepare("SELECT * FROM sf_member WHERE idx = ?");
$stmt->execute([123]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

$user = new UserEntity($row);
// 또는
$user = UserEntity::fromArray($row);

echo $user->point;          // 5000
echo $user->level;          // 4 (동적 계산됨)
echo $user->level_progress; // 50 (동적 계산됨)

// API 응답용 배열 변환
$responseData = $user->toArray();
// → ['idx' => 123, 'level' => 4, 'level_progress' => 50, ...]
```

### 8.4 password 필드 미포함

`UserEntity`는 보안상 `password` 필드를 포함하지 않는다.
`toArray()`로 변환한 결과를 API 응답으로 직접 사용할 수 있다.

---

## 9. 사용자 설정 페이지 (SSR)

### 9.1 개요

사용자 설정 페이지(`v7/user/settings.php`)는 v6 `user/settings.php`를 v7 아키텍처로 재작성한 페이지이다.
Web Awesome Pro 컴포넌트 기반, SSR 렌더링 방식으로 구현되었다.

| 항목 | 값 |
|------|---|
| **페이지 파일** | `v7/user/settings.php` |
| **CSS 파일** | `v7/user/settings.css` |
| **URL** | `/user/settings` |
| **URL 헬퍼** | `url()->user->settings` |
| **테스트 파일** | `tests/Browser/SettingsTest.php` |

### 9.2 표시 항목

| 항목 | 로그인 시 | 비로그인 시 |
|------|----------|------------|
| **로그인 방식** | provider 이름 + 아이콘 (Google, Apple, 카카오톡, 네이버, 전화번호 등) | 로그인 안내 + 로그인 버튼 |
| **이메일** | `sf_member.email` 값 (비어있으면 미표시) | - |
| **차단한 사용자** | `/user/blocked` 링크 (`url()->user->blocked`) | - |
| **운영자 문의** | `/contact` 링크 (항상 표시) | `/contact` 링크 (항상 표시) |

### 9.3 provider 조회

`UserEntity`에 `login_provider` 필드가 있으나 `email` 필드는 없으므로, `Db::fetch()`로 직접 조회한다.

```php
use Philgo\Utils\AuthService;
use Philgo\Utils\Db;

$loginUser = AuthService::getLoginUser();
if ($loginUser !== null) {
    $row = Db::fetch("SELECT email, login_provider FROM sf_member WHERE idx = ?", [$loginUser->idx]);
    if ($row !== false) {
        $email = $row['email'] ?? '';
        $provider = $row['login_provider'] ?? '';
    }
}
```

### 9.4 provider 표시명 매핑

| DB 값 | 표시명 | 아이콘 | 색상 |
|-------|--------|--------|------|
| `google` | Google | `fa-brands fa-google` | `#4285f4` |
| `apple` | Apple | `fa-brands fa-apple` | `#333333` |
| `kakaotalk` | 카카오톡 | `fa-solid fa-comment` | `#fee500` |
| `naver` | 네이버 | `fa-solid fa-n` | `#03c75a` |
| `phone_sign_in` | 전화번호 | `fa-solid fa-phone` | brand blue |
| 기타/빈값 | 알 수 없음 | `fa-solid fa-right-to-bracket` | neutral |

### 9.5 사이드바 메뉴

왼쪽 사이드바 로그인 위젯(`v7/widgets/layout/layout.sidebar-left.login.php`)에
"내 정보 / 내 글 / 채팅 / **설정**" 4개 빠른 메뉴가 표시된다.

### 9.6 v6과의 차이점

| 항목 | v6 | v7 |
|------|----|----|
| **전화번호 표시** | ✅ 표시 | ❌ 미표시 (provider + 이메일로 대체) |
| **언어 설정** | ✅ 표시 | ❌ 미표시 (v7은 단일 언어) |
| **로그인 provider** | ❌ 미표시 | ✅ provider명 + 아이콘 표시 |
| **이메일 표시** | ❌ 미표시 | ✅ 표시 |
| **운영자 문의** | ✅ 표시 | ✅ 표시 |
| **CSS 프레임워크** | Bootstrap 5 | Web Awesome Pro |

---

## 10. 사용자 차단 기능

### 10.1 개요

v7 사용자 차단 기능은 로그인 사용자가 특정 사용자를 차단하여 해당 사용자의 글과 댓글을 가릴 수 있는 기능이다.
차단 백엔드는 `lib/user/UserController.php`의 v7 Controller 메서드로 구현되어 있으며,
v7 프론트엔드에서 `v7api()` → `/api.php`를 통해 호출한다.

> **중요**: v6의 `/func.php` 호출 방식은 v7 세션(`session_id_v7`)과 호환되지 않으므로,
> 반드시 `v7api()` → `/api.php` → `UserController` 경로를 사용해야 한다.

> **🔴 절대 규칙: 차단/해제는 오직 v7 API를 통해서만 수행한다**
>
> 사용자 차단/해제는 반드시 필고 v7 API(`user.toggleBlock`, `user.unblock`)를 통해서만 수행해야 한다.
> Firebase RTDB에 직접 쓰기(`set(true)`, `remove()`)로 차단/해제하는 것은 **엄격히 금지**한다.
> v7 API가 MariaDB에 차단 정보를 저장한 후 Firebase RTDB에 자동 동기화(`UserService::syncBlockToFirebase()`)하므로,
> 채팅방에서는 Firebase RTDB 리스너(`listenBlockedUsers()`)로 차단 여부를 실시간 감지하여 UI에 반영하면 된다.

| 항목 | 값 |
|------|---|
| **v7 Controller** | `lib/user/UserController.php` (`toggleBlock`, `unblock`, `blockedList`) |
| **v7 Service** | `lib/user/UserService.php` (`syncBlockToFirebase`) |
| **차단 목록 페이지** | `v7/user/blocked.php` |
| **차단 목록 CSS** | `v7/user/blocked.css` |
| **JS 유틸리티** | `v7/js/block.js` |
| **URL** | `/user/blocked` |
| **URL 헬퍼** | `url()->user->blocked` |
| **설정 페이지 링크** | `v7/user/settings.php`에서 "차단한 사용자" 링크 표시 |
| **PEST 테스트** | `tests/Unit/MemberBlockTest.php` (16개 테스트) |
| **DB 테이블** | `sf_member_blocks` (`idx`, `idx_blocker`, `idx_blockee`, `created_at`) |
| **Firebase RTDB 경로** | `user-private/{blockerUid}/blocks/{blockeeUid}` (v7 API가 자동 동기화) |

### 10.2 v7 API 엔드포인트 (UserController)

`lib/user/UserController.php`에 차단 관련 3개 메서드가 정의되어 있다.
`AuthService::getLoginUser()`로 v7 세션 인증을 수행한다.
`user.toggleBlock`과 `user.unblock`은 차단/해제 후 `UserService::syncBlockToFirebase()`를 호출하여
Firebase RTDB에 자동 동기화한다 (채팅 앱에서 실시간 반영).

| API 메서드 | 설명 | 입력 | 반환 |
|------|------|------|------|
| `user.toggleBlock` | 차단/해제 토글 + Firebase RTDB 동기화 | `{ idx_blockee: int }` 또는 `{ blockee_firebase_uid: string }` | `{ idx_blockee, blocked: bool, message }` |
| `user.unblock` | 차단 해제 + Firebase RTDB 동기화 | `{ idx_blockee: int }` 또는 `{ blockee_firebase_uid: string }` | `{ idx_blockee, blocked: false, message }` |
| `user.blockedList` | 차단 목록 조회 | 없음 | `[{ idx, idx_blockee, nickname, photo_url, created_at }]` |

> **`blockee_firebase_uid` 파라미터**: 채팅방에서는 상대방의 Firebase UID만 알고 있으므로,
> `idx_blockee` 대신 `blockee_firebase_uid`를 전달할 수 있다.
> 서버에서 `UserService::getByFirebaseUid()`로 idx를 자동 변환하여 처리한다.

### 10.2.1 Firebase RTDB 동기화 (UserService)

`UserService::syncBlockToFirebase(int $idxBlocker, int $idxBlockee, bool $blocked)` 메서드가
차단/해제 시 Firebase RTDB에 동기화한다.

```php
// 차단 시: user-private/{blockerUid}/blocks/{blockeeUid} = true
// 해제 시: user-private/{blockerUid}/blocks/{blockeeUid} 삭제
UserService::syncBlockToFirebase($me->idx, $idxBlockee, true);  // 차단
UserService::syncBlockToFirebase($me->idx, $idxBlockee, false); // 해제
```

- Kreait Firebase Admin SDK를 사용하여 `PROD_DATABASE_URL`에 접근
- Firebase UID가 없는 사용자는 동기화 스킵
- 동기화 실패 시 로그만 남기고 차단/해제 기능은 정상 작동

### 10.3 JS API (block.js)

`v7/js/block.js`는 차단 관련 유틸리티 함수를 제공한다. 차단 기능이 필요한 페이지에서 `<script defer>` 태그로 로드한다.

- `v7/user/blocked.php` — 차단 목록 페이지
- `v7/post/view.php` — 글 읽기 페이지 (액션바 + 코멘트 차단 버튼에서 사용)

| 함수 | 설명 | 파라미터 |
|------|------|----------|
| `toggleBlockMember(idxBlockee)` | 차단 토글 (차단 ↔ 해제) → `v7api('user.toggleBlock', ...)` | 대상 사용자 idx |
| `unblockMember(idxBlockee)` | 차단 해제 → `v7api('user.unblock', ...)` | 대상 사용자 idx |
| `getBlockedMembers()` | 차단 목록 조회 → `v7api('user.blockedList', ...)` | 없음 |
| `confirmUnblockAndView(idxBlockee, type, targetUrl)` | 차단 해제 확인 다이얼로그 | 대상 idx, 'post'/'comment', 이동 URL |

### 10.4 차단된 콘텐츠 표시

#### 글 목록 (`post-list-tile.php`)

차단된 사용자의 글은 "차단된 사용자의 글입니다" 텍스트로 대체 표시된다.
클릭 시 `confirmUnblockAndView()`로 차단 해제 확인 다이얼로그가 표시된다.

```php
$_isBlockedPost = !empty($_blockedMemberIds) && in_array($post['idx_member'] ?? 0, $_blockedMemberIds);
```

#### 글 상세 (`view.php`)

- 관리자 차단(blind): `$post->isBlockedOrBlinded()` → "이 글은 관리자에 의해 차단되었습니다"
- 사용자 차단: `$isBlockedAuthor` → "차단된 사용자의 글입니다" + "차단 해제하고 내용 보기" 버튼
- 첨부파일도 차단 시 숨김 처리
- 액션바에 차단/해제 토글 버튼 (`post-actions.js` Vue 앱)
- `data-author-name` 속성으로 작성자 이름을 전달하여 confirm 메시지에 `"사용자명" 사용자를 차단하시겠습니까?` 형식으로 표시
- 차단 성공 시 `"사용자명" 사용자가 차단되었습니다.` alert 후 페이지 새로고침

#### 코멘트 (`view.php`)

- 관리자 차단: "차단된 댓글입니다"
- 사용자 차단: "차단된 사용자의 댓글입니다" + "해제하고 보기" 버튼
- 코멘트 첨부파일도 차단 시 숨김
- 각 코멘트 액션에 차단/해제 버튼 (`comment.js` Vue 앱)
- `data-author-name` 속성으로 댓글 작성자 이름을 전달하여 confirm 메시지에 표시

#### 공개 프로필 (`public-profile.php`)

- 타인 프로필에서 차단/해제 버튼 표시 (`toggleBlockMember()` 호출)
- 차단 상태에 따라 버튼 색상 변경 (danger/neutral)
- 차단 여부 확인은 `Db::fetch()`를 사용하여 `sf_member_blocks` 테이블을 조회

```php
// ✅ v7 방식: Db::fetch() 사용 (pdo() 사용 금지)
use Philgo\Utils\Db;

$isProfileBlocked = false;
if ($loginUser) {
    $blockRow = Db::fetch(
        "SELECT idx FROM sf_member_blocks WHERE idx_blocker = ? AND idx_blockee = ?",
        [$loginUser->idx, $user->idx]
    );
    $isProfileBlocked = $blockRow !== false;
}
```

> **주의**: 이전에 v6 `pdo()` 함수를 직접 호출하던 코드(`pdo()->prepare()` + `->execute()` + `->fetch()`)는
> v7 `Db::fetch()`로 교체되었다. v7 홈페이지(`v7/` 폴더)에서 `pdo()` 직접 호출은 금지이며,
> 반드시 `Philgo\Utils\Db` 클래스를 통해 DB에 접근해야 한다.

### 10.5 차단 목록 페이지 (`blocked.php`)

Vue.js CDN MPA 방식으로 구현된 차단 사용자 관리 페이지이다.

- **비로그인**: "로그인 후 이용해 주세요" + 로그인 버튼
- **로그인**: `getBlockedMembers()` API로 차단 목록 조회 → `wa-avatar` + 닉네임 + 차단일 + 해제 버튼
- **해제**: `unblockMember()` 호출 → 목록에서 실시간 제거
- **빈 목록**: "차단한 사용자가 없습니다" 표시

> **주의**: `wa-button`의 `:disabled` 바인딩은 Web Component 특성상 `null`을 반환해야 속성이 제거된다.
> `!!expr` 대신 `expr || null` 패턴을 사용해야 한다.

### 10.6 접근 경로

1. 설정 페이지 → "차단한 사용자" 링크 (`url()->user->settings` → `url()->user->blocked`)
2. 사이드바 설정 메뉴 → 설정 페이지 → 차단한 사용자 링크
3. 글 보기 → 액션바 차단/해제 버튼 (타인 글에만 표시)
4. 글 보기 → 코멘트 액션 차단/해제 버튼 (타인 댓글에만 표시)
5. 공개 프로필 → 차단 버튼

---

## 11. 사용자 신고 기능

### 11.1 개요

사용자를 신고하는 기능이다. 공개 프로필 페이지(`v7/user/public-profile.php`)에서 타인의 프로필을 신고할 수 있다.
글/코멘트 신고는 `post.report` API를 사용하며, 사용자 신고는 `user.reportUser` API를 사용한다.

### 11.2 user.reportUser — 사용자 신고 API

인증 필수.

```
GET https://local.philgo.com/api.php?method=user.reportUser&session_id=xxx&idx_reported=190076&reason=스팸
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| idx_reported | int | O | 신고 대상 사용자의 sf_member.idx |
| reason | string | X | 신고 사유 (기본값: 빈 문자열) |

**성공 응답:**

```json
{ "idx_reported": 190076, "message": "사용자를 신고했습니다." }
```

**에러 응답:**

| 메시지 | 상황 |
|--------|------|
| 로그인이 필요합니다. | 미인증 |
| idx_reported는 필수입니다. | idx_reported 누락 또는 0 |
| 자기 자신을 신고할 수 없습니다. | 본인 신고 시도 |
| 이미 신고한 사용자입니다. | 동일 사용자에 대한 중복 신고 |

**호출 경로:**

```
UserController::reportUser($input)
  → UserService::reportUser($idxReporter, $idxReported, $reason)
    → UserRepository::ensureUserReportsTable()  ← sf_user_reports 테이블 자동 생성
    → UserRepository::hasReported() 중복 확인
    → UserRepository::insertReport() 신고 등록
```

### 11.3 DB 테이블: sf_user_reports

사용자 신고 전용 테이블. `UserService::ensureUserReportsTable()`에서 자동 생성된다.

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int (PK, AUTO_INCREMENT) | 신고 레코드 ID |
| `idx_reporter` | int | 신고한 사용자의 sf_member.idx |
| `idx_reported` | int | 신고당한 사용자의 sf_member.idx |
| `reason` | varchar(255) | 신고 사유 (기본값: 빈 문자열) |
| `stamp` | int | 신고 시각 (Unix timestamp) |

**인덱스:**

| 인덱스 | 컬럼 | 설명 |
|--------|------|------|
| UNIQUE `unique_report` | `(idx_reporter, idx_reported)` | 동일 사용자 간 중복 신고 방지 |
| KEY `idx_reported` | `(idx_reported)` | 신고당한 사용자 기준 조회 |

### 11.4 관리자용 신고 사용자 목록 조회

`UserService::listReportedUsers($limit)`로 신고된 사용자 목록을 조회한다 (관리자 전용). 내부적으로 `UserRepository::findReportedUsers()`를 호출한다.

**반환 데이터:**

| 필드 | 설명 |
|------|------|
| `idx_reported` | 신고당한 사용자 idx |
| `nickname` | 닉네임 |
| `photo_url` | 프로필 사진 URL |
| `report_count` | 신고 횟수 |
| `last_report_stamp` | 최근 신고 시각 |
| `reasons` | 신고 사유 모음 (콤마 구분) |

### 11.5 공개 프로필 페이지 신고 버튼

`v7/user/public-profile.php`에서 타인 프로필에 신고 버튼이 표시된다.

```html
<wa-button id="profile-report-btn" variant="neutral" appearance="outlined" size="small"
           data-idx-reported="<?= $user->idx ?>"
           data-user-name="<?= htmlspecialchars($user->nickname) ?>">
    <i slot="start" class="fal fa-flag"></i> 신고
</wa-button>
```

**JavaScript 동작:**

1. 신고 버튼 클릭 → `confirm()` 확인 다이얼로그
2. 확인 시 `v7api('user.reportUser', { idx_reported: ... })` 호출
3. 성공 시 버튼 텍스트 "신고됨"으로 변경, variant를 `warning`으로 변경, 버튼 비활성화
4. 에러 시 원래 상태로 복원

### 11.6 관련 파일

| 파일 | 역할 |
|------|------|
| `lib/user/UserController.php` | `reportUser()` API 엔드포인트 |
| `lib/user/UserService.php` | `reportUser()`, `listReportedUsers()` 비즈니스 로직 (UserRepository에 위임) |
| `lib/user/UserRepository.php` | `ensureUserReportsTable()`, `hasReported()`, `insertReport()`, `findReportedUsers()` DB 접근 |
| `v7/user/public-profile.php` | 공개 프로필 신고 버튼 UI + JavaScript |
| `v7/admin/reports.php` | 관리자 신고 관리 페이지 (사용자 신고 탭) |

---

## 12. UserRepository

### 12.1 개요

`UserRepository`는 `sf_member` 테이블의 모든 DB 접근을 중앙 집중하는 Repository 클래스이다.
`RepositoryInterface`를 구현하여 표준 CRUD 4개 메서드를 제공하며,
Firebase UID 조회, 닉네임 관련, 목록/통계, 사용자 활동, 신고 관련 등 확장 쿼리를 포함한다.

- **파일**: `lib/user/UserRepository.php`
- **네임스페이스**: `Philgo\User\UserRepository`
- **테이블**: `sf_member` (CRUD), `sf_user_reports` (신고), `sf_post_data` (활동 조회)
- **인터페이스**: `implements RepositoryInterface`

**도입 배경**: UserService에서 `Db::` 직접 호출이 곳곳에 산재해 있어 DB 쿼리 중복 및 관심사 분리 위반 문제가 있었다.
리팩토링으로 UserService의 모든 DB 접근 코드를 UserRepository로 이관하여 `Db::` 직접 호출 0개를 달성했다.

**아키텍처 흐름:**

```
UserController → UserService → UserRepository → Db → MariaDB
                 (비즈니스 로직)   (DB CRUD)       (PDO)
```

### 12.2 RepositoryInterface 필수 메서드 (4개)

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `create` | `create(array $data): int` | sf_member에 새 사용자 삽입, AUTO_INCREMENT idx 반환 |
| `findByIdx` | `findByIdx(int $idx): ?UserEntity` | idx로 사용자 조회 (password 제외), 없으면 null |
| `update` | `update(int $idx, array $data): bool` | idx로 사용자 정보 수정 |
| `deleteByIdx` | `deleteByIdx(int $idx): bool` | idx로 사용자 삭제 |

### 12.3 Firebase UID 기반 조회

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `findByFirebaseUid` | `findByFirebaseUid(string $firebaseUid): ?UserEntity` | Firebase UID로 사용자 Entity 조회 (password 제외) |
| `findRawByFirebaseUid` | `findRawByFirebaseUid(string $firebaseUid): array\|false` | Firebase UID로 raw 배열 조회 (AuthService::loginUser()에 전달용) |
| `findRawByIdx` | `findRawByIdx(int $idx): array\|false` | idx로 raw 배열 조회 (AuthService::loginUser()에 전달용) |
| `findByFirebaseUids` | `findByFirebaseUids(array $firebaseUids): array` | 복수 Firebase UID로 일괄 조회 (최대 100개) |
| `getFirebaseUidByIdx` | `getFirebaseUidByIdx(int $idx): string` | idx로 Firebase UID만 경량 조회 |

### 12.4 닉네임 관련 조회

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `isNicknameTaken` | `isNicknameTaken(string $nickname, int $excludeIdx = 0): bool` | 닉네임 중복 검사 (자기 자신 제외 가능) |
| `searchByNickname` | `searchByNickname(string $nickname, ?int $excludeIdx = null, int $limit = 20): array` | 닉네임으로 사용자 검색 |
| `getNicknameInfo` | `getNicknameInfo(int $idx): array\|false` | 닉네임 + 변경 이력(varchar_8) 조회 |

### 12.5 목록/통계 조회

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `findAll` | `findAll(int $page = 1, int $limit = 20): array` | 사용자 목록 페이지네이션 조회 (password 제외) |
| `countAll` | `countAll(): int` | 전체 사용자 수 |
| `findRecent` | `findRecent(int $limit = 3): array` | 최근 가입 사용자 목록 |

### 12.6 사용자 활동 조회

sf_post_data 테이블에서 특정 사용자의 글/댓글을 조회한다.

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `findRecentPosts` | `findRecentPosts(int $idxMember, int $limit = 5): array` | 최근 글 목록 (deleted=0) |
| `findRecentComments` | `findRecentComments(int $idxMember, int $limit = 5): array` | 최근 댓글 목록 (idx_parent>0, deleted=0) |

### 12.7 사용자 신고 관련

sf_user_reports 테이블 관련 메서드이다.

| 메서드 | 시그니처 | 설명 |
|--------|----------|------|
| `ensureUserReportsTable` | `ensureUserReportsTable(): void` | sf_user_reports 테이블 자동 생성 (CREATE TABLE IF NOT EXISTS) |
| `hasReported` | `hasReported(int $idxReporter, int $idxReported): bool` | 중복 신고 여부 확인 |
| `insertReport` | `insertReport(int $idxReporter, int $idxReported, string $reason = ''): void` | 신고 등록 |
| `findReportedUsers` | `findReportedUsers(int $limit = 20): array` | 신고된 사용자 목록 (관리자 전용, GROUP BY + COUNT) |

### 12.8 UserService와의 관계

UserService는 비즈니스 로직(검증, 권한 확인, 데이터 가공 등)만 담당하고,
모든 DB 접근은 UserRepository를 통해 수행한다. `Db::` 직접 호출 0개.

**호출 예시:**

```php
// UserService::getMe() — 비즈니스 로직
public static function getMe(): array
{
    $me = AuthService::getLoginUser();
    if (!$me) {
        throw new RuntimeException('로그인이 필요합니다.');
    }
    // DB 접근은 UserRepository에 위임
    $entity = UserRepository::findByIdx((int) $me['idx']);
    // ... 비즈니스 로직 (레벨 계산, 필드 가공 등)
    return $entity->toArray();
}

// UserService::reportUser() — 비즈니스 로직
public static function reportUser(int $idxReporter, int $idxReported, string $reason = ''): void
{
    UserRepository::ensureUserReportsTable();
    if (UserRepository::hasReported($idxReporter, $idxReported)) {
        throw new RuntimeException('이미 신고한 사용자입니다.');
    }
    UserRepository::insertReport($idxReporter, $idxReported, $reason);
}
```

**테스트 현황:**

| 테스트 파일 | 테스트 수 | 대상 |
|------------|----------|------|
| `tests/Unit/UserRepositoryTest.php` | 33개 | CRUD, Firebase UID, 닉네임, 목록, 활동, 신고 |
| `tests/Unit/UserServiceTest.php` | 41개 | Service 비즈니스 로직 + Repository 위임 검증 |
| **합계** | **74개** | **100% 통과** |

---

## 13. Firebase RTDB 사용자 정보 동기화

### 13.1 개요

`UserService::syncUserToFirebase()` 메서드는 사용자의 닉네임과 프로필 사진 URL을
Firebase Realtime Database(RTDB)에 동기화한다.

이 기능은 v6 레거시 `user.functions.php`(784~804행)의 동일 로직을 v7 아키텍처(Service 계층)로 재구현한 것이다.
채팅 시스템 등 Firebase RTDB를 참조하는 클라이언트가 최신 사용자 정보를 실시간으로 조회할 수 있도록 한다.

| 항목 | 값 |
|------|-----|
| **메서드** | `UserService::syncUserToFirebase(string $firebaseUid, ?string $nickname, ?string $photoUrl): void` |
| **RTDB 경로** | `users/{firebaseUid}` |
| **동기화 필드** | `nickname`, `nicknameLowerCase`, `photoUrl` |
| **Firebase SDK** | Kreait Firebase Admin SDK (`FirebaseService::getDatabase()`) |
| **레거시 대응** | `user.functions.php:784-804` 동일 로직 |

### 13.2 syncUserToFirebase() 메서드

```php
// lib/user/UserService.php
public static function syncUserToFirebase(
    string $firebaseUid,
    ?string $nickname = null,
    ?string $photoUrl = null
): void {
    if ($firebaseUid === '') {
        return;
    }

    $up = [];
    if ($nickname !== null && $nickname !== '') {
        $up['nickname'] = $nickname;
        $up['nicknameLowerCase'] = strtolower($nickname);
    }
    if ($photoUrl !== null && $photoUrl !== '') {
        $up['photoUrl'] = $photoUrl;
    }

    if (empty($up)) {
        return;
    }

    try {
        $database = FirebaseService::getDatabase();
        $database->getReference('users/' . $firebaseUid)->update($up);
    } catch (\Exception $e) {
        Debug::log("Firebase RTDB 사용자 동기화 실패: " . $e->getMessage());
    }
}
```

**동기화 필드 상세**:

| RTDB 필드 | 값 | 설명 |
|-----------|-----|------|
| `nickname` | 원본 닉네임 | 화면 표시용 닉네임 |
| `nicknameLowerCase` | `strtolower($nickname)` | 대소문자 무시 검색용 (소문자 변환) |
| `photoUrl` | 프로필 사진 URL | 채팅 등에서 사용하는 프로필 사진 |

**동기화 조건**:
- `$firebaseUid`가 빈 문자열이면 즉시 반환 (동기화 스킵)
- `$nickname`이 null 또는 빈 문자열이면 nickname 관련 필드는 업데이트하지 않음
- `$photoUrl`이 null 또는 빈 문자열이면 photoUrl 필드는 업데이트하지 않음
- 모든 필드가 비어 있으면(`$up`이 빈 배열) 즉시 반환

### 13.3 호출 위치

`syncUserToFirebase()`는 사용자 정보가 변경되는 3곳에서 호출된다.

| 호출 위치 | 메서드 | 동기화 시점 | 동기화 데이터 |
|-----------|--------|------------|--------------|
| **회원 정보 수정** | `UserService::update()` | nickname 또는 photo_url이 변경된 경우에만 | 변경된 nickname, photo_url |
| **소셜 로그인** | `UserService::socialLogin()` | 신규/기존 사용자 로그인 완료 후 | nickname, photo_url |
| **자동 회원 가입** | `UserService::getMe()` | Firebase 인증 후 신규 사용자 자동 가입 시 | nickname, photo_url |

**각 호출 위치의 코드 패턴**:

```php
// 1. UserService::update() — nickname/photo_url 변경 시만 동기화
$syncNickname = $updateData['nickname'] ?? null;
$syncPhotoUrl = $updateData['photo_url'] ?? null;
if ($syncNickname !== null || $syncPhotoUrl !== null) {
    self::syncUserToFirebase($entity->firebase_uid, $syncNickname, $syncPhotoUrl);
}

// 2. UserService::socialLogin() — 소셜 로그인 완료 후
self::syncUserToFirebase(
    $firebaseUid,
    (string)($row['nickname'] ?? ''),
    (string)($row['photo_url'] ?? '')
);

// 3. UserService::getMe() — 신규 사용자 자동 가입 시
self::syncUserToFirebase(
    $firebaseUid,
    (string)($user['nickname'] ?? ''),
    (string)($user['photo_url'] ?? '')
);
```

### 13.4 RTDB 데이터 구조

```
Firebase Realtime Database
└── users/
    └── {firebaseUid}/
        ├── nickname: "홍길동"
        ├── nicknameLowerCase: "홍길동"
        └── photoUrl: "https://file.philgo.com/..."
```

> **참고**: `update()` 메서드를 사용하므로 해당 필드만 업데이트되며,
> `users/{firebaseUid}` 노드의 다른 기존 데이터(예: 채팅 관련 필드)는 보존된다.

### 13.5 에러 처리

- 동기화 실패 시 예외를 throw하지 않고 `Debug::log()`로 로그만 남긴다
- 메인 비즈니스 로직(회원 정보 수정, 소셜 로그인, 자동 가입)은 RTDB 동기화 실패와 무관하게 정상 작동한다
- 로그 경로: `var/debug.log`

> **10.2.1절의 `syncBlockToFirebase()`와의 관계**: 두 메서드 모두 `FirebaseService::getDatabase()`를 사용하여
> Firebase RTDB에 데이터를 동기화하는 동일한 패턴을 따른다. `syncUserToFirebase()`는 사용자 프로필 정보를,
> `syncBlockToFirebase()`는 차단 정보를 각각 다른 RTDB 경로에 동기화한다.
