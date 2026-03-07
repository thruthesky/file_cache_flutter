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
11. [v6 레거시 함수 대응표](#11-v6-레거시-함수-대응표)
12. [API 엔드포인트](#12-api-엔드포인트)

---

## 1. 개요

v7 포인트 시스템은 v6 `lib/point.functions.php`의 핵심 로직을 v7 아키텍처(Controller + Service + Repository + Entity)로 구현한다.

핵심 원칙:
- 포인트는 **0 이하로 내려가지 않는다** (음수 방지)
- 모든 포인트 변경은 `sf_point_log` 테이블에 기록된다
- 실제 지급된 포인트는 글/코멘트의 `int_10` 필드에 저장된다
- 검열 거부(`checked='R'`) 또는 블라인드(`blind='Y'`) 처리된 글/코멘트는 포인트 지급/차감하지 않는다

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
| `module` | varchar | 모듈명 (post, comment, vote, admin, event, point_event, adv) |
| `action` | varchar | 액션명 (create, delete, like, unlike, spin 등) |
| `idx_post` | int | 관련 글/코멘트 idx (0이면 해당 없음) |
| `etc` | varchar | 기타 정보 (사유) |
| `stamp` | int | Unix timestamp |
| `ip` | varchar | 사용자 IP |

### sf_post_vote_history (좋아요 이력)

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx_post` | int | 글/코멘트 idx |
| `idx_member` | int | 좋아요한 회원 idx |
| `webbrowser_id` | varchar(32) | 브라우저 ID |
| `code` | char(1) | 'G'=좋아요 |
| `ip` | char(15) | IP 주소 |

### sf_post_config (게시판 설정)

포인트 관련 컬럼:
- `point_write` int(11) — 글 작성 포인트
- `point_comment` int(11) — 코멘트 작성 포인트
- `point_write_delete` int(11) — 글 삭제 포인트 (음수)
- `point_comment_delete` int(11) — 코멘트 삭제 포인트 (음수)

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

```php
// v7 사용 예시
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

module/action/etc 값:
| 필드 | 값 |
|------|-----|
| module | `post` |
| action | `create` |
| etc | `point_write` |

### 글 삭제 시 (PostService::delete)

```
PostService::delete()
  → decreasePointsForDelete($post, $member)
    → 검열/블라인드 체크 → 해당하면 skip
    → int_10이 0이 아니면 → int_10 * -1 포인트 차감 (이벤트 포인트 전액 회수)
    → int_10이 0이면 → PostRepository::getPostConfig() → point_write_delete 조회
    → changeUserPoints()
```

**핵심**: 삭제 시 `int_10`에 저장된 실제 지급 포인트를 기반으로 전액 회수한다.
이벤트로 1500점을 받았으면 삭제 시 -1500점이 차감된다.

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
2. **원글(parent post)의 작성 시간(stamp)이 현재로부터 24시간(PointConfig::$comment_point_available_hours) 이내인 경우에만 포인트 지급**
3. 그 외는 일반 글 생성과 동일

```php
// 24시간 제한 핵심 로직 (v6)
if ($is_comment) {
    if (created_in_hours($post[STAMP], PointConfig::$comment_point_available_hours) == false) {
        return 0; // 포인트 미지급
    }
}
```

v7 구현:
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
| 코멘트 생성 | `comment` | `create` | `point_comment` |
| 코멘트 삭제 | `comment` | `delete` | `point_comment_delete` |

---

## 8. 좋아요/좋아요 해제 시 포인트 처리

### 좋아요 포인트 규칙

- 포인트: **3점 고정** (PointConfig::$point_for_like = 3)
- 조건: 글/코멘트가 **작성 후 24시간 이내**인 경우에만 적용
- 좋아요 시: 포인트 +3
- 좋아요 해제 시: 포인트 -3
- 좋아요 이력: `sf_post_vote_history` 테이블에 기록
- 좋아요 포인트는 `int_10`에 기록하지 않는다 (v6에서 글 생성 포인트를 덮어쓰는 문제 방지)

### v6 좋아요 로직 (참고)

v6에서는 좋아요 취소가 불가능했다. v7에서는 좋아요 취소(unlike)를 지원하며, 포인트도 함께 차감한다.

```php
// v6 좋아요 포인트
function increase_user_points_for_like(int $idx_post, array $login_user): void {
    $points = PointConfig::$point_for_like ?? 0; // 3
    if ($points <= 0) return;

    // 24시간 이내의 글/코멘트인 경우만 포인트 증가
    $post = get_raw_post($idx_post, 'idx, stamp, post_id');
    if (created_in_hours($post['stamp'], 24) == false) return;

    change_user_points(
        points: $points,
        module: 'vote',
        action: 'like',
        idx_post: $idx_post,
        etc: 'like',
        idx_member_to: $login_user[IDX]
    );
}
```

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

### v6 로직 (get_event_points)

```
1. 설정 포인트 가져오기 (point_write 또는 point_comment)
2. 코멘트인 경우 → 원글이 24시간 이내인지 확인 (아니면 0점)
3. 포인트 남용 방지 체크 (throttling)
4. 포인트 이벤트 기간인지 확인 (PointConfig::inEventDate())
5. 이벤트 게시판인지 확인 (PointConfig::$event_post_ids)
6. 랜덤 포인트 계산 (randomize_event_point)
7. max(랜덤 포인트, 설정 포인트) 반환
```

### 랜덤 포인트 계산 (randomize_event_point)

```
1. score(0~100) = 글 내용의 관련성 점수 (최소 $min_event_score = 5)
2. rand(1, 100) = 확률
3. 확률 구간별 배율 적용 (point_multiplier_tiers):
   - 0%~50%: 3배
   - 50%~90%: 10배
   - 90%~95%: 20배
   - 95%~99%: 30배
   - 99%~100%: 200배
4. 최종 포인트 = score × multiplier
```

### v7 구현

```php
// PostService::getEventPoints() — 이벤트 포인트 계산
// PostService::randomizeEventPoint() — 랜덤 배율 적용
```

### 삭제 시 이벤트 포인트 회수

글/코멘트 삭제 시 `int_10`에 저장된 실제 지급 포인트를 전액 회수한다.
- int_10 ≠ 0이면 → `int_10 * -1` 포인트 차감
- int_10 = 0이면 → 게시판 설정의 `point_write_delete` / `point_comment_delete` 사용

```php
// 예: 이벤트로 1500점 받은 글 삭제 시
$post->int_10 = 1500;
// → -1500 포인트 차감 (전액 회수)
```

### 이벤트 설정 (테스트용)

```php
// 이벤트 기간 강제 설정
PostService::setEventPeriod(true);

// 이벤트 대상 게시판 설정
PostService::setEventPostIds(['temp', 'freetalk']);

// 이벤트 설정 초기화
PostService::resetEventSettings();
```

---

## 10. 포인트 남용 방지

v6의 PointConfig 설정:
- `$event_throttling_minutes = 10` — 최근 10분 이내
- `$event_throttling_count = 3` — 3회 이상 포인트를 받았으면
- `$event_throttling_points = 8` — 기본 8점만 지급

```php
if (PointConfig::$event_throttling_minutes > 0) {
    $count = PointLogService::getRecentActionCount($idxMember, 10, 'create');
    if ($count >= 3) {
        return 8; // 기본 포인트만 지급
    }
}
```

---

## 11. v6 레거시 함수 대응표

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

---

## 12. API 엔드포인트

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
