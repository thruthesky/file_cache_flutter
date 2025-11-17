import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/home/user.stats.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        /// AppBar with Menu Page title and settings button
        Container(
          color: scheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  /// Menu Page title
                  Text('Menu', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),

                  /// Settings button
                  IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.lightGear,
                      color: scheme.primary,
                      size: 24,
                    ),
                    onPressed: () {
                      // TODO: Navigate to settings screen
                    },
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),

        /// Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                /// User stats widget
                const UserStats(),

                const SizedBox(height: 16),

                /// Menu actions row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// Edit Profile menu item
                    _MenuAction(
                      icon: FontAwesomeIcons.lightPenToSquare,
                      label: 'Edit Profile',
                      color: scheme.tertiary,
                      onPressed: () {
                        // TODO: Navigate to edit profile screen
                      },
                    ),

                    /// My Posts menu item
                    _MenuAction(
                      icon: FontAwesomeIcons.lightFileLines,
                      label: 'My Posts',
                      color: scheme.tertiary,
                      onPressed: () {
                        // TODO: Navigate to my posts screen
                      },
                    ),

                    /// My Comments menu item
                    _MenuAction(
                      icon: FontAwesomeIcons.lightComments,
                      label: 'My Comments',
                      color: scheme.tertiary,
                      onPressed: () {
                        // TODO: Navigate to my comments screen
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                /// Menu list items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('App Guide'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          // TODO: Navigate to App Guide screen
                        },
                      ),

                      /// Banner Ads menu item
                      ListTile(
                        title: const Text('Banner Ads'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          // TODO: Navigate to banner ads screen
                        },
                      ),

                      /// Point Ads menu item
                      ListTile(
                        title: const Text('Point Ads'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          // TODO: Navigate to point ads screen
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual menu action widget with icon and label
class _MenuAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MenuAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Icon container with background
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(child: FaIcon(icon, size: 24, color: color)),
            ),
            const SizedBox(height: 8),

            /// Label
            Text(
              label,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
