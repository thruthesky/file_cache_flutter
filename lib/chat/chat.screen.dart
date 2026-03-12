import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/list/chat.room_list_view.dart';
// import 'package:philgo/chat/room/chat.room_screen.dart';
import 'package:philgo/chat/widgets/bookmarked_chats_dialog.dart';
import 'package:philgo/chat/widgets/favorite_folders_dialog.dart';
import 'package:philgo/chat/widgets/pinned_chat_rooms_list.dart';

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

    return Column(
      children: [
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Chat",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const Spacer(),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.sharpSolidStar,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    final folderName = await showDialog<String>(
                      context: context,
                      builder: (context) => const FavoriteFoldersDialog(),
                    );

                    if (folderName != null && context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (context) =>
                            BookmarkedChatsDialog(folderName: folderName),
                      );
                    }
                  },
                ),

                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.lightUserMagnifyingGlass,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    final uid = await showUserSearchDialog(context);
                    if (uid != null && context.mounted) {
                      // ChatRoomScreen.push(context, uid);
                    }
                  },
                ),

                PopupMenuButton<String>(
                  icon: FaIcon(
                    FontAwesomeIcons.bars,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    if (value == 'admin_chat') {
                      // 운영자와 1:1 채팅방 입장
                      // @TODO: UPDATE with actual admin UID when available
                      // ChatRoomScreen.push(
                      //   context,
                      //   UserService.instance.adminUserUid,
                      // );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'admin_chat',
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.headset,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text("Contact Admin"),
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
            // ChatRoomScreen.push(context, roomId);
          },
        ),
        Expanded(
          child: ChatRoomListView(
            onTap: (roomId) {
              // ChatRoomScreen.push(context, roomId);
            },
          ),
        ),
      ],
    );
  }
}
