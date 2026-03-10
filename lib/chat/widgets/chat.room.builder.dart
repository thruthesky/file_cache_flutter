import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.room.dart';

class ChatRoomBuilder extends StatefulWidget {
  const ChatRoomBuilder({
    super.key,
    required this.roomId,
    required this.builder,
  });

  final String roomId;
  final Function(BuildContext context, ChatRoom? room) builder;

  @override
  State<ChatRoomBuilder> createState() => _ChatRoomBuilderState();
}

class _ChatRoomBuilderState extends State<ChatRoomBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: chatRoomRef(widget.roomId).onValue,
      builder: (context, event) {
        if (event.hasData) {
          final room = ChatRoom.fromSnapshot(event.data!.snapshot);
          return widget.builder(context, room);
        }
        return widget.builder(context, null);
      },
    );
  }
}
