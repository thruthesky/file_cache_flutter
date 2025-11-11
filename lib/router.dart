import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/screens/about/about.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// 라우트 변경을 추적하고 로그를 출력하는 Observer
class RouteLoggingObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      // developer.log(
      //   '🔀 Go_ROUTE: Push: ${route.settings.name} INTO',
      //   name: 'Router',
      // );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name != null) {
      developer.log(
        '↩️ Go_ROUTE: Pop: ${previousRoute?.settings.name} BACK TO',
        name: 'Router',
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name != null) {
      // developer.log(
      //   '🔄 Go_ROUTE: Replace: ${oldRoute?.settings.name ?? 'unknown'} → ${newRoute?.settings.name} REPLACE TO',
      //   name: 'Router',
      // );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route.settings.name != null) {
      // developer.log(
      //   '🗑️ Go_ROUTE: Remove: ${route.settings.name} REMOVE',
      //   name: 'Router',
      // );
    }
  }
}

final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  observers: [RouteLoggingObserver()],
  errorBuilder: (context, state) {
    developer.log('❗ Go_ROUTE: Error: ${state.error}', name: 'Router');
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableText(
                state.error.toString(),
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () => context.go(HomeScreen.routeName),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  },
  redirect: (context, state) {
    developer.log(
      '🔍 Go_ROUTE: Redirect 체크: path=${state.fullPath}, name=${state.name} matchedLocation=${state.matchedLocation} uri=${state.uri} uri.path=${state.uri.path} uri.query=${state.uri.query}',
      name: 'Router',
    );

    Map<String, String> queryParameters = state.uri.queryParameters;

    if (state.matchedLocation.contains('/post/list.php')) {
      NavigationState.of(
        context,
        listen: false,
      ).setHomeNavigation(HomeNavigationItem.forum);

      if (queryParameters.containsKey('post_id') &&
          queryParameters['post_id']!.isNotEmpty) {
        String postId = queryParameters['post_id']!;
        String? category = queryParameters['category'];
        final postCategory = PhilGoAppConfig.getCategories().firstWhere(
          (cat) => cat.postId == postId && cat.category == category,
          orElse: () => PostCategoryItem(postId: '', category: null),
        );
        if (postCategory.postId.isNotEmpty) {
          ForumState.of(
            context,
            listen: false,
          ).setHomePostCategory(postCategory);
        }
      }

      return HomeScreen.routeName;
    }

    if (state.matchedLocation.contains('/post/view.php') &&
        queryParameters.containsKey('idx') &&
        queryParameters['idx']!.isNotEmpty) {
      final post = Post.fromJson({'idx': int.parse(queryParameters['idx']!)});
      NavigationState.of(context, listen: false).setData({'post': post});
      return PostViewScreen.routeName;
    }

    if (state.matchedLocation.contains('/chat/rooms.php')) {
      return ChatRoomScreen.routeName.replaceFirst(
        ':id',
        state.uri.queryParameters['id'] ?? '',
      );
    }

    if (state.fullPath == ChatRoomScreen.routeName) {
      Globals.screenName = 'ChatRoomScreen';
      Globals.screenId = state.pathParameters['id'] ?? '';
    }

    developer.log('Globals: ${Globals.screenName}, ${Globals.screenId}');

    if (state.fullPath == EntryScreen.routeName) {
      return null;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return EntryScreen.routeName;
      } else {
        return null;
      }
    }
  },
  routes: [
    GoRoute(
      path: HomeScreen.routeName,
      name: HomeScreen.routeName,
      builder: (context, state) {
        developer.log('🔍 Go_ROUTE: HomeScreen');
        return const HomeScreen();
      },
    ),

    GoRoute(
      path: AboutScreen.routeName,
      name: AboutScreen.routeName,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: EntryScreen.routeName,
      name: EntryScreen.routeName,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const EntryScreen(),
      ),
    ),
    GoRoute(
      path: ChatRoomScreen.routeName,
      name: ChatRoomScreen.routeName,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatRoomScreen(
          key: UniqueKey(),
          id: id,
          // enableBuyAndSell: id == '-OUnSfg19eHjBMn8iArt',
          homeRouteName: HomeScreen.routeName,
        );
      },
    ),
    GoRoute(
      path: CreateChatRoomScreen.routeName,
      name: CreateChatRoomScreen.routeName,
      builder: (context, state) {
        return CreateChatRoomScreen(
          onRoomCreated: (roomId) {
            ChatRoomScreen.push(context, roomId);
          },
        );
      },
    ),
    GoRoute(
      path: PostViewScreen.routeName,
      name: PostViewScreen.routeName,
      builder: (context, state) {
        // 안전한 타입 체크: Post 객체 직접 전달 또는 Map으로 전달 모두 지원
        Post? post;
        if (state.extra is Post) {
          // Post 객체가 직접 전달된 경우 (일반적인 경우)
          post = state.extra as Post;
        } else if (state.extra is Map<String, dynamic>) {
          // Map으로 전달된 경우 (예: {'post': post})
          final extraMap = state.extra as Map<String, dynamic>;
          post = extraMap['post'] as Post?;
        }

        // NavigationState fallback (웹 URL 접근 시)
        if (post == null) {
          final data = NavigationState.of(context, listen: false).data;
          if (data is Map<String, dynamic> && data['post'] != null) {
            post = data['post'] as Post?;
          }
        }

        // post가 여전히 null인 경우 (Toggle Select Widget Mode 등)
        // 홈 화면으로 리다이렉트하여 에러 방지
        if (post == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(HomeScreen.routeName);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PostViewScreen(post: post);
      },
    ),
    GoRoute(
      path: PostCreateScreen.routeName,
      name: PostCreateScreen.routeName,
      builder: (context, state) => const PostCreateScreen(),
    ),
    GoRoute(
      path: PostUpdateScreen.routeName,
      name: PostUpdateScreen.routeName,
      builder: (context, state) {
        Post? post = (state.extra as Map<String, dynamic>)['post'] as Post?;
        return PostUpdateScreen(post: post!);
      },
    ),
    GoRoute(
      path: ProfileEditScreen.routeName,
      name: ProfileEditScreen.routeName,
      builder: (context, state) => const ProfileEditScreen(),
    ),
    GoRoute(
      path: ProfileViewScreen.routeName,
      name: ProfileViewScreen.routeName,
      builder: (context, state) {
        final extraMap = state.extra as Map<String, dynamic>;
        return ProfileViewScreen(
          firebaseUid: extraMap['firebaseUid'] as String,
          nickname: extraMap['nickname'] as String?,
          photoUrl: extraMap['photoUrl'] as String?,
        );
      },
    ),
    GoRoute(
      path: CompanyViewScreen.routeName,
      name: CompanyViewScreen.routeName,
      builder: (context, state) {
        return const CompanyViewScreen();
      },
    ),
    GoRoute(
      path: WebViewScreen.routeName,
      name: WebViewScreen.routeName,
      builder: (context, state) => WebViewScreen(
        url: (state.extra as Map<String, dynamic>)['url'],
        title: (state.extra as Map<String, dynamic>)['title'] ?? '',
      ),
    ),
  ],
);
