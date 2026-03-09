import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/info/car/car_insurance.screen.dart';
import 'package:philgo/screens/info/car/car_purchase.screen.dart';
import 'package:philgo/screens/info/car/or_renewal.screen.dart';

/// 자동차 메뉴 아이템 데이터 클래스
/// Car Menu Item Data Class
///
/// 각 메뉴 아이템의 아이콘, 라벨 getter, 라우트 정보를 담습니다.
/// Contains icon, label getter, and route for each menu item.
class CarMenuItem {
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

  const CarMenuItem({
    required this.icon,
    required this.getLabel,
    required this.routeName,
    required this.push,
  });
}

/// 자동차 메뉴 아이템 목록
/// Car Menu Items List
///
/// 구매, 보험, OR 리뉴얼 정보를 포함합니다.
/// Includes purchase, insurance, and OR renewal info.
class CarMenuData {
  CarMenuData._();

  /// 모든 메뉴 아이템 목록 (All menu items list)
  static List<CarMenuItem> get items => [
    /// 구매 (Purchase)
    /// 필리핀 자동차 구매 정보
    CarMenuItem(
      icon: FontAwesomeIcons.cartShopping,
      getLabel: (l10n) => l10n.carPurchase,
      routeName: CarPurchaseScreen.routeName,
      push: CarPurchaseScreen.push,
    ),

    /// 보험 (Insurance)
    /// 필리핀 자동차 보험 정보
    CarMenuItem(
      icon: FontAwesomeIcons.shieldHalved,
      getLabel: (l10n) => l10n.carInsurance,
      routeName: CarInsuranceScreen.routeName,
      push: CarInsuranceScreen.push,
    ),

    /// OR 리뉴얼 (OR Renewal)
    /// 필리핀 OR 리뉴얼 정보
    CarMenuItem(
      icon: FontAwesomeIcons.fileLines,
      getLabel: (l10n) => l10n.carOrRenewal,
      routeName: OrRenewalScreen.routeName,
      push: OrRenewalScreen.push,
    ),
  ];
}
