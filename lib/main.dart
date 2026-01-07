import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/functions/init.functions.dart';
import 'package:philgo/functions/init/build_number_check.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.theme.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:omni_video_player/omni_video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  OmniVideoPlayer.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => PhilgoState(), lazy: false),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    bool isRunningInE2EEnvironment = WidgetsBinding.instance.runtimeType
        .toString()
        .contains('Test');

    // ChatService.instance.initialize();
    UserService.instance.initialize(
      useUserPresence: true,
      onTapViewProfile: (context, user) {
        ProfileViewScreen.push(
          globalContext,
          firebaseUid: user.uid,
          nickname: user.nickname,
          photoUrl: user.photoUrl,
        );
      },
      onTapUserRecentPostItem: (context, post) => {
        PostViewScreen.push(context, post),
      },
    );

    if (isRunningInE2EEnvironment == false) {
      initMessagingService();
      if (Platform.isAndroid) {
        // Android-specific initialization
        initNotificationChannel();
      }
    }

    // Navigator가 완전히 준비된 후 globalContext 설정
    // 첫 프레임이 렌더링된 후에 실행되도록 보장
    // Set globalContext after Navigator is fully prepared
    // Ensure execution after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalNavigatorKey.currentContext != null) {
        PhilgoConfig.setGlobalContext(globalNavigatorKey.currentContext!);
      }

      /// 외부 공유 수신 서비스 초기화
      /// Initialize receive share service
      initializeReceiveShareService();

      /// Shorebird 코드 푸시 초기화 (180초 주기 업데이트 확인)
      /// Initialize Shorebird Code Push (check for updates every 180 seconds)
      initShorebirdCodePush();

      initMinimalBuildNumberCheck();
    });

    /// 테스트 할 때에만 사용. 테스트가 끝나면 주석 처리
    // _debugTestRun();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///
  // ignore: unused_element
  void _debugTestRun() {
    // Timer(Duration(seconds: 1), showUpgradeDialog);
    // Timer(Duration(seconds: 1), showShorebirdUpdateDialog);
    /// 디버깅용: 0.5초 후 메뉴 탭으로 이동 (확인 후 제거)
    /// For debugging: Navigate to menu tab after 0.5s (remove after verification)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugNavigateToMenu(context);
    });
  }

  /// 앱 시작 후 메뉴 탭으로 이동 (디버깅용 - 확인 후 제거)
  /// Navigate to menu tab after app start (for debugging - remove after verification)
  void _debugNavigateToMenu(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        NavigationState.of(
          context,
          listen: false,
        ).setHomeNavigation(HomeNavigationItem.menu);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
      localizationsDelegates: [
        Lo.delegate,
        PhilgoTr.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [...Lo.supportedLocales, ...PhilgoTr.supportedLocales],
    );
  }
}
