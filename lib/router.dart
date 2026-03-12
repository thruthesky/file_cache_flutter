import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.screen.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// GoRouter
final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  routes: [
    GoRoute(
      path: AppScreen.routeName,
      name: AppScreen.routeName,
      builder: (context, state) => const AppScreen(),
    ),
    GoRoute(
      path: UserLoginScreen.routeName,
      name: UserLoginScreen.routeName,
      builder: (context, state) => const UserLoginScreen(),
    ),

    // GoRoute(
    //   path: AppScreen.routeName,
    //   name: AppScreen.routeName,
    //   builder: (context, state) => const AppScreen(),
    // ),
    // GoRoute(
    //   path: MenuScreen.routeName,
    //   name: MenuScreen.routeName,
    //   builder: (context, state) => const MenuScreen(),
    // ),
    // GoRoute(
    //   path: EntryScreen.routeName,
    //   name: EntryScreen.routeName,
    //   pageBuilder: (context, state) => NoTransitionPage<void>(
    //     key: state.pageKey,
    //     child: const EntryScreen(),
    //   ),
    // ),
    GoRoute(
      path: ChatRoomScreen.routeName,
      name: ChatRoomScreen.routeName,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatRoomScreen(
          key: UniqueKey(),
          id: id,
          homeRouteName: AppScreen.routeName,
        );
      },
    ),
  ],
);
