import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/screens/guide/must_read.screen.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:provider/provider.dart';

/// 퀵 메뉴 아이템 데이터 클래스 (Quick Menu Item Data Class)
///
/// 각 퀵 메뉴 아이템의 아이콘, 라벨, 탭 콜백 정보를 담습니다.
/// Contains icon, label, and tap callback for each quick menu item.
class _QuickMenuItem {
  /// 메뉴 아이콘 (Menu Icon)
  final IconData icon;

  /// 메뉴 라벨 (Menu Label)
  final String label;

  /// 탭 콜백 (Tap Callback)
  final VoidCallback? onTap;

  const _QuickMenuItem({required this.icon, required this.label, this.onTap});
}

/// 홈 화면 퀵 메뉴 섹션 위젯 (Home Quick Menu Section Widget)
///
/// 필리핀 생활에 꼭 필요한 필수 정보를 빠르게 접근할 수 있는 메뉴입니다.
/// Quick access menu for essential information about living in the Philippines.
///
/// ### 메뉴 항목 (Menu Items):
/// - 환율: 페소-원화 환율 정보 (Exchange rate: PHP-KRW)
/// - 필수정보: 비자, 대사관, 병원 등 (Essential info: Visa, Embassy, Hospital, etc.)
/// - 한달살기: 장기 체류 정보 (Monthly living: Long-term stay info)
/// - 여행: 여행지, 관광 정보 (Travel: Destinations, Tourism info)
///
/// ### Example:
/// ```dart
/// const HomeQuickMenuSection()
/// ```
class HomeQuickMenuSection extends StatelessWidget {
  const HomeQuickMenuSection({super.key});

  /// 공지 메뉴 탭 핸들러 (Notice menu tap handler)
  ///
  /// 공지사항 화면을 다이얼로그로 표시합니다.
  /// Shows notice screen as dialog.
  void _onNoticeTap(BuildContext context) {
    showFullScreen(
      context,
      child: const NoticeScreen(),
      barrierLabel: '공지사항 닫기',
    );
  }

  /// 환율 메뉴 탭 핸들러 (Exchange rate menu tap handler)
  ///
  /// 환율 정보 화면을 다이얼로그로 표시합니다.
  /// Shows exchange rate information screen as dialog.
  void _onExchangeRateTap(BuildContext context) {
    showFullScreen(
      context,
      child: const ExchangeRateScreen(),
      barrierLabel: '환율 정보 닫기',
    );
  }

  /// 날씨 메뉴 탭 핸들러 (Weather menu tap handler)
  ///
  /// 필리핀 주요 도시의 날씨 정보 화면을 다이얼로그로 표시합니다.
  /// Shows weather information screen for major Philippine cities as dialog.
  void _onWeatherTap(BuildContext context) {
    showFullScreen(
      context,
      child: const WeatherScreen(),
      barrierLabel: '날씨 정보 닫기',
    );
  }

  /// 긴급 연락처 메뉴 탭 핸들러 (Emergency contact menu tap handler)
  ///
  /// 대사관, 경찰, 병원 등 긴급 연락처 화면을 다이얼로그로 표시합니다.
  /// Shows emergency contacts screen (Embassy, Police, Hospital, etc.) as dialog.
  void _onEmergencyContactTap(BuildContext context) {
    showFullScreen(
      context,
      child: const EmergencyContactScreen(),
      barrierLabel: '긴급 연락처 닫기',
    );
  }

  /// 필수정보 메뉴 탭 핸들러 (Essential info menu tap handler)
  ///
  /// 비자, 대사관, 병원 등 필수 정보 화면을 다이얼로그로 표시합니다.
  /// Shows essential info screen (Visa, Embassy, Hospital, etc.) as dialog.
  void _onEssentialInfoTap(BuildContext context) {
    showFullScreen(
      context,
      child: const EssentialInfoScreen(),
      barrierLabel: '필수정보 닫기',
    );
  }

  /// 한달살기 메뉴 탭 핸들러 (Monthly living menu tap handler)
  ///
  /// 장기 체류 정보 화면을 다이얼로그로 표시합니다.
  /// Shows monthly living (long-term stay) information screen as dialog.
  void _onMonthlyLivingTap(BuildContext context) {
    showFullScreen(
      context,
      child: const MonthlyLivingScreen(),
      barrierLabel: '한달살기 닫기',
    );
  }

  /// 여행 메뉴 탭 핸들러 (Travel menu tap handler)
  ///
  /// 여행지, 관광 정보 화면을 다이얼로그로 표시합니다.
  /// Shows travel destinations and tourism information screen as dialog.
  void _onTravelTap(BuildContext context) {
    showFullScreen(
      context,
      child: const TravelInfoScreen(),
      barrierLabel: '여행 정보 닫기',
    );
  }

  /// 내 정보 메뉴 탭 핸들러 (My info menu tap handler)
  ///
  /// 회원 정보 수정 화면으로 이동합니다.
  /// Hero 애니메이션을 위해 Navigator.push 방식 사용
  /// Navigates to profile edit screen.
  /// Uses Navigator.push for Hero animation support
  void _onMyInfoTap(BuildContext context) {
    ProfileEditScreen.push(context);
  }

  /// 전체 메뉴 탭 핸들러 (All menu tap handler)
  ///
  /// 메뉴 탭으로 이동합니다.
  /// Navigates to Menu tab.
  void _onAllMenuTap(BuildContext context) {
    NavigationState.of(
      context,
      listen: false,
    ).setHomeNavigation(HomeNavigationItem.menu);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 다국어 지원을 위한 로컬라이제이션 객체 (Localization object for i18n)
    final l10n = Lo.of(context)!;

    /// 퀵 메뉴 아이템 목록 (Quick menu items list)
    /// FontAwesome 7.1 Pro Light 아이콘 사용
    final menuItems = [
      _QuickMenuItem(
        /// 공지 아이콘: 공지사항/알림을 상징하는 메가폰 아이콘
        /// Notice icon: Megaphone representing announcements
        icon: FontAwesomeIcons.lightBullhorn,
        label: l10n.quickMenuNotice,
        onTap: () => _onNoticeTap(context),
      ),
      _QuickMenuItem(
        /// 환율 아이콘: 페소-원화 환전을 상징하는 동전 아이콘
        /// Exchange rate icon: Coins representing PHP-KRW exchange
        icon: FontAwesomeIcons.lightCoins,
        label: l10n.quickMenuExchangeRate,
        onTap: () => _onExchangeRateTap(context),
      ),
      _QuickMenuItem(
        /// 날씨 아이콘: 필리핀 날씨를 상징하는 태양과 구름 아이콘
        /// Weather icon: Sun and cloud representing Philippine weather
        icon: FontAwesomeIcons.lightCloudSun,
        label: l10n.quickMenuWeather,
        onTap: () => _onWeatherTap(context),
      ),
      _QuickMenuItem(
        /// 긴급 연락처 아이콘: 긴급 전화를 상징하는 전화 아이콘
        /// Emergency contact icon: Phone representing emergency calls
        icon: FontAwesomeIcons.lightPhoneVolume,
        label: l10n.quickMenuEmergency,
        onTap: () => _onEmergencyContactTap(context),
      ),
      _QuickMenuItem(
        /// 필수정보 아이콘: 중요 정보를 나타내는 원형 정보 아이콘
        /// Essential info icon: Circle info representing important information
        icon: FontAwesomeIcons.lightCircleInfo,
        label: l10n.quickMenuEssentialInfo,
        onTap: () => _onEssentialInfoTap(context),
      ),
      _QuickMenuItem(
        /// 한달살기 아이콘: 장기 체류를 상징하는 달력 아이콘
        /// Monthly living icon: Calendar representing long-term stay
        icon: FontAwesomeIcons.lightCalendarDays,
        label: l10n.quickMenuMonthlyLiving,
        onTap: () => _onMonthlyLivingTap(context),
      ),
      _QuickMenuItem(
        /// 여행 아이콘: 필리핀 해변 여행을 상징하는 우산 아이콘
        /// Travel icon: Beach umbrella representing Philippines vacation
        icon: FontAwesomeIcons.lightUmbrellaBeach,
        label: l10n.quickMenuTravel,
        onTap: () => _onTravelTap(context),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.s12),
      child: SingleChildScrollView(
        /// 가로 스크롤 활성화 (Enable horizontal scrolling)
        scrollDirection: Axis.horizontal,

        /// 좌우 패딩 추가 (Add horizontal padding)
        padding: EdgeInsets.symmetric(horizontal: sp.s8),

        child: Row(
          /// 아이템들을 시작점에 정렬 (Align items to start)
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            /// 내 정보 아바타 메뉴 (맨 처음 위치)
            /// My info avatar menu (first position)
            _buildAvatarMenuItem(
              context: context,
              label: l10n.quickMenuMyInfo,
              onTap: () => _onMyInfoTap(context),
              scheme: scheme,
              theme: theme,
              sp: sp,
            ),

            /// 필독 정보 (내 정보 다음 위치)
            /// Must-Read Information (after my info)
            _buildMenuItem(
              context: context,
              icon: FontAwesomeIcons.starShooting,
              label: l10n.quickMenuMustReadInfo,
              onTap: () => context.push(MustReadScreen.routeName),
              scheme: scheme,
              theme: theme,
              sp: sp,

              /// 강조 표시: tertiaryContainer 색상 사용
              /// Highlight: Use tertiaryContainer colors
              backgroundColor: scheme.tertiaryContainer,
              iconColor: scheme.onTertiaryContainer,
            ),

            /// 기존 메뉴 아이템들 (Other menu items)
            ...menuItems.map((item) {
              return _buildMenuItem(
                context: context,
                icon: item.icon,
                label: item.label,
                onTap: item.onTap,
                scheme: scheme,
                theme: theme,
                sp: sp,
              );
            }),

            /// 전체 메뉴 (내 정보 다음 위치)
            /// All menu (after my info)
            _buildMenuItem(
              context: context,
              icon: FontAwesomeIcons.lightBars,
              label: l10n.quickMenuAllMenu,
              onTap: () => _onAllMenuTap(context),
              scheme: scheme,
              theme: theme,
              sp: sp,
            ),
          ],
        ),
      ),
    );
  }

  /// 개별 메뉴 아이템 빌드 (Build individual menu item)
  ///
  /// [context] → BuildContext
  /// [icon] → 메뉴 아이콘 (Menu icon)
  /// [label] → 메뉴 라벨 (Menu label)
  /// [onTap] → 탭 콜백 (Tap callback)
  /// [scheme] → ColorScheme
  /// [theme] → ThemeData
  /// [sp] → AppSpacing
  /// [backgroundColor] → 아이콘 배경색 (Icon background color), 기본값: primaryContainer
  /// [iconColor] → 아이콘 색상 (Icon color), 기본값: onPrimaryContainer
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme scheme,
    required ThemeData theme,
    required AppSpacing sp,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    /// InkWell 사용: SingleChildScrollView + Row 조합에서는 InkWell 정상 동작
    /// ripple effect를 제공하여 탭 피드백 표시
    ///
    /// Using InkWell: Works correctly with SingleChildScrollView + Row combination
    /// Provides ripple effect for tap feedback
    return InkWell(
      /// 탭 시 콜백 호출 (Call callback on tap)
      onTap: onTap,

      /// 둥근 모서리 ripple 효과 (Rounded corner ripple effect)
      borderRadius: BorderRadius.circular(12),

      child: Padding(
        padding: EdgeInsets.all(sp.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 아이콘 컨테이너 (Icon container)
            /// 배경색 + 둥근 모서리로 강조 (한 단계 작은 크기: 48x48)
            /// Highlighted with background color + rounded corners (smaller size: 48x48)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                /// 배경색: backgroundColor 또는 기본값 primaryContainer
                /// Background color: backgroundColor or default primaryContainer
                color: backgroundColor ?? scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  icon,

                  /// 아이콘 크기: 20 (컨테이너 축소에 맞춤)
                  /// Icon size: 20 (adjusted for smaller container)
                  size: 20,

                  /// 아이콘 색상: iconColor 또는 기본값 onPrimaryContainer
                  /// Icon color: iconColor or default onPrimaryContainer
                  color: iconColor ?? scheme.onPrimaryContainer,
                ),
              ),
            ),

            SizedBox(height: sp.s4),

            /// 메뉴 라벨 (Menu label)
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 아바타 메뉴 아이템 빌드 (Build avatar menu item)
  ///
  /// 사용자 아바타를 표시하는 메뉴 아이템입니다.
  /// 아바타 이미지가 있으면 이미지를 표시하고, 없으면 기본 사용자 아이콘을 표시합니다.
  ///
  /// Menu item displaying user avatar.
  /// Shows avatar image if available, otherwise shows default user icon.
  ///
  /// [context] → BuildContext
  /// [label] → 메뉴 라벨 (Menu label)
  /// [onTap] → 탭 콜백 (Tap callback)
  /// [scheme] → ColorScheme
  /// [theme] → ThemeData
  /// [sp] → AppSpacing
  Widget _buildAvatarMenuItem({
    required BuildContext context,
    required String label,
    required VoidCallback? onTap,
    required ColorScheme scheme,
    required ThemeData theme,
    required AppSpacing sp,
  }) {
    return InkWell(
      /// 탭 시 콜백 호출 (Call callback on tap)
      onTap: onTap,

      /// 둥근 모서리 ripple 효과 (Rounded corner ripple effect)
      borderRadius: BorderRadius.circular(12),

      child: Padding(
        padding: EdgeInsets.all(sp.s4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 아바타 컨테이너 (Avatar container)
            /// Selector를 사용하여 사용자 photoUrl만 구독 (한 단계 작은 크기: 48x48)
            /// Use Selector to subscribe only to user photoUrl (smaller size: 48x48)
            /// Hero 애니메이션: 프로필 수정 화면과 연결
            /// Hero animation: Connected with profile edit screen
            Selector<PhilgoState, String?>(
              selector: (_, state) => state.user?.photoUrl,
              builder: (_, photoUrl, _) {
                return Hero(
                  /// Hero 태그: 프로필 사진 전환 애니메이션용
                  /// Hero tag: For profile photo transition animation
                  tag: 'profile-photo-hero',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      /// 배경색: primaryContainer
                      /// Background color: primaryContainer
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: photoUrl != null && photoUrl.isNotEmpty
                        /// 아바타 이미지가 있으면 CachedNetworkImage로 표시
                        /// If avatar image exists, display with CachedNetworkImage
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.cover,
                            width: 48,
                            height: 48,

                            /// 로딩 중: 기본 아이콘 표시
                            /// Loading: Show default icon
                            placeholder: (_, _) => Center(
                              child: FaIcon(
                                FontAwesomeIcons.lightUser,
                                size: 20,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),

                            /// 에러 시: 기본 아이콘 표시
                            /// On error: Show default icon
                            errorWidget: (context, url, error) => Center(
                              child: FaIcon(
                                FontAwesomeIcons.lightUser,
                                size: 20,
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          )
                        /// 아바타 이미지가 없으면 기본 사용자 아이콘 표시
                        /// If no avatar image, show default user icon
                        : Center(
                            child: FaIcon(
                              FontAwesomeIcons.lightUser,
                              size: 20,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                  ),
                );
              },
            ),

            SizedBox(height: sp.s4),

            /// 메뉴 라벨 (Menu label)
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
