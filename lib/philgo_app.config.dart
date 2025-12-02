import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class PhilGoAppConfig {
  static List<PostCategoryItem> getCategories() {
    final List<PostCategoryItem> categories = [
      if (Config.isDevelopment || Config.isJaeho)
        PostCategoryItem(postId: 'temp', category: null),
      PostCategoryItem(postId: 'freetalk', category: null),
      PostCategoryItem(postId: 'qna', category: null),
      PostCategoryItem(postId: 'freetalk', category: 'discussion'),
      PostCategoryItem(postId: 'business', category: null),
      PostCategoryItem(postId: 'buyandsell', category: null),
      PostCategoryItem(postId: 'buyandsell', category: '호텔'),
      PostCategoryItem(postId: 'buyandsell', category: '렌트카'),
      PostCategoryItem(postId: 'wanted', category: null),
    ];

    return categories;
  }
}
