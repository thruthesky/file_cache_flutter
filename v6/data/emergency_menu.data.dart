import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/emergency/embassy.screen.dart';
import 'package:philgo/screens/info/emergency/hospital.screen.dart';
import 'package:philgo/screens/info/emergency/korean_association.screen.dart';
import 'package:philgo/screens/info/emergency/police_station.screen.dart';

/// 긴급 연락처 메뉴 아이템 데이터 클래스
/// Emergency Contact Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class EmergencyMenuItem {
  /// 메뉴 아이콘 (Menu Icon)
  final IconData icon;

  /// 라벨 getter 함수 (Label getter function)
  /// BuildContext를 받아 다국어 라벨을 반환합니다.
  final String Function(Lo l10n) getLabel;

  /// 라우트 이름 (Route name)
  final String routeName;

  const EmergencyMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
  });
}

/// 긴급 연락처 메뉴 아이템 목록
/// Emergency Contact Menu Items List
///
/// 대사관, 경찰서, 병원 연락처를 포함합니다.
/// Includes embassy, police station, and hospital contacts.
class EmergencyMenuData {
  EmergencyMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<EmergencyMenuItem> get items => [
    EmergencyMenuItem(
      icon: FontAwesomeIcons.landmarkFlag,
      getLabel: (l10n) => l10n.quickMenuEmbassy,
      routeName: EmbassyScreen.routeName,
    ),
    EmergencyMenuItem(
      icon: FontAwesomeIcons.peopleGroup,
      getLabel: (l10n) => l10n.quickMenuKoreanAssociation,
      routeName: KoreanAssociationScreen.routeName,
    ),
    EmergencyMenuItem(
      icon: FontAwesomeIcons.buildingShield,
      getLabel: (l10n) => l10n.quickMenuPoliceStation,
      routeName: PoliceStationScreen.routeName,
    ),
    EmergencyMenuItem(
      icon: FontAwesomeIcons.hospital,
      getLabel: (l10n) => l10n.quickMenuHospital,
      routeName: HospitalScreen.routeName,
    ),
  ];
}
