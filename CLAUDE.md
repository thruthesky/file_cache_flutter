# PhilGo v6 App Development Guidelines

This document outlines the mandatory rules to follow when collaborating with AI on PhilGo v6 app development.

## Table of Contents

1. [Top Priority Rules](#top-priority-rules)
2. [Code Writing Rules](#code-writing-rules)
3. [Comments and Documentation](#comments-and-documentation)
4. [Development Workflow](#development-workflow)
5. [Reference Documents](#reference-documents)

---

## Standard Workflow

This checklist must be completed whenever the user request a work:

- [ ] Always use the dart_mcp MCP and DTD to hot reload after code changes.
- [ ] Strictly follow the COT (Chain-of-Thought) approach. Clearly explain the flow of reasoning in all tasks.
  - When the developer requests "cot", think step by step and approach problem-solving in stages.
    - (1) First, understand the core of the problem in more detail.
    - (2) Establish a plan for solving the problem.
    - (3) Completely ignore the existing code and approach it fresh from the beginning.
    - (4) Write completely new code to solve the problem.
    - (5) Conduct testing step by step.
- [ ] Strictly follow the TOT (Tree-of-Thought) approach. Break down complex tasks into smaller sub-tasks for processing.
  - When the developer requests "tot", decompose the problem into multiple sub-problems, solve each sub-problem independently, and then integrate them finally.
    - (1) First, decompose the problem into multiple sub-problems (branching).
    - (2) Prepare independent solutions for each sub-problem.
    - (3) Integrate the solutions of each sub-problem to derive the final solution.

## Top Priority Rules

### 1. Never Modify main.dart Theme Without Explicit Request

**Rule**: Only modify Theme in `philgo_app/lib/main.dart` when explicitly requested

- ❌ DO NOT modify main.dart for general UI modification requests
- ✅ ONLY modify when there's a **clear request** like "modify main theme" or "change entire Theme"
- Use `Theme.of(context)` in individual screens or widgets

### 2. Theme-Based Styling Required (No Custom Styles)

**Rule**: Always use `Theme.of(context)` to apply styles

❌ **NEVER USE**:

```dart
color: Colors.blue              // Hardcoded color
fontSize: 16                    // Hardcoded size
backgroundColor: Colors.white  // Direct color specification
```

✅ **CORRECT WAY**:

```dart
color: Theme.of(context).colorScheme.primary
style: Theme.of(context).textTheme.bodyLarge
backgroundColor: Theme.of(context).colorScheme.surface
```

### 3. Never Use Inline Styles

**Rule**: Do not specify `style` attribute inside buttons, cards, or other widgets

❌ **PROBLEM**: Specifying style in Text inside Button overrides Button's Theme

```dart
// ❌ NEVER DO THIS
ElevatedButton(
  child: Text('Login', style: TextStyle(color: Colors.white)),
)

// ✅ CORRECT WAY
ElevatedButton(
  child: Text('Login'),  // Theme is automatically applied
)
```

### 4. Work with Deep Thinking

**Rule**: Analyze all requests deeply before working

- ✅ Understand the true intent of the request
- ✅ Review impact scope and side effects
- ✅ Find the optimal solution
- ❌ NO superficial and hasty decisions

### 5. Always response in english

---

## Code Writing Rules

### 1. Import Statements Required

Always add import statements when using any widget or class

```dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
```

### 2. Never Hardcode Text (i18n Required)

All user-facing text must use i18n translations

❌ **NEVER USE**: `Text("Hello World")`
✅ **CORRECT WAY**: `Text(T.hello_world)` or `Text(Lo.hello_world)`

Location: Manage translations in `philgo_app/lib/l10n/*.arb` files

### 3. Use flutter_animate Package for Animations

❌ **NEVER USE**:

```dart
Creating AnimationController directly
Using AnimatedBuilder directly
```

✅ **ALWAYS USE**:

```dart
import 'package:flutter_animate/flutter_animate.dart';

Container()
  .animate()
  .fadeIn(duration: 300.ms)
  .slideX(begin: -0.2, end: 0)
```

### 4. Use Latest Flutter/Dart Features

- Flutter 3.35.2 or higher
- Dart 3.9 or higher
- Must use latest syntax and APIs

---

## Comments and Documentation

### 1. English Comments Required

Write detailed comments in english for all Dart files

### 2. Enhanced Comments for Theme-Related Code

Theme, style, and color-related code **must** explain reasons and effects in comments

```dart
// ✅ CORRECT EXAMPLE
Text(
  'Hello',
  style: Theme.of(context)
    .textTheme
    .bodyLarge
    ?.copyWith(
      // Change bodyLarge color to primary for emphasis
      color: Theme.of(context).colorScheme.primary,
    ),
)
```

---

## Development Workflow

### 1. Hot reload changes after code modifications

**🔄 CRITICAL RULE: Always perform hot reload after making code changes**

- ✅ **MUST** execute hot reload after every code modification
- ✅ Use `mcp__dart__hot_reload` tool immediately after editing files
- ✅ Verify changes are applied before proceeding to next task
- ❌ NEVER skip hot reload - changes won't be visible without it

**When to hot reload:**

- After editing UI/design code
- After modifying widgets
- After changing Theme or styles
- After fixing bugs
- After ANY code change

**How to hot reload:**

```
Use mcp__dart__hot_reload tool with clearRuntimeErrors: true
```

### 2. Pre-Work Checklist

**Required Order**:

1. Specify reference documents
2. 5W1H Analysis (When, Where, What, How, Why, Who)
3. 📝 Present Work Plan (PLAN)
4. ✅ Present TODO List
5. Start actual work

### 3. When Analysis/Explanation is Requested

When keywords like "analyze", "explain", "review" are included:

- ✅ Only read and analyze code
- ❌ NEVER modify source code
- ❌ NEVER edit files

### 4. When Naming is Requested

When developer requests "naming" only:

- ✅ Record appropriate Korean names as comments for each UI/widget/item in source code
- ✅ Define common terminology for smooth communication between developers
- ✅ Add easy-to-understand descriptions for each code group

**Naming Comment Rules**:

- Add naming comments in `///` format at the top of each UI element or widget group
- Names should be concise and clear in Korean
- Express the role and function intuitively

**Example**:

```dart
/// Comment Header
class CommentHeader extends StatelessWidget {
  ...
}
```

### 5. When Design is Requested

When developer makes UI/design-related requests:

- ✅ **Must refer to [App Design Guide](./docs/apps/app-design-v2.md) first**
- ✅ Follow Flat design principles (no borders/shadows)
- ✅ Theme-based styling required
- ✅ Use Font Awesome Pro icons (Light > Regular > Solid priority)
- ✅ Use multiples of 8 for spacing
- ✅ Set elevation to 0

**Design-Related Keywords**:

- "design", "UI", "style", "color", "layout"
- "button", "card", "menu", "list"
- "spacing", "margin", "size", "font"
- "icon", "image", "background"

**IMPORTANT**: All design work must follow app-design.md rules, and main.dart Theme modification is only allowed upon explicit request.

---

## Reference Documents

### Required Reference Documents

For all PhilGo app development requests:

- [App Development Guidelines](./docs/apps/app-dev-guideline.md)
- [PhilGo App Development Guidelines](./docs/apps/philgo/philgo-app-development-guideline.md)
- [Flutter Coding Guidelines](./docs/apps/flutter-coding-guideline.md)

### Reference Documents by Keyword

| Keyword                | Reference Document                                            |
| ---------------------- | ------------------------------------------------------------- |
| Design, Design         | [App Design Guide](./docs/apps/app-design.md)                 |
| Multilingual, i18n     | [Flutter i18n](./docs/apps/app-l10n.md)                       |
| State Management       | [Flutter State Management](./docs/apps/state-management.md)   |
| API, PhilGo Connection | [PhilGo API Documentation](./docs/apps/flutter-philgo-api.md) |
| Routing                | [Flutter Routing](./docs/apps/routing.md)                     |

### Key File Locations

| Purpose             | Path                                          |
| ------------------- | --------------------------------------------- |
| Main Settings       | `philgo_app/lib/main.dart`                    |
| Translation Files   | `philgo_app/lib/l10n/*.arb`                   |
| State Management    | `philgo_app/lib/state/app.state.dart`         |
| API Functions       | `philgo_app/lib/philgo/philgo.functions.dart` |
| Custom Widgets      | `philgo_app/lib/widgets/`                     |
| Translation Classes | `philgo_app/lib/l10n/app_localizations.dart`  |

---

## Flat Design Required Rules

### Must Follow When Design is Requested

- ✅ Flat design style required
- ❌ NO border usage
- ❌ NO shadow usage
- ✅ Distinguish UI elements only with color contrast
- ✅ All elevation set to 0

### Prioritize Font Awesome Pro Icons

- **Priority**: Light > Regular > Solid
- Example: `FontAwesomeIcons.lightCamera` (light style)
- Icons must be added to all buttons, menus, and lists

---

## Provider and Selector Required Rules

### Use Provider Package for State Management

❌ **NEVER USE**: Riverpod, Consumer, context.watch()
✅ **ALWAYS USE**: Selector

```dart
Selector<AppState, int>(
  builder: (context, value, _) => Text(value.toString()),
  selector: (context, model) => model.someValue,
)
```

---

## Checklist

Before starting work:

- [ ] Check reference documents
- [ ] Complete 5W1H analysis
- [ ] Establish work plan
- [ ] Create TODO list

After completing work:

- [ ] Add Korean comments
- [ ] Verify Theme-based styling

---

**Final Check**: All rules are applied **without exception**. Follow these rules even for simple tasks.
