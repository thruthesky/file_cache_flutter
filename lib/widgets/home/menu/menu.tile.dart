import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Menu tile widget for displaying individual menu items
/// Displays an icon, title, subtitle, and chevron in a styled container
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.index,
    required this.isAnimated,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final int index;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child:
            Container(
                  padding: EdgeInsets.all(sp.s16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      // Icon container
                      IconContainer(
                        icon: icon,
                        size: 56,
                        iconSize: 24,
                        borderRadius: 16,
                      ),
                      SizedBox(width: sp.s16),
                      // Text area
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: sp.s4),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Chevron icon
                      FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                )
                .animate(target: isAnimated ? 1 : 0)
                .fadeIn(delay: (100 * index).ms, duration: 500.ms)
                .slideX(
                  begin: 0.2,
                  end: 0,
                  delay: (100 * index).ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
      ),
    );
  }
}
