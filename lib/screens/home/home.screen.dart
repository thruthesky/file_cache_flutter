import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/sections/main.home.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_api/philgo_api.dart';
import 'sections/chat.home.dart';
import 'sections/forum.home.dart';
import 'sections/company.home.dart';
import 'sections/menu.home.dart';
import '../../l10n/app_localizations.dart';

// 홈 스크린
// 사용자가 로그인 후, 보이게되는 첫번째 스크린. 사실 로그인 사용자의 메인 스크린, 첫 스크린, 홈 스크린이다.
// 여기서 필요한 초기화를 한다.
// - 로그인 사용자의 정보를 가져온다.
class HomeScreen extends StatefulWidget {
  static const String routeName = '/';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Timer(const Duration(milliseconds: 500), () {
    //   ProfileScreen.push(context);
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userLogin();
    });
  }

  void userLogin() async {
    final user = await philgoApiUserVerify();
    if (mounted == true) {
      AppState.of(context, listen: false).setUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final HomeNavigationItem selectedItem = NavigationState.of(context).homeNav;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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

        /// 하단 네비게이션 바 (Bottom Navigation Bar)
        /// 항상 표시됨 (Always visible)
        bottomNavigationBar: Container(
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
                            return Badge(
                              label: Text(unreadSingleCount.toString()),
                            );
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
                NavigationState.of(
                  context,
                  listen: false,
                ).setHomeNavigation(HomeNavigationItem.values[index]);
              },
              type: BottomNavigationBarType.fixed,
              iconSize: 28,
            ),
          ),
        ),
      ),
    );
  }
}
