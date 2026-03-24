import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/guide/app_guide.screen.dart';
import 'package:philgo/app_info/app_info.screen.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/bookmark/bookmark.screen.dart';
import 'package:philgo/event/event_coupon.screen.dart';
import 'package:philgo/point/point_history.screen.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/my/my.posts.screen.dart';
import 'package:philgo/user/account_withdrawal.screen.dart';
import 'package:philgo/user/merge/merge_account.screen.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/user/user.model.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/user/widgets/blocked_users_bottom_sheet.dart';
import 'package:philgo/user/widgets/login_required_dialog.dart';
import 'package:philgo/notice/notice.screen.dart';
import 'package:philgo/version/version.screen.dart';
import 'package:philgo/currency/currency.screen.dart';
import 'package:philgo/weather/weather.screen.dart';
import 'package:philgo/webview/webview.screen.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatefulWidget {
  static const String routeName = '/Menu';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 앱바 영역
            _buildAppBar(context),
            Container(height: 1, color: scheme.outlineVariant),

            // 스크롤 가능한 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 28,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // 내 정보 섹션
                    Consumer<UserState>(
                          builder: (context, userState, _) {
                            final section = _buildSection(
                              context,
                              // "My Profile"
                              title: '내 정보'.tr(),
                              icon: FontAwesomeIcons.lightCircleUser,
                              child: _buildProfileContent(
                                context,
                                userState.user,
                              ),
                            );
                            if (userState.user == null) {
                              return GestureDetector(
                                onTap: () => UserLoginScreen.push(context),
                                behavior: HitTestBehavior.opaque,
                                child: section,
                              );
                            }
                            return section;
                          },
                        )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 내 활동 섹션
                    _buildSection(
                          context,
                          // "My Activity"
                          title: '내 활동'.tr(),
                          child: _buildActivityGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 필리핀 생활 정보 섹션
                    _buildSection(
                          context,
                          // "Philippines Info"
                          title: '필리핀 생활 정보'.tr(),
                          child: _buildInfoGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 게시판 섹션
                    _buildSection(
                          context,
                          // "Forum"
                          title: '게시판'.tr(),
                          child: _buildForumContent(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 내 업소 섹션
                    ValueListenableBuilder<CompanyModel?>(
                          valueListenable:
                              CompanyService.instance.companyNotifier,
                          builder: (context, myCompany, _) {
                            return _buildSection(
                              context,
                              // "My Business"
                              title: '내 업소'.tr(),
                              icon: FontAwesomeIcons.lightStore,
                              child: _buildMyCompanyContent(context, myCompany),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 350.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 업소록 섹션
                    ValueListenableBuilder<CompanyModel?>(
                          valueListenable:
                              CompanyService.instance.companyNotifier,
                          builder: (context, myCompany, _) {
                            return _buildSection(
                              context,
                              // "Company"
                              title: '업소록'.tr(),
                              child: _buildCompanyGrid(context, myCompany),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 채팅 섹션
                    _buildSection(
                          context,
                          // "Chat"
                          title: '채팅'.tr(),
                          child: _buildChatGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 450.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 광고 섹션
                    _buildSection(
                          context,
                          // "Advertising"
                          title: '광고'.tr(),
                          child: _buildAdGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 지원 섹션
                    _buildSection(
                          context,
                          // "Support"
                          title: '지원'.tr(),
                          child: _buildSupportGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 550.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 앱 정보 섹션
                    _buildSection(
                          context,
                          // "App Info"
                          title: '앱 정보'.tr(),
                          child: _buildAppInfoGrid(context),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    // 계정 삭제 & 로그아웃 (로그인 시에만 표시)
                    Consumer<UserState>(
                      builder: (context, userState, _) {
                        if (userState.user == null) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          spacing: 28,
                          children: [
                            // 계정 삭제
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  AccountWithdrawalScreen.push(context);
                                },
                                icon: FaIcon(
                                  FontAwesomeIcons.lightTrashCan,
                                  size: 14,
                                  color: scheme.onSurfaceVariant,
                                ),
                                label: Text(
                                  // "Delete Account"
                                  '계정 삭제'.tr(),
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 650.ms),

                            // 로그아웃
                            OutlinedButton.icon(
                              onPressed: () async {
                                await UserService.signOut();
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.lightRightFromBracket,
                                size: 16,
                                color: scheme.error,
                              ),
                              label: Text(
                                // "Logout"
                                '로그아웃'.tr(),
                                style: TextStyle(color: scheme.error),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: scheme.error.withValues(alpha: 0.4),
                                ),
                                minimumSize: const Size(double.infinity, 48),
                              ),
                            ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱바 영역
  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            'assets/img/logo/philgo_wide_logo_icon.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 8),
          // "Menu"
          Text('메뉴'.tr(), style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  /// 섹션 컨테이너 빌드 (아이콘 옵셔널)
  Widget _buildSection(
    BuildContext context, {
    required String title,
    IconData? icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 - 인디케이터 바 + (아이콘) + 타이틀
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              /// 섹션 인디케이터 바
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),

              /// 섹션 아이콘 (옵셔널)
              if (icon != null) ...[
                FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
              ],

              /// 섹션 타이틀
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        /// 섹션 콘텐츠 컨테이너
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
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ],
    );
  }

  /// 프로필 카드 내용
  Widget _buildProfileContent(BuildContext context, UserModel? user) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (user == null) {
      return Row(
        children: [
          _buildDefaultAvatar(context),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // "Please login"
                  '로그인 해주세요'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  // "Login to access all features"
                  '로그인하여 모든 기능을 이용하세요'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FaIcon(
            FontAwesomeIcons.lightChevronRight,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
        ],
      );
    }

    return Row(
      children: [
        /// 프로필 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _isValidPhotoUrl(user.photoUrl)
              ? CachedNetworkImage(
                  imageUrl: user.photoUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  memCacheWidth: 112,
                  memCacheHeight: 112,
                  placeholder: (_, _) => _buildDefaultAvatar(context),
                  errorWidget: (_, _, _) => _buildDefaultAvatar(context),
                )
              : _buildDefaultAvatar(context),
        ),
        const SizedBox(width: 12),

        /// 프로필 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.id.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  user.id,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 6),
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightPenToSquare,
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // "{} posts"
                    '{}개 게시물'.tr(args: ['${user.noOfPost}']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FaIcon(
                    FontAwesomeIcons.lightComment,
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    // "{} comments"
                    '{}개 댓글'.tr(args: ['${user.noOfComment}']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        /// 오른쪽 화살표
        FaIcon(
          FontAwesomeIcons.lightChevronRight,
          size: 16,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }

  /// 기본 프로필 아바타
  bool _isValidPhotoUrl(String url) {
    if (url.isEmpty || url.trim().isEmpty) return false;
    if (url.toLowerCase() == 'null') return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.lightCircleUser,
          size: 28,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 로그인이 필요한 메뉴 아이템의 onTap을 래핑한다.
  VoidCallback _requireLogin(VoidCallback action) {
    return () {
      if (!UserService.isLoggedIn) {
        LoginRequiredDialog.show(context);
        return;
      }
      action();
    };
  }

  /// 내 활동 메뉴 그리드
  Widget _buildActivityGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightPenToSquare,
        // "Edit Profile"
        '프로필 수정'.tr(),
        onTap: _requireLogin(() => UserEditScreen.push(context)),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightClockRotateLeft,
        // "My Posts"
        '내 게시글'.tr(),
        onTap: _requireLogin(
          () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MyPostsScreen())),
        ),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightPenNib,
        // "Write"
        '글쓰기'.tr(),
        onTap: _requireLogin(
          () => PostCreateScreen.push(context, postId: 'freetalk'),
        ),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightMagnifyingGlass,
        // "Find Friends"
        '친구 검색'.tr(),
        onTap: _requireLogin(() async {
          final uid = await ChatService.instance.showUserSearchDialog(context);
          if (uid != null && context.mounted) {
            ChatRoomScreen.push(context, uid);
          }
        }),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightUserSlash,
        // "Blocked Users"
        '차단된 사용자'.tr(),
        onTap: _requireLogin(
          () => showBlockedUsersBottomSheet(context: context),
        ),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightTicket,
        // "Event Coupons"
        '이벤트 쿠폰'.tr(),
        onTap: _requireLogin(() => EventCouponScreen.push(context)),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightCoins,
        // "Point History"
        '포인트 내역'.tr(),
        onTap: _requireLogin(() => PointHistoryScreen.push(context)),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightBookmark,
        // "Bookmark"
        '북마크'.tr(),
        onTap: _requireLogin(() => BookmarkScreen.push(context)),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightUserGroup,
        // "Merge Account"
        '아이디 합치기'.tr(),
        onTap: _requireLogin(() => MergeAccountScreen.push(context)),
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 필리핀 생활 정보 메뉴 그리드
  Widget _buildInfoGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightStarShooting,
        // "Essential Info"
        '필수 정보'.tr(),
        isHighlighted: true,
      ),
      // "Notices"
      _MenuItemData(FontAwesomeIcons.lightBullhorn, '공지'.tr(),
          onTap: () => NoticeScreen.push(context)),
      // "Exchange Rate"
      _MenuItemData(FontAwesomeIcons.lightCoins, '환율'.tr(),
          onTap: () => ExchangeRateScreen.push(context)),
      _MenuItemData(
        FontAwesomeIcons.lightCloudSun,
        // "Weather"
        '날씨'.tr(),
        onTap: () => WeatherScreen.push(context),
      ),
      // "Emergency"
      _MenuItemData(FontAwesomeIcons.lightPhoneVolume, '긴급연락처'.tr()),
      // "Beginner Guide"
      _MenuItemData(FontAwesomeIcons.lightCircleInfo, '초보 필독'.tr()),
      // "Month Stay"
      _MenuItemData(FontAwesomeIcons.lightCalendarDays, '한달살기'.tr()),
      // "Travel"
      _MenuItemData(FontAwesomeIcons.lightMountain, '여행'.tr()),
      // "Tourist Spots"
      _MenuItemData(FontAwesomeIcons.lightMapLocationDot, '여행 명소'.tr()),
      // "Food Delivery"
      _MenuItemData(FontAwesomeIcons.lightBicycle, '음식 배달'.tr()),
      // "Delivery K"
      _MenuItemData(FontAwesomeIcons.lightBowlRice, '배달K'.tr()),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 메뉴에서 선택한 게시판으로 이동
  void _navigateToForum(String postId, {String? category}) {
    AppNavigationState.of(
      context,
    ).openForumScreen(postId: postId, category: category);
  }

  /// 게시판 섹션 콘텐츠 (서브카테고리 포함)
  Widget _buildForumContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 커뮤니티 서브카테고리
        // "Community"
        _buildSubCategoryLabel('커뮤니티'.tr(), context),
        const SizedBox(height: 16),
        _buildMenuGrid([
          _MenuItemData(
            FontAwesomeIcons.lightComments,
            // "Free Board"
            '자유게시판'.tr(),
            onTap: () => _navigateToForum('freetalk'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightCircleQuestion,
            // "Q&A"
            '묻고 답하기'.tr(),
            onTap: () => _navigateToForum('qna'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightPeopleArrows,
            // "Greetings"
            '인사'.tr(),
            onTap: () => _navigateToForum('greeting'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightBlog,
            // "Blog"
            '블로그'.tr(),
            onTap: () => _navigateToForum('blog'),
          ),
          _MenuItemData(
            FontAwesomeIcons.youtube,
            // "YouTube"
            '유튜브'.tr(),
            backgroundColor: Colors.red.shade600,
            iconColor: Colors.white,
            onTap: () => _navigateToForum('youtube'),
          ),
        ], context),

        const SizedBox(height: 24),

        // 회원장터 서브카테고리
        // "Marketplace"
        _buildSubCategoryLabel('회원장터'.tr(), context),
        const SizedBox(height: 16),
        _buildMenuGrid([
          _MenuItemData(
            FontAwesomeIcons.lightCartShopping,
            // "Buy & Sell"
            '사고팔기'.tr(),
            onTap: () => _navigateToForum('buyandsell'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightBriefcase,
            // "Jobs"
            '구인구직'.tr(),
            onTap: () => _navigateToForum('wanted'),
          ),
        ], context),

        const SizedBox(height: 24),

        // 기타 서브카테고리
        // "Others"
        _buildSubCategoryLabel('기타'.tr(), context),
        const SizedBox(height: 16),
        _buildMenuGrid([
          _MenuItemData(
            FontAwesomeIcons.lightSpa,
            // "Massage"
            '마사지'.tr(),
            onTap: () => _navigateToForum('massage'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightHouse,
            // "Boarding/Dorm"
            '하숙집/기숙사'.tr(),
            onTap: () => _navigateToForum('boarding_house'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightPlaneDeparture,
            // "Travel"
            '여행'.tr(),
            onTap: () => _navigateToForum('travel'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightBuildingColumns,
            // "Business"
            '비즈니스'.tr(),
            onTap: () => _navigateToForum('business'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightGraduationCap,
            // "School"
            '학교'.tr(),
            onTap: () => _navigateToForum('school'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightTriangleExclamation,
            // "Warning"
            '주의/경고'.tr(),
            onTap: () => _navigateToForum('caution'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightUtensils,
            // "Food Delivery"
            '음식배달'.tr(),
            onTap: () => _navigateToForum('food_delivery'),
          ),
          _MenuItemData(
            FontAwesomeIcons.lightBurger,
            // "Restaurant"
            '레스토랑'.tr(),
            onTap: () => _navigateToForum('rest'),
          ),
        ], context),
      ],
    );
  }

  /// 서브카테고리 라벨 칩
  Widget _buildSubCategoryLabel(String label, BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 내 업소 섹션 콘텐츠
  Widget _buildMyCompanyContent(BuildContext context, CompanyModel? myCompany) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasRegistered = myCompany != null && myCompany.name.isNotEmpty;

    return GestureDetector(
      onTap: _requireLogin(() {
        if (myCompany == null) return;
        if (hasRegistered) {
          CompanyViewScreen.push(context, company: myCompany);
        } else {
          CompanyEditScreen.push(context, company: myCompany);
        }
      }),
      child: Row(
        children: [
          /// 업소 로고/이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: hasRegistered && myCompany.primaryImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: myCompany.primaryImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: ($, $$, $$$) =>
                        _buildCompanyPlaceholderIcon(context),
                  )
                : _buildCompanyPlaceholderIcon(context),
          ),
          const SizedBox(width: 12),

          /// 업소 정보
          Expanded(
            child: hasRegistered
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myCompany.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (myCompany.category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          myCompany.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (myCompany.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          myCompany.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (myCompany.phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          myCompany.phoneNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // "Please register your business"
                        '업소를 등록해 주세요'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        // "Register and promote your business"
                        '나의 업소를 등록하고 홍보하세요'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),

          /// 오른쪽 화살표
          FaIcon(
            FontAwesomeIcons.lightChevronRight,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPlaceholderIcon(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.lightStore,
          size: 24,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  /// 업소록 메뉴 그리드
  Widget _buildCompanyGrid(BuildContext context, CompanyModel? myCompany) {
    final hasRegistered = myCompany != null && myCompany.name.isNotEmpty;

    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightBuilding,
        // "Search Business"
        '업소 검색'.tr(),
        onTap: () => AppNavigationState.of(context).openCompanyScreen(),
      ),
      _MenuItemData(
        hasRegistered
            ? FontAwesomeIcons.lightPenToSquare
            : FontAwesomeIcons.lightCirclePlus,
        // "Edit Business", "Register Business"
        hasRegistered ? '업소 수정'.tr() : '업소 등록'.tr(),
        onTap: _requireLogin(() {
          if (myCompany != null) {
            CompanyEditScreen.push(context, company: myCompany);
          }
        }),
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 채팅 메뉴 그리드
  Widget _buildChatGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightComments,
        // "Open Chat"
        '오픈 채팅방'.tr(),
        onTap: () => AppNavigationState.of(context).openChatScreen(),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightHeadset,
        // "Contact Admin"
        '운영자 문의'.tr(),
        onTap: () {
          ChatRoomScreen.pushAdminChat(context);
        },
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 광고 메뉴 그리드
  Widget _buildAdGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightRectangleAd,
        // "Banner Ad"
        '배너 광고'.tr(),
        onTap: () => WebViewScreen.push(
          context,
          url: '${Config.v7BaseUrl}/adv/banner',
          // "Banner Ad"
          title: '배너 광고'.tr(),
        ),
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 지원 메뉴 그리드
  Widget _buildSupportGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightCircleQuestion,
        // "App Guide"
        '앱 사용 안내'.tr(),
        onTap: () => AppGuideScreen.push(context),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightFileContract,
        // "Terms of Service"
        '이용 약관'.tr(),
        onTap: () => WebViewScreen.push(
          context,
          url: '${Config.v7BaseUrl}/help/terms',
          // "Terms of Service"
          title: '이용 약관'.tr(),
        ),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightShieldHalved,
        // "Privacy Policy"
        '개인정보 처리방침'.tr(),
        onTap: () => WebViewScreen.push(
          context,
          url: '${Config.v7BaseUrl}/help/privacy',
          // "Privacy Policy"
          title: '개인정보 처리방침'.tr(),
        ),
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 앱 정보 메뉴 그리드
  Widget _buildAppInfoGrid(BuildContext context) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightFloppyDisk,
        // "App Info"
        '앱 정보'.tr(),
        onTap: () => AppInfoScreen.push(context),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightCircleInfo,
        // "Version Info"
        '버전 정보'.tr(),
        onTap: () => VersionScreen.push(context),
      ),
    ];

    return _buildMenuGrid(items, context);
  }

  /// 4열 메뉴 그리드 빌드
  Widget _buildMenuGrid(List<_MenuItemData> items, BuildContext context) {
    const crossAxisCount = 4;
    List<List<_MenuItemData>> rows = [];
    for (var i = 0; i < items.length; i += crossAxisCount) {
      rows.add(
        items.sublist(
          i,
          (i + crossAxisCount > items.length)
              ? items.length
              : i + crossAxisCount,
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 20),
          Row(
            children: [
              for (var item in rows[i])
                Expanded(child: _buildMenuItem(item, context)),
              // 빈 공간 채우기
              for (var j = rows[i].length; j < crossAxisCount; j++)
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  /// 개별 메뉴 아이템 위젯
  Widget _buildMenuItem(_MenuItemData item, BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 아이콘 배경
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color:
                  item.backgroundColor ??
                  (item.isHighlighted
                      ? scheme.primary.withValues(alpha: 0.1)
                      : scheme.surfaceContainerHigh.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                item.icon,
                size: 22,
                color:
                    item.iconColor ??
                    (item.isHighlighted
                        ? scheme.primary
                        : scheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// 아이콘 라벨
          Text(
            item.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 메뉴 아이템 데이터 모델
class _MenuItemData {
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _MenuItemData(
    this.icon,
    this.label, {
    this.isHighlighted = false,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });
}
