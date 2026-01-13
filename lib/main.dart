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
import 'package:philgo/services/chat_sound/chat_sound.service.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.theme.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:omni_video_player/omni_video_player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  OmniVideoPlayer.ensureInitialized();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

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
      onStateChange: (user) {
        if (user != null) {
          FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
          FirebaseAnalytics.instance.logLogin(parameters: {'uid': user.uid});
        } else {
          FirebaseCrashlytics.instance.setUserIdentifier('');
        }
      },
      onNewMessageArrived: () {
        // Play notification sound when new message arrives
        // 새 메시지가 도착하면 알림음 재생
        ChatSoundService.instance.playReceiveSound();
      },
    );

    // Initialize ChatSoundService - ChatSoundService 초기화
    // Must be called after UserService initialization
    // UserService 초기화 후에 호출해야 함
    ChatSoundService.instance.initialize();

    // Set callback for playing send sound when message is sent
    // 메시지 전송 시 전송음 재생을 위한 콜백 설정
    ChatConfig.onMessageSent = () {
      ChatSoundService.instance.playSendSound();
    };

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
    _debugTestRun();

    ///
    FirebaseAnalytics.instance.logAppOpen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 디버깅용 테스트 실행 함수 (Debug test run function)
  ///
  /// 앱 시작 시 특정 화면으로 이동하여 테스트합니다.
  /// Navigates to a specific screen for testing when app starts.
  // ignore: unused_element
  void _debugTestRun() {
    // Timer(Duration(seconds: 1), showUpgradeDialog);
    // Timer(Duration(seconds: 1), showShorebirdUpdateDialog);

    /// 디버깅용: 0.5초 후 메뉴 탭으로 이동 (확인 후 제거)
    /// For debugging: Navigate to menu tab after 0.5s (remove after verification)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _debugNavigateToMenu(context);

      /// 디버깅: ElNidoScreen 열기 (Debug: Open ElNidoScreen)
      /// 0.5초 후 엘니도 여행 정보 화면으로 이동합니다.
      /// Navigates to El Nido travel info screen after 0.5 seconds.
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   if (context.mounted) {
      //     debugPrint('[DEBUG] _debugTestRun: ElNidoScreen으로 이동합니다.');
      //     ElNidoScreen.push(context);
      //   }
      // });

    });
  }

  /// 앱 시작 후 메뉴 탭으로 이동 (디버깅용 - 확인 후 제거)
  /// Navigate to menu tab after app start (for debugging - remove after verification)
  // ignore: unused_element
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
