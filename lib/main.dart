import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart' hide Config;
import 'package:image_picker/image_picker.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => ForumState()),
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

    // ChatService.instance.initialize();
    UserService.instance.initialize(useUserPresence: true);
    initMessagingService();
    if (Platform.isAndroid) {
      // Android-specific initialization
      initNotificationChannel();
    }

    // Navigator가 완전히 준비된 후 globalContext 설정
    // 첫 프레임이 렌더링된 후에 실행되도록 보장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalNavigatorKey.currentContext != null) {
        Config.setGlobalContext(globalNavigatorKey.currentContext!);
      }
      ReceiveShareService.instance.initialize(
        categories: PhilGoAppConfig.getCategories(),
        onCategorySelect:
            (PostCategoryItem category, List<SharedMediaFile> data) async {
              log(
                "${category.toString()} || ${data.map((f) => f.toMap()).toString()}",
                name: 'onCategorySelect',
              );
              if (data.length == 1 && await isSharedMediaPlainText(data[0])) {
                if (globalContext.mounted) {
                  PostCreateScreen.push(globalContext);
                }
              } else {
                List<XFile> xFiles = [];
                for (SharedMediaFile file in data) {
                  xFiles.add(XFile(file.path));
                }

                if (globalContext.mounted) {
                  PostCreateScreen.push(globalContext);
                }
              }
            },
        onData: (data) async {
          log(data.map((f) => f.toMap()).toString(), name: 'onValue');
          // Handle the received files and text as needed
          if (data.isEmpty) return;
          showReceiveShareDialog(globalContext, data);
        },
      );

      // showReceiveShareDialog(globalContext, [
      //   // SharedMediaFile.fromMap({
      //   //   "path":
      //   //       "/data/user/0/com.withcenter.philgo/cache/Screenshot 2025-08-07 022558.png",
      //   //   "thumbnail": null,
      //   //   "duration": null,
      //   //   "type": "image",
      //   //   "mimeType": "image/png",
      //   //   "message": null,
      //   // }),
      //   // SharedMediaFile.fromMap({
      //   //   "path":
      //   //       "/data/user/0/com.withcenter.philgo/cache/to share text file.txt",
      //   //   "thumbnail": null,
      //   //   "duration": null,
      //   //   "type": "text",
      //   //   "mimeType": "text/plain",
      //   //   "message": null,
      //   // }),
      // ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initMessagingService() async {
    // Initialize messaging service
    await MessagingService.instance.initialize(
      domain: 'philgo_v6_app',
      onForegroundMessage: (message) {
        debugPrint('Foreground message received: ${message.messageId}');
        // You can show a notification or update UI here
        // MessagingService.instance.handleForegroundMessage(
        //   context: globalContext,
        //   message: message,
        //   onPressed: (msg) {
        //     debugPrint('Notification tapped: ${msg.toString()}');
        //     WidgetsBinding.instance.addPostFrameCallback((_) {
        //       onMessageOpen(message);
        //     });
        //   },
        // );
      },
      onMessageOpenedFromBackground: (message) {
        // Handle messages opened from background state
        debugPrint(
          'Message opened from background state: ${message.toString()}',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageOpen(message);
        });
      },
      onMessageOpenedFromTerminated: (message) {
        // Handle messages opened from terminated state
        debugPrint(
          'Message opened from terminated state: ${message.toString()}',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onMessageOpen(message);
        });
      },
      // onBackgroundMessage: firebaseMessagingBackgroundHandler,
    );
  }

  void onMessageOpen(RemoteMessage message) {
    debugPrint('Message opened from notification: ${message.messageId}');
    final data = message.data;
    final roomId = data['roomId'] as String?;

    if (roomId != null) {
      if (Globals.screenName == 'ChatRoomScreen') {
        if (Globals.screenId == roomId) {
          // Already in the chat room, no need to navigate
          debugPrint('Already in the chat room: $roomId');
          return;
        } else {
          Navigator.of(globalContext).pop();
        }
      }
      // Navigate to the chat room if roomId is present
      ChatRoomScreen.push(globalContext, roomId);
    } else {
      debugPrint('No roomId found in message data: ${data.toString()}');
    }
  }

  void initNotificationChannel() async {
    // Android-specific notification channel initialization
    const MethodChannel channel = MethodChannel(
      'com.withcenter.philgo/push_notification',
    );
    Map<String, String> channelMap1 = {
      "id": "main_notification",
      "name": "Main Notifications",
      "description": "Main notifications settings",
      "sound": "custom_sound",
    };
    // Map<String, String> channelMap2 = {
    //   "id": "DOG_NOTIFICATION",
    //   "name": "Dog Notifications",
    //   "description": "Dog notifications settings",
    //   "sound": "dogwav",
    // };

    try {
      await channel.invokeMethod('createNotificationChannel', channelMap1);
      log('Finished creating channel1', name: 'NotificationChannel Success');
      // await channel.invokeMethod('createNotificationChannel', channelMap2);
      // log('Finished creating channel2');
    } on PlatformException catch (e) {
      log(
        'Error while creating channel: ${e.message}',
        name: 'NotificationChannel registration Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 중앙 집중식 Theme 구성 (버튼 색상 등)
    final cs = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 46, 160, 225),
      brightness: Brightness.light,
    );
    final typography = Typography.material2021();
    final baseTextTheme = typography.black;

    return MaterialApp.router(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        textTheme: GoogleFonts.interTextTheme(baseTextTheme).copyWith(
          displayLarge: GoogleFonts.inter(
            fontSize: 52,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.inter(
            fontSize: 40,
            fontWeight: FontWeight.w600, // SemiBold
            letterSpacing: 0,
          ),
          displaySmall: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w500, // Medium
            letterSpacing: 0,
          ),
          // Headline styles
          headlineLarge: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700, // Bold
            letterSpacing: 0,
          ),
          headlineMedium: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w600, // SemiBold
            letterSpacing: 0,
          ),
          headlineSmall: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w500, // Medium
            letterSpacing: 0,
          ),
          // Title styles
          titleLarge: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600, // SemiBold
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500, // Medium
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500, // Medium
            letterSpacing: 0.1,
          ),
          // Body styles
          bodyLarge: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400, // Regular
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400, // Regular
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400, // Regular
            letterSpacing: 0.4,
          ),
          // Label styles
          labelLarge: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500, // Medium
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w400, // Regular
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w300, // Light
            letterSpacing: 0.5,
          ),
        ),
        // Flat Design - ElevatedButton Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style:
              ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600, // 더 굵은 폰트
                  fontSize: 16,
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith<Color?>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.pressed)) {
                    return Colors.black.withValues(alpha: 0.15);
                  }
                  if (states.contains(WidgetState.hovered)) {
                    return Colors.black.withValues(alpha: 0.08);
                  }
                  return null;
                }),
              ),
        ),
        // Flat Design - Card Theme
        cardTheme: const CardThemeData(
          elevation: 0, // Flat 디자인 - 그림자 제거
          shadowColor: Colors.transparent,
        ),
        // Flat Design - AppBar Theme
        appBarTheme: const AppBarTheme(
          elevation: 0, // Flat 디자인 - 그림자 제거
          scrolledUnderElevation: 0, // 스크롤 시에도 elevation 0
          shadowColor: Colors.transparent,
        ),
        // Spacing Tokens 등록 (8 배수 기반)
        extensions: const <ThemeExtension<dynamic>>[AppSpacing()],
      ),
      routerConfig: router,
      localizationsDelegates: [
        Lo.delegate,
        LibTr.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [...Lo.supportedLocales, ...LibTr.supportedLocales],
    );
  }
}

/// Top-level function for handling background messages
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Ensure Firebase is initialized for background messages
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   debugPrint('Handling background message: ${message.messageId}');
//   // Handle background message logic here if needed
// }
