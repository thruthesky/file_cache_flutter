import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/room/chat.room.message_input.dart';
import 'package:philgo/chat/room/single.chat_room.header.dart';
import 'package:philgo/chat/room/single.chat_room.init.dart';
import 'package:philgo/chat/room/single.chat_room.message_list.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/util/util.functions.dart';

/// Single Chat Room Screen
/// Displays a 1:1 chat room with another user following Comic design theme
class SingleChatRoom extends StatefulWidget {
  const SingleChatRoom({
    super.key,
    required this.id,
    required this.homeRouteName,
  });

  final String id;
  final String homeRouteName;

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
            strokeWidth: 3.0,
          ),
        ),
      ),
      onRoomReady: (init) {
        return Scaffold(
          // Comic design: Use theme background color
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: SingleChatRoomHeader(
              join: init.join,
              otherUser: init.otherUser!,
              onLeave: () {
                leaveChatRoom(
                  roomId: init.join.id,
                  success: () {
                    if (mounted) {
                      showSuccessSnackBar(
                        context,
                        "Left the room successfully",
                      );
                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  error: (e) {
                    debugPrint('Error leaving room: $e');
                    if (mounted) {
                      showErrorSnackBar(context, "Error leaving room");
                    }
                  },
                );
                init.newMessageSubscription?.cancel();
              },
              onBackPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  context.go(widget.homeRouteName);
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
                      width: 1,
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
                otherUserUid: init.otherUser!.uid,
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
