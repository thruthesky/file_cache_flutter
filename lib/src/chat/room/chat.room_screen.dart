import 'package:flutter/material.dart';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

import 'package:go_router/go_router.dart';

class ChatRoomScreen extends StatefulWidget {
  static const String routeName = '/chat-room/:id';
  static Function(BuildContext ctx, String roomId) push = (ctx, roomId) =>
      ctx.push(routeName.replaceFirst(':id', roomId));
  static Function(BuildContext ctx, String roomId) go = (ctx, roomId) =>
      ctx.go(routeName.replaceFirst(':id', roomId));

  final String id; // This can be roomId or uid for single chat

  const ChatRoomScreen({
    super.key,
    required this.id,
    required this.homeRouteName,
  });
  final String homeRouteName;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  ChatRoomMessageListController messageListController =
      ChatRoomMessageListController();
  @override
  Widget build(BuildContext context) {
    return
    //  Scaffold(
    //   body:
    Login(
      builder: (uid) {
        if (isSingleChatRoom(widget.id) || isFirebaseUid(widget.id)) {
          return SingleChatRoom(
            id: widget.id,
            homeRouteName: widget.homeRouteName,
          );
        }

        return ChatRoomInit(
          id: widget.id,
          loading: loading(),
          onRoomReady: (init) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: ChatRoomHeader(
                  room: init.room,
                  otherUser: init.otherUser,
                  roomId: init.room.id,
                  isSingleChat: init.isSingleChat,
                  onEditTap: () => showDialog<bool>(
                    context: context,
                    builder: (context) => ChatRoomEdit(room: init.room),
                  ),
                  onLeave: () {
                    leaveChatRoom(
                      roomId: init.room.id,
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
                    child: ChatRoomMessageList(
                      room: init.room,
                      controller: messageListController,
                    ),
                  ),
                  ChatRoomMessageInput(
                    roomId: init.room.id,
                    onSend: () {
                      messageListController.scrollToBottom();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },

      // Loading of the Login of the user
      loading: loading(),
      notLoggedIn: Scaffold(
        appBar: AppBar(title: Text(LibTr.of(context)!.login_required)),
        body: Center(child: Text(LibTr.of(context)!.please_log_in_to_continue)),
      ),
    );

    // );
  }

  Widget loading() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
