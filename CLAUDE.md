# 필고 v6 앱 개발 지침

이 문서는 필고 v6 앱 개발 시 AI와 협업할 때 반드시 따라야 할 규칙을 정리한 것입니다.

## 목차

1. [최우선 필수 규칙](#최우선-필수-규칙)
2. [코드 작성 규칙](#코드-작성-규칙)
3. [주석 및 문서화](#주석-및-문서화)
4. [개발 워크플로우](#개발-워크플로우)
5. [참고 문서](#참고-문서)

---

## 최우선 필수 규칙

### 1. main.dart Theme 수정 절대 금지

**규칙**: `philgo_app/lib/main.dart`의 Theme은 명시적 요청이 있을 때만 수정

- ❌ 일반적인 UI 수정 요청 시 main.dart 수정 금지
- ✅ "main theme 수정", "전체 Theme 변경" 등 **명확한 요청**이 있을 때만 수정
- 개별 화면이나 위젯에서 `Theme.of(context)`를 사용하여 처리

### 2. Theme 기반 스타일링 필수 (커스텀 스타일 금지)

**규칙**: 항상 `Theme.of(context)`를 사용하여 스타일 적용

❌ **절대 금지**:
```dart
color: Colors.blue              // 하드코딩된 색상
fontSize: 16                    // 하드코딩된 크기
backgroundColor: Colors.white  // 직접 지정 색상
```

✅ **올바른 방법**:
```dart
color: Theme.of(context).colorScheme.primary
style: Theme.of(context).textTheme.bodyLarge
backgroundColor: Theme.of(context).colorScheme.surface
```

### 3. 인라인 스타일 절대 금지

**규칙**: 버튼, 카드 등 위젯 내부에 `style` 속성 지정 금지

❌ **문제**: Button 내부의 Text에 style을 지정하면 Button의 Theme이 무시됨

```dart
// ❌ 절대 금지
ElevatedButton(
  child: Text('Login', style: TextStyle(color: Colors.white)),
)

// ✅ 올바른 방법
ElevatedButton(
  child: Text('Login'),  // Theme이 자동으로 적용됨
)
```

### 4. 깊이 있는 사고로 작업하기

**규칙**: 모든 요청에 대해 깊이 있게 분석한 후 작업

- ✅ 요청의 진정한 의도 파악
- ✅ 영향 범위와 부작용 검토
- ✅ 최적의 해결책 찾기
- ❌ 피상적이고 성급한 결정 금지

---

## 코드 작성 규칙

### 1. Import 문 필수 추가

모든 위젯, 클래스 사용 시 import 문 반드시 추가

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
```

### 2. 하드코딩 텍스트 절대 금지 (i18n 필수)

모든 사용자 표시 텍스트는 i18n 번역 사용

❌ **절대 금지**: `Text("Hello World")`
✅ **올바른 방법**: `Text(T.hello_world)` 또는 `Text(Lo.hello_world)`

위치: `philgo_app/lib/l10n/*.arb` 파일에서 번역 관리

### 3. 애니메이션은 flutter_animate 패키지 필수

❌ **절대 금지**:
```dart
AnimationController 직접 생성
AnimatedBuilder 직접 사용
```

✅ **반드시 사용**:
```dart
import 'package:flutter_animate/flutter_animate.dart';

Container()
  .animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: -0.2, end: 0)
```

### 4. Roboto 폰트 통일 사용

`google_fonts` 패키지를 통해 모든 플랫폼에서 Roboto 폰트 사용

### 5. Flutter/Dart 최신 버전 기능 사용

- Flutter 3.35.2 이상
- Dart 3.9 이상
- 최신 문법 및 API 활용 필수

---

## 주석 및 문서화

### 1. 한국어 주석 필수

모든 Dart 파일에 한국어로 상세한 주석 작성

### 2. Theme 관련 코드 주석 강화

Theme, 스타일, 색상 관련 코드는 **반드시** 이유와 효과를 주석으로 설명

```dart
// ✅ 올바른 예
Text(
  'Hello',
  style: Theme.of(context)
    .textTheme
    .bodyLarge
    ?.copyWith(
      // bodyLarge의 색상을 primary로 변경하여 강조
      color: Theme.of(context).colorScheme.primary,
    ),
)
```

---

## 개발 워크플로우

### 1. 작업 전 확인사항

**필수 순서**:
1. 참고할 문서 명시
2. 육하원칙 분석 (When, Where, What, How, Why, Who)
3. 📝 작업 계획(PLAN) 제시
4. ✅ TODO 목록 제시
5. 실제 작업 시작


### 2. 분석/설명 요청 시

"분석", "설명", "검토" 등의 키워드 포함 시:
- ✅ 코드 읽기 및 분석만 수행
- ❌ 소스 코드 수정 절대 금지
- ❌ 파일 편집 절대 금지

---

## 참고 문서

### 필수 참고 문서

필고 앱 개발 관련 모든 요청 시:
- [앱 개발 가이드라인](./docs/apps/app-dev-guideline.md)
- [필고 앱 개발 가이드라인](./docs/apps/philgo/philgo-app-development-guideline.md)
- [Flutter 코딩 가이드라인](./docs/apps/flutter-coding-guideline.md)

### 키워드별 참고 문서

| 키워드 | 참고 문서 |
|--------|---------|
| 디자인, Design | [앱 디자인 가이드](./docs/apps/app-design.md) |
| 다국어, i18n | [플러터 i18n](./docs/apps/app-l10n.md) |
| 상태관리 | [플러터 상태관리](./docs/apps/state-management.md) |
| API, 필고 연결 | [PhilGo API 문서](./docs/apps/flutter-philgo-api.md) |
| 라우팅 | [플러터 라우팅](./docs/apps/routing.md) |

### 주요 파일 위치

| 용도 | 경로 |
|------|------|
| 메인 설정 | `philgo_app/lib/main.dart` |
| 번역 파일 | `philgo_app/lib/l10n/*.arb` |
| 상태 관리 | `philgo_app/lib/state/app.state.dart` |
| API 함수 | `philgo_app/lib/philgo/philgo.functions.dart` |
| 커스텀 위젯 | `philgo_app/lib/widgets/` |
| 번역 클래스 | `philgo_app/lib/l10n/app_localizations.dart` |

---

## Flat 디자인 필수 규칙

### 디자인 요청 시 반드시 준수

- ✅ Flat 디자인 스타일 필수
- ❌ 테두리(border) 사용 금지
- ❌ 그림자(shadow) 사용 금지
- ✅ 색상 대비로만 UI 요소 구분
- ✅ 모든 elevation은 0으로 설정

### Font Awesome Pro 아이콘 우선 사용

- **우선순위**: Light > Regular > Solid
- 예시: `FontAwesomeIcons.lightCamera` (light 스타일)
- 모든 버튼, 메뉴, 리스트에 아이콘 필수 추가

### 이모지 적극 활용

- 메뉴: 🏠 홈, ⚙️ 설정, 👤 프로필
- 버튼: ✅ 확인, ❌ 취소, 💾 저장
- 상태: ✅ 성공, ⚠️ 경고, ❌ 오류

---

## Provider와 Selector 필수 규칙

### 상태 관리는 Provider 패키지 사용

❌ **절대 금지**: Riverpod, Consumer, context.watch()
✅ **반드시 사용**: Selector

```dart
Selector<AppState, int>(
  builder: (context, value, _) => Text(value.toString()),
  selector: (context, model) => model.someValue,
)
```

---

## 체크리스트

작업 시작 전:
- [ ] 참고 문서 확인
- [ ] 육하원칙 분석 완료
- [ ] 작업 계획 수립
- [ ] TODO 목록 작성

작업 완료 후:
- [ ] 한국어 주석 추가
- [ ] Theme 기반 스타일링 확인

---

**최종 확인**: 모든 규칙은 **예외 없이 적용**됩니다. 간단한 작업이라도 이 규칙들을 반드시 따르세요.
