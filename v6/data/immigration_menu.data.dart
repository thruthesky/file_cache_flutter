import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/immigration/e_travel.screen.dart';
import 'package:philgo/screens/info/immigration/retirement_visa.screen.dart';
import 'package:philgo/screens/info/immigration/travel_visa.screen.dart';
import 'package:philgo/screens/info/immigration/working_visa.screen.dart';

/// 출입국 & 비자 메뉴 아이템 데이터 클래스
/// Immigration & Visa Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class ImmigrationMenuItem {
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

  const ImmigrationMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 출입국 & 비자 메뉴 아이템 목록
/// Immigration & Visa Menu Items List
///
/// e트래블, 여행비자, 워킹비자, 은퇴비자 정보를 포함합니다.
/// Includes e-Travel, travel visa, working visa, and retirement visa info.
class ImmigrationMenuData {
  ImmigrationMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<ImmigrationMenuItem> get items => [
    /// e트래블 (E-Travel)
    /// 필리핀 전자여행허가 시스템 정보
    ImmigrationMenuItem(
      icon: FontAwesomeIcons.mobileScreenButton,
      getLabel: (l10n) => l10n.immigrationETravel,
      routeName: ETravelScreen.routeName,
      push: ETravelScreen.push,
    ),

    /// 여행비자 (Travel Visa)
    /// 필리핀 관광비자 정보
    ImmigrationMenuItem(
      icon: FontAwesomeIcons.planeDeparture,
      getLabel: (l10n) => l10n.immigrationTravelVisa,
      routeName: TravelVisaScreen.routeName,
      push: TravelVisaScreen.push,
    ),

    /// 워킹비자 (Working Visa)
    /// 필리핀 취업비자 정보
    ImmigrationMenuItem(
      icon: FontAwesomeIcons.briefcase,
      getLabel: (l10n) => l10n.immigrationWorkingVisa,
      routeName: WorkingVisaScreen.routeName,
      push: WorkingVisaScreen.push,
    ),

    /// 은퇴비자 (Retirement Visa)
    /// 필리핀 SRRV 비자 정보
    ImmigrationMenuItem(
      icon: FontAwesomeIcons.personCane,
      getLabel: (l10n) => l10n.immigrationRetirementVisa,
      routeName: RetirementVisaScreen.routeName,
      push: RetirementVisaScreen.push,
    ),
  ];
}
