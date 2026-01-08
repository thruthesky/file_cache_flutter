import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/travel_destination/manila.screen.dart';
import 'package:philgo/screens/info/travel_destination/cebu.screen.dart';
import 'package:philgo/screens/info/travel_destination/subic.screen.dart';
import 'package:philgo/screens/info/travel_destination/bohol.screen.dart';
import 'package:philgo/screens/info/travel_destination/boracay.screen.dart';
import 'package:philgo/screens/info/travel_destination/palawan.screen.dart';

/// 필리핀 추천 여행지 메뉴 아이템 데이터 클래스
/// Philippine Travel Destination Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class TravelDestinationMenuItem {
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

  const TravelDestinationMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 필리핀 추천 여행지 메뉴 아이템 목록
/// Philippine Travel Destination Menu Items List
///
/// 마닐라, 세부, 수빅, 보홀, 보라카이, 팔라완 정보를 포함합니다.
/// Includes Manila, Cebu, Subic, Bohol, Boracay, Palawan info.
class TravelDestinationMenuData {
  TravelDestinationMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<TravelDestinationMenuItem> get items => [
    /// 마닐라 (Manila)
    /// 필리핀 마닐라 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.city,
      getLabel: (l10n) => l10n.travelDestinationManila,
      routeName: ManilaScreen.routeName,
      push: ManilaScreen.push,
    ),

    /// 세부 (Cebu)
    /// 필리핀 세부 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.umbrellaBeach,
      getLabel: (l10n) => l10n.travelDestinationCebu,
      routeName: CebuScreen.routeName,
      push: CebuScreen.push,
    ),

    /// 수빅 (Subic)
    /// 필리핀 수빅 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.anchor,
      getLabel: (l10n) => l10n.travelDestinationSubic,
      routeName: SubicScreen.routeName,
      push: SubicScreen.push,
    ),

    /// 보홀 (Bohol)
    /// 필리핀 보홀 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.mountain,
      getLabel: (l10n) => l10n.travelDestinationBohol,
      routeName: BoholScreen.routeName,
      push: BoholScreen.push,
    ),

    /// 보라카이 (Boracay)
    /// 필리핀 보라카이 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.sun,
      getLabel: (l10n) => l10n.travelDestinationBoracay,
      routeName: BoracayScreen.routeName,
      push: BoracayScreen.push,
    ),

    /// 팔라완 (Palawan)
    /// 필리핀 팔라완 여행 정보
    TravelDestinationMenuItem(
      icon: FontAwesomeIcons.water,
      getLabel: (l10n) => l10n.travelDestinationPalawan,
      routeName: PalawanScreen.routeName,
      push: PalawanScreen.push,
    ),
  ];
}
