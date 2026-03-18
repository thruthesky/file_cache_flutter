import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/list/chat.room_list_view.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/chat/widgets/bookmarked_chats_dialog.dart';
import 'package:philgo/chat/widgets/favorite_folders_dialog.dart';
import 'package:philgo/chat/widgets/pinned_chat_rooms_list.dart';
import 'package:philgo/setting/setting.model.dart';
import 'package:philgo/setting/setting.state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Theme(
      data: chatThemeData(context),
      child: Column(
        children: [
          SafeArea(
            child: Container(
              padding: headerPadding,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: scheme.outlineVariant,
                    width: headerBottomBorderWidth,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '채팅'.tr(),
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.sharpSolidStar,
                      size: headerIconSize,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      final group = await showDialog(
                        context: context,
                        builder: (context) => const FavoriteFoldersDialog(),
                      );

                      if (group != null && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) => BookmarkedChatsDialog(
                            groupIdx: group.idx,
                            groupName: group.name,
                          ),
                        );
                      }
                    },
                  ),

                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.lightUserMagnifyingGlass,
                      size: headerIconSize,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: () async {
                      final uid = await ChatService.instance
                          .showUserSearchDialog(context);
                      if (uid != null && context.mounted) {
                        ChatRoomScreen.push(context, uid);
                      }
                    },
                  ),

                  PopupMenuButton<String>(
                    icon: FaIcon(
                      FontAwesomeIcons.bars,
                      size: headerIconSize,
                      color: scheme.onSurfaceVariant,
                    ),
                    onSelected: (value) {
                      if (value == 'admin_chat') {
                        ChatRoomScreen.pushAdminChat(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'admin_chat',
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.headset,
                              size: headerMenuIconSize,
                              color: scheme.onSurfaceVariant,
                            ),
                            SizedBox(width: dialogItemSpacing),
                            Text('운영자 문의'.tr()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PinnedChatRoomsList(
            onTap: (roomId) {
              ChatRoomScreen.push(context, roomId);
            },
          ),
          Expanded(
            child: ChatRoomListView(
              onTap: (roomId) {
                ChatRoomScreen.push(context, roomId);
              },
            ),
          ),
        ],
      ),
    );
  }
}
