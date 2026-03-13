import 'package:flutter/material.dart';
import 'package:philgo/app.config.dart';
import 'package:provider/provider.dart';

class AppNavigationState extends ChangeNotifier {
  static AppNavigationState of(BuildContext context) =>
      Provider.of<AppNavigationState>(context, listen: false);

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  String _selectedPostId = forumCategories[0].$1;
  String get selectedPostId => _selectedPostId;

  String? _selectedCategory = forumCategories[0].$2;
  String? get selectedCategory => _selectedCategory;

  /// Computed index for backward compat (category tab highlighting)
  int get selectedForumIndex {
    final index = forumCategories.indexWhere(
      (item) => item.$1 == _selectedPostId && item.$2 == _selectedCategory,
    );
    return index < 0 ? 0 : index;
  }

  void openHomeScreen() {
    _currentIndex = 0;
    notifyListeners();
  }

  void openPostListScreen({String? postId, String? category}) {
    if (postId != null) {
      _selectedPostId = postId;
      _selectedCategory = category;
    }
    _currentIndex = 1;
    notifyListeners();
  }

  void setSelectedForum(String postId, String? category) {
    if (_selectedPostId == postId && _selectedCategory == category) return;
    _selectedPostId = postId;
    _selectedCategory = category;
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
