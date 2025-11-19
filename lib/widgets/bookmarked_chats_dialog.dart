import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/globals.dart';

/// 북마크된 채팅 목록 다이얼로그
/// 특정 폴더에 저장된 북마크 채팅방 목록을 표시하고 선택 시 채팅방으로 이동
class BookmarkedChatsDialog extends StatelessWidget {
  const BookmarkedChatsDialog({
    super.key,
    required this.folderName,
  });

  final String folderName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightComments,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          T.bookmarked_chats,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          folderName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.lightXmark),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                  // 로딩 중
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }

                  // 에러 발생
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightCircleExclamation,
                            size: 48,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            LibTr.of(context)!
                                .error_with_message(snapshot.error.toString()),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  // 데이터가 없거나 비어있는 경우
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightComments,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            T.no_bookmarked_chats,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
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

                  // 채팅방 목록 표시
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: chatRoomIds.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      itemBuilder: (context, index) {
                        final roomId = chatRoomIds[index].toString();

                        // 각 채팅방의 join 정보 가져오기
                        return StreamBuilder<DatabaseEvent>(
                          stream: FirebaseDatabase.instance
                              .ref('chat/joins/$uid/$roomId')
                              .onValue,
                          builder: (context, joinSnapshot) {
                            // 로딩 중이거나 데이터가 없으면 간단한 표시
                            if (joinSnapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !joinSnapshot.hasData ||
                                joinSnapshot.data?.snapshot.value == null) {
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: FaIcon(
                                    FontAwesomeIcons.lightComments,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(roomId),
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
                              );
                            }

                            // ChatJoin 정보가 있으면 상세 표시
                            try {
                              final chatJoin = ChatJoin.fromSnapshot(
                                joinSnapshot.data!.snapshot,
                              );

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  backgroundImage: chatJoin.userPhotoUrl.isNotEmpty
                                      ? NetworkImage(chatJoin.userPhotoUrl)
                                      : null,
                                  child: chatJoin.userPhotoUrl.isEmpty
                                      ? FaIcon(
                                          FontAwesomeIcons.lightUser,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        )
                                      : null,
                                ),
                                title: Text(
                                  chatJoin.customName.isNotEmpty
                                      ? chatJoin.customName
                                      : chatJoin.roomName.isNotEmpty
                                          ? chatJoin.roomName
                                          : chatJoin.userDisplayName,
                                ),
                                subtitle: chatJoin.lastMessage.text.isNotEmpty
                                    ? Text(
                                        chatJoin.lastMessage.text,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                trailing: chatJoin.unread > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          chatJoin.unread.toString(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      )
                                    : null,
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
                              );
                            } catch (e) {
                              // 에러 발생 시 기본 표시
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: FaIcon(
                                    FontAwesomeIcons.lightComments,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(roomId),
                                onTap: () {
                                  Navigator.pop(context);
                                  ChatRoomScreen.push(context, roomId);
                                },
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
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightCircleExclamation,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      LibTr.of(context)!.login_required,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
