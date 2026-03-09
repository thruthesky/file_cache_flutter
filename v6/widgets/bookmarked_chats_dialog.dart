import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:philgo/globals.dart';

/// 북마크된 채팅 목록 다이얼로그
/// 특정 폴더에 저장된 북마크 채팅방 목록을 표시하고 선택 시 채팅방으로 이동
/// Comic 스타일 적용: 2.0 테두리, 그림자 없음, 둥근 모서리
class BookmarkedChatsDialog extends StatelessWidget {
  const BookmarkedChatsDialog({super.key, required this.folderName});

  final String folderName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline, width: 2.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: 2.0),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightComments,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(T.bookmarked_chats, style: textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          folderName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 북마크된 채팅 목록
            Login(
              builder: (uid) => StreamBuilder<DatabaseEvent>(
                stream: FirebaseDatabase.instance
                    .ref('chat/favorites/$uid/$folderName')
                    .onValue,
                builder: (context, snapshot) {
                  // 로딩 중 - Comic 스타일
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: 2.0,
                            ),
                          ),
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // 에러 발생 - Comic 스타일
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.error,
                                width: 2.0,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightCircleExclamation,
                              size: 48,
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            PhilgoTr.of(
                              context,
                            )!.error_with_message(snapshot.error.toString()),
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // 데이터가 없거나 비어있는 경우 - Comic 스타일
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outline,
                                width: 2.0,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightComments,
                              size: 48,
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            T.no_bookmarked_chats,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // 북마크된 채팅방 ID 목록 가져오기
                  final data =
                      snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final chatRoomIds = data.keys.toList();

                  // 채팅방 목록 표시 - Comic 스타일
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: chatRoomIds.length,
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final roomId = chatRoomIds[index].toString();

                        // 각 채팅방의 join 정보 가져오기
                        return StreamBuilder<DatabaseEvent>(
                          stream: FirebaseDatabase.instance
                              .ref('chat/joins/$uid/$roomId')
                              .onValue,
                          builder: (context, joinSnapshot) {
                            // 로딩 중이거나 데이터가 없으면 간단한 표시 - Comic 스타일
                            if (joinSnapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !joinSnapshot.hasData ||
                                joinSnapshot.data?.snapshot.value == null) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          roomId,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            // ChatJoin 정보가 있으면 상세 표시 - Comic 스타일
                            try {
                              final chatJoin = ChatJoin.fromSnapshot(
                                joinSnapshot.data!.snapshot,
                              );
                              final otherUserUid =
                                  getOtherUserUidFromChatRoomId(roomId)!;

                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar with Comic border
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Avatar(
                                          photoUrl: chatJoin.userPhotoUrl,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Chat info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chatJoin.customName.isNotEmpty
                                                  ? chatJoin.customName
                                                  : chatJoin.roomName.isNotEmpty
                                                  ? chatJoin.roomName
                                                  : chatJoin.userDisplayName,
                                              style: textTheme.bodyLarge,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Blocked(
                                              otherUserUid: otherUserUid,
                                              yes: () => Text(
                                                PhilgoTr.of(
                                                  context,
                                                )!.blocked_message,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.outline,
                                                    ),
                                              ),
                                              no: () {
                                                return chatJoin
                                                        .lastMessage
                                                        .text
                                                        .isNotEmpty
                                                    ? Text(
                                                        chatJoin
                                                            .lastMessage
                                                            .text,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                      )
                                                    : const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Unread badge with Comic style
                                      if (chatJoin.unread > 0) ...[
                                        const SizedBox(width: 8),
                                        Blocked(
                                          otherUserUid: otherUserUid,
                                          yes: () => SizedBox.shrink(),
                                          no: () => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme.error,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: colorScheme.error,
                                                width: 2.0,
                                              ),
                                            ),
                                            child: Text(
                                              chatJoin.unread.toString(),
                                              style: textTheme.labelSmall
                                                  ?.copyWith(
                                                    color: colorScheme.onError,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            } catch (e) {
                              // 에러 발생 시 기본 표시 - Comic 스타일
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: 16,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          roomId,
                                          style: textTheme.bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
              notLoggedIn: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightCircleExclamation,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      PhilgoTr.of(context)!.login_required,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
