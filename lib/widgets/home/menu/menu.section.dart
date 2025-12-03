import 'package:flutter/material.dart';

/// Comic Menu Section Container
///
/// A reusable container widget that wraps menu items with a section header.
/// Used for grouping related menu items together with a title.
/// Follows Comic design principles:
/// - 2.0px border thickness
/// - No shadow (elevation: 0)
/// - Rounded corners (borderRadius: 12)
/// - Theme-based colors
/// - 8-multiples spacing
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
      // Comic design: No shadow, rounded corners (12), 2.0px border
      decoration: BoxDecoration(
        color: scheme.surface,
        // Comic design: 2.0px border with outline color
        border: Border.all(
          color: scheme.outline,
          width: 2.0,
        ),
        // Comic design: Rounded corners (borderRadius: 12)
        borderRadius: BorderRadius.circular(12),
      ),
      // Comic design: 8-multiples spacing (16px padding)
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section header - Comic design: Using Theme textTheme
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              // Comic design: Use Theme color (error for danger, onSurface for normal)
              color: isDanger ? scheme.error : scheme.onSurface,
            ),
          ),
          // Comic design: 8-multiples spacing (16px gap)
          const SizedBox(height: 16),

          /// Menu items
          ...children,
        ],
      ),
    );
  }
}
