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
import 'package:philgo_api/philgo_api.dart';

class NavigationState extends ChangeNotifier {
  Post? post;
  String? initialPostId;
  String? initialCategory;

  /// Get the current instance of NavigationState
  static NavigationState of(BuildContext context, {bool listen = true}) {
    return Provider.of<NavigationState>(context, listen: listen);
  }

  // Home navigation
  HomeNavigationItem homeNav = HomeNavigationItem.home;

  // Chat room order: single or group
  String roomOrder = RoomOrder.singleOrder;

  /// Chat screen navigation state
  /// Tracks which item is selected in the chat-specific bottom navigation bar
  /// 채팅 화면 전용 네비게이션 상태
  ChatNavigationItem chatNav = ChatNavigationItem.singleChat;

  void setHomeNavigation(HomeNavigationItem item) {
    homeNav = item;
    notifyListeners();
  }

  void setRoomOrder(String order) {
    roomOrder = order;
    notifyListeners();
  }

  /// Set chat navigation item
  /// Changes the selected item in the chat-specific bottom navigation bar
  /// 채팅 화면 전용 네비게이션 아이템 변경
  void setChatNavigation(ChatNavigationItem item) {
    chatNav = item;
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
