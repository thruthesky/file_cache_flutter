# Components & Interactions

## Button System

### ElevatedButton (Primary Action)

Styled via theme — no inline styling needed:

```dart
ElevatedButton(
  onPressed: () => doAction(),
  child: Text('버튼텍스트'.tr()),
)
```

Theme provides: blue background, white text, 8px radius, 0 elevation.

### TextButton (Secondary Action)

```dart
TextButton(
  onPressed: () => doAction(),
  child: Text('취소'.tr()),
)
```

Theme provides: blue text, no background.

## FAB (Floating Action Button)

Compact comic-style FAB specs:

| Size | Dimensions | Icon Size |
|------|-----------|-----------|
| Large (default) | 44x44 | 20px |
| Small | 36x36 | 18px |
| Mini | 32x32 | 16px |

```dart
Container(
  width: 44,
  height: 44,
  decoration: BoxDecoration(
    color: color.surface,
    border: Border.all(color: color.outline, width: 1.5),
    borderRadius: BorderRadius.circular(16),
  ),
  child: FaIcon(FontAwesomeIcons.plus, size: 20, color: color.onSurface),
)
```

## SnackBar

```dart
showComicSuccessSnackBar(context, '성공메시지'.tr());
showComicErrorSnackBar(context, '에러메시지'.tr());
showComicInfoSnackBar(context, '정보메시지'.tr());
showComicWarningSnackBar(context, '경고메시지'.tr());
```

## Card Styling

Cards use theme defaults — flat, no shadow:

```dart
Card(
  // Theme provides: elevation 0, transparent shadow,
  // surfaceContainerLowest color, 12px radius
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: content,
  ),
)
```

For custom containers (preferred over Card):

```dart
Container(
  decoration: BoxDecoration(
    color: color.surfaceContainerLowest,
    border: Border.all(
      color: color.outlineVariant.withValues(alpha: 0.5),
      width: 1.0,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  padding: const EdgeInsets.all(16),
  child: content,
)
```

## Font Awesome Icons

**Always use Font Awesome Pro. Never use Material Icons.**

Priority: Light > Regular > Solid

```dart
// Light (preferred)
FaIcon(FontAwesomeIcons.lightUser, size: 20, color: color.onSurface)

// Regular (fallback)
FaIcon(FontAwesomeIcons.user, size: 20, color: color.onSurface)

// Solid (rare, for emphasis)
FaIcon(FontAwesomeIcons.solidHeart, size: 20, color: color.primary)
```

### Icon Sizing

| Context | Size |
|---------|------|
| Header/AppBar | 18-20px |
| Section title | 14px |
| Field label | 14px |
| Button | 16-20px |
| FAB | 20px |
| Large display | 40-64px |
| Category badge | 48px |

## Animation Patterns

Use `flutter_animate` for all animations:

```dart
import 'package:flutter_animate/flutter_animate.dart';

// Staggered section entrance
_buildSection(title: '섹션1'.tr(), icon: icon1, child: content1)
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: 0.1, end: 0),

_buildSection(title: '섹션2'.tr(), icon: icon2, child: content2)
    .animate()
    .fadeIn(duration: 400.ms, delay: 100.ms)
    .slideY(begin: 0.1, end: 0),

_buildSection(title: '섹션3'.tr(), icon: icon3, child: content3)
    .animate()
    .fadeIn(duration: 400.ms, delay: 200.ms)
    .slideY(begin: 0.1, end: 0),
```

### Animation Specs

| Property | Value |
|----------|-------|
| Fade-in duration | 400ms |
| Slide-Y begin | 0.1 |
| Slide-Y end | 0 |
| Stagger delay | 100ms between sections |

### Special Animations

```dart
// Pulsing effect (for attention)
widget.animate(onPlay: (c) => c.repeat(reverse: true))
    .scaleXY(begin: 1.0, end: 1.08, duration: 800.ms)
    .shimmer(duration: 1500.ms)

// Rotation toggle (FAB +/x)
AnimatedRotation(
  turns: isOpen ? 0.125 : 0,  // 45 degrees
  duration: const Duration(milliseconds: 200),
  child: FaIcon(FontAwesomeIcons.plus),
)
```

## List Patterns

### Paginated List

```dart
PagedListView.separated(
  pagingController: _pagingController,
  builderDelegate: PagedChildBuilderDelegate<ItemModel>(
    itemBuilder: (context, item, index) => _buildListTile(item),
    firstPageErrorIndicatorBuilder: (_) => _buildError(),
    noItemsFoundIndicatorBuilder: (_) => _buildEmpty(),
  ),
  separatorBuilder: (_, __) => const Divider(),
)
```

### Masonry Grid

```dart
PagedMasonryGridView.count(
  crossAxisCount: 2,
  pagingController: _pagingController,
  builderDelegate: PagedChildBuilderDelegate<ItemModel>(
    itemBuilder: (context, item, index) => MasonryCard(item: item),
  ),
)
```

## Image Patterns

Always use `CachedNetworkImage` for network images:

```dart
CachedNetworkImage(
  imageUrl: url,
  fit: BoxFit.cover,
  placeholder: (_, __) => Container(color: color.surfaceContainerLowest),
  errorWidget: (_, __, ___) => FaIcon(FontAwesomeIcons.lightImage),
)
```

## Gradient Overlay (for text on images)

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withValues(alpha: 0.7),
      ],
    ),
  ),
)
```

## Avatar Pattern

```dart
CircleAvatar(
  radius: 24,
  backgroundColor: color.surfaceContainerLowest,
  child: CachedNetworkImage(
    imageUrl: avatarUrl,
    imageBuilder: (_, provider) => CircleAvatar(
      backgroundImage: provider,
    ),
    placeholder: (_, __) => FaIcon(FontAwesomeIcons.lightUser, size: 20),
    errorWidget: (_, __, ___) => FaIcon(FontAwesomeIcons.lightUser, size: 20),
  ),
)
```
