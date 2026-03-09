import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppNavigationState extends ChangeNotifier {
  static AppNavigationState of(BuildContext context) =>
      Provider.of<AppNavigationState>(context, listen: false);

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void openHomeScreen() {
    _currentIndex = 0;
    notifyListeners();
  }

  void openPostListScreen() {
    _currentIndex = 1;
    notifyListeners();
  }

  void openChatScreen() {
    _currentIndex = 2;
    notifyListeners();
  }

  void openCompanyScreen() {
    _currentIndex = 3;
    notifyListeners();
  }

  void openMenuScreen() {
    _currentIndex = 4;
    notifyListeners();
  }
}
