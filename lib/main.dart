import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/app/app.service.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat_sound.service.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/init/init.functions.dart';
import 'package:philgo/l10n/code_asset_loader.dart';
import 'package:philgo/router.dart';
import 'package:philgo/theme.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/util/run_zoned_guarded_error_handler.dart';
import 'package:philgo/setting/setting.state.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:omni_video_player/omni_video_player.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await EasyLocalization.ensureInitialized();

      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 카카오 SDK 초기화
      KakaoSdk.init(nativeAppKey: Config.kakaoNativeAppKey);

      OmniVideoPlayer.ensureInitialized();

      // Pass all uncaught "fatal" errors from the framework to Crashlytics
      FlutterError.onError = (details) {
        debugPrint('🔴 FlutterError: ${details.exception}');
        debugPrint('🔴 스택: ${details.stack}');
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('🔴 PlatformDispatcher 에러: $error');
        debugPrint('🔴 스택 트레이스: $stack');
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('ko'), Locale('en')],
          path: 'unused',
          assetLoader: const CodeAssetLoader(),
          fallbackLocale: const Locale('ko'),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => UserState()),
              ChangeNotifierProvider(create: (_) => AppNavigationState()),
              ChangeNotifierProvider(create: (_) => SettingsState()),
            ],
            child: const PhilGoV7App(),
          ),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        fatal: true,
        printDetails: false,
      );
      runZoneGuardedErrorHandler(error, stack);
    },
  );
}

class PhilGoV7App extends StatefulWidget {
  const PhilGoV7App({super.key});

  @override
  State<PhilGoV7App> createState() => _MyAppState();
}

class _MyAppState extends State<PhilGoV7App> {
  @override
  void initState() {
    super.initState();
    // FirebaseAuth 상태 변화 구독 시작 (로그인/로그아웃 자동 감지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppService.instance.initialize(context: globalContext);
      UserService.instance.initialize(globalContext);
      ChatService.instance.initialize(
        onNewMessageArrived: () => {
          log(
            'New message arrived callback triggered',
            name: 'onNewMessageArrived::',
          ),
        },
        onMessageSent: () => {
          log('Message sent callback triggered', name: 'onMessageSent::'),
        },
      );
      ChatSoundService.instance.initialize();
      // Initialize messaging service
      initMessagingService();

      /// Initialize receive share service
      initializeReceiveShareService();
    });
    FirebaseAnalytics.instance.logAppOpen();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: philgoThemeData(context),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router,
    );
  }
}
