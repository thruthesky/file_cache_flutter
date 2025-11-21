import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// User statistics widget showing posts, comments, and points
class UserStats extends StatelessWidget {
  const UserStats({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Selector<AppState, User?>(
      selector: (_, appState) => appState.user,
      builder: (_, user, child) {
        if (user == null) {
          /// Show login prompt when user is not logged in
          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  /// Avatar placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 32,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// Login prompt text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Login to see your profile',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View your posts, comments, and points',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        /// Show user stats when logged in
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              /// User info card
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      /// User avatar
                      UserAvatar(user: user, size: 60),

                      const SizedBox(width: 16),

                      /// User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// User name
                            Text(
                              user.nickname.isNotEmpty
                                  ? user.nickname
                                  : 'Update your nickname',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            /// Level indicator
                            Text(
                              'Level ${user.level}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// Three equal-sized stat boxes
              Row(
                children: [
                  /// Posts stat
                  Expanded(
                    child: StatContainer(
                      value: user.noOfPost ?? 0,
                      // value: 1,
                      label: 'Posts',
                      icon: FontAwesomeIcons.lightFileLines,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Comments stat
                  Expanded(
                    child: StatContainer(
                      value: user.noOfComment ?? 0,
                      label: 'Comments',
                      icon: FontAwesomeIcons.lightComment,
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// Points stat
                  Expanded(
                    child: StatContainer(
                      value: user.point ?? 0,
                      label: 'Points',
                      icon: FontAwesomeIcons.lightStar,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat container component - displays a single stat with value and label
class StatContainer extends StatelessWidget {
  const StatContainer({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  /// Format number in compact format (e.g., 1.0K, 10.0K, 1.5M)
  String _formatNumber(int number) {
    if (number < 1000) {
      return number.toString();
    } else if (number < 1000000) {
      /// Format as K (thousands)
      final k = number / 1000;
      return '${k.toStringAsFixed(1)}K';
    } else if (number < 1000000000) {
      /// Format as M (millions)
      final m = number / 1000000;
      return '${m.toStringAsFixed(1)}M';
    } else {
      /// Format as B (billions)
      final b = number / 1000000000;
      return '${b.toStringAsFixed(1)}B';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Stat value with comma formatting
            Text(
              _formatNumber(value),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            /// Stat label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, size: 16, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// Stat icon
          ],
        ),
      ),
    );
  }
}
