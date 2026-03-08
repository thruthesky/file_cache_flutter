# 필고 v7 시스템 레퍼런스

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처 설계 원칙](#2-아키텍처-설계-원칙)
- [3. 폴더 및 파일 구조](#3-폴더-및-파일-구조)
- [4. 부트 프로세스](#4-부트-프로세스)
- [5. API 시스템](#5-api-시스템)
- [6. Entity (데이터 구조체)](#6-entity-데이터-구조체)
- [7. 함수 작성 규칙](#7-함수-작성-규칙)
- [8. 입출력 처리](#8-입출력-처리)
- [9. 에러 처리](#9-에러-처리)
- [10. 데이터베이스 처리](#10-데이터베이스-처리)
- [11. 테스트 시스템](#11-테스트-시스템)
- [12. 마이그레이션 전략](#12-마이그레이션-전략)
- [13. Vue.js CDN MPA 방식](#13-vuejs-cdn-mpa-방식)
- [14. Utils 클래스 (유틸리티)](#14-utils-클래스-유틸리티)
- [15. PSR-4 Autoloading](#15-psr-4-autoloading)
- [16. 문서 분할 규칙](#16-문서-분할-규칙)
- [17. 기존 코드와의 통합 사용](#17-기존-코드와의-통합-사용)

---

## 1. 개요

### 1.1 배경

필고 프로젝트(v6)의 기존 코드는 복잡하고 유지보수가 어렵다. v7 시스템은 기존 버전과의 **100% 호환성을 유지**하면서 코드 구조를 체계화하여 가독성, 유지보수성, 확장성을 높이는 것을 목표로 한다.

### 1.2 핵심 목표

| 목표 | 설명 |
|------|------|
| API 중심 설계 | 웹(PHP)과 모바일(Flutter) 앱에서 동일한 API를 사용 |
| Vue.js CDN MPA | SEO 불필요 페이지는 Vue.js CDN 방식으로 전환 |
| 모듈화 | `lib/` 하위에 기능별 폴더로 코드 분리 |
| 테스트 커버리지 | PEST 프레임워크로 100% 유닛 테스트 작성 |
| 점진적 마이그레이션 | 기존 기능을 깨뜨리지 않으면서 단계적 전환 |

### 1.3 기술 스택

```
백엔드: PHP 8.x + MariaDB + Nginx (Docker 컨테이너)
프론트엔드: Vue.js 3 (CDN, Options API) + Bootstrap 5.3 + FontAwesome 7
API 통신: Axios (func() 래퍼 함수)
인증: Firebase Authentication
테스트: PEST v4 + PHPUnit + Playwright (Browser Test)
의존성: Composer (kreait/firebase-php, libphonenumber, openai-php, guzzle)
```

---

## 2. 아키텍처 설계 원칙

### 2.1 Controller + Entity 아키텍처

v7 시스템은 **Controller 클래스 + Entity(POPO)** 아키텍처를 채택한다. 각 기능 모듈(`lib/<module>/`)에 Controller 클래스를 두고, API 요청은 Controller 인스턴스의 멤버 함수로 디스패치한다. 데이터 구조는 Entity 클래스(POPO)로 정의한다.

```
┌─────────────────────────────────────────────────────┐
│  JavaScript Client  (func() 함수로 API 호출)         │
│  - js/app.js 의 func() → Axios POST /api.php       │
│  - method 파라미터: "post.create" (모듈.메서드)       │
└──────────────┬──────────────────────────────────────┘
               │ HTTP POST (JSON)
               │ Body: {method: "post.create", ...}
               ▼
┌─────────────────────────────────────────────────────┐
│  api.php (API Gateway) — PSR-4 Autoloading           │
│  - vendor/autoload.php 로드 (boot.php 미포함)        │
│  - method 파라미터 파싱: "user.count"                │
│    → module = "user", action = "count"              │
│  - PSR-4로 Controller 자동 로드                      │
│    → Philgo\User\UserController                     │
│    → $ctrl = new UserController()                   │
│  - 멤버 함수 호출                                    │
│    → $ctrl->count($input)                           │
└──────────────┬──────────────────────────────────────┘
               │ Controller 멤버 함수 호출
               ▼
┌─────────────────────────────────────────────────────┐
│  Controller (Philgo\<Module>\<Module>Controller)     │
│  - namespace Philgo\<Module>                        │
│  - Service 호출 (비즈니스 로직)                      │
│  - Db를 통한 DB 쿼리                           │
│  - PDO prepared statement로 DB 쿼리                  │
└──────────────┬──────────────────────────────────────┘
               │ PDO prepared statement
               ▼
┌─────────────────────────────────────────────────────┐
│  MariaDB (pdo()->prepare() + execute())             │
└─────────────────────────────────────────────────────┘
```

### 2.2 설계 원칙

1. **Controller 기반 API**: 모든 API 요청은 `api.php`에서 Controller 클래스를 인스턴스화하고 멤버 함수를 호출
2. **method 파라미터**: `/api.php?method=<module>.<action>` 형식 (예: `post.create`, `user.login`)
3. **Controller 클래스**: `lib/<module>/<Module>Controller.php`에 `Philgo\<Module>\<Module>Controller` 클래스 정의 (PSR-4)
4. **Entity (POPO)**: `lib/entities/` 에 데이터 구조를 정의하는 Entity 클래스 (PostEntity, UserEntity 등)
5. **통일된 입출력**: 모든 Controller 멤버 함수는 `array $input` 입력, 배열/Entity 출력 (Controller는 반드시 객체를 리턴)
6. **PDO 필수**: 모든 DB 쿼리는 `pdo()->prepare()` + `execute()` 방식 사용
7. **⚠️ 기존 함수 사용 금지**: v7 시스템에서는 가능한 기존 함수(`*.functions.php`)를 사용하지 않는다. 필요한 유틸리티는 `lib/utils/<Module>Utils.php` 클래스로 작성하여 PSR-4 autoloading으로 로드한다.
8. **Utils 클래스**: 공통 유틸리티는 `lib/utils/` 폴더에 `<Module>Utils.php` 형식으로 작성 (예: `RequestUtils.php`, `Db.php`). 네임스페이스: `Philgo\Utils\`
9. **boot.php 미포함**: `api.php`는 기존 `boot.php`를 로드하지 않는다. RequestUtils 등 Utils 클래스를 통해 독립적으로 동작한다.
10. **에러 처리**: try/catch로 예외를 캐치하여 `{success: false, message: "에러 메시지"}` 형식으로 응답. 성공 시 `{success: true}` 추가 없이 Controller 리턴값 그대로 출력.
11. **⚠️ API 테스트 필수**: 모든 API endpoint는 반드시 **PEST Unit Test**로 테스트한다.
12. **레거시 AllowedFunctions**: 기존 `AllowedFunctions` 클래스는 레거시로 유지하되, 새 코드는 Controller 방식 사용

---

## 3. 폴더 및 파일 구조

### 3.1 전체 프로젝트 구조

```
www/                          # 프로젝트 루트 (ROOT_DIR)
├── boot.php                  # 부트 엔트리포인트
├── api.php                   # ★ API 엔트리포인트 (JavaScript func() 호출 대상, 필수 파라미터: func)
├── func.php                  # (레거시) 기존 API 엔트리포인트 → api.php로 전환
│
├── lib/                      # ★ 핵심 소스코드 (모든 비즈니스 로직)
│   ├── api/                  #   API 게이트웨이
│   │   └── api.allowed_functions.php  # AllowedFunctions 클래스
│   ├── post/                 #   게시글 CRUD, 댓글, 설정
│   ├── user/                 #   사용자 관리, 인증, 차단
│   ├── chat/                 #   채팅 기능
│   ├── entities/             #   Entity 클래스 (데이터 구조체)
│   ├── utils/                #   ★ Utils 클래스 (PSR-4, 기존 함수 대체)
│   │   ├── RequestUtils.php   # ★  Philgo\Utils\RequestUtils (클라이언트 입력 처리)
│   │   ├── Db.php        # ★  Philgo\Utils\Db (PDO DB 연결)
│   │   └── ...               #     기타 유틸리티 클래스
│   ├── types/                #   타입/필드 정의
│   ├── firebase/             #   Firebase 연동 (인증, FCM)
│   ├── advertisement/        #   광고/배너 시스템
│   ├── family-site/          #   패밀리사이트 (2차 도메인)
│   ├── moderate/             #   콘텐츠 검열 (Gemini AI)
│   ├── spam/                 #   스팸 필터링
│   ├── functions/            #   기타 유틸리티
│   └── *.functions.php       #   루트 레벨 공통 함수 파일들
│
├── etc/                      # 설정 파일
│   ├── boot.php              #   부트 설정
│   ├── includes.php          #   전체 라이브러리 include
│   ├── db.php                #   DB 연결 설정
│   ├── app.config.php        #   앱 설정
│   ├── translations/         #   번역 파일
│   └── database-schema/      #   DB 스키마 파일
│
├── tests/                    # 테스트 코드
│   ├── Unit/                 #   PEST 유닛 테스트
│   ├── Browser/              #   PEST 브라우저(E2E) 테스트
│   ├── Feature/              #   PEST 기능 테스트
│   ├── api/                  #   API 커스텀 테스트
│   ├── Pest.php              #   PEST 설정 & 헬퍼
│   └── bootstrap.php         #   PHPUnit 부트스트랩
│
├── js/                       # JavaScript 파일
│   └── app.js                #   func() API 호출 함수 포함
│
├── page/                     # 웹 페이지 (MPA)
├── post/                     # 게시판 페이지
├── user/                     # 회원 페이지
├── company/                  # 업소록 페이지
├── chat/                     # 채팅 페이지
├── family_site/              # 패밀리사이트 페이지
├── widget/                   # 재사용 위젯 (PHP include)
│
├── composer.json             # PHP 의존성
├── phpunit.xml               # 테스트 설정
└── vendor/                   # Composer 패키지
```

### 3.2 기능별 폴더 규칙

각 기능 폴더(`lib/<module>/`)에 **Controller 클래스**와 기능별 함수 파일을 모아서 관리한다.

```
lib/<module>/
├── <Module>Controller.php       # ★ Controller 클래스 (PSR-4, 네임스페이스)
├── <module>.functions.php       # 핵심 함수 (기존 레거시, Controller에서 호출 가능)
├── <module>.fields.php          # 필드/타입 정의 (선택)
├── process_before_save.php      # 저장 전처리 (선택)
├── process_after_read.php       # 읽기 후처리 (선택)
└── ...                          # 기타 부가 파일
```

**예시: `lib/post/` 폴더**

```
lib/post/
├── PostController.php           # ★ Philgo\Post\PostController
│                                #   create(), update(), delete()
│                                #   get(), list(), latest(), view()
├── post.functions.php           # 기존 게시글 함수 (레거시, Controller에서 호출 가능)
├── post.fields.php              # 게시판 타입별 필드 정의
├── CommentController.php        # Philgo\Post\CommentController
├── process_before_save.php      # 저장 전처리 (파일 첨부, 콘텐츠 정리)
├── process_after_read.php       # 읽기 후처리 (URL 추출, 시간 포맷)
└── ReportController.php         # Philgo\Post\ReportController
```

**예시: `lib/user/` 폴더**

```
lib/user/
├── UserController.php           # ★ Philgo\User\UserController
├── user.functions.php           # 기존 사용자 함수 (레거시)
└── MemberBlockController.php    # Philgo\MemberBlock\MemberBlockController
```

**예시: `lib/upload/` 폴더**

```
lib/upload/
├── UploadController.php         # ★ Philgo\Upload\UploadController
└── upload.functions.php         # 기존 업로드 함수 (레거시)
```

### 3.3 파일 명명 규칙

| 패턴 | 역할 | 예시 |
|------|------|------|
| `*Controller.php` | ★ Controller 클래스 (PSR-4, API 엔드포인트) | `PostController.php`, `UserController.php` |
| `*Service.php` | ★ Service 클래스 (PSR-4, 비즈니스 로직) | `UserService.php` |
| `*Utils.php` | ★ Utils 클래스 (PSR-4, 유틸리티) | `RequestUtils.php`, `Db.php` |
| `*.functions.php` | ⚠️ 기존 함수 (레거시, 새 코드에서 사용 금지) | `post.functions.php` |
| `*.fields.php` | 필드/타입 정의 | `post.fields.php` |
| `process_*.php` | 데이터 전/후처리 | `process_before_save.php` |

### 3.4 Controller 클래스 명명 규칙

| 파일 | 클래스명 | API method 접두사 |
|------|----------|------------------|
| `PostController.php` | `Philgo\Post\PostController` | `post.*` |
| `CommentController.php` | `Philgo\Post\CommentController` | `comment.*` |
| `UserController.php` | `Philgo\User\UserController` | `user.*` |
| `UploadController.php` | `Philgo\Upload\UploadController` | `upload.*` |
| `MemberBlockController.php` | `Philgo\MemberBlock\MemberBlockController` | `member_block.*` |

---

## 4. 부트 프로세스

### 4.1 부트 순서

```
api.php (또는 page/*.php)
  │
  ├─ define ROOT_DIR, API_CALL
  │
  └─ require boot.php
       │
       ├─ 타임존 설정 (Asia/Seoul)
       ├─ 시작 시간 기록
       ├─ ROOT_DIR, DEBUG 상수 정의
       │
       └─ require etc/boot.php
            │
            └─ require etc/includes.php
                 │
                 ├─ lib/boot.functions.php     (에러 핸들러, is_cli, is_localhost 등)
                 ├─ etc/preflight.php           (CORS 설정)
                 ├─ etc/error.handler.php       (로컬호스트 에러 핸들러)
                 │
                 ├─ [설정 파일들]
                 │   ├─ etc/app.version.php
                 │   ├─ etc/app.config.php
                 │   ├─ lib/constants.php
                 │   └─ etc/translations/texts.php, t.php
                 │
                 ├─ [타입 & Entity]
                 │   ├─ lib/types/*.php
                 │   └─ lib/entities/*.entity.php (10개 Entity 클래스)
                 │
                 ├─ [핵심 함수 라이브러리]    (~50개 파일)
                 │   ├─ lib/functions.php         (success, response, error 등)
                 │   ├─ lib/input.functions.php   (in() 함수)
                 │   ├─ lib/auth.functions.php    (인증)
                 │   ├─ lib/post/*.php            (게시글 전체)
                 │   ├─ lib/user/*.php            (사용자 전체)
                 │   ├─ lib/chat/*.php            (채팅)
                 │   └─ ... (기타 모듈별 함수)
                 │
                 ├─ vendor/autoload.php           (Composer 의존성)
                 ├─ etc/firebase.config.php       (Firebase 설정)
                 │
                 └─ etc/db.php                    (DB 연결 - PDO)
```

### 4.2 핵심 부트 코드

**`api.php` (API 엔트리포인트)** — 필수 파라미터: `method` (형식: `<module>.<action>`):

> ⚠️ **중요**: `api.php`는 기존 `boot.php`를 포함하지 않는다. Composer PSR-4 autoloader를 통해 클래스를 자동 로드하고, 기존 함수에 의존하지 않는다.

```php
<?php
const ROOT_DIR = __DIR__;
// ⚠️ boot.php를 포함하지 않음! Composer PSR-4 autoloader 사용
require_once ROOT_DIR . '/vendor/autoload.php';
use Philgo\Utils\RequestUtils;
// Controller는 PSR-4 autoloader를 통해 자동 로드
// 예: method=user.count → Philgo\User\UserController::count()
```

**`boot.php`** (레거시 - api.php에서 사용하지 않음):

```php
<?php
date_default_timezone_set('Asia/Seoul');
$_START_TIME = microtime(true);
if (!defined('ROOT_DIR')) { define('ROOT_DIR', __DIR__); }
if (!defined('DEBUG')) { define('DEBUG', true); }
require_once __DIR__ . '/etc/boot.php';
```

**`API_CALL` 상수의 역할** (레거시): `API_CALL`이 정의되면 기존 `error()` 함수가 예외를 throw하지 않고 JSON 에러 응답을 출력 후 `exit`한다. v7 시스템의 `api.php`에서는 이 상수를 사용하지 않으며, try/catch로 직접 예외를 처리한다.

> **참고**: 기존 시스템에서는 `func.php`를 API 엔트리포인트로 사용했으나, v7 시스템에서는 `api.php`를 사용한다. `api.php`의 필수 파라미터는 `method`이며, `<module>.<action>` 형식으로 호출할 Controller와 멤버 함수를 지정한다. (예: `method=post.create` → `PostController->create()`)
>
> ⚠️ **v7 시스템 원칙**: `api.php`는 `boot.php`를 포함하지 않으며, 기존 함수(`in()`, `http_param()`, `error()` 등)에 의존하지 않는다. 대신 `RequestUtils`, `Db` 등의 Utils 클래스를 사용한다.

---

## 5. API 시스템

### 5.1 전체 요청 흐름 (Controller 방식)

```
[JavaScript]                     [PHP]
func('post.get', {idx: 123})
    │
    ▼ Axios POST /api.php
    │ Body: {method: "post.get", idx: 123}
    │
    │                            api.php
    │                              │
    │                              ├─ RequestUtils::parseMethod()  // "post.get"
    │                              ├─ [$module, $action] = ["post", "get"]
    │                              │
    │                              ├─ PSR-4 Controller FQCN 생성
    │                              │   → "Philgo\Post\PostController"
    │                              │
    │                              ├─ Controller 인스턴스 생성 (autoload)
    │                              │   → $ctrl = new Philgo\Post\PostController()
    │                              │
    │                              ├─ 멤버 함수 호출
    │                              │   → $res = $ctrl->get($input)
    │                              │   → return PostEntity 객체
    │                              │
    │                              ├─ 응답 변환
    │                              │   ├─ 객체 → toArray() 호출
    │                              │   ├─ 배열 → 그대로 유지
    │                              │   └─ 스칼라 → ['data' => 값]
    │                              │
    │                              └─ echo json_encode($res)
    │
    ▼ HTTP 200 (JSON)
res = {idx: 123, subject: "제목", content: "내용", ...}
```

### 5.2 api.php 디스패치 로직

**필수 파라미터**: `method` (형식: `<module>.<action>`)

> ⚠️ **핵심 원칙**:
> - `boot.php`를 포함하지 않는다 — `RequestUtils` 클래스를 통해 입력을 처리한다.
> - 기존 함수(`in()`, `http_param()`, `error()` 등)를 사용하지 않는다.
> - 에러 시 `{success: false, message: "에러 메시지"}` 형식으로 응답한다.
> - 성공 시 `{success: true}` 추가 없이 Controller 리턴값 그대로 JSON 출력한다.
> - Controller는 반드시 배열 또는 Entity 객체를 리턴해야 한다.
> - Service/Repository에서 에러가 나면 반드시 throw한다 → api.php에서 try/catch로 캐치한다.

```php
<?php
/**
 * @file api.php
 * @brief v7 시스템 API 엔트리포인트 - Controller 기반 디스패치 (PSR-4)
 *
 * method 파라미터를 파싱하여 Controller 클래스를 인스턴스화하고 멤버 함수를 호출한다.
 * 예: method=user.count → Philgo\User\UserController::count($input)
 *
 * ⚠️ boot.php를 포함하지 않음! Composer PSR-4 autoloader로 클래스 자동 로드.
 */
const ROOT_DIR = __DIR__;

// Composer PSR-4 Autoloader (boot.php 대신)
require_once ROOT_DIR . '/vendor/autoload.php';

use Philgo\Utils\RequestUtils;

header('Content-Type: application/json; charset=utf-8');

// method 파라미터 파싱
try {
    [$module, $action] = RequestUtils::parseMethod();
} catch (RuntimeException $e) {
    echo json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    exit;
}

// Controller FQCN 생성 (PSR-4 네임스페이스 기반)
// "user" → "Philgo\User\UserController"
// "member_block" → "Philgo\MemberBlock\MemberBlockController"
$pascalModule = str_replace(' ', '', ucwords(str_replace(['_', '-'], ' ', $module)));
$className = "Philgo\\{$pascalModule}\\{$pascalModule}Controller";

if (!class_exists($className)) {
    echo json_encode(['success' => false, 'message' => "Controller 클래스를 찾을 수 없습니다: {$className}"], JSON_UNESCAPED_UNICODE);
    exit;
}
$ctrl = new $className();

// 멤버 함수 존재 확인
if (!method_exists($ctrl, $action)) {
    echo json_encode(['success' => false, 'message' => "메서드를 찾을 수 없습니다: {$className}::{$action}()"], JSON_UNESCAPED_UNICODE);
    exit;
}

// Controller 멤버 함수 호출 (try/catch)
$input = RequestUtils::all();
try {
    $res = $ctrl->$action($input);
} catch (Exception $e) {
    // Service/Repository에서 throw한 예외를 캐치하여 에러 응답 리턴
    echo json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
    exit;
}

// 응답 변환 및 JSON 출력 (성공 시 success: true 추가 없음)
if (is_object($res)) {
    $res = method_exists($res, 'toArray') ? $res->toArray() : get_object_vars($res);
} else if (is_array($res)) {
    // 배열은 그대로
} else {
    $res = ['data' => $res];
}
echo json_encode($res, JSON_UNESCAPED_UNICODE);
```

### 5.3 JavaScript func() 함수

**파일**: `js/app.js`

```javascript
async function func(method, params = {}) {
    params.method = method;  // 필수 파라미터: method (모듈.액션)
    const alertOnError = params.alertOnError !== undefined ? params.alertOnError : true;
    const debug = params.debug || false;
    delete params.alertOnError;
    delete params.debug;

    try {
        const res = await axios.post('/api.php', params);  // 엔드포인트: /api.php
        // 208: "Already Done" (중복 동작 - soft_error)
        if (res.status == 208) {
            throw new Error('208: ' + res.data.message);
        }
        return res.data;
    } catch (error) {
        // 에러 처리 (alertOnError가 true면 alert 표시)
    }
}
```

**호출 예시**:

```javascript
// 글 조회 — method: "post.get"
const post = await func('post.get', { idx: 12345 });
console.log(post.subject);  // "제목"

// 글 생성 — method: "post.create"
const newPost = await func('post.create', {
    post_id: 'freetalk',
    subject: '제목',
    content: '내용'
});

// 사용자 프로필 조회 — method: "user.getMyData"
const me = await func('user.getMyData');

// Boolean 반환 함수 → res.data로 접근 — method: "family_site.exists"
const res = await func('family_site.exists', { domain: 'banana' });
console.log(res.data);  // true 또는 false

// 에러 알림 끄기
await func('post.like', { idx: 123, alertOnError: false });
```

### 5.4 Controller 클래스 작성 규칙

**파일 위치**: `lib/<module>/<Module>Controller.php` (PascalCase 파일명, PSR-4)

> **주석 규칙**: 모든 Controller 멤버 함수의 PHPDoc에 **GET REST 호출 URL 예시**를 반드시 포함한다.
> 형식: `GET 호출 예시:\n  https://local.philgo.com/api.php?method=<module>.<action>&파라미터=값`

```php
<?php
/**
 * @file lib/post/PostController.php
 * @brief 게시글 Controller - API 엔드포인트
 *
 * API method 접두사: "post.*"
 * 예: post.create, post.get, post.update, post.delete, post.list
 *
 * PSR-4 Autoloading: Philgo\Post\PostController
 */

namespace Philgo\Post;

use Philgo\Utils\Db;

class PostController
{
    /**
     * 게시글 생성
     * API: method=post.create
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.create&post_id=freetalk&subject=제목&content=내용
     *
     * @param array $input ['post_id' => string, 'subject' => string, 'content' => string, ...]
     * @return PostEntity 생성된 게시글
     */
    public function create(array $input): PostEntity {
        $post_id = $input['post_id'] ?? '';
        $subject = $input['subject'] ?? '';
        $content = $input['content'] ?? '';
        // 비즈니스 로직 처리
        // ...
        return new PostEntity($result);
    }

    /**
     * 게시글 조회
     * API: method=post.get
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.get&idx=12345
     */
    public function get(array $input): PostEntity {
        $idx = $input['idx'] ?? 0;
        if (empty($idx)) throw new RuntimeException('idx 파라미터가 필요합니다.');
        // ⚠️ 기존 함수 사용 금지! Db를 통해 DB 쿼리
        $stmt = Db::pdo()->prepare("SELECT * FROM posts WHERE idx = :idx");
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) throw new RuntimeException('글을 찾을 수 없습니다.');
        return new PostEntity($row);
    }

    /**
     * 게시글 수정
     * API: method=post.update
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.update&idx=12345&subject=수정된제목
     */
    public function update(array $input): PostEntity { ... }

    /**
     * 게시글 삭제
     * API: method=post.delete
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.delete&idx=12345
     */
    public function delete(array $input): array { ... }

    /**
     * 게시글 목록
     * API: method=post.list
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.list&post_id=freetalk&limit=20
     */
    public function list(array $input): array { ... }

    /**
     * 최신 게시글 조회
     * API: method=post.latest
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.latest&post_id=qna&limit=5
     */
    public function latest(array $input): array { ... }

    /**
     * 조회수 증가
     * API: method=post.increaseView
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.increaseView&idx=12345
     */
    public function increaseView(array $input): array { ... }

    /**
     * 좋아요
     * API: method=post.like
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.like&idx=12345
     */
    public function like(array $input): array { ... }

    /**
     * 신고
     * API: method=post.report
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.report&idx=12345
     */
    public function report(array $input): array { ... }
}
```

**Controller 클래스 예시 목록**:

| Controller (FQCN) | 파일 | 주요 메서드 |
|-----------|------|-----------|
| `Philgo\Post\PostController` | `lib/post/PostController.php` | `create()`, `get()`, `update()`, `delete()`, `list()`, `latest()`, `like()`, `report()` |
| `Philgo\Post\CommentController` | `lib/post/CommentController.php` | `create()`, `update()`, `delete()` |
| `Philgo\User\UserController` | `lib/user/UserController.php` | `count()`, `getMyData()`, `updateProfile()`, `getPublicProfile()`, `login()` |
| `Philgo\Company\CompanyController` | `lib/company/CompanyController.php` | `get()`, `create()`, `update()` |
| `Philgo\Upload\UploadController` | `lib/upload/UploadController.php` | `upload()`, `delete()` |
| `Philgo\MemberBlock\MemberBlockController` | `lib/user/MemberBlockController.php` | `block()`, `unblock()`, `toggle()` |
| `Philgo\Advertisement\AdvertisementController` | `lib/advertisement/AdvertisementController.php` | `getAllActive()`, `getTopBanners()` |
| `Philgo\FamilySite\FamilySiteController` | `lib/family-site/FamilySiteController.php` | `exists()` |
| `Philgo\App\AppController` | `lib/app/AppController.php` | `getSettings()`, `version()`, `saveFcmToken()` |

### 5.5 새 API 함수 추가 방법

1. `lib/<module>/` 폴더에 `<Module>Controller.php` 생성 (PSR-4, namespace 포함)
2. Controller 클래스에 public 멤버 함수 추가
3. `composer.json`에 `"Philgo\\<Module>\\": "lib/<module>/"` 매핑 추가
4. `composer dump-autoload` 실행
5. 테스트 작성 (`tests/Unit/<Module>ControllerTest.php`)
6. JavaScript에서 `func('<module>.<action>', { ... })` 호출

```
// 호출 흐름 예시: 사용자 수 조회 (PSR-4)
JavaScript: func('user.count')
  → POST /api.php (Body: {method: "user.count"})
    → api.php: method 파싱 → module="user", action="count"
    → PSR-4 autoload → Philgo\User\UserController
    → $ctrl = new Philgo\User\UserController()
    → $res = $ctrl->count($input)
      → UserService::getTotalCount()
      → Db::pdo()->prepare("SELECT COUNT(*)...")
      → return ['count' => 188186]
  → JSON 응답: {"count": 188186}
```

### 5.6 레거시: AllowedFunctions 클래스

> **참고**: `AllowedFunctions` 클래스는 기존 레거시 시스템의 API 게이트웨이이다. 새로운 코드는 Controller 방식으로 작성하고, 기존 `AllowedFunctions`는 점진적으로 Controller로 마이그레이션한다.

**파일**: `lib/api/api.allowed_functions.php`

기존 `func.php`에서 사용하던 방식으로, `AllowedFunctions` 클래스의 public static 메서드를 통해 API 함수를 디스패치한다. v7 시스템에서는 Controller 방식을 사용하므로, 이 클래스는 레거시로 유지된다.

### 5.7 응답 변환 규칙

`api.php`에서 API 함수의 반환값을 JSON으로 변환하는 규칙:

| 반환 타입 | 변환 방법 | JavaScript 접근 |
|-----------|-----------|----------------|
| Entity 객체 (PostEntity 등) | `$res->toArray()` | `res.subject`, `res.idx` |
| stdClass 객체 | `get_object_vars($res)` | `res.property` |
| 배열 | 그대로 유지 | `res.key` |
| 스칼라 (bool, int, string) | `['data' => $res]` | `res.data` |

**핵심 소스코드** (`api.php` 응답 변환 로직):

```php
if (is_object($res)) {
    if (method_exists($res, 'toArray')) {
        $res = $res->toArray();   // Entity 클래스
    } else {
        $res = get_object_vars($res);  // 일반 객체
    }
} else if (is_array($res)) {
    // 배열은 그대로
} else {
    $res = ['data' => $res];  // 스칼라 값은 data 키로 래핑
}
```

---

## 6. Entity (데이터 구조체)

### 6.0 v7 Entity/Repository Interface 시스템 → [v7-interface.md](v7-interface.md)

v7 시스템은 `EntityInterface`와 `RepositoryInterface`를 도입하여 모든 Entity/Repository 클래스의 구조를 강제한다.
`lib/<module>/` 폴더에 위치하는 13개 Entity는 모두 `Philgo\Utils\EntityInterface`를 구현하며,
`fromArray(array $data): static` 정적 팩토리 메서드와 `toArray(): array` 배열 변환 메서드를 필수로 제공한다.
7개 Repository는 `Philgo\Utils\RepositoryInterface`를 구현하여 `create()`, `findByIdx()`, `update()`, `deleteByIdx()` 표준 CRUD 메서드명을 강제한다.
Service는 인터페이스 없이 문서 기반 명명 규칙(`get()`, `list()`, `create()`, `update()`, `delete()`)을 따른다.
전체 Entity 13개 목록, Repository 11개 목록(7개 적용 + 4개 예외), Service 13개 목록, 표준 패턴 코드,
계산 필드 패턴, 런타임 속성 패턴, 데이터 흐름, 새 모듈 추가 워크플로우 등 상세 내용은
[v7-interface.md](v7-interface.md)를 참조한다.

### 6.1 레거시 Entity 클래스 목록

**위치**: `lib/entities/` (레거시, 기존 v6 코드에서 사용)

> ⚠️ 아래는 기존 v6 시스템의 Entity이다. v7 시스템의 Entity는 `lib/<module>/` 폴더에 위치하며
> `EntityInterface`를 구현한다. 상세 목록은 [v7-interface.md](v7-interface.md) 참조.

| Entity | 파일 | 설명 |
|------|------|------|
| `PostEntity` | `post.entity.php` | 게시글 (800+ LOC, 확장 필드 포함) |
| `UserEntity` | `user.entity.php` | 사용자 (356+ LOC) |
| `CompanyEntity` | `company.entity.php` | 업체 (180+ LOC) |
| `CommentEntity` | `comment.entity.php` | 댓글 (PostEntity 상속) |
| `PostListEntity` | `post_list.entity.php` | 글 목록 경량 Entity |
| `PostViewEntity` | `post_view.entity.php` | 글 보기 Entity |
| `PostConfigEntity` | `post_config.entity.php` | 게시판 설정 |
| `BannerEntity` | `banner.entity.php` | 배너 |
| `ActiveAdvertisementEntity` | `active.advertisement.entity.php` | 활성 광고 |
| `ReminderEntity` | `reminder.entity.php` | 알림 |

### 6.2 레거시 Entity 패턴

레거시 Entity는 **POPO (Plain Old PHP Object)** 패턴을 따른다:

```php
class PostEntity {
    public int $idx = 0;
    public int $idx_member = 0;
    public string $post_id = '';
    public string $category = '';
    public string $subject = '';
    public string $content = '';
    public int $stamp = 0;
    public int $good = 0;
    public int $no_of_comment = 0;
    // ... 확장 필드 (int_1~int_10, char_1~char_10, varchar_1~varchar_20, text_1~text_10)

    public function __construct(array $data = []) {
        foreach ($data as $key => $value) {
            if (property_exists($this, $key)) {
                $this->$key = $value;
            }
        }
    }

    public function toArray(): array {
        return get_object_vars($this);
    }

    // 출력 메서드
    public function display_subject(): string { ... }
    public function display_content(): string { ... }
    public function first_image_url(): ?string { ... }
}
```

**사용 규칙**:
- 배열로 받은 게시글은 반드시 `new PostEntity($array)` 로 변환하여 사용
- 제목 출력: `$post->display_subject()` (htmlspecialchars 직접 사용 금지)
- 내용 출력: `$post->display_content()` (strip_tags 직접 사용 금지)
- 첫 이미지: `$post->first_image_url()`

---

## 7. 함수 작성 규칙

### 7.1 입력 파라미터 규칙

**모든 함수**는 `array $input`을 입력 파라미터로 사용한다:

```php
/**
 * 게시글 생성
 *
 * @param array $input ['post_id' => string, 'subject' => string, 'content' => string, ...]
 * @return PostEntity 생성된 게시글
 */
function create_post(array $input): PostEntity {
    $post_id = $input['post_id'] ?? '';
    $subject = $input['subject'] ?? '';
    $content = $input['content'] ?? '';
    // ...
}
```

**이유**: JavaScript에서 `func('create_post', { post_id: 'freetalk', subject: '제목' })` 호출 시, 파라미터가 그대로 PHP 함수의 `$input` 배열로 전달되기 때문이다.

### 7.2 반환값 규칙

```php
// ✅ 배열 반환 (데이터 목록 등)
function get_posts(array $input): array { return [...]; }

// ✅ Entity 반환 (단일 엔티티)
function create_post(array $input): PostEntity { return new PostEntity($data); }

// ✅ 스칼라 반환 (boolean, int, string)
function family_site_exists(array $input): bool { return true; }

// ❌ 금지: boolean을 억지로 배열에 넣기
function family_site_exists(array $input): array { return ['exists' => true]; }  // WRONG!
```

### 7.3 PHP 파일 상단 주석

모든 PHP 파일 상단에 용도와 워크플로우 문서 링크를 작성한다:

```php
<?php
/**
 * @file lib/post/post.functions.php
 * @brief 게시글 핵심 함수 (생성, 수정, 삭제, 조회)
 *
 * @see docs/www/post.md
 */
```

---

## 8. 입출력 처리

### 8.1 입력 수집

**파일**: `lib/input.functions.php`

HTTP 요청의 JSON body + POST/GET 파라미터를 합쳐서 `$__in` 전역 변수에 저장:

```php
$__json = @file_get_contents('php://input');
$__decoded_json = json_decode($__json, true);
$__in = ($__decoded_json !== null) ? array_merge($_REQUEST, $__decoded_json) : $_REQUEST;
```

### 8.2 in() 함수

```php
// 모든 입력 파라미터 조회
$all_params = in();  // array

// 특정 파라미터 조회
$idx = in('idx');       // mixed (값 없으면 null)
$name = in('name');     // 'null', 'undefined', '' 은 null로 변환
```

### 8.3 http_param() / http_params() 함수

```php
// 단일 파라미터 (기본값 지원)
$page = http_param('page', 1);

// 복수 파라미터 일괄 추출
$params = http_params(['name', 'email', 'phone' => '+default']);
// → ['name' => '입력값', 'email' => '입력값', 'phone' => '입력값 또는 +default']
```

---

## 9. 에러 처리

### 9.0 ⚠️ v7 시스템 에러 처리 (api.php)

> **핵심 원칙**: v7 시스템(`api.php`)에서는 기존 `error()` 함수를 사용하지 않는다. 대신 **throw + try/catch** 패턴을 사용한다.

**에러 처리 규칙**:
1. **Service/Repository에서 에러 발생 시**: 반드시 `throw new RuntimeException('에러 메시지')` 한다.
2. **api.php에서 try/catch로 캐치**: `{success: false, message: "에러 메시지"}` 형식으로 응답한다.
3. **성공 시**: `{success: true}` 추가 없이 Controller 리턴값 그대로 JSON 출력한다.

**에러 응답 형식 (v7 시스템)**:
```json
{
    "success": false,
    "message": "에러 메시지 문자열"
}
```

**성공 응답 형식 (v7 시스템)**:
```json
// Controller 리턴값 그대로 (success: true 추가 없음!)
{
    "idx": 123,
    "subject": "제목",
    "content": "내용"
}
```

**Controller 내부 에러 처리 예시**:
```php
class PostController
{
    /**
     * 게시글 조회
     * API: method=post.get
     *
     * GET 호출 예시:
     *   https://local.philgo.com/api.php?method=post.get&idx=12345
     */
    public function get(array $input): PostEntity {
        $idx = $input['idx'] ?? 0;
        // ⚠️ error() 함수 대신 throw 사용
        if (empty($idx)) throw new RuntimeException('idx 파라미터가 필요합니다.');

        $stmt = Db::pdo()->prepare("SELECT * FROM posts WHERE idx = :idx");
        $stmt->execute(['idx' => $idx]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) throw new RuntimeException('글을 찾을 수 없습니다.');

        return new PostEntity($row);
    }
}
```

### 9.1 error() 함수 (레거시)

> ⚠️ **레거시**: v7 시스템(`api.php`)에서는 이 함수를 사용하지 않는다. 기존 `func.php` 및 웹 페이지에서만 사용.

**파일**: `lib/boot.functions.php`

```php
function error(string $error_code, string $error_message = '', int $status_code = 400): void {
    if (defined('API_CALL')) {
        // API 호출: JSON 에러 응답 후 exit
        http_response_code($status_code);
        echo json_encode(['error' => $error_code, 'message' => $error_message]);
        exit;
    } else {
        // 웹 페이지: RuntimeException throw
        throw new RuntimeException("$error_message ($error_code)");
    }
}
```

### 9.2 soft_error() 함수 (레거시)

중복 동작(이미 추천함, 이미 신고함 등)에 사용. HTTP 208 상태코드 반환:

```php
function soft_error(string $error_code, string $error_message = ''): void {
    error($error_code, $error_message, 208);
}
```

### 9.3 에러 응답 형식

```json
{
    "error": "post-not-found",
    "message": "글을 찾을 수 없습니다."
}
```

### 9.4 주요 상태 코드

| 코드 | 의미 | 사용처 |
|------|------|--------|
| 200 | 성공 | 정상 응답 |
| 208 | Already Done | soft_error (중복 동작) |
| 400 | Bad Request | 파라미터 오류 |
| 401 | Unauthorized | 미로그인 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스 없음 |
| 500 | Server Error | 서버 예외 |

---

## 10. 데이터베이스 처리

### 10.0 데이터베이스 스키마 참조

> **필고 전체 DB 스키마(최신 버전)**: [`database/philgo.sql`](../database/philgo.sql)
>
> 이 파일에는 모든 테이블의 `CREATE TABLE` 문, 인덱스(`ALTER TABLE ... ADD KEY`), `AUTO_INCREMENT` 설정이 포함되어 있다.
> v7 시스템에서 새로운 Service/Entity를 작성하거나 쿼리를 작성할 때, **반드시 이 파일을 참조**하여 테이블 구조, 컬럼명, 데이터 타입, 인덱스를 확인해야 한다.

### 10.1 PDO 연결

```php
$pdo = pdo();  // PDO 연결 객체 반환 (싱글톤)
```

### 10.2 쿼리 실행 패턴

**반드시** prepared statement 사용:

```php
// SELECT
$stmt = pdo()->prepare("SELECT * FROM " . POST_TABLE . " WHERE idx = :idx");
$stmt->execute(['idx' => $idx]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

// INSERT
$stmt = pdo()->prepare("INSERT INTO " . POST_TABLE . " (post_id, subject, content) VALUES (:post_id, :subject, :content)");
$stmt->execute([
    'post_id' => $input['post_id'],
    'subject' => $input['subject'],
    'content' => $input['content'],
]);
$new_idx = pdo()->lastInsertId();

// UPDATE
$stmt = pdo()->prepare("UPDATE " . POST_TABLE . " SET subject = :subject WHERE idx = :idx");
$stmt->execute(['subject' => $new_subject, 'idx' => $idx]);

// DELETE
$stmt = pdo()->prepare("DELETE FROM " . POST_TABLE . " WHERE idx = :idx");
$stmt->execute(['idx' => $idx]);
```

### 10.3 Db 헬퍼 메서드 (1줄 패턴)

`Philgo\Utils\Db` 클래스는 반복적인 3줄 패턴(`prepare → execute → fetch`)을 1줄로 줄이는
헬퍼 메서드를 제공한다. **새 코드 작성 시 헬퍼 메서드를 우선 사용**한다.

```php
use Philgo\Utils\Db;

// 단일 행 조회 (기본 PDO::FETCH_ASSOC)
$user = Db::fetch("SELECT * FROM sf_member WHERE idx = ?", [$idx]);
$user = Db::fetch("SELECT * FROM sf_member WHERE firebase_uid = :uid", ['uid' => $uid]);

// 다중 행 조회 (기본 PDO::FETCH_ASSOC)
$rows = Db::fetchAll("SELECT * FROM sf_post_data WHERE post_id = ? LIMIT 10", ['freetalk']);

// 단일 컬럼 값 (COUNT, MAX 등 스칼라 쿼리)
$count = Db::fetchColumn("SELECT COUNT(*) FROM sf_member");
$name = Db::fetchColumn("SELECT name FROM sf_member WHERE idx = ?", [123]);

// INSERT/UPDATE/DELETE (PDOStatement 반환 — rowCount() 접근 가능)
Db::execute("UPDATE sf_member SET name = ? WHERE idx = ?", ['홍길동', 123]);
$stmt = Db::execute("DELETE FROM sf_member WHERE idx = ?", [999]);
$affected = $stmt->rowCount();

// INSERT 후 lastInsertId 정수 반환
$newIdx = Db::insert(
    "INSERT INTO sf_member (id, nickname, stamp) VALUES (?, ?, ?)",
    ['user123', '홍길동', time()]
);
```

#### 메서드 시그니처

| 메서드 | 반환 타입 | 용도 |
|--------|----------|------|
| `Db::fetch(string $sql, array $params = [], int $fetchMode = PDO::FETCH_ASSOC)` | `array\|false` | 단일 행 조회, 결과 없으면 `false` |
| `Db::fetchAll(string $sql, array $params = [], int $fetchMode = PDO::FETCH_ASSOC)` | `array` | 다중 행 조회, 결과 없으면 빈 배열 |
| `Db::fetchColumn(string $sql, array $params = [], int $column = 0)` | `mixed` | 단일 컬럼 값, 결과 없으면 `false` |
| `Db::execute(string $sql, array $params = [])` | `PDOStatement` | INSERT/UPDATE/DELETE 실행 |
| `Db::insert(string $sql, array $params = [])` | `int` | INSERT 후 `lastInsertId` 정수 반환 |

#### 헬퍼로 변환하면 안 되는 패턴

`bindValue()`로 `PDO::PARAM_INT`를 명시해야 하는 LIMIT/OFFSET 쿼리는 기존 `prepare()` 패턴을 유지한다:

```php
// ❌ 헬퍼로 변환 불가 — bindValue 필요
$stmt = Db::prepare($sql);
$stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
$stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
$stmt->execute($params);
$rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
```

### 10.4 금지 패턴

```php
// ❌ 기존 db_ 헬퍼 함수 사용 금지
db_select_col(...);   // WRONG
db_select_row(...);   // WRONG
db_insert(...);       // WRONG

// ❌ 문자열 직접 삽입 금지 (SQL Injection 취약)
$stmt = pdo()->query("SELECT * FROM table WHERE idx = $idx");  // WRONG

// ✅ 반드시 prepared statement 사용
$stmt = pdo()->prepare("SELECT * FROM table WHERE idx = :idx");
$stmt->execute(['idx' => $idx]);
```

### 10.5 주요 테이블 상수

```php
POST_TABLE         // 게시글 테이블
POST_CONFIG_TABLE  // 게시판 설정 테이블
USER_TABLE         // 회원 테이블
```

---

## 11. 테스트 시스템

### 11.0 ⚠️ API 테스트 필수 원칙

> **핵심 원칙**: 모든 API endpoint는 반드시 **PEST Unit Test**로 테스트한다. Controller의 모든 public 메서드는 대응하는 PEST 테스트가 있어야 한다.

**필수 사항**:
1. **새 API endpoint 추가 시**: 반드시 PEST Unit Test를 함께 작성
2. **기존 API 수정 시**: 영향받는 테스트를 업데이트하고, 부족하면 추가 작성
3. **테스트 파일 위치**: `tests/Unit/<Module>ControllerTest.php`
4. **테스트 커버리지 목표**: Controller의 모든 public 메서드에 대해 정상/에러 케이스 모두 테스트

**Controller 테스트 예시 (PSR-4)**:
```php
<?php
// tests/Unit/PostControllerTest.php
use Philgo\Post\PostController;

beforeAll(function () {
    if (!defined('ROOT_DIR')) {
        define('ROOT_DIR', dirname(dirname(__DIR__)));
    }
    require_once ROOT_DIR . '/vendor/autoload.php';
});

describe('PostController', function () {
    it('get() - 정상 조회', function () {
        $ctrl = new PostController();
        $result = $ctrl->get(['idx' => 1]);
        expect($result)->toBeInstanceOf(PostEntity::class);
    });

    it('get() - idx 누락 시 예외 발생', function () {
        $ctrl = new PostController();
        expect(fn() => $ctrl->get([]))->toThrow(RuntimeException::class);
    });
});
```

### 11.1 테스트 프레임워크

- **PEST v4** + PHPUnit (유닛/기능 테스트) — ⚠️ **모든 API endpoint 테스트 필수**
- **PEST Browser Plugin v4.1** + Playwright (브라우저 E2E 테스트)
- **커스텀 PHP 테스트** (legacy, `tests/api/` 폴더)

### 11.2 테스트 실행

```bash
# 전체 테스트
./vendor/bin/pest

# 특정 파일 실행
./vendor/bin/pest tests/Unit/ApiSettingTest.php

# 브라우저 테스트 (headed 모드)
./vendor/bin/pest tests/Browser/PostViewTest.php --headed

# 그룹별 실행
./vendor/bin/pest --group=unit
./vendor/bin/pest --group=browser

# 커스텀 PHP 테스트
php tests/api/increase-post-no-of-view.test.php --db-config=etc/db.config.dev.php
```

### 11.3 PEST 유닛 테스트 패턴

**파일**: `tests/Unit/*.php`

```php
<?php
/**
 * @file tests/Unit/GetLatestPostsTest.php
 * @brief 최신 게시글 조회 API 유닛 테스트
 */

beforeAll(function () {
    bootPhilgo();
    require_once __DIR__ . '/../../lib/api/api.allowed_functions.php';
});

describe('get_latest_posts() API', function () {

    it('배열을 반환한다', function () {
        $result = AllowedFunctions::get_latest_posts(['post_id' => 'qna', 'limit' => 5]);
        expect($result)->toBeArray();
    });

    it('limit 옵션이 적용된다', function () {
        $result = AllowedFunctions::get_latest_posts(['post_id' => 'qna', 'limit' => 3]);
        expect(count($result))->toBeLessThanOrEqual(3);
    });
});
```

### 11.4 PEST 브라우저 테스트 패턴

> **상세 가이드**: → [v7-pest-browser-test.md](v7-pest-browser-test.md) 참조 (60+ assertion, 디바이스 에뮬레이션, 필고 전용 패턴 등)

**파일**: `tests/Browser/*.php`

```php
<?php
test('게시글 보기 페이지 접근 가능', function () {
    $page = $this->visit('https://local.philgo.com/post/view.php?idx=123&post_id=massage');
    $page->assertPresent('.post-view-page');
})->group('browser', 'post', 'view');
```

### 11.5 커스텀 PHP 테스트 패턴

**파일**: `tests/api/*.test.php`

```php
<?php
require_once __DIR__ . '/../../boot.php';
require_once __DIR__ . '/../../lib/api/api.allowed_functions.php';

$test_count = 0; $pass_count = 0; $fail_count = 0;

function run_test(string $name, callable $test_fn): void {
    global $test_count, $pass_count, $fail_count;
    $test_count++;
    try {
        $result = $test_fn();
        if ($result === true) { $pass_count++; echo "✅ $name\n"; }
        else { $fail_count++; echo "❌ $name\n"; }
    } catch (Exception $e) {
        $fail_count++; echo "❌ $name - " . $e->getMessage() . "\n";
    }
}

run_test("idx 누락 시 에러", function () {
    try { AllowedFunctions::increase_post_no_of_view([]); return false; }
    catch (Exception $e) { return strpos($e->getMessage(), 'idx') !== false; }
});

echo "\n📊 결과: 총 $test_count, ✅ $pass_count, ❌ $fail_count\n";
```

### 11.6 테스트 헬퍼 함수

**파일**: `tests/Pest.php`

```php
// 필고 부트스트랩 로드 (1회만 실행)
function bootPhilgo(): void {
    static $booted = false;
    if (!$booted) {
        if (!defined('CLI_DB_CONFIG_PATH')) {
            define('CLI_DB_CONFIG_PATH', 'etc/db.config.dev.php');
        }
        require_once dirname(__DIR__) . '/boot.php';
        $booted = true;
    }
}

// 테스트용 토큰 로그인 (Firebase 없이)
function verifyLoginWithTestToken(string $token): array {
    bootPhilgo();
    return verify_login(['id_token' => $token]);
}

// 테스트 사용자 정보 조회
function getTestUser(int $idx): ?array {
    bootPhilgo();
    return get_user($idx, USER_PRIVATE_FIELDS);
}
```

---

## 12. 마이그레이션 전략

### 12.1 점진적 전환 원칙

기존 시스템을 한번에 교체하지 않고, **단계적으로** 전환한다:

1. **기존 함수는 그대로 유지**: 기존 `lib/*.functions.php`의 함수는 삭제하지 않음
2. **새 함수는 기능별 폴더에 작성**: `lib/<module>/` 폴더에 새 함수 추가
3. **AllowedFunctions 래퍼 추가**: 새 함수를 API로 노출할 때 AllowedFunctions에 static 메서드 추가
4. **테스트 우선 작성**: 새 함수 작성 전 PEST 테스트 먼저 작성 (TDD)

### 12.2 전환 단계

| 단계 | 내용 | 상태 |
|------|------|------|
| Phase 1 | 폴더 구조 정리 (`lib/<module>/` 분리) | ✅ 완료 |
| Phase 2 | PEST 테스트 프레임워크 도입 | ✅ 완료 |
| Phase 3 | Entity 클래스 정의 | ✅ 완료 |
| Phase 4 | AllowedFunctions API 게이트웨이 | ✅ 완료 |
| Phase 5 | Controller 클래스 도입 (api.php + method 디스패치) | ✅ 완료 |
| Phase 5.1 | Utils 클래스 도입 (RequestUtils, Db) | ✅ 완료 |
| Phase 5.2 | api.php에서 boot.php 제거, Utils 클래스로 독립 | ✅ 완료 |
| Phase 6 | PDO prepared statement 전환 (Db 사용) | 🔄 진행 중 |
| Phase 7 | 테스트 커버리지 100% 달성 (PEST Unit Test 필수) | 🔄 진행 중 |
| Phase 8 | PSR-4 Autoloading 도입 (Utils, User 완료) | ✅ 완료 |
| Phase 9 | Vue.js CDN MPA 전면 적용 | 📋 계획 |

### 12.3 호환성 유지 규칙

- v7 시스템 API 엔드포인트: `/api.php` (필수 파라미터: `method`, 형식: `<module>.<action>`)
- 기존 `func.php`는 레거시로 유지하되, 새 코드는 `/api.php` + Controller 방식 사용
- 기존 `AllowedFunctions` 클래스는 레거시로 유지, 새 코드는 Controller 클래스 작성
- 기존 API 응답 구조 변경 금지 (필드 추가는 가능, 제거/변경 금지)
- 기존 JavaScript `func()` 호출 방식 유지
- 기존 PHP 페이지(`page/*.php`)의 동작 유지

---

## 13. Vue.js CDN MPA 방식

### 13.1 개념

SEO가 필요하지 않는 모든 페이지를 Vue.js CDN + MPA 방식으로 구현하여, PHP 서버 렌더링 대신 클라이언트에서 API 호출로 데이터를 가져온다.

### 13.2 적용 규칙

```html
<!-- Vue.js는 body 상단에 CDN으로 사전 로드됨 (중복 로드 금지) -->

<!-- ready() 래퍼 필수 (defer 로딩으로 DOMContentLoaded 보장) -->
<script>
ready(() => {
    Vue.createApp({
        data() {
            return { posts: [], loading: true };
        },
        async mounted() {
            const res = await func('get_posts', { post_id: 'freetalk', limit: 20 });
            this.posts = res;
            this.loading = false;
        },
        methods: {
            async deletePost(idx) {
                await func('delete_post', { idx });
                this.posts = this.posts.filter(p => p.idx !== idx);
            }
        }
    }).mount('#post-list-app');
});
</script>

<div id="post-list-app">
    <div v-if="loading">로딩 중...</div>
    <div v-for="post in posts" :key="post.idx">
        {{ post.subject }}
    </div>
</div>
```

### 13.3 필수 규칙

| 규칙 | 설명 |
|------|------|
| Options API 필수 | Composition API 사용 금지 |
| body 마운트 금지 | 고유 ID 컨테이너에 마운트 |
| `ready()` 래퍼 | 모든 Vue 코드는 `ready(() => { ... })` 안에 |
| `func()` 사용 | 모든 API 호출은 `func()` 함수 사용 |
| 구조 분해 금지 | `const { createApp } = Vue;` 금지 |
| 컴포넌트 함수화 | `Vue.createApp({ components: { xxx: xxxComponent() }})` |

---

## 14. Utils 클래스 (유틸리티)

### 14.0 ⚠️ 기존 함수 사용 금지 원칙

> **핵심 원칙**: **v7 시스템에서는 가능한 기존의 함수를 사용하지 않는다.** 기존 `*.functions.php` 파일의 함수(`in()`, `http_param()`, `pdo()`, `error()` 등)는 레거시로 취급하며, 새로운 코드에서 호출하지 않는다.
>
> **필요한 유틸리티는 `lib/utils/<Module>Utils.php` 클래스로 작성하여 Composer PSR-4 autoloading으로 로드한다.** (`use Philgo\Utils\<Module>Utils;`)

### 14.1 Utils 클래스 목록

**위치**: `lib/utils/`

| Utils 클래스 (FQCN) | 파일 | 대체 대상 (레거시) | 설명 |
|-------------|------|------------------|------|
| `Philgo\Utils\RequestUtils` | `lib/utils/RequestUtils.php` | `in()`, `http_param()`, `http_params()` | 클라이언트 요청 입력 처리 |
| `Philgo\Utils\Db` | `lib/utils/Db.php` | `pdo()`, `db_select()`, `db_insert()` 등 | PDO 데이터베이스 연결 |
| `Philgo\Utils\AuthService` | `lib/utils/AuthService.php` | `login()`, `get_user_from_session_id()`, `verify_login()` | 2경로 인증 (세션 + Firebase ID Token) |
| `Philgo\Utils\FirebaseService` | `lib/utils/FirebaseService.php` | `verifyFirebaseToken()`, `config()->tokens` | Firebase ID Token 검증 유틸리티 |
| `Philgo\Utils\Debug` | `lib/utils/Debug.php` | `debug_log()` | 디버그 로그 기록 (`var/debug.log`) |

### 14.2 RequestUtils 클래스

**파일**: `lib/utils/RequestUtils.php` | **네임스페이스**: `Philgo\Utils\RequestUtils`

```php
namespace Philgo\Utils;

class RequestUtils
{
    /**
     * 모든 입력 파라미터 조회 (JSON body + POST/GET 병합)
     */
    public static function all(): array { ... }

    /**
     * 특정 입력 파라미터 조회
     * 'null', 'undefined', 빈 문자열은 $default로 처리
     */
    public static function get(string $key, mixed $default = null): mixed { ... }

    /**
     * method 파라미터 파싱 → [module, action] 반환
     * @throws RuntimeException method 파라미터 없거나 형식 오류 시
     */
    public static function parseMethod(): array { ... }
}
```

**사용 예시**:
```php
use Philgo\Utils\RequestUtils;

// 모든 입력 조회
$input = RequestUtils::all();

// 특정 파라미터 조회 (기본값 지원)
$idx = RequestUtils::get('idx', 0);
$method = RequestUtils::get('method');

// method 파라미터 파싱
[$module, $action] = RequestUtils::parseMethod();
```

### 14.3 Db 클래스

**파일**: `lib/utils/Db.php` | **네임스페이스**: `Philgo\Utils\Db`

```php
namespace Philgo\Utils;

class Db
{
    /**
     * PDO 인스턴스 반환 (싱글톤)
     * etc/db.config.php 설정 파일을 포함하여 DB 연결
     * @throws RuntimeException DB 연결 실패 시
     */
    public static function pdo(): PDO { ... }

    /**
     * DB 설정 파일 경로를 수동 설정 (테스트용)
     */
    public static function setConfigPath(string $path): void { ... }
}
```

**사용 예시**:
```php
use Philgo\Utils\Db;

// PDO 인스턴스 가져오기
$pdo = Db::pdo();

// prepared statement 사용
$stmt = Db::pdo()->prepare("SELECT * FROM posts WHERE idx = :idx");
$stmt->execute(['idx' => 123]);
$row = $stmt->fetch(PDO::FETCH_ASSOC);

// 테스트 환경에서 다른 DB 설정 사용
Db::setConfigPath(__DIR__ . '/etc/db.config.test.php');
```

### 14.4 AuthService 클래스

**파일**: `lib/utils/AuthService.php` | **네임스페이스**: `Philgo\Utils\AuthService`

v7 `api.php`는 `boot.php`를 포함하지 않으므로 레거시 `login()` 함수를 사용할 수 없다.
`AuthService`는 v6의 `login()` 함수와 동일한 2경로 인증을 v7에서 독립적으로 구현한다.

**2경로 인증**:
1. 쿠키/파라미터의 `session_id` → 세션 해시 검증 후 DB 조회 (SSR/CURL용)
2. `id_token` 파라미터 → `FirebaseService`로 Firebase UID 획득 → DB 조회 (API용)

```php
namespace Philgo\Utils;

class AuthService
{
    /**
     * 현재 로그인한 사용자 정보를 리턴한다.
     * 경로 1: 쿠키/파라미터 session_id → 세션 기반 인증
     * 경로 2: id_token 파라미터 → Firebase ID Token 인증
     * 동일 요청 내 중복 조회 방지 (static 캐싱).
     *
     * @return array|null sf_member 전체 컬럼, 비로그인 시 null
     */
    public static function getLoginUser(): ?array { ... }

    /** 캐시 초기화 (테스트용) */
    public static function reset(): void { ... }
}
```

**사용 예시**:
```php
use Philgo\Utils\AuthService;

$user = AuthService::getLoginUser();
if ($user === null) {
    throw new RuntimeException('로그인이 필요합니다.');
}
echo $user['name'];

// 테스트 시 캐시 초기화
AuthService::reset();
```

> 상세 인증 흐름, 세션 ID 구조, 핵심 소스코드는 → [api/user.md 섹션 5](api/user.md#5-인증-시스템-authservice--firebaseservice) 참조

### 14.5 FirebaseService 클래스

**파일**: `lib/utils/FirebaseService.php` | **네임스페이스**: `Philgo\Utils\FirebaseService`

Firebase ID Token 검증 전용 유틸리티. v7에서 boot.php 없이 독립적으로 동작한다.
Kreait Firebase PHP SDK를 직접 사용하여 레거시 `verifyFirebaseToken()` 함수와 동일한 검증을 수행한다.

```php
namespace Philgo\Utils;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Exception\Auth\FailedToVerifyToken;

class FirebaseService
{
    /**
     * Firebase ID Token을 검증하고 Firebase UID를 반환한다.
     * 테스트 토큰이면 Firebase 인증 우회, 실제 토큰이면 Kreait SDK로 검증.
     *
     * @param string $token Firebase ID Token 또는 테스트 토큰
     * @return string Firebase UID
     * @throws \RuntimeException 토큰 검증 실패 시
     */
    public static function verifyIdToken(string $token): string { ... }

    /** 싱글톤 초기화 (테스트용) */
    public static function reset(): void { ... }
}
```

**사용 예시**:
```php
use Philgo\Utils\FirebaseService;

// 테스트 토큰으로 검증
$uid = FirebaseService::verifyIdToken('LOCAL_BANANA_TOKEN');
// → 'DA76oHESU0YnHo7i9lzu85vdirA2'

// 실제 Firebase ID Token으로 검증
$uid = FirebaseService::verifyIdToken($realFirebaseToken);
```

> 테스트 토큰 목록, Firebase 프로젝트 설정, 핵심 소스코드는 → [api/user.md 섹션 5.5](api/user.md#55-firebaseservice-핵심-소스코드) 참조

### 14.6 Debug 클래스

**파일**: `lib/utils/Debug.php` | **네임스페이스**: `Philgo\Utils\Debug`

기존 `debug_log()` 함수(`lib/boot.functions.php`)의 핵심 기능을 PSR-4 클래스로 구현한 디버그 로깅 유틸리티이다.
v7 `api.php`는 `boot.php`를 포함하지 않으므로, 레거시 `debug_log()` 함수를 사용할 수 없다.
`Debug` 클래스는 동일한 기능을 v7에서 독립적으로 제공한다.

**핵심 기능**:
- 개발 환경에서만 로그 기록 (macOS/Windows/localhost/CLI)
- 호출 스택 추적 자동 포함 (함수명, 파일명, 라인번호)
- 배열/객체는 JSON, bool/null은 문자열로 자동 변환
- 로그 파일: `var/debug.log` (기존과 동일 경로)

```php
namespace Philgo\Utils;

class Debug
{
    /**
     * 디버그 로그를 var/debug.log에 기록한다.
     * 개발 환경에서만 동작 (macOS/Windows/localhost/CLI).
     * 호출 스택 추적 자동 포함.
     */
    public static function log(mixed ...$messages): void { ... }

    /** 로그 파일 경로를 수동 설정 (테스트용) */
    public static function setLogPath(string $path): void { ... }

    /** 디버그 모드 활성화/비활성화 */
    public static function setEnabled(bool $enabled): void { ... }

    /** 개발 환경 체크 여부 설정 (false면 항상 로그 기록) */
    public static function setCheckEnv(bool $check): void { ... }

    /** 모든 설정 초기화 (테스트용) */
    public static function reset(): void { ... }
}
```

**사용 예시**:
```php
use Philgo\Utils\Debug;

// 기본 로그
Debug::log('사용자 로그인 성공', $userId);

// 배열 데이터 로그 (JSON으로 자동 변환)
Debug::log('입력값:', $input);

// 여러 인자 로그 (공백으로 구분)
Debug::log('쿼리 결과:', $sql, $params, $result);

// Controller에서 사용 예시
class UserController {
    public function me(array $input): array {
        Debug::log('user.me 호출됨, 입력값:', $input);
        $user = AuthService::getLoginUser();
        Debug::log('로그인 사용자:', $user);
        return $user;
    }
}
```

**로그 출력 형식 예시**:
```
[{main} at www/api.php:81 -> me() at utils/Debug.php:62] user.me 호출됨, 입력값: {"method":"user.me","session_id":"abc123"}
```

**로그 파일 확인**:
```bash
# 실시간 로그 모니터링
tail -f var/debug.log

# 로그 파일 비우기
> var/debug.log
```

> **참고**: `var/debug.log`는 `.gitignore`에 등록되어 있어 git에 포함되지 않는다.

### 14.7 새 Utils 클래스 작성 규칙

1. **파일 위치**: `lib/utils/<Module>Utils.php` (PascalCase 파일명)
2. **네임스페이스**: `namespace Philgo\Utils;`
3. **클래스명**: `<Module>Utils` (PascalCase + Utils 접미사)
4. **메서드**: 모든 메서드는 `public static` (stateless 유틸리티)
5. **에러 처리**: 에러 시 `throw new RuntimeException('에러 메시지')` — 기존 `error()` 함수 사용 금지
6. **테스트**: 모든 Utils 클래스는 PEST Unit Test 작성 필수
7. **composer.json**: `"Philgo\\Utils\\": "lib/utils/"` 매핑 이미 설정됨 (추가 설정 불필요)

---

## 15. PSR-4 Autoloading

> **상태**: ✅ 적용 완료 (User API, Utils 클래스)

v7 시스템의 모든 클래스는 **PSR-4 Autoloading**을 사용하여 네임스페이스 기반으로 자동 로드한다. `require_once` 대신 Composer autoloader를 통해 클래스를 로드한다.

### 15.1 네임스페이스 규칙

```
루트 네임스페이스: Philgo\
매핑 규칙: Philgo\<Module>\<ClassName> → lib/<module>/<ClassName>.php
```

**현재 적용된 매핑**:

| 네임스페이스 (FQCN) | 파일 경로 | 설명 |
|---------------------|-----------|------|
| `Philgo\Utils\RequestUtils` | `lib/utils/RequestUtils.php` | 요청 입력 처리 |
| `Philgo\Utils\Db` | `lib/utils/Db.php` | PDO 데이터베이스 연결 |
| `Philgo\Utils\AuthService` | `lib/utils/AuthService.php` | 2경로 인증 (세션 + Firebase) |
| `Philgo\Utils\FirebaseService` | `lib/utils/FirebaseService.php` | Firebase ID Token 검증 |
| `Philgo\User\UserController` | `lib/user/UserController.php` | 사용자 Controller |
| `Philgo\User\UserService` | `lib/user/UserService.php` | 사용자 Service |

### 15.2 Composer autoload 설정

**파일**: `composer.json`

```json
{
    "autoload": {
        "psr-4": {
            "Philgo\\Utils\\": "lib/utils/",
            "Philgo\\User\\": "lib/user/"
        }
    }
}
```

**새 모듈 추가 시**: `composer.json`에 PSR-4 매핑을 추가하고 `composer dump-autoload` 실행

```bash
# 예: Post 모듈 추가
# composer.json에 "Philgo\\Post\\": "lib/post/" 추가 후
composer dump-autoload
```

### 15.3 파일 네이밍 규칙

```
폴더명: lowercase (기존 폴더 유지 — lib/user/, lib/utils/ 등)
파일명: PascalCase (클래스명과 동일 — UserController.php, Db.php 등)
```

**규칙**:
1. **폴더명은 lowercase** 유지 — 기존 레거시 파일과 공존하기 위함
2. **파일명은 PascalCase** — PSR-4 표준에 따라 클래스명과 동일
3. **레거시 파일은 그대로 유지** — `user.functions.php` 등은 변경하지 않음

```
lib/user/
├── UserController.php          # ★ v7 시스템 (PSR-4, namespace)
├── UserService.php             # ★ v7 시스템 (PSR-4, namespace)
├── user.functions.php          # ⚠️ 레거시 (namespace 없음, require_once 사용)
├── user.login.functions.php    # ⚠️ 레거시
└── ...
```

### 15.4 api.php에서 Autoloader 사용

`api.php`는 Composer autoloader를 통해 모든 클래스를 자동 로드한다:

```php
<?php
const ROOT_DIR = __DIR__;

// Composer PSR-4 Autoloader (boot.php 대신)
require_once ROOT_DIR . '/vendor/autoload.php';

use Philgo\Utils\RequestUtils;

// method 파라미터 파싱
[$module, $action] = RequestUtils::parseMethod();

// Controller FQCN 생성 (PSR-4 네임스페이스 기반)
// "user" → "Philgo\User\UserController"
// "member_block" → "Philgo\MemberBlock\MemberBlockController"
$pascalModule = str_replace(' ', '', ucwords(str_replace(['_', '-'], ' ', $module)));
$className = "Philgo\\{$pascalModule}\\{$pascalModule}Controller";

// class_exists()가 autoloader를 트리거하여 자동 로드
$ctrl = new $className();
$res = $ctrl->$action(RequestUtils::all());
```

### 15.5 PEST 테스트에서 Autoloader 사용

```php
<?php
// tests/Unit/UserControllerTest.php

use Philgo\User\UserController;
use Philgo\User\UserService;

beforeAll(function () {
    if (!defined('ROOT_DIR')) {
        define('ROOT_DIR', dirname(dirname(__DIR__)));
    }
    require_once ROOT_DIR . '/vendor/autoload.php';
});

describe('UserController', function () {
    it('count() - 배열을 반환한다', function () {
        $ctrl = new UserController();
        $result = $ctrl->count([]);
        expect($result)->toBeArray();
    });
});
```

### 15.6 새 모듈 추가 절차

1. **폴더 생성**: `lib/<module>/` (lowercase)
2. **Controller 파일 생성**: `lib/<module>/<Module>Controller.php`
   - `namespace Philgo\<Module>;` 선언
3. **Service 파일 생성**: `lib/<module>/<Module>Service.php`
   - `namespace Philgo\<Module>;` 선언
   - `use Philgo\Utils\Db;` 등 필요한 클래스 임포트
4. **composer.json에 매핑 추가**:
   ```json
   "Philgo\\<Module>\\": "lib/<module>/"
   ```
5. **`composer dump-autoload` 실행**
6. **PEST 테스트 작성**: `tests/Unit/<Module>ControllerTest.php`

### 15.7 전환 전략

1. ✅ 새로운 클래스부터 네임스페이스 + PSR-4 적용 (완료: Utils, User)
2. 기존 레거시 파일(`*.functions.php`)은 당분간 `require_once` 유지
3. 점진적으로 기존 클래스에 네임스페이스 추가 (Entity 등)
4. 충분히 전환된 후 `etc/includes.php`의 `require_once` 정리

---

## 16. 문서 분할 규칙

### 16.1 분할 원칙

`architecture.md` 문서가 길어지면, 모듈별 상세 API 문서를 별도 파일로 분리한다.

```
.claude/skills/v7-skill/references/
├── architecture.md            # ★ 메인 문서 (아키텍처, 설계 원칙, 공통 규칙)
└── api/                       # ★ 모듈별 API 상세 문서
    ├── user.md                # 사용자 API (user.count, user.login 등)
    ├── post.md                # 게시글 API (post.create, post.get 등)
    ├── comment.md             # 댓글 API
    ├── company.md             # 업소록 API
    ├── upload.md              # 업로드 API
    └── ...                    # 기타 모듈
```

### 16.2 분할 기준

| 문서 | 내용 | 비고 |
|------|------|------|
| `architecture.md` | 아키텍처 설계 원칙, 폴더 구조, 부트 프로세스, 공통 규칙 | 메인 문서 (변경 빈도 낮음) |
| `api/<module>.md` | 모듈별 API 엔드포인트, Controller/Service 코드, 테스트 방법, curl 예시 | 모듈별 상세 (변경 빈도 높음) |

### 16.3 모듈 문서 작성 규칙

각 `api/<module>.md` 문서는 다음 구조를 따른다:

1. **개요**: 모듈 설명, DB 테이블, Controller/Service FQCN
2. **아키텍처**: 호출 흐름 다이어그램
3. **API 엔드포인트**: 각 endpoint별 method, 파라미터, 응답, curl 예시
4. **파일 구조**: Controller, Service 코드 예시
5. **테스트**: PEST Unit Test 항목 및 실행 방법

### 16.4 현재 분리된 모듈 문서

| 모듈 | 문서 | 상태 |
|------|------|------|
| User | `api/user.md` | ✅ 작성 완료 |

---

## 17. 기존 코드와의 통합 사용

### 17.1 개요

v7 시스템의 Controller/Service 클래스는 **기존 레거시 페이지(page.header.php, page.footer.php)**와 함께 사용할 수 있다. 기존 레이아웃과 디자인을 유지하면서 v7 시스템의 비즈니스 로직을 활용하는 방식이다.

### 17.2 사용 방법

기존 페이지 템플릿 안에서 v7 시스템의 Service 클래스를 사용하려면, `vendor/autoload.php`를 추가로 로드하면 된다.

```php
<?php
include_once '../page.header.php';
require_once ROOT_DIR . '/vendor/autoload.php';

use Philgo\User\UserService;

// UserService를 사용하여 총 사용자 수 표시
$count = UserService::getTotalCount();
echo "<h1>총 사용자 수: {$count}</h1>";

include_once '../page.footer.php';
```

### 17.3 핵심 포인트

| 항목 | 설명 |
|------|------|
| `page.header.php` | 기존 레이아웃(헤더, 네비게이션, Bootstrap 등)을 로드한다. `boot.php`도 포함되어 `ROOT_DIR`, `pdo()` 등 레거시 함수를 사용할 수 있다. |
| `vendor/autoload.php` | Composer PSR-4 autoloader를 로드한다. `page.header.php`에는 포함되어 있지 않으므로 **별도로 require** 해야 한다. |
| `use` 문 | 네임스페이스 기반 클래스를 임포트한다. `use Philgo\User\UserService;` 등 |
| `page.footer.php` | 기존 레이아웃(푸터, JavaScript 등)을 닫는다. |

### 17.4 주의사항

- `page.header.php`를 먼저 include한 후 `vendor/autoload.php`를 require한다. (`ROOT_DIR` 상수가 `boot.php`에서 정의되기 때문)
- 기존 레거시 함수(`pdo()`, `login()`, `in()` 등)와 v7 시스템 클래스(`UserService`, `Db` 등)를 **동일 페이지에서 함께** 사용할 수 있다.
- v7 시스템의 `Db::pdo()`와 기존 `pdo()` 함수는 **별도의 PDO 커넥션**이므로, 하나의 페이지에서는 가능하면 한쪽만 사용하는 것을 권장한다.

---

## 부록: 주요 유틸리티 함수 레퍼런스

| 함수 | 용도 | 파일 |
|------|------|------|
| `pdo()` | PDO 커넥션 객체 반환 | `etc/db.php` |
| `in($key)` | 입력 파라미터 조회 | `lib/input.functions.php` |
| `http_param($key, $default)` | 입력 파라미터 (기본값) | `lib/input.functions.php` |
| `error($code, $msg, $status)` | 에러 응답/예외 | `lib/boot.functions.php` |
| `soft_error($code, $msg)` | 208 중복 에러 | `lib/functions.php` |
| `success($data)` | JSON 성공 응답 | `lib/functions.php` |
| `login()` | 현재 로그인 사용자 | `lib/auth.functions.php` |
| `is_admin()` | 관리자 여부 확인 | `lib/functions.php` |
| `t()->키` | 다국어 텍스트 | `etc/translations/t.php` |
| `href()->post->view(...)` | URL 생성 | `lib/href.functions.php` |
| `debug_log($tag, $msg)` | 디버그 로그 | `lib/boot.functions.php` |
