---
description: philgo-skill과 flutter-design-skill을 사용하여 PhilGo App 프로젝트의 UI/디자인을 개선합니다. Comic 스타일 디자인 가이드라인을 따릅니다.
allowed-tools: Bash(*)
argument-hint: [디자인 개선이 필요한 화면/위젯 설명]
---

# Flutter UI/디자인 개선 전문가

Flutter/Dart, Material 3, Comic 스타일 Flat Design 개발 전문가입니다.

다음 디자인 개선 요청을 분석하고 구현합니다: $ARGUMENTS

---

# 🔥 필수: 스킬 호출 지침

## philgo-skill 호출 (필수)
작업 시작 전, 반드시 philgo-skill을 호출하여 프로젝트 구조와 규칙을 파악합니다.

---

# 🏆 Best Practice (강력 권장)

## 🔥🔥🔥 중요: 반드시 Best Practice를 따르세요! 🔥🔥🔥

아래 Best Practice는 `ProfileEditScreen`과 `MenuHome` 위젯에서 검증된 현대적이고 심플한 디자인 패턴입니다.
**새로운 화면/위젯을 만들거나 기존 디자인을 개선할 때 반드시 이 패턴을 따라야 합니다.**

### 참고 파일 (Reference Files)
- `lib/screens/user/profile.edit.screen.dart` - 프로필 수정 화면
- `lib/screens/home/sections/menu.home.dart` - 메뉴 홈 화면

---

## 📐 페이지 레이아웃 구조

### 전체 레이아웃 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| 페이지 패딩 | `EdgeInsets.all(16)` | 전체 콘텐츠 영역 패딩 |
| 섹션 간 간격 | `spacing: 28` | Column의 spacing 속성 |
| 첫 섹션 상단 여백 | `SizedBox(height: 8)` | 첫 번째 섹션 위 추가 여백 |
| 그림자 | **없음** (elevation: 0) | 절대 그림자 사용 금지 |

### 페이지 구조 코드 예제

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: Column(
    spacing: 28,  // 섹션 간 간격
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),  // 첫 섹션 상단 여백

      // 섹션 1
      _buildSection(title: T.section1, icon: FontAwesomeIcons.icon1, child: ...),

      // 섹션 2
      _buildSection(title: T.section2, icon: FontAwesomeIcons.icon2, child: ...),

      // 더 많은 섹션...
    ],
  ),
)
```

---

## 🎨 AppBar 스타일

### AppBar 디자인 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| 제목 스타일 | `textTheme.titleLarge` | 앱바 제목 |
| 하단 테두리 높이 | `1px` | 미니멀한 구분선 |
| 하단 테두리 색상 | `colorScheme.outlineVariant` | 부드러운 테두리 색상 |

### AppBar 코드 예제

```dart
AppBar(
  title: Text(T.pageTitle, style: theme.textTheme.titleLarge),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(height: 1, color: scheme.outlineVariant),
  ),
)
```

---

## 📦 섹션 디자인 (핵심!)

### 섹션 헤더 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| 인디케이터 바 너비 | `3px` | 세로 강조 바 |
| 인디케이터 바 높이 | `16px` | 세로 강조 바 |
| 인디케이터 바 색상 | `colorScheme.primary` | 주요 색상 |
| 인디케이터 바 라운드 | `borderRadius: 2` | 부드러운 모서리 |
| 아이콘 크기 | `14px` | 섹션 제목 아이콘 |
| 아이콘 색상 | `colorScheme.onSurfaceVariant` | 보조 텍스트 색상 |
| 제목 스타일 | `textTheme.titleSmall` | 작은 제목 |
| 제목 fontWeight | `FontWeight.normal` | 미니멀한 두께 |
| 제목 letterSpacing | `0.2` | 약간의 자간 |
| 헤더 패딩 | `left: 4, bottom: 12` | 헤더 여백 |

### 섹션 컨테이너 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| 배경색 | `colorScheme.surfaceContainerLowest` | 가장 밝은 surface 색상 |
| 테두리 색상 | `outlineVariant.withValues(alpha: 0.5)` | 반투명 테두리 |
| 테두리 두께 | `1.0px` | 얇은 테두리 |
| 모서리 라운드 | `borderRadius: 16` | 부드러운 모서리 |
| 내부 패딩 | `EdgeInsets.all(20)` | 콘텐츠 영역 패딩 |
| clipBehavior | `Clip.antiAlias` | 부드러운 클리핑 |

### 섹션 빌드 코드 예제 (필수 패턴!)

```dart
/// 섹션 컨테이너 빌드 (Best Practice 패턴)
Widget _buildSection({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// 섹션 헤더 - 인디케이터 바 + 아이콘 + 타이틀
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Row(
          children: [
            /// 섹션 인디케이터 바 (강조 표시)
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),

            /// 섹션 아이콘
            FaIcon(
              icon,
              size: 14,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),

            /// 섹션 타이틀
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),

      /// 섹션 콘텐츠 컨테이너
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    ],
  );
}
```

---

## 🏷️ 필드 라벨 스타일

### 필드 라벨 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| 아이콘 크기 | `14px` | 라벨 앞 아이콘 |
| 아이콘 색상 | `colorScheme.onSurfaceVariant` | 보조 색상 |
| 텍스트 스타일 | `textTheme.bodyMedium` | 본문 텍스트 |
| 텍스트 fontWeight | `FontWeight.w500` | 중간 두께 |
| 텍스트 색상 | `colorScheme.onSurfaceVariant` | 보조 텍스트 색상 |
| 아이콘-텍스트 간격 | `8px` | 아이콘과 텍스트 사이 |

### 필드 라벨 코드 예제

```dart
/// 필드 라벨 위젯 (Best Practice 패턴)
Widget _buildFieldLabel(
  BuildContext context,
  String label,
  IconData icon,
) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return Row(
    children: [
      FaIcon(
        icon,
        size: 14,
        color: scheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    ],
  );
}
```

---

## 🎭 선택 옵션 스타일 (라디오/체크박스)

### 선택 옵션 규칙

| 속성 | 상태 | 값 |
|------|------|-----|
| 배경색 | 선택됨 | `primary.withValues(alpha: 0.1)` |
| 배경색 | 미선택 | `Colors.transparent` |
| 테두리 색상 | 선택됨 | `colorScheme.primary` |
| 테두리 색상 | 미선택 | `outlineVariant.withValues(alpha: 0.5)` |
| 테두리 두께 | 선택됨 | `1.5px` |
| 테두리 두께 | 미선택 | `1.0px` |
| 모서리 라운드 | - | `borderRadius: 12` |
| 패딩 | - | `horizontal: 8, vertical: 12` |

### 선택 옵션 코드 예제

```dart
/// 선택 옵션 위젯 (Best Practice 패턴)
Widget _buildOption(
  BuildContext context, {
  required String value,
  required String label,
  required IconData icon,
  required bool isSelected,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Radio/Checkbox + Icon + Label
          ...
        ],
      ),
    ),
  );
}
```

---

## ✨ 애니메이션 패턴

### flutter_animate 사용 규칙

| 속성 | 값 | 설명 |
|------|-----|------|
| fadeIn duration | `400.ms` | 페이드인 시간 |
| slideY begin | `0.1` | 시작 위치 (10% 아래) |
| slideY end | `0` | 끝 위치 |
| 섹션 간 delay | `100.ms` | 순차적 애니메이션 |

### 애니메이션 코드 예제

```dart
// 섹션에 순차적 애니메이션 적용
_buildSection(
  title: T.section1,
  icon: FontAwesomeIcons.icon1,
  child: ...
)
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, end: 0),

_buildSection(
  title: T.section2,
  icon: FontAwesomeIcons.icon2,
  child: ...
)
    .animate()
    .fadeIn(duration: 400.ms, delay: 100.ms)  // 100ms 지연
    .slideY(begin: 0.1, end: 0),

_buildSection(
  title: T.section3,
  icon: FontAwesomeIcons.icon3,
  child: ...
)
    .animate()
    .fadeIn(duration: 400.ms, delay: 200.ms)  // 200ms 지연
    .slideY(begin: 0.1, end: 0),
```

---

## 📊 색상 계층 구조 (중요!)

### 배경색 계층

| 계층 | 색상 | 용도 |
|------|------|------|
| 페이지 배경 | `colorScheme.surface` | Scaffold 배경 |
| 섹션 컨테이너 | `colorScheme.surfaceContainerLowest` | 카드/섹션 배경 |
| 선택된 아이템 | `primary.withValues(alpha: 0.1)` | 활성 상태 배경 |
| 투명 | `Colors.transparent` | 비활성 상태 배경 |

### 테두리 색상 계층

| 용도 | 색상 | 설명 |
|------|------|------|
| AppBar 하단 | `colorScheme.outlineVariant` | 구분선 |
| 섹션 컨테이너 | `outlineVariant.withValues(alpha: 0.5)` | 부드러운 테두리 |
| 선택된 아이템 | `colorScheme.primary` | 강조 테두리 |
| 비선택 아이템 | `outlineVariant.withValues(alpha: 0.5)` | 약한 테두리 |

### 텍스트/아이콘 색상 계층

| 용도 | 색상 | 설명 |
|------|------|------|
| 주요 텍스트 | `colorScheme.onSurface` | 제목, 본문 |
| 보조 텍스트 | `colorScheme.onSurfaceVariant` | 라벨, 힌트 |
| 강조 텍스트 | `colorScheme.primary` | 선택된 항목 |
| 버튼 텍스트 | `colorScheme.onPrimary` | Primary 버튼 위 |

---

# Comic 디자인 핵심 원칙

## 🌞 테마 모드 정책

**⚠️ 중요: 다크 모드는 지원하지 않습니다. 오직 라이트 모드만 지원합니다.**

- [ ] **금지**: 다크 모드 관련 코드 작성
- [ ] **금지**: `Brightness.dark` 조건 분기
- [ ] **필수**: 라이트 모드 전용 디자인
- [ ] **필수**: Theme colorScheme 사용 (라이트 모드 기준)

## 디자인 규칙 요약

| 속성 | 값 | 설명 |
|------|-----|------|
| 테마 모드 | **라이트 모드 전용** | 다크 모드 미지원 |
| Border Width | `2.0` (표준), `1.0` (목록/입력필드) | Comic 스타일 테두리 |
| Border Radius | `12` (큰 요소), `8` (작은 요소), `16` (섹션) | 둥근 모서리 |
| Elevation | `0` | 항상 그림자 없음 |
| 간격 | 8의 배수 | 8, 16, 24, 32... |

## 색상 사용 규칙

| 용도 | Theme 색상 |
|------|------------|
| 주요 요소 | `colorScheme.primary` |
| 보조 요소 | `colorScheme.secondary` |
| 카드/컨테이너 | `colorScheme.surfaceContainerLowest` |
| 테두리 | `colorScheme.outlineVariant` |
| 텍스트/아이콘 | `colorScheme.onSurface` |
| 보조 텍스트 | `colorScheme.onSurfaceVariant` |

## 타이포그래피 규칙

| 용도 | Text Style |
|------|------------|
| AppBar 제목 | `textTheme.titleLarge` |
| 섹션 제목 | `textTheme.titleSmall` |
| 일반 텍스트 | `textTheme.bodyLarge` |
| 필드 라벨 | `textTheme.bodyMedium` |
| 버튼 | `textTheme.labelLarge` |

---

# 분석 단계

- [ ] **🔥 [필수]** philgo-skill 호출하여 프로젝트 구조 파악
- [ ] **🔥 [필수]** flutter-design-skill 호출하여 디자인 가이드라인 파악
- [ ] **🔥 [필수]** Best Practice 참고 파일 확인 (`profile.edit.screen.dart`, `menu.home.dart`)
- [ ] `$ARGUMENTS` 요청에 대해 CoT/ToT 분석 수행
- [ ] 관련 위젯/화면의 부모-자식 관계, 데이터 흐름 분석
- [ ] 기존 디자인 패턴과 일관성 확인

---

# Comic 컴포넌트 사용 가이드

## ComicButton 시스템

### 버튼 변형

| 버튼 스타일 | rounded | padding | textSize |
|-----------|---------|---------|----------|
| 큰 CTA | `full` | `large` | `large` |
| 표준 | `normal` | `medium` | `medium` |
| 컴팩트 | `normal` | `small` | `small` |

### 사용 예제

```dart
// 큰 로그인 버튼 (알약 형태)
ComicPrimaryButton(
  onPressed: () => login(),
  rounded: ComicButtonRounded.full,
  padding: ComicButtonPadding.large,
  textSize: ComicButtonTextSize.large,
  child: Text(Lo.of(context)!.login),
)

// 표준 버튼
ComicButton(
  onPressed: () => doSomething(),
  child: Text(Lo.of(context)!.action),
)

// 보조 버튼
ComicSecondaryButton(
  onPressed: () => cancel(),
  padding: ComicButtonPadding.small,
  child: Text(Lo.of(context)!.cancel),
)
```

## ComicTextFormField

```dart
ComicTextFormField(
  controller: _controller,
  labelText: T.fieldLabel,
  hintText: T.fieldHint,
  borderWidth: 1.0,  // 기본값
  borderRadius: 12,  // 기본값
)
```

## Comic SnackBar

```dart
// 성공 메시지
showComicSuccessSnackBar(context, T.successMessage);

// 에러 메시지
showComicErrorSnackBar(context, T.errorMessage);

// 정보 메시지
showComicInfoSnackBar(context, T.infoMessage);

// 경고 메시지
showComicWarningSnackBar(context, T.warningMessage);
```

---

# 필수 규칙

## Theme 관련
- [ ] **금지**: 명시적 요청 없이 main.dart의 Theme 수정
- [ ] **필수**: 개별 위젯에서 `Theme.of(context)` 사용

## 하드코딩 금지
- [ ] **금지**: `Colors.blue`, `fontSize: 16`, `backgroundColor: Colors.white` 직접 지정
- [ ] **필수**: `Theme.of(context).colorScheme.primary`, `Theme.of(context).textTheme.bodyLarge` 사용

```dart
// ❌ 절대 금지
color: Colors.blue
fontSize: 16
elevation: 4
Text('Login', style: TextStyle(...))

// ✅ 반드시 사용
color: Theme.of(context).colorScheme.primary
style: Theme.of(context).textTheme.bodyLarge
elevation: 0
Text(T.login)  // 테마가 스타일링 처리
```

## 상태 관리
- [ ] **금지**: Riverpod, Consumer, context.watch() 사용
- [ ] **필수**: Provider + Selector 패턴 사용

## i18n 필수
- [ ] **금지**: `Text("Hello World")` 같은 하드코딩 텍스트
- [ ] **필수**: `Text(T.hello)` 또는 `Text(Lo.of(context)!.hello)` 사용

## Flat Design 원칙
- [ ] 모든 elevation = 0
- [ ] 그림자 사용 금지
- [ ] 색상 대비로만 UI 요소 구분
- [ ] 테두리는 `colorScheme.outlineVariant` 사용

## 아이콘
- [ ] Font Awesome Pro 아이콘 사용 (우선순위: Light > Regular > Solid)

## 애니메이션
- [ ] flutter_animate 패키지 사용 필수

---

# 실행 단계

- [ ] Flutter + Dart + Firebase + Provider 환경에서 개발
- [ ] **🔥 Best Practice 패턴을 반드시 따라 UI 구현**
- [ ] Comic 디자인 가이드라인에 따라 UI 구현
- [ ] CoT/ToT 방식으로 단계별 문제 분석 및 해결
- [ ] 발견된 문제와 해결책을 사용자에게 상세히 보고

---

# 테스트 및 검증 단계

- [ ] 코드 작업 후 `flutter analyze` 실행하여 오류/경고 확인 및 수정
- [ ] 필요시 `flutter test`로 단위 테스트 실행
- [ ] 라이트 모드에서 UI 확인 (다크 모드 미지원)

---

# 주요 파일 위치 참고

| 용도 | 경로 |
|------|------|
| 메인 설정 | `lib/main.dart` |
| 라우터 | `lib/router.dart` |
| 앱 상태 | `lib/state/app.state.dart` |
| 테마 | `lib/themes/app.theme.dart` |
| 간격 토큰 | `lib/themes/app.spacing.dart` |
| i18n | `lib/l10n/*.arb` |
| Comic 위젯 | `lib/widgets/theme/comic_*.dart` |
| **Best Practice 참고** | `lib/screens/user/profile.edit.screen.dart` |
| **Best Practice 참고** | `lib/screens/home/sections/menu.home.dart` |

---

# 작업 완료 체크리스트

- [ ] `flutter analyze` 실행 후 모든 오류/경고 해결
- [ ] **🔥 Best Practice 패턴 준수 확인**
- [ ] Theme 기반 스타일링 확인
- [ ] i18n 적용 확인 (하드코딩 텍스트 없음)
- [ ] Provider + Selector 패턴 준수 확인
- [ ] Comic 디자인 원칙 준수 확인 (elevation: 0, outline 테두리)
- [ ] 섹션 구조 확인 (인디케이터 바 + 아이콘 + 타이틀)
- [ ] 색상 계층 확인 (surfaceContainerLowest, outlineVariant)
- [ ] 한글 주석 추가
- [ ] 라이트 모드 UI 확인 (다크 모드 미지원)
