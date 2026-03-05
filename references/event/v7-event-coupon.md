# 이벤트 쿠폰 관리 시스템

> **📌 문서 목적**: `event_coupons` DB 테이블 기반 범용 쿠폰 관리 시스템의 전체 구조,
> 관리자 쿠폰 등록/관리, 스피닝 휠 당첨 시 쿠폰 배정, 사용자에게 쿠폰 표시 로직을 다룬다.

## 목차

- [1. 핵심 개념](#1-핵심-개념)
- [2. DB 스키마 — event_coupons](#2-db-스키마--event_coupons)
- [3. 쿠폰 상태 흐름](#3-쿠폰-상태-흐름)
- [4. 관리자 쿠폰 등록 (Admin Widget)](#4-관리자-쿠폰-등록-admin-widget)
- [5. 관리자 쿠폰 관리 (목록/필터/수정/삭제)](#5-관리자-쿠폰-관리-목록필터수정삭제)
- [6. 쿠폰 당첨 배정 (스피닝 휠 연동)](#6-쿠폰-당첨-배정-스피닝-휠-연동)
- [7. 당첨 쿠폰 사용자 표시](#7-당첨-쿠폰-사용자-표시) ← `event.viewCoupon` API, QR 확인 흐름 포함
- [8. v7 클래스 구조](#8-v7-클래스-구조)
- [9. 레거시 API 함수](#9-레거시-api-함수)
- [10. 파일 구조](#10-파일-구조)

---

## 1. 핵심 개념

- **DB 기반 쿠폰 관리**: `event_coupons` 테이블에서 쿠폰 등록/배정/전송/만료 상태를 관리한다
- **v7 Upload API 연동**: QR 이미지를 `uploads` 테이블에 저장하고 `idx_upload`로 연결한다
- **Race Condition 방어**: `SELECT ... FOR UPDATE`로 동시 당첨 시 중복 배정을 방지한다
- **동적 확률 조정**: 사용 가능 쿠폰이 0개이면 스타벅스 확률이 자동으로 0%가 된다
- **범용 쿠폰 타입**: `coupon_type` 필드로 스타벅스 외 다양한 쿠폰 유형 확장 가능

---

## 2. DB 스키마 — event_coupons

```sql
CREATE TABLE `event_coupons` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `coupon_type` varchar(50) NOT NULL DEFAULT 'starbucks' COMMENT '쿠폰 유형',
  `title` varchar(255) NOT NULL DEFAULT '' COMMENT '쿠폰 제목',
  `memo` text DEFAULT NULL COMMENT '관리자 메모',
  `image_url` varchar(512) DEFAULT NULL COMMENT '외부 이미지 URL (레거시 호환)',
  `idx_upload` int(10) UNSIGNED DEFAULT NULL COMMENT 'uploads 테이블 FK (v7 Upload API)',
  `status` varchar(20) NOT NULL DEFAULT 'available' COMMENT 'available|won|sent|expired|cancelled',
  `idx_winner` int(10) UNSIGNED DEFAULT NULL COMMENT '당첨자 sf_member.idx',
  `idx_spin_history` int(10) UNSIGNED DEFAULT NULL COMMENT 'event_spin_history.idx',
  `won_at` int(10) UNSIGNED DEFAULT NULL COMMENT '당첨 시간 (unix timestamp)',
  `sent_at` int(10) UNSIGNED DEFAULT NULL COMMENT '전송 완료 시간',
  `viewed_at` int(10) UNSIGNED DEFAULT NULL COMMENT 'QR 코드 최초 확인 시간',
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`idx`),
  KEY `idx_status` (`status`),
  KEY `idx_coupon_type_status` (`coupon_type`, `status`),
  KEY `idx_winner` (`idx_winner`),
  KEY `idx_upload` (`idx_upload`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='이벤트 쿠폰 관리';
```

### 주요 컬럼 설명

| 컬럼 | 용도 | 비고 |
|------|------|------|
| `coupon_type` | 쿠폰 유형 (`starbucks`, `mcdonalds` 등) | 확장 가능 |
| `idx_upload` | v7 Upload API로 업로드된 QR 이미지 FK | `uploads.idx` 참조 |
| `image_url` | 외부 이미지 URL (레거시 호환) | `idx_upload` 우선, 없으면 이 필드 사용 |
| `status` | 쿠폰 상태 (아래 상태 흐름 참조) | 5가지 상태 |
| `idx_winner` | 당첨자 회원 번호 | `sf_member.idx` FK |
| `idx_spin_history` | 스피닝 휠 게임 기록 번호 | `event_spin_history.idx` FK |
| `viewed_at` | QR 코드 최초 확인 시간 (unix timestamp) | NULL이면 미확인, 값이 있으면 확인 완료. 1회만 기록 |

### 이미지 표시 우선순위

쿠폰 목록 조회 시 이미지 URL 결정 로직:

```sql
SELECT c.*, COALESCE(c.image_url, u.url) as display_image_url,
       u.thumbnail_400x400_url as thumbnail_url
FROM event_coupons c
LEFT JOIN uploads u ON c.idx_upload = u.idx
```

- **1순위**: `c.image_url` (외부 URL — 레거시 호환)
- **2순위**: `u.url` (v7 Upload API로 업로드된 이미지)
- **썸네일**: `u.thumbnail_400x400_url` (목록에서 50x50으로 축소 표시)

---

## 3. 쿠폰 상태 흐름

```
available (미사용)
  ├─ [스피닝 휠 당첨] → won (당첨)
  │                      ├─ [관리자 전송 완료] → sent (전송완료)
  │                      │                      └─ [전송 취소] → won (당첨)
  │                      └─ [만료 처리] → expired
  ├─ [관리자 삭제] → DELETE (DB에서 삭제)
  └─ [취소 처리] → cancelled
```

| 상태 | 의미 | 관리자 가능 액션 |
|------|------|-----------------|
| `available` | 미사용 (대기 중) | 수정, 삭제 |
| `won` | 당첨 (배정 완료) | 전송 완료 처리 |
| `sent` | 전송 완료 (사용자에게 발송됨) | 전송 취소 |
| `expired` | 만료 | — |
| `cancelled` | 취소 | — |

**규칙**:
- `available` 상태의 쿠폰만 삭제 가능
- `won` → `sent` 전환만 가능 (역방향: `sent` → `won` 전송 취소도 가능)
- 당첨된 쿠폰은 삭제 불가

---

## 4. 관리자 쿠폰 등록 (Admin Widget)

### 4.1 접속 경로

- **관리자 페이지 URL**: `https://local.philgo.com/page/admin/event-coupon-list.php`
- **위젯 파일**: `widgets/admin/event/coupon-list.php`

### 4.2 등록 폼 구조

| 필드 | 필수 | 설명 |
|------|:----:|------|
| 쿠폰 유형 (coupon_type) | ✅ | `<select>` — 기본값 `starbucks` |
| 쿠폰 제목 (title) | ❌ | 선택 사항 (예: "아메리카노 기프티콘") |
| QR 이미지 | ✅ | v7 Upload API로 업로드 — 빨간 `*` 필수 표시 |
| 메모 (memo) | ❌ | 관리자용 메모 |

### 4.3 QR 이미지 업로드 흐름

```
파일 선택 (@change="onFileSelected")
  ↓
v7Upload(file, 'event', 'coupon_qr')
  ↓ axios.post('/api.php', formData)
  ↓ method=upload.upload, module=event, code=coupon_qr
  ↓
uploads 테이블에 저장
  ↓
응답: { idx, url, thumbnail_400x400_url }
  ↓
idxUpload = data.idx
uploadedUrl = data.thumbnail_400x400_url || data.url
  ↓
미리보기 표시 (80x80 썸네일)
```

**v7Upload 헬퍼 함수** (위젯 내 JavaScript):

```javascript
async function v7Upload(file, module, code) {
    const formData = new FormData();
    formData.append('method', 'upload.upload');
    formData.append('module', module);
    formData.append('code', code);
    formData.append('file', file);
    const res = await axios.post('/api.php', formData);
    if (res.data && res.data.success === false) {
        throw new Error(res.data.message || '업로드 실패');
    }
    return res.data;
}
```

**v7DeleteUpload 헬퍼 함수**:

```javascript
async function v7DeleteUpload(idx) {
    if (!idx) return;
    try {
        await axios.get('/api.php', { params: { method: 'upload.delete', idx: idx } });
    } catch (e) { /* 삭제 실패 무시 */ }
}
```

### 4.4 쿠폰 등록 API 호출

```javascript
// 필수 검증: coupon_type + idxUpload
if (!this.couponType.trim()) { /* 에러: 쿠폰 유형 필수 */ return; }
if (!this.idxUpload) { /* 에러: QR 이미지 필수 */ return; }

const res = await axios.post('/api.php', Object.assign({
    method: 'event.createCoupon'
}, {
    coupon_type: 'starbucks',
    title: '아메리카노 기프티콘',
    memo: '관리자 메모',
    idx_upload: this.idxUpload
}));
if (res.data && res.data.success === false) {
    // 에러 처리
    return;
}
// 성공 → res.data.idx 로 생성된 쿠폰 idx 확인
```

**백엔드 흐름**: `axios.post('/api.php', { method: 'event.createCoupon' })` → `api.php` → `EventController::createCoupon()` → `requireAdmin()` (ADMINS 상수로 관리자 확인) → `EventCouponService::createCoupon()` → `EventCouponRepository::create()` → `event_coupons` INSERT

### 4.5 Vue.js 등록 앱 (coupon-create-app)

```javascript
Vue.createApp({
    data() {
        return {
            couponType: 'starbucks',
            title: '',
            memo: '',
            idxUpload: 0,       // uploads 테이블 idx
            uploadedUrl: '',     // 미리보기 URL
            uploading: false,    // 업로드 진행 중
            loading: false,      // 등록 API 호출 중
            message: '',
            messageClass: 'alert-success',
        };
    },
    methods: {
        onFileSelected(event),   // 파일 선택 → v7Upload
        removeImage(),           // 이미지 삭제 → v7DeleteUpload
        createCoupon(),          // 등록 → axios.post('/api.php', { method: 'event.createCoupon' })
        resetForm(),             // 폼 초기화
        showMessage(msg, cls),   // 결과 메시지 표시 (5초 후 자동 소멸)
    },
}).mount('#coupon-create-app');
```

---

## 5. 관리자 쿠폰 관리 (목록/필터/수정/삭제)

### 5.1 통계 대시보드

위젯 상단에 쿠폰 통계를 표시한다:

```
전체: 50개 | 미사용: 30개 | 당첨: 10개 | 전송완료: 8개 | 만료: 2개 | 취소: 0개
───────────
[starbucks] 전체: 50  미사용: 30  당첨: 10  전송완료: 8
```

**통계 API**: `EventCouponService::getStatsSummary()` → PHP 서버 사이드 렌더링

### 5.2 필터 시스템

| 필터 | 타입 | 옵션 |
|------|------|------|
| 유형 (coupon_type) | `<select>` | 전체 + DB에 등록된 유형 목록 |
| 상태 (status) | `<select>` | 전체/미사용/당첨/전송완료/만료/취소 |
| 검색 (search) | `<input>` | 제목/메모 LIKE 검색 |

필터는 GET 파라미터로 전달: `?coupon_type=starbucks&status=won&search=아메리카노&page=1`

### 5.3 쿠폰 목록 테이블

| 컬럼 | 내용 |
|------|------|
| # | 쿠폰 idx |
| 이미지 | 50x50 썸네일 (클릭 시 원본 새 탭 오픈) |
| 유형 | `badge bg-info` 스타일 |
| 제목 | 제목 + 메모 (줄바꿈) |
| 상태 | 색상 배지 (available=초록, won=노랑, sent=파랑 등) |
| 당첨자 | 닉네임 (관리자 회원정보 페이지 링크) |
| 당첨일 | `Y-m-d H:i` 형식 |
| 관리 | 상태별 버튼 (아래 참조) |

### 5.4 상태별 관리 버튼

| 상태 | 버튼 | 동작 |
|------|------|------|
| `available` | 수정 + 삭제 | 수정 모달 / `axios.post('/api.php', { method: 'event.deleteCoupon', idx })` |
| `won` | 전송 | `axios.post('/api.php', { method: 'event.updateCouponSent', idx, sent: true })` |
| `sent` | 전송취소 | `axios.post('/api.php', { method: 'event.updateCouponSent', idx, sent: false })` |
| `expired` / `cancelled` | 없음 | — |

### 5.5 쿠폰 수정 (Bootstrap Modal)

수정 모달(`#editCouponModal`)에서 제목, 메모, QR 이미지를 변경할 수 있다.

```javascript
// 수정 모달 열기
window.openEditCoupon = function(idx, title, memo, imageUrl, idxUpload) {
    editApp.open(idx, title, memo, imageUrl, idxUpload);
    const modal = new bootstrap.Modal(document.getElementById('editCouponModal'));
    modal.show();
};

// 수정 저장
const res = await axios.post('/api.php', Object.assign({
    method: 'event.updateCoupon'
}, {
    idx: this.editIdx,
    title: this.editTitle.trim(),
    memo: this.editMemo.trim(),
    idx_upload: this.editIdxUpload,
    image_url: '',  // v7 Upload으로 전환하므로 image_url 초기화
}));
```

**이미지 교체 로직**:
1. 새 이미지 업로드 → `v7Upload(file, 'event', 'coupon_qr')`
2. 기존 업로드 삭제 → `v7DeleteUpload(기존 editIdxUpload)`
3. 새 idx_upload 저장

### 5.6 페이지네이션

- 페이지당 20개 (`$limit = 20`)
- Bootstrap 페이지네이션 컴포넌트 사용
- 필터 파라미터 유지: `?page=2&coupon_type=starbucks&status=won&search=xxx`

---

## 6. 쿠폰 당첨 배정 (스피닝 휠 연동)

### 6.1 동적 확률 조정

스피닝 휠 게임 시작 시 사용 가능한 쿠폰 유무에 따라 확률이 동적으로 변경된다:

```php
// EventService::calculateSpinResult()
$sections = self::getSections();
if (!$hasStarbucksCoupon) {
    $sections[0]['weight'] += $sections[8]['weight']; // 50P: 379 → 381
    $sections[8]['weight'] = 0;                        // 스타벅스: 2 → 0
}
```

| 조건 | 스타벅스 weight | 스타벅스 확률 | 50P weight |
|------|:--------------:|:------------:|:----------:|
| 쿠폰 1개 이상 | 2 | 0.2% | 379 |
| 쿠폰 0개 | 0 | 0% | 381 |

### 6.2 쿠폰 배정 흐름 (트랜잭션 내부)

```
EventService::spin()
  ↓ 확률 계산 → prize_type == 'starbucks'
  ↓
EventCouponService::assignCouponToWinner('starbucks', $idxMember, $spinIdx)
  ↓
EventCouponRepository::lockAndPickAvailable('starbucks')
  ↓ SELECT * FROM event_coupons
    WHERE status='available' AND coupon_type='starbucks'
    ORDER BY created_at ASC LIMIT 1 FOR UPDATE
  ↓
EventCouponRepository::assignToWinner($couponIdx, $idxMember, $spinIdx)
  ↓ UPDATE event_coupons
    SET status='won', idx_winner=?, idx_spin_history=?, won_at=?
    WHERE idx=? AND status='available'
  ↓
쿠폰 배정 완료 → 트랜잭션 커밋
```

### 6.3 Race Condition 방어

```php
// EventCouponRepository::lockAndPickAvailable()
$sql = "SELECT * FROM event_coupons
        WHERE status = 'available' AND coupon_type = :type
        ORDER BY created_at ASC LIMIT 1 FOR UPDATE";
```

- `FOR UPDATE`: 해당 행에 **배타적 잠금** → 다른 트랜잭션이 대기
- `ORDER BY created_at ASC`: 가장 오래된 쿠폰부터 순서대로 배정
- `LIMIT 1`: 한 번에 1개만 배정
- `WHERE status = 'available'`: 이미 배정된 쿠폰 제외

### 6.4 당첨 시 자동 게시글 작성

스타벅스 쿠폰 당첨 시 커밋 후 자동으로 freetalk 게시판에 당첨 글을 작성한다:

```php
// EventService::spin() — 트랜잭션 커밋 후 실행
if ($prizeType === 'starbucks') {
    try {
        PostService::create([
            'idx_member' => $idxMember,
            'post_id' => 'freetalk',
            'subject' => '필고 스타벅스 이용 쿠폰에 당첨되었습니다',
            'content' => '필고 포인트 이벤트를 통해서 스타벅스 이용권에 당첨되었습니다.',
        ]);
    } catch (\Exception $e) {
        // 글 작성 실패 시에도 스핀 결과는 유지
        Debug::log('[EventService] 스타벅스 당첨 글 작성 실패: ' . $e->getMessage());
    }
}
```

---

## 7. 당첨 쿠폰 사용자 표시

### 7.1 스피닝 휠 API 응답

쿠폰 당첨 시 `event.spin` API 응답에 `coupon` 객체가 포함된다:

```json
{
  "success": true,
  "section_index": 8,
  "points": -1,
  "prize_type": "starbucks",
  "current_point": 4800,
  "lv": 3,
  "level_progress": 45,
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 2,
  "spin_idx": 789,
  "coupon": {
    "idx": 42,
    "title": "아메리카노 기프티콘",
    "coupon_type": "starbucks"
  }
}
```

> **참고**: `starbucks_coupon_file`과 `starbucks_coupon_url`은 레거시 호환용으로 항상 `null`을 반환한다.
> 쿠폰 정보는 `coupon` 객체에서 확인한다. 스타벅스 미당첨 시 `coupon`은 `null`이다.

### 7.2 Flutter 앱에서 스피닝 휠 결과 쿠폰 표시

스피닝 휠 결과 다이얼로그에서 `prize_type == 'starbucks'`일 때 `coupon` 객체로 쿠폰 정보를 표시한다:

```dart
// 스피닝 휠 결과 콜백
onResult: (section) {
    if (_lastSpinResult['prize_type'] == 'starbucks') {
        final coupon = _lastSpinResult['coupon'];
        _showStarbucksCouponDialog(
            couponTitle: coupon?['title'] ?? '',
            couponIdx: coupon?['idx'],
        );
    } else {
        _showPointResultDialog(_lastSpinResult);
    }
}
```

### 7.3 내 당첨 쿠폰 목록 API — event.myCoupons

로그인 사용자의 당첨 쿠폰 목록을 `event_coupons` 테이블에서 조회한다.
`uploads` 테이블과 JOIN하여 쿠폰 이미지 URL을 포함한다.

**API**: `POST /api.php?method=event.myCoupons` 또는 `GET /api.php?method=event.myCoupons&session_id=xxx&page=1&limit=20`

```json
// 요청
{
  "method": "event.myCoupons",
  "session_id": "xxx",
  "page": 1,
  "limit": 20
}

// 응답
{
  "success": true,
  "total": 3,
  "page": 1,
  "limit": 20,
  "items": [
    {
      "idx": 42,
      "coupon_type": "starbucks",
      "title": "아메리카노 기프티콘",
      "memo": null,
      "status": "sent",
      "won_at": 1709446800,
      "sent_at": 1709533200,
      "idx_spin_history": 789,
      "display_image_url": "/uploads/event/coupon_qr/image.jpg",
      "thumbnail_url": "/uploads/event/coupon_qr/image_400x400.jpg"
    }
  ]
}
```

**응답 필드**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `total` | int | 전체 당첨 쿠폰 수 |
| `items[].idx` | int | 쿠폰 번호 |
| `items[].coupon_type` | string | 쿠폰 유형 (`starbucks` 등) |
| `items[].title` | string | 쿠폰 제목 |
| `items[].status` | string | `won` (당첨) 또는 `sent` (전송완료) |
| `items[].won_at` | int | 당첨 시간 (Unix timestamp) |
| `items[].sent_at` | int\|null | 전송 완료 시간 |
| `items[].viewed_at` | int\|null | QR 코드 최초 확인 시간 (NULL이면 미확인) |
| `items[].display_image_url` | string\|null | 쿠폰 이미지 URL (`COALESCE(image_url, uploads.url)`) |
| `items[].thumbnail_url` | string\|null | 썸네일 URL |

### 7.4 쿠폰 QR 코드 확인 API — event.viewCoupon

사용자가 쿠폰 QR 코드를 확인할 때 호출하여 `viewed_at`에 최초 확인 시간을 기록한다.
이미 확인한 쿠폰은 `viewed_at`을 갱신하지 않고 기존 쿠폰 정보를 반환한다.

**API**: `GET /api.php?method=event.viewCoupon&session_id=xxx&idx=123`

```json
// 요청
{
  "method": "event.viewCoupon",
  "session_id": "xxx",
  "idx": 123
}

// 응답
{
  "success": true,
  "idx": 123,
  "coupon_type": "starbucks",
  "title": "아메리카노 기프티콘",
  "status": "won",
  "viewed_at": 1709533200,
  "won_at": 1709446800
}
```

**비즈니스 규칙**:
- 인증 필수 (본인 쿠폰만 확인 가능)
- 상태가 `won` 또는 `sent`인 쿠폰만 확인 가능
- `viewed_at`이 NULL인 경우에만 현재 시간 기록 (최초 1회)
- 이미 확인된 쿠폰도 에러 없이 현재 정보 반환

**Flutter 앱 사용 흐름**:
1. 사용자가 쿠폰 목록에서 쿠폰 클릭
2. 미확인 쿠폰: 확인 다이얼로그 표시 ("쿠폰을 사용하시겠습니까?")
3. 사용자가 "예, 사용하겠습니다" 클릭
4. `event.viewCoupon` API 호출 → `viewed_at` 기록
5. QR 코드 이미지를 전체 화면 다이얼로그로 표시
6. 이미 확인한 쿠폰: 다이얼로그 없이 바로 QR 코드 표시

**쿠폰 목록에서 확인 날짜 표시**:
- `viewed_at`이 있는 쿠폰은 "확인 날짜: YYYY.MM.DD" 형태로 표시
- tertiary 색상으로 구분하여 시각적 식별

### 7.5 Flutter 앱에서 쿠폰 목록 표시

`event.myCoupons` API를 호출하여 당첨 쿠폰 목록을 표시한다.

**파일**: `lib/screens/event/event_coupon.screen.dart`

```dart
// API 호출
final result = await v7api('event.myCoupons', data: {'page': 1, 'limit': 100});
final items = (result['items'] as List<dynamic>?) ?? [];
_coupons = items.whereType<Map<String, dynamic>>().toList();
```

**이미지 URL 처리**:

```dart
String _getCouponImageUrl(Map<String, dynamic> coupon) {
    final imageUrl = coupon['display_image_url'] as String? ?? '';
    if (imageUrl.isEmpty) return '';
    // 절대 URL인 경우 그대로 반환
    if (imageUrl.startsWith('http')) return imageUrl;
    // 상대 경로인 경우 baseUrl 결합
    final baseUrl = PhilgoConfig.v7ApiEndpoint.replaceAll('/api.php', '');
    return '$baseUrl$imageUrl';
}
```

**쿠폰 카드 표시 정보**:

| 항목 | 필드 | 설명 |
|------|------|------|
| 쿠폰 제목 | `title` | "아메리카노 기프티콘" |
| 당첨 날짜 | `won_at` | Unix timestamp → `YYYY.MM.DD` 포맷 |
| 전송 상태 | `status` | `sent`일 때 체크 아이콘 (primary 색상) |
| 쿠폰 보기 | `display_image_url` | 다이얼로그에서 핀치 줌 지원 이미지 표시 |

### 7.5 웹에서 쿠폰 히스토리 표시

`event.history` API로 사용자의 스핀 기록을 조회하면 당첨 기록이 포함된다.
단, 쿠폰 이미지 URL은 `event.myCoupons` API에서 별도 조회해야 한다.

```json
{
  "total": 2,
  "page": 1,
  "limit": 20,
  "items": [
    {
      "idx": 42,
      "coupon_type": "starbucks",
      "title": "아메리카노 기프티콘",
      "memo": "",
      "status": "won",
      "won_at": 1709446800,
      "sent_at": null,
      "idx_spin_history": 789,
      "display_image_url": "https://file.philgo.com/uploads/qr.png",
      "thumbnail_url": "https://file.philgo.com/uploads/qr_400x400.png"
    }
  ]
}
```

- `status`가 `won`(당첨) 또는 `sent`(전송완료)인 쿠폰만 반환
- `display_image_url`: COALESCE(c.image_url, u.url) — v7 Upload 이미지 우선
- `thumbnail_url`: uploads 테이블의 400x400 썸네일

### 7.4 관리자 당첨자 확인 → 쿠폰 전송

```
관리자 쿠폰 관리 페이지 (status=won 필터)
  ↓
당첨자 닉네임 확인 (sf_member 조인)
  ↓
QR 이미지 클릭 → 원본 이미지 새 탭 오픈
  ↓
별도 채널(카카오톡 등)로 쿠폰 이미지를 사용자에게 전송
  ↓
"전송" 버튼 클릭 → axios.post('/api.php', { method: 'event.updateCouponSent', idx, sent: true })
  ↓
상태: won → sent
```

---

## 8. v7 클래스 구조

```
lib/event/
├── EventCouponService.php      ← 쿠폰 비즈니스 로직 (Philgo\Event\EventCouponService)
│   ├── createCoupon(array): array           ← 쿠폰 생성 (관리자)
│   ├── deleteCoupon(array): bool            ← 쿠폰 삭제 (available만)
│   ├── updateCoupon(array): array           ← 쿠폰 수정 (관리자)
│   ├── assignCouponToWinner(?type, idx, spin): ?array  ← 당첨자 배정 (트랜잭션 내)
│   ├── toggleSentStatus(array): array       ← 전송 상태 토글
│   ├── getAvailableCount(?type): int        ← 사용 가능 쿠폰 수
│   ├── hasAvailableCoupon(?type): bool      ← 쿠폰 존재 여부
│   ├── getStatsSummary(): array             ← 유형별/상태별 통계
│   ├── getCouponListForAdmin(array): array  ← 관리자 목록 (페이지네이션)
│   └── markCouponViewed(array, int): array  ← QR 코드 최초 확인 시간 기록 (본인 쿠폰만)
│
├── EventCouponRepository.php   ← 쿠폰 DB 계층 (Philgo\Event\EventCouponRepository)
│   ├── create(array): int                   ← INSERT
│   ├── findByIdx(int): ?array               ← SELECT by idx
│   ├── findAvailableByType(string): array   ← 유형별 available 목록
│   ├── lockAndPickAvailable(?type): ?array  ← SELECT ... FOR UPDATE (1개)
│   ├── assignToWinner(idx, member, spin): bool  ← 당첨자 배정 UPDATE
│   ├── markAsSent(idx): bool                ← won → sent
│   ├── unmarkSent(idx): bool                ← sent → won
│   ├── delete(idx): bool                    ← DELETE (available만)
│   ├── update(idx, data): bool              ← UPDATE
│   ├── countAvailable(?type): int           ← COUNT(available)
│   ├── getStatsByType(): array              ← GROUP BY 통계
│   ├── getDistinctTypes(): array            ← DISTINCT coupon_type
│   ├── getListWithPagination(filters, page, limit): array  ← 페이지네이션 목록
│   ├── findByWinner(idxMember, page, limit): array  ← 당첨자별 쿠폰 목록 (won/sent, viewed_at 포함)
│   └── markAsViewed(idx): bool              ← QR 코드 최초 확인 (viewed_at NULL → 현재 시간)
│
├── EventService.php            ← 스피닝 휠 로직 + DB 기반 쿠폰 배정
├── EventController.php         ← event.* API (스핀 + 쿠폰 관리 통합)
│   ├── spin(array): array                 ← 스피닝 휠 돌리기
│   ├── history(array): array              ← 스핀 히스토리 조회
│   ├── myCoupons(array): array            ← 내 당첨 쿠폰 목록 조회
│   ├── viewCoupon(array): array           ← 쿠폰 QR 코드 확인 (viewed_at 기록)
│   ├── createCoupon(array): array         ← 쿠폰 생성 (관리자)
│   ├── deleteCoupon(array): array         ← 쿠폰 삭제 (관리자)
│   ├── updateCoupon(array): array         ← 쿠폰 수정 (관리자)
│   ├── updateCouponSent(array): array     ← 전송 상태 토글 (관리자)
│   ├── listCoupons(array): array          ← 쿠폰 목록 조회 (관리자)
│   └── couponStats(array): array          ← 쿠폰 통계 조회 (관리자)
└── EventRepository.php          ← event_spin_history DB 계층
```

---

## 9. v7 API 엔드포인트 (관리자 전용 쿠폰 관리)

쿠폰 관리 API는 **v7 API** (`api.php` → `EventController`)를 통해 제공된다.
관리자 확인은 `ADMINS` 상수(firebase_uid 배열)로 수행한다.

| API method | 용도 | 권한 | Controller 메서드 |
|------------|------|------|-------------------|
| `event.createCoupon` | 쿠폰 생성 | 관리자 | `EventController::createCoupon()` |
| `event.deleteCoupon` | 쿠폰 삭제 | 관리자 | `EventController::deleteCoupon()` |
| `event.updateCoupon` | 쿠폰 수정 | 관리자 | `EventController::updateCoupon()` |
| `event.updateCouponSent` | 전송 상태 토글 | 관리자 | `EventController::updateCouponSent()` |
| `event.listCoupons` | 쿠폰 목록 | 관리자 | `EventController::listCoupons()` |
| `event.couponStats` | 쿠폰 통계 | 관리자 | `EventController::couponStats()` |
| `event.myCoupons` | 내 당첨 쿠폰 | 로그인 | `EventController::myCoupons()` |
| `event.viewCoupon` | 쿠폰 QR 확인 | 로그인 | `EventController::viewCoupon()` |

**JavaScript 호출 예시 (axios)**:

```javascript
// 쿠폰 생성
const res = await axios.post('/api.php', {
    method: 'event.createCoupon',
    coupon_type: 'starbucks',
    title: '아메리카노 기프티콘',
    memo: '관리자 메모',
    idx_upload: 42  // v7 Upload API로 미리 업로드한 이미지 idx
});
// 에러: res.data.success === false, res.data.message
// 성공: res.data.idx, res.data.coupon_type 등

// 쿠폰 삭제 (available 상태만)
await axios.post('/api.php', { method: 'event.deleteCoupon', idx: 123 });

// 쿠폰 수정
await axios.post('/api.php', {
    method: 'event.updateCoupon',
    idx: 123, title: '새 제목', memo: '새 메모', idx_upload: 43
});

// 전송 상태 토글
await axios.post('/api.php', { method: 'event.updateCouponSent', idx: 123, sent: true });  // won → sent
await axios.post('/api.php', { method: 'event.updateCouponSent', idx: 123, sent: false }); // sent → won

// 쿠폰 목록 조회 (관리자)
const list = await axios.post('/api.php', {
    method: 'event.listCoupons',
    coupon_type: 'starbucks', status: 'won', page: 1, limit: 20
});
// list.data = { total, page, limit, items: [...] }

// 쿠폰 통계 (관리자)
const stats = await axios.post('/api.php', { method: 'event.couponStats' });
// stats.data = { total, available, won, sent, expired, cancelled, by_type, types }
```

> **참고**: 쿠키의 `session_id`가 자동 전송되므로 별도의 인증 파라미터가 필요 없다.
> 관리자 확인은 `ADMINS` 상수(firebase_uid 배열)로 수행하며, DB의 admin 필드는 사용하지 않는다.

---

## 10. 파일 구조

```
lib/event/
├── EventCouponService.php       ← 쿠폰 비즈니스 로직
├── EventCouponRepository.php    ← 쿠폰 DB 계층
├── EventService.php             ← 스피닝 휠 + 쿠폰 배정 호출
├── EventController.php          ← event.spin, event.history, event.myCoupons, event.viewCoupon API
└── EventRepository.php          ← event_spin_history DB 계층

widgets/admin/event/
└── coupon-list.php              ← 관리자 쿠폰 관리 위젯 (Vue.js + v7 Upload)

page/admin/
└── event-coupon-list.php        ← 관리자 쿠폰 관리 페이지 (위젯 include)

tests/Unit/
└── EventCouponServiceTest.php   ← PEST Unit Test
```
