import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// Menu Item Widget
///
/// A reusable menu item with icon, title, and chevron.
/// Supports custom styling for danger items (error color scheme).
/// Follows Comic design principles:
/// - No border on individual items (handled by MenuSection dividers)
/// - Theme-based colors
/// - 8-multiples spacing (16px padding)
class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  /// Icon to display in the leading position
  final IconData icon;

  /// Title text to display
  final String title;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Whether this is a danger item (uses error color scheme)
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // Comic design: Use InkWell for tap effect without ListTile overhead
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          // Comic design: 8-multiples spacing (16px padding)
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              /// Leading icon
              IconContainer(
                icon: icon,
                size: 40,
                iconSize: 18,
                borderRadius: 8,
                backgroundColor: isDanger ? scheme.errorContainer : null,
                iconColor: isDanger ? scheme.error : null,
              ),
              // Comic design: 8-multiples spacing (16px gap)
              const SizedBox(width: 16),

              /// Title text
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDanger ? scheme.error : scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              /// Trailing chevron
              FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 14,
                color: isDanger ? scheme.error : scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
