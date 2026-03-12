# v7 1:1 채팅 시스템

## 목차

1. [개요](#1-개요)
2. [파일 구조](#2-파일-구조)
3. [아키텍처](#3-아키텍처)
4. [Firebase RTDB 데이터 구조](#4-firebase-rtdb-데이터-구조)
5. [채팅방 ID 규칙](#5-채팅방-id-규칙)
6. [PHP 페이지 — index.php](#6-php-페이지--indexphp)
7. [JS 파일별 상세 API](#7-js-파일별-상세-api)
   - 7.1 [chat-helpers.js — 설정, 상수, 헬퍼 함수](#71-chat-helpersjs--설정-상수-헬퍼-함수)
   - 7.2 [chat-store.js — 글로벌 반응형 스토어](#72-chat-storejs--글로벌-반응형-스토어)
   - 7.3 [chat-room-list.js — 채팅방 목록 컴포넌트](#73-chat-room-listjs--채팅방-목록-컴포넌트)
   - 7.4 [chat-single-room.js — 1:1 채팅방 컴포넌트](#74-chat-single-roomjs--11-채팅방-컴포넌트)
   - 7.5 [chat-search.js — 사용자 검색 컴포넌트](#75-chat-searchjs--사용자-검색-컴포넌트)
   - 7.6 [chat-app.js — Vue 앱 초기화](#76-chat-appjs--vue-앱-초기화)
8. [CSS 클래스 체계](#8-css-클래스-체계)
9. [주요 기능 목록](#9-주요-기능-목록)
10. [Cloud Functions 연동](#10-cloud-functions-연동)
11. [사운드 시스템](#11-사운드-시스템)
12. [이미지/파일 업로드 및 뷰어](#12-이미지파일-업로드-및-뷰어)
13. [layout.php 연동 — CSS/JS 조건부 로딩](#13-layoutphp-연동--cssjs-조건부-로딩)
14. [PEST 브라우저 테스트](#14-pest-브라우저-테스트)
15. [새 기능 추가 방법](#15-새-기능-추가-방법)

---

## 1. 개요

v7 1:1 채팅 시스템은 **Firebase Realtime Database(RTDB)** 기반의 실시간 1:1 채팅 기능이다. PHP(서버)는 로그인 확인과 설정값 전달만 담당하며, 채팅 데이터의 읽기/쓰기/구독은 모두 **클라이언트 JavaScript**에서 Firebase SDK를 직접 호출하여 처리한다.

| 항목 | 설명 |
|------|------|
| **렌더링 방식** | CSR (클라이언트 사이드 렌더링) — Vue.js 3 CDN + Firebase compat SDK |
| **데이터 저장소** | Firebase Realtime Database |
| **파일 저장소** | Firebase Storage |
| **인증** | Firebase Auth (PHP 로그인 + Firebase Custom Token) |
| **UI 프레임워크** | Web Awesome Pro (Bootstrap 미사용) |
| **다크 모드** | 미적용 (라이트 모드 전용) |
| **URL** | `/chat` → `v7/chat/index.php` |

### 핵심 설계 원칙

| 원칙 | 설명 |
|------|------|
| **Firebase 직접 접근** | PHP 서버를 거치지 않고, 클라이언트 JS에서 Firebase RTDB/Storage에 직접 읽기/쓰기 |
| **Vue.js Options API** | Composition API 금지. `data()`, `methods`, `computed`, `mounted` 등 Options API만 사용 |
| **컴포넌트 함수 패턴** | 각 컴포넌트는 `function v7ChatXxxComponent() { return { ... }; }` 형태로 정의 |
| **글로벌 스토어** | `Vue.reactive()`를 사용하여 `v7ChatState` 전역 반응형 상태 관리 |
| **v7chat- 접두어** | 모든 CSS 클래스에 `v7chat-` 접두어를 사용하여 네이밍 충돌 방지 |
| **조건부 로딩** | layout.php에서 `/chat` 경로일 때만 CSS/JS 파일을 로드 |

---

## 2. 파일 구조

```
v7/chat/
├── index.php              # 채팅 메인 페이지 (PHP — 로그인 확인, 설정 전달)
└── chat.css               # 채팅 전용 CSS (~1168줄)

v7/js/chat/
├── chat-helpers.js        # 설정, 상수, 헬퍼 함수 (가장 먼저 로드)
├── chat-store.js          # 글로벌 반응형 스토어 (Vue.reactive)
├── chat-room-list.js      # 채팅방 목록 Vue 컴포넌트
├── chat-single-room.js    # 1:1 채팅방 Vue 컴포넌트 (핵심)
├── chat-search.js         # 사용자 검색 Vue 컴포넌트
└── chat-app.js            # Vue 앱 초기화 (가장 마지막에 로드)

tests/Browser/
└── ChatTest.php           # PEST 브라우저 테스트 (9개 테스트 케이스)
```

### 파일별 역할 요약

| 파일 | 역할 | 줄 수 | 로드 순서 |
|------|------|------:|-----------|
| `chat-helpers.js` | 설정(v7ChatConfig), 상수(v7ChatRoute), 채팅방 ID 유틸, 시간 포맷, 파일 판별, URL 링크화, Firebase 작업(고정/신고), 무한 스크롤, 사운드 | ~291 | 1 |
| `chat-store.js` | `v7ChatState` 전역 반응형 상태, `v7ChatActions` 액션 (방 열기/닫기, 리스너 관리) | ~163 | 2 |
| `chat-room-list.js` | 채팅방 목록 표시, 무한 스크롤 페이지네이션, 고정/비고정 섹션 분리 | ~228 | 3 |
| `chat-single-room.js` | 메시지 전송/수신, 파일 업로드, 이미지 뷰어, 고정/즐겨찾기/차단/신고/커스텀이름/나가기 | ~844 | 4 |
| `chat-search.js` | 사용자 검색 (Firebase RTDB users 노드), 새 채팅 시작 | ~126 | 5 |
| `chat-app.js` | Firebase Auth 확인 후 Vue 앱 생성/마운트, 전역 리스너 초기화 | ~69 | 6 (최후) |

---

## 3. 아키텍처

### 3.1 전체 흐름

```
[사용자 브라우저]
    │
    ├─ (1) GET /chat → PHP(index.php): 로그인 확인, 설정값을 window.v7chat에 주입
    │
    ├─ (2) layout.php: /chat 경로 감지 → 채팅 CSS 1개 + JS 6개 defer 로드
    │
    ├─ (3) chat-app.js: firebase_ready() → onAuthStateChanged() → Vue 앱 마운트
    │
    ├─ (4) Vue 컴포넌트 라우팅 (state.route):
    │      ├─ "list"   → v7ChatRoomListComponent (채팅방 목록)
    │      ├─ "single" → v7ChatSingleRoomComponent (1:1 채팅방)
    │      └─ "search" → v7ChatSearchComponent (사용자 검색)
    │
    └─ (5) Firebase RTDB 실시간 리스너로 데이터 동기화
```

### 3.2 클라이언트 사이드 라우팅

채팅 앱 내에서 화면 전환은 `v7ChatState.route` 값을 변경하여 처리한다. URL이 변경되지 않는 SPA 스타일 라우팅이다.

```javascript
// 라우트 상수
const v7ChatRoute = {
    list: 'list',       // 채팅방 목록
    single: 'single',   // 1:1 채팅방
    search: 'search',   // 사용자 검색
};

// 라우트 전환 예시
v7ChatState.route = v7ChatRoute.single;  // 채팅방 열기
v7ChatState.route = v7ChatRoute.list;    // 목록으로 돌아가기
```

### 3.3 데이터 흐름

```
┌──────────────────┐     실시간 리스너     ┌────────────────────┐
│  Firebase RTDB   │ ◄──── on('value') ──► │  v7ChatState       │
│  /chat/joins     │      on('child_added')│  (Vue.reactive)    │
│  /chat/messages  │                       │                    │
│  /users          │                       │  .rooms            │
│  /user-private   │                       │  .myUid            │
│  /reports        │                       │  .route            │
└──────────────────┘                       │  .blockedUsers     │
                                           │  .pinnedChatRooms  │
      ┌────────────────────┐               │  .favoriteFolders  │
      │  Firebase Storage  │               └────────────────────┘
      │  /users/{uid}/...  │                         │
      └────────────────────┘                         ▼
              ▲                           ┌────────────────────┐
              │ 파일 업로드               │  Vue 컴포넌트       │
              └───────────────────────────│  (자동 렌더링)      │
                                          └────────────────────┘
```

### 3.4 JS 파일 로드 순서 및 의존성

```
chat-helpers.js      ← 의존성 없음 (독립 유틸리티)
    ↓
chat-store.js        ← chat-helpers.js의 상수/함수 사용
    ↓
chat-room-list.js    ← chat-helpers.js + chat-store.js 사용
chat-single-room.js  ← chat-helpers.js + chat-store.js 사용
chat-search.js       ← chat-helpers.js + chat-store.js 사용
    ↓
chat-app.js          ← 위 모든 파일이 로드된 후 Vue 앱 생성
```

모든 JS 파일은 `defer` 속성으로 로드되므로, HTML 파싱 후 순서대로 실행이 보장된다.

---

## 4. Firebase RTDB 데이터 구조

### 4.1 경로 맵

| Firebase 경로 | 설명 | 읽기/쓰기 |
|---------------|------|-----------|
| `chat/joins/{myUid}/{roomId}` | 채팅방 참여 정보 (목록 표시용) | 읽기 + 쓰기 |
| `chat/messages/{roomId}/{messageId}` | 메시지 데이터 | 읽기 + 쓰기 |
| `chat/favorites-folder-list/{myUid}` | 즐겨찾기 폴더 목록 | 읽기 |
| `users/{uid}` | 사용자 프로필 (닉네임, 프로필 사진 등) | 읽기 |
| `users/{uid}/pinnedChatRooms/{roomId}` | 고정된 채팅방 | 읽기 + 쓰기 |
| `user-private/{myUid}/blocks/{otherUid}` | 차단된 사용자 | 읽기 + 쓰기 |
| `reports/{reporterUid}/{reportId}` | 내가 한 신고 | 쓰기 |
| `reports-list/{reportId}` | 전체 신고 목록 (관리자 조회용) | 쓰기 |

### 4.2 joins 데이터 필드

`chat/joins/{myUid}/{roomId}` 하위에 저장되는 채팅방 참여 데이터이다.

```javascript
{
    singleOrder: 1710000000000,   // 정렬 기준 (타임스탬프) — 최신 메시지 시간
    unread: 3,                    // 읽지 않은 메시지 수
    userDisplayName: "홍길동",     // 상대방 표시 이름
    userPhotoUrl: "https://...",  // 상대방 프로필 사진 URL
    customName: "회사 동료",       // 사용자가 설정한 커스텀 이름 (선택)
    lastMessage: {                // 마지막 메시지 요약
        text: "안녕하세요",
        urls: []
    }
}
```

### 4.3 messages 데이터 필드

`chat/messages/{roomId}/{messageId}` 하위에 저장되는 메시지 데이터이다.

```javascript
{
    senderUid: "firebaseUid123",               // 보낸 사람 Firebase UID
    text: "메시지 내용",                         // 텍스트 메시지
    urls: ["https://storage.url/image.jpg"],   // 첨부파일 URL 배열
    sentAt: 1710000000000,                     // 서버 타임스탬프 (firebase.database.ServerValue.TIMESTAMP)
    isDeleted: false,                          // 삭제 여부 (선택)
    isEdited: false,                           // 수정 여부 (선택)
}
```

### 4.4 pinnedChatRooms 데이터

`users/{uid}/pinnedChatRooms/{roomId}` 경로에 `true` 값으로 저장한다.

```javascript
// 고정
firebase.database().ref('users/' + uid + '/pinnedChatRooms/' + roomId).set(true);
// 해제
firebase.database().ref('users/' + uid + '/pinnedChatRooms/' + roomId).remove();
```

### 4.5 blocks 데이터

`user-private/{myUid}/blocks/{otherUid}` 경로에 `true` 값으로 저장한다.

```javascript
// 차단
firebase.database().ref('user-private/' + myUid + '/blocks/' + otherUid).set(true);
// 해제
firebase.database().ref('user-private/' + myUid + '/blocks/' + otherUid).remove();
```

### 4.6 reports 데이터

```javascript
{
    path: "chat/messages/roomId123",    // 신고 대상 경로
    reporter: "myFirebaseUid",          // 신고자 UID
    reportee: "otherFirebaseUid",       // 신고 대상 UID
    reason: "스팸/광고",                 // 신고 사유
    created_at: ServerValue.TIMESTAMP   // 생성 시간
}
```

---

## 5. 채팅방 ID 규칙

1:1 채팅방 ID는 두 사용자의 Firebase UID를 **알파벳 정렬** 후 `---` 구분자로 연결하여 생성한다.

### 5.1 ID 생성

```javascript
// 구분자
const v7ChatConfig = { chatRoomSeparator: '---' };

// 채팅방 ID 생성 (알파벳 정렬)
function v7ChatMakeRoomId(otherUid, myUid) {
    return [otherUid, myUid].sort().join(v7ChatConfig.chatRoomSeparator);
}

// 예시
v7ChatMakeRoomId("bbb", "aaa");  // → "aaa---bbb"
v7ChatMakeRoomId("aaa", "bbb");  // → "aaa---bbb" (동일한 결과)
```

### 5.2 1:1 채팅방 여부 확인

```javascript
function v7ChatIsSingleRoom(roomId) {
    return !!(roomId && roomId.includes(v7ChatConfig.chatRoomSeparator));
}

v7ChatIsSingleRoom("aaa---bbb");       // → true
v7ChatIsSingleRoom("group_room_123");  // → false
```

### 5.3 상대방 UID 추출

```javascript
function v7ChatGetOtherUid(roomId, myUid) {
    if (!roomId || typeof roomId !== 'string') return null;
    const parts = roomId.split(v7ChatConfig.chatRoomSeparator);
    if (parts.length !== 2) return null;
    if (parts[0] === myUid) return parts[1];
    if (parts[1] === myUid) return parts[0];
    return null;
}

v7ChatGetOtherUid("aaa---bbb", "aaa");  // → "bbb"
v7ChatGetOtherUid("aaa---bbb", "bbb");  // → "aaa"
```

---

## 6. PHP 페이지 — index.php

`v7/chat/index.php`는 채팅 페이지의 진입점이다. PHP에서 처리하는 작업은 다음 3가지뿐이다.

### 6.1 로그인 확인

```php
$loginUser = AuthService::getLoginUser();
if (!$loginUser) {
    // 로그인 안내 표시 후 return
}
```

### 6.2 관리자 여부 확인

```php
$firebaseUid = $loginUser->firebase_uid ?? '';
$isAdmin = in_array($firebaseUid, Config::admins());
```

### 6.3 `window.v7chat` 설정 주입

PHP에서 JavaScript 전역 객체 `window.v7chat`으로 설정값을 전달한다.

```javascript
window.v7chat = {
    user: {
        isAdmin: true|false           // 관리자 여부
    },
    api: {
        resetJoin: 'https://...',     // Cloud Function: 읽음 표시 초기화 URL
        favorite: 'https://...',      // Cloud Function: 즐겨찾기 추가 URL
        leaveChatRoom: 'https://...'  // Cloud Function: 채팅방 나가기 URL
    },
    href: {
        login: '/user/login',                        // 로그인 페이지 경로
        publicProfile: '/user/public-profile?firebase_uid='  // 공개 프로필 경로
    },
    sounds: {
        send: '/packages/vchat/sounds/send.mp3',     // 전송 사운드 경로
        receive: '/packages/vchat/sounds/send.mp3'   // 수신 사운드 경로
    }
};
```

### 6.4 Vue 마운트 대상 HTML

```html
<div id="v7-chat">
    <div class="v7chat-loading">
        <i class="fa-solid fa-spinner fa-spin"></i> 채팅을 불러오는 중...
    </div>
</div>
```

Vue 앱이 마운트되면 내부 `v7chat-loading` div는 Vue 컴포넌트 출력으로 대체된다.

---

## 7. JS 파일별 상세 API

### 7.1 chat-helpers.js — 설정, 상수, 헬퍼 함수

모든 채팅 JS 파일 중 **가장 먼저** 로드되어야 하며, 다른 파일에서 공통으로 사용하는 설정, 상수, 유틸리티 함수를 제공한다.

#### 전역 설정 객체

```javascript
const v7ChatConfig = {
    initialMessageLimit: 20,     // 초기 메시지 로딩 수
    chatRoomSeparator: '---',    // 1:1 채팅방 ID 구분자
    pageSize: 20,                // 방 목록 페이지 크기
};

const v7ChatRoute = {
    list: 'list',        // 채팅방 목록
    single: 'single',    // 1:1 채팅방
    search: 'search',    // 사용자 검색
};
```

#### 함수 목록

| 함수명 | 파라미터 | 반환 | 설명 |
|--------|----------|------|------|
| `v7ChatIsSingleRoom(roomId)` | `string` | `boolean` | 1:1 채팅방 여부 확인 |
| `v7ChatGetOtherUid(roomId, myUid)` | `string, string` | `string\|null` | 채팅방 ID에서 상대방 UID 추출 |
| `v7ChatMakeRoomId(otherUid, myUid)` | `string, string` | `string` | 1:1 채팅방 ID 생성 (알파벳 정렬) |
| `v7ChatFormatTime(timestamp)` | `number` | `string` | 타임스탬프를 한국어 시간 문자열로 변환 |
| `v7ChatGetFileExt(url)` | `string` | `string` | URL에서 파일 확장자 추출 |
| `v7ChatIsImage(url)` | `string` | `boolean` | 이미지 파일 여부 (gif/jpg/jpeg/png/webp) |
| `v7ChatIsVideo(url)` | `string` | `boolean` | 비디오 파일 여부 (mp4/webm/mov) |
| `v7ChatLinkify(text)` | `string` | `string` | 텍스트 내 URL을 `<a>` 태그로 변환 |
| `v7ChatTogglePin(uid, roomId)` | `string, string` | `Promise<boolean>` | 채팅방 고정/해제 토글 |
| `v7ChatCreateReport(path, reason, reportee, reporter)` | `string, string, string, string` | `Promise<void>` | 채팅방 신고 생성 |
| `v7ChatInfiniteScroll(el, opts)` | `HTMLElement, Object` | `Object` | 무한 스크롤 초기화 |
| `v7ChatPlaySendSound()` | 없음 | `void` | 메시지 전송 사운드 재생 |
| `v7ChatPlayReceiveSound()` | 없음 | `void` | 메시지 수신 사운드 재생 (볼륨 0.5) |

#### 시간 포맷 규칙

```javascript
v7ChatFormatTime(timestamp)
// 1분 미만   → "방금"
// 1시간 미만 → "3분 전"
// 1시간 이상 → "24/03/12 오후 3:45"
```

#### 무한 스크롤 옵션

```javascript
var helper = v7ChatInfiniteScroll(element, {
    onTop: function() { /* 상단 도달 시 */ },      // 이전 메시지 로드
    onBottom: function() { /* 하단 도달 시 */ },    // 추가 채팅방 로드
    threshold: 10,              // 스크롤 경계 px (기본: 10)
    debounce: 100,              // 디바운스 ms (기본: 100)
    scrollToBottom: true|false  // 자동 하단 스크롤 (기본: true)
});

// 반환 객체
helper.destroy();        // 스크롤 리스너 해제
helper.scrollToBottom(); // 수동 하단 스크롤
```

---

### 7.2 chat-store.js — 글로벌 반응형 스토어

`Vue.reactive()`로 생성된 전역 반응형 상태와 액션을 제공한다.

#### v7ChatState (반응형 상태)

```javascript
var v7ChatState = Vue.reactive({
    myUid: null,                        // 내 Firebase UID
    route: v7ChatRoute.list,            // 현재 라우트 (list, single, search)
    room: {                             // 현재 열린 채팅방 정보
        id: null,
        name: '',
        photoUrl: '',
        customName: '',
    },
    my: {                               // 내 정보
        nickname: '',
        photoUrl: '',
    },
    rooms: {},                          // 채팅방 목록 { roomId: joinData }
    pinnedChatRooms: {},                // 고정된 채팅방 { roomId: true }
    favoriteFolders: [],                // 즐겨찾기 폴더 목록
    initializedNewRoomListener: false,  // 새 방 리스너 초기화 여부
    noMoreRooms: false,                 // 방 목록 더보기 없음
    blockedUsers: {},                   // 차단된 사용자 { uid: true }
});
```

#### v7ChatActions (액션 함수)

| 액션명 | 파라미터 | 설명 |
|--------|----------|------|
| `setMyData(u)` | `{ nickname, photoUrl }` | 내 사용자 정보 설정 |
| `openRoom(room)` | `{ id, name, customName, userDisplayName, userPhotoUrl }` | 채팅방 열기 → route를 `single`로 변경 |
| `closeRoom()` | 없음 | 채팅방 닫기 → route를 `list`로 변경 |
| `openSearch()` | 없음 | 사용자 검색 화면 열기 → route를 `search`로 변경 |
| `joinRoomListener(roomId)` | `string` | 개별 방 데이터 실시간 리스너 연결 |
| `attachNewRoomListener()` | 없음 | 새 방 감지 리스너 (1회만 초기화) |
| `loadFavoriteFolders()` | 없음 | 즐겨찾기 폴더 목록 실시간 리스너 |
| `listenBlockedUsers()` | 없음 | 차단된 사용자 실시간 리스너 |
| `listenPinnedRooms()` | 없음 | 고정된 채팅방 실시간 리스너 |

#### 주요 Firebase 리스너 경로

```javascript
// 채팅방 참여 정보
'chat/joins/' + myUid + '/' + roomId   // joinRoomListener

// 새 채팅방 감지
'chat/joins/' + myUid                   // attachNewRoomListener (singleOrder 기준)

// 즐겨찾기 폴더 목록
'chat/favorites-folder-list/' + myUid   // loadFavoriteFolders

// 차단된 사용자
'user-private/' + myUid + '/blocks'     // listenBlockedUsers

// 고정된 채팅방
'users/' + myUid + '/pinnedChatRooms'   // listenPinnedRooms
```

---

### 7.3 chat-room-list.js — 채팅방 목록 컴포넌트

`v7ChatRoomListComponent()` 함수로 정의된 Vue 컴포넌트이다. 채팅방 목록을 표시하고, 무한 스크롤 페이지네이션과 고정/비고정 섹션 분리를 제공한다.

#### data

```javascript
{
    state: v7ChatState,   // 전역 스토어 참조
    loading: false,       // 로딩 중 여부
    lastOrder: null,      // 페이지네이션 커서 (마지막 singleOrder)
    scrollHelper: null,   // 무한 스크롤 헬퍼 인스턴스
}
```

#### computed

| 이름 | 설명 |
|------|------|
| `sortedRooms` | 모든 채팅방을 고정→일반 순으로 정렬. 고정방은 상단, 일반방은 `singleOrder` 내림차순 |
| `firstNormalIdx` | 첫 번째 일반(비고정) 채팅방의 인덱스. 섹션 제목 표시에 사용 |

#### methods

| 메서드명 | 설명 |
|----------|------|
| `loadRooms()` | Firebase에서 채팅방 목록 페이지네이션 로드. `singleOrder` 기준 `limitToLast(20)` |
| `openRoom(room)` | 채팅방 열기 — `v7ChatActions.openRoom()` 호출 |
| `openSearch()` | 사용자 검색 화면 열기 — `v7ChatActions.openSearch()` 호출 |
| `unpin(room)` | 채팅방 고정 해제 — `v7ChatTogglePin()` 호출 |
| `getDisplayName(room)` | 채팅방 표시 이름 반환 (customName > userDisplayName > '사용자') |
| `getInitial(room)` | 이름 이니셜 반환 (아바타 텍스트용) |
| `getPreview(room)` | 마지막 메시지 미리보기 (30자 제한, 첨부파일 시 '첨부파일' 표시) |
| `formatTime(ts)` | 시간 포맷 — `v7ChatFormatTime()` 호출 |

#### 페이지네이션 동작

```
1. mounted → loadRooms() 최초 호출 (limitToLast 20개)
2. 무한 스크롤 하단 도달 → loadRooms() 재호출
3. lastOrder(이전 최소 singleOrder)를 커서로 사용하여 endBefore() 쿼리
4. 반환 수가 pageSize 미만이면 noMoreRooms = true → 추가 로드 중단
```

#### 채팅방 목록 UI 구조

```
┌─────────────────────────────────────┐
│ 채팅                         [새 채팅] │  ← 헤더
├─────────────────────────────────────┤
│ 📌 고정                              │  ← 고정 섹션 제목 (고정방 있을 때만)
│ ┌─────────────────────────────────┐ │
│ │ [아바타] 홍길동        3분 전    │ │  ← 채팅방 아이템 (고정)
│ │         안녕하세요...    (3)    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ 💬 전체                              │  ← 전체 섹션 제목
│ ┌─────────────────────────────────┐ │
│ │ [아바타] 김철수     1시간 전    │ │  ← 채팅방 아이템 (일반)
│ │         감사합니다              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⏳ 로딩 중...                        │  ← 무한 스크롤 로딩
└─────────────────────────────────────┘
```

---

### 7.4 chat-single-room.js — 1:1 채팅방 컴포넌트

`v7ChatSingleRoomComponent()` 함수로 정의된 Vue 컴포넌트이다. 채팅 시스템의 핵심 컴포넌트로, 메시지 전송/수신, 파일 업로드, 이미지 뷰어, 채팅방 관리 기능을 모두 포함한다.

#### data

```javascript
{
    state: v7ChatState,                 // 전역 스토어 참조
    messages: {},                       // 메시지 맵 { messageId: messageData }
    newMessage: '',                     // 입력 중인 메시지 텍스트
    selectedFiles: [],                  // 선택된 파일 배열 (File 객체)
    uploadPreviews: [],                 // 업로드 미리보기 배열
    uploading: false,                   // 업로드 진행 중 여부
    uploadProgress: 0,                  // 업로드 진행률 (0~100)
    loading: true,                      // 초기 메시지 로딩 중
    loadingMore: false,                 // 이전 메시지 로딩 중
    noMoreMessages: false,              // 이전 메시지 없음
    oldestKey: null,                    // 가장 오래된 메시지 키 (페이지네이션)
    scrollHelper: null,                 // 무한 스크롤 헬퍼
    otherUserData: { nickname: '', photoUrl: '' },  // 상대방 정보
    showDropdown: false,                // 드롭다운 메뉴 표시 여부
    showCustomNameModal: false,         // 커스텀 이름 모달
    customNameInput: '',                // 커스텀 이름 입력값
    showFavoriteModal: false,           // 즐겨찾기 모달
    selectedFolder: '',                 // 선택된 즐겨찾기 폴더
    newFolderName: '',                  // 새 폴더 이름
    showReportModal: false,             // 신고 모달
    reportReason: '',                   // 신고 사유
    imageViewer: { show: false, images: [], currentIndex: 0 },  // 이미지 뷰어
}
```

#### computed

| 이름 | 반환 | 설명 |
|------|------|------|
| `sortedMessages` | `Array` | 메시지를 `sentAt` 기준 시간순 정렬 |
| `allImages` | `Array<string>` | 모든 메시지에서 이미지 URL만 수집 (뷰어용) |
| `otherUid` | `string\|null` | 상대방 Firebase UID |
| `displayName` | `string` | 표시 이름 (customName > room.name > otherUserData.nickname) |
| `isPinned` | `boolean` | 현재 방 고정 여부 |
| `isBlocked` | `boolean` | 상대방 차단 여부 |
| `canSend` | `boolean` | 전송 가능 여부 (텍스트 또는 파일 있고, 업로드 중 아님) |
| `profileUrl` | `string` | 상대방 공개 프로필 URL |

#### methods 분류

**네비게이션:**

| 메서드명 | 설명 |
|----------|------|
| `goBack()` | 리스너 정리 후 채팅방 닫기 → 목록으로 이동 |

**메시지 로딩:**

| 메서드명 | 설명 |
|----------|------|
| `loadInitialMessages()` | 초기 메시지 로드 (최신 20개) + 실시간 리스너 시작 + 읽음 표시 |
| `loadMoreMessages()` | 이전 메시지 더 불러오기 (위로 스크롤 시, `endBefore` 쿼리) |
| `startMessageListener()` | 새 메시지 실시간 감지 (`child_added`) + 메시지 변경 감지 (`child_changed`) |

**메시지 전송:**

| 메서드명 | 설명 |
|----------|------|
| `sendMessage()` | 메시지 전송 (텍스트 + 파일). 낙관적 업데이트로 입력 즉시 초기화 |
| `handleKeyDown(e)` | Enter → 전송, Shift+Enter → 줄바꿈 |

**파일 업로드:**

| 메서드명 | 설명 |
|----------|------|
| `triggerFileInput()` | 숨겨진 `<input type="file">` 클릭 트리거 |
| `onFileSelected(e)` | 파일 선택 시 미리보기 생성 (이미지는 FileReader로 DataURL 생성) |
| `removeFile(idx)` | 선택된 파일 제거 |
| `uploadFiles(files)` | Firebase Storage에 파일 순차 업로드 → URL 배열 반환 |

**이미지 전체화면 뷰어:**

| 메서드명 | 설명 |
|----------|------|
| `openImageViewer(url)` | 이미지 클릭 시 전체화면 뷰어 열기 |
| `closeImageViewer()` | 뷰어 닫기 |
| `prevImage()` | 이전 이미지 (← 키보드 지원) |
| `nextImage()` | 다음 이미지 (→ 키보드 지원) |

**채팅방 관리:**

| 메서드명 | 설명 |
|----------|------|
| `togglePin()` | 채팅방 고정/해제 토글 |
| `markAsRead()` | 읽음 표시 (RTDB unread=0 + Cloud Function 호출) |
| `leaveRoom()` | 채팅방 나가기 (confirm 후 Cloud Function 호출 또는 직접 삭제) |
| `toggleBlock()` | 상대방 차단/해제 토글 |
| `showCustomNameDialog()` | 커스텀 이름 설정 모달 열기 |
| `saveCustomName()` | 커스텀 이름 저장 (RTDB에 저장) |
| `showFavoriteDialog()` | 즐겨찾기 모달 열기 |
| `saveFavorite()` | 즐겨찾기 추가 (Cloud Function 호출) |
| `showReportDialog()` | 신고 모달 열기 |
| `submitReport()` | 신고 제출 (`v7ChatCreateReport()` 호출) |

**유틸리티:**

| 메서드명 | 설명 |
|----------|------|
| `callCloudFn(url, data)` | Cloud Function 호출 헬퍼 (Firebase Auth 토큰 포함) |
| `loadOtherUserData()` | 상대방 사용자 데이터 로드 (`users/{uid}` 노드) |
| `showDateSep(msg, idx)` | 날짜 구분선 표시 여부 (날짜가 바뀌면 표시) |
| `formatDate(ts)` | 날짜 포맷 ("2024년 3월 12일") |
| `formatTime(ts)` | 시간 포맷 |
| `linkify(text)` | URL 링크화 |
| `isImage(url)` / `isVideo(url)` | 파일 유형 판별 |
| `getFileExt(url)` / `getFileName(url)` | 파일명/확장자 추출 |
| `bubbleClass(msg)` | 말풍선 CSS 클래스 결정 (mine/other) |
| `cleanupListeners()` | Firebase 리스너 정리 |

#### 드롭다운 메뉴 항목

```
┌──────────────────┐
│ 📌 고정/고정 해제 │
│ ✏️ 이름 설정      │
│ ⭐ 즐겨찾기       │
│ ✔✔ 읽음 표시     │
│ 👤 프로필 보기    │  ← 외부 링크 (새 탭)
├──────────────────┤
│ 🚫 차단/차단 해제 │
│ 🚩 신고          │  ← 빨간색
├──────────────────┤
│ 🚪 나가기        │  ← 빨간색
└──────────────────┘
```

#### 신고 사유 옵션

| 사유 |
|------|
| 스팸/광고 |
| 욕설/비방 |
| 음란물 |
| 사기/사칭 |
| 기타 |

---

### 7.5 chat-search.js — 사용자 검색 컴포넌트

`v7ChatSearchComponent()` 함수로 정의된 Vue 컴포넌트이다. Firebase RTDB의 `users` 노드에서 사용자를 검색하여 새 1:1 채팅을 시작한다.

#### data

```javascript
{
    state: v7ChatState,   // 전역 스토어 참조
    query: '',            // 검색어
    results: [],          // 검색 결과 배열 [{ uid, nickname, photoUrl }]
    loading: false,       // 검색 중 여부
    searched: false,      // 검색 수행 여부 (결과 없음 표시 조건)
}
```

#### methods

| 메서드명 | 설명 |
|----------|------|
| `goBack()` | 채팅방 목록으로 돌아가기 |
| `search()` | Firebase에서 사용자 검색 (`displayName` 기준, startAt/endAt 접두사 매칭, 최대 20명) |
| `startChat(user)` | 검색 결과에서 사용자 선택 → `v7ChatMakeRoomId()`로 방 ID 생성 → `v7ChatActions.openRoom()` 호출 |
| `handleKeyDown(e)` | Enter 키 → 검색 실행 |
| `initial(name)` | 이름 이니셜 반환 |

#### 검색 쿼리

```javascript
firebase.database().ref('users')
    .orderByChild('displayName')
    .startAt(query)
    .endAt(query + '\uf8ff')   // Unicode 접두사 매칭
    .limitToFirst(20)
    .once('value')
```

---

### 7.6 chat-app.js — Vue 앱 초기화

모든 채팅 JS 파일 중 **가장 마지막**에 로드되며, Firebase 인증 확인 후 Vue 앱을 생성하고 마운트한다.

#### 초기화 흐름

```javascript
ready(function() {                              // (1) DOMContentLoaded 대기
    firebase_ready(function() {                  // (2) Firebase SDK 초기화 대기
        firebase.auth().onAuthStateChanged(function(user) {  // (3) Auth 상태 확인
            if (!user) {
                // Firebase 미인증 → 로그인 안내 표시
                return;
            }

            // (4) 현재 사용자 UID 설정
            v7ChatState.myUid = user.uid;

            // (5) 사용자 정보 로드 (닉네임, 프로필 사진)
            firebase.database().ref('users/' + user.uid).once('value')...

            // (6) 전역 리스너 시작
            v7ChatActions.listenBlockedUsers();
            v7ChatActions.listenPinnedRooms();
            v7ChatActions.loadFavoriteFolders();
            v7ChatActions.attachNewRoomListener();

            // (7) Vue 앱 생성 및 마운트
            var app = Vue.createApp({
                components: {
                    'v7-chat-room-list': v7ChatRoomListComponent(),
                    'v7-chat-single-room': v7ChatSingleRoomComponent(),
                    'v7-chat-search': v7ChatSearchComponent(),
                },
                data: function() { return { state: v7ChatState }; },
                template: '...'   // state.route 기반 컴포넌트 전환
            });
            app.mount('#v7-chat');
        });
    });
});
```

#### Vue 앱 템플릿

```html
<div class="v7chat-container">
    <v7-chat-room-list v-if="state.route === 'list'" />
    <v7-chat-single-room v-else-if="state.route === 'single'" />
    <v7-chat-search v-else-if="state.route === 'search'" />
</div>
```

---

## 8. CSS 클래스 체계

모든 CSS 클래스는 `v7chat-` 접두어를 사용한다. Bootstrap 미사용, Web Awesome Pro 컴포넌트(`<wa-button>` 등)만 사용한다.

### 8.1 레이아웃 클래스

| 클래스명 | 설명 |
|----------|------|
| `#v7-chat` | 루트 컨테이너 (`height: calc(100dvh - 120px)`) |
| `.v7chat-container` | Vue 앱 컨테이너 (flex column, 100% 높이) |
| `.v7chat-loading` | 초기 로딩 표시 |

### 8.2 채팅방 목록 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-room-list` | 목록 전체 래퍼 |
| `.v7chat-list-header` | 헤더 (제목 + 새 채팅 버튼) |
| `.v7chat-header-top` | 헤더 상단 (제목 + 액션) |
| `.v7chat-header-actions` | 헤더 액션 버튼 그룹 |
| `.v7chat-room-list-scroll` | 스크롤 가능 영역 |
| `.v7chat-section-title` | 섹션 제목 (고정/전체) |
| `.v7chat-pinned-section` | 고정 섹션 래퍼 |
| `.v7chat-room-item` | 채팅방 아이템 (flex, border, hover 효과) |
| `.v7chat-room-item.pinned` | 고정된 채팅방 (노란 배경, 왼쪽 테두리) |
| `.v7chat-room-content` | 방 정보 (이름, 미리보기) |
| `.v7chat-room-name` | 방 이름 |
| `.v7chat-last-message` | 마지막 메시지 미리보기 |
| `.v7chat-room-meta` | 메타 (시간 + 배지) |
| `.v7chat-time` | 시간 표시 |
| `.v7chat-badge` | 읽지 않은 메시지 수 배지 (빨간 원) |
| `.v7chat-unpin-btn` | 고정 해제 버튼 (hover 시 표시) |
| `.v7chat-empty` | 빈 상태 표시 |
| `.v7chat-loading-more` | 추가 로딩 표시 |

### 8.3 채팅방 뷰 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-single-room` | 채팅방 전체 래퍼 |
| `.v7chat-room-header` | 채팅방 헤더 (뒤로가기, 이름, 드롭다운) |
| `.v7chat-back-btn` | 뒤로가기 버튼 |
| `.v7chat-room-title` | 방 제목 |
| `.v7chat-header-right` | 헤더 오른쪽 (드롭다운 메뉴) |
| `.v7chat-messages` | 메시지 영역 (flex 1, 스크롤) |
| `.v7chat-no-messages` | 빈 대화 표시 |
| `.v7chat-load-more` | 이전 메시지 로딩 표시 |
| `.v7chat-date-sep` | 날짜 구분선 |

### 8.4 말풍선 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-bubble-wrap` | 말풍선 래퍼 (flex) |
| `.v7chat-bubble-wrap.mine` | 내 말풍선 (오른쪽 정렬) |
| `.v7chat-bubble-wrap.other` | 상대 말풍선 (왼쪽 정렬) |
| `.v7chat-bubble-group` | 말풍선 그룹 (max-width: 70%) |
| `.v7chat-bubble-header` | 말풍선 헤더 (아바타 + 이름) |
| `.v7chat-bubble-author` | 발신자 이름 |
| `.v7chat-bubble-content` | 말풍선 내용 |
| `.v7chat-bubble-content` (mine) | 노란 배경 (`#fff3cd`), 오른쪽 꼬리 |
| `.v7chat-bubble-content` (other) | 회색 배경 (`#f1f3f5`), 왼쪽 꼬리 |
| `.v7chat-bubble-time` | 시간 표시 |
| `.v7chat-bubble-deleted` | 삭제된 메시지 (이탤릭, 회색) |
| `.v7chat-bubble-edited` | 수정됨 표시 |
| `.v7chat-blocked-msg` | 차단된 사용자 메시지 |

### 8.5 첨부파일 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-attachments` | 첨부파일 래퍼 (flex wrap) |
| `.v7chat-attach-image` | 이미지 첨부 (클릭 시 전체화면 뷰어) |
| `.v7chat-attach-video` | 비디오 첨부 |
| `.v7chat-attach-file` | 파일 첨부 (다운로드 링크) |
| `.v7chat-file-ext` | 파일 확장자 표시 |
| `.v7chat-fullscreen-btn` | 전체화면 버튼 (이미지 hover 시 표시) |

### 8.6 이미지 전체화면 뷰어 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-viewer` | 뷰어 오버레이 (fixed, z-index: 9999) |
| `.v7chat-viewer-close` | 닫기 버튼 (우상단) |
| `.v7chat-viewer-nav` | 네비게이션 버튼 (좌/우) |
| `.v7chat-viewer-prev` / `.v7chat-viewer-next` | 이전/다음 버튼 |
| `.v7chat-viewer-counter` | 카운터 (1/5 형식) |
| `.v7chat-viewer-thumbs` | 썸네일 네비게이션 (하단) |
| `.v7chat-thumb-list` | 썸네일 목록 |
| `.v7chat-thumb-item` / `.v7chat-thumb-item.active` | 썸네일 아이템 |

### 8.7 입력 영역 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-input-area` | 입력 영역 전체 래퍼 |
| `.v7chat-upload-preview` | 업로드 미리보기 영역 |
| `.v7chat-preview-item` | 미리보기 아이템 (80x80px) |
| `.v7chat-preview-remove` | 미리보기 삭제 버튼 |
| `.v7chat-preview-file` | 파일 미리보기 (비이미지) |
| `.v7chat-input-box` | 입력 박스 (textarea + 버튼) |
| `.v7chat-upload-progress` | 업로드 진행률 |
| `.v7chat-progress-bar` / `.v7chat-progress-fill` | 진행률 바 |
| `.v7chat-progress-text` | 진행률 텍스트 |
| `.v7chat-blocked-input` | 차단됨 안내 (입력 비활성화) |

### 8.8 공통 UI 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-icon-btn` | 아이콘 버튼 (32x32px, 원형) |
| `.v7chat-send-btn` | 전송 버튼 (36x36px, 파란 원형) |
| `.v7chat-avatar-wrap` | 아바타 래퍼 |
| `.v7chat-avatar-img` | 아바타 이미지 (원형) |
| `.v7chat-avatar-text` | 아바타 텍스트 (이니셜, 회색 원형) |
| `.v7chat-dropdown` | 드롭다운 래퍼 |
| `.v7chat-dropdown-menu` / `.v7chat-dropdown-menu.show` | 드롭다운 메뉴 |
| `.v7chat-dropdown-item` / `.v7chat-dropdown-item.danger` | 드롭다운 항목 |
| `.v7chat-dropdown-divider` | 드롭다운 구분선 |

### 8.9 모달 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-modal-backdrop` | 모달 배경 (fixed, 반투명) |
| `.v7chat-modal` | 모달 본체 (max-width: 420px) |
| `.v7chat-modal-header` | 모달 헤더 |
| `.v7chat-modal-body` | 모달 본문 |
| `.v7chat-modal-footer` | 모달 푸터 (버튼 영역) |
| `.v7chat-folder-item` / `.v7chat-folder-item.active` | 폴더 목록 아이템 (즐겨찾기 모달) |
| `.v7chat-report-option` | 신고 사유 라디오 옵션 |

### 8.10 검색 페이지 클래스

| 클래스명 | 설명 |
|----------|------|
| `.v7chat-search-page` | 검색 페이지 래퍼 |
| `.v7chat-search-header` | 검색 헤더 |
| `.v7chat-search-input` | 검색 입력 영역 (input + 버튼) |
| `.v7chat-search-results` | 검색 결과 영역 |
| `.v7chat-user-item` | 사용자 아이템 |
| `.v7chat-user-info` | 사용자 정보 |
| `.v7chat-search-empty` | 검색 결과 없음 |

### 8.11 반응형

```css
/* 모바일 (768px 이하) */
@media (max-width: 768px) {
    #v7-chat { height: calc(100dvh - 80px); }
    .v7chat-bubble-group { max-width: 85%; }         /* 70% → 85% */
    .v7chat-attach-image img { max-width: 160px; }   /* 200 → 160 */
}

/* 데스크톱 (992px 이상) */
@media (min-width: 992px) {
    #v7-chat { height: calc(100dvh - 180px); }
}
```

---

## 9. 주요 기능 목록

채팅 시스템에서 지원하는 기능을 범주별로 정리한다.

### 9.1 채팅방 목록 (10개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 1 | 채팅방 목록 실시간 업데이트 | `chat-store.js` → `joinRoomListener()` |
| 2 | 무한 스크롤 페이지네이션 | `chat-room-list.js` → `loadRooms()` |
| 3 | 고정된 채팅방 상단 표시 | `chat-room-list.js` → `sortedRooms` computed |
| 4 | 고정 섹션 / 전체 섹션 제목 표시 | `chat-room-list.js` → `firstNormalIdx` computed |
| 5 | 마지막 메시지 미리보기 (30자 제한) | `chat-room-list.js` → `getPreview()` |
| 6 | 읽지 않은 메시지 수 배지 | `chat-room-list.js` 템플릿 (99+ 처리) |
| 7 | 시간 표시 (방금/N분 전/날짜) | `chat-helpers.js` → `v7ChatFormatTime()` |
| 8 | 아바타 표시 (사진 또는 이니셜) | `chat-room-list.js` 템플릿 |
| 9 | 빈 상태 표시 (채팅방 없을 때) | `chat-room-list.js` 템플릿 |
| 10 | 고정 해제 버튼 (hover 시 표시) | `chat-room-list.js` → `unpin()` |

### 9.2 1:1 채팅방 메시지 (12개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 11 | 텍스트 메시지 전송 | `chat-single-room.js` → `sendMessage()` |
| 12 | 메시지 실시간 수신 (child_added) | `chat-single-room.js` → `startMessageListener()` |
| 13 | 메시지 변경 감지 (child_changed) | `chat-single-room.js` → `startMessageListener()` |
| 14 | 이전 메시지 더 불러오기 (위로 스크롤) | `chat-single-room.js` → `loadMoreMessages()` |
| 15 | Enter 전송 / Shift+Enter 줄바꿈 | `chat-single-room.js` → `handleKeyDown()` |
| 16 | textarea 자동 높이 조절 | `chat-single-room.js` → `newMessage` watcher |
| 17 | URL 자동 링크화 | `chat-helpers.js` → `v7ChatLinkify()` |
| 18 | 삭제된 메시지 표시 ("삭제된 메시지입니다") | 템플릿 `msg.isDeleted` 조건 |
| 19 | 수정된 메시지 표시 ("(수정됨)") | 템플릿 `msg.isEdited` 조건 |
| 20 | 날짜 구분선 | `chat-single-room.js` → `showDateSep()` |
| 21 | 새 메시지 시 자동 하단 스크롤 | `startMessageListener()` 내 isNearBottom 판정 |
| 22 | 읽음 표시 (unread=0 + Cloud Function) | `chat-single-room.js` → `markAsRead()` |

### 9.3 파일/이미지 처리 (10개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 23 | 파일 선택 (multiple 지원) | `chat-single-room.js` → `onFileSelected()` |
| 24 | 이미지 파일 미리보기 (DataURL) | `chat-single-room.js` → `onFileSelected()` |
| 25 | 파일 미리보기 제거 | `chat-single-room.js` → `removeFile()` |
| 26 | Firebase Storage 업로드 (순차) | `chat-single-room.js` → `uploadFiles()` |
| 27 | 업로드 진행률 표시 (%) | `chat-single-room.js` → `uploadProgress` |
| 28 | 이미지 첨부 렌더링 (max 200x200px) | 템플릿 `.v7chat-attach-image` |
| 29 | 비디오 첨부 렌더링 (controls) | 템플릿 `.v7chat-attach-video` |
| 30 | 파일 첨부 렌더링 (다운로드 링크) | 템플릿 `.v7chat-attach-file` |
| 31 | 이미지 전체화면 뷰어 (좌/우 네비) | `chat-single-room.js` → `openImageViewer()` 등 |
| 32 | 뷰어 키보드 네비게이션 (←→Esc) | `chat-single-room.js` → `_viewerKeyHandler` |

### 9.4 채팅방 관리 (10개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 33 | 채팅방 고정/해제 토글 | `chat-helpers.js` → `v7ChatTogglePin()` |
| 34 | 커스텀 이름 설정/제거 | `chat-single-room.js` → `saveCustomName()` |
| 35 | 즐겨찾기 폴더에 추가 | `chat-single-room.js` → `saveFavorite()` |
| 36 | 즐겨찾기 폴더 목록 실시간 로드 | `chat-store.js` → `loadFavoriteFolders()` |
| 37 | 채팅방 나가기 | `chat-single-room.js` → `leaveRoom()` |
| 38 | 상대방 프로필 보기 (새 탭) | 드롭다운 메뉴 링크 |
| 39 | 상대방 차단/해제 | `chat-single-room.js` → `toggleBlock()` |
| 40 | 차단된 사용자 메시지 입력 비활성화 | 템플릿 `isBlocked` 조건 |
| 41 | 사용자 신고 (5가지 사유) | `chat-single-room.js` → `submitReport()` |
| 42 | 드롭다운 외부 클릭 닫기 | `_closeDropdown` 이벤트 리스너 |

### 9.5 사용자 검색 (5개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 43 | 사용자 이름 검색 (접두사 매칭) | `chat-search.js` → `search()` |
| 44 | 검색 결과 목록 표시 | 템플릿 `.v7chat-user-item` |
| 45 | 검색 결과에서 채팅 시작 | `chat-search.js` → `startChat()` |
| 46 | Enter 키 검색 | `chat-search.js` → `handleKeyDown()` |
| 47 | 결과 없음 표시 | 템플릿 `.v7chat-search-empty` |

### 9.6 사운드/알림 (3개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 48 | 메시지 전송 사운드 재생 | `chat-helpers.js` → `v7ChatPlaySendSound()` |
| 49 | 메시지 수신 사운드 재생 (볼륨 0.5) | `chat-helpers.js` → `v7ChatPlayReceiveSound()` |
| 50 | 사운드 재생 실패 무시 (try-catch) | `v7ChatPlaySendSound()` / `v7ChatPlayReceiveSound()` |

### 9.7 기타 (2개)

| # | 기능 | 구현 위치 |
|---|------|-----------|
| 51 | Firebase Auth 미인증 시 로그인 안내 | `chat-app.js` → `onAuthStateChanged()` |
| 52 | 새 채팅방 자동 감지 | `chat-store.js` → `attachNewRoomListener()` |

---

## 10. Cloud Functions 연동

채팅 시스템은 일부 작업에 Firebase Cloud Functions를 호출한다. URL은 `window.v7chat.api` 객체를 통해 PHP에서 전달된다.

### 10.1 Cloud Function 호출 방식

```javascript
callCloudFn: function(url, data) {
    return firebase.auth().currentUser.getIdToken().then(function(token) {
        return fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + token   // Firebase Auth 토큰
            },
            body: JSON.stringify(data),
        }).then(function(res) { return res.json(); });
    });
}
```

### 10.2 사용되는 Cloud Functions

| API 키 | 기능 | 호출 시점 | 전달 데이터 |
|---------|------|-----------|-------------|
| `resetJoin` | 읽음 표시 초기화 | 채팅방 진입 시, 새 메시지 수신 시 | `{ roomId }` |
| `favorite` | 즐겨찾기 추가 | 즐겨찾기 모달에서 저장 시 | `{ roomId, folder }` |
| `leaveChatRoom` | 채팅방 나가기 | 나가기 confirm 후 | `{ roomId }` |

### 10.3 URL 설정 (PHP → Config)

```php
// v7/chat/index.php
window.v7chat = {
    api: {
        resetJoin: '<?= Config::chatResetJoinUrl() ?>',
        favorite: '<?= Config::chatFavoriteUrl() ?>',
        leaveChatRoom: '<?= Config::chatRoomLeaveUrl() ?>'
    }
};
```

이 URL들은 `V7\Utils\Config` 클래스의 정적 메서드를 통해 반환된다.

---

## 11. 사운드 시스템

### 11.1 사운드 파일

| 용도 | 경로 | 설명 |
|------|------|------|
| 전송 사운드 | `/packages/vchat/sounds/send.mp3` | 메시지 전송 시 재생 |
| 수신 사운드 | `/packages/vchat/sounds/send.mp3` | 상대방 새 메시지 수신 시 재생 (볼륨 0.5) |

### 11.2 사운드 경로 커스터마이즈

`window.v7chat.sounds`를 통해 PHP에서 사운드 파일 경로를 오버라이드할 수 있다.

```javascript
// 전송 사운드
var src = window.v7chat && window.v7chat.sounds
    ? window.v7chat.sounds.send
    : '/packages/vchat/sounds/send.mp3';

// 수신 사운드 (볼륨 0.5)
sound.volume = 0.5;
```

### 11.3 사운드 재생 실패 처리

브라우저 자동 재생 정책(Autoplay Policy)으로 인해 사운드 재생이 실패할 수 있다. `try-catch`와 `.catch(function() {})`로 모든 에러를 무시한다.

```javascript
function v7ChatPlaySendSound() {
    try {
        var sound = new Audio(src);
        sound.play().catch(function() {});  // Promise 실패 무시
    } catch (e) {
        // Audio 생성 실패 무시
    }
}
```

---

## 12. 이미지/파일 업로드 및 뷰어

### 12.1 파일 업로드 흐름

```
(1) 사용자가 📎 버튼 클릭 → triggerFileInput() → <input type="file" multiple> 팝업
(2) 파일 선택 → onFileSelected():
    - selectedFiles 배열에 File 객체 추가
    - 이미지이면 FileReader로 DataURL 생성 → uploadPreviews에 미리보기 추가
    - 비이미지이면 파일명만 표시
(3) 전송 버튼 클릭 → sendMessage():
    - 파일이 있으면 uploadFiles() 호출
    - Firebase Storage에 순차 업로드 (진행률 표시)
    - 모든 업로드 완료 후 URL 배열을 포함한 메시지 전송
(4) Firebase RTDB에 메시지 저장 (urls 필드에 URL 배열)
```

### 12.2 Firebase Storage 업로드 경로

```
users/{myUid}/{timestamp}-{filename}
```

예시: `users/abc123/1710000000000-photo.jpg`

### 12.3 업로드 진행률

```javascript
// totalBytes: 모든 파일의 총 바이트
// uploadedBytes: 이미 업로드된 바이트
// snap.bytesTransferred: 현재 파일의 전송된 바이트
var progress = uploadedBytes + snap.bytesTransferred;
self.uploadProgress = totalBytes > 0
    ? Math.round((progress / totalBytes) * 100)
    : 0;
```

### 12.4 파일 유형별 렌더링

| 파일 유형 | 확장자 | 렌더링 방식 |
|-----------|--------|-------------|
| 이미지 | gif, jpg, jpeg, png, webp | `<img>` 태그 (max 200x200), 클릭 시 전체화면 뷰어 |
| 비디오 | mp4, webm, mov | `<video>` 태그 (controls, max 250x200) |
| 기타 파일 | 모든 기타 | 파일 아이콘 + 파일명 + 확장자 + 다운로드 링크 |

### 12.5 이미지 전체화면 뷰어

```
┌─────────────────────────────────────────────────┐
│ [1/5]                                     [×]   │  ← 카운터 + 닫기
│                                                  │
│  [◀]          ┌──────────────┐           [▶]    │  ← 네비게이션
│               │              │                   │
│               │   이미지     │                   │
│               │   (90vw×85vh)│                   │
│               │              │                   │
│               └──────────────┘                   │
│                                                  │
│        ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐               │  ← 썸네일 (60×60px)
│        │  │ │██│ │  │ │  │ │  │               │     현재 이미지 하이라이트
│        └──┘ └──┘ └──┘ └──┘ └──┘               │
└─────────────────────────────────────────────────┘

키보드: ← 이전  → 다음  Esc 닫기
```

- 여러 이미지가 있으면 하단에 썸네일 네비게이션이 표시된다.
- 배경 클릭 시 뷰어가 닫힌다.
- `document.body.style.overflow = 'hidden'`으로 배경 스크롤을 방지한다.

---

## 13. layout.php 연동 — CSS/JS 조건부 로딩

`v7/layout.php`에서 URI가 `/chat`으로 시작할 때만 채팅 관련 CSS/JS 파일을 로드한다.

```php
<!-- v7/layout.php 198~207행 -->
<?php if (str_starts_with($route->getUri(), '/chat')): ?>
<link rel="stylesheet" href="/v7/chat/chat.css?v=<?= CACHE_VERSION ?>">
<script defer src="/v7/js/chat/chat-helpers.js?v=<?= CACHE_VERSION ?>"></script>
<script defer src="/v7/js/chat/chat-store.js?v=<?= CACHE_VERSION ?>"></script>
<script defer src="/v7/js/chat/chat-room-list.js?v=<?= CACHE_VERSION ?>"></script>
<script defer src="/v7/js/chat/chat-single-room.js?v=<?= CACHE_VERSION ?>"></script>
<script defer src="/v7/js/chat/chat-search.js?v=<?= CACHE_VERSION ?>"></script>
<script defer src="/v7/js/chat/chat-app.js?v=<?= CACHE_VERSION ?>"></script>
<?php endif; ?>
```

### 로드 순서 보장

모든 JS 파일에 `defer` 속성이 부여되어 있으므로, HTML에 선언된 순서대로 실행이 보장된다:

1. `chat-helpers.js` — 설정, 상수, 헬퍼 함수
2. `chat-store.js` — 전역 스토어 (`v7ChatState`, `v7ChatActions`)
3. `chat-room-list.js` — 채팅방 목록 컴포넌트 함수
4. `chat-single-room.js` — 1:1 채팅방 컴포넌트 함수
5. `chat-search.js` — 사용자 검색 컴포넌트 함수
6. `chat-app.js` — Vue 앱 생성 및 마운트

### 전역 의존성 (layout.php에서 먼저 로드됨)

채팅 JS 파일들이 사용하는 전역 라이브러리는 layout.php에서 채팅 JS보다 먼저 로드된다:

- `Vue.js CDN` (defer) — `Vue.createApp()`, `Vue.reactive()`
- `Firebase compat SDK` (defer) — `firebase.database()`, `firebase.auth()`, `firebase.storage()`
- `firebase-init.js` (defer) — Firebase 초기화 → `firebase_ready()` 콜백 실행
- `ready()` 함수 — 인라인 스크립트로 `<head>`에 정의 (defer 불필요)

### 캐시 버스팅

모든 CSS/JS 파일에 `?v=<?= CACHE_VERSION ?>` 쿼리 파라미터가 추가되어 있다. `CACHE_VERSION`은 `v7/etc/cache-version.php`에서 정의된다.

---

## 14. PEST 브라우저 테스트

### 14.1 테스트 파일 위치

```
tests/Browser/ChatTest.php
```

### 14.2 실행 방법

```bash
# 전체 채팅 테스트 실행
./vendor/bin/pest tests/Browser/ChatTest.php

# 헤드리스(기본) / 헤디드 모드
./vendor/bin/pest tests/Browser/ChatTest.php --headed

# 그룹별 실행
./vendor/bin/pest --group=chat
```

### 14.3 테스트 케이스 목록 (9개)

| # | 테스트명 | 그룹 | 검증 내용 |
|---|----------|------|-----------|
| 1 | 미로그인 시 로그인 안내 표시 | smoke | `로그인이 필요합니다` 텍스트 + `wa-button[variant="brand"]` 존재 |
| 2 | PHP 에러 없음 | smoke | `Fatal error`, `Parse error`, `Warning:`, `Uncaught` 미표시 |
| 3 | 채팅 CSS 로드 | css-load | `link[href*="chat.css"]` 존재 |
| 4 | 6개 채팅 JS 로드 | js-load | 6개 `script[src*="chat-*.js"]` 존재 |
| 5 | firebase_ready/ready 함수 정의 | firebase | `typeof firebase_ready === "function"` 등 |
| 6 | 채팅 헬퍼 함수 로드 | helpers | `v7ChatConfig`, `v7ChatMakeRoomId` 등 8개 함수/객체 확인 |
| 7 | 채팅 스토어 로드 | store | `v7ChatState`, `v7ChatActions` 확인 |
| 8 | Vue 컴포넌트 함수 로드 | components | 3개 컴포넌트 함수 확인 |
| 9 | 채팅방 ID 함수 동작 검증 | helpers-unit | `v7ChatMakeRoomId("bbb","aaa")` → `"aaa---bbb"` 등 |

### 14.4 테스트 URL

```
https://v7-local.philgo.com/chat
```

### 14.5 defer 스크립트 대기

테스트에서 defer 로드된 스크립트의 실행을 기다리기 위해 1초 대기를 사용한다:

```php
$page->script("new Promise(r => setTimeout(r, 1000))");
```

---

## 15. 새 기능 추가 방법

### 15.1 새 헬퍼 함수 추가

`v7/js/chat/chat-helpers.js`에 전역 함수를 추가한다. 네이밍 규칙: `v7Chat` + PascalCase.

```javascript
// chat-helpers.js에 추가
function v7ChatMyNewHelper(param) {
    // 구현
}
```

### 15.2 새 상태 필드 추가

`v7/js/chat/chat-store.js`의 `v7ChatState`에 새 필드를 추가한다.

```javascript
var v7ChatState = Vue.reactive({
    // ... 기존 필드
    myNewField: null,  // 새 상태 필드 추가
});
```

### 15.3 새 Vue 컴포넌트 추가

1. `v7/js/chat/chat-새기능.js` 파일을 생성한다.
2. Options API + 함수 패턴으로 컴포넌트를 정의한다.

```javascript
function v7ChatNewFeatureComponent() {
    return {
        data: function() {
            return { state: v7ChatState, /* ... */ };
        },
        methods: { /* ... */ },
        template: '<div>...</div>',
    };
}
```

3. `v7/layout.php`의 `/chat` 조건부 로딩 블록에 새 JS 파일을 추가한다 (chat-app.js 이전).

```php
<script defer src="/v7/js/chat/chat-새기능.js?v=<?= CACHE_VERSION ?>"></script>
```

4. `v7/js/chat/chat-app.js`의 Vue 앱에 새 컴포넌트를 등록한다.

```javascript
var app = Vue.createApp({
    components: {
        'v7-chat-room-list': v7ChatRoomListComponent(),
        'v7-chat-single-room': v7ChatSingleRoomComponent(),
        'v7-chat-search': v7ChatSearchComponent(),
        'v7-chat-new-feature': v7ChatNewFeatureComponent(),  // 추가
    },
    // ...
});
```

5. 필요 시 `v7ChatRoute`에 새 라우트를 추가하고, 앱 템플릿에 `v-else-if` 조건을 추가한다.

### 15.4 새 CSS 클래스 추가

`v7/chat/chat.css`에 `v7chat-` 접두어를 사용하여 새 클래스를 추가한다.

```css
/* 새 기능 영역 */
.v7chat-new-feature {
    /* 스타일 */
}
```

### 15.5 새 Cloud Function 연동

1. `V7\Utils\Config`에 새 URL 반환 메서드를 추가한다.
2. `v7/chat/index.php`의 `window.v7chat.api`에 새 URL을 추가한다.
3. `chat-single-room.js`에서 `callCloudFn(url, data)`로 호출한다.

### 15.6 새 테스트 추가

`tests/Browser/ChatTest.php`에 `browserTest()` 함수로 새 테스트를 추가한다.

```php
browserTest('채팅 페이지 — 새 기능이 동작한다', function () {
    $page = $this->visit(V7_TEST_BASE_URL . '/chat');
    $page->script("new Promise(r => setTimeout(r, 1000))");
    // 검증 로직
})->group('browser', 'v7', 'chat', 'new-feature');
```

### 15.7 체크리스트

새 채팅 기능 추가 시 반드시 확인할 항목:

- [ ] `v7chat-` 접두어 CSS 클래스 사용
- [ ] Options API로 Vue 컴포넌트 작성
- [ ] `v7Chat` + PascalCase 네이밍 규칙
- [ ] `defer` 속성으로 JS 로드
- [ ] `chat-app.js` 이전에 로드되도록 순서 배치
- [ ] Firebase RTDB 리스너 정리 (`cleanupListeners` 패턴)
- [ ] 에러 처리 (`try-catch` 또는 `.catch()`)
- [ ] PEST 브라우저 테스트 추가
- [ ] `chat.css`에 반응형 스타일 추가 (768px, 992px 분기점)
- [ ] 이 문서(v7-chat.md) 업데이트
