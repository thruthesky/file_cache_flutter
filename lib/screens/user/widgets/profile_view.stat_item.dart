import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// Legacy ProfileViewStatItem for backward compatibility with other screens
class ProfileViewStatItem extends StatelessWidget {
  const ProfileViewStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatCompactNumber(value),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sp.s4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
