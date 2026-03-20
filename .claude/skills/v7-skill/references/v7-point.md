# v7 포인트 시스템 레퍼런스

## 목차

1. [개요](#1-개요)
2. [포인트 개념 및 용어](#2-포인트-개념-및-용어)
3. [포인트 테이블 구조](#3-포인트-테이블-구조)
4. [게시판 포인트 설정 (sf_post_config)](#4-게시판-포인트-설정)
5. [포인트 변경 핵심 로직 (PointLogService::changePoints)](#5-포인트-변경-핵심-로직)
6. [글 생성/삭제 시 포인트 처리](#6-글-생성삭제-시-포인트-처리)
7. [코멘트 생성/삭제 시 포인트 처리](#7-코멘트-생성삭제-시-포인트-처리)
8. [좋아요/좋아요 해제 시 포인트 처리](#8-좋아요좋아요-해제-시-포인트-처리)
9. [포인트 이벤트 (랜덤 포인트)](#9-포인트-이벤트-랜덤-포인트)
10. [포인트 남용 방지 (Throttling)](#10-포인트-남용-방지)
11. [포인트 광고 시스템](#11-포인트-광고-시스템)
12. [포인트 레벨 시스템](#12-포인트-레벨-시스템)
13. [관리자 포인트 관리](#13-관리자-포인트-관리)
14. [v6 레거시 함수 대응표](#14-v6-레거시-함수-대응표)
15. [API 엔드포인트](#15-api-엔드포인트)
16. [포인트 흐름도](#16-포인트-흐름도)
17. [계산 예시](#17-계산-예시)
18. [v7 웹 포인트 내역 페이지](#18-v7-웹-포인트-내역-페이지)

---

## 1. 개요

v7 포인트 시스템은 v6 `lib/point.functions.php`의 핵심 로직을 v7 아키텍처(Controller + Service + Repository + Entity)로 구현한다.

핵심 원칙:
- 포인트는 **0 이하로 내려가지 않는다** (음수 방지)
- 모든 포인트 변경은 `sf_point_log` 테이블에 기록된다
- 실제 지급된 포인트는 글/코멘트의 `int_10` 필드에 저장된다
- 검열 거부(`checked='R'`) 또는 블라인드(`blind='Y'`) 처리된 글/코멘트는 포인트 지급/차감하지 않는다
- 좋아요 포인트는 `int_10`에 기록하지 않는다 (글 생성 포인트를 덮어쓰는 문제 방지)

### v6 소스코드 파일 참조

| 파일 | 설명 |
|------|------|
| `lib/point.functions.php` (812줄) | 모든 포인트 함수 (생성, 삭제, 로그, 광고 등) |
| `etc/app.config.php` (348-536줄) | PointConfig 클래스 및 포인트 설정 전체 |
| `lib/constants.php` | 포인트 관련 상수 (POINT_WRITE, POINT_COMMENT 등) |
| `lib/post/post.create.functions.php` | 글 생성 시 포인트 지급 호출 |
| `lib/post/post.delete.functions.php` | 글 삭제 시 포인트 차감 호출 |
| `lib/post/comment.create.functions.php` | 코멘트 생성 시 포인트 지급 호출 |
| `lib/post/comment.delete.functions.php` | 코멘트 삭제 시 포인트 차감 호출 |
| `lib/functions.php` (564-589줄) | update_like() 좋아요 처리 |
| `lib/moderate/moderation-v2.functions.php` (256-267줄) | AI 검열 점수 (필리핀 관련도) |

---

## 2. 포인트 개념 및 용어

| 용어 | 설명 |
|------|------|
| `point_write` | 글 작성 시 지급할 포인트 (양수) |
| `point_comment` | 코멘트 작성 시 지급할 포인트 (양수) |
| `point_write_delete` | 글 삭제 시 차감할 포인트 (음수) |
| `point_comment_delete` | 코멘트 삭제 시 차감할 포인트 (음수) |
| `point_for_like` | 좋아요 1회당 포인트 (고정값 3점) |
| `int_10` | 글/코멘트에 실제 지급된 포인트 (sf_post_data.int_10) |
| `earned_point` | PostEntity.toArray()에서 int_10의 별칭 |
| `int_5` | 포인트 광고 종료 시간 (Unix timestamp) |
| `int_6` | 포인트 광고 시작/연장 시간 |
| `int_7` | 포인트 광고 기간 (일 단위) |
| `int_8` | 이번 광고에 사용한 포인트 |

---

## 3. 포인트 테이블 구조

### sf_point_log (포인트 변경 이력)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | int(AUTO_INCREMENT) | PK |
| `idx_member_from` | int | 포인트를 변경한 회원 ID |
| `idx_member_to` | int | 포인트를 받은 회원 ID |
| `point_before` | int | 변경 전 포인트 |
| `point` | int | 변경 포인트 (양수=증가, 음수=감소) |
| `point_after` | int | 변경 후 포인트 |
| `module` | varchar | 모듈명 (post, comment, vote, admin, adv, event, point_event) |
| `action` | varchar | 액션명 (create, delete, like, unlike, update, point-post-advertisement, spin 등) |
| `idx_post` | int | 관련 글/코멘트 idx (0이면 해당 없음) |
| `etc` | varchar | 기타 정보 (point_write, point_event_write, point_comment, point_event_comment, like, post_on_top, admin-point-update 등) |
| `stamp` | int | Unix timestamp |
| `ip` | char(15) | 사용자 IP (현재는 비워둠 - IPv6 호환성 이슈) |

### sf_post_vote_history (좋아요 이력 - v7에서 DB 기반으로 전환)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx_post` | int | 글/코멘트 idx |
| `idx_member` | int | 좋아요한 회원 idx |
| `webbrowser_id` | varchar(32) | 브라우저 ID |
| `code` | char(1) | 'G'=좋아요 |
| `ip` | char(15) | IP 주소 |

### sf_post_config (게시판 설정)

포인트 관련 컬럼:
- `point_write` int(11) — 글 작성 포인트 (기본: 0)
- `point_comment` int(11) — 코멘트 작성 포인트 (기본: 0)
- `point_write_delete` int(11) — 글 삭제 포인트 (음수, 기본: 0)
- `point_comment_delete` int(11) — 코멘트 삭제 포인트 (음수, 기본: 0)

### sf_member (사용자)

- `point` int(11) — 사용자 보유 포인트 (최소 0, 음수 불가)

### sf_post_data (글/코멘트)

- `good` int — 좋아요 개수
- `int_5` int — 포인트 광고 종료 시간 (Unix timestamp)
- `int_6` int — 포인트 광고 시작/연장 시간
- `int_7` int — 포인트 광고 기간 (일)
- `int_8` int — 이번 광고에 사용한 포인트
- `int_10` int — 글/코멘트 작성 시 획득한 포인트

---

## 4. 게시판 포인트 설정

각 게시판(post_id)별로 sf_post_config에서 포인트를 설정한다.

```sql
-- 예: temp 게시판에 글 88점, 코멘트 33점 설정
UPDATE sf_post_config SET
  point_write = 88,
  point_comment = 33,
  point_write_delete = -88,
  point_comment_delete = -33
WHERE post_id = 'temp';
```

### 관리자 설정 페이지

v6에서는 `/admin/post/config.php?post_id=wanted` 페이지에서 게시판별 포인트를 설정한다.

설정 필드:
- `point_write`: 글 작성 시 포인트 (기본: 0)
- `point_comment`: 코멘트 작성 시 포인트 (기본: 0)
- `point_write_delete`: 글 삭제 시 포인트 (음수: 차감, 기본: 0)
- `point_comment_delete`: 코멘트 삭제 시 포인트 (음수: 차감, 기본: 0)

### 게시판별 설정 예시

| 게시판 | point_write | point_comment | point_write_delete | point_comment_delete |
|--------|-------------|---------------|--------------------|--------------------|
| freetalk (자유게시판) | 5 | 2 | -2 | 0 |
| wanted (구인구직) | 10 | 3 | -5 | 0 |
| qna (Q&A) | 5 | 2 | -2 | 0 |
| temp (테스트) | 88 | 33 | -88 | -33 |

---

## 5. 포인트 변경 핵심 로직

`PointLogService::changePoints()` — 모든 포인트 변경의 단일 진입점.

```
1. idx_member_to의 현재 포인트 조회 (sf_member.point)
2. 새 포인트 = 현재 포인트 + 변경 포인트
3. 새 포인트 < 0이면 → 0으로 보정
4. sf_member.point 업데이트
5. sf_point_log에 이력 기록 (point_before, point, point_after)
6. PointLogEntity 반환
```

### v6 원본 로직 (change_user_points)

```php
// lib/point.functions.php 라인 392-456
function change_user_points(
    int $points,
    array $login_user,
    string $module,
    string $action,
    int $idx_post = 0,
    string $etc = '',
    int $idx_member_to = 0,
): array {
    if ($points == 0) return [];

    $new_points = $login_user[POINT] + $points;
    if ($new_points < 0) {
        $new_points = 0;  // 음수 방지
    }

    // sf_member 업데이트
    db_update(MEMBER_TABLE, ['point' => $new_points], "idx = :idx", [':idx' => $login_user[IDX]]);

    // sf_point_log 기록
    $data = [
        MODULE => $module,
        ACTION => $action,
        IDX_POST => $idx_post ?? 0,
        STAMP => time(),
        ETC => $etc,
        IDX_MEMBER_FROM => $login_user[IDX],
        IDX_MEMBER_TO => $idx_member_to,
        POINT_BEFORE => $login_user[POINT],
        POINT => $points,
        POINT_AFTER => $new_points,
        'ip' => '',
    ];
    $data[IDX] = db_insert("sf_point_log", $data);
    return $data;
}
```

### v7 사용 예시

```php
use Philgo\PointLog\PointLogService;

$log = PointLogService::changePoints(
    points: 88,
    idxMemberFrom: $memberIdx,
    idxMemberTo: $memberIdx,
    module: 'post',
    action: 'create',
    idxPost: $postIdx,
    etc: 'point_write'
);
```

---

## 6. 글 생성/삭제 시 포인트 처리

### 글 생성 전체 흐름 (v6)

```
create_post_from_user_input()
├─ 사용자 검증 (로그인, 탈퇴, 차단)
├─ 게시판 설정 로드
├─ 글 쓰기 대기 시간 확인
├─ 포인트 충분도 확인 (음수 포인트인 경우)
├─ create_post() → DB 저장
├─ moderate_post() → AI 검열 (필리핀 관련도 점수 포함)
├─ is_blocked_post() 확인
└─ increase_user_points_for_post_create() → 포인트 지급
```

### 글 생성 시 (PostService::create)

```
PostService::create()
  → increasePointsForCreate($post, $member)
    → 검열/블라인드 체크 → 해당하면 skip
    → PostRepository::getPostConfig($postId) → point_write 조회
    → getEventPoints() 호출 → 이벤트 기간이면 랜덤 포인트와 비교하여 더 큰 값 사용
    → changeUserPoints() → PointLogService::changePoints() 위임
    → int_10에 실제 지급 포인트 저장
```

### v6 원본 코드 (increase_user_points_for_post_create)

```php
// lib/point.functions.php 라인 141-172
function increase_user_points_for_post_create(array $post, array $config, array $login_user): void
{
    // 검열/블라인드 확인
    if (is_blocked_post($post) || is_blinded_post($post)) return;

    // 이벤트 포인트 계산 (기본값 또는 랜덤)
    $points = get_event_points(config: $config, post: $post);

    // 이벤트 포인트인지 판별: 반환된 포인트가 설정 기본 포인트보다 크면 이벤트 포인트
    $config_points = $config[POINT_WRITE] ?? 0;
    $pointEtc = ($points > $config_points && $config_points > 0) ? 'point_event_write' : POINT_WRITE;

    // 포인트 적용
    $re = change_user_points(
        points: $points,
        login_user: $login_user,
        module: MODULE_POST,     // 'post'
        action: ACTION_CREATE,   // 'create'
        idx_post: $post[IDX],
        etc: $pointEtc,          // 'point_write' 또는 'point_event_write'
        idx_member_to: $post[IDX_MEMBER]
    );

    // int_10에 실제 지급된 포인트 기록
    if (isset($re[POINT_BEFORE]) && isset($re[POINT_AFTER])) {
        $actual_points = $re[POINT_AFTER] - $re[POINT_BEFORE];
        if ($actual_points != 0) {
            update_post([IDX => $post[IDX], 'int_10' => $actual_points]);
        }
    }
}
```

module/action/etc 값:
| 필드 | 값 |
|------|-----|
| module | `post` |
| action | `create` |
| etc | `point_write` (일반) 또는 `point_event_write` (이벤트 포인트) |

### 이벤트 포인트 etc 값 구분 (v7 신규)

글/코멘트 생성 시 포인트가 이벤트 포인트인지 판별하여 `etc` 값을 다르게 저장한다.

**판별 기준**: `get_event_points()` 반환값 > 게시판 설정 기본 포인트(`point_write` 또는 `point_comment`)이면 이벤트 포인트로 판정한다.

```php
// v6 (lib/point.functions.php)
$config_points = $config[POINT_WRITE] ?? 0;
$pointEtc = ($points > $config_points && $config_points > 0) ? 'point_event_write' : POINT_WRITE;

// v7 (PostService.php)
$configPoints = (int) ($config['point_write'] ?? 0);
$pointEtc = ($points > $configPoints && $configPoints > 0) ? 'point_event_write' : 'point_write';
```

| 상황 | etc 값 |
|------|--------|
| 일반 글 작성 포인트 | `point_write` |
| 이벤트 글 작성 포인트 (랜덤 포인트 > 기본 포인트) | `point_event_write` |
| 일반 코멘트 작성 포인트 | `point_comment` |
| 이벤트 코멘트 작성 포인트 (랜덤 포인트 > 기본 포인트) | `point_event_comment` |

> **참고**: 이 구분은 포인트 내역 페이지에서 일반 포인트와 이벤트 포인트를 시각적으로 구별하기 위해 도입되었다.

### 글 삭제 시 (PostService::delete)

```
PostService::delete()
  → decreasePointsForDelete($post, $member)
    → 검열/블라인드 체크 → 해당하면 skip
    → int_10이 0이 아니면 → int_10 * -1 포인트 차감 (이벤트 포인트 전액 회수)
    → int_10이 0이면 → PostRepository::getPostConfig() → point_write_delete 조회
    → changeUserPoints()
```

**핵심**: v7에서는 삭제 시 `int_10`에 저장된 실제 지급 포인트를 기반으로 전액 회수한다.
이벤트로 1500점을 받았으면 삭제 시 -1500점이 차감된다.

### v6 원본 코드 (decrease_user_points_for_post_delete)

```php
// lib/point.functions.php 라인 285-314
function decrease_user_points_for_post_delete(array $post, array $config, array $login_user): void
{
    if (is_blocked_or_blinded_post($post)) return;

    // v6에서는 게시판 설정의 point_write_delete 사용
    $points = $config[POINT_WRITE_DELETE] ?? 0;

    $re = change_user_points(
        points: $points,              // 음수값으로 차감
        login_user: $login_user,
        module: MODULE_POST,
        action: ACTION_DELETE,
        idx_post: $post[IDX],
        etc: POINT_WRITE_DELETE,
        idx_member_to: $post[IDX_MEMBER]
    );
}
```

**v7 개선점**: v6는 `point_write_delete` 설정값만 사용하지만, v7은 `int_10` 기반으로 실제 지급 포인트를 전액 회수한다. 이벤트 포인트가 큰 경우에도 정확한 회수가 가능하다.

module/action/etc 값:
| 필드 | 값 |
|------|-----|
| module | `post` |
| action | `delete` |
| etc | `point_write_delete` |

---

## 7. 코멘트 생성/삭제 시 포인트 처리

### 코멘트 생성 시 — 24시간 제한

v6의 `increase_user_points_for_comment_create()` 로직:
1. 코멘트가 검열/블라인드 되었으면 포인트 미지급
2. **원글(parent post)의 작성 시간(stamp)이 현재로부터 24시간(PointConfig::$comment_point_available_hours = 25) 이내인 경우에만 포인트 지급**
3. 그 외는 일반 글 생성과 동일

### v6 원본 코드 (get_event_points 내 24시간 체크)

```php
// lib/point.functions.php 라인 70-124
function get_event_points(array $config, array $post, array $comment = [], bool $is_comment = false): int
{
    $config_points = $is_comment ? ($config[POINT_COMMENT] ?? 0) : ($config[POINT_WRITE] ?? 0);

    // 코멘트 24시간 제한 핵심 로직
    if ($is_comment) {
        if (created_in_hours($post[STAMP], PointConfig::$comment_point_available_hours) == false) {
            return 0; // 25시간 넘으면 포인트 미지급
        }
    }

    // 쓰로틀링, 이벤트 포인트 등 계속...
}
```

### v6 원본 코드 (increase_user_points_for_comment_create)

```php
// lib/point.functions.php 라인 190-223
function increase_user_points_for_comment_create(array $comment, array $post, array $config, array $login_user): void
{
    if (is_blocked_or_blinded_post($comment)) return;

    $points = get_event_points(config: $config, post: $post, comment: $comment, is_comment: true);

    // 이벤트 포인트인지 판별: 반환된 포인트가 설정 기본 포인트보다 크면 이벤트 포인트
    $config_points = $config[POINT_COMMENT] ?? 0;
    $pointEtc = ($points > $config_points && $config_points > 0) ? 'point_event_comment' : POINT_COMMENT;

    $re = change_user_points(
        points: $points,
        login_user: $login_user,
        module: MODULE_COMMENT,    // 'comment'
        action: ACTION_CREATE,     // 'create'
        idx_post: $comment[IDX],
        etc: $pointEtc,            // 'point_comment' 또는 'point_event_comment'
        idx_member_to: $comment[IDX_MEMBER]
    );

    // int_10에 실제 지급 포인트 기록
    if (isset($re[POINT_BEFORE]) && isset($re[POINT_AFTER])) {
        $actual_points = $re[POINT_AFTER] - $re[POINT_BEFORE];
        if ($actual_points != 0) {
            update_post([IDX => $comment[IDX], 'int_10' => $actual_points]);
        }
    }
}
```

### v7 구현

```php
// PostService::increasePointsForCommentCreate()
private static function increasePointsForCommentCreate(PostEntity $comment, array $member): void
{
    // 원글 조회
    $parentPost = PostRepository::findByIdx($comment->idx_root);
    if ($parentPost === null) return;

    // 24시간 이내 작성된 원글에만 포인트 지급
    if (!self::isCreatedWithinHours($parentPost->stamp, 24)) {
        return;
    }
    // ... 이하 포인트 지급 로직
}
```

module/action/etc 값:
| 작업 | module | action | etc |
|------|--------|--------|-----|
| 코멘트 생성 (일반) | `comment` | `create` | `point_comment` |
| 코멘트 생성 (이벤트) | `comment` | `create` | `point_event_comment` |
| 코멘트 삭제 | `comment` | `delete` | `point_comment_delete` |

> **이벤트 포인트 판별**: `get_event_points()` 반환값 > `point_comment` 설정값이면 `point_event_comment`, 아니면 `point_comment`

---

## 8. 좋아요/좋아요 해제 시 포인트 처리

### 좋아요 포인트 규칙

- 포인트: **3점 고정** (PointConfig::$point_for_like = 3)
- 조건: 글/코멘트가 **작성 후 24시간 이내**인 경우에만 적용
- 좋아요 시: 포인트 +3
- 좋아요 해제 시: 포인트 -3
- 좋아요 이력: `sf_post_vote_history` 테이블에 기록 (v7에서 DB 기반으로 전환)
- 좋아요 포인트는 `int_10`에 기록하지 않는다 (글 생성 포인트를 덮어쓰는 문제 방지)

### v6 원본 코드 (increase_user_points_for_like)

```php
// lib/point.functions.php 라인 234-271
function increase_user_points_for_like(int $idx_post, array $login_user): void
{
    $points = PointConfig::$point_for_like ?? 0;  // 기본값: 3포인트
    if ($points <= 0) return;

    // 24시간 이내 글/코멘트인 경우만 포인트 증가
    $post = get_raw_post($idx_post, 'idx, stamp, post_id');
    if (!$post) return;
    if (created_in_hours($post['stamp'], PointConfig::$comment_point_available_hours) == false) {
        return;  // 24시간 넘으면 포인트 없음
    }

    change_user_points(
        points: $points,
        login_user: $login_user,
        module: 'vote',
        action: 'like',
        idx_post: $idx_post,
        etc: 'like',
        idx_member_to: $login_user[IDX]
    );

    // 주의: int_10 필드에 기록 안 함 (2025.11.02 이후)
    // 이유: 글 생성 포인트를 좋아요 포인트가 덮어쓸 수 있기 때문
}
```

### v6 좋아요 처리 흐름

```php
// lib/functions.php 라인 564-589
function update_like()
    ├─ 이미 좋아요 했는지 확인
    └─ 새 좋아요 추가
       ├─ sf_like 테이블에 기록
       ├─ sf_post_data good 필드 +1
       └─ increase_user_points_for_like()
```

### v7 개선점

v6에서는 좋아요 취소가 불가능했다. v7에서는:
- **좋아요 해제(unlike) 지원** → 포인트도 함께 차감 (-3점)
- **DB 기반 중복 방지** (sf_post_vote_history 테이블)
- 쿠키 기반에서 DB 기반으로 전환

### v7 좋아요/해제 구현

```php
// PostService::like() — 좋아요 + 포인트
// PostService::unlike() — 좋아요 해제 + 포인트 차감
```

module/action/etc 값:
| 작업 | module | action | etc |
|------|--------|--------|-----|
| 좋아요 | `vote` | `like` | `like` |
| 좋아요 해제 | `vote` | `unlike` | `unlike` |

---

## 9. 포인트 이벤트 (랜덤 포인트)

### 개념

특정 기간(포인트 이벤트 기간)에 지정된 게시판에 글/코멘트를 작성하면 랜덤 포인트를 지급한다.
랜덤 포인트가 설정된 게시판 포인트(point_write/point_comment)보다 크면 랜덤 포인트를 사용하고, 아니면 설정 포인트를 사용한다.

### 이벤트 기간 관리 (DB 기반 — v7 신규)

v7에서는 이벤트 기간을 **DB(sf_config 테이블)** 기반으로 관리한다.
v6의 `PointConfig::$point_event_dates` 하드코딩 방식에서 DB 동적 관리로 전환되었다.

| 항목 | v6 (레거시) | v7 (신규) |
|------|------------|-----------|
| **이벤트 기간 저장** | `PointConfig::$point_event_dates` PHP 배열 하드코딩 | `sf_config` 테이블에 JSON으로 저장 (키: `point_event_dates`) |
| **이벤트 기간 판별** | `PointConfig::inEventDate()` | `SettingsService::isInPointEventDate()` |
| **관리 방법** | 소스 코드 직접 수정 | 관리자 페이지(`/admin/point-event`)에서 추가/삭제 |
| **데이터 형식** | `[[20260107, 20260111], ...]` (인덱스 기반 배열) | `[{"start": 20260107, "end": 20260111}, ...]` (키-값 객체 배열) |

#### SettingsService 이벤트 기간 메서드

| 메서드 | 설명 |
|--------|------|
| `getPointEventDates(): array` | DB에서 JSON 이벤트 기간 목록 조회 |
| `addPointEventDate(int $start, int $end): void` | 이벤트 기간 추가 (start 기준 오름차순 자동 정렬) |
| `deletePointEventDate(int $index): void` | 이벤트 기간 삭제 (인덱스 기반) |
| `isInPointEventDate(?int $Ymd = null): bool` | 오늘(또는 지정 날짜)이 이벤트 기간인지 DB 기반 판별 |

설정 키 상수: `SettingsService::KEY_POINT_EVENT_DATES = 'point_event_dates'`

> 설정 키 상세 → [api/v7-settings.md](api/v7-settings.md) 참조

#### 이벤트 기간 판별 호출 체인

```
Config::isPointEventDate()          ← v7 웹 홈페이지에서 호출 (요청 단위 캐싱)
  → SettingsService::isInPointEventDate()  ← DB에서 이벤트 기간 목록 조회

PostService::isInEventPeriod()      ← 글/코멘트 생성 시 호출
  → SettingsService::isInPointEventDate()  ← DB에서 이벤트 기간 목록 조회
```

#### PostService::getEventPostIdsPublic()

이벤트 대상 게시판 ID 목록을 외부에서 조회할 수 있도록 공개하는 public 메서드이다.
관리자 페이지(`/admin/point-event`)에서 설정 정보 표시용으로 사용한다.

```php
public static function getEventPostIdsPublic(): array
{
    return self::EVENT_POST_IDS;  // ['freetalk', 'qna']
}
```

#### Config.php 요청 단위 캐싱

`Config::isPointEventDate()`는 같은 요청 내에서 중복 DB 조회를 방지하기 위해 static 변수로 캐싱한다.

```php
// v7/utils/Config.php
private static ?bool $cachedIsPointEventDate = null;

public static function isPointEventDate(?int $Ymd = null): bool
{
    // 특정 날짜 지정 시 캐시 미사용
    if ($Ymd !== null) {
        return SettingsService::isInPointEventDate($Ymd);
    }
    // 오늘 날짜 판별: 요청 단위 캐시
    if (self::$cachedIsPointEventDate === null) {
        self::$cachedIsPointEventDate = SettingsService::isInPointEventDate();
    }
    return self::$cachedIsPointEventDate;
}

// 테스트용 캐시 초기화
public static function resetPointEventDateCache(): void
{
    self::$cachedIsPointEventDate = null;
}
```

#### 관리자 페이지

이벤트 기간을 관리하는 전용 관리자 페이지가 제공된다.

| 항목 | 설명 |
|------|------|
| **URL** | `/admin/point-event` |
| **파일** | `v7/admin/point-event.php` |
| **CSS** | `v7/admin/point-event.css` |
| **기능** | 이벤트 기간 추가/삭제, 현재 이벤트 상태 표시, 이벤트 설정 정보(읽기 전용) 표시 |
| **데이터 소스** | `SettingsService::getPointEventDates()`, `SettingsService::isInPointEventDate()`, `PostService::getEventPostIdsPublic()` |
| **메뉴 위치** | `admin-nav.php` → `'/admin/point-event' => ['label' => '포인트이벤트', 'icon' => 'fa-solid fa-calendar-star']` |

> 관리자 페이지 상세 → [web/v7-admin.md](web/v7-admin.md) 20장 참조

### PointConfig 이벤트 설정 (v6 etc/app.config.php — 레거시 참고용)

```php
// v6 이벤트 기간 설정 (YYYYMMDD 형식) — 현재는 DB 기반으로 전환됨
public static $point_event_dates = [
    [20260107, 20260111],  // 1/7(수) ~ 1/11(일)
    [20260210, 20260220],  // 설날
    [20260301, 20260311],  // 3.1절
    // ... 매주 금-토-일 (2026년 전체)
];

// 이벤트 대상 게시판
public static $event_post_ids = ['freetalk', 'qna'];

// 최소 이벤트 점수
public static $min_event_score = 5;

// v6 이벤트 기간 판별 함수 — v7에서는 SettingsService::isInPointEventDate() 사용
public static function inEventDate(?int $Ymd = null): bool
{
    $today = $Ymd ?? (int)date('Ymd');
    foreach (self::$point_event_dates as $range) {
        if ($today >= $range[0] && $today <= $range[1]) return true;
    }
    return false;
}
```

### v6 로직 (get_event_points) — 전체 코드

```php
// lib/point.functions.php 라인 70-124
function get_event_points(array $config, array $post, array $comment = [], bool $is_comment = false): int
{
    // [1단계] 기본 포인트 가져오기
    $config_points = $is_comment ? ($config[POINT_COMMENT] ?? 0) : ($config[POINT_WRITE] ?? 0);

    // [2단계] 코멘트 24시간 제한 확인
    if ($is_comment) {
        if (created_in_hours($post[STAMP], PointConfig::$comment_point_available_hours) == false) {
            return 0;  // 25시간 넘으면 0점
        }
    }

    // [3단계] 쓰로틀링 (남용 방지) 확인
    if (PointConfig::$event_throttling_minutes > 0) {
        $count = get_point_history_count_within(minutes: PointConfig::$event_throttling_minutes);
        if ($count >= PointConfig::$event_throttling_count) {
            return PointConfig::$event_throttling_points;  // 8포인트만 반환
        }
    }

    // [4단계] 포인트 이벤트 기간 및 게시판 확인
    $post_arr = $is_comment ? $comment : $post;
    $random_points = 0;
    $score = 0;

    if (PointConfig::inEventDate()) {
        if (in_array($post_arr[POST_ID], PointConfig::$event_post_ids)) {
            $score = get_info_score($post_arr);  // AI 필리핀 관련도 점수 (0~100)
            $random_points = randomize_event_point($score);
        }
    }

    // [5단계] 최종 포인트 결정 (랜덤 vs 기본)
    if ($random_points > $config_points) {
        return $random_points;
    }
    return $config_points;
}
```

### 랜덤 포인트 배율 설정 (v6 PointConfig)

```php
// etc/app.config.php 라인 495-516
public static $point_multiplier_tiers = [
    ['probability' => 50,  'multiplier' => 3],     // 0~50%: 3배
    ['probability' => 90,  'multiplier' => 10],    // 50~90%: 10배
    ['probability' => 95,  'multiplier' => 20],    // 90~95%: 20배
    ['probability' => 99,  'multiplier' => 40],    // 95~99%: 40배 (v7에서는 30배→40배로 변경)
    ['probability' => 100, 'multiplier' => 200],   // 99~100%: 200배
];
```

### 랜덤 포인트 계산 (randomize_event_point) — 전체 코드

```php
// lib/point.functions.php 라인 573-600
function randomize_event_point(int $score): int
{
    // 최소 점수 설정
    if ($score < PointConfig::$min_event_score) {
        $score = PointConfig::$min_event_score;  // 0점 → 5점으로 조정
    }

    // 1~100 사이의 랜덤 확률
    $rand = rand(1, 100);

    // 확률에 따른 배율 선택
    $multiplier = 1;
    foreach (PointConfig::$point_multiplier_tiers as $tier) {
        if ($rand <= $tier['probability']) {
            $multiplier = $tier['multiplier'];
            break;
        }
    }

    // 최종 포인트 = 점수 × 배율
    return $score * $multiplier;
}
```

### 계산 예시

| score | rand | 확률 구간 | 배율 | 최종 포인트 |
|-------|------|----------|------|-----------|
| 70 | 45 | 0~50% | 3배 | 210 |
| 70 | 75 | 50~90% | 10배 | 700 |
| 70 | 92 | 90~95% | 20배 | 1,400 |
| 70 | 98 | 95~99% | 40배 | 2,800 |
| 70 | 100 | 99~100% | 200배 | 14,000 |
| 5 (최소) | 100 | 99~100% | 200배 | 1,000 |

### AI 검열 점수 (필리핀 관련도)

```php
// lib/moderate/moderation-v2.functions.php 라인 256-267
function get_info_score($post): int
{
    if (isset($post[MODERATION_RESULTS]['info_score'])) {
        $score = $post[MODERATION_RESULTS]['info_score'];
        if ($score >= 0 && $score <= 100) return $score;
    }
    return 0;
}
```

v7에서는 AI 검열 점수 대신 기본 점수(min_event_score = 5)를 사용한다.

### 삭제 시 이벤트 포인트 회수

글/코멘트 삭제 시 `int_10`에 저장된 실제 지급 포인트를 전액 회수한다.
- int_10 ≠ 0이면 → `int_10 * -1` 포인트 차감
- int_10 = 0이면 → 게시판 설정의 `point_write_delete` / `point_comment_delete` 사용

```php
// 예: 이벤트로 1500점 받은 글 삭제 시
$post->int_10 = 1500;
// → -1500 포인트 차감 (전액 회수)
```

### DB 기반 이벤트 기간 관리 (v7 신규)

v6에서는 `PointConfig::$point_event_dates` 하드코딩 배열로 이벤트 기간을 관리했지만,
v7에서는 **DB(`sf_config` 테이블) 기반**으로 이벤트 기간을 동적 관리한다.

#### 아키텍처

```
PostService::isInEventPeriod()
  ├─ 테스트 오버라이드 ($forceEventPeriod) 확인
  └─ SettingsService::isInPointEventDate() 호출
       └─ sf_config 테이블에서 'point_event_dates' 키 조회
            └─ JSON 배열 파싱 → 오늘 날짜 포함 여부 판별

Config::isPointEventDate()
  ├─ 특정 날짜 지정 시 → SettingsService::isInPointEventDate($Ymd) 직접 호출 (캐시 미사용)
  └─ 오늘 날짜 판별 시 → 요청 단위 static 캐싱 ($cachedIsPointEventDate)
```

#### 핵심 클래스/메서드

| 클래스 | 메서드 | 설명 |
|--------|--------|------|
| `SettingsService` | `getPointEventDates()` | DB에서 이벤트 기간 목록 조회 (JSON 배열 → `array<{start, end}>`) |
| `SettingsService` | `addPointEventDate($start, $end)` | 이벤트 기간 추가 (start 기준 오름차순 자동 정렬) |
| `SettingsService` | `deletePointEventDate($index)` | 이벤트 기간 삭제 (인덱스 기반) |
| `SettingsService` | `isInPointEventDate($Ymd)` | 지정 날짜가 이벤트 기간인지 판별 |
| `Config` | `isPointEventDate($Ymd)` | `SettingsService` 위임 + 요청 단위 캐싱 |
| `Config` | `resetPointEventDateCache()` | 이벤트 기간 캐시 초기화 (테스트용) |
| `PostService` | `isInEventPeriod()` | `SettingsService::isInPointEventDate()` 호출 (테스트 오버라이드 지원) |
| `PostService` | `getEventPostIdsPublic()` | 이벤트 대상 게시판 ID 목록 외부 공개 (관리자 페이지용) |

#### DB 저장 구조

`sf_config` 테이블에 키 `point_event_dates`로 JSON 배열 저장:

```json
[
  {"start": 20260107, "end": 20260111},
  {"start": 20260210, "end": 20260220},
  {"start": 20260301, "end": 20260311}
]
```

- 날짜는 `YYYYMMDD` 정수 형식
- 추가 시 `start` 기준 오름차순 자동 정렬
- 42개 이벤트 기간 데이터가 마이그레이션 완료됨

#### 관리자 페이지

| 파일 | URL | 설명 |
|------|-----|------|
| `v7/admin/point-event.php` | `/admin/point-event` | 이벤트 기간 추가/삭제 관리 UI |

관리자 페이지 기능:
- 현재 이벤트 상태 표시 (진행중/비이벤트)
- 이벤트 기간 추가 (`<input type="date">` 폼)
- 이벤트 기간 목록 (상태: 진행중/예정/종료)
- 이벤트 기간 삭제
- 이벤트 설정 정보 표시 (대상 게시판, 쓰로틀링, 배수 티어 등)

#### 도움말 페이지

| 파일 | URL | 설명 |
|------|-----|------|
| `v7/help/point-event.php` | `/help/point-event` | DB 기반 이벤트 날짜 표시 (사용자용) |

- `SettingsService::getPointEventDates()`로 DB에서 직접 조회
- 오늘 이후(진행 중 + 미래) 이벤트만 표시
- 현재 이벤트 상태 안내 (`Config::isPointEventDate()`)

#### v6 → v7 대응

| v6 | v7 |
|----|----|
| `PointConfig::$point_event_dates` (하드코딩) | `sf_config.point_event_dates` (DB 저장) |
| `PointConfig::inEventDate()` | `SettingsService::isInPointEventDate()` |
| 코드 수정으로만 기간 변경 가능 | 관리자 웹 UI로 실시간 변경 가능 |

### v7 이벤트 설정 (테스트용)

```php
// 이벤트 기간 강제 설정 (테스트 오버라이드)
PostService::setEventPeriod(true);

// 이벤트 대상 게시판 설정
PostService::setEventPostIds(['temp', 'freetalk']);

// 이벤트 설정 초기화 (DB 조회 모드로 복귀)
PostService::resetEventSettings();

// Config 캐시 초기화 (테스트에서 DB 변경 후 필요)
\V7\Utils\Config::resetPointEventDateCache();
```

### 유닛 테스트

`tests/Unit/PostControllerTest.php`에 포인트 이벤트 관련 테스트가 포함되어 있다.

| 테스트 그룹 | 테스트 수 | 설명 |
|------------|----------|------|
| 이벤트 포인트 (기존) | 7개 | 이벤트/비이벤트 기간 포인트, etc 값 구분, 쓰로틀링 등 |
| DB 기반 포인트 이벤트 | 5개 | DB 이벤트 기간 판별, 랜덤 포인트 적용, 글/코멘트 전액 회수, 랜덤성 검증 |

DB 기반 포인트 이벤트 테스트 목록:

1. **DB에 이벤트 기간이 설정되면 isInEventPeriod()가 DB를 조회한다** — `SettingsService::addPointEventDate()`로 오늘 날짜 추가 후 `PostService::isInEventPeriod()` 확인
2. **자유게시판(freetalk)에서 이벤트 기간 시 랜덤 포인트가 적용된다** — freetalk point_write=5 이상 포인트 지급, etc 값 `point_event_write` 확인
3. **이벤트 포인트 글 삭제 시 전액 회수된다** — int_10 기반 전액 회수, 원래 포인트 복귀
4. **이벤트 기간 코멘트 생성 시 랜덤 포인트가 적용되고 삭제 시 전액 회수된다** — 코멘트 이벤트 포인트 및 etc 값 `point_event_comment` 확인, 삭제 전액 회수
5. **이벤트 포인트는 랜덤으로 생성되어 매번 다를 수 있다** — `randomizeEventPoint()` 50회 호출, 최소 2가지 다른 값 확인

---

## 10. 포인트 남용 방지

### v6 PointConfig 설정

```php
public static $event_throttling_minutes = 10;  // 최근 10분 이내
public static $event_throttling_count = 3;     // 3회 이상 포인트를 받았으면
public static $event_throttling_points = 8;    // 기본 8점만 지급
```

### v6 원본 코드 (get_point_history_count_within)

```php
// lib/point.functions.php 라인 792-811
function get_point_history_count_within(int $minutes, string $action = 'create'): int
{
    if (!login() || !login()->idx) return 0;

    $start_time = time() - ($minutes * 60);
    $idx_login_user = login()->idx;

    $q = "SELECT COUNT(*) AS total FROM sf_point_log
          WHERE idx_member_to = $idx_login_user
            AND stamp > $start_time
            AND action = '$action'
          LIMIT 1";

    $re = db_select_row($q, []);
    return (int) ($re['total'] ?? 0);
}
```

### v7 구현

```php
if (PointConfig::$event_throttling_minutes > 0) {
    $count = PointLogService::getRecentActionCount($idxMember, 10, 'create');
    if ($count >= 3) {
        return 8; // 기본 포인트만 지급
    }
}
```

### 쓰로틀링 예시

```
시간대:
- 10:00 글 작성 → 50포인트 (이벤트 포인트)
- 10:03 코멘트 → 200포인트 (이벤트 포인트)
- 10:05 글 작성 → 100포인트 (이벤트 포인트)
- 10:07 코멘트 작성 → 8포인트 (쓰로틀링 적용, 10분 내 3회 초과)
```

---

## 11. 포인트 광고 시스템

### 개념

사용자의 포인트를 사용하여 자신의 글을 게시판 목록 상단에 고정 노출하는 기능.
v6의 `advertise_point_post()` 함수와 100% 동일한 로직을 v7 아키텍처(Controller + Service + Repository)로 구현.

### DB 필드 매핑 (sf_post_data)

| 필드 | 타입 | 설명 |
|------|------|------|
| `int_5` | INT | 광고 종료 Unix timestamp — **핵심 필드** (`int_5 > time()` = 활성) |
| `int_6` | INT | 마지막 광고 등록/연장 시간 |
| `int_7` | INT | 마지막 등록 기간 (일) |
| `int_8` | INT | 마지막 등록에 소비한 포인트 |

### 광고 비용

```php
// PostService 상수
private const POINT_ADV_COST_PER_HOUR = 240;  // 시간당 240포인트
```

| 광고 기간 | 필요 포인트 (240 × 24 × days) |
|----------|-------------------------------|
| 3일 | 17,280 |
| 5일 | 28,800 |
| 7일 | 40,320 |
| 10일 | 57,600 |
| 15일 | 86,400 |
| 30일 | 172,800 |
| 90일 | 518,400 |
| 365일 | 2,102,400 |

### 광고 허용 게시판 (24개)

```php
// PostService 상수
private const POINT_ADV_CATEGORIES = [
    'boarding_house', 'business', 'buyandsell', 'massage', 'promotion',
    'real_estate', 'rest', 'study', 'travel', 'wanted', 'blog',
    '가전/생활용품', '개인장터', '골프', '렌트카', '주택임대', '중고차',
    '여권/비자', '이민', '컴퓨터/인터넷', '페소환전', '핸드폰', '호텔', 'temp'
];
```

제외: `freetalk`(자유게시판), `qna`(질문답변)

### 기간 옵션

```php
private const POINT_ADV_DAYS = [3, 5, 7, 10, 15, 30, 60, 90, 180, 365];
```

### v7 백엔드 구현

#### 소스코드 파일

| 파일 | 클래스/메서드 | 설명 |
|------|-------------|------|
| `lib/post/PostController.php` | `advertisementConfig()` | 광고 설정 조회 API |
| `lib/post/PostController.php` | `advertise()` | 광고 등록/연장 API |
| `lib/post/PostService.php` | `getAdvertisementConfig()` | 적격 여부 + 기간별 비용 반환 |
| `lib/post/PostService.php` | `advertise()` | 등록/연장 핵심 로직 |
| `lib/post/PostService.php` | `listPointAdvertisements()` | 활성 광고 목록 조회 |
| `lib/post/PostRepository.php` | `findPointAdvertisements()` | DB 쿼리 (USE INDEX) |

#### 핵심 로직: PostService::advertise()

```php
// lib/post/PostService.php (라인 682-764)
public static function advertise(array $input): PostEntity
{
    $idx = (int)($input['idx'] ?? 0);
    $days = (int)($input['days'] ?? 0);
    $idxMember = (int)($input['idx_member'] ?? 0);

    // 1. 글 조회 + 본인 확인
    $post = PostRepository::findByIdx($idx);
    if ($post->idx_member !== $idxMember) throw new RuntimeException('본인 글만 가능');

    // 2. 적격 게시판 확인
    if (!in_array($post->post_id, self::POINT_ADV_CATEGORIES, true)
        && !in_array($post->category, self::POINT_ADV_CATEGORIES, true)) {
        throw new RuntimeException('이 게시판에서는 포인트 광고를 사용할 수 없습니다.');
    }

    // 3. 포인트 계산 + 잔액 확인
    $requiredPoints = self::POINT_ADV_COST_PER_HOUR * 24 * $days;
    $userRow = Db::fetch("SELECT point FROM sf_member WHERE idx = ?", [$idxMember]);
    if ((int)$userRow['point'] < $requiredPoints) {
        throw new RuntimeException('포인트가 부족합니다.');
    }

    // 4. 포인트 차감
    PointLogService::changePoints($requiredPoints * -1, $idxMember, $idxMember,
        'adv', 'point-post-advertisement', $idx, 'point_adv');

    // 5. 광고 종료 시간 계산 (연장 지원)
    $now = time();
    $extensionSeconds = 86400 * $days;
    $currentExpiry = $post->int_5;
    // 핵심: 기존 광고 유효 → 연장, 만료 → 신규
    $endTime = ($currentExpiry > $now)
        ? $currentExpiry + $extensionSeconds
        : $now + $extensionSeconds;

    // 6. DB 업데이트
    PostRepository::update($idx, [
        'int_5' => $endTime,        // 광고 종료 시간
        'int_6' => $now,            // 등록 시간
        'int_7' => $days,           // 기간 (일)
        'int_8' => $requiredPoints, // 소비 포인트
    ]);

    return PostRepository::findByIdx($idx);
}
```

#### 광고 목록 조회: PostRepository::findPointAdvertisements()

```php
// lib/post/PostRepository.php (라인 938-952)
public static function findPointAdvertisements(string $postId, string $category = ''): array
{
    $sql = "SELECT * FROM sf_post_data USE INDEX(int_5) "
        . "WHERE int_5 > :stamp AND post_id = :post_id AND category = :category "
        . "ORDER BY int_5 DESC LIMIT 100";
    $rows = Db::fetchAll($sql, ['stamp' => time(), 'post_id' => $postId, 'category' => $category]);
    return array_map(fn(array $row) => PostEntity::fromArray($row), $rows);
}
```

### v7 프론트엔드 구현

#### 소스코드 파일

| 파일 | 설명 |
|------|------|
| `v7/widgets/advertisement/point-advertisements.php` | 게시판 목록 상단 포인트 광고 표시 위젯 |
| `v7/widgets/advertisement/point-advertisements.css` | 광고 표시 CSS |
| `v7/widgets/post/view/post-view-point-adv.php` | 글 보기 페이지 광고 등록/연장 위젯 |
| `v7/widgets/post/view/post-view-point-adv.css` | 글 보기 광고 위젯 CSS |
| `v7/js/post-form.js` | 글 작성/수정 시 포인트 광고 UI + API 호출 |

#### 게시판 목록에서 포인트 광고 조회 (list.php)

```php
// v7/post/list.php (라인 137-141)
$v7_point_ads = [];
if ($page <= 1) {
    $v7_point_ads = PostService::listPointAdvertisements($postId, $category);
}
// → v7/widgets/advertisement/point-advertisements.php에서 렌더링
```

#### 글 작성 폼에서 포인트 광고 선택 (post-form.js)

```javascript
// v7/js/post-form.js — 글 작성/수정 모두에서 표시
// 적격 게시판이면 기간 선택 드롭다운 + 등록/연장 버튼 표시
// 글 작성 완료 후 자동으로 post.advertise API 호출

// 광고 설정 로드
var data = await v7api('post.advertisementConfig', {
    post_id: this.postId, category: this.category
});
this.advEligible = data.eligible;
this.advDayOptions = data.days;

// 광고 등록/연장
var data = await v7api('post.advertise', {
    idx: this.idx, days: this.advSelectedDays
});
```

#### 목록 위젯 핵심 코드 (point-advertisements.php)

```php
// v7/widgets/advertisement/point-advertisements.php
/** @var PostEntity[] $v7_point_ads */
$v7_point_ads = $v7_point_ads ?? [];
if (empty($v7_point_ads)) return;

foreach ($v7_point_ads as $_paAd):
    // URL: link 필드가 있으면 사용, 없으면 글 보기 페이지
    $_paUrl = !empty($_paAd->link)
        ? htmlspecialchars($_paAd->link)
        : Route::postView($_paAd->idx, $_paAd->post_id);
    $_paThumb = $_paAd->resolved_thumbnail;
    // 렌더링: 썸네일 + 제목 + "포인트 광고" 배지 + 종료일 + 조회수 + 댓글수
endforeach;
```

#### 글 보기 페이지 광고 위젯 (post-view-point-adv.php)

```php
// v7/widgets/post/view/post-view-point-adv.php
// post-view-default.php에서 include됨
use V7\Utils\Config;

// 조건 1: 미로그인 또는 타인 글이면 표시 안 함
if ($loginIdxMember <= 0 || $post->idx_member !== $loginIdxMember) return;

// 조건 2: 적격 게시판 확인 (Config::pointAdvertisementPostCategories())
$advCategories = Config::pointAdvertisementPostCategories();
$cat = $post->category !== '' ? $post->category : $post->post_id;
if (!in_array($post->post_id, $advCategories, true)
    && !in_array($cat, $advCategories, true)) return;

// 설정 로드
$advDays = Config::pointAdvertisementDays();    // [3, 5, 7, ...]
$costPerHour = Config::pointAdvCostPerHour();   // 240
$isActive = $post->int_5 > time();
$remainingDays = $isActive ? (int)ceil(($post->int_5 - time()) / 86400) : 0;

// HTML: 기간 선택 드롭다운 + 등록/연장 버튼
// JS: v7api('post.advertise', { idx, days }) 호출 후 location.reload()
```

#### 글 작성/수정 폼 광고 UI (post-form.js 핵심 코드)

```javascript
// v7/js/post-form.js — Vue.js Options API data
advEligible: false,       // 적격 게시판 여부
advDayOptions: [],        // [{days:3, points:17280}, ...]
advCostPerHour: 0,        // 240
advSelectedDays: 0,       // 사용자 선택한 일수
advCurrentExpiry: 0,      // 현재 광고 종료 timestamp
advSubmitting: false,     // 제출 중 플래그

// computed
advRequiredPoints: function() { return this.advCostPerHour * 24 * this.advSelectedDays; },
advIsActive: function() { return this.advCurrentExpiry > Math.floor(Date.now() / 1000); },

// 글 작성 완료 후 자동 광고 등록 (post-form.js 라인 896-907)
if (!this.isUpdate && this.advSelectedDays > 0 && resultIdx) {
    await v7api('post.advertise', { idx: resultIdx, days: this.advSelectedDays });
}

// 템플릿: v-if="advEligible"로 적격 게시판에서만 표시
// 작성 모드: "글 작성 완료 시 포인트 광고가 자동으로 등록됩니다." 안내 표시
// 수정 모드: advIsActive이면 "광고 진행 중 — N일 N시간 남음" 배지 표시
```

### 전체 흐름도

```
[사용자] → 글 작성/수정/보기 페이지에서 "기간 선택" + "광고 등록" 클릭
    ↓
[JS] v7api('post.advertise', { idx, days }) 호출
    ↓
[PostController::advertise()] → 인증(세션/Firebase)
    ↓
[PostService::advertise()] 핵심 로직
    ├─ 본인 글 확인
    ├─ 적격 게시판 확인
    ├─ 포인트 계산 (240 × 24 × days)
    ├─ 포인트 잔액 확인 (부족 시 에러)
    ├─ PointLogService::changePoints() 포인트 차감
    ├─ 종료 시간 계산 (기존 유효 → 연장, 만료 → 신규)
    └─ PostRepository::update() DB 업데이트 (int_5/6/7/8)
    ↓
[게시판 목록 로드] list.php
    ├─ PostService::listPointAdvertisements() 호출 (첫 페이지만)
    ├─ PostRepository::findPointAdvertisements() SQL 쿼리
    │   └─ WHERE int_5 > time() AND post_id = ? ORDER BY int_5 DESC
    └─ point-advertisements.php 위젯에서 상단에 렌더링
```

### 에러 케이스

| 상황 | 에러 메시지 |
|------|-----------|
| 미로그인 | "로그인이 필요합니다." |
| 타인 글 | "본인이 작성한 글만 포인트 광고로 올릴 수 있습니다." |
| 비적격 게시판 | "이 게시판에서는 포인트 광고를 사용할 수 없습니다." |
| 포인트 부족 | "포인트가 부족합니다. 필요: N포인트, 보유: N포인트" |

### 포인트 로그 기록

| 필드 | 값 |
|------|-----|
| module | `adv` |
| action | `point-post-advertisement` |
| etc | `point_adv` |
| point | 음수 (차감) |
| idx_post | 광고 글 번호 |

---

## 12. 포인트 레벨 시스템

### 레벨 기준 (v6 etc/app.config.php 라인 157-313)

```php
const POINT_LEVELS = [
    0,        // 레벨 1: 0포인트 이상
    400,      // 레벨 2: 400포인트 이상
    1600,     // 레벨 3: 1600포인트 이상
    3600,     // 레벨 4: 3600포인트 이상
    6400,     // 레벨 5: 6400포인트 이상
    10000,    // 레벨 6: 10000포인트 이상
    // ... 130개 레벨까지
];
```

### 레벨 계산 함수

```php
// lib/point.functions.php 라인 19-29
function get_user_level(int $points): int
{
    foreach (POINT_LEVELS as $idx => $point) {
        if ($points < $point) return $idx;
    }
    return count(POINT_LEVELS);
}
```

### 레벨 진행률

```php
// lib/point.functions.php 라인 42-57
function get_user_level_progress(int $points, int $lv): int
{
    $current = POINT_LEVELS[$lv - 1] ?? 0;
    $next = POINT_LEVELS[$lv] ?? 0;
    $needed = $next - $current;
    $earned = $points - $current;
    return ($needed > 0) ? (int)floor(($earned / $needed) * 100) : 0;
}
```

---

## 13. 관리자 포인트 관리

### 관리자 포인트 수정

```php
// lib/point.functions.php 라인 472-507
function point_update_controller(array $in, array $login_user): array
{
    assert_admin_user($login_user);  // 관리자만 가능

    $points = (int)($in['point'] ?? 0);
    $idx_member_to = (int)($in['idx_member_to'] ?? 0);
    $target_user = get_user_by_idx($idx_member_to);

    return change_user_points(
        points: $points,
        login_user: $target_user,
        module: 'admin',
        action: 'update',
        etc: empty($in['etc']) ? 'admin-point-update' : $in['etc'],
        idx_member_to: $idx_member_to
    );
}
```

### 포인트 로그 조회

```php
// lib/point.functions.php 라인 519-552
function point_log_controller(array $in, array $login_user): array
{
    // 일반 사용자: 자신의 로그만
    // 관리자: 특정 사용자의 로그
    SELECT * FROM sf_point_log
    WHERE idx_member_from = ? OR idx_member_to = ?
    ORDER BY stamp DESC
}
```

---

## 14. v6 레거시 함수 대응표

| v6 함수 | v7 메서드 |
|---------|----------|
| `change_user_points()` | `PointLogService::changePoints()` |
| `increase_user_points_for_post_create()` | `PostService::increasePointsForCreate()` |
| `decrease_user_points_for_post_delete()` | `PostService::decreasePointsForDelete()` |
| `increase_user_points_for_comment_create()` | `PostService::increasePointsForCommentCreate()` |
| `decrease_user_points_for_comment_delete()` | `PostService::decreasePointsForCommentDelete()` |
| `increase_user_points_for_like()` | `PostService::increasePointsForLike()` |
| `get_event_points()` | `PostService::getEventPoints()` |
| `randomize_event_point()` | `PostService::randomizeEventPoint()` |
| `get_point_history_count_within()` | `PointLogService::getRecentActionCount()` |
| `created_in_hours()` | `PostService::isCreatedWithinHours()` |
| `update_like()` | `PostService::like()` |
| `get_like()` | `PostRepository::getVoteHistory()` |
| `advertise_point_post()` | (v7 미구현) |
| `point_update_controller()` | `PointLogController::changePoints()` |
| `point_log_controller()` | `PointLogController::history()` |
| `get_user_level()` | (v7 미구현) |
| `PointConfig::inEventDate()` | `SettingsService::isInPointEventDate()` |
| `PointConfig::$point_event_dates` (하드코딩) | `SettingsService::getPointEventDates()` (DB 기반) |

---

## 15. API 엔드포인트

### 기존 API (PointLogController)

- `pointLog.changePoints` — 포인트 변경
- `pointLog.get` — 로그 단건 조회
- `pointLog.history` — 히스토리 조회
- `pointLog.memberPoint` — 회원 포인트 조회
- `pointLog.recentCount` — 최근 액션 횟수
- `pointLog.weeklyCount` — 주간 횟수
- `pointLog.sumByPost` — 게시글별 합산

### 글/코멘트/좋아요 관련 (PostController)

- `post.create` — 글 생성 (포인트 자동 지급)
- `post.delete` — 글 삭제 (포인트 자동 차감)
- `post.commentCreate` — 코멘트 생성 (포인트 자동 지급, 24시간 제한)
- `post.commentDelete` — 코멘트 삭제 (포인트 자동 차감)
- `post.like` — 좋아요 (포인트 +3, 24시간 제한)
- `post.unlike` — 좋아요 해제 (포인트 -3, 24시간 제한)

---

## 16. 포인트 흐름도

### 글 작성 시 포인트 획득

```
글 작성 요청
    ↓
[1] 글 검증 (검열, 블라인드, 스팸 확인)
    ↓
[2] 게시판 설정에서 point_write 가져오기
    ↓
[3] 쓰로틀링 확인 (10분 내 3회 이상?)
    ├─ YES → 8포인트만 반환
    └─ NO → 계속
    ↓
[4] 이벤트 기간 확인
    ├─ NO → point_write 반환
    └─ YES → 이벤트 게시판 확인
             ├─ freetalk/qna → AI 점수(0-100) 계산
             │   ↓
             │   랜덤 배율 적용 (3배~200배)
             │   ↓
             │   $random_points = score × multiplier
             │
             └─ 다른 게시판 → point_write 반환
    ↓
[5] 최종 포인트 결정 (max(random_points, point_write))
    ↓
[6] etc 값 결정 (이벤트 포인트 판별)
    ├─ 최종 포인트 > point_write 설정값 → etc = 'point_event_write'
    └─ 그 외 → etc = 'point_write'
    ↓
[7] change_user_points() / PointLogService::changePoints()
    ├─ sf_member.point 업데이트 (합산)
    ├─ sf_point_log 레코드 삽입 (etc = 'point_write' 또는 'point_event_write')
    └─ 글의 int_10 필드에 획득 포인트 기록
    ↓
완료
```

### 코멘트 작성 시 포인트 획득

```
코멘트 작성 요청
    ↓
[1] 코멘트 검증 (검열, 블라인드 확인)
    ↓
[2] 원글 작성 시간 확인 (24/25시간 제한)
    ├─ 시간 초과 → 포인트 0
    └─ OK → 계속
    ↓
[3] 이후 글 작성과 동일 (쓰로틀링, 이벤트 등)
    ↓
완료
```

### 좋아요 클릭 시 포인트

```
좋아요 클릭
    ↓
[1] 중복 체크 (sf_post_vote_history)
    ├─ 이미 좋아요 함 → 에러
    └─ OK → 계속
    ↓
[2] 글/코멘트 24시간 제한 확인
    ├─ 24시간 초과 → 포인트 0 (좋아요는 등록)
    └─ OK → 계속
    ↓
[3] 3포인트 지급 (int_10 기록 안 함)
    ↓
완료
```

### 글 삭제 시 포인트 차감 (v7)

```
글 삭제 요청
    ↓
[1] 글이 차단/블라인드 처리?
    ├─ YES → 포인트 변화 없음
    └─ NO → 계속
    ↓
[2] int_10 확인
    ├─ int_10 ≠ 0 → int_10 * -1 차감 (전액 회수)
    └─ int_10 = 0 → point_write_delete 설정값 사용
    ↓
[3] changeUserPoints() 호출
    ↓
완료
```

---

## 17. 계산 예시

### 예시 1: 글 작성 (이벤트 기간 외)

```
상황:
- 게시판: wanted (구인구직)
- point_write = 10
- 이벤트 기간: NO

결과:
- 최종 포인트: 10
- etc: 'point_write' (10 > 10 아니므로 일반 포인트)
- 사용자: 100 → 110
- int_10: 10
- sf_point_log: module='post', action='create', etc='point_write', point=10
```

### 예시 2: 글 작성 (이벤트 기간, freetalk)

```
상황:
- 게시판: freetalk
- point_write = 5
- 이벤트 기간: YES
- AI 점수: 70, 랜덤 확률: 92 → 20배

결과:
- random_points = 70 × 20 = 1,400
- 최종 = max(1400, 5) = 1,400
- etc: 'point_event_write' (1,400 > 5이므로 이벤트 포인트)
- 사용자: 100 → 1,500
- int_10: 1,400
- sf_point_log: module='post', action='create', etc='point_event_write', point=1400
```

### 예시 3: 이벤트 글 삭제 (v7)

```
상황:
- int_10 = 1,400 (이벤트로 받은 포인트)

결과:
- 차감: -1,400 (int_10 기반 전액 회수)
- 사용자: 1,500 → 100
```

### 예시 4: 코멘트 (24시간 이내)

```
상황:
- 원글 작성: 10시간 전
- point_comment = 33

결과:
- 24시간 이내 → 포인트 지급
- 사용자: 1000 → 1033
```

### 예시 5: 코멘트 (24시간 초과)

```
상황:
- 원글 작성: 30시간 전
- point_comment = 33

결과:
- 24시간 초과 → 포인트 0
- 사용자 포인트 변화 없음
```

### 예시 6: 좋아요 (24시간 이내 글)

```
상황:
- 글 작성: 12시간 전
- point_for_like = 3

결과:
- 포인트 +3
- 사용자: 500 → 503
- int_10 기록 안 함
```

### 예시 7: 포인트 광고 (7일)

```
상황:
- days = 7
- 사용자 포인트: 100,000

결과:
- 비용: 240 × 24 × 7 = 40,320
- 사용자: 100,000 → 59,680
- int_5: now + 604,800 (7일 후 종료)
```

### 예시 8: 쓰로틀링

```
상황:
- 10:00 글 작성 → 50포인트
- 10:03 코멘트 → 200포인트
- 10:05 글 작성 → 100포인트
- 10:07 코멘트 작성 요청

결과:
- 10분 내 3회 초과 → 쓰로틀링 적용
- 10:07 코멘트 → 8포인트만 지급
```

### 예시 9: 포인트 음수 방지

```
상황:
- 사용자 포인트: 3
- 차감 포인트: -10

결과:
- 계산: 3 + (-10) = -7
- 최종: max(-7, 0) = 0
- point_before=3, point=-10, point_after=0
```

---

## 18. v7 웹 포인트 내역 페이지

### 개요

v7 홈페이지에서 로그인한 사용자의 포인트 변동 이력을 확인하는 웹 페이지이다.
v6 `page/point/history.php` + `widget/point/history.php`의 로직을 100% 동일하게 v7 아키텍처로 재구현한다.

### 파일 구조

| 파일 | 설명 |
|------|------|
| `v7/point/history.php` | 포인트 내역 페이지 (SSR) |
| `v7/point/history.css` | 페이지 전용 CSS |
| `tests/Unit/PointHistoryPageTest.php` | PEST 유닛 테스트 (33개 테스트) |

### 접속 URL

- **v7 로컬**: `https://v7-local.philgo.com/point/history`
- **라우팅**: `/point/history` → `v7.php` → `v7/layout.php` → `v7/point/history.php`
- **URL 헬퍼**: `url()->point->history` → `/point/history`

### 주요 기능

| 기능 | 설명 |
|------|------|
| **로그인 필수** | 비로그인 시 로그인 안내 + `wa-button` 로그인 링크 표시 |
| **현재 포인트 표시** | 상단에 `나의 현재 포인트: N` 박스 표시 |
| **포인트 내역 테이블** | sf_point_log 테이블에서 사유, 적용 포인트, 적용 후 포인트, 날짜/시간 표시 |
| **색상 구분** | 양수(초록), 음수(빨강), 0(회색) |
| **사유 배지** | Web Awesome `wa-badge` 컴포넌트로 사유별 variant 표시 |
| **관련 글 링크** | 글 작성/댓글 작성/이벤트 포인트(`point_event_write`, `point_event_comment`) 시 해당 글로 이동하는 `보기` 링크 |
| **관리자 필터** | 관리자는 `idx_member`, `etc` 파라미터로 다른 사용자 조회 가능 |
| **관리자 FROM/TO** | 관리자에게만 FROM/TO 사용자 칼럼 표시 |
| **페이지네이션** | 10개씩, 최대 5개 페이지 버튼 표시 |
| **반응형** | 모바일(<992px)에서 축약 날짜, 작은 폰트 |

### 사유(etc) 라벨 매핑

`getPointReasonLabel()` 함수에서 etc 값을 한글로 변환한다.

| etc 값 | 한글 라벨 |
|--------|----------|
| `point_write` | 글 작성 |
| `point_comment` | 댓글 작성 |
| `point_event_write` | 포인트 이벤트 |
| `point_event_comment` | 포인트 이벤트 |
| `point_write_delete` | 글 삭제 |
| `point_comment_delete` | 댓글 삭제 |
| `like` | 좋아요 |
| `unlike` | 좋아요 취소 |
| `post_on_top` | 포인트 광고 |
| `admin-point-update` | 관리자 조정 |
| `biz-point-buy` | 포인트 구매 |
| `spin` | 스피닝 휠 |
| `spin_reward` | 스피닝 휠 보상 |
| `mukbang_event_base` | 먹방 이벤트 |
| `register` | 회원가입 |
| `login` | 로그인 |

### 사유별 배지 variant

`getPointReasonVariant()` 함수에서 etc 값에 따른 Web Awesome 배지 variant를 반환한다.

| etc 값 | variant | 색상 |
|--------|---------|------|
| `biz-point-buy` | `danger` | 빨강 |
| `admin-point-update` | `warning` | 노랑 |
| `point_write_delete`, `point_comment_delete` | `neutral` | 회색 |
| `point_event_write`, `point_event_comment` | `success` | 초록 |
| 그 외 | `primary` | 파랑 |

### DB 쿼리 패턴

```php
// history.php에서 사용하는 WHERE 절 동적 구성
$where = "(idx_member_from = :idx_member OR idx_member_to = :idx_member2)";
$params = [
    'idx_member' => $targetIdx,
    'idx_member2' => $targetIdx,
];

// 관리자 etc 필터 (단일 값)
$where .= " AND etc = :etc";

// 관리자 etc 필터 (배열 - IN 쿼리)
$where .= " AND etc IN (:etc_0, :etc_1, ...)";

// 정렬 및 페이지네이션
"ORDER BY stamp DESC, idx DESC LIMIT $offset, $limit"
```

### CSS 클래스 체계

| 클래스 | 용도 |
|--------|------|
| `.point-login-required` | 비로그인 안내 래퍼 |
| `.point-history-wrapper` | 전체 래퍼 |
| `.point-current-box` | 현재 포인트 표시 박스 |
| `.point-table` | 포인트 내역 테이블 |
| `.point-positive` | 양수 포인트 (초록) |
| `.point-negative` | 음수 포인트 (빨강) |
| `.point-zero` | 0 포인트 (회색) |
| `.point-pagination` | 페이지네이션 래퍼 |
| `.point-page-link` | 페이지 버튼 |
| `.point-page-link.active` | 현재 페이지 버튼 |

### v6 → v7 대응

| v6 | v7 |
|----|----|
| `page/point/history.php` | `v7/point/history.php` |
| `widget/point/history.php` | `v7/point/history.php` (위젯 없이 페이지에 통합) |
| `login()` | `AuthService::getLoginUser()` |
| `pdo()` | `Db::pdo()`, `Db::fetchAll()`, `Db::fetchColumn()` |
| Bootstrap CSS | Web Awesome Pro + 커스텀 CSS |
| `href()->user->login` | `url()->user->login` |
| `t()->{$etc}` | `getPointReasonLabel($etc)` 함수 |
