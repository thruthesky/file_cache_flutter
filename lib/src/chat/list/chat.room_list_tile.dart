import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    if (join != null) {
      if (join!.customName.isNotEmpty) {
        return join!.customName;
      }

      if (isSingle) {
        return join!.userDisplayName.isNotEmpty
            ? join!.userDisplayName
            : 'no name';
      } else {
        return join!.roomName.isNotEmpty ? join!.roomName : 'No name';
      }
    }

    if (room != null) {
      return room!.name.isNotEmpty ? room!.name : 'No room name';
    }
    return 'no room name';
  }

  // photo URL for the room or user
  String? get photoUrl {
    if (isSingle && join != null) {
      return join!.userPhotoUrl.isNotEmpty ? join!.userPhotoUrl : null;
    }
    return null;
  }

  int get unread {
    String j = join.toString();
    debugPrint(j);
    if (join != null) return join!.unread;
    return 0;
  }

  String get subTitle {
    if (join?.lastMessage.text != null) return join!.lastMessage.text;
    if (room != null) return room!.description;
    return '';
  }

  int get lastMessageAt {
    if (join?.lastMessage.sentAt != null) {
      return join!.lastMessage.sentAt;
    }
    return 0;
  }

  /// 채팅방 고정 여부 확인
  bool get isPinned {
    return UserService.instance.pinnedChatRooms.contains(roomId);
  }

  /// 채팅방 고정/고정 해제 토글
  Future<void> togglePinned() async {
    if (loginUid() == null) return;

    final ref = FirebaseDatabase.instance.ref('users/${myUid()}/pinnedChatRooms/$roomId');

    if (isPinned) {
      // 고정 해제
      await ref.remove();
    } else {
      // 고정
      await ref.set(true);
    }
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
        trailing: buildTrailing(showBadge),
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

  /// 채팅방 타일 우측 트레일링 위젯 (읽지 않은 메시지 배지 + 고정 아이콘)
  Widget buildTrailing(bool showBadge) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 읽지 않은 메시지 배지
        if (showBadge && unread > 0) ...[
          buildUnreadBadge(unread),
          const SizedBox(width: 8),
        ],
        // 고정 아이콘 버튼
        ValueListenableBuilder<Set<String>>(
          valueListenable: UserService.instance.pinnedChatRoomsStream,
          builder: (context, pinnedRooms, _) {
            final isPinnedNow = pinnedRooms.contains(roomId);
            return IconButton(
              icon: FaIcon(
                FontAwesomeIcons.thumbtack,
                // 고정된 경우 노란색, 아닌 경우 회색
                color: isPinnedNow
                    ? Colors.yellow[700]
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 18,
              ),
              onPressed: togglePinned,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            );
          },
        ),
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
