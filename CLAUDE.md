This project is a Flutter app for building PhilGo v7 application.

# App Configuration

- All app configuration is defined in `lib/app.config.dart` (forum categories, etc.).


# Important Rules

## Never use packages/philgo_api/

- **NEVER** use, import, or reference any code from the `packages/philgo_api/` folder.
- This package is deprecated/legacy and must not be used in any new or existing code.
- If you encounter imports from `packages/philgo_api/`, do not follow that pattern. Use the v7 API approach instead.


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