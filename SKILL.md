---
name: v7-skill
description: 필고(Philgo) v7 시스템 통합 개발 스킬. PHP 백엔드(PSR-4 Controller + Service 아키텍처, api.php, PEST Unit Test), 웹 홈페이지(Vue.js CDN MPA, Web Awesome Pro, SEO — Bootstrap 미사용), Flutter 앱(v7 API 연동, V7FileUpload, CompanyApi, TravelApi) 개발을 모두 포함합니다. (1) PHP 백엔드: 새 API 엔드포인트 추가, Controller/Service 클래스 생성, PEST 테스트 작성, PSR-4 모듈 추가, api.php 관련 작업, (2) 웹 홈페이지: Vue.js 페이지 개발, PHP 페이지에서 v7 Service 호출, 웹 프론트엔드 작업, (3) Flutter 앱: v7api() 호출, V7FileUpload 위젯, 업소록/여행/이벤트 등 v7 기반 앱 기능 개발, v7 마이그레이션 등을 작업할 때 이 스킬을 사용하세요. 트리거 키워드: v7, v7 API, v7 백엔드, v7 웹, v7 앱, v7 홈페이지, Philgo v7, PSR-4, Controller, Service, api.php, PEST, PEST 브라우저 테스트, PEST Browser Test, Playwright, v7api, V7FileUpload, CompanyApi, TravelApi, v7 마이그레이션.
---

# 필고 v7 시스템 개발 가이드

## 🔴🔴🔴 Mandatory Workflow — Follow for ALL Tasks 🔴🔴🔴

> **Every v7 task MUST follow this workflow. No exceptions.**

### Before Starting Work

1. **Read at least 2 reference documents** from the v7-skill references before beginning any task. Choose documents relevant to the task at hand (e.g., architecture + module-specific API doc).
2. **For Flutter app tasks**, always read and refer to (Create/Update/Read/Delete) the docs under `references/app/` folder:
   - [app/v7-flutter-api.md](references/app/v7-flutter-api.md) — Flutter API integration
   - [app/v7-app.md](references/app/v7-app.md) — Company/business listing
   - [app/v7-app-travel.md](references/app/v7-app-travel.md) — Travel spots
   - [app/v7-app-phone-login.md](references/app/v7-app-phone-login.md) — Phone login
   - [app/v7-app-settings.md](references/app/v7-app-settings.md) — App settings
   - [app/v7-app-kakoatalk-social-login.md](references/app/v7-app-kakoatalk-social-login.md) — Kakao social login
   - [app/v7-event-entry.md](references/app/v7-event-entry.md) — Event entry (spinning wheel)
   - [app/v7-event-entry.md](references/app/v7-event-entry.md) — Event/spinning wheel

### After Completing Each Task

3. **Git commit** the changes (do NOT push). Create a descriptive commit message summarizing what was done.

### After Finishing All Work

4. **Update the v7-skill reference documents** to reflect any new patterns, APIs, widgets, or architectural decisions introduced during the work. Keep the documentation in sync with the codebase.

---

## 🔴🔴🔴 v7-skill 적용 범위: 백엔드 + 웹 홈페이지 + Flutter 앱 🔴🔴🔴

> **⚠️ v7-skill은 PHP 백엔드 개발만을 위한 스킬이 아닙니다.**
> **v7 시스템과 관련된 모든 개발 — PHP 백엔드, 웹 홈페이지, Flutter 앱 — 에 이 스킬을 사용합니다.**
> **v7 API를 호출하는 Flutter 앱 코드, v7 Service를 사용하는 웹 페이지 모두 이 스킬의 범위입니다.**

## 개요

이 스킬은 **필고 v7 시스템** 개발을 위한 **통합 스킬**입니다.
PHP 백엔드, 웹 홈페이지, Flutter 앱 개발을 모두 포함합니다.

| 영역 | 설명 | 핵심 기술 |
|------|------|-----------|
| **PHP 백엔드** | PSR-4 기반 Controller + Service 아키텍처로 v7 API 개발 | PHP 8.3, PSR-4, PEST, MariaDB |
| **웹 홈페이지** | v7 Service를 활용한 PHP 페이지 및 Vue.js CDN MPA 웹 개발 | Vue.js, **Web Awesome Pro v3.3.1**, **Font Awesome Pro v7.2.0**, PHP, Firebase, SEO (**🚫 Bootstrap 미사용**) |
| **Flutter 앱** | v7 API를 호출하는 Flutter 앱 기능 개발 | Dart, v7api(), V7FileUpload, Provider |

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

### 🔴🔴🔴 최우선 작업 원칙: Sub Agents 병렬 처리 필수 🔴🔴🔴

> **⛔⛔⛔ 절대 규칙: 사용자가 v7 시스템 관련 작업을 요청하면, 반드시 최대한의 Sub Agents를 사용하여 병렬(Parallel)로 작업을 수행해야 한다. ⛔⛔⛔**

| 원칙 | 설명 |
|------|------|
| **병렬 처리 필수** | 독립적인 작업은 **반드시** 여러 Sub Agents를 동시에 실행하여 병렬로 처리한다. 순차적으로 하나씩 처리하는 것은 **금지**한다. |
| **최대 병렬화** | 파일 탐색, 코드 분석, 레퍼런스 문서 조회, 테스트 실행 등 독립적인 작업은 **가능한 한 많은 수의 Sub Agents를 동시에** 실행한다. |
| **Explore Agent 적극 활용** | 코드베이스 탐색이 필요한 경우 `subagent_type=Explore`를 사용하여 **high thoroughness**로 탐색한다. |
| **단일 메시지 다중 호출** | 여러 Sub Agent를 실행할 때 **반드시 하나의 메시지에 여러 Agent tool 호출을 포함**하여 동시에 실행한다. 별도 메시지로 나누어 순차 실행하지 않는다. |

**병렬 처리 적용 예시:**

- Controller + Service + Test 파일을 동시에 분석할 때 → 3개의 Sub Agent를 병렬 실행
- 여러 레퍼런스 문서를 동시에 조회할 때 → 각 문서별 Sub Agent를 병렬 실행
- 기존 코드 패턴 분석 + DB 스키마 조회 + 테스트 코드 확인 → 3개의 Sub Agent를 병렬 실행
- 새 모듈 추가 시 기존 모듈 구조 분석 → 여러 모듈을 동시에 분석하는 Sub Agent를 병렬 실행

**⛔ 절대 금지: 병렬로 실행할 수 있는 작업을 순차적으로 하나씩 처리하는 것은 엄격히 금지한다. ⛔**

---

### 기존 스킬과의 관계

| 스킬 | 용도 |
|------|------|
| `philgo-skill` | 기존 레거시 시스템 (앱, 웹, API) 개발 |
| **`v7-skill`** | **v7 시스템 통합 개발 — PHP 백엔드 + 웹 홈페이지 + Flutter 앱 (기존 코드와 공존)** |

> v7 시스템 관련 작업(백엔드 API, 웹 홈페이지, Flutter 앱)은 이 스킬을, 레거시 코드 작업 시에는 `philgo-skill`을 사용합니다.
> **두 스킬은 상호 배타적이 아니며, 하나의 페이지에서 두 시스템을 동시에 사용할 수 있습니다.**

---

## 🔴🔴🔴 백엔드 소스코드 경로 — Entity/Service/Repository/Controller만 수정 가능 🔴🔴🔴

> **필고 프로젝트의 PHP API 백엔드 소스코드 경로:**
> `/Users/thruthesky/apps/withcenter/philgo/www`
>
> **API 엔트리포인트:** `/Users/thruthesky/apps/withcenter/philgo/www/api.php`
> **API 접근 URL:** `https://v7-local.philgo.com/api.php?method=<module>.<action>`
> **예시:** `https://v7-local.philgo.com/api.php?method=user.count`

### 🔴🔴🔴 필수 선행 조건: 백엔드 SKILL.md 읽기 🔴🔴🔴

> **PhilGo v7 API 백엔드 코드를 수정하기 전에 반드시 아래 파일을 먼저 읽어야 한다:**
> `/Users/thruthesky/apps/withcenter/philgo/www/.claude/skills/v7-skill/SKILL.md`
>
> 이 파일을 읽지 않고 백엔드 코드를 수정하는 것은 **절대 금지**한다.

### ⚠️⚠️⚠️ 최우선 원칙: Entity/Service/Repository/Controller 파일만 수정 가능 ⚠️⚠️⚠️

> **v7 API 백엔드에서 수정할 수 있는 파일은 Entity, Service, Repository, Controller 4가지 종류뿐이다.**
> **그 외 모든 파일(api.php, utils, 레거시 파일 등)은 수정할 수 없다.**
> **수정 전 반드시 백엔드 SKILL.md를 확인하고, 해당 파일이 허용된 종류인지 검증한 후 작업하세요.**

| 규칙 | 설명 |
|------|------|
| **📖 참고용으로 적극 활용** | v7 시스템 개발 시 기존 백엔드 코드의 로직, DB 쿼리, 비즈니스 규칙, 테이블 구조 등을 **반드시 참고**하여 일관성을 유지한다 |
| **✅ Entity/Service/Repository/Controller만 수정** | `Philgo\*` 네임스페이스의 **Entity, Service, Repository, Controller** 4가지 종류의 파일만 수정할 수 있다 |
| **🚫 그 외 v7 파일 수정 금지** | `api.php`, `lib/utils/` 등 Entity/Service/Repository/Controller가 아닌 v7 파일도 수정하지 않는다 |
| **🚫 레거시 파일 수정 절대 금지** | `boot.php`, `*.functions.php`, `widget/`, `page.*.php` 등 **기존 레거시 파일은 절대로 수정, 삭제, 이동하지 않는다** |
| **🚫 레거시 파일 쓰기 작업 금지** | `Edit`, `Write`, `Bash`(echo, sed, awk 등) 도구로 레거시 파일에 **어떠한 쓰기 작업도 수행하지 않는다** |

### 수정 가능한 v7 파일 (화이트리스트) — Entity/Service/Repository/Controller만

| 수정 가능 | 경로 패턴 | 예시 |
|-----------|-----------|------|
| ✅ 수정 가능 | `lib/*/` 내 Entity 클래스 | `lib/user/UserEntity.php`, `lib/company/CompanyEntity.php` |
| ✅ 수정 가능 | `lib/*/` 내 Service 클래스 | `lib/user/UserService.php`, `lib/company/CompanyService.php` |
| ✅ 수정 가능 | `lib/*/` 내 Repository 클래스 | `lib/user/UserRepository.php`, `lib/company/CompanyRepository.php` |
| ✅ 수정 가능 | `lib/*/` 내 Controller 클래스 | `lib/user/UserController.php`, `lib/company/CompanyController.php` |

### 수정 불가능한 파일 (블랙리스트) — 절대 금지

| 수정 불가 | 경로 패턴 | 예시 |
|-----------|-----------|------|
| ❌ **절대 금지** | `api.php` (엔트리포인트) | `api.php` |
| ❌ **절대 금지** | `lib/utils/` v7 유틸리티 클래스 | `lib/utils/Db.php`, `lib/utils/RequestUtils.php` |
| ❌ **절대 금지** | `composer.json` | `composer.json` |
| ❌ **절대 금지** | `tests/` 테스트 파일 | `tests/Unit/UserControllerTest.php` |
| ❌ **절대 금지** | `boot.php` 및 설정 파일 | `boot.php`, `config.php` |
| ❌ **절대 금지** | `*.functions.php` 레거시 함수 파일 | `user.functions.php`, `post.functions.php` |
| ❌ **절대 금지** | `widget/` 레거시 위젯 | `widget/*.php` |
| ❌ **절대 금지** | `page.*.php` 레거시 페이지 | `page.header.php`, `page.footer.php` |
| ❌ **절대 금지** | 기존 레거시 PHP 파일 전체 | v7 네임스페이스(`Philgo\*`)가 아닌 모든 PHP 파일 |

### 수정 전 필수 확인 절차

> **🔴 PHP 백엔드 파일을 수정하기 전에 반드시 아래 절차를 따를 것 🔴**

1. **백엔드 SKILL.md 읽기** — `/Users/thruthesky/apps/withcenter/philgo/www/.claude/skills/v7-skill/SKILL.md`를 반드시 먼저 읽는다
2. **파일 종류 확인** — 수정하려는 파일이 Entity, Service, Repository, Controller 중 하나인지 확인
3. **네임스페이스 확인** — 파일이 `namespace Philgo\*`를 사용하는 v7 클래스인지 확인
4. **Entity/Service/Repository/Controller가 확실한 경우에만 수정** — 조금이라도 의심되면 수정하지 않고 사용자에게 확인

- ✅ `Read`, `Grep`, `Glob` 도구로 **모든 코드**를 읽고 참고하는 것은 적극 권장
- ✅ 기존 API 로직, SQL 쿼리, 함수 동작 방식을 파악하여 v7 코드에 반영
- ✅ DB 테이블 구조, 컬럼명, 데이터 타입 등을 확인하여 v7 Entity/Service에 활용
- ✅ **Entity, Service, Repository, Controller** 파일만 수정
- ❌ **절대로** api.php, utils, composer.json, 테스트 파일 등을 수정하지 않는다
- ❌ **절대로** 레거시 파일(`*.functions.php`, `widget/`, `boot.php`, `page.*.php` 등)을 수정하지 않는다
- ❌ **절대로** 레거시 파일에 새 코드를 추가하지 않는다
- ❌ **절대로** 레거시 파일을 삭제하거나 이동하지 않는다

---

## 핵심 아키텍처

```
클라이언트 → api.php → Controller → Service → Repository → Db → DB
                │
                ├─ vendor/autoload.php (PSR-4)
                ├─ RequestUtils::parseMethod() → [module, action]
                ├─ FQCN: "Philgo\{Module}\{Module}Controller"
                └─ $ctrl->$action($input) → JSON 응답

위젯(v7/widgets/) → Service → Repository → Db → DB
  (위젯에서 Db:: 직접 사용 절대 금지)
```

- **엔트리포인트**: `api.php` (boot.php 미포함)
- **네임스페이스**: `Philgo\{Module}\` (예: `Philgo\User\UserController`)
- **DB 접근**: `Philgo\Utils\Db::pdo()` (레거시 `pdo()` 사용 금지)
- **입력 처리**: `Philgo\Utils\RequestUtils::all()` (레거시 `in()` 사용 금지)
- **인증 처리**: `Philgo\Utils\AuthService::getLoginUser()` — 2경로 인증: 세션 + Firebase ID Token (레거시 `login()` 사용 금지)
- **Firebase 토큰 검증**: `Philgo\Utils\FirebaseService::verifyIdToken()` (레거시 `verifyFirebaseToken()` 사용 금지)
- **디버그 로깅**: `Philgo\Utils\Debug::log()` → `var/debug.log` 기록 (레거시 `debug_log()` 사용 금지)
- **에러 처리**: `throw new RuntimeException()` → api.php에서 catch → `{success: false}`
- **테스트**: PEST v4 Unit Test (`tests/Unit/`) + PEST Browser Test (`tests/Browser/`) → [상세 가이드](references/v7-pest-browser-test.md)
- **🔴 `./tests` 폴더는 오직 v7 용 코드 테스트만 저장한다.** v6(레거시) 테스트는 `tests/old-tests/`에 보관되며 새로 작성하지 않는다. 테스트 대상: `v7/` 폴더 하위 코드, `lib/` 폴더의 v7 Controller/Service/Repository/Entity 클래스.

---

## 🔴🔴🔴 PHP LSP (intelephense) 필수 사용 — 절대 규칙 🔴🔴🔴

> **⛔⛔⛔ 프로젝트에 `intelephense@claude-code-lsps`를 통한 PHP LSP가 설치되어 있다. ⛔⛔⛔**
> **모든 PHP 관련 작업(코드 분석, 수정, 리팩토링, 디버깅 등)과 웹 관련 작업 시 반드시 PHP LSP를 활용해야 한다.**
> **LSP 없이 Grep/Glob만으로 코드를 추측하여 작업하는 것은 엄격히 금지한다.**

| 활용 항목 | 설명 |
|-----------|------|
| **심볼 정의 탐색** | 함수, 클래스, 메서드의 정확한 정의 위치를 LSP `definition` 기능으로 확인한다 |
| **참조 검색** | 특정 함수/클래스/변수가 어디서 사용되는지 LSP `references` 기능으로 검색한다 |
| **타입 정보 확인** | 변수, 매개변수, 반환값의 타입을 LSP `hover` 기능으로 확인한다 |
| **진단(Diagnostics)** | PHP 코드의 타입 에러, 문법 에러, 경고를 LSP `diagnostics`로 감지하고 반드시 수정한다 |
| **코드 수정 후 검증** | 코드 수정 후 LSP 진단을 확인하여 타입 에러나 경고(P1006 등)가 없는지 반드시 검증한다 |

**⛔ 절대 금지: Grep/Glob만으로 코드 관계를 추측하여 작업하는 것. 반드시 LSP를 통해 정확한 코드 관계를 파악한 후 작업할 것. ⛔**

---

## 🔴🔴🔴 데이터 모델 클래스를 통한 접근 필수 — 절대 규칙 (PHP + JavaScript 전 영역) 🔴🔴🔴

> **⛔⛔⛔ 어떤 경우에도 연관 배열(`$arr['key']`), JSON 객체, Map 등으로 데이터에 직접 접근하지 않는다. ⛔⛔⛔**
> **반드시 데이터 모델링 클래스(Entity, Model 등)를 통해 멤버 변수(`->`) 또는 멤버 함수로 값을 읽고 써야 한다.**
> **이 규칙은 PHP, JavaScript 등 모든 코드 영역에 걸쳐 적용된다. 예외 없음.**

| 규칙 | 설명 |
|------|------|
| **연관 배열 접근 금지** | `$c['idx_member']`, `$row['firebase_uid']` 등 배열 키로 직접 접근 금지 |
| **모델 클래스 접근 필수** | `$c->idx_member`, `$post->content` 등 객체 멤버 변수/함수로 접근 |
| **PHP Entity 변환 필수** | DB 조회 결과(배열)는 반드시 `PostEntity::fromArray()`, `UserEntity::fromArray()` 등으로 Entity 객체로 변환 후 사용 |
| **JavaScript에서도 동일** | API 응답을 Vue.js data에 바인딩하여 프로퍼티로 접근 |
| **Flutter에서도 동일** | API 응답을 반드시 데이터 모델 클래스(`fromJson()`)로 변환 후 사용. `Map<String, dynamic>` 직접 접근 금지 |

**올바른 예시:**

```php
// ✅ PHP: Entity 객체를 통한 접근
$c = PostEntity::fromArray($commentArr);
$idxMember = $c->idx_member;        // ✅ 멤버 변수
$content = $c->content;              // ✅ 멤버 변수
$subject = $post->display_subject(); // ✅ 멤버 함수
```

**잘못된 예시 (절대 금지):**

```php
// ❌ PHP: 연관 배열로 직접 접근
$idxMember = $c['idx_member'];       // ❌ 배열 키 접근 금지
$content = $row['content'];           // ❌ DB 결과 직접 접근 금지
```

**적용 범위**: PHP 백엔드(Entity/Service/Repository/Controller), v7 웹 홈페이지(PHP + JavaScript), Flutter 앱(Dart 모델 클래스) — 모든 코드 영역에 예외 없이 적용.

---

## 🔴 PHP 코딩 규칙: 타입 안전성 필수 🔴

### Intelephense / 정적 분석 타입 경고 방지 — 캐스팅 필수

> **⛔ PHP 코드 작성 시 반드시 타입 에러 및 타입 경고가 발생하지 않도록 해야 한다. ⛔**
> **VSCode Intelephense(PHP 정적 분석기)에서 타입 관련 경고(P1006 등)가 절대 발생하지 않도록 명시적 타입 캐스팅을 수행한다.**

| 규칙 | 설명 |
|------|------|
| **nullable 타입 반환 시 캐스팅 필수** | `?bool`, `?int`, `?string` 등 nullable 속성을 non-nullable 반환 타입 메서드에서 반환할 때 반드시 `(bool)`, `(int)`, `(string)` 등으로 캐스팅한다 |
| **반환 타입과 실제 값 일치** | 메서드의 반환 타입 선언(`bool`, `int`, `string`)과 실제 반환 값의 타입이 항상 일치해야 한다 |
| **PHPDoc 타입 힌트 정확히 작성** | `@var`, `@param`, `@return` 어노테이션의 타입이 실제 코드와 일치해야 한다 |
| **함수 반환값 타입 확인** | `parse_url()`, `realpath()` 등 `false`나 `null`을 반환할 수 있는 PHP 내장 함수 사용 시 반드시 반환 타입을 확인하고 적절히 처리한다 |

**올바른 예시:**

```php
// ✅ nullable 속성을 non-nullable 반환 타입으로 반환 시 캐스팅
private ?bool $validPath = null;

public function isValidPath(): bool
{
    if ($this->validPath === null) {
        $this->resolvePageFile();
    }
    return (bool) $this->validPath;  // ✅ (bool) 캐스팅으로 타입 안전성 보장
}

// ✅ parse_url() 반환값 처리
$this->uri = (string) (parse_url($rawUri, PHP_URL_PATH) ?: '/');
```

**잘못된 예시:**

```php
// ❌ nullable 속성을 캐스팅 없이 직접 반환 → Intelephense P1006 경고 발생
public function isValidPath(): bool
{
    return $this->validPath;  // ❌ ?bool → bool 타입 불일치
}
```

### 🔴🔴🔴 Db 헬퍼 메서드 반환값 타입 처리 — 절대 규칙 🔴🔴🔴

> **⛔ `Db::fetch()`는 `array<string, mixed>|false`를 반환한다. `array` 타입이 필요한 곳에 바로 전달하면 P1006 에러가 발생한다. ⛔**

| Db 메서드 | 반환 타입 | 주의사항 |
|-----------|-----------|----------|
| `Db::fetch()` | `array\|false` | **결과 없으면 `false` 반환** → `false` 체크 필수 |
| `Db::fetchAll()` | `array` | 결과 없으면 빈 배열 → 안전하게 사용 가능 |
| `Db::fetchColumn()` | `mixed` | 결과 없으면 `false` → 타입 체크 필수 |
| `Db::insert()` | `int` | 항상 정수 반환 → 안전 |
| `Db::execute()` | `PDOStatement` | 항상 PDOStatement 반환 → 안전 |

**✅ 올바른 `Db::fetch()` 사용 패턴:**

```php
// 패턴 1: false 체크 후 사용 (권장)
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [$idx]);
if ($user === false) {
    throw new RuntimeException("사용자를 찾을 수 없습니다");
}
// 이 시점에서 $user는 array 타입으로 확정
AuthService::loginUser($user);  // ✅ 안전

// 패턴 2: 조건부 사용
$row = Db::fetch("SELECT * FROM sf_post_data WHERE idx = ?", [$idx]);
if ($row !== false) {
    $post = PostEntity::fromArray($row);  // ✅ 안전
}

// 패턴 3: 변수에 기본값 할당
$config = Db::fetch("SELECT * FROM settings WHERE key = ?", [$key]);
if ($config === false) {
    $config = ['value' => 'default'];  // 기본값 설정
}
```

**❌ 잘못된 `Db::fetch()` 사용 (P1006 에러 발생):**

```php
// ❌ false 체크 없이 array 기대 함수에 전달
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [$idx]);
AuthService::loginUser($user);  // ❌ array|false를 array로 전달 → P1006!

// ❌ false 체크 없이 Entity 변환
$row = Db::fetch("SELECT * FROM sf_post_data WHERE idx = ?", [$idx]);
$post = PostEntity::fromArray($row);  // ❌ array|false를 array로 전달 → P1006!
```

> **⛔⛔⛔ 코드 수정 후 반드시 LSP 진단(Diagnostics)을 실행하여 P1006 등 타입 에러가 없는지 검증할 것! ⛔⛔⛔**

---

## 레퍼런스 문서

### 레퍼런스 폴더 구조

| 폴더 | 용도 | 대상 |
|------|------|------|
| `references/api/` | v7 API 모듈 문서 (웹+앱 공통) | 모든 v7 API 엔드포인트 (Controller/Service) — 웹과 앱 모두 사용하는 공통 API |
| `references/web/` | 웹/서버 전용 문서 | 웹서버, PHP, Vue.js, **Web Awesome Pro**, 폰트, 위젯, 레이아웃, SEO 등 웹 프론트엔드/백엔드 관련 내용만 포함 (**Bootstrap 미사용**) |
| `references/app/` | Flutter 앱 전용 문서 | Flutter 앱 개발, Dart 코드, 앱 위젯, 앱 API 연동 등 앱 관련 내용만 포함 |
| `references/event/` | 이벤트 시스템 문서 | 포인트 이벤트, 스피닝 휠, QR 코드 등 이벤트 관련 통합 문서 |
| `references/server/` | 서버/인프라 문서 | Docker, Dokploy 배포, DB, Nginx 등 서버 인프라 관련 문서 |
| `references/` (루트) | 공통 인프라 문서 | 아키텍처, DB 스키마 등 전체 시스템 공통 문서 |

> **`references/api/`** 폴더의 문서는 **웹과 앱 모두에서 사용하는 공통 API 문서**이다.
> 특정 플랫폼(웹 또는 앱) 전용 내용은 해당 폴더(`web/` 또는 `app/`)에 작성한다.

### 아키텍처 전체 → [v7-architecture.md](references/v7-architecture.md)

v7 시스템의 전체 아키텍처, 설계 원칙, 폴더 구조, 부트 프로세스, API 시스템,
Entity 구조체, 함수 작성 규칙, 입출력/에러/DB 처리, 테스트 시스템, 마이그레이션 전략,
Vue.js CDN MPA 방식, Utils 클래스, PSR-4 Autoloading 설정, 문서 분할 규칙,
기존 코드와의 통합 사용 방법을 상세히 다룹니다. Controller 클래스의 멤버 함수에는
반드시 GET REST URL 호출 예시를 PHPDoc에 포함해야 하며, Composer autoload 설정과
네임스페이스 매핑(`Philgo\User\` → `lib/user/`, `Philgo\Utils\` → `lib/utils/`)을
정확히 따라야 합니다.

### Interface 시스템 → [v7-interface.md](references/v7-interface.md)

v7 시스템의 EntityInterface, RepositoryInterface, ServiceInterface, ControllerInterface를
상세히 다룹니다. 모든 Entity(14개)는 `Philgo\Utils\EntityInterface`를 구현하여
`fromArray(array $data): static` 정적 팩토리와 `toArray(): array` 배열 변환을 필수로 제공합니다.
6개 Repository는 `Philgo\Utils\RepositoryInterface`를 구현하여 `create()`, `findByIdx()`,
`update()`, `deleteByIdx()` 표준 CRUD 메서드명을 강제합니다. 10개 Service는
`Philgo\Utils\ServiceInterface`를 구현하여 `create()`, `update()`, `delete()`, `get()`,
`list()` 표준 CRUD 메서드를 강제하며, CRUD를 지원하지 않는 Service는
도메인 특성상 지원하지 않는 CRUD 메서드는 도메인에 맞는 구체적인 에러 메시지로
`RuntimeException`을 throw합니다. 10개 Controller는 `Philgo\Utils\ControllerInterface`를
구현합니다. 표준 패턴 코드, 계산 필드 패턴, 런타임 속성 패턴,
데이터 흐름, 새 모듈 추가 워크플로우 등을 포함합니다.

### Docker 인프라 설정 → [v7-docker.md](references/server/v7-docker.md)

필고 프로젝트의 Docker Compose 이중 구조(신규 v7 + 기존 v6)를 상세히 다룹니다.
하나의 compose.yaml에서 5개 서비스(nginx, php, old_philgo_nginx, old_philgo_php, mariadb)를
관리하며, 신규 필고는 포트 80/443(PHP 8.3.6), 기존 필고는 포트 81/444(PHP 7.4.1)에서
서비스됩니다. Nginx 설정(SSL/TLS, HTTP→HTTPS 리다이렉트, Sitemap/Google 확인 rewrite 규칙),
PHP Dockerfile 구성(Extension 목록, FPM 프로세스 관리), MariaDB 11.7.2 접속 정보,
볼륨 매핑(소스코드·로그·DB 데이터 영구 저장), 개발 환경 접속 URL
(`https://local.philgo.com` — v6, `https://v7-local.philgo.com` — v7),
Cloudflare 터널을 통한 외부 접속(`https://local.philgo.com` — Cloudflare Tunnel + Proxied DNS 레코드로
로컬 Docker에 접속, IUAM 모드 호환을 위해 Nginx에서 `X-Forwarded-Proto` 헤더 기반 리다이렉트 예외 처리),
Docker 운영 명령어, Windows 환경 설정 차이점을 포함합니다.

### Dokploy 프로덕션 배포 → [v7-dokploy.md](references/server/v7-dokploy.md)

필고 v7 프로젝트의 Dokploy 기반 프로덕션 배포 구성 전체를 다룹니다.
Dokploy는 셀프호스팅 PaaS 도구로, Git 레포지토리(thruthesky/withcenter, 브랜치 v7)와 연동하여
Docker Compose 기반 자동 배포를 수행합니다. Nginx + PHP-FPM 8.3.6을 하나의 단일 컨테이너(web)로
통합하고 MariaDB 11.7.2를 별도 컨테이너로 운영하는 2-서비스 구조입니다. SSL/TLS 종단은
Dokploy 내장 Traefik 리버스 프록시가 처리하므로 컨테이너는 HTTP(80)만 리슨합니다.
모노레포 내 Compose Path(`./philgo/www/docker/dokploy-deploy/docker-compose.yml`), 환경변수 기반 DB 설정 자동 생성
(entrypoint.sh), PHP Extension(gd, mbstring, pdo_mysql 등), Dockerfile 빌드 단계,
Nginx 라우팅 규칙(v6 호환 rewrite, 정적 파일 캐싱, Sitemap/Google 확인),
로컬 개발 환경과의 차이점(fastcgi_pass, SSL, 볼륨 방식)을 상세히 기술합니다.
서버 접속: Dokploy 관리 패널 `http://209.97.169.136:3000`,
프로덕션 URL `https://philgo.net`,
프리뷰 URL `http://philgo.209.97.169.136.traefik.me`.

### 데이터베이스 관리 → [v7-db.md](references/server/v7-db.md)

MariaDB 11.7.2 데이터베이스 접속·관리·사용 방법을 상세히 다룹니다.
DB 접속 정보(`etc/db.config.php`, `etc/db.config.dev.php`), Docker 컨테이너에서
`docker exec -it mariadb mysql` 명령으로 직접 접속하는 방법, 호스트에서
`mysql -h 127.0.0.1 -P 3306` CLI 접속 방법을 포함합니다. v7 `Philgo\Utils\Db` 클래스의
전체 메서드 레퍼런스(`fetch`, `fetchAll`, `fetchColumn`, `execute`, `insert`)와 사용 예제,
Intelephense P1006 타입 안전성 규칙(`Db::fetch()` 반환값 `array|false` 체크 필수),
레거시 `pdo()` 함수 및 `db_*()` 헬퍼 함수와의 비교, v7 3계층 DB 접근 패턴
(Controller → Service → Repository → Db), 위젯에서 직접 DB 접근 금지 규칙,
주요 테이블 목록(`sf_member`, `sf_post_data` 등), 테스트 환경 DB 설정을 포함합니다.

### Flutter 앱 전화번호 로그인 → [app/v7-app-phone-login.md](references/app/v7-app-phone-login.md)

Flutter 앱의 전화번호 로그인 시스템과 v7 API 인증 연동을 상세히 다룹니다.
Firebase Phone Auth 기반 전화번호 인증, E.164 국제 형식 변환, +1 화이트리스트 검증,
특수 계정(리뷰/테스트), SMS 코드 전송/확인 흐름, 로그인 후 Firebase ID Token을
v7 API에 전달하는 인증 구조, AuthService 2경로 인증(세션+Firebase Token),
sf_member 테이블 연동, 다국어 에러 메시지를 포함합니다.

### Flutter 앱 API 연동 → [app/v7-flutter-api.md](references/app/v7-flutter-api.md)

Flutter 앱에서 v7 API를 호출하는 방법을 상세히 다룹니다.

### 레거시 앱 설정 API → [app/v7-app-settings.md](references/app/v7-app-settings.md)

레거시 `func.php` 기반 `get_app_settings` API 문서이다.
Flutter 앱이 시작할 때 서버에서 은행 정보, 포인트 설정, 관리자 UID 목록을 한 번에 가져온다.
`PhilgoSetting` 모델 계층, `PhilgoState` 상태 관리, 앱 내 사용 예시를 포함한다.

### Flutter 앱 업소록 연동 → [app/v7-app.md](references/app/v7-app.md)

Flutter 앱의 업소록(Company) 기능이 v7 API를 통해 데이터를 가져오는 방법을 상세히 다룹니다.
CompanyApi 클래스(list, get, mine, create, update, reVisitPoint, submitVisitReview, getVisitReviews),
개발 모드/프로덕션 모드 엔드포인트 설정(`--dart-define=V7_API_ENDPOINT`),
개발 모드에서 로컬 MariaDB 직접 접근, 8개 화면 구조와 라우팅,
QR 코드 삼단콤보 흐름(QR 스캔→재방문→후기→포인트), CompanyEntity 필드(33개),
업소 상태 흐름(신규→심사중→승인), 파일 업로드(V7FileUpload 위젯),
포인트 적립 규칙, 에러 처리 패턴, 권한 모델을 포함합니다.

### Flutter 앱 여행 명소 연동 → [app/v7-app-travel.md](references/app/v7-app-travel.md)

Flutter 앱의 여행 명소 기능이 v7 Travel API를 통해 데이터를 가져오는 방법을 상세히 다룹니다.
TravelApi 래퍼 클래스(list, get, filters), TravelSpot 모델(index/hasTextsFlag 필드, 이중 키 호환),
TravelSpotService(3일 캐시 TTL, 번들 폴백, Isolate JSON 파싱),
TravelSpotViewScreen(texts API 로드, _spot 상태 변수),
데이터 흐름 다이어그램(목록/상세), CoT/ToT 핵심 결정 사항을 포함합니다.
JSON 데이터 관리(Source of Truth, 서버 경로, 앱 번들 동기화)는
→ [api/v7-travel.md](references/api/v7-travel.md) 3장 참조.

### Flutter 앱 카카오톡 소셜 로그인 → [app/v7-app-kakoatalk-social-login.md](references/app/v7-app-kakoatalk-social-login.md)

Flutter 앱(iOS, Android)에서 카카오톡 소셜 로그인을 구현하는 전체 가이드를 다룹니다.
카카오 Flutter SDK를 통해 카카오 로그인 후 Firebase Custom Token 방식으로
Firebase Authentication에 연동하는 흐름을 설명합니다. Android/iOS 플랫폼별 설정
(AndroidManifest.xml, Info.plist), SDK 초기화, UserService의 카카오 로그인 구현,
PHP 서버의 Firebase Custom Token 생성 연동, 로그인 UI 구현, 에러 처리,
로그아웃/연결끊기(탈퇴), 카카오 SDK 주요 API 레퍼런스, 실전 트러블슈팅,
관련 파일 목록을 포함합니다.

### 웹 문서 → [references/web/](references/web/)

> **🔴 모든 웹 관련 작업 내용은 `references/web/` 폴더에 문서를 보관한다. 🔴**
> 웹서버, PHP 뷰, Vue.js, CSS, 레이아웃, 위젯, 폰트, SEO 등 웹 프론트엔드/백엔드 관련 내용은 모두 이 폴더에 작성한다.

| 문서 | 설명 | 상태 |
|------|------|------|
| v7 홈페이지 개요 | [web/v7-overview.md](references/web/v7-overview.md) | ✅ 완료 |
| **레이아웃 시스템** | [web/v7-layout.md](references/web/v7-layout.md) | ✅ 완료 |
| Firebase | [web/v7-firebase.md](references/web/v7-firebase.md) | ✅ 완료 |
| 위젯 시스템 | [web/v7-widgets.md](references/web/v7-widgets.md) | ✅ 완료 |
| 폰트 로딩 | [web/v7-fonts.md](references/web/v7-fonts.md) | ✅ 완료 |
| **업소록 홈페이지** | [web/v7-company.md](references/web/v7-company.md) | ✅ 완료 |
| **관리자 대시보드** | [web/v7-admin.md](references/web/v7-admin.md) | ✅ 완료 |
| **웹 로그인 인증** | [web/v7-web-login.md](references/web/v7-web-login.md) | ✅ 완료 |
| **검색 (Google CSE)** | [web/v7-search.md](references/web/v7-search.md) | ✅ 완료 |
| **카카오톡 소셜 로그인** | [web/v7-web-kakoatalk-social-login.md](references/web/v7-web-kakoatalk-social-login.md) | ✅ 완료 |
| **네이버 소셜 로그인** | [web/v7-web-naver-social-login.md](references/web/v7-web-naver-social-login.md) | ✅ 완료 |
| **도움말 페이지** | [web/v7-help.md](references/web/v7-help.md) | ✅ 완료 |
| **1:1 채팅 시스템** | [web/v7-chat.md](references/web/v7-chat.md) | ✅ 완료 |
| SEO | [web/v7-seo.md](references/web/v7-seo.md) | 작성 예정 |
| **코멘트 스레드 세로선** | [web/v7-comment-thread-line.md](references/web/v7-comment-thread-line.md) | ✅ 완료 |

### 1:1 채팅 시스템 → [web/v7-chat.md](references/web/v7-chat.md)

v7 1:1 채팅 시스템은 **Firebase Realtime Database(RTDB)** 기반의 실시간 1:1 채팅 기능이다.
PHP(서버)는 로그인 확인과 설정값 전달만 담당하며, 채팅 데이터의 읽기/쓰기/구독은 모두
클라이언트 JavaScript에서 Firebase SDK를 직접 호출하여 처리한다.
Vue.js 3 CDN + Firebase compat SDK 기반 CSR 방식이며, Web Awesome Pro UI를 사용한다.
채팅방 생성, 메시지 전송, 읽음 표시, 즐겨찾기(v7 API `bookmark.*` 기반), 사운드 알림, 이미지/파일 업로드,
Presence(온라인/오프라인), FCM 푸시 알림, 메시지 수정/삭제, 관리자 기능 등을 지원한다.
즐겨찾기 시스템은 Firebase RTDB에서 v7 API(`bookmarks`/`bookmark_groups` 테이블)로 마이그레이션되었다.

#### 🔥 Firebase Cloud Functions 채팅 백엔드 코드

채팅 시스템의 서버 측 로직(Cloud Functions)은 **`firebase/chat-v2/`** 폴더에 위치한다.
이 폴더는 필고 프로젝트 루트(`./`)에서 `firebase/chat-v2/` 경로에 있으며,
Firebase Cloud Functions v2(Gen2)를 사용하는 독립적인 TypeScript 프로젝트이다.

| 항목 | 설명 |
|------|------|
| **프로젝트 경로** | `./firebase/chat-v2/` |
| **소스 코드** | `firebase/chat-v2/functions/src/` |
| **런타임** | Node.js 22, TypeScript, Firebase Cloud Functions v2 (Gen2) |
| **주요 의존성** | `firebase-admin` ^12.6.0, `firebase-functions` ^6.0.1 |
| **테스트** | Mocha + Chai + Sinon |
| **Firebase 프로젝트** | `philgo-64b1a` (프로덕션), `withcenter-test-5` (테스트) |
| **CLAUDE.md** | `firebase/chat-v2/CLAUDE.md` — Cloud Functions 코딩 가이드라인 |
| **문서** | `firebase/chat-v2/docs/chat/` — DB 스키마, 비즈니스 로직, 플로우차트, 코딩 가이드 |

**소스 코드 모듈 구조** (`firebase/chat-v2/functions/src/`):

| 모듈 | 파일 수 | 설명 |
|------|---------|------|
| `chat/` | 26개 | 채팅 핵심 로직 — 방 생성/수정, 메시지 처리, 입장/퇴장, 읽음 표시, 즐겨찾기 |
| `messaging/` | 11개 | FCM 푸시 알림 — 토큰 관리, 메시지 전송, 구독 처리 |
| `user/` | 2개 | 사용자 관련 로직 |
| `lib/` | 2개 | 유틸리티 함수 (즐겨찾기, 읽지 않은 메시지 카운트) |
| `common/` | 1개 | 공통 유틸리티 (배열 청킹) |

**배포 대상 Cloud Functions** (8개):

| 함수명 | 트리거 유형 | 기능 |
|--------|-------------|------|
| `onChatMessageCreated` | RTDB 트리거 | 메시지 생성 시 후처리 (읽지 않은 메시지 카운트, Join 업데이트) |
| `onResetChatJoin` | RTDB 트리거 | 채팅 조인 초기화 (읽음 표시) |
| `onCustomNameUpdated` | RTDB 트리거 | 사용자 정의 이름 업데이트 반영 |
| `onFavorite` | RTDB 트리거 | ~~즐겨찾기 추가/제거~~ -- v7 API(`bookmark.*`)로 마이그레이션됨. 앱 호환용으로 유지 |
| `onPushMessageCreated` | RTDB 트리거 | 푸시 메시지 생성 → FCM 전송 |
| `onCreateGroupChatRoom` | HTTP 요청 | 그룹 채팅방 생성 |
| `onUpdateGroupChatRoom` | RTDB 트리거 | 그룹 채팅방 정보 업데이트 |
| `onUpdateGroupChatRoomImage` | RTDB 트리거 | 그룹 채팅방 이미지 업데이트 |

**배포 명령어**:

```bash
cd firebase/chat-v2/functions
npm run deploy:philgo    # 프로덕션 배포
npm run deploy:test5     # 테스트 환경 배포
```

**채팅 관련 작업 시 반드시 이 문서와 `firebase/chat-v2/CLAUDE.md`를 함께 참조한다.**

### 코멘트 스레드 세로선 → [web/v7-comment-thread-line.md](references/web/v7-comment-thread-line.md)

Reddit 스타일 코멘트 스레드 세로선의 완전 구현 가이드이다. PHP 재귀 렌더링(`renderCommentThread()`)으로
`.comment-node` 트리를 생성하고, CSS 절대 위치 `.thread-line`(1px, `#94a3b8`, `left: 17px`)으로
아바타 바로 아래에서 세로선을 시작한다. JavaScript `adjustThreadLines()` 함수가 마지막 직접 자식의
상단까지만 세로선 높이를 동적 계산하며, `::before` 의사 요소로 모든 직접 자식에 `border-bottom-left-radius`
L자 곡선 연결선을 표시한다. 세로선 클릭으로 접기/펼치기, "[+N개 답글]" 텍스트 클릭으로 펼치기를 지원한다.
HTML/CSS/JS 전체 소스코드, 좌표 계산 다이어그램, 복구 체크리스트를 포함한다.

### 관리자 대시보드 → [web/v7-admin.md](references/web/v7-admin.md)

v7 관리자 대시보드 시스템(`/admin/**` 경로)의 전체 아키텍처를 상세히 문서화합니다.
`v7/layout.php`에서 `/admin` 경로 감지 시 관리자 전용 레이아웃(`admin-layout.php`)으로 분기하며,
`AuthService::getLoginUser()`와 `Config::admins()` Firebase UID 배열 대조로 관리자 인증을 처리합니다.
8개 관리자 페이지(대시보드, 회원, 게시판, 글 목록, 코멘트, 업소록, 설정, **글 이동**)의 PHP SSR 구현,
`Db::pdo()` 직접 쿼리 패턴, 검색/필터/페이지네이션 공통 코딩 패턴, `admin.css` CSS 클래스 체계(탑바·네비·통계카드·테이블·배지·버튼·페이지네이션),
반응형 모바일 대응, `admin.js` 유틸리티 함수, DB 테이블 컬럼 참조(sf_member, sf_post_data, sf_post_config, sf_member_blocks, company),
새 관리자 페이지 추가 방법, **게시글 목록 관리자 기능**(체크박스 선택, 일괄 작업 UI, 글 이동/차단/임시보관, Vue.js 동적 카테고리 선택)을 포함합니다.
**관리자 페이지 관련 작업 시 반드시 이 문서를 참조한다.**

### 레이아웃 시스템 → [web/v7-layout.md](references/web/v7-layout.md)

v7 홈페이지의 5-column flex 레이아웃 구조를 완전히 문서화합니다.
CSS 변수(`--v7-sidebar-width: 240px`, `--v7-wing-width: 120px`, `--v7-gap: 16px`,
`--v7-max-width: 1320px`, `--v7-topbar-height: 2.25rem`), 탑바·헤더·사이드바·메인·날개·푸터 각 영역의
정확한 CSS 규칙, 3단계 반응형 브레이크포인트(모바일 <992px, lg ≥992px, xl ≥1200px)에서의 레이아웃 전환,
`layout.css`/`responsive.css`/`utilities.css` 3파일의 핵심 코드, 색상 팔레트(`#7f1d1d` 브랜드색,
`#dc2626` 강조색 등), 폰트 크기 체계(0.8em~1em), 위젯 포함 관계도, `layout.php` 핵심 소스코드,
레이아웃 수정 시 절대 변경 금지 항목과 연쇄 확인 필요 항목을 상세히 기술합니다.
**레이아웃 관련 작업 시 반드시 이 문서를 참조하여 레이아웃이 흐트러지지 않도록 한다.**

### 위젯 시스템 → [web/v7-widgets.md](references/web/v7-widgets.md)

v7 홈페이지의 PHP include 기반 위젯 시스템을 상세히 다룹니다.
`v7/widgets/` 폴더에 모듈별(`layout/`, `home/`, `shared/`, `user/`, `post/`) 독립 PHP 파일로 분리된 위젯 구조, 5-column 레이아웃 배치,
레이아웃 위젯 8개(topbar, header-mobile/desktop, sidebar-left/right, wing-left/right, footer),
공유 위젯 4개(exchange-rate, company-categories, latest-companies, stats — 사이드바와 모바일 양쪽에서
동일 파일을 include하여 DRY 원칙 적용), 콘텐츠 위젯 5개(mobile-top-banners, news-tabs,
mobile-wing-banners, latest-posts, popular-posts), **사용자 호버 드롭다운 위젯**(user-hover-dropdown —
글/코멘트 작성자 아바타/닉네임 호버 시 프로필/채팅/글목록/차단 등 드롭다운 메뉴 표시),
게시글 목록 위젯(post-list-widget), layout.php 핵심 소스코드(~140줄),
index.php 공유 위젯 사용 패턴, 새 위젯 추가 방법을 포함합니다.

### 폰트 로딩 및 적용 → [web/v7-fonts.md](references/web/v7-fonts.md)

v7 홈페이지의 폰트 로딩 전략을 상세히 다룹니다.
모든 OS(Mac, Windows, Android)에서 **Noto Sans KR** 웹폰트를 통일 사용합니다.
CSS font-family 스택에서 `'Noto Sans KR'`을 최우선으로 배치하고,
Google Fonts를 조건 없이 모든 기기에서 로드합니다.
`v7/css/layout.css` 26행의 font-family 선언, `v7/layout.php` 63~67행의
Google Fonts 로딩 코드, 폴백 폰트 구성을 포함합니다.

### Firebase 웹 SDK 초기화 및 사용 → [web/v7-firebase.md](references/web/v7-firebase.md)

필고 웹 페이지에서 Firebase JavaScript SDK(compat 버전 12.3.0)를 초기화하고 사용하는 전체 흐름을 다룹니다.
`etc/default-head-javascript.php`의 `<head>`에서 `ready()`와 `firebase_ready()` 래퍼 함수를 정의하고,
`etc/firebase/firebase-js-setup.php`에서 5개 Firebase SDK 스크립트를 `defer`로 로딩하며
`firebaseConfig`와 `vapidKey`를 PHP 서버에서 주입합니다. `firebase_ready()` 함수는 싱글톤 패턴으로
`firebase.initializeApp()`을 한 번만 호출하여 초기화를 보장합니다. Auth(`onAuthStateChanged`),
Realtime Database(Presence 시스템, 채팅 알림), Cloud Messaging(FCM 토큰 획득/저장/권한 요청),
Storage 사용법과 서비스 워커(`firebase-messaging-sw.js`) 구조, 전역 변수(`appConfig.token`,
`window.__HYDRATE__`) 흐름, 안티패턴을 상세히 기술합니다.

### 업소록 홈페이지 → [web/v7-company.md](references/web/v7-company.md)

v7 업소록 웹 홈페이지의 전체 구현을 상세히 다룹니다.
목록(`v7/company/index.php`)과 상세(`v7/company/view.php`) 페이지는 SSR로 구현하여
`CompanyService::list()`/`CompanyService::info()`를 호출해 서버에서 렌더링하고,
등록/수정(`v7/company/register.php`)은 Vue.js CDN CSR로 `v7api('company.mine')`,
`v7api('company.update')`, `v7apiUpload()`를 통해 동적 처리합니다.
`Route::companyList()`/`companyView()` URL 헬퍼, `url()->company->*` 프로퍼티 접근,
디렉토리 인덱스 폴백(`/company` → `v7/company/index.php`), `Config::companyCategoryIcon()`
등 16개 카테고리 매핑, SEO(`Seo::title/description/canonical/ogImage`),
사이드바 위젯 2개(`shared.company-categories.php`, `shared.latest-companies.php`),
CSS 3파일(`index.css`, `view.css`, `register.css`)의 핵심 코드를 포함합니다.

> 웹/서버(PHP, Vue.js, Web Awesome Pro, Nginx, 폰트, 위젯, 레이아웃) 관련 문서는 모두 `references/web/` 폴더에 작성한다.

### 검색 (Google CSE) → [web/v7-search.md](references/web/v7-search.md)

v7 검색 기능의 전체 구현을 상세히 다룹니다.
Google Custom Search Engine(CSE)을 사용한 검색 결과 페이지(`v7/post/search.php`), 데스크톱 헤더 검색 폼(`.v7-search-form`,
debounce 자동 제출), 모바일 헤더 검색 링크, `Route::postSearch()` URL 헬퍼, `url()->search` / `url()->post->search()` 프로퍼티,
검색 CSS(`v7/post/search.css`), 검색 JS(`v7/js/search.js`),
향후 활용 가능한 FULLTEXT 검색 서비스(`SearchService`), PEST 브라우저 테스트(7개)를 포함합니다.
**검색 관련 작업 시 반드시 이 문서를 참조한다.**

### 카카오톡 소셜 로그인 (웹) → [web/v7-web-kakoatalk-social-login.md](references/web/v7-web-kakoatalk-social-login.md)

v7 웹 홈페이지에서 카카오톡 소셜 로그인을 구현한 전체 가이드를 다룹니다.
카카오는 Firebase에서 직접 지원하지 않으므로 Firebase Custom Token 방식을 사용하며,
서버 측에서 카카오 OAuth Authorization Code 흐름(start → callback → complete 3파일)을
처리합니다. `KakaoLoginService`(lib/user/)가 카카오 API 호출과 Firebase Custom Token 발급을
담당하고, complete.php에서 `signInWithCustomToken()` → `v7api('user.socialLogin')` 호출로
기존 소셜 로그인 흐름에 합류합니다. 카카오 키는 `V7\Utils\Config` 클래스에 통합되어 있으며,
Redirect URI는 `Config::kakaoRedirectUri()`로 동적 생성합니다.
**카카오 로그인 관련 작업 시 반드시 이 문서를 참조한다.**

### 네이버 소셜 로그인 (웹) → [web/v7-web-naver-social-login.md](references/web/v7-web-naver-social-login.md)

v7 웹 홈페이지에서 네이버 소셜 로그인을 구현한 전체 가이드를 다룹니다.
카카오톡과 동일한 Firebase Custom Token 방식을 사용하며,
서버 측에서 네이버 OAuth Authorization Code 흐름(start → callback → complete 3파일)을
처리합니다. `NaverLoginService`(lib/user/)가 네이버 API 호출과 Firebase Custom Token 발급을
담당하고, complete.php에서 `signInWithCustomToken()` → `v7api('user.socialLogin')` 호출로
기존 소셜 로그인 흐름에 합류합니다. 카카오와의 주요 차이점: `client_secret` 필수,
토큰 교환 시 `state` 전달, 프로필 응답이 `response` 중첩 구조(`$data['response']['id']`).
**네이버 로그인 관련 작업 시 반드시 이 문서를 참조한다.**

### 이벤트 통합 개요 → [event/v7-event-overview.md](references/event/v7-event-overview.md)

필고 포인트 이벤트 시스템 전체를 하나로 통합 정리한 개요 문서입니다.
스피닝 휠(서버 API + Flutter 클라이언트), QR 코드 삼단콤보(QR 발행→스캔→재방문→후기),
포인트 로그 인프라(sf_point_log), DB 스키마 요약, 확률 계산·안티치트·스타벅스 쿠폰 관리 로직,
module/action 매트릭스, 핵심 PHP/Dart 코드 스니펫을 포함합니다.
이벤트 관련 작업 시 **이 문서를 먼저 읽고** 필요에 따라 개별 상세 문서로 이동하세요.

### 이벤트 쿠폰 관리 → [event/v7-event-coupon.md](references/event/v7-event-coupon.md)

`event_coupons` DB 테이블 기반 범용 쿠폰 관리 시스템의 전체 구조를 다룹니다.
관리자가 v7 Upload API로 QR 이미지를 업로드하여 쿠폰을 등록하고,
스피닝 휠 당첨 시 `SELECT ... FOR UPDATE`로 race condition을 방어하며 자동 배정합니다.
상태 흐름(`available → won → sent`), 관리자 위젯(Vue.js 등록/수정/삭제/전송 관리),
EventCouponService/Repository 클래스 구조, v7 API 엔드포인트
(`event.createCoupon`, `event.deleteCoupon`, `event.updateCoupon`, `event.updateCouponSent`,
`event.listCoupons`, `event.couponStats` — 모두 `EventController`에서 `axios.post('/api.php')` 방식으로 호출),
동적 확률 조정(쿠폰 0개 시 스타벅스 weight → 50P 합산), 당첨 시 freetalk 자동 게시글 작성,
Flutter 앱/웹에서의 쿠폰 표시 로직을 상세히 기술합니다.
최신 `database/philgo.sql` 스키마에서 `description`(쿠폰 설명), `viewed_at`(QR 최초 확인 시간),
`expired_at`(만료 시각) 컬럼이 추가되었고, `status`가 enum 타입으로 변경되었습니다.
기존 스키마(`etc/database-schema/`)에는 이 테이블이 존재하지 않으므로 실제 서버 배포 시 신규 생성이 필요합니다.

### 이벤트 응모 (스피닝 휠) → [app/v7-event-entry.md](references/app/v7-event-entry.md)

스피닝 휠(원판 돌리기) 기반 이벤트 응모 시스템의 상세 문서입니다.
COT/TOT 분석, CustomPainter 렌더링, 가중치 기반 섹션, 회전 애니메이션,
서버 기반 안티치트, 연속 돌리기(Auto Spin), 사운드, v7 API 연동,
사용자 프로필 표시, 다국어 지원, 파일 구조를 상세히 다룹니다.
`v7api()` 함수 시그니처, 매개변수, 반환값, 에러 처리 패턴,
기존 `func()`과의 비교, 핵심 헬퍼 함수(`createDio()`, `patchToken()`),
`PhilgoConfig.v7ApiEndpoint` 설정, 위젯에서의 3상태 관리 패턴
(로딩/에러/성공), Firebase ID Token 인증 흐름, 실전 코드 예제,
**v7apiFileUpload() 파일 업로드 함수**, **V7FileUpload 재활용 위젯**,
v7 위젯 목록을 포함합니다.

### 데이터베이스 스키마 → [database/philgo.sql](database/philgo.sql)

필고 프로젝트의 **전체 MariaDB 데이터베이스 스키마**(최신 버전)가 `database/philgo.sql`에 저장되어 있습니다.
이 파일에는 모든 테이블의 CREATE TABLE 문, 인덱스, AUTO_INCREMENT 설정이 포함되어 있으며,
v7 시스템 개발 시 테이블 구조, 컬럼명, 데이터 타입, 인덱스 등을 참조할 때 **반드시 이 파일을 확인**해야 합니다.
주요 테이블: `sf_member`(회원), `sf_post_data`(게시글), `sf_post_config`(게시판 설정), `uploads`(v7 파일 업로드),
`company`(업체), `company_meta`(업체 메타), `sf_point_log`(포인트 로그) 등.

### 모듈별 API 문서 → [references/api/](references/api/)

| 모듈 | 문서 | 상태 |
|------|------|------|
| User | [api/v7-user.md](references/api/v7-user.md) | ✅ 완료 |
| Upload | [api/v7-upload.md](references/api/v7-upload.md) | ✅ 완료 |
| AI | [api/v7-ai.md](references/api/v7-ai.md) | ✅ 완료 |
| Company | [api/v7-company.md](references/api/v7-company.md) | ✅ 완료 |
| Company QR Code | [api/v7-company-qr-code.md](references/api/v7-company-qr-code.md) | ✅ 완료 |
| Company Visit Review | [api/v7-company-visit-review.md](references/api/v7-company-visit-review.md) | ✅ 완료 |
| Post | [api/v7-post.md](references/api/v7-post.md) — 게시글 CRUD + Reddit 스타일 코멘트 스레드 (avatar-col 독립 분리 + thread-line 절대 위치 세로선 + adjustThreadLines() 동적 높이 계산 + 세로선 클릭/답글 텍스트 클릭 접기/펼치기) | ✅ 완료 |
| Event | [api/v7-event.md](references/api/v7-event.md) | ✅ 완료 |
| Settings | [api/v7-settings.md](references/api/v7-settings.md) | ✅ 완료 |
| Travel | [api/v7-travel.md](references/api/v7-travel.md) | ✅ 완료 |
| Bookmark | [api/v7-bookmark.md](references/api/v7-bookmark.md) — 즐겨찾기 그룹(폴더) 관리 + 즐겨찾기 항목 CRUD. 채팅방 즐겨찾기(`entity_type='chat_room'`)에 사용. Firebase RTDB 기반에서 v7 API(`bookmarks`/`bookmark_groups` 테이블)로 마이그레이션 완료 | ✅ 완료 |

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

## 🔴🔴🔴 Flutter Driver / E2E 테스트 절대 금지 🔴🔴🔴

> **⛔ Flutter 앱 개발 또는 소스 코딩 시 Flutter Driver 테스트, E2E 테스트, Integration Test를 절대로 작성하거나 실행하지 않는다. ⛔**

| 금지 항목 | 설명 |
|-----------|------|
| ❌ **flutter_driver** | `flutter_driver` 패키지를 사용한 테스트 코드 작성 금지 |
| ❌ **integration_test** | `integration_test` 패키지를 사용한 테스트 코드 작성 금지 |
| ❌ **flutter_test** | `flutter_test` 패키지를 사용한 위젯/유닛 테스트 코드 작성 금지 |
| ❌ **테스트 디렉토리** | `test/`, `integration_test/`, `test_driver/` 디렉토리에 파일 생성 금지 |
| ❌ **테스트 실행 명령** | `flutter drive`, `flutter test` 등 테스트 실행 명령어 사용 금지 |

- 테스트가 필요한 경우 **CLAUDE.md의 "Debugging with Dart Tooling Daemon (DTD)" 섹션에 정의된 DTD 방식만** 사용한다.
- DTD 방식: hot reload를 사용하여 `initState()`에 임시 테스트 코드를 주입하는 방식

---

## 🔴🔴🔴 Flutter v7 코드 저장 경로 — 예외 없음 🔴🔴🔴

> **필고 앱(Flutter) 프로젝트 루트 경로:**
> `/Users/thruthesky/apps/flutter/philgo_app`

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

## 🔴 Flutter State vs Service 아키텍처 — 절대 원칙 🔴

> **State 클래스는 최소한의 상태 저장 코드만, 복잡한 로직은 반드시 Service 클래스에 모은다.**
> 상세 가이드 및 코드 예시: [app/v7-flutter-api.md § 16. State vs Service 아키텍처](references/app/v7-flutter-api.md)

| 계층 | 역할 | 금지 사항 |
|------|------|-----------|
| **State** (ChangeNotifier) | 필드 저장, `notifyListeners()`, Service 호출 결과 저장 | API 호출, 비즈니스 로직, 데이터 변환 금지 |
| **Service** | API 호출, 데이터 변환, 에러 처리, 복잡한 비즈니스 로직 | UI 코드, BuildContext, setState 금지 |
| **Screen/Widget** | 위젯 빌드, 로컬 UI 상태(setState), 네비게이션 | API 호출, 비즈니스 로직, 데이터 변환 금지 |

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
| `ApiListView<T>` | `lib/v7_api/widgets/api_list_view/api_list_view.dart` | v7 API 무한 스크롤 리스트 (infinite_scroll_pagination encapsulation) | ✅ **필수** |

> **🔴🔴🔴 ApiListView 데이터 모델 클래스 필수 — 절대 규칙 🔴🔴🔴**
>
> `ApiListView<T>`의 제네릭 타입 `T`에 **`Map<String, dynamic>`을 절대로 사용하지 않는다.**
> **반드시 `lib/v7_api/models/` 폴더에 데이터 모델 클래스를 만들고, `fromJson()` 팩토리를 통해 변환하여 사용해야 한다.**
>
> - ❌ `ApiListView<Map<String, dynamic>>` — **절대 금지**
> - ✅ `ApiListView<PointLog>` — 데이터 모델 클래스 필수
> - ✅ `ApiListView<Company>` — 데이터 모델 클래스 필수

상세 사용법: → [app/v7-flutter-api.md](references/app/v7-flutter-api.md) 11~15장 참조

---

## httpYac API 테스트 파일

`.claude/skills/v7-skill/httpYac/` 폴더에 httpYac 확장용 `.http` 테스트 파일을 저장한다.
각 API 모듈별로 테스트 쿼리를 작성하여 Assert, 스크립팅, 요청 체이닝으로 API 동작을 자동 검증할 수 있다.

| 파일 | 용도 |
|------|------|
| `event-spin-test.http` | Event(스피닝 휠) API 테스트 |
| `post-thumbnail-test.http` | Post 글 생성 시 썸네일 URL 저장 테스트 |

> 새 모듈 API를 추가할 때마다 `httpYac/<module>-test.http` 파일을 작성한다.
> 파일 내에 `@baseUrl`, `@session_id` 등 변수를 정의하고 ▶ (Send) 버튼으로 실행한다.
> httpYac 문법 상세는 → [httpYac/yac.md](httpYac/yac.md) 참조.

### httpYac 핵심 문법

| 기능 | 문법 | 설명 |
|------|------|------|
| 응답 변수화 | `# @name 이름` | 응답을 변수로 저장하여 다른 요청에서 `{{이름.필드}}` 참조 |
| 요청 체이닝 | `# @ref 이름` / `# @forceRef 이름` | 현재 요청 전에 다른 요청을 먼저 실행 |
| SSL 무시 | `# @no-reject-unauthorized` | 로컬 HTTPS 자체 서명 인증서 허용 |
| Assert | `?? status == 200` | 응답 상태, 헤더, 바디 자동 검증 |
| 스크립팅 | `{{ 코드 }}` | 요청 전/후 JavaScript 실행, 응답 파싱 |
| 글로벌 변수 | `$global.변수 = 값` | 모든 요청에서 접근 가능한 글로벌 변수 |

### PEST 브라우저 테스트 (E2E) → [v7-pest-browser-test.md](references/v7-pest-browser-test.md)

PEST v4 Browser Plugin + Playwright 기반 브라우저 E2E 테스트의 완벽 가이드이다.
`tests/Browser/*.php` 파일에서 실제 브라우저(Chromium/Firefox/Safari)를 실행하여
페이지 방문(`visit()`), 요소 클릭(`click()`), 텍스트 입력(`type()`/`fill()`), 폼 조작(`select()`, `check()`),
60+ assertion 메서드(`assertSee()`, `assertPresent()`, `assertUrlIs()`, `assertNoSmoke()` 등),
스크린샷 캡처(`screenshot()`), 디바이스 에뮬레이션(`on()->mobile()`), 디버깅(`debug()`, `waitForKey()`)을
수행하는 방법을 설명한다. 필고 프로젝트 전용 패턴(v6/v7 URL, 그룹 태깅, 로그인 테스트, 패밀리사이트 테스트),
v7 관리자 대시보드 2차 인증 쿠키 패턴, Playwright 타임아웃 방지 폼 제출(`script()` + `waitForEvent('load')`),
Vue.js v-model 입력값 조작(nativeInputValueSetter), `script()`의 return 키워드 주의사항,
`Pest.php` 전역 설정, CI/CD GitHub Actions 설정도 포함한다.
**브라우저 테스트 작성 시 반드시 이 문서를 참조한다.**

#### 🔴🔴🔴 PEST 브라우저 테스트 PHP 타입 안전성 (절대 규칙) 🔴🔴🔴

> **⛔ 브라우저 테스트 코드에서 반드시 PHPDoc 타입 힌트를 지정하여 intelephense P1006 에러가 발생하지 않도록 해야 한다. ⛔**

| 규칙 | 설명 |
|------|------|
| **`browserTest()` 래퍼 필수** | `test()` 대신 `browserTest()` 래퍼 함수 사용 — P1006 완전 해결 (`tests/Pest.php`에 정의) |
| **`$this->visit()` 타입 힌트 필수** | `/** @var \Pest\Browser\Api\PendingAwaitablePage $page */` 반드시 추가 |
| **`test()` 직접 사용 금지** | `test()->group()` 대신 `browserTest()->group()` 체이닝 사용 — P1006 에러 방지 |
| **`@noinspection` 필수** | 파일 상단에 `PhpUndefinedMethodInspection`, `PhpUndefinedFunctionInspection` 추가 |

> **상세 규칙**: → [v7-pest-browser-test.md](references/v7-pest-browser-test.md) 26.6절

#### 🔴 필고 프로젝트 전용 테스트 계정 (브라우저 테스트 필수)

| 계정 | session_id | 용도 |
|------|-----------|------|
| **로컬 관리자** | `090e2895f9280a7d7d6ec11d3f0ce483-186619` | 관리자 권한 테스트 |
| **Durian** (idx: 190076) | `2278018daa75e0ab879d8791fb0e2b2d-190076` | 일반 사용자 테스트 |
| **Poster** (idx: 193824) | `d87e7374e22f1bf1aaebbbb97d280115-193824` | 글 쓰기 테스트 (`poster@philgo.com:12345a,*`) |

> 세션 쿠키 설정: `$page->script("document.cookie = 'session_id=세션ID; path=/'")` 후 `->navigate()`
> 이메일 로그인: `$page->type('phone_number', 'banana@test.com:12345a,*')->click('SMS 코드 전송')`
> 상세 정보: → [v7-accounts.md](references/v7-accounts.md) | 전체 가이드: → [v7-pest-browser-test.md](references/v7-pest-browser-test.md) 26.0절

---

## 🔴🔴🔴 v7 홈페이지는 Bootstrap을 사용하지 않는다 — 절대 금지 🔴🔴🔴

> **⛔⛔⛔ v7 웹 홈페이지(`v7/` 폴더)에서는 Bootstrap CSS를 절대로 사용하지 않는다. ⛔⛔⛔**
> **Bootstrap은 v6(레거시)에서만 사용하며, v7은 Web Awesome Pro + 커스텀 CSS로 완전히 대체한다.**

| 항목 | v6 (레거시) | v7 (신규) |
|------|------------|-----------|
| **UI 프레임워크** | Bootstrap 5.3 | **Web Awesome Pro v3.3.1** (Bootstrap 완전 배제) |
| **반응형 유틸리티** | `d-none`, `d-lg-block`, `d-xl-block` 등 | `v7-lg`, `v7-xl`, `v7-mobile-only` 등 커스텀 CSS (`v7/css/responsive.css`) |
| **그리드 시스템** | `row`, `col-md-6` 등 | CSS flex/grid 직접 작성 (`v7/css/layout.css`) |
| **컴포넌트** | Bootstrap Card, Modal, Dropdown 등 | `wa-card`, `wa-dialog`, `wa-dropdown` 등 Web Awesome 컴포넌트 |
| **CSS 변수** | `--bs-*` | `--wa-*` (Web Awesome) + `--v7-*` (커스텀) |

**사용 금지 목록:**
- ❌ `class="d-none d-lg-block"` → ✅ `class="v7-lg"`
- ❌ `class="row"`, `class="col-md-6"` → ✅ CSS flex/grid 직접 작성
- ❌ `class="btn btn-primary"` → ✅ `<wa-button variant="brand">`
- ❌ `class="card"` → ✅ `<wa-card>`
- ❌ `class="container"` → ✅ `class="v7-page-wrapper"` 또는 `max-width` 직접 지정
- ❌ Bootstrap CDN `<link>` 또는 `<script>` → ✅ 포함하지 않음

> 상세 내용은 → [web/v7-fonts.md](references/web/v7-fonts.md), [web/v7-widgets.md](references/web/v7-widgets.md) 참조.

---

## 🔴🔴🔴 Web Awesome Pro + Font Awesome Pro — 최대 활용 필수 🔴🔴🔴

v7 홈페이지는 **Web Awesome Pro v3.3.1** (유료 버전)과 **Font Awesome Pro v7.2.0** (유료 버전)을 UI 라이브러리로 사용한다.

> **⛔⛔⛔ 절대 규칙: 이 두 유료 라이브러리의 기능을 최대한 활용해야 한다. ⛔⛔⛔**
> **커스텀 CSS/HTML로 직접 구현하기 전에, 반드시 Web Awesome 컴포넌트와 Font Awesome 아이콘으로 해결할 수 있는지 먼저 확인한다.**
> **유료 라이브러리를 사용하는 이유는 풍부한 컴포넌트와 아이콘을 활용하기 위함이므로, 사용하지 않으면 라이선스 비용이 낭비된다.**

| 라이브러리 | 버전 | 라이선스 | 활용 범위 |
|-----------|------|---------|----------|
| **Web Awesome Pro** | v3.3.1 | 유료 (Pro) | 모든 UI 컴포넌트 (버튼, 입력, 다이얼로그, 카드, 탭, 드롭다운 등) |
| **Font Awesome Pro** | v7.2.0 | 유료 (Pro) | 모든 아이콘 (Solid, Regular, Light, Thin, Duotone, Sharp 스타일 포함) |

### 최대 활용 원칙

| 원칙 | 설명 |
|------|------|
| **컴포넌트 우선** | 버튼, 입력, 셀렉트, 다이얼로그, 카드, 탭, 드롭다운, 툴팁 등 UI 요소는 **반드시 Web Awesome 컴포넌트**(`wa-button`, `wa-input`, `wa-dialog` 등)를 사용한다. `<button>`, `<input>` 등 네이티브 HTML 태그를 직접 스타일링하지 않는다. |
| **CSS 유틸리티 우선** | 레이아웃은 Web Awesome CSS 유틸리티(`wa-stack`, `wa-cluster`, `wa-grid`, `wa-sidebar` 등)를 우선 사용한다. |
| **아이콘 적극 활용** | Font Awesome Pro v7.2.0의 풍부한 아이콘 세트(Solid, Regular, Light, Thin, Duotone, Sharp)를 적극 활용한다. Pro 전용 아이콘과 스타일을 최대한 사용한다. |
| **CSS 변수 활용** | Web Awesome의 CSS 커스텀 속성(`--wa-*`)을 활용하여 테마와 스타일을 일관되게 관리한다. |
| **커스텀 CSS 최소화** | Web Awesome 컴포넌트의 내장 속성, 슬롯, CSS 파트로 해결 가능한 스타일링은 커스텀 CSS를 작성하지 않는다. |

### AI 활용 가이드

AI(Claude Code 등)를 통해 Web Awesome 컴포넌트를 활용한 UI 개발을 효율적으로 수행할 수 있다.

### llms.txt 활용

Web Awesome 배포판에 포함된 `llms.txt` 파일은 AI가 컴포넌트 목록과 공식 문서 URL을 빠르게 파악할 수 있도록 설계된 파일이다.

| 파일 위치 | 설명 |
|-----------|------|
| `v7/dist-cdn/llms.txt` | Web Awesome 배포판에 포함된 llms.txt |
| `llms.txt` (프로젝트 루트) | 동일 내용 (루트 접근용) |

**프롬프트 예시:**

```
@llms.txt 를 참고해서 wa-button 컴포넌트로 로그인 버튼 코드 작성해줘

@v7/dist-cdn/llms.txt 를 참고해서 wa-card와 wa-input으로 회원가입 폼 만들어줘
```

### webawesome 스킬 활용

프로젝트에 `webawesome` 스킬(`.claude/skills/webawesome/`)이 설치되어 있다.
이 스킬에는 Web Awesome의 **모든 컴포넌트에 대한 상세한 레퍼런스 문서**(속성, 이벤트, 슬롯, CSS 변수, 예제 코드)가 포함되어 있어,
AI가 정확한 코드를 작성할 수 있다.

**프롬프트 예시:**

```
webawesome 스킬을 참고해서 wa-dialog로 확인 모달 만들어줘

wa-select와 wa-option으로 카테고리 선택 드롭다운 만들어줘 (webawesome 스킬 참조)
```

### 두 방법의 차이

| 항목 | llms.txt | webawesome 스킬 |
|------|----------|-----------------|
| **내용** | 컴포넌트 목록 + 공식 문서 URL 링크 | 각 컴포넌트별 상세 레퍼런스 (속성, 이벤트, 슬롯, CSS 변수, 예제) |
| **용도** | 어떤 컴포넌트가 있는지 빠르게 탐색 | 특정 컴포넌트의 정확한 사용법 확인 |
| **장점** | 간결, 빠른 개요 파악 | 상세한 코드 예제와 옵션 제공 |

> 상세 내용은 → [web/v7-overview.md](references/web/v7-overview.md) 8장 「AI(Claude, LLM)를 활용한 Web Awesome 개발 방법」 참조.

---

## 🔴🔴🔴 v7 홈페이지는 다크 모드를 적용하지 않는다 — 절대 규칙 🔴🔴🔴

> **⛔⛔⛔ v7 웹 홈페이지(`v7/` 폴더)에서는 다크 모드(Dark Mode)를 적용하지 않는다. ⛔⛔⛔**
> **v7 홈페이지는 라이트 모드(Light Mode) 전용으로 운영된다.**
> **다크 모드 관련 CSS, JavaScript, 미디어 쿼리를 작성하거나 테스트할 필요가 없다.**

| 항목 | 규칙 |
|------|------|
| **다크 모드 CSS** | `@media (prefers-color-scheme: dark)` 미디어 쿼리 작성 금지 |
| **color-scheme** | CSS `color-scheme` 속성은 `light`만 지정 (`light dark` 금지) |
| **다크 모드 테스트** | 다크 모드에서의 디자인 확인/테스트 불필요 |
| **다크 모드 변수** | 다크 모드 전용 CSS 변수(`--dark-*` 등) 작성 금지 |
| **Web Awesome 다크 테마** | Web Awesome의 다크 테마 클래스(`wa-theme-dark` 등) 적용 금지 |

**이유:**
- v7 홈페이지는 라이트 모드 전용으로 설계되었다
- 다크 모드를 지원하지 않음으로써 디자인 일관성과 유지보수 효율성을 높인다
- Web Awesome Pro의 기본 라이트 테마(Blue)를 그대로 활용한다

> **참고**: v6(레거시) 홈페이지는 Bootstrap 기반으로 다크 모드를 지원하지만, v7은 이와 무관하게 라이트 모드 전용이다.

---

## 🔴🔴🔴 v7 색상 테마: 블루 기본 + 메인 메뉴 헤더만 빨간색 — 절대 규칙 🔴🔴🔴

> **⛔⛔⛔ v7 홈페이지의 기본 테마 색상은 블루(Blue)이다. Web Awesome Pro의 기본 default theme 색상(Blue)을 그대로 사용한다. ⛔⛔⛔**
> **단 하나의 예외: 데스크탑 상단 메인 메뉴의 1차 카테고리 바탕색만 빨간색(`#7f1d1d`)으로 표시한다.**
> **그 외 모든 UI 요소(버튼, 링크, 탭, 페이지네이션, 배지, 폼 요소 등)는 블루 테마를 따른다.**

### 색상 테마 원칙

| 원칙 | 설명 |
|------|------|
| **기본 테마: 블루** | Web Awesome Pro의 기본 default theme(Blue)를 그대로 사용한다. `--wa-color-brand-*` CSS 변수가 블루 계열로 설정된 기본 상태를 유지한다. |
| **🔴 유일한 예외: 메인 메뉴 헤더** | 데스크탑 상단의 메인 메뉴 1차 카테고리 헤더(`.v7-main-menu .menu-col-header`)만 빨간색 배경(`#7f1d1d`)을 사용한다. 이것은 필고 브랜드 아이덴티티를 나타내는 유일한 빨간색 영역이다. |
| **그 외 모두 블루** | 메인 메뉴 헤더를 제외한 모든 UI 요소는 블루 테마를 따른다. 빨간색 계열을 임의로 사용하지 않는다. |

### 색상 적용 가이드

| UI 요소 | 색상 | 비고 |
|---------|------|------|
| **메인 메뉴 1차 카테고리 헤더** | `#7f1d1d` (빨간색 배경, 흰색 텍스트) | 🔴 **유일한 빨간색 예외 영역** |
| **버튼 (primary)** | 블루 (Web Awesome 기본 `wa-button variant="brand"`) | 블루 테마 |
| **링크** | 블루 (Web Awesome 기본 링크 색상) | 블루 테마 |
| **탭 활성 상태** | 블루 | 블루 테마 |
| **페이지네이션 활성 버튼** | 블루 | 블루 테마 |
| **배지, 태그** | 블루 | 블루 테마 |
| **폼 요소 포커스** | 블루 | 블루 테마 |
| **글쓰기 버튼** | 블루 | 블루 테마 |
| **섹션 타이틀 언더라인** | 블루 | 블루 테마 |
| **인기글 순위 뱃지** | 블루 | 블루 테마 |

### Web Awesome 기본 테마 활용

Web Awesome Pro의 기본 default theme는 **블루**이다. 별도의 테마 커스터마이징 없이 기본 상태를 그대로 사용하면 된다.

```css
/* ✅ 올바름: Web Awesome 기본 CSS 변수를 그대로 사용 (블루) */
/* --wa-color-brand-600 등은 기본값이 블루이므로 별도 오버라이드 불필요 */

/* ✅ 올바름: 컴포넌트는 기본 블루 테마를 따름 */
<wa-button variant="brand">확인</wa-button>

/* 🔴 유일한 예외: 메인 메뉴 헤더만 빨간색 */
.v7-main-menu .menu-col-header {
    background-color: #7f1d1d;   /* 필고 브랜드 빨간색 — 이 영역만 예외 */
    color: white;
}
```

### 잘못된 사용법 (금지)

```css
/* ❌ 금지: 메인 메뉴 헤더 외 영역에 빨간색 사용 */
.post-write-btn { background: #7f1d1d; }         /* ❌ → 블루로 변경 */
.pagination .active { background: #dc2626; }      /* ❌ → 블루로 변경 */
.section-title { border-bottom: 2px solid #7f1d1d; } /* ❌ → 블루로 변경 */
.rank-badge { background: #7f1d1d; }              /* ❌ → 블루로 변경 */

/* ❌ 금지: Web Awesome brand 색상을 빨간색으로 오버라이드 */
:root { --wa-color-brand-600: #dc2626; }          /* ❌ 절대 금지 */
```

> **참고**: 기존 CSS에 빨간색(`#7f1d1d`, `#dc2626`, `#991b1b`)이 하드코딩된 부분이 있다면, 메인 메뉴 헤더를 제외하고 모두 블루 테마(Web Awesome 기본 brand 변수)로 전환해야 한다.
> 상세 색상 팔레트 → [web/v7-layout.md](references/web/v7-layout.md) 「색상 팔레트」 섹션 참조.

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

## 기존 v6 코드와의 통합 (v6 레거시 페이지에서 v7 Service 사용)

기존 v6 페이지(page.header.php)에서 v7 시스템 Service를 사용할 수 있습니다:

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

---

## 🔴🔴🔴🔴🔴 v7 웹 홈페이지: API 호출 시 v7api() 함수 필수 사용 — 절대 규칙 🔴🔴🔴🔴🔴

> **⛔⛔⛔⛔⛔ 최최최우선 절대 규칙: v7 홈페이지(`v7/` 폴더)에서 v7 API를 호출할 때는 반드시 `v7api()` 함수를 사용해야 한다. ⛔⛔⛔⛔⛔**
> **`fetch()`, `axios.post()`, `XMLHttpRequest` 등으로 `/api.php`를 직접 호출하는 것은 엄격히 금지한다.**
> **이 규칙은 어떤 상황에서도, 어떤 이유로도 예외가 없다.**

### v7api() 함수란?

`/v7/js/v7api.js`에 정의된 v7 시스템 전용 API 호출 래퍼 함수이다. 이 함수는 다음 기능을 내장하고 있다:

| 내장 기능 | 설명 |
|----------|------|
| **입력값 핸들링** | `method` 파라미터를 자동으로 요청에 추가, 세션 ID는 쿠키로 자동 전송 |
| **에러 감지** | `success === false` 응답을 자동으로 감지하여 Error throw |
| **기본 에러 UI** | 에러 발생 시 `alert()`으로 사용자에게 에러 메시지 자동 표시 (`alertOnError: true` 기본값) |
| **에러 메시지 추출** | 서버 응답, HTTP 에러, 네트워크 에러 등 다양한 에러 상황에서 적절한 메시지 추출 |

### 올바른 사용법

```javascript
// ✅ 올바른 방법: v7api() 함수 사용
const result = await v7api('user.socialLogin', { id_token: idToken });
const posts = await v7api('post.list', { post_id: 'freetalk', limit: 10 });

// ✅ 에러 알림을 끄고 싶은 경우
const data = await v7api('user.me', {}, { alertOnError: false });

// ✅ 파일 업로드: v7apiUpload() 함수 사용
const uploaded = await v7apiUpload(file, 'company', 'visit_review');
```

### 잘못된 사용법 (절대 금지)

```javascript
// ❌ 절대 금지: fetch()로 직접 API 호출
const response = await fetch('/api.php', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ method: 'user.socialLogin', id_token: idToken }),
});

// ❌ 절대 금지: axios로 직접 API 호출
const res = await axios.post('/api.php', { method: 'post.list', post_id: 'freetalk' });

// ❌ 절대 금지: XMLHttpRequest로 직접 API 호출
const xhr = new XMLHttpRequest();
xhr.open('POST', '/api.php');
```

### fetch 직접 호출이 금지되는 이유

1. **에러 처리 누락**: `v7api()`는 `success === false` 응답을 자동 감지하여 에러를 throw한다. fetch를 직접 사용하면 이 로직을 매번 수동으로 작성해야 하며, 누락 시 에러가 무시된다.
2. **사용자 알림 누락**: `v7api()`는 에러 시 `alert()`으로 사용자에게 자동 알림한다. fetch를 직접 사용하면 에러가 콘솔에만 출력되고 사용자는 모른다.
3. **코드 중복**: 모든 API 호출마다 에러 처리, 응답 파싱, 메시지 추출 로직을 반복 작성해야 한다.
4. **일관성 저해**: 프로젝트 전체에서 API 호출 패턴이 달라져 유지보수가 어려워진다.

> **위반 사례 — 이런 코드가 발견되면 즉시 v7api()로 교체해야 한다:**
> - `fetch('/api.php', ...)` → `v7api('module.action', { ... })`
> - `axios.post('/api.php', ...)` → `v7api('module.action', { ... })`
> - `new URLSearchParams({ method: '...' })` → `v7api('module.action', { ... })`

---

## 🔴🔴🔴 v7 웹 홈페이지: 페이지별 CSS 파일 분리 — 필수 규칙 🔴🔴🔴

> **⛔ 각 PHP 페이지에 적용되는 CSS `<style>` 코드는 반드시 해당 PHP 파일과 같은 폴더에 별도 `.css` 파일로 분리해야 한다. ⛔**
> **PHP 파일 안에 `<style>` 태그로 CSS를 인라인 작성하는 것은 금지한다.**

### 규칙

| 규칙 | 설명 |
|------|------|
| **CSS 파일 위치** | PHP 파일과 **같은 폴더**, **같은 이름**으로 `.css` 확장자 파일 생성 |
| **PHP 파일 슬림 유지** | PHP 파일에는 HTML 구조와 로직만 유지, CSS는 외부 파일로 분리 |
| **`<style>` 태그 금지** | PHP 파일 내 `<style>...</style>` 인라인 CSS 작성 금지 |
| **`<link>` 태그로 로드** | 분리된 CSS 파일은 `<link rel="stylesheet" href="...">` 로 로드 |

### 올바른 예시

```
v7/user/login.php      ← PHP 페이지 (HTML + 로직만)
v7/user/login.css      ← 해당 페이지 전용 CSS (같은 폴더에 분리)
```

```php
<!-- v7/user/login.php -->
<link rel="stylesheet" href="/v7/user/login.css">
```

```css
/* v7/user/login.css */
.login-form { max-width: 400px; margin: 0 auto; }
.login-title { font-size: 1.2em; }
```

### 잘못된 예시 (금지)

```php
<!-- ❌ 절대 금지: PHP 파일 안에 <style> 태그로 CSS 인라인 작성 -->
<style>
.login-form { max-width: 400px; margin: 0 auto; }
.login-title { font-size: 1.2em; }
</style>
```

### CSS 파일 분류

| 분류 | 위치 | 설명 |
|------|------|------|
| **공통 CSS** | `v7/css/layout.css`, `v7/css/responsive.css`, `v7/css/utilities.css` | 전체 사이트에 적용되는 공통 스타일 |
| **페이지별 CSS** | 해당 PHP와 같은 폴더 (예: `v7/user/login.css`) | 해당 페이지에만 적용되는 스타일 |
| **위젯별 CSS** | `v7/widgets/` 폴더 (예: `v7/widgets/topbar.css`) | 해당 위젯에만 적용되는 스타일 |

---

## 🔴🔴🔴🔴🔴 v7 웹 홈페이지: URL 생성 시 url() 함수 필수 사용 — 절대 규칙 🔴🔴🔴🔴🔴

> **⛔⛔⛔⛔⛔ 최최최우선 절대 규칙: v7 홈페이지(`v7/` 폴더)에서 URL을 생성할 때는 반드시 `url()` 함수를 사용해야 한다. ⛔⛔⛔⛔⛔**
> **URL을 하드코딩하는 것은 엄격히 금지한다. 이 규칙은 어떤 상황에서도, 어떤 이유로도 예외가 없다.**

### url() 함수란?

`v7/utils/Url.php`에 정의된 v7 시스템 전용 URL 유틸리티 싱글톤 함수이다.
v6의 `href()` 함수와 동일한 패턴으로, 중첩 프로퍼티를 통해 모든 URL을 중앙에서 관리한다.

| 내장 기능 | 설명 |
|----------|------|
| **게시판 URL 매핑** | v6의 50+ 카테고리 URL을 v7 형식(`/post/list?category=X`)으로 자동 변환 |
| **중앙 집중 관리** | URL이 변경되면 `Url.php` 한 곳만 수정하면 전체 사이트에 반영 |
| **타입 안전성** | 문자열 하드코딩 대신 프로퍼티 접근으로 오타 방지 |
| **싱글톤 패턴** | `url()` 호출마다 새 인스턴스를 생성하지 않고 기존 인스턴스를 재사용 |

### 올바른 사용법

```php
<!-- ✅ 올바른 방법: url() 함수 사용 -->
<a href="<?= url()->home ?>">홈</a>
<a href="<?= url()->post->list->community ?>">커뮤니티</a>
<a href="<?= url()->post->list->qna ?>">질문답변</a>
<a href="<?= url()->user->login ?>">로그인</a>
<a href="<?= url()->user->profile ?>">프로필</a>
<a href="<?= url()->company->home ?>">업소록</a>

<!-- ✅ 동적 URL 생성 -->
<a href="<?= url()->post->view(123) ?>">글 보기</a>
<a href="<?= url()->post->create('qna') ?>">글 작성</a>
<a href="<?= url()->company->view(99) ?>">업소 보기</a>
```

### 잘못된 사용법 (절대 금지)

```php
<!-- ❌ 절대 금지: URL 하드코딩 -->
<a href="/">홈</a>
<a href="/post/list?category=freetalk">커뮤니티</a>
<a href="/post/list?category=qna">질문답변</a>
<a href="/user/login">로그인</a>
<a href="/user/profile">프로필</a>
```

### URL 구조

```
url()
├── home                          → '/'
├── search                        → '/post/search'
├── post (PostUrl)
│   ├── list (PostListUrl)
│   │   ├── community             → '/post/list?category=freetalk'
│   │   ├── qna                   → '/post/list?category=qna'
│   │   ├── discussion            → '/post/list?category=discussion'
│   │   ├── info                  → '/post/list?category=info'
│   │   ├── buyandsell            → '/post/list?category=buyandsell'
│   │   ├── job                   → '/post/list?category=wanted'
│   │   ├── travel                → '/post/list?category=travel'
│   │   └── ... (50+ 카테고리)
│   ├── view(idx)                 → '/post/view?idx=123'
│   ├── create(category)          → '/post/create?category=qna'
│   ├── update(idx)               → '/post/update?idx=123'
│   └── search(query)             → '/post/search?query=...'
├── user (UserUrl)
│   ├── login                     → '/user/login'
│   ├── profile                   → '/user/profile'
│   ├── logout                    → '/user/logout'
│   ├── settings                  → '/user/settings'
│   └── publicProfile(id)         → '/user/public-profile?idx_member=42'
└── company (CompanyUrl)
    ├── home                      → '/company'
    ├── view(idx)                 → '/company/view?idx=99'
    └── category(cat)             → '/company/category?category=...'
```

### v6 href()와의 대응 관계

| v6 (레거시) | v7 (신규) |
|------------|-----------|
| `href()->home` | `url()->home` |
| `href()->post->list->community` | `url()->post->list->community` |
| `href()->post->list->qna` | `url()->post->list->qna` |
| `href()->post->view($params)` | `url()->post->view($idx)` |
| `href()->user->login` | `url()->user->login` |
| `href()->user->profile` | `url()->user->profile` |
| `href()->company->home` | `url()->company->home` |

### 소스 파일

| 파일 | 설명 |
|------|------|
| `v7/utils/Url.php` | Url 클래스 + url() 전역 함수 정의 |
| `v7/boot.php` | Url.php를 자동 require (url() 함수를 즉시 사용 가능) |
| `tests/Unit/UrlTest.php` | PEST 유닛 테스트 |

---

## 🔴🔴🔴🔴🔴 v7 웹 홈페이지: v6 코드 사용 절대 금지 — 이 규칙은 절대로 예외 없음 🔴🔴🔴🔴🔴

> **⛔⛔⛔⛔⛔ 최최최우선 절대 규칙: v7 홈페이지(`v7/` 폴더)에서는 v6 코드를 단 한 줄도 사용하지 않는다. ⛔⛔⛔⛔⛔**
> **이 규칙은 다른 모든 규칙보다 우선한다. 어떤 상황에서도, 어떤 이유로도 예외가 없다.**
> **v7 홈페이지를 만들 때는 반드시 완전히 새로운 v7 코드를 작성해야 한다.**
> **v6 코드(boot.php, page.header.php, widget/, func(), pdo(), login(), t(), is_dev(), is_admin(), in(), href() 등 모든 v6 전역 함수)를 재사용하거나 참조하여 include하는 것은 엄격히 금지한다.**
> **v6 전역 함수가 필요한 경우, 반드시 v7 자체 클래스(`V7\Utils\*`)로 새로 구현해야 한다.**
>
> **위반 사례 — 이런 코드가 발견되면 즉시 v7 코드로 교체해야 한다:**
> - `is_dev()` → `V7\Utils\Env::isDev()`
> - `pdo()` → `Philgo\Utils\Db::pdo()`
> - `login()` → `Philgo\Utils\AuthService::getLoginUser()`
> - `in()` → `Philgo\Utils\RequestUtils::all()`
> - `is_admin()` → v7 자체 구현
> - `t()->키` → v7 자체 다국어 시스템
> - `href()->...` → **`url()` 함수** (`V7\Utils\Url` — `url()->post->list->community`, `url()->user->login` 등)

### v7 전용 부팅 시스템 (`v7/boot.php`)

v7 홈페이지는 **v6 `boot.php`를 사용하지 않는** 완전히 독립적인 부팅 파일 `v7/boot.php`를 사용한다.

| 항목 | v6 (기존) | v7 (신규) |
|------|-----------|-----------|
| **부팅 파일** | `boot.php` → `etc/boot.php` → `etc/includes.php` (50개+ 파일) | `v7/boot.php` (PSR-4 오토로더 + 설정 상수만) |
| **프론트 컨트롤러** | `v7.php`에서 `boot.php` include | `v7.php`에서 `v7/boot.php` include |
| **DB 연결** | `pdo()` 전역 함수 | `Philgo\Utils\Db::pdo()` 클래스 |
| **인증** | `login()` 전역 함수 | `Philgo\Utils\AuthService::getLoginUser()` |
| **입력 처리** | `in()` 전역 함수 | `Philgo\Utils\RequestUtils::all()` |
| **다국어** | `t()->키` 전역 함수 | v7 자체 다국어 시스템 |
| **레이아웃** | `page.header.php` / `page.footer.php` | `v7/layouts/` 폴더에서 자체 관리 |
| **UI 라이브러리** | Bootstrap 5 + FontAwesome 7 | **Web Awesome Pro v3.3.1** + **Font Awesome Pro v7.2.0** |
| **JavaScript** | jQuery + Vue.js CDN + `func()` | Vue.js 3 CDN + **`v7api()`** (`/v7/js/v7api.js`) |

### 개발 환경 접속 URL

| 사이트 | URL | 설명 |
|--------|-----|------|
| **v6 홈페이지** | `https://local.philgo.com` | 기존 레거시 v6 홈페이지 |
| **v7 홈페이지** | `https://v7-local.philgo.com` | 신규 v7 홈페이지 |

> Chrome DevTools MCP 테스트 시 v7 페이지는 반드시 `https://v7-local.philgo.com` URL을 사용한다.
> 예: v7 홈페이지 테스트 → `https://v7-local.philgo.com/`

### v6 URL Backward Compatibility (v6 URL 하위 호환)

v7 홈페이지는 v6 URL 패턴(`.php` 확장자 포함)을 **100% 지원**한다.
Google 검색엔진, 외부 링크, 북마크 등에서 v6 URL로 접속해도 v7 페이지가 정상적으로 표시된다.

**지원하는 v6 URL 패턴:**

| v6 URL 패턴 | v7 내부 라우팅 | 예시 |
|-------------|---------------|------|
| `/post/list.php?...` | `v7/post/list.php` | `/post/list.php?post_id=qna&category=여권/비자` |
| `/post/view.php?...` | `v7/post/view.php` | `/post/view.php?idx=797646&post_id=buyandsell&page=15674` |

**구현 구조:**

1. **Nginx Rewrite** (`docker/etc/nginx/nginx.conf`): `location ~ ^/post/(list|view)\.php$` 규칙으로 v7.php 프론트 컨트롤러로 전달
2. **Route.php `.php` 확장자 제거** (`v7/utils/Route.php`): `parseRequest()`에서 `.php` 확장자를 자동 제거하여 기존 라우팅 로직으로 처리
3. **v6와 동일한 파라미터 이름**: `idx`, `post_id`, `category`, `page` (v6과 100% 동일)

> 상세 내용은 → [web/v7-overview.md](references/web/v7-overview.md) 6장 「v6 URL Backward Compatibility」 참조.

### v7 웹 홈페이지에서 사용 금지 목록

| 분류 | 사용 금지 (v6) | 대체 사용 (v7) |
|------|---------------|---------------|
| **부팅** | `include boot.php` | `include v7/boot.php` |
| **레이아웃** | `page.header.php`, `page.footer.php` | `v7/layouts/` 자체 레이아웃 |
| **위젯** | `widget/*.php`, `include widget()` | v7 자체 컴포넌트/뷰 |
| **DB** | `pdo()`, `db_select_row()`, `db_insert()` | `Db::pdo()`, `Db::prepare()` |
| **인증** | `login()`, `is_admin()` | `AuthService::getLoginUser()` |
| **입력** | `in()` | `RequestUtils::all()`, `RequestUtils::get()` |
| **다국어** | `t()->키`, `tr()` | v7 자체 다국어 시스템 |
| **API 호출** | `func('함수명', {...})` | **`v7api('module.action', { ... })`** (`/v7/js/v7api.js` — fetch 직접 호출 절대 금지) |
| **CSS** | Bootstrap utility class | **Web Awesome Pro v3.3.1** CSS 변수 + 유틸리티 (`wa-stack`, `wa-cluster`, `wa-grid` 등) |
| **JavaScript** | `ready()`, `firebase_ready()`, jQuery | `DOMContentLoaded`, Vue.js 3, **`v7api()`** (fetch 직접 사용 금지) |
| **이미지 처리** | `attr_onerror_xbox()` | v7 자체 이미지 에러 처리 |
| **URL 생성** | `href()->post->view(...)` | **`url()->post->view(...)`, `url()->post->list->community` 등** (`V7\Utils\Url`) |

### 왜 v6 코드를 사용하면 안 되는가

1. **성능**: v6 `boot.php`는 50개 이상의 파일을 include하여 무겁다. v7은 PSR-4 오토로더로 필요한 클래스만 로드한다.
2. **독립성**: v7 홈페이지는 v6과 완전히 독립적으로 운영되어야 한다. v6에 대한 의존성이 있으면 향후 v6 변경 시 v7도 영향을 받는다.
3. **일관성**: v7 API(`api.php`)도 `boot.php`를 사용하지 않는다. v7 웹 홈페이지도 동일한 원칙을 따른다.
4. **UI 통일성**: v7은 Web Awesome Pro를 사용하며, Bootstrap 기반 v6 위젯/레이아웃을 혼용하면 UI가 혼재된다.
5. **미래 지향적**: v7 시스템이 완성되면 v6 코드는 점진적으로 제거될 예정이다. v6에 의존하면 마이그레이션이 어려워진다.

### v7 웹 페이지 작성 예시 (올바른 방법)

```php
<?php
/**
 * v7/post/list.php - v7 게시판 목록 페이지
 *
 * v7/boot.php가 이미 로드된 상태 (v7.php 프론트 컨트롤러에서 include).
 * v6 boot.php, page.header.php 등은 사용하지 않는다.
 *
 * 접속 URL: https://v7-local.philgo.com/post/list
 */
use Philgo\Post\PostService;
use Philgo\Utils\AuthService;

// v7 Service로 데이터 조회 (SSR)
$posts = PostService::list(['post_id' => 'freetalk', 'limit' => 20]);
$user = AuthService::getLoginUser();
?>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>자유게시판 - 필고 v7</title>
    <!-- Web Awesome Pro v3.3.1 (유료) -->
    <link rel="stylesheet" href="/v7/dist-cdn/styles/webawesome.css">
    <script type="module" src="/v7/dist-cdn/webawesome.loader.js" data-webawesome="/v7/dist-cdn"></script>
    <!-- Font Awesome Pro v7.2.0 (유료) -->
    <link rel="stylesheet" href="/v7/etc/font-awesome/css/all.min.css">
    <!-- Vue.js 3 CDN -->
    <script defer src="https://unpkg.com/vue@3/dist/vue.global.prod.js"></script>
</head>
<body>
    <!-- v7 자체 레이아웃 (page.header.php 사용 금지) -->
    <div class="wa-stack" style="--wa-stack-gap: var(--wa-space-xl); max-width: 1200px; margin: 0 auto;">
        <!-- SSR: PHP에서 렌더링 -->
        <?php foreach ($posts as $post): ?>
            <wa-card>
                <div slot="header"><?= htmlspecialchars($post['subject'] ?? '') ?></div>
                <p><?= htmlspecialchars($post['content'] ?? '') ?></p>
            </wa-card>
        <?php endforeach; ?>
    </div>
</body>
</html>
```

### 잘못된 예시 (절대 금지)

```php
<?php
// ❌ 절대 금지: v6 boot.php include
include_once '../boot.php';

// ❌ 절대 금지: v6 레이아웃 사용
include_once '../page.header.php';

// ❌ 절대 금지: v6 전역 함수 사용
$user = login();
$posts = db_select_all("SELECT * FROM sf_post_data");

// ❌ 절대 금지: v6 위젯 include
include widget('post/list/default');

// ❌ 절대 금지: v6 다국어 함수 사용
echo t()->게시판목록;

include_once '../page.footer.php';
```

---

## Git Subtree 관리

이 프로젝트는 Git Subtree를 사용하여 외부 패키지와 스킬을 관리한다.
사용자가 "서브트리 업데이트", "subtree 업데이트", "subtree pull/push" 등을 요청하면 아래 절차를 수행한다.

### Subtree 목록

| 리모트 이름 | 경로 (prefix) | 브랜치 |
|-------------|---------------|--------|
| `easy_phone_sign_in` | `packages/easy_phone_sign_in` | `main` |
| `file_cache_flutter` | `packages/file_cache_flutter` | `main` |
| `font_awesome_flutter` | `packages/font_awesome_flutter` | `main` |
| `philgo_api` | `packages/philgo_api` | `main` |
| `flutter-skill` | `.claude/skills/flutter-skill` | `main` |
| `v7-skill` | `.claude/skills/v7-skill` | `main` |

### Subtree Pull (원격 → 로컬)

각 subtree에 대해 `--squash` 옵션으로 pull한다:

```bash
git subtree pull --prefix=packages/easy_phone_sign_in easy_phone_sign_in main --squash
git subtree pull --prefix=packages/file_cache_flutter file_cache_flutter main --squash
git subtree pull --prefix=packages/font_awesome_flutter font_awesome_flutter main --squash
git subtree pull --prefix=packages/philgo_api philgo_api main --squash
git subtree pull --prefix=.claude/skills/flutter-skill flutter-skill main --squash
git subtree pull --prefix=.claude/skills/v7-skill v7-skill main --squash
```

### Subtree Push (로컬 → 원격)

각 subtree에 대해 push한다:

```bash
git subtree push --prefix=packages/easy_phone_sign_in easy_phone_sign_in main
git subtree push --prefix=packages/file_cache_flutter file_cache_flutter main
git subtree push --prefix=packages/font_awesome_flutter font_awesome_flutter main
git subtree push --prefix=packages/philgo_api philgo_api main
git subtree push --prefix=.claude/skills/flutter-skill flutter-skill main
git subtree push --prefix=.claude/skills/v7-skill v7-skill main
```

### 작업 순서

1. **커밋**: 현재 작업 중인 변경사항이 있으면 먼저 커밋한다
2. **Pull**: 모든 subtree에 대해 pull을 수행한다 (충돌 발생 시 해결 후 진행)
3. **Push**: 모든 subtree에 대해 push를 수행한다
4. **메인 저장소 push**: 필요 시 `git push origin v7`으로 메인 저장소도 push한다

> **참고:** subtree push는 전체 커밋 히스토리를 순회하므로 시간이 걸릴 수 있다.
