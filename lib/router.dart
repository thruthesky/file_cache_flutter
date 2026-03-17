import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.screen.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/point/point_history.screen.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';

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
    GoRoute(
      path: UserEditScreen.routeName,
      name: UserEditScreen.routeName,
      builder: (context, state) => const UserEditScreen(),
    ),
    GoRoute(
      path: PostViewScreen.routeName,
      name: PostViewScreen.routeName,
      builder: (context, state) {
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        final postId = state.uri.queryParameters['post_id'] ?? '';
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        // 빈 Post 객체로 초기화하고, PostViewScreen의 initState에서 전체 데이터를 로드
        return PostViewScreen(
          post: Post(
            idx: idx,
            idxMember: 0,
            postId: postId,
            subject: '',
            content: '',
            stamp: now,
            stampUpdate: now,
            depth: 0,
            noOfComment: 0,
            noOfView: 0,
            good: 0,
            category: '',
            earnedPoint: 0,
            secret: '',
            checked: '',
            blind: '',
            hasImage: '',
            hasVideo: '',
          ),
        );
      },
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
      path: PointHistoryScreen.routeName,
      name: PointHistoryScreen.routeName,
      builder: (context, state) => const PointHistoryScreen(),
    ),
    GoRoute(
      path: OtherUserScreen.routeName,
      name: OtherUserScreen.routeName,
      builder: (context, state) {
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '');
        final firebaseUid = state.uri.queryParameters['firebase_uid'];
        return OtherUserScreen(idx: idx, firebaseUid: firebaseUid);
      },
    ),
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
