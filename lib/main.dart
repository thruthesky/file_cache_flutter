import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/functions/init.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.theme.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppState.of(context).initializeLocaleFromDevice();
    });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalNavigatorKey.currentContext != null) {
        PhilgoConfig.setGlobalContext(globalNavigatorKey.currentContext!);
      }

      initializeReceiveShareService();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, Locale?>(
      selector: (context, appState) => appState.locale,
      builder: (context, locale, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: router,
          locale: locale, // AppState의 locale 사용
          localizationsDelegates: [
            Lo.delegate,
            PhilgoTr.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            ...Lo.supportedLocales,
            ...PhilgoTr.supportedLocales,
          ],
        );
      },
    );
  }
}
