import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/chat/room/chat.room.message_bubble.dart';
import 'package:philgo/user/user.firebase_model.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/util/widgets/full_screen_image_viewer.dart';

class SingleChatRoomMessageListController {
  late final SingleChatRoomMessageListState state;
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

class SingleChatRoomMessageList extends StatefulWidget {
  //
  // ignore: prefer_const_constructors_in_immutables
  SingleChatRoomMessageList({
    super.key,
    required this.roomId,
    required this.controller,
  });

  final String roomId;
  late final SingleChatRoomMessageListController controller;

  @override
  State<SingleChatRoomMessageList> createState() =>
      SingleChatRoomMessageListState();
}

class SingleChatRoomMessageListState extends State<SingleChatRoomMessageList> {
  final ScrollController scrollController = ScrollController();

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

  /// Extract all image URLs from the current messages
  /// Returns a map with unique keys to preserve duplicate URLs
  /// Key format: 'messageId_imageIndex' to ensure uniqueness
  Map<String, String> _extractAllImageUrls(List<DataSnapshot> messageDocs) {
    final Map<String, String> allImageUrls = {};

    // Iterate through messages as they are (newest first from ListView)
    for (final messageDoc in messageDocs) {
      final message = ChatMessage.fromDataSnapshot(messageDoc);
      if (message.urls != null && message.urls!.isNotEmpty) {
        // Add all URLs from this message in reverse order
        // This preserves duplicates by using message ID and index
        for (int i = 0; i < message.urls!.length; i++) {
          // Access URLs in reverse order to maintain proper display order
          final url = message.urls![message.urls!.length - 1 - i];
          final key = '${message.id}_$i';
          allImageUrls[key] = url;
        }
      }
    }

    return allImageUrls;
  }

  @override
  Widget build(BuildContext context) {
    return FirebaseDatabaseQueryBuilder(
      key: ValueKey('messages_${widget.roomId}'), // Add key to prevent rebuilds
      query: FirebaseDatabase.instance
          .ref('chat/messages/${widget.roomId}')
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
                  "Send a message to start a conversation",
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
            // bool showSenderInfo = true;

            // if (!isSingleChat && index < snapshot.docs.length - 1) {
            //   final nextMessageDoc = snapshot.docs[index + 1];
            //   final nextMessage = ChatMessage.fromDataSnapshot(nextMessageDoc);
            //   showSenderInfo = nextMessage.senderUid != message.senderUid;
            // }
            return FutureBuilder<UserFirebaseModel?>(
              key: ValueKey(
                'user_${message.senderUid}',
              ), // Add key for consistent building
              future: getUser(message.senderUid),
              builder: (context, userSnapshot) {
                // Use cached data if available to avoid rebuilds
                final userData =
                    userSnapshot.data ??
                    UserFirebaseModel.fromJson({"uid": message.senderUid});

                return ChatRoomMessageBubble(
                  key: ValueKey(
                    'message_${message.id}',
                  ), // Add key for message bubble
                  message: message,
                  sender: userData,
                  isCurrentUser: isCurrentUser,
                  showSenderInfo:
                      false, // isSingleChat ? false : showSenderInfo,
                  roomBlocksAdvertisement: false, // room.blockAdvertisement,
                  roomId: widget.roomId,
                  isSingleChat: true,
                  onImageTap: (String url) async {
                    // Extract all image URLs from current messages as a map
                    final allImageUrlsMap = _extractAllImageUrls(snapshot.docs);

                    // Convert map values to list to preserve order including duplicates
                    final imageUrlsList = allImageUrlsMap.values.toList();

                    // Find the index of the tapped image in the list
                    final initialIndex = imageUrlsList.indexOf(url);

                    // Use await to prevent widget rebuild on navigation back
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          imageUrls: imageUrlsList,
                          initialIndex: initialIndex >= 0 ? initialIndex : 0,
                        ),
                        // Maintain the route state to avoid rebuilding previous screen
                        maintainState: true,
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
