import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

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
    // debugPrint(j);
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
            PhilgoTr.of(context)!.blocked_message,
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

    return Stack(
      children: [
        // Main content
        Container(
          margin: const EdgeInsets.only(top: 16.0, left: 8, right: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            // Comic design - rounded corners 12 for large elements
            borderRadius: BorderRadius.circular(12.0),
            // Comic design - 2.0px outline border
            border: Border.all(
              color: isPinned
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: 2.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.0),
              onTap: onTap ?? () => widget.onTap(roomId),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Left Column: Avatar + Content
                    Expanded(
                      child: Row(
                        children: [
                          // Avatar
                          buildAvatar(),
                          const SizedBox(width: 12),
                          // Content: Title and Subtitle with date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                Text(
                                  name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 4),
                                // Subtitle with date separator - flexible layout
                                subTitleWidget ??
                                    (subTitle.isNotEmpty || lastMessageAt > 0
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 4,
                                            children: [
                                              if (subTitle.isNotEmpty)
                                                Flexible(
                                                  child: Text(
                                                    subTitle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                        ),
                                                  ),
                                                ),
                                              // Date with bullet separator
                                              if (lastMessageAt > 0) ...[
                                                if (subTitle.isNotEmpty)
                                                  Text(
                                                    '•',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.4,
                                                              ),
                                                        ),
                                                  ),
                                                Text(
                                                  formatTimestamp(
                                                    context,
                                                    lastMessageAt,
                                                  ),
                                                  style: theme
                                                      .textTheme
                                                      .labelSmall
                                                      ?.copyWith(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ],
                                          )
                                        : const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right Column: Unread badge only
                    if (!blocked) ...[
                      const SizedBox(width: 12),
                      buildTrailing(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        // Pinned icon - positioned at upper right with tilt
        if (!blocked) buildPinnedIcon(),
      ],
    );
  }

  /// 고정된 채팅방 표시 - 우측 상단에 핀 아이콘을 기울여서 배치
  Widget buildPinnedIcon() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ValueListenableBuilder<Set<String>>(
      valueListenable: UserService.instance.pinnedChatRoomsStream,
      builder: (context, pinnedRooms, _) {
        final isPinnedNow = pinnedRooms.contains(roomId);
        if (!isPinnedNow) return const SizedBox.shrink();

        return Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () async {
              await togglePinned();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // Round container background for visibility
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
                // Comic design - 2.0px border
                border: Border.all(color: colorScheme.primary, width: 2.0),
              ),
              child: Transform.rotate(
                angle: 0.4, // Tilt angle in radians (~23 degrees)
                child: FaIcon(
                  FontAwesomeIcons.solidThumbtack,
                  color: colorScheme.primary,
                  size: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 채팅방 타일 우측 트레일링 위젯 - Unread badge and menu button
  Widget buildTrailing() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Unread badge
        if (unread > 0) ...[buildUnreadBadge(unread)],
        // Vertical 3-dot menu button
        PopupMenuButton<String>(
          icon: FaIcon(
            FontAwesomeIcons.lightEllipsisVertical,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          padding: EdgeInsets.zero,
          onSelected: (value) async {
            if (value == 'pin') {
              await togglePinned();
              setState(() {});
            } else if (value == 'report') {
              _showReportDialog();
            } else if (value == 'block') {
              _showBlockDialog();
            } else if (value == 'unblock') {
              _showUnblockDialog();
            }
          },
          itemBuilder: (context) =>
              _buildMenuItems(context, theme, colorScheme),
        ),
      ],
    );
  }

  /// Build menu items for popup menu
  List<PopupMenuEntry<String>> _buildMenuItems(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final menuItems = <PopupMenuEntry<String>>[
      // Pin/Unpin option
      PopupMenuItem<String>(
        value: 'pin',
        child: Row(
          children: [
            FaIcon(
              isPinned
                  ? FontAwesomeIcons.lightThumbtack
                  : FontAwesomeIcons.solidThumbtack,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              isPinned
                  ? PhilgoTr.of(context)!.unpin
                  : PhilgoTr.of(context)!.pin,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    ];

    // Add Report and Block options only for single chat rooms
    if (isSingle) {
      final otherUserUid = getOtherUserUidFromChatRoomId(roomId)!;

      menuItems.add(
        PopupMenuItem<String>(
          value: 'report',
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightFlag,
                size: 16,
                color: colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                PhilgoTr.of(context)!.report,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );

      // Use Blocked widget to determine block/unblock menu item
      // Check if user is blocked using UserService
      final isBlocked = UserService.instance.blockedUsers.contains(
        otherUserUid,
      );

      if (isBlocked) {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'unblock',
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightUserPlus,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                Text(
                  PhilgoTr.of(context)!.unblock_user,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        menuItems.add(
          PopupMenuItem<String>(
            value: 'block',
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightBan,
                  size: 16,
                  color: colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  PhilgoTr.of(context)!.block_user,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }
    }

    return menuItems;
  }

  /// Show report dialog
  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => ReportChatRoom(
        roomId: roomId,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show block user dialog
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
        onBlocked: () {
          // Optionally show success message
        },
      ),
    );
  }

  /// Show unblock user dialog
  void _showUnblockDialog() {
    showDialog(
      context: context,
      builder: (context) => UnblockUserDialog(
        otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
        onUnblocked: () {
          // Optionally show success message
        },
      ),
    );
  }

  /// 읽지 않은 메시지 배지 - Comic design
  Widget buildUnreadBadge(int unreadCount) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.error,
        // Comic design - rounded corners 32 for small elements
        borderRadius: BorderRadius.circular(50),
        // Comic design - 2.0px border
        border: Border.all(color: colorScheme.error, width: 2.0),
      ),
      child: Text(
        unreadCount > 99 ? '99+' : unreadCount.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onError,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  /// 아바타 위젯 - 온라인 상태 표시 포함 - Comic design
  Widget buildAvatar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        // Comic design - 2.0px outline border
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 2.0,
        ),
      ),
      child: Stack(
        children: [
          Avatar(photoUrl: photoUrl),

          // Favorite icon - positioned at left bottom (left of online indicator)
          ValueListenableBuilder<bool>(
            valueListenable: _isFavoritedNotifier,
            builder: (context, isFavorited, _) {
              if (!isFavorited) return const SizedBox.shrink();
              return Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    // Comic design - 2.0px border
                    border: Border.all(color: Colors.amber, width: 2.0),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.solidStar,
                      color: Colors.amber,
                      size: 8,
                    ),
                  ),
                ),
              );
            },
          ),

          // Online status indicator - only show when user is online and not blocked
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
                      color: Colors.green,
                      // Comic design - 2.0px border
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  // Only show when online - no indicator when offline
                  no: const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
