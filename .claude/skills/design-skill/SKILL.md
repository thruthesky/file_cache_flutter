---
name: "flutter-design-skill"
description: "Flutter UI design guideline and standards for PhilGo App. Use this skill when the task involves: (1) UI structure or visual design decisions, (2) creating a new widget or screen, (3) refactoring an existing widget's design, (4) interaction patterns (tap, selection, animation), (5) theming, color, typography, or spacing decisions, (6) ThemeExtension or design token implementation, (7) responsive layout with MediaQuery or custom slivers. Trigger keywords: design, UI, widget, screen, layout, theme, color, spacing, animation, responsive, ThemeExtension, design token, sliver."
---

# Flutter Design Skill — PhilGo App

## Core Design Identity

**Flat design, light mode only, Material 3.**

| Principle | Rule |
|-----------|------|
| Mode | Light only. No dark mode code. |
| Elevation | Always `0`. No shadows. |
| Borders | Use borders (not shadows) to separate elements |
| Spacing | Multiples of 8 (8, 16, 24, 32) |
| Icons | Font Awesome Pro only (Light > Regular > Solid) |
| Colors | Theme-based only. No hardcoded `Colors.xxx` |
| Text | Theme-based only. No hardcoded font sizes |
| Animation | `flutter_animate` package |

## Global Shortcuts (MUST USE)

Use the global getters from `lib/globals.dart` — **never** use `Theme.of(context).colorScheme` or `Theme.of(context).textTheme` directly:

```dart
color.primary        // instead of Theme.of(context).colorScheme.primary
text.titleLarge      // instead of Theme.of(context).textTheme.titleLarge
```

## Theme File

The app theme is defined in `lib/theme.dart` via `philgoThemeData()`:
- Primary: `#007AFF` (iOS blue)
- Secondary: `#5AC8FA` (light cyan)
- Material 3 enabled
- All elevations set to 0

## Color Hierarchy

| Layer | Color | Usage |
|-------|-------|-------|
| Page background | `color.surface` | Scaffold |
| Card/Section | `color.surfaceContainerLowest` | Containers |
| Selected item | `color.primary.withValues(alpha: 0.1)` | Active state |
| Primary text | `color.onSurface` | Titles, body |
| Secondary text | `color.onSurfaceVariant` | Labels, hints |
| Border (base) | `color.outlineVariant` | Dividers |
| Border (soft) | `color.outlineVariant.withValues(alpha: 0.5)` | Section borders |
| Border (active) | `color.primary` | Selected items |

## Typography

| Usage | Style |
|-------|-------|
| AppBar title | `text.titleLarge` |
| Section title | `text.titleSmall` |
| Body | `text.bodyLarge` |
| Field label | `text.bodyMedium` with `FontWeight.w500` |
| Button | `text.labelLarge` |

## Screen Layout with Custom Slivers

Content screens use `CustomScrollView` with slivers — **not** `LayoutBuilder`:

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      pinned: true,
      backgroundColor: color.surface,
      // expandedHeight: 240, // for collapsible header image
      // flexibleSpace: FlexibleSpaceBar(background: headerImage),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 28,
          children: [
            _buildSection(title: '섹션1'.tr(), icon: icon1, child: content1),
            _buildSection(title: '섹션2'.tr(), icon: icon2, child: content2),
          ],
        ),
      ),
    ),
  ],
)
```

### Key Sliver Types

| Sliver | Usage |
|--------|-------|
| `SliverAppBar` | Pinned toolbar, collapsible headers (`expandedHeight`, `FlexibleSpaceBar`) |
| `SliverToBoxAdapter` | Wraps any Box widget (Column, Padding, sections) |
| `SliverFillRemaining` | Loading/error states — centers content in remaining space |

### Bottom Input Pattern

For screens with fixed bottom input (comments, chat):

```dart
Column(
  children: [
    Expanded(child: CustomScrollView(slivers: [...])),
    BottomInputWidget(), // Fixed at bottom, outside scroll
  ],
)
```

## References

Read these reference documents based on what the task requires:

- **Theming & Design Tokens** → [references/theming.md](references/theming.md)
  Covers `ThemeExtension` implementation, custom design tokens, centralized `ThemeData` customization, and component theme configuration. Read when creating custom theme extensions, adding new color tokens, or modifying the app-wide theme.

- **Layout & Responsiveness** → [references/layout.md](references/layout.md)
  Covers section component pattern (indicator bar + icon + title + container), AppBar style, field labels, selection options, spacing rules, `MediaQuery` for responsiveness, `SafeArea`, and sliver-based screen structure. Read when building screens, sections, or responsive layouts.

- **Components & Interactions** → [references/components.md](references/components.md)
  Covers button system, text fields, snackbar patterns, FAB design, animation patterns (`flutter_animate`), card styling, icon usage, and interaction patterns. Read when implementing interactive components or animations.

## Mandatory Checklist

Before completing any design task, verify:

- [ ] No hardcoded colors (`Colors.xxx`) — use `color.*` global getter
- [ ] No hardcoded text styles — use `text.*` global getter
- [ ] All elevation = 0, no shadows
- [ ] Font Awesome Pro icons only (no Material Icons)
- [ ] Spacing in multiples of 8
- [ ] Localization keys in Korean: `'한글키'.tr()`
- [ ] No dark mode code
- [ ] Section pattern followed (indicator bar + icon + title)
- [ ] Borders use `color.outlineVariant`
- [ ] Content screens use `CustomScrollView` with slivers
