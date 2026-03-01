import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      final company = await getMyCompany();
      if (mounted) {
        setState(() => _myCompany = company);
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

                /// [1. 내 활동 섹션] - My Activity Section
                /// 메뉴 화면 최상단 배치
                MenuGridSection(
                  title: l10n.myActivity,
                  children: [
                    /// 프로필 수정 아이템 (Edit Profile Item)
                    /// 사용자 프로필 사진이 있으면 사진 표시, 없으면 기본 아이콘 표시
                    /// Selector를 사용하여 photoUrl 변경 시에만 리빌드
                    Selector<PhilgoState, String?>(
                      selector: (_, state) => state.user?.photoUrl,
                      builder: (context, photoUrl, _) {
                        // 프로필 사진이 있는지 확인
                        final hasPhoto =
                            photoUrl != null && photoUrl.isNotEmpty;

                        return MenuGridItem(
                          icon: hasPhoto ? null : FontAwesomeIcons.user,
                          iconWidget: hasPhoto
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: photoUrl,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    // 로딩 중에는 기본 아이콘 표시
                                    placeholder: (context, url) => Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12),
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.04),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.user,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                    // 에러 시 기본 아이콘 표시
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.12),
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.04),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          FontAwesomeIcons.user,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                          title: l10n.editProfile,
                          onTap: () => ProfileEditScreen.push(context),
                        );
                      },
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

                /// [3. 업소록 섹션] - Business Directory Section
                /// Wrap + 아이콘 위/레이블 아래 형태로 변경
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
                    // Show "View my company" icon only when user has a registered company
                    if (_myCompany != null)
                      MenuGridItem(
                        icon: FontAwesomeIcons.eye,
                        title: l10n.viewMyCompany,
                        onTap: () {
                          CompanyViewScreen.push(context, _myCompany!.idx);
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
}
