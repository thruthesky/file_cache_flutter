# User API - v7 시스템 (PSR-4)

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
- [3. API 엔드포인트](#3-api-엔드포인트)
- [4. 파일 구조](#4-파일-구조)
- [5. 테스트](#5-테스트)

---

## 1. 개요

사용자(User) 모듈의 v7 시스템 API이다.
`api.php`의 PSR-4 autoloading + Controller 기반 디스패치를 통해 호출된다.

- **DB 테이블**: `sf_member`
- **Controller**: `Philgo\User\UserController` (`lib/user/UserController.php`)
- **Service**: `Philgo\User\UserService` (`lib/user/UserService.php`)
- **API 접두사**: `user.*`
- **네임스페이스**: `Philgo\User`

---

## 2. 아키텍처

```
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
curl -s "https://local.philgo.com:444/api.php?method=user.count"

# POST 방식 (JSON)
curl -s -X POST "https://local.philgo.com:444/api.php" \
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
     *   https://local.philgo.com:444/api.php?method=user.count
     */
    public function count(array $input): array
    {
        $count = UserService::getTotalCount();
        return ['count' => $count];
    }
}
```

### 4.2 UserService

```php
// lib/user/UserService.php
namespace Philgo\User;

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
}
```

### 4.3 PSR-4 Autoload 설정

```json
// composer.json
{
    "autoload": {
        "psr-4": {
            "Philgo\\User\\": "lib/user/"
        }
    }
}
```

---

## 5. 테스트

### 5.1 PEST Unit Test

**파일**: `tests/Unit/UserControllerTest.php`

```bash
# 실행
./vendor/bin/pest tests/Unit/UserControllerTest.php
```

**테스트 항목**:

| 테스트 | 설명 |
|--------|------|
| `UserController → count() - 배열을 반환한다` | Controller가 배열을 리턴하는지 확인 |
| `UserController → count() - count 키가 존재한다` | 반환값에 'count' 키 존재 확인 |
| `UserController → count() - count 값이 정수이다` | count 값의 타입 확인 |
| `UserController → count() - count 값이 0 이상이다` | count 값의 범위 확인 |
| `UserService → getTotalCount() - 정수를 반환한다` | Service 직접 호출 검증 |
| `UserService → getTotalCount() - 0 이상의 값을 반환한다` | Service 값 범위 검증 |

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

### 5.2 curl 테스트

```bash
# 파라미터 없이 호출 → 에러
curl -s "https://local.philgo.com:444/api.php"
# → {"success":false,"message":"method 파라미터가 필요합니다."}

# user.count 호출 → 성공
curl -s "https://local.philgo.com:444/api.php?method=user.count"
# → {"count":188186}
```
