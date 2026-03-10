import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/user/login/user.login.screen.dart';
import 'package:philgo/user/widgets/login.dart';

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
                        title: '내 정보',
                        icon: FontAwesomeIcons.lightCircleUser,
                        child: _buildProfileContent(theme, scheme),
                      ).animate().fadeIn(duration: 400.ms).slideY(
                        begin: 0.1,
                        end: 0,
                      ),

                      // 내 활동 섹션
                      _buildSection(
                        title: '내 활동',
                        icon: FontAwesomeIcons.lightRectangleHistory,
                        child: _buildActivityGrid(theme, scheme),
                      ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 100.ms,
                      ).slideY(begin: 0.1, end: 0),

                      // 필리핀 생활 정보 섹션
                      _buildSection(
                        title: '필리핀 생활 정보',
                        icon: FontAwesomeIcons.lightEarthAsia,
                        child: _buildInfoGrid(theme, scheme),
                      ).animate().fadeIn(
                        duration: 400.ms,
                        delay: 200.ms,
                      ).slideY(begin: 0.1, end: 0),
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
          Text('로그인이 필요합니다', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            '메뉴를 이용하려면 로그인해 주세요.',
            style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => UserLoginScreen.push(context),
            icon: const FaIcon(FontAwesomeIcons.lightRightToBracket, size: 16),
            label: const Text('로그인'),
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
          Text('메뉴', style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  /// 섹션 컨테이너 빌드 (Best Practice 패턴)
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 섹션 헤더 - 인디케이터 바 + 아이콘 + 타이틀
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

              /// 섹션 아이콘
              FaIcon(icon, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),

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
    return Row(
      children: [
        /// 프로필 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/img/logo/philgo_v6_app_logo.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),

        /// 프로필 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '필고',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '송재호',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
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
                    '78개 게시물',
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
                    '14개 댓글',
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

  /// 내 활동 메뉴 그리드
  Widget _buildActivityGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(FontAwesomeIcons.lightPenToSquare, '프로필 수정'),
      _MenuItemData(FontAwesomeIcons.lightClockRotateLeft, '내 게시글'),
      _MenuItemData(FontAwesomeIcons.lightPenNib, '글쓰기'),
      _MenuItemData(FontAwesomeIcons.lightMagnifyingGlass, '친구 검색'),
      _MenuItemData(FontAwesomeIcons.lightUserSlash, '차단된 사용자'),
      _MenuItemData(FontAwesomeIcons.lightTicket, '이벤트 쿠폰'),
      _MenuItemData(FontAwesomeIcons.lightCoins, '포인트 내역'),
    ];

    return _buildMenuGrid(items, theme, scheme);
  }

  /// 필리핀 생활 정보 메뉴 그리드
  Widget _buildInfoGrid(ThemeData theme, ColorScheme scheme) {
    final items = [
      _MenuItemData(
        FontAwesomeIcons.lightStarShooting,
        '필수 정보',
        isHighlighted: true,
      ),
      _MenuItemData(FontAwesomeIcons.lightBullhorn, '공지'),
      _MenuItemData(FontAwesomeIcons.lightCoins, '환율'),
      _MenuItemData(FontAwesomeIcons.lightCloudSun, '날씨'),
      _MenuItemData(FontAwesomeIcons.lightPhoneVolume, '긴급연락처'),
      _MenuItemData(FontAwesomeIcons.lightCircleInfo, '초보 필독'),
      _MenuItemData(FontAwesomeIcons.lightCalendarDays, '한달살기'),
      _MenuItemData(FontAwesomeIcons.lightMountain, '여행'),
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
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 아이콘 배경
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.isHighlighted
                  ? scheme.primary.withValues(alpha: 0.1)
                  : scheme.surfaceContainerHigh.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(
                item.icon,
                size: 22,
                color: item.isHighlighted
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
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

  const _MenuItemData(this.icon, this.label, {this.isHighlighted = false});
}
