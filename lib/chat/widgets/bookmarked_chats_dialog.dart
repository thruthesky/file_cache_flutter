import 'package:easy_localization/easy_localization.dart';
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: dialogElevation,
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(dialogBorderRadius),
          border: Border.all(color: colorScheme.outline, width: dialogBorderWidth),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 다이얼로그 헤더 - Comic 스타일
            Container(
              padding: dialogHeaderPadding,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dialogHeaderBorderRadius),
                  topRight: Radius.circular(dialogHeaderBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(color: colorScheme.outline, width: dialogHeaderBorderWidth),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightComments,
                    color: colorScheme.primary,
                    size: dialogHeaderIconSize,
                  ),
                  SizedBox(width: dialogItemSpacing),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('북마크된 채팅'.tr(), style: textTheme.titleMedium),
                        SizedBox(height: subtitleSpacing),
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
                    borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(closeButtonBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightXmark,
                        size: closeIconSize,
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
                      padding: dialogEmptyPadding,
                      child: Center(
                        child: Container(
                          padding: dialogEmptyContainerPadding,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(dialogBorderRadius),
                            border: Border.all(
                              color: colorScheme.outline,
                              width: dialogBorderWidth,
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
                      padding: dialogEmptyPadding,
                      child: Column(
                        children: [
                          Container(
                            padding: dialogEmptyContainerPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(dialogBorderRadius),
                              border: Border.all(
                                color: colorScheme.error,
                                width: dialogBorderWidth,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightCircleExclamation,
                              size: dialogEmptyIconSize,
                              color: colorScheme.error,
                            ),
                          ),
                          SizedBox(height: dialogEmptySpacing),
                          Text(
                            '오류: {}'.tr(args: [snapshot.error.toString()]),
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
                      padding: dialogEmptyPadding,
                      child: Column(
                        children: [
                          Container(
                            padding: dialogEmptyContainerPadding,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(dialogBorderRadius),
                              border: Border.all(
                                color: colorScheme.outline,
                                width: dialogBorderWidth,
                              ),
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.lightComments,
                              size: dialogEmptyIconSize,
                              color: colorScheme.outline,
                            ),
                          ),
                          SizedBox(height: dialogEmptySpacing),
                          Text(
                            '북마크된 채팅이 없습니다'.tr(),
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
                    constraints: BoxConstraints(maxHeight: dialogListMaxHeight),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: chatRoomIds.length,
                      padding: dialogContentPadding,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: dialogItemSpacing),
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
                                borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                child: Container(
                                  padding: dialogItemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: dialogItemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: dialogAvatarSize,
                                        height: dialogAvatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            dialogAvatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: dialogAvatarBorderWidth,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: closeIconSize,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: dialogAvatarSpacing),
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
                                borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                child: Container(
                                  padding: dialogItemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: dialogItemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar with Comic border
                                      Container(
                                        width: dialogAvatarSize,
                                        height: dialogAvatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            dialogAvatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: dialogAvatarBorderWidth,
                                          ),
                                        ),
                                        child: Avatar(
                                          photoUrl: chatJoin.userPhotoUrl,
                                        ),
                                      ),
                                      SizedBox(width: dialogAvatarSpacing),
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
                                            SizedBox(height: subtitleSpacing),
                                            Blocked(
                                              otherUserUid: otherUserUid,
                                              yes: () => Text(
                                                '차단된 사용자의 메시지 (탭하여 차단 해제)'.tr(),
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
                                        SizedBox(width: dialogItemSpacing),
                                        Blocked(
                                          otherUserUid: otherUserUid,
                                          yes: () => SizedBox.shrink(),
                                          no: () => Container(
                                            padding: dialogUnreadBadgePadding,
                                            decoration: BoxDecoration(
                                              color: colorScheme.error,
                                              borderRadius:
                                                  BorderRadius.circular(dialogUnreadBadgeBorderRadius),
                                              border: Border.all(
                                                color: colorScheme.error,
                                                width: dialogUnreadBadgeBorderWidth,
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
                                borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                child: Container(
                                  padding: dialogItemPadding,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(dialogItemBorderRadius),
                                    border: Border.all(
                                      color: colorScheme.outline,
                                      width: dialogItemBorderWidth,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: dialogAvatarSize,
                                        height: dialogAvatarSize,
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            dialogAvatarBorderRadius,
                                          ),
                                          border: Border.all(
                                            color: colorScheme.primary,
                                            width: dialogAvatarBorderWidth,
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.lightComments,
                                            size: closeIconSize,
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: dialogAvatarSpacing),
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
                padding: dialogEmptyPadding,
                child: Column(
                  children: [
                    Container(
                      padding: dialogEmptyContainerPadding,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(dialogBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: dialogBorderWidth,
                        ),
                      ),
                      child: FaIcon(
                        FontAwesomeIcons.lightCircleExclamation,
                        size: dialogEmptyIconSize,
                        color: colorScheme.outline,
                      ),
                    ),
                    SizedBox(height: dialogEmptySpacing),
                    Text(
                      '북마크된 채팅을 보려면 로그인하세요'.tr(),
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
