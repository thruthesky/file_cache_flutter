import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/guide/must_read.screen.dart';
import 'package:philgo/screens/guide/travel_spots.screen.dart';
import 'package:philgo/screens/info/emergency/embassy.screen.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/emergency/korean_association.screen.dart';
import 'package:philgo/screens/info/emergency/police_station.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/helper/house_helper.screen.dart';
import 'package:philgo/screens/info/housing/airbnb.screen.dart';
import 'package:philgo/screens/info/immigration/e_travel.screen.dart';
import 'package:philgo/screens/info/immigration/travel_visa.screen.dart';
import 'package:philgo/screens/info/transportation/grab_taxi.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 헬퍼 메뉴 아이템 데이터 클래스 (Helper Menu Item Data Class)
///
/// 각 헬퍼 메뉴 아이템의 아이콘, 라벨, 라우트 정보를 담습니다.
/// Contains icon, label, and route for each helper menu item.
class _HelperMenuItem {
  /// 메뉴 아이콘 (Menu Icon)
  final IconData icon;

  /// 메뉴 라벨 (Menu Label)
  final String label;

  /// 라우트 이름 (Route Name)
  final String routeName;

  const _HelperMenuItem({
    required this.icon,
    required this.label,
    required this.routeName,
  });
}

/// 홈 화면 헬퍼 메뉴 섹션 위젯 (Home Helper Menu Section Widget)
///
/// 필리핀 생활에 필요한 바로가기 메뉴를 Wrap 형식으로 표시합니다.
/// Displays quick access helper menu items in Wrap layout.
///
/// ### 메뉴 항목 (Menu Items):
/// - 대사관: 주 필리핀 대한민국 대사관 정보
/// - 한인회: 필리핀 한인회 연락처
/// - 경찰서: 필리핀 경찰 연락처
/// - e트래블: 필리핀 전자여행허가 정보
/// - 여행비자: 여행비자 안내
/// - 그랩 택시: 그랩 택시 이용 안내
/// - 에어비앤비: 에어비앤비 숙소 안내
/// - 환율: 페소-원화 환율 정보
/// - 날씨: 필리핀 주요 도시 날씨
/// - 긴급연락처: 긴급 상황 연락처
/// - 초보필독: 필리핀 초보자 필수 정보
///
/// ### Example:
/// ```dart
/// const HomeHelperMenuSection()
/// ```
class HomeHelperMenuSection extends StatelessWidget {
  const HomeHelperMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;
    final l10n = Lo.of(context)!;

    /// 헬퍼 메뉴 아이템 목록 (Helper menu items list)
    /// FontAwesome 7.1 Pro Light 아이콘 사용
    /// Using FontAwesome 7.1 Pro Light icons
    final menuItems = [
      _HelperMenuItem(
        /// 대사관: 깃발이 있는 랜드마크 아이콘 (Embassy: Landmark with flag icon)
        icon: FontAwesomeIcons.lightLandmarkFlag,
        label: l10n.quickMenuEmbassy,
        routeName: EmbassyScreen.routeName,
      ),
      _HelperMenuItem(
        /// 한인회: 사람들 그룹 아이콘 (Korean Association: People group icon)
        icon: FontAwesomeIcons.lightPeopleGroup,
        label: l10n.quickMenuKoreanAssociation,
        routeName: KoreanAssociationScreen.routeName,
      ),
      _HelperMenuItem(
        /// 경찰서: 방패가 있는 건물 아이콘 (Police: Building with shield icon)
        icon: FontAwesomeIcons.lightBuildingShield,
        label: l10n.quickMenuPoliceStation,
        routeName: PoliceStationScreen.routeName,
      ),
      _HelperMenuItem(
        /// e트래블: 비행기 티켓 아이콘 (e-Travel: Plane ticket icon)
        icon: FontAwesomeIcons.lightPlaneUp,
        label: l10n.immigrationETravel,
        routeName: ETravelScreen.routeName,
      ),
      _HelperMenuItem(
        /// 여행비자: 여권 아이콘 (Travel Visa: Passport icon)
        icon: FontAwesomeIcons.lightPassport,
        label: l10n.immigrationTravelVisa,
        routeName: TravelVisaScreen.routeName,
      ),
      _HelperMenuItem(
        /// 그랩 택시: 자동차 아이콘 (Grab Taxi: Car icon)
        icon: FontAwesomeIcons.lightCarSide,
        label: l10n.transportationGrabTaxi,
        routeName: GrabTaxiScreen.routeName,
      ),
      _HelperMenuItem(
        /// 에어비앤비: 집 아이콘 (Airbnb: House icon)
        icon: FontAwesomeIcons.lightHouseUser,
        label: l10n.housingAirbnb,
        routeName: AirbnbScreen.routeName,
      ),
      _HelperMenuItem(
        /// 환율: 코인 아이콘 (Exchange Rate: Coins icon)
        icon: FontAwesomeIcons.lightCoins,
        label: l10n.quickMenuExchangeRate,
        routeName: ExchangeRateScreen.routeName,
      ),
      _HelperMenuItem(
        /// 날씨: 태양과 구름 아이콘 (Weather: Sun and cloud icon)
        icon: FontAwesomeIcons.lightCloudSun,
        label: l10n.quickMenuWeather,
        routeName: WeatherScreen.routeName,
      ),
      _HelperMenuItem(
        /// 긴급연락처: 전화 아이콘 (Emergency: Phone icon)
        icon: FontAwesomeIcons.lightPhoneVolume,
        label: l10n.quickMenuEmergency,
        routeName: EmergencyContactScreen.routeName,
      ),
      _HelperMenuItem(
        /// 하우스헬퍼: 빗자루 아이콘 (House Helper: Broom icon)
        /// 가사도우미 고용 관련 정보
        icon: FontAwesomeIcons.lightBroom,
        label: l10n.helperHouseHelper,
        routeName: HouseHelperScreen.routeName,
      ),
      _HelperMenuItem(
        /// 여행 명소: 우산 해변 아이콘 (Travel Spots: Umbrella beach icon)
        /// 필리핀 여행 명소 정보
        icon: FontAwesomeIcons.lightUmbrellaBeach,
        label: l10n.quickMenuTravelSpots,
        routeName: TravelSpotsScreen.routeName,
      ),
      _HelperMenuItem(
        /// 초보필독: 별 아이콘 (Must Read: Star icon)
        icon: FontAwesomeIcons.lightStarShooting,
        label: l10n.quickMenuMustReadInfo,
        routeName: MustReadScreen.routeName,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더 (Section Header)
          /// "퀵메뉴" 타이틀 표시
          Padding(
            padding: EdgeInsets.only(top: sp.s12, bottom: sp.s12),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightGridRound2,
                  size: 16,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Text(
                  l10n.helperMenuTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          /// Wrap 레이아웃으로 메뉴 아이템 표시
          /// Display menu items in Wrap layout
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: menuItems.map((item) {
              return _buildMenuItem(
                context: context,
                icon: item.icon,
                label: item.label,
                onTap: () => context.push(item.routeName),
                scheme: scheme,
                theme: theme,
                sp: sp,
              );
            }).toList(),
          ),
        ],
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
  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme scheme,
    required ThemeData theme,
    required AppSpacing sp,
  }) {
    /// InkWell로 탭 효과 제공
    /// Provide tap effect with InkWell
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        /// 최소 너비 설정: 아이템이 균일한 크기로 표시되도록 함
        /// Minimum width: Ensures items display with uniform size
        constraints: const BoxConstraints(minWidth: 72),
        padding: EdgeInsets.all(sp.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 아이콘 컨테이너 (Icon Container)
            /// 배경색 + 둥근 모서리로 강조 (48x48 크기)
            /// Highlighted with background color + rounded corners (48x48 size)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                /// 배경색: primaryContainer
                /// Background color: primaryContainer
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(icon, size: 20, color: scheme.onPrimaryContainer),
              ),
            ),

            SizedBox(height: sp.s4),

            /// 메뉴 라벨 (Menu Label)
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
              ),
              textAlign: TextAlign.center,

              /// 한 줄로 표시하고 넘치면 생략
              /// Display in single line and truncate if overflow
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
