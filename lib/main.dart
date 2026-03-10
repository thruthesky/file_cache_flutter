import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/router.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => AppNavigationState()),
      ],
      child: const PhilGoV7App(),
    ),
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
      context.read<UserState>().listenAuthState();
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
      routerConfig: router,
    );
  }
}
