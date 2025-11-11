import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';

class CompanyCategoryEmpty extends StatelessWidget {
  const CompanyCategoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.inbox,
              size: 48,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        SizedBox(height: sp.s16),
        Text(
          T.noRegisteredCompanies,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sp.s8),
        Text(
          T.registerCompanyPrompt,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
