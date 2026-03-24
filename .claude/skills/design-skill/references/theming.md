# Theming & Design Tokens

## Centralized Theme (`lib/theme.dart`)

The app uses a single `philgoThemeData(BuildContext context)` function returning `ThemeData`. It is applied in `lib/main.dart`:

```dart
MaterialApp.router(
  theme: philgoThemeData(context),
  ...
)
```

### Current Theme Configuration

```dart
ThemeData philgoThemeData(BuildContext context) {
  const blue = Color(0xFF007AFF);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: blue,
    brightness: Brightness.light,
    primary: blue,
    onPrimary: Colors.white,
    secondary: const Color(0xFF5AC8FA),
    onSecondary: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      color: colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: blue,
      foregroundColor: Colors.white,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: blue, width: 1.5),
      ),
    ),
  );
}
```

### Key Rules

- **Never modify `lib/theme.dart` without explicit user request.**
- All component themes must have `elevation: 0`.
- All border radii: 12px (cards/inputs), 8px (buttons), 16px (sections).

## Component Theme Customization

To customize individual Material components, add properties to `ThemeData`:

```dart
// AppBar
appBarTheme: AppBarTheme(
  backgroundColor: colorScheme.surface,
  elevation: 0,
  scrolledUnderElevation: 0,
),

// ElevatedButton
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
),

// Card
cardTheme: CardThemeData(
  elevation: 0,
  shadowColor: Colors.transparent,
),
```

## ThemeExtension — Custom Design Tokens

For custom styles not covered by standard `ThemeData`, use `ThemeExtension`.

### Step 1: Define the Extension

```dart
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  const AppCustomColors({
    required this.success,
    required this.danger,
    required this.warning,
    required this.info,
  });

  final Color? success;
  final Color? danger;
  final Color? warning;
  final Color? info;

  @override
  ThemeExtension<AppCustomColors> copyWith({
    Color? success,
    Color? danger,
    Color? warning,
    Color? info,
  }) {
    return AppCustomColors(
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(
    ThemeExtension<AppCustomColors>? other,
    double t,
  ) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      success: Color.lerp(success, other.success, t),
      danger: Color.lerp(danger, other.danger, t),
      warning: Color.lerp(warning, other.warning, t),
      info: Color.lerp(info, other.info, t),
    );
  }
}
```

### Step 2: Register in ThemeData

Add to the `extensions` list in `philgoThemeData()`:

```dart
return ThemeData(
  // ... existing theme config ...
  extensions: const <ThemeExtension<dynamic>>[
    AppCustomColors(
      success: Color(0xFF34C759),
      danger: Color(0xFFFF3B30),
      warning: Color(0xFFFF9500),
      info: Color(0xFF5AC8FA),
    ),
  ],
);
```

### Step 3: Access in Widgets

```dart
// Access custom tokens
final customColors = Theme.of(context).extension<AppCustomColors>()!;

Container(
  color: customColors.success,
  child: Text('Success', style: text.bodyMedium),
)
```

### When to Use ThemeExtension

| Use Case | Standard ThemeData | ThemeExtension |
|----------|-------------------|----------------|
| Primary/secondary colors | Yes | No |
| Success/danger/warning colors | No | Yes |
| Custom spacing tokens | No | Yes |
| Status-specific colors | No | Yes |
| Domain-specific tokens | No | Yes |

### Custom Spacing Tokens Example

```dart
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  const AppSpacing({
    required this.sectionGap,
    required this.cardPadding,
    required this.itemSpacing,
  });

  final double? sectionGap;
  final double? cardPadding;
  final double? itemSpacing;

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? sectionGap,
    double? cardPadding,
    double? itemSpacing,
  }) {
    return AppSpacing(
      sectionGap: sectionGap ?? this.sectionGap,
      cardPadding: cardPadding ?? this.cardPadding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(
    ThemeExtension<AppSpacing>? other,
    double t,
  ) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t),
      cardPadding: lerpDouble(cardPadding, other.cardPadding, t),
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t),
    );
  }
}
```

## Color Palette Reference

The app uses iOS-inspired blue tones:

| Token | Hex | Usage |
|-------|-----|-------|
| Primary | `#007AFF` | Main actions, links, active states |
| Secondary | `#5AC8FA` | Supporting elements |
| Surface | System default | Page backgrounds |
| SurfaceContainerLowest | System default | Cards, sections |
| OutlineVariant | System default | Borders, dividers |

All colors derive from `ColorScheme.fromSeed(seedColor: #007AFF)` in light mode.
