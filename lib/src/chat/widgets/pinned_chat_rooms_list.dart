import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
      valueListenable: UserService.instance.pinnedChatRoomsStream,
      builder: (context, pinnedChatRooms, _) {
        // 고정된 채팅방이 없으면 빈 위젯 반환
        if (pinnedChatRooms.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          // 고정된 채팅방 섹션 배경 - primaryContainer로 구분
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primaryContainer.withValues(alpha: 0.15),
                colorScheme.surface,
              ],
            ),
            // Flat design - subtle border instead of shadow
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 섹션 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.solidThumbtack,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pinned Chats',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${pinnedChatRooms.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 가로 스크롤 리스트
              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: pinnedChatRooms.length,
                  itemBuilder: (context, index) {
                    final roomId = pinnedChatRooms.elementAt(index);
                    return Blocked(
                      otherUserUid: getOtherUserUidFromChatRoomId(roomId)!,
                      yes: () => const SizedBox.shrink(),
                      no: () => _PinnedChatRoomItem(
                        roomId: roomId,
                        onTap: () => onTap(roomId),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
  Future<void> _showUnpinConfirmDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LibTr.of(context)!.unpin_chat_room_title),
        content: Text(LibTr.of(context)!.unpin_chat_room_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LibTr.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LibTr.of(context)!.unpin),
          ),
        ],
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
            content: Text(LibTr.of(context)!.chat_room_unpinned),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LibTr.of(context)!.error_with_message(e.toString())),
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
              : 'No name';
        } else {
          name = join.roomName.isNotEmpty ? join.roomName : 'No name';
        }

        // 읽지 않은 메시지 수
        final unreadCount = join.unread;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                width: 76,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  // Flat design - subtle border for definition
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 아바타와 닫기 버튼을 포함하는 Stack
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 아바타
                        Avatar(photoUrl: photoUrl, size: 56, radius: 28),
                        // 우측 상단 닫기 버튼
                        Positioned(
                          right: -4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () => _showUnpinConfirmDialog(context),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.xmark,
                                  color: colorScheme.onErrorContainer,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // 읽지 않은 메시지 배지
                        if (unreadCount > 0)
                          Positioned(
                            left: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                unreadCount > 99 ? '99+' : unreadCount.toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onError,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 채팅방 이름 표시
                    Text(
                      name,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
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
