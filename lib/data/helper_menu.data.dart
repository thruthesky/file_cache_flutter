import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/helper/house_helper.screen.dart';
import 'package:philgo/screens/info/helper/driver.screen.dart';
import 'package:philgo/screens/info/helper/tutor.screen.dart';

/// 도우미 & 가정교사 메뉴 아이템 데이터 클래스
/// Helper & Tutor Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class HelperMenuItem {
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

  const HelperMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 도우미 & 가정교사 메뉴 아이템 목록
/// Helper & Tutor Menu Items List
///
/// 하우스헬퍼, 운전기사, 가정교사 정보를 포함합니다.
/// Includes House Helper, Driver, and Tutor info.
class HelperMenuData {
  HelperMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<HelperMenuItem> get items => [
    /// 하우스헬퍼 (House Helper)
    /// 필리핀 하우스헬퍼 고용 정보
    HelperMenuItem(
      icon: FontAwesomeIcons.lightBroom,
      getLabel: (l10n) => l10n.helperHouseHelper,
      routeName: HouseHelperScreen.routeName,
      push: HouseHelperScreen.push,
    ),

    /// 운전기사 (Driver)
    /// 필리핀 운전기사 고용 정보
    HelperMenuItem(
      icon: FontAwesomeIcons.lightCarSide,
      getLabel: (l10n) => l10n.helperDriver,
      routeName: DriverScreen.routeName,
      push: DriverScreen.push,
    ),

    /// 가정교사 (Tutor)
    /// 필리핀 가정교사 고용 정보
    HelperMenuItem(
      icon: FontAwesomeIcons.lightChalkboardUser,
      getLabel: (l10n) => l10n.helperTutor,
      routeName: TutorScreen.routeName,
      push: TutorScreen.push,
    ),
  ];
}
