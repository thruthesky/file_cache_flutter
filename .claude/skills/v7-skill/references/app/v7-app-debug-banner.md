# 홈 화면 디버그 배너 (HomeDevModeBanner)

## 개요

홈 화면의 디버그 배너는 개발자/관리자 전용 위젯으로, API 연결 상태(프로덕션/개발), ENV 환경변수, 설정 리로드 타이머, 로그인 유저 상세 정보(idx, id, name, nickname, phone, firebase uid, gender, level, point 등)를 한 곳에 표시한다.

## 기본 동작

- 디버그 배너는 **기본적으로 숨겨져 있다** (`HomeDevModeBanner.visible` 초기값: `false`)
- 프로덕션 앱에서는 일반 사용자에게 절대 노출되지 않는다
- 프로덕션 API(`philgo.com`, `www.philgo.com`)에 연결되어 있으면 빨간색 경고(`PRODUCTION MODE`)를 강하게 표시한다
- 개발 서버에 연결되어 있으면 초록색으로 표시한다

## 표시 방법 (롱 프레스 토글)

1. 홈 화면 퀵 메뉴(헬퍼 메뉴)의 **"내 정보" 아이콘**을 **길게 누르면(롱 프레스)** 디버그 배너가 토글된다
2. 한 번 롱 프레스 → 배너 표시, 다시 롱 프레스 → 배너 숨김
3. 배너 우측 상단의 X 버튼으로도 닫을 수 있다 (`_dismissed` 상태)

## 토글 조건

롱 프레스는 다음 조건 중 **하나 이상**을 만족할 때만 동작한다:

| 조건 | 설명 |
|------|------|
| `kDebugMode` | 로컬 개발 모드 (디버그 빌드) |
| 관리자 로그인 | Firebase UID가 `SettingsState.settings.adminUids` 목록에 포함 |

## 배너가 표시하는 정보

| 항목 | 설명 |
|------|------|
| 설정 리로드 타이머 | `SettingService.instance.remainingSeconds` 카운트다운 |
| PRODUCTION MODE 경고 | 프로덕션 API 연결 시 빨간색 경고 |
| API 엔드포인트 | `Config.v7ApiEndpoint` 값 |
| ENV 환경변수 | `String.fromEnvironment('ENV')` 값 |
| 유저 정보 | idx, id, name, nickname, phone, firebase uid, gender, level, point, posts, comments |

## 관련 파일

| 파일 | 역할 |
|------|------|
| `lib/home/widgets/home_dev_mode_banner.dart` | 디버그 배너 위젯, `HomeDevModeBanner.visible` (static `ValueNotifier<bool>`) |
| `lib/home/widgets/home_profile_menu_item.dart` | 내 정보 아이콘 위젯, `_toggleDevBanner()` 메서드로 롱 프레스 처리 |
| `lib/home/widgets/home_helper_menu_section.dart` | 헬퍼 메뉴 섹션, `HomeProfileMenuItem`을 첫 번째 아이템으로 포함 |
| `lib/home/home.screen.dart` | 홈 화면, `HomeDevModeBanner`를 `SliverToBoxAdapter`로 포함 |

## 핵심 소스코드

### 상태 제어: static ValueNotifier

`HomeDevModeBanner` 위젯에 `static final visible`로 전역 표시 상태를 관리한다. 다른 위젯에서 `HomeDevModeBanner.visible.value`를 변경하면 배너가 즉시 반응한다.

```dart
// lib/home/widgets/home_dev_mode_banner.dart
class HomeDevModeBanner extends StatefulWidget {
  const HomeDevModeBanner({super.key});

  /// 배너 표시 여부 (내 정보 아이콘 롱 프레스로 토글)
  static final visible = ValueNotifier<bool>(false);

  @override
  State<HomeDevModeBanner> createState() => _HomeDevModeBannerState();
}
```

### ValueNotifier 리스닝

`_HomeDevModeBannerState`에서 `initState`/`dispose`로 리스너를 등록/해제한다.

```dart
// lib/home/widgets/home_dev_mode_banner.dart
class _HomeDevModeBannerState extends State<HomeDevModeBanner> {
  @override
  void initState() {
    super.initState();
    HomeDevModeBanner.visible.addListener(_onVisibilityChanged);
  }

  @override
  void dispose() {
    HomeDevModeBanner.visible.removeListener(_onVisibilityChanged);
    super.dispose();
  }

  void _onVisibilityChanged() => setState(() {});
}
```

### 배너 표시 조건

`visible.value`가 `false`이거나 사용자가 X 버튼으로 닫은 경우(`_dismissed`) 빈 위젯을 반환한다.

```dart
// lib/home/widgets/home_dev_mode_banner.dart - build()
@override
Widget build(BuildContext context) {
  if (!HomeDevModeBanner.visible.value || _dismissed) return const SizedBox.shrink();
  // ... 배너 UI 렌더링
}
```

### 롱 프레스 토글: 조건 체크 후 ValueNotifier 토글

`HomeProfileMenuItem`(StatelessWidget)의 `GestureDetector`에 `onLongPress`를 추가하여 디버그 배너를 토글한다. `kDebugMode`도 아니고 관리자도 아니면 아무 동작도 하지 않는다.

```dart
// lib/home/widgets/home_profile_menu_item.dart
class HomeProfileMenuItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UserEditScreen.push(context),
      onLongPress: () => _toggleDevBanner(context),
      child: SizedBox(/* ... */),
    );
  }

  /// kDebugMode이거나 관리자 로그인 시 디버그 배너 토글
  void _toggleDevBanner(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isAdmin = uid.isNotEmpty &&
        (SettingsState.of(context).settings?.adminUids.contains(uid) ?? false);
    if (!kDebugMode && !isAdmin) return;
    HomeDevModeBanner.visible.value = !HomeDevModeBanner.visible.value;
  }
}
```

### 홈 화면에서의 배치

`HomeScreen`의 `CustomScrollView` 내에서 퀵 글쓰기 박스 바로 아래, 헬퍼 메뉴 바로 위에 배치된다.

```dart
// lib/home/home.screen.dart
CustomScrollView(
  slivers: [
    // ... 메뉴 카테고리, 퀵 글쓰기
    const SliverToBoxAdapter(child: HomeDevModeBanner()),  // 디버그 배너
    const SliverToBoxAdapter(child: HomeHelperMenuSection()),  // 헬퍼 메뉴
    // ... 배너, 최신글, 공지 등
  ],
)
```

## 프로덕션 판별 로직

`philgo.com` 또는 `www.philgo.com`에 연결되어 있거나, ENV가 `dev`가 아닌 경우 프로덕션으로 판별한다. 서브도메인(`v7-local.philgo.com` 등)은 프로덕션이 아니다.

```dart
bool get _isProduction {
  final uri = Uri.tryParse(Config.v7ApiEndpoint);
  final host = uri?.host ?? '';
  final isProductionHost = host == 'philgo.com' || host == 'www.philgo.com';
  return isProductionHost || (_env != 'dev' && _env.isEmpty);
}
```
