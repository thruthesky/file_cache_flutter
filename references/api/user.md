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
JavaScript: func('user.me')
    │
    ▼ POST /api.php (body: {method: "user.me"})
    │
    ▼ api.php (PSR-4 Autoloading)
    │  └─ new UserController() → me($input)
    │
    ▼ Philgo\User\UserController::me()
    │  └─ UserService::getMe()
    │
    ▼ Philgo\User\UserService::getMe()
    │  ├─ AuthService::getLoginUser()  ← 쿠키/파라미터에서 session_id 읽기
    │  │  ├─ 세션 ID 파싱: "{MD5해시}-{idx}" → idx 추출
    │  │  ├─ Db::pdo() → SELECT * FROM sf_member WHERE idx = ?
    │  │  └─ 해시 검증: md5(salt + idx + firebase_uid + phone_number)
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
| **인증** | 필수 — 쿠키 `session_id` 또는 HTTP 파라미터 `session_id` |
| **파라미터** | `session_id` (선택적, 쿠키 없을 때 사용) |
| **성공 응답** | 사용자 정보 배열 (password 제외) |
| **에러 응답** | `{"success": false, "message": "로그인이 필요합니다."}` |

**인증 처리 흐름**:
1. `AuthService::getLoginUser()` → 쿠키/파라미터에서 `session_id` 추출
2. 세션 ID 형식 검증: `"{MD5해시}-{사용자idx}"` → `idx` 추출
3. DB에서 사용자 조회: `SELECT * FROM sf_member WHERE idx = ?`
4. 해시 검증: `md5(salt + idx + firebase_uid + phone_number) + '-' + idx` 비교
5. 모든 검증 통과 시 사용자 레코드 리턴 (password 필드 제거)

**curl 예시**:
```bash
# 비로그인 상태 → 에러
curl -s "https://local.philgo.com:443/api.php?method=user.me"
# → {"success":false,"message":"로그인이 필요합니다."}

# session_id 파라미터로 인증
curl -s "https://local.philgo.com:443/api.php?method=user.me&session_id={세션ID}"

# 쿠키로 인증
curl -s -b "session_id={세션ID}" "https://local.philgo.com:443/api.php?method=user.me"
```

**JavaScript 호출 예시**:
```javascript
// 로그인 상태에서 호출 (쿠키에 session_id 자동 포함)
const res = await func('user.me');
console.log(res.idx);    // 123
console.log(res.id);     // "user@test.com"
console.log(res.name);   // "홍길동"
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
    "stamp": 1700000000
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
├── AuthService.php               # ★ Philgo\Utils\AuthService (세션 인증)
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
     *   https://local.philgo.com:443/api.php?method=user.me&session_id={세션ID}
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

## 5. 인증 시스템 (AuthService)

### 5.1 개요

v7 `api.php`는 `boot.php`를 포함하지 않으므로 레거시 `login()` 함수를 사용할 수 없다.
`AuthService`는 레거시 세션 검증 로직(`user.login.functions.php`)을 v7 시스템에서 독립적으로 처리한다.

**파일**: `lib/utils/AuthService.php` | **네임스페이스**: `Philgo\Utils\AuthService`

### 5.2 세션 ID 구조

```
세션 ID 형식: "{MD5해시}-{사용자idx}"
해시 생성: md5(SALT + idx + firebase_uid + phone_number) + '-' + idx

SALT: "---secret_salt: withcenter philgo v6 server key: WA113A,*lvptB--- (update)"
```

- 레거시 `generate_session_id()` 함수와 **동일한 로직**을 사용
- 쿠키명: `session_id` (레거시 `SESSION_ID` 상수와 동일)

### 5.3 인증 흐름

```
1. 세션 ID 획득: $_COOKIE['session_id'] → 없으면 RequestUtils::get('session_id')
2. 형식 검증: explode('-', $sessionId) → [해시, idx]
3. DB 조회: SELECT * FROM sf_member WHERE idx = ?
4. firebase_uid 존재 확인 (없으면 로그인 불가)
5. 해시 검증: generateSessionId($user) === $sessionId
6. 모든 검증 통과 → 사용자 배열 리턴 (static 캐싱)
```

### 5.4 핵심 소스코드

```php
// lib/utils/AuthService.php
namespace Philgo\Utils;

use PDO;

class AuthService
{
    private const SALT = "---secret_salt: withcenter philgo v6 server key: WA113A,*lvptB--- (update)";
    private const SESSION_KEY = 'session_id';
    private static ?array $cachedUser = null;
    private static bool $checked = false;

    /**
     * 현재 로그인한 사용자 정보를 리턴한다.
     * 동일 요청 내에서 여러 번 호출해도 DB 조회는 1회만 수행 (static 캐싱).
     *
     * @return array|null sf_member 전체 컬럼, 비로그인 시 null
     */
    public static function getLoginUser(): ?array
    {
        if (self::$checked) return self::$cachedUser;
        self::$checked = true;

        $sessionId = $_COOKIE[self::SESSION_KEY] ?? RequestUtils::get(self::SESSION_KEY);
        if (empty($sessionId)) return null;

        // 세션 ID 형식: "{MD5해시}-{idx}"
        $parts = explode('-', $sessionId);
        if (count($parts) !== 2) return null;

        $idx = (int) $parts[1];
        if ($idx <= 0) return null;

        $stmt = Db::pdo()->prepare("SELECT * FROM sf_member WHERE idx = ?");
        $stmt->execute([$idx]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($user === false || empty($user)) return null;
        if (empty($user['firebase_uid'])) return null;

        // 세션 ID 해시 검증
        if (self::generateSessionId($user) !== $sessionId) return null;

        self::$cachedUser = $user;
        return self::$cachedUser;
    }

    /**
     * 세션 ID 생성 (레거시 generate_session_id()와 동일)
     */
    private static function generateSessionId(array $user): string
    {
        $hash = md5(self::SALT . $user['idx'] . $user['firebase_uid'] . ($user['phone_number'] ?? ''));
        return $hash . '-' . $user['idx'];
    }

    /** 캐시 초기화 (테스트용) */
    public static function reset(): void
    {
        self::$cachedUser = null;
        self::$checked = false;
    }
}
```

### 5.5 사용 패턴

```php
use Philgo\Utils\AuthService;

// 로그인 사용자 조회
$user = AuthService::getLoginUser();
if ($user === null) {
    throw new RuntimeException('로그인이 필요합니다.');
}
echo $user['name'];  // 사용자 이름

// 테스트 시 캐시 초기화
AuthService::reset();
```

### 5.6 레거시 함수와의 관계

| v7 시스템 (AuthService) | 레거시 함수 | 파일 |
|-------------------------|------------|------|
| `AuthService::getLoginUser()` | `login()`, `get_user_from_session_id()` | `user.login.functions.php` |
| `AuthService::generateSessionId()` | `generate_session_id()` | `user.login.functions.php:296-304` |
| `AuthService::SALT` | `$salt` 변수 | `user.login.functions.php:301` |
| `AuthService::SESSION_KEY` | `SESSION_ID` 상수 | `constants.php` |

---

## 6. 테스트

### 6.1 PEST Unit Test

**파일**: `tests/Unit/UserControllerTest.php`

```bash
# 실행
./vendor/bin/pest tests/Unit/UserControllerTest.php
```

**테스트 항목 (총 9개)**:

| 테스트 | 설명 |
|--------|------|
| `UserController → count() - 배열을 반환한다` | Controller가 배열을 리턴하는지 확인 |
| `UserController → count() - count 키가 존재한다` | 반환값에 'count' 키 존재 확인 |
| `UserController → count() - count 값이 정수이다` | count 값의 타입 확인 |
| `UserController → count() - count 값이 0 이상이다` | count 값의 범위 확인 |
| `UserService → getTotalCount() - 정수를 반환한다` | Service 직접 호출 검증 |
| `UserService → getTotalCount() - 0 이상의 값을 반환한다` | Service 값 범위 검증 |
| `UserService → getMe() - 비로그인 시 RuntimeException 발생` | 비로그인 예외 처리 검증 |
| `UserController::me() → 비로그인 시 RuntimeException 발생` | Controller 예외 전파 검증 |
| `AuthService → getLoginUser() - 비로그인 시 null 반환` | 인증 서비스 기본 동작 검증 |

**테스트 코드 핵심**:
```php
use Philgo\User\UserController;
use Philgo\User\UserService;

beforeAll(function () {
    if (!defined('ROOT_DIR')) {
        define('ROOT_DIR', dirname(dirname(__DIR__)));
    }
    require_once ROOT_DIR . '/vendor/autoload.php';
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

# user.me 호출 (세션ID 파라미터) → 성공
curl -s "https://local.philgo.com:443/api.php?method=user.me&session_id={세션ID}"
# → {"idx":123,"id":"user@test.com","name":"홍길동",...}
```
