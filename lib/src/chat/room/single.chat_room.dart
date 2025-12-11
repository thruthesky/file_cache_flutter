import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo_api/philgo_api.dart';

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
                    // Show success message with Comic design theme
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            PhilgoTr.of(context)!.leftroom_successfully,
                          ),
                          // Comic design: Use theme primary color for success
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          // Comic design: Rounded corners with borderRadius 12
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // Comic design: 2.0px border
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                          elevation: 0, // Comic design: No shadow
                        ),
                      );

                      if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                  error: (e) {
                    debugPrint('Error leaving room: $e');

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(PhilgoTr.of(context)!.error),
                          // Comic design: Use theme error color
                          backgroundColor: Theme.of(context).colorScheme.error,
                          // Comic design: Rounded corners with borderRadius 12
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // Comic design: 2.0px border
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                          elevation: 0, // Comic design: No shadow
                        ),
                      );
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
