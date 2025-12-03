---
name: frontend-design
description: Create distinctive, production-grade Flutter UI/UX with high design quality. ALWAYS use this skill when the user asks to create, update, design, modify, or build any page, screen, widget, or UI component. Generates creative, polished Flutter code following PhilGo design guidelines with Theme-based styling and Flat design principles.
---

This skill guides creation of distinctive, production-grade Flutter interfaces following PhilGo design guidelines. Implement real working Flutter code with exceptional attention to aesthetic details and creative choices.

The user provides UI/UX requirements: a screen, page, widget, or component to build. They may include context about the purpose, audience, or technical constraints.

## PhilGo Design Rules (MANDATORY)

**CRITICAL REQUIREMENTS - MUST FOLLOW:**

1. **Theme-Based Styling ONLY**: Always use `Theme.of(context)` - NEVER hardcode colors, fonts, or styles
2. **Flat Design**: NO borders, NO shadows, elevation: 0, distinguish with color contrast only
3. **No Inline Styles**: NEVER override Theme inside widgets (especially buttons)
4. **Font Awesome Pro Icons**: Use FontAwesomeIcons (Light > Regular > Solid priority)
5. **i18n Required**: NEVER hardcode text, always use `T.key` or `Lo.key` from translations
6. **Spacing**: Use multiples of 8 (8, 16, 24, 32, etc.)
7. **flutter_animate**: Use for all animations, NEVER AnimationController directly
8. **Hot Reload**: Always use mcp__dart__hot_reload after code changes

## Design Thinking

Before coding, understand the context and commit to a design direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Flat, minimal, clean, modern - following PhilGo design system
- **Theme Alignment**: Uses existing Theme colors and text styles consistently
- **Differentiation**: What makes this intuitive and delightful to use?

**CRITICAL**: Execute with precision following PhilGo guidelines. The key is Theme consistency and Flat design principles.

Then implement working Flutter code that is:

- Production-grade and functional
- Theme-based styling throughout
- Flat design with no borders/shadows
- Properly internationalized
- Meticulously refined in every detail

## Flutter Design Guidelines

Focus on:

- **Typography**: ALWAYS use `Theme.of(context).textTheme` styles (displayLarge, headlineMedium, bodyLarge, etc.). NEVER use TextStyle directly or hardcode fontSize/fontWeight. Trust the Theme's font choices.
- **Color & Theme**: ALWAYS use `Theme.of(context).colorScheme` properties (primary, secondary, surface, background, error, etc.). NEVER hardcode Colors.blue or any direct color values. Use Theme for complete consistency.
- **Motion**: Use `flutter_animate` package for ALL animations. Apply .animate().fadeIn(), .slideX(), .shimmer(), etc. Focus on high-impact moments: page transitions, reveals, micro-interactions. Use staggered delays for list items.
- **Spatial Composition**: Use Column, Row, Stack, Positioned for layouts. Apply SizedBox for spacing (multiples of 8). Use Expanded, Flexible for responsive layouts. Leverage ListView, GridView for scrolling content.
- **Backgrounds & Visual Details**: Use Theme colors with Container backgrounds. Apply gradients via BoxDecoration (LinearGradient, RadialGradient) when needed. Keep elevation at 0 for Flat design. NO BoxShadow, NO Border (unless explicitly requested).

**CRITICAL FLUTTER RULES:**

❌ NEVER DO:
```dart
Text('Login')  // Hardcoded text
color: Colors.blue  // Hardcoded color
fontSize: 16  // Hardcoded size
border: Border.all()  // Borders not allowed
elevation: 4  // Must be 0
ElevatedButton(child: Text('Click', style: TextStyle(...)))  // Inline style overrides Theme
```

✅ ALWAYS DO:
```dart
Text(T.login)  // i18n translation
color: Theme.of(context).colorScheme.primary  // Theme color
style: Theme.of(context).textTheme.bodyLarge  // Theme text style
elevation: 0  // Flat design
ElevatedButton(child: Text(T.click))  // Let Theme handle styling
```

**IMPORTANT**: Flutter design should follow PhilGo's Flat design system with Theme-based styling. Every color, font, and style MUST come from Theme.of(context). Keep designs clean, minimal, and consistent.

## Required Imports

Always include necessary imports:

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo_app/l10n/app_localizations.dart';  // For T.key translations
```

## Workflow

1. **Reference Documents**: Check [App Design Guide](./docs/apps/app-design.md) and [PhilGo Guidelines](./docs/apps/philgo/philgo-app-development-guideline.md)
2. **Plan**: Create TODO list for the design work
3. **Implement**: Write Flutter code following all PhilGo rules
4. **Hot Reload**: Use mcp__dart__hot_reload to test changes
5. **Verify**: Ensure Theme-based styling, Flat design, i18n, and proper imports

Remember: Create exceptional Flutter UI that strictly follows PhilGo design guidelines. Every detail matters - from Theme usage to spacing to internationalization.
