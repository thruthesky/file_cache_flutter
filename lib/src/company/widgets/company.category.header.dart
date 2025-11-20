import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CompanyCategoryHeader extends StatelessWidget {
  const CompanyCategoryHeader({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    this.onCategoryTap,
  });

  final List<Map<String, dynamic>> categories;
  final String? selectedCategoryId;
  final Function(String? categoryId)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final categoryId = category['id'] as String;
          final categoryName = category['name'] as String;
          final categoryIcon = category['icon'] as IconData;
          final isSelected = selectedCategoryId == categoryId;

          return _CompanyCategoryItem(
            icon: categoryIcon,
            name: categoryName,
            isSelected: isSelected,
            onTap: () => onCategoryTap?.call(categoryId),
          );
        },
      ),
    );
  }
}

class _CompanyCategoryItem extends StatelessWidget {
  const _CompanyCategoryItem({
    required this.icon,
    required this.name,
    required this.isSelected,
    this.onTap,
  });

  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Ink(
        width: 88,
        decoration: BoxDecoration(
          color: isSelected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  icon,
                  size: 24,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
