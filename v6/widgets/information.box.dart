import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';

class InformationBox extends StatelessWidget {
  const InformationBox({
    super.key,
    required this.message,
    this.icon,
    this.bgColor,
  });

  final String message;
  final IconData? icon;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(sp.s8),
      decoration: BoxDecoration(
        color: bgColor ?? scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            FaIcon(
              // FontAwesomeIcons.lightCircleInfo,
              icon,
              size: 14,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
          ],

          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
