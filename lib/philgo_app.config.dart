import 'package:v6_apps/v6_apps.dart';

class PhilGoAppConfig {
  static List<PostCategoryItem> getCategories() {
    final List<PostCategoryItem> categories = [
      if (Config.isDevelopment)
        PostCategoryItem(postId: 'temp', category: null),
      PostCategoryItem(postId: 'freetalk', category: null),
      PostCategoryItem(postId: 'qna', category: null),
      // PostCategoryItem(postId: 'freetalk', category: 'discussion'),
      PostCategoryItem(postId: 'business', category: null),
      PostCategoryItem(postId: 'buyandsell', category: null),
      PostCategoryItem(postId: 'buyandsell', category: 'hotel'),
      PostCategoryItem(postId: 'buyandsell', category: '렌트카'),
      PostCategoryItem(postId: 'wanted', category: null),
    ];

    return categories;
  }
}
