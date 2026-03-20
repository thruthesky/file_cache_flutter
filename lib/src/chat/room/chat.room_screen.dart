import 'package:flutter/material.dart';

import 'package:philgo_api/philgo_api.dart';

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
    return Login(
      builder: (uid) {
        if (isSingleChatRoom(widget.id) || isFirebaseUid(widget.id)) {
          return SingleChatRoom(
            id: widget.id,
            homeRouteName: widget.homeRouteName,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(PhilgoTr.of(context)!.invalid_chat_room_id),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Center(
                child: Text(PhilgoTr.of(context)!.invalid_chat_room_id_message),
              ),
              ElevatedButton(
                onPressed: () {
                  context.go(widget.homeRouteName);
                },
                child: Text(PhilgoTr.of(context)!.go_back_to_home),
              ),
            ],
          ),
        );
      },

      // Loading of the Login of the user
      loading: loading(),
      notLoggedIn: Scaffold(
        appBar: AppBar(title: Text(PhilgoTr.of(context)!.login_required)),
        body: Center(
          child: Text(PhilgoTr.of(context)!.please_log_in_to_continue),
        ),
      ),
    );
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
