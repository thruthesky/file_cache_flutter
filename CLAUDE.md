This project is a Flutter app for building PhilGo v7 application.

# 🔴🔴🔴 Mandatory Workflow — MUST Follow for EVERY Task 🔴🔴🔴

> **THIS WORKFLOW IS NON-NEGOTIABLE. Every single task — no matter how small — MUST follow these steps. Skipping any step is strictly prohibited.**

1. **Before starting work**: Read at least 2 relevant v7-skill reference documents from `.claude/skills/v7-skill/references/`.
2. **For Flutter app tasks**: Refer to docs under `.claude/skills/v7-skill/references/app/` folder for CRUD operations and patterns.
3. **After completing each task**: Git commit the changes (do NOT push).
4. **After finishing all work**: Update the v7-skill markdown files to reflect any new patterns, APIs, or architectural decisions.


# App Configuration

- All app configuration is defined in `lib/app.config.dart` (forum categories, etc.).


# Important Rules

## 🔴🔴🔴 Easy Localization 번역 키는 반드시 한글로 작성 🔴🔴🔴

- **THIS IS NON-NEGOTIABLE. 번역 키(key)는 반드시 한글로 작성해야 한다. 영어 키 사용은 절대 금지.**
- Easy Localization(이지 로컬리제이션)으로 텍스트를 번역할 때, `.tr` 또는 `tr()` 에 사용하는 **키(key)는 반드시 한글**이어야 한다.
- 올바른 예시: `'로그인'.tr()`, `'회원가입'.tr()`, `'설정'.tr()`
- **잘못된 예시 (절대 금지)**: `'login'.tr()`, `'signUp'.tr()`, `'settings'.tr()`
- 한글 키를 사용하면 번역이 없는 언어에서도 기본값으로 한글이 그대로 표시되어 UX가 자연스럽다.
- JSON 번역 파일에서도 키는 한글로 작성한다: `{ "로그인": "Login", "회원가입": "Sign Up" }`

## Never use packages/philgo_api/

- **NEVER** import or directly use any code from the `packages/philgo_api/` folder in the project.
- This package is deprecated/legacy and must not be imported or referenced in any new or existing code.
- **Reading is allowed**: You may read code in `packages/philgo_api/` to understand patterns, logic, or data structures, then regenerate equivalent code using the v7 API approach for this project.
- If you encounter imports from `packages/philgo_api/`, do not follow that pattern. Use the v7 API approach instead.


# Architecture Rules

## State vs Service 분리 원칙

- **State 클래스** (Provider의 ChangeNotifier): 상태 관리만 담당한다. API 호출, 비즈니스 로직, 데이터 변환 등을 직접 포함하지 않는다.
- **Service 클래스**: API 호출, 비즈니스 로직, 데이터 처리를 담당한다. State 클래스는 Service 클래스의 메서드를 호출하여 데이터를 가져온 후 상태만 업데이트한다.
- 예시: `UserState`는 `UserService.loadCurrentUser()`를 호출하고 결과 `UserModel`을 저장만 한다. API 호출 로직은 `UserService`에 있다.

## 데이터 클래스 필수 사용 원칙

- **`Map<String, dynamic>` 또는 JSON 타입 변수 사용 금지**: 서버/API 응답 데이터를 `Map<String, dynamic>`이나 `dynamic` 타입으로 직접 사용하지 않는다.
- **반드시 데이터 클래스(Model)를 정의**하여 사용한다. 모든 API 응답은 데이터 클래스의 `fromJson()` 팩토리를 통해 변환한 후 사용한다.
- **데이터 클래스 위치**: 해당 모듈의 `lib/{module}/` 폴더에 `{module}.model.dart` 파일로 생성한다 (예: `lib/user/user.model.dart`, `lib/post/post.model.dart`).
- 예시: `UserService.loadCurrentUser()`는 `UserModel`을 반환하고, `UserState`는 `UserModel?`을 저장한다.


# Design Principles

## Design references

- Use .claude/commands/design/*.md files as design references for UI and UX decisions.

## Font Awesome icons only

- Use only Font Awesome icons for all UI elements to maintain visual consistency and reduce asset management overhead.



# Debugging with Dart Tooling Daemon (DTD)

## Core Concept

DTD testing uses **hot reload** to inject temporary test code into `initState()` methods. This avoids app restarts and preserves the current app state, making it significantly faster than traditional testing approaches.

## Critical Rules

- **NEVER restart the app** — always use hot reload to apply changes
- **NEVER write e2e test code** (no `flutter_test`, `integration_test`, or test runner files)
- **NEVER create files in the `test/` directory** for DTD testing
- All test logic is written as **temporary code inside `initState()`** of existing screen widgets

## Testing Workflow

### Step 0: Confirm DTD URI (Required)

Before starting a test, **you must ask the user for the DTD URI**. The DTD URI is generated when the Flutter app is running in debug mode and is required to perform hot reload.

Ask the user as follows:
> "Please provide the DTD URI. It is displayed in the terminal when the Flutter app is running in debug mode. (e.g., `ws://127.0.0.1:xxxxx/yyyyyyy=/ws`)"

Hot reload cannot be performed without the DTD URI, so do not proceed with writing test code until the URI is received.

### Step 1: Navigate to the Target Screen

Add temporary code in `_AppScreenState.initState()` of `AppScreen` to programmatically navigate to the desired screen, then hot reload.

```dart
@override
void initState() {
  super.initState();
  // Temporary: navigate to the target screen
  WidgetsBinding.instance.addPostFrameCallback((_) {
    AppNavigationState.of(context).openCompanyScreen(); // or any target
  });
}
```

### Step 2: Interact with the Target Screen

In the target screen's `initState()`, add a delayed call to simulate user interaction (tap, input, etc.) by directly invoking the widget's handler methods with test data.

```dart
@override
void initState() {
  super.initState();
  // Temporary: simulate interaction after UI is built
  Future.delayed(const Duration(seconds: 1), () {
    _onSubmit(testData); // call the actual handler with test data
  });
}
```

### Step 3: Verify the Result

Display the result using a **long-lived SnackBar** so it remains visible for inspection.

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Result: $result'),
    duration: const Duration(seconds: 30),
  ),
);
```

### Step 4: Clean Up

After testing is complete, **remove all temporary test code** from `initState()` methods before committing.