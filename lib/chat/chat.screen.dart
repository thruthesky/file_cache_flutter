import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/list/chat.room_list_view.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/chat/widgets/bookmarked_chats_dialog.dart';
import 'package:philgo/chat/widgets/favorite_folders_dialog.dart';
import 'package:philgo/chat/widgets/pinned_chat_rooms_list.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/user/widgets/login.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Login(
      builder: (uid) => buildChatRoomList(),
      notLoggedIn: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.lightComments,
              size: 64,
              color: color.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            // "Login required"
            Text('로그인이 필요합니다'.tr()),
            Text(
              // "Login to access all features"
              '로그인하여 모든 기능을 이용하세요'.tr(),
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                UserLoginScreen.push(context);
              },
              // "Login"
              child: Text('로그인'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChatRoomList() {
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
                    color: color.outlineVariant,
                    width: headerBottomBorderWidth,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // "Chat"
                    '채팅'.tr(),
                    style: text.titleLarge!.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),

                  const Spacer(),
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.sharpSolidStar,
                      size: headerIconSize,
                      color: color.onSurfaceVariant,
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
                      color: color.onSurfaceVariant,
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
                      color: color.onSurfaceVariant,
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
                              color: color.onSurfaceVariant,
                            ),
                            SizedBox(width: dialogItemSpacing),
                            // "Contact Admin"
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
