import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/widgets/home/menu/menu.grid_item.dart';
import 'package:philgo/widgets/home/menu/menu.grid_section.dart';

class MustReadScreen extends StatefulWidget {
  // You may add routeName with dynamic parameters if needed like this:
  // static const String routeName = '/ScreenName/:id';
  // And update the push and go methods accordingly like below.
  // static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName.replaceFirst(':id'));
  static const String routeName = '/MustRead';
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);
  const MustReadScreen({super.key});

  @override
  State<MustReadScreen> createState() => _MustReadScreenState();
}

class _MustReadScreenState extends State<MustReadScreen> {
  /// 메뉴 화면으로 이동 (Navigate to Menu Screen)
  void _navigateToMenu() {
    // 현재 화면을 닫고 홈으로 돌아간 후 메뉴 탭으로 이동
    context.pop();
    NavigationState.of(
      context,
      listen: false,
    ).setHomeNavigation(HomeNavigationItem.menu);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickMenuMustReadInfo),
        actions: [
          /// 메뉴 아이콘 버튼 (Menu Icon Button)
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
            onPressed: _navigateToMenu,
            tooltip: l10n.menu,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 필리핀 생활 정보 섹션 (Philippine Life Info Section)
            MenuGridSection(
              title: l10n.philippineLifeInfo,
              children: [
                MenuGridItem(
                  icon: FontAwesomeIcons.bullhorn,
                  title: l10n.quickMenuNotice,
                  onTap: () => context.push(NoticeScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.coins,
                  title: l10n.quickMenuExchangeRate,
                  onTap: () => context.push(ExchangeRateScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.cloudSun,
                  title: l10n.quickMenuWeather,
                  onTap: () => context.push(WeatherScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.phoneVolume,
                  title: l10n.quickMenuEmergency,
                  onTap: () => context.push(EmergencyContactScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.circleInfo,
                  title: l10n.quickMenuEssentialInfo,
                  onTap: () => context.push(EssentialInfoScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.calendarDays,
                  title: l10n.quickMenuMonthlyLiving,
                  onTap: () => context.push(MonthlyLivingScreen.routeName),
                ),
                MenuGridItem(
                  icon: FontAwesomeIcons.umbrellaBeach,
                  title: l10n.quickMenuTravel,
                  onTap: () => context.push(TravelInfoScreen.routeName),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
