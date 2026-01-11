import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/entertainment/golf.screen.dart';
import 'package:philgo/screens/info/entertainment/massage.screen.dart';
import 'package:philgo/screens/info/entertainment/nightlife.screen.dart';
import 'package:philgo/screens/info/entertainment/market_tour.screen.dart';
import 'package:philgo/screens/info/entertainment/seafood.screen.dart';
import 'package:philgo/screens/info/entertainment/restaurant.screen.dart';
import 'package:philgo/screens/info/entertainment/water_sports.screen.dart';
import 'package:philgo/screens/info/entertainment/island_tour.screen.dart';
import 'package:philgo/screens/info/entertainment/festival.screen.dart';

/// 먹거리, 놀거리, 볼거리 메뉴 아이템 데이터 클래스
/// Entertainment Menu Item Data Class (Food, Fun & Sights)
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class EntertainmentMenuItem {
  /// 메뉴 아이콘 (Menu Icon)
  final IconData icon;

  /// 라벨 getter 함수 (Label getter function)
  /// Lo 객체를 받아 다국어 라벨을 반환합니다.
  final String Function(Lo l10n) getLabel;

  /// 라우트 이름 (Route name)
  final String routeName;

  /// push 함수 (Push function)
  /// 해당 화면으로 이동하는 함수입니다.
  /// Function to navigate to the screen.
  final void Function(BuildContext context) push;

  const EntertainmentMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 먹거리, 놀거리, 볼거리 메뉴 아이템 목록
/// Entertainment Menu Items List (Food, Fun & Sights)
///
/// 골프, 마사지, 밤문화, 시장 투어, 해산물, 맛집, 수상스포츠, 섬투어, 축제 정보를 포함합니다.
/// Includes Golf, Massage, Nightlife, Market Tour, Seafood, Restaurant, Water Sports, Island Tour, Festival info.
class EntertainmentMenuData {
  EntertainmentMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<EntertainmentMenuItem> get items => [
        /// 골프 (Golf)
        /// 필리핀 골프 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightGolfBallTee,
          getLabel: (l10n) => l10n.entertainmentGolf,
          routeName: GolfScreen.routeName,
          push: GolfScreen.push,
        ),

        /// 마사지 (Massage)
        /// 필리핀 마사지 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightSpa,
          getLabel: (l10n) => l10n.entertainmentMassage,
          routeName: MassageScreen.routeName,
          push: MassageScreen.push,
        ),

        /// 밤문화 (Nightlife)
        /// 필리핀 밤문화 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightMartiniGlass,
          getLabel: (l10n) => l10n.entertainmentNightlife,
          routeName: NightlifeScreen.routeName,
          push: NightlifeScreen.push,
        ),

        /// 시장 투어 (Market Tour)
        /// 필리핀 시장 투어 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightStore,
          getLabel: (l10n) => l10n.entertainmentMarketTour,
          routeName: MarketTourScreen.routeName,
          push: MarketTourScreen.push,
        ),

        /// 해산물 (Seafood)
        /// 필리핀 해산물 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightShrimp,
          getLabel: (l10n) => l10n.entertainmentSeafood,
          routeName: SeafoodScreen.routeName,
          push: SeafoodScreen.push,
        ),

        /// 맛집 (Restaurant)
        /// 필리핀 맛집 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightUtensils,
          getLabel: (l10n) => l10n.entertainmentRestaurant,
          routeName: RestaurantScreen.routeName,
          push: RestaurantScreen.push,
        ),

        /// 수상스포츠 (Water Sports)
        /// 필리핀 수상스포츠 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightPersonSwimming,
          getLabel: (l10n) => l10n.entertainmentWaterSports,
          routeName: WaterSportsScreen.routeName,
          push: WaterSportsScreen.push,
        ),

        /// 섬투어 (Island Tour)
        /// 필리핀 섬투어 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightIslandTropical,
          getLabel: (l10n) => l10n.entertainmentIslandTour,
          routeName: IslandTourScreen.routeName,
          push: IslandTourScreen.push,
        ),

        /// 축제 (Festival)
        /// 필리핀 축제 정보
        EntertainmentMenuItem(
          icon: FontAwesomeIcons.lightPartyHorn,
          getLabel: (l10n) => l10n.entertainmentFestival,
          routeName: FestivalScreen.routeName,
          push: FestivalScreen.push,
        ),
      ];
}
