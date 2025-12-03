import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';

/// Minimal advertisement banner placeholder
/// Simple, clean design with just a thin border
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: sp.s16),
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          'Ad',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
