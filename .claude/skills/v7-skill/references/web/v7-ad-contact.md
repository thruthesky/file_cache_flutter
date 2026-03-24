# v7 광고 연락처 시스템 + QR 코드 디코딩

## 목차

1. [개요](#1-개요)
2. [DB 필드 매핑](#2-db-필드-매핑)
3. [파일 구조](#3-파일-구조)
4. [관리자 판단 로직](#4-관리자-판단-로직)
5. [관리자 옵션 UI](#5-관리자-옵션-ui)
6. [QR 코드 디코딩 흐름](#6-qr-코드-디코딩-흐름)
7. [광고 연락처 저장 (submitPost)](#7-광고-연락처-저장-submitpost)
8. [광고 보기 페이지 (/post/adv)](#8-광고-보기-페이지-postadv)
9. [BannerEntity URL 경로 변환](#9-bannerentity-url-경로-변환)
10. [연락처 카드 CSS 디자인](#10-연락처-카드-css-디자인)
11. [v6과의 차이점](#11-v6과의-차이점)

---

## 1. 개요

v7 광고 연락처 시스템은 **관리자가 글 작성/수정 시** 광고용 연락처 정보를 입력하고,
**광고 보기 페이지(`/post/adv?idx=N`)에서** 플랫폼별 연락처 버튼을 표시하는 기능이다.

### 핵심 기능

| 기능 | 설명 |
|------|------|
| **관리자 옵션 토글** | 글 작성/수정 폼 하단에 "관리자 옵션" 버튼 → 클릭 시 패널 펼침 |
| **6종 연락처 입력** | 카카오톡, 텔레그램, SMS, 위챗, 라인, 페이스북 메신저 |
| **QR 코드 디코딩** | QR 이미지 업로드 → 클라이언트 측 jsQR 디코딩 → URL 자동 입력 |
| **광고 보기 페이지** | `/post/adv?idx=N`에서 글 본문 + 연락처 카드 버튼 표시 |
| **배너 URL 연동** | `BannerEntity::resolveClickUrl()` → `/post/adv?idx=N` |

### 데이터 흐름

```
관리자가 글 작성/수정
    ↓
post-form.js: 관리자 옵션 패널에서 연락처 입력 + QR 디코딩
    ↓
v7api('post.create' / 'post.update'): varchar_10~16, text_2, text_3, varchar_20 전달
    ↓
PostService::extractPostFields(): varchar_1~20, text_1~10 자동 허용
    ↓
sf_post_data 테이블에 저장
    ↓
/post/adv?idx=N: PostService::get()으로 조회 → 연락처 카드 렌더링
```

---

## 2. DB 필드 매핑

### sf_post_data 커스텀 필드 (광고 연락처)

| 연락처 종류 | DB 필드 | v6 상수 | JS data 속성 | 설명 |
|------------|---------|---------|-------------|------|
| 페이스북 메신저 URL | `varchar_10` | `FACEBOOK_MESSENGER_URL_FIELD` | `adFacebookMessengerUrl` | `https://m.me/...` 형식 |
| 카카오톡 ID | `varchar_11` | `KAKAOTALK_ID_FIELD` | `adKakaotalkId` | 카카오톡 채널/ID |
| 카카오톡 QR 이미지 | `varchar_12` | `KAKAOTALK_ID_QR_IMAGE_FIELD` | — | QR 이미지 URL (v6 호환) |
| 카카오톡 QR URL | `varchar_13` | `KAKAOTALK_ID_QR_URL_FIELD` | `adKakaotalkQrUrl` | QR 디코딩 결과 URL |
| 텔레그램 ID | `varchar_14` | `TELEGRAM_ID_FIELD` | `adTelegramId` | `@` 제외 ID |
| 전화번호 | `varchar_15` | `PHONE_NUMBER_FIELD` | `adPhoneNumber` | SMS 전송용 |
| 위챗 ID | `varchar_16` | `WECHAT_ID_FIELD` | `adWechatId` | 위챗 사용자 ID |
| 위챗 QR 이미지 URL | `text_2` | `WECHAT_QR_IMAGE_FIELD` | `adWechatQrImage` | QR 이미지 표시용 |
| 라인 ID | `text_3` | `LINE_ID_FIELD` | `adLineId` | 라인 사용자 ID |
| 라인 QR 이미지 | `text_6` | `LINE_QR_IMAGE_FIELD` | — | QR 이미지 URL (v6 호환) |
| 라인 QR URL | `varchar_20` | `LINE_QR_URL_FIELD` | `adLineQrUrl` | QR 디코딩 결과 URL |

> 상수 정의 위치: `lib/constants.php` 362~380행

---

## 3. 파일 구조

```
v7/js/post-form.js              # Vue.js 글 작성/수정 폼 — 관리자 옵션 + QR 디코딩
v7/post/adv.php                 # 광고 글 보기 페이지 (SSR) — 연락처 카드 렌더링
v7/post/adv.css                 # 연락처 카드 CSS (6종 플랫폼별 그래디언트)
v7/post/create.css              # 관리자 옵션 토글 + QR 버튼 + 연락처 그리드 CSS
v7/admin/ads-update.php         # 관리 광고 수정 — 수정하기/보기 링크
lib/advertisement/BannerEntity.php  # resolveClickUrl() → /post/adv?idx=N
lib/user/UserService.php        # getMe() — Firebase UID 기반 admin='Y' 설정
lib/constants.php               # 연락처 필드 상수 정의 (362~380행)
```

---

## 4. 관리자 판단 로직

### 핵심 문제와 해결

v7에서 관리자는 `sf_member.admin` 컬럼이 아닌 **Firebase UID 기반**(`Config::admins()`)으로 판단한다.
그런데 `user.me` API는 `sf_member.admin` 값을 그대로 반환하므로, JS에서 `data.admin === 'Y'` 비교가 실패했다.

### 해결: UserService::getMe()에서 admin 필드 설정

```php
// lib/user/UserService.php:487-496
public static function getMe(): UserEntity
{
    $user = AuthService::getLoginUser();
    if ($user !== null) {
        // v7 관리자 여부: Firebase UID 기반으로 admin 필드 설정
        if ($user->firebase_uid !== '' && in_array($user->firebase_uid, \V7\Utils\Config::admins(), true)) {
            $user->admin = 'Y';
        }
        return $user;
    }
    // ...
}
```

### JS 측 관리자 확인 (post-form.js)

```javascript
// post-form.js — mounted에서 호출
checkAdmin: async function () {
    try {
        var data = await v7api('user.me', {}, { alertOnError: false });
        this.isAdmin = data && data.admin === 'Y';
    } catch (e) {
        this.isAdmin = false;
    }
},
```

---

## 5. 관리자 옵션 UI

### Vue.js data 속성

```javascript
// post-form.js data
isAdmin: false,
adminOptionsExpanded: false,   // 관리자 옵션 패널 펼침/접기
reminder: '',                  // 공지글 ('Y' 또는 '')
qrDecoding: '',                // 현재 QR 디코딩 중인 필드명
adKakaotalkId: '',             // varchar_11
adKakaotalkQrUrl: '',          // varchar_13
adTelegramId: '',              // varchar_14
adPhoneNumber: '',             // varchar_15
adWechatId: '',                // varchar_16
adWechatQrImage: '',           // text_2
adLineId: '',                  // text_3
adLineQrUrl: '',               // varchar_20
adFacebookMessengerUrl: '',    // varchar_10
```

### 템플릿 구조

```html
<!-- 관리자 옵션 토글 버튼 (v-if="isAdmin") -->
<div v-if="isAdmin" class="post-form-group">
    <!-- 접힌 상태: 토글 버튼 -->
    <button v-if="!adminOptionsExpanded" type="button" class="post-admin-toggle"
            @click="adminOptionsExpanded = true">
        <i class="fa-solid fa-shield-halved"></i> 관리자 옵션
    </button>

    <!-- 펼친 상태: 옵션 패널 -->
    <div v-if="adminOptionsExpanded" class="post-admin-options">
        <div class="post-admin-header">
            <span class="post-admin-title">관리자 옵션</span>
            <button class="post-admin-close" @click="adminOptionsExpanded = false">×</button>
        </div>

        <!-- 공지글 체크박스 -->
        <label class="post-form-checkbox">
            <input type="checkbox" v-model="reminder" true-value="Y" false-value="">
            <span>공지글로 설정 (게시판 상단 고정)</span>
        </label>

        <!-- 광고 연락처 (2열 그리드, 9개 필드) -->
        <div class="post-admin-contact-grid">
            <!-- 카카오톡 ID -->
            <div class="post-admin-contact-field">
                <label>카카오톡 ID</label>
                <input type="text" v-model="adKakaotalkId">
            </div>
            <!-- 카카오톡 QR URL + QR 업로드 버튼 -->
            <div class="post-admin-contact-field">
                <label>카카오톡 QR URL</label>
                <div class="post-admin-qr-input">
                    <input type="text" v-model="adKakaotalkQrUrl">
                    <button class="post-admin-qr-btn" @click="$refs.qrKakao.click()"
                            :disabled="qrDecoding === 'adKakaotalkQrUrl'">
                        <i :class="qrDecoding === 'adKakaotalkQrUrl'
                            ? 'fa-solid fa-spinner fa-spin' : 'fa-solid fa-qrcode'"></i>
                    </button>
                    <input type="file" ref="qrKakao" accept="image/*" style="display:none"
                           @change="decodeQrImage($event, 'adKakaotalkQrUrl')">
                </div>
            </div>
            <!-- 위챗/라인 QR URL도 동일 패턴 (qrWechat, qrLine ref) -->
            <!-- ... 나머지 필드 (텔레그램, 전화번호, 위챗, 라인, 페이스북) ... -->
        </div>
    </div>
</div>
```

### CSS 클래스 체계 (create.css)

| CSS 클래스 | 용도 |
|-----------|------|
| `.post-admin-toggle` | 접힌 상태의 토글 버튼 (인디고 테두리, 0.75rem) |
| `.post-admin-options` | 펼쳐진 패널 (파란색 배경 `#eff6ff`, 테두리 `#bfdbfe`) |
| `.post-admin-header` | 패널 헤더 (제목 + 닫기 버튼) |
| `.post-admin-title` | 패널 제목 (인디고 `#4338ca`, 0.8rem) |
| `.post-admin-close` | 닫기 버튼 (X 아이콘) |
| `.post-admin-contact-grid` | 연락처 입력 그리드 (2열, 모바일 1열) |
| `.post-admin-contact-field` | 개별 연락처 입력 필드 |
| `.post-admin-qr-input` | QR URL 입력 + QR 버튼 래퍼 (flex) |
| `.post-admin-qr-btn` | QR 이미지 업로드 버튼 (32×32px) |

---

## 6. QR 코드 디코딩 흐름

### 사용 라이브러리

- **jsQR v1.4.0** — 순수 JavaScript QR 코드 디코더
- CDN: `https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js`
- MIT 라이선스, 무료 오픈소스, 서비스 비용 없음
- 클라이언트 측 실행 — 서버 의존성 없음, 네트워크 비용 없음

### 디코딩 흐름 다이어그램

```
1. QR 아이콘 버튼 클릭
   ↓
2. hidden <input type="file"> 트리거 ($refs.qrKakao.click())
   ↓
3. 사용자가 QR 코드 이미지 파일 선택
   ↓
4. qrDecoding = targetField → 스피너 표시 (fa-spinner fa-spin)
   ↓
5. jsQR CDN 동적 로드 (최초 1회만, window.jsQR 존재 확인)
   ↓
6. new Image() → img.src = URL.createObjectURL(file)
   ↓
7. img.onload → Canvas 생성 → ctx.drawImage(img)
   ↓
8. ctx.getImageData() → 픽셀 데이터 추출
   ↓
9. window.jsQR(imageData.data, width, height) 호출
   ↓
10a. 성공: self[targetField] = code.data (URL 자동 입력)
10b. 실패: alert('QR 코드를 인식하지 못했습니다.')
   ↓
11. qrDecoding = '' → 스피너 해제
```

### 핵심 코드 (post-form.js)

```javascript
/**
 * QR 코드 이미지를 선택하면 클라이언트에서 디코딩하여 URL 필드에 자동 입력한다.
 * jsQR 라이브러리를 CDN으로 동적 로드한다.
 *
 * @param {Event} event - file input change 이벤트
 * @param {string} targetField - 디코딩 결과를 저장할 data 속성명
 */
decodeQrImage: async function (event, targetField) {
    var file = event.target.files[0];
    if (!file) return;
    event.target.value = '';

    this.qrDecoding = targetField;

    // jsQR 라이브러리 동적 로드 (최초 1회)
    if (typeof window.jsQR === 'undefined') {
        try {
            await new Promise(function (resolve, reject) {
                var script = document.createElement('script');
                script.src = 'https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js';
                script.onload = resolve;
                script.onerror = reject;
                document.head.appendChild(script);
            });
        } catch (e) {
            alert('QR 디코딩 라이브러리 로드 실패');
            this.qrDecoding = '';
            return;
        }
    }

    // 이미지를 Canvas에 그려서 디코딩
    var self = this;
    var img = new Image();
    img.onload = function () {
        var canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        var ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);
        var imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        var code = window.jsQR(imageData.data, imageData.width, imageData.height);
        if (code && code.data) {
            self[targetField] = code.data;
        } else {
            alert('QR 코드를 인식하지 못했습니다. 다른 이미지를 시도하세요.');
        }
        self.qrDecoding = '';
    };
    img.onerror = function () {
        alert('이미지를 읽을 수 없습니다.');
        self.qrDecoding = '';
    };
    img.src = URL.createObjectURL(file);
},
```

### QR 업로드 대상 필드 (3개)

| 대상 | ref 이름 | targetField | 디코딩 결과 저장 |
|------|---------|------------|----------------|
| 카카오톡 QR | `qrKakao` | `adKakaotalkQrUrl` | varchar_13 |
| 위챗 QR | `qrWechat` | `adWechatQrImage` | text_2 |
| 라인 QR | `qrLine` | `adLineQrUrl` | varchar_20 |

---

## 7. 광고 연락처 저장 (submitPost)

### JS → API 파라미터 전달

```javascript
// post-form.js submitPost() 내부
// 관리자 광고 연락처 필드 추가
if (this.isAdmin) {
    params.varchar_11 = this.adKakaotalkId;
    params.varchar_13 = this.adKakaotalkQrUrl;
    params.varchar_14 = this.adTelegramId;
    params.varchar_15 = this.adPhoneNumber;
    params.varchar_16 = this.adWechatId;
    params.text_2 = this.adWechatQrImage;
    params.text_3 = this.adLineId;
    params.varchar_20 = this.adLineQrUrl;
    params.varchar_10 = this.adFacebookMessengerUrl;
}
```

### 수정 모드에서 로드 (loadPost)

```javascript
// post-form.js loadPost() 내부
// 광고 연락처 필드 로드 (관리자 옵션)
this.adKakaotalkId = data.varchar_11 || '';
this.adKakaotalkQrUrl = data.varchar_13 || '';
this.adTelegramId = data.varchar_14 || '';
this.adPhoneNumber = data.varchar_15 || '';
this.adWechatId = data.varchar_16 || '';
this.adWechatQrImage = data.text_2 || '';
this.adLineId = data.text_3 || '';
this.adLineQrUrl = data.varchar_20 || '';
this.adFacebookMessengerUrl = data.varchar_10 || '';
```

### 백엔드 허용 (PostService)

`PostService::extractPostFields()` 메서드에서 `varchar_1~20`, `text_1~10`을 자동 허용하므로
별도의 백엔드 수정 없이 연락처 필드가 저장된다.

```php
// lib/post/PostService.php extractPostFields()
for ($i = 1; $i <= 20; $i++) {
    $field = "varchar_{$i}";
    if (isset($input[$field])) {
        $data[$field] = (string)$input[$field];
    }
}
for ($i = 1; $i <= 10; $i++) {
    $field = "text_{$i}";
    if (isset($input[$field])) {
        $data[$field] = (string)$input[$field];
    }
}
```

---

## 8. 광고 보기 페이지 (/post/adv)

### URL 및 파일

- **URL**: `/post/adv?idx=N` (.php 없이)
- **파일**: `v7/post/adv.php` + `v7/post/adv.css`

### 핵심 코드 (adv.php)

```php
// 글 조회
$post = PostService::get(['idx' => $idx]);
PostService::increaseViewCount($idx);

// 연락처 필드 추출
$kakaotalkId = (string) ($post->varchar_11 ?? '');
$kakaotalkQrUrl = (string) ($post->varchar_13 ?? '');
$telegramId = (string) ($post->varchar_14 ?? '');
$phoneNumber = (string) ($post->varchar_15 ?? '');
$wechatId = (string) ($post->varchar_16 ?? '');
$wechatQrImage = (string) ($post->text_2 ?? '');
$lineId = (string) ($post->text_3 ?? '');
$lineQrUrl = (string) ($post->varchar_20 ?? '');
$facebookMessengerUrl = (string) ($post->varchar_10 ?? '');
```

### 6종 연락처 카드 구조

| 플랫폼 | CSS 클래스 | 배경 그래디언트 | 링크 형식 | 아이콘 |
|--------|-----------|---------------|----------|--------|
| 카카오톡 | `.contact-card-kakao` | `#F7C815 → #F9D71C` | QR URL 직접 | `fa-solid fa-comment-dots` |
| 텔레그램 | `.contact-card-telegram` | `#0077B5 → #0088CC` | `https://t.me/{id}` | `fa-brands fa-telegram` |
| SMS | `.contact-card-phone` | `#E9ECEF → #DEE2E6` | `sms:{number}` | `fa-solid fa-comment-sms` |
| 위챗 | `.contact-card-wechat` | `#07C160 → #09B05C` | 클릭 불가 (QR 표시) | `fa-brands fa-weixin` |
| 라인 | `.contact-card-line` | `#00B900 → #00C300` | QR URL 또는 `line.me` | `fa-brands fa-line` |
| 메신저 | `.contact-card-messenger` | `#0084FF → #0099FF` | 직접 URL | `fa-brands fa-facebook-messenger` |

### 위챗 QR 코드 특별 처리

위챗 카드만 `<div>`로 렌더링되며(클릭 불가), QR 이미지가 카드 오른쪽에 표시:

```html
<div class="contact-card contact-card-wechat has-qr">
    <!-- 아이콘 + 텍스트 -->
    <div class="contact-qr-wrapper">
        <img src="<?= htmlspecialchars($wechatQrImage) ?>" alt="WeChat QR Code">
    </div>
</div>
```

```css
.contact-card-wechat.has-qr { padding-right: 110px; }
.contact-qr-wrapper {
    position: absolute; top: 0; right: 0; bottom: 0;
    border-radius: 0 16px 16px 0;
}
```

---

## 9. BannerEntity URL 경로 변환

### resolveClickUrl() (lib/advertisement/BannerEntity.php)

```php
public static function resolveClickUrl(string $url): string
{
    if (empty($url)) return '';
    if (str_starts_with($url, 'http')) return $url;      // 외부 URL 그대로
    if (ctype_digit($url)) return "/post/adv?idx=$url";  // 숫자 → /post/adv
    if (preg_match('/idx=(\d+)/', $url, $m)) return "/post/adv?idx={$m[1]}";
    return $url;
}
```

### 관리자 광고 관리 링크 (ads-update.php)

```php
$clickUrl = BannerEntity::resolveClickUrl($company['ad_click_url']);
$editUrl = str_replace('/post/adv', '/post/update', $clickUrl);  // 수정하기
// 광고 보기: $clickUrl (/post/adv?idx=N)
// 광고 수정하기: $editUrl (/post/update?idx=N)
// 광고 등록 게시판: /post/list?post_id=company_info
```

---

## 10. 연락처 카드 CSS 디자인

### 공통 호버 효과 (adv.css)

```css
.contact-card:hover {
    transform: translateY(-5px) scale(1.02);
    box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}
/* 빛 스칼라 효과 */
.contact-card::before {
    background: linear-gradient(135deg, transparent, rgba(255,255,255,0.1), transparent);
    transform: translateX(-100%);
}
.contact-card:hover::before { transform: translateX(100%); }
/* 아이콘 회전 */
.contact-card-kakao:hover .contact-icon { transform: rotate(15deg) scale(1.1); }
```

### 반응형 (모바일 ≤576px)

```css
@media (max-width: 576px) {
    .contact-icon-wrapper { width: 75px; margin-right: 1rem; }
    .contact-icon { font-size: 2.75rem; }
    .contact-id { font-size: 1.5rem; }
    .contact-card-wechat.has-qr { padding-right: 90px; }
    .contact-qr-wrapper { width: 80px; }
}
```

---

## 11. v6과의 차이점

| 항목 | v6 | v7 |
|------|----|----|
| **QR 디코딩** | 서버 측 (`v5-files/upload.php`에서 `decodeQrCode=Y`) | 클라이언트 측 (jsQR CDN, 서버 의존성 없음) |
| **UI 프레임워크** | Bootstrap + jQuery | Web Awesome Pro + Vue.js (Bootstrap 미사용) |
| **API 호출** | `func()` | `v7api()` |
| **관리자 옵션 UI** | 항상 표시 | 토글 버튼 → 클릭 시 펼침 |
| **관리자 판단** | `is_admin()` 전역 함수 | Firebase UID 기반 (`Config::admins()`) |
| **광고 보기 경로** | `/post/adv.php?idx=N` | `/post/adv?idx=N` (.php 없이) |
| **파일 업로드** | `file-upload` Vue 컴포넌트 (`decodeQrCode` prop) | hidden `<input type="file">` + jsQR |
| **다국어** | `t()->inject()` 4개 언어 | 하드코딩 한국어 (v7 다국어 시스템 미적용) |
| **다크모드** | 지원 (`:root[data-bs-theme="dark"]`) | 미지원 (v7 라이트 모드 전용) |
