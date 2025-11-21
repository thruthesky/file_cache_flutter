import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/sections/main.home.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
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
    return Scaffold(
      body: IndexedStack(
        index: selectedItem.index,
        children: const [
          MainHome(), // 홈
          ChatHome(), // 채팅
          ForumHome(), // 게시판
          CompanyHome(), // 업소록
          MenuHome(), // 메뉴
        ],
      ),
      // BottomNavigationBar 추가
      bottomNavigationBar: BottomNavigationBar(
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
              selectedItem == HomeNavigationItem.chat
                  ? FontAwesomeIcons.solidCommentDots
                  : FontAwesomeIcons.thinCommentDots,
            ),
            label: Lo.of(context)!.chat,
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
            icon: FaIcon(
              selectedItem == HomeNavigationItem.menu
                  ? FontAwesomeIcons.solidUser
                  : FontAwesomeIcons.thinUser,
            ),
            label: 'Menu',
          ),
        ],
        currentIndex: selectedItem.index,
        onTap: (index) {
          NavigationState.of(
            context,
            listen: false,
          ).setHomeNavigation(HomeNavigationItem.values[index]);
        },
        type: BottomNavigationBarType.fixed, // 5개 이상의 항목을 사용할 때 필요
        selectedItemColor: Theme.of(context).primaryColor, // 선택된 항목 색상
        unselectedItemColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.6),
        iconSize: 28,
      ),
    );
  }
}
