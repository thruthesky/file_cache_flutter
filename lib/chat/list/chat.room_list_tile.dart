import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/models/chat.room.dart';
import 'package:philgo/chat/report/chat.report.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/user/widgets/online.status.dart';
import 'package:philgo/util/util.functions.dart';

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
            "Message from blocked user",
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
            } else if (value == 'leave') {
              _showLeaveConfirmDialog();
            } else if (value == 'block_and_leave') {
              _showBlockAndLeaveConfirmDialog();
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
            Text(isPinned ? "Unpin" : "Pin", style: theme.textTheme.bodyMedium),
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
              Text("Report", style: theme.textTheme.bodyMedium),
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
                  "Unblock User",
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
                Text("Block User", style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        );
      }
    }

    // Leave room option - available for all room types
    menuItems.add(
      PopupMenuItem<String>(
        value: 'leave',
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.lightArrowRightFromBracket,
              size: 16,
              color: colorScheme.error,
            ),
            const SizedBox(width: 12),
            Text(
              "Leave Room",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );

    // Block & Leave option - only for single chat rooms
    if (isSingle) {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'block_and_leave',
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightBan,
                size: 16,
                color: colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                "Block & Leave",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      );
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

  /// Show block user dialog with the other user's display name
  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => BlockUserDialog(
        otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
        displayName: name,
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

  /// Show leave room confirmation dialog.
  /// For single chat rooms, also offers "Block & Leave" option.
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  void _showLeaveConfirmDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Returns null (dismissed), 'leave', or 'block_and_leave' (single only)
    final String? action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: colorScheme.outline, width: 2.0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Text(
                  "Leave Room",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  "Are you sure you want to leave this room?",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Block & Leave - only for single chat rooms
                    if (isSingle) ...[
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop('block_and_leave'),
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(0),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: colorScheme.error,
                                width: 2.0,
                              ),
                            ),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            colorScheme.error,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            colorScheme.onError,
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textStyle: WidgetStateProperty.all(
                            theme.textTheme.bodyMedium,
                          ),
                        ),
                        child: Text("Block & Leave"),
                      ),
                      const SizedBox(height: 8),
                    ],
                    // Leave only - outlined error button
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop('leave'),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: 2.0,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text("Leave"),
                    ),
                    const SizedBox(height: 8),
                    // Cancel - neutral button
                    ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(0),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (action == 'block_and_leave' && isSingle) {
      // Block the other user first, then leave the room
      try {
        await toggleBlockUser(getOtherUserUidFromChatRoomId(roomId)!);
      } catch (e) {
        debugPrint('Error blocking user before leave: $e');
      }
      if (!mounted) return;
      leaveChatRoom(
        roomId: roomId,
        success: () {
          if (mounted) {
            showSuccessSnackBar(context, "Left the room successfully");
          }
        },
        error: (e) => debugPrint('Error leaving room: $e'),
      );
    } else if (action == 'leave') {
      leaveChatRoom(
        roomId: roomId,
        success: () {
          if (mounted) {
            showSuccessSnackBar(context, "Left the room successfully");
          }
        },
        error: (e) => debugPrint('Error leaving room: $e'),
      );
    }
  }

  /// Show Block & Leave confirmation dialog for single chat rooms.
  /// Blocks the other user first, then leaves the room.
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  /// Delegates to ChatService to show "Block & Leave" confirmation dialog.
  void _showBlockAndLeaveConfirmDialog() {
    final otherUserUid = getOtherUserUidFromChatRoomId(roomId)!;
    ChatService.instance.showBlockAndLeaveConfirmDialog(
      context: context,
      otherUserUid: otherUserUid,
      onLeave: () => leaveChatRoom(
        roomId: roomId,
        success: () {
          if (mounted) {
            showSuccessSnackBar(context, "Left the room successfully");
          }
        },
        error: (e) => debugPrint('Error leaving room: $e'),
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
