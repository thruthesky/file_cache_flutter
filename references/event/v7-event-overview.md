# 필고 v7 이벤트 시스템 통합 개요

> 이 문서는 필고 v7의 모든 포인트 이벤트 시스템을 하나로 통합 요약한다.
> 상세 구현은 각 서브 문서를 참조한다.

## 목차

- [1. 이벤트 시스템 전체 구조](#1-이벤트-시스템-전체-구조)
- [2. 스피닝 휠 이벤트 (서버)](#2-스피닝-휠-이벤트-서버)
- [3. 스피닝 휠 이벤트 (클라이언트 Flutter)](#3-스피닝-휠-이벤트-클라이언트-flutter)
- [4. 업소록 QR 코드 이벤트 (삼단콤보)](#4-업소록-qr-코드-이벤트-삼단콤보)
- [5. 포인트 로그 시스템 (공통 인프라)](#5-포인트-로그-시스템-공통-인프라)
- [6. DB 스키마 요약](#6-db-스키마-요약)
- [7. 파일 구조 및 참조 문서](#7-파일-구조-및-참조-문서)

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
│                │ point_event_   │                           │
│                │ history        │                           │
└────────────────┴────────────────┴───────────────────────────┘
```

### 이벤트 간 연결 흐름

```
사용자 업소 방문
  ↓
QR 코드 스캔 → 1,000~2,000P 즉시 적립
  ↓
재방문 판별 → 추가 2,000~3,000P 추첨
  ↓
후기 작성 → 추가 2,000~3,000P 적립
  ↓
획득한 포인트로 스피닝 휠 이벤트 참여
  ↓
200P 소비 → 확률 게임 → 50P~2,000P 또는 스타벅스 쿠폰
```

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
| 후기 작성 | `company` | `review` | +2,000~3,000 | `{업소명} 후기 보상` |

### 4.7 QR 코드 API 엔드포인트

| 메서드 | 용도 | 인증 |
|--------|------|------|
| `company.issueQrCode` | QR 코드 발행 (업소 소유자) | 필수 |
| `company.scanQrCode` | QR 코드 스캔 | 비로그인 가능 |
| `company.listQrCodes` | 발행된 QR 코드 목록 | 필수 |
| `company.listQrCodeUsages` | 스캔 기록 목록 | 필수 |
| `company.qrCodeStats` | 발행/스캔 통계 | 필수 |

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
sf_point_log (포인트 기록)
    ├─ module='company'
    └─ action='qr_scan'|'qr_revisit'|'review'
```

---

## 5. 포인트 로그 시스템 (공통 인프라)

### 5.1 핵심 개념

모든 포인트 이벤트의 공통 기반. `sf_point_log` 테이블에 모든 포인트 변동을 기록한다.

**파일**: `lib/point_log/PointLogController.php`, `lib/point_log/PointLogService.php`, `lib/point_log/PointLogRepository.php`, `lib/point_log/PointLogEntity.php`

### 5.2 핵심 메서드 — PointLogService::changePoints()

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

### 5.3 API 엔드포인트 (11개)

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

### 5.4 module/action 매트릭스 (전체 이벤트)

| module | action | etc | 용도 |
|--------|--------|-----|------|
| `event` | `spin_cost` | `spin_cost` | 스피닝 휠 참가비 -200P |
| `event` | `spin_reward` | `spin_reward_{N}` | 스피닝 휠 당첨 +NP |
| `event` | `spin_reward` | `spin_reward_starbucks:{파일}` | 스타벅스 쿠폰 당첨 |
| `company` | `qr_scan` | `{업소명} QR 스캔 보상` | QR 스캔 +1,000~2,000P |
| `company` | `qr_revisit` | `{업소명} 재방문 보상` | 재방문 +2,000~3,000P |
| `company` | `review` | `{업소명} 후기 보상` | 후기 +2,000~3,000P |
| `post` | `create` | `point_write` | 글 작성 포인트 |
| `post` | `delete` | `point_write_delete` | 글 삭제 환급 |
| `comment` | `create` | `point_comment` | 코멘트 포인트 |
| `point_event` | `mukbang_create` | `mukbang_event_base` | 먹방 이벤트 (기본) |
| `point_event` | `mukbang_create` | `mukbang_event_bonus` | 먹방 이벤트 (보너스) |
| `admin` | `update` | `admin-point-update` | 관리자 수동 수정 |

### 5.5 레거시 호환

| 레거시 함수 | v7 대응 |
|------------|---------|
| `change_user_points()` | `PointLogService::changePoints()` |
| `get_point_history_count_within()` | `PointLogService::getRecentActionCount()` |
| `increase_user_points_for_post_create()` | `changePoints(module='post', action='create')` |

---

## 6. DB 스키마 요약

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

## 7. 파일 구조 및 참조 문서

### PHP 서버 파일

```
lib/event/
├── EventController.php        ← event.spin, event.history API
├── EventService.php           ← spin(), calculateSpinResult(), getAvailableStarbucksCoupons()
└── EventRepository.php        ← event_spin_history CRUD

lib/company/
├── CompanyController.php      ← company.* API (QR 관련 포함)
├── CompanyService.php         ← issueQrCode(), scanQrCode(), reVisitPoint()
├── CompanyRepository.php      ← company 테이블 CRUD
├── QrCodeRepository.php       ← company_qr_codes 테이블 CRUD
├── QrCodeUsageRepository.php  ← company_qr_code_usages 테이블 CRUD
└── QrCodeEntity.php           ← QR 코드 데이터 구조체

lib/point_log/
├── PointLogController.php     ← pointLog.* API (11개)
├── PointLogService.php        ← changePoints(), getHistory() 등
├── PointLogRepository.php     ← sf_point_log 테이블 CRUD
└── PointLogEntity.php         ← 포인트 로그 데이터 구조체

event/cupon/starbucks/         ← 스타벅스 쿠폰 이미지 저장 폴더
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
