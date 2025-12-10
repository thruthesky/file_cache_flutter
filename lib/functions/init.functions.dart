import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:image_picker/image_picker.dart';

Future<void> initMessagingService() async {
  // Initialize messaging service
  await MessagingService.instance.initialize(
    domain: 'philgo_v6_app',
    onForegroundMessage: (message) {
      debugPrint('Foreground message received: ${message.messageId}');
    },
    onMessageOpenedFromBackground: (message) {
      // Handle messages opened from background state
      debugPrint('Message opened from background state: ${message.toString()}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageOpen(message);
      });
    },
    onMessageOpenedFromTerminated: (message) {
      // Handle messages opened from terminated state
      debugPrint('Message opened from terminated state: ${message.toString()}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMessageOpen(message);
      });
    },
    // onBackgroundMessage: firebaseMessagingBackgroundHandler,
  );
}

/// Handle message when app is opened from notification
void onMessageOpen(RemoteMessage message) {
  debugPrint('Message opened from notification: ${message.messageId}');
  final data = message.data;
  final roomId = data['roomId'] as String?;
  final type = data['type'] as String?;

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
  } else if (type != null && type == 'post') {
    final postId = int.tryParse(data['idx_post']);
    if (postId == null) return;
    PostViewScreen.push(globalContext, Post.fromJson({'idx': postId}));
  } else if (type != null && type == 'comment') {
    final postId = int.tryParse(data['idx_post']);
    if (postId == null) return;
    PostViewScreen.push(globalContext, Post.fromJson({'idx': postId}));
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
    // log('Finished creating channel1', name: 'NotificationChannel Success');
    // await channel.invokeMethod('createNotificationChannel', channelMap2);
    // log('Finished creating channel2');
  } on PlatformException catch (e) {
    // log(
    //   'Error while creating channel: ${e.message}',
    //   name: 'NotificationChannel registration Error',
    // );
  }
}

void initializeReceiveShareService() {
  /// 외부 공유 수신 서비스 초기화
  /// Initialize receive share service
  ReceiveShareService.instance.initialize(
    /// PhilgoCategory.majorCategories()를 사용하여 카테고리 목록 설정
    /// Set category list using PhilgoCategory.majorCategories()
    categories: PhilgoCategory.majorCategories(),
    onCategorySelect:
        (String postId, String? category, List<SharedMediaFile> data) async {
          // log(
          //   "postId: $postId, category: $category || ${data.map((f) => f.toMap()).toString()}",
          //   name: 'onCategorySelect',
          // );

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
      // log(data.map((f) => f.toMap()).toString(), name: 'onValue');
      // Handle the received files and text as needed
      if (data.isEmpty) return;

      // 사용자가 (구글) 검색을 통해서 클릭한 경우, URL 에 정보가 들어온다.
      // When the user clicked through (google) search, it will have a url share.
      if (data[0].type == SharedMediaType.url) {
        if (data[0].path.contains('philgo.com')) {
          final url = parsePhilgoUrl(data[0].path);
          if (url != null) {
            if (url.idx != null) {
              // 스마트폰(핸드폰)이 매우 느린 경우, 렉걸려서 PostViewScreen 이동이 안되는 경우가 있어, 1초 딜레이를 줌
              // In very slow smartphones, there are cases where moving to PostViewScreen does not work due to lag, so we give a 1 second delay
              Timer(Duration(milliseconds: 1000), () {
                if (globalContext.mounted) {
                  PostViewScreen.push(
                    globalContext,
                    Post.fromJson({'idx': url.idx}),
                  );
                }
              });
              return;
            } else {
              // 클릭(검색)된 경로가 필고 URL 인데, idx 정보가 없는 경우는 홈으로 이동
              // If the clicked (searched) path is a Philgo URL but has no idx info, go to home
              return;
            }
          }
        }
      }
      showReceiveShareDialog(globalContext, data);
    },
  );
}
