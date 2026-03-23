# 이벤트 응모 (스피닝 휠) 시스템 상세 문서

## 목차

1. [개요](#개요)
2. [COT (Chain-of-Thought) 분석](#cot-chain-of-thought-분석)
3. [TOT (Tree-of-Thought) 분석](#tot-tree-of-thought-분석)
4. [화면 구조](#화면-구조)
5. [스피닝 휠 위젯 아키텍처](#스피닝-휠-위젯-아키텍처)
6. [데이터 모델](#데이터-모델)
7. [가중치 기반 섹션 시스템](#가중치-기반-섹션-시스템)
8. [CustomPainter 렌더링](#custompainter-렌더링)
9. [회전 애니메이션 메커니즘](#회전-애니메이션-메커니즘)
10. [서버 기반 안티치트 설계](#서버-기반-안티치트-설계)
11. [연속 돌리기 (Auto Spin)](#연속-돌리기-auto-spin)
12. [사운드 효과 시스템](#사운드-효과-시스템)
13. [v7 API 연동](#v7-api-연동)
14. [사용자 프로필 섹션](#사용자-프로필-섹션)
15. [다국어(l10n) 지원](#다국어l10n-지원)
16. [라우팅](#라우팅)
17. [에러 처리 및 복원력](#에러-처리-및-복원력)
18. [파일 구조](#파일-구조)
19. [향후 개선 방향](#향후-개선-방향)

---

## 개요

필고 앱의 **스피닝 휠(원판 돌리기) 기반 이벤트 응모 시스템**.
사용자가 원판을 돌려 랜덤 포인트를 획득하는 게임 메커니즘으로,
서버에서 결과를 미리 결정하여 클라이언트 조작을 방지하는 안티치트 설계를 포함한다.

### 핵심 특징

| 항목 | 설명 |
|------|------|
| **렌더링** | CustomPainter 기반 원판 (가중치 비율 각도 분할) |
| **애니메이션** | AnimationController + easeOutCubic 곡선 |
| **안티치트** | 서버 선결정 결과 → 클라이언트가 해당 섹션에 정렬 |
| **Auto Spin** | N회 반복 / 조건 충족 시까지 연속 돌리기 |
| **사운드** | audioplayers 패키지, 음소거 토글 |
| **프로필** | v7 API `user.me`로 사용자 정보 + 포인트 실시간 표시 |
| **다국어** | 한/영/일/중 4개 언어 지원 |

### 기술 스택

| 영역 | 라이브러리 | 용도 |
|------|-----------|------|
| UI | Flutter Material 3 | Theme 기반 디자인 |
| 진입 애니메이션 | flutter_animate | fadeIn, slideY |
| 회전 | AnimationController | easeOutCubic 6초 회전 |
| 아이콘 | font_awesome_flutter | 섹션/버튼 아이콘 |
| 그래픽 | CustomPaint | 원판 + 링 + 포인터 |
| 사운드 | audioplayers | 회전 효과음 |
| API | Dio + v7api() | HTTP POST |
| 인증 | Firebase Auth | ID Token |
| 라우팅 | go_router | 화면 전환 |
| 다국어 | intl (ARB) | 4개 언어 |

---

## COT (Chain-of-Thought) 분석

### 1단계: 문제의 핵심 이해

**문제**: 업소 방문 이벤트에서 사용자가 원판을 돌려 포인트를 획득하는 게임을 구현해야 한다.

**핵심 요구사항**:
- 시각적으로 매력적인 원판 UI (CustomPainter)
- 가중치 기반의 불균등 확률 (꽝 30%, 고포인트 5%)
- 서버에서 결과를 미리 결정하여 클라이언트 조작 방지
- 연속 돌리기 기능으로 반복 게임 편의성 제공
- 효과음으로 몰입감 증대

**기존 시스템과의 관계**:
```
업소 방문 → QR 코드 스캔 → 포인트 획득 → 이벤트 응모(원판 돌리기)
                                              ↑ 본 문서의 범위
```

### 2단계: 해결 전략 수립

| 과제 | 해결 방법 |
|------|----------|
| 원판 시각화 | CustomPainter (Canvas.drawArc + TextPainter) |
| 가중치 비율 | weight 기반 sweepAngle 계산 |
| 부드러운 회전 | AnimationController + easeOutCubic |
| 정확한 정렬 | 타겟 섹션 중앙각 역산 + jitter |
| 안티치트 | onSpinRequested 콜백으로 서버 결과 수신 |
| 연속 돌리기 | autoSpinRemaining / autoSpinUntilCondition |
| 사운드 | AudioPlayer + 음소거 토글 |

### 3단계: 아키텍처 결정

**재사용 가능한 위젯 설계**:
- `SpinningWheel` 위젯은 섹션 데이터와 콜백만 받음
- 이벤트 응모 화면(`EventEntryScreen`)이 섹션 정의와 서버 연동 담당
- 결과 UI는 `resultBuilder` 콜백으로 외부에서 주입

```
EventEntryScreen (비즈니스 로직)
    ├─ 섹션 정의 (_sections)
    ├─ 서버 호출 (onSpinRequested)
    ├─ 결과 UI (resultBuilder)
    └─ 사용자 정보 (UserApi.me)

SpinningWheel (재사용 위젯)
    ├─ 원판 렌더링 (_WheelPainter)
    ├─ 회전 애니메이션 (AnimationController)
    ├─ Auto Spin 로직
    └─ 사운드 (AudioPlayer)
```

### 4단계: 구현 핵심 알고리즘

**회전각 계산**: 타겟 섹션의 중앙이 12시 포인터에 정확히 정렬되도록
```
targetCenterAngle = startAngles[targetIndex] + sweep / 2
targetNormalized = (2π - targetCenterAngle) % (2π)
delta = targetNormalized - currentNormalized
totalRotation = extraTurns * 2π + delta + jitter
```

**jitter**: ±30% of sweep 범위의 미세 변동으로 자연스러움 확보

### 5단계: 테스트 전략

- 테스트 선택 UI로 특정 섹션에 정확히 멈추는지 검증
- 가중치 변경 시 원판 비율이 정확히 반영되는지 확인
- Auto Spin에서 조건 충족 시 정확히 멈추는지 확인
- 사운드 음소거 상태에서 재생되지 않는지 확인
- mounted 보호로 메모리 누수 없는지 확인

---

## TOT (Tree-of-Thought) 분석

### 하위 문제 분해

```
이벤트 응모 시스템
├─ [P1] 원판 시각화
│  ├─ [P1-1] 가중치 기반 섹션 분할
│  ├─ [P1-2] 섹션 배경색 + 라벨 텍스트
│  ├─ [P1-3] FontAwesome 아이콘 렌더링
│  ├─ [P1-4] 외곽 장식 링 + 도트
│  └─ [P1-5] 상단 포인터 (역삼각형)
│
├─ [P2] 회전 애니메이션
│  ├─ [P2-1] 타겟 섹션 정렬 각도 계산
│  ├─ [P2-2] easeOutCubic 감속 곡선
│  ├─ [P2-3] 추가 바퀴 회전 (랜덤성)
│  └─ [P2-4] jitter 자연스러움
│
├─ [P3] 서버 연동 (안티치트)
│  ├─ [P3-1] onSpinRequested 콜백 패턴
│  ├─ [P3-2] 서버 선결정 인덱스 수신
│  └─ [P3-3] 클라이언트 랜덤 폴백 (테스트용)
│
├─ [P4] 연속 돌리기
│  ├─ [P4-1] N회 반복 모드
│  ├─ [P4-2] 조건 충족 모드
│  ├─ [P4-3] 빠른 회전 속도 (2.5초)
│  └─ [P4-4] 중지 + 속도 복원
│
├─ [P5] 사운드
│  ├─ [P5-1] AudioPlayer 재생/중지
│  └─ [P5-2] 음소거 토글 UI
│
├─ [P6] 사용자 정보
│  ├─ [P6-1] v7 API user.me 호출
│  ├─ [P6-2] 3상태 관리 (로딩/에러/성공)
│  └─ [P6-3] 프로필 + 포인트 뱃지
│
└─ [P7] 다국어
   ├─ [P7-1] ARB 키 정의
   └─ [P7-2] 4개 언어 번역
```

### 각 하위 문제의 해결 방안

| 문제 | 해결 방안 | 복잡도 |
|------|----------|--------|
| P1-1 | weight / totalWeight * 2π → sweepAngle | 낮음 |
| P1-2 | Canvas.drawArc + TextPainter | 중간 |
| P1-3 | FontAwesome codePoint → TextPainter | 높음 |
| P2-1 | 역각도 계산 + 바퀴 수 추가 | 높음 |
| P3-1 | Future<int> 콜백으로 추상화 | 낮음 |
| P4-1 | 카운트다운 + 딜레이 루프 | 중간 |
| P4-2 | stopCondition 콜백 + 결과 체크 | 중간 |
| P6-1 | UserApi.me() + setState | 낮음 |

### 통합 및 검증

- P1(시각화) + P2(애니메이션) → Transform.rotate로 연결
- P3(서버) + P2(애니메이션) → onSpinRequested가 타겟 인덱스 결정, 회전각 계산에 주입
- P4(Auto Spin) + P5(사운드) → 각 회전마다 사운드 재생/중지 자동 관리
- P6(사용자) + P7(다국어) → 프로필 섹션과 결과 메시지에 적용

---

## 화면 구조

### EventEntryScreen 레이아웃

```
┌─────────────────────────────────────┐
│  AppBar: "이벤트 응모"               │
└─────────────────────────────────────┘
│
├─ [1] 사용자 프로필 섹션 (animated)
│  ├─ 프로필 사진 (네트워크 또는 기본 아이콘)
│  ├─ 사용자 이름 (name > nickname > id)
│  ├─ 레벨 (Lv.N 또는 Lv...)
│  └─ 포인트 뱃지 (천 단위 콤마, "13,915P")
│
├─ [2] 테스트용 결과 선택 UI (개발 단계용)
│  └─ DropdownButton (Random / 각 섹션 선택)
│
└─ [3] SpinningWheel 위젯
   ├─ 안내 텍스트
   ├─ 원판 + 포인터 + 외곽 장식
   ├─ 버튼 영역
   │  ├─ 돌리기 / 중지 버튼
   │  ├─ Auto Spin 드롭다운
   │  └─ 음소거 토글
   └─ 결과 배너 (당첨/꽝/쿠폰)
```

---

## 스피닝 휠 위젯 아키텍처

### 클래스 계층

```
SpinningWheel (StatefulWidget)
├─ _SpinningWheelState (with SingleTickerProviderStateMixin)
│  ├─ AnimationController + Animation<double>
│  ├─ AudioPlayer
│  ├─ CustomPaint x 3
│  │  ├─ _WheelPainter      (섹션 배경 + 라벨 + 아이콘)
│  │  ├─ _OuterRingPainter   (외곽 링 + 12개 도트)
│  │  └─ _PointerPainter     (상단 역삼각형 포인터)
│  └─ Auto Spin 상태 관리
│
├─ WheelSection (데이터 모델)
└─ AutoSpinOption (연속 돌리기 옵션)
```

### SpinningWheel 주요 프로퍼티

| 프로퍼티 | 타입 | 설명 |
|----------|------|------|
| `sections` | `List<WheelSection>` | 원판 섹션 목록 (필수) |
| `onSpinRequested` | `Future<int> Function()?` | 서버에서 타겟 인덱스 반환 |
| `onResult` | `ValueChanged<WheelSection>?` | 결과 콜백 |
| `resultBuilder` | `Widget Function(WheelSection)?` | 결과 UI 빌더 |
| `instructionText` | `String` | 안내 텍스트 (필수) |
| `spinButtonText` | `String` | 돌리기 버튼 텍스트 (필수) |
| `autoSpinButtonText` | `String?` | Auto Spin 버튼 텍스트 |
| `autoSpinStopText` | `String?` | 중지 버튼 텍스트 |
| `autoSpinOptions` | `List<AutoSpinOption>?` | Auto Spin 옵션 |
| `autoSpinStopCondition` | `bool Function(WheelSection)?` | Auto Spin 중지 조건 |

---

## 데이터 모델

### WheelSection

```dart
class WheelSection {
  final String label;       // 표시 텍스트 ("50", "1,000", "꽝" 등)
  final Color color;        // 섹션 배경색
  final int points;         // 포인트 (0=꽝, -1=쿠폰/특별상품)
  final double weight;      // 상대적 크기 비중 (기본 1.0)
  final IconData? icon;     // FontAwesome 아이콘 (선택)
  final int iconCount;      // 아이콘 반복 횟수 (기본 1)
}
```

### AutoSpinOption

```dart
class AutoSpinOption {
  final String label;       // UI 표시 텍스트 ("5회", "쿠폰 나올 때까지")
  final int count;          // 반복 횟수 (-1 = 조건 충족까지)
}
```

### EventEntryScreen 섹션 정의

```dart
_sections = [
  WheelSection(label: '50',    color: Color(0xFFE88B8B), points: 50,   weight: 30),
  WheelSection(label: '500',   color: Color(0xFFF5B971), points: 500,  weight: 20),
  WheelSection(label: '1,000', color: Color(0xFFC9A9C9), points: 1000, weight: 10,
    icon: FontAwesomeIcons.solidStar),
  WheelSection(label: '2,000', color: Color(0xFF9CC2D8), points: 2000, weight: 5,
    icon: FontAwesomeIcons.solidStar, iconCount: 2),
  WheelSection(label: '스타벅스 쿠폰', color: Color(0xFF8BC78B), points: -1, weight: 5,
    icon: FontAwesomeIcons.lightMugHot),
  WheelSection(label: '꽝',    color: Color(0xFFB0B0B0), points: 0,    weight: 30),
];
```

### 확률 분석

| 섹션 | Weight | 확률 | 각도 |
|------|--------|------|------|
| 50P | 30 | 30% | 108° |
| 500P | 20 | 20% | 72° |
| 1,000P | 10 | 10% | 36° |
| 2,000P | 5 | 5% | 18° |
| 스타벅스 쿠폰 | 5 | 5% | 18° |
| 꽝 | 30 | 30% | 108° |
| **합계** | **100** | **100%** | **360°** |

---

## 가중치 기반 섹션 시스템

### 각도 계산 공식

```dart
/// 전체 weight 합계
double get _totalWeight =>
    sections.fold(0.0, (sum, s) => sum + s.weight);

/// 각 섹션의 시작 각도 (라디안)
List<double> get _sectionStartAngles {
  final total = _totalWeight;
  final angles = <double>[];
  double cumulative = 0;
  for (final section in sections) {
    angles.add(cumulative / total * 2 * pi);
    cumulative += section.weight;
  }
  return angles;
}

/// 특정 섹션의 각도 크기 (라디안)
double _sectionSweep(int index) {
  return sections[index].weight / _totalWeight * 2 * pi;
}
```

### 섹션별 각도 범위 예시 (총 weight = 100)

```
인덱스 0 (50P, weight=30):   0° ~ 108°     (sweep = 108°)
인덱스 1 (500P, weight=20):  108° ~ 180°   (sweep = 72°)
인덱스 2 (1000P, weight=10): 180° ~ 216°   (sweep = 36°)
인덱스 3 (2000P, weight=5):  216° ~ 234°   (sweep = 18°)
인덱스 4 (쿠폰, weight=5):   234° ~ 252°   (sweep = 18°)
인덱스 5 (꽝, weight=30):    252° ~ 360°   (sweep = 108°)
```

---

## CustomPainter 렌더링

### _WheelPainter (원판 메인)

**렌더링 순서**:

1. **섹션 배경** (`Canvas.drawArc`): weight 기반 부채꼴
2. **구분선** (흰색, alpha 0.6, strokeWidth 2)
3. **라벨 텍스트** (radius * 0.55 위치, 안쪽)
4. **아이콘** (조건부, radius * 0.82~0.88 위치, 바깥쪽)
5. **외곽 테두리** (흰색, strokeWidth 3)

### 아이콘 렌더링 상세

FontAwesome 아이콘을 TextPainter로 렌더링하는 핵심 기법:

```dart
final icon = sections[i].icon!;
final count = sections[i].iconCount;
final iconText = String.fromCharCode(icon.codePoint) * count;

final iconPainter = TextPainter(
  text: TextSpan(
    text: iconText,
    style: TextStyle(
      fontFamily: icon.fontFamily,    // FontAwesome 폰트 패밀리
      package: icon.fontPackage,      // 'font_awesome_flutter' 패키지
      fontSize: count == 1 ? 16.0 : 13.0,
      color: Colors.white,
      letterSpacing: count > 1 ? 2 : 0,
      shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
    ),
  ),
  textDirection: TextDirection.ltr,
);
```

**아이콘 위치 분기**:

| 조건 | 폰트 크기 | 위치 (radius 배수) | 이유 |
|------|----------|-------------------|------|
| iconCount == 1 (별 1개, 커피) | 16.0 | 0.88 | 단일 아이콘은 더 바깥쪽 |
| iconCount > 1 (별 2개) | 13.0 | 0.82 | 복수 아이콘은 넓이 확보 위해 안쪽 |

### 텍스트 + 아이콘 배치도

```
     포인터 (12시)
        ▼
    ┌─────────┐
    │ ★ 아이콘 │ radius * 0.82~0.88 (가장자리)
    │          │
    │ "1,000"  │ radius * 0.55 (안쪽)
    │  라벨    │
    └─────────┘
        중앙
```

### _OuterRingPainter (외곽 장식)

- 외곽 링 배경 (alpha 0.3, strokeWidth 8)
- 12개 장식 도트 (시계처럼 균등 분포, dotRadius 3.0)

### _PointerPainter (상단 포인터)

- 역삼각형 (Path: 좌상 → 우상 → 하단 중앙)
- error 색상 (빨간색) 사용

---

## 회전 애니메이션 메커니즘

### AnimationController 설정

```dart
_controller = AnimationController(
  vsync: this,
  duration: Duration(milliseconds: 6000),  // 일반 회전
);

_animation = Tween<double>(begin: 0, end: 1).animate(
  CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
);
```

**곡선 특성**: `easeOutCubic` — 빠르게 시작, 천천히 감속하며 정지

### 회전각 계산 알고리즘

```dart
double _calculateRotationForTarget(int targetIndex) {
  // 1. 타겟 섹션의 중앙 각도
  final targetCenterAngle = startAngles[targetIndex] + sweep / 2;

  // 2. 포인터(12시)에 맞추기 위한 정규화
  //    원판이 시계반대방향으로 회전하므로 역산
  final targetNormalized = (2π - targetCenterAngle) % (2π);
  final currentNormalized = _currentAngle % (2π);

  // 3. 필요한 회전 델타
  var delta = targetNormalized - currentNormalized;
  if (delta < 0) delta += 2π;

  // 4. 추가 바퀴 (자연스러움)
  //    일반: 5~8바퀴, Auto Spin: 2~3바퀴
  final extraTurns = _isAutoSpinning
      ? 2 + random.nextInt(2)
      : 5 + random.nextInt(4);

  // 5. jitter (±30% of sweep, 미세 변동)
  final jitter = (random.nextDouble() - 0.5) * sweep * 0.6;

  return extraTurns * 2π + delta + jitter;
}
```

### 회전 적용

```dart
// Transform.rotate로 원판 회전 (CustomPaint 재페인트 불필요)
Transform.rotate(
  angle: _currentAngle,
  child: CustomPaint(painter: _WheelPainter(sections: sections)),
)
```

### 당첨 섹션 판별

```dart
void _notifyResult() {
  final normalizedAngle = _currentAngle % (2π);
  final pointerAngle = (2π - normalizedAngle) % (2π);

  for (int i = 0; i < sections.length; i++) {
    final start = _sectionStartAngles[i];
    final end = start + _sectionSweep(i);
    if (pointerAngle >= start && pointerAngle < end) {
      sectionIndex = i;
      break;
    }
  }
}
```

---

## 서버 기반 안티치트 설계

### 핵심 원칙

> **결과를 서버에서 미리 결정하고, 클라이언트는 해당 결과에 맞춰 원판을 회전.**
> DevTools 조작으로도 다른 섹션에 도달할 수 없음.

### 구현 패턴

```dart
/// SpinningWheel의 onSpinRequested 콜백
onSpinRequested: () async {
  // 서버 API 호출 → 당첨 섹션 인덱스 반환
  final result = await v7api('event.spin', data: {...});
  return result['section_index'] as int;
},
```

### 현재 상태 (테스트 모드)

```dart
/// EventEntryScreen._resolveTargetIndex()
int _resolveTargetIndex() {
  // 테스트 선택값이 있으면 반환
  if (_testTargetIndex != null) return _testTargetIndex!;
  // 클라이언트 랜덤 (서버 연동 전 임시)
  return DateTime.now().microsecond % _sections.length;
}
```

### 향후 서버 API 구조 (예상)

```
POST api.php
  method: event.spin
  event_id: 123
  → 서버에서 가중치 기반 랜덤 결정
  → { section_index: 2, points: 1000 }
```

### 보안 레이어

| 레이어 | 구현 상태 | 설명 |
|--------|----------|------|
| 서버 선결정 | ✅ 설계됨 | onSpinRequested 콜백 패턴 |
| Firebase 인증 | ✅ 구현됨 | ID Token 자동 첨부 |
| 일일 제한 | ⬜ 미구현 | 서버에서 횟수 제한 필요 |
| 중복 방지 | ⬜ 미구현 | IP/디바이스 기반 검증 |

---

## 연속 돌리기 (Auto Spin)

### 옵션 정의

```dart
autoSpinOptions: [
  AutoSpinOption(label: '5회', count: 5),
  AutoSpinOption(label: '10회', count: 10),
  AutoSpinOption(label: '20회', count: 20),
  AutoSpinOption(label: '30회', count: 30),
  AutoSpinOption(label: '50회', count: 50),
  AutoSpinOption(label: '스타벅스 쿠폰 나올 때까지', count: -1),
],

/// 쿠폰(points == -1) 당첨 시 자동 중지
autoSpinStopCondition: (section) => section.points == -1,
```

### 상태 변수

```dart
int _autoSpinRemaining = 0;           // 남은 횟수 (0=비활성)
bool _autoSpinUntilCondition = false; // 조건 모드
bool get _isAutoSpinning =>
    _autoSpinRemaining > 0 || _autoSpinUntilCondition;
```

### Auto Spin 흐름

```
_startAutoSpin(option)
  ├─ count == -1 → _autoSpinUntilCondition = true
  └─ count > 0  → _autoSpinRemaining = count
  └─ 회전 속도 2.5초로 변경
  └─ _spin()
       ↓
  회전 완료 (_controller.completed)
       ↓
  _checkAutoSpin()
  ├─ 조건 모드: stopCondition 확인 → 중지 or 600ms 후 다음 _spin()
  └─ 횟수 모드: remaining-- → 0이면 중지, 아니면 600ms 후 다음 _spin()
       ↓
  _stopAutoSpin()
  └─ 속도 6초로 복원
```

### 회전 시간 비교

| 모드 | 회전 시간 | 추가 바퀴 | 간격 |
|------|----------|----------|------|
| 일반 | 6,000ms | 5~8 | - |
| Auto Spin | 2,500ms | 2~3 | 600ms |

---

## 사운드 효과 시스템

### AudioPlayer 관리

```dart
final AudioPlayer _audioPlayer = AudioPlayer();
bool _isMuted = false;

// 회전 시작 시
if (!_isMuted) {
  await _audioPlayer.play(AssetSource('sound/spinning_wheel.mp3'));
}

// 회전 종료 시
_audioPlayer.stop();

// 위젯 해제 시
@override
void dispose() {
  _audioPlayer.dispose();
  super.dispose();
}
```

### 음소거 토글 UI

```dart
Material(
  color: _isMuted ? scheme.errorContainer : scheme.surfaceContainerHighest,
  borderRadius: BorderRadius.circular(20),
  child: InkWell(
    onTap: () => setState(() => _isMuted = !_isMuted),
    child: FaIcon(
      _isMuted ? FontAwesomeIcons.lightVolumeXmark
               : FontAwesomeIcons.lightVolumeHigh,
    ),
  ),
)
```

### 사운드 파일

- 위치: `assets/sound/spinning_wheel.mp3`
- pubspec.yaml에 assets 등록 필요

---

## v7 API 연동

### UserApi.me() 호출

```dart
// lib/v7_api/user_api.dart
class UserApi {
  static Future<Map<String, dynamic>> me() async {
    return await v7api('user.me');
  }
}
```

### user.me 주요 응답 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `idx` | int | 회원 번호 |
| `id` | string | 이메일/아이디 |
| `name` | string | 이름 |
| `nickname` | string | 닉네임 |
| `phone_number` | string | 전화번호 |
| `photo_url` | string | 프로필 사진 URL |
| `point` | int | 보유 포인트 |
| `level` | int | 레벨 |
| `firebase_uid` | string | Firebase UID |

### 인증 흐름

```
Flutter → v7api('user.me')
  → patchToken() → Firebase ID Token 자동 첨부
  → Dio POST → api.php
  → AuthService::getLoginUser()
  → UserController::me()
  → JSON 응답
```

---

## 사용자 프로필 섹션

### 3상태 관리 패턴

| 상태 | 변수 | UI |
|------|------|-----|
| 로딩 중 | `_isUserLoading = true` | CircularProgressIndicator + "로딩 중..." |
| 에러 | `_userErrorMessage != null` | 경고 아이콘 + 에러 메시지 + 재시도 버튼 |
| 성공 | `_userInfo != null` | 프로필 사진 + 이름 + 레벨 + 포인트 뱃지 |

### 프로필 레이아웃

```
┌──────────────────────────────────────┐
│ [사진]  이름          [🪙 13,915P]  │
│         Lv.3                         │
└──────────────────────────────────────┘
```

### 표시 이름 결정 우선순위

```dart
final displayName = name.isNotEmpty ? name
    : nickname.isNotEmpty ? nickname
    : id;
```

### 포인트 포맷 (천 단위 콤마)

```dart
final pointFormatted = point.toString().replaceAllMapped(
  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]},',
);
// 결과: "13,915P"
```

---

## 다국어(l10n) 지원

### l10n 키 목록

| 키 | 한국어 | 영어 |
|----|--------|------|
| `spinWheelInstruction` | 원판을 돌려주세요! | Spin the wheel! |
| `spinWheelSpin` | 원판 돌리기 | Spin |
| `spinWheelMiss` | 꽝 | Miss |
| `spinWheelCoupon` | 스타벅스 쿠폰 | Starbucks Coupon |
| `spinWheelResultPoints` | {point}P 당첨! | Won {point}P! |
| `spinWheelResultMiss` | 아쉽지만 다음 기회에! | Better luck next time! |
| `spinWheelResultCoupon` | 스타벅스 쿠폰 당첨! | Won Starbucks Coupon! |
| `spinWheelAutoSpin` | 연속 돌리기 | Auto Spin |
| `spinWheelStop` | 중지 | Stop |
| `spinWheelUntilCoupon` | 스타벅스 쿠폰 나올 때까지 | Until Starbucks Coupon |
| `spinWheelAutoSpinCount` | {count}회 | {count} times |
| `quickMenuEventEntry` | 이벤트 응모 | Event Entry |

### 지원 언어

- 한국어 (`app_ko.arb`)
- 영어 (`app_en.arb`)
- 일본어 (`app_ja.arb`)
- 중국어 (`app_zh.arb`)

---

## 라우팅

### go_router 설정

```dart
// lib/router.dart
GoRoute(
  path: EventEntryScreen.routeName,   // '/event-entry'
  name: EventEntryScreen.routeName,
  builder: (context, state) => const EventEntryScreen(),
),
```

### 화면 이동 헬퍼

```dart
// EventEntryScreen
static const String routeName = '/event-entry';
static Future<dynamic> push(BuildContext context) =>
    context.push(routeName);
```

### 인증 요구

EventEntryScreen은 공개 라우트 목록에 없으므로 **로그인 필수**.
미로그인 시 라우터의 `redirect`에서 로그인 화면으로 이동.

---

## 에러 처리 및 복원력

### 네트워크 에러 (사용자 정보)

```dart
try {
  final result = await UserApi.me();
  setState(() { _userInfo = result; _isUserLoading = false; });
} catch (e) {
  setState(() { _userErrorMessage = e.toString(); _isUserLoading = false; });
}
```

재시도 버튼으로 `_loadUserInfo()` 재호출 가능.

### 사운드 에러

```dart
try {
  await _audioPlayer.play(AssetSource('sound/spinning_wheel.mp3'));
} catch (_) {
  // 사운드 실패해도 게임은 계속 진행
}
```

### mounted 보호

```dart
// 비동기 콜백에서 위젯 해제 상태 확인
if (!mounted) return;
setState(() { ... });

// Auto Spin 딜레이 콜백
Future.delayed(Duration(milliseconds: 600), () {
  if (mounted && _autoSpinUntilCondition) _spin();
});
```

### 리소스 해제

```dart
@override
void dispose() {
  _controller.dispose();    // AnimationController
  _audioPlayer.dispose();   // AudioPlayer
  super.dispose();
}
```

---

## 파일 구조

```
philgo_app/
├── lib/
│   ├── screens/event/
│   │   ├── event_entry.screen.dart       ← 이벤트 응모 메인 화면
│   │   └── company_event.screen.dart     ← 업소 이벤트 안내 화면
│   │
│   ├── widgets/
│   │   └── spinning_wheel.dart           ← 재사용 스피닝 휠 위젯
│   │
│   ├── v7_api/
│   │   ├── v7_api.dart                   ← v7 API 기본 함수
│   │   └── user_api.dart                 ← UserApi.me()
│   │
│   ├── l10n/
│   │   ├── app_ko.arb                    ← 한국어
│   │   ├── app_en.arb                    ← 영어
│   │   ├── app_ja.arb                    ← 일본어
│   │   └── app_zh.arb                    ← 중국어
│   │
│   └── router.dart                       ← 라우팅 (/event-entry)
│
└── assets/sound/
    └── spinning_wheel.mp3                ← 회전 효과음
```

---

## 향후 개선 방향

| 항목 | 현재 | 개선 방향 |
|------|------|----------|
| **서버 연동** | 클라이언트 랜덤 | v7 API `event.spin` 호출 |
| **결과 저장** | 메모리 상태만 | 서버에 기록 + 포인트 자동 지급 |
| **이력 조회** | 없음 | 과거 결과 목록 탭 추가 |
| **일일 제한** | 없음 | 횟수/시간 제한 서버 규칙 |
| **특수 이벤트** | 고정 섹션 | 시간대별/계절별 섹션 변경 |
| **보상 시스템** | 단순 포인트 | 연쇄 보너스, 콤보 시스템 |
| **소셜 기능** | 없음 | 친구 초대, 결과 공유 |
| **테스트 UI 제거** | 개발 단계 표시 | 서버 연동 완료 후 제거 |

---

## 관련 문서

| 문서 | 내용 |
|------|------|
| [v7-flutter-api.md](v7-flutter-api.md) | Flutter v7 API 연동 가이드 |
| [../api/v7-user.md](../api/v7-user.md) | User API (user.me 응답 필드 상세) |
| [../api/v7-point-event.md](../api/v7-point-event.md) | PointEvent API (먹방 이벤트 포인트) |
| [../../plan/point-event-pland.md](../../plan/point-event-pland.md) | 포인트 이벤트 전체 계획 |
