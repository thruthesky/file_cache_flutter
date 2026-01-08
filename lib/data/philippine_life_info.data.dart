import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/emergency/emergency_contact.screen.dart';
import 'package:philgo/screens/info/essential/essential_info.screen.dart';
import 'package:philgo/screens/info/exchange/exchange_rate.screen.dart';
import 'package:philgo/screens/info/monthly/monthly_living.screen.dart';
import 'package:philgo/screens/info/notice/notice.screen.dart';
import 'package:philgo/screens/info/travel/travel_info.screen.dart';
import 'package:philgo/screens/weather/weather.screen.dart';

/// 필리핀 생활 정보 메뉴 아이템 데이터 클래스
/// Philippine Life Info Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class PhilippineLifeInfoItem {
  /// 메뉴 아이콘 (Menu Icon)
  final IconData icon;

  /// 라벨 getter 함수 (Label getter function)
  /// BuildContext를 받아 다국어 라벨을 반환합니다.
  final String Function(Lo l10n) getLabel;

  /// 라우트 이름 (Route name)
  final String routeName;

  /// push 함수 (Push function)
  /// 해당 화면으로 이동하는 함수입니다.
  /// Function to navigate to the screen.
  final void Function(BuildContext context) push;

  const PhilippineLifeInfoItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 필리핀 생활 정보 메뉴 아이템 목록
/// Philippine Life Info Menu Items List
///
/// 공지, 환율, 날씨, 긴급연락처, 필수정보, 한달살기, 여행 정보를 포함합니다.
/// Includes notice, exchange rate, weather, emergency contacts,
/// essential info, monthly living, and travel info.
class PhilippineLifeInfoData {
  PhilippineLifeInfoData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<PhilippineLifeInfoItem> get items => [
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.bullhorn,
      getLabel: (l10n) => l10n.quickMenuNotice,
      routeName: NoticeScreen.routeName,
      push: NoticeScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.coins,
      getLabel: (l10n) => l10n.quickMenuExchangeRate,
      routeName: ExchangeRateScreen.routeName,
      push: ExchangeRateScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.cloudSun,
      getLabel: (l10n) => l10n.quickMenuWeather,
      routeName: WeatherScreen.routeName,
      push: WeatherScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.phoneVolume,
      getLabel: (l10n) => l10n.quickMenuEmergency,
      routeName: EmergencyContactScreen.routeName,
      push: EmergencyContactScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.circleInfo,
      getLabel: (l10n) => l10n.quickMenuEssentialInfo,
      routeName: EssentialInfoScreen.routeName,
      push: EssentialInfoScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.calendarDays,
      getLabel: (l10n) => l10n.quickMenuMonthlyLiving,
      routeName: MonthlyLivingScreen.routeName,
      push: MonthlyLivingScreen.push,
    ),
    PhilippineLifeInfoItem(
      icon: FontAwesomeIcons.umbrellaBeach,
      getLabel: (l10n) => l10n.quickMenuTravel,
      routeName: TravelInfoScreen.routeName,
      push: TravelInfoScreen.push,
    ),
  ];
}
