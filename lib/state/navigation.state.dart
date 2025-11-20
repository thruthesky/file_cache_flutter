// ignore: dangling_library_doc_comments
///
/// * NOTE: use this only for page navigation state.
/// * NOTE: Do not use this for passing data between screens.
///
/// The navigation state for the app
/// @Attention: Follow the state management rules
///   1. The state must be changed in multiple places.
///   2. The state must be used in multiples places (on the screen)
/// Or it should be globals.dart

import 'package:flutter/material.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class NavigationState extends ChangeNotifier {
  Object? data;
  void setData(Object? obj) {
    data = obj;
    notifyListeners();
  }

  /// Get the current instance of NavigationState
  static NavigationState of(BuildContext context, {bool listen = true}) {
    return Provider.of<NavigationState>(context, listen: listen);
  }

  // Home navigation
  HomeNavigationItem homeNav = HomeNavigationItem.home;

  // Chat room order: single or group
  String roomOrder = RoomOrder.singleOrder;

  void setHomeNavigation(HomeNavigationItem item) {
    homeNav = item;
    notifyListeners();
  }

  void setRoomOrder(String order) {
    roomOrder = order;
    notifyListeners();
  }

  void openOpenChat() {
    homeNav = HomeNavigationItem.chat;
    roomOrder = RoomOrder.openOrder;
    notifyListeners();
  }

  void openCompanyPage() {
    homeNav = HomeNavigationItem.company;
    roomOrder = RoomOrder.openOrder;
    notifyListeners();
  }
}
