# FAB (Floating Action Button) 컴팩트 디자인 가이드

홈, 게시판, 업소록 페이지의 우측 하단 "작성(+)" 버튼 디자인 명세입니다.
이 가이드를 따라 완전히 동일한 FAB를 구현할 수 있습니다.

---

## 핵심 위젯: `ComicFab`

파일 위치: `lib/widgets/theme/comic_fab.dart`

### 디자인 스펙 (Before → After)

| 속성 | 이전 | **현재 (컴팩트)** |
|------|------|-------------------|
| FAB 크기 (large) | 56x56 | **44x44** |
| FAB 크기 (small) | 40x40 | **36x36** |
| FAB 크기 (mini) | 36x36 | **32x32** |
| 테두리 두께 | 2.0px | **1.5px** |
| borderRadius | 24 | **16** |
| 아이콘 크기 (large) | 24px | **20px** |
| 아이콘 크기 (small) | 24px | **18px** |
| 아이콘 크기 (mini) | 24px | **16px** |

### 변하지 않은 속성

| 속성 | 값 | 설명 |
|------|-----|------|
| `elevation` | `0` | 그림자 없음 (Flat Design) |
| `backgroundColor` | `colorScheme.surface` | 배경색 (흰색) |
| `foregroundColor` | `colorScheme.onSurface` | 아이콘 색상 (검정) |
| `borderColor` | `colorScheme.outline` | 테두리 색상 |
| `clipBehavior` | `Clip.antiAlias` | 부드러운 클리핑 |
| 아이콘 | `FontAwesomeIcons.plus` | "+" 아이콘 |

---

## 위젯 트리 구조

```
SizedBox (44x44)
  └── Material (elevation: 0, RoundedRectangleBorder)
       ├── borderRadius: 16
       ├── borderSide: outline 색상, 1.5px
       ├── color: surface (흰색 배경)
       ├── clipBehavior: Clip.antiAlias
       └── InkWell (borderRadius: 16)
            └── Tooltip (message: tooltip)
                 └── Center
                      └── IconTheme (color: onSurface, size: 20)
                           └── FaIcon(FontAwesomeIcons.plus)
```

---

## ComicFab 위젯 전체 코드

```dart
import 'package:flutter/material.dart';

/// ComicFabSize - FAB 크기 옵션 (컴팩트 디자인)
enum ComicFabSize {
  large,  // 44x44 - 기본
  small,  // 36x36 - 보조
  mini,   // 32x32 - 최소
}

class ComicFab extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final ComicFabSize size;
  final String? tooltip;
  final Object? heroTag;

  const ComicFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1.5,           // 컴팩트: 1.5px
    this.size = ComicFabSize.large,
    this.tooltip,
    this.heroTag,
  });

  double _getSize() {
    switch (size) {
      case ComicFabSize.large: return 44;   // 컴팩트 표준
      case ComicFabSize.small: return 36;
      case ComicFabSize.mini:  return 32;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ComicFabSize.large: return 20;   // 컴팩트 아이콘
      case ComicFabSize.small: return 18;
      case ComicFabSize.mini:  return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = foregroundColor ?? colorScheme.onSurface;
    final bdColor = borderColor ?? colorScheme.outline;
    final fabSize = _getSize();
    final iconSize = _getIconSize();

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: Material(
        elevation: 0,                        // Flat Design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),  // 컴팩트: 16
          side: BorderSide(color: bdColor, width: borderWidth),
        ),
        color: bgColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Tooltip(
            message: tooltip ?? '',
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: fgColor, size: iconSize),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 페이지별 사용 패턴

### 1. 홈 (MainHome) - Scaffold의 floatingActionButton

```dart
Scaffold(
  floatingActionButton: ComicFab(
    onPressed: () => showPostCategoryDialog(context),
    tooltip: '글쓰기',
    child: const FaIcon(FontAwesomeIcons.plus),
  ),
  body: ...,
)
```

### 2. 게시판 (ForumHome) - Stack + Positioned

```dart
Stack(
  children: [
    // 게시판 콘텐츠
    ...,
    // FAB (우측 하단 고정)
    Positioned(
      right: 16,
      bottom: 16,
      child: ComicFab(
        onPressed: _showPostCreateScreen,
        tooltip: 'Write Post',
        child: const FaIcon(FontAwesomeIcons.plus),
      ),
    ),
  ],
)
```

### 3. 업소록 (CompanyListScreen) - 상태에 따른 아이콘 변경

```dart
Scaffold(
  floatingActionButton: ComicFab(
    onPressed: _handleCreateOrUpdateButton,
    tooltip: myCompany != null
        ? Lo.of(context)!.editMyCompany
        : Lo.of(context)!.addMyCompany,
    child: FaIcon(
      myCompany != null
          ? FontAwesomeIcons.penToSquare  // 수정
          : FontAwesomeIcons.plus,         // 작성
    ),
  ),
  body: ...,
)
```

---

## 변형 위젯

| 변형 | 배경색 | 아이콘 색상 | 테두리 색상 | 용도 |
|------|--------|-------------|-------------|------|
| `ComicFab` | `surface` | `onSurface` | `outline` | 기본 (흰색+검정) |
| `ComicPrimaryFab` | `primary` | `onPrimary` | `primary` | 강조 액션 |
| `ComicSecondaryFab` | `secondary` | `onSecondary` | `secondary` | 보조 액션 |

---

## 필수 규칙

- elevation: 반드시 `0` (Flat Design)
- 테두리 두께: `1.5px` (컴팩트 디자인)
- borderRadius: `16` (둥근 사각형)
- FAB 크기: `44x44` (기본 large)
- 아이콘 크기: `20px` (기본 large)
- 아이콘: `FontAwesomeIcons` 사용 (Light > Regular > Solid 우선)
- 기본 작성 아이콘: `FontAwesomeIcons.plus`
- 모든 색상: `Theme.of(context).colorScheme` 사용
- 하드코딩 색상 절대 금지
