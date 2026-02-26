---
name: new-philgo-skill
description: 필고(Philgo) 새로운 시스템(New System) 개발 스킬. PSR-4 Autoloading 기반 Controller + Service 아키텍처, api.php 디스패치, PEST Unit Test, 네임스페이스(Philgo\*) 등 필고 v6 새로운 시스템 코드를 개발할 때 사용합니다. 새로운 API 엔드포인트 추가, Controller/Service 클래스 생성, PEST 테스트 작성, PSR-4 모듈 추가, api.php 관련 작업, 새 시스템 마이그레이션 등을 작업할 때 이 스킬을 사용하세요.
---

# 필고 새로운 시스템 (New System) 개발 가이드

## 개요

이 스킬은 **필고 v6 새로운 시스템** 개발을 위한 전용 스킬입니다.
PSR-4 기반 Controller + Service 아키텍처로 API를 개발합니다.

### ⚠️⚠️⚠️ 핵심 원칙: 기존 필고 코드와 100% 공존 ⚠️⚠️⚠️

> **새로운 시스템은 기존 필고 프로젝트를 대체하는 것이 아닙니다.**
> **기존 코드와 완벽하게 공존하며, 기존의 모든 코드를 100% 지원합니다.**

| 원칙 | 설명 |
|------|------|
| **기존 코드 유지** | 기존 `boot.php`, `lib/*.functions.php`, `widget/` 등 레거시 코드는 **절대 수정하거나 삭제하지 않는다** |
| **동일 폴더 공존** | 새 시스템 파일(`UserController.php`)과 레거시 파일(`user.functions.php`)이 **같은 `lib/user/` 폴더에 공존**한다 |
| **동일 페이지 혼용** | 하나의 PHP 페이지에서 기존 코드(`page.header.php`, `pdo()`, `login()`)와 새 시스템(`UserService`, `DbUtils`)을 **함께 사용**할 수 있다 |
| **점진적 마이그레이션** | 기존 기능을 깨뜨리지 않으면서 **새 기능만 새 시스템으로** 추가한다 |
| **기존 DB/테이블 공유** | 새 시스템은 기존과 **동일한 MariaDB 데이터베이스와 테이블**을 사용한다 |
| **기존 프론트엔드 호환** | 기존 `func()` JavaScript 함수로 새 시스템 API도 호출 가능하다 |

**절대 금지 사항:**
- 기존 레거시 코드를 새 시스템 코드로 강제 전환하지 않는다
- 기존 `boot.php`의 함수(`pdo()`, `in()`, `login()` 등)를 제거하거나 변경하지 않는다
- 기존 페이지 동작을 깨뜨리는 변경을 하지 않는다

### 기존 스킬과의 관계

| 스킬 | 용도 |
|------|------|
| `philgo-skill` | 기존 레거시 시스템 (앱, 웹, API) 개발 |
| **`new-philgo-skill`** | **새로운 시스템 (PSR-4 Controller/Service) 개발 — 기존 코드와 공존** |

> 레거시 코드 작업 시에는 `philgo-skill`을, 새 시스템 API 작업 시에는 이 스킬을 사용합니다.
> **두 스킬은 상호 배타적이 아니며, 하나의 페이지에서 두 시스템을 동시에 사용할 수 있습니다.**

---

## 핵심 아키텍처

```
클라이언트 → api.php → Controller → Service → DB
                │
                ├─ vendor/autoload.php (PSR-4)
                ├─ RequestUtils::parseMethod() → [module, action]
                ├─ FQCN: "Philgo\{Module}\{Module}Controller"
                └─ $ctrl->$action($input) → JSON 응답
```

- **엔트리포인트**: `api.php` (boot.php 미포함)
- **네임스페이스**: `Philgo\{Module}\` (예: `Philgo\User\UserController`)
- **DB 접근**: `Philgo\Utils\DbUtils::pdo()` (레거시 `pdo()` 사용 금지)
- **입력 처리**: `Philgo\Utils\RequestUtils::all()` (레거시 `in()` 사용 금지)
- **에러 처리**: `throw new RuntimeException()` → api.php에서 catch → `{success: false}`
- **테스트**: PEST v4 Unit Test (`tests/Unit/`)

---

## 레퍼런스 문서

### 아키텍처 전체 → [architecture.md](references/architecture.md)

새로운 시스템의 전체 아키텍처, 설계 원칙, 폴더 구조, 부트 프로세스, API 시스템,
Entity 구조체, 함수 작성 규칙, 입출력/에러/DB 처리, 테스트 시스템, 마이그레이션 전략,
Vue.js CDN MPA 방식, Utils 클래스, PSR-4 Autoloading 설정, 문서 분할 규칙,
기존 코드와의 통합 사용 방법을 상세히 다룹니다. Controller 클래스의 멤버 함수에는
반드시 GET REST URL 호출 예시를 PHPDoc에 포함해야 하며, Composer autoload 설정과
네임스페이스 매핑(`Philgo\User\` → `lib/user/`, `Philgo\Utils\` → `lib/utils/`)을
정확히 따라야 합니다.

### 모듈별 API 문서 → [references/api/](references/api/)

| 모듈 | 문서 | 상태 |
|------|------|------|
| User | [api/user.md](references/api/user.md) | ✅ 완료 |

> 새 모듈을 추가할 때마다 `references/api/<module>.md` 문서를 작성합니다.

---

## 새 모듈 추가 워크플로우

1. `lib/<module>/` 폴더 생성
2. `<Module>Controller.php` 작성 (namespace `Philgo\<Module>`)
3. `<Module>Service.php` 작성 (비즈니스 로직)
4. `composer.json`에 PSR-4 매핑 추가: `"Philgo\\<Module>\\": "lib/<module>/"`
5. `composer dump-autoload` 실행
6. PEST Unit Test 작성 (`tests/Unit/<Module>ControllerTest.php`)
7. curl 및 테스트 실행으로 검증
8. `references/api/<module>.md` 문서 작성

---

## 기존 코드와의 통합

기존 페이지(page.header.php)에서 새 시스템 Service를 사용할 수 있습니다:

```php
<?php
include_once '../page.header.php';
require_once ROOT_DIR . '/vendor/autoload.php';

use Philgo\User\UserService;

$count = UserService::getTotalCount();
echo "<h1>총 사용자 수: {$count}</h1>";

include_once '../page.footer.php';
```

> `page.header.php`를 먼저 include한 후 `vendor/autoload.php`를 require합니다.
> (`ROOT_DIR` 상수가 `boot.php`에서 정의되기 때문)
