# 이벤트 스피닝 휠 서버 API 계획서

## 목차

1. [개요](#개요)
2. [COT (Chain-of-Thought) 분석](#cot-chain-of-thought-분석)
3. [TOT (Tree-of-Thought) 분석](#tot-tree-of-thought-분석)
4. [확률 시스템](#확률-시스템)
5. [API 흐름도](#api-흐름도)
6. [데이터베이스 설계](#데이터베이스-설계)
7. [API 엔드포인트 명세](#api-엔드포인트-명세)
8. [서버 비즈니스 로직](#서버-비즈니스-로직)
9. [스타벅스 쿠폰 관리 시스템](#스타벅스-쿠폰-관리-시스템)
10. [클라이언트 연동](#클라이언트-연동)
11. [파일 구조](#파일-구조)
12. [테스트 계획](#테스트-계획)
13. [보안 고려사항](#보안-고려사항)
14. [향후 확장 방향](#향후-확장-방향)

---

## 개요

### 핵심 목적

필고 앱의 **이벤트 응모 스피닝 휠(원판 돌리기)** 서버 API 개발.
**서버에서 모든 결과를 미리 결정**하여 클라이언트에 응답하고,
클라이언트는 해당 결과에 맞춰 원판을 회전시켜 **랜덤으로 당첨되는 것처럼 보이게** 한다.

### 안티치트 원칙

> **서버에서 100% 결과를 결정하고, 클라이언트는 시각적 연출만 담당한다.**
> DevTools 조작, 메모리 해킹, 네트워크 패킷 변조로도 결과를 바꿀 수 없다.

### 처리 흐름 요약

```
사용자 버튼 클릭
  → 클라이언트: event.spin API 호출
  → 서버: 사용 가능한 스타벅스 쿠폰 수 확인 (event_coupons DB 테이블 조회)
  → 서버: 200P 차감
  → 서버: 가중치 기반 확률 결과 결정 (쿠폰 없으면 스타벅스 확률 0%)
  → 서버: 당첨 포인트 충전 (0, 50, 100, 200, 300, 400, 500, 1000, 2000)
  → 서버: 스타벅스 당첨 시 event_coupons에서 쿠폰 배정 (SELECT...FOR UPDATE)
  → 서버: DB에 이벤트 기록 저장
  → 서버: 클라이언트에 결과(section_index, points, prize_type) 응답
  → 클라이언트: section_index에 맞춰 원판 회전 애니메이션
```

### 스타벅스 쿠폰 관리 핵심 원칙

> **쿠폰은 `event_coupons` DB 테이블로 100% 관리**한다.
> 관리자가 v7 Upload API로 QR 이미지를 업로드하여 쿠폰을 등록하고,
> 당첨 시 `SELECT ... FOR UPDATE`로 race condition을 방어하며 자동 배정한다.
> 상태 흐름: `available → won → sent`
> 사용 가능한 쿠폰이 **0개이면 스타벅스 당첨 확률은 자동으로 0%**가 된다.
> 상세 문서: → [v7-event-coupon.md](v7-event-coupon.md)

---

## COT (Chain-of-Thought) 분석

### 1단계: 문제의 핵심 이해

**문제**: 스피닝 휠 이벤트에서 사용자가 포인트를 소비하여 게임을 하고, 확률에 따라 보상을 받는 시스템.

**핵심 요구사항**:
- 200P를 차감하고 게임 진행
- 서버에서 확률적으로 결과를 미리 결정 (안티치트)
- 당첨 시 포인트 자동 충전
- 스타벅스 쿠폰 당첨 시 event_coupons에서 쿠폰 배정 (DB 기반)
- 사용 가능한 쿠폰이 없으면 스타벅스 당첨 불가
- 모든 게임 기록을 DB에 상세히 저장
- 클라이언트에는 section_index만 응답하여 원판 애니메이션에 사용

**기존 시스템과의 관계**:
```
기존 포인트 이벤트 (먹방 이벤트)
  ├─ 글 작성 + 영수증 검증 → 포인트 지급
  └─ module='point_event', action='mukbang_create'

스피닝 휠 이벤트 (신규)
  ├─ 200P 소비 → 확률 기반 보상
  └─ module='event', action='spin'
```

### 2단계: 해결 전략 수립

| 과제 | 해결 방법 |
|------|----------|
| 확률 계산 | 가중치(weight) 기반 확률, `random_int(1, 1000)` 사용 (0.1% 단위) |
| 포인트 차감 | sf_member.point UPDATE + sf_point_log INSERT |
| 포인트 충전 | sf_member.point UPDATE + sf_point_log INSERT |
| 스타벅스 쿠폰 | `event_coupons` DB 테이블에서 status='available' 쿠폰 조회 → SELECT...FOR UPDATE로 배정 |
| 쿠폰 소진 | 사용 가능 쿠폰 0개 → 스타벅스 확률 0%로 변경 (스타벅스 weight를 50P에 합산) |
| 기록 저장 | event_spin_history 테이블에 INSERT |
| 클라이언트 연동 | section_index 반환 → 원판 회전 애니메이션 |

### 3단계: 아키텍처 결정

**기존 PointEvent 모듈과 분리하여 신규 Event 모듈로 생성**:

```
lib/event/
├── EventController.php        ← API 엔드포인트 (event.spin, event.history)
├── EventService.php           ← 비즈니스 로직 (확률 계산, 포인트 처리, 쿠폰 관리)
└── EventRepository.php        ← DB 접근 (event_spin_history CRUD)
```

**이유**: 스피닝 휠 이벤트는 먹방 이벤트(PointEvent)와 성격이 다르다.
먹방 이벤트는 글 작성 + 영수증 검증 기반이고, 스피닝 휠은 포인트 소비 + 확률 게임이다.
따라서 별도의 Event 모듈로 분리하여 관리한다.

### 4단계: 확률 알고리즘 설계

**가중치 기반(weight 합계 1000) 확률 매핑** — 10개 섹션, 스타벅스 쿠폰 유무에 따라 동적 변경:

```php
// ◆ 10개 섹션 가중치 테이블 (weight 합계 = 1000 → 0.1% 단위)
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

// ◆ 스타벅스 쿠폰이 없을 때: section_index=8(스타벅스)의 weight=2을 section_index=0(50P)에 합산
// 즉 50P weight: 379 → 381, 스타벅스 weight: 2 → 0 (총합 여전히 1000)
```

### 5단계: 테스트 전략

- PEST Unit Test로 확률 분포 검증 (10만 회 시뮬레이션)
- 포인트 차감/충전 정확성 검증
- 스타벅스 쿠폰 DB 조회 → 배정 로직 검증
- 쿠폰 소진 시 스타벅스 당첨 불가 확인
- 잔액 부족 시 에러 처리 검증
- REST Client (.http 파일)로 API 동작 검증

---

## TOT (Tree-of-Thought) 분석

### 하위 문제 분해

```
이벤트 스피닝 휠 서버 API
├─ [P1] 데이터베이스
│  ├─ [P1-1] event_spin_history 테이블 생성 (starbucks_coupon_file 컬럼 포함)
│  └─ [P1-2] sf_point_log 기록 규칙 정의
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
├─ [P4] 스타벅스 쿠폰 관리 (DB 기반 — event_coupons 테이블)
│  ├─ [P4-1] EventCouponService::hasAvailableCoupon('starbucks') → 사용 가능 쿠폰 존재 여부
│  ├─ [P4-2] 쿠폰 0개 → 스타벅스 확률 0%로 전환 (weight를 50P에 합산)
│  ├─ [P4-3] 당첨 시 EventCouponService::assignCouponToWinner() → SELECT...FOR UPDATE 배정
│  └─ [P4-4] 상태 흐름: available → won → sent
│  → 상세: [v7-event-coupon.md](v7-event-coupon.md)
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
| P1-1 | CREATE TABLE event_spin_history + event_coupons | 낮음 |
| P2-1 | 가중치(weight 합계 1000) 기반 누적 매핑, random_int(1, 1000) | 중간 |
| P2-4 | 쿠폰 유무 판단 후 확률 테이블 분기 | 중간 |
| P3-1 | BEGIN TRANSACTION → SELECT point → UPDATE → COMMIT | 높음 |
| P3-3 | PDO transaction으로 원자성 보장 | 중간 |
| P4-1 | EventCouponService::hasAvailableCoupon('starbucks') → DB 조회 | 낮음 |
| P4-2 | 사용 가능 쿠폰 0개 → $hasStarbucks = false → 스타벅스 weight=0, 50P에 합산 | 낮음 |
| P4-3 | 당첨 시 EventCouponService::assignCouponToWinner() → SELECT...FOR UPDATE | 중간 |
| P5-1 | EventController::spin($input) | 중간 |
| P7-1 | JSON: {section_index, points, prize_type, coupon, ...} | 낮음 |

### 통합 및 검증

- P4(쿠폰 확인) → P2(확률 결정) → P3(포인트 처리) → P1(기록 저장): 순차 실행
- P4(쿠폰 유무) + P2(확률) → 쿠폰 없으면 스타벅스 확률 0%로 동적 전환
- P5(API) + P7(클라이언트) → section_index 기반 연동
- P1(DB) + P6(모듈) → Repository에서 DB 접근

---

## 확률 시스템

### 기본 확률 분포표 (스타벅스 쿠폰 있을 때)

총 10개 섹션, 가중치(weight) 합계 1000 (0.1% 단위 확률 제어).

| 섹션 | section_index | 당첨 포인트 | Weight | 확률 |
|------|:------------:|:-----------:|:------:|:----:|
| 50P | 0 | +50P | 379 | **37.9%** |
| 100P | 1 | +100P | 80 | **8.0%** |
| 200P | 2 | +200P | 70 | **7.0%** |
| 300P | 3 | +300P | 60 | **6.0%** |
| 400P | 4 | +400P | 50 | **5.0%** |
| 500P | 5 | +500P | 40 | **4.0%** |
| 1,000P | 6 | +1,000P | 15 | **1.5%** |
| 2,000P | 7 | +2,000P | 4 | **0.4%** |
| 스타벅스 쿠폰 | 8 | 쿠폰 전송 | 2 | **0.2%** |
| 꽝 | 9 | 0P | 300 | **30.0%** |
| **합계** | | | **1,000** | **100.0%** |

### 확률 등급 분류

| 등급 | 섹션 | 확률 합계 | 설계 의도 |
|------|------|----------|----------|
| **일반** | 50P + 꽝 | 67.9% | 대부분의 결과 (약 2/3) |
| **중간** | 100P ~ 500P | 30% | 적당한 보상감 제공 |
| **희귀** | 1,000P | 1.5% | 드문 행운 |
| **초희귀** | 2,000P | 0.4% | 매우 드문 대박 |
| **전설** | 스타벅스 쿠폰 | 0.2% | 500회에 1번 (최고 보상) |

### 쿠폰 소진 시 확률 분포표 (스타벅스 쿠폰 없을 때)

> 스타벅스 0.2%(weight 2)을 50P에 합산 → 50P weight: 379 → **381**, 스타벅스 weight: 2 → **0**

| 섹션 | section_index | 당첨 포인트 | Weight | 확률 |
|------|:------------:|:-----------:|:------:|:----:|
| 50P | 0 | +50P | **381** | **38.1%** |
| 100P | 1 | +100P | 80 | 8.0% |
| 200P | 2 | +200P | 70 | 7.0% |
| 300P | 3 | +300P | 60 | 6.0% |
| 400P | 4 | +400P | 50 | 5.0% |
| 500P | 5 | +500P | 40 | 4.0% |
| 1,000P | 6 | +1,000P | 15 | 1.5% |
| 2,000P | 7 | +2,000P | 4 | 0.4% |
| ~~스타벅스 쿠폰~~ | ~~8~~ | ~~쿠폰~~ | **0** | **0.0%** |
| 꽝 | 9 | 0P | 300 | 30.0% |
| **합계** | | | **1,000** | **100.0%** |

### 손익 분석 (1회 게임 기준)

| 항목 | 계산 |
|------|------|
| **비용** | -200P (게임 참가비) |
| **기대 수익** | 50×0.379 + 100×0.08 + 200×0.07 + 300×0.06 + 400×0.05 + 500×0.04 + 1000×0.015 + 2000×0.004 + 0×0.30 = **121.95P** |
| **기대 순손실** | 200 - 121.95 = **-78.05P** |

> 사용자는 평균적으로 1회 게임당 약 78P를 잃는다. 이는 게임의 지속 가능성을 보장한다.
> ※ 스타벅스 쿠폰(0.2%)은 포인트가 아닌 실물 보상이므로 기대값 계산에서 제외

### 확률 계산 알고리즘 (PHP)

```php
/**
 * 스피닝 휠 확률 계산 (가중치 기반)
 *
 * 10개 섹션의 weight 합계 1000 기반으로 확률 계산.
 * 사용 가능한 스타벅스 쿠폰 유무에 따라 확률 테이블을 동적으로 변경한다.
 * - 쿠폰 있음: 스타벅스 weight=2 (0.2%) 포함
 * - 쿠폰 없음: 스타벅스 weight=0, 해당 weight를 50P에 합산
 *
 * @param bool $hasStarbucksCoupon 사용 가능한 스타벅스 쿠폰 존재 여부
 * @return array ['section_index' => int, 'points' => int, 'prize_type' => string, 'random_value' => int]
 */
public static function calculateSpinResult(bool $hasStarbucksCoupon): array
{
    // 10개 섹션 가중치 테이블 (클라이언트와 동일한 순서)
    $sections = [
        ['section_index' => 0, 'points' => 50,   'weight' => 379, 'prize_type' => 'point'],
        ['section_index' => 1, 'points' => 100,  'weight' => 80,  'prize_type' => 'point'],
        ['section_index' => 2, 'points' => 200,  'weight' => 70,  'prize_type' => 'point'],
        ['section_index' => 3, 'points' => 300,  'weight' => 60,  'prize_type' => 'point'],
        ['section_index' => 4, 'points' => 400,  'weight' => 50,  'prize_type' => 'point'],
        ['section_index' => 5, 'points' => 500,  'weight' => 40,  'prize_type' => 'point'],
        ['section_index' => 6, 'points' => 1000, 'weight' => 15,  'prize_type' => 'point'],
        ['section_index' => 7, 'points' => 2000, 'weight' => 4,   'prize_type' => 'point'],
        ['section_index' => 8, 'points' => -1,   'weight' => 2,   'prize_type' => 'starbucks'],
        ['section_index' => 9, 'points' => 0,    'weight' => 300, 'prize_type' => 'miss'],
    ];

    // 스타벅스 쿠폰이 없으면: 스타벅스 weight를 50P에 합산
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
    return ['section_index' => 9, 'points' => 0, 'prize_type' => 'miss', 'random_value' => $rand];
}
```

---

## API 흐름도

### event.spin 전체 흐름

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
  │  └─ AuthService::getLoginUser() → $user (실패 시 에러)
  │
  ├─ [2] 잔액 확인
  │  └─ SELECT point FROM sf_member WHERE idx = ?
  │  └─ point < 200 이면 에러: "포인트가 부족합니다. (최소 200P 필요)"
  │
  ├─ [3] ★ 사용 가능한 스타벅스 쿠폰 확인 (event_coupons DB 테이블)
  │  └─ EventCouponService::hasAvailableCoupon('starbucks')
  │     → SELECT COUNT(*) FROM event_coupons WHERE coupon_type='starbucks' AND status='available'
  │
  ├─ [4] BEGIN TRANSACTION
  │
  ├─ [5] 200P 차감
  │  ├─ UPDATE sf_member SET point = point - 200 WHERE idx = ?
  │  └─ INSERT INTO sf_point_log (차감 기록)
  │     └─ module='event', action='spin_cost', point=-200
  │
  ├─ [6] ★ 확률 계산 → 결과 결정 (쿠폰 유무에 따라 동적 확률)
  │  └─ EventService::calculateSpinResult($hasStarbucksCoupon)
  │     → {section_index, points, prize_type, random_value}
  │
  ├─ [7] 보상 처리 (prize_type에 따라 분기)
  │  │
  │  ├─ prize_type == 'point' (50, 100, 200, 300, 400, 500, 1000, 2000P)
  │  │  ├─ UPDATE sf_member SET point = point + ? WHERE idx = ?
  │  │  └─ INSERT INTO sf_point_log (충전 기록)
  │  │     └─ module='event', action='spin_reward', point=+N
  │  │
  │  ├─ prize_type == 'starbucks'
  │  │  ├─ sf_point_log에 기록 (포인트 변동 없음, 기록용)
  │  │  └─ EventCouponService::assignCouponToWinner() → SELECT...FOR UPDATE 배정
  │  │     → status: available → won, idx_winner 설정
  │  │
  │  └─ prize_type == 'miss' (꽝)
  │     └─ 보상 없음
  │
  ├─ [8] 이벤트 기록 저장
  │  └─ INSERT INTO event_spin_history
  │     (idx_member, section_index, prize_type, points_cost, points_reward,
  │      starbucks_coupon_file, random_value, created_at)
  │
  ├─ [9] COMMIT TRANSACTION
  │
  └─ [10] 응답 반환
     └─ {
          success: true,
          section_index: 2,
          points: 1000,
          prize_type: "point",
          current_point: 13800,
          lv: 3,
          level_progress: 45,
          available_coupons: 3,
          spin_idx: 456,
          coupon: null
        }
```

---

## 데이터베이스 설계

### 1. 신규 테이블: event_spin_history

스피닝 휠 이벤트의 **모든 게임 기록**을 저장한다.
스타벅스 쿠폰 당첨 시 쿠폰 배정은 `event_coupons` 테이블에서 관리한다.

```sql
CREATE TABLE `event_spin_history` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '게임한 회원 번호 (sf_member.idx)',
  `section_index` tinyint(3) UNSIGNED NOT NULL COMMENT '당첨 섹션 인덱스 (0~9)',
  `prize_type` varchar(16) NOT NULL COMMENT '보상 유형: miss | point | starbucks',
  `points_cost` int(10) UNSIGNED NOT NULL DEFAULT 200 COMMENT '차감된 포인트 (참가비)',
  `points_reward` int(10) NOT NULL DEFAULT 0 COMMENT '획득 포인트 (0=꽝, 50/100/200/300/400/500/1000/2000)',
  `starbucks_coupon_file` varchar(255) DEFAULT NULL COMMENT '스타벅스 쿠폰 파일명 (NULL=해당없음, 예: 2.jpg)',
  `random_value` int(10) UNSIGNED NOT NULL COMMENT '확률 계산에 사용된 랜덤 값 (1~10000, 감사 추적용)',
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
| `section_index` | TINYINT | 원판 섹션 인덱스 (0=50P, 1=100P, 2=200P, 3=300P, 4=400P, 5=500P, 6=1000P, 7=2000P, 8=스타벅스, 9=꽝) |
| `prize_type` | VARCHAR(16) | `miss` / `point` / `starbucks` |
| `points_cost` | INT | 차감 포인트 (기본 200) |
| `points_reward` | INT | 획득 포인트 (꽝=0, 스타벅스=-1, 포인트=50/100/200/300/400/500/1000/2000) |
| `starbucks_coupon_file` | VARCHAR(255) NULL | 레거시 컬럼 (항상 NULL — 쿠폰은 event_coupons 테이블로 관리) |
| `random_value` | INT | 확률 계산 랜덤 값 (감사 추적용) |
| `point_before` | INT | 게임 전 잔액 |
| `point_after` | INT | 게임 후 잔액 |
| `created_at` | INT | Unix timestamp |
| `ip` | VARCHAR(45) | 접속 IP |

### 스타벅스 쿠폰 관리 — DB 기반 (event_coupons 테이블)

> 파일 기반 쿠폰 관리(`event/cupon/starbucks/` 폴더)는 **완전히 삭제**되었다.
> 모든 쿠폰은 `event_coupons` DB 테이블로 관리한다.
> 상세 문서: → [v7-event-coupon.md](v7-event-coupon.md)

```
event_coupons 테이블:
  idx=1, coupon_type='starbucks', status='won',       idx_winner=123  ← 이미 배정됨
  idx=2, coupon_type='starbucks', status='available',  idx_winner=NULL ← 사용 가능
  idx=3, coupon_type='starbucks', status='sent',       idx_winner=456  ← 전송 완료

사용 가능 쿠폰 = status='available' 인 행 수
```

### 3. sf_point_log 기록 규칙

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

> 꽝인 경우 포인트 변동이 없으므로 sf_point_log에 충전 기록을 남기지 않는다.
> 단, 참가비 차감 기록(spin_cost)은 항상 남긴다.
> 스타벅스 당첨 시 쿠폰 배정은 event_coupons 테이블에서 관리한다.
> event_spin_history에는 꽝 포함 모든 결과를 기록한다.

---

## API 엔드포인트 명세

### 1. event.spin — 스피닝 휠 돌리기

**메서드**: `POST /api.php?method=event.spin`
**인증**: 필수 (Firebase ID Token)

#### 요청 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|:----:|------|
| *(없음)* | | | 인증 정보만 필요 |

#### 성공 응답 (200)

```json
{
  "success": true,
  "section_index": 2,
  "points": 1000,
  "prize_type": "point",
  "current_point": 13800,
  "lv": 3,
  "level_progress": 45,
  "available_coupons": 2,
  "spin_idx": 456,
  "coupon": null
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `success` | bool | 성공 여부 |
| `section_index` | int | 원판 섹션 인덱스 (0~9) |
| `points` | int | 당첨 포인트 (0=꽝, -1=스타벅스) |
| `prize_type` | string | `miss` / `point` / `starbucks` |
| `current_point` | int | 게임 후 잔여 포인트 |
| `lv` | int | 현재 레벨 |
| `level_progress` | int | 레벨 진행률 (0~100) |
| `available_coupons` | int | 남은 사용 가능 쿠폰 수 |
| `spin_idx` | int | event_spin_history.idx (기록 번호) |
| `coupon` | object\|null | 당첨 쿠폰 정보 `{idx, title, coupon_type}` (스타벅스 당첨 시만) |

#### 스타벅스 당첨 응답 예시

```json
{
  "success": true,
  "section_index": 8,
  "points": -1,
  "prize_type": "starbucks",
  "current_point": 13800,
  "lv": 3,
  "level_progress": 45,
  "available_coupons": 1,
  "spin_idx": 457,
  "coupon": {
    "idx": 42,
    "title": "스타벅스 아메리카노",
    "coupon_type": "starbucks"
  }
}
```

#### 에러 응답

```json
{
  "success": false,
  "message": "포인트가 부족합니다. (최소 200P 필요, 현재 150P)"
}
```

| 에러 상황 | message |
|----------|---------|
| 미로그인 | "로그인이 필요합니다." |
| 포인트 부족 | "포인트가 부족합니다. (최소 200P 필요, 현재 {N}P)" |
| 서버 에러 | "이벤트 처리 중 오류가 발생했습니다." |

#### curl 테스트

```bash
# 스피닝 휠 돌리기
curl -X POST "https://local.philgo.com/api.php" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "event.spin",
    "session_id": "YOUR_SESSION_ID"
  }'
```

### 2. event.history — 이벤트 기록 조회

**메서드**: `POST /api.php?method=event.history`
**인증**: 필수 (Firebase ID Token)

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
      "idx": 457,
      "section_index": 8,
      "prize_type": "starbucks",
      "points_cost": 200,
      "points_reward": -1,
      "starbucks_coupon_file": null,
      "point_before": 14000,
      "point_after": 13800,
      "created_at": 1709876543
    },
    {
      "idx": 456,
      "section_index": 2,
      "prize_type": "point",
      "points_cost": 200,
      "points_reward": 1000,
      "starbucks_coupon_file": null,
      "point_before": 14200,
      "point_after": 15000,
      "created_at": 1709876400
    }
  ]
}
```

---

## 서버 비즈니스 로직

### EventService::spin() 상세 로직

```php
/**
 * 스피닝 휠 게임 실행
 *
 * 1. 잔액 확인 (200P 이상)
 * 2. 사용 가능한 스타벅스 쿠폰 확인 (event_coupons DB 테이블)
 * 3. 200P 차감
 * 4. 확률 계산 → 결과 결정 (쿠폰 유무에 따라 동적 확률)
 * 5. 보상 처리 (포인트 충전 / 스타벅스 쿠폰 배정)
 * 6. 이벤트 기록 저장
 * 7. 결과 반환
 *
 * @param array $user 로그인 사용자 정보
 * @return array 게임 결과
 * @throws RuntimeException 잔액 부족, 서버 에러
 */
public static function spin(array $user): array
{
    $pdo = Db::pdo();
    $idxMember = (int) $user['idx'];

    // [1] 잔액 확인
    $member = EventRepository::getMember($idxMember);
    $currentPoint = (int) $member['point'];

    if ($currentPoint < 200) {
        throw new RuntimeException(
            "포인트가 부족합니다. (최소 200P 필요, 현재 {$currentPoint}P)"
        );
    }

    // [2] ★ 사용 가능한 스타벅스 쿠폰 확인 (event_coupons DB 테이블)
    $hasStarbucksCoupon = EventCouponService::hasAvailableCoupon('starbucks');

    // [3] 트랜잭션 시작
    $pdo->beginTransaction();

    try {
        // [4] 200P 차감 (PointLogService를 통해 포인트 변경 + 로그 기록)
        $costLog = PointLogService::changePoints(
            -self::SPIN_COST, $idxMember, $idxMember,
            'event', 'spin_cost', 0, 'spin_cost'
        );
        $pointAfterCost = $costLog->point_after;

        // [5] ★ 확률 계산 (쿠폰 유무에 따라 동적 확률)
        $result = self::calculateSpinResult($hasStarbucksCoupon);
        $sectionIndex = $result['section_index'];
        $prizeType = $result['prize_type'];
        $rewardPoints = $result['points'];
        $randomValue = $result['random_value'];

        // [6] 보상 처리
        $assignedCoupon = null;
        $finalPoint = $pointAfterCost;

        if ($prizeType === 'point' && $rewardPoints > 0) {
            // 포인트 당첨 (PointLogService를 통해 포인트 충전 + 로그 기록)
            $rewardLog = PointLogService::changePoints(
                $rewardPoints, 0, $idxMember,
                'event', 'spin_reward', 0, "spin_reward_{$rewardPoints}"
            );
            $finalPoint = $rewardLog->point_after;
        } elseif ($prizeType === 'starbucks') {
            // sf_point_log 기록 (포인트 변동 없음, 기록용)
            PointLogService::changePoints(
                0, 0, $idxMember,
                'event', 'spin_reward', 0, 'spin_reward_starbucks'
            );
            $finalPoint = $pointAfterCost;
        }
        // prize_type == 'miss' → 보상 없음

        // [7] 이벤트 기록 저장
        $spinIdx = EventRepository::insertSpinHistory([
            'idx_member' => $idxMember,
            'section_index' => $sectionIndex,
            'prize_type' => $prizeType,
            'points_cost' => self::SPIN_COST,
            'points_reward' => $rewardPoints,
            'starbucks_coupon_file' => null,
            'random_value' => $randomValue,
            'point_before' => $currentPoint,
            'point_after' => $finalPoint,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? '',
        ]);

        // [7-1] 스타벅스 당첨 시 → event_coupons에서 쿠폰 배정 (트랜잭션 내)
        if ($prizeType === 'starbucks') {
            $assignedCoupon = EventCouponService::assignCouponToWinner(
                'starbucks', $idxMember, $spinIdx
            );
        }

        // [8] 커밋
        $pdo->commit();

        // [8-1] 스타벅스 당첨 시 freetalk 게시판에 당첨 글 자동 작성
        if ($prizeType === 'starbucks') { /* PostService::create(...) */ }

        // 남은 쿠폰 수 — DB 기반 조회
        $remainingCoupons = EventCouponService::getAvailableCount('starbucks');

        // [9] 응답 반환
        return [
            'section_index' => $sectionIndex,
            'points' => $rewardPoints,
            'prize_type' => $prizeType,
            'current_point' => $finalPoint,
            'lv' => UserService::calculateLevel($finalPoint),
            'level_progress' => UserService::calculateLevelProgress($finalPoint, ...),
            'available_coupons' => $remainingCoupons,
            'spin_idx' => $spinIdx,
            'coupon' => $assignedCoupon ? [
                'idx' => (int) $assignedCoupon['idx'],
                'title' => $assignedCoupon['title'] ?? '',
                'coupon_type' => $assignedCoupon['coupon_type'] ?? 'starbucks',
            ] : null,
        ];

    } catch (\Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}
```

---

## 스타벅스 쿠폰 관리 시스템

> **⚠️ 파일 기반 쿠폰 관리는 완전히 삭제되었다.**
> 모든 쿠폰은 `event_coupons` DB 테이블로 100% 관리한다.
> 상세 문서: → [v7-event-coupon.md](v7-event-coupon.md)

### 핵심 원칙

- 관리자가 v7 Upload API로 QR 이미지를 업로드하여 쿠폰 등록
- `event_coupons` 테이블로 쿠폰 상태 관리: `available → won → sent`
- 당첨 시 `SELECT ... FOR UPDATE`로 race condition 방어
- 사용 가능 쿠폰 0개 → 스타벅스 확률 자동 0%

### 쿠폰 라이프사이클

```
[1] 관리자가 쿠폰 등록 (관리자 위젯)
    └─ func('create_event_coupon', {...}) → event_coupons INSERT (status='available')

[2] 스핀 API 호출 시 사용 가능 쿠폰 확인
    └─ EventCouponService::hasAvailableCoupon('starbucks')
       → SELECT COUNT(*) FROM event_coupons WHERE coupon_type='starbucks' AND status='available'

[3] 스타벅스 당첨 시
    └─ EventCouponService::assignCouponToWinner('starbucks', $idxMember, $spinIdx)
       → SELECT ... FOR UPDATE + UPDATE status='won', idx_winner, won_at, idx_spin_history

[4] 관리자가 쿠폰 전송 완료 처리
    └─ func('update_event_coupon_sent', {idx: ...}) → UPDATE status='sent'

[5] 모든 쿠폰 소진 시
    ├─ $hasStarbucksCoupon = false
    └─ 스타벅스 weight를 50P에 합산 (동적 확률 조정)
```

### 쿠폰 보충 방법

관리자 위젯에서 `func('create_event_coupon', {...})`으로 새 쿠폰을 등록하면 된다.
**DB에 INSERT하면 자동으로 다음 스핀부터 스타벅스 당첨 가능**.

---

## 클라이언트 연동

### Flutter 앱 연동 방법

#### 1. onSpinRequested 콜백 구현

```dart
// EventEntryScreen에서 SpinningWheel 위젯에 전달
SpinningWheel(
  sections: _sections,
  onSpinRequested: () async {
    // v7 API 호출
    final result = await v7api('event.spin');

    // 결과 저장 (결과 UI 표시용)
    _lastSpinResult = result;

    // section_index 반환 → 원판이 해당 섹션에 정렬
    return result['section_index'] as int;
  },
  onResult: (section) {
    // 원판 회전 완료 후 결과 UI 표시
    _showResultDialog(_lastSpinResult);
  },
  resultBuilder: (section) {
    // 결과 배너 위젯
    return _buildResultBanner(_lastSpinResult);
  },
  // ...
);
```

#### 2. 섹션 정의 (10개 섹션, weight 합계 1000)

```dart
/// 원판 섹션 정의 (10개 섹션, 총 weight = 1000 → 확률 0.1% 단위)
_sections = [
  WheelSection(label: '50',    color: Color(0xFFE88B8B), points: 50,   weight: 379),   // index 0
  WheelSection(label: '100',   color: Color(0xFFE8A87C), points: 100,  weight: 80),    // index 1
  WheelSection(label: '200',   color: Color(0xFFF5B971), points: 200,  weight: 70),    // index 2
  WheelSection(label: '300',   color: Color(0xFFD4A76A), points: 300,  weight: 60),    // index 3
  WheelSection(label: '400',   color: Color(0xFFD4B896), points: 400,  weight: 50),    // index 4
  WheelSection(label: '500',   color: Color(0xFFE8C170), points: 500,  weight: 40),    // index 5
  WheelSection(label: '1,000', color: Color(0xFFC9A9C9), points: 1000, weight: 15,     // index 6
    icon: FontAwesomeIcons.solidStar),
  WheelSection(label: '2,000', color: Color(0xFF9CC2D8), points: 2000, weight: 4,      // index 7
    icon: FontAwesomeIcons.solidStar, iconCount: 2),
  WheelSection(label: l10n.spinWheelCoupon, color: Color(0xFF8BC78B), points: -1, weight: 2,  // index 8
    icon: FontAwesomeIcons.lightMugHot),
  WheelSection(label: l10n.spinWheelMiss, color: Color(0xFFB0B0B0), points: 0, weight: 300), // index 9
];
```

> **참고**: 클라이언트의 `weight`는 원판에서 섹션이 차지하는 **시각적 크기**와 **실제 확률**을 동시에 결정한다.
> 서버와 클라이언트가 **동일한 weight 테이블**을 사용하여 확률이 일치한다.
> 스타벅스 쿠폰이 소진되어도 클라이언트 원판에는 여전히 스타벅스 섹션이 표시된다.
> (단, 서버에서 절대 해당 section_index=8을 반환하지 않으므로 당첨되지 않음)

#### 3. 서버/클라이언트 section_index 매핑

| section_index | 섹션 | 포인트 | Weight | 확률 |
|:------------:|------|:------:|:------:|:----:|
| 0 | 50P | 50 | 379 | 37.9% |
| 1 | 100P | 100 | 80 | 8.0% |
| 2 | 200P | 200 | 70 | 7.0% |
| 3 | 300P | 300 | 60 | 6.0% |
| 4 | 400P | 400 | 50 | 5.0% |
| 5 | 500P | 500 | 40 | 4.0% |
| 6 | 1,000P | 1,000 | 15 | 1.5% |
| 7 | 2,000P | 2,000 | 4 | 0.4% |
| 8 | 스타벅스 쿠폰 | -1 | 2 | 0.2% |
| 9 | 꽝 | 0 | 300 | 30.0% |

> 서버와 클라이언트가 동일한 weight 기반 확률을 사용한다.

#### 4. 에러 처리

```dart
onSpinRequested: () async {
  try {
    final result = await v7api('event.spin');
    if (result['success'] == false) {
      // 포인트 부족 등 에러 → 사용자에게 알림
      _showErrorSnackBar(result['message']);
      return null; // 회전 취소
    }
    _lastSpinResult = result;
    return result['section_index'] as int;
  } catch (e) {
    _showErrorSnackBar('네트워크 오류가 발생했습니다.');
    return null; // 회전 취소
  }
},
```

---

## 파일 구조

### 서버 (PHP v7)

```
lib/event/
├── EventController.php        ← Philgo\Event\EventController
│   ├── spin(array $input)     ← event.spin API
│   └── history(array $input)  ← event.history API
│
├── EventService.php           ← Philgo\Event\EventService
│   ├── spin(array $user)                 ← 메인 비즈니스 로직
│   ├── calculateSpinResult(bool $has)    ← 확률 계산 (쿠폰 유무 반영)
│   ├── getSections()                      ← 10개 섹션 가중치 테이블
│   └── getHistory(...)                    ← 기록 조회
│
├── EventCouponService.php     ← Philgo\Event\EventCouponService
│   ├── hasAvailableCoupon(string $type)          ← 사용 가능 쿠폰 존재 여부
│   ├── getAvailableCount(string $type)           ← 사용 가능 쿠폰 수
│   └── assignCouponToWinner(string $type, ...)   ← SELECT...FOR UPDATE 배정
│
├── EventCouponRepository.php  ← Philgo\Event\EventCouponRepository
│   ├── lockAndPickAvailable(string $type)        ← SELECT...FOR UPDATE
│   ├── assignToWinner(int $idx, int $winner, ...) ← UPDATE status='won'
│   ├── findByWinner(int $idx, int $page, int $limit) ← 당첨자 쿠폰 목록
│   └── countByStatus(string $type, string $status)
│
└── EventRepository.php        ← Philgo\Event\EventRepository
    ├── getMember(int $idx)
    ├── insertSpinHistory(array $data)
    └── getSpinHistory(int $idxMember, int $page, int $limit)
```

### composer.json PSR-4 매핑 추가

```json
{
  "autoload": {
    "psr-4": {
      "Philgo\\Event\\": "lib/event/"
    }
  }
}
```

### Flutter 클라이언트 (수정 대상)

```
lib/screens/event/
└── event_entry.screen.dart    ← onSpinRequested 콜백에 v7api('event.spin') 연동
```

---

## 테스트 계획

### 1. PEST Unit Test

**파일**: `tests/Unit/EventControllerTest.php`

| 테스트 케이스 | 설명 |
|-------------|------|
| 확률 분포 검증 (쿠폰 있음) | 10만 회 시뮬레이션 → 10개 섹션 확률 분포 확인, 스타벅스 0.2% 포함 |
| 확률 분포 검증 (쿠폰 없음) | 10만 회 시뮬레이션 → 스타벅스 0% 확인, 50P 38.1% 확인 |
| 포인트 차감 정확성 | 게임 전후 포인트 차이 = -200 + reward |
| 잔액 부족 에러 | 199P 보유 시 에러 발생 확인 |
| 쿠폰 사용 가능 확인 | event_coupons에서 status='available' 조회 |
| 쿠폰 당첨 시 배정 | EventCouponService::assignCouponToWinner() → SELECT...FOR UPDATE |
| 쿠폰 소진 시 당첨 불가 | 모든 쿠폰 소진 → 스타벅스 당첨 확률 0% |
| race condition 방어 | SELECT...FOR UPDATE로 동시 배정 방지 |
| 트랜잭션 원자성 | 중간 에러 시 롤백 확인 |
| 이벤트 기록 저장 | event_spin_history INSERT 확인 |
| sf_point_log 기록 | 차감 + 충전 로그 확인 |
| 미인증 에러 | 로그인 없이 호출 시 에러 |
| event.history | 페이지네이션 동작 확인 |
| 쿠폰 추가 후 활성화 | event_coupons에 INSERT → 즉시 사용 가능 확인 |

### 2. REST Client 테스트

**파일**: `.claude/skills/v7-skill/rest-client/event-spin-test.http`

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

### 1. 안티치트

| 위협 | 방어 |
|------|------|
| 클라이언트 확률 조작 | 서버에서 100% 결과 결정, 클라이언트는 section_index만 수신 |
| 네트워크 패킷 변조 | HTTPS 통신 + Firebase ID Token 인증 |
| 반복 요청 (자동화) | 200P 차감으로 무한 시도 방지, 필요 시 일일 횟수 제한 추가 |
| 응답 변조 | 결과가 이미 서버에 기록됨, 클라이언트 변조 무의미 |
| 쿠폰 이미지 접근 | uploads 테이블 기반 — v7 Upload API로 관리 |

### 2. 트랜잭션 안전성

- 포인트 차감 → 확률 계산 → 보상 지급 → 기록 저장을 **단일 트랜잭션**으로 처리
- 중간에 실패하면 전체 롤백
- `sf_member.point` UPDATE 시 `point = point - 200` 형태로 원자적 연산

### 3. 감사 추적

- `event_spin_history.random_value`: 확률 계산에 사용된 랜덤 값 저장 → 사후 검증 가능
- `event_coupons`: 쿠폰 배정 이력 (status, idx_winner, won_at, idx_spin_history)
- `event_spin_history.ip`: 접속 IP 기록
- `sf_point_log`: 모든 포인트 변동 기록

### 4. 쿠폰 보안

- 쿠폰 이미지는 uploads 테이블 기반으로 v7 Upload API로 관리
- 당첨 쿠폰 정보는 `event.myCoupons` API로 당첨자에게만 제공

---

## 향후 확장 방향

| 항목 | 현재 | 확장 방향 |
|------|------|----------|
| 일일 횟수 제한 | 없음 (포인트 잔액으로만 제한) | 일일 N회 제한 추가 |
| 확률 동적 변경 | 코드에 하드코딩 | DB 테이블로 확률 관리 (관리자 페이지에서 변경) |
| 이벤트 기간 | 상시 | 시작/종료일 설정 |
| 보상 종류 | 포인트 + 스타벅스 | 다양한 쿠폰/상품 추가 (폴더별 관리) |
| 통계 대시보드 | 없음 | 관리자용 통계 페이지 (일별 게임 횟수, 포인트 지출/수입, 당첨 분포) |
| Auto Spin 서버 제한 | 없음 | 연속 돌리기 시 서버 부하 제한 (최소 간격 1초) |
| 쿠폰 관리 UI | ✅ 구현 완료 | 관리자 위젯에서 쿠폰 등록/삭제/전송 관리 |

---

## 관련 문서

| 문서 | 내용 |
|------|------|
| [v7-event-entry.md](../references/app/v7-event-entry.md) | 클라이언트 스피닝 휠 위젯 아키텍처 |
| [v7-point-event.md](../references/api/v7-point-event.md) | 기존 먹방 이벤트 API (참고용) |
| [v7-upload.md](../references/api/v7-upload.md) | 파일 업로드 API (참고용) |
| [v7-architecture.md](../references/v7-architecture.md) | v7 시스템 아키텍처 |
| [point-event-pland.md](point-event-pland.md) | 포인트 이벤트 전체 계획 |
| [philgo.sql](../database/philgo.sql) | DB 스키마 |
