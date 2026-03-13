import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/edit/company.edit.screen.dart';
import 'package:philgo/company/view/company.view.screen.dart';
import 'package:philgo/post/my/my.posts.screen.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/user/widgets/login.dart';
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
  CompanyModel? _myCompany;

  @override
  void initState() {
    super.initState();
    _loadMyCompany();
  }

  Future<void> _loadMyCompany() async {
    try {
      final company = await CompanyService.mine();
      if (mounted && company != null && company.name.isNotEmpty) {
        setState(() => _myCompany = company);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Login(
        notLoggedIn: _buildNotLoggedIn(theme, scheme),
        builder: (_) => SafeArea(
          child: Column(
            children: [
              // 앱바 영역
              _buildAppBar(theme, scheme),
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
                      _buildSection(
                            title: '내 정보'.tr(),
                            icon: FontAwesomeIcons.lightCircleUser,
                            child: _buildProfileContent(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 내 활동 섹션
                      _buildSection(
                            title: '내 활동'.tr(),
                            child: _buildActivityGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 필리핀 생활 정보 섹션
                      _buildSection(
                            title: '필리핀 생활 정보'.tr(),
                            child: _buildInfoGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 게시판 섹션
                      _buildSection(
                            title: '게시판'.tr(),
                            child: _buildForumContent(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 내 업소 섹션
                      _buildSection(
                            title: '내 업소'.tr(),
                            icon: FontAwesomeIcons.lightStore,
                            child: _buildMyCompanyContent(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 350.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 업소록 섹션
                      _buildSection(
                            title: '업소록'.tr(),
                            child: _buildCompanyGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 채팅 섹션
                      _buildSection(
                            title: '채팅'.tr(),
                            child: _buildChatGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 450.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 광고 섹션
                      _buildSection(
                            title: '광고'.tr(),
                            child: _buildAdGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 500.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 지원 섹션
                      _buildSection(
                            title: '지원'.tr(),
                            child: _buildSupportGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 550.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 앱 정보 섹션
                      _buildSection(
                            title: '앱 정보'.tr(),
                            child: _buildAppInfoGrid(theme, scheme),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 600.ms)
                          .slideY(begin: 0.1, end: 0),

                      // 계정 삭제
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: 계정 삭제 로직
                          },
                          child: Text(
                            '계정 삭제'.tr(),
                            style: TextStyle(color: scheme.error, fontSize: 14),
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

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 비로그인 상태 UI
  Widget _buildNotLoggedIn(ThemeData theme, ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleUser,
            size: 64,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text('로그인이 필요합니다'.tr(), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '메뉴를 이용하려면 로그인해 주세요.'.tr(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => UserLoginScreen.push(context),
            icon: const FaIcon(FontAwesomeIcons.lightRightToBracket, size: 16),
            label: Text('로그인'.tr()),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  /// 앱바 영역
  Widget _buildAppBar(ThemeData theme, ColorScheme scheme) {
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
          Text('메뉴'.tr(), style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  /// 섹션 컨테이너 빌드 (아이콘 옵셔널)
  Widget _buildSection({
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
  Widget _buildProfileContent(ThemeData theme, ColorScheme scheme) {
    final user = context.watch<UserState>().user;
    if (user == null) return const SizedBox.shrink();

    return Row(
      children: [
        /// 프로필 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: user.photoUrl.isNotEmpty
              ? Image.network(
                  user.photoUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(scheme),
                )
              : _buildDefaultAvatar(scheme),
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
  Widget _buildDefaultAvatar(ColorScheme scheme) {
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

  /// 내 활동 메뉴 그리드
  Widget _buildActivityGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightPenToSquare,
        '프로필 수정'.tr(),
        onTap: () => UserEditScreen.push(context),
      ),
      _MenuItemData(
        FontAwesomeIcons.lightClockRotateLeft,
        '내 게시글'.tr(),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const MyPostsScreen())),
      ),
      _MenuItemData(FontAwesomeIcons.lightPenNib, '글쓰기'.tr()),
      _MenuItemData(FontAwesomeIcons.lightMagnifyingGlass, '친구 검색'.tr()),
      _MenuItemData(FontAwesomeIcons.lightUserSlash, '차단된 사용자'.tr()),
      _MenuItemData(FontAwesomeIcons.lightTicket, '이벤트 쿠폰'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCoins, '포인트 내역'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 필리핀 생활 정보 메뉴 그리드
  Widget _buildInfoGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightStarShooting,
        '필수 정보'.tr(),
        isHighlighted: true,
      ),
      _MenuItemData(FontAwesomeIcons.lightBullhorn, '공지'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCoins, '환율'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCloudSun, '날씨'.tr()),
      _MenuItemData(FontAwesomeIcons.lightPhoneVolume, '긴급연락처'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCircleInfo, '초보 필독'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCalendarDays, '한달살기'.tr()),
      _MenuItemData(FontAwesomeIcons.lightMountain, '여행'.tr()),
      _MenuItemData(FontAwesomeIcons.lightMapLocationDot, '여행 명소'.tr()),
      _MenuItemData(FontAwesomeIcons.lightBicycle, '음식 배달'.tr()),
      _MenuItemData(FontAwesomeIcons.lightBowlRice, '배달K'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 메뉴에서 선택한 게시판으로 이동
  void _navigateToForum(String postId, {String? category}) {
    AppNavigationState.of(context).openPostListScreen(
      postId: postId,
      category: category,
    );
  }

  /// 게시판 섹션 콘텐츠 (서브카테고리 포함)
  Widget _buildForumContent(ThemeData theme, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 커뮤니티 서브카테고리
        _buildSubCategoryLabel('커뮤니티'.tr(), scheme),
        const SizedBox(height: 16),
        _buildMenuGrid(
          [
            _MenuItemData(
              FontAwesomeIcons.lightComments,
              '자유게시판'.tr(),
              onTap: () => _navigateToForum('freetalk'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightCircleQuestion,
              '묻고 답하기'.tr(),
              onTap: () => _navigateToForum('qna'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightPeopleArrows,
              '인사'.tr(),
              onTap: () => _navigateToForum('greeting'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightBlog,
              '블로그'.tr(),
              onTap: () => _navigateToForum('blog'),
            ),
            _MenuItemData(
              FontAwesomeIcons.youtube,
              '유튜브'.tr(),
              backgroundColor: Colors.red.shade600,
              iconColor: Colors.white,
              onTap: () => _navigateToForum('youtube'),
            ),
          ],
          theme,
          scheme,
        ),

        const SizedBox(height: 24),

        // 회원장터 서브카테고리
        _buildSubCategoryLabel('회원장터'.tr(), scheme),
        const SizedBox(height: 16),
        _buildMenuGrid(
          [
            _MenuItemData(
              FontAwesomeIcons.lightCartShopping,
              '사고팔기'.tr(),
              onTap: () => _navigateToForum('buyandsell'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightBriefcase,
              '구인구직'.tr(),
              onTap: () => _navigateToForum('wanted'),
            ),
          ],
          theme,
          scheme,
        ),

        const SizedBox(height: 24),

        // 기타 서브카테고리
        _buildSubCategoryLabel('기타'.tr(), scheme),
        const SizedBox(height: 16),
        _buildMenuGrid(
          [
            _MenuItemData(
              FontAwesomeIcons.lightSpa,
              '마사지'.tr(),
              onTap: () => _navigateToForum('massage'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightHouse,
              '하숙집/기숙사'.tr(),
              onTap: () => _navigateToForum('boarding_house'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightPlaneDeparture,
              '여행'.tr(),
              onTap: () => _navigateToForum('travel'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightBuildingColumns,
              '비즈니스'.tr(),
              onTap: () => _navigateToForum('business'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightGraduationCap,
              '학교'.tr(),
              onTap: () => _navigateToForum('school'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightTriangleExclamation,
              '주의/경고'.tr(),
              onTap: () => _navigateToForum('caution'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightUtensils,
              '음식배달'.tr(),
              onTap: () => _navigateToForum('food_delivery'),
            ),
            _MenuItemData(
              FontAwesomeIcons.lightBurger,
              '레스토랑'.tr(),
              onTap: () => _navigateToForum('rest'),
            ),
          ],
          theme,
          scheme,
        ),
      ],
    );
  }

  /// 서브카테고리 라벨 칩
  Widget _buildSubCategoryLabel(String label, ColorScheme scheme) {
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
  Widget _buildMyCompanyContent(ThemeData theme, ColorScheme scheme) {
    final company = _myCompany;

    return GestureDetector(
      onTap: () {
        if (company != null) {
          _openCompanyView(company);
        } else {
          _openCompanyEdit();
        }
      },
      child: Row(
        children: [
          /// 업소 로고/이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: company != null && company.primaryImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: company.primaryImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildCompanyPlaceholderIcon(scheme),
                  )
                : _buildCompanyPlaceholderIcon(scheme),
          ),
          const SizedBox(width: 12),

          /// 업소 정보
          Expanded(
            child: company != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (company.category.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          company.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (company.address.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          company.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (company.phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          company.phoneNumber,
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
                        '업소를 등록해 주세요'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
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

  Widget _buildCompanyPlaceholderIcon(ColorScheme scheme) {
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

  /// 업소 상세 화면 열기
  void _openCompanyView(CompanyModel company) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CompanyViewScreen(company: company)),
    );
  }

  /// 업소 등록/수정 화면 열기
  Future<void> _openCompanyEdit() async {
    var company = _myCompany;
    if (company == null) {
      // 로딩 다이얼로그 표시
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
      }
      try {
        company = await CompanyService.mine();
      } catch (_) {}
      if (mounted) Navigator.of(context).pop(); // 로딩 다이얼로그 닫기
      if (company == null || !mounted) return;
      _myCompany = company;
    }

    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => CompanyEditScreen(company: company!),
      ),
    );

    if (result is CompanyModel && mounted) {
      setState(() => _myCompany = result);
    }
  }

  /// 업소록 메뉴 그리드
  Widget _buildCompanyGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightBuilding,
        '업소 검색'.tr(),
        onTap: () => AppNavigationState.of(context).openCompanyScreen(),
      ),
      _MenuItemData(
        _myCompany != null
            ? FontAwesomeIcons.lightPenToSquare
            : FontAwesomeIcons.lightCirclePlus,
        _myCompany != null ? '업소 수정'.tr() : '업소 등록'.tr(),
        onTap: _openCompanyEdit,
      ),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 채팅 메뉴 그리드
  Widget _buildChatGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(FontAwesomeIcons.lightComments, '오픈 채팅방'.tr()),
      _MenuItemData(FontAwesomeIcons.lightHeadset, '운영자 문의'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 광고 메뉴 그리드
  Widget _buildAdGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(FontAwesomeIcons.lightRectangleAd, '배너 광고'.tr()),
      _MenuItemData(FontAwesomeIcons.lightDollarSign, '포인트 광고'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 지원 메뉴 그리드
  Widget _buildSupportGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(FontAwesomeIcons.lightCircleQuestion, '앱 사용 안내'.tr()),
      _MenuItemData(FontAwesomeIcons.lightFileContract, '이용 약관'.tr()),
      _MenuItemData(FontAwesomeIcons.lightShieldHalved, '개인정보 처리방침'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 앱 정보 메뉴 그리드
  Widget _buildAppInfoGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(FontAwesomeIcons.lightFloppyDisk, '앱 정보'.tr()),
      _MenuItemData(FontAwesomeIcons.lightCircleInfo, '버전 정보'.tr()),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 4열 메뉴 그리드 빌드
  Widget _buildMenuGrid(
    List<_MenuItemData> items,
    ThemeData theme,
    ColorScheme scheme,
  ) {
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
                Expanded(child: _buildMenuItem(item, theme, scheme)),
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
  Widget _buildMenuItem(
    _MenuItemData item,
    ThemeData theme,
    ColorScheme scheme,
  ) {
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
