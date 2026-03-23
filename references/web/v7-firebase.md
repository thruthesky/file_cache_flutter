# v7 Firebase 웹 SDK 초기화 및 사용 가이드

## 목차

- [개요](#개요)
- [v7 Firebase SDK 로딩 구조](#v7-firebase-sdk-로딩-구조)
- [defer 스크립트 실행 순서와 타이밍 보장](#defer-스크립트-실행-순서와-타이밍-보장)
- [firebase_ready()는 일반적으로 불필요](#firebase_ready는-일반적으로-불필요)
- [v7 페이지에서 Firebase 사용법](#v7-페이지에서-firebase-사용법)
- [Firebase Auth — 인증 상태 감지](#firebase-auth--인증-상태-감지)
- [Firebase Realtime Database 사용](#firebase-realtime-database-사용)
- [Firebase Cloud Messaging (FCM)](#firebase-cloud-messaging-fcm)
- [Firebase Storage](#firebase-storage)
- [서비스 워커 (Service Worker)](#서비스-워커-service-worker)
- [전체 초기화 순서 요약](#전체-초기화-순서-요약)
- [주의사항 및 안티패턴](#주의사항-및-안티패턴)

---

## 개요

v7에서는 Firebase JavaScript SDK의 **compat (호환) 버전**을 사용함. compat 버전은 `firebase.xxx()` 네임스페이스 방식의 API를 제공하며, CDN에서 `defer` 속성으로 로딩함.

### 사용하는 Firebase 서비스

| 서비스 | 네임스페이스 | 용도 |
|--------|------------|------|
| Authentication | `firebase.auth()` | 사용자 로그인/로그아웃, ID Token 관리 |
| Realtime Database | `firebase.database()` | 채팅 읽지 않은 수, 온/오프라인 상태 |
| Cloud Messaging | `firebase.messaging()` | 푸시 알림 (FCM) |
| Storage | `firebase.storage()` | 파일 업로드/다운로드 |

### SDK 버전

현재 사용 중인 Firebase SDK 버전: **12.10.0** (compat)

---

## v7 Firebase SDK 로딩 구조

v7에서는 `layout.php` 한 곳에서 Firebase SDK 로딩, 설정 주입, 초기화를 모두 처리함.

### 1단계: 설정 객체 및 유틸리티 함수 정의 (인라인 스크립트)

**소스**: `v7/layout.php:186-206`

```html
<script>
    function ready(fn) {
        if (document.readyState !== 'loading') fn();
        else document.addEventListener('DOMContentLoaded', fn);
    }
    window._v7fb = {
        ready: false,
        cbs: [],
        config: <?= Config::firebaseConfigJson() ?>,
        vapidKey: "<?= Config::firebaseVapidKey() ?>",
        isDev: <?= Env::isDev() ? 'true' : 'false' ?>
    };

    function firebase_ready(fn) {
        if (window._v7fb.ready) {
            fn();
            return;
        }
        window._v7fb.cbs.push(fn);
    }
</script>
```

- `window._v7fb.config`: PHP에서 주입된 Firebase 설정 (apiKey, authDomain 등)
- `window._v7fb.ready`: Firebase 초기화 완료 플래그
- `window._v7fb.cbs`: 초기화 전에 등록된 콜백 큐
- `firebase_ready(fn)`: 초기화 완료 시 즉시 실행, 미완료 시 큐에 push

### 2단계: Firebase SDK defer 로딩

**소스**: `v7/layout.php:208-213`

```html
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-app-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-auth-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-database-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-storage-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-messaging-compat.js"></script>
```

### 3단계: Firebase 초기화 실행

**소스**: `v7/js/firebase-init.js`

```javascript
(function() {
    if (typeof firebase !== 'undefined' && window._v7fb && !window._v7fb.ready) {
        firebase.initializeApp(window._v7fb.config);
        window._v7fb.ready = true;
        window._v7fb.cbs.forEach(function(fn) {
            try { fn(); } catch(e) { console.error('firebase_ready 콜백 에러:', e); }
        });
        window._v7fb.cbs = [];
    }
})();
```

- `firebase-init.js`도 `defer`로 로딩되며, SDK 스크립트들보다 **아래에 선언**되어 있으므로 반드시 SDK 이후에 실행됨
- 초기화 완료 후 `_v7fb.ready = true`로 설정하고, 큐에 쌓인 콜백들을 순차 실행
- 이후 `firebase_ready(fn)` 호출 시 즉시 실행됨

---

## defer 스크립트 실행 순서와 타이밍 보장

### 핵심: defer 스크립트는 선언 순서대로 실행됨

HTML 표준 스펙에 의해, `defer` 속성이 붙은 외부 스크립트는 **다운로드는 병렬**로 하되, **실행은 HTML에 선언된 순서를 반드시 보장**함. 이것이 `async`와의 핵심 차이임.

| 속성 | 다운로드 | 실행 순서 | 실행 시점 |
|------|---------|----------|----------|
| (없음) | 즉시 | 선언 순서 | 즉시 (HTML 파싱 블로킹) |
| `defer` | 병렬 | **선언 순서 보장** | HTML 파싱 완료 후, DOMContentLoaded 직전 |
| `async` | 병렬 | 도착 순서 (비보장) | 다운로드 완료 즉시 |

### v7 layout.php의 실제 실행 순서

```
선언 순서 (layout.php)              실행 순서 (브라우저)
─────────────────────              ─────────────────────
209: firebase-app-compat.js        1번째 실행
210: firebase-auth-compat.js       2번째 실행
211: firebase-database-compat.js   3번째 실행
212: firebase-storage-compat.js    4번째 실행
213: firebase-messaging-compat.js  5번째 실행
216: firebase-init.js              6번째 실행 (SDK 모두 로딩된 후)
219: chat-unread.js                7번째 실행
... 이하 defer 스크립트들 ...       선언 순서대로
```

### 타이밍 문제가 발생하지 않는 이유

1. **defer 스크립트 간 순서 보장**: `firebase-init.js`가 SDK 스크립트들보다 아래에 선언되어 있으므로, SDK가 모두 실행된 후에 `firebase.initializeApp()`이 호출됨. `firebase-init.js`가 먼저 실행될 가능성은 **불가능**함.

2. **defer → DOMContentLoaded 순서 보장**: HTML 스펙에 의해 모든 `defer` 스크립트가 실행 완료된 후에 `DOMContentLoaded` 이벤트가 발생함. 따라서 `ready()` 콜백이나 `DOMContentLoaded` 핸들러 안에서는 Firebase가 **100% 초기화 완료** 상태임.

3. **사용자 인터랙션 시점**: Vue.js 앱의 버튼 클릭 등 사용자 이벤트 핸들러가 실행되는 시점은 페이지 로드 완료 이후이므로, Firebase가 초기화되지 않았을 가능성은 **없음**.

```
[타임라인]

HTML 파싱 시작
    │
    ├─ <script> (인라인): ready(), firebase_ready(), _v7fb 정의
    │
    ├─ <script defer> SDK 5개 + firebase-init.js + 기타: 병렬 다운로드 시작
    │
HTML 파싱 완료
    │
    ├─ firebase-app-compat.js 실행     ← defer 순서 1
    ├─ firebase-auth-compat.js 실행    ← defer 순서 2
    ├─ firebase-database-compat.js 실행 ← defer 순서 3
    ├─ firebase-storage-compat.js 실행  ← defer 순서 4
    ├─ firebase-messaging-compat.js 실행 ← defer 순서 5
    ├─ firebase-init.js 실행            ← defer 순서 6 (여기서 initializeApp)
    ├─ chat-unread.js 실행              ← defer 순서 7
    ├─ fcm.js 실행                      ← defer 순서 8
    │  ... 기타 defer 스크립트 ...
    │
DOMContentLoaded 이벤트 발생
    │  ├─ ready() 콜백들 실행
    │  └─ Vue.createApp().mount() 실행
    │
사용자 인터랙션 가능 (Firebase는 이미 초기화 완료)
```

---

## firebase_ready()는 일반적으로 불필요

### 왜 불필요한가

`firebase-init.js`가 `defer`로 로딩되어 다른 모든 `defer` 스크립트 및 `DOMContentLoaded` 이전에 실행됨. 따라서 다음 상황에서는 Firebase가 **항상 초기화되어 있으므로** `firebase_ready()`를 호출할 필요 없음:

| 상황 | Firebase 초기화 상태 | firebase_ready() 필요 여부 |
|------|---------------------|--------------------------|
| `ready(() => { ... })` 콜백 안 | 초기화 완료 | 불필요 |
| `DOMContentLoaded` 핸들러 안 | 초기화 완료 | 불필요 |
| Vue.js `mounted()` 안 | 초기화 완료 | 불필요 |
| Vue.js `methods`의 이벤트 핸들러 안 | 초기화 완료 | 불필요 |
| 다른 `defer` 스크립트 안 (firebase-init.js 이후 선언) | 초기화 완료 | 불필요 |

### 올바른 사용법 (직접 호출)

```javascript
// v7 페이지에서 Firebase를 바로 사용할 수 있음
ready(() => {
    Vue.createApp({
        methods: {
            async doLogout() {
                await firebase.auth().signOut();
                window.location.href = '/';
            },
        },
    }).mount('#my-app');
});
```

```javascript
// defer 스크립트에서도 바로 사용 가능 (firebase-init.js 이후에 선언된 경우)
firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        console.log('로그인됨:', user.uid);
    }
});
```

### firebase_ready()가 여전히 필요한 경우

`firebase_ready()`는 **firebase-init.js보다 먼저 실행될 수 있는 스크립트**에서만 필요함. 실제로 이런 경우는 거의 없지만, 예를 들면:

- layout.php의 인라인 `<script>`에서 Firebase를 사용해야 하는 경우 (인라인 스크립트는 defer보다 먼저 실행됨)
- `firebase-init.js`보다 위에 선언된 defer 스크립트에서 Firebase를 사용하는 경우

이런 특수한 경우에만 `firebase_ready()`로 감싸면 됨.

### 실제 사용 예시: firebase_ready() 불필요

```javascript
// v7/js/fcm.js (firebase-init.js 이후에 defer로 선언됨)
// firebase_ready()로 감싸져 있지만, 실제로는 직접 호출해도 동작함
firebase_ready(async function () {
    // FCM 토큰 처리...
});
```

```javascript
// v7/js/chat-unread.js (firebase-init.js 이후에 defer로 선언됨)
// firebase_ready()로 감싸져 있지만, 불필요함
firebase_ready(function () {
    firebase.auth().onAuthStateChanged(function(user) { ... });
});
```

> **정리**: 기존 코드에 `firebase_ready()`가 사용된 곳이 있지만, v7 layout.php 구조에서는 대부분 불필요함. 새 코드 작성 시에는 `firebase_ready()` 없이 직접 `firebase.auth()` 등을 호출하면 됨.

---

## v7 페이지에서 Firebase 사용법

### 기본 원칙

1. **Firebase SDK를 중복 로딩하지 않음** — layout.php에서 이미 로딩됨
2. **`firebase.initializeApp()`을 직접 호출하지 않음** — firebase-init.js에서 이미 처리됨
3. **`firebase_ready()`로 감쌀 필요 없음** — defer 순서에 의해 항상 초기화 완료 상태

### 올바른 패턴 vs 잘못된 패턴

```php
<!-- 잘못된 패턴: SDK 중복 로딩 + 수동 초기화 -->
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-app-compat.js"></script>
<script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-auth-compat.js"></script>
<script>
ready(() => {
    const firebaseConfig = <?= firebase_config_json() ?>;
    if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
    }
    firebase.auth().signOut();
});
</script>

<!-- 올바른 패턴: 직접 사용 -->
<script>
ready(() => {
    firebase.auth().signOut();
});
</script>
```

### 실제 적용 사례

#### 로그아웃 (v7/user/logout.php)

```javascript
ready(async function() {
    // Firebase 로그아웃 (layout.php에서 이미 초기화됨)
    try {
        await firebase.auth().signOut();
    } catch (e) {
        console.warn('[Logout] Firebase signOut 실패 (무시):', e.message);
    }
    window.location.href = '/';
});
```

#### 회원 탈퇴 (v7/user/resign.php)

```javascript
// Vue.js methods 안에서 직접 사용
async doResign() {
    const result = await v7api('user.resign', {});
    try {
        await firebase.auth().signOut();
    } catch (e) {
        console.warn('[Resign] Firebase signOut 실패 (무시):', e.message);
    }
    alert(result.message);
    window.location.href = '/';
},
```

#### 카카오/네이버 로그인 완료 (v7/auth/kakao/complete.php, v7/auth/naver/complete.php)

```javascript
// Vue.js mounted() 안에서 직접 사용
async mounted() {
    try {
        const result = await firebase.auth().signInWithCustomToken(customToken);
        const idToken = await result.user.getIdToken();
        await v7api('user.socialLogin', { id_token: idToken, login_provider: 'kakaotalk' });
        window.location.href = '/';
    } catch (e) {
        this.error = e.message;
    }
},
```

---

## Firebase Auth — 인증 상태 감지

### 핵심 패턴: onAuthStateChanged

```javascript
// defer 스크립트에서 직접 사용 가능 (firebase-init.js 이후 선언된 경우)
firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
        // 로그인 상태
        const uid = user.uid;
        const email = user.email;
    } else {
        // 비로그인 상태
    }
});
```

### ID Token 획득

```javascript
// 로그인된 사용자의 Firebase ID Token 획득
const user = firebase.auth().currentUser;
if (user) {
    const idToken = await user.getIdToken();
    // 서버 API 호출에 사용
}
```

---

## Firebase Realtime Database 사용

### 채팅 읽지 않은 메시지 수 (실시간 감시)

**소스**: `v7/js/chat-unread.js`

```javascript
firebase_ready(function () {
    firebase.auth().onAuthStateChanged(function(user) {
        if (user) {
            const uid = user.uid;
            firebase.database().ref(`chat-rooms/${uid}/unread-count-total`).on('value', (snapshot) => {
                const count = snapshot.val() || 0;
                // 배지 UI 업데이트
            });
        }
    });
});
```

### 데이터 읽기/쓰기

```javascript
// 데이터 읽기
const snapshot = await firebase.database().ref(`users/${uid}`).once('value');
const userData = snapshot.val();

// 데이터 쓰기
await firebase.database().ref(`users/${uid}/nickname`).set('새닉네임');

// 실시간 감시
firebase.database().ref(`path/to/data`).on('value', (snapshot) => {
    const data = snapshot.val();
});
```

---

## Firebase Cloud Messaging (FCM)

### FCM 초기화 및 메시지 수신

**소스**: `v7/js/fcm.js`

```javascript
firebase_ready(async function () {
    // 페이지 로드 카운터 증가
    increase_page_load_counter();

    firebase.auth().onAuthStateChanged(async function(user) {
        if (user) {
            // FCM 권한 요청 및 토큰 저장
        }
    });

    // 포그라운드 메시지 수신
    const messaging = firebase.messaging();
    messaging.onMessage((payload) => {
        // 알림 표시
    });
});
```

### FCM 토큰 획득

```javascript
async function getFcmToken() {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
        throw new Error('푸시 알림 권한이 거부됨');
    }
    const messaging = firebase.messaging();
    const token = await messaging.getToken({ vapidKey: window._v7fb.vapidKey });
    return token;
}
```

---

## Firebase Storage

```javascript
// Firebase Storage 사용 (layout.php에서 SDK 이미 로딩됨)
const storageRef = firebase.storage().ref();
const fileRef = storageRef.child('uploads/photo.jpg');

// 파일 업로드
await fileRef.put(file);

// 다운로드 URL 획득
const url = await fileRef.getDownloadURL();
```

---

## 서비스 워커 (Service Worker)

**소스**: `firebase-messaging-sw.js` (웹 루트)

```javascript
importScripts("https://www.gstatic.com/firebasejs/12.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/12.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "...",
    // ... Firebase 설정
});

firebase.messaging();
```

- 서비스 워커는 별도의 스레드에서 실행되므로 독립적으로 Firebase를 초기화해야 함
- 앱이 백그라운드일 때 푸시 알림을 수신/표시하는 역할
- `firebase-messaging-sw.js`는 반드시 **웹 루트**에 위치해야 함

---

## 전체 초기화 순서 요약

### v7 관련 파일

```
1. v7/layout.php (인라인 <script>)
   ├─ ready() 함수 정의
   ├─ firebase_ready() 함수 정의
   └─ window._v7fb 객체 생성 (config, vapidKey, cbs, ready 플래그)

2. v7/layout.php (defer <script> 태그들)
   ├─ firebase-app-compat.js      ← defer 1
   ├─ firebase-auth-compat.js     ← defer 2
   ├─ firebase-database-compat.js ← defer 3
   ├─ firebase-storage-compat.js  ← defer 4
   ├─ firebase-messaging-compat.js ← defer 5
   └─ firebase-init.js            ← defer 6 (initializeApp 실행)

3. v7/js/firebase-init.js
   ├─ firebase.initializeApp(window._v7fb.config)
   ├─ window._v7fb.ready = true
   └─ 큐에 쌓인 firebase_ready() 콜백들 실행

4. DOMContentLoaded 이벤트
   └─ ready() 콜백들 실행 (이 시점에서 Firebase 100% 초기화 완료)
```

### 핵심 정리

| 항목 | 설명 |
|------|------|
| SDK 로딩 위치 | `v7/layout.php` (유일) |
| 초기화 위치 | `v7/js/firebase-init.js` (유일) |
| 설정 주입 방식 | `window._v7fb.config` (PHP → JS) |
| 타이밍 보장 | `defer` 선언 순서에 의해 SDK → init 순서 보장 |
| `firebase_ready()` | 대부분 불필요, 직접 호출 가능 |

---

## 주의사항 및 안티패턴

### 절대 하지 말아야 할 것

1. **Firebase SDK를 개별 페이지에서 중복 로딩 금지**
   ```html
   <!-- 금지: layout.php에서 이미 로딩됨 -->
   <script defer src="https://www.gstatic.com/firebasejs/12.10.0/firebase-app-compat.js"></script>
   ```

2. **`firebase.initializeApp()` 직접 호출 금지**
   ```javascript
   // 금지: firebase-init.js에서 이미 처리됨
   firebase.initializeApp(firebaseConfig);
   ```

3. **`firebase_config_json()` PHP 함수를 JS에 인라인 주입 금지**
   ```javascript
   // 금지: layout.php의 window._v7fb.config으로 이미 주입됨
   const firebaseConfig = <?= firebase_config_json() ?>;
   ```

4. **Firebase SDK를 `<head>`에 넣지 않음** — 성능 문제 발생

5. **`const { createApp, ref } = Vue;` 구조 분해 할당 금지** — v7 Vue.js 규칙

### 올바른 패턴

1. **Firebase는 바로 사용** — `ready()` 또는 Vue.js `mounted()` 안에서 직접 호출
   ```javascript
   ready(() => {
       firebase.auth().signOut();
   });
   ```

2. **signOut 실패는 catch로 무시** — 서버 측 세션이 이미 처리된 경우가 많음
   ```javascript
   try {
       await firebase.auth().signOut();
   } catch (e) {
       console.warn('Firebase signOut 실패 (무시):', e.message);
   }
   ```

3. **`ready()` 래퍼로 모든 JavaScript를 감쌈** (defer 로딩 때문)
   ```javascript
   ready(() => {
       // DOM 및 모든 라이브러리 접근 가능
   });
   ```
