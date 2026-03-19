# v7 Report API — 신고 시스템

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
  - [2.1 파일 구조](#21-파일-구조)
  - [2.2 DB 컬럼 사용](#22-db-컬럼-사용)
  - [2.3 ReportEntity](#23-reportentity)
  - [2.4 ReportRepository](#24-reportrepository)
  - [2.5 ReportService](#25-reportservice)
  - [2.6 ReportController](#26-reportcontroller)
- [3. API 엔드포인트](#3-api-엔드포인트)
  - [3.1 report.report — 글/코멘트 신고](#31-reportreport--글코멘트-신고)
  - [3.2 report.list — 신고 목록 조회](#32-reportlist--신고-목록-조회)
  - [3.3 report.dismiss — 신고 해제](#33-reportdismiss--신고-해제)
- [4. 하위 호환 (PostController/PostService 위임)](#4-하위-호환-postcontrollerpostservice-위임)
- [5. 웹 페이지에서의 사용](#5-웹-페이지에서의-사용)
- [6. 데이터 흐름](#6-데이터-흐름)
- [7. 에러 처리](#7-에러-처리)

---

## 1. 개요

Report 모듈은 글(post)과 코멘트(comment)에 대한 **신고(Report) 시스템**을 제공함.
사용자가 부적절한 콘텐츠를 신고하면 관리자가 신고 목록을 확인하고 조치(해제/삭제 등)할 수 있음.

기존에 PostService/PostController에 흩어져 있던 신고 관련 로직을 **독립 모듈(Report)**로 분리하여
단일 책임 원칙(SRP)을 적용한 구조임.

| 항목 | 설명 |
|------|------|
| **모듈 이름** | Report |
| **네임스페이스** | `Philgo\Report` |
| **DB 테이블** | `sf_post_data` (기존 테이블 공유) |
| **사용 컬럼** | `report` (신고 플래그), `text_10` (REPORTER_LIST_FIELD, 신고자 idx 목록) |
| **인증** | 신고: 로그인 필수 / 목록 조회 및 해제: 관리자 전용 |

---

## 2. 아키텍처

### 2.1 파일 구조

```
lib/report/
  ReportEntity.php        — 신고 정보 Entity (EntityInterface 구현)
  ReportRepository.php    — DB 접근 Repository
  ReportService.php       — 비즈니스 로직 Service (ServiceInterface 구현)
  ReportController.php    — API Controller (ControllerInterface 구현)
```

### 2.2 DB 컬럼 사용

Report 모듈은 별도의 전용 테이블을 사용하지 않고, 기존 `sf_post_data` 테이블의 두 컬럼을 활용함.

| 컬럼 | 상수 | 타입 | 설명 |
|------|------|------|------|
| `report` | — | varchar | 신고 플래그. 신고 시 `'Y'`, 해제 시 `''` |
| `text_10` | `REPORTER_LIST_FIELD` | text | 신고자 회원 idx를 콤마(`,`)로 구분한 문자열. 예: `"88802,88803"` |

> `REPORTER_LIST_FIELD` 상수는 `lib/constants.php`(라인 289)에 정의: `const REPORTER_LIST_FIELD = 'text_10';`

### 2.3 ReportEntity

- **파일**: `lib/report/ReportEntity.php`
- **네임스페이스**: `Philgo\Report\ReportEntity`
- **인터페이스**: `EntityInterface` 구현 (`fromArray()`, `toArray()`)

| 프로퍼티 | 타입 | 설명 |
|---------|------|------|
| `idx` | int | 글/코멘트 고유 ID |
| `idx_member` | int | 작성자 회원 번호 |
| `type` | string | `'post'` 또는 `'comment'` (idx_parent > 0이면 comment) |
| `subject` | string | 제목 |
| `content` | string | 내용 |
| `user_name` | string | 작성자 닉네임 |
| `report` | string | 신고 플래그 (`'Y'` 또는 `''`) |
| `reporters` | string | 신고자 idx 목록 (콤마 구분) |
| `reporter_count` | int | 신고자 수 (reporters에서 계산) |
| `stamp_update` | int | 마지막 업데이트 시각 (Unix timestamp) |
| `idx_parent` | int | 부모 글 idx (코멘트인 경우) |
| `idx_root` | int | 최상위 글 idx |
| `post_id` | string | 게시판 ID |

`type` 필드는 별도 DB 컬럼이 아니라 `idx_parent` 값으로 자동 판정함:
- `idx_parent > 0` → `'comment'`
- `idx_parent == 0` → `'post'`

### 2.4 ReportRepository

- **파일**: `lib/report/ReportRepository.php`
- **네임스페이스**: `Philgo\Report\ReportRepository`
- **인터페이스**: 미적용 (표준 CRUD 패턴과 다른 도메인 특성)

| 메서드 | 시그니처 | 설명 |
|--------|---------|------|
| `getReporters()` | `(int $idx): string\|false` | 특정 글/코멘트의 신고자 목록 문자열 조회. 대상 없으면 `false` |
| `updateReporters()` | `(int $idx, string $reportersCsv): void` | 신고자 목록 업데이트 + `report='Y'` 설정 |
| `findReported()` | `(int $limit = 5): array` | 신고된 글/코멘트 간단 목록 (idx, subject만) |
| `findReportedDetailed()` | `(int $limit = 20, int $offset = 0): array` | 신고된 글/코멘트 상세 목록 (관리자용) |
| `countReported()` | `(): int` | 신고된 글/코멘트 총 건수 |
| `dismissReport()` | `(int $idx): void` | 신고 해제 (report 플래그 + 신고자 목록 초기화) |

### 2.5 ReportService

- **파일**: `lib/report/ReportService.php`
- **네임스페이스**: `Philgo\Report\ReportService`
- **인터페이스**: `ServiceInterface` 구현

**도메인 전용 메서드**:

| 메서드 | 시그니처 | 설명 |
|--------|---------|------|
| `report()` | `(int $memberIdx, string $type, int $idx): array` | 신고 처리 (중복 방지, 타입 검증) |
| `listReported()` | `(int $limit = 5): array` | 간단 목록 조회 |
| `listReportedDetailed()` | `(int $limit = 20, int $offset = 0): array` | 상세 목록 조회 (관리자 전용) |
| `countReported()` | `(): int` | 총 건수 조회 |
| `dismissReport()` | `(int $idx): void` | 신고 해제 (관리자 전용) |

**ServiceInterface 필수 메서드** (미지원 메서드는 RuntimeException throw):

| 메서드 | 동작 |
|--------|------|
| `create()` | `RuntimeException` — `report.report`를 사용하세요 |
| `update()` | `RuntimeException` — 미지원 |
| `delete()` | `RuntimeException` — `report.dismiss`를 사용하세요 |
| `get()` | `RuntimeException` — 미지원 |
| `list()` | `listReportedDetailed()` 호출 (items + total + limit + offset 반환) |

### 2.6 ReportController

- **파일**: `lib/report/ReportController.php`
- **네임스페이스**: `Philgo\Report\ReportController`
- **인터페이스**: `ControllerInterface` 구현
- **API method 접두사**: `report.*`

| 메서드 | API method | 권한 | 설명 |
|--------|-----------|------|------|
| `report()` | `report.report` | 로그인 필수 | 글/코멘트 신고 |
| `list()` | `report.list` | 관리자 전용 | 신고 목록 조회 |
| `dismiss()` | `report.dismiss` | 관리자 전용 | 신고 해제 |

**ControllerInterface CRUD 매핑**:

| CRUD 메서드 | 동작 |
|------------|------|
| `create()` | `report()` 래퍼 |
| `update()` | `RuntimeException` — 미지원 |
| `delete()` | `RuntimeException` — `report.dismiss` 사용 |
| `get()` | `RuntimeException` — 미지원 |
| `list()` | 직접 구현 (관리자 권한 확인 후 ReportService 호출) |

---

## 3. API 엔드포인트

### 3.1 report.report -- 글/코멘트 신고

글 또는 코멘트를 신고함. 인증된 사용자만 가능하며, 같은 사용자가 같은 대상을 중복 신고할 수 없음.

**URL**: `/api.php?method=report.report`

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `session_id` | string | O | 인증용 세션 ID |
| `type` | string | O | 신고 유형: `'post'` 또는 `'comment'` |
| `idx` | int | O | 신고 대상 글/코멘트 idx |

**응답 예시**:

```json
{
  "success": true,
  "idx": 123,
  "message": "신고가 접수되었습니다."
}
```

**에러 상황**:
- 미인증: `"로그인이 필요합니다."`
- 유효하지 않은 파라미터: `"유효하지 않은 파라미터입니다."`
- 유효하지 않은 타입: `"유효하지 않은 신고 유형입니다."`
- 대상 없음: `"신고할 항목을 찾을 수 없습니다."`
- 중복 신고: `"이미 신고를 하였습니다."`

**curl 예시**:

```bash
curl -k "https://v7-local.philgo.com/api.php?method=report.report&session_id=xxx&type=post&idx=123"
```

### 3.2 report.list -- 신고 목록 조회

신고된 글/코멘트의 상세 목록을 조회함. 관리자 전용.

**URL**: `/api.php?method=report.list`

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `session_id` | string | O | — | 관리자 인증용 세션 ID |
| `limit` | int | X | 20 | 최대 조회 수 |
| `offset` | int | X | 0 | 시작 위치 |

**응답 예시**:

```json
{
  "success": true,
  "items": [
    {
      "idx": 123,
      "subject": "부적절한 글",
      "content": "내용 200자 제한...",
      "idx_member": 456,
      "user_name": "작성자",
      "report": "Y",
      "text_10": "88802,88803",
      "stamp_update": 1710835200,
      "idx_parent": 0,
      "idx_root": 0,
      "post_id": "freetalk"
    }
  ],
  "total": 15,
  "limit": 20,
  "offset": 0
}
```

**curl 예시**:

```bash
curl -k "https://v7-local.philgo.com/api.php?method=report.list&session_id=관리자세션&limit=10&offset=0"
```

### 3.3 report.dismiss -- 신고 해제

신고된 글/코멘트의 신고를 해제(초기화)함. 관리자 전용.
`report` 플래그를 `''`으로, 신고자 목록(`text_10`)을 `''`으로 초기화함.

**URL**: `/api.php?method=report.dismiss`

**요청 파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `session_id` | string | O | 관리자 인증용 세션 ID |
| `idx` | int | O | 신고 해제할 글/코멘트 idx |

**응답 예시**:

```json
{
  "success": true,
  "idx": 123,
  "message": "신고가 해제되었습니다."
}
```

**에러 상황**:
- 미인증: `"로그인이 필요합니다."`
- 관리자 아님: `"관리자 권한이 필요합니다."`
- idx 누락: `"idx는 필수입니다."`
- 대상 없음: `"항목을 찾을 수 없습니다."`

**curl 예시**:

```bash
curl -k "https://v7-local.philgo.com/api.php?method=report.dismiss&session_id=관리자세션&idx=123"
```

---

## 4. 하위 호환 (PostController/PostService 위임)

기존에 `post.report`, `post.reportList` API로 신고 기능을 사용하던 코드와의 하위 호환을 위해,
PostController와 PostService에서 ReportService로 위임하는 구조를 유지함.

### PostController 위임 (lib/post/PostController.php)

```php
// post.report → ReportService::report() 위임
public function report(array $input): array
{
    // ...인증 처리 후...
    return ReportService::report($memberIdx, $type, $idx);
}

// post.reportList → ReportService::listReported() 위임
public function reportList(array $input): array
{
    return ReportService::listReported($limit);
}
```

### PostService 위임 (lib/post/PostService.php)

```php
// PostService의 신고 관련 메서드들이 모두 ReportService로 위임
public static function listReported(int $limit = 5): array
{
    return \Philgo\Report\ReportService::listReported($limit);
}

public static function listReportedDetailed(int $limit = 20, int $offset = 0): array
{
    return \Philgo\Report\ReportService::listReportedDetailed($limit, $offset);
}

public static function countReported(): int
{
    return \Philgo\Report\ReportService::countReported();
}
```

> **권장**: 신규 코드에서는 `report.*` API를 직접 사용할 것. `post.report`/`post.reportList`는 하위 호환 용도로만 유지됨.

---

## 5. 웹 페이지에서의 사용

v7 웹 페이지에서는 API를 거치지 않고 ReportService를 직접 호출하여 서버 사이드 렌더링(SSR)에 활용함.

### 관리자 신고 관리 페이지 (v7/admin/reports.php)

```php
use Philgo\Report\ReportService;

$totalReported = ReportService::countReported();
$reportedPosts = ReportService::listReportedDetailed($perPage, $offset);
```

### 홈 관리자 알림 위젯 (v7/widgets/home/home.admin-reminder.php)

```php
use Philgo\Report\ReportService;

$_reportedPosts = ReportService::listReported(5);
```

---

## 6. 데이터 흐름

```
[API 경로]
클라이언트 → api.php → ReportController → ReportService → ReportRepository → sf_post_data

[하위 호환 경로]
클라이언트 → api.php → PostController → ReportService → ReportRepository → sf_post_data

[웹 페이지 직접 호출]
v7/admin/reports.php → ReportService → ReportRepository → sf_post_data
v7/widgets/home/home.admin-reminder.php → ReportService → ReportRepository → sf_post_data
```

---

## 7. 에러 처리

모든 에러는 `RuntimeException`으로 throw되며, `api.php`에서 catch하여 `{success: false, message: "..."}` JSON 응답으로 변환됨.

| 에러 상황 | 발생 위치 | 메시지 |
|----------|----------|--------|
| 미인증 | ReportController | `"로그인이 필요합니다."` |
| 관리자 아님 | ReportController | `"관리자 권한이 필요합니다."` |
| 파라미터 누락 | ReportController | `"유효하지 않은 파라미터입니다."` / `"idx는 필수입니다."` |
| 유효하지 않은 타입 | ReportService | `"유효하지 않은 신고 유형입니다."` |
| 대상 없음 | ReportService | `"신고할 항목을 찾을 수 없습니다."` / `"항목을 찾을 수 없습니다."` |
| 중복 신고 | ReportService | `"이미 신고를 하였습니다."` |
| 미지원 CRUD | ReportService/Controller | `"report.create는 지원하지 않습니다. report.report를 사용하세요."` 등 |
