import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/emergency_menu.data.dart';
import 'package:philgo/data/immigration_menu.data.dart';
import 'package:philgo/data/philippine_life_info.data.dart';
import 'package:philgo/data/transportation_menu.data.dart';
import 'package:philgo/data/housing_menu.data.dart';
import 'package:philgo/data/car_menu.data.dart';
import 'package:philgo/data/residence_menu.data.dart';
import 'package:philgo/data/calendar_menu.data.dart';
import 'package:philgo/data/travel_destination_menu.data.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/home/home.globals.dart';
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
            /// 긴급 연락처 섹션 (Emergency Contacts Section)
            /// EmergencyMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.emergencyContactsSection,
              children: EmergencyMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => context.push(item.routeName),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 출입국 & 비자 여권 섹션 (Immigration & Visa Section)
            /// ImmigrationMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.immigrationSection,
              children: ImmigrationMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 교통 수단 섹션 (Transportation Section)
            /// TransportationMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.transportationSection,
              children: TransportationMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 콘도/주택 임대 섹션 (Housing Rental Section)
            /// HousingMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.housingSection,
              children: HousingMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 자동차 섹션 (Car Section)
            /// CarMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.carSection,
              children: CarMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 추천 거주 지역 섹션 (Recommended Residence Area Section)
            /// ResidenceMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.residenceSection,
              children: ResidenceMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 달력/휴일 섹션 (Calendar/Holiday Section)
            /// CalendarMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.calendarSection,
              children: CalendarMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 필리핀 추천 여행지 섹션 (Philippine Travel Destination Section)
            /// TravelDestinationMenuData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.travelDestinationSection,
              children: TravelDestinationMenuData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 16),

            /// 필리핀 생활 정보 섹션 (Philippine Life Info Section)
            /// PhilippineLifeInfoData를 사용하여 메뉴 아이템 생성
            MenuGridSection(
              title: l10n.philippineLifeInfo,
              children: PhilippineLifeInfoData.items
                  .map(
                    (item) => MenuGridItem(
                      icon: item.icon,
                      title: item.getLabel(l10n),
                      onTap: () => item.push(context),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
