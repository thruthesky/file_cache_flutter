import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/transportation/express_bus.screen.dart';
import 'package:philgo/screens/info/transportation/grab_taxi.screen.dart';
import 'package:philgo/screens/info/transportation/regular_taxi.screen.dart';

/// 교통 수단 메뉴 아이템 데이터 클래스
/// Transportation Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class TransportationMenuItem {
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

  const TransportationMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 교통 수단 메뉴 아이템 목록
/// Transportation Menu Items List
///
/// 그랩 택시, 일반 택시, 고속 버스 정보를 포함합니다.
/// Includes Grab taxi, regular taxi, and express bus info.
class TransportationMenuData {
  TransportationMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<TransportationMenuItem> get items => [
    /// 그랩 택시 (Grab Taxi)
    /// 필리핀 그랩 택시 서비스 정보
    TransportationMenuItem(
      icon: FontAwesomeIcons.mobileScreen,
      getLabel: (l10n) => l10n.transportationGrabTaxi,
      routeName: GrabTaxiScreen.routeName,
      push: GrabTaxiScreen.push,
    ),

    /// 일반 택시 (Regular Taxi)
    /// 필리핀 일반 택시 이용 정보
    TransportationMenuItem(
      icon: FontAwesomeIcons.taxi,
      getLabel: (l10n) => l10n.transportationRegularTaxi,
      routeName: RegularTaxiScreen.routeName,
      push: RegularTaxiScreen.push,
    ),

    /// 고속 버스 (Express Bus)
    /// 필리핀 고속 버스 이용 정보
    TransportationMenuItem(
      icon: FontAwesomeIcons.bus,
      getLabel: (l10n) => l10n.transportationExpressBus,
      routeName: ExpressBusScreen.routeName,
      push: ExpressBusScreen.push,
    ),
  ];
}
