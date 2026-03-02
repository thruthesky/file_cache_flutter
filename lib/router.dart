import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/company/company.list.screen.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.qr_code.screen.dart';
import 'package:philgo/screens/company/company.qr_code_scanned.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/guide/must_read.screen.dart';
import 'package:philgo/models/travel_spot.model.dart';
import 'package:philgo/screens/guide/travel_spot.view.screen.dart';
import 'package:philgo/screens/guide/travel_spots.screen.dart';
import 'package:philgo/screens/info/emergency/embassy.screen.dart';
import 'package:philgo/screens/info/emergency/hospital.screen.dart';
import 'package:philgo/screens/info/emergency/korean_association.screen.dart';
import 'package:philgo/screens/info/emergency/police_station.screen.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/info/delivery/food_delivery.screen.dart';
import 'package:philgo/screens/info/delivery/baedal_k.screen.dart';
import 'package:philgo/screens/info/immigration/e_travel.screen.dart';
import 'package:philgo/screens/info/immigration/travel_visa.screen.dart';
import 'package:philgo/screens/info/immigration/working_visa.screen.dart';
import 'package:philgo/screens/info/immigration/retirement_visa.screen.dart';
import 'package:philgo/screens/info/transportation/grab_taxi.screen.dart';
import 'package:philgo/screens/info/transportation/regular_taxi.screen.dart';
import 'package:philgo/screens/info/transportation/express_bus.screen.dart';
import 'package:philgo/screens/info/housing/monthly_rent.screen.dart';
import 'package:philgo/screens/info/housing/airbnb.screen.dart';
import 'package:philgo/screens/info/housing/hotel.screen.dart';
import 'package:philgo/screens/info/car/car_purchase.screen.dart';
import 'package:philgo/screens/info/car/car_insurance.screen.dart';
import 'package:philgo/screens/info/car/car_rental.screen.dart';
import 'package:philgo/screens/info/car/or_renewal.screen.dart';
import 'package:philgo/screens/info/residence/bgc.screen.dart';
import 'package:philgo/screens/info/residence/ortigas.screen.dart';
import 'package:philgo/screens/info/residence/alabang.screen.dart';
import 'package:philgo/screens/info/holiday/holiday.screen.dart';
import 'package:philgo/screens/info/travel_destination/manila.screen.dart';
import 'package:philgo/screens/info/travel_destination/cebu.screen.dart';
import 'package:philgo/screens/info/travel_destination/subic.screen.dart';
import 'package:philgo/screens/info/travel_destination/bohol.screen.dart';
import 'package:philgo/screens/info/travel_destination/boracay.screen.dart';
import 'package:philgo/screens/info/travel_destination/palawan.screen.dart';
import 'package:philgo/screens/info/travel_destination/el_nido.screen.dart';
import 'package:philgo/screens/info/helper/house_helper.screen.dart';
import 'package:philgo/screens/info/helper/driver.screen.dart';
import 'package:philgo/screens/info/helper/tutor.screen.dart';
import 'package:philgo/screens/info/entertainment/golf.screen.dart';
import 'package:philgo/screens/info/entertainment/massage.screen.dart';
import 'package:philgo/screens/info/entertainment/nightlife.screen.dart';
import 'package:philgo/screens/info/entertainment/market_tour.screen.dart';
import 'package:philgo/screens/info/entertainment/seafood.screen.dart';
import 'package:philgo/screens/info/entertainment/restaurant.screen.dart';
import 'package:philgo/screens/info/entertainment/water_sports.screen.dart';
import 'package:philgo/screens/info/entertainment/island_tour.screen.dart';
import 'package:philgo/screens/info/entertainment/festival.screen.dart';
import 'package:philgo/screens/advertisement/advertisement.view.screen.dart';
import 'package:philgo/screens/version/version.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo/screens/user/user.activity.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/screens/event/company_event.screen.dart';
import 'package:philgo/screens/event/event_coupon.screen.dart';
import 'package:philgo/screens/event/event_entry.screen.dart';
import 'package:philgo/screens/event/qr_scanner.screen.dart';
import 'package:philgo/screens/search/search.screen.dart';
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

    /// Authentication check (인증 체크)
    ///
    /// 로그인 없이도 접근 가능한 화면들 (Screens accessible without login):
    /// - EntryScreen: 시작 화면
    /// - ExchangeRateScreen: 환율 정보 (정보성 화면)
    /// - WeatherScreen: 날씨 정보 (정보성 화면)
    /// - EmergencyContactScreen: 긴급 연락처 (정보성 화면)
    /// - EssentialInfoScreen: 필수 정보 (정보성 화면)
    /// - MonthlyLivingScreen: 한달살기 정보 (정보성 화면)
    /// - TravelInfoScreen: 여행 정보 (정보성 화면)
    ///
    /// 이 화면들은 EntryScreen에서 로그인 전에도 접근할 수 있어야 합니다.
    /// These screens should be accessible from EntryScreen before login.
    final publicRoutes = <String>{
      EntryScreen.routeName,
      ExchangeRateScreen.routeName,
      WeatherScreen.routeName,
      EmergencyContactScreen.routeName,
      EssentialInfoScreen.routeName,
      MonthlyLivingScreen.routeName,
      TravelInfoScreen.routeName,
      FoodDeliveryScreen.routeName,
      BaedalKScreen.routeName,
      // Entry 화면 퀵 메뉴 캐러셀에서 접근 가능한 정보성 화면
      MustReadScreen.routeName,
      TravelSpotsScreen.routeName,
      ETravelScreen.routeName,
      TravelVisaScreen.routeName,
      GrabTaxiScreen.routeName,
      MonthlyRentScreen.routeName,
    };

    if (publicRoutes.contains(state.fullPath)) {
      return null;
    } else {
      /// 인증된 사용자인지 확인 -> 로그인한 사용자만 페이지(화면)을 보여준다.
      /// 즉, 로그인을 하지 않았으면, 위의 화면은 보여주고, 그 외의 화면은 로그인을 해야지만 볼 수 있다.
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
          }
        }

        // 3. Post가 없으면 홈으로 이동
        // Navigate to home if no Post available
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

    /// 업소록 보기 페이지
    /// 중요: Deeplink 에 들어오는 값을 지원한다.
    GoRoute(
      path: CompanyViewScreen.routeName,
      name: CompanyViewScreen.routeName,
      builder: (context, state) {
        /// Deeplink 로 값이 들어왔나?
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        if (idx > 0) {
          return HomeScreen(redirect: CompanyViewScreen(companyIdx: idx));
        }

        /// 앱 내에서 페이지 전환인가?
        int companyIdx = 0;
        if (state.extra is int) {
          companyIdx = state.extra as int;
        }
        debugLog('🔍 CompanyViewScreen: Received companyIdx=$companyIdx');

        return CompanyViewScreen(companyIdx: companyIdx);
      },
    ),

    /// Company QR Code Screen - 업소록 QR 코드 화면
    GoRoute(
      path: CompanyQrCodeScreen.routeName,
      name: CompanyQrCodeScreen.routeName,
      builder: (context, state) {
        int companyIdx = 0;
        if (state.extra is int) {
          companyIdx = state.extra as int;
        }
        return CompanyQrCodeScreen(companyIdx: companyIdx);
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
    GoRoute(
      path: TravelSpotsScreen.routeName,
      name: TravelSpotsScreen.routeName,
      builder: (context, state) => const TravelSpotsScreen(),
    ),
    GoRoute(
      path: TravelSpotViewScreen.routeName,
      name: TravelSpotViewScreen.routeName,
      builder: (context, state) {
        final spot = state.extra as TravelSpot;
        return TravelSpotViewScreen(spot: spot);
      },
    ),
    GoRoute(
      path: EmbassyScreen.routeName,
      name: EmbassyScreen.routeName,
      builder: (context, state) => const EmbassyScreen(),
    ),
    GoRoute(
      path: PoliceStationScreen.routeName,
      name: PoliceStationScreen.routeName,
      builder: (context, state) => const PoliceStationScreen(),
    ),
    GoRoute(
      path: HospitalScreen.routeName,
      name: HospitalScreen.routeName,
      builder: (context, state) => const HospitalScreen(),
    ),

    /// 한인회 화면 (Korean Association Screen)
    GoRoute(
      path: KoreanAssociationScreen.routeName,
      name: KoreanAssociationScreen.routeName,
      builder: (context, state) => const KoreanAssociationScreen(),
    ),
    GoRoute(
      path: NoticeScreen.routeName,
      name: NoticeScreen.routeName,
      builder: (context, state) => const NoticeScreen(),
    ),

    /// 환율 정보 화면 (Exchange Rate Screen)
    GoRoute(
      path: ExchangeRateScreen.routeName,
      name: ExchangeRateScreen.routeName,
      builder: (context, state) => const ExchangeRateScreen(),
    ),

    /// 긴급 연락처 화면 (Emergency Contact Screen)
    GoRoute(
      path: EmergencyContactScreen.routeName,
      name: EmergencyContactScreen.routeName,
      builder: (context, state) => const EmergencyContactScreen(),
    ),

    /// 필수 정보 화면 (Essential Info Screen)
    GoRoute(
      path: EssentialInfoScreen.routeName,
      name: EssentialInfoScreen.routeName,
      builder: (context, state) => const EssentialInfoScreen(),
    ),

    /// 한달살기 정보 화면 (Monthly Living Screen)
    GoRoute(
      path: MonthlyLivingScreen.routeName,
      name: MonthlyLivingScreen.routeName,
      builder: (context, state) => const MonthlyLivingScreen(),
    ),

    /// 여행 정보 화면 (Travel Info Screen)
    GoRoute(
      path: TravelInfoScreen.routeName,
      name: TravelInfoScreen.routeName,
      builder: (context, state) => const TravelInfoScreen(),
    ),

    /// 음식 배달 화면 (Food Delivery Screen)
    GoRoute(
      path: FoodDeliveryScreen.routeName,
      name: FoodDeliveryScreen.routeName,
      builder: (context, state) => const FoodDeliveryScreen(),
    ),

    /// 배달K 화면 (Baedal K Screen) - 한국 음식 전문 배달 앱
    GoRoute(
      path: BaedalKScreen.routeName,
      name: BaedalKScreen.routeName,
      builder: (context, state) => const BaedalKScreen(),
    ),

    /// e트래블 화면 (E-Travel Screen)
    GoRoute(
      path: ETravelScreen.routeName,
      name: ETravelScreen.routeName,
      builder: (context, state) => const ETravelScreen(),
    ),

    /// 여행비자 화면 (Travel Visa Screen)
    GoRoute(
      path: TravelVisaScreen.routeName,
      name: TravelVisaScreen.routeName,
      builder: (context, state) => const TravelVisaScreen(),
    ),

    /// 워킹비자 화면 (Working Visa Screen)
    GoRoute(
      path: WorkingVisaScreen.routeName,
      name: WorkingVisaScreen.routeName,
      builder: (context, state) => const WorkingVisaScreen(),
    ),

    /// 은퇴비자 화면 (Retirement Visa Screen)
    GoRoute(
      path: RetirementVisaScreen.routeName,
      name: RetirementVisaScreen.routeName,
      builder: (context, state) => const RetirementVisaScreen(),
    ),

    /// 그랩 택시 화면 (Grab Taxi Screen)
    GoRoute(
      path: GrabTaxiScreen.routeName,
      name: GrabTaxiScreen.routeName,
      builder: (context, state) => const GrabTaxiScreen(),
    ),

    /// 일반 택시 화면 (Regular Taxi Screen)
    GoRoute(
      path: RegularTaxiScreen.routeName,
      name: RegularTaxiScreen.routeName,
      builder: (context, state) => const RegularTaxiScreen(),
    ),

    /// 고속 버스 화면 (Express Bus Screen)
    GoRoute(
      path: ExpressBusScreen.routeName,
      name: ExpressBusScreen.routeName,
      builder: (context, state) => const ExpressBusScreen(),
    ),

    /// 월세 화면 (Monthly Rent Screen)
    GoRoute(
      path: MonthlyRentScreen.routeName,
      name: MonthlyRentScreen.routeName,
      builder: (context, state) => const MonthlyRentScreen(),
    ),

    /// 에어비앤비 화면 (Airbnb Screen)
    GoRoute(
      path: AirbnbScreen.routeName,
      name: AirbnbScreen.routeName,
      builder: (context, state) => const AirbnbScreen(),
    ),

    /// 호텔 화면 (Hotel Screen)
    GoRoute(
      path: HotelScreen.routeName,
      name: HotelScreen.routeName,
      builder: (context, state) => const HotelScreen(),
    ),

    /// 자동차 구매 화면 (Car Purchase Screen)
    GoRoute(
      path: CarPurchaseScreen.routeName,
      name: CarPurchaseScreen.routeName,
      builder: (context, state) => const CarPurchaseScreen(),
    ),

    /// 자동차 보험 화면 (Car Insurance Screen)
    GoRoute(
      path: CarInsuranceScreen.routeName,
      name: CarInsuranceScreen.routeName,
      builder: (context, state) => const CarInsuranceScreen(),
    ),

    /// OR 리뉴얼 화면 (OR Renewal Screen)
    GoRoute(
      path: OrRenewalScreen.routeName,
      name: OrRenewalScreen.routeName,
      builder: (context, state) => const OrRenewalScreen(),
    ),

    /// 자동차 렌트 화면 (Car Rental Screen)
    GoRoute(
      path: CarRentalScreen.routeName,
      name: CarRentalScreen.routeName,
      builder: (context, state) => const CarRentalScreen(),
    ),

    /// BGC 화면 (BGC Screen)
    GoRoute(
      path: BgcScreen.routeName,
      name: BgcScreen.routeName,
      builder: (context, state) => const BgcScreen(),
    ),

    /// 올티가스 화면 (Ortigas Screen)
    GoRoute(
      path: OrtigasScreen.routeName,
      name: OrtigasScreen.routeName,
      builder: (context, state) => const OrtigasScreen(),
    ),

    /// 알라방 화면 (Alabang Screen)
    GoRoute(
      path: AlabangScreen.routeName,
      name: AlabangScreen.routeName,
      builder: (context, state) => const AlabangScreen(),
    ),

    /// 휴일 화면 (Holiday Screen)
    GoRoute(
      path: HolidayScreen.routeName,
      name: HolidayScreen.routeName,
      builder: (context, state) => const HolidayScreen(),
    ),

    /// 마닐라 화면 (Manila Screen)
    GoRoute(
      path: ManilaScreen.routeName,
      name: ManilaScreen.routeName,
      builder: (context, state) => const ManilaScreen(),
    ),

    /// 세부 화면 (Cebu Screen)
    GoRoute(
      path: CebuScreen.routeName,
      name: CebuScreen.routeName,
      builder: (context, state) => const CebuScreen(),
    ),

    /// 수빅 화면 (Subic Screen)
    GoRoute(
      path: SubicScreen.routeName,
      name: SubicScreen.routeName,
      builder: (context, state) => const SubicScreen(),
    ),

    /// 보홀 화면 (Bohol Screen)
    GoRoute(
      path: BoholScreen.routeName,
      name: BoholScreen.routeName,
      builder: (context, state) => const BoholScreen(),
    ),

    /// 보라카이 화면 (Boracay Screen)
    GoRoute(
      path: BoracayScreen.routeName,
      name: BoracayScreen.routeName,
      builder: (context, state) => const BoracayScreen(),
    ),

    /// 팔라완 화면 (Palawan Screen)
    GoRoute(
      path: PalawanScreen.routeName,
      name: PalawanScreen.routeName,
      builder: (context, state) => const PalawanScreen(),
    ),

    /// 엘니도 화면 (El Nido Screen)
    GoRoute(
      path: ElNidoScreen.routeName,
      name: ElNidoScreen.routeName,
      builder: (context, state) => const ElNidoScreen(),
    ),

    /// 하우스헬퍼 화면 (House Helper Screen)
    GoRoute(
      path: HouseHelperScreen.routeName,
      name: HouseHelperScreen.routeName,
      builder: (context, state) => const HouseHelperScreen(),
    ),

    /// 운전기사 화면 (Driver Screen)
    GoRoute(
      path: DriverScreen.routeName,
      name: DriverScreen.routeName,
      builder: (context, state) => const DriverScreen(),
    ),

    /// 가정교사 화면 (Tutor Screen)
    GoRoute(
      path: TutorScreen.routeName,
      name: TutorScreen.routeName,
      builder: (context, state) => const TutorScreen(),
    ),

    /// 골프 화면 (Golf Screen)
    GoRoute(
      path: GolfScreen.routeName,
      name: GolfScreen.routeName,
      builder: (context, state) => const GolfScreen(),
    ),

    /// 마사지 화면 (Massage Screen)
    GoRoute(
      path: MassageScreen.routeName,
      name: MassageScreen.routeName,
      builder: (context, state) => const MassageScreen(),
    ),

    /// 밤문화 화면 (Nightlife Screen)
    GoRoute(
      path: NightlifeScreen.routeName,
      name: NightlifeScreen.routeName,
      builder: (context, state) => const NightlifeScreen(),
    ),

    /// 시장 투어 화면 (Market Tour Screen)
    GoRoute(
      path: MarketTourScreen.routeName,
      name: MarketTourScreen.routeName,
      builder: (context, state) => const MarketTourScreen(),
    ),

    /// 해산물 화면 (Seafood Screen)
    GoRoute(
      path: SeafoodScreen.routeName,
      name: SeafoodScreen.routeName,
      builder: (context, state) => const SeafoodScreen(),
    ),

    /// 맛집 화면 (Restaurant Screen)
    GoRoute(
      path: RestaurantScreen.routeName,
      name: RestaurantScreen.routeName,
      builder: (context, state) => const RestaurantScreen(),
    ),

    /// 수상스포츠 화면 (Water Sports Screen)
    GoRoute(
      path: WaterSportsScreen.routeName,
      name: WaterSportsScreen.routeName,
      builder: (context, state) => const WaterSportsScreen(),
    ),

    /// 섬투어 화면 (Island Tour Screen)
    GoRoute(
      path: IslandTourScreen.routeName,
      name: IslandTourScreen.routeName,
      builder: (context, state) => const IslandTourScreen(),
    ),

    /// 축제 화면 (Festival Screen)
    GoRoute(
      path: FestivalScreen.routeName,
      name: FestivalScreen.routeName,
      builder: (context, state) => const FestivalScreen(),
    ),

    /// 광고 상세 화면 (Advertisement View Screen)
    GoRoute(
      path: AdvertisementViewScreen.routeName,
      name: AdvertisementViewScreen.routeName,
      builder: (context, state) {
        final idx = state.extra as int;
        return AdvertisementViewScreen(idx: idx);
      },
    ),

    /// 검색 화면 (Search Screen)
    /// Google CSE를 WebView로 표시 (검색어 파라미터 필수)
    GoRoute(
      path: SearchScreen.routeName,
      name: SearchScreen.routeName,
      builder: (context, state) {
        final searchTerm = state.extra as String? ?? '';
        return SearchScreen(searchTerm: searchTerm);
      },
    ),

    /// 업소 이벤트 화면 (Company Event Screen)
    GoRoute(
      path: CompanyEventScreen.routeName,
      name: CompanyEventScreen.routeName,
      builder: (context, state) => const CompanyEventScreen(),
    ),

    /// 이벤트 응모 화면 (Event Entry Screen)
    GoRoute(
      path: EventEntryScreen.routeName,
      name: EventEntryScreen.routeName,
      builder: (context, state) => const EventEntryScreen(),
    ),

    /// 이벤트 쿠폰 화면 (Event Coupon Screen)
    /// 스피닝 휠에서 당첨된 스타벅스 쿠폰 목록 표시
    GoRoute(
      path: EventCouponScreen.routeName,
      name: EventCouponScreen.routeName,
      builder: (context, state) => const EventCouponScreen(),
    ),

    /// QR 코드 스캐너 화면 (QR Scanner Screen)
    GoRoute(
      path: QrScannerScreen.routeName,
      name: QrScannerScreen.routeName,
      builder: (context, state) => const QrScannerScreen(),
    ),

    /// QR 코드 스캔 결과 화면 (QR Code Scanned Screen)
    /// 쿼리 파라미터로 idx(업체 번호)와 verification_id(인증 ID)를 전달받습니다.
    GoRoute(
      path: CompanyQrCodeScannedScreen.routeName,
      builder: (context, state) {
        final idx = int.tryParse(state.uri.queryParameters['idx'] ?? '') ?? 0;
        final verificationId =
            state.uri.queryParameters['verification_id'] ?? '';
        final screen = CompanyQrCodeScannedScreen(
          idx: idx,
          verificationId: verificationId,
        );

        return HomeScreen(redirect: screen);
      },
    ),
  ],
);
