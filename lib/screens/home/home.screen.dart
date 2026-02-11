import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/sections/main.home.dart';
import 'package:philgo/services/chat_sound/chat_sound.service.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_api/philgo_api.dart';
import 'sections/chat.home.dart';
import 'sections/forum.home.dart';
import 'sections/company.home.dart';
import 'sections/menu.home.dart';
import '../../l10n/app_localizations.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

/// HomeScreen - 홈 스크린
///
/// 사용자가 로그인 후 보이는 메인 스크린입니다.
/// 하단 네비게이션 바를 통해 홈, 게시판, 업소록, 채팅, 메뉴 화면을 전환합니다.
class HomeScreen extends StatefulWidget {
  static const String routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final HomeNavigationItem selectedItem = NavigationState.of(context).homeNav;
    return Scaffold(
      body: IndexedStack(
        index: selectedItem.index,
        children: const [
          MainHome(), // 홈
          ForumHome(), // 게시판
          CompanyHome(), // 업소록
          ChatHome(), // 채팅
          MenuHome(), // 메뉴
        ],
      ),

      /// Bottom Navigation Bar with conditional rendering
      /// Shows chat-specific navigation bar when chat screen is active
      /// 채팅 화면 활성화 시 채팅 전용 하단 네비게이션 바 표시
      bottomNavigationBar: selectedItem == HomeNavigationItem.chat
          ? _buildChatBottomNavigationBar(context)
          : _buildHomeBottomNavigationBar(context, selectedItem),
    );
  }

  /// Build the default home bottom navigation bar
  /// 기본 홈 하단 네비게이션 바 구성
  ///
  /// Contains: Home, Forum, Directory, Chat, Menu
  Widget _buildHomeBottomNavigationBar(
    BuildContext context,
    HomeNavigationItem selectedItem,
  ) {
    return Container(
      // BottomNavigationBar와 동일한 배경색 설정
      decoration: BoxDecoration(
        // BottomNavigationBar의 기본 배경색과 동일하게 surface 색상 사용
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: FaIcon(
                selectedItem == HomeNavigationItem.home
                    ? FontAwesomeIcons.solidHouse
                    : FontAwesomeIcons.thinHouse,
              ),
              label: Lo.of(context)!.home,
            ),

            BottomNavigationBarItem(
              icon: FaIcon(
                selectedItem == HomeNavigationItem.forum
                    ? FontAwesomeIcons.solidNewspaper
                    : FontAwesomeIcons.thinNewspaper,
              ),
              label: Lo.of(context)!.forum,
            ),
            BottomNavigationBarItem(
              icon: FaIcon(
                selectedItem == HomeNavigationItem.company
                    ? FontAwesomeIcons.solidBuilding
                    : FontAwesomeIcons.thinBuilding,
              ),
              label: Lo.of(context)!.company,
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: FaIcon(
                      selectedItem == HomeNavigationItem.chat
                          ? FontAwesomeIcons.solidCommentDots
                          : FontAwesomeIcons.thinCommentDots,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable:
                          UserService.instance.unreadSingleCountStream,
                      builder: (context, unreadSingleCount, child) {
                        if (unreadSingleCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return Badge(label: Text(unreadSingleCount.toString()));
                      },
                    ),
                  ),
                ],
              ),
              label: Lo.of(context)!.chat,
            ),
            BottomNavigationBarItem(
              key: ValueKey('menuButton'),
              icon: FaIcon(
                selectedItem == HomeNavigationItem.menu
                    ? FontAwesomeIcons.solidBars
                    : FontAwesomeIcons.thinBars,
              ),
              label: Lo.of(context)!.menu,
            ),
          ],
          currentIndex: selectedItem.index,
          onTap: (index) {
            // Firebase Analytics 화면 조회 로깅
            FirebaseAnalytics.instance.logScreenView(
              screenName: HomeNavigationItem.values[index].name,
            );

            final tappedItem = HomeNavigationItem.values[index];

            // 디버그: unreadSingleCount 값 확인
            debugPrint('[HomeScreen] 🔵 onTap: unreadSingleCount = ${UserService.instance.unreadSingleCount}');

            // 읽지 않은 메시지가 있으면 알림음 재생
            // Play notification sound when there are unread messages
            if (UserService.instance.unreadSingleCount > 0) {
              debugPrint('[HomeScreen] 🔊 Playing receive sound!');
              ChatSoundService.instance.playReceiveSound();
            }

            NavigationState.of(
              context,
              listen: false,
            ).setHomeNavigation(tappedItem);
          },
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
        ),
      ),
    );
  }

  /// Build chat-specific bottom navigation bar
  /// 채팅 화면 전용 하단 네비게이션 바 구성
  ///
  /// Contains: Home, Forum, 1:1 Chat, Admin Chat, Menu
  /// When Admin Chat is tapped, directly enters admin's 1:1 chat room
  Widget _buildChatBottomNavigationBar(BuildContext context) {
    final navState = NavigationState.of(context);
    final chatNav = navState.chatNav;

    return Container(
      // Same styling as home navigation bar for consistency
      // 홈 네비게이션 바와 동일한 스타일 유지
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            // Home - Navigate to main home screen
            // 홈 - 메인 홈 화면으로 이동
            BottomNavigationBarItem(
              icon: FaIcon(
                chatNav == ChatNavigationItem.home
                    ? FontAwesomeIcons.solidHouse
                    : FontAwesomeIcons.thinHouse,
              ),
              label: Lo.of(context)!.home,
            ),

            // Forum - Navigate to forum screen
            // 게시판 - 게시판 화면으로 이동
            BottomNavigationBarItem(
              icon: FaIcon(
                chatNav == ChatNavigationItem.forum
                    ? FontAwesomeIcons.solidNewspaper
                    : FontAwesomeIcons.thinNewspaper,
              ),
              label: Lo.of(context)!.forum,
            ),

            // Admin Chat - Enter admin 1:1 chat room directly
            // 운영자채팅 - 운영자와 1:1 채팅방 바로 입장
            BottomNavigationBarItem(
              icon: FaIcon(
                chatNav == ChatNavigationItem.adminChat
                    ? FontAwesomeIcons.solidUserShield
                    : FontAwesomeIcons.lightUserShield,
              ),
              label: Lo.of(context)!.adminChat,
            ),

            // 1:1 Chat - Show single chat list
            // 1:1채팅 - 1:1 채팅 목록 표시
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: FaIcon(
                      chatNav == ChatNavigationItem.singleChat
                          ? FontAwesomeIcons.solidCommentDots
                          : FontAwesomeIcons.thinCommentDots,
                    ),
                  ),
                  // Unread message badge
                  // 읽지 않은 메시지 배지
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable:
                          UserService.instance.unreadSingleCountStream,
                      builder: (context, unreadSingleCount, child) {
                        if (unreadSingleCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return Badge(label: Text(unreadSingleCount.toString()));
                      },
                    ),
                  ),
                ],
              ),
              label: Lo.of(context)!.singleChat,
            ),

            // Menu - Navigate to menu screen
            // 메뉴 - 메뉴 화면으로 이동
            BottomNavigationBarItem(
              icon: FaIcon(
                chatNav == ChatNavigationItem.menu
                    ? FontAwesomeIcons.solidBars
                    : FontAwesomeIcons.thinBars,
              ),
              label: Lo.of(context)!.menu,
            ),
          ],
          currentIndex: _getChatNavIndex(chatNav),
          onTap: (index) => _handleChatNavTap(context, index),
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
        ),
      ),
    );
  }

  /// Get the current index for chat navigation bar
  /// 채팅 네비게이션 바의 현재 인덱스 반환
  int _getChatNavIndex(ChatNavigationItem item) {
    switch (item) {
      case ChatNavigationItem.home:
        return 0;
      case ChatNavigationItem.forum:
        return 1;
      case ChatNavigationItem.adminChat:
        return 2;
      case ChatNavigationItem.singleChat:
        return 3;
      case ChatNavigationItem.menu:
        return 4;
    }
  }

  /// Handle chat navigation bar tap events
  /// 채팅 네비게이션 바 탭 이벤트 처리
  void _handleChatNavTap(BuildContext context, int index) {
    final navState = NavigationState.of(context, listen: false);

    // Log screen view to Firebase Analytics
    // Firebase Analytics에 화면 조회 로깅
    FirebaseAnalytics.instance.logScreenView(
      screenName: 'chat_nav_${ChatNavigationItem.values[index].name}',
    );

    switch (index) {
      case 0:
        // Home - Navigate to main home screen and restore default navigation bar
        // 홈 - 메인 홈 화면으로 이동하고 기본 네비게이션 바 복원
        navState.update(
          homeNav: HomeNavigationItem.home,
          chatNav: ChatNavigationItem.singleChat,
        );
        break;

      case 1:
        // Forum - Navigate to forum screen and restore default navigation bar
        // 게시판 - 게시판 화면으로 이동하고 기본 네비게이션 바 복원
        navState.update(
          homeNav: HomeNavigationItem.forum,
          chatNav: ChatNavigationItem.singleChat,
        );
        break;

      case 2:
        // Admin Chat - Enter admin's 1:1 chat room directly
        // 운영자채팅 - 운영자와 1:1 채팅방 바로 입장
        navState.update(chatNav: ChatNavigationItem.adminChat);
        ChatRoomScreen.push(context, UserService.instance.adminUserUid);
        break;

      case 3:
        // 1:1 Chat - Show single chat list (stay on chat screen)
        // 1:1채팅 - 1:1 채팅 목록 표시 (채팅 화면 유지)

        // Play notification sound when there are unread messages
        // 읽지 않은 메시지가 있으면 알림음 재생
        if (UserService.instance.unreadSingleCount > 0) {
          ChatSoundService.instance.playReceiveSound();
        }

        navState.update(
          chatNav: ChatNavigationItem.singleChat,
          roomOrder: RoomOrder.singleOrder,
        );
        break;

      case 4:
        // Menu - Navigate to menu screen and restore default navigation bar
        // 메뉴 - 메뉴 화면으로 이동하고 기본 네비게이션 바 복원
        navState.update(
          homeNav: HomeNavigationItem.menu,
          chatNav: ChatNavigationItem.singleChat,
        );
        break;
    }
  }
}
