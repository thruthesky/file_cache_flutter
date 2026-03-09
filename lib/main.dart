import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    ChangeNotifierProvider(
      create: (_) => UserState(),
      child: const PhilGoV7Ap(),
    ),
  );
}

class PhilGoV7Ap extends StatefulWidget {
  const PhilGoV7Ap({super.key});

  @override
  State<PhilGoV7Ap> createState() => _MyAppState();
}

class _MyAppState extends State<PhilGoV7Ap> {
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
