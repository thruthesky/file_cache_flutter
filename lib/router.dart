import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/company/company.list.screen.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/guide/must_read.screen.dart';
import 'package:philgo/screens/version/version.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/post/quick_post.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/screens/user/user.activity.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo_api/philgo_api.dart';

import 'package:firebase_analytics/firebase_analytics.dart';

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
    // developer.log('❗ Go_ROUTE: Error: ${state.error}', name: 'Router');
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
    final uri = state.uri.toString();
    final url = parsePhilgoUrl(uri);

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    /// Post view page DeepLink
    if (url?.isPostView == true) {
      NavigationState.of(context, listen: false).post = Post.fromJson({
        'idx': url?.idx,
      });

      analytics.logScreenView(
        screenName: '$uri/${(url?.idx.toString() ?? '')}',
      );
      return PostViewScreen.routeName;
    }

    if (state.fullPath == PostViewScreen.routeName) {
      analytics.logScreenView(
        screenName: state.extra != null
            ? '$uri/${(state.extra as Post).idx}'
            : '$uri/unknown',
      );
      return PostViewScreen.routeName;
    }

    /// Forum home. Post list page DeepLink
    if (url?.isPostList == true) {
      NavigationState.of(
        context,
        listen: false,
      ).setHomeNavigation(HomeNavigationItem.forum);
      NavigationState.of(context, listen: false).initialPostId = url?.postId;
      analytics.logScreenView(screenName: 'forum/${(url?.postId ?? '')}');
      return HomeScreen.routeName;
    }

    /// Chat room DeepLink
    /// 채팅방 딥링크 처리 (/chat/room.php 또는 /chat/rooms.php)
    if (url?.isChatRoom == true && url?.chatRoomId != null) {
      final routeName = ChatRoomScreen.routeName.replaceFirst(
        ':id',
        url!.chatRoomId!,
      );
      analytics.logScreenView(screenName: routeName);
      return routeName;
    }

    ///
    if (state.fullPath == ChatRoomScreen.routeName) {
      Globals.screenName = 'ChatRoomScreen';
      Globals.screenId = state.pathParameters['id'] ?? '';

      analytics.logScreenView(
        screenName: ChatRoomScreen.routeName.replaceFirst(
          ':id',
          Globals.screenId,
        ),
      );
    }

    /// Authentication check
    if (state.fullPath == EntryScreen.routeName) {
      return null;
    } else {
      /// 인증된 사용자인지 확인
      /// Check if the user is authenticated
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
        // developer.log('🔍 Go_ROUTE: HomeScreen');
        return const HomeScreen();
      },
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
        Post? post;

        // 1. state.extra에서 Post 가져오기 (일반 네비게이션)
        // Get Post from state.extra (normal navigation)
        if (state.extra != null) {
          if (state.extra is Post) {
            post = state.extra as Post;
          } else {
            final extraMap = state.extra as Map<String, dynamic>;
            post = Post.fromJson(extraMap);
          }
        }

        // 2. NavigationState에서 Post 가져오기 (딥링크에서 redirect로 온 경우)
        // Get Post from NavigationState (when coming from deeplink redirect)
        if (post == null) {
          final navState = NavigationState.of(context, listen: false);
          if (navState.post != null) {
            post = navState.post;
            // 사용 후 초기화하여 다음 네비게이션에 영향 주지 않도록 함
            // Clear after use to prevent affecting next navigation
            navState.post = null;
            developer.log(
              '📱 Go_ROUTE: PostViewScreen - 딥링크에서 Post 로드: idx=${post?.idx}',
              name: 'Router',
            );
          }
        }

        // 3. Post가 없으면 홈으로 이동
        // Navigate to home if no Post available
        if (post == null) {
          developer.log(
            '⚠️ Go_ROUTE: PostViewScreen - Post 없음, 홈으로 이동',
            name: 'Router',
          );
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;

        /// postId와 category를 extra에서 추출하여 PostCreateScreen에 전달
        /// Extract postId and category from extra and pass to PostCreateScreen
        return PostCreateScreen(
          postId: extra['postId'] as String,
          category: extra['category'] as String?,
          xFiles: extra['xFiles'] as List<XFile>?,
          content: extra['content'] as String?,
        );
      },
    ),

    /// 빠른 글쓰기 화면 (Quick Post Screen)
    /// 홈 화면의 가짜 입력 박스를 클릭하면 이 화면으로 이동합니다.
    /// Navigate to this screen when the fake input box on home is tapped.
    GoRoute(
      path: QuickPostScreen.routeName,
      name: QuickPostScreen.routeName,
      builder: (context, state) => const QuickPostScreen(),
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
          userIdx: extraMap['idxMember'] as int?,
          firebaseUid: extraMap['firebaseUid'] as String?,
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
      path: VersionScreen.routeName,
      name: VersionScreen.routeName,
      builder: (context, state) => const VersionScreen(),
    ),
    GoRoute(
      path: WeatherScreen.routeName,
      name: WeatherScreen.routeName,
      builder: (context, state) => const WeatherScreen(),
    ),
    GoRoute(
      path: MustReadScreen.routeName,
      name: MustReadScreen.routeName,
      builder: (context, state) => const MustReadScreen(),
    ),
  ],
);
