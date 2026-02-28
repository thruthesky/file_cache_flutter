# v7 PointEvent API 문서

## 목차

1. [개요](#개요)
2. [아키텍처](#아키텍처)
3. [API 엔드포인트](#api-엔드포인트)
   - [pointEvent.createMukbang](#pointeventcreatemukbang---먹방-이벤트-글-생성)
   - [pointEvent.weeklyCount](#pointeventweeklycount---주간-횟수-조회)
4. [포인트 시스템](#포인트-시스템)
5. [영수증 검증](#영수증-검증)
6. [게시글 커스텀 필드](#게시글-커스텀-필드)
7. [에러 처리](#에러-처리)
8. [테스트](#테스트)

---

## 개요

v7 PointEvent API는 먹방 이벤트 포인트 기능을 제공한다.
먹방 후기 글 등록 + 영수증 검증 + 랜덤 포인트 지급을 **단일 API**로 처리한다.

### 주요 특징

- 먹방 이벤트 = 먹방 후기 **글 등록** (PostService::create() 재활용)
- **AI 영수증 검증** (`AiService::analyzeReceiptByUrl()` 재활용) + receipt_date 폴백
- 영수증 검증 성공 시에만 랜덤 포인트 지급
- **영수증 검증 실패/정보 부족/주간 초과 시에도 글은 정상 생성** (포인트만 미지급)
- 획득 포인트를 게시글 레코드(int_1, int_2)에 저장하여 화면 표시 가능
- 주간 최대 4회 참여 제한
- 글 삭제 시 이벤트 포인트 자동 차감

---

## 아키텍처

```
클라이언트 → api.php → PointEventController → PointEventService → DB
                                                    ↓
                                          PostService::create() (글 생성 재활용)
                                                    ↓
                                          AiService::analyzeReceiptByUrl() (AI 영수증 검증)
                                                    ↓ (실패 시 receipt_date 폴백)
                                          영수증 날짜 검증 → 포인트 지급
                                                    ↓
                                          게시글 레코드에 포인트 기록 (int_1, int_2)
```

### 파일 구조

```
lib/point_event/
├── PointEventController.php    # API 엔드포인트 (인증 처리)
├── PointEventService.php       # 비즈니스 로직 (글 생성 + 검증 + 포인트)
└── PointEventRepository.php    # DB CRUD (prepared statement)
```

### PSR-4 네임스페이스

```json
"Philgo\\PointEvent\\": "lib/point_event/"
```

---

## API 엔드포인트

### pointEvent.createMukbang — 먹방 이벤트 글 생성

인증 필수.

```
GET https://local.philgo.com/api.php?method=pointEvent.createMukbang
    &session_id=xxx
    &subject=맛있는 삼겹살
    &content=정말 맛있었어요
    &files=photo1.jpg,photo2.jpg
    &receipt_url=/uploads/123/receipt.jpg
    &receipt_date=2026-02-27 12:30:00
```

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| subject | string | O | 제목 |
| content | string | O | 내용 |
| files | string | X | 먹방 사진 URL (쉼표 구분, 영수증 제외) |
| receipt_url | string | X | 영수증 이미지 URL (AI 검증 대상, 글에 첨부 안 함) |
| receipt_date | string | X | 영수증 날짜 — **PHT(UTC+8) 기준** (AI 분석 실패 시 폴백으로 사용, 예: "2026-02-27 23:30:00") |

**영수증 검증 흐름:**
1. `receipt_url` 존재 → `AiService::analyzeReceiptByUrl()`로 AI 검증
2. AI 분석 성공 → `is_receipt`, `is_authentic`, `date`(24시간) 검증
3. AI 분석 실패 → `receipt_date` 파라미터로 폴백하여 날짜 검증
4. 둘 다 없음 → "영수증 정보가 부족합니다." (글은 생성, 포인트 미지급)

**응답 (포인트 지급 + AI 분석 성공):**
```json
{
  "idx": 12345,
  "subject": "맛있는 삼겹살",
  "post_id": "freetalk",
  "category": "먹방",
  "files": "photo1.jpg,photo2.jpg",
  "event_point": {
    "awarded": true,
    "base_point": 1900,
    "bonus_point": 5000,
    "total_point": 6900,
    "reason": ""
  },
  "weekly_count": 3,
  "weekly_remaining": 1,
  "member_point": 16900,
  "receipt": {
    "is_receipt": true,
    "is_authentic": true,
    "store_name": "Jollibee",
    "date": "2026-02-27 12:30:00",
    "total_amount": 500,
    "currency": "PHP",
    "confidence_score": 90,
    "suspicious_reasons": []
  }
}
```

**응답 (포인트 미지급 — 영수증 만료):**
```json
{
  "idx": 12346,
  "subject": "어제 먹은 갈비",
  "event_point": {
    "awarded": false,
    "base_point": 0,
    "bonus_point": 0,
    "total_point": 0,
    "reason": "영수증이 24시간이 지났습니다."
  },
  "weekly_count": 3,
  "weekly_remaining": 1,
  "member_point": 10000
}
```

**응답 (포인트 미지급 — AI 검증 실패):**
```json
{
  "idx": 12347,
  "subject": "검증 실패 후기",
  "event_point": {
    "awarded": false,
    "base_point": 0,
    "bonus_point": 0,
    "total_point": 0,
    "reason": "영수증 검증에 실패했습니다. (위조 의심)"
  },
  "weekly_count": 2,
  "weekly_remaining": 2,
  "member_point": 10000,
  "receipt": {
    "is_receipt": true,
    "is_authentic": false,
    "confidence_score": 30,
    "suspicious_reasons": ["위조 의심"]
  }
}
```

---

### pointEvent.weeklyCount — 주간 횟수 조회

인증 필수.

```
GET https://local.philgo.com/api.php?method=pointEvent.weeklyCount&session_id=xxx
```

**응답:**
```json
{
  "count": 2,
  "remaining": 2,
  "limit": 4,
  "member_point": 16900,
  "events": [
    {
      "idx_post": 12345,
      "subject": "맛있는 삼겹살 후기",
      "base_point": 1900,
      "bonus_point": 5000,
      "total_point": 6900,
      "created_at": "2026-02-27 12:30:00"
    },
    {
      "idx_post": 12340,
      "subject": "어제 점심 먹방",
      "base_point": 1200,
      "bonus_point": 0,
      "total_point": 1200,
      "created_at": "2026-02-26 18:00:00"
    }
  ]
}
```

| 응답 필드 | 타입 | 설명 |
|-----------|------|------|
| count | int | 이번 주 참여 횟수 |
| remaining | int | 이번 주 남은 횟수 |
| limit | int | 주간 최대 횟수 (4) |
| member_point | int | 현재 회원 보유 포인트 |
| events | array | 주간 이벤트 참여 내역 목록 |
| events[].idx_post | int | 게시글 번호 |
| events[].subject | string | 게시글 제목 |
| events[].base_point | int | 기본 포인트 (int_1) |
| events[].bonus_point | int | 보너스 포인트 (int_2) |
| events[].total_point | int | 총 포인트 (base + bonus) |
| events[].created_at | string | 참여 일시 |

---

## 포인트 시스템

### 랜덤 포인트 알고리즘

| 기본 | 보너스 | 합계 | 확률 |
|------|--------|------|------|
| 1,000~1,800 | 0 | 1,000~1,800 | ~81.82% |
| 1,900 | 2,000~10,000 | 3,900~11,900 | ~9.09% |
| 2,000 | 2,000~10,000 | 4,000~12,000 | ~9.09% |

- 기본: 1,000 ~ 2,000 (100 단위, 11가지)
- 보너스: 기본 >= 1,900이면 추가 2,000 ~ 10,000 (100 단위)

### 주간 제한

- 최대 4회/주 (7일 롤링 윈도우)
- 글 삭제해도 주간 횟수는 유지 (mukbang_create 로그 유지)

### 포인트 로그 (sf_point_log)

| 상황 | module | action | etc |
|------|--------|--------|-----|
| 이벤트 기본 포인트 | point_event | mukbang_create | mukbang_event_base |
| 이벤트 보너스 포인트 | point_event | mukbang_create | mukbang_event_bonus |
| 글 삭제 포인트 차감 | point_event | mukbang_delete | mukbang_event_revoke |

### 포인트 차감 (글 삭제 시)

PostService::delete() 내부에서 `PointEventService::revokePoints()` 자동 호출.
이벤트 포인트만 차감하며, 게시판 기본 포인트 차감은 별도 처리.

---

## 영수증 검증

### AI 검증 (AiService::analyzeReceiptByUrl 재활용)

`receipt_url`이 제공되면 `AiService::analyzeReceiptByUrl()`을 호출하여 Gemini AI로 영수증을 검증한다.
AI 분석은 다음 항목을 판별한다:

| AI 검증 항목 | 설명 | 실패 시 |
|-------------|------|---------|
| is_receipt | 영수증 이미지 여부 | "이미지가 영수증이 아닙니다." |
| is_authentic | 진위 여부 | "영수증 검증에 실패했습니다." |
| date | 24시간 이내 | "영수증이 24시간이 지났습니다." |

### 폴백 전략

AI 분석이 실패(파일 없음, API 오류 등)하면 `receipt_date` 파라미터로 폴백한다.

```
receipt_url 있음 → AI 분석 시도
  ├─ AI 성공 → is_receipt, is_authentic, date 검증
  └─ AI 실패 → receipt_date 폴백
                ├─ receipt_date 있음 → 날짜 검증
                └─ receipt_date 없음 → "영수증 정보가 부족합니다."
```

### 검증 기준

영수증은 반드시 필리핀 내 업소에서 발행한 것만 사용되므로 별도의 국가 검증은 수행하지 않는다.

**⚠️ 영수증 시간은 필리핀 시간(PHT, UTC+8) 기준이다.**
영수증은 필리핀 업소에서 발행되므로 `receipt_date` 입력 시 필리핀 현지 시간을 그대로 입력한다.
서버(`validateReceipt()`)가 `Asia/Manila` timezone으로 해석하여 UTC timestamp로 자동 변환한다.

| 검증 | 기준 | 실패 시 |
|------|------|---------|
| AI 영수증 여부 | is_receipt = true | 글 유지, 포인트 미지급 |
| AI 진위 여부 | is_authentic = true | 글 유지, 포인트 미지급 |
| 날짜 | 24시간 이내 (PHT 기준) | 글 유지, 포인트 미지급 |
| 미래 날짜 | 5분 이상 미래 불가 (PHT 기준) | 글 유지, 포인트 미지급 |
| 정보 부족 | receipt_url 또는 receipt_date 필요 | 글 유지, 포인트 미지급 |

### 핵심 원칙

- **영수증 검증 실패해도 글은 정상 생성됨**
- **주간 횟수 초과해도 글은 정상 생성됨**
- 포인트만 미지급되며, `event_point.reason`에 사유 기록
- AI 분석 결과가 있으면 응답의 `receipt` 필드에 포함

---

## 게시글 커스텀 필드

이벤트 포인트는 게시글의 커스텀 필드에 저장되어 화면에서 표시 가능.

| 필드 | 용도 | 예시 |
|------|------|------|
| int_1 | 이벤트 기본 포인트 | 1900 |
| int_2 | 이벤트 보너스 포인트 | 5000 |
| varchar_1 | 영수증 URL (검증용) | "/uploads/123/receipt.jpg" |
| int_10 | 게시판 기본 포인트 (기존) | 10 |
| files | 먹방 사진만 (영수증 제외) | "photo1.jpg,photo2.jpg" |

**화면 표시 예시:**
- `int_1 > 0`이면 "기본 포인트: {int_1}점" 표시
- `int_2 > 0`이면 "보너스: +{int_2}점" 추가 표시
- 총 포인트 = int_1 + int_2

---

## 에러 처리

모든 에러는 `RuntimeException`으로 발생하며, api.php에서 JSON으로 변환된다.

| 상황 | 에러/사유 메시지 | 동작 |
|------|----------------|------|
| 미로그인 | '로그인이 필요합니다.' | 에러 (글 미생성) |
| 영수증이 아님 (AI) | '이미지가 영수증이 아닙니다.' | 글 생성, 포인트 미지급 |
| 영수증 위조 (AI) | '영수증 검증에 실패했습니다.' | 글 생성, 포인트 미지급 |
| 영수증 날짜 파싱 실패 | '영수증 날짜를 확인할 수 없습니다.' | 글 생성, 포인트 미지급 |
| 영수증 24시간 초과 | '영수증이 24시간이 지났습니다.' | 글 생성, 포인트 미지급 |
| 영수증 미래 날짜 | '영수증 날짜가 유효하지 않습니다.' | 글 생성, 포인트 미지급 |
| 영수증 정보 부족 | '영수증 정보가 부족합니다.' | 글 생성, 포인트 미지급 |
| 주간 횟수 초과 | '이번 주 이벤트 참여 횟수를 초과했습니다.' | 글 생성, 포인트 미지급 |
| 회원 미존재 | '회원 정보를 찾을 수 없습니다.' | 글 생성, 포인트 미지급 |

---

## 테스트

### 실행 방법

```bash
# PointEvent 테스트
./vendor/bin/pest tests/Unit/PointEventTest.php

# 기존 Post 테스트 (revokePoints 추가 확인)
./vendor/bin/pest tests/Unit/PostControllerTest.php
```

### 테스트 범위

| 분류 | 테스트 수 | 설명 |
|------|----------|------|
| PointEventRepository | 7 | CRUD, 주간 카운트, 커스텀 필드, 이벤트 로그 |
| 랜덤 포인트 계산 | 4 | 범위, 보너스 조건, total 계산 |
| 영수증 검증 | 4 | 유효/만료/잘못된 형식/미래 날짜 |
| createMukbang 통합 | 6 | 정상/실패/글 확인/파일 분리 |
| 주간 횟수 제한 | 2 | 4회 초과/횟수 조회 |
| 포인트 차감 | 3 | 차감/미차감/최소 0 |
| AI 영수증 검증 | 5 | AI 폴백/정보 부족/파일 없음/ReceiptEntity |
| Controller | 5 | 인증/비인증/글 생성/횟수 조회/포인트 기록 |
| **합계** | **36** | 418 assertions |
