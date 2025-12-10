# 테마 시스템

## 개요

필고 앱은 Material 3 기반의 Flat Design을 사용합니다.

> **🎨 중요**: `lib/themes/app.theme.dart`는 앱의 전반적인 UI 디자인을 담당하는 **가장 핵심적인 파일**입니다. 이 파일에서 정의된 테마 설정은 앱 전체의 색상, 타이포그래피, 컴포넌트 스타일을 결정합니다. 모든 UI 작업 시 이 테마를 기반으로 스타일을 적용해야 합니다.

## 파일 구조

| 파일 | 역할 |
|------|------|
| `lib/themes/app.theme.dart` | 앱 전체 테마 정의 (핵심) |
| `lib/themes/app.spacing.dart` | 간격 토큰 시스템 |
| `lib/extensions/text_theme.extension.dart` | 특수 목적 테마 확장 (게시글 제목용) |

---

## AppTheme (lib/themes/app.theme.dart)

### 역할

- **앱 전체의 시각적 일관성**을 담당하는 중앙 집중식 테마 관리
- Material 3 디자인 시스템 기반
- Flat Design 원칙 적용 (elevation = 0, 그림자 없음)
- 모든 위젯의 기본 스타일 정의

### 전체 소스 코드

```dart
import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';

class AppTheme {
  static ThemeData get lightTheme {
    // ColorScheme - 앱의 모든 색상을 시드 색상에서 자동 생성
    final ColorScheme cs = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 37, 112, 244),  // 필고 브랜드 파란색
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,

      // Flat 2.0 Design - 회색 배경색 (surface container)
      scaffoldBackgroundColor: cs.surfaceContainerLow,

      // 텍스트 테마 - letterSpacing: -0.10 으로 가독성 향상
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 52),
        displayMedium: TextStyle(fontSize: 42),
        displaySmall: TextStyle(fontSize: 34),
        headlineLarge: TextStyle(fontSize: 30),
        headlineMedium: TextStyle(fontSize: 26, letterSpacing: -0.10),
        headlineSmall: TextStyle(letterSpacing: -0.10),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.10),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
        ),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, letterSpacing: -0.10),
        labelLarge: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
          height: 1.20,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontWeight: FontWeight.w500,
          letterSpacing: -0.10,
          height: 1.45,
        ),
      ),

      // Card Theme - Flat Design (그림자 제거)
      cardTheme: const CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
      ),

      // AppBar Theme - Flat Design
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: cs.surfaceContainerLow,
        centerTitle: false,
      ),

      // BottomNavigationBar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 24),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.0,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          height: 2.0,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurfaceVariant,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(showCheckmark: false),

      // FloatingActionButton Theme - Flat Design
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Spacing Tokens 등록 (8 배수 기반)
      extensions: const <ThemeExtension<dynamic>>[AppSpacing()],
    );
  }
}
```

### 브랜드 색상

```dart
// 필고 브랜드 파란색 - 시드 컬러
seedColor: const Color.fromARGB(255, 37, 112, 244)  // #2570F4
```

이 시드 색상에서 Material 3의 `ColorScheme.fromSeed()`가 자동으로 다음 색상들을 생성합니다:
- `primary`, `onPrimary` - 주요 색상
- `secondary`, `onSecondary` - 보조 색상
- `surface`, `onSurface` - 표면 색상
- `surfaceContainerLow` - 앱 배경색
- 기타 모든 Material 3 색상 토큰

---

## Flat Design 원칙

필고 앱은 **Flat 2.0 Design**을 따릅니다:

| 원칙 | 설명 | 구현 |
|------|------|------|
| 그림자 제거 | 모든 elevation = 0 | `cardTheme`, `appBarTheme`, `floatingActionButtonTheme` |
| 테두리 최소화 | border 사용 지양 | 색상 대비로 구분 |
| 색상 대비 | 색상으로만 UI 구분 | `surfaceContainerLow` vs `surface` |
| 플랫 버튼 | 입체감 없는 버튼 | `highlightElevation: 0` |

### 배경색 계층 구조

```
scaffoldBackgroundColor: cs.surfaceContainerLow  // 앱 전체 배경 (연한 회색)
        ↓
Card/Surface: cs.surface                          // 카드/컨테이너 배경 (흰색)
```

---

## 스타일 적용 규칙

### ❌ 절대 사용 금지 (하드코딩)

```dart
// ❌ 금지 - 하드코딩된 색상
color: Colors.blue
color: Color(0xFF2196F3)
backgroundColor: Colors.white

// ❌ 금지 - 하드코딩된 크기
fontSize: 16
padding: EdgeInsets.all(16)

// ❌ 금지 - 인라인 스타일 (버튼 내부)
ElevatedButton(
  child: Text('로그인', style: TextStyle(color: Colors.white)),  // ❌
)
```

### ✅ 올바른 방법 (Theme 사용)

```dart
// ✅ 올바름 - Theme에서 색상 가져오기
color: Theme.of(context).colorScheme.primary
color: Theme.of(context).colorScheme.onSurface
backgroundColor: Theme.of(context).colorScheme.surface

// ✅ 올바름 - Theme에서 텍스트 스타일 가져오기
style: Theme.of(context).textTheme.bodyLarge
style: Theme.of(context).textTheme.titleMedium

// ✅ 올바름 - AppSpacing에서 간격 가져오기
final sp = Theme.of(context).extension<AppSpacing>()!;
padding: EdgeInsets.all(sp.s16)

// ✅ 올바름 - 버튼은 Theme 자동 적용
ElevatedButton(
  child: Text('로그인'),  // Theme이 자동으로 스타일 적용
)
```

---

## AppSpacing (lib/themes/app.spacing.dart)

8의 배수 기반 간격 시스템으로, 일관된 레이아웃을 보장합니다.

### 간격 토큰

| 토큰 | 값 | 용도 |
|------|-----|------|
| `s4` | 4px | 아이콘과 텍스트 사이 |
| `s8` | 8px | 작은 요소 간격 |
| `s12` | 12px | 리스트 아이템 내부 |
| `s16` | 16px | 기본 패딩/마진 |
| `s20` | 20px | 중간 간격 |
| `s24` | 24px | 섹션 간격 |
| `s32` | 32px | 큰 섹션 간격 |
| `s40` | 40px | 페이지 상단/하단 |
| `s48` | 48px | 대형 요소 간격 |

### 사용법

```dart
// AppSpacing 가져오기
final sp = Theme.of(context).extension<AppSpacing>()!;

// 패딩 적용
Container(
  padding: EdgeInsets.all(sp.s16),
  margin: EdgeInsets.symmetric(
    horizontal: sp.s16,
    vertical: sp.s8,
  ),
  child: Column(
    children: [
      Text('제목'),
      SizedBox(height: sp.s12),  // 간격
      Text('내용'),
    ],
  ),
)
```

---

## TextThemeExtension (lib/extensions/text_theme.extension.dart)

특정 화면에서 기본 테마와 다른 텍스트 스타일이 필요할 때 사용하는 **BuildContext 확장**입니다.

### 역할

- 기본 `titleLarge` 스타일(w600, 세미볼드)을 게시글 목록에 맞게 조정
- 게시글 제목을 더 가볍고 읽기 편한 스타일로 표시
- 전역 테마를 수정하지 않고 특정 위젯 트리에만 적용

### 소스 코드

```dart
import 'package:flutter/material.dart';

extension TextThemeExtension on BuildContext {
  /// 게시글 제목 전용 테마
  /// - titleLarge: w400 (레귤러), 19px
  /// - 기본 titleLarge(w600)보다 가벼운 스타일로 게시글 목록에 적합
  ThemeData get postTitleTheme => Theme.of(this).copyWith(
    textTheme: Theme.of(this).textTheme.copyWith(
      titleLarge: Theme.of(this).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.w400,  // 세미볼드(w600) → 레귤러(w400)
        fontSize: 19,                  // 게시글 제목 크기
      ),
    ),
  );
}
```

### 스타일 비교

| 속성 | 기본 `titleLarge` | `postTitleTheme.titleLarge` |
|------|-------------------|----------------------------|
| fontWeight | w600 (세미볼드) | w400 (레귤러) |
| fontSize | Material 3 기본값 | 19px |
| 용도 | 화면 제목, 카드 헤더 | 게시글 목록 제목 |

### 사용 위치

**`lib/screens/home/sections/forum.home.dart`**에서 게시글 목록(`PostListView`)을 감싸는 데 사용됩니다:

```dart
Widget _buildPostList() {
  return Expanded(
    child: Theme(
      data: context.postTitleTheme,  // ← 게시글 제목 전용 테마 적용
      child: PostListView(
        postId: _currentSelection.postId,
        category: _currentSelection.category,
        // ...
      ),
    ),
  );
}
```

### 동작 원리

1. `context.postTitleTheme`으로 현재 테마를 기반으로 수정된 `ThemeData` 생성
2. `Theme` 위젯으로 `PostListView`를 감싸서 하위 위젯에 적용
3. `PostListView` 내부에서 `titleLarge` 스타일을 사용하면 w400/19px로 렌더링
4. 다른 위젯들은 기본 테마(w600)를 그대로 사용

### 확장 방법

새로운 특수 테마가 필요하면 이 파일에 getter를 추가합니다:

```dart
extension TextThemeExtension on BuildContext {
  // 기존 게시글 제목 테마
  ThemeData get postTitleTheme => ...;

  // 예시: 댓글 전용 테마 추가
  ThemeData get commentTheme => Theme.of(this).copyWith(
    textTheme: Theme.of(this).textTheme.copyWith(
      bodyMedium: Theme.of(this).textTheme.bodyMedium!.copyWith(
        fontSize: 14,
        height: 1.5,
      ),
    ),
  );
}
```

### ⚠️ 주의사항

- **남용 금지**: 특수 테마는 정말 필요한 경우에만 사용
- **범위 제한**: `Theme` 위젯으로 최소 범위에만 적용
- **일관성 유지**: 가능하면 기본 테마 사용 권장

---

## 텍스트 스타일

| 스타일 | fontWeight | 용도 |
|--------|------------|------|
| `displayLarge` | - | 52px, 대형 타이틀 |
| `displayMedium` | - | 42px, 중형 타이틀 |
| `displaySmall` | - | 34px, 소형 타이틀 |
| `headlineLarge` | - | 30px, 대형 헤드라인 |
| `headlineMedium` | - | 26px, 중형 헤드라인 |
| `titleLarge` | w600 | 화면 제목, 카드 제목 |
| `titleMedium` | w600 | 섹션 제목 |
| `titleSmall` | w600 | 소제목 |
| `bodyLarge` | w400 | 본문 강조 |
| `bodyMedium` | w400 | 일반 본문 (기본) |
| `bodySmall` | w400 | 부가 정보, 캡션 |
| `labelLarge` | w500 | 버튼 텍스트 |
| `labelMedium` | w500 | 작은 버튼, 탭 |
| `labelSmall` | w500 | 매우 작은 레이블 |

### 텍스트 스타일 특징

- **letterSpacing: -0.10**: 모든 텍스트에 적용되어 가독성 향상
- **fontWeight**: title은 w600(세미볼드), body는 w400(레귤러), label은 w500(미디엄)

---

## 컴포넌트 테마 요약

| 컴포넌트 | 주요 설정 |
|----------|----------|
| **Card** | elevation: 0, shadowColor: transparent |
| **AppBar** | elevation: 0, scrolledUnderElevation: 0, centerTitle: false |
| **BottomNavigationBar** | elevation: 0, type: fixed, 아이콘 24px |
| **FloatingActionButton** | elevation: 0, borderRadius: 16 |
| **Chip** | showCheckmark: false |

---

## ⚠️ 중요 주의사항

### main.dart Theme 수정 금지

```
🚫 명시적 요청 없이 lib/themes/app.theme.dart 수정 금지!
```

- 이 파일은 앱 전체에 영향을 미치는 **핵심 파일**입니다
- 테마 수정은 반드시 **명시적인 요청**이 있을 때만 수행합니다
- 개별 위젯에서는 `Theme.of(context)`를 사용하여 스타일을 적용합니다

### 잘못된 예시

```dart
// ❌ 개별 위젯에서 테마 오버라이드 금지
Theme(
  data: ThemeData(colorScheme: ...),  // 잘못됨
  child: MyWidget(),
)
```

### 올바른 예시

```dart
// ✅ Theme.of(context) 사용
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    '제목',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

---

## 빠른 참조 코드

```dart
// 테마 및 색상 가져오기
final theme = Theme.of(context);
final cs = theme.colorScheme;
final textTheme = theme.textTheme;
final sp = theme.extension<AppSpacing>()!;

// 색상 사용
Container(
  color: cs.surface,              // 흰색 표면
  child: Text(
    '제목',
    style: textTheme.titleLarge?.copyWith(
      color: cs.primary,          // 브랜드 파란색
    ),
  ),
)

// 간격 사용
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: sp.s16,
    vertical: sp.s12,
  ),
  child: ...,
)
```
