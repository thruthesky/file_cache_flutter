import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:philgo/post/list/widgets/post_list_category_item.dart';

class PostListHeaderCategories extends StatelessWidget {
  const PostListHeaderCategories({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
  });

  final List<(String, String?, String)> categories;
  final int selectedIndex;
  final void Function(int index) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        spacing: 0,
        runSpacing: 0,
        children: [
          for (int i = 0; i < categories.length; i++)
            PostListCategoryItem(
              label: categories[i].$3.tr(),
              isSelected: i == selectedIndex,
              onTap: () => onCategoryTap(i),
            ),
        ],
      ),
    );
  }
}
