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
              // Handle navigation based on the tapped index
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
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Forum'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Company',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
            ],
          );
        },
      ),
    );
  }
}
