/// Flutter Driver 테스트용 엔트리포인트
/// Flutter Driver test entrypoint
///
/// 이 파일은 Flutter Driver를 사용한 UI 자동화 테스트를 위해 사용됩니다.
/// This file is used for UI automation testing using Flutter Driver.
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/functions/init.functions.dart';
import 'package:philgo/functions/init/build_number_check.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.theme.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';

void main() async {
  // Flutter Driver 확장 활성화
  // Enable Flutter Driver extension
  enableFlutterDriverExtension();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        initNotificationChannel();
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalNavigatorKey.currentContext != null) {
        PhilgoConfig.setGlobalContext(globalNavigatorKey.currentContext!);
      }

      initializeReceiveShareService();
      initShorebirdCodePush();
      initMinimalBuildNumberCheck();
    });
  }

  @override
  void dispose() {
    super.dispose();
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
