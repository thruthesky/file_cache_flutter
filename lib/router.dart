import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/app/app.screen.dart';
import 'package:philgo/app_info/app_info.screen.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/deeplink/deeplink.service.dart';
import 'package:philgo/event/company_event.screen.dart';
import 'package:philgo/event/event_coupon.screen.dart';
import 'package:philgo/event/event_entry.screen.dart';
import 'package:philgo/guide/app_guide.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/update/post.update.screen.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/account_withdrawal.screen.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/point/point_history.screen.dart';
import 'package:philgo/bookmark/bookmark.screen.dart';
import 'package:philgo/user/other_user/other_user.screen.dart';
import 'package:philgo/search/search.screen.dart';
import 'package:philgo/version/version.screen.dart';
import 'package:philgo/info/essential_info.screen.dart';
import 'package:philgo/info/info_view.screen.dart';
import 'package:philgo/weather/weather.screen.dart';
import 'package:philgo/currency/currency.screen.dart';
import 'package:philgo/webview/webview.screen.dart';
import 'package:philgo/company/qr/company.qr_code.screen.dart';
import 'package:philgo/company/qr/company.qr_code_scanned.screen.dart';
import 'package:philgo/company/review/company.visit_review.screen.dart';
import 'package:philgo/company/review/company.revisit_point_result.screen.dart';
import 'package:philgo/company/review/company.review_point_result.screen.dart';
import 'package:philgo/event/qr_scanner.screen.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey();
BuildContext get globalContext => globalNavigatorKey.currentContext!;

/// GoRouter
final router = GoRouter(
  navigatorKey: globalNavigatorKey,
  redirect: (context, state) {
    // 리다이렉트가 필요 없는 일반 앱 내부 경로는 건너뜀 (무한 루프 방지)
    if (!isDeepLinkUrl(state.uri)) return null;

    final result = parsePhilgoUrl(state.uri.toString());
    if (result == null) return null;

    // 게시글 보기: /post/view?idx=123 또는 /post/view.php?idx=123
    if (result.isPostView && result.idx != null) {
      return '${PostViewScreen.routeName}?idx=${result.idx}&post_id=${result.postId ?? ''}';
    }

    // 게시판 목록 → 포럼 탭으로 이동
    if (result.isPostList && result.postId != null) {
      final navState = context.read<AppNavigationState>();
      navState.openForumScreen(
        postId: result.postId,
        category: result.category,
      );
      return AppScreen.routeName;
    }

    // // 채팅방: /chat/index.php?id=xxx
    // if (result.isChatRoom && result.chatRoomId != null) {
    //   return ChatRoomScreen.routeName.replaceFirst(':id', result.chatRoomId!);
    // }

    // 업소록 보기: /company/view?idx=5422 또는 /company/view.php?idx=1025
    if (result.isCompanyView && result.idx != null) {
      return '${CompanyViewScreen.routeName}?idx=${result.idx}';
    }

    // 업소록 목록: /company → 업소록 탭으로 이동
    if (result.isCompanyList) {
      final navState = context.read<AppNavigationState>();
      navState.openCompanyScreen();
      return AppScreen.routeName;
    }

    // 홈
    if (result.isHome) return AppScreen.routeName;

    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: Text('페이지를 찾을 수 없습니다'.tr())),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('요청한 페이지를 찾을 수 없습니다'.tr()),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go(AppScreen.routeName),
            child: Text('홈으로'.tr()),
          ),
        ],
      ),
    ),
  ),
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
        // 1. extra에서 CompanyModel 가져오기 (일반 네비게이션)
        if (state.extra is CompanyModel) {
          return CompanyViewScreen(company: state.extra as CompanyModel);
        }
        // 2. query parameters fallback (딥링크)
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        return CompanyViewScreen(company: CompanyModel.minimal(idx: idx));
      },
    ),
    GoRoute(
      path: ChatRoomScreen.routeName,
      name: ChatRoomScreen.routeName,
      builder: (context, state) {
        String id = state.pathParameters['id']!;
        if (id == '') {
          id = state.uri.queryParameters['uid'] ?? '';
        }

        return ChatRoomScreen(
          key: UniqueKey(),
          id: id,
          // homeRouteName: AppScreen.routeName,
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
      path: SearchScreen.routeName,
      name: SearchScreen.routeName,
      builder: (context, state) {
        final searchTerm = state.extra as String? ?? '';
        return SearchScreen(searchTerm: searchTerm);
      },
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
    GoRoute(
      path: AppGuideScreen.routeName,
      name: AppGuideScreen.routeName,
      builder: (context, state) => const AppGuideScreen(),
    ),
    GoRoute(
      path: WeatherScreen.routeName,
      name: WeatherScreen.routeName,
      builder: (context, state) => const WeatherScreen(),
    ),
    GoRoute(
      path: ExchangeRateScreen.routeName,
      name: ExchangeRateScreen.routeName,
      builder: (context, state) => const ExchangeRateScreen(),
    ),
    GoRoute(
      path: CompanyQrCodeScreen.routeName,
      name: CompanyQrCodeScreen.routeName,
      builder: (context, state) {
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        return CompanyQrCodeScreen(companyIdx: idx);
      },
    ),
    GoRoute(
      path: QrScannerScreen.routeName,
      name: QrScannerScreen.routeName,
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: CompanyQrCodeScannedScreen.routeName,
      name: CompanyQrCodeScannedScreen.routeName,
      builder: (context, state) {
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        final code = state.uri.queryParameters['code'] ?? '';
        return CompanyQrCodeScannedScreen(idx: idx, code: code);
      },
    ),
    GoRoute(
      path: CompanyVisitReviewScreen.routeName,
      name: CompanyVisitReviewScreen.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CompanyVisitReviewScreen(
          usageIdx: extra['usageIdx'] as int,
          idxCompany: extra['idxCompany'] as int,
          companyName: extra['companyName'] as String,
        );
      },
    ),
    GoRoute(
      path: CompanyRevisitPointResultScreen.routeName,
      name: CompanyRevisitPointResultScreen.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CompanyRevisitPointResultScreen(
          usageIdx: extra['usageIdx'] as int,
          idxCompany: extra['idxCompany'] as int,
          companyName: extra['companyName'] as String,
        );
      },
    ),
    GoRoute(
      path: CompanyReviewPointResultScreen.routeName,
      name: CompanyReviewPointResultScreen.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return CompanyReviewPointResultScreen(
          rewardPoints: extra['rewardPoints'] as int,
          pointBefore: extra['pointBefore'] as int,
          pointAfter: extra['pointAfter'] as int,
          idxCompany: extra['idxCompany'] as int,
        );
      },
    ),
    GoRoute(
      path: AccountWithdrawalScreen.routeName,
      name: AccountWithdrawalScreen.routeName,
      builder: (context, state) => const AccountWithdrawalScreen(),
    ),
    GoRoute(
      path: EssentialInfoScreen.routeName,
      name: EssentialInfoScreen.routeName,
      builder: (context, state) => const EssentialInfoScreen(),
    ),
    GoRoute(
      path: InfoViewScreen.routeName,
      name: InfoViewScreen.routeName,
      builder: (context, state) {
        final accessCode = state.uri.queryParameters['access_code'] ?? '';
        final title = state.extra as String?;
        return InfoViewScreen(accessCode: accessCode, title: title);
      },
    ),
  ],
);
