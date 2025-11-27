import 'package:flutter/material.dart';

/// Menu Section Container
///
/// A reusable container widget that wraps menu items with a section header.
/// Used for grouping related menu items together with a title.
class MenuSection extends StatelessWidget {
  const MenuSection({
    super.key,
    required this.title,
    required this.children,
    this.isDanger = false,
  });

  /// Section title displayed at the top
  final String title;

  /// List of menu items to display in this section
  final List<Widget> children;

  /// Whether this section is a danger zone (displays title in error color)
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(color: scheme.surface),
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isDanger ? scheme.error : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),

          /// Menu items
          ...children,
        ],
      ),
    );
  }
}
