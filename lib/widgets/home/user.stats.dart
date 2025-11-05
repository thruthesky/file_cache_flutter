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
    return Selector<AppState, User?>(
      selector: (_, appState) => appState.user,
      builder: (_, user, child) {
        if (user == null) {
          /// Show login prompt when user is not logged in (로그인하지 않은 경우 로그인 안내 표시)
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
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'View your posts, comments, and points',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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

        /// TODO: Replace with actual user data from user model
        final mockPosts = 42;
        final mockComments = 128;
        final mockPoints = 2560;

        /// Show user stats when logged in (로그인한 경우 사용자 통계 표시)
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
            children: [
              /// User avatar (사용자 아바타)
              UserAvatar(user: user, size: 60),
              const SizedBox(width: 16),

              /// User info and stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// User name
                    Text(
                      user.nickname.isNotEmpty ? user.nickname : user.uid,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    /// Stats row: posts, comments, points with icons and containers
                    Row(
                      children: [
                        /// Number of posts with icon
                        StatContainer(
                          icon: FontAwesomeIcons.lightFileLines,
                          value: mockPosts.toString(),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),

                        /// Number of comments with icon
                        StatContainer(
                          icon: FontAwesomeIcons.lightComments,
                          value: mockComments.toString(),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),

                        /// Points with icon
                        StatContainer(
                          icon: FontAwesomeIcons.lightCoins,
                          value: mockPoints.toString(),
                          color: Theme.of(context).colorScheme.tertiary,
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

/// Individual stat container with icon, value, and label
class StatContainer extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Value text
  final String value;

  /// Color for icon and value
  final Color color;

  const StatContainer({
    super.key,
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Icon
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 6),

          /// Value and label text
          RichText(
            text: TextSpan(
              children: [
                /// Value in bold
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
