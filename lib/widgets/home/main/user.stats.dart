import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// Minimalist inline user profile and statistics
/// Clean design with no containers, just text and numbers
class UserStats extends StatelessWidget {
  const UserStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Selector<AppState, User?>(
      selector: (_, appState) => appState.user,
      builder: (_, user, child) {
        if (user == null) {
          /// Simple login prompt
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: sp.s16),
            child: Column(
              children: [
                Text(
                  T.loginToSeeProfile,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms);
        }

        /// Minimalist inline profile
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sp.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Avatar and name row
              Row(
                children: [
                  /// Small avatar
                  UserAvatar(user: user, size: 48)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 300.ms),

                  SizedBox(width: sp.s12),

                  /// Name and level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.nickname.isNotEmpty
                              ? user.nickname
                              : T.updateYourNickname,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: sp.s4),
                        Text(
                          '${T.lv} ${user.level ?? 0}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 100.ms)
                        .slideX(begin: -0.2, end: 0, duration: 300.ms),
                  ),
                ],
              ),

              SizedBox(height: sp.s20),

              /// Simple stats row - just numbers and labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// Posts
                  _MinimalStat(
                    value: user.noOfPost ?? 0,
                    label: T.posts,
                  ).animate().fadeIn(duration: 300.ms, delay: 150.ms),

                  /// Comments
                  _MinimalStat(
                    value: user.noOfComment ?? 0,
                    label: T.comments,
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                  /// Points
                  _MinimalStat(
                    value: user.point ?? 0,
                    label: T.points,
                  ).animate().fadeIn(duration: 300.ms, delay: 250.ms),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms);
      },
    );
  }
}

/// Minimal stat item - just number and label, no decoration
class _MinimalStat extends StatelessWidget {
  const _MinimalStat({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Large number
        Text(
          formatCompactNumber(value),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),

        /// Small label
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

/// Legacy StatItem for backward compatibility with other screens
class StatItem extends StatelessWidget {
  const StatItem({
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
