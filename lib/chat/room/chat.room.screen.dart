import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/room/single.chat_room.dart';
import 'package:philgo/chat/room/single.chat_room.message_list.dart';
import 'package:philgo/user/widgets/login.dart';

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
  SingleChatRoomMessageListController messageListController =
      SingleChatRoomMessageListController();
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
          appBar: AppBar(title: Text('잘못된 채팅방 ID'.tr())),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Center(child: Text('잘못된 채팅방 ID'.tr())),
              ElevatedButton(
                onPressed: () {
                  context.go(widget.homeRouteName);
                },
                child: Text('홈으로 돌아가기'.tr()),
              ),
            ],
          ),
        );
      },

      // Loading of the Login of the user
      loading: loading(),
      notLoggedIn: Scaffold(
        appBar: AppBar(title: Text('로그인이 필요합니다'.tr())),
        body: Center(child: Text('로그인 후 이용해 주세요'.tr())),
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
