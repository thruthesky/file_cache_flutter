import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/models/chat.join.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/user/widgets/avatar.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/user/widgets/login.dart';

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
    final chatTheme = ChatThemeData.instance;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: chatTheme.dialog.elevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: chatTheme.dialog.maxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
          border: Border.all(color: colorScheme.outline, width: chatTheme.dialog.borderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: chatTheme.dialog.headerPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(chatTheme.dialog.headerBorderRadius),
                  topRight: Radius.circular(chatTheme.dialog.headerBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: chatTheme.dialog.headerBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightComments,
                    color: colorScheme.primary,
                    size: chatTheme.dialog.headerIconSize,
                  ),
                  SizedBox(width: chatTheme.dialog.itemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bookmarked Chats', style: textTheme.titleMedium),
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
                    borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: chatTheme.dialog.closeIconSize,
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
                      padding: chatTheme.dialog.emptyPadding,
                      child: Center(
                        child: Container(
                          padding: chatTheme.dialog.emptyContainerPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: chatTheme.dialog.borderWidth,
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
                      padding: chatTheme.dialog.emptyPadding,
                      child: Column(
                        children: [
                          Container(
                            padding: chatTheme.dialog.emptyContainerPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
                              border: Border.all(
                                color: colorScheme.error,
                                width: chatTheme.dialog.borderWidth,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightCircleExclamation,
                              size: chatTheme.dialog.emptyIconSize,
                              color: colorScheme.error,
                            ),
                          ),
                          SizedBox(height: chatTheme.dialog.emptySpacing),
                          Text(
                            "Error: ${snapshot.error.toString()}",
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
                      padding: chatTheme.dialog.emptyPadding,
                      child: Column(
                        children: [
                          Container(
                            padding: chatTheme.dialog.emptyContainerPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
                              border: Border.all(
                                color: colorScheme.outline,
                                width: chatTheme.dialog.borderWidth,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightComments,
                              size: chatTheme.dialog.emptyIconSize,
                              color: colorScheme.outline,
                            ),
                          ),
                          SizedBox(height: chatTheme.dialog.emptySpacing),
                          Text(
                            'No bookmarked chats yet',
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
                    constraints: BoxConstraints(maxHeight: chatTheme.dialog.listMaxHeight),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: chatRoomIds.length,
                      padding: chatTheme.dialog.contentPadding,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: chatTheme.dialog.itemSpacing),
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
                                borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                child: Container(
                                  padding: chatTheme.dialog.itemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: chatTheme.dialog.itemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: chatTheme.dialog.avatarSize,
                                        height: chatTheme.dialog.avatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            chatTheme.dialog.avatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: chatTheme.dialog.avatarBorderWidth,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: chatTheme.dialog.closeIconSize,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: chatTheme.dialog.avatarSpacing),
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
                                borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                child: Container(
                                  padding: chatTheme.dialog.itemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: chatTheme.dialog.itemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar with Comic border
                                      Container(
                                        width: chatTheme.dialog.avatarSize,
                                        height: chatTheme.dialog.avatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            chatTheme.dialog.avatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: chatTheme.dialog.avatarBorderWidth,
                                          ),
                                        ),
                                        child: Avatar(
                                          photoUrl: chatJoin.userPhotoUrl,
                                        ),
                                      ),
                                      SizedBox(width: chatTheme.dialog.avatarSpacing),
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
                                                "Message from blocked user (tap to unblock)",
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
                                            padding: chatTheme.dialog.dialogUnreadBadgePadding,
                                            decoration: BoxDecoration(
                                              color: colorScheme.error,
                                              borderRadius:
                                                  BorderRadius.circular(chatTheme.dialog.dialogUnreadBadgeBorderRadius),
                                              border: Border.all(
                                                color: colorScheme.error,
                                                width: chatTheme.dialog.dialogUnreadBadgeBorderWidth,
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
                                borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                child: Container(
                                  padding: chatTheme.dialog.itemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: chatTheme.dialog.itemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: chatTheme.dialog.avatarSize,
                                        height: chatTheme.dialog.avatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            chatTheme.dialog.avatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: chatTheme.dialog.avatarBorderWidth,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: chatTheme.dialog.closeIconSize,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: chatTheme.dialog.avatarSpacing),
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
                padding: chatTheme.dialog.emptyPadding,
                child: Column(
                  children: [
                    Container(
                      padding: chatTheme.dialog.emptyContainerPadding,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.borderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightCircleExclamation,
                        size: chatTheme.dialog.emptyIconSize,
                        color: colorScheme.outline,
                      ),
                    ),
                    SizedBox(height: chatTheme.dialog.emptySpacing),
                    Text(
                      "Login required to view bookmarked chats",
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
