# User API - v7 시스템 (PSR-4)

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. API 엔드포인트](#3-api-엔드포인트)
  - [3.1 user.count](#31-usercount---총-사용자-수-조회)
  - [3.2 user.me](#32-userme---현재-로그인-사용자-정보-조회)
- [4. 파일 구조](#4-파일-구조)
- [5. 인증 시스템 (AuthService)](#5-인증-시스템-authservice)
- [6. 테스트](#6-테스트)

---

## 1. 개요

사용자(User) 모듈의 v7 시스템 API이다.
`api.php`의 PSR-4 autoloading + Controller 기반 디스패치를 통해 호출된다.

- **DB 테이블**: `sf_member`
- **Controller**: `Philgo\User\UserController` (`lib/user/UserController.php`)
- **Service**: `Philgo\User\UserService` (`lib/user/UserService.php`)
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
    │  └─ Db::pdo() → SELECT COUNT(*) FROM sf_member
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
| **성공 응답** | 사용자 정보 배열 (sf_member 전체 컬럼, password 제외). `point`, `level` 등 포함 |
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
| `level` | int | 회원 레벨 (포인트 기반 산정) |
| `photo_url` | string | 프로필 사진 URL |
| `gender` | string | 성별 (M/F) |
| `no_of_post` | int | 작성한 글 수 |
| `no_of_comment` | int | 작성한 댓글 수 |
| `stamp` | int | 레코드 생성/수정 시간 (UNIX timestamp) |

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
console.log(res.point);  // 5000 (회원 포인트)
console.log(res.level);  // 2 (회원 레벨)
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

---

## 4. 파일 구조

```
lib/user/
├── UserController.php            # ★ Philgo\User\UserController (API 엔드포인트)
├── UserService.php               # ★ Philgo\User\UserService (비즈니스 로직)
├── user.functions.php            # ⚠️ 레거시 (새 코드에서 사용 금지)
├── user.login.functions.php      # ⚠️ 레거시
├── user.block.php                # ⚠️ 레거시
├── user.resign.functions.php     # ⚠️ 레거시
└── member-block.functions.php    # ⚠️ 레거시

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
     *
     * @return array 사용자 정보 배열 (password 제외)
     * @throws RuntimeException 비로그인 시
     */
    public static function getMe(): array
    {
        $user = AuthService::getLoginUser();
        if ($user === null) {
            throw new RuntimeException('로그인이 필요합니다.');
        }
        unset($user['password']);
        return $user;
    }
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
