import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/settings/settings.screen.dart';
import 'package:philgo/screens/theme/theme.preview.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/widgets/home/user.stats.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  @override
  Widget build(BuildContext context) {
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
                      context.push(SettingsScreen.routeName);
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
                    RoundedIconMenu(
                      icon: FontAwesomeIcons.lightPenToSquare,
                      label: 'Edit Profile',
                      color: scheme.tertiary,
                      onPressed: () {
                        context.push(ProfileEditScreen.routeName);
                      },
                    ),

                    /// My Posts menu item
                    RoundedIconMenu(
                      icon: FontAwesomeIcons.lightFileLines,
                      label: 'My Posts',
                      color: scheme.tertiary,
                      onPressed: () {
                        // TODO: Navigate to my posts screen
                      },
                    ),

                    /// My Comments menu item
                    RoundedIconMenu(
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
                      /// App Guide menu item
                      ListTile(
                        title: const Text('App Guide'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          context.push(AppGuideScreen.routeName);
                        },
                      ),

                      /// Banner Ads menu item
                      ListTile(
                        title: const Text('Banner Ads'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          WebViewScreen.push(
                            context,
                            bannerPageUrl(),
                            title: T.bannerAdTitle,
                          );
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
                          WebViewScreen.push(
                            context,
                            pointPageUrl(),
                            title: T.bannerAdTitle,
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('Logout'),
                        trailing: FaIcon(
                          FontAwesomeIcons.lightChevronRight,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            context.go(EntryScreen.routeName);
                          }
                        },
                      ),
                      if (Config.isJaeho)
                        ListTile(
                          title: Text('Design Preview'),
                          trailing: FaIcon(
                            FontAwesomeIcons.lightChevronRight,
                            size: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                          onTap: () {
                            context.push(ThemePreviewScreen.routeName);
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
class RoundedIconMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const RoundedIconMenu({
    super.key,
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
