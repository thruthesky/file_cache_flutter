import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ChatRoomListTile extends StatefulWidget {
  const ChatRoomListTile({
    super.key,

    this.join,
    this.room,

    required this.onTap,
  });

  final ChatJoin? join;
  final ChatRoom? room;
  final void Function(String roomId) onTap;

  @override
  State<ChatRoomListTile> createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  ChatJoin? get join => widget.join;
  ChatRoom? get room => widget.room;
  String get roomId => join?.id ?? room!.id;
  bool get isSingle => isSingleChatRoom(roomId);

  // room name or user name
  String get name {
    if (room != null && room!.name.isNotEmpty) {
      return room!.name;
    } else if (join != null &&
        (join!.nickname.isNotEmpty || join!.name.isNotEmpty)) {
      return join!.nickname.isNotEmpty ? join!.nickname : join!.name;
    } else {
      return 'no-name';
    }
  }

  // photo URL for the room or user
  String? get photoUrl {
    if (join != null) {
      return join!.photoUrl.isNotEmpty
          ? join!.photoUrl
          : join!.imageUrl.isNotEmpty
          ? join!.imageUrl
          : null;
    }

    if (room != null && room?.imageUrl?.isNotEmpty == true) {
      return room!.imageUrl;
    }

    return null;
  }

  int get unreadCount {
    if (join != null) return join!.unreadMessageCount;
    return 0;
  }

  String get subTitle {
    if (join != null) return join!.lastText;
    if (room != null) return room!.description;
    return '';
  }

  int get lastMessageAt {
    if (join != null) return join!.lastMessageAt;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (!isSingle) {
      return chatRoomTile();
    }

    return Blocked(
      key: Key(roomId),
      otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
      yes: () {
        return chatRoomTile(
          subTitleWidget: Text(
            LibTr.of(context)!.blocked_message,
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          showBadge: false,
          onTap: () => showDialog(
            context: context,
            builder: (context) => UnblockUserDialog(
              user: User.fromJson({
                'uid': getOtherUserUidFromChatRoomId(roomId)!,
              }),
              onUnblocked: () {
                // Show success message
              },
            ),
          ),
        );
      },
      no: () => chatRoomTile(),
    );
  }

  Widget chatRoomTile({
    Widget? subTitleWidget,
    void Function()? onTap,
    bool showBadge = true,
  }) {
    return Card(
      // margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: buildAvatar(),
        title: buildTitle(),
        subtitle:
            subTitleWidget ??
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subTitle.isNotEmpty) Text(subTitle, maxLines: 1),
                // if (kDebugMode) Text(roomId, style: TextStyle(fontSize: 8)),
                if (lastMessageAt > 0)
                  Text(
                    formatTimestamp(context, lastMessageAt),
                    style: TextStyle(fontSize: 8),
                  ),
              ],
            ),
        trailing: showBadge && (unreadCount > 0)
            ? buildUnreadBadge(unreadCount)
            : null,
        onTap: onTap ?? () => widget.onTap(roomId),
      ),
    );
  }

  Widget buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Don't show online status if user is blocked
      ],
    );
  }

  Widget buildUnreadBadge(int unreadCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildAvatar() {
    return Stack(
      children: [
        Avatar(photoUrl: photoUrl),

        // Online status indicator - don't show if user is blocked
        if (isSingle)
          Positioned(
            right: 0,
            bottom: 0,
            child: Blocked(
              otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
              yes: () => SizedBox.shrink(),
              no: () => OnlineStatus(
                uid: getOtherUserUidFromChatRoomId(roomId)!,
                yes: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surface,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
