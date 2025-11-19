import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/widgets/favorite_folders_dialog.dart';
import 'package:philgo/widgets/bookmarked_chats_dialog.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  bool isActive(String order) {
    return NavigationState.of(context).roomOrder == order;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    T.chat,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),

                // Stack(
                //   children: [
                //     IconButton(
                //       icon: FaIcon(
                //         isActive(RoomOrder.singleOrder)
                //             ? FontAwesomeIcons.solidUser
                //             : FontAwesomeIcons.sharpLightUser,
                //         color: isActive(RoomOrder.singleOrder)
                //             ? Theme.of(context).colorScheme.primary
                //             : null,
                //       ),
                //       onPressed: () {
                //         NavigationState.of(
                //           context,
                //           listen: false,
                //         ).setRoomOrder(RoomOrder.singleOrder);
                //       },
                //     ),
                //     Positioned(
                //       right: 2,
                //       top: 2,
                //       child: ValueListenableBuilder<int>(
                //         valueListenable:
                //             UserService.instance.unreadSingleCountStream,
                //         builder: (context, unreadSingleCount, child) {
                //           if (unreadSingleCount == 0) {
                //             return const SizedBox.shrink();
                //           }
                //           return Badge(
                //             label: Text(unreadSingleCount.toString()),
                //           );
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                // Stack(
                //   children: [
                //     IconButton(
                //       icon: FaIcon(
                //         isActive(RoomOrder.order)
                //             ? FontAwesomeIcons.solidComments
                //             : FontAwesomeIcons.sharpLightComments,
                //         color: isActive(RoomOrder.order)
                //             ? Theme.of(context).colorScheme.primary
                //             : null,
                //       ),
                //       onPressed: () {
                //         NavigationState.of(
                //           context,
                //           listen: false,
                //         ).setRoomOrder(RoomOrder.order);
                //       },
                //     ),
                //     Positioned(
                //       right: 2,
                //       top: 2,
                //       child: ValueListenableBuilder<int>(
                //         valueListenable: UserService.instance.unreadCountStream,
                //         builder: (context, unreadCount, child) {
                //           if (unreadCount == 0) {
                //             return const SizedBox.shrink();
                //           }
                //           return Badge(label: Text(unreadCount.toString()));
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                // IconButton(
                //   icon: FaIcon(
                //     isActive(RoomOrder.openOrder)
                //         ? FontAwesomeIcons.solidCommentNodes
                //         : FontAwesomeIcons.sharpLightCommentNodes,
                //     color: isActive(RoomOrder.openOrder)
                //         ? Theme.of(context).colorScheme.primary
                //         : null,
                //   ),
                //   onPressed: () {
                //     NavigationState.of(
                //       context,
                //       listen: false,
                //     ).setRoomOrder(RoomOrder.openOrder);
                //   },
                // ),
                const Spacer(),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.sharpSolidStar),
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
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.sharpLightMagnifyingGlass,
                  ),
                  onPressed: () async {
                    final uid = await showUserSearchDialog(context);
                    if (uid != null && context.mounted) {
                      // Navigate to chat room if a room ID is returned
                      ChatRoomScreen.push(context, uid);
                    }
                  },
                ),
                // IconButton(
                //   icon: const FaIcon(FontAwesomeIcons.sharpLightPlus),
                //   onPressed: () {
                //     CreateChatRoomScreen.push(context);
                //   },
                // ),
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
