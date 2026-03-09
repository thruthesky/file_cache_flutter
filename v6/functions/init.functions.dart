import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/router.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

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
    log(
      'Error while creating channel: ${e.message}',
      name: 'NotificationChannel registration Error',
    );
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
                content: data[0].message,
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
        // ! Warning: philgo deeplink handling is disabled since it is handled by Go_Router's redirect.
        if (data[0].path.contains('philgo.com')) {
          return;
          // final url = parsePhilgoUrl(data[0].path);
          // if (url != null) {
          // if (url.idx != null) {
          //   // 스마트폰(핸드폰)이 매우 느린 경우, 렉걸려서 PostViewScreen 이동이 안되는 경우가 있어, 1초 딜레이를 줌
          //   // In very slow smartphones, there are cases where moving to PostViewScreen does not work due to lag, so we give a 1 second delay
          //   Timer(Duration(milliseconds: 1000), () {
          //     if (globalContext.mounted) {
          //       PostViewScreen.push(
          //         globalContext,
          //         Post.fromJson({'idx': url.idx}),
          //       );
          //     }
          //   });
          //   return;
          // } else {
          //   // 클릭(검색)된 경로가 필고 URL 인데, idx 정보가 없는 경우는 홈으로 이동
          //   // If the clicked (searched) path is a Philgo URL but has no idx info, go to home
          //   return;
          // }
          // }
        }
      }
      showReceiveShareDialog(globalContext, data);
    },
  );
}

/// Shorebird 업데이트 확인 타이머 (Shorebird Update Check Timer)
///
/// 주기적으로 업데이트를 확인하기 위한 타이머
/// Timer for periodic update checking
Timer? _shorebirdTimer;

/// Shorebird 코드 푸시 초기화 및 주기적 업데이트 확인
/// Initialize Shorebird Code Push and check for updates periodically
///
/// ## 업데이트 확인 타이밍 (Update Check Timing)
/// - 최초 실행: 30초 후 1회 확인
/// - 이후: 180초(3분)마다 주기적 확인
///
/// ## 동작 흐름 (Flow)
/// 1. 앱 시작 → 30초 후 첫 번째 업데이트 확인
/// 2. 업데이트 있음 → 다운로드 → 다이얼로그 표시 → 타이머 종료
/// 3. 업데이트 없음 → 180초 주기 타이머 시작
///
/// 중요: kReleaseMode에서만 동작합니다 (디버그 모드에서는 에러 발생)
/// Important: Only works in kReleaseMode (errors occur in debug mode)
void initShorebirdCodePush() async {
  /// 릴리즈 모드에서만 동작 (디버그 모드에서 Shorebird 에러 발생 방지)
  /// Only works in release mode (prevents Shorebird errors in debug mode)
  if (!kReleaseMode) {
    return;
  }

  try {
    /// ShorebirdUpdater 인스턴스 생성 (Recommended API)
    /// Create ShorebirdUpdater instance (Recommended API)
    final updater = ShorebirdUpdater();

    /// [1단계] 최초 30초 후 첫 번째 업데이트 확인
    /// [Step 1] First update check after 30 seconds
    _shorebirdTimer = Timer(const Duration(seconds: 30), () async {
      final hasUpdate = await _checkAndDownloadUpdate(updater);

      /// [2단계] 업데이트가 없으면 180초 주기 타이머 시작
      /// [Step 2] If no update, start periodic timer (180 seconds)
      if (!hasUpdate) {
        _startPeriodicUpdateCheck(updater);
      }
    });
  } catch (e) {
    // Shorebird 초기화 오류 무시
  }
}

/// 180초 주기 업데이트 확인 타이머 시작
/// Start periodic update check timer (180 seconds)
void _startPeriodicUpdateCheck(ShorebirdUpdater updater) {
  _shorebirdTimer = Timer.periodic(const Duration(seconds: 180), (_) async {
    final hasUpdate = await _checkAndDownloadUpdate(updater);

    /// 업데이트 다운로드 완료 시 타이머 중지
    /// Stop timer when update download is complete
    if (hasUpdate) {
      _shorebirdTimer?.cancel();
    }
  });
}

/// 업데이트 확인 및 다운로드 실행
/// Check for update and download if available
///
/// 반환값: 업데이트가 있어서 다운로드했으면 true, 없으면 false
/// Returns: true if update was downloaded, false otherwise
Future<bool> _checkAndDownloadUpdate(ShorebirdUpdater updater) async {
  try {
    /// 새 패치 버전이 다운로드 가능한지 확인
    /// Check if a new patch version is available for download
    final status = await updater.checkForUpdate();

    if (status == UpdateStatus.outdated) {

      /// 업데이트 다운로드
      /// Download update
      await updater.update();

      /// 다이얼로그 표시 (globalContext가 유효한 경우)
      /// Show dialog (if globalContext is valid)
      if (globalContext.mounted) {
        showShorebirdUpdateDialog();
      }

      return true;
    }

    return false;
  } catch (e) {
    // Shorebird 업데이트 확인 오류 무시
    return false;
  }
}
