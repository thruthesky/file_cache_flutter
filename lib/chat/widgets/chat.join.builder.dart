import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/models/chat.join.dart';

class ChatJoinBuilder extends StatefulWidget {
  const ChatJoinBuilder({
    super.key,
    required this.roomId,
    required this.builder,
  });

  final String roomId;
  final Function(BuildContext context, ChatJoin? join) builder;

  @override
  State<ChatJoinBuilder> createState() => _ChatJoinBuilderState();
}

class _ChatJoinBuilderState extends State<ChatJoinBuilder> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: myJoinRoomRef(widget.roomId).onValue,
      builder: (context, event) {
        if (event.hasData && event.data!.snapshot.exists) {
          final join = ChatJoin.fromSnapshot(event.data!.snapshot);
          return widget.builder(context, join);
        }
        return widget.builder(context, null);
      },
    );
  }
}
