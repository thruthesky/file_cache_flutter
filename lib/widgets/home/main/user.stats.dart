import 'package:flutter/material.dart';
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
          child: Card(
            elevation: 0,

            /// Flat 2.0 - 미묘한 그림자 추가 (4% 투명도)
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000), // 4% opacity black
                    offset: Offset(0, 1),
                    blurRadius: 2,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// User info row
                    Row(
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
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 4),

                              /// Level indicator (레벨 표시) - "Level: 1" format
                              Text(
                                'Level ${user.level}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Three equal-sized stat boxes - no dividers, square, scaffold background
                    Row(
                      children: [
                        /// Posts stat
                        Expanded(
                          child: StatContainer(
                            value: user.noOfPost ?? 0,
                            label: 'Posts',
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Comments stat
                        Expanded(
                          child: StatContainer(
                            value: user.noOfComment ?? 0,
                            label: 'Comments',
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// Points stat
                        Expanded(
                          child: StatContainer(
                            value: user.point ?? 0,
                            label: 'Points',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stat container component - responsive box with scaffold background
/// Uses AspectRatio to maintain square shape while being flexible
class StatContainer extends StatelessWidget {
  const StatContainer({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AspectRatio(
      /// Maintain 1:1 aspect ratio for square shape
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          /// Use scaffold background color (same gray as page background)
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Stat value with comma formatting (no color - black by default)
            Text(
              formatCompactNumber(value),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            /// Stat label
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
