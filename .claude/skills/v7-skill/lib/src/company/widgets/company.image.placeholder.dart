import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Corporate Image Placeholder Widget
///
/// Common placeholder displayed when there is no corporate image or load fails
/// Displays a category icon or a default building icon
class CompanyImagePlaceholder extends StatelessWidget {
  const CompanyImagePlaceholder({
    super.key,
    this.icon = FontAwesomeIcons.building,
    this.iconOpacity = 0.3,
  });

  /// Icon to display (default: building icon)
  final IconData icon;

  /// Icon transparency (0.0 to 1.0, default: 0.3)

  final double iconOpacity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: FaIcon(
          icon,
          size: 64,
          color: scheme.onSurfaceVariant.withValues(alpha: iconOpacity),
        ),
      ),
    );
  }
}
