// ChatService
// This is a singleton service to manage chat functionalities.
// Contains API calls, business logic, and UI dialog operations.
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/chat/report/chat.report.dart';
import 'package:philgo/chat/widgets/search_friends_dialog.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/util/common.functions.dart';

class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();
  ChatService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  // ===================== API / Business Logic =====================

  /// Get Chat Join
  Future<ChatJoin?> getChatJoin(String roomId) async {
    DatabaseReference ref = myJoinRoomRef(roomId);
    final snapshot = await ref.get();
    if (snapshot.exists) {
      return ChatJoin.fromSnapshot(snapshot);
    }
    return null;
  }

  /// Resets the unread message counter for a user in a specific room to 0
  ///
  /// [roomId] - The chat room ID
  /// When user is inside the room and new messages arrive, this function
  /// should be called to reset the unread message counter.
  Future<void> resetUnreadMessageCounter(String roomId) async {
    if (loginUid() == null) return;

    final joinRef = myJoinRoomRef(roomId);

    await joinRef.update({UNREAD: 0, LAST_READ_AT: ServerValue.timestamp});
  }

  Future<void> resetChatJoin(String otherUserUid) async {
    final Dio dio = Dio();
    final response = await dio.post(
      chatCloudFunctionUrl('onResetChatJoin'),
      data: {'myUid': loginUid(), 'otherUid': otherUserUid},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200) {
      log(
        'Success to resetChatJoin',
        name: "resetUnreadMessageCounter::${response.statusCode}",
      );
    } else {
      log(
        'faild to resetChatJoin',
        name: "resetUnreadMessageCounter::${response.statusCode}",
      );
    }
  }

  /// Sends a message to a chat room
  ///
  /// [roomId] - The chat room ID
  /// [text] - Message content (max 2048 chars)
  /// [urls] - Attachment file URL list (optional)
  /// [protocol] - Protocol message type (optional)
  ///
  /// Returns the message ID after successful send.
  Future<String> sendMessage({
    required String roomId,
    required String text,
    List<String>? urls,
    String? protocol,
  }) async {
    final messageRef = FirebaseDatabase.instance
        .ref('chat/messages/$roomId')
        .push();

    final messageData = {
      'text': cut(text, 2048, defaultValue: ""),
      'senderUid': myUid(),
      'sentAt': ServerValue.timestamp,
      'protocol': protocol,
    };

    if (urls != null && urls.isNotEmpty) {
      messageData['urls'] = urls;
    }

    await messageRef.set(messageData);

    ChatConfig.onMessageSent?.call();

    return messageRef.key!;
  }

  Future<String> sendChatProtocolMessage({
    required String roomId,
    required String protocol,
  }) async {
    DatabaseReference ref = chatMessageRef(roomId).push();
    await ref.set({
      SENDER_UID: myUid(),
      PROTOCOL: protocol,
      SENT_AT: ServerValue.timestamp,
    });
    return ref.key!;
  }

  Future<void> leaveChatRoom({
    required String roomId,
    Function()? success,
    Function(String error)? error,
  }) async {
    try {
      await sendChatProtocolMessage(
        roomId: roomId,
        protocol: ChatProtocol.left,
      );
      await myJoinRoomRef(roomId).set(null);
      success?.call();
    } catch (e) {
      error?.call(e.toString());
    }
  }

  Future<void> createReport({
    required String path,
    required String reason,
    String? reportee,
    required Function() success,
    required Function(String error) error,
  }) async {
    try {
      DataSnapshot snapshot = await myReportRef()
          .orderByChild('path')
          .equalTo(path)
          .get();

      if (snapshot.exists) {
        throw ('이미 신고하셨습니다.'.tr());
      }

      final data = {
        REPORT_PATH: path,
        REPORT_REPORTER: myUid(),
        REPORT_REPORTEE: reportee,
        REPORT_REASON: reason,
        REPORT_CREATED_AT: ServerValue.timestamp,
      };

      DatabaseReference ref = myReportRef().push();
      await ref.set(data);

      await reportsListRef().child(ref.key!).set(data);

      success();
    } catch (e) {
      error(e.toString());
    }
  }

  Future<void> updateJoinRoomNickname(ChatJoin join, String nickname) async {
    if (nickname.isEmpty) return;
    if (nickname == join.customName) return;
    await FirebaseDatabase.instance.ref().update({
      'chat/joins/${myUid()}/${join.id}/userDisplayName': nickname,
    });
  }

  Future<void> updateJoinRoomPhotoUrl(ChatJoin join, String? imageUrl) async {
    if (imageUrl == null) return;
    if (imageUrl.isEmpty) return;
    if (imageUrl == join.userPhotoUrl) return;
    await FirebaseDatabase.instance.ref().update({
      'chat/joins/${myUid()}/${join.id}/userPhotoUrl': imageUrl,
    });
  }

  // ===================== UI Dialogs =====================

  /// Show block dialog
  void showBlockDialog({
    required BuildContext context,
    required String otherUserUid,
    String? displayName,
    bool popOnBlocked = true,
    VoidCallback? onBlocked,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => BlockUserDialog(
        otherUserUid: otherUserUid,
        displayName: displayName,
        onBlocked: () {
          if (popOnBlocked) {
            Navigator.of(context).pop();
          }
          onBlocked?.call();
        },
      ),
    );
  }

  /// Show unblock dialog
  void showUnblockDialog({
    required BuildContext context,
    required String otherUserUid,
    bool popOnUnblocked = false,
    VoidCallback? onUnblocked,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => UnblockUserDialog(
        otherUserUid: otherUserUid,
        onUnblocked: () {
          if (popOnUnblocked) {
            Navigator.of(context).pop();
          }
          onUnblocked?.call();
        },
      ),
    );
  }

  /// Show report dialog for a chat message
  void showChatMessageReportDialog({
    required BuildContext context,
    required ChatMessage message,
    required String? roomId,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportChatMessage(
        message: message,
        roomId: roomId!,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show user search dialog and return selected UID
  Future<String?> showUserSearchDialog(BuildContext context) async {
    final uid = await showDialog<String?>(
      context: context,
      builder: (context) => SearchFriendsDialog(),
    );
    return uid;
  }

  /// Show a "Block & Leave" confirmation dialog.
  /// Blocks [otherUserUid] first, then calls [onLeave].
  /// For single chat rooms only.
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  Future<void> showBlockAndLeaveConfirmDialog({
    required BuildContext context,
    required String otherUserUid,
    required VoidCallback onLeave,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightBan,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '차단 및 나가기'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  '이 사용자를 차단하고 채팅방을 나가시겠습니까?'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('취소'.tr()),
                    ),
                    const SizedBox(width: 8),
                    // Confirm Block & Leave
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: 2.0,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onError,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('차단 및 나가기'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await toggleBlockUser(otherUserUid);
      } catch (e) {
        debugPrint('Error blocking user before leave: $e');
      }
      if (context.mounted) {
        onLeave();
      }
    }
  }
}
