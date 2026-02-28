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
  → 서버: 사용 가능한 스타벅스 쿠폰 수 확인 (폴더 파일 vs DB 기록 비교)
  → 서버: 200P 차감
  → 서버: 확률 기반 결과 결정 (쿠폰 없으면 스타벅스 확률 0%)
  → 서버: 당첨 포인트 충전 (0, 50, 500, 1000, 2000)
  → 서버: 스타벅스 당첨 시 쿠폰 파일명을 DB에 기록
  → 서버: DB에 이벤트 기록 저장
  → 서버: 클라이언트에 결과(section_index, points, prize_type) 응답
  → 클라이언트: section_index에 맞춰 원판 회전 애니메이션
```

### 스타벅스 쿠폰 관리 핵심 원칙

> **쿠폰 파일은 서버의 `event/cupon/starbucks/` 폴더에 직접 저장**된다.
> uploads 테이블은 사용하지 않는다.
> 사용 가능한 쿠폰 = 폴더의 전체 파일 - event_spin_history에 이미 기록된 파일.
> 사용 가능한 쿠폰이 **0개이면 스타벅스 당첨 확률은 자동으로 0%**가 된다.

---

## COT (Chain-of-Thought) 분석

### 1단계: 문제의 핵심 이해

**문제**: 스피닝 휠 이벤트에서 사용자가 포인트를 소비하여 게임을 하고, 확률에 따라 보상을 받는 시스템.

**핵심 요구사항**:
- 200P를 차감하고 게임 진행
- 서버에서 확률적으로 결과를 미리 결정 (안티치트)
- 당첨 시 포인트 자동 충전
- 스타벅스 쿠폰 당첨 시 쿠폰 파일명을 DB에 기록 (사용 처리)
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
| 확률 계산 | `random_int(1, 10000)` 사용, 만분율 기반 정밀 확률 |
| 포인트 차감 | sf_member.point UPDATE + sf_point_log INSERT |
| 포인트 충전 | sf_member.point UPDATE + sf_point_log INSERT |
| 스타벅스 쿠폰 | `event/cupon/starbucks/` 폴더 파일 스캔 → event_spin_history와 비교 → 미사용 쿠폰 선별 |
| 쿠폰 소진 | 사용 가능 쿠폰 0개 → 스타벅스 확률 0%로 변경 (50P 확률에 0.1% 합산) |
| 기록 저장 | event_spin_history 신규 테이블에 INSERT (쿠폰 파일명 포함) |
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

**만분율(10,000 기준) 확률 매핑** — 스타벅스 쿠폰 유무에 따라 동적 변경:

```php
// ◆ 스타벅스 쿠폰이 있을 때 (기본 확률)
$rand = random_int(1, 10000);

if ($rand <= 3300)      → 꽝 (33.00%)        → section_index = 5, points = 0
else if ($rand <= 8390) → 50P (50.90%)       → section_index = 0, points = 50
else if ($rand <= 9390) → 500P (10.00%)      → section_index = 1, points = 500
else if ($rand <= 9890) → 1,000P (5.00%)     → section_index = 2, points = 1000
else if ($rand <= 9990) → 2,000P (1.00%)     → section_index = 3, points = 2000
else                    → 스타벅스 (0.10%)    → section_index = 4, points = 0

// ◆ 스타벅스 쿠폰이 없을 때 (스타벅스 0%, 50P에 합산)
$rand = random_int(1, 10000);

if ($rand <= 3300)      → 꽝 (33.00%)        → section_index = 5, points = 0
else if ($rand <= 8400) → 50P (51.00%)       → section_index = 0, points = 50  ← +0.10%
else if ($rand <= 9400) → 500P (10.00%)      → section_index = 1, points = 500
else if ($rand <= 9900) → 1,000P (5.00%)     → section_index = 2, points = 1000
else                    → 2,000P (1.00%)     → section_index = 3, points = 2000
```

### 5단계: 테스트 전략

- PEST Unit Test로 확률 분포 검증 (10만 회 시뮬레이션)
- 포인트 차감/충전 정확성 검증
- 스타벅스 쿠폰 파일 스캔 → 미사용 쿠폰 선별 로직 검증
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
│  ├─ [P2-1] 만분율 기반 확률 매핑
│  ├─ [P2-2] random_int() CSPRNG 사용
│  ├─ [P2-3] section_index ↔ 확률 매핑 테이블
│  └─ [P2-4] ★ 스타벅스 쿠폰 유무에 따른 동적 확률 전환
│
├─ [P3] 포인트 처리
│  ├─ [P3-1] 200P 차감 (잔액 확인 → UPDATE → LOG)
│  ├─ [P3-2] 당첨 포인트 충전 (UPDATE → LOG)
│  └─ [P3-3] 트랜잭션 원자성 보장
│
├─ [P4] 스타벅스 쿠폰 관리 (파일 시스템 기반)
│  ├─ [P4-1] event/cupon/starbucks/ 폴더에서 *.jpg 파일 목록 스캔
│  ├─ [P4-2] event_spin_history에서 이미 사용된 쿠폰 파일명 조회
│  ├─ [P4-3] 사용 가능 쿠폰 = 폴더 파일 - DB 기록 파일
│  ├─ [P4-4] 쿠폰 0개 → 스타벅스 확률 0%로 전환
│  └─ [P4-5] 당첨 시 쿠폰 파일명을 event_spin_history에 기록
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
| P1-1 | CREATE TABLE event_spin_history (starbucks_coupon_file VARCHAR 포함) | 낮음 |
| P2-1 | random_int(1, 10000) 기반 구간 매핑 | 중간 |
| P2-4 | 쿠폰 유무 판단 후 확률 테이블 분기 | 중간 |
| P3-1 | BEGIN TRANSACTION → SELECT point → UPDATE → COMMIT | 높음 |
| P3-3 | PDO transaction으로 원자성 보장 | 중간 |
| P4-1 | `glob('event/cupon/starbucks/*.jpg')` + `*.png` 파일 스캔 | 낮음 |
| P4-2 | SELECT starbucks_coupon_file FROM event_spin_history WHERE starbucks_coupon_file IS NOT NULL | 낮음 |
| P4-3 | array_diff(폴더 파일, DB 기록) | 낮음 |
| P4-4 | 사용 가능 쿠폰 0개 → $hasStarbucks = false → 확률 테이블 변경 | 낮음 |
| P5-1 | EventController::spin($input) | 중간 |
| P7-1 | JSON: {section_index, points, prize_type, ...} | 낮음 |

### 통합 및 검증

- P4(쿠폰 확인) → P2(확률 결정) → P3(포인트 처리) → P1(기록 저장): 순차 실행
- P4(쿠폰 유무) + P2(확률) → 쿠폰 없으면 스타벅스 확률 0%로 동적 전환
- P5(API) + P7(클라이언트) → section_index 기반 연동
- P1(DB) + P6(모듈) → Repository에서 DB 접근

---

## 확률 시스템

### 기본 확률 분포표 (스타벅스 쿠폰 있을 때)

| 섹션 | section_index | 당첨 포인트 | 확률 | 만분율 범위 |
|------|:------------:|:-----------:|:----:|:-----------:|
| 50P | 0 | +50P | **50.9%** | 3,301 ~ 8,390 |
| 500P | 1 | +500P | **10.0%** | 8,391 ~ 9,390 |
| 1,000P | 2 | +1,000P | **5.0%** | 9,391 ~ 9,890 |
| 2,000P | 3 | +2,000P | **1.0%** | 9,891 ~ 9,990 |
| 스타벅스 쿠폰 | 4 | 쿠폰 전송 | **0.1%** | 9,991 ~ 10,000 |
| 꽝 | 5 | 0P | **33.0%** | 1 ~ 3,300 |
| **합계** | | | **100.0%** | **10,000** |

### 쿠폰 소진 시 확률 분포표 (스타벅스 쿠폰 없을 때)

> 스타벅스 0.1%를 50P에 합산 → 50P가 50.9% → **51.0%**로 변경

| 섹션 | section_index | 당첨 포인트 | 확률 | 만분율 범위 |
|------|:------------:|:-----------:|:----:|:-----------:|
| 50P | 0 | +50P | **51.0%** | 3,301 ~ 8,400 |
| 500P | 1 | +500P | **10.0%** | 8,401 ~ 9,400 |
| 1,000P | 2 | +1,000P | **5.0%** | 9,401 ~ 9,900 |
| 2,000P | 3 | +2,000P | **1.0%** | 9,901 ~ 10,000 |
| ~~스타벅스 쿠폰~~ | ~~4~~ | ~~쿠폰~~ | **0.0%** | *(제외)* |
| 꽝 | 5 | 0P | **33.0%** | 1 ~ 3,300 |
| **합계** | | | **100.0%** | **10,000** |

### 손익 분석 (1회 게임 기준)

| 항목 | 계산 |
|------|------|
| **비용** | -200P (게임 참가비) |
| **기대 수익** | 50 × 0.509 + 500 × 0.10 + 1000 × 0.05 + 2000 × 0.01 + 0 × 0.33 = **145.45P** |
| **기대 순손실** | 200 - 145.45 = **-54.55P** |

> 사용자는 평균적으로 1회 게임당 약 54.55P를 잃는다. 이는 게임의 지속 가능성을 보장한다.

### 확률 계산 알고리즘 (PHP)

```php
/**
 * 스피닝 휠 확률 계산
 *
 * 사용 가능한 스타벅스 쿠폰 유무에 따라 확률 테이블을 동적으로 변경한다.
 * - 쿠폰 있음: 스타벅스 0.1% 포함
 * - 쿠폰 없음: 스타벅스 0%, 해당 확률을 50P에 합산
 *
 * @param bool $hasStarbucksCoupon 사용 가능한 스타벅스 쿠폰 존재 여부
 * @return array ['section_index' => int, 'points' => int, 'prize_type' => string, 'random_value' => int]
 */
public static function calculateSpinResult(bool $hasStarbucksCoupon): array
{
    $rand = random_int(1, 10000); // CSPRNG 사용

    if ($hasStarbucksCoupon) {
        // ◆ 스타벅스 쿠폰이 있을 때 (기본 확률)
        $prizes = [
            ['max' => 3300,  'section_index' => 5, 'points' => 0,    'prize_type' => 'miss'],
            ['max' => 8390,  'section_index' => 0, 'points' => 50,   'prize_type' => 'point'],
            ['max' => 9390,  'section_index' => 1, 'points' => 500,  'prize_type' => 'point'],
            ['max' => 9890,  'section_index' => 2, 'points' => 1000, 'prize_type' => 'point'],
            ['max' => 9990,  'section_index' => 3, 'points' => 2000, 'prize_type' => 'point'],
            ['max' => 10000, 'section_index' => 4, 'points' => 0,    'prize_type' => 'starbucks'],
        ];
    } else {
        // ◆ 스타벅스 쿠폰이 없을 때 (스타벅스 0%, 50P에 합산)
        $prizes = [
            ['max' => 3300,  'section_index' => 5, 'points' => 0,    'prize_type' => 'miss'],
            ['max' => 8400,  'section_index' => 0, 'points' => 50,   'prize_type' => 'point'],
            ['max' => 9400,  'section_index' => 1, 'points' => 500,  'prize_type' => 'point'],
            ['max' => 9900,  'section_index' => 2, 'points' => 1000, 'prize_type' => 'point'],
            ['max' => 10000, 'section_index' => 3, 'points' => 2000, 'prize_type' => 'point'],
            // 스타벅스 항목 없음
        ];
    }

    foreach ($prizes as $prize) {
        if ($rand <= $prize['max']) {
            $prize['random_value'] = $rand;
            return $prize;
        }
    }

    // 폴백 (도달할 수 없음)
    return ['section_index' => 5, 'points' => 0, 'prize_type' => 'miss', 'random_value' => $rand];
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
  ├─ [3] ★ 사용 가능한 스타벅스 쿠폰 확인
  │  ├─ [3-1] 폴더 파일 스캔: glob('event/cupon/starbucks/*.{jpg,png}')
  │  │  └─ 파일명만 추출 (예: ['2.jpg', '3.jpg', '4.jpg', 'KakaoTalk_Photo_...png'])
  │  ├─ [3-2] DB에서 이미 사용된 파일명 조회
  │  │  └─ SELECT starbucks_coupon_file FROM event_spin_history
  │  │     WHERE starbucks_coupon_file IS NOT NULL
  │  ├─ [3-3] 사용 가능 쿠폰 = 폴더 파일 - DB 기록
  │  │  └─ array_diff($folderFiles, $usedFiles)
  │  └─ [3-4] $hasStarbucksCoupon = count($available) > 0
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
  │  ├─ prize_type == 'point' (50, 500, 1000, 2000P)
  │  │  ├─ UPDATE sf_member SET point = point + ? WHERE idx = ?
  │  │  └─ INSERT INTO sf_point_log (충전 기록)
  │  │     └─ module='event', action='spin_reward', point=+N
  │  │
  │  ├─ prize_type == 'starbucks'
  │  │  ├─ 사용 가능 쿠폰에서 첫 번째 파일 선택
  │  │  └─ 쿠폰 파일명을 event_spin_history.starbucks_coupon_file에 기록
  │  │     → 이 쿠폰은 더 이상 사용 불가 (다음 스핀에서 제외됨)
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
          starbucks_coupon_file: null,
          starbucks_coupon_url: null,
          available_coupons: 3,
          spin_idx: 456
        }
```

---

## 데이터베이스 설계

### 1. 신규 테이블: event_spin_history

스피닝 휠 이벤트의 **모든 게임 기록**을 저장한다.
스타벅스 쿠폰 당첨 시 **쿠폰 파일명**을 함께 기록하여 쿠폰 사용 여부를 추적한다.

```sql
CREATE TABLE `event_spin_history` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL COMMENT '게임한 회원 번호 (sf_member.idx)',
  `section_index` tinyint(3) UNSIGNED NOT NULL COMMENT '당첨 섹션 인덱스 (0~5)',
  `prize_type` varchar(16) NOT NULL COMMENT '보상 유형: miss | point | starbucks',
  `points_cost` int(10) UNSIGNED NOT NULL DEFAULT 200 COMMENT '차감된 포인트 (참가비)',
  `points_reward` int(10) NOT NULL DEFAULT 0 COMMENT '획득 포인트 (0=꽝, 50/500/1000/2000)',
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
| `section_index` | TINYINT | 원판 섹션 인덱스 (0=50P, 1=500P, 2=1000P, 3=2000P, 4=스타벅스, 5=꽝) |
| `prize_type` | VARCHAR(16) | `miss` / `point` / `starbucks` |
| `points_cost` | INT | 차감 포인트 (기본 200) |
| `points_reward` | INT | 획득 포인트 (꽝=0, 스타벅스=0) |
| `starbucks_coupon_file` | VARCHAR(255) NULL | ★ 스타벅스 쿠폰 파일명 (예: `2.jpg`, `KakaoTalk_Photo_...png`) |
| `random_value` | INT | 확률 계산 랜덤 값 (감사 추적용) |
| `point_before` | INT | 게임 전 잔액 |
| `point_after` | INT | 게임 후 잔액 |
| `created_at` | INT | Unix timestamp |
| `ip` | VARCHAR(45) | 접속 IP |

### 스타벅스 쿠폰 사용 추적 원리

```
event/cupon/starbucks/ 폴더:
  ├── 2.jpg                          ← 파일 존재
  ├── 3.jpg                          ← 파일 존재
  ├── 4.jpg                          ← 파일 존재
  └── KakaoTalk_Photo_...png         ← 파일 존재

event_spin_history 테이블:
  idx=1, starbucks_coupon_file='2.jpg'           ← 이미 사용됨
  idx=2, starbucks_coupon_file=NULL              ← 포인트 당첨 (관계없음)
  idx=3, starbucks_coupon_file='3.jpg'           ← 이미 사용됨

사용 가능 쿠폰 = {'2.jpg','3.jpg','4.jpg','KakaoTalk_...'} - {'2.jpg','3.jpg'}
             = {'4.jpg', 'KakaoTalk_Photo_...png'}  ← 2개 사용 가능
```

### 2. uploads 테이블 변경 — ⚠️ 불필요 (삭제됨)

> ~~기존 계획의 uploads.attached → attached_to 변경은 불필요합니다.~~
> 스타벅스 쿠폰은 uploads 테이블을 사용하지 않고,
> **파일 시스템(`event/cupon/starbucks/`)과 event_spin_history 테이블**로 관리합니다.

### 3. sf_point_log 기록 규칙

| 상황 | module | action | point | etc |
|------|--------|--------|-------|-----|
| 게임 참가비 차감 | `event` | `spin_cost` | -200 | `spin_cost` |
| 50P 당첨 | `event` | `spin_reward` | +50 | `spin_reward_50` |
| 500P 당첨 | `event` | `spin_reward` | +500 | `spin_reward_500` |
| 1,000P 당첨 | `event` | `spin_reward` | +1000 | `spin_reward_1000` |
| 2,000P 당첨 | `event` | `spin_reward` | +2000 | `spin_reward_2000` |
| 스타벅스 당첨 | `event` | `spin_reward` | 0 | `spin_reward_starbucks:{파일명}` |
| 꽝 | *(충전 기록 없음)* | | | |

> 꽝인 경우 포인트 변동이 없으므로 sf_point_log에 충전 기록을 남기지 않는다.
> 단, 참가비 차감 기록(spin_cost)은 항상 남긴다.
> 스타벅스 당첨 시 etc에 파일명을 함께 기록하여 추적 가능하게 한다.
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
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 2,
  "spin_idx": 456
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `success` | bool | 성공 여부 |
| `section_index` | int | 원판 섹션 인덱스 (0~5) |
| `points` | int | 당첨 포인트 (0=꽝) |
| `prize_type` | string | `miss` / `point` / `starbucks` |
| `current_point` | int | 게임 후 잔여 포인트 |
| `starbucks_coupon_file` | string\|null | 스타벅스 쿠폰 파일명 (당첨 시만) |
| `starbucks_coupon_url` | string\|null | 스타벅스 쿠폰 이미지 URL (당첨 시만) |
| `available_coupons` | int | 남은 사용 가능 쿠폰 수 |
| `spin_idx` | int | event_spin_history.idx (기록 번호) |

#### 스타벅스 당첨 응답 예시

```json
{
  "success": true,
  "section_index": 4,
  "points": 0,
  "prize_type": "starbucks",
  "current_point": 13800,
  "starbucks_coupon_file": "4.jpg",
  "starbucks_coupon_url": "/event/cupon/starbucks/4.jpg",
  "available_coupons": 1,
  "spin_idx": 457
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
      "section_index": 4,
      "prize_type": "starbucks",
      "points_cost": 200,
      "points_reward": 0,
      "starbucks_coupon_file": "4.jpg",
      "starbucks_coupon_url": "/event/cupon/starbucks/4.jpg",
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
      "starbucks_coupon_url": null,
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
 * 2. 사용 가능한 스타벅스 쿠폰 확인 (폴더 파일 vs DB 비교)
 * 3. 200P 차감
 * 4. 확률 계산 → 결과 결정 (쿠폰 유무에 따라 동적 확률)
 * 5. 보상 처리 (포인트 충전 / 스타벅스 쿠폰 기록)
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

    // [2] ★ 사용 가능한 스타벅스 쿠폰 확인
    $availableCoupons = self::getAvailableStarbucksCoupons();
    $hasStarbucksCoupon = count($availableCoupons) > 0;

    // [3] 트랜잭션 시작
    $pdo->beginTransaction();

    try {
        // [4] 200P 차감
        $pointAfterCost = $currentPoint - 200;
        EventRepository::updateMemberPoint($idxMember, $pointAfterCost);
        EventRepository::insertPointLog([
            'idx_member_from' => $idxMember,
            'idx_member_to' => $idxMember,
            'point_before' => $currentPoint,
            'point' => -200,
            'point_after' => $pointAfterCost,
            'module' => 'event',
            'action' => 'spin_cost',
            'etc' => 'spin_cost',
        ]);

        // [5] ★ 확률 계산 (쿠폰 유무에 따라 동적 확률)
        $result = self::calculateSpinResult($hasStarbucksCoupon);
        $sectionIndex = $result['section_index'];
        $prizeType = $result['prize_type'];
        $rewardPoints = $result['points'];
        $randomValue = $result['random_value'];

        // [6] 보상 처리
        $starbucksCouponFile = null;
        $starbucksCouponUrl = null;
        $finalPoint = $pointAfterCost;

        if ($prizeType === 'point' && $rewardPoints > 0) {
            // 포인트 당첨
            $finalPoint = $pointAfterCost + $rewardPoints;
            EventRepository::updateMemberPoint($idxMember, $finalPoint);
            EventRepository::insertPointLog([
                'idx_member_from' => 0,
                'idx_member_to' => $idxMember,
                'point_before' => $pointAfterCost,
                'point' => $rewardPoints,
                'point_after' => $finalPoint,
                'module' => 'event',
                'action' => 'spin_reward',
                'etc' => "spin_reward_{$rewardPoints}",
            ]);

        } elseif ($prizeType === 'starbucks') {
            // ★ 스타벅스 쿠폰 당첨 → 사용 가능 쿠폰에서 첫 번째 선택
            $starbucksCouponFile = $availableCoupons[0]; // 첫 번째 사용 가능 쿠폰
            $starbucksCouponUrl = '/event/cupon/starbucks/' . $starbucksCouponFile;

            // sf_point_log 기록 (포인트 변동 없음, 기록용)
            EventRepository::insertPointLog([
                'idx_member_from' => 0,
                'idx_member_to' => $idxMember,
                'point_before' => $pointAfterCost,
                'point' => 0,
                'point_after' => $pointAfterCost,
                'module' => 'event',
                'action' => 'spin_reward',
                'etc' => "spin_reward_starbucks:{$starbucksCouponFile}",
            ]);
            $finalPoint = $pointAfterCost;
        }
        // prize_type == 'miss' → 보상 없음

        // [7] 이벤트 기록 저장 (★ starbucks_coupon_file 포함)
        $spinIdx = EventRepository::insertSpinHistory([
            'idx_member' => $idxMember,
            'section_index' => $sectionIndex,
            'prize_type' => $prizeType,
            'points_cost' => 200,
            'points_reward' => $rewardPoints,
            'starbucks_coupon_file' => $starbucksCouponFile, // 쿠폰 파일명 or NULL
            'random_value' => $randomValue,
            'point_before' => $currentPoint,
            'point_after' => $finalPoint,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? '',
        ]);

        // [8] 커밋
        $pdo->commit();

        // 쿠폰이 사용되었으므로 남은 쿠폰 수 업데이트
        $remainingCoupons = $hasStarbucksCoupon
            ? count($availableCoupons) - ($starbucksCouponFile ? 1 : 0)
            : 0;

        // [9] 응답 반환
        return [
            'section_index' => $sectionIndex,
            'points' => $rewardPoints,
            'prize_type' => $prizeType,
            'current_point' => $finalPoint,
            'starbucks_coupon_file' => $starbucksCouponFile,
            'starbucks_coupon_url' => $starbucksCouponUrl,
            'available_coupons' => $remainingCoupons,
            'spin_idx' => $spinIdx,
        ];

    } catch (\Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}
```

---

## 스타벅스 쿠폰 관리 시스템

### 핵심 원칙

> **uploads 테이블을 사용하지 않는다.**
> 쿠폰 파일은 `event/cupon/starbucks/` 폴더에 직접 저장되며,
> `event_spin_history.starbucks_coupon_file` 컬럼으로 사용 여부를 추적한다.

### 쿠폰 파일 저장 위치

```
www/event/cupon/starbucks/
├── index.php                          ← 디렉토리 접근 차단용
├── 2.jpg                              ← 스타벅스 쿠폰 이미지
├── 3.jpg                              ← 스타벅스 쿠폰 이미지
├── 4.jpg                              ← 스타벅스 쿠폰 이미지
└── KakaoTalk_Photo_2026-02-28-22-10-33.png  ← 스타벅스 쿠폰 이미지
```

> 관리자가 이 폴더에 쿠폰 이미지를 직접 업로드(복사)하면 자동으로 이벤트에 사용된다.
> 파일명은 랜덤하게 지정되며, 확장자는 `.jpg` 또는 `.png`이다.

### 사용 가능 쿠폰 조회 알고리즘

```php
/**
 * 사용 가능한 스타벅스 쿠폰 파일 목록 반환
 *
 * 1. event/cupon/starbucks/ 폴더에서 이미지 파일 스캔
 * 2. event_spin_history에서 이미 사용된 쿠폰 파일명 조회
 * 3. 차집합 = 사용 가능 쿠폰
 *
 * @return array 사용 가능한 쿠폰 파일명 배열 (예: ['4.jpg', 'KakaoTalk_...png'])
 */
public static function getAvailableStarbucksCoupons(): array
{
    // [1] 폴더에서 이미지 파일 스캔 (index.php 제외)
    $couponDir = ROOT_DIR . '/event/cupon/starbucks/';
    $allFiles = [];

    // jpg, jpeg, png 확장자 파일만 수집
    foreach (['*.jpg', '*.jpeg', '*.png'] as $pattern) {
        $matched = glob($couponDir . $pattern);
        if ($matched) {
            foreach ($matched as $filePath) {
                $allFiles[] = basename($filePath);
            }
        }
    }

    if (empty($allFiles)) {
        return []; // 폴더에 쿠폰 파일 없음
    }

    // [2] DB에서 이미 사용된 쿠폰 파일명 조회
    $usedFiles = EventRepository::getUsedStarbucksCouponFiles();

    // [3] 차집합 = 사용 가능 쿠폰
    $available = array_values(array_diff($allFiles, $usedFiles));

    return $available;
}
```

### EventRepository 쿠폰 관련 메서드

```php
/**
 * 이미 사용된 스타벅스 쿠폰 파일명 목록 조회
 *
 * @return array 사용된 파일명 배열 (예: ['2.jpg', '3.jpg'])
 */
public static function getUsedStarbucksCouponFiles(): array
{
    $pdo = Db::pdo();
    $stmt = $pdo->prepare("
        SELECT starbucks_coupon_file
        FROM event_spin_history
        WHERE starbucks_coupon_file IS NOT NULL
          AND starbucks_coupon_file != ''
    ");
    $stmt->execute();
    return $stmt->fetchAll(\PDO::FETCH_COLUMN);
}
```

### 쿠폰 라이프사이클

```
[1] 관리자가 쿠폰 파일 업로드
    └─ event/cupon/starbucks/new_coupon.jpg 저장

[2] 스핀 API 호출 시 사용 가능 쿠폰 확인
    ├─ 폴더 파일: ['2.jpg', '3.jpg', '4.jpg', 'new_coupon.jpg']
    ├─ DB 사용됨: ['2.jpg']
    └─ 사용 가능: ['3.jpg', '4.jpg', 'new_coupon.jpg'] → 3개

[3] 스타벅스 당첨 시
    └─ event_spin_history에 starbucks_coupon_file='3.jpg' 기록
    └─ 이제 3.jpg는 사용 불가

[4] 다음 스핀 API 호출 시
    ├─ DB 사용됨: ['2.jpg', '3.jpg']
    └─ 사용 가능: ['4.jpg', 'new_coupon.jpg'] → 2개

[5] 모든 쿠폰 소진 시
    ├─ 사용 가능: [] → 0개
    └─ $hasStarbucksCoupon = false
    └─ 스타벅스 확률 0% → 50P에 0.1% 합산
```

### 쿠폰 보충 방법

관리자가 새 쿠폰 이미지를 `event/cupon/starbucks/` 폴더에 복사하기만 하면 된다.
DB 작업 불필요. **파일만 추가하면 자동으로 다음 스핀부터 스타벅스 당첨 가능**.

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

#### 2. 섹션 정의 (기존과 동일)

```dart
_sections = [
  WheelSection(label: '50',    color: Color(0xFFE88B8B), points: 50,   weight: 30),   // index 0
  WheelSection(label: '500',   color: Color(0xFFF5B971), points: 500,  weight: 20),   // index 1
  WheelSection(label: '1,000', color: Color(0xFFC9A9C9), points: 1000, weight: 10),   // index 2
  WheelSection(label: '2,000', color: Color(0xFF9CC2D8), points: 2000, weight: 5),    // index 3
  WheelSection(label: '스타벅스 쿠폰', color: Color(0xFF8BC78B), points: -1, weight: 5), // index 4
  WheelSection(label: '꽝',    color: Color(0xFFB0B0B0), points: 0,    weight: 30),   // index 5
];
```

> **참고**: 클라이언트의 `weight`는 원판에서 섹션이 차지하는 **시각적 크기**만 결정한다.
> 실제 당첨 확률은 서버에서 100% 결정하므로, weight와 실제 확률은 의도적으로 다를 수 있다.
> 스타벅스 쿠폰이 소진되어도 클라이언트 원판에는 여전히 스타벅스 섹션이 표시된다.
> (단, 서버에서 절대 해당 section_index=4를 반환하지 않으므로 당첨되지 않음)

#### 3. 서버/클라이언트 확률 비교

| 섹션 | 서버 실제 확률 | 클라이언트 시각적 비중(weight) |
|------|:-------------:|:----------------------------:|
| 50P | 50.9% | 30 (33.3%) |
| 500P | 10.0% | 20 (22.2%) |
| 1,000P | 5.0% | 10 (11.1%) |
| 2,000P | 1.0% | 5 (5.6%) |
| 스타벅스 | 0.1% (쿠폰 있을 때) / 0% (쿠폰 없을 때) | 5 (5.6%) |
| 꽝 | 33.0% | 30 (33.3%) |

> 시각적으로는 모든 섹션이 적당한 크기로 보이지만, 실제 확률은 서버에서 별도로 관리된다.

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
│   ├── getAvailableStarbucksCoupons()    ← ★ 사용 가능 쿠폰 조회
│   └── getHistory(...)                    ← 기록 조회
│
└── EventRepository.php        ← Philgo\Event\EventRepository
    ├── getMember(int $idx)
    ├── updateMemberPoint(int $idx, int $point)
    ├── insertPointLog(array $data)
    ├── insertSpinHistory(array $data)
    ├── getSpinHistory(int $idxMember, int $page, int $limit)
    └── getUsedStarbucksCouponFiles()     ← ★ 사용된 쿠폰 파일명 조회
```

### 스타벅스 쿠폰 파일 (파일 시스템)

```
event/cupon/starbucks/
├── index.php                          ← 디렉토리 접근 차단
├── 2.jpg                              ← 쿠폰 이미지
├── 3.jpg                              ← 쿠폰 이미지
├── 4.jpg                              ← 쿠폰 이미지
└── KakaoTalk_Photo_2026-02-28-22-10-33.png
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
| 확률 분포 검증 (쿠폰 있음) | 10만 회 시뮬레이션 → 스타벅스 0.1% 포함 확인 |
| 확률 분포 검증 (쿠폰 없음) | 10만 회 시뮬레이션 → 스타벅스 0% 확인, 50P 51% 확인 |
| 포인트 차감 정확성 | 게임 전후 포인트 차이 = -200 + reward |
| 잔액 부족 에러 | 199P 보유 시 에러 발생 확인 |
| 쿠폰 사용 가능 확인 | 폴더 파일 - DB 기록 = 사용 가능 쿠폰 |
| 쿠폰 당첨 시 파일명 기록 | event_spin_history.starbucks_coupon_file에 파일명 저장 확인 |
| 쿠폰 소진 시 당첨 불가 | 모든 쿠폰 사용됨 → 스타벅스 당첨 확률 0% |
| 동일 쿠폰 중복 사용 불가 | 이미 사용된 쿠폰 파일명은 다시 사용 불가 |
| 트랜잭션 원자성 | 중간 에러 시 롤백 확인 |
| 이벤트 기록 저장 | event_spin_history INSERT 확인 |
| sf_point_log 기록 | 차감 + 충전 로그 확인 |
| 미인증 에러 | 로그인 없이 호출 시 에러 |
| event.history | 페이지네이션 동작 확인 |
| 쿠폰 추가 후 활성화 | 폴더에 새 파일 추가 → 즉시 사용 가능 확인 |

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
| 쿠폰 파일 직접 접근 | index.php로 디렉토리 접근 차단, Nginx에서 직접 접근 차단 권장 |

### 2. 트랜잭션 안전성

- 포인트 차감 → 확률 계산 → 보상 지급 → 기록 저장을 **단일 트랜잭션**으로 처리
- 중간에 실패하면 전체 롤백
- `sf_member.point` UPDATE 시 `point = point - 200` 형태로 원자적 연산

### 3. 감사 추적

- `event_spin_history.random_value`: 확률 계산에 사용된 랜덤 값 저장 → 사후 검증 가능
- `event_spin_history.starbucks_coupon_file`: 어떤 쿠폰 파일이 배분되었는지 추적
- `event_spin_history.ip`: 접속 IP 기록
- `sf_point_log`: 모든 포인트 변동 기록

### 4. 쿠폰 파일 보안

- `event/cupon/starbucks/index.php`: 디렉토리 접근 차단
- Nginx 설정에서 `event/cupon/starbucks/` 경로 직접 접근 차단 권장
- 쿠폰 URL은 스타벅스 당첨 사용자에게만 API 응답으로 전달

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
| 쿠폰 관리 UI | 파일 직접 복사 | 관리자 페이지에서 쿠폰 업로드/삭제/현황 확인 |

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
