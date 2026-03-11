import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/list/chat.room_list_view.dart';
import 'package:philgo/chat/room/chat.room_screen.dart';
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
        /// 상단 SafeArea 및 헤더 (Top SafeArea and Header)
        /// Comic Design: 1.0px bottom border with outlineVariant color
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Comic design: 1.0px border with outlineVariant color (matches bottom nav)
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// 채팅 타이틀 (Chat Title)
                Text(
                  "Chat",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.normal,
                  ),
                ),

                const Spacer(),

                /// 즐겨찾기 버튼 (Favorite/Bookmark Button)
                /// 즐겨찾기 폴더 목록을 표시하고 선택한 폴더의 채팅 목록을 보여줌
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.sharpSolidStar,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    // 즐겨찾기 폴더 목록 다이얼로그 표시
                    final folderName = await showDialog<String>(
                      context: context,
                      builder: (context) => const FavoriteFoldersDialog(),
                    );

                    // 폴더가 선택되면 해당 폴더의 북마크된 채팅 목록 표시
                    if (folderName != null && context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (context) =>
                            BookmarkedChatsDialog(folderName: folderName),
                      );
                    }
                  },
                ),

                /// 사용자 검색 버튼 (User Search Button)
                /// 사용자를 검색하여 1:1 채팅방으로 이동
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.lightUserMagnifyingGlass,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  onPressed: () async {
                    final uid = await showUserSearchDialog(context);
                    if (uid != null && context.mounted) {
                      // Navigate to chat room if a room ID is returned
                      ChatRoomScreen.push(context, uid);
                    }
                  },
                ),

                /// 채팅 메뉴 버튼 (운영자 문의 등)
                /// Chat Menu Button (Admin contact, etc.)
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
        // 고정된 채팅방 목록 (가로 스크롤)
        PinnedChatRoomsList(
          onTap: (roomId) {
            ChatRoomScreen.push(context, roomId);
          },
        ),
        Expanded(
          child: ChatRoomListView(
            order: 'singleOrder',
            onTap: (roomId) {
              ChatRoomScreen.push(context, roomId);
            },
          ),
        ),
      ],
    );
  }
}
