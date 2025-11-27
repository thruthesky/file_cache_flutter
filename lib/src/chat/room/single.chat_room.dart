import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
        body: Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator.adaptive(),
        ),
      ),
      onRoomReady: (init) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: SingleChatRoomHeader(
              join: init.join,
              otherUser: init.otherUser!,
              onLeave: () {
                leaveChatRoom(
                  roomId: init.join.id,
                  success: () {
                    // Show success message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            LibTr.of(context)!.leftroom_successfully,
                          ),
                          backgroundColor: Colors.green,
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
                          content: Text(LibTr.of(context)!.error),
                          backgroundColor: Colors.red,
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
              Expanded(
                child: SingleChatRoomMessageList(
                  roomId: init.join.id,
                  controller: singleMessageListController,
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
