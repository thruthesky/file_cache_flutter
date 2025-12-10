# 테마 시스템

## 개요

필고 앱은 Material 3 기반의 Flat Design을 사용합니다.

## 테마 설정

`lib/themes/app.theme.dart`에서 정의:

```dart
class AppTheme {
  static ThemeData get lightTheme {
    final ColorScheme cs = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 37, 112, 244),
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: cs.surfaceContainerLow,
      ...
    );
  }
}
```

## Flat Design 원칙

- **그림자 제거**: 모든 elevation = 0
- **테두리 없음**: border 사용 최소화
- **색상 대비**: 색상으로만 UI 요소 구분

## 스타일 적용 규칙

**절대 사용 금지**:
```dart
// ❌ 하드코딩 금지
color: Colors.blue
fontSize: 16
backgroundColor: Colors.white
```

**올바른 방법**:
```dart
// ✅ Theme 사용
color: Theme.of(context).colorScheme.primary
style: Theme.of(context).textTheme.bodyLarge
backgroundColor: Theme.of(context).colorScheme.surface
```

## AppSpacing (lib/themes/app.spacing.dart)

8의 배수 기반 간격 시스템:

```dart
class AppSpacing extends ThemeExtension<AppSpacing> {
  final double s4 = 4;   // 4px
  final double s8 = 8;   // 8px
  final double s12 = 12; // 12px
  final double s16 = 16; // 16px
  final double s24 = 24; // 24px
  final double s32 = 32; // 32px
  final double s48 = 48; // 48px
}
```

사용법:
```dart
final sp = Theme.of(context).extension<AppSpacing>()!;
Padding(padding: EdgeInsets.all(sp.s16))
```

## 텍스트 스타일

| 스타일 | 용도 |
|--------|------|
| titleLarge | 화면 제목 |
| titleMedium | 섹션 제목 |
| bodyLarge | 본문 강조 |
| bodyMedium | 일반 본문 |
| bodySmall | 부가 정보 |
| labelLarge | 버튼 텍스트 |

## 폰트

Pretendard 폰트 사용 (100-900 weight):
- `assets/fonts/pretendard/`에 위치
- `pubspec.yaml`에 등록

## 컴포넌트 테마

```dart
// Card - 그림자 제거
cardTheme: CardThemeData(elevation: 0)

// AppBar - 그림자 제거
appBarTheme: AppBarTheme(elevation: 0, scrolledUnderElevation: 0)

// FAB - 그림자 제거, 둥근 모서리
floatingActionButtonTheme: FloatingActionButtonThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
)
```

## main.dart Theme 수정 주의

**중요**: `main.dart`의 Theme은 명시적 요청 없이 절대 수정 금지.
개별 위젯에서 `Theme.of(context)`로 스타일 적용.
