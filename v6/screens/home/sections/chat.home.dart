import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/widgets/favorite_folders_dialog.dart';
import 'package:philgo/widgets/bookmarked_chats_dialog.dart';
import 'package:provider/provider.dart';
import 'package:philgo_api/philgo_api.dart';

/// 채팅 홈 화면 위젯 (Chat Home Screen Widget)
///
/// 앱의 채팅 기능에 접근하는 메인 화면입니다.
/// 상단 헤더, 고정된 채팅방 목록, 전체 채팅방 목록으로 구성됩니다.
///
/// ### 화면 구조:
/// - 헤더: 로고 + 타이틀 + 액션 버튼들 (즐겨찾기, 검색, 메뉴)
/// - 고정 채팅방: PinnedChatRoomsList (가로 스크롤)
/// - 채팅방 목록: ChatRoomListView (세로 스크롤)
class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  /// 채팅방 정렬 순서가 활성화되었는지 확인
  bool isActive(String order) {
    return NavigationState.of(context).roomOrder == order;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

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
                  l10n.chat,
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
                      ChatRoomScreen.push(
                        context,
                        UserService.instance.adminUserUid,
                      );
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
                          Text(l10n.contactAdmin),
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
          child: Selector<NavigationState, String>(
            selector: (_, navState) => navState.roomOrder,
            builder: (_, roomOrder, _) => ChatRoomListView(
              order: roomOrder,
              onTap: (roomId) {
                ChatRoomScreen.push(context, roomId);
              },
            ),
          ),
        ),
      ],
    );
  }
}
