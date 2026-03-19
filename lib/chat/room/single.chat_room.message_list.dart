import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/chat/room/chat.room.message_bubble.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/common_widgets/full_screen_image_viewer.dart';

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

  /// Extract all media URLs (images + videos) from the current messages
  /// Returns a map with unique keys to preserve duplicate URLs
  /// Key format: 'messageId_imageIndex' to ensure uniqueness
  Map<String, String> _extractAllMediaUrls(List<DataSnapshot> messageDocs) {
    final Map<String, String> allMediaUrls = {};

    // Iterate through messages as they are (newest first from ListView)
    for (final messageDoc in messageDocs) {
      final message = ChatMessage.fromDataSnapshot(messageDoc);
      if (message.urls != null && message.urls!.isNotEmpty) {
        // Add only image/video URLs from this message in reverse order
        // This preserves duplicates by using message ID and index
        for (int i = 0; i < message.urls!.length; i++) {
          // Access URLs in reverse order to maintain proper display order
          final url = message.urls![message.urls!.length - 1 - i];
          final type = getMediaType(toAbsoluteUrl(url));
          if (type == MediaType.image || type == MediaType.video) {
            final key = '${message.id}_$i';
            allMediaUrls[key] = toAbsoluteUrl(url);
          }
        }
      }
    }

    return allMediaUrls;
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
                  size: msgListEmptyIconSize,
                  color: msgListEmptyIconColor,
                ),
                SizedBox(height: msgListEmptySpacing),
                Text(
                  '메시지를 보내 대화를 시작하세요'.tr(),
                  style: TextStyle(fontSize: msgListEmptyTextFontSize, color: msgListEmptyTextColor),
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

            return FutureBuilder<UserModel?>(
              key: ValueKey(
                'user_${message.senderUid}',
              ), // Add key for consistent building
              future: UserService.getByFirebaseUid(
                firebaseUid: message.senderUid,
              ),
              builder: (context, userSnapshot) {
                // Use cached data if available to avoid rebuilds
                final userData =
                    userSnapshot.data ??
                    UserModel.fromJson({"uid": message.senderUid});

                return ChatRoomMessageBubble(
                  key: ValueKey(
                    'message_${message.id}',
                  ), // Add key for message bubble
                  message: message,
                  sender: userData,
                  isCurrentUser: message.senderUid == myUid(),
                  showSenderInfo:
                      false, // isSingleChat ? false : showSenderInfo,
                  roomId: widget.roomId,
                  onImageTap: (String url) async {
                    // Extract all media URLs (images + videos) from current messages
                    final allMediaUrlsMap = _extractAllMediaUrls(snapshot.docs);

                    // Convert map values to list to preserve order including duplicates
                    final mediaUrlsList = allMediaUrlsMap.values.toList();

                    // Find the index of the tapped media in the list
                    final absoluteUrl = toAbsoluteUrl(url);
                    final initialIndex = mediaUrlsList.indexOf(absoluteUrl);

                    // Use await to prevent widget rebuild on navigation back
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageViewer(
                          mediaUrls: mediaUrlsList,
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
