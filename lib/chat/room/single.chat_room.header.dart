import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/report/chat.report.dart';
import 'package:philgo/messaging/widget/push_notification_icon.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/bookmark/widgets/bookmark_group_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/user/widgets/online.status.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/user/widgets/block_user_dialog.dart';
import 'package:philgo/util/util.functions.dart';

/// Header widget for chat room screen showing room info and options
class SingleChatRoomHeader extends StatelessWidget {
  final ChatJoin join;
  final UserModel otherUser;
  final VoidCallback? onLeave;
  final VoidCallback? onBackPressed;

  const SingleChatRoomHeader({
    super.key,
    required this.join,
    required this.otherUser,
    this.onLeave,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: onBackPressed,
        icon: const Icon(Icons.arrow_back),
      ),
      title: buildRoomTitle(context),
      // Comic design: Transparent background, no shadow
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      actions: [
        _FavoriteIconButton(roomId: join.id),
        PushNotificationIcon(subscriptionId: join.id, reverse: true),

        // Gear Menu Button
        IconButton(
          onPressed: () => showMenuModal(context),
          icon: const Icon(Icons.settings),
          tooltip: '메뉴'.tr(),
        ),
      ],
    );
  }

  /// Show menu modal with various options
  void showMenuModal(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,

      /// Comic design: No elevation, transparent background
      elevation: dialogElevation,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        /// Comic design: 2px border, rounded corners, no shadow
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(dialogBorderRadius),
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: dialogBorderWidth,
          ),
        ),
        padding: dialogContentPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '메뉴'.tr(),

                    /// Comic design: Use theme text style
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기'.tr(),
                  ),
                ],
              ),
            ),

            /// Comic design: 2px divider
            Divider(
              color: Theme.of(context).colorScheme.outline,
              thickness: dialogDividerThickness,
              height: dialogDividerHeight,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show admin notice for admin chats, or regular options for other chats
                    if (isAdminChatRoom(
                      roomId: join.id,
                      otherUserUid: otherUser.firebaseUid,
                    )) ...[
                      /// Admin chat notice with Comic design
                      Container(
                        padding: dialogContentPadding,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          /// Comic design: Use theme primaryContainer for notice background
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            dialogBorderRadius,
                          ),

                          /// Comic design: 2.0px border with primary color
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: dialogBorderWidth,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            SizedBox(width: dialogAvatarSpacing),
                            Expanded(
                              child: Text(
                                '관리자 채팅 안내'.tr(),
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Blocked(
                        otherUserUid: otherUser.firebaseUid,
                        yes: () => _buildComicMenuItem(
                          context: context,
                          icon: FaIcon(
                            FontAwesomeIcons.lightUserPlus,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: '차단 해제'.tr(),
                          onTap: () {
                            Navigator.of(context).pop();
                            showUnblockDialog(parentContext);
                          },
                        ),
                        no: () => Column(
                          children: [
                            /// Pin/Unpin menu item - Real-time pin status
                            ValueListenableBuilder<Set<String>>(
                              valueListenable:
                                  ChatService.instance.pinnedChatRoomsStream,
                              builder: (context, pinnedRooms, _) {
                                final isPinned = pinnedRooms.contains(join.id);
                                return _buildComicMenuItem(
                                  context: context,
                                  icon: FaIcon(
                                    isPinned
                                        ? FontAwesomeIcons.lightThumbtack
                                        : FontAwesomeIcons.solidThumbtack,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  title: isPinned
                                      ? '채팅 고정 해제'.tr()
                                      : '채팅 고정'.tr(),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    await togglePinned(parentContext);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Profile menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: Avatar(photoUrl: getPhotoUrl()),
                              title: '프로필'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                showProfileDialog(parentContext, otherUser);
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Recent posts menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightNewspaper,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              title: '최근 글'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                showUserRecentPostsDialog(
                                  context: parentContext,
                                  otherUser: otherUser,
                                );
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Report menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightFlag,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: '신고'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                reportRoom(parentContext);
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Block user menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightBan,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: '사용자 차단'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                showBlockDialog(parentContext);
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Leave room menu item
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightArrowRightFromBracket,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: '방 나가기'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                showLeaveConfirmDialog(parentContext);
                              },
                            ),
                            SizedBox(height: dialogItemSpacing),

                            /// Block & Leave menu item - blocks user then leaves
                            _buildComicMenuItem(
                              context: context,
                              icon: FaIcon(
                                FontAwesomeIcons.lightBan,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              title: '차단 및 나가기'.tr(),
                              onTap: () {
                                Navigator.of(context).pop();
                                showBlockAndLeaveConfirmDialog(parentContext);
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: dialogItemSpacing),
                    ],
                    SizedBox(height: dialogItemSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Report room - show report dialog
  void reportRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ReportChatRoom(
        roomId: join.id,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Show confirmation dialog for leaving room
  /// Returns 'leave' or 'block_and_leave' as the user's choice.
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  void showLeaveConfirmDialog(BuildContext parentContext) async {
    final theme = Theme.of(parentContext);
    final colorScheme = theme.colorScheme;
    // Returns null (dismissed), 'leave', or 'block_and_leave'
    final String? action = await showDialog<String>(
      context: parentContext,
      builder: (context) => Dialog(
        // Comic design: no shadow
        elevation: dialogElevation,
        // Comic design: rounded corners (borderRadius: 12)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogBorderRadius),
        ),
        // Remove default background to use Container decoration
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            // Comic design: surface background color
            color: colorScheme.surface,
            // Comic design: 2.0px outline border with rounded corners
            border: Border.all(
              color: colorScheme.outline,
              width: dialogBorderWidth,
            ),
            borderRadius: BorderRadius.circular(dialogBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title section - Comic design spacing (multiples of 8)
              Padding(
                padding: dialogTitlePadding,
                child: Text(
                  '방 나가기'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Content section - Comic design spacing
              Padding(
                padding: dialogBodyPadding,
                child: Text(
                  '이 방을 나가시겠습니까?'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Actions section - Column layout to fit 3 full-width buttons
              Padding(
                padding: dialogActionsPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Block & Leave button - blocks user then leaves
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.of(context).pop('block_and_leave'),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(dialogElevation),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onError,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('차단 및 나가기'.tr()),
                    ),
                    SizedBox(height: dialogButtonSpacing),

                    // Leave only button - Comic design error outlined button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop('leave'),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(dialogElevation),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        // Outlined style: surface background, error text
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('나가기'.tr()),
                    ),
                    SizedBox(height: dialogButtonSpacing),

                    // Cancel button - Comic design neutral button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(dialogElevation),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              actionButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: actionButtonBorderWidth,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        padding: WidgetStateProperty.all(actionButtonPadding),
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      child: Text('취소'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!parentContext.mounted) return;

    if (action == 'block_and_leave') {
      // Block the other user first, then leave the room
      try {
        await toggleBlockUser(otherUser.firebaseUid);
      } catch (e) {
        debugPrint('Error blocking user before leave: $e');
      }
      if (parentContext.mounted) {
        onLeave?.call();
      }
    } else if (action == 'leave') {
      onLeave?.call();
    }
  }

  /// Delegates to ChatService to show "Block & Leave" confirmation dialog.
  void showBlockAndLeaveConfirmDialog(BuildContext parentContext) {
    ChatService.instance.showBlockAndLeaveConfirmDialog(
      context: parentContext,
      otherUserUid: otherUser.firebaseUid,
      onLeave: () => onLeave?.call(),
    );
  }

  /// Show block/unblock dialog with the other user's nickname
  void showBlockDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => BlockUserDialog(
        otherUserUid: otherUser.firebaseUid,
        displayName: otherUser.nickname,
        onBlocked: () {
          Navigator.of(parentContext).pop(); // Close chat message.
        },
      ),
    );
  }

  /// Show block/unblock dialog
  void showUnblockDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => UnblockUserDialog(
        otherUserUid: otherUser.firebaseUid,
        onUnblocked: () {
          // Optionally refresh or show success message
        },
      ),
    );
  }

  /// Toggle pin/unpin status for the chat room
  /// Pin: Add to Firebase users/{uid}/pinnedChatRooms/{roomId}
  /// Unpin: Remove from Firebase
  Future<void> togglePinned(BuildContext context) async {
    if (loginUid() == null) return;

    try {
      final ref = FirebaseDatabase.instance.ref(
        'users/${myUid()}/pinnedChatRooms/${join.id}',
      );

      // Check current pin status
      final isPinned = ChatService.instance.pinnedChatRooms.contains(join.id);

      if (isPinned) {
        // Unpin: Remove from Firebase
        await ref.remove();

        if (context.mounted) {
          showSuccessSnackBar(context, '채팅방 고정 해제 완료'.tr());
        }
      } else {
        // Pin: Set value to true in Firebase
        await ref.set(true);

        if (context.mounted) {
          showSuccessSnackBar(context, '채팅방 고정 완료'.tr());
        }
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, '오류: {}'.tr(args: [e.toString()]));
      }
    }
  }

  Widget buildRoomTitle(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showProfileDialog(context, otherUser);
      },
      child: Row(
        children: [
          Avatar(photoUrl: getPhotoUrl()),
          const SizedBox(width: 12),

          // Room/User Name + Last seen
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  getRoomName(),
                  // Comic design: Use theme text style instead of hardcoded
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                OnlineStatus(
                  uid: otherUser.firebaseUid,
                  yes: Text(
                    '온라인'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  lastSeenBuilder: (lastChanged) {
                    final lastSeen = DateTime.fromMillisecondsSinceEpoch(
                      lastChanged,
                    );
                    final diff = DateTime.now().difference(lastSeen);
                    final String timeText;
                    if (diff.inMinutes < 1) {
                      timeText = '방금 전'.tr();
                    } else if (diff.inMinutes < 60) {
                      timeText = '{분}분 전'.tr(args: ['${diff.inMinutes}']);
                    } else if (diff.inHours < 24) {
                      timeText = '{시간}시간 전'.tr(args: ['${diff.inHours}']);
                    } else {
                      timeText = '{일}일 전'.tr(args: ['${diff.inDays}']);
                    }
                    return Text(
                      '마지막 접속: {시간}'.tr(args: [timeText]),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? getPhotoUrl() {
    if (otherUser.photoUrl.isNotEmpty) {
      return otherUser.photoUrl;
    }
    if (join.userPhotoUrl.isNotEmpty) {
      return join.userPhotoUrl;
    }
    return null;
  }

  String getRoomName() {
    if (join.customName.isNotEmpty) {
      return join.customName;
    }
    if (otherUser.nickname.isNotEmpty) {
      return otherUser.nickname;
    }
    if (join.userDisplayName.isNotEmpty) {
      return join.userDisplayName;
    }
    return '이름없음'.tr();
  }

  /// Build a menu item with Comic design
  /// Comic design: 2px border, rounded corners, no shadow
  Widget _buildComicMenuItem({
    required BuildContext context,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(dialogItemBorderRadius),
      child: Container(
        padding: dialogItemPadding,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(dialogItemBorderRadius),

          /// Comic design: 2.0px border with outline color
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: dialogItemBorderWidth,
          ),
        ),
        child: Row(
          children: [
            /// Icon
            SizedBox(width: 32, height: 32, child: Center(child: icon)),
            SizedBox(width: dialogAvatarSpacing),

            /// Title
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 북마크 아이콘 버튼 - API로 북마크 상태를 확인하여 아이콘 표시
class _FavoriteIconButton extends StatefulWidget {
  final String roomId;

  const _FavoriteIconButton({required this.roomId});

  @override
  State<_FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<_FavoriteIconButton> {
  bool? _isBookmarked;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    final ids = await BookmarkService.instance.myBookmarkedIds(
      entityType: 'chat_room',
    );
    if (mounted) {
      setState(() {
        _isBookmarked = ids.contains(widget.roomId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isBookmarked == null) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );
    }
    return IconButton(
      onPressed: () => _onTap(context),
      icon: FaIcon(
        _isBookmarked!
            ? FontAwesomeIcons.solidStar
            : FontAwesomeIcons.star,
        color: _isBookmarked! ? Colors.amberAccent : null,
        size: 20,
      ),
      tooltip: '즐겨찾기에 추가'.tr(),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    final result = await showBookmarkGroupPicker(
      context: context,
      isBookmarked: _isBookmarked ?? false,
    );
    if (result == null || !context.mounted) return;

    if (result.removed) {
      await BookmarkService.instance.remove(
        entityType: 'chat_room',
        entityId: widget.roomId,
      );
      setState(() => _isBookmarked = false);
    } else {
      await BookmarkService.instance.add(
        entityType: 'chat_room',
        entityId: widget.roomId,
        groupName: result.groupName ?? '',
      );
      setState(() => _isBookmarked = true);
    }
  }
}
