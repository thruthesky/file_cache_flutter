This project is a Flutter app for building PhilGo v7 application.


# Design Principles

## Design refernces

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

### Step 0: DTD URI 확인 (필수)

테스트를 시작하기 전에 **반드시 사용자에게 DTD URI를 요청**해야 합니다. DTD URI는 Flutter 앱이 디버그 모드로 실행 중일 때 생성되며, hot reload를 수행하는 데 필요합니다.

사용자에게 다음과 같이 요청하세요:
> "DTD URI를 제공해 주세요. Flutter 앱을 디버그 모드로 실행하면 터미널에 표시됩니다. (예: `ws://127.0.0.1:xxxxx/yyyyyyy=/ws`)"

DTD URI 없이는 hot reload를 수행할 수 없으므로, URI를 받기 전에 테스트 코드 작성을 진행하지 마세요.

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