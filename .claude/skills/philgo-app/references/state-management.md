# 상태 관리

## 개요

필고 앱은 `provider` 패키지(^6.1.5)를 사용하여 상태를 관리합니다.

**중요**: Riverpod이나 Consumer 사용 금지. Selector 사용 필수.

## 상태 관리 규칙

상태가 다음 조건을 만족할 때만 상태 관리 사용:
1. 여러 곳에서 상태 변경 필요
2. 여러 화면에서 상태 사용 필요

그 외의 경우 `globals.dart` 사용.

## Provider 설정

`lib/main.dart`에서 MultiProvider 설정:

```dart
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => NavigationState()),
    ],
    child: const MyApp(),
  ),
);
```

## AppState (lib/state/app.state.dart)

사용자 정보 및 앱 전역 상태 관리:

```dart
class AppState extends ChangeNotifier {
  String uid = '';
  String phoneNumber = '';
  User? user;
  Locale? _locale;

  static AppState of(BuildContext context, {bool listen = false}) {
    return Provider.of<AppState>(context, listen: listen);
  }

  void setLocale(Locale locale) { ... }
  void setUser(User user) { ... }
  void setLogout() { ... }
}
```

## NavigationState (lib/state/navigation.state.dart)

네비게이션 상태 관리 (페이지 이동 상태 전용):

```dart
class NavigationState extends ChangeNotifier {
  Post? post;
  String? initialPostId;
  String? initialCategory;
  HomeNavigationItem homeNav = HomeNavigationItem.home;
  String roomOrder = RoomOrder.singleOrder;

  static NavigationState of(BuildContext context, {bool listen = true}) {
    return Provider.of<NavigationState>(context, listen: listen);
  }
}
```

## Selector 사용 패턴

**필수**: 상태 구독 시 반드시 `Selector` 사용:

```dart
Selector<AppState, Locale?>(
  selector: (context, appState) => appState.locale,
  builder: (context, locale, child) {
    return Text(locale.toString());
  },
)
```

## 상태 접근 패턴

```dart
// 읽기 전용 (listen: false)
final appState = AppState.of(context, listen: false);

// 리빌드 필요 (listen: true)
final navState = NavigationState.of(context, listen: true);

// 글로벌 접근
User get login => AppState.of(globalContext, listen: false).user!;
```
