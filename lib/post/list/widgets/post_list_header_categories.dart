import 'package:easy_localization/easy_localization.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        spacing: 0,
        runSpacing: 0,
        children: [
          // Search item (always first)
          _buildIconItem(
            icon: FontAwesomeIcons.lightMagnifyingGlass,
            label: '검색'.tr(),
            onTap: widget.onSearchTap,
          ),
          // Notification item (second)
          _buildIconItem(
            icon: FontAwesomeIcons.lightBell,
            label: '알림'.tr(),
            onTap: widget.onNotificationTap,
          ),
          // Category items
          for (int i = 0; i < visibleCount; i++)
            PostListCategoryItem(
              label: widget.categories[i].$3.tr(),
              isSelected: i == widget.selectedIndex,
              onTap: () => widget.onCategoryTap(i),
            ),
          // Show More / Hide toggle
          if (hasMore)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? '접기'.tr() : '더보기'.tr(),
                      style: text.labelMedium?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    FaIcon(
                      _expanded
                          ? FontAwesomeIcons.lightChevronUp
                          : FontAwesomeIcons.lightChevronDown,
                      size: 10,
                      color: color.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIconItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 12, color: color.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: text.labelMedium?.copyWith(
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
