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

## 🔴🔴🔴 Flutter Driver / E2E 테스트 절대 금지 🔴🔴🔴

- **THIS IS NON-NEGOTIABLE. Flutter 앱 개발 또는 소스 코딩 시 Flutter Driver 테스트, E2E 테스트, Integration Test를 절대로 작성하거나 실행하지 않는다.**
- `flutter_driver`, `integration_test`, `flutter_test` 패키지를 사용한 테스트 코드를 작성하지 않는다.
- `test/`, `integration_test/`, `test_driver/` 디렉토리에 테스트 파일을 생성하지 않는다.
- `flutter drive`, `flutter test` 등 테스트 실행 명령어를 사용하지 않는다.
- 테스트가 필요한 경우 CLAUDE.md의 "Debugging with Dart Tooling Daemon (DTD)" 섹션에 정의된 DTD 방식만 사용한다.

## Git Subtree 병렬 Pull & Push

- 사용자가 "subtree 업데이트", "서브트리 pull", "subtree push" 등을 요청하면, **모든 git subtree를 병렬로 pull한 후 병렬로 push**해야 한다.
- Subtree 목록과 상세 명령어는 `.claude/skills/v7-skill/SKILL.md`의 "Git Subtree 관리" 섹션을 참조한다.
- **작업 순서**: (1) 현재 변경사항 커밋 → (2) 모든 subtree 병렬 pull (`--squash`) → (3) 모든 subtree 병렬 push → (4) 메인 저장소 push
- 병렬 실행 시 각 subtree 작업을 별도의 Agent 또는 백그라운드 Bash 명령으로 동시에 실행한다.

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

### Step 3-B: Capture Screenshot for Visual Verification

**Important Workflow**: Instead of restarting the app or running Flutter Driver tests, capture screenshots directly from the running simulator using `xcrun simctl` commands:

```bash
# 기본 스크린샷 캡쳐 (결과 확인)
xcrun simctl io booted screenshot ~/tmp/sim_screenshot.png && echo "스크린샷 완료"

# 또는 더 자세한 정보와 함께
xcrun simctl io booted screenshot /Users/thruthesky/tmp/sim_v3.png 2>&1 && echo "완료"

# 추가 지연 시간을 포함한 버전 (레이아웃이 로드되는 시간을 고려)
sleep 3 && xcrun simctl io booted screenshot ~/tmp/sim_screenshot.png && echo "스크린샷 완료"
```

**Key Points:**
- 🔴 **앱을 재실행하지 말 것** — 현재 실행 중인 앱 유지
- 🔴 **Flutter Driver 테스트를 실행하지 말 것** — DTD hot reload만 사용
- Hot reload/restart로 코드 변경 적용 후 스크린캡쳐
- 시뮬레이터 실행 상태 확인 후 스크린샷 파일 경로 지정
- 스크린샷으로 UI 레이아웃 및 컴포넌트 렌더링 상태 검증

**Workflow Example:**
```
1. initState() 코드 작성
2. Hot reload/restart (Cmd+R 또는 DartDD)
3. 원하는 페이지로 자동 이동 확인
4. xcrun simctl 명령으로 스크린캡쳐
5. 스크린샷 결과 확인 → 필요시 코드 수정
6. 단계 2-5 반복
```

### Step 4: Clean Up

After testing is complete, **remove all temporary test code** from `initState()` methods before committing.