import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/calendar/regular_holiday.screen.dart';
import 'package:philgo/screens/info/calendar/special_working_day.screen.dart';

/// 달력/휴일 메뉴 아이템 데이터 클래스
/// Calendar/Holiday Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class CalendarMenuItem {
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

  const CalendarMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 달력/휴일 메뉴 아이템 목록
/// Calendar/Holiday Menu Items List
///
/// 정규 휴일, 근무휴일 정보를 포함합니다.
/// Includes regular holiday and special working day info.
class CalendarMenuData {
  CalendarMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<CalendarMenuItem> get items => [
    /// 정규 휴일 (Regular Holiday)
    /// 필리핀 정규 휴일 정보
    CalendarMenuItem(
      icon: FontAwesomeIcons.calendarCheck,
      getLabel: (l10n) => l10n.calendarRegularHoliday,
      routeName: RegularHolidayScreen.routeName,
      push: RegularHolidayScreen.push,
    ),

    /// 근무휴일 (Special Working Day)
    /// 필리핀 근무휴일(특별 비근무일) 정보
    CalendarMenuItem(
      icon: FontAwesomeIcons.calendarXmark,
      getLabel: (l10n) => l10n.calendarSpecialWorkingDay,
      routeName: SpecialWorkingDayScreen.routeName,
      push: SpecialWorkingDayScreen.push,
    ),
  ];
}
