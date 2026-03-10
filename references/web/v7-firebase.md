# Firebase 웹 SDK 초기화 및 사용 가이드

## 목차

- [개요](#개요)
- [Firebase SDK 로딩 구조](#firebase-sdk-로딩-구조)
- [페이지 라이프사이클과 Firebase 초기화 흐름](#페이지-라이프사이클과-firebase-초기화-흐름)
- [핵심 함수: ready()](#핵심-함수-ready)
- [핵심 함수: firebase_ready()](#핵심-함수-firebase_ready)
- [Firebase 설정(Config) 주입](#firebase-설정config-주입)
- [Firebase Auth - 인증 상태 감지](#firebase-auth---인증-상태-감지)
- [Firebase ID Token 관리](#firebase-id-token-관리)
- [Firebase Realtime Database 사용](#firebase-realtime-database-사용)
- [Firebase Cloud Messaging (FCM)](#firebase-cloud-messaging-fcm)
- [Firebase Storage](#firebase-storage)
- [서비스 워커 (Service Worker)](#서비스-워커-service-worker)
- [전체 초기화 순서 요약](#전체-초기화-순서-요약)
- [주의사항 및 안티패턴](#주의사항-및-안티패턴)

---

## 개요

필고 웹사이트는 Firebase JavaScript SDK의 **compat (호환) 버전**을 사용한다. compat 버전은 `firebase.xxx()` 네임스페이스 방식의 API를 제공하며, CDN에서 `defer` 속성으로 로딩한다.

### 사용하는 Firebase 서비스

| 서비스 | 네임스페이스 | 용도 |
|--------|------------|------|
| Authentication | `firebase.auth()` | 사용자 로그인/로그아웃, ID Token 관리 |
| Realtime Database | `firebase.database()` | 온/오프라인 상태, 채팅 읽지 않은 수 |
| Cloud Messaging | `firebase.messaging()` | 푸시 알림 (FCM) |
| Storage | `firebase.storage()` | 파일 업로드/다운로드 |

### SDK 버전

현재 사용 중인 Firebase SDK 버전: **12.3.0** (compat)

---

## Firebase SDK 로딩 구조

### 로딩 위치와 파일

Firebase SDK는 **`</body>` 직전**에서 로딩된다. `<head>`에서 로딩하지 않는 이유는 페이지 렌더링 성능을 위해서이다.

**로딩 체인:**

```
page.footer.php
  └─ modules/final-init.php
       └─ etc/firebase/firebase-js-setup.php  ← Firebase SDK 스크립트 태그
```

### 소스 파일: `etc/firebase/firebase-js-setup.php`

```html
<!-- 파이어베이스 코드를 </body> 직전에 넣어서, 로딩하는데 시간이 걸리지 않도록 한다. -->
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-app-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-auth-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-database-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-storage-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.3.0/firebase-messaging-compat.js"></script>
<script>
    const vapidKey = "<?= get_firebase_vapid_key() ?>"; // FCM VAPID Key
    const firebaseConfig = <?php echo config()->firebase->web_config_json; ?>;
    ready(() => {
        firebase_ready(() => {});

        // 인증 상태 변화 감지 및 온/오프라인 상태 관리
        firebase.auth().onAuthStateChanged(async function(user) {
            if (user) {
                appConfig.token = await user.getIdToken();
                // 온/오프라인 Presence 시스템 등록
                const database = firebase.database();
                const myConnectionsRef = database.ref(`status/${user.uid}/connections`);
                const lastChangedRef = database.ref(`status/${user.uid}/last_changed`);
                const connectedRef = database.ref('.info/connected');
                connectedRef.on('value', (snap) => {
                    if (snap.val() === true) {
                        var ref = myConnectionsRef.push();
                        ref.set(true);
                        ref.onDisconnect().remove();
                        lastChangedRef.onDisconnect().set(firebase.database.ServerValue.TIMESTAMP);
                    }
                });
            } else {
                appConfig.token = "";
            }
        });
    });
</script>
```

**핵심 포인트:**

- 5개의 Firebase SDK 스크립트가 모두 `defer` 속성으로 로딩됨
- `vapidKey`와 `firebaseConfig`는 PHP에서 서버 설정 값을 주입
- `ready()` 콜백 안에서 `firebase_ready(() => {})`를 호출하여 Firebase 앱을 초기화
- `onAuthStateChanged`로 로그인 사용자의 ID Token을 `appConfig.token`에 저장
- 온/오프라인 Presence 시스템을 RTDB로 관리

---

## 페이지 라이프사이클과 Firebase 초기화 흐름

전체 흐름을 시간 순서대로 정리하면:

```
[1] 브라우저가 HTML 파싱 시작
    │
[2] <head> 파싱 - etc/default-head-javascript.php 실행
    │  ├─ ready() 함수 정의
    │  ├─ firebase_ready() 함수 정의
    │  └─ (아직 Firebase SDK는 로딩되지 않음)
    │
[3] <body> 파싱 - 페이지 콘텐츠 렌더링
    │
[4] </body> 직전 - modules/final-init.php 실행
    │  ├─ etc/firebase/firebase-js-setup.php include
    │  │   ├─ Firebase SDK 5개 <script defer> 태그 삽입
    │  │   ├─ vapidKey, firebaseConfig 전역 변수 선언
    │  │   └─ ready(() => { firebase_ready(() => {}); ... }) 등록
    │  │
    │  ├─ appConfig, __HYDRATE__ 전역 변수 선언
    │  ├─ firebase_ready(() => { messaging.onMessage(...) }) 등록
    │  ├─ firebase_ready(() => { onAuthStateChanged(...) }) 등록 (채팅 알림)
    │  └─ FCM 권한 요청 로직 등록
    │
[5] DOMContentLoaded 이벤트 발생
    │  ├─ initialize_on_ready() 실행 (Vue 전역 스토어 초기화)
    │  ├─ 모든 ready() 콜백 실행
    │  │   └─ firebase_ready() 콜백들 실행
    │  │       ├─ 첫 번째 호출: firebase.initializeApp(firebaseConfig)
    │  │       └─ 이후 호출: 이미 초기화됨 → 콜백 즉시 실행
    │  │
    │  └─ Firebase 서비스 사용 가능
    │
[6] Firebase Auth 상태 확인
    ├─ 로그인 상태: onAuthStateChanged에서 user 객체 수신
    │   ├─ ID Token 저장
    │   ├─ Presence 등록
    │   └─ 채팅 알림 리스너 등록
    └─ 비로그인 상태: user === null
```

---

## 핵심 함수: ready()

### 소스 파일: `etc/default-head-javascript.php`

```javascript
/** DOMContentLoaded 이벤트가 발생했을 때 실행할 함수 등록. */
function ready(fn) {
    if (document.readyState !== "loading") {
        initialize_on_ready();
        fn();
        return;
    }
    document.addEventListener("DOMContentLoaded", () => {
        initialize_on_ready();
        fn();
    });
}
```

### 동작 설명

- `document.readyState`가 이미 `"loading"`이 아니면 (= DOM 파싱 완료됨) 즉시 실행
- 아직 로딩 중이면 `DOMContentLoaded` 이벤트 리스너에 등록
- 콜백 실행 전 항상 `initialize_on_ready()`를 먼저 호출하여 Vue 전역 스토어를 초기화
- **모든 JavaScript 코드는 반드시 `ready(() => { ... })` 안에서 실행해야 한다** (defer 로딩 때문)

---

## 핵심 함수: firebase_ready()

### 소스 파일: `etc/default-head-javascript.php`

```javascript
// Firebase 초기화 함수. 여러번 호출해도 한번만 초기화 함.
function firebase_ready(callback) {
    ready(() => {
        if (typeof firebase === 'undefined') {
            throw new Error("No firebase. Firebase SDK script not loaded.");
        }
        if (firebase.apps.length > 0) {
            // 이미 초기화 되었으면 바로 콜백 호출
            callback();
            return;
        }
        // 파이어베이스 app 초기화
        firebase.initializeApp(firebaseConfig);
        console.log("---> Firebase 초기화 됨");
        callback();
    })
}
```

### 동작 설명

1. `ready()` 안에서 실행 → DOMContentLoaded 이후 실행 보장
2. `firebase` 글로벌 객체 존재 확인 → 없으면 에러 발생
3. **싱글톤 패턴**: `firebase.apps.length > 0`이면 이미 초기화됨 → 콜백 즉시 실행
4. 초기화 안 됐으면 `firebase.initializeApp(firebaseConfig)` 호출 후 콜백 실행
5. **여러 번 호출해도 `initializeApp()`은 한 번만 실행됨**

### 사용 예시

```javascript
// 위젯이나 페이지에서 Firebase를 사용할 때
firebase_ready(() => {
    // 여기서 Firebase 서비스를 안전하게 사용할 수 있다
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            console.log('로그인됨:', user.uid);
        }
    });
});
```

### Firebase 준비 상태 확인 방법

| 확인 방법 | 코드 | 설명 |
|-----------|------|------|
| SDK 로딩 여부 | `typeof firebase !== 'undefined'` | Firebase SDK 스크립트가 로딩되었는지 |
| 앱 초기화 여부 | `firebase.apps.length > 0` | `initializeApp()`이 호출되었는지 |
| 안전한 사용 방법 | `firebase_ready(() => { ... })` | 모든 조건을 자동으로 보장 |

**항상 `firebase_ready()` 래퍼를 사용하는 것을 권장한다.** 직접 `firebase.apps.length`를 확인하는 것보다 안전하고 일관적이다.

---

## Firebase 설정(Config) 주입

### PHP 서버에서 설정 값 주입

```javascript
// etc/firebase/firebase-js-setup.php 에서
const vapidKey = "<?= get_firebase_vapid_key() ?>"; // FCM VAPID Key
const firebaseConfig = <?php echo config()->firebase->web_config_json; ?>;
```

- `firebaseConfig`: Firebase 프로젝트 설정 (apiKey, authDomain, projectId 등)
- `vapidKey`: FCM 푸시 알림용 VAPID Key

### firebaseConfig 객체 구조

```javascript
const firebaseConfig = {
    apiKey: "...",
    authDomain: "xxx.firebaseapp.com",
    databaseURL: "https://xxx.firebaseio.com",
    projectId: "xxx",
    storageBucket: "xxx.firebasestorage.app",
    messagingSenderId: "...",
    appId: "...",
    measurementId: "..."
};
```

- PHP 설정 파일 `etc/app.config.php`에서 관리됨
- `config()->firebase->web_config_json`으로 JSON 문자열 출력

---

## Firebase Auth - 인증 상태 감지

### 핵심 패턴: onAuthStateChanged

Firebase 인증 상태 변화를 감지하는 패턴은 프로젝트 전체에서 일관되게 사용된다.

```javascript
firebase_ready(() => {
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            // 로그인 상태
            const uid = user.uid;
            const email = user.email;
            // user.getIdToken()으로 서버 API 인증용 토큰 획득 가능
        } else {
            // 비로그인 상태
        }
    });
});
```

### 사용 위치 (실제 소스코드)

| 파일 | 용도 |
|------|------|
| `etc/firebase/firebase-js-setup.php` | ID Token 저장, Presence 관리 |
| `modules/final-init.php:199` | 채팅 읽지 않은 메시지 수 표시 |
| `widgets/user/login.php:223` | 로그인 UI 처리 |
| `chat/list.php:113` | 채팅 목록 Firebase 연동 |

---

## Firebase ID Token 관리

### 소스 파일: `etc/firebase/firebase-js-setup.php`

```javascript
firebase.auth().onAuthStateChanged(async function(user) {
    if (user) {
        appConfig.token = await user.getIdToken();
    } else {
        appConfig.token = "";
    }
});
```

### 전역 접근

```javascript
// modules/final-init.php 에서 선언됨
window.appConfig = {
    api: { ... },   // PHP에서 주입된 API 설정
    token: "",       // Firebase ID Token (로그인 후 자동 설정됨)
};
```

- `appConfig.token`은 `onAuthStateChanged` 콜백에서 자동으로 설정됨
- 서버 API 호출 시 이 토큰을 사용하여 사용자 인증
- `func()` 함수에서 `auth: true` 옵션으로 자동 포함 가능

---

## Firebase Realtime Database 사용

### Presence (온/오프라인 상태) 시스템

```javascript
// etc/firebase/firebase-js-setup.php
firebase.auth().onAuthStateChanged(async function(user) {
    if (user) {
        const database = firebase.database();
        const myConnectionsRef = database.ref(`status/${user.uid}/connections`);
        const lastChangedRef = database.ref(`status/${user.uid}/last_changed`);
        const connectedRef = database.ref('.info/connected');

        connectedRef.on('value', (snap) => {
            if (snap.val() === true) {
                var ref = myConnectionsRef.push();
                ref.set(true);
                ref.onDisconnect().remove();
                lastChangedRef.onDisconnect().set(firebase.database.ServerValue.TIMESTAMP);
            }
        });
    }
});
```

### 채팅 읽지 않은 메시지 수 (실시간 감시)

```javascript
// modules/final-init.php
firebase_ready(() => {
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            const uid = user.uid;
            const database = firebase.database();
            database.ref(`users/${uid}/chatUnreadCount`).on('value', (snapshot) => {
                const chatUnreadCount = snapshot.val() || 0;
                document.querySelectorAll('.chat-unread-count').forEach(el => {
                    if (chatUnreadCount > 0) {
                        el.style.display = 'inline-block';
                        el.textContent = chatUnreadCount > 99 ? '99+' : chatUnreadCount;
                    } else {
                        el.style.display = 'none';
                        el.textContent = '';
                    }
                });
                if (chatUnreadCount > 0) {
                    play_beep_sound();
                }
            });
        } else {
            document.querySelectorAll('.chat-unread-count').forEach(el => {
                el.style.display = 'none';
                el.textContent = '';
            });
        }
    });
});
```

### 사용자 정보 로드 (js/user.js)

```javascript
async function getUser(uid) {
    const snapshot = await firebase.database().ref(`users/${uid}`).once('value');
    const userData = snapshot.val();
    if (userData) {
        userData.photoUrl = userData.photoUrl || userData.photo_url;
        return userData;
    }
    return null;
}
```

---

## Firebase Cloud Messaging (FCM)

### FCM 초기화 및 메시지 수신

```javascript
// modules/final-init.php
firebase_ready(() => {
    const messaging = firebase.messaging();
    messaging.onMessage((payload) => {
        // 앱이 포커스 상태일 때 메시지 수신
    });
});
```

### FCM 토큰 획득 흐름

```javascript
// js/app.js
async function get_fcm_token() {
    const current_permission = get_notification_permission();
    if (current_permission !== 'granted') {
        const permission = await Notification.requestPermission();
        if (permission !== 'granted') {
            throw new Error("푸시 알림 권한이 거부되었습니다.");
        }
    }
    const messaging = firebase.messaging();
    const token = await messaging.getToken({ vapidKey: vapidKey });
    return token;
}
```

### FCM 권한 요청 흐름 (modules/final-init.php)

```
[1] 페이지 로드 카운터 확인 (increase_page_load_counter())
    │
[2] 10회 이상 방문 시 → begin_fcm_permission_request() 호출
    │
[3] 이미 granted → request_now() → 토큰 획득 및 서버 저장
    │
[4] denied → 설정 페이지 유도 다이얼로그 표시
    │
[5] default → 권한 요청 다이얼로그 표시 → 허용 시 request_now()
```

### FCM 관련 핵심 함수 (js/app.js)

| 함수 | 설명 |
|------|------|
| `get_fcm_token()` | FCM 토큰 획득 (권한 요청 포함) |
| `save_fcm_token(token)` | 토큰을 서버에 저장 (변경 시에만) |
| `update_fcm_token(token, uid)` | 토큰에 Firebase UID 연결 |
| `get_notification_permission()` | 알림 권한 상태 반환 ('granted'/'denied'/'default'/'unsupported') |
| `can_show_fcm_dialog(isDev)` | FCM 다이얼로그 표시 가능 여부 (시간 제한) |
| `increase_page_load_counter()` | 페이지 로드 카운터 증가 |
| `update_fcm_dialog_time()` | 다이얼로그 표시 시간 기록 |

---

## Firebase Storage

Firebase Storage SDK가 로딩되어 있으므로 다음과 같이 사용 가능하다:

```javascript
firebase_ready(() => {
    const storageRef = firebase.storage().ref();
    // 파일 업로드/다운로드 작업
});
```

---

## 서비스 워커 (Service Worker)

### 소스 파일: `firebase-messaging-sw.js` (웹 루트)

```javascript
importScripts("https://www.gstatic.com/firebasejs/12.3.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.3.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "...",
    authDomain: "...",
    databaseURL: "...",
    projectId: "...",
    storageBucket: "...",
    messagingSenderId: "...",
    appId: "...",
    measurementId: "..."
});

firebase.messaging();
```

- 서비스 워커는 별도의 스레드에서 실행되므로 독립적으로 Firebase를 초기화함
- 앱이 백그라운드일 때 푸시 알림을 수신/표시하는 역할
- `firebase-messaging-sw.js`는 반드시 **웹 루트**에 위치해야 함

---

## 전체 초기화 순서 요약

### 관련 파일 순서

```
1. etc/default-head-javascript.php     ← <head>에서 로딩. ready(), firebase_ready() 함수 정의
2. etc/firebase/firebase-js-setup.php  ← </body> 직전. Firebase SDK 로딩 + Config 주입 + 초기 이벤트 등록
3. modules/final-init.php              ← </body> 직전. appConfig/HYDRATE 선언, FCM/RTDB 리스너 등록
4. js/app.js                           ← defer 로딩. FCM 토큰 관련 함수, func() API 호출 함수 등
5. firebase-messaging-sw.js            ← 서비스 워커. 백그라운드 FCM 수신
```

### 변수/객체 흐름

```
[PHP 서버]
    ├─ config()->firebase->web_config_json  → firebaseConfig (JS 전역)
    ├─ get_firebase_vapid_key()             → vapidKey (JS 전역)
    └─ login()?->toArray()                  → window.__HYDRATE__.user (JS 전역)

[JavaScript 전역]
    ├─ window.appConfig.token               ← Firebase ID Token (Auth 상태 변화 시 갱신)
    ├─ window.state.user                    ← Vue reactive 사용자 정보
    └─ window.__HYDRATE__                   ← PHP에서 주입된 초기 데이터
```

---

## 주의사항 및 안티패턴

### 반드시 지켜야 할 것

1. **Firebase 코드는 항상 `firebase_ready()` 안에서 실행한다**
   ```javascript
   // 올바른 사용법
   firebase_ready(() => {
       firebase.auth().onAuthStateChanged(...);
   });
   ```

2. **`ready()` 래퍼로 모든 JavaScript를 감싼다** (defer 로딩 때문)
   ```javascript
   ready(() => {
       // DOM 및 라이브러리 접근 가능
   });
   ```

3. **Firebase SDK를 중복 로딩하지 않는다** — `etc/firebase/firebase-js-setup.php`에서 이미 로딩됨

### 절대 하지 말아야 할 것

1. **`firebase_ready()` 없이 직접 Firebase 사용 금지**
   ```javascript
   // 잘못된 사용법 - SDK 로딩 전에 실행될 수 있음
   firebase.auth().onAuthStateChanged(...); // Error!
   ```

2. **`firebase.initializeApp()` 직접 호출 금지** — `firebase_ready()`가 자동으로 처리

3. **Firebase SDK 스크립트를 `<head>`에 넣지 않는다** — 성능 문제 발생

4. **`const { createApp, ref } = Vue;` 구조 분해 할당 사용 금지** — defer 로딩 환경에서 오류 발생 가능
