import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/state/app.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:provider/provider.dart';

/// User statistics widget showing posts, comments, and points
/// 사용자의 게시글, 댓글, 포인트를 표시하는 통계 위젯
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                /// User avatar + badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(user: user, size: 60),

                    /// Level Badge
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: scheme.surface, width: 2),
                        ),
                        child: Text(
                          "Lv.${user.level}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                /// User info and stats
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

                      const SizedBox(height: 8),

                      /// Stats row: posts, comments, points
                      Row(
                        children: [
                          StatContainer(
                            icon: FontAwesomeIcons.lightFileLines,
                            value: user.noOfPost.toString(),
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 8),

                          StatContainer(
                            icon: FontAwesomeIcons.lightComments,
                            value: user.noOfComment.toString(),
                            color: scheme.secondary,
                          ),
                          const SizedBox(width: 8),

                          StatContainer(
                            icon: FontAwesomeIcons.lightCoins,
                            value: user.point.toString(),
                            color: scheme.tertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Individual stat container with icon and value
class StatContainer extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const StatContainer({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 6),

          /// Value
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
