import 'dart:async';

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

  /// 즐겨찾기 상태를 관리하는 ValueNotifier
  final _isFavoritedNotifier = ValueNotifier<bool>(false);
  StreamSubscription<DatabaseEvent>? _favoritesSubscription;

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

    final ref = FirebaseDatabase.instance.ref(
      'users/${myUid()}/pinnedChatRooms/$roomId',
    );

    if (isPinned) {
      // 고정 해제
      await ref.remove();
    } else {
      // 고정
      await ref.set(true);
    }
  }

  @override
  void initState() {
    super.initState();
    _listenToFavorites();
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    _isFavoritedNotifier.dispose();
    super.dispose();
  }

  /// Firebase에서 즐겨찾기 상태를 실시간으로 구독
  /// chat/favorites/{uid} 경로의 모든 폴더를 확인하여 현재 roomId가 존재하는지 체크
  void _listenToFavorites() {
    if (loginUid() == null) return;

    final database = FirebaseDatabase.instance;
    final favoritesRef = database.ref('chat/favorites/${loginUid()}');

    _favoritesSubscription = favoritesRef.onValue.listen((event) {
      bool isFavorited = false;

      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        // 모든 폴더를 순회하며 현재 roomId가 있는지 확인
        for (var roomsData in data.values) {
          if (roomsData is Map && roomsData.containsKey(roomId)) {
            isFavorited = true;
            break;
          }
        }
      }

      _isFavoritedNotifier.value = isFavorited;
    });
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
          blocked: true,
          subTitleWidget: Text(
            LibTr.of(context)!.blocked_message,
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => showDialog(
            context: context,
            builder: (context) => UnblockUserDialog(
              otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
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

  /// 채팅방 타일 - 메인 UI 컴포넌트
  Widget chatRoomTile({
    Widget? subTitleWidget,
    void Function()? onTap,
    bool blocked = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 고정된 방은 배경색 강조
    final backgroundColor = isPinned
        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
        : colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        // Flat design - no shadow, use color contrast
        border: isPinned
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onTap ?? () => widget.onTap(roomId),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Avatar with enhanced styling
                buildAvatar(),
                const SizedBox(width: 12),
                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTitle(),
                      const SizedBox(height: 4),
                      subTitleWidget ??
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subTitle.isNotEmpty)
                                Text(
                                  subTitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              if (lastMessageAt > 0) ...[
                                const SizedBox(height: 4),
                                Text(
                                  formatTimestamp(context, lastMessageAt),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                    ],
                  ),
                ),
                // Trailing section
                if (!blocked) ...[const SizedBox(width: 8), buildTrailing()],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 채팅방 제목 위젯
  Widget buildTitle() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // 고정 아이콘 - 고정된 방만 표시
        if (isPinned) ...[
          FaIcon(
            FontAwesomeIcons.lightThumbtack,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 채팅방 타일 우측 트레일링 위젯 (읽지 않은 메시지 배지 + 즐겨찾기 아이콘 + 고정 아이콘)
  Widget buildTrailing() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 즐겨찾기 아이콘 - 즐겨찾기에 추가된 경우에만 별 표시
            ValueListenableBuilder<bool>(
              valueListenable: _isFavoritedNotifier,
              builder: (context, isFavorited, _) {
                if (!isFavorited) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: FaIcon(
                    FontAwesomeIcons.solidStar,
                    color: colorScheme.tertiary,
                    size: 16,
                  ),
                );
              },
            ),
            // 고정 아이콘 버튼
            ValueListenableBuilder<Set<String>>(
              valueListenable: UserService.instance.pinnedChatRoomsStream,
              builder: (context, pinnedRooms, _) {
                final isPinnedNow = pinnedRooms.contains(roomId);
                return IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                  icon: FaIcon(
                    isPinnedNow
                        ? FontAwesomeIcons.solidThumbtack
                        : FontAwesomeIcons.lightThumbtack,
                    color: isPinnedNow
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                    size: 18,
                  ),
                  onPressed: () async {
                    await togglePinned();
                    setState(() {});
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              },
            ),
          ],
        ),
        // 읽지 않은 메시지 배지 - 하단에 배치
        if (unread > 0) ...[
          const SizedBox(height: 4),
          buildUnreadBadge(unread),
        ],
      ],
    );
  }

  /// 읽지 않은 메시지 배지
  Widget buildUnreadBadge(int unreadCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  /// 아바타 위젯 - 온라인 상태 표시 포함
  Widget buildAvatar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        // Flat design - subtle color contrast instead of shadow
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Avatar(photoUrl: photoUrl),

          // Online status indicator - don't show if user is blocked
          if (isSingle)
            Positioned(
              right: 0,
              bottom: 0,
              child: Blocked(
                otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
                yes: () => const SizedBox.shrink(),
                no: () => OnlineStatus(
                  uid: getOtherUserUidFromChatRoomId(roomId)!,
                  yes: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
