# v7 Event (스피닝 휠) API 문서

> **📌 문서 목적**: 이 문서는 v7 이벤트 시스템의 **API 엔드포인트, 서버 비즈니스 로직, 코드 구현 상세**를 다룬다.
> 스피닝 휠 이벤트의 확률 알고리즘, 트랜잭션 처리, 스타벅스 쿠폰 관리, 업소록 방문 후기 포인트 API 등
> **서버 측 코드와 로직**에 집중하며, 전체 이벤트 시스템 개요는 [v7-event-overview.md](../event/v7-event-overview.md)를 참조한다.

## 목차

1. [개요](#개요)
   - [핵심 목적](#핵심-목적)
   - [주요 특징](#주요-특징)
   - [안티치트 원칙](#안티치트-원칙)
2. [COT 분석: 단계별 설계](#cot-분석-단계별-설계)
   - [Step 1: 문제의 핵심 이해](#step-1-문제의-핵심-이해)
   - [Step 2: 기존 시스템과의 관계](#step-2-기존-시스템과의-관계)
   - [Step 3: 해결 전략 수립](#step-3-해결-전략-수립)
   - [Step 4: 확률 알고리즘 설계](#step-4-확률-알고리즘-설계)
   - [Step 5: 트랜잭션 설계](#step-5-트랜잭션-설계)
3. [TOT 분석: 설계 결정 트리](#tot-분석-설계-결정-트리)
   - [하위 문제 분해](#하위-문제-분해)
   - [각 하위 문제의 해결 방안](#각-하위-문제의-해결-방안)
   - [통합 및 검증](#통합-및-검증)
4. [아키텍처](#아키텍처)
   - [시스템 흐름도](#시스템-흐름도)
   - [파일 구조](#파일-구조)
   - [PSR-4 네임스페이스](#psr-4-네임스페이스)
5. [확률 시스템](#확률-시스템)
   - [기본 확률 분포표](#기본-확률-분포표)
   - [쿠폰 소진 시 확률 분포표](#쿠폰-소진-시-확률-분포표)
   - [확률 등급 분류](#확률-등급-분류)
   - [확률 계산 알고리즘](#확률-계산-알고리즘)
   - [손익 분석](#손익-분석)
6. [API 엔드포인트](#api-엔드포인트)
   - [event.spin — 스피닝 휠 돌리기](#eventspin--스피닝-휠-돌리기)
   - [event.history — 이벤트 기록 조회](#eventhistory--이벤트-기록-조회)
7. [스타벅스 쿠폰 관리 시스템](#스타벅스-쿠폰-관리-시스템)
   - [핵심 원칙](#핵심-원칙-1)
   - [쿠폰 파일 저장 위치](#쿠폰-파일-저장-위치)
   - [사용 가능 쿠폰 조회 알고리즘](#사용-가능-쿠폰-조회-알고리즘)
   - [쿠폰 라이프사이클](#쿠폰-라이프사이클)
8. [데이터베이스 설계](#데이터베이스-설계)
   - [event_spin_history 테이블](#event_spin_history-테이블)
   - [sf_point_log 기록 규칙](#sf_point_log-기록-규칙)
9. [서버 비즈니스 로직 상세](#서버-비즈니스-로직-상세)
   - [EventController 클래스](#eventcontroller-클래스)
   - [EventService 클래스](#eventservice-클래스)
   - [EventRepository 클래스](#eventrepository-클래스)
10. [에러 처리](#에러-처리)
11. [클라이언트 연동](#클라이언트-연동)
    - [Flutter 앱 연동](#flutter-앱-연동)
    - [서버/클라이언트 section_index 매핑](#서버클라이언트-section_index-매핑)
12. [테스트](#테스트)
    - [PEST Unit Test 실행](#pest-unit-test-실행)
    - [테스트 범위](#테스트-범위)
    - [REST Client 테스트](#rest-client-테스트)
13. [보안 고려사항](#보안-고려사항)
14. [향후 확장 방향](#향후-확장-방향)
15. [업소록 방문 후기 포인트 API](#업소록-방문-후기-포인트-api)
    - [개요 (후기)](#개요-후기)
    - [company.submitVisitReview — 후기 작성](#companysubmitvisitreview--후기-작성)
    - [company.getVisitReviews — 후기 목록 조회](#companygetvisitreviews--후기-목록-조회)
    - [후기 서비스 로직 상세](#후기-서비스-로직-상세)
    - [후기 DB 테이블: company_reviews](#후기-db-테이블-company_reviews)
    - [후기 웹 페이지: visit-review-point.php](#후기-웹-페이지-visit-review-pointphp)
    - [후기 JavaScript 헬퍼: v7api.js](#후기-javascript-헬퍼-v7apijs)

---

## 개요

### 핵심 목적

필고 앱의 **이벤트 응모 스피닝 휠(원판 돌리기)** 서버 API이다.
**서버에서 모든 결과를 미리 결정**하여 클라이언트에 응답하고,
클라이언트는 해당 결과에 맞춰 원판을 회전시켜 **랜덤으로 당첨되는 것처럼 보이게** 한다.

### 주요 특징

- **200P 소비 → 10개 섹션 가중치 기반 확률 게임**: weight 합계 1000 (0.1% 단위 확률 제어)
- **서버 100% 결과 결정 (안티치트)**: 클라이언트는 `section_index`만 수신하여 원판 회전 애니메이션 재생
- **10개 보상 섹션**: 50P, 100P, 200P, 300P, 400P, 500P, 1,000P, 2,000P, 스타벅스 쿠폰, 꽝
- **스타벅스 쿠폰 event_coupons DB 기반 관리**: `EventCouponService`로 쿠폰 유무 확인/배정 (`SELECT ... FOR UPDATE` race condition 방어)
- **동적 확률 전환**: 사용 가능한 쿠폰이 0개이면 스타벅스 확률 자동 0% (해당 weight를 50P에 합산)
- **PDO 트랜잭션**: 포인트 차감 → 확률 계산 → 보상 지급 → 기록 저장을 원자적으로 처리
- **감사 추적**: `random_value`, `ip`로 사후 검증 가능

### 안티치트 원칙

> **서버에서 100% 결과를 결정하고, 클라이언트는 시각적 연출만 담당한다.**
> DevTools 조작, 메모리 해킹, 네트워크 패킷 변조로도 결과를 바꿀 수 없다.

---

## COT 분석: 단계별 설계

### Step 1: 문제의 핵심 이해

**문제**: 스피닝 휠 이벤트에서 사용자가 포인트를 소비하여 게임을 하고, 확률에 따라 보상을 받는 시스템.

**핵심 요구사항**:
- 200P를 차감하고 게임 진행
- 서버에서 확률적으로 결과를 미리 결정 (안티치트)
- 당첨 시 포인트 자동 충전
- 스타벅스 쿠폰 당첨 시 `event_coupons` 테이블에서 쿠폰 배정 (`EventCouponService`)
- 사용 가능한 쿠폰이 없으면 스타벅스 당첨 불가
- 모든 게임 기록을 DB에 상세히 저장
- 클라이언트에는 `section_index`만 응답하여 원판 애니메이션에 사용

### Step 2: 기존 시스템과의 관계

```
기존 포인트 이벤트 (먹방 이벤트)
  ├─ 글 작성 + 영수증 검증 → 포인트 지급
  └─ module='point_event', action='mukbang_create'

스피닝 휠 이벤트 (신규)
  ├─ 200P 소비 → 확률 기반 보상
  └─ module='event', action='spin_cost' / 'spin_reward'
```

먹방 이벤트(`PointEvent` 모듈)와 성격이 다르다.
먹방 이벤트는 글 작성 + 영수증 검증 기반이고, 스피닝 휠은 포인트 소비 + 확률 게임이다.
따라서 **별도의 `Event` 모듈**로 분리하여 관리한다.

### Step 3: 해결 전략 수립

| 과제 | 해결 방법 |
|------|----------|
| 확률 계산 | 가중치(weight) 기반 확률, `random_int(1, 1000)` CSPRNG 사용 |
| 포인트 차감 | `sf_member.point` UPDATE + `sf_point_log` INSERT |
| 포인트 충전 | `sf_member.point` UPDATE + `sf_point_log` INSERT |
| 스타벅스 쿠폰 | `event_coupons` DB 테이블 기반 — `EventCouponService::hasAvailableCoupon()` / `assignCouponToWinner()` |
| 쿠폰 소진 | 사용 가능 쿠폰 0개 → 스타벅스 확률 0%로 변경 (스타벅스 weight=2를 50P에 합산) |
| 기록 저장 | `event_spin_history` 테이블에 INSERT |
| 클라이언트 연동 | `section_index` 반환 → 원판 회전 애니메이션 |
| 트랜잭션 | PDO `beginTransaction()` → `commit()` / `rollBack()` |

### Step 4: 확률 알고리즘 설계

**가중치 기반(weight 합계 1000) 확률 매핑** — 10개 섹션, 스타벅스 쿠폰 유무에 따라 동적 변경:

```php
// 10개 섹션 가중치 테이블 (weight 합계 = 1000 → 0.1% 단위)
$sections = [
    ['section_index' => 0, 'points' => 50,   'weight' => 379, 'prize_type' => 'point'],     // 37.9%
    ['section_index' => 1, 'points' => 100,  'weight' => 80,  'prize_type' => 'point'],     // 8.0%
    ['section_index' => 2, 'points' => 200,  'weight' => 70,  'prize_type' => 'point'],     // 7.0%
    ['section_index' => 3, 'points' => 300,  'weight' => 60,  'prize_type' => 'point'],     // 6.0%
    ['section_index' => 4, 'points' => 400,  'weight' => 50,  'prize_type' => 'point'],     // 5.0%
    ['section_index' => 5, 'points' => 500,  'weight' => 40,  'prize_type' => 'point'],     // 4.0%
    ['section_index' => 6, 'points' => 1000, 'weight' => 15,  'prize_type' => 'point'],     // 1.5%
    ['section_index' => 7, 'points' => 2000, 'weight' => 4,   'prize_type' => 'point'],     // 0.4%
    ['section_index' => 8, 'points' => -1,   'weight' => 2,   'prize_type' => 'starbucks'], // 0.2%
    ['section_index' => 9, 'points' => 0,    'weight' => 300,  'prize_type' => 'miss'],     // 30.0%
];

// 스타벅스 쿠폰이 없을 때: section_index=8의 weight=2를 section_index=0(50P)에 합산
// 50P weight: 379 → 381, 스타벅스 weight: 2 → 0 (총합 여전히 1000)
```

### Step 5: 트랜잭션 설계

```
BEGIN TRANSACTION
  ├─ [1] 200P 차감 (sf_member UPDATE + sf_point_log INSERT)
  ├─ [2] 확률 계산 → 결과 결정
  ├─ [3] 보상 처리 (포인트: UPDATE + LOG / 스타벅스: 쿠폰 할당 / 꽝: 없음)
  ├─ [4] 이벤트 기록 저장 (event_spin_history INSERT)
COMMIT
  └─ 실패 시 ROLLBACK (포인트 변동 없음)
```

---

## TOT 분석: 설계 결정 트리

### 하위 문제 분해

```
이벤트 스피닝 휠 서버 API
├─ [P1] 데이터베이스
│  ├─ [P1-1] event_spin_history 테이블 (게임 기록)
│  ├─ [P1-2] event_coupons 테이블 (쿠폰 관리)
│  └─ [P1-3] sf_point_log 기록 규칙 정의
│
├─ [P2] 확률 시스템
│  ├─ [P2-1] 가중치(weight) 기반 확률 매핑 (10개 섹션, 합계 1000)
│  ├─ [P2-2] random_int() CSPRNG 사용
│  ├─ [P2-3] section_index(0~9) ↔ 확률 매핑 테이블
│  └─ [P2-4] ★ 스타벅스 쿠폰 유무에 따른 동적 확률 전환
│
├─ [P3] 포인트 처리
│  ├─ [P3-1] 200P 차감 (잔액 확인 → UPDATE → LOG)
│  ├─ [P3-2] 당첨 포인트 충전 (UPDATE → LOG)
│  └─ [P3-3] 트랜잭션 원자성 보장
│
├─ [P4] 스타벅스 쿠폰 관리 (event_coupons DB 기반)
│  ├─ [P4-1] EventCouponService::hasAvailableCoupon('starbucks') — 사용 가능 쿠폰 확인
│  ├─ [P4-2] 쿠폰 0개 → 스타벅스 확률 0%로 전환 (weight → 50P에 합산)
│  ├─ [P4-3] 당첨 시 EventCouponService::assignCouponToWinner() — SELECT...FOR UPDATE
│  └─ [P4-4] 관리자가 v7 Upload API로 QR 이미지 업로드하여 쿠폰 등록
│
├─ [P5] API 엔드포인트
│  ├─ [P5-1] event.spin (메인 API)
│  ├─ [P5-2] event.history (이벤트 기록 조회)
│  └─ [P5-3] 인증 + 입력 검증
│
├─ [P6] PSR-4 모듈 구조
│  ├─ [P6-1] EventController.php
│  ├─ [P6-2] EventService.php
│  └─ [P6-3] EventRepository.php
│
└─ [P7] 클라이언트 연동
   ├─ [P7-1] 응답 포맷 정의 (section_index, points, prize_type)
   ├─ [P7-2] Flutter onSpinRequested 콜백 연동
   └─ [P7-3] 에러 응답 처리
```

### 각 하위 문제의 해결 방안

| 문제 | 해결 방안 | 복잡도 |
|------|----------|--------|
| P1-1 | CREATE TABLE event_spin_history (게임 기록 테이블) | 낮음 |
| P2-1 | 가중치(weight 합계 1000) 기반 누적 매핑, `random_int(1, 1000)` | 중간 |
| P2-4 | 쿠폰 유무 판단 후 확률 테이블 분기 | 중간 |
| P3-1 | BEGIN TRANSACTION → SELECT point → UPDATE → COMMIT | 높음 |
| P3-3 | PDO transaction으로 원자성 보장 | 중간 |
| P4-1 | `EventCouponService::hasAvailableCoupon('starbucks')` — DB에서 available 쿠폰 확인 | 낮음 |
| P4-2 | 사용 가능 쿠폰 0개 → `$hasStarbucks = false` → weight 재조정 | 낮음 |
| P4-3 | 당첨 시 `EventCouponService::assignCouponToWinner()` — SELECT...FOR UPDATE | 중간 |
| P4-4 | 관리자 쿠폰 등록: v7 Upload API → `event_coupons` INSERT | 낮음 |
| P5-1 | `EventController::spin($input)` | 중간 |
| P7-1 | JSON: `{section_index, points, prize_type, ...}` | 낮음 |

### 통합 및 검증

- **순차 실행**: P4(쿠폰 확인) → P2(확률 결정) → P3(포인트 처리) → P1(기록 저장)
- **동적 확률**: P4(쿠폰 유무) + P2(확률) → 쿠폰 없으면 스타벅스 확률 0%로 전환
- **API + 클라이언트**: P5(API) + P7(클라이언트) → `section_index` 기반 연동
- **DB + 모듈**: P1(DB) + P6(모듈) → Repository에서 DB 접근

---

## 아키텍처

### 시스템 흐름도

```
Flutter 앱
  │
  ├─ 사용자가 "원판 돌리기" 버튼 클릭
  │
  ├─ v7api('event.spin') 호출
  │  ├─ Firebase ID Token 자동 첨부 (patchToken)
  │  └─ POST /api.php?method=event.spin
  │
  ▼
api.php (v7 엔트리포인트)
  │
  ├─ RequestUtils::parseMethod() → ["event", "spin"]
  ├─ FQCN: "Philgo\Event\EventController"
  ├─ new EventController()
  └─ $ctrl->spin($input)
  │
  ▼
EventController::spin($input)
  │
  ├─ [1] 인증 확인
  │  └─ AuthService::getLoginUser() → $user
  │
  └─ EventService::spin($user) 호출
     │
     ├─ [2] 잔액 확인 (200P 이상)
     │  └─ EventRepository::getMember($idxMember)
     │
     ├─ [3] 사용 가능한 스타벅스 쿠폰 확인
     │  └─ EventCouponService::hasAvailableCoupon('starbucks') → DB 기반
     │
     ├─ [4] BEGIN TRANSACTION
     │
     ├─ [5] 200P 차감
     │  ├─ EventRepository::updateMemberPoint()
     │  └─ EventRepository::insertPointLog(action='spin_cost')
     │
     ├─ [6] 확률 계산 → 결과 결정
     │  └─ EventService::calculateSpinResult($hasStarbucksCoupon)
     │
     ├─ [7] 보상 처리
     │  ├─ point: 포인트 충전 (PointLogService::changePoints)
     │  ├─ starbucks: 포인트 로그 기록 (0P 변동)
     │  └─ miss: 보상 없음
     │
     ├─ [8] 이벤트 기록 저장
     │  └─ EventRepository::insertSpinHistory()
     │
     ├─ [8-1] 스타벅스 당첨 시 쿠폰 배정
     │  └─ EventCouponService::assignCouponToWinner('starbucks', $idxMember, $spinIdx)
     │
     ├─ [9] COMMIT
     │
     ├─ [9-1] 스타벅스 당첨 시 freetalk 자동 게시글
     │  └─ PostService::create() (커밋 후 실행)
     │
     └─ [10] 응답 반환
        └─ {section_index, points, prize_type, current_point, coupon, ...}
```

### 파일 구조

```
lib/event/
├── EventController.php        ← Philgo\Event\EventController
│   ├── spin(array $input)     ← event.spin API
│   ├── history(array $input)  ← event.history API
│   └── myCoupons(array $input) ← event.myCoupons API (당첨 쿠폰 목록)
│
├── EventService.php           ← Philgo\Event\EventService
│   ├── spin(array $user)                     ← 메인 비즈니스 로직 (EventCouponService 연동)
│   ├── calculateSpinResult(bool $has)        ← 가중치 기반 확률 계산
│   ├── getSections()                          ← 10개 섹션 테이블 반환
│   └── getHistory(...)                        ← 기록 페이지네이션 조회
│
├── EventCouponService.php     ← Philgo\Event\EventCouponService (쿠폰 비즈니스 로직)
│   ├── hasAvailableCoupon(?type): bool       ← 쿠폰 존재 여부 (spin에서 사용)
│   ├── assignCouponToWinner(?type, idx, spin): ?array  ← 당첨자 배정 (FOR UPDATE)
│   ├── getAvailableCount(?type): int         ← 사용 가능 쿠폰 수
│   └── ...                                    ← 기타 관리자 기능
│
├── EventCouponRepository.php  ← Philgo\Event\EventCouponRepository (쿠폰 DB 계층)
│   ├── lockAndPickAvailable(?type): ?array   ← SELECT ... FOR UPDATE
│   ├── assignToWinner(idx, member, spin): bool  ← 당첨자 배정 UPDATE
│   ├── findByWinner(idxMember, page, limit): array ← 당첨자별 쿠폰 목록 (won/sent, uploads JOIN)
│   └── ...                                    ← 기타 CRUD
│
└── EventRepository.php        ← Philgo\Event\EventRepository
    ├── getMember(int $idx)                    ← sf_member 조회
    ├── insertSpinHistory(array $data)        ← event_spin_history INSERT
    └── getSpinHistory(int $idx, int $p, int $l) ← 페이지네이션 조회
```

### PSR-4 네임스페이스

```json
"Philgo\\Event\\": "lib/event/"
```

`composer.json`의 `autoload.psr-4`에 매핑이 추가되어 있다.

---

## 확률 시스템

### 기본 확률 분포표

총 10개 섹션, 가중치(weight) 합계 1000 (0.1% 단위 확률 제어).
**스타벅스 쿠폰이 사용 가능할 때**의 확률 분포이다.

| 섹션 | section_index | 당첨 포인트 | Weight | 확률 | prize_type |
|------|:------------:|:-----------:|:------:|:----:|:----------:|
| 50P | 0 | +50P | 379 | **37.9%** | `point` |
| 100P | 1 | +100P | 80 | **8.0%** | `point` |
| 200P | 2 | +200P | 70 | **7.0%** | `point` |
| 300P | 3 | +300P | 60 | **6.0%** | `point` |
| 400P | 4 | +400P | 50 | **5.0%** | `point` |
| 500P | 5 | +500P | 40 | **4.0%** | `point` |
| 1,000P | 6 | +1,000P | 15 | **1.5%** | `point` |
| 2,000P | 7 | +2,000P | 4 | **0.4%** | `point` |
| 스타벅스 쿠폰 | 8 | 쿠폰 전송 | 2 | **0.2%** | `starbucks` |
| 꽝 | 9 | 0P | 300 | **30.0%** | `miss` |
| **합계** | | | **1,000** | **100.0%** | |

### 쿠폰 소진 시 확률 분포표

> 스타벅스 0.2%(weight 2)를 50P에 합산 → 50P weight: 379 → **381**, 스타벅스 weight: 2 → **0**

| 섹션 | section_index | Weight | 확률 | 변경 |
|------|:------------:|:------:|:----:|:----:|
| 50P | 0 | **381** | **38.1%** | +0.2% |
| 100P~2,000P | 1~7 | (변동 없음) | (변동 없음) | |
| ~~스타벅스~~ | ~~8~~ | **0** | **0.0%** | -0.2% |
| 꽝 | 9 | 300 | 30.0% | |
| **합계** | | **1,000** | **100.0%** | |

### 확률 등급 분류

| 등급 | 섹션 | 확률 합계 | 설계 의도 |
|------|------|----------|----------|
| **일반** | 50P + 꽝 | 68% | 대부분의 결과 (약 2/3) |
| **중간** | 100P ~ 500P | 30% | 적당한 보상감 제공 |
| **희귀** | 1,000P | 1.5% | 드문 행운 |
| **초희귀** | 2,000P | 0.4% | 매우 드문 대박 |
| **전설** | 스타벅스 쿠폰 | 0.2% | 500회에 1번 (최고 보상) |

### 확률 계산 알고리즘

`EventService::calculateSpinResult()` 구현:

```php
public static function calculateSpinResult(bool $hasStarbucksCoupon): array
{
    $sections = self::getSections(); // 10개 섹션 가중치 테이블

    // 스타벅스 쿠폰이 없으면: weight 동적 재조정
    if (!$hasStarbucksCoupon) {
        $starbucksWeight = $sections[8]['weight']; // 2
        $sections[0]['weight'] += $starbucksWeight; // 50P: 379 → 381
        $sections[8]['weight'] = 0;                 // 스타벅스: 2 → 0
    }

    $totalWeight = array_sum(array_column($sections, 'weight')); // 1000
    $rand = random_int(1, $totalWeight); // CSPRNG 사용

    $cumulative = 0;
    foreach ($sections as $section) {
        if ($section['weight'] <= 0) continue; // weight 0인 섹션 건너뛰기
        $cumulative += $section['weight'];
        if ($rand <= $cumulative) {
            $section['random_value'] = $rand;
            return $section;
        }
    }

    // 폴백 (도달할 수 없음)
    return ['section_index' => 9, 'points' => 0, 'prize_type' => 'miss', ...];
}
```

**알고리즘 동작 원리**:

```
random_int(1, 1000) = 250 일 때:

누적 계산:
  0:  379 (50P)   → 1~379    ← 250 ≤ 379 → ★ 50P 당첨!
  1:  459 (100P)  → 380~459
  2:  529 (200P)  → 460~529
  3:  589 (300P)  → 530~589
  4:  639 (400P)  → 590~639
  5:  679 (500P)  → 640~679
  6:  694 (1000P) → 680~694
  7:  698 (2000P) → 695~698
  8:  700 (쿠폰)  → 699~700
  9: 1000 (꽝)    → 701~1000
```

### 손익 분석

| 항목 | 계산 |
|------|------|
| **비용** | -200P (게임 참가비) |
| **기대 수익** | 50×0.379 + 100×0.08 + 200×0.07 + 300×0.06 + 400×0.05 + 500×0.04 + 1000×0.015 + 2000×0.004 + 0×0.30 = **122P** |
| **기대 순손실** | 200 - 122 = **-78P** |

> 사용자는 평균적으로 1회 게임당 약 78P를 잃는다. 이는 게임의 지속 가능성을 보장한다.
> ※ 스타벅스 쿠폰(0.2%)은 포인트가 아닌 실물 보상이므로 기대값 계산에서 제외한다.

---

## API 엔드포인트

### event.spin — 스피닝 휠 돌리기

인증 필수.

200P를 차감하고 가중치 기반 확률 게임을 실행한다.
서버에서 결과를 결정하여 `section_index`로 반환하며,
클라이언트는 해당 인덱스에 맞춰 원판 회전 애니메이션을 재생한다.

**메서드**: `POST /api.php?method=event.spin`

#### cURL 예시

```bash
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "event.spin",
    "session_id": "YOUR_SESSION_ID"
  }'
```

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| *(없음)* | | | 인증 정보만 필요 |

#### 성공 응답 — 포인트 당첨

```json
{
  "success": true,
  "section_index": 2,
  "points": 200,
  "prize_type": "point",
  "current_point": 5000,
  "lv": 4,
  "level_progress": 50,
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 3,
  "spin_idx": 456
}
```

#### 성공 응답 — 스타벅스 쿠폰 당첨

```json
{
  "success": true,
  "section_index": 8,
  "points": -1,
  "prize_type": "starbucks",
  "current_point": 4800,
  "lv": 4,
  "level_progress": 42,
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 2,
  "spin_idx": 457,
  "coupon": {
    "idx": 42,
    "title": "아메리카노 기프티콘",
    "coupon_type": "starbucks"
  }
}
```

#### 성공 응답 — 꽝

```json
{
  "success": true,
  "section_index": 9,
  "points": 0,
  "prize_type": "miss",
  "current_point": 4800,
  "lv": 4,
  "level_progress": 42,
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 3,
  "spin_idx": 458
}
```

#### 응답 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `success` | bool | 성공 여부 |
| `section_index` | int | 원판 섹션 인덱스 (0~9) |
| `points` | int | 당첨 포인트 (0=꽝, -1=스타벅스, 50/100/200/300/400/500/1000/2000=포인트) |
| `prize_type` | string | `miss` / `point` / `starbucks` |
| `current_point` | int | 게임 후 잔여 포인트 |
| `lv` | int | 게임 후 회원 레벨 (**포인트 기반 동적 계산**, `UserService::calculateLevel()`) |
| `level_progress` | int | 다음 레벨까지 진행률 (0~100%, **동적 계산**) |
| `starbucks_coupon_file` | null | ~~레거시~~ 항상 null (하위 호환 유지) |
| `starbucks_coupon_url` | null | ~~레거시~~ 항상 null (하위 호환 유지) |
| `available_coupons` | int | 남은 사용 가능 쿠폰 수 (`EventCouponService::getAvailableCount`) |
| `spin_idx` | int | `event_spin_history.idx` (기록 번호) |
| `coupon` | object\|null | 당첨 쿠폰 정보 (스타벅스 당첨 시만). `{idx, title, coupon_type}` |

#### 에러 응답

```json
{
  "success": false,
  "message": "포인트가 부족합니다. (최소 200P 필요, 현재 150P)"
}
```

---

### event.history — 이벤트 기록 조회

인증 필수.

로그인 사용자의 스핀 히스토리를 페이지네이션으로 조회한다.

**메서드**: `POST /api.php?method=event.history`

#### cURL 예시

```bash
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "event.history",
    "session_id": "YOUR_SESSION_ID",
    "page": 1,
    "limit": 20
  }'
```

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| `page` | int | X | 페이지 번호 (기본 1) |
| `limit` | int | X | 페이지당 개수 (기본 20, 최대 100) |

#### 성공 응답

```json
{
  "success": true,
  "total": 150,
  "page": 1,
  "limit": 20,
  "items": [
    {
      "idx": 458,
      "idx_member": 12345,
      "section_index": 9,
      "prize_type": "miss",
      "points_cost": 200,
      "points_reward": 0,
      "starbucks_coupon_file": null,
      "starbucks_coupon_url": null,
      "random_value": 850,
      "point_before": 5000,
      "point_after": 4800,
      "created_at": 1709876543,
      "ip": "192.168.1.1"
    },
    {
      "idx": 457,
      "idx_member": 12345,
      "section_index": 8,
      "prize_type": "starbucks",
      "points_cost": 200,
      "points_reward": -1,
      "starbucks_coupon_file": null,
      "starbucks_coupon_url": null,
      "random_value": 700,
      "point_before": 5200,
      "point_after": 5000,
      "created_at": 1709876400,
      "ip": "192.168.1.1"
    }
  ]
}
```

#### 응답 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `total` | int | 전체 기록 수 |
| `page` | int | 현재 페이지 번호 |
| `limit` | int | 페이지당 개수 |
| `items` | array | 기록 배열 (최신순 정렬) |
| `items[].starbucks_coupon_url` | null | ~~레거시~~ 항상 null (하위 호환 유지) |

---

### event.myCoupons — 내 당첨 쿠폰 목록 조회

인증 필수.

로그인 사용자의 당첨 쿠폰 목록을 `event_coupons` 테이블에서 조회한다.
`uploads` 테이블과 JOIN하여 쿠폰 이미지 URL을 포함한다.
상태가 `won`(당첨) 또는 `sent`(전송완료)인 쿠폰만 반환한다.

**메서드**: `POST /api.php?method=event.myCoupons`

#### cURL 예시

```bash
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "event.myCoupons",
    "session_id": "YOUR_SESSION_ID",
    "page": 1,
    "limit": 20
  }'
```

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| `page` | int | X | 페이지 번호 (기본 1) |
| `limit` | int | X | 페이지당 개수 (기본 20, 최대 100) |

#### 성공 응답

```json
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

#### 응답 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `total` | int | 전체 당첨 쿠폰 수 |
| `page` | int | 현재 페이지 번호 |
| `limit` | int | 페이지당 개수 |
| `items` | array | 쿠폰 배열 (당첨일 역순) |
| `items[].idx` | int | 쿠폰 번호 |
| `items[].coupon_type` | string | 쿠폰 유형 (`starbucks` 등) |
| `items[].title` | string | 쿠폰 제목 |
| `items[].status` | string | `won` (당첨) 또는 `sent` (전송완료) |
| `items[].won_at` | int | 당첨 시간 (Unix timestamp) |
| `items[].sent_at` | int\|null | 전송 완료 시간 |
| `items[].display_image_url` | string\|null | 쿠폰 이미지 URL (`COALESCE(image_url, uploads.url)`) |
| `items[].thumbnail_url` | string\|null | 썸네일 URL (`uploads.thumbnail_400x400_url`) |

---

## 스타벅스 쿠폰 관리 시스템

### 핵심 원칙

> **`event_coupons` DB 테이블 기반으로 쿠폰을 관리한다.**
> 관리자가 v7 Upload API로 QR 이미지를 업로드하여 쿠폰을 등록하고,
> 스피닝 휠 당첨 시 `EventCouponService::assignCouponToWinner()`로 자동 배정한다.
> 사용 가능한 쿠폰이 **0개이면 스타벅스 당첨 확률은 자동으로 0%**가 된다.
> 상세는 → [v7-event-coupon.md](../event/v7-event-coupon.md) 참조.

### 쿠폰 관리 — event_coupons DB 기반

> ~~기존 `event/cupon/starbucks/` 폴더 기반 파일 스캔 방식은 폐기되었다.~~
> 현재는 `event_coupons` DB 테이블 기반으로 쿠폰을 관리한다.
> 상세는 → [v7-event-coupon.md](../event/v7-event-coupon.md) 참조.

**쿠폰 라이프사이클 (DB 기반)**:

```
[1] 관리자가 쿠폰 등록 (관리자 위젯)
    └─ v7 Upload API로 QR 이미지 업로드 → event_coupons INSERT (status='available')

[2] 스핀 API 호출 시 사용 가능 쿠폰 확인
    └─ EventCouponService::hasAvailableCoupon('starbucks')
    └─ SELECT COUNT(*) FROM event_coupons WHERE status='available' AND coupon_type='starbucks'

[3] 스타벅스 당첨 시 (트랜잭션 내)
    └─ EventCouponService::assignCouponToWinner('starbucks', $idxMember, $spinIdx)
    └─ SELECT ... FOR UPDATE (race condition 방어) → UPDATE status='won'

[4] 모든 쿠폰 소진 시
    └─ hasAvailableCoupon() == false
    └─ 스타벅스 weight=0, 50P weight: 379→381
```

> **쿠폰 보충**: 관리자가 관리자 페이지에서 새 쿠폰을 등록하면 자동으로 다음 스핀부터 스타벅스 당첨 가능하다.

---

## 데이터베이스 설계

### event_spin_history 테이블

스피닝 휠 이벤트의 **모든 게임 기록**을 저장한다.
쿠폰 배정은 `event_coupons` 테이블에서 관리한다 (`starbucks_coupon_file` 컬럼은 레거시 호환용으로 유지, 항상 null).

```sql
CREATE TABLE `event_spin_history` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '게임한 회원 번호 (sf_member.idx)',
  `section_index` tinyint(3) UNSIGNED NOT NULL COMMENT '당첨 섹션 인덱스 (0~9)',
  `prize_type` varchar(16) NOT NULL COMMENT '보상 유형: miss | point | starbucks',
  `points_cost` int(10) UNSIGNED NOT NULL DEFAULT 200 COMMENT '차감된 포인트 (참가비)',
  `points_reward` int(10) NOT NULL DEFAULT 0 COMMENT '획득 포인트 (0=꽝, -1=스타벅스)',
  `starbucks_coupon_file` varchar(255) DEFAULT NULL COMMENT '쿠폰 파일명 (예: 2.jpg)',
  `random_value` int(10) UNSIGNED NOT NULL COMMENT '확률 계산 랜덤 값 (1~1000)',
  `point_before` int(11) NOT NULL DEFAULT 0 COMMENT '게임 전 보유 포인트',
  `point_after` int(11) NOT NULL DEFAULT 0 COMMENT '게임 후 보유 포인트',
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '게임 시각 (Unix timestamp)',
  `ip` varchar(45) NOT NULL DEFAULT '' COMMENT '접속 IP (IPv4/IPv6)',
  PRIMARY KEY (`idx`),
  KEY `idx_member` (`idx_member`),
  KEY `prize_type` (`prize_type`),
  KEY `created_at` (`created_at`),
  KEY `idx_member_created` (`idx_member`, `created_at`),
  KEY `starbucks_coupon_file` (`starbucks_coupon_file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='스피닝 휠 이벤트 기록';
```

**컬럼 설명**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | INT AUTO_INCREMENT | PK |
| `idx_member` | INT | 게임한 회원 번호 |
| `section_index` | TINYINT | 원판 섹션 인덱스 (0~9) |
| `prize_type` | VARCHAR(16) | `miss` / `point` / `starbucks` |
| `points_cost` | INT | 차감 포인트 (기본 200) |
| `points_reward` | INT | 획득 포인트 (꽝=0, 스타벅스=-1) |
| `starbucks_coupon_file` | VARCHAR(255) NULL | ~~레거시~~ 항상 null (쿠폰은 event_coupons 테이블로 이관) |
| `random_value` | INT | 확률 계산 랜덤 값 (감사 추적용) |
| `point_before` | INT | 게임 전 잔액 |
| `point_after` | INT | 게임 후 잔액 |
| `created_at` | INT | Unix timestamp |
| `ip` | VARCHAR(45) | 접속 IP |

### sf_point_log 기록 규칙

| 상황 | module | action | point | etc |
|------|--------|--------|-------|-----|
| 게임 참가비 차감 | `event` | `spin_cost` | -200 | `spin_cost` |
| 50P 당첨 | `event` | `spin_reward` | +50 | `spin_reward_50` |
| 100P 당첨 | `event` | `spin_reward` | +100 | `spin_reward_100` |
| 200P 당첨 | `event` | `spin_reward` | +200 | `spin_reward_200` |
| 300P 당첨 | `event` | `spin_reward` | +300 | `spin_reward_300` |
| 400P 당첨 | `event` | `spin_reward` | +400 | `spin_reward_400` |
| 500P 당첨 | `event` | `spin_reward` | +500 | `spin_reward_500` |
| 1,000P 당첨 | `event` | `spin_reward` | +1000 | `spin_reward_1000` |
| 2,000P 당첨 | `event` | `spin_reward` | +2000 | `spin_reward_2000` |
| 스타벅스 당첨 | `event` | `spin_reward` | 0 | `spin_reward_starbucks` |
| 꽝 | *(충전 기록 없음)* | | | |

> 꽝인 경우 포인트 변동이 없으므로 `sf_point_log`에 충전 기록을 남기지 않는다.
> 단, 참가비 차감 기록(`spin_cost`)은 항상 남긴다.
> 스타벅스 당첨 시 `etc`에 `spin_reward_starbucks`로 기록하여 추적 가능하게 한다.
> `event_spin_history`에는 꽝 포함 모든 결과를 기록한다.

---

## 서버 비즈니스 로직 상세

### EventController 클래스

`Philgo\Event\EventController` — API 엔드포인트 담당.

| 메서드 | API | 인증 | 설명 |
|--------|-----|:----:|------|
| `getAuthenticatedUser()` | (private) | | `AuthService::getLoginUser()` 호출, 미인증 시 예외 |
| `spin(array $input)` | `event.spin` | 필수 | 인증 확인 → `EventService::spin($user)` 호출 |
| `history(array $input)` | `event.history` | 필수 | 인증 확인 → `EventService::getHistory()` 호출 |
| `myCoupons(array $input)` | `event.myCoupons` | 필수 | 인증 확인 → `EventCouponRepository::findByWinner()` 호출 |

### EventService 클래스

`Philgo\Event\EventService` — 비즈니스 로직 담당.

#### 상수

| 상수 | 값 | 설명 |
|------|------|------|
| `SPIN_COST` | 200 | 게임 참가비 (포인트) |

#### 메서드 상세

| 메서드 | 접근 | 설명 |
|--------|:----:|------|
| `spin(array $user)` | public static | 메인 비즈니스 로직 — 8단계 처리 (EventCouponService 연동) |
| `calculateSpinResult(bool $has)` | public static | 가중치 기반 확률 계산, CSPRNG 사용 |
| `getSections()` | public static | 10개 섹션 가중치 테이블 반환 |
| `getHistory(int $idx, int $p, int $l)` | public static | 히스토리 페이지네이션 조회 |

#### `spin()` 처리 흐름 (event_coupons DB 기반)

```
[1] 잔액 확인
    └─ EventRepository::getMember($idxMember)
    └─ currentPoint < 200 → RuntimeException

[2] 사용 가능 쿠폰 확인 (event_coupons DB 기반)
    └─ EventCouponService::hasAvailableCoupon('starbucks')

[3] BEGIN TRANSACTION

[4] 200P 차감
    └─ PointLogService::changePoints(-200, $idxMember, $idxMember, 'event', 'spin_cost', 0, 'spin_cost')

[5] 확률 계산 (쿠폰 유무에 따라 동적)
    └─ self::calculateSpinResult($hasStarbucksCoupon)
    └─ 반환: {section_index, points, prize_type, random_value}

[6] 보상 처리
    ├─ prize_type == 'point' && points > 0:
    │   └─ PointLogService::changePoints($rewardPoints, 0, $idxMember, 'event', 'spin_reward', 0, "spin_reward_{$rewardPoints}")
    │
    ├─ prize_type == 'starbucks':
    │   └─ PointLogService::changePoints(0, 0, $idxMember, 'event', 'spin_reward', 0, 'spin_reward_starbucks')
    │
    └─ prize_type == 'miss':
        └─ (보상 없음)

[7] 이벤트 기록 저장
    └─ EventRepository::insertSpinHistory([
         idx_member, section_index, prize_type, points_cost, points_reward,
         starbucks_coupon_file=null, random_value, point_before, point_after, ip
       ])

[7-1] 스타벅스 당첨 시 쿠폰 배정 (트랜잭션 내)
     └─ EventCouponService::assignCouponToWinner('starbucks', $idxMember, $spinIdx)
        ├─ EventCouponRepository::lockAndPickAvailable('starbucks')  — SELECT ... FOR UPDATE
        └─ EventCouponRepository::assignToWinner($couponIdx, $idxMember, $spinIdx)

[8] COMMIT

[8-1] 스타벅스 당첨 시 freetalk 자동 게시글 (커밋 후)
     └─ PostService::create([post_id='freetalk', ...])

[9] 응답 반환
    └─ {section_index, points, prize_type, current_point, coupon, available_coupons, ...}
    └─ 남은 쿠폰 수: EventCouponService::getAvailableCount('starbucks')
    └─ 실패 시 ROLLBACK (catch 블록에서 $pdo->rollBack())
```

### EventRepository 클래스

`Philgo\Event\EventRepository` — DB 접근 계층 담당.

#### 테이블 상수

| 상수 | 값 | 설명 |
|------|------|------|
| `MEMBER_TABLE` | `sf_member` | 회원 테이블 |
| `POINT_LOG_TABLE` | `sf_point_log` | 포인트 로그 테이블 |
| `SPIN_HISTORY_TABLE` | `event_spin_history` | 스핀 히스토리 테이블 |

#### 메서드 상세

| 메서드 | 쿼리 | 반환 |
|--------|------|------|
| `getMember(int $idx)` | `SELECT * FROM sf_member WHERE idx = ?` | `?array` (회원 레코드 또는 null) |
| `updateMemberPoint(int $idx, int $pt)` | `UPDATE sf_member SET point = ? WHERE idx = ?` | `bool` |
| `insertPointLog(array $data)` | `INSERT INTO sf_point_log (...)` | `int` (생성된 idx) |
| `insertSpinHistory(array $data)` | `INSERT INTO event_spin_history (...)` | `int` (생성된 idx) |
| ~~`getUsedStarbucksCouponFiles()`~~ | ~~폐기~~ — 쿠폰 관리는 `EventCouponRepository`로 이관 | — |
| `getSpinHistory(int $idx, int $p, int $l)` | `SELECT * ... LIMIT ? OFFSET ?` | `['total' => int, 'items' => array]` |

#### `insertPointLog()` 자동 기본값

| 필드 | 기본값 | 조건 |
|------|--------|------|
| `stamp` | `time()` | 미지정 시 |
| `ip` | `$_SERVER['REMOTE_ADDR']` | 미지정 시 |
| `idx_post` | `0` | 미지정 시 |

---

## 에러 처리

모든 에러는 `RuntimeException`으로 발생하며, `api.php`에서 JSON으로 변환된다.

| 상황 | 에러 메시지 | 동작 |
|------|------------|------|
| 미로그인 | `'로그인이 필요합니다.'` | 에러 (게임 미실행) |
| 잔액 부족 | `'포인트가 부족합니다. (최소 200P 필요, 현재 {N}P)'` | 에러 (게임 미실행) |
| 회원 정보 없음 | `'회원 정보를 찾을 수 없습니다.'` | 에러 (게임 미실행) |
| 서버 내부 에러 | `'이벤트 처리 중 오류가 발생했습니다.'` | 에러 (트랜잭션 롤백) |
| 트랜잭션 실패 | (catch 블록) | `$pdo->rollBack()` — 포인트 변동 없음 |

> 모든 에러 상황에서 포인트 변동은 발생하지 않는다 (트랜잭션 원자성 보장).

---

## 클라이언트 연동

### Flutter 앱 연동

#### 1. onSpinRequested 콜백 구현

```dart
SpinningWheel(
  sections: _sections,
  onSpinRequested: () async {
    try {
      final result = await v7api('event.spin');
      if (result['success'] == false) {
        _showErrorSnackBar(result['message']);
        return null; // 회전 취소
      }
      _lastSpinResult = result;
      return result['section_index'] as int;
    } catch (e) {
      _showErrorSnackBar('네트워크 오류가 발생했습니다.');
      return null;
    }
  },
  onResult: (section) {
    _showResultDialog(_lastSpinResult);
  },
);
```

#### 2. 섹션 정의 (10개 섹션, weight 합계 1000)

```dart
_sections = [
  WheelSection(label: '50',    color: Color(0xFFE88B8B), points: 50,   weight: 379),   // index 0
  WheelSection(label: '100',   color: Color(0xFFE8A87C), points: 100,  weight: 80),    // index 1
  WheelSection(label: '200',   color: Color(0xFFF5B971), points: 200,  weight: 70),    // index 2
  WheelSection(label: '300',   color: Color(0xFFD4A76A), points: 300,  weight: 60),    // index 3
  WheelSection(label: '400',   color: Color(0xFFD4B896), points: 400,  weight: 50),    // index 4
  WheelSection(label: '500',   color: Color(0xFFE8C170), points: 500,  weight: 40),    // index 5
  WheelSection(label: '1,000', color: Color(0xFFC9A9C9), points: 1000, weight: 15),    // index 6
  WheelSection(label: '2,000', color: Color(0xFF9CC2D8), points: 2000, weight: 4),     // index 7
  WheelSection(label: '쿠폰',  color: Color(0xFF8BC78B), points: -1,   weight: 2),     // index 8
  WheelSection(label: '꽝',    color: Color(0xFFB0B0B0), points: 0,    weight: 300),   // index 9
];
```

> 서버와 클라이언트가 **동일한 weight 테이블**을 사용하여 확률이 일치한다.
> 스타벅스 쿠폰이 소진되어도 클라이언트 원판에는 여전히 스타벅스 섹션이 표시된다.
> (단, 서버에서 절대 `section_index=8`을 반환하지 않으므로 당첨되지 않음)

### 서버/클라이언트 section_index 매핑

| section_index | 섹션 | 포인트 | Weight | 확률 | prize_type |
|:------------:|------|:------:|:------:|:----:|:----------:|
| 0 | 50P | 50 | 379 | 37.9% | `point` |
| 1 | 100P | 100 | 80 | 8.0% | `point` |
| 2 | 200P | 200 | 70 | 7.0% | `point` |
| 3 | 300P | 300 | 60 | 6.0% | `point` |
| 4 | 400P | 400 | 50 | 5.0% | `point` |
| 5 | 500P | 500 | 40 | 4.0% | `point` |
| 6 | 1,000P | 1,000 | 15 | 1.5% | `point` |
| 7 | 2,000P | 2,000 | 4 | 0.4% | `point` |
| 8 | 스타벅스 쿠폰 | -1 | 2 | 0.2% | `starbucks` |
| 9 | 꽝 | 0 | 300 | 30.0% | `miss` |

---

## 테스트

### PEST Unit Test 실행

```bash
./vendor/bin/pest tests/Unit/EventSpinTest.php
```

### 테스트 범위

총 **46개 테스트**, **11,461개 assertions** 통과.

| 분류 | 테스트 수 | 설명 |
|------|:--------:|------|
| `EventService::getSections` | 7 | 섹션 테이블 정합성 (10개 섹션, weight 합계 1000, 인덱스/포인트/유형) |
| `EventService::calculateSpinResult` | 6 | 확률 계산 (유효 범위, 쿠폰 없을 때 스타벅스 0%, 10만 회 시뮬레이션 ×2) |
| `EventRepository` | 6 | DB CRUD (getMember, updateMemberPoint, insertPointLog, insertSpinHistory, 쿠폰 조회, 페이지네이션) |
| `EventCouponService` | 3 | DB 기반 쿠폰 조회, 배정, race condition 방어 |
| `EventService::spin` | 11 | 메인 로직 (정상 실행, 200P 차감, 포인트 당첨, 꽝, 잔액 부족, 기록 저장, 로그 확인, 연속 스핀) |
| `EventService::getHistory` | 4 | 페이지네이션, 쿠폰 URL 추가, limit/page 검증 |
| `EventController` | 5 | API 엔드포인트 (미인증 예외, 인증 실행, 잔액 부족) |
| 트랜잭션 원자성 | 2 | 실패 시 롤백, point_before/point_after 정확도 |
| 종합 통합 | 2 | 10회 연속 스핀 포인트 누적 + 로그 개수 |
| **합계** | **46** | **11,461 assertions** |

### 주요 테스트 항목 상세

| 테스트 | 방법 | 검증 |
|--------|------|------|
| 확률 분포 (쿠폰 있음) | 10만 회 시뮬레이션 | 모든 섹션 기대값 ±2% 이내, 스타벅스 0.2% 포함 |
| 확률 분포 (쿠폰 없음) | 10만 회 시뮬레이션 | 스타벅스 0% (0회), 50P 38.1% 확인 |
| 쿠폰 없을 때 차단 | `calculateSpinResult(false)` 1만 회 | `section_index=8` 절대 불가 |
| 포인트 정확도 | 연속 5회 스핀 | 매 스핀 후 잔액 = 이전 - 200 + reward |
| 꽝 결과 | 50회 시도 중 꽝 발견 | `points=0`, `current_point=이전-200`, `section_index=9` |
| 기록 저장 | DB 직접 조회 | `event_spin_history` 모든 컬럼 정합성 |

### REST Client 테스트

**파일**: `.claude/skills/v7-skill/rest-client/event-spin-test.http`

VS Code REST Client 확장에서 "Send Request"로 실행 가능하다.

```http
@baseUrl = https://local.philgo.com/api.php
@session_id = YOUR_SESSION_ID

### 스피닝 휠 돌리기
POST {{baseUrl}}
Content-Type: application/json

{
  "method": "event.spin",
  "session_id": "{{session_id}}"
}

### 이벤트 기록 조회
POST {{baseUrl}}
Content-Type: application/json

{
  "method": "event.history",
  "session_id": "{{session_id}}",
  "page": 1,
  "limit": 20
}
```

---

## 보안 고려사항

### 안티치트 방어

| 위협 | 방어 |
|------|------|
| 클라이언트 확률 조작 | 서버에서 100% 결과 결정, 클라이언트는 `section_index`만 수신 |
| 네트워크 패킷 변조 | HTTPS 통신 + Firebase ID Token 인증 |
| 반복 요청 (자동화) | 200P 차감으로 무한 시도 방지 |
| 응답 변조 | 결과가 이미 서버에 기록됨, 클라이언트 변조 무의미 |
| 쿠폰 파일 직접 접근 | `index.php`로 디렉토리 접근 차단 |

### 트랜잭션 안전성

- 포인트 차감 → 확률 계산 → 보상 지급 → 기록 저장을 **단일 트랜잭션**으로 처리
- 중간에 실패하면 전체 롤백 (`$pdo->rollBack()`)

### 감사 추적

| 필드 | 용도 |
|------|------|
| `event_spin_history.random_value` | 확률 계산에 사용된 랜덤 값 → 사후 검증 가능 |
| `event_coupons.idx_spin_history` | 어떤 쿠폰이 어떤 스핀에서 배분되었는지 추적 (DB 기반) |
| `event_spin_history.ip` | 접속 IP 기록 |
| `sf_point_log` | 모든 포인트 변동 기록 |

---

## 향후 확장 방향

| 항목 | 현재 | 확장 방향 |
|------|------|----------|
| 일일 횟수 제한 | 없음 (포인트 잔액으로만 제한) | 일일 N회 제한 추가 |
| 확률 동적 변경 | 코드에 하드코딩 | DB 테이블로 확률 관리 (관리자 페이지에서 변경) |
| 이벤트 기간 | 상시 | 시작/종료일 설정 |
| 보상 종류 | 포인트 + 스타벅스 | 다양한 쿠폰/상품 추가 (`coupon_type` 확장) |
| 통계 대시보드 | ✅ 관리자 위젯 (유형별/상태별 통계) | 더 상세한 통계 페이지 |
| Auto Spin 서버 제한 | 없음 | 연속 돌리기 시 최소 간격 1초 |
| 쿠폰 관리 UI | ✅ 관리자 위젯 (`event_coupons` DB + v7 Upload) | — |

---

## 업소록 방문 후기 포인트 API

### 개요 (후기)

업소록 QR 코드 삼단콤보의 **3단계**이다.
QR 스캔 성공 후 사진과 글(최소 10자)로 후기를 남기면 **랜덤 2,000~3,000P**를 추가 적립한다.
동일 스캔 기록(usage_idx)에 대해 **1회만** 후기 작성이 가능하다.

| 항목 | 값 |
|------|------|
| **적립 범위** | 랜덤 2,000~3,000P (`random_int(2000, 3000)`) |
| **필수 조건** | 로그인 + 본인 스캔 기록 + 성공(result='s') + 미작성 |
| **글 최소 길이** | 10자 |
| **사진 최소 장수** | 1장 이상 |
| **중복 방지** | usage_idx 기준 1회만 |
| **포인트 로그** | module='company', action='visit_review' |
| **DB 테이블** | `company_reviews` |
| **사진 저장** | `uploads` 테이블 (module='company', code='visit_review') |

### company.submitVisitReview — 후기 작성

인증 필수.

QR 스캔 성공 후 사진+글로 업소록 후기를 작성하고 보너스 포인트를 적립한다.

**메서드**: `POST /api.php?method=company.submitVisitReview`

#### cURL 예시

```bash
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "company.submitVisitReview",
    "session_id": "YOUR_SESSION_ID",
    "usage_idx": 104,
    "content": "매우 친절하고 음식이 맛있었습니다. 다음에도 꼭 방문하겠습니다!",
    "photo_idxs": [501, 502]
  }'
```

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| `usage_idx` | int | O | QR 코드 사용 기록 idx |
| `content` | string | O | 후기 글 내용 (최소 10자) |
| `photo_idxs` | int[] | O | 업로드된 사진 idx 배열 (1장 이상) |

#### 성공 응답

```json
{
  "success": true,
  "review_idx": 15,
  "reward_points": 2547,
  "point_before": 3969845,
  "point_after": 3972392,
  "company_name": "체리",
  "idx_company": 1337
}
```

#### 응답 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `success` | bool | 성공 여부 |
| `review_idx` | int | 생성된 후기 idx |
| `reward_points` | int | 지급된 포인트 (2,000~3,000) |
| `point_before` | int | 적립 전 포인트 |
| `point_after` | int | 적립 후 포인트 |
| `company_name` | string | 업소명 |
| `idx_company` | int | 업소 idx |

#### 에러 응답

| 상황 | 에러 메시지 |
|------|------------|
| 미로그인 | `'로그인이 필요합니다.'` |
| usage_idx 없음 | `'유효하지 않은 요청입니다.'` |
| 스캔 기록 없음 | `'스캔 기록을 찾을 수 없습니다.'` |
| 본인 기록 아님 | `'본인의 스캔 기록이 아닙니다.'` |
| 실패한 스캔 | `'성공한 스캔 기록이 아닙니다.'` |
| 중복 작성 | `'이미 후기를 작성하셨습니다.'` |
| 내용 부족 | `'후기 내용은 최소 10자 이상 입력해 주세요.'` |
| 사진 없음 | `'사진을 1장 이상 첨부해 주세요.'` |

---

### company.getVisitReviews — 후기 목록 조회

인증 불필요 (공개 조회).

업소별 방문 후기를 페이지네이션으로 조회한다. 각 후기에 첨부된 사진도 함께 반환한다.

**메서드**: `POST /api.php?method=company.getVisitReviews`

#### cURL 예시

```bash
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "company.getVisitReviews",
    "idx_company": 1337,
    "page": 1,
    "limit": 10
  }'
```

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| `idx_company` | int | O | 업소 idx |
| `page` | int | X | 페이지 번호 (기본 1) |
| `limit` | int | X | 페이지당 개수 (기본 10, 최대 50) |

#### 성공 응답

```json
{
  "success": true,
  "reviews": [
    {
      "idx": 15,
      "idx_company": 1337,
      "idx_member": 186427,
      "usage_idx": 104,
      "content": "매우 친절하고 음식이 맛있었습니다.",
      "reward_points": 2547,
      "created_at": 1740900000,
      "photos": [
        {
          "idx": 501,
          "url": "/uploads/company/visit_review/photo1.jpg",
          "filename": "photo1.jpg"
        }
      ]
    }
  ],
  "total": 5,
  "page": 1,
  "limit": 10
}
```

---

### 후기 서비스 로직 상세

#### CompanyService::submitVisitReview() 처리 흐름

```
[1] 입력 검증
    ├─ idx_member > 0 (로그인 필수)
    ├─ usage_idx > 0
    ├─ content 길이 >= 10자
    └─ photo_idxs 개수 >= 1

[2] 스캔 기록 검증
    ├─ QrCodeUsageRepository::findByIdx($usageIdx) → 존재 확인
    ├─ $usage['idx_member'] === $idxMember → 본인 확인
    └─ $usage['result'] === 's' → 성공 스캔 확인

[3] 중복 검증
    └─ VisitReviewRepository::existsByUsageIdx($usageIdx) → false 필수

[4] 업소 정보 조회
    └─ CompanyRepository::findByIdx($usage['idx_company'])

[5] 포인트 결정
    └─ $rewardPoints = random_int(2000, 3000)

[6] 후기 저장
    └─ VisitReviewRepository::insert([
         idx_company, idx_member, usage_idx, content, reward_points
       ])

[7] 사진 연결
    └─ UploadRepository::updateAttached([
         module='company', code='visit_review',
         attached_to=$reviewIdx, photo_idxs
       ])

[8] 포인트 적립
    └─ PointLogService::changePoints([
         idx_member, points=$rewardPoints,
         module='company', action='visit_review',
         etc='{업소명} 방문 후기 보상 (usage_idx:{N})'
       ])

[9] 결과 반환
```

#### sf_point_log 기록 규칙 (후기)

| 상황 | module | action | point | etc |
|------|--------|--------|-------|-----|
| 후기 작성 보상 | `company` | `visit_review` | +2,000~3,000 | `{업소명} 방문 후기 보상 (usage_idx:{N})` |

#### VisitReviewRepository 메서드

| 메서드 | 쿼리 | 반환 |
|--------|------|------|
| `insert(array $data)` | `INSERT INTO company_reviews (...)` | `int` (생성된 idx) |
| `findByIdx(int $idx)` | `SELECT * WHERE idx = ?` | `?VisitReviewEntity` |
| `findByUsageIdx(int $usageIdx)` | `SELECT * WHERE usage_idx = ?` | `?VisitReviewEntity` |
| `existsByUsageIdx(int $usageIdx)` | `SELECT COUNT(*) WHERE usage_idx = ?` | `bool` |
| `findByCompany(int $idx, int $p, int $l)` | `SELECT * WHERE idx_company = ? LIMIT ? OFFSET ?` | `VisitReviewEntity[]` |
| `countByCompany(int $idxCompany)` | `SELECT COUNT(*) WHERE idx_company = ?` | `int` |

---

### 후기 DB 테이블: company_reviews

```sql
CREATE TABLE `company_reviews` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_company` int(10) UNSIGNED NOT NULL COMMENT '업소 FK',
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '회원 FK',
  `usage_idx` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'QR 사용 기록 FK',
  `content` text NOT NULL COMMENT '후기 내용',
  `reward_points` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '지급 포인트',
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '작성 시간',
  PRIMARY KEY (`idx`),
  KEY `idx_company` (`idx_company`),
  KEY `idx_member` (`idx_member`),
  UNIQUE KEY `uk_usage_idx` (`usage_idx`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='업소록 방문 후기';
```

**컬럼 설명**:

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `idx` | INT AUTO_INCREMENT | PK |
| `idx_company` | INT | 업소 FK |
| `idx_member` | INT | 작성자 회원 FK |
| `usage_idx` | INT UNIQUE | QR 사용 기록 FK (1회 제한 보장) |
| `content` | TEXT | 후기 글 내용 |
| `reward_points` | INT | 지급한 포인트 (2,000~3,000) |
| `created_at` | INT | 작성 시간 (Unix timestamp) |

**사진 저장**: `uploads` 테이블에 `module='company'`, `code='visit_review'`, `attached_to=company_reviews.idx`로 연결.

---

### 후기 웹 페이지: visit-review-point.php

**URL**: `/company/visit-review-point.php?usage_idx={usage_idx}`

레거시(boot.php) + v7(CompanyService) 혼용 페이지.
Vue.js Options API로 프론트엔드를 구성하며, `v7apiUpload()`로 사진 업로드, `v7api()`로 후기 제출을 처리한다.

```
boot.php 로드 + vendor/autoload.php
  ↓
로그인/usage_idx 검증 (PHP 서버 사이드)
  ↓
Vue.js 앱 마운트
  ├─ 사진 업로드 그리드 (v7apiUpload → uploads 테이블)
  ├─ 글 내용 textarea (최소 10자)
  └─ 제출 버튼 → v7api('company.submitVisitReview')
       ├─ 성공 → 축하 화면 (포인트 표시)
       └─ 실패 → 에러 메시지
```

**진입 경로**:
1. QR 스캔 성공 → `qr-code-scanned.php` → "업소록 후기 포인트" CTA → `visit-review-point.php`
2. 재방문 포인트 적립 → `re-visit-point.php` → "후기 작성하기" CTA → `visit-review-point.php`

---

### 후기 JavaScript 헬퍼: v7api.js

`/js/v7api.js`에 v7 시스템 전용 API 호출 함수가 정의되어 있다.
기존 레거시 `func()` 함수 대신 사용한다.

#### v7api() — API 호출

```javascript
async function v7api(method, params = {}, options = {})
// method: API 메서드명 (예: 'company.submitVisitReview')
// params: 파라미터 객체
// options: { alertOnError: true } — 에러 시 alert 표시 여부
// 반환: Promise<Object> — API 응답 데이터
// 내부: session_id 자동 추가 → axios.post('/api.php', params)
```

#### v7apiUpload() — 파일 업로드

```javascript
async function v7apiUpload(file, module, code)
// file: File 객체
// module: 모듈명 (예: 'company')
// code: 코드 (예: 'visit_review')
// 반환: Promise<Object> — 업로드 응답 (idx, url 포함)
// 내부: FormData + axios.post('/api.php?method=upload.create')
```

> **중요**: 기존 레거시 `func()` 함수로는 v7 API를 호출할 수 없다.
> v7 시스템 API 호출 시 반드시 `v7api()` 또는 `v7apiUpload()`를 사용해야 한다.

---

## 관련 문서

| 문서 | 내용 |
|------|------|
| [server-point-event-spin-plan.md](../../plan/server-point-event-spin-plan.md) | 이벤트 스피닝 휠 서버 API 계획서 |
| [v7-event-entry.md](../app/v7-event-entry.md) | 클라이언트 스피닝 휠 위젯 아키텍처 |
| [v7-point-event.md](v7-point-event.md) | 기존 먹방 이벤트 API (참고용) |
| [v7-architecture.md](../v7-architecture.md) | v7 시스템 아키텍처 |
| [v7-event-overview.md](../event/v7-event-overview.md) | 이벤트 시스템 통합 개요 |
| [philgo.sql](../../database/philgo.sql) | DB 스키마 |
