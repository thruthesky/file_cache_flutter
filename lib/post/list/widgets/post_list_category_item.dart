import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';

class PostListCategoryItem extends StatelessWidget {
  const PostListCategoryItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.primary.withValues(alpha: 0.12) : null,
        ),
        child: Text(
          label,
          style: text.labelLarge?.copyWith(
            color: isSelected ? color.primary : color.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
