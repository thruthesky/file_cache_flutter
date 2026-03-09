import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/residence/bgc.screen.dart';
import 'package:philgo/screens/info/residence/ortigas.screen.dart';
import 'package:philgo/screens/info/residence/alabang.screen.dart';

/// 추천 거주 지역 메뉴 아이템 데이터 클래스
/// Recommended Residence Area Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class ResidenceMenuItem {
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

  const ResidenceMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 추천 거주 지역 메뉴 아이템 목록
/// Recommended Residence Area Menu Items List
///
/// BGC, 올티가스, 알라방 정보를 포함합니다.
/// Includes BGC, Ortigas, and Alabang info.
class ResidenceMenuData {
  ResidenceMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<ResidenceMenuItem> get items => [
    /// BGC (Bonifacio Global City)
    /// 필리핀 BGC 거주 정보
    ResidenceMenuItem(
      icon: FontAwesomeIcons.building,
      getLabel: (l10n) => l10n.residenceBgc,
      routeName: BgcScreen.routeName,
      push: BgcScreen.push,
    ),

    /// 올티가스 (Ortigas)
    /// 필리핀 올티가스 거주 정보
    ResidenceMenuItem(
      icon: FontAwesomeIcons.city,
      getLabel: (l10n) => l10n.residenceOrtigas,
      routeName: OrtigasScreen.routeName,
      push: OrtigasScreen.push,
    ),

    /// 알라방 (Alabang)
    /// 필리핀 알라방 거주 정보
    ResidenceMenuItem(
      icon: FontAwesomeIcons.houseChimney,
      getLabel: (l10n) => l10n.residenceAlabang,
      routeName: AlabangScreen.routeName,
      push: AlabangScreen.push,
    ),
  ];
}
