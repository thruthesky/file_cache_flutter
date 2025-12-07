import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/firebase_options.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.theme.dart';
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
    initMessagingService();
    if (Platform.isAndroid) {
      // Android-specific initialization
      initNotificationChannel();
    }

    // Navigator가 완전히 준비된 후 globalContext 설정
    // 첫 프레임이 렌더링된 후에 실행되도록 보장
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (globalNavigatorKey.currentContext != null) {
        PhilgoConfig.setGlobalContext(globalNavigatorKey.currentContext!);
      }
      /// 외부 공유 수신 서비스 초기화
      /// Initialize receive share service
      ReceiveShareService.instance.initialize(
        /// PhilgoCategory.majorCategories()를 사용하여 카테고리 목록 설정
        /// Set category list using PhilgoCategory.majorCategories()
        categories: PhilgoCategory.majorCategories(),
        onCategorySelect:
            (String postId, String? category, List<SharedMediaFile> data) async {
              log(
                "postId: $postId, category: $category || ${data.map((f) => f.toMap()).toString()}",
                name: 'onCategorySelect',
              );

              /// postId와 category를 직접 전달하여 글쓰기 화면 표시
              /// Pass postId and category directly to post create screen
              if (data.length == 1 && await isSharedMediaPlainText(data[0])) {
                if (globalContext.mounted) {
                  PostCreateScreen.push(
                    globalContext,
                    postId: postId,
                    category: category,
                    content: data[0].path,
                  );
                }
              } else {
                List<XFile> xFiles = [];
                for (SharedMediaFile file in data) {
                  xFiles.add(XFile(file.path));
                }

                if (globalContext.mounted) {
                  PostCreateScreen.push(
                    globalContext,
                    postId: postId,
                    category: category,
                    xFiles: xFiles,
                  );
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
