import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';

class IntroHeader extends StatelessWidget {
  const IntroHeader({
    super.key,
    required this.introTitle,
    required this.introDescription,
    this.introIcon,
    this.introWidget,
  });

  final String introTitle;
  final String introDescription;
  final IconData? introIcon;
  final Widget? introWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (introWidget != null) ...[
            introWidget!,
          ] else if (introIcon != null) ...[
            Icon(introIcon, size: 48, color: scheme.primary),
          ],

          SizedBox(height: sp.s16),
          Text(
            introTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s8),
          Text(
            introDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
