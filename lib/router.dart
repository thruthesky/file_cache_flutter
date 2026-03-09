import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/home/home.screen.dart';
import 'package:philgo/menu/menu.screen.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// GoRouter
final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      name: HomeScreen.routeName,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: MenuScreen.routeName,
      name: MenuScreen.routeName,
      builder: (context, state) => const MenuScreen(),
    ),
    // GoRoute(
    //   path: EntryScreen.routeName,
    //   name: EntryScreen.routeName,
    //   pageBuilder: (context, state) => NoTransitionPage<void>(
    //     key: state.pageKey,
    //     child: const EntryScreen(),
    //   ),
    // ),
  ],
);
