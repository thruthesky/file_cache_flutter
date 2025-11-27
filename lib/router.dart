import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/screens/about/about.screen.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.list.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/settings/language.screen.dart';
import 'package:philgo/screens/theme/theme.preview.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.update.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/screens/user/user.activity.screen.dart';
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
        if (state.extra == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(HomeScreen.routeName);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        Post post;
        if (state.extra is Post) {
          post = state.extra as Post;
        } else {
          final extraMap = state.extra as Map<String, dynamic>;
          post = Post.fromJson(extraMap);
        }
        return PostViewScreen(post: post);
      },
    ),
    GoRoute(
      path: CompanyViewScreen.routeName,
      name: CompanyViewScreen.routeName,
      builder: (context, state) {
        int companyIdx = 0;
        if (state.extra is int) {
          companyIdx = state.extra as int;
        }

        debugLog('🔍 CompanyViewScreen: Received companyIdx=$companyIdx');

        return CompanyViewScreen(companyIdx: companyIdx);
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
      path: UserActivityScreen.routeName,
      name: UserActivityScreen.routeName,
      builder: (context, state) {
        return UserActivityScreen(uid: '');
      },
    ),
    GoRoute(
      path: CompanyListScreen.routeName,
      name: CompanyListScreen.routeName,
      builder: (context, state) {
        return const CompanyListScreen();
      },
    ),
    GoRoute(
      path: CompanyFormScreen.routeName,
      name: CompanyFormScreen.routeName,
      builder: (context, state) {
        // Get company from extra parameter (for update mode)
        Company? company;
        if (state.extra is Company) {
          company = state.extra as Company;
        }

        return CompanyFormScreen(company: company);
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
    GoRoute(
      path: AppGuideScreen.routeName,
      name: AppGuideScreen.routeName,
      builder: (context, state) => const AppGuideScreen(),
    ),
    GoRoute(
      path: AccountWithdrawalScreen.routeName,
      name: AccountWithdrawalScreen.routeName,
      builder: (context, state) => const AccountWithdrawalScreen(),
    ),
    GoRoute(
      path: ThemePreviewScreen.routeName,
      name: ThemePreviewScreen.routeName,
      builder: (context, state) => const ThemePreviewScreen(),
    ),
    GoRoute(
      path: LanguageScreen.routeName,
      name: LanguageScreen.routeName,
      builder: (context, state) => const LanguageScreen(),
    ),
  ],
);
