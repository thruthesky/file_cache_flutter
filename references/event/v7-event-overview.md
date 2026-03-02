# 필고 v7 이벤트 시스템 통합 개요

> **📌 문서 목적**: 이 문서는 필고 v7의 **모든 포인트 이벤트 시스템을 하나로 통합 요약**한다.
> 스피닝 휠 이벤트, 업소록 QR 코드 삼단콤보(QR 스캔 → 재방문 보너스 → 후기 포인트),
> 포인트 로그 공통 인프라 등 **전체 이벤트 시스템의 전반적인 구조와 흐름**을 다루며,
> API 코드/로직 상세는 [v7-event.md](../api/v7-event.md)를 참조한다.

## 목차

- [1. 이벤트 시스템 전체 구조](#1-이벤트-시스템-전체-구조)
- [2. 스피닝 휠 이벤트 (서버)](#2-스피닝-휠-이벤트-서버)
- [3. 스피닝 휠 이벤트 (클라이언트 Flutter)](#3-스피닝-휠-이벤트-클라이언트-flutter)
- [4. 업소록 QR 코드 이벤트 (삼단콤보)](#4-업소록-qr-코드-이벤트-삼단콤보)
  - [4.9 업소록 이벤트 전체 흐름 (CoT 단계별 분석)](#49-업소록-이벤트-전체-흐름-cot-단계별-분석)
  - [4.10 분기별 사용자 경험 (ToT 트리 구조 분석)](#410-분기별-사용자-경험-tot-트리-구조-분석)
  - [4.11 API 메서드별 검증 로직 상세](#411-api-메서드별-검증-로직-상세)
  - [4.12 에러 시나리오 매트릭스](#412-에러-시나리오-매트릭스)
  - [4.13 웹 페이지 통합 흐름](#413-웹-페이지-통합-흐름)
- [5. 업소록 방문 후기 포인트 (삼단콤보 3단계)](#5-업소록-방문-후기-포인트-삼단콤보-3단계)
- [6. 포인트 로그 시스템 (공통 인프라)](#6-포인트-로그-시스템-공통-인프라)
- [7. DB 스키마 요약](#7-db-스키마-요약)
- [8. 파일 구조 및 참조 문서](#8-파일-구조-및-참조-문서)
- [9. 테스트 방법](#9-테스트-방법)
  - [9.1 QR 코드 스캔 테스트](#91-qr-코드-스캔-테스트)

---

## 1. 이벤트 시스템 전체 구조

필고의 포인트 이벤트는 크게 **3개 시스템**으로 구성된다:

```
┌─────────────────────────────────────────────────────────────┐
│                필고 포인트 이벤트 시스템                      │
├────────────────┬────────────────┬───────────────────────────┤
│  스피닝 휠     │  업소록 QR     │  포인트 로그              │
│  이벤트        │  이벤트        │  (공통 인프라)            │
│                │  (삼단콤보)    │                           │
├────────────────┼────────────────┼───────────────────────────┤
│ 200P 소비      │ 1단계: QR스캔  │ PointLogService           │
│ → 10개 섹션    │  1,000~2,000P  │ ::changePoints()          │
│ 가중치 확률    │ 2단계: 재방문  │                           │
│ 게임           │  2,000~3,000P  │ sf_point_log 테이블       │
│                │ 3단계: 후기    │ sf_member.point 업데이트   │
│ 서버 100%      │  2,000~3,000P  │                           │
│ 결과 선결정    │                │ 11개 API 엔드포인트       │
├────────────────┼────────────────┼───────────────────────────┤
│ event_spin_    │ company_qr_    │ sf_point_log              │
│ history        │ codes          │                           │
│                │ company_qr_    │                           │
│                │ code_usages    │                           │
│                │ company_reviews│                           │
│                │ uploads        │                           │
└────────────────┴────────────────┴───────────────────────────┘
```

### 이벤트 간 연결 흐름

```
사용자 업소 방문
  ↓
[1단계] QR 코드 스캔 → 1,000~2,000P 즉시 적립
  ↓                     (qr-code-scanned.php)
  ├─ 재방문자 → [2단계] 재방문 포인트 추첨 → 추가 2,000~3,000P
  │              (re-visit-point.php)
  │                ↓
  │              후기 CTA → [3단계] 후기 작성 → 추가 2,000~3,000P
  │                          (visit-review-point.php)
  │
  └─ 첫 방문자 → 후기 CTA → [3단계] 후기 작성 → 추가 2,000~3,000P
                              (visit-review-point.php)
  ↓
획득한 포인트로 스피닝 휠 이벤트 참여
  ↓
200P 소비 → 확률 게임 → 50P~2,000P 또는 스타벅스 쿠폰
```

**삼단콤보 최대 포인트**: 2,000 + 3,000 + 3,000 = **8,000P/회**

---

## 2. 스피닝 휠 이벤트 (서버)

### 2.1 핵심 개념

- **200P 소비** → 10개 섹션 가중치 기반 확률 게임
- **서버 100% 결과 선결정** → 클라이언트에 `section_index`만 전달 (안티치트)
- **Weight 합계 1000** = 0.1% 단위 정밀 확률 제어
- **CSPRNG**: `random_int(1, 1000)` 사용 (암호학적 난수)

### 2.2 10개 섹션 확률 분포

| index | 섹션 | 포인트 | Weight | 확률 | prize_type |
|:-----:|------|:------:|:------:|:----:|:----------:|
| 0 | 50P | +50 | 380 | 38.0% | `point` |
| 1 | 100P | +100 | 80 | 8.0% | `point` |
| 2 | 200P | +200 | 70 | 7.0% | `point` |
| 3 | 300P | +300 | 60 | 6.0% | `point` |
| 4 | 400P | +400 | 50 | 5.0% | `point` |
| 5 | 500P | +500 | 40 | 4.0% | `point` |
| 6 | 1,000P | +1,000 | 15 | 1.5% | `point` |
| 7 | 2,000P | +2,000 | 4 | 0.4% | `point` |
| 8 | 스타벅스 | -1 | 1 | 0.1% | `starbucks` |
| 9 | 꽝 | 0 | 300 | 30.0% | `miss` |

**쿠폰 소진 시**: 스타벅스 weight(1) → 50P에 합산 (380→381), 스타벅스 0%

**손익**: 1회 게임당 기대 순손실 **-78P** (기대 수익 122P - 비용 200P)

### 2.3 게임 처리 8단계

```
[1] 잔액 확인 (200P 이상 필수)
[2] 사용 가능 스타벅스 쿠폰 확인 (폴더 스캔 - DB 사용됨 = 차집합)
[3] BEGIN TRANSACTION
[4] 200P 차감 (sf_member + sf_point_log)
[5] 확률 계산 (random_int(1,1000) → 누적 weight 비교)
[6] 보상 처리 (point/starbucks/miss 분기)
[7] 이벤트 기록 저장 (event_spin_history)
[8] COMMIT (실패 시 ROLLBACK)
```

### 2.4 핵심 소스코드

**파일**: `lib/event/EventService.php`, `lib/event/EventRepository.php`, `lib/event/EventController.php`

#### 확률 계산 — EventService::calculateSpinResult()

```php
public static function calculateSpinResult(bool $hasStarbucksCoupon): array
{
    $sections = self::getSections(); // 10개 섹션 weight 테이블

    // 쿠폰 없으면 동적 재조정
    if (!$hasStarbucksCoupon) {
        $sections[0]['weight'] += $sections[8]['weight']; // 50P: 380→381
        $sections[8]['weight'] = 0;                        // 스타벅스: 0%
    }

    $totalWeight = array_sum(array_column($sections, 'weight')); // 1000
    $rand = random_int(1, $totalWeight); // CSPRNG

    $cumulative = 0;
    foreach ($sections as $section) {
        if ($section['weight'] <= 0) continue;
        $cumulative += $section['weight'];
        if ($rand <= $cumulative) {
            $section['random_value'] = $rand;
            return $section;
        }
    }
    return ['section_index' => 9, 'points' => 0, 'prize_type' => 'miss', 'random_value' => $rand];
}
```

#### 메인 로직 — EventService::spin()

```php
public static function spin(array $user): array
{
    $pdo = Db::pdo();
    $idxMember = (int) $user['idx'];

    $member = EventRepository::getMember($idxMember);
    $currentPoint = (int) $member['point'];

    if ($currentPoint < 200) {
        throw new RuntimeException("포인트가 부족합니다. (최소 200P 필요, 현재 {$currentPoint}P)");
    }

    $availableCoupons = self::getAvailableStarbucksCoupons();
    $hasStarbucksCoupon = count($availableCoupons) > 0;

    $pdo->beginTransaction();
    try {
        // 200P 차감
        $pointAfterCost = $currentPoint - 200;
        EventRepository::updateMemberPoint($idxMember, $pointAfterCost);
        EventRepository::insertPointLog([
            'idx_member_from' => $idxMember, 'idx_member_to' => $idxMember,
            'point_before' => $currentPoint, 'point' => -200,
            'point_after' => $pointAfterCost,
            'module' => 'event', 'action' => 'spin_cost', 'etc' => 'spin_cost',
        ]);

        // 확률 계산
        $result = self::calculateSpinResult($hasStarbucksCoupon);
        $finalPoint = $pointAfterCost;
        $starbucksCouponFile = null;

        // 보상 처리
        if ($result['prize_type'] === 'point' && $result['points'] > 0) {
            $finalPoint = $pointAfterCost + $result['points'];
            EventRepository::updateMemberPoint($idxMember, $finalPoint);
            EventRepository::insertPointLog([
                'idx_member_from' => 0, 'idx_member_to' => $idxMember,
                'point_before' => $pointAfterCost, 'point' => $result['points'],
                'point_after' => $finalPoint,
                'module' => 'event', 'action' => 'spin_reward',
                'etc' => "spin_reward_{$result['points']}",
            ]);
        } elseif ($result['prize_type'] === 'starbucks') {
            $starbucksCouponFile = $availableCoupons[0];
            EventRepository::insertPointLog([
                'idx_member_from' => 0, 'idx_member_to' => $idxMember,
                'point_before' => $pointAfterCost, 'point' => 0,
                'point_after' => $pointAfterCost,
                'module' => 'event', 'action' => 'spin_reward',
                'etc' => "spin_reward_starbucks:{$starbucksCouponFile}",
            ]);
        }

        // 기록 저장
        $spinIdx = EventRepository::insertSpinHistory([
            'idx_member' => $idxMember, 'section_index' => $result['section_index'],
            'prize_type' => $result['prize_type'], 'points_cost' => 200,
            'points_reward' => $result['points'],
            'starbucks_coupon_file' => $starbucksCouponFile,
            'random_value' => $result['random_value'],
            'point_before' => $currentPoint, 'point_after' => $finalPoint,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? '',
        ]);

        $pdo->commit();
        return [
            'section_index' => $result['section_index'], 'points' => $result['points'],
            'prize_type' => $result['prize_type'], 'current_point' => $finalPoint,
            'starbucks_coupon_file' => $starbucksCouponFile,
            'starbucks_coupon_url' => $starbucksCouponFile ? "/event/cupon/starbucks/{$starbucksCouponFile}" : null,
            'available_coupons' => count($availableCoupons) - ($starbucksCouponFile ? 1 : 0),
            'spin_idx' => $spinIdx,
        ];
    } catch (\Exception $e) {
        $pdo->rollBack();
        throw $e;
    }
}
```

### 2.5 API 엔드포인트

| 메서드 | 용도 | 인증 |
|--------|------|------|
| `event.spin` | 스피닝 휠 돌리기 | 필수 |
| `event.history` | 게임 기록 조회 (페이지네이션) | 필수 |

**event.spin 응답 예시:**

```json
{
  "success": true,
  "section_index": 2,
  "points": 200,
  "prize_type": "point",
  "current_point": 5000,
  "starbucks_coupon_file": null,
  "starbucks_coupon_url": null,
  "available_coupons": 3,
  "spin_idx": 456
}
```

### 2.6 스타벅스 쿠폰 관리

- **저장 위치**: `event/cupon/starbucks/` 폴더 (파일 시스템 기반)
- **사용 추적**: `event_spin_history.starbucks_coupon_file` 컬럼
- **사용 가능 쿠폰** = 폴더 파일 - DB 사용됨 (차집합)
- 쿠폰 0개 → 스타벅스 확률 자동 0%, 50P에 weight 합산

### 2.7 sf_point_log 기록 규칙 (스피닝 휠)

| 상황 | module | action | point | etc |
|------|--------|--------|-------|-----|
| 참가비 차감 | `event` | `spin_cost` | -200 | `spin_cost` |
| 50P~2,000P 당첨 | `event` | `spin_reward` | +N | `spin_reward_{N}` |
| 스타벅스 당첨 | `event` | `spin_reward` | 0 | `spin_reward_starbucks:{파일명}` |
| 꽝 | *(기록 없음)* | | | |

---

## 3. 스피닝 휠 이벤트 (클라이언트 Flutter)

### 3.1 핵심 개념

- **CustomPainter** 기반 원판 렌더링 (가중치 비율 → 각도 분할)
- **AnimationController** + `easeOutCubic` 감속 곡선 (일반 6초, Auto 2.5초)
- **서버 선결정**: `onSpinRequested` 콜백으로 서버 결과 수신 → 해당 섹션에 정렬
- **Auto Spin**: N회 반복 또는 조건(쿠폰 당첨) 충족까지 자동 회전
- **사운드**: `audioplayers` 패키지, 음소거 토글

### 3.2 위젯 구조

```
SpinningWheel (StatefulWidget)
├─ _WheelPainter         → 원판: 섹션 배경 + 라벨 + 아이콘
├─ _OuterRingPainter     → 외곽 링 + 12개 도트
├─ _PointerPainter       → 상단 역삼각형 포인터
├─ AnimationController   → 회전 애니메이션
├─ AudioPlayer           → 효과음
└─ Auto Spin 상태        → _autoSpinRemaining, _autoSpinUntilCondition
```

### 3.3 데이터 모델

```dart
class WheelSection {
  final String label;    // "50", "1,000", "꽝"
  final Color color;     // 섹션 배경색
  final int points;      // 0=꽝, -1=쿠폰
  final double weight;   // 상대적 크기 비중
  final IconData? icon;  // FontAwesome 아이콘
}
```

### 3.4 서버 연동 패턴

```dart
SpinningWheel(
  sections: _sections,
  onSpinRequested: () async {
    final result = await v7api('event.spin');
    if (result['success'] == false) {
      _showError(result['message']);
      return null;  // null → 회전 취소
    }
    _lastSpinResult = result;
    return result['section_index'] as int;  // 서버가 결정한 섹션
  },
  onResult: (section) {
    _showResultDialog(_lastSpinResult);
  },
)
```

### 3.5 회전각 계산 핵심

```dart
double _calculateRotationForTarget(int targetIndex) {
  final targetCenterAngle = startAngles[targetIndex] + sweep / 2;
  final targetNormalized = (2π - targetCenterAngle) % (2π);
  final currentNormalized = _currentAngle % (2π);
  var delta = targetNormalized - currentNormalized;
  if (delta < 0) delta += 2π;

  // 추가 바퀴 (일반: 5~8, Auto: 2~3) + jitter (±30%)
  final extraTurns = _isAutoSpinning ? 2 + random.nextInt(2) : 5 + random.nextInt(4);
  final jitter = (random.nextDouble() - 0.5) * sweep * 0.6;

  return extraTurns * 2π + delta + jitter;
}
```

### 3.6 Auto Spin 흐름

```
_startAutoSpin(option)
  ├─ count == -1 → 조건 모드 (_autoSpinUntilCondition = true)
  └─ count > 0  → 횟수 모드 (_autoSpinRemaining = count)
  └─ 속도 2.5초로 변경 → _spin()
       ↓
  회전 완료 → _checkAutoSpin()
       ├─ 조건 모드: stopCondition(section) == true → 중지
       └─ 횟수 모드: remaining-- == 0 → 중지
       └─ 계속: 600ms 딜레이 → 다음 _spin()
```

### 3.7 Flutter 파일 경로

```
lib/
├─ screens/event/
│   ├─ event_entry.screen.dart       ← 이벤트 응모 메인 화면
│   └─ company_event.screen.dart     ← 업소 이벤트 안내 화면
├─ widgets/spinning_wheel.dart       ← 재사용 스피닝 휠 위젯
├─ v7_api/
│   ├─ v7_api.dart                   ← v7api(), v7apiFileUpload()
│   └─ user_api.dart                 ← UserApi.me()
└─ assets/sound/spinning_wheel.mp3   ← 회전 효과음
```

---

## 4. 업소록 QR 코드 이벤트 (삼단콤보)

### 4.1 핵심 개념

**삼단콤보**: 한 번의 업소 방문에서 최대 3가지 방법으로 포인트 획득

| 단계 | 행동 | 포인트 | 조건 |
|------|------|--------|------|
| 1단계 | QR 코드 스캔 | 랜덤 1,000~2,000P | 유효한 QR 스캔 시 즉시 |
| 2단계 | 재방문 보너스 | 랜덤 2,000~3,000P | 24시간 이전 방문 기록 보유 시 |
| 3단계 | 후기 작성 | 랜덤 2,000~3,000P | 텍스트 후기 작성 시 |

**최대 획득**: 2,000 + 3,000 + 3,000 = **8,000P/회**

### 4.2 QR 코드 시스템

| 항목 | 값 |
|------|-----|
| **verification_id** | `bin2hex(random_bytes(32))` = 64자 hex (256비트 CSPRNG) |
| **만료 시간** | 발행 후 180초 (3분) |
| **일일 발행 한도** | 업소당 최대 10개 |
| **중복 사용 제한** | 로그인 사용자, 24시간 내 동일 업소 1회 |
| **QR URL 형식** | `https://philgo.com/company/qr-code-scanned.php?code={verification_id}` |

### 4.3 QR 스캔 → 포인트 적립 흐름

```
사용자 QR 스캔
  ↓
CompanyService::scanQrCode()
  ├─ verification_id로 QR 코드 조회
  ├─ 유효성 검증 (활성/만료/승인 상태)
  ├─ 24시간 중복 검사 (로그인 사용자만)
  │   ├─ 중복 → result='r' (거부) 기록 → 에러
  │   └─ 통과 → 진행
  ├─ 포인트 적립 (로그인 사용자만)
  │   ├─ random_int(1000, 2000)
  │   ├─ PointLogService::changePoints()
  │   └─ module='company', action='qr_scan'
  ├─ 사용 기록 저장 (result='s')
  └─ 재방문 여부 판별 → is_revisit 반환
```

### 4.4 재방문 포인트 추첨

```
재방문자 판별: 24시간 이전 성공(result='s') 기록 보유
  ↓
"재방문 포인트 추첨" 버튼 표시 (글로우 애니메이션)
  ↓
CompanyService::reVisitPoint()
  ├─ usage_idx로 기록 조회
  ├─ 중복 적립 방지 (sf_point_log etc 필드 검색)
  ├─ random_int(2000, 3000) 포인트 결정
  ├─ PointLogService::changePoints()
  │   └─ module='company', action='qr_revisit'
  └─ 축하 페이지 + 포인트 표시
```

### 4.5 핵심 소스코드

**파일**: `lib/company/CompanyService.php`, `lib/company/QrCodeRepository.php`, `lib/company/QrCodeUsageRepository.php`

#### QR 코드 발행 — CompanyService::issueQrCode()

```php
public static function issueQrCode(array $input): array
{
    $idx = $input['idx'] ?? 0;
    $idxMember = $input['idx_member'] ?? 0;

    $entity = CompanyRepository::findByIdx($idx);
    if (!$entity || !$entity->isApproved()) {
        throw new RuntimeException('승인된 업소만 QR 코드를 발행할 수 있습니다.');
    }
    if ($entity->idx_member !== $idxMember && !($input['is_admin'] ?? false)) {
        throw new RuntimeException('업소 소유자만 QR 코드를 발행할 수 있습니다.');
    }

    $todayCount = QrCodeRepository::countTodayIssued($idx);
    if ($todayCount >= 10) {
        throw new RuntimeException('하루 최대 10개 발행 가능합니다.');
    }

    $verificationId = bin2hex(random_bytes(32));
    $qrIdx = QrCodeRepository::insert([
        'idx_company' => $idx, 'idx_member' => $idxMember,
        'verification_id' => $verificationId, 'status' => 'a',
        'created_at' => time(), 'expired_at' => time() + 180,
    ]);

    return QrCodeRepository::findByIdx($qrIdx)->toArray();
}
```

#### QR 코드 스캔 — CompanyService::scanQrCode()

```php
public static function scanQrCode(array $input): array
{
    $code = $input['code'] ?? '';
    $idxMember = $input['idx_member'] ?? 0;

    $qrCode = QrCodeRepository::findByVerificationId($code);
    if (!$qrCode || !$qrCode->isActive() || $qrCode->isExpired()) {
        QrCodeUsageRepository::insert([
            'verification_id' => $code, 'scanned_at' => time(), 'result' => 'f'
        ]);
        throw new RuntimeException('유효하지 않은 QR 코드입니다.');
    }

    // 24시간 중복 확인 (로그인 사용자만)
    if ($idxMember > 0 && QrCodeUsageRepository::hasRecentUsage($qrCode->idx_company, $idxMember)) {
        QrCodeUsageRepository::insert([
            'idx_qr_code' => $qrCode->idx, 'idx_company' => $qrCode->idx_company,
            'idx_member' => $idxMember, 'verification_id' => $code,
            'scanned_at' => time(), 'result' => 'r'
        ]);
        throw new RuntimeException('24시간 이내에 이미 사용하셨습니다.');
    }

    // 성공 기록
    $usageIdx = QrCodeUsageRepository::insert([
        'idx_qr_code' => $qrCode->idx, 'idx_company' => $qrCode->idx_company,
        'idx_member' => $idxMember, 'verification_id' => $code,
        'scanned_at' => time(), 'result' => 's'
    ]);

    // 포인트 적립 (로그인 사용자만)
    $rewardPoints = 0;
    if ($idxMember > 0) {
        $rewardPoints = random_int(1000, 2000);
        PointLogService::changePoints([
            'idx_member' => $idxMember, 'points' => $rewardPoints,
            'module' => 'company', 'action' => 'qr_scan',
            'etc' => "{$company->name} QR 스캔 보상"
        ]);
    }

    $isRevisit = QrCodeUsageRepository::hasPriorVisit($qrCode->idx_company, $idxMember);

    return [
        'success' => true, 'usage_idx' => $usageIdx,
        'reward_points' => $rewardPoints, 'is_revisit' => $isRevisit,
    ];
}
```

#### 재방문 포인트 — CompanyService::reVisitPoint()

```php
public static function reVisitPoint(array $input): array
{
    $usageIdx = $input['usage_idx'] ?? 0;
    $idxMember = $input['idx_member'] ?? 0;

    $usage = QrCodeUsageRepository::findByIdx($usageIdx);
    if (!$usage) throw new RuntimeException('방문 기록을 찾을 수 없습니다.');

    // 중복 적립 방지
    $already = PointLogService::findByEtc([
        'idx_member' => $idxMember, 'module' => 'company',
        'action' => 'qr_revisit', 'etc_like' => "usage_idx:{$usageIdx}"
    ]);
    if (!empty($already)) throw new RuntimeException('이미 적립된 기록이 있습니다.');

    $rewardPoints = random_int(2000, 3000);
    PointLogService::changePoints([
        'idx_member' => $idxMember, 'points' => $rewardPoints,
        'module' => 'company', 'action' => 'qr_revisit',
        'etc' => "{$company->name} 재방문 보상 (usage_idx:{$usageIdx})"
    ]);

    return ['success' => true, 'reward_points' => $rewardPoints];
}
```

### 4.6 sf_point_log 기록 규칙 (업소록 이벤트)

| 상황 | module | action | point | etc |
|------|--------|--------|-------|-----|
| QR 스캔 적립 | `company` | `qr_scan` | +1,000~2,000 | `{업소명} QR 스캔 보상` |
| 재방문 보너스 | `company` | `qr_revisit` | +2,000~3,000 | `{업소명} 재방문 보상 (usage_idx:{N})` |
| 후기 작성 보상 | `company` | `visit_review` | +2,000~3,000 | `{업소명} 방문 후기 보상 (usage_idx:{N})` |

### 4.7 QR 코드 & 후기 API 엔드포인트

| 메서드 | 용도 | 인증 |
|--------|------|------|
| `company.issueQrCode` | QR 코드 발행 (업소 소유자) | 필수 |
| `company.scanQrCode` | QR 코드 스캔 | 비로그인 가능 |
| `company.listQrCodes` | 발행된 QR 코드 목록 | 필수 |
| `company.listQrCodeUsages` | 스캔 기록 목록 | 필수 |
| `company.qrCodeStats` | 발행/스캔 통계 | 필수 |
| `company.submitVisitReview` | 방문 후기 작성 + 포인트 적립 | 필수 |
| `company.getVisitReviews` | 업소별 후기 목록 조회 | 불필요 |

### 4.8 데이터 관계도

```
sf_member (회원)
    │
company (업소, status='a' 필수)
    │
company_qr_codes (QR 코드)
    ├─ verification_id (64자 hex)
    ├─ expired_at (time()+180)
    └─ status ('a'|'d')
    │
company_qr_code_usages (사용 기록)
    ├─ result ('s'|'f'|'r')
    └─ scanned_at
    │
company_reviews (방문 후기)          ← 삼단콤보 3단계
    ├─ usage_idx (UNIQUE, 1회 제한)
    ├─ content (후기 글)
    ├─ reward_points (2,000~3,000)
    └─ → uploads 테이블 (사진 연결)
    │
sf_point_log (포인트 기록)
    ├─ module='company'
    └─ action='qr_scan'|'qr_revisit'|'visit_review'
```

### 4.9 업소록 이벤트 전체 흐름 (CoT 단계별 분석)

> **CoT(Chain of Thought)**: 업소록 QR 코드 이벤트의 전체 흐름을 **5단계**로 분해하여,
> 각 단계의 입력→처리→출력을 순서대로 추적한다.

#### 전체 흐름 요약도

```
┌──────────────────────────────────────────────────────────────────────────┐
│                  업소록 QR 코드 이벤트 — 5단계 전체 흐름                    │
├──────────┬──────────┬──────────┬──────────┬──────────────────────────────┤
│ [1단계]  │ [2단계]  │ [3단계]  │ [4단계]  │ [5단계]                      │
│ QR 발행  │ QR 스캔  │ 재방문   │ 후기     │ 업소 보기                    │
│          │          │ 포인트   │ 작성     │ (후기 표시)                  │
├──────────┼──────────┼──────────┼──────────┼──────────────────────────────┤
│ 업소     │ 고객     │ 재방문   │ 고객     │ 모든 사용자                   │
│ 소유자   │ (모든    │ 고객     │ (로그인) │                              │
│ (관리자) │ 사용자)  │ (로그인) │          │                              │
├──────────┼──────────┼──────────┼──────────┼──────────────────────────────┤
│ —        │ 1,000~   │ 2,000~   │ 2,000~   │ —                            │
│          │ 2,000P   │ 3,000P   │ 3,000P   │                              │
├──────────┼──────────┼──────────┼──────────┼──────────────────────────────┤
│ qr-code  │ qr-code  │ re-visit │ visit-   │ view.php                     │
│ .php     │ -scanned │ -point   │ review-  │ (#visit-                     │
│          │ .php     │ .php     │ point.php│  reviews-app)                │
└──────────┴──────────┴──────────┴──────────┴──────────────────────────────┘
```

---

#### [1단계] QR 코드 발행 — `company/qr-code.php`

> **누가**: 업소 소유자 또는 관리자
> **언제**: 고객에게 QR 코드를 보여주고 싶을 때
> **어디서**: 업소 현장 (매장 카운터, 테이블 등)

```
[입력]
  URL: /company/qr-code.php?idx={업소_idx}
  요구: 로그인 필수, 업소 소유자 또는 관리자

[처리] CompanyService::issueQrCode()
  ① 로그인 확인 (idx_member > 0)
  ② 업소 idx 유효성 확인 (idx > 0)
  ③ 업소 존재 확인 (CompanyRepository::findByIdx)
  ④ 업소 승인 상태 확인 (status === 'a')
  ⑤ 권한 확인 (업소 소유자 OR 관리자)
  ⑥ 하루 발행 한도 확인 (QrCodeRepository::countTodayIssued < 10)
  ⑦ verification_id 생성: bin2hex(random_bytes(32)) → 64자 hex
  ⑧ DB INSERT: company_qr_codes
     ├─ status = 'a'
     ├─ created_at = time()
     └─ expired_at = time() + 180 (3분)

[출력]
  QR URL: https://philgo.com/company/qr-code-scanned.php?code={verification_id}
  화면에 QRCode.js 라이브러리(CDN)로 256×256 QR 코드 이미지 렌더링
  오늘 발행 현황: "발행 N/10 · 남은 횟수 M"
```

**핵심 제약 조건**:

| 항목 | 값 | 설명 |
|------|-----|------|
| verification_id 길이 | 64자 hex | 256비트 CSPRNG (`bin2hex(random_bytes(32))`) |
| 만료 시간 | 180초 (3분) | `time() + 180` |
| 일일 발행 한도 | 업소당 10개/일 | `countTodayIssued()` |
| QR 코드 크기 | 256×256px | QRCode.js 설정 |
| 오류 복구 수준 | H (High) | QRCode.CorrectLevel.H |

---

#### [2단계] QR 코드 스캔 — `company/qr-code-scanned.php`

> **누가**: 업소를 방문한 고객 (로그인/비로그인 모두 가능)
> **언제**: 업소에서 QR 코드를 스캔했을 때
> **어디서**: 고객의 모바일 기기 (카메라 앱 또는 QR 스캐너)

```
[입력]
  URL: /company/qr-code-scanned.php?code={verification_id}
  요구: 없음 (비로그인도 스캔 가능, 포인트 적립은 로그인 시만)

[처리] CompanyService::scanQrCode()
  ① code 파라미터 존재 확인
  ② verification_id로 QR 코드 조회 (QrCodeRepository::findByVerificationId)
  ③ QR 코드 상태 확인 (status === 'a')
  ④ 만료 확인 (time() <= expired_at, expired_at=0이면 무제한)
  ⑤ 업소 승인 확인 (CompanyRepository::findByIdx → isApproved)
  ⑥ 24시간 중복 확인 (로그인 사용자만)
     ├─ QrCodeUsageRepository::hasRecentUsage(idx_company, idx_member)
     │  SELECT COUNT(*) FROM company_qr_code_usages
     │  WHERE idx_company=? AND idx_member=? AND scanned_at > time()-86400 AND result='s'
     └─ 중복 시: result='r' 기록 → 에러 (이전 방문 시간 포함)
  ⑦ 성공 기록 INSERT: company_qr_code_usages (result='s')
  ⑧ used_count 증가: company_qr_codes
  ⑨ 포인트 적립 (로그인 사용자만):
     ├─ 금액: random_int(1000, 2000) → 1,000P~2,000P
     └─ PointLogService::changePoints(module='company', action='qr_scan')
  ⑩ 재방문 판별:
     └─ QrCodeUsageRepository::hasPreviousVisit(idx_company, idx_member)
        SELECT COUNT(*) FROM company_qr_code_usages
        WHERE idx_company=? AND idx_member=? AND scanned_at <= time()-86400 AND result='s'

[출력]
  성공: { usage_idx, reward_points, point_after, is_revisit, company }
  화면:
    ├─ 체크 아이콘 (펄스 애니메이션 3회)
    ├─ "N포인트 적립!" 표시
    ├─ 재방문자 → "재방문 포인트 추첨" 강조 버튼 (글로우 애니메이션)
    └─ 첫 방문자 → "업소록 후기 포인트" CTA (녹색 그라데이션)
```

**중요 분기점**: `is_revisit` 값에 따라 다음 단계 결정

```
is_revisit === true  → [3단계] 재방문 포인트 추첨으로 유도
is_revisit === false → [4단계] 후기 작성으로 유도 (재방문 건너뜀)
비로그인             → 로그인 안내 메시지 표시
```

---

#### [3단계] 재방문 포인트 추첨 — `company/re-visit-point.php`

> **누가**: 24시간 이전에 해당 업소를 방문한 이력이 있는 로그인 고객
> **언제**: QR 스캔 성공 후 "재방문 포인트 추첨" 버튼 클릭
> **어디서**: `qr-code-scanned.php` → `re-visit-point.php`

```
[입력]
  URL: /company/re-visit-point.php?usage_idx={usage_idx}
  요구: 로그인 필수, 재방문자만

[처리] CompanyService::reVisitPoint()
  ① 로그인 확인 (idx_member > 0)
  ② usage_idx 유효성 확인 (> 0)
  ③ 스캔 기록 조회 (QrCodeUsageRepository::findByIdx)
  ④ 본인 기록 확인 (usage.idx_member === 로그인 사용자)
  ⑤ 성공한 스캔 확인 (usage.result === 's')
  ⑥ 재방문 여부 재확인 (QrCodeUsageRepository::hasPreviousVisit)
  ⑦ 중복 적립 방지:
     SELECT COUNT(*) FROM sf_point_log
     WHERE module='company' AND action='qr_revisit'
       AND idx_member_to=? AND etc LIKE '%usage_idx:{N}%'
  ⑧ 포인트 적립:
     ├─ 금액: random_int(2000, 3000) → 2,000P~3,000P
     └─ PointLogService::changePoints(module='company', action='qr_revisit')
     └─ etc: "{업소명} 재방문 보상 (usage_idx:{N})"

[출력]
  성공: { reward_points, point_before, point_after, company_name }
  화면:
    ├─ 선물 아이콘 (confetti-drop 애니메이션)
    ├─ "재방문 축하" 제목
    ├─ "N포인트" 강조 (point-reveal 애니메이션)
    ├─ 포인트 변동: "변경 전 → 변경 후"
    └─ "업소록 후기 포인트" CTA → [4단계]로 유도
```

---

#### [4단계] 업소록 후기 작성 — `company/visit-review-point.php`

> **누가**: QR 스캔에 성공한 로그인 고객 (재방문/첫방문 모두)
> **언제**: QR 스캔 성공 후 또는 재방문 포인트 추첨 후
> **어디서**: `qr-code-scanned.php` 또는 `re-visit-point.php` → `visit-review-point.php`

```
[입력]
  URL: /company/visit-review-point.php?usage_idx={usage_idx}
  요구: 로그인 필수, 본인 스캔 기록, 미작성 상태

[서버 검증] (PHP 사이드, 페이지 로드 시)
  ① 로그인 확인
  ② usage_idx 유효성 확인
  ③ 스캔 기록 조회 → 본인 확인 → result='s' 확인
  ④ 중복 후기 확인: VisitReviewRepository::existsByUsageIdx($usage_idx)
  ⑤ 상태 분기:
     ├─ 에러 → 에러 메시지 표시
     ├─ 이미 작성 → "이미 후기를 작성하셨습니다" 안내
     └─ 작성 가능 → Vue.js 폼 표시

[Vue.js 프론트엔드 처리]
  ① 사진 업로드:
     ├─ <input type="file" accept="image/*" multiple>
     ├─ v7apiUpload(file, 'company', 'visit_review')
     └─ 업로드된 사진 idx 배열 저장
  ② 후기 내용 입력:
     ├─ <textarea v-model="content" maxlength="1000">
     └─ 유효성: mb_strlen(content) >= 10
  ③ 제출 유효성:
     └─ isValid = content.length >= 10 && uploadedPhotos.length >= 1

[API 호출] v7api('company.submitVisitReview', {...})
  → CompanyService::submitVisitReview()
    ① 로그인 확인
    ② usage_idx 유효성
    ③ 스캔 기록 조회 → 본인 → result='s'
    ④ 중복 후기 확인 (VisitReviewRepository::existsByUsageIdx)
    ⑤ 내용 검증 (최소 10자)
    ⑥ 사진 검증 (최소 1장)
    ⑦ 후기 INSERT: company_reviews (usage_idx UNIQUE 제약)
    ⑧ 사진 연결: uploads.attached_to = review_idx
    ⑨ 포인트 적립:
       ├─ 금액: random_int(2000, 3000) → 2,000P~3,000P
       └─ PointLogService::changePoints(module='company', action='visit_review')
       └─ etc: "{업소명} 방문 후기 보상 (usage_idx:{N})"

[출력]
  성공: { review_idx, reward_points, point_before, point_after }
  화면:
    ├─ 별 아이콘 (success-pop 애니메이션)
    ├─ "후기 포인트 적립 완료!"
    ├─ "N포인트" 강조
    ├─ 포인트 변동: "변경 전 → 변경 후"
    └─ 버튼: "업소 보기" | "업소록 홈"
```

---

#### [5단계] 업소 상세 페이지 — `company/view.php`

> **누가**: 모든 사용자 (로그인 불필요)
> **언제**: 업소 정보와 방문 후기를 확인하고 싶을 때
> **어디서**: 업소록 목록, 검색 결과, 후기 작성 완료 후

```
[입력]
  URL: /company/view.php?idx={업소_idx}
  요구: 없음

[처리] Vue.js 앱 (#visit-reviews-app)
  mounted() → v7api('company.getVisitReviews', { idx_company, page: 1, limit: 5 })
  → CompanyService::getVisitReviews()
    ① 업소 idx 확인 (> 0)
    ② 페이지네이션: page=max(1,...), limit=max(1,min(50,...))
    ③ 후기 목록 조회: VisitReviewRepository::findByCompany
    ④ 각 후기의 사진 조회: UploadRepository::findByAttached
    ⑤ 후기 총 개수 조회: VisitReviewRepository::countByCompany

[출력]
  { reviews: [...], total, page, limit }
  화면:
    ├─ "방문 후기" 섹션 제목 + 총 개수 배지
    ├─ 후기 카드 목록:
    │  ├─ 사진 갤러리 (수평 스크롤, 80×80px)
    │  ├─ 후기 내용 (줄바꿈 보존, 200자 truncate)
    │  └─ 메타: 날짜 + 포인트 배지 + 사진 개수
    └─ "더보기" 버튼 (page++ → 추가 5개 로드)
```

---

### 4.10 분기별 사용자 경험 (ToT 트리 구조 분석)

> **ToT(Tree of Thought)**: 각 분기점에서 발생할 수 있는 **모든 경로**를 트리 구조로 나열한다.
> 이를 통해 모든 사용자 시나리오와 에러 케이스를 빠짐없이 파악할 수 있다.

```
사용자가 업소에서 QR 코드 스캔
│
├─ [A] code 파라미터 없음
│  └─ ❌ "QR 코드가 필요합니다" → 업소록 홈
│
├─ [B] verification_id 미존재 (잘못된 QR)
│  └─ ❌ "유효하지 않은 QR 코드입니다" (result='f') → 업소록 홈
│
├─ [C] QR 코드 비활성 (status !== 'a')
│  └─ ❌ "비활성화된 QR 코드입니다" (result='f') → 업소록 홈
│
├─ [D] QR 코드 만료 (time() > expired_at)
│  └─ ❌ "만료된 QR 코드입니다" (result='f') → 업소록 홈
│
├─ [E] 업소 미승인/삭제
│  └─ ❌ "해당 업소가 유효하지 않습니다" (result='f') → 업소록 홈
│
├─ [F] 24시간 중복 (로그인 상태)
│  └─ ⚠️ "포인트 충전 실패" + 이전 방문 시간 (result='r') → 업소록 홈
│
├─ [G] 스캔 성공 — 비로그인
│  └─ ✅ 감사 페이지 (포인트 0) + 로그인 안내 → 끝
│
├─ [H] 스캔 성공 — 로그인 + 첫 방문
│  ├─ ✅ 1,000~2,000P 적립 + is_revisit=false
│  └─ 후기 CTA 표시
│     ├─ [H-1] 후기 작성 클릭 → [4단계]
│     │  ├─ [H-1a] 사진+글 제출 성공 → 2,000~3,000P 추가 적립
│     │  │  └─ "업소 보기" | "업소록 홈"
│     │  ├─ [H-1b] 내용 부족 (< 10자) → 에러 안내 → 재시도
│     │  ├─ [H-1c] 사진 없음 → 에러 안내 → 재시도
│     │  └─ [H-1d] 이미 작성함 → "이미 후기를 작성하셨습니다"
│     └─ [H-2] 후기 미작성 → 끝 (포인트: 1,000~2,000P)
│
└─ [I] 스캔 성공 — 로그인 + 재방문
   ├─ ✅ 1,000~2,000P 적립 + is_revisit=true
   └─ 재방문 포인트 추첨 버튼 표시
      ├─ [I-1] 추첨 버튼 클릭 → [3단계]
      │  ├─ [I-1a] 추첨 성공 → 2,000~3,000P 추가 적립
      │  │  └─ 후기 CTA 표시
      │  │     ├─ [I-1a-i] 후기 작성 → 2,000~3,000P 추가 적립
      │  │     │  └─ 최대 합계: 2,000 + 3,000 + 3,000 = 8,000P
      │  │     └─ [I-1a-ii] 후기 미작성 → 끝 (합계: ~5,000P)
      │  ├─ [I-1b] 이미 적립함 → "이미 재방문 포인트를 받으셨습니다"
      │  └─ [I-1c] 재방문 조건 미충족 → "재방문 조건을 충족하지 않습니다"
      └─ [I-2] 추첨 미클릭 → 끝 (포인트: 1,000~2,000P)
```

#### 포인트 적립 시나리오별 합산

| 시나리오 | QR 스캔 | 재방문 추첨 | 후기 작성 | **합계** |
|----------|---------|------------|----------|----------|
| 비로그인 스캔 | 0P | — | — | **0P** |
| 첫 방문 (후기 미작성) | 1,000~2,000P | — | — | **1,000~2,000P** |
| 첫 방문 + 후기 작성 | 1,000~2,000P | — | 2,000~3,000P | **3,000~5,000P** |
| 재방문 (추첨+후기 미진행) | 1,000~2,000P | — | — | **1,000~2,000P** |
| 재방문 + 추첨만 | 1,000~2,000P | 2,000~3,000P | — | **3,000~5,000P** |
| 재방문 + 추첨 + 후기 | 1,000~2,000P | 2,000~3,000P | 2,000~3,000P | **5,000~8,000P** |

---

### 4.11 API 메서드별 검증 로직 상세

#### issueQrCode() — QR 코드 발행

```
순서  검증 항목                     에러 메시지                              에러 조건
──── ──────────────────────────── ─────────────────────────────────────── ─────────────────
 ①   로그인 확인                   '로그인이 필요합니다.'                    idx_member <= 0
 ②   업소 idx 확인                 '업소 idx가 필요합니다.'                  idx <= 0
 ③   업소 존재 확인                '해당 업소를 찾을 수 없습니다.'           findByIdx === null
 ④   업소 승인 상태                '승인된 업소만 QR 코드를 발행...'         status !== 'a'
 ⑤   권한 확인                     'QR 코드 발행 권한이 없습니다.'          소유자 아님 AND 관리자 아님
 ⑥   하루 발행 한도                '하루 최대 10개까지 발행 가능...'         todayCount >= 10
```

#### scanQrCode() — QR 코드 스캔

```
순서  검증 항목                     에러 메시지                              result   에러 조건
──── ──────────────────────────── ─────────────────────────────────────── ─────── ─────────────────
 ①   code 존재                     'QR 코드가 필요합니다.'                  'f'      empty($code)
 ②   verification_id 조회          '유효하지 않은 QR 코드입니다.'           'f'      findByVerificationId === null
 ③   QR 코드 상태                  '비활성화된 QR 코드입니다.'              'f'      status !== 'a'
 ④   만료 확인                     '만료된 QR 코드입니다.'                  'f'      time() > expired_at
 ⑤   업소 승인                     '해당 업소가 유효하지 않습니다.'         'f'      company === null || !isApproved
 ⑥   24시간 중복                   '24시간_중복|{이전 방문 시간}'           'r'      hasRecentUsage === true
```

#### reVisitPoint() — 재방문 포인트 추첨

```
순서  검증 항목                     에러 메시지                              에러 조건
──── ──────────────────────────── ─────────────────────────────────────── ─────────────────
 ①   로그인 확인                   '로그인이 필요합니다.'                    idx_member <= 0
 ②   usage_idx 유효성              '유효하지 않은 요청입니다.'               usage_idx <= 0
 ③   스캔 기록 존재                '스캔 기록을 찾을 수 없습니다.'           findByIdx === null
 ④   본인 기록 확인                '본인의 스캔 기록이 아닙니다.'            idx_member 불일치
 ⑤   성공 스캔 확인                '유효한 스캔 기록이 아닙니다.'            result !== 's'
 ⑥   재방문 여부                   '재방문 조건을 충족하지 않습니다.'        hasPreviousVisit === false
 ⑦   중복 적립 방지                '이미 재방문 포인트를 받으셨습니다.'      sf_point_log에 동일 usage_idx 존재
```

#### submitVisitReview() — 방문 후기 제출

```
순서  검증 항목                     에러 메시지                              에러 조건
──── ──────────────────────────── ─────────────────────────────────────── ─────────────────
 ①   로그인 확인                   '로그인이 필요합니다.'                    idx_member <= 0
 ②   usage_idx 유효성              '유효하지 않은 요청입니다.'               usage_idx <= 0
 ③   스캔 기록 존재                '스캔 기록을 찾을 수 없습니다.'           findByIdx === null
 ④   본인 기록 확인                '본인의 스캔 기록이 아닙니다.'            idx_member 불일치
 ⑤   성공 스캔 확인                '유효한 스캔 기록이 아닙니다.'            result !== 's'
 ⑥   중복 후기 방지                '이미 후기를 작성하셨습니다.'             existsByUsageIdx === true
 ⑦   내용 최소 길이                '후기 내용을 10자 이상 작성해 주세요.'    mb_strlen(content) < 10
 ⑧   사진 최소 장수                '사진을 1장 이상 첨부해 주세요.'          photoIdxs count < 1
```

---

### 4.12 에러 시나리오 매트릭스

> 모든 에러 케이스를 **페이지 × 에러 유형**으로 정리한 종합 매트릭스이다.

| 페이지 | 에러 | 원인 | result | 화면 처리 | 다음 액션 |
|--------|------|------|:------:|-----------|-----------|
| qr-code.php | 로그인 필요 | 비로그인 | — | 에러 메시지 | 로그인 유도 |
| qr-code.php | 업소 없음 | idx 파라미터 오류 | — | 에러 카드 | 업소록 홈 |
| qr-code.php | 업소 미승인 | status !== 'a' | — | 에러 카드 | 업소 보기 |
| qr-code.php | 권한 없음 | 소유자 아님 | — | 에러 카드 | 업소 보기 |
| qr-code.php | 발행 한도 초과 | 하루 10개 초과 | — | 에러 카드 | 내일 재시도 |
| **scanned.php** | **QR 코드 없음** | **code 파라미터 누락** | **'f'** | **에러 아이콘** | **업소록 홈** |
| scanned.php | 유효하지 않은 QR | verification_id 미존재 | 'f' | 에러 아이콘 | 업소록 홈 |
| scanned.php | 비활성 QR | status !== 'a' | 'f' | 에러 아이콘 | 업소록 홈 |
| scanned.php | 만료된 QR | 180초 초과 | 'f' | 에러 아이콘 | 업소록 홈 |
| scanned.php | 업소 미유효 | 업소 미승인/삭제 | 'f' | 에러 아이콘 | 업소록 홈 |
| **scanned.php** | **24시간 중복** | **동일 업소 24시간 내 재스캔** | **'r'** | **시계 아이콘 + 이전 방문 시간** | **업소록 홈** |
| re-visit.php | 로그인 필요 | 비로그인 | — | 에러 카드 | 로그인 유도 |
| re-visit.php | 유효하지 않은 요청 | usage_idx 오류 | — | 에러 카드 | 업소록 홈 |
| re-visit.php | 본인 기록 아님 | idx_member 불일치 | — | 에러 카드 | 업소록 홈 |
| re-visit.php | 재방문 미충족 | hasPreviousVisit=false | — | 에러 카드 | 업소록 홈 |
| **re-visit.php** | **중복 적립** | **sf_point_log에 이미 존재** | — | **에러 카드** | **업소록 홈** |
| review.php | 로그인 필요 | 비로그인 | — | 에러 카드 | 로그인 유도 |
| review.php | 유효하지 않은 요청 | usage_idx 오류 | — | 에러 카드 | 업소록 홈 |
| review.php | 본인 기록 아님 | idx_member 불일치 | — | 에러 카드 | 업소록 홈 |
| **review.php** | **이미 작성** | **existsByUsageIdx=true** | — | **체크 아이콘 + 안내** | **업소 보기** |
| review.php | 내용 부족 | < 10자 | — | alert-danger | 재시도 |
| review.php | 사진 없음 | 0장 | — | alert-danger | 재시도 |

---

### 4.13 웹 페이지 통합 흐름

> 각 PHP 페이지 간의 **데이터 전달 방식**과 **이동 경로**를 종합 정리한다.

#### 페이지 간 데이터 전달

```
[1단계] qr-code.php
  ├─ 입력: ?idx={업소_idx}
  ├─ 생성: verification_id (64자 hex)
  └─ 출력: QR URL에 code={verification_id} 인코딩

       ↓ QR 스캔 (물리적 행위)

[2단계] qr-code-scanned.php
  ├─ 입력: ?code={verification_id}
  ├─ 생성: usage_idx (사용 기록 ID)
  ├─ 판단: is_revisit (재방문 여부)
  └─ 출력: usage_idx를 URL 파라미터로 전달

       ↓ 링크 클릭

[3단계] re-visit-point.php          (재방문자만)
  ├─ 입력: ?usage_idx={usage_idx}
  ├─ 처리: 재방문 포인트 적립
  └─ 출력: usage_idx를 다음 페이지에 전달

       ↓ 링크 클릭

[4단계] visit-review-point.php
  ├─ 입력: ?usage_idx={usage_idx}
  ├─ 처리: 사진 업로드 + 후기 작성 + 포인트 적립
  └─ 출력: 업소 보기 또는 업소록 홈으로 이동

       ↓ 링크 클릭

[5단계] view.php
  ├─ 입력: ?idx={업소_idx}
  └─ 처리: 후기 목록 표시 (Vue.js + v7api)
```

#### 핵심 연결 키(Key)

| 키 | 형식 | 생성 시점 | 사용 페이지 |
|-----|------|-----------|-------------|
| `verification_id` | 64자 hex | issueQrCode() | qr-code.php → qr-code-scanned.php |
| `usage_idx` | int (AUTO_INCREMENT) | scanQrCode() | qr-code-scanned.php → re-visit-point.php → visit-review-point.php |
| `idx_company` | int | 업소 등록 시 | 모든 페이지에서 사용 |

#### 중복 방지 메커니즘 종합

| 대상 | 방지 방법 | DB 검증 |
|------|-----------|---------|
| QR 스캔 (24시간) | `hasRecentUsage()` | `company_qr_code_usages` WHERE scanned_at > time()-86400 AND result='s' |
| 재방문 포인트 | `sf_point_log` 검색 | WHERE module='company' AND action='qr_revisit' AND etc LIKE '%usage_idx:{N}%' |
| 후기 작성 | `existsByUsageIdx()` + UNIQUE 제약 | `company_reviews.usage_idx` UNIQUE KEY |

#### sf_point_log 기록 종합

| 단계 | module | action | 포인트 | etc 형식 |
|------|--------|--------|--------|----------|
| QR 스캔 | `company` | `qr_scan` | +1,000~2,000 | `{업소명} QR 스캔 보상` |
| 재방문 추첨 | `company` | `qr_revisit` | +2,000~3,000 | `{업소명} 재방문 보상 (usage_idx:{N})` |
| 후기 작성 | `company` | `visit_review` | +2,000~3,000 | `{업소명} 방문 후기 보상 (usage_idx:{N})` |

#### Debug 로그 태그

| 단계 | 로그 태그 | 기록 시점 |
|------|-----------|-----------|
| QR 스캔 | `[QR-POINT]` | 포인트 적립 시작 / 랜덤 포인트 결정 / 적립 완료 |
| 재방문 추첨 | `[QR-REVISIT]` | 추첨 시작 / 포인트 결정 / 적립 완료 |
| 후기 제출 | `[VISIT-REVIEW]` | 제출 시작 / 포인트 결정 / 저장+적립 완료 |

---

## 5. 업소록 방문 후기 포인트 (삼단콤보 3단계)

### 5.1 핵심 개념

QR 코드 삼단콤보의 **3단계**: 사진과 글로 업소록 후기를 작성하면 랜덤 2,000~3,000P를 추가 적립한다.
QR 스캔 성공 페이지(`qr-code-scanned.php`)와 재방문 포인트 성공 페이지(`re-visit-point.php`) 모두에서
후기 작성 CTA 버튼을 표시하여 `visit-review-point.php`로 유도한다.

| 항목 | 값 |
|------|------|
| **적립 범위** | 랜덤 2,000~3,000P |
| **필수 조건** | 로그인 + 본인 스캔 기록 + 성공(result='s') + 미작성 |
| **글 최소 길이** | 10자 |
| **사진 최소 장수** | 1장 이상 |
| **중복 방지** | usage_idx UNIQUE 제약 → 1회만 |
| **포인트 로그** | module='company', action='visit_review' |
| **DB 테이블** | `company_reviews` |
| **사진 저장** | `uploads` 테이블 (module='company', code='visit_review') |

### 5.2 후기 작성 흐름

```
사용자가 후기 CTA 클릭
  ↓
visit-review-point.php?usage_idx={N}
  ↓
[PHP 서버 사이드 검증]
  ├─ 로그인 확인
  ├─ usage_idx 유효성 검증
  ├─ 본인 스캔 기록 확인
  ├─ 성공한 스캔 확인 (result='s')
  └─ 이미 후기 작성 여부 확인
  ↓
[Vue.js 프론트엔드]
  ├─ 사진 업로드 (v7apiUpload → uploads 테이블)
  ├─ 글 내용 입력 (최소 10자)
  └─ 제출 → v7api('company.submitVisitReview')
  ↓
[CompanyService::submitVisitReview()]
  ├─ 입력 검증 (중복, 길이, 사진 수)
  ├─ 후기 저장 (company_reviews INSERT)
  ├─ 사진 연결 (uploads.attached_to 업데이트)
  └─ 포인트 적립 (PointLogService::changePoints)
  ↓
성공 → 축하 화면 (적립 포인트 표시)
```

### 5.3 후기 CTA 진입 경로

| 진입 경로 | 조건 | CTA 위치 |
|-----------|------|----------|
| QR 스캔 성공 (첫 방문) | `!is_revisit && login()` | `qr-code-scanned.php` 하단 |
| QR 스캔 성공 (재방문) | `is_revisit && login()` | `qr-code-scanned.php` 재방문 추첨 버튼 위 |
| 재방문 포인트 적립 성공 | 항상 표시 | `re-visit-point.php` 성공 화면 하단 |

**CTA 디자인**: 녹색 그라데이션 카드 + 글로우 애니메이션 + "후기 작성하기" 뱃지 버튼 + "포인트를 두배로 받으세요!" 안내 메시지

### 5.4 v7 클래스 구조

```
lib/company/
├── VisitReviewEntity.php       ← Philgo\Company\VisitReviewEntity
│   ├── fromArray(array): self  ← DB 행 → Entity 변환
│   └── toArray(): array        ← Entity → 배열 변환 (photos 포함)
│
├── VisitReviewRepository.php   ← Philgo\Company\VisitReviewRepository
│   ├── insert(array): int      ← 후기 INSERT
│   ├── findByIdx(int): ?Entity ← idx로 조회
│   ├── findByUsageIdx(int): ?Entity ← usage_idx로 조회
│   ├── existsByUsageIdx(int): bool  ← 중복 확인
│   ├── findByCompany(int, int, int): Entity[] ← 업소별 목록
│   └── countByCompany(int): int ← 업소별 개수
│
├── CompanyService.php          ← submitVisitReview(), getVisitReviews() 추가
└── CompanyController.php       ← company.submitVisitReview, company.getVisitReviews 추가
```

### 5.5 웹 페이지 파일

| 파일 | URL | 용도 |
|------|-----|------|
| `company/visit-review-point.php` | `/company/visit-review-point.php?usage_idx={N}` | 후기 작성 폼 (Vue.js + v7api) |
| `company/qr-code-scanned.php` | `/company/qr-code-scanned.php?code={code}` | QR 스캔 성공 → 후기 CTA 표시 |
| `company/re-visit-point.php` | `/company/re-visit-point.php?usage_idx={N}` | 재방문 적립 성공 → 후기 CTA 표시 |
| `company/view.php` | `/company/view.php?idx={N}` | 업소 상세 → 후기 목록 표시 |
| `js/v7api.js` | `/js/v7api.js` | v7api(), v7apiUpload() 헬퍼 함수 |

### 5.6 업소 상세 페이지 후기 표시

`company/view.php` 하단에 Vue.js 앱으로 해당 업소의 후기 목록을 표시한다.
`v7api('company.getVisitReviews', { idx_company })` 호출로 데이터를 로드하며,
후기가 없으면 섹션을 숨긴다 (`v-if="reviews.length > 0"`).

---

## 6. 포인트 로그 시스템 (공통 인프라)

### 6.1 핵심 개념

모든 포인트 이벤트의 공통 기반. `sf_point_log` 테이블에 모든 포인트 변동을 기록한다.

**파일**: `lib/point_log/PointLogController.php`, `lib/point_log/PointLogService.php`, `lib/point_log/PointLogRepository.php`, `lib/point_log/PointLogEntity.php`

### 6.2 핵심 메서드 — PointLogService::changePoints()

```php
// 포인트 변경 (모든 이벤트에서 공통 사용)
$log = PointLogService::changePoints([
    'idx_member' => $idxMember,     // 대상 회원
    'points' => 100,                // 양수=증가, 음수=감소
    'module' => 'event',            // 모듈명
    'action' => 'spin_reward',      // 액션명
    'idx_post' => 0,                // 관련 게시글 (없으면 0)
    'etc' => 'spin_reward_100',     // 기타 정보
]);
```

**처리 흐름**: 인증 확인 → 파라미터 검증 → 현재 포인트 조회 → 계산 → 최소값 0 검증 → sf_point_log INSERT → sf_member.point UPDATE

### 6.3 API 엔드포인트 (11개)

| 메서드 | 용도 |
|--------|------|
| `pointLog.changePoints` | 포인트 변경 (핵심) |
| `pointLog.get` | 로그 단건 조회 |
| `pointLog.history` | 히스토리 조회 (페이지네이션) |
| `pointLog.logsByPost` | 게시글별 로그 조회 |
| `pointLog.memberPoint` | 회원 포인트 조회 |
| `pointLog.recentCount` | 최근 액션 횟수 (Throttling) |
| `pointLog.weeklyCount` | 주간 액션 횟수 |
| `pointLog.sumByPost` | 게시글별 포인트 합산 |
| `pointLog.update` | 로그 수정 (메타 정보만) |
| `pointLog.delete` | 로그 삭제 |

### 6.4 module/action 매트릭스 (전체 이벤트)

| module | action | etc | 용도 |
|--------|--------|-----|------|
| `event` | `spin_cost` | `spin_cost` | 스피닝 휠 참가비 -200P |
| `event` | `spin_reward` | `spin_reward_{N}` | 스피닝 휠 당첨 +NP |
| `event` | `spin_reward` | `spin_reward_starbucks:{파일}` | 스타벅스 쿠폰 당첨 |
| `company` | `qr_scan` | `{업소명} QR 스캔 보상` | QR 스캔 +1,000~2,000P |
| `company` | `qr_revisit` | `{업소명} 재방문 보상` | 재방문 +2,000~3,000P |
| `company` | `visit_review` | `{업소명} 방문 후기 보상 (usage_idx:{N})` | 후기 +2,000~3,000P |
| `post` | `create` | `point_write` | 글 작성 포인트 |
| `post` | `delete` | `point_write_delete` | 글 삭제 환급 |
| `comment` | `create` | `point_comment` | 코멘트 포인트 |
| `point_event` | `mukbang_create` | `mukbang_event_base` | 먹방 이벤트 (기본) |
| `point_event` | `mukbang_create` | `mukbang_event_bonus` | 먹방 이벤트 (보너스) |
| `admin` | `update` | `admin-point-update` | 관리자 수동 수정 |

### 6.5 레거시 호환

| 레거시 함수 | v7 대응 |
|------------|---------|
| `change_user_points()` | `PointLogService::changePoints()` |
| `get_point_history_count_within()` | `PointLogService::getRecentActionCount()` |
| `increase_user_points_for_post_create()` | `changePoints(module='post', action='create')` |

---

## 7. DB 스키마 요약

### 설계 문서 vs 실제 구현 테이블 매핑

> **⚠️ 참고**: [client-point-event-spin.md](client-point-event-spin.md)는 초기 설계 문서로,
> 설계 단계에서 `point_event_qr`, `point_event_history` 테이블을 계획했으나,
> 실제 구현에서는 아래와 같이 `company_` 접두사 테이블로 변경되었다.

| 초기 설계 (레거시) | 실제 구현 | 변경 사유 |
|---|---|---|
| `point_event_qr` | `company_qr_codes` | 업소록(company) 모듈에 통합 |
| `point_event_history` | `company_qr_code_usages` | 스캔 기록 전용 테이블로 분리 |
| *(point_event_history.content)* | `company_reviews` | 후기를 별도 테이블로 분리 (사진 연결 등) |

**현재 사용 중인 테이블 5개:**

| 테이블 | 용도 | 모듈 |
|---|---|---|
| `event_spin_history` | 스피닝 휠 게임 기록 | event |
| `company_qr_codes` | QR 코드 발행/검증/만료 | company |
| `company_qr_code_usages` | QR 스캔 기록 (성공/실패/거부) | company |
| `company_reviews` | 방문 후기 + 포인트 적립 | company |
| `sf_point_log` | 포인트 변동 이력 (공통) | 공통 |

### event_spin_history (스피닝 휠 기록)

```sql
CREATE TABLE `event_spin_history` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_member` int(10) UNSIGNED NOT NULL,
  `section_index` tinyint(3) UNSIGNED NOT NULL COMMENT '0~9',
  `prize_type` varchar(16) NOT NULL COMMENT 'miss|point|starbucks',
  `points_cost` int(10) UNSIGNED NOT NULL DEFAULT 200,
  `points_reward` int(10) NOT NULL DEFAULT 0,
  `starbucks_coupon_file` varchar(255) DEFAULT NULL,
  `random_value` int(10) UNSIGNED NOT NULL COMMENT '감사 추적용 난수',
  `point_before` int(11) NOT NULL DEFAULT 0,
  `point_after` int(11) NOT NULL DEFAULT 0,
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ip` varchar(45) NOT NULL DEFAULT '',
  PRIMARY KEY (`idx`),
  KEY `idx_member` (`idx_member`),
  KEY `idx_member_created` (`idx_member`, `created_at`),
  KEY `starbucks_coupon_file` (`starbucks_coupon_file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### company_qr_codes (QR 코드)

```sql
CREATE TABLE `company_qr_codes` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_company` int(10) UNSIGNED NOT NULL,
  `idx_member` int(10) UNSIGNED NOT NULL,
  `verification_id` varchar(64) NOT NULL COMMENT '고유 검증 ID',
  `status` char(1) NOT NULL DEFAULT 'a' COMMENT 'a=활성, d=비활성',
  `created_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `expired_at` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'time()+180',
  `used_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`idx`),
  UNIQUE KEY `uk_verification_id` (`verification_id`),
  KEY `idx_company` (`idx_company`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### company_qr_code_usages (QR 사용 기록)

```sql
CREATE TABLE `company_qr_code_usages` (
  `idx` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `idx_qr_code` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `idx_company` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `idx_member` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=비회원',
  `verification_id` varchar(64) NOT NULL DEFAULT '',
  `scanned_at` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `result` char(1) NOT NULL DEFAULT '' COMMENT 's=성공, f=실패, r=거부(24h중복)',
  `device_type` varchar(32) NOT NULL DEFAULT '',
  `ip_address` varchar(45) NOT NULL DEFAULT '',
  `user_agent` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`idx`),
  KEY `idx_company_member` (`idx_company`, `idx_member`),
  KEY `idx_qr_code` (`idx_qr_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### company_reviews (방문 후기)

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

> 사진은 `uploads` 테이블에 `module='company'`, `code='visit_review'`, `attached_to=company_reviews.idx`로 연결.

### sf_point_log (포인트 로그 — 기존 테이블)

| 주요 컬럼 | 설명 |
|-----------|------|
| `idx_member_from` | 포인트를 보낸 회원 (시스템=0) |
| `idx_member_to` | 포인트를 받은 회원 (실제 변경 대상) |
| `point_before` | 변경 전 포인트 |
| `point` | 변경량 (양수/음수) |
| `point_after` | 변경 후 포인트 |
| `module` | 모듈명 (event, company, post, ...) |
| `action` | 액션명 (spin_cost, qr_scan, ...) |
| `etc` | 기타 정보/사유 |
| `stamp` | Unix 타임스탬프 |

---

## 8. 파일 구조 및 참조 문서

### PHP 서버 파일

```
lib/event/
├── EventController.php        ← event.spin, event.history API
├── EventService.php           ← spin(), calculateSpinResult(), getAvailableStarbucksCoupons()
└── EventRepository.php        ← event_spin_history CRUD

lib/company/
├── CompanyController.php      ← company.* API (QR + 후기 포함)
├── CompanyService.php         ← issueQrCode(), scanQrCode(), reVisitPoint(), submitVisitReview(), getVisitReviews()
├── CompanyRepository.php      ← company 테이블 CRUD
├── QrCodeRepository.php       ← company_qr_codes 테이블 CRUD
├── QrCodeUsageRepository.php  ← company_qr_code_usages 테이블 CRUD
├── QrCodeEntity.php           ← QR 코드 데이터 구조체
├── VisitReviewEntity.php      ← 방문 후기 데이터 구조체
└── VisitReviewRepository.php  ← company_reviews 테이블 CRUD

lib/point_log/
├── PointLogController.php     ← pointLog.* API (11개)
├── PointLogService.php        ← changePoints(), getHistory() 등
├── PointLogRepository.php     ← sf_point_log 테이블 CRUD
└── PointLogEntity.php         ← 포인트 로그 데이터 구조체

event/cupon/starbucks/         ← 스타벅스 쿠폰 이미지 저장 폴더

company/
├── qr-code-scanned.php        ← QR 스캔 성공 감사 페이지 (후기 CTA 포함)
├── re-visit-point.php         ← 재방문 포인트 적립 페이지 (후기 CTA 포함)
├── visit-review-point.php     ← 후기 작성 폼 페이지 (Vue.js + v7api)
└── view.php                   ← 업소 상세 페이지 (후기 목록 표시)

js/v7api.js                    ← v7api(), v7apiUpload() 헬퍼 함수
```

### 상세 참조 문서

| 문서 | 내용 | 라인 수 |
|------|------|--------|
| [api/v7-event.md](../api/v7-event.md) | 스피닝 휠 서버 API 전체 (CoT/ToT, 아키텍처, PEST 테스트) | ~1,100 |
| [event/server-point-event-spin.md](server-point-event-spin.md) | 서버 포인트 이벤트 상세 (확률, 쿠폰, 트랜잭션) | ~1,300 |
| [event/client-point-event-spin.md](client-point-event-spin.md) | 클라이언트 삼단콤보 (QR 스캔, 재방문, 후기) | ~1,700 |
| [api/v7-point-log.md](../api/v7-point-log.md) | 포인트 로그 시스템 (11개 API, 레거시 호환) | ~500 |
| [app/v7-event-entry.md](../app/v7-event-entry.md) | Flutter 스피닝 휠 위젯 (CustomPainter, Auto Spin, 사운드) | ~1,000 |
| [api/v7-company.md](../api/v7-company.md) | 업소록 API (QR 발행/스캔 포함) | ~900 |
| [api/v7-company-qr-code.md](../api/v7-company-qr-code.md) | 업소록 QR 코드 상세 | ~900 |

### 보안 요약

| 위협 | 방어 |
|------|------|
| 클라이언트 확률 조작 | 서버 100% 결과 선결정 |
| QR 코드 위조 | 256비트 CSPRNG 랜덤 |
| QR 재사용 | 24시간 중복 검사 + result 기록 |
| 자기 업소 스캔 | idx_member_created 비교 |
| 포인트 조작 | 서버 random_int() + 트랜잭션 |
| 감사 추적 | random_value, ip, starbucks_coupon_file 저장 |
| 후기 중복 작성 | usage_idx UNIQUE 제약 + existsByUsageIdx() 검증 |
| 후기 타인 스캔 도용 | idx_member 비교로 본인 스캔 기록만 허용 |
| 후기 내용 검증 | 최소 10자 + 사진 1장 이상 필수 |

---

## 9. 테스트 방법

### 9.1 QR 코드 스캔 테스트

업소록 QR 코드 스캔 및 포인트 적립 기능을 테스트하려면, **관리자 계정**을 활용하여 QR 코드를 대량 생성하고 스캔하는 방법이 가장 효율적이다.

#### 사전 준비

1. **개발 서버 접속**: 필고 개발 홈페이지(`https://banana.philgo.com`)에 접속한다
2. **관리자 로그인**: 관리자 계정으로 로그인한다
   - 관리자 계정은 일반 사용자와 달리 **모든 업소의 QR 코드를 조회하고 생성**할 수 있는 권한을 가진다

#### 테스트 절차

##### Step 1: 업소록에서 QR 코드 확인

1. 개발 홈페이지에서 **업소록** 페이지로 이동한다
2. 관리자로 로그인된 상태에서는 모든 업소 목록에 **QR 코드 바로보기** 기능이 표시된다
3. 원하는 업소를 선택하면 해당 업소의 QR 코드를 즉시 확인할 수 있다

##### Step 2: QR 코드 임의 생성

- 관리자는 **여러 업소의 QR 코드를 임의로 생성**할 수 있다
- 업소록 목록에서 QR 코드가 없는 업소에도 새로운 QR 코드를 발행할 수 있다
- 이를 통해 **다양한 업소의 QR 코드를 대량으로 준비**하여 테스트에 활용할 수 있다

##### Step 3: Flutter 앱에서 스캔 테스트

1. Flutter 앱을 개발 서버에 연결한 상태로 실행한다
2. 앱의 **QR 스캔** 기능으로 위에서 생성한 QR 코드를 스캔한다
3. 다음 항목들을 검증한다:
   - QR 스캔 후 **포인트 적립** 정상 동작 여부
   - **24시간 중복 스캔 방지** 로직 동작 확인 (같은 업소를 다시 스캔했을 때 차단되는지)
   - **자기 업소 스캔 차단** 로직 확인 (본인이 등록한 업소의 QR 코드를 스캔했을 때)
   - **재방문 포인트 추첨** 결과 확인 (이전에 방문한 업소를 다시 방문했을 때)
   - 스캔 결과 화면의 **포인트, 업소 정보, 에러 메시지** 표시 확인

#### 관리자 계정의 테스트 이점

| 이점 | 설명 |
|------|------|
| **QR 코드 대량 생성** | 관리자는 모든 업소에 QR 코드를 임의로 생성할 수 있어, 다양한 시나리오를 빠르게 준비 가능 |
| **모든 업소 접근** | 일반 사용자와 달리 업소록의 모든 업소에 대해 QR 코드를 바로 확인 가능 |
| **반복 테스트 용이** | 여러 업소의 QR 코드를 미리 생성해두면 스캔 → 포인트 적립 → 재방문 → 후기 전체 흐름을 반복 테스트 가능 |
| **에러 시나리오 재현** | 중복 스캔, 자기 업소 스캔, 만료된 QR 코드 등 다양한 에러 케이스를 쉽게 재현 가능 |

#### 테스트 체크리스트

- [ ] 정상 QR 스캔 → 포인트 적립 성공
- [ ] 동일 업소 24시간 내 재스캔 → 중복 차단 확인
- [ ] 자기 업소 QR 스캔 → 차단 메시지 확인
- [ ] 재방문 업소 스캔 → 재방문 보너스 포인트 추첨 확인
- [ ] 스캔 후 후기 작성 CTA → 후기 포인트 적립 확인
- [ ] sf_point_log 테이블에 기록 정상 저장 확인
