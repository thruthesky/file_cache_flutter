import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/housing/airbnb.screen.dart';
import 'package:philgo/screens/info/housing/hotel.screen.dart';
import 'package:philgo/screens/info/housing/monthly_rent.screen.dart';

/// 콘도/주택 임대 메뉴 아이템 데이터 클래스
/// Housing Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class HousingMenuItem {
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

  const HousingMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 콘도/주택 임대 메뉴 아이템 목록
/// Housing Menu Items List
///
/// 월세, 에어비앤비, 호텔 정보를 포함합니다.
/// Includes monthly rent, Airbnb, and hotel info.
class HousingMenuData {
  HousingMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<HousingMenuItem> get items => [
    /// 월세 (Monthly Rent)
    /// 필리핀 월세/장기 임대 정보
    HousingMenuItem(
      icon: FontAwesomeIcons.key,
      getLabel: (l10n) => l10n.housingMonthlyRent,
      routeName: MonthlyRentScreen.routeName,
      push: MonthlyRentScreen.push,
    ),

    /// 에어비앤비 (Airbnb)
    /// 필리핀 에어비앤비 정보
    HousingMenuItem(
      icon: FontAwesomeIcons.airbnb,
      getLabel: (l10n) => l10n.housingAirbnb,
      routeName: AirbnbScreen.routeName,
      push: AirbnbScreen.push,
    ),

    /// 호텔 (Hotel)
    /// 필리핀 호텔 정보
    HousingMenuItem(
      icon: FontAwesomeIcons.hotel,
      getLabel: (l10n) => l10n.housingHotel,
      routeName: HotelScreen.routeName,
      push: HotelScreen.push,
    ),
  ];
}
