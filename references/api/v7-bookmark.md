# v7 Bookmark API

## 목차

1. [개요](#1-개요)
2. [DB 테이블 구조](#2-db-테이블-구조)
3. [DB 사용 주의사항](#3-db-사용-주의사항)
4. [파일 구조](#4-파일-구조)
5. [API 엔드포인트](#5-api-엔드포인트)
6. [채팅방 즐겨찾기 연동](#6-채팅방-즐겨찾기-연동)
7. [웹 프론트엔드 연동](#7-웹-프론트엔드-연동)

---

## 1. 개요

Bookmark 모듈은 범용 즐겨찾기(북마크) 시스템으로, 게시글/댓글/사용자/채팅방 등 다양한 엔티티를 즐겨찾기에 추가할 수 있다.
즐겨찾기는 **그룹(폴더)** 단위로 분류할 수 있으며, 그룹이 없으면 `default` 그룹이 자동 생성된다.

| 항목 | 설명 |
|------|------|
| **네임스페이스** | `Philgo\Bookmark` |
| **API 접두사** | `bookmark.*` |
| **DB 테이블** | `bookmarks`, `bookmark_groups` |
| **인증** | 로그인 필수 (`AuthService::getLoginUser()`) |
| **주요 사용처** | 채팅방 즐겨찾기 (`entity_type='chat_room'`, `entity_id=roomId`) |

### 마이그레이션 이력

채팅방 즐겨찾기는 원래 **Firebase RTDB** + **Cloud Functions**(`onFavorite`)로 구현되어 있었으나,
v7 API 기반 `bookmarks`/`bookmark_groups` MariaDB 테이블로 마이그레이션되었다.

| 항목 | 변경 전 (Firebase) | 변경 후 (v7 API) |
|------|-------------------|-----------------|
| **데이터 저장소** | Firebase RTDB `chat/favorites/{uid}/{folder}`, `chat/favorites-folder-list/{uid}` | MariaDB `bookmarks`, `bookmark_groups` 테이블 |
| **폴더 목록 조회** | Firebase `on('value')` 실시간 리스너 | `v7api('bookmark.listGroups', { entity_type: 'chat_room' })` |
| **즐겨찾기 추가** | Cloud Function `onFavorite` 호출 | `v7api('bookmark.add', { group_name, entity_type: 'chat_room', entity_id: roomId })` |
| **폴더별 목록 조회** | Firebase `once('value')` | `v7api('bookmark.listByGroup', { idx_group, entity_type: 'chat_room' })` |
| **내 즐겨찾기 ID 목록** | 없음 (각 방의 `room.favorite` 필드 참조) | `v7api('bookmark.myBookmarkedIds', { entity_type: 'chat_room' })` |
| **별 아이콘 표시 기준** | 각 방의 `room.favorite` 필드 | `state.bookmarkedRoomIds` 배열에 roomId 포함 여부 |

---

## 2. DB 테이블 구조

### bookmarks 테이블

```sql
CREATE TABLE `bookmarks` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '즐겨찾기한 회원 idx',
  `idx_group` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '그룹 idx (0이면 미분류)',
  `entity_type` varchar(20) NOT NULL COMMENT '대상 타입: post, comment, user, chat_room',
  `entity_idx` int(10) UNSIGNED NOT NULL COMMENT '대상의 idx',
  `entity_id` varchar(100) NOT NULL DEFAULT '' COMMENT '문자열 대상 ID (채팅방 등)',
  `memo` varchar(255) NOT NULL DEFAULT '' COMMENT '사용자 메모 (선택)',
  `created_at` int(10) UNSIGNED NOT NULL COMMENT '생성 Unix timestamp',
  PRIMARY KEY (`idx`),
  UNIQUE KEY `uk_member_entity` (`idx_member`, `entity_type`, `entity_idx`, `entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='즐겨찾기/북마크';
```

### bookmark_groups 테이블

```sql
CREATE TABLE `bookmark_groups` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '그룹 소유자',
  `name` varchar(50) NOT NULL COMMENT '그룹명',
  `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '정렬 순서',
  `created_at` int(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='북마크 그룹';
```

### entity_type 값 규약

| entity_type | entity_idx | entity_id | 설명 |
|------------|-----------|----------|------|
| `chat_room` | 0 | 채팅방 ID (예: `uid1_uid2`) | 채팅방 즐겨찾기 |
| `post` | 게시글 idx | `` | 게시글 즐겨찾기 |
| `comment` | 댓글 idx | `` | 댓글 즐겨찾기 |
| `user` | 회원 idx | `` | 사용자 즐겨찾기 |

### 즐겨찾기 호환성 -- 그룹은 entity_type 무관하게 공유

`bookmark_groups` 테이블에는 `entity_type` 필드가 **없다**. 따라서 채팅방/게시글/코멘트/사용자 모든 엔티티가 **동일한 그룹을 공유**한다.

| 호출 방법 | count 동작 |
|----------|-----------|
| `bookmark.listGroups` (entity_type 미전달) | 전체 항목 수가 `count`로 표시 |
| `bookmark.listGroups` (entity_type='post') | 해당 타입 항목만 `count`에 포함 |

예를 들어 "가족" 그룹에 게시글 3개 + 채팅방 2개가 있을 때, entity_type 없이 호출하면 `count: 5`, `entity_type='post'`로 호출하면 `count: 3`이 반환된다.

---

## 3. DB 사용 주의사항

### LIMIT 바인딩 주의사항

`Db::fetchAll()` 사용 시 `LIMIT ?`에 파라미터를 바인딩하면 PDO가 문자열로 처리하여 SQL 문법 에러가 발생한다. LIMIT 값은 `"LIMIT " . (int)$limit` 형태로 직접 SQL에 삽입해야 한다. 이는 `Db::fetch()`, `Db::fetchAll()` 등 모든 Db 헬퍼 메서드에 공통 적용된다.

```php
// ❌ 잘못된 방법: LIMIT에 ? 바인딩 → SQL 문법 에러 발생
$rows = Db::fetchAll(
    "SELECT * FROM bookmarks WHERE idx_member = ? ORDER BY created_at DESC LIMIT ?",
    [$idxMember, $limit]
);

// ✅ 올바른 방법: LIMIT 값을 (int) 캐스팅 후 SQL에 직접 삽입
$rows = Db::fetchAll(
    "SELECT * FROM bookmarks WHERE idx_member = ? ORDER BY created_at DESC LIMIT " . (int)$limit,
    [$idxMember]
);
```

> **참고**: 이 제한은 PDO의 기본 동작에 기인한다. `PDO::ATTR_EMULATE_PREPARES`가 false인 경우, `?` 바인딩 값은 항상 문자열로 전달되어 `LIMIT '3'`처럼 따옴표가 붙어 문법 에러가 발생한다.

---

## 4. 파일 구조

### 백엔드 파일

```
lib/bookmark/
├── BookmarkEntity.php        # bookmarks 테이블 Entity
├── BookmarkGroupEntity.php   # bookmark_groups 테이블 Entity
├── BookmarkService.php       # 비즈니스 로직 (그룹/항목 CRUD, getBookmarkedIdxs)
└── BookmarkController.php    # API 엔드포인트 (bookmark.*, listByGroup enrichment)
```

### 웹 프론트엔드 파일

```
v7/js/bookmark.js             # 공통 즐겨찾기 JS 모듈 (bookmarkToggle, bookmarkShowGroupDialog, bookmarkRemove)
v7/bookmark/index.php         # 즐겨찾기 관리 페이지 (그룹 CRUD + 목록 + 해제)
v7/bookmark/index.css         # 즐겨찾기 관리 페이지 CSS
v7/widgets/layout/layout.sidebar-left.bookmarks.php  # 사이드바 즐겨찾기 위젯 (최근 3개)
```

### BookmarkEntity 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | `int` | 고유 ID |
| `idx_member` | `int` | 소유자 회원 idx |
| `idx_group` | `int` | 그룹 idx (0이면 미분류) |
| `entity_type` | `string` | 대상 타입 |
| `entity_idx` | `int` | 대상 정수 idx |
| `entity_id` | `string` | 대상 문자열 ID |
| `memo` | `string` | 사용자 메모 |
| `created_at` | `int` | 생성 Unix timestamp |
| `group_name` | `string` | 그룹명 (JOIN 시 계산) |
| `subject` | `string` | (enrichment) 게시글 제목 (entity_type='post'일 때) |
| `post_id` | `string` | (enrichment) 게시판 ID (entity_type='post'일 때) |
| `parent_idx` | `int` | (enrichment) 부모 글 idx (entity_type='comment'일 때) |
| `content_preview` | `string` | (enrichment) 내용 미리보기 80자 (entity_type='comment'일 때) |
| `nickname` | `string` | (enrichment) 닉네임 (entity_type='user'일 때) |
| `photo_url` | `string` | (enrichment) 프로필 사진 URL (entity_type='user'일 때) |
| `other_name` | `string` | (enrichment) 채팅 상대방 이름 (entity_type='chat_room'일 때) |
| `other_nickname` | `string` | (enrichment) 채팅 상대방 닉네임 (entity_type='chat_room'일 때) |
| `other_photo_url` | `string` | (enrichment) 채팅 상대방 프로필 사진 URL (entity_type='chat_room'일 때) |

> **enrichment 필드**: `bookmark.listByGroup` API 응답에서만 포함된다. `entity_type`에 따라 해당 필드가 동적으로 추가됨.

### BookmarkGroupEntity 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | `int` | 고유 ID |
| `idx_member` | `int` | 소유자 회원 idx |
| `name` | `string` | 그룹명 |
| `sort_order` | `int` | 정렬 순서 |
| `created_at` | `int` | 생성 Unix timestamp |
| `count` | `int` | 그룹 내 즐겨찾기 개수 (JOIN 시 계산) |

---

## 5. API 엔드포인트

### bookmark.createGroup -- 그룹 생성

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.createGroup&name=가족` |
| **인증** | 필수 |
| **입력** | `name` (string, 필수) -- 그룹명 |
| **출력** | `BookmarkGroupEntity` |

### bookmark.deleteGroup -- 그룹 삭제

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.deleteGroup&idx_group=5` |
| **인증** | 필수 |
| **입력** | `idx_group` (int, 필수) -- 그룹 idx |
| **출력** | `{ deleted: true }` |
| **부수 효과** | 그룹 하위 즐겨찾기도 함께 삭제 |

### bookmark.listGroups -- 내 그룹 목록

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.listGroups&entity_type=chat_room` |
| **인증** | 필수 |
| **입력** | `entity_type` (string, 선택) -- 타입 필터. 생략 시 전체 entity_type 합산 count |
| **출력** | `{ groups: BookmarkGroupEntity[] }` -- 각 그룹에 `count` 포함 |
| **참고** | `bookmark_groups` 테이블에 `entity_type` 필드가 없으므로 그룹 자체는 모든 타입에서 공유됨 |

### bookmark.add -- 즐겨찾기 추가

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.add&group_name=가족&entity_type=chat_room&entity_id=uid1_uid2` |
| **인증** | 필수 |
| **입력** | `group_name` (string), `entity_type` (string, 필수), `entity_id` (string), `entity_idx` (int), `memo` (string) |
| **출력** | `BookmarkEntity` |
| **특이사항** | 그룹이 없으면 자동 생성. 이미 존재하면 그룹만 변경. `group_name`이 빈 문자열이면 `default` 그룹 사용 |

### bookmark.remove -- 즐겨찾기 제거

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.remove&entity_type=chat_room&entity_id=uid1_uid2` |
| **인증** | 필수 |
| **입력** | `entity_type` (string, 필수), `entity_id` (string), `entity_idx` (int) |
| **출력** | `{ removed: true/false }` |

### bookmark.listByGroup -- 그룹별 즐겨찾기 목록

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.listByGroup&idx_group=5&entity_type=chat_room` |
| **인증** | 필수 |
| **입력** | `idx_group` (int, 필수), `entity_type` (string, 선택) |
| **출력** | `{ bookmarks: BookmarkEntity[] }` |
| **enrichment** | entity_type에 따라 추가 정보를 자동으로 JOIN하여 반환 |

**entity_type별 enrichment 추가 필드:**

| entity_type | 추가 필드 | 데이터 소스 |
|------------|----------|------------|
| `post` | `subject`, `post_id` | `sf_post_data` 테이블 |
| `comment` | `parent_idx` (idx_root), `content_preview` (80자) | `sf_post_data` 테이블 |
| `user` | `nickname`, `photo_url` | `sf_member` 테이블 |
| `chat_room` | `other_name`, `other_nickname`, `other_photo_url` | `sf_member` 테이블 (firebase_uid로 상대방 조회) |

**chat_room enrichment 상세:**

채팅방 즐겨찾기의 enrichment는 다음 로직으로 상대방 정보를 추출한다.

1. 로그인 사용자의 `firebase_uid`를 `sf_member` 테이블에서 1회 조회 (루프 밖에서 실행하여 N+1 방지)
2. `entity_id`(roomId) 형식인 `uid1---uid2`를 `---` 구분자로 분리
3. 로그인 사용자의 UID가 아닌 쪽을 상대방 UID로 결정
4. `sf_member` 테이블에서 상대방의 `name`, `nickname`, `photo_url` 조회
5. 응답에 `other_name`, `other_nickname`, `other_photo_url` 필드로 추가

### bookmark.myBookmarkedIds -- 내 즐겨찾기 ID 목록

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.myBookmarkedIds&entity_type=chat_room` |
| **인증** | 필수 |
| **입력** | `entity_type` (string, 필수) |
| **출력** | `{ ids: string[] }` -- entity_id 문자열 배열 |

---

## 6. 채팅방 즐겨찾기 연동

채팅 시스템에서 즐겨찾기 기능은 다음과 같이 v7 API를 호출한다.

### JS 파일별 변경 사항

| JS 파일 | 변경된 함수 | 변경 내용 |
|---------|-----------|----------|
| `chat-store.js` | `loadFavoriteFolders()` | Firebase `on('value')` 리스너 -> `v7api('bookmark.listGroups')` 호출 |
| `chat-store.js` | `loadBookmarkedRoomIds()` | 신규 추가. `v7api('bookmark.myBookmarkedIds')` 호출하여 `state.bookmarkedRoomIds` 배열 설정 |
| `chat-app.js` | `initApp()` | `loadBookmarkedRoomIds()` 호출 추가 |
| `chat-single-room.js` | `saveFavorite()` | Cloud Function -> `v7api('bookmark.add')` 호출로 변경 |
| `chat-room-list.js` | `openFavFolder()` | Firebase `once('value')` -> `v7api('bookmark.listByGroup')` 호출로 변경 |
| `chat-room-list.js` | 별 아이콘 표시 | `room.favorite` 필드 -> `state.bookmarkedRoomIds.includes(roomId)` 로 변경 |

### v7ChatState 변경

```javascript
// 추가된 상태 필드
bookmarkedRoomIds: [],  // 내 즐겨찾기 채팅방 ID 목록 (bookmark.myBookmarkedIds에서 로드)
```

### 호출 흐름

```
[채팅 앱 초기화]
    │
    ├─ v7ChatActions.loadFavoriteFolders()
    │   └─ v7api('bookmark.listGroups', { entity_type: 'chat_room' })
    │       → state.favoriteFolders = groups
    │
    ├─ v7ChatActions.loadBookmarkedRoomIds()
    │   └─ v7api('bookmark.myBookmarkedIds', { entity_type: 'chat_room' })
    │       → state.bookmarkedRoomIds = ids
    │
    [채팅방 내 즐겨찾기 추가]
    │
    ├─ saveFavorite()
    │   └─ v7api('bookmark.add', { group_name, entity_type: 'chat_room', entity_id: roomId })
    │       → loadFavoriteFolders() + loadBookmarkedRoomIds() 재호출
    │
    [즐겨찾기 폴더 열기]
    │
    └─ openFavFolder(group)
        └─ v7api('bookmark.listByGroup', { idx_group: group.idx, entity_type: 'chat_room' })
            → favModalRooms = bookmarks
```

---

## 7. 웹 프론트엔드 연동

### 7.1 공통 즐겨찾기 JS 모듈 (`v7/js/bookmark.js`)

글, 코멘트, 사용자 프로필 등에서 즐겨찾기 추가/제거 기능을 제공하는 공통 JS 모듈이다. 의존: `v7/js/v7api.js`.

| 함수 | 설명 |
|------|------|
| `bookmarkToggle(entityType, entityIdx, isBookmarked, callback)` | 즐겨찾기 토글 -- 이미 되어있으면 제거, 아니면 그룹 선택 다이얼로그 표시 후 추가 |
| `bookmarkShowGroupDialog(entityType, entityIdx, callback)` | 그룹 선택 다이얼로그 표시 (기존 그룹 선택 / 새 그룹 생성 / 기본 그룹 추가) |
| `bookmarkRemove(entityType, entityIdx, callback)` | 즐겨찾기 제거 (직접 호출용) |

**그룹 선택 다이얼로그 동작:**

1. `v7api('bookmark.listGroups', {})` 호출로 전체 그룹 목록 로드 (entity_type 미전달 -- 전체 count 표시)
2. 기존 그룹 버튼 클릭 시 해당 그룹에 추가
3. 새 그룹명 입력 후 추가 버튼 클릭 시 그룹 자동 생성 + 추가
4. "기본 그룹에 추가" 클릭 시 `default` 그룹에 추가
5. 다이얼로그는 Web Awesome Pro `wa-dialog` 컴포넌트 사용

**사용 예시 (Vue.js 메서드에서):**

```javascript
doToggleBookmark: function () {
    var self = this;
    bookmarkToggle('post', this.idx, this.bookmarked, function (result) {
        self.bookmarked = result.bookmarked;
    });
}
```

### 7.2 글 보기 페이지 (`v7/post/view.php` + `v7/js/post-actions.js`)

글 보기 페이지 액션바에 즐겨찾기 버튼이 추가되었다.

**SSR 측 (view.php):**

- `BookmarkService::getBookmarkedIdxs($loginUser->idx, 'post', [$post->idx])` 호출로 현재 글의 즐겨찾기 상태 확인
- `BookmarkService::getBookmarkedIdxs($loginUser->idx, 'comment', $_commentIdxs)` 호출로 코멘트들의 즐겨찾기 상태 일괄 확인
- 즐겨찾기 상태를 `data-bookmarked="1"` / `data-bookmarked="0"` HTML 속성으로 전달

**CSR 측 (post-actions.js):**

- 로그인 사용자에게만 즐겨찾기 버튼 표시 (`v-if="canBookmark"`)
- 별 아이콘: 즐겨찾기 됨 → `fa-solid fa-star`, 안 됨 → `fa-regular fa-star`
- 클릭 시 `bookmarkToggle('post', idx, isBookmarked, callback)` 호출
- 스피너 표시 중 중복 클릭 방지 (`bookmarking` 상태)

### 7.3 코멘트 즐겨찾기 (`v7/js/comment.js`)

코멘트 액션에 즐겨찾기 버튼이 추가되었다.

- 로그인 사용자에게만 표시 (`v-if="canBookmark"`)
- `bookmarkToggle('comment', idx, isBookmarked, callback)` 호출
- SSR에서 `data-bookmarked` 속성으로 초기 상태 전달
- 글 보기 페이지와 동일한 별 아이콘 + 스피너 패턴 사용

### 7.4 타인 프로필 페이지 (`v7/user/public-profile.php`)

타인의 공개 프로필 페이지에 즐겨찾기 버튼이 추가되었다.

- SSR: `BookmarkService::getBookmarkedIdxs($loginUser->idx, 'user', [$user->idx])` 호출로 즐겨찾기 상태 확인
- 즐겨찾기 버튼: `wa-button` 컴포넌트 + `data-bookmarked` 속성
- 클릭 시 `bookmarkToggle('user', entityIdx, isBookmarked, callback)` 호출
- 즐겨찾기 추가 시 별 아이콘 노란색(`#f59e0b`), variant `brand`로 변경

### 7.5 즐겨찾기 관리 페이지 (`v7/bookmark/index.php`)

즐겨찾기를 통합 관리하는 전용 페이지이다.

| 항목 | 값 |
|------|---|
| **URL** | `url()->bookmark->home` → `/bookmark` |
| **라우팅** | `/bookmark` → `v7.php` → `v7/layout.php` → `v7/bookmark/index.php` |
| **구현 방식** | Vue.js 3 CDN 기반 CSR |
| **인증** | 비로그인 시 로그인 유도 UI 표시 |

**주요 기능:**

- 그룹 목록 사이드바 (그룹별 항목 count 표시)
- 그룹 생성/삭제 (그룹 삭제 시 하위 항목도 함께 삭제)
- 그룹별 즐겨찾기 목록 표시 (entity_type별 enrichment 정보 포함)
- 즐겨찾기 해제 기능
- 모든 entity_type(글, 코멘트, 사용자, 채팅방) 통합 관리
- 채팅방 항목에 상대방 프로필 사진(원형 아바타) + 이름/닉네임 표시

**채팅방 즐겨찾기 항목 표시 로직:**

| 요소 | 표시 내용 | 폴백 |
|------|----------|------|
| **아이콘 영역** | `other_photo_url`이 있으면 원형 아바타 이미지, 없으면 기본 채팅 아이콘 | `.bookmark-chat-avatar` (32px 원형) |
| **제목** | `other_name` → `other_nickname` → `entity_id` 순서로 폴백 | 이름이 없으면 채팅방 ID 표시 |
| **서브텍스트** | `other_nickname`이 `other_name`과 다른 경우에만 닉네임 추가 표시 | `.bookmark-chat-sub` 스타일 |

**관련 파일:**

| 파일 | 설명 |
|------|------|
| `v7/bookmark/index.php` | 페이지 PHP + Vue.js 템플릿 |
| `v7/bookmark/index.css` | 페이지 전용 CSS (채팅방 아바타 `.bookmark-chat-avatar`, 서브텍스트 `.bookmark-chat-sub` 포함) |
| `v7/js/bookmark.js` | 공통 즐겨찾기 JS (그룹 선택 다이얼로그 등) |

### 7.6 BookmarkService::listRecent() 메서드

사이드바 즐겨찾기 위젯(`layout.sidebar-left.bookmarks.php`)에서 사용하는 메서드이다.
모든 entity_type의 최근 즐겨찾기를 enrichment 정보와 함께 반환한다.

```php
/**
 * 최근 즐겨찾기 목록 (enrichment 포함, 사이드바 위젯용)
 *
 * @param int $idxMember 회원 idx
 * @param int $limit 가져올 개수 (기본 3)
 * @return array enrichment가 포함된 즐겨찾기 배열
 */
public static function listRecent(int $idxMember, int $limit = 3): array
```

**enrichment 로직 (entity_type별):**

| entity_type | 추가 필드 | 데이터 소스 |
|------------|----------|------------|
| `post` | `subject`, `post_id` | `sf_post_data` 테이블 |
| `comment` | `parent_idx` (idx_root), `content_preview` (80자) | `sf_post_data` 테이블 |
| `user` | `nickname`, `photo_url` | `sf_member` 테이블 |
| `chat_room` | `other_name`, `other_nickname`, `other_photo_url` | `sf_member` 테이블 (firebase_uid로 상대방 조회) |

**chat_room enrichment 상세:**

1. 로그인 사용자의 `firebase_uid`를 `sf_member`에서 1회 조회 (루프 밖에서 실행하여 N+1 방지)
2. `entity_id`(roomId) 형식인 `uid1---uid2`를 `---` 구분자로 분리
3. 로그인 사용자의 UID가 아닌 쪽을 상대방 UID로 결정
4. `sf_member`에서 상대방의 `name`, `nickname`, `photo_url` 조회

**사용 예시:**

```php
use Philgo\Bookmark\BookmarkService;
use Philgo\Utils\AuthService;

$loginUser = AuthService::getLoginUser();
if ($loginUser !== null) {
    $recentBookmarks = BookmarkService::listRecent($loginUser->idx, 3);
    foreach ($recentBookmarks as $bm) {
        // $bm['entity_type'], $bm['subject'], $bm['nickname'] 등 접근 가능
    }
}
```

### 7.7 BookmarkService::getBookmarkedIdxs() 메서드

SSR에서 여러 entity_idx의 즐겨찾기 상태를 **한 번의 쿼리**로 일괄 확인하는 메서드이다.
(상세는 기존 내용 참조)

```php
/**
 * @param int $idxMember 회원 idx
 * @param string $entityType 대상 타입 (post, comment, user 등)
 * @param array<int> $entityIdxs 확인할 entity_idx 배열
 * @return array<int> 즐겨찾기된 entity_idx 배열
 */
public static function getBookmarkedIdxs(int $idxMember, string $entityType, array $entityIdxs): array
```

- `IN ($placeholders)` SQL 절로 한 번에 여러 idx를 조회 (N+1 문제 방지)
- 빈 배열 입력 시 쿼리 없이 빈 배열 반환
- 반환값은 즐겨찾기된 entity_idx만 포함하는 정수 배열

**SSR 사용 패턴:**

```php
// 글의 즐겨찾기 상태 확인
$bookmarkedPostIdxs = BookmarkService::getBookmarkedIdxs($loginUser->idx, 'post', [$post->idx]);
$isPostBookmarked = in_array($post->idx, $bookmarkedPostIdxs);

// 코멘트 목록의 즐겨찾기 상태 일괄 확인
$commentIdxs = array_map(fn($c) => $c->idx, $comments);
$bookmarkedCommentIdxs = BookmarkService::getBookmarkedIdxs($loginUser->idx, 'comment', $commentIdxs);
// HTML에서: data-bookmarked="<?= in_array($comment->idx, $bookmarkedCommentIdxs) ? '1' : '0' ?>"
```

### 7.8 연동 사용 페이지 요약

| 페이지 | entity_type | SSR 확인 | CSR 토글 | JS 파일 |
|--------|-------------|---------|---------|---------|
| `v7/post/view.php` | `post` | `getBookmarkedIdxs()` | `post-actions.js` | `bookmark.js` |
| `v7/post/view.php` | `comment` | `getBookmarkedIdxs()` | `comment.js` | `bookmark.js` |
| `v7/user/public-profile.php` | `user` | `getBookmarkedIdxs()` | 인라인 JS | `bookmark.js` |
| `v7/bookmark/index.php` | 전체 | -- | Vue.js CSR | `bookmark.js` |
| `v7/chat/index.php` | `chat_room` | -- | `chat-store.js` 등 | -- (채팅 전용 JS) |
| `v7/widgets/layout/layout.sidebar-left.bookmarks.php` | 전체 | `listRecent()` | -- (SSR 전용) | -- |
