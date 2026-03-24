# Layout & Responsiveness

## Screen Layout with Custom Slivers

Content screens use `CustomScrollView` with slivers for scrollable layout:

### Detail Screen Pattern (post view, company view)

```dart
CustomScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  slivers: [
    SliverAppBar(
      pinned: true,
      backgroundColor: color.surface,
      title: Text('제목'.tr(), style: text.titleLarge),
      // For collapsible header image:
      // expandedHeight: 240,
      // flexibleSpace: FlexibleSpaceBar(background: _buildHeaderImage()),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 28,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildSection(title: '섹션1'.tr(), icon: icon1, child: content1),
            _buildSection(title: '섹션2'.tr(), icon: icon2, child: content2),
          ],
        ),
      ),
    ),
  ],
)
```

### Home Screen Pattern (multiple independent sections)

```dart
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: SafeArea(child: MenuCategories())),
    _sectionGap,  // SliverToBoxAdapter(child: SizedBox(height: 16))
    SliverToBoxAdapter(child: BannerSection()),
    _sectionGap,
    SliverToBoxAdapter(child: LatestPostsSection()),
    _sectionGap,
    SliverToBoxAdapter(child: NoticeSection()),
  ],
)
```

### Bottom Input Pattern (comment bar, chat input)

For screens with a fixed bottom input outside the scroll area:

```dart
Column(
  children: [
    Expanded(
      child: CustomScrollView(slivers: [...]),
    ),
    CommentInputBar(), // Fixed at bottom, outside scroll
  ],
)
```

### Key Sliver Types

| Sliver | Usage |
|--------|-------|
| `SliverAppBar` | Pinned toolbar with optional collapsible header (`expandedHeight`, `FlexibleSpaceBar`) |
| `SliverToBoxAdapter` | Wraps any Box widget (Column, Padding, individual sections) |
| `SliverFillRemaining` | Loading/error states — centers content in remaining viewport space |

### Loading & Error States

```dart
if (_isLoading)
  SliverFillRemaining(
    child: Center(child: CircularProgressIndicator()),
  )
else if (_errorMessage != null)
  SliverFillRemaining(
    child: Center(child: Text(_errorMessage!)),
  )
else
  SliverToBoxAdapter(child: _buildContent()),
```

### Scroll Controller for Collapse Tracking

For screens with collapsible `SliverAppBar` headers:

```dart
final _scrollController = ScrollController();
bool _isCollapsed = false;

@override
void initState() {
  super.initState();
  _scrollController.addListener(() {
    final collapsed = _scrollController.offset > 200;
    if (collapsed != _isCollapsed) {
      setState(() => _isCollapsed = collapsed);
    }
  });
}
```

## Page Layout Spacing

| Property | Value |
|----------|-------|
| Page padding | `EdgeInsets.all(16)` |
| Section gap | `spacing: 28` in Column |
| First section margin | `SizedBox(height: 8)` |
| Section gap (slivers) | `SliverToBoxAdapter(child: SizedBox(height: 16))` |

## Section Component Pattern (MUST FOLLOW)

Every content section uses indicator bar + icon + title + container:

```dart
Widget _buildSection({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section header
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 12),
        child: Row(
          children: [
            // Indicator bar
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            // Icon
            FaIcon(icon, size: 14, color: color.onSurfaceVariant),
            const SizedBox(width: 6),
            // Title
            Text(
              title,
              style: text.titleSmall?.copyWith(
                color: color.onSurface,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      // Content container
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color.surfaceContainerLowest,
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.5),
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

### Section Header Specs

| Property | Value |
|----------|-------|
| Indicator bar | 3px wide, 16px tall, primary color, 2px radius |
| Icon | 14px, `onSurfaceVariant` color |
| Title | `text.titleSmall`, normal weight, 0.2 letter spacing |
| Header padding | `left: 4, bottom: 12` |

### Section Container Specs

| Property | Value |
|----------|-------|
| Background | `color.surfaceContainerLowest` |
| Border | 1px, `outlineVariant` at 50% alpha |
| Border radius | 16px |
| Padding | `EdgeInsets.all(20)` |
| Clip | `Clip.antiAlias` |

## AppBar Style

```dart
AppBar(
  title: Text('페이지제목'.tr(), style: text.titleLarge),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(1),
    child: Container(height: 1, color: color.outlineVariant),
  ),
)
```

## Field Labels

```dart
Widget _buildFieldLabel(String label, IconData icon) {
  return Row(
    children: [
      FaIcon(icon, size: 14, color: color.onSurfaceVariant),
      const SizedBox(width: 8),
      Text(
        label,
        style: text.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: color.onSurfaceVariant,
        ),
      ),
    ],
  );
}
```

## Selection Options (Radio/Checkbox)

```dart
Widget _buildOption({
  required String label,
  required IconData icon,
  required bool isSelected,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? color.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? color.primary
              : color.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [/* Radio/Checkbox + Icon + Label */],
      ),
    ),
  );
}
```

| State | Background | Border Color | Border Width |
|-------|-----------|-------------|-------------|
| Selected | `primary` at 10% alpha | `primary` | 1.5px |
| Unselected | `transparent` | `outlineVariant` at 50% alpha | 1.0px |

## Spacing Rules

All spacing must be multiples of 8:

| Context | Value |
|---------|-------|
| Page padding | 16px |
| Section gap | 28px (Column spacing) |
| Container padding | 20px |
| Item spacing | 8-12px |
| Icon-text gap | 6-8px |
| Header bottom | 12px |

## Responsiveness

### MediaQuery

Use `MediaQuery` for screen-dependent layout:

```dart
final screenWidth = MediaQuery.of(context).size.width;

// Responsive column count
final crossAxisCount = screenWidth > 600 ? 3 : 2;

// Responsive padding
final horizontalPadding = screenWidth > 400 ? 16.0 : 8.0;
```

### SafeArea

```dart
// Top only (respects notch/status bar)
SafeArea(bottom: false, child: content)

// Full protection
SafeArea(child: content)
```

## Text Fields

Configure text fields properly:

```dart
TextField(
  textCapitalization: TextCapitalization.sentences,
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    hintText: '힌트텍스트'.tr(),
    // Theme handles border styling automatically
  ),
)
```

| Property | When to Set |
|----------|------------|
| `textCapitalization` | Always — `sentences` for general, `none` for email/password |
| `keyboardType` | Always — `emailAddress`, `phone`, `number`, `text` |
| `hintText` | Always — use Korean localization key |

## Border Radius Reference

| Element | Radius |
|---------|--------|
| Section container | 16px |
| Card | 12px |
| Input field | 12px |
| Selection option | 12px |
| Button | 8px |
| Indicator bar | 2px |
