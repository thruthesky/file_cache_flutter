# 사용자 차단 기능 — v7 시스템

## 목차

- [1. 개요](#1-개요)
- [2. 아키텍처](#2-아키텍처)
  - [2.1 두 가지 차단 시스템](#21-두-가지-차단-시스템)
  - [2.2 파일 구조](#22-파일-구조)
- [3. DB 테이블 구조](#3-db-테이블-구조)
  - [3.1 sf_member_blocks (회원 간 차단)](#31-sf_member_blocks-회원-간-차단)
  - [3.2 sf_member 관리자 차단 필드](#32-sf_member-관리자-차단-필드)
- [4. 회원 간 차단 — 백엔드 (v7 Controller)](#4-회원-간-차단--백엔드-v7-controller)
  - [4.1 user.toggleBlock API](#41-usertoggleblock-api)
  - [4.2 user.unblock API](#42-userunblock-api)
  - [4.3 user.blockedList API](#43-userblockedlist-api)
- [5. Firebase RTDB 동기화](#5-firebase-rtdb-동기화)
- [6. 회원 간 차단 — 레거시 함수](#6-회원-간-차단--레거시-함수)
  - [6.1 글 목록 필터링 (get_my_blocked_member_ids)](#61-글-목록-필터링-get_my_blocked_member_ids)
  - [6.2 캐싱 메커니즘](#62-캐싱-메커니즘)
- [7. 프론트엔드 — JS API (block.js)](#7-프론트엔드--js-api-blockjs)
- [8. 차단된 콘텐츠 표시](#8-차단된-콘텐츠-표시)
  - [8.1 글 목록에서 차단 글 표시](#81-글-목록에서-차단-글-표시)
  - [8.2 글 상세 페이지](#82-글-상세-페이지)
  - [8.3 코멘트 차단 표시](#83-코멘트-차단-표시)
  - [8.4 공개 프로필 차단 버튼](#84-공개-프로필-차단-버튼)
  - [8.5 Masonry 목록 (매물/일반)](#85-masonry-목록-매물일반)
  - [8.6 지역 페이지 차단 필터링](#86-지역-페이지-차단-필터링)
- [9. 차단 목록 관리 페이지 (blocked.php)](#9-차단-목록-관리-페이지-blockedphp)
- [10. 관리자 차단 시스템](#10-관리자-차단-시스템)
  - [10.1 차단 로직](#101-차단-로직)
  - [10.2 차단 확인](#102-차단-확인)
  - [10.3 관리자 차단 사용자 목록 페이지](#103-관리자-차단-사용자-목록-페이지)
- [11. 접근 경로 및 라우팅](#11-접근-경로-및-라우팅)
- [12. 차단 플로우 다이어그램](#12-차단-플로우-다이어그램)
- [13. 테스트](#13-테스트)

---

## 1. 개요

v7 사용자 차단 기능은 **두 가지 독립적인 차단 시스템**으로 구성된다:

1. **회원 간 차단**: 사용자 A가 사용자 B를 차단하여 B의 글/댓글을 숨김
2. **관리자 차단**: 관리자가 특정 사용자의 활동을 일시적으로 제한

> **절대 규칙: 차단/해제는 오직 v7 API를 통해서만 수행한다**
>
> 사용자 차단/해제는 반드시 필고 v7 API(`user.toggleBlock`, `user.unblock`)를 통해서만 수행해야 한다.
> Firebase RTDB에 직접 쓰기(`set(true)`, `remove()`)로 차단/해제하는 것은 **엄격히 금지**한다.
> v7 API가 MariaDB에 차단 정보를 저장한 후 Firebase RTDB에 자동 동기화(`UserService::syncBlockToFirebase()`)하므로,
> 채팅방에서는 Firebase RTDB 리스너(`listenBlockedUsers()`)로 차단 여부를 실시간 감지하여 UI에 반영하면 된다.

> **중요**: v6의 `/func.php` 호출 방식은 v7 세션(`session_id_v7`)과 호환되지 않으므로,
> 반드시 `v7api()` → `/api.php` → `UserController` 경로를 사용해야 한다.

---

## 2. 아키텍처

### 2.1 두 가지 차단 시스템

| 구분 | 회원 간 차단 | 관리자 차단 |
|------|-------------|------------|
| **목적** | 사용자가 특정 사용자의 글/댓글 숨김 | 관리자가 사용자 활동 일시 제한 |
| **DB** | `sf_member_blocks` 테이블 | `sf_member` 테이블 (int_8, int_9, text_5) |
| **실행 주체** | 로그인 사용자 | 관리자만 |
| **효과** | 차단자의 목록에서만 숨김 | 차단된 사용자의 글쓰기/수정 제한 |
| **기간** | 영구 (수동 해제) | 차단횟수 × 30분 (자동 해제) |
| **v7 Controller** | `UserController::toggleBlock/unblock/blockedList` | 없음 (레거시 함수) |
| **Firebase 동기화** | O (채팅 앱용) | X |

### 2.2 파일 구조

| 파일 | 용도 |
|------|------|
| `lib/user/UserController.php` | v7 차단 API Controller (toggleBlock, unblock, blockedList) |
| `lib/user/UserService.php` | Firebase RTDB 동기화 (syncBlockToFirebase) |
| `lib/user/UserRepository.php` | Firebase UID 조회 (getFirebaseUidByIdx) |
| `lib/user/member-block.functions.php` | 레거시 차단 함수 (block_member, get_my_blocked_member_ids 등) |
| `lib/user/user.block.php` | 관리자 차단 함수 (block_user, blocked_user) |
| `v7/js/block.js` | 차단 관련 JS 유틸리티 |
| `v7/user/blocked.php` | 차단 목록 관리 페이지 (Vue.js) |
| `v7/user/blocked.css` | 차단 목록 페이지 스타일 |
| `v7/admin/blocked-users.php` | 관리자 차단 사용자 목록 |
| `tests/Unit/MemberBlockTest.php` | 유닛 테스트 |
| `tests/Browser/BlockTest.php` | 브라우저 테스트 |

---

## 3. DB 테이블 구조

### 3.1 sf_member_blocks (회원 간 차단)

```sql
CREATE TABLE `sf_member_blocks` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_blocker` int(10) UNSIGNED NOT NULL,    -- 차단한 사용자 idx
  `idx_blockee` int(10) UNSIGNED NOT NULL,    -- 차단당한 사용자 idx
  `created_at` int(10) UNSIGNED NOT NULL,     -- 차단 시간 (unix timestamp)
  PRIMARY KEY (`idx`),
  UNIQUE KEY `idx_blocker_idx_blockee` (`idx_blocker`, `idx_blockee`),
  KEY `idx_blocker_created_at` (`idx_blocker`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

- `UNIQUE KEY`: 동일 사용자 쌍의 중복 차단 방지
- `idx_blocker_created_at`: 차단 목록 조회 최적화 (최신순 정렬)
- 상수: `MEMBER_BLOCKS_TABLE = 'sf_member_blocks'` (`lib/constants.php`)

### 3.2 sf_member 관리자 차단 필드

| 상수 | 실제 컬럼 | 타입 | 설명 |
|------|----------|------|------|
| `BLOCK_COUNT` | `int_8` | int | 차단 횟수 (0 = 차단 이력 없음) |
| `BLOCK_TIME` | `int_9` | int | 차단 해제 시간 (unix timestamp, 0 = 차단 안 됨) |
| `BLOCK_REASON` | `text_5` | text | 차단 사유 |

상수 정의: `lib/constants.php`

---

## 4. 회원 간 차단 — 백엔드 (v7 Controller)

### 4.1 user.toggleBlock API

**파일**: `lib/user/UserController.php:226-276`

차단/해제를 토글한다. 이미 차단 → 해제, 미차단 → 차단.

```php
// UserController::toggleBlock()
public function toggleBlock(array $input): array
{
    $me = AuthService::getLoginUser();
    if ($me === null) {
        throw new RuntimeException('로그인이 필요합니다.');
    }

    // blockee_firebase_uid → idx_blockee 변환 (채팅 앱용)
    if (!empty($input['blockee_firebase_uid'])) {
        $blockee = UserService::getByFirebaseUid((string)$input['blockee_firebase_uid']);
        if ($blockee === null) {
            throw new RuntimeException('존재하지 않는 사용자입니다.');
        }
        $input['idx_blockee'] = $blockee->idx;
    }

    $idxBlockee = (int)($input['idx_blockee'] ?? 0);
    if ($idxBlockee <= 0) {
        throw new RuntimeException('idx_blockee는 필수입니다.');
    }
    if ($me->idx === $idxBlockee) {
        throw new RuntimeException('자기 자신을 차단할 수 없습니다.');
    }

    // 현재 차단 상태 확인
    $existing = Db::fetch(
        "SELECT idx FROM sf_member_blocks WHERE idx_blocker = ? AND idx_blockee = ?",
        [$me->idx, $idxBlockee]
    );

    if ($existing !== false) {
        // 차단 해제
        Db::execute("DELETE FROM sf_member_blocks WHERE idx_blocker = ? AND idx_blockee = ?",
            [$me->idx, $idxBlockee]);
        UserService::syncBlockToFirebase($me->idx, $idxBlockee, false);
        return ['idx_blockee' => $idxBlockee, 'blocked' => false, 'message' => '차단이 해제되었습니다.'];
    } else {
        // 차단 추가
        Db::execute("INSERT INTO sf_member_blocks (idx_blocker, idx_blockee, created_at) VALUES (?, ?, ?)",
            [$me->idx, $idxBlockee, time()]);
        UserService::syncBlockToFirebase($me->idx, $idxBlockee, true);
        return ['idx_blockee' => $idxBlockee, 'blocked' => true, 'message' => '사용자를 차단했습니다.'];
    }
}
```

**호출 예시**:
```
GET /api.php?method=user.toggleBlock&idx_blockee=123&session_id=xxx
GET /api.php?method=user.toggleBlock&blockee_firebase_uid=abc123&session_id=xxx
```

**입력**: `{ idx_blockee: int }` 또는 `{ blockee_firebase_uid: string }`
**반환**: `{ idx_blockee: int, blocked: bool, message: string }`

### 4.2 user.unblock API

**파일**: `lib/user/UserController.php:293-323`

차단만 해제한다 (차단되지 않은 상태에서도 에러 없이 처리).

```php
// UserController::unblock()
public function unblock(array $input): array
{
    $me = AuthService::getLoginUser();
    if ($me === null) {
        throw new RuntimeException('로그인이 필요합니다.');
    }

    // blockee_firebase_uid → idx_blockee 변환
    if (!empty($input['blockee_firebase_uid'])) {
        $blockee = UserService::getByFirebaseUid((string)$input['blockee_firebase_uid']);
        if ($blockee === null) {
            throw new RuntimeException('존재하지 않는 사용자입니다.');
        }
        $input['idx_blockee'] = $blockee->idx;
    }

    $idxBlockee = (int)($input['idx_blockee'] ?? 0);
    if ($idxBlockee <= 0) {
        throw new RuntimeException('idx_blockee는 필수입니다.');
    }

    Db::execute("DELETE FROM sf_member_blocks WHERE idx_blocker = ? AND idx_blockee = ?",
        [$me->idx, $idxBlockee]);
    UserService::syncBlockToFirebase($me->idx, $idxBlockee, false);

    return ['idx_blockee' => $idxBlockee, 'blocked' => false, 'message' => '차단이 해제되었습니다.'];
}
```

### 4.3 user.blockedList API

**파일**: `lib/user/UserController.php:443-460`

로그인 사용자가 차단한 모든 사용자 목록을 조회한다.

```php
// UserController::blockedList()
public function blockedList(array $input): array
{
    $me = AuthService::getLoginUser();
    if ($me === null) {
        throw new RuntimeException('로그인이 필요합니다.');
    }

    $rows = Db::fetchAll(
        "SELECT b.idx, b.idx_blockee, b.created_at, m.nickname, m.photo_url
         FROM sf_member_blocks b
         LEFT JOIN sf_member m ON m.idx = b.idx_blockee
         WHERE b.idx_blocker = ?
         ORDER BY b.created_at DESC",
        [$me->idx]
    );

    return $rows ?: [];
}
```

**반환**: `[{ idx, idx_blockee, created_at, nickname, photo_url }, ...]`

---

## 5. Firebase RTDB 동기화

**파일**: `lib/user/UserService.php:639-664`

차단/해제 시 Firebase Realtime Database에 동기화하여 채팅 앱에서 실시간 반영한다.

```php
// UserService::syncBlockToFirebase()
public static function syncBlockToFirebase(int $idxBlocker, int $idxBlockee, bool $blocked): void
{
    try {
        $blockerUid = UserRepository::getFirebaseUidByIdx($idxBlocker);
        $blockeeUid = UserRepository::getFirebaseUidByIdx($idxBlockee);

        // Firebase UID가 없으면 동기화 스킵
        if ($blockerUid === '' || $blockeeUid === '') {
            return;
        }

        $database = FirebaseService::getDatabase();
        $path = "user-private/{$blockerUid}/blocks/{$blockeeUid}";

        if ($blocked) {
            $database->getReference($path)->set(true);   // 차단
        } else {
            $database->getReference($path)->remove();     // 해제
        }
    } catch (\Exception $e) {
        Debug::log("Firebase RTDB 차단 동기화 실패: " . $e->getMessage());
    }
}
```

**RTDB 경로**: `user-private/{blockerFirebaseUid}/blocks/{blockeeFirebaseUid}`

| 상태 | RTDB 값 |
|------|---------|
| 차단 | `true` |
| 해제 | 경로 삭제 |

**핵심 원칙**:
- MariaDB(`sf_member_blocks`)가 source of truth
- Firebase RTDB는 클라이언트용 캐시 (채팅 앱에서 실시간 메시지 필터링)
- 동기화 실패해도 차단/해제 기능은 정상 작동 (에러 무시)
- Kreait Firebase Admin SDK 사용

---

## 6. 회원 간 차단 — 레거시 함수

**파일**: `lib/user/member-block.functions.php`

v6 레거시 함수이지만 v7의 글 목록 필터링에서 여전히 사용된다.

### 6.1 글 목록 필터링 (get_my_blocked_member_ids)

**파일**: `lib/user/member-block.functions.php:236-269`

```php
function get_my_blocked_member_ids(): array
{
    global $_member_block_cache_invalidated;
    static $cached_ids = null;

    // 캐시 무효화 플래그 확인
    if ($_member_block_cache_invalidated) {
        $cached_ids = null;
        $_member_block_cache_invalidated = false;
    }

    if ($cached_ids !== null) {
        return $cached_ids;
    }

    if (!login()) {
        return $cached_ids = [];
    }

    $idx_blocker = login()->idx;
    $stmt = pdo()->prepare(
        "SELECT idx_blockee FROM sf_member_blocks WHERE idx_blocker = ?"
    );
    $stmt->execute([$idx_blocker]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // 정수형 배열로 변환 (SQL 인젝션 방지)
    return $cached_ids = array_map('intval', array_column($results, 'idx_blockee'));
}
```

**v7 페이지에서의 사용 패턴** (v7에서는 `Db::fetchAll()` 사용):

```php
// v7/post/list.php, v7/post/latest.php, v7/post/view.php, v7/post/region.php 공통 패턴
$_blockedMemberIds = [];
if ($_v7LoginUser) {
    $_blockedMemberIds = Db::fetchAll(
        "SELECT idx_blockee FROM sf_member_blocks WHERE idx_blocker = ?",
        [$_v7LoginUser->idx],
        \PDO::FETCH_COLUMN
    );
}

// 개별 글/코멘트 차단 여부 확인
$isBlockedAuthor = !empty($_blockedMemberIds) && in_array($post->idx_member, $_blockedMemberIds);
$isBlockedComment = !empty($_blockedMemberIds) && in_array($c->idx_member, $_blockedMemberIds);
```

**사용되는 v7 페이지**:
- `v7/post/list.php:120-122` — 게시판 목록
- `v7/post/latest.php:79-81` — 최신 글 목록
- `v7/post/view.php:111-119` — 글 상세 (글 본문 + 코멘트)
- `v7/post/region.php:50-55` — 지역 페이지
- `v7/photo/latest.php:111` — 사진 갤러리

### 6.2 캐싱 메커니즘

```php
// 캐시 무효화 (차단/해제 후 호출)
function clear_blocked_member_cache(): void
{
    global $_member_block_cache_invalidated;
    $_member_block_cache_invalidated = true;
}
```

- `get_my_blocked_member_ids()`는 정적 변수(`static $cached_ids`)로 요청 내 캐싱
- 차단/해제 후 `clear_blocked_member_cache()`로 글로벌 플래그 설정 → 다음 호출 시 DB 재조회
- v7 페이지에서는 이 레거시 캐싱을 사용하지 않고 각 페이지에서 직접 `Db::fetchAll()` 호출

---

## 7. 프론트엔드 — JS API (block.js)

**파일**: `v7/js/block.js` (68줄)

차단 관련 프론트엔드 유틸리티 함수. `v7api.js`에 의존하며, `v7/layout.php`에서 전역 로드됨.

```javascript
// 차단 토글 (차단 ↔ 해제)
async function toggleBlockMember(idxBlockee) {
    return await v7api('user.toggleBlock', { idx_blockee: idxBlockee }, { alertOnError: false });
}

// 차단 해제
async function unblockMember(idxBlockee) {
    return await v7api('user.unblock', { idx_blockee: idxBlockee }, { alertOnError: false });
}

// 차단 목록 조회
async function getBlockedMembers() {
    return await v7api('user.blockedList', {}, { alertOnError: false });
}

// 차단된 사용자 글/코멘트 클릭 시 확인 다이얼로그
async function confirmUnblockAndView(idxBlockee, type, targetUrl) {
    var typeText = type === 'comment' ? '댓글' : '글';
    var confirmed = confirm('차단된 사용자의 ' + typeText + '입니다.\n차단을 해제하고 내용을 확인하시겠습니까?');
    if (!confirmed) return false;

    try {
        await unblockMember(idxBlockee);
        if (targetUrl) {
            location.href = targetUrl;
        } else {
            location.reload();
        }
        return true;
    } catch (e) {
        alert(e.message || '차단 해제에 실패했습니다.');
        return false;
    }
}
```

| 함수 | v7 API | 용도 |
|------|--------|------|
| `toggleBlockMember(idx)` | `user.toggleBlock` | 프로필/액션바 차단 토글 |
| `unblockMember(idx)` | `user.unblock` | 차단 해제 전용 |
| `getBlockedMembers()` | `user.blockedList` | 차단 목록 페이지 |
| `confirmUnblockAndView(idx, type, url)` | `user.unblock` | 차단 글/댓글 클릭 시 |

---

## 8. 차단된 콘텐츠 표시

### 8.1 글 목록에서 차단 글 표시

**파일**: `v7/widgets/post/list/post-list-tile.php:24,65-74`

```php
// 차단 여부 판정
$_isBlockedPost = !empty($_blockedMemberIds) && in_array($post->idx_member, $_blockedMemberIds);

// 차단된 글: 클릭 시 confirmUnblockAndView 호출
<?php if ($_isBlockedPost): ?>
<a href="javascript:void(0)"
   class="post-tile-row post-tile-blocked"
   title="차단된 사용자의 글"
   onclick="confirmUnblockAndView(<?= $post->idx_member ?>, 'post', '<?= Route::postView($_postIdx, $postId, $category, $page) ?>'); return false;">
<?php else: ?>
<a href="<?= Route::postView($_postIdx, $postId, $category, $page) ?>"
   class="post-tile-row">
<?php endif; ?>
```

- 차단된 글은 `post-tile-blocked` CSS 클래스로 시각적 구분
- 클릭 시 `confirmUnblockAndView()` → confirm 다이얼로그 → 해제 후 글 보기 이동

### 8.2 글 상세 페이지

**파일**: `v7/widgets/post/view/post-view-default.php:143-157`

```php
<?php elseif ($isBlockedAuthor): ?>
    <div class="post-user-blocked-notice" data-idx-blockee="<?= $post->idx_member ?>">
        <div class="post-blocked-ban-icon">
            <i class="fal fa-ban"></i>
        </div>
        <div class="post-blocked-ban-msg">
            <strong>차단된 사용자의 글입니다</strong>
            <p>이 사용자를 차단했습니다. 내용을 보려면 차단을 해제하세요.</p>
        </div>
        <wa-button variant="neutral" appearance="outlined" size="small"
            onclick="confirmUnblockAndView(<?= $post->idx_member ?>, 'post')">
            <i slot="start" class="fal fa-lock-open"></i>
            차단 해제하고 내용 보기
        </wa-button>
    </div>
```

- 차단된 글 본문 영역 전체를 차단 안내로 대체
- 첨부파일도 숨김: `!$post->isBlockedOrBlinded() && !$isBlockedAuthor` 조건으로 가드
- 부동산 갤러리도 동일 조건: `$post->category === 'real_estate' && ... && !$isBlockedAuthor` (라인 69)
- 액션바에 `data-is-blocked` 속성 전달 (라인 241)

### 8.3 코멘트 차단 표시

**파일**: `v7/post/view.php:416-431`

```php
$isBlockedComment = !empty($_blockedMemberIds) && in_array($c->idx_member, $_blockedMemberIds);

<?php if ($c->isBlockedOrBlinded()): ?>
    <!-- 관리자 차단: "차단된 댓글입니다" -->
<?php elseif ($isBlockedComment): ?>
    <span class="comment-user-blocked" data-idx-blockee="<?= $c->idx_member ?>">
        <i class="fa-solid fa-ban" style="opacity:0.5;"></i> 차단된 사용자의 댓글입니다
        <button type="button" class="unblock-comment-btn"
            onclick="confirmUnblockAndView(<?= $c->idx_member ?>, 'comment')">
            해제하고 보기
        </button>
    </span>
<?php else: ?>
    <!-- 정상 코멘트 내용 -->
```

- 코멘트 첨부파일도 숨김: `!$c->isBlockedOrBlinded() && !$isBlockedComment` (라인 455)
- 각 코멘트 액션에 `data-is-blocked` 속성 전달 (라인 472)

### 8.4 공개 프로필 차단 버튼

**파일**: `v7/user/public-profile.php:207-227`

```php
// 차단 여부 확인 (Db::fetch 사용)
$isProfileBlocked = false;
if ($loginUser) {
    $blockRow = Db::fetch(
        "SELECT idx FROM sf_member_blocks WHERE idx_blocker = ? AND idx_blockee = ?",
        [$loginUser->idx, $user->idx]
    );
    $isProfileBlocked = $blockRow !== false;
}

// 차단 버튼 UI
<wa-button
    id="profile-block-btn"
    variant="<?= $isProfileBlocked ? 'danger' : 'neutral' ?>"
    appearance="outlined"
    size="small"
    data-idx-blockee="<?= $user->idx ?>"
    data-is-blocked="<?= $isProfileBlocked ? '1' : '0' ?>"
>
    <i slot="start" class="fal fa-ban"></i>
    <?= $isProfileBlocked ? '차단 해제' : '차단' ?>
</wa-button>
```

**JS 이벤트 핸들러** (`public-profile.php:338-348`):

```javascript
var blockBtn = document.getElementById('profile-block-btn');
if (blockBtn) {
    blockBtn.addEventListener('click', async function () {
        var idxBlockee = parseInt(blockBtn.dataset.idxBlockee, 10) || 0;
        var isBlocked = blockBtn.dataset.isBlocked === '1';
        var action = isBlocked ? '해제' : '차단';
        if (!confirm('이 사용자를 ' + action + '하시겠습니까?')) return;

        try {
            var res = await toggleBlockMember(idxBlockee);
            location.reload();
        } catch (e) { /* ... */ }
    });
}
```

> **주의**: v7 홈페이지(`v7/` 폴더)에서 `pdo()` 직접 호출은 금지이며,
> 반드시 `Philgo\Utils\Db` 클래스를 통해 DB에 접근해야 한다.

### 8.5 Masonry 목록 (매물/일반)

**masonry-item-default.php** (`v7/widgets/post/list/masonry-item-default.php:25`):
```php
$_isBlockedPost = !empty($_blockedMemberIds) && in_array($post->idx_member, $_blockedMemberIds);
```

**masonry-item-realestate.php** (`v7/widgets/post/list/masonry-item-realestate.php:29`):
```php
$_isBlockedPost = !empty($_blockedMemberIds) && in_array($re->idx_member, $_blockedMemberIds);
```

- 매장 목록, 부동산 목록에서도 동일한 차단 패턴 사용
- `$_blockedMemberIds` 변수는 부모 페이지에서 주입됨

### 8.6 지역 페이지 차단 필터링

**파일**: `v7/post/region.php:144-146,182-184`

```php
// 차단/블라인드 글 스킵 (목록에서 아예 제거)
$isBlocked = !empty($_blockedMemberIds) && in_array($post->idx_member, $_blockedMemberIds);
$isBlind = $post->blind === 'Y';
if ($isBlocked || $isBlind) continue;
```

- 지역 페이지에서는 차단된 글을 "차단됨" 표시가 아닌 **아예 건너뛰기** 처리
- 자유게시판 + 중고장터 모두 동일 패턴

---

## 9. 차단 목록 관리 페이지 (blocked.php)

**파일**: `v7/user/blocked.php` (179줄)

**URL**: `https://v7-local.philgo.com/user/blocked`
**URL 헬퍼**: `url()->user->blocked`

Vue.js Options API로 구현된 차단 사용자 관리 페이지.

```php
// SEO 설정
Seo::title('차단한 사용자 - 필고');
Seo::description('내가 차단한 사용자 목록을 관리합니다');
Seo::canonical('https://www.philgo.com/user/blocked');

// 로그인 확인
$loginUser = AuthService::getLoginUser();
```

**Vue.js 앱 구조** (마운트: `#blocked-members-app`):

```javascript
Vue.createApp({
    data: function () {
        return {
            members: [],       // 차단 사용자 목록
            loading: true,     // 로딩 상태
            error: '',         // 에러 메시지
            unblocking: {}     // 해제 중인 사용자 idx → true
        };
    },
    mounted: function () {
        this.loadMembers();  // 페이지 로드 시 자동 조회
    },
    methods: {
        loadMembers: async function () {
            this.loading = true;
            try {
                var data = await getBlockedMembers();
                this.members = Array.isArray(data) ? data : [];
            } catch (e) {
                this.error = e.message || '차단 목록을 불러오지 못했습니다.';
            } finally {
                this.loading = false;
            }
        },
        doUnblock: async function (member) {
            if (!confirm('"' + (member.nickname || '알 수 없음') + '"의 차단을 해제하시겠습니까?')) return;
            this.unblocking[member.idx_blockee] = true;
            try {
                await unblockMember(member.idx_blockee);
                this.members = this.members.filter(function (m) {
                    return m.idx_blockee !== member.idx_blockee;
                });
            } catch (e) {
                alert(e.message || '차단 해제에 실패했습니다.');
            } finally {
                delete this.unblocking[member.idx_blockee];
            }
        },
        formatDate: function (timestamp) {
            if (!timestamp) return '';
            var d = new Date(timestamp * 1000);
            return d.getFullYear() + '.' + String(d.getMonth() + 1).padStart(2, '0') + '.' + String(d.getDate()).padStart(2, '0');
        },
        getInitial: function (nickname) {
            return (nickname || '?').substring(0, 1);
        }
    }
}).mount('#blocked-members-app');
```

**UI 상태**:
- **비로그인**: "로그인 후 이용해 주세요" + 로그인 버튼
- **로딩 중**: 스피너
- **에러**: 에러 메시지 + 재시도 버튼
- **빈 목록**: "차단한 사용자가 없습니다" (fa-face-smile 아이콘)
- **차단 목록**: wa-avatar + 닉네임 + 차단일(YYYY.MM.DD) + 해제 버튼

> **주의**: `wa-button`의 `:disabled` 바인딩은 Web Component 특성상 `null`을 반환해야 속성이 제거된다.
> `!!expr` 대신 `expr || null` 패턴을 사용해야 한다.

**CSS**: `v7/user/blocked.css` (141줄)
- `.blocked-page-header`: 페이지 제목 섹션
- `.blocked-member-list`: 차단 목록 컨테이너
- `.blocked-member-item`: 각 차단 사용자 아이템 (flex row)
- `.blocked-member-info`: 아바타 + 텍스트 영역
- `.blocked-empty`: 빈 목록 상태

---

## 10. 관리자 차단 시스템

### 10.1 차단 로직

**파일**: `lib/user/user.block.php:19-47`

```php
function block_user(int $idx_member, string $reason): array
{
    $user = get_user_by_idx($idx_member, '*');
    if (!$user) {
        error('user-not-found-for-block', '차단할 사용자가 존재하지 않습니다.');
    }

    $block_count = $user[BLOCK_COUNT] ?? 0;
    $block_count++;

    // 차단 기간: 30분 × 차단횟수
    // 1차=30분, 2차=60분, 3차=90분, ... 10차=300분(5시간)
    $block_until = time() + 60 * 30 * $block_count;

    $block_data = [
        BLOCK_COUNT => $block_count,      // int_8
        BLOCK_REASON => $reason,          // text_5
        BLOCK_TIME => $block_until,       // int_9
    ];
    update_user($idx_member, $block_data);

    $updated = get_user_by_idx($idx_member, '*');
    return trim_falsy_values($updated);
}
```

**차단 시간 공식**: `차단해제시각 = 현재시간 + (30분 × 차단횟수)`

| 차단 횟수 | 차단 기간 |
|-----------|----------|
| 1차 | 30분 |
| 2차 | 60분 |
| 3차 | 90분 |
| 5차 | 150분 (2.5시간) |
| 10차 | 300분 (5시간) |

### 10.1a v7 관리자 차단 API (user.adminBlock)

**v6 `block_user()` 동일 로직을 v7 아키텍처로 구현.**

| 항목 | 내용 |
|------|------|
| **API** | `api.php?method=user.adminBlock` |
| **Controller** | `UserController::adminBlock()` |
| **Service** | `UserService::adminBlock()` |
| **권한** | `AuthService::isAdmin()` — `etc/app.config.php`의 `ADMINS` 배열(firebase_uid 목록)에 포함된 사용자만 true |
| **입력** | `idx_member`(필수), `reason`(필수), `idx_post`(선택 — 블라인드 처리할 글/코멘트 idx) |

**처리 순서:**

1. `AuthService::isAdmin()` 관리자 확인 (ADMINS firebase_uid 배열 기반)
2. `sf_member.int_8`(BLOCK_COUNT) 증가
3. `sf_member.int_9`(BLOCK_TIME) = `time() + 60 * 30 * count`
4. `sf_member.text_5`(BLOCK_REASON) = 사유 텍스트
5. `idx_post`가 있으면 해당 글/코멘트 `blind='Y'`, `text_8=사유` 설정
6. Firebase RTDB 채팅 메시지 전송 (`UserService::sendChatMessage()`)

**프론트엔드 동작:**

1. 관리자가 글/코멘트 "차단" 버튼 클릭 → `showAdminBlockDialog()` (wa-dialog 모달)
2. 4가지 차단 사유 중 라디오 선택 → 즉시 `v7api('user.adminBlock')` 호출
3. 성공 시 1초 후 페이지 새로고침 → 블라인드 상태 반영

**차단 사유 선택지:**
- 다중 아이디로 동일 광고 등록
- 스팸
- 시비성 또는 모욕성 글 등록
- 광고 게시판이 아닌 곳에 광고

**관련 JS 파일:** `v7/js/admin-block.js`, `v7/js/post-actions.js`, `v7/js/comment.js`

> **⚠️ `AuthService::isAdmin()` 판별 기준**: `etc/app.config.php`의 `ADMINS` 상수(firebase_uid 배열)에 현재 로그인 사용자의 `firebase_uid`가 포함되어 있으면 `true`. `sf_member.admin` 컬럼이 아닌 **ADMINS 배열** 기반이므로, 관리자를 추가하려면 `etc/app.config.php`의 `ADMINS` 배열에 firebase_uid를 추가해야 한다.

### 10.1b PHP에서 Firebase 채팅 메시지 전송 (UserService::sendChatMessage)

**관리자 차단 시 차단된 사용자에게 채팅 알림을 전송한다.**

```php
UserService::sendChatMessage(string $senderUid, string $receiverUid, string $text): void
```

- 1:1 채팅방 roomId = `sort([$uid1, $uid2])` → `implode('---', $uids)`
- `/chat/messages/{roomId}/{pushKey}` 에 메시지 write
- Cloud Functions `onChatMessageCreated` 트리거가 자동으로 joins, unread, FCM 푸시 알림 처리

### 10.2 차단 확인

**파일**: `lib/user/user.block.php:75-78`

```php
function blocked_user(array $login_user): bool
{
    return isset($login_user[BLOCK_TIME]) && $login_user[BLOCK_TIME] > time();
}
```

- `BLOCK_TIME(int_9)` > 현재시간 → 차단 중
- `BLOCK_TIME(int_9)` <= 현재시간 → 차단 해제 (자동)

**차단 상태 검사**: `lib/user/user.block.php:61-68`

```php
function error_if_blocked(array $login_user, string $error_code, string $error_message): void
{
    if (blocked_user($login_user)) {
        error($error_code, $error_message);
    }
}
```

### 10.3 관리자 차단 사용자 목록 페이지

**파일**: `v7/admin/blocked-users.php`
**URL**: `/admin/blocked-users`

- `sf_member WHERE int_8 > 0` (BLOCK_COUNT > 0) 조건으로 차단 이력 있는 사용자 조회
- 검색 기능: 이름, 닉네임, 이메일, 전화번호, idx
- 페이지네이션: limit=30

---

## 11. 접근 경로 및 라우팅

**차단 목록 페이지 접근 경로**:

1. 설정 페이지 → "차단한 사용자" 링크 (`url()->user->settings` → `url()->user->blocked`)
2. 사이드바 설정 메뉴 → 설정 페이지 → 차단한 사용자 링크
3. 글 보기 → 액션바 차단/해제 버튼 (타인 글에만 표시)
4. 글 보기 → 코멘트 액션 차단/해제 버튼 (타인 댓글에만 표시)
5. 공개 프로필 → 차단 버튼

**API 라우팅** (`api.php`):
- method 파라미터 파싱: `"user.toggleBlock"` → module=`"user"`, action=`"toggleBlock"`
- FQCN 생성: `Philgo\User\UserController`
- `$controller->toggleBlock($input)` 호출

---

## 12. 차단 플로우 다이어그램

### 12.1 회원 간 차단 플로우

```
사용자 A가 프로필/액션바에서 차단 버튼 클릭
  ↓
JS: toggleBlockMember(idxBlockee)
  ↓
v7api('user.toggleBlock', { idx_blockee })
  ↓
api.php → UserController::toggleBlock()
  ↓
AuthService::getLoginUser() → idx_blocker
  ↓
Db::fetch() → 현재 차단 여부 확인
  ↓
┌─ 미차단 → INSERT INTO sf_member_blocks
│            → UserService::syncBlockToFirebase(true)
│            → { blocked: true }
│
└─ 이미 차단 → DELETE FROM sf_member_blocks
               → UserService::syncBlockToFirebase(false)
               → { blocked: false }
  ↓
Firebase RTDB: user-private/{A_uid}/blocks/{B_uid} 동기화
  ↓
UI 업데이트 (location.reload 또는 버튼 상태 변경)
```

### 12.2 차단된 글 클릭 플로우

```
사용자가 글 목록에서 차단된 글 클릭
  ↓
confirmUnblockAndView(idxBlockee, 'post', targetUrl)
  ↓
confirm('차단된 사용자의 글입니다.\n차단을 해제하고 내용을 확인하시겠습니까?')
  ↓
┌─ 취소 → return false (아무것도 안 함)
│
└─ 확인 → unblockMember(idxBlockee)
          → DELETE FROM sf_member_blocks
          → Firebase RTDB 동기화
          → location.href = targetUrl (글 보기로 이동)
```

### 12.3 글 목록 필터링 플로우

```
글 목록 페이지 로드 (list.php, latest.php, region.php 등)
  ↓
v7 로그인 사용자 확인 → $_v7LoginUser
  ↓
Db::fetchAll("SELECT idx_blockee FROM sf_member_blocks WHERE idx_blocker = ?")
  ↓
$_blockedMemberIds = [100, 200, 300, ...]
  ↓
각 글/코멘트에 대해:
  $_isBlockedPost = in_array($post->idx_member, $_blockedMemberIds)
  ↓
┌─ true → 차단 UI 표시 (post-tile-blocked, confirmUnblockAndView)
│         또는 아예 스킵 (region.php)
│
└─ false → 정상 표시
```

---

## 13. 테스트

### 유닛 테스트

**파일**: `tests/Unit/MemberBlockTest.php`

| 테스트 | 설명 |
|--------|------|
| sf_member_blocks 테이블 존재 | DB 테이블 확인 |
| 필수 컬럼 존재 | idx, idx_blocker, idx_blockee, created_at |
| is_member_blocked() | 차단되지 않은 사용자 조합 |
| get_my_blocked_member_ids() | 비로그인 시 빈 배열 |
| get_blocked_members() | 비로그인 시 빈 배열 |
| clear_blocked_member_cache() | 에러 없이 실행 |
| MEMBER_BLOCKS_TABLE 상수 | 값 확인 |
| DB CRUD 통합 테스트 | INSERT → 확인 → DELETE → 확인 |
| v7 파일 존재 확인 | blocked.php, block.js, blocked.css |
| URL 경로 확인 | url()->user->blocked |

### 브라우저 테스트

**파일**: `tests/Browser/BlockTest.php`

| 테스트 | 설명 |
|--------|------|
| 비로그인 차단 목록 | "차단한 사용자" 제목 + "로그인 후 이용해 주세요" |
| 로그인 차단 목록 | Vue 앱 마운트 컨테이너 확인 |
| 설정 페이지 링크 | "/user/blocked" 링크 존재 |
| 레이아웃 확인 | v7 페이지 구조 확인 |
| block.js 함수 로드 | confirmUnblockAndView, toggleBlockMember, getBlockedMembers |
| 글 상세 data 속성 | data-is-blocked 속성 존재 |

**실행 명령**:
```bash
# 유닛 테스트
./vendor/bin/pest tests/Unit/MemberBlockTest.php

# 브라우저 테스트
./vendor/bin/pest tests/Browser/BlockTest.php
```
