import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.screen.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/room/chat.room.message_input.dart';
import 'package:philgo/chat/room/single.chat_room.header.dart';
import 'package:philgo/chat/room/single.chat_room.init.dart';
import 'package:philgo/chat/room/single.chat_room.message_list.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/util/util.functions.dart';

/// Single Chat Room Screen
/// Displays a 1:1 chat room with another user following Comic design theme
class SingleChatRoom extends StatefulWidget {
  const SingleChatRoom({super.key, required this.id});

  final String id;

  @override
  State<SingleChatRoom> createState() => _SingleChatRoomState();
}

class _SingleChatRoomState extends State<SingleChatRoom> {
  SingleChatRoomMessageListController singleMessageListController =
      SingleChatRoomMessageListController();
  @override
  Widget build(BuildContext context) {
    return SingleChatRoomInit(
      id: widget.id,
      loading: Scaffold(
        // Comic design: Clean loading screen with theme-based colors
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Container(
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            // Use theme primary color for loading indicator
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: msgListLoadingStrokeWidth,
          ),
        ),
      ),
      onRoomReady: (init) {
        return Scaffold(
          // Comic design: Use theme background color
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 8),
            child: SingleChatRoomHeader(
              join: init.join,
              otherUser: init.otherUserProfile!,
              onLeave: () {
                ChatService.instance.leaveChatRoom(
                  roomId: init.join.id,
                  success: () {
                    if (mounted) {
                      showSuccessSnackBar(context, '방을 나갔습니다'.tr());
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  error: (e) {
                    debugPrint('Error leaving room: $e');
                    if (mounted) {
                      showErrorSnackBar(context, '방 나가기 오류'.tr());
                    }
                  },
                );
                init.newMessageSubscription?.cancel();
              },
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  context.go(AppScreen.routeName);
                }
              },
            ),
          ),
          body: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  /// Flat design - subtle border instead of shadow
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: msgListTopBorderWidth,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  // Dismiss keyboard when tapping on message list area
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  // Allow scrolling and other interactions
                  behavior: HitTestBehavior.translucent,
                  child: SingleChatRoomMessageList(
                    roomId: init.join.id,
                    controller: singleMessageListController,
                  ),
                ),
              ),
              Blocked(
                otherUserUid: init.otherUserProfile!.firebaseUid,
                no: () => ChatRoomMessageInput(
                  roomId: init.join.id,
                  onSend: () {
                    singleMessageListController.scrollToBottom();
                  },
                ),
                yes: () => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
