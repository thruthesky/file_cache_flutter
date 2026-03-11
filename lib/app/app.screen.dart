import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/chat/chat.screen.dart';
import 'package:philgo/company/company.screen.dart';
import 'package:philgo/home/home.screen.dart';
import 'package:philgo/menu/menu.screen.dart';
import 'package:philgo/post/list/post.list.screen.dart';
import 'package:provider/provider.dart';

class AppScreen extends StatefulWidget {
  static const String routeName = '/';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<AppNavigationState, int>(
        selector: (_, state) => state.currentIndex,
        builder: (context, currentIndex, child) {
          return IndexedStack(
            index: currentIndex,
            children: const [
              HomeScreen(),
              PostListScreen(),

              ChatScreen(),

              CompanyScreen(),
              MenuScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: Selector<AppNavigationState, int>(
        selector: (_, state) => state.currentIndex,
        builder: (context, currentIndex, child) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: (index) {
              switch (index) {
                case 0:
                  AppNavigationState.of(context).openHomeScreen();
                  break;
                case 1:
                  AppNavigationState.of(context).openPostListScreen();
                  break;
                case 2:
                  AppNavigationState.of(context).openChatScreen();
                  break;
                case 3:
                  AppNavigationState.of(context).openCompanyScreen();
                  break;
                case 4:
                  AppNavigationState.of(context).openMenuScreen();
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'nav.home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.list),
                label: 'nav.forum'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat),
                label: 'nav.chat'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.business),
                label: 'nav.company'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu),
                label: 'nav.menu'.tr(),
              ),
            ],
          );
        },
      ),
    );
  }
}
