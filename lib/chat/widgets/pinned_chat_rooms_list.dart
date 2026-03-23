import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/widgets/chat.join.builder.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/user/widgets/avatar.dart';

/// 고정된 채팅방 목록 위젯
///
/// 사용자가 고정한 채팅방들을 가로 스크롤 형태로 표시합니다.
/// 각 채팅방의 아바타를 클릭하면 해당 채팅방으로 이동하고,
/// 우측 상단의 닫기 버튼을 클릭하면 고정 해제 확인 다이얼로그가 표시됩니다.
class PinnedChatRoomsList extends StatelessWidget {
  const PinnedChatRoomsList({super.key, required this.onTap});

  /// 채팅방 클릭 시 호출되는 콜백
  final void Function(String roomId) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ValueListenableBuilder<Set<String>>(
      valueListenable: ChatService.instance.pinnedChatRoomsStream,
      builder: (context, pinnedChatRooms, _) {
        // 고정된 채팅방이 없으면 빈 위젯 반환
        if (pinnedChatRooms.isEmpty) {
          return const SizedBox.shrink();
        }

        return ValueListenableBuilder<Set<String>>(
          valueListenable: UserService.instance.blockedUsersStream,
          builder: (context, blockedUsers, _) {
            // Filter out blocked users to get the actual display count
            final filteredCount = pinnedChatRooms.where((roomId) {
              final otherUserUid = getOtherUserUidFromChatRoomId(roomId);
              if (otherUserUid == null) return false;
              return !blockedUsers.contains(otherUserUid);
            }).length;

            // If all pinned chats are from blocked users, show nothing
            if (filteredCount == 0) {
              return const SizedBox.shrink();
            }

            return Container(
              // Comic design - solid background color with primaryContainer
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                // Comic design - outline border at bottom
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline,
                    width: pinnedSectionBorderWidth,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 섹션 헤더 - Comic design with Theme-based spacing
                  Padding(
                    padding: pinnedHeaderPadding,
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.solidThumbtack,
                          size: pinnedSectionIconSize,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: pinnedSectionIconSpacing),
                        Text(
                          // "Pinned Chats"
                          '고정된 채팅'.tr(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: pinnedSectionIconSpacing),
                        // Comic design - badge with border and rounded corners
                        // Show filtered count (excluding blocked users)
                        Container(
                          padding: pinnedCountBadgePadding,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              pinnedCountBadgeBorderRadius,
                            ),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: pinnedCountBadgeBorderWidth,
                            ),
                          ),
                          child: Text(
                            '$filteredCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 가로 스크롤 리스트 (높이 축소: 108 → 80)
                  // Filter out blocked users from the pinned chat rooms list
                  SizedBox(
                    height: pinnedListHeight,
                    child: Builder(
                      builder: (context) {
                        final filteredRoomIds = pinnedChatRooms.where((roomId) {
                          final otherUserUid = getOtherUserUidFromChatRoomId(
                            roomId,
                          );
                          if (otherUserUid == null) return false;
                          return !blockedUsers.contains(otherUserUid);
                        }).toList();

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: pinnedListPadding,
                          itemCount: filteredRoomIds.length,
                          itemBuilder: (context, index) {
                            final roomId = filteredRoomIds[index];
                            return _PinnedChatRoomItem(
                              roomId: roomId,
                              onTap: () => onTap(roomId),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: pinnedDividerSpacing),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// 고정된 채팅방 개별 아이템
class _PinnedChatRoomItem extends StatelessWidget {
  const _PinnedChatRoomItem({required this.roomId, required this.onTap});

  final String roomId;
  final VoidCallback onTap;

  /// 고정 해제 확인 다이얼로그 표시
  /// Comic design applied - 2.0px border, rounded corners, no shadow
  Future<void> _showUnpinConfirmDialog(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        // Comic design: no shadow
        elevation: dialogElevation,
        // Comic design: rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(unpinDialogBorderRadius),
        ),
        // Remove default background to use Container decoration
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            // Comic design: surface background color
            color: colorScheme.surface,
            // Comic design: outline border with rounded corners
            border: Border.all(
              color: colorScheme.outline,
              width: unpinDialogBorderWidth,
            ),
            borderRadius: BorderRadius.circular(unpinDialogBorderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title section - Comic design spacing (multiples of 8)
              Padding(
                padding: unpinTitlePadding,
                child: Text(
                  // "Unpin Chat Room"
                  '채팅방 고정 해제'.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Content section - Comic design spacing
              Padding(
                padding: unpinBodyPadding,
                child: Text(
                  // "Are you sure you want to unpin this chat room?"
                  '이 채팅방의 고정을 해제하시겠습니까?'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),

              // Actions section - Comic design buttons with spacing
              Padding(
                padding: unpinActionsPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel button - Comic design neutral button
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ButtonStyle(
                        // Comic design: no shadow
                        elevation: WidgetStateProperty.all(0),
                        // Comic design: border with rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              unpinButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.outline,
                              width: unpinButtonBorderWidth,
                            ),
                          ),
                        ),
                        // Comic design: surface background
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.surface,
                        ),
                        // Comic design: onSurface text color
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onSurface,
                        ),
                        // Comic design: padding in multiples of 8
                        padding: WidgetStateProperty.all(unpinButtonPadding),
                        // Comic design: text style from Theme
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      // "Cancel"
                      child: Text('취소'.tr()),
                    ),
                    SizedBox(width: unpinButtonSpacing),
                    // Unpin button - Comic design error button (destructive action)
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ButtonStyle(
                        // Comic design: no shadow
                        elevation: WidgetStateProperty.all(0),
                        // Comic design: border with rounded corners
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              unpinButtonBorderRadius,
                            ),
                            side: BorderSide(
                              color: colorScheme.error,
                              width: unpinButtonBorderWidth,
                            ),
                          ),
                        ),
                        // Comic design: error background for destructive action
                        backgroundColor: WidgetStateProperty.all(
                          colorScheme.error,
                        ),
                        // Comic design: onError text color
                        foregroundColor: WidgetStateProperty.all(
                          colorScheme.onError,
                        ),
                        // Comic design: padding in multiples of 8
                        padding: WidgetStateProperty.all(unpinButtonPadding),
                        // Comic design: text style from Theme
                        textStyle: WidgetStateProperty.all(
                          theme.textTheme.bodyMedium,
                        ),
                      ),
                      // "Unpin"
                      child: Text('고정 해제'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 사용자가 확인을 클릭한 경우 고정 해제
    if (confirmed == true && context.mounted) {
      await _unpinChatRoom(context);
    }
  }

  /// Firebase에서 고정 채팅방 삭제
  Future<void> _unpinChatRoom(BuildContext context) async {
    try {
      final uid = myUid();

      // user/{uid}/pinnedChatRooms/{joinId} 삭제
      final ref = FirebaseDatabase.instance.ref(
        'users/$uid/pinnedChatRooms/$roomId',
      );
      await ref.remove();

      if (context.mounted) {
        // 성공 메시지 표시 (선택적)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // "Chat room unpinned"
            content: Text('채팅방 고정이 해제되었습니다'.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // "Error: {}"
            content: Text('오류: {}'.tr(args: [e.toString()])),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChatJoinBuilder(
      roomId: roomId,
      builder: (context, join) {
        // join이 없으면 빈 위젯 반환
        if (join == null) {
          return const SizedBox.shrink();
        }

        final isSingle = isSingleChatRoom(roomId);
        final photoUrl = isSingle && join.userPhotoUrl.isNotEmpty
            ? join.userPhotoUrl
            : null;

        // 채팅방 이름 또는 사용자 이름
        String name;
        if (join.customName.isNotEmpty) {
          name = join.customName;
        } else if (isSingle) {
          name = join.userDisplayName.isNotEmpty
              ? join.userDisplayName
              // "No name"
              : '이름없음'.tr();
        } else {
          name = join.roomName.isNotEmpty ? join.roomName : 'No name';
        }

        // 읽지 않은 메시지 수
        final unreadCount = join.unread;

        return Padding(
          // 좌우 간격 축소 (8 → 4)
          padding: pinnedItemHPadding,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onTap,
              child: Container(
                // 너비 축소 (80 → 64)
                width: pinnedItemWidth,
                // 패딩 축소 (8 → 4)
                padding: pinnedItemPadding,
                // 보더 없는 미니멀 디자인
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아바타와 닫기 버튼을 포함하는 Stack
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 아바타 크기 축소 (56 → 44)
                        Avatar(
                          photoUrl: photoUrl,
                          size: pinnedAvatarSize,
                          radius: pinnedAvatarSize / 2,
                        ),
                        // 우측 상단 닫기 버튼 - 축소된 크기
                        Positioned(
                          right: -2,
                          top: -2,
                          child: GestureDetector(
                            onTap: () => _showUnpinConfirmDialog(context),
                            child: Container(
                              // 크기 축소 (24 → 18)
                              width: pinnedCloseButtonSize,
                              height: pinnedCloseButtonSize,
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                shape: BoxShape.circle,
                                // 테두리 두께 축소 (2.0 → 1.5)
                                border: Border.all(
                                  color: colorScheme.error,
                                  width: pinnedCloseButtonBorderWidth,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.xmark,
                                  color: colorScheme.error,
                                  // 아이콘 크기 축소 (12 → 9)
                                  size: pinnedCloseIconSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 읽지 않은 메시지 배지 - 축소된 크기
                        if (unreadCount > 0)
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              // 패딩 축소 (horizontal: 8 → 5, vertical: 2 → 1)
                              padding: pinnedUnreadBadgePadding,
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(
                                  pinnedUnreadBadgeBorderRadius,
                                ),
                                // 테두리 두께 축소 (2.0 → 1.5)
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: pinnedUnreadBadgeBorderWidth,
                                ),
                              ),
                              child: Text(
                                unreadCount > 99
                                    ? '99+'
                                    : unreadCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onError,
                                  fontWeight: FontWeight.w700,
                                  // 폰트 크기 축소 (10 → 8)
                                  fontSize: pinnedUnreadBadgeFontSize,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: pinnedNameSpacing),
                    // 채팅방 이름 표시
                    Text(
                      name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
