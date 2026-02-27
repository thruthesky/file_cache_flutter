---
name: v7-skill
description: 필고(Philgo) v7 시스템 개발 스킬. PSR-4 Autoloading 기반 Controller + Service 아키텍처, api.php 디스패치, PEST Unit Test, 네임스페이스(Philgo\*) 등 필고 v7 시스템 코드를 개발할 때 사용합니다. 새로운 API 엔드포인트 추가, Controller/Service 클래스 생성, PEST 테스트 작성, PSR-4 모듈 추가, api.php 관련 작업, v7 마이그레이션 등을 작업할 때 이 스킬을 사용하세요.
---

# 필고 v7 시스템 개발 가이드

## 개요

이 스킬은 **필고 v7 시스템** 개발을 위한 전용 스킬입니다.
PSR-4 기반 Controller + Service 아키텍처로 API를 개발합니다.

### ⚠️⚠️⚠️ 핵심 원칙: 기존 필고 코드와 100% 공존 ⚠️⚠️⚠️

> **v7 시스템은 기존 필고 프로젝트를 대체하는 것이 아닙니다.**
> **기존 코드와 완벽하게 공존하며, 기존의 모든 코드를 100% 지원합니다.**

| 원칙 | 설명 |
|------|------|
| **기존 코드 유지** | 기존 `boot.php`, `lib/*.functions.php`, `widget/` 등 레거시 코드는 **절대 수정하거나 삭제하지 않는다** |
| **동일 폴더 공존** | v7 파일(`UserController.php`)과 레거시 파일(`user.functions.php`)이 **같은 `lib/user/` 폴더에 공존**한다 |
| **동일 페이지 혼용** | 하나의 PHP 페이지에서 기존 코드(`page.header.php`, `pdo()`, `login()`)와 v7 시스템(`UserService`, `Db`)을 **함께 사용**할 수 있다 |
| **점진적 마이그레이션** | 기존 기능을 깨뜨리지 않으면서 **새 기능만 v7 시스템으로** 추가한다 |
| **기존 DB/테이블 공유** | v7 시스템은 기존과 **동일한 MariaDB 데이터베이스와 테이블**을 사용한다 |
| **기존 프론트엔드 호환** | 기존 `func()` JavaScript 함수로 v7 시스템 API도 호출 가능하다 |

**절대 금지 사항:**
- 기존 레거시 코드를 v7 시스템 코드로 강제 전환하지 않는다
- 기존 `boot.php`의 함수(`pdo()`, `in()`, `login()` 등)를 제거하거나 변경하지 않는다
- 기존 페이지 동작을 깨뜨리는 변경을 하지 않는다

### 기존 스킬과의 관계

| 스킬 | 용도 |
|------|------|
| `philgo-skill` | 기존 레거시 시스템 (앱, 웹, API) 개발 |
| **`v7-skill`** | **v7 시스템 (PSR-4 Controller/Service) 개발 — 기존 코드와 공존** |

> 레거시 코드 작업 시에는 `philgo-skill`을, v7 시스템 API 작업 시에는 이 스킬을 사용합니다.
> **두 스킬은 상호 배타적이 아니며, 하나의 페이지에서 두 시스템을 동시에 사용할 수 있습니다.**

---

## 🔴🔴🔴 백엔드 소스코드 참조 경로 (READ-ONLY) 🔴🔴🔴

> **필고 프로젝트의 PHP API 백엔드 소스코드 경로:**
> `/Users/thruthesky/apps/withcenter/philgo/www`

| 규칙 | 설명 |
|------|------|
| **📖 참고용으로 적극 활용** | v7 시스템 개발 시 기존 백엔드 코드의 로직, DB 쿼리, 비즈니스 규칙, 테이블 구조 등을 **반드시 참고**하여 일관성을 유지한다 |
| **🚫 절대 수정 금지** | 이 경로의 파일은 **어떤 상황에서도 절대로 수정, 삭제, 이동하지 않는다** |
| **🚫 쓰기 작업 금지** | `Edit`, `Write`, `Bash`(echo, sed, awk 등) 도구로 이 경로에 **어떠한 쓰기 작업도 수행하지 않는다** |

**⚠️⚠️⚠️ 이 백엔드 코드는 100% 순수 참고용(READ-ONLY)입니다 ⚠️⚠️⚠️**

- ✅ `Read`, `Grep`, `Glob` 도구로 코드를 **읽고 참고**하는 것은 적극 권장
- ✅ 기존 API 로직, SQL 쿼리, 함수 동작 방식을 파악하여 v7 코드에 반영
- ✅ DB 테이블 구조, 컬럼명, 데이터 타입 등을 확인하여 v7 Entity/Service에 활용
- ❌ **절대로** 이 경로의 어떤 파일도 수정하지 않는다
- ❌ **절대로** 이 경로에 새 파일을 생성하지 않는다
- ❌ **절대로** 이 경로의 파일을 삭제하지 않는다

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
- **DB 접근**: `Philgo\Utils\Db::pdo()` (레거시 `pdo()` 사용 금지)
- **입력 처리**: `Philgo\Utils\RequestUtils::all()` (레거시 `in()` 사용 금지)
- **인증 처리**: `Philgo\Utils\AuthService::getLoginUser()` — 2경로 인증: 세션 + Firebase ID Token (레거시 `login()` 사용 금지)
- **Firebase 토큰 검증**: `Philgo\Utils\FirebaseService::verifyIdToken()` (레거시 `verifyFirebaseToken()` 사용 금지)
- **에러 처리**: `throw new RuntimeException()` → api.php에서 catch → `{success: false}`
- **테스트**: PEST v4 Unit Test (`tests/Unit/`)

---

## 레퍼런스 문서

### 아키텍처 전체 → [v7-architecture.md](references/v7-architecture.md)

v7 시스템의 전체 아키텍처, 설계 원칙, 폴더 구조, 부트 프로세스, API 시스템,
Entity 구조체, 함수 작성 규칙, 입출력/에러/DB 처리, 테스트 시스템, 마이그레이션 전략,
Vue.js CDN MPA 방식, Utils 클래스, PSR-4 Autoloading 설정, 문서 분할 규칙,
기존 코드와의 통합 사용 방법을 상세히 다룹니다. Controller 클래스의 멤버 함수에는
반드시 GET REST URL 호출 예시를 PHPDoc에 포함해야 하며, Composer autoload 설정과
네임스페이스 매핑(`Philgo\User\` → `lib/user/`, `Philgo\Utils\` → `lib/utils/`)을
정확히 따라야 합니다.

### Docker 인프라 설정 → [v7-docker.md](references/v7-docker.md)

필고 프로젝트의 Docker Compose 이중 구조(신규 v7 + 기존 v6)를 상세히 다룹니다.
하나의 compose.yaml에서 5개 서비스(nginx, php, old_philgo_nginx, old_philgo_php, mariadb)를
관리하며, 신규 필고는 포트 80/443(PHP 8.3.6), 기존 필고는 포트 81/444(PHP 7.4.1)에서
서비스됩니다. Nginx 설정(SSL/TLS, HTTP→HTTPS 리다이렉트, Sitemap/Google 확인 rewrite 규칙),
PHP Dockerfile 구성(Extension 목록, FPM 프로세스 관리), MariaDB 11.7.2 접속 정보,
볼륨 매핑(소스코드·로그·DB 데이터 영구 저장), 개발 환경 접속 URL
(`https://local.philgo.com`, `https://banana.philgo.com`), Docker 운영 명령어,
Windows 환경 설정 차이점을 포함합니다.

### Flutter 앱 API 연동 → [app/v7-flutter-api.md](references/app/v7-flutter-api.md)

Flutter 앱에서 v7 API를 호출하는 방법을 상세히 다룹니다.
`v7api()` 함수 시그니처, 매개변수, 반환값, 에러 처리 패턴,
기존 `func()`과의 비교, 핵심 헬퍼 함수(`createDio()`, `patchToken()`),
`PhilgoConfig.v7ApiEndpoint` 설정, 위젯에서의 3상태 관리 패턴
(로딩/에러/성공), Firebase ID Token 인증 흐름, 실전 코드 예제,
**v7apiFileUpload() 파일 업로드 함수**, **V7FileUpload 재활용 위젯**,
v7 위젯 목록을 포함합니다.

### 모듈별 API 문서 → [references/api/](references/api/)

| 모듈 | 문서 | 상태 |
|------|------|------|
| User | [api/v7-user.md](references/api/v7-user.md) | ✅ 완료 |
| Upload | [api/v7-upload.md](references/api/v7-upload.md) | ✅ 완료 |
| AI | [api/v7-ai.md](references/api/v7-ai.md) | ✅ 완료 |
| Company | [api/v7-company.md](references/api/v7-company.md) | ✅ 완료 |
| Post | [api/v7-post.md](references/api/v7-post.md) | ✅ 완료 |

> 새 모듈을 추가할 때마다 `references/api/<module>.md` 문서를 작성합니다.

### 문서 분할 규칙

**하나의 레퍼런스 문서가 2,000라인을 초과하면 반드시 서브 파일로 분리한다.**

| 규칙 | 설명 |
|------|------|
| **분할 기준** | 단일 `.md` 파일이 2,000라인을 초과할 때 |
| **분할 방법** | 독립적인 섹션(예: 테스트, curl 가이드, MIME 목록 등)을 별도 파일로 분리 |
| **파일 위치** | 동일 폴더에 `<module>-<섹션>.md` 형태로 저장 (예: `upload-curl-guide.md`, `upload-test.md`) |
| **본문 참조** | 분리된 파일은 원본 문서에서 링크로 참조: `→ [상세 가이드](upload-curl-guide.md)` |
| **목차 유지** | 원본 문서의 목차에는 분리된 섹션도 링크 포함 |

---

## 🔴🔴🔴 Flutter v7 코드 저장 경로 — 예외 없음 🔴🔴🔴

> **Flutter 앱에서 v7 관련 모든 코드는 반드시 `lib/v7_api/` 폴더 하위에만 존재해야 한다.**
> **위젯, 로직, 알고리즘, 리포지토리, 서비스, 스테이트, 모델, 유틸 등 종류를 불문하고 예외 없이 `lib/v7_api/` 하위에 저장한다.**

| 분류 | 저장 경로 예시 |
|------|---------------|
| API 호출 함수 | `lib/v7_api/v7_api.dart` |
| 위젯 | `lib/v7_api/widgets/upload/v7_file_upload.dart` |
| 서비스/로직 | `lib/v7_api/services/` |
| 모델/엔티티 | `lib/v7_api/models/` |
| 스테이트 | `lib/v7_api/state/` |
| 리포지토리 | `lib/v7_api/repositories/` |
| 유틸리티 | `lib/v7_api/utils/` |

- ✅ v7 관련 **모든 Dart 코드**(위젯, 서비스, 모델, 스테이트, 리포지토리, 유틸 등)는 `lib/v7_api/` 하위에 위치
- ✅ 하위 폴더 구조는 자유롭게 생성 가능 (예: `lib/v7_api/widgets/`, `lib/v7_api/services/`)
- ❌ **절대로** `lib/v7_api/` 외부에 v7 관련 코드를 생성하지 않는다
- ❌ **절대로** 기존 레거시 폴더(`lib/philgo/`, `lib/widgets/`, `packages/philgo_api/` 등)에 v7 코드를 추가하지 않는다

---

## Flutter v7 위젯/함수 재활용 원칙

> **⚠️⚠️⚠️ 재활용 필수 ⚠️⚠️⚠️**
> v7 시스템용 Flutter 위젯과 함수는 **반드시 기존 것을 재활용**해야 한다.
> 새로운 업로드 위젯, API 호출 함수 등을 중복 생성하지 말 것.

| 함수/위젯 | 위치 | 용도 | 재활용 |
|-----------|------|------|--------|
| `v7api()` | `lib/v7_api/v7_api.dart` | v7 일반 API 호출 (JSON POST) | ✅ 필수 |
| `v7apiFileUpload()` | `lib/v7_api/v7_api.dart` | v7 파일 업로드 (multipart/form-data) | ✅ 필수 |
| `V7FileUpload` | `lib/v7_api/widgets/upload/v7_file_upload.dart` | 파일 업로드 위젯 (카메라/갤러리/파일) | ✅ **필수** |

상세 사용법: → [app/v7-flutter-api.md](references/app/v7-flutter-api.md) 11~13장 참조

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

기존 페이지(page.header.php)에서 v7 시스템 Service를 사용할 수 있습니다:

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
