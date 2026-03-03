import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/company/company.form.screen.dart';
import 'package:philgo/screens/company/company.view.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/guide/must_read.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/guide/travel_spots.screen.dart';
import 'package:philgo/screens/info/delivery/food_delivery.screen.dart';
import 'package:philgo/screens/info/delivery/baedal_k.screen.dart';
import 'package:philgo/screens/event/event_coupon.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/user/user.activity.screen.dart';
import 'package:philgo/screens/info/app_info.screen.dart';
import 'package:philgo/screens/version/version.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';
import 'package:philgo/widgets/home/menu/forum.sub_section.dart';
import 'package:philgo/widgets/home/menu/menu.grid_item.dart';
import 'package:philgo/widgets/home/menu/menu.grid_section.dart';
import 'package:philgo/widgets/home/menu/menu.item.dart';
import 'package:philgo/widgets/home/menu/menu.section.dart';
import 'package:philgo/widgets/logo/logo.dart';
import 'package:philgo/v7_api/company_api.dart';
import 'package:philgo_api/philgo_api.dart';

/// 메뉴 홈 화면 위젯 (Menu Home Screen Widget)
///
/// 앱의 모든 기능과 페이지에 접근할 수 있는 전체 메뉴 화면입니다.
/// 2차/3차 카테고리로 정리되어 가독성이 높습니다.
///
/// ### 메뉴 구조:
/// - 2차 카테고리: 일반 섹션 (필리핀 생활 정보, 내 활동, 업소록, 채팅, 광고, 지원 등)
/// - 3차 카테고리: 게시판 섹션 (커뮤니티, 회원장터, 기타)
///
/// ### 메뉴 아이템 형태:
/// - Wrap 레이아웃 + 아이콘 위/레이블 아래 형태의 그리드 아이템
class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  /// 내 업소 데이터 (My company data)
  /// null이면 업소가 없거나 아직 로딩 중
  Company? _myCompany;

  @override
  void initState() {
    super.initState();
    _loadMyCompany();
  }

  /// 내 업소 데이터 로드 (Load my company data)
  Future<void> _loadMyCompany() async {
    try {
      final company = await CompanyApi.mine();
      if (mounted) {
        /// 빈 업소(서버 자동 생성)는 null 처리하여 기존 null 체크 로직 유지
        setState(() => _myCompany = company.name.isNotEmpty ? company : null);
      }
    } catch (e) {
      debugLog('Error loading my company in menu: $e');
    }
  }

  /// 로그아웃 처리 핸들러 (Logout Handler)
  ///
  /// 사용자에게 확인 다이얼로그를 표시하고, 확인 시 Firebase에서 로그아웃합니다.
  /// Shows confirmation dialog and signs out from Firebase if confirmed.
  Future<void> _handleLogout() async {
    final confirmed = await showConfirmDialog(
      title: Lo.of(context)!.logoutTitle,
      message: Lo.of(context)!.logoutConfirmMessage,
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go(EntryScreen.routeName);
      }
    }
  }

  /// 게시판 카테고리로 이동하는 핸들러 (Navigate to Forum Category Handler)
  ///
  /// NavigationState를 사용하여 포럼 탭으로 이동하고 해당 카테고리를 선택합니다.
  /// Uses NavigationState to navigate to forum tab and select the category.
  ///
  /// [postId] → 게시판 카테고리 ID (예: 'freetalk', 'qna', 'buyandsell')
  void _navigateToForum(String postId) {
    final navState = NavigationState.of(context, listen: false);
    // 딥링크 데이터 설정 (Set deep link data)
    navState.initialPostId = postId;
    navState.initialCategory = null;
    // 포럼 탭으로 이동 (Navigate to forum tab)
    navState.setHomeNavigation(HomeNavigationItem.forum);
  }

  /// 운영자 문의 처리 핸들러 (Admin Contact Handler)
  ///
  /// 운영자와 1:1 채팅방으로 직접 입장합니다.
  /// Directly enters 1:1 chat room with admin.
  void _handleAdminContact() {
    // 운영자와 1:1 채팅방 입장 (Enter 1:1 chat room with admin)
    ChatRoomScreen.push(context, UserService.instance.adminUserUid);
  }

  /// 사용자 검색 다이얼로그 핸들러 (User Search Dialog Handler)
  ///
  /// 사용자 검색 다이얼로그를 표시합니다.
  /// Shows user search dialog.
  void _handleUserSearch() {
    showUserSearchDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final l10n = Lo.of(context)!;

    return Column(
      children: [
        /// 상단 SafeArea 및 헤더 (Top SafeArea and Header)
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Comic design: 1.0px border with outlineVariant color (matches bottom nav)
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Logo(size: 48),
                Text(l10n.menu, style: theme.textTheme.titleLarge),
                const Spacer(),
                SizedBox(width: 48, height: 48),
              ],
            ),
          ),
        ),

        /// 메뉴 콘텐츠 (Menu Content)
        Expanded(
          child: SingleChildScrollView(
            // Comic design: Add horizontal padding for menu sections
            padding: const EdgeInsets.all(16),
            child: Column(
              // 각 섹션 간 여백 (spacing between sections)
              spacing: 28,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 첫 번째 섹션 상단 여백 (Top padding for first section)
                const SizedBox(height: 8),

                /// [1. 내 정보 섹션] - My Profile Info Section
                /// 프로필 미리보기 카드: 사진, 닉네임, 이름, 게시물/댓글 수
                _buildProfileCard(l10n, scheme)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),

                /// [2. 내 활동 섹션] - My Activity Section
                MenuGridSection(
                  title: l10n.myActivity,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.penToSquare,
                      title: l10n.editProfile,
                      onTap: () => ProfileEditScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.clockRotateLeft,
                      title: l10n.myPosts,
                      onTap: () =>
                          UserActivityScreen.push(context, uid: myUid()),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.penToSquare,
                      title: l10n.writePost,
                      onTap: () =>
                          showPostCreateScreen(context, postId: 'freetalk'),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.magnifyingGlass,
                      title: PhilgoTr.of(context)!.search_friends,
                      onTap: _handleUserSearch,
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.usersSlash,
                      title: l10n.blockedUsers,
                      onTap: () => showBlockedUserListDialog(context),
                    ),
                    // 이벤트 쿠폰 (Event Coupon) - 스피닝 휠에서 당첨된 스타벅스 쿠폰 확인
                    MenuGridItem(
                      icon: FontAwesomeIcons.ticket,
                      title: l10n.eventCoupon,
                      onTap: () => EventCouponScreen.push(context),
                    ),
                  ],
                ),

                /// [2. 필리핀 생활 정보 섹션] - Philippine Life Info Section
                /// 퀵 메뉴의 페이지들을 메뉴 화면에서도 접근 가능하도록 추가
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
                MenuGridSection(
                  title: l10n.philippineLifeInfo,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.starShooting,
                      title: l10n.quickMenuMustReadInfo,
                      onTap: () => context.push(MustReadScreen.routeName),

                      /// 강조 표시: tertiaryContainer 색상 사용
                      backgroundColor: scheme.tertiaryContainer,
                      iconColor: scheme.onTertiaryContainer,
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.bullhorn,
                      title: l10n.quickMenuNotice,
                      onTap: () => NoticeScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.coins,
                      title: l10n.quickMenuExchangeRate,
                      onTap: () => ExchangeRateScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.cloudSun,
                      title: l10n.quickMenuWeather,
                      onTap: () => WeatherScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.phoneVolume,
                      title: l10n.quickMenuEmergency,
                      onTap: () => EmergencyContactScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.circleInfo,
                      title: l10n.quickMenuEssentialInfo,
                      onTap: () => EssentialInfoScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.calendarDays,
                      title: l10n.quickMenuMonthlyLiving,
                      onTap: () => MonthlyLivingScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.umbrellaBeach,
                      title: l10n.quickMenuTravel,
                      onTap: () => TravelInfoScreen.push(context),
                    ),
                    // 여행 명소 (Travel Spots) - 필리핀 여행 명소 목록
                    MenuGridItem(
                      icon: FontAwesomeIcons.mapLocationDot,
                      title: l10n.quickMenuTravelSpots,
                      onTap: () => TravelSpotsScreen.push(context),
                    ),
                    // 음식 배달 (Food Delivery) - Grab 앱을 이용한 음식 배달 정보
                    MenuGridItem(
                      icon: FontAwesomeIcons.lightMotorcycle,
                      title: l10n.quickMenuFoodDelivery,
                      onTap: () => FoodDeliveryScreen.push(context),
                    ),
                    // 배달K (Baedal K) - 한국 음식 전문 배달 앱
                    MenuGridItem(
                      icon: FontAwesomeIcons.lightBowlRice,
                      title: l10n.quickMenuBaedalK,
                      onTap: () => BaedalKScreen.push(context),
                    ),
                  ],
                ),

                /// [2. 게시판 섹션] - Forum Section (3단 카테고리 구조)
                /// 게시판 -> 커뮤니티 / 회원장터 / 기타 로 분리
                /// 3-tier category structure: Forum -> Community / Market / Other
                _buildForumSection(l10n, scheme),

                /// [4. 내 업소 미리보기 + 업소록 섹션] - My Company Preview + Business Directory
                _buildMyCompanyCard(l10n, scheme)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.1, end: 0),

                MenuGridSection(
                  title: l10n.businessDirectoryTitle,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.building,
                      title: l10n.businessDirectoryTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.company);
                        }
                      },
                    ),
                    MenuGridItem(
                      icon: _myCompany != null
                          ? FontAwesomeIcons.penToSquare
                          : FontAwesomeIcons.circlePlus,
                      title: _myCompany != null
                          ? l10n.editMyCompany
                          : l10n.addMyCompany,
                      onTap: () async {
                        final result = await CompanyFormScreen.push(
                          context,
                          company: _myCompany,
                        );
                        if (result is Company && mounted) {
                          setState(() => _myCompany = result);
                        }
                      },
                    ),
                  ],
                ),

                /// [5. 채팅 섹션] - Chat Section
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
                MenuGridSection(
                  title: l10n.chat,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.comments,
                      title: l10n.openChatTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.chat);
                        }
                      },
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.headset,
                      title: l10n.contactAdmin,
                      onTap: _handleAdminContact,
                    ),
                  ],
                ),

                /// [6. 광고 섹션] - Advertising Section
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
                MenuGridSection(
                  title: l10n.advertising,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.rectangleAd,
                      title: l10n.bannerAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          bannerPageUrl(),
                          title: l10n.bannerAdTitle,
                        );
                      },
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.dollarSign,
                      title: l10n.pointAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          pointPageUrl(),
                          title: l10n.pointAdTitle,
                        );
                      },
                    ),
                  ],
                ),

                /// [7. 지원 및 정보 섹션] - Support & Information Section
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
                MenuGridSection(
                  title: l10n.support,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.circleQuestion,
                      title: l10n.appGuideTitle,
                      onTap: () => AppGuideScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.fileLines,
                      title: l10n.termsOfServiceTitle,
                      onTap: () => showTermsAndConditions(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.shieldHalved,
                      title: l10n.privacyPolicyTitle,
                      onTap: () => showPrivacyPolicy(context),
                    ),
                  ],
                ),

                /// [8. 앱 정보 섹션] - App Information Section
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
                MenuGridSection(
                  title: l10n.appInfoTitle,
                  children: [
                    MenuGridItem(
                      icon: FontAwesomeIcons.mobileScreen,
                      title: l10n.appInfoTitle,
                      onTap: () => AppInfoScreen.push(context),
                    ),
                    MenuGridItem(
                      icon: FontAwesomeIcons.circleInfo,
                      title: l10n.versionTitle,
                      onTap: () => VersionScreen.push(context),
                    ),
                  ],
                ),

                /// [9. 계정 관리 섹션] - Account Management Section
                /// 리스트 형태 유지 (위험 동작이므로)
                MenuSection(
                  title: l10n.accountActions,
                  isDanger: true,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.userMinus,
                      title: l10n.withdrawTitle,
                      isDanger: true,
                      onTap: () => AccountWithdrawalScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: l10n.logoutTitle,
                      isDanger: true,
                      onTap: _handleLogout,
                    ),
                  ],
                ),
                SizedBox(height: sp.s16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 게시판 섹션 빌드 (Build Forum Section)
  ///
  /// 3단 카테고리 구조로 게시판을 표시합니다.
  /// - 게시판 (1단) - 메인 섹션
  /// - 커뮤니티 / 회원장터 / 기타 (2단) - 서브 섹션
  /// - 개별 게시판 (3단) - 아이템
  Widget _buildForumSection(Lo l10n, ColorScheme scheme) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 게시판 섹션 헤더 (Forum Section Header)
        /// 현대적 디자인: 인디케이터 바 + 타이틀
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              // 섹션 인디케이터 바 (Section indicator bar)
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              // 섹션 타이틀 (Section title)
              Text(
                l10n.forum,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  // 미니멀 디자인: 일반 폰트 두께 사용
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 게시판 컨테이너 (Forum Container)
        /// 현대적 디자인: 부드러운 배경, 미니멀 테두리
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [2-1. 커뮤니티] - Community Subcategory
              /// 자유게시판, 질문답변, 인사/소개, 블로그, 유튜브
              ForumSubSection(
                title: l10n.forumCommunity,
                children: [
                  MenuGridItem(
                    icon: FontAwesomeIcons.comments,
                    title: l10n.categoryFreetalk,
                    onTap: () => _navigateToForum('freetalk'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.circleQuestion,
                    title: l10n.categoryQna,
                    onTap: () => _navigateToForum('qna'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.handWave,
                    title: l10n.categoryGreeting,
                    onTap: () => _navigateToForum('greeting'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.blog,
                    title: l10n.categoryBlog,
                    onTap: () => _navigateToForum('blog'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.youtube,
                    title: l10n.categoryYoutube,
                    onTap: () => _navigateToForum('youtube'),
                  ),
                ],
              ),

              /// [2-2. 회원장터] - Member Market Subcategory
              /// 사고팔기, 구인구직
              ForumSubSection(
                title: l10n.forumMarket,
                children: [
                  MenuGridItem(
                    icon: FontAwesomeIcons.cartShopping,
                    title: l10n.categoryBuyandsell,
                    onTap: () => _navigateToForum('buyandsell'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.briefcase,
                    title: l10n.categoryWanted,
                    onTap: () => _navigateToForum('wanted'),
                  ),
                ],
              ),

              /// [2-3. 기타] - Other Subcategory
              /// 마사지, 하숙집/기숙사, 여행, 비즈니스, 학교, 주의사항, 음식배달, 레스토랑
              ForumSubSection(
                title: l10n.forumOther,
                children: [
                  MenuGridItem(
                    icon: FontAwesomeIcons.spa,
                    title: l10n.categoryMassage,
                    onTap: () => _navigateToForum('massage'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.house,
                    title: l10n.categoryBoardingHouse,
                    onTap: () => _navigateToForum('boarding_house'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.plane,
                    title: l10n.categoryTravel,
                    onTap: () => _navigateToForum('travel'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.buildingColumns,
                    title: l10n.categoryBusiness,
                    onTap: () => _navigateToForum('business'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.graduationCap,
                    title: l10n.categorySchool,
                    onTap: () => _navigateToForum('school'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.triangleExclamation,
                    title: l10n.categoryCaution,
                    onTap: () => _navigateToForum('caution'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.utensils,
                    title: l10n.categoryFoodDelivery,
                    onTap: () => _navigateToForum('food_delivery'),
                  ),
                  MenuGridItem(
                    icon: FontAwesomeIcons.burger,
                    title: l10n.categoryRest,
                    onTap: () => _navigateToForum('rest'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 내 정보 미리보기 카드 (Profile Preview Card)
  ///
  /// 사용자 프로필 사진, 닉네임, 이름, 게시물/댓글 수를 보여주는 카드.
  /// Selector로 user 변경 시에만 리빌드.
  Widget _buildProfileCard(Lo l10n, ColorScheme scheme) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section Header)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.circleUser,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.myProfileInfo,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 프로필 카드 본체 (Profile Card Body)
        /// Record 타입으로 필요한 필드만 선택 (firebase User 타입 충돌 방지)
        Selector<PhilgoState,
            ({String? photoUrl, String nickname, String name, int postCount, int commentCount})>(
          selector: (_, state) {
            final u = state.user;
            return (
              photoUrl: u?.photoUrl,
              nickname: u?.nickname ?? '',
              name: u?.name ?? '',
              postCount: u?.noOfPost ?? 0,
              commentCount: u?.noOfComment ?? 0,
            );
          },
          builder: (context, data, _) {
            final hasPhoto =
                data.photoUrl != null && data.photoUrl!.isNotEmpty;
            final nickname = data.nickname.isNotEmpty
                ? data.nickname
                : l10n.anonymous;

            return GestureDetector(
              onTap: () => ProfileEditScreen.push(context),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    /// 프로필 사진 (Profile Photo)
                    Hero(
                      tag: 'profile-photo-hero',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasPhoto
                            ? CachedNetworkImage(
                                imageUrl: data.photoUrl!,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.user,
                                    size: 24,
                                    color: scheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.user,
                                    size: 24,
                                    color: scheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: FaIcon(
                                  FontAwesomeIcons.user,
                                  size: 24,
                                  color: scheme.primary.withValues(alpha: 0.4),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// 프로필 텍스트 정보 (Profile Text Info)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 닉네임 (Nickname)
                          Text(
                            nickname,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          /// 이름 (Name)
                          if (data.name.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              data.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),

                          /// 게시물/댓글 수 (Posts/Comments count)
                          Row(
                            children: [
                              _buildStatChip(
                                scheme,
                                theme,
                                FontAwesomeIcons.penToSquare,
                                l10n.postsCount('${data.postCount}'),
                              ),
                              const SizedBox(width: 12),
                              _buildStatChip(
                                scheme,
                                theme,
                                FontAwesomeIcons.comment,
                                l10n.commentsCount('${data.commentCount}'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// 편집 화살표 (Edit Arrow)
                    FaIcon(
                      FontAwesomeIcons.chevronRight,
                      size: 14,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// 통계 칩 위젯 (Stat Chip Widget)
  ///
  /// 게시물/댓글 수를 아이콘 + 텍스트로 표시하는 작은 칩
  Widget _buildStatChip(
    ColorScheme scheme,
    ThemeData theme,
    IconData icon,
    String label,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FaIcon(icon, size: 11, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 내 업소 미리보기 카드 (My Company Preview Card)
  ///
  /// 업소가 있으면 업소 정보(이름, 카테고리, 주소, 전화번호) 미리보기 표시.
  /// 업소가 없으면 등록 유도 안내 표시.
  Widget _buildMyCompanyCard(Lo l10n, ColorScheme scheme) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 (Section Header)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.store,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.myCompanyInfo,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 업소 카드 본체 (Company Card Body)
        GestureDetector(
          onTap: () {
            if (_myCompany != null) {
              /// 업소 상세 화면으로 이동 (Navigate to company detail)
              CompanyViewScreen.push(context, _myCompany!.idx);
            } else {
              /// 업소 등록 화면으로 이동 (Navigate to company form)
              _navigateToCompanyForm();
            }
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.5),
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(20),
            child: _myCompany != null
                ? _buildCompanyInfo(l10n, scheme, theme)
                : _buildNoCompanyPlaceholder(l10n, scheme, theme),
          ),
        ),
      ],
    );
  }

  /// 업소 정보 표시 (Company Info Display)
  ///
  /// 업소가 등록되어 있을 때 로고, 이름, 카테고리, 주소, 전화번호 표시
  Widget _buildCompanyInfo(Lo l10n, ColorScheme scheme, ThemeData theme) {
    final company = _myCompany!;
    final hasLogo = company.logo_url.isNotEmpty;

    return Row(
      children: [
        /// 업소 로고 (Company Logo)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasLogo
              ? CachedNetworkImage(
                  imageUrl: company.logo_url,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: FaIcon(
                      FontAwesomeIcons.store,
                      size: 24,
                      color: scheme.secondary.withValues(alpha: 0.4),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: FaIcon(
                      FontAwesomeIcons.store,
                      size: 24,
                      color: scheme.secondary.withValues(alpha: 0.4),
                    ),
                  ),
                )
              : Center(
                  child: FaIcon(
                    FontAwesomeIcons.store,
                    size: 24,
                    color: scheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
        ),
        const SizedBox(width: 16),

        /// 업소 텍스트 정보 (Company Text Info)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 업소명 (Company Name)
              Text(
                company.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              /// 카테고리 (Category)
              if (company.category.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.tag,
                      size: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        company.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              /// 주소 (Address)
              if (company.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        company.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              /// 전화번호 (Phone Number)
              if (company.phone_number.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.phone,
                      size: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company.phone_number,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        /// 상세 보기 화살표 (View Detail Arrow)
        FaIcon(
          FontAwesomeIcons.chevronRight,
          size: 14,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  /// 업소 미등록 안내 (No Company Placeholder)
  ///
  /// 업소가 없을 때 등록 유도 안내 표시
  Widget _buildNoCompanyPlaceholder(
    Lo l10n,
    ColorScheme scheme,
    ThemeData theme,
  ) {
    return Row(
      children: [
        /// 빈 업소 아이콘 (Empty Company Icon)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.store,
              size: 24,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(width: 16),

        /// 안내 텍스트 (Guide Text)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.noCompanyRegistered,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.tapToRegisterCompany,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),

        /// 등록 화살표 (Register Arrow)
        FaIcon(
          FontAwesomeIcons.chevronRight,
          size: 14,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ],
    );
  }

  /// 업소 등록/수정 화면으로 이동 (Navigate to Company Form)
  Future<void> _navigateToCompanyForm() async {
    final result = await CompanyFormScreen.push(
      context,
      company: _myCompany,
    );
    if (result is Company && mounted) {
      setState(() => _myCompany = result);
    }
  }
}
