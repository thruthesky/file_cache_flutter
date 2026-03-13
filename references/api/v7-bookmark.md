# v7 Bookmark API

## 목차

1. [개요](#1-개요)
2. [DB 테이블 구조](#2-db-테이블-구조)
3. [파일 구조](#3-파일-구조)
4. [API 엔드포인트](#4-api-엔드포인트)
5. [채팅방 즐겨찾기 연동](#5-채팅방-즐겨찾기-연동)

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
| `post` | 게시글 idx | `` | 게시글 즐겨찾기 (향후) |
| `comment` | 댓글 idx | `` | 댓글 즐겨찾기 (향후) |
| `user` | 회원 idx | `` | 사용자 즐겨찾기 (향후) |

---

## 3. 파일 구조

```
lib/bookmark/
├── BookmarkEntity.php        # bookmarks 테이블 Entity
├── BookmarkGroupEntity.php   # bookmark_groups 테이블 Entity
├── BookmarkService.php       # 비즈니스 로직 (그룹/항목 CRUD)
└── BookmarkController.php    # API 엔드포인트 (bookmark.*)
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

## 4. API 엔드포인트

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
| **입력** | `entity_type` (string, 선택) -- 타입 필터 |
| **출력** | `{ groups: BookmarkGroupEntity[] }` -- 각 그룹에 `count` 포함 |

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

### bookmark.myBookmarkedIds -- 내 즐겨찾기 ID 목록

| 항목 | 값 |
|------|---|
| **URL** | `/api.php?method=bookmark.myBookmarkedIds&entity_type=chat_room` |
| **인증** | 필수 |
| **입력** | `entity_type` (string, 필수) |
| **출력** | `{ ids: string[] }` -- entity_id 문자열 배열 |

---

## 5. 채팅방 즐겨찾기 연동

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
