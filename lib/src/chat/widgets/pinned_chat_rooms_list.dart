import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
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
    return ValueListenableBuilder<Set<String>>(
      valueListenable: UserService.instance.pinnedChatRoomsStream,
      builder: (context, pinnedChatRooms, _) {
        // 고정된 채팅방이 없으면 빈 위젯 반환
        if (pinnedChatRooms.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          // Theme의 surface 색상을 배경으로 사용
          color: Theme.of(context).colorScheme.surface,
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
            itemCount: pinnedChatRooms.length,
            itemBuilder: (context, index) {
              final roomId = pinnedChatRooms.elementAt(index);
              return _PinnedChatRoomItem(
                roomId: roomId,
                onTap: () => onTap(roomId),
              );
            },
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아바타와 닫기 버튼을 포함하는 Stack
                Stack(
                  children: [
                    // 아바타 - 탭하면 채팅방으로 이동
                    GestureDetector(
                      onTap: onTap,
                      child: Avatar(photoUrl: photoUrl, size: 56, radius: 28),
                    ),
                    // 우측 상단 닫기 버튼
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _showUnpinConfirmDialog(context),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            // Theme의 error 색상 사용
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                            // surface 색상으로 테두리 추가 (가독성 향상)
                            border: Border.all(
                              color: Theme.of(context).colorScheme.surface,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.close,
                            // onError 색상 사용 (error 위의 텍스트 색상)
                            color: Theme.of(context).colorScheme.onError,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 채팅방 이름 표시
                Text(
                  name,
                  // Theme의 bodySmall 텍스트 스타일 사용
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
