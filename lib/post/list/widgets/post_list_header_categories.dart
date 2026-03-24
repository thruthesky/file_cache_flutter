import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/list/widgets/post_list_category_item.dart';

class PostListHeaderCategories extends StatefulWidget {
  const PostListHeaderCategories({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  final List<(String, String?, String)> categories;
  final int selectedIndex;
  final void Function(int index) onCategoryTap;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  /// 접힌 상태에서 보여줄 카테고리 개수
  static const int collapsedCount = 12;

  @override
  State<PostListHeaderCategories> createState() =>
      _PostListHeaderCategoriesState();
}

class _PostListHeaderCategoriesState extends State<PostListHeaderCategories> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleCount = _expanded
        ? widget.categories.length
        : widget.categories.length >
              PostListHeaderCategories.collapsedCount
          ? PostListHeaderCategories.collapsedCount
          : widget.categories.length;

    final hasMore =
        widget.categories.length > PostListHeaderCategories.collapsedCount;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 0,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search item (always first)
          _buildSearchItem(),
          // Category items
          for (int i = 0; i < visibleCount; i++)
            PostListCategoryItem(
              label: widget.categories[i].$3.tr(),
              isSelected: i == widget.selectedIndex,
              onTap: () => widget.onCategoryTap(i),
            ),
          // "더보기" only when collapsed and has more
          if (hasMore && !_expanded)
            GestureDetector(
              onTap: () => setState(() => _expanded = true),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      // "More"
                      '더보기'.tr(),
                      style: text.labelLarge?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    FaIcon(
                      FontAwesomeIcons.lightChevronDown,
                      size: 10,
                      color: color.primary,
                    ),
                  ],
                ),
              ),
            ),
          // Notification icon at the end (only when logged in)
          if (isLoggedIn)
            GestureDetector(
              onTap: widget.onNotificationTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: FaIcon(
                  FontAwesomeIcons.solidBell,
                  size: 14,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchItem() {
    return GestureDetector(
      onTap: widget.onSearchTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightMagnifyingGlass,
              size: 12,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              // "Search"
              '검색'.tr(),
              style: text.labelLarge?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
