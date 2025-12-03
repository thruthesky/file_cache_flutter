import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../philgo_v6_flutter.dart';

class CompanyContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const CompanyContactButton({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        // Comic design: Border radius 12 for large elements
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            // Comic design: Border radius 12 for large elements
            borderRadius: BorderRadius.circular(12),
            // Comic design: 2.0px border with outline color
            border: Border.all(
              color: scheme.outline,
              width: 2.0,
            ),
          ),
          child: Row(
            children: [
              IconContainer(
                icon: icon,
                size: 36,
                iconSize: 20,
                borderRadius: 8,
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                iconColor: scheme.primary,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(value, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.lightChevronRight,
                color: scheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
