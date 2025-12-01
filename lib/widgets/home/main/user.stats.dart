import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
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
        // Show loading state while checking user status
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
                          T.loginToSeeProfile,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          T.viewPostsCommentsPoints,
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
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// User info row
                Row(
                  children: [
                    /// Enhanced user avatar with border
                    UserAvatar(user: user, size: 64),

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
                                : T.updateYourNickname,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          /// Level indicator with icon
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightCrown,
                                size: 14,
                                color: scheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${T.lv} ${user.level}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Three equal-sized stat boxes with icons
                Row(
                  children: [
                    /// Posts stat
                    Expanded(
                      child: StatContainer(
                        icon: FontAwesomeIcons.lightFileLines,
                        value: user.noOfPost ?? 0,
                        label: T.posts,
                        color: scheme.primary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Comments stat
                    Expanded(
                      child: StatContainer(
                        icon: FontAwesomeIcons.lightComments,
                        value: user.noOfComment ?? 0,
                        label: T.comments,
                        color: scheme.secondary,
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// Points stat
                    Expanded(
                      child: StatContainer(
                        icon: FontAwesomeIcons.lightStar,
                        value: user.point ?? 0,
                        label: T.points,
                        color: scheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Enhanced stat container with icon and color
/// Uses AspectRatio to maintain square shape while being flexible
class StatContainer extends StatelessWidget {
  const StatContainer({
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

    return AspectRatio(
      /// Maintain 1:1 aspect ratio for square shape
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          /// Solid color background with theme color
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Icon at top
              FaIcon(icon, size: 20, color: color),

              const SizedBox(height: 6),

              /// Stat value with compact formatting
              Text(
                formatCompactNumber(value),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),

              const SizedBox(height: 2),

              /// Stat label
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
