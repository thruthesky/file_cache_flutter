import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ChatRoomMessageListController {
  late final ChatRoomMessageListState state;
  void scrollToBottom() {
    if (state.scrollController.hasClients) {
      state.scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

class ChatRoomMessageList extends StatefulWidget {
  //
  // ignore: prefer_const_constructors_in_immutables
  ChatRoomMessageList({
    super.key,
    required this.room,
    required this.controller,
  });

  final ChatRoom room;
  late final ChatRoomMessageListController controller;

  @override
  State<ChatRoomMessageList> createState() => ChatRoomMessageListState();
}

class ChatRoomMessageListState extends State<ChatRoomMessageList> {
  final ScrollController scrollController = ScrollController();

  ChatRoom get room => widget.room;
  String get roomId => widget.room.id;
  bool get isSingleChat => isSingleChatRoom(roomId);

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      key: ValueKey('messages_$roomId'), // Add key to prevent rebuilds
      query: FirebaseDatabase.instance
          .ref('chat/messages/$roomId')
          .orderByChild('sentAt'),
      reverseQuery: true,
      pageSize: 10,
      builder: (context, snapshot, _) {
        if (snapshot.isFetching && snapshot.docs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  PhilgoTr.of(context)!.send_message_to_start_conversation,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Debug: Log the number of messages
        // debugPrint(
        //   'Messages loaded: ${snapshot.docs.length}, hasMore: ${snapshot.hasMore}',
        // );
        return ListView.builder(
          key: const ValueKey('messages_list'), // Add key to ListView
          controller: scrollController,
          reverse: true,
          itemCount: snapshot.docs.length + (snapshot.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom when fetching more
            if (index >= snapshot.docs.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            // Trigger loading more items when reaching near the end
            if (snapshot.hasMore && index + 1 == snapshot.docs.length) {
              // debugPrint('Fetching more items... index: $index');
              snapshot.fetchMore();
            }
            final messageDoc = snapshot.docs[index];

            final message = ChatMessage.fromDataSnapshot(messageDoc);

            final isCurrentUser = message.senderUid == myUid();

            // Determine if sender info should be shown
            bool showSenderInfo = true;
            if (!isSingleChat && index < snapshot.docs.length - 1) {
              final nextMessageDoc = snapshot.docs[index + 1];
              final nextMessage = ChatMessage.fromDataSnapshot(nextMessageDoc);
              showSenderInfo = nextMessage.senderUid != message.senderUid;
            }
            return FutureBuilder<User?>(
              key: ValueKey(
                'user_${message.senderUid}',
              ), // Add key for consistent building
              future: getUser(message.senderUid),
              builder: (context, userSnapshot) {
                // Use cached data if available to avoid rebuilds
                final userData =
                    userSnapshot.data ??
                    User.fromJson({"uid": message.senderUid});

                return ChatRoomMessageBubble(
                  key: ValueKey(
                    'message_${message.id}',
                  ), // Add key for message bubble
                  message: message,
                  sender: userData,
                  isCurrentUser: isCurrentUser,
                  showSenderInfo: isSingleChat ? false : showSenderInfo,
                  roomBlocksAdvertisement: room.blockAdvertisement,
                  roomId: roomId,
                  isSingleChat: isSingleChat,
                );
              },
            );
          },
        );
      },
    );
  }
}
