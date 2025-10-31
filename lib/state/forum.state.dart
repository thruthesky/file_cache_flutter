import 'package:flutter/material.dart';
import 'package:philgo/philgo_app.config.dart';
import 'package:philgo/router.dart';
import 'package:provider/provider.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class ForumState extends ChangeNotifier {
  static ForumState of(BuildContext context, {bool listen = false}) {
    return Provider.of<ForumState>(context, listen: listen);
  }

  /// A state to hold the selected post & category on the forum home screen.
  PostCategoryItem homePostCategory = PhilGoAppConfig.getCategories().first;

  void setHomePostCategory(PostCategoryItem category) {
    homePostCategory = category;
    notifyListeners();
  }

  /// A state to hold the post & category for creating or updating a post.
  PostCategoryItem? editPostCategory;
  void setEditCategory(PostCategoryItem? category) {
    editPostCategory = category;
    notifyListeners();
  }
}

class HomePostCategory {
  static String get label {
    return ForumState.of(
      globalContext,
    ).homePostCategory.getLabel(globalContext);
  }

  static String get postId {
    return ForumState.of(globalContext).homePostCategory.postId;
  }

  static String? get category {
    return ForumState.of(globalContext).homePostCategory.category;
  }
}

class EditPostCategory {
  static String get label {
    return ForumState.of(
          globalContext,
        ).editPostCategory?.getLabel(globalContext) ??
        '';
  }
}
