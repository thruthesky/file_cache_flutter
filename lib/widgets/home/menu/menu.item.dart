import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Menu Item Widget
///
/// A reusable ListTile-based menu item with icon, title, and chevron.
/// Supports custom styling for danger items (error color scheme).
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

    // Wrap ListTile with Material to enable splash/ripple effect
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: IconContainer(
          icon: icon,
          size: 40,
          iconSize: 16,
          backgroundColor: isDanger ? scheme.errorContainer : null,
          iconColor: isDanger ? scheme.error : null,
        ),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isDanger ? scheme.error : null,
          ),
        ),
        trailing: Icon(
          FontAwesomeIcons.chevronRight,
          size: 16,
          color: isDanger ? scheme.error : null,
        ),
      ),
    );
  }
}
