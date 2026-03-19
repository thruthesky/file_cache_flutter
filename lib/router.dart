import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.screen.dart';
import 'package:philgo/app_info/app_info.screen.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/event/company_event.screen.dart';
import 'package:philgo/event/event_coupon.screen.dart';
import 'package:philgo/event/event_entry.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/point/point_history.screen.dart';
import 'package:philgo/bookmark/bookmark.screen.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/version/version.screen.dart';
import 'package:philgo/webview/webview.screen.dart';

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
        // 1. extra에서 Post 가져오기 (일반 네비게이션)
        if (state.extra is Post) {
          return PostViewScreen(post: state.extra as Post);
        }
        // 2. query parameters fallback (딥링크 등)
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        final postId = state.uri.queryParameters['post_id'] ?? '';
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
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
      path: PostUpdateScreen.routeName,
      name: PostUpdateScreen.routeName,
      builder: (context, state) {
        final post = state.extra as Post;
        return PostUpdateScreen(post: post);
      },
    ),
    GoRoute(
      path: PointHistoryScreen.routeName,
      name: PointHistoryScreen.routeName,
      builder: (context, state) => const PointHistoryScreen(),
    ),
    GoRoute(
      path: BookmarkScreen.routeName,
      name: BookmarkScreen.routeName,
      builder: (context, state) => const BookmarkScreen(),
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
      path: CompanyEditScreen.routeName,
      name: CompanyEditScreen.routeName,
      builder: (context, state) {
        final company = state.extra as CompanyModel;
        return CompanyEditScreen(company: company);
      },
    ),
    GoRoute(
      path: CompanyViewScreen.routeName,
      name: CompanyViewScreen.routeName,
      builder: (context, state) {
        final company = state.extra as CompanyModel;
        return CompanyViewScreen(company: company);
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
    GoRoute(
      path: WebViewScreen.routeName,
      name: WebViewScreen.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        return WebViewScreen(url: extra['url']!, title: extra['title']!);
      },
    ),
    GoRoute(
      path: CompanyEventScreen.routeName,
      name: CompanyEventScreen.routeName,
      builder: (context, state) => const CompanyEventScreen(),
    ),
    GoRoute(
      path: EventEntryScreen.routeName,
      name: EventEntryScreen.routeName,
      builder: (context, state) => const EventEntryScreen(),
    ),
    GoRoute(
      path: EventCouponScreen.routeName,
      name: EventCouponScreen.routeName,
      builder: (context, state) => const EventCouponScreen(),
    ),
    GoRoute(
      path: AppInfoScreen.routeName,
      name: AppInfoScreen.routeName,
      builder: (context, state) => const AppInfoScreen(),
    ),
    GoRoute(
      path: VersionScreen.routeName,
      name: VersionScreen.routeName,
      builder: (context, state) => const VersionScreen(),
    ),
  ],
);
