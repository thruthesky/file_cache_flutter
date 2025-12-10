import 'package:flutter/material.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/navigation.state.dart';

extension NavExtension on BuildContext {
  void setHomeIndex(
    HomeNavigationItem item, {
    String? initialPostId,
    String? initialCategory,
  }) {
    final navState = NavigationState.of(this, listen: false);
    navState.initialPostId = initialPostId;
    navState.initialCategory = initialCategory;
    navState.setHomeNavigation(item);
  }

  void openForum(String? postId, {String? category}) {
    setHomeIndex(
      HomeNavigationItem.forum,
      initialPostId: postId,
      initialCategory: category,
    );
  }
}
