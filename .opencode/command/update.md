---
description: Analyze and modify source code using philgo-skill with CoT (Chain-of-Thought) and ToT (Tree-of-Thought) approaches in Flutter + Dart + Firebase + Provider environment for PhilGo App project.
allowed-tools: Bash(*)
argument-hint: [Detailed description of what needs to be modified in PhilGo App]
---


# Flutter + Dart + Firebase + Provider Development Expert

You are an expert in Flutter/Dart programming language as well as Firebase, Provider state management, go_router routing, and Material 3 Flat Design development.

Analyze and provide solutions for the following requirements (or issues): $ARGUMENTS

# 🔥 Required: Skill Usage Instructions

## philgo-skill Invocation (Required)
Before starting any work, you MUST invoke philgo-skill to understand the project structure and rules.

## flutter-design-skill Invocation (For UI/Design Work)
For UI/design related tasks, invoke flutter-design-skill to reference Comic style UI guidelines.

## For API Work
For PhilGo API integration work, reference `.claude/skills/philgo-skill/references/api/*.md` documents.

# Requirements Analysis Phase
- [ ] **🔥 [Required]** Invoke philgo-skill to understand the overall project structure and rules.
- [ ] **🔥 [For UI Work]** Invoke flutter-design-skill to understand design guidelines.
- [ ] First, perform complete CoT and ToT analysis on the user's `$ARGUMENTS` request, then read appropriate philgo-skill documents that match the user's requirements.
- [ ] Find code parts related to user requirements. Specifically, analyze parent widgets/Screens/States, sibling widgets/Screens/States, current code's widgets/Screens/States and their logic, and all child widgets/Screens/States using CoT and ToT approaches to understand relationships, code structure, data flow, before/after layout, left/right layout, and code connections.
- [ ] Reference philgo-skill's references documents to analyze requirements (or issues).
- [ ] Strictly follow the COT (Chain-of-Thought) approach. Clearly explain the reasoning flow in all tasks.
  - (1) First, understand the core of the requirement (problem) in detail.
  - (2) Establish a plan for implementing the requirement (problem/issue).
  - (3) Reference existing code, but approach from scratch with new logic. Use existing code only as reference.
  - (4) Conduct step-by-step testing.
- [ ] Strictly follow the TOT (Tree-of-Thought) approach. Break down complex tasks into smaller sub-tasks.
  - (1) First, decompose the requirement (problem) into multiple sub-problems (branching).
  - (2) Prepare independent solutions for each sub-task (problem).
  - (3) Integrate solutions from each sub-task (problem) to derive the final solution.
- [ ] Analyze code at the Flutter widget level, examining each widget's State, props, Provider/Selector to deeply understand data flow and widget interactions.
- [ ] Use debugPrint() logs to check messages in Flutter console.
- [ ] If needed, use Dart MCP to check internal state of PhilGo app running in debug mode.

# Execution Phase
- [ ] You will develop in Flutter + Dart + Firebase + Provider environment.
- [ ] Reference `.claude/skills/philgo-skill` documents to deeply understand the overall system structure and behavior.
- [ ] Always strictly follow `COT (Chain-of-Thought)` and `TOT (Tree-of-Thought)` approaches, analyzing and solving problems step by step.
- [ ] Report discovered issues and solutions in detail to the user during requirement implementation (debugging/resolution) process.

# Mandatory Rules

## Theme Related
- [ ] **NEVER**: Modify Theme in main.dart without explicit request.
- [ ] **MUST**: Use `Theme.of(context)` in individual widgets.

## No Hardcoding
- [ ] **NEVER**: Directly specify `Colors.blue`, `fontSize: 16`, `backgroundColor: Colors.white`, etc.
- [ ] **MUST**: Use `Theme.of(context).colorScheme.primary`, `Theme.of(context).textTheme.bodyLarge`.

## State Management
- [ ] **NEVER**: Use Riverpod, Consumer, context.watch().
- [ ] **MUST**: Use Provider + Selector pattern.
```dart
Selector<AppState, User?>(
  selector: (_, appState) => appState.user,
  builder: (_, user, _) => Text(user?.nickname ?? ''),
)
```

## i18n Required
- [ ] **NEVER**: Hardcode text like `Text("Hello World")`.
- [ ] **MUST**: Use i18n support like `Text(T.hello)`.

## Flat Design Principles
- [ ] All elevation = 0
- [ ] No shadows allowed
- [ ] Distinguish UI elements only with color contrast

## Icons
- [ ] Use Font Awesome Pro icons (Priority: Light > Regular > Solid)

## Animation
- [ ] Must use flutter_animate package

# Testing and Verification Phase
- [ ] After code work, MUST run `flutter analyze` to check and fix errors/warnings.
- [ ] Run `flutter test` for unit tests if needed.
- [ ] For API related work, use test scripts in philgo-skill's scripts folder.

# Key File Location Reference

| Purpose | Path |
|---------|------|
| Main Settings | `lib/main.dart` |
| Router | `lib/router.dart` |
| App State | `lib/state/app.state.dart` |
| Navigation State | `lib/state/navigation.state.dart` |
| Theme | `lib/themes/app.theme.dart` |
| Spacing Tokens | `lib/themes/app.spacing.dart` |
| i18n | `lib/l10n/*.arb` |
| PhilgoService | `packages/philgo_api/lib/src/services/philgo.service.dart` |
| Post Model | `packages/philgo_api/lib/src/post/models/post.model.dart` |

# Work Completion Checklist
- [ ] Run `flutter analyze` and resolve all errors/warnings
- [ ] Verify Theme-based styling
- [ ] Verify i18n applied (no hardcoded text)
- [ ] Verify Provider + Selector pattern compliance
- [ ] Add English comments
- [ ] Verify Flat Design principles compliance
