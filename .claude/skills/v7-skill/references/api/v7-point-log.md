# v7 포인트 로그 (PointLog) API

## 개요

`sf_point_log` 테이블에 대한 범용 CRUD API.
포인트 변경(충전/차감), 히스토리 조회, 로그 관리 등을 제공한다.

레거시 `change_user_points()` 함수와 100% 호환되는 핵심 로직을 v7 아키텍처로 구현하였다.

### 모듈 구조

| 파일 | 역할 |
|------|------|
| `lib/point_log/PointLogEntity.php` | sf_point_log 레코드 Entity |
| `lib/point_log/PointLogRepository.php` | CRUD DB 쿼리 |
| `lib/point_log/PointLogService.php` | 비즈니스 로직 |
| `lib/point_log/PointLogController.php` | API 엔드포인트 |

### API 접두사

`pointLog.*`

### 관련 테이블

- `sf_point_log` — 포인트 변경 이력
- `sf_member` — 회원 정보 (point 컬럼)

---

## 목차

1. [PointLogEntity 구조](#1-pointlogentity-구조)
2. [pointLog.changePoints — 포인트 변경](#2-pointlogchangepoints--포인트-변경)
3. [pointLog.get — 로그 단건 조회](#3-pointlogget--로그-단건-조회)
4. [pointLog.history — 히스토리 조회](#4-pointloghistory--히스토리-조회)
5. [pointLog.logsByPost — 게시글별 로그 조회](#5-pointloglogsbypost--게시글별-로그-조회)
6. [pointLog.memberPoint — 회원 포인트 조회](#6-pointlogmemberpoint--회원-포인트-조회)
7. [pointLog.recentCount — 최근 액션 횟수](#7-pointlogrecentcount--최근-액션-횟수)
8. [pointLog.weeklyCount — 주간 횟수](#8-pointlogweeklycount--주간-횟수)
9. [pointLog.sumByPost — 게시글별 합산](#9-pointlogsumbypost--게시글별-합산)
10. [pointLog.update — 로그 수정](#10-pointlogupdate--로그-수정)
11. [pointLog.delete — 로그 삭제](#11-pointlogdelete--로그-삭제)
12. [에러 응답](#12-에러-응답)
13. [레거시 호환 매핑](#13-레거시-호환-매핑)

---

## 1. PointLogEntity 구조

`sf_point_log` 테이블의 한 행을 나타내는 Entity.

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | int | 로그 고유 ID (AUTO_INCREMENT) |
| `idx_member_from` | int | 포인트를 변경한(보낸) 회원 ID |
| `idx_member_to` | int | 포인트를 받은 회원 ID |
| `point_before` | int | 변경 전 포인트 (idx_member_to 기준) |
| `point` | int | 변경 포인트 (양수=증가, 음수=감소) |
| `point_after` | int | 변경 후 포인트 (idx_member_to 기준) |
| `module` | string | 모듈명 |
| `action` | string | 액션명 |
| `idx_post` | int | 관련 게시글 ID (없으면 0) |
| `etc` | string | 기타 정보 (사유 등) |
| `stamp` | int | Unix 타임스탬프 |
| `ip` | string | 사용자 IP 주소 |
| `created_at` | string | ISO 8601 형식 시간 (toArray 전용) |

### module / action 값 예시 (레거시 호환)

| module | action | etc | 용도 |
|--------|--------|-----|------|
| `post` | `create` | `point_write` | 글 작성 |
| `post` | `delete` | `point_write_delete` | 글 삭제 |
| `comment` | `create` | `point_comment` | 코멘트 작성 |
| `comment` | `delete` | `point_comment_delete` | 코멘트 삭제 |
| `vote` | `like` | `like` | 좋아요 |
| `admin` | `update` | `admin-point-update` | 관리자 수정 |
| `adv` | `point-post-advertisement` | `point-post-advertisement` | 포인트 광고 |
| `point_event` | `mukbang_create` | `mukbang_event_base` | 먹방 이벤트 (기본) |
| `point_event` | `mukbang_create` | `mukbang_event_bonus` | 먹방 이벤트 (보너스) |
| `event` | `spin` | `spin_reward` | 스피닝 휠 보상 |
| `event` | `spin` | `spin_cost` | 스피닝 휠 비용 |

---

## 2. pointLog.changePoints — 포인트 변경

포인트를 변경하고 sf_point_log에 기록한다.

- **인증**: 필수
- **포인트 최소값**: 0 이하로 내려가지 않음

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.changePoints",
  "session_id": "xxx",
  "points": 100,
  "module": "event",
  "action": "spin",
  "idx_member_to": 12345,
  "idx_post": 0,
  "etc": "스피닝 휠 보상"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `points` | int | O | 변경할 포인트 (양수=증가, 음수=감소) |
| `module` | string | O | 모듈명 |
| `action` | string | O | 액션명 |
| `idx_member_to` | int | X | 대상 회원 ID (미지정 시 본인) |
| `idx_post` | int | X | 관련 게시글 ID (기본 0) |
| `etc` | string | X | 기타 정보 |

### 응답

```json
{
  "idx": 12345,
  "idx_member_from": 188690,
  "idx_member_to": 188690,
  "point_before": 5000,
  "point": 100,
  "point_after": 5100,
  "module": "event",
  "action": "spin",
  "idx_post": 0,
  "etc": "스피닝 휠 보상",
  "stamp": 1740000000,
  "ip": "127.0.0.1",
  "created_at": "2025-02-20 00:00:00"
}
```

---

## 3. pointLog.get — 로그 단건 조회

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.get",
  "session_id": "xxx",
  "idx": 12345
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx` | int | O | 로그 idx |

### 응답

PointLogEntity 배열 (→ [1. PointLogEntity 구조](#1-pointlogentity-구조) 참조)

---

## 4. pointLog.history — 히스토리 조회

회원의 포인트 변경 히스토리를 페이지네이션으로 조회한다.

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.history",
  "session_id": "xxx",
  "page": 1,
  "limit": 20,
  "module": "event",
  "action": "spin"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `page` | int | X | 페이지 번호 (기본 1) |
| `limit` | int | X | 페이지당 항목 수 (기본 20, 최대 100) |
| `module` | string | X | 모듈 필터 |
| `action` | string | X | 액션 필터 |

### 응답

```json
{
  "total": 150,
  "page": 1,
  "limit": 20,
  "items": [
    {
      "idx": 12345,
      "idx_member_from": 188690,
      "idx_member_to": 188690,
      "point_before": 5000,
      "point": 100,
      "point_after": 5100,
      "module": "event",
      "action": "spin",
      "idx_post": 0,
      "etc": "spin_reward",
      "stamp": 1740000000,
      "ip": "127.0.0.1",
      "created_at": "2025-02-20 00:00:00"
    }
  ]
}
```

---

## 5. pointLog.logsByPost — 게시글별 로그 조회

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.logsByPost",
  "session_id": "xxx",
  "idx_post": 456,
  "module": "point_event"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx_post` | int | O | 게시글 번호 |
| `module` | string | X | 모듈 필터 |
| `action` | string | X | 액션 필터 |

### 응답

PointLogEntity 배열의 리스트.

---

## 6. pointLog.memberPoint — 회원 포인트 조회

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.memberPoint",
  "session_id": "xxx"
}
```

### 응답

```json
{
  "idx_member": 188690,
  "point": 5100
}
```

---

## 7. pointLog.recentCount — 최근 액션 횟수

포인트 남용 방지(throttling)에 사용. 레거시 `get_point_history_count_within()`과 동일.

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.recentCount",
  "session_id": "xxx",
  "minutes": 10,
  "action": "create"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `minutes` | int | O | 최근 몇 분 |
| `action` | string | O | 액션명 |

### 응답

```json
{
  "count": 3,
  "minutes": 10,
  "action": "create"
}
```

---

## 8. pointLog.weeklyCount — 주간 횟수

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.weeklyCount",
  "session_id": "xxx",
  "module": "point_event",
  "action": "mukbang_create",
  "etc": "mukbang_event_base"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `module` | string | O | 모듈명 |
| `action` | string | O | 액션명 |
| `etc` | string | X | etc 필터 |

### 응답

```json
{
  "count": 2,
  "module": "point_event",
  "action": "mukbang_create"
}
```

---

## 9. pointLog.sumByPost — 게시글별 합산

글 삭제 시 포인트 차감 금액 계산에 사용.

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.sumByPost",
  "session_id": "xxx",
  "idx_post": 456,
  "module": "point_event"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx_post` | int | O | 게시글 번호 |
| `module` | string | X | 모듈 필터 |

### 응답

```json
{
  "idx_post": 456,
  "sum_point": 6900
}
```

---

## 10. pointLog.update — 로그 수정

메타 정보(etc, module, action)만 수정 가능.

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.update",
  "session_id": "xxx",
  "idx": 12345,
  "etc": "수정된 사유"
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx` | int | O | 로그 idx |
| `etc` | string | X | 수정할 기타 정보 |
| `module` | string | X | 수정할 모듈명 |
| `action` | string | X | 수정할 액션명 |

### 응답

수정된 PointLogEntity 배열.

---

## 11. pointLog.delete — 로그 삭제

### 요청

```
POST https://local.philgo.com/api.php
Content-Type: application/json

{
  "method": "pointLog.delete",
  "session_id": "xxx",
  "idx": 12345
}
```

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `idx` | int | O | 로그 idx |

### 응답

```json
{
  "deleted": true,
  "idx": 12345
}
```

---

## 12. 에러 응답

모든 에러는 다음 형태로 반환된다:

```json
{
  "success": false,
  "message": "에러 메시지"
}
```

| 에러 메시지 | 원인 |
|------------|------|
| `로그인이 필요합니다.` | session_id 미제공 또는 만료 |
| `points 파라미터가 필요합니다.` | changePoints에서 points 미제공 |
| `module 파라미터가 필요합니다.` | module 미제공 |
| `action 파라미터가 필요합니다.` | action 미제공 |
| `idx 파라미터가 필요합니다.` | get/update/delete에서 idx 미제공 |
| `포인트 로그를 찾을 수 없습니다.` | 존재하지 않는 idx |
| `회원을 찾을 수 없습니다.` | 존재하지 않는 회원 |

---

## 13. 레거시 호환 매핑

| 레거시 함수 | v7 API / Service 메서드 |
|------------|----------------------|
| `change_user_points()` | `pointLog.changePoints` / `PointLogService::changePoints()` |
| `point_log_controller()` | `pointLog.history` / `PointLogService::getHistory()` |
| `get_point_history_count_within()` | `pointLog.recentCount` / `PointLogService::getRecentActionCount()` |
| `increase_user_points_for_post_create()` | `PointLogService::changePoints()` + module='post', action='create' |
| `decrease_user_points_for_post_delete()` | `PointLogService::changePoints()` + module='post', action='delete' |

### 다른 v7 모듈에서 사용 예시

```php
use Philgo\PointLog\PointLogService;

// 스피닝 휠 보상 포인트 지급
$log = PointLogService::changePoints(
    points: 100,
    idxMemberFrom: 0,
    idxMemberTo: $idxMember,
    module: 'event',
    action: 'spin',
    etc: 'spin_reward'
);

// 먹방 이벤트 포인트 지급
$log = PointLogService::changePoints(
    points: 1500,
    idxMemberFrom: 0,
    idxMemberTo: $idxMember,
    module: 'point_event',
    action: 'mukbang_create',
    idxPost: $idxPost,
    etc: 'mukbang_event_base'
);

// 포인트 히스토리 조회
$history = PointLogService::getHistory($idxMember, page: 1, limit: 20);

// 현재 포인트 조회
$point = PointLogService::getMemberPoint($idxMember);
```
