import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/screens/settings/language.screen.dart';
import 'package:philgo/screens/user/profile.edit.screen.dart';
import 'package:philgo/screens/webview/webview.screen.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';
import 'package:philgo/widgets/home/menu/menu.item.dart';
import 'package:philgo/widgets/home/menu/menu.section.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MenuHome extends StatefulWidget {
  const MenuHome({super.key});

  @override
  State<MenuHome> createState() => _MenuHomeState();
}

class _MenuHomeState extends State<MenuHome> {
  /// Handle logout
  Future<void> _handleLogout() async {
    final confirmed = await showConfirmDialog(
      title: Lo.of(context)!.logoutTitle,
      message: Lo.of(context)!.logoutConfirmMessage,
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        context.go(EntryScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        /// Top SafeArea
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Menu', style: theme.textTheme.titleLarge),
                const Spacer(),
              ],
            ),
          ),
        ),

        /// Menu content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              spacing: 24,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Account Section
                MenuSection(
                  title: 'Account',
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.user,
                      title: Lo.of(context)!.editProfile,
                      onTap: () => ProfileEditScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.globe,
                      title: Lo.of(context)!.languageTitle,
                      onTap: () => LanguageScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.building,
                      title: Lo.of(context)!.businessDirectoryTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.company);
                        }
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.comments,
                      title: Lo.of(context)!.openChatTitle,
                      onTap: () async {
                        await Future.delayed(const Duration(milliseconds: 150));
                        if (context.mounted) {
                          NavigationState.of(
                            context,
                            listen: false,
                          ).setHomeNavigation(HomeNavigationItem.chat);
                        }
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.usersSlash,
                      title: 'Blocked Users',
                      onTap: () async {
                        showBlockedUserListDialog(context);
                      },
                    ),
                  ],
                ),

                /// Advertising Section
                MenuSection(
                  title: 'Advertising',
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.rectangleAd,
                      title: Lo.of(context)!.bannerAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          bannerPageUrl(),
                          title: Lo.of(context)!.bannerAdTitle,
                        );
                      },
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.dollarSign,
                      title: Lo.of(context)!.pointAdTitle,
                      onTap: () {
                        WebViewScreen.push(
                          context,
                          pointPageUrl(),
                          title: Lo.of(context)!.pointAdTitle,
                        );
                      },
                    ),
                  ],
                ),

                /// Support & Information Section
                MenuSection(
                  title: 'Support',
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.circleQuestion,
                      title: Lo.of(context)!.appGuideTitle,
                      onTap: () => AppGuideScreen.push(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.fileLines,
                      title: Lo.of(context)!.termsOfServiceTitle,
                      onTap: () => showTermsAndConditions(context),
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.shieldHalved,
                      title: Lo.of(context)!.privacyPolicyTitle,
                      onTap: () => showPrivacyPolicy(context),
                    ),
                  ],
                ),

                /// Danger Zone Section
                MenuSection(
                  title: 'Danger Zone',
                  isDanger: true,
                  children: [
                    MenuItem(
                      icon: FontAwesomeIcons.userMinus,
                      title: Lo.of(context)!.withdrawTitle,
                      onTap: () => AccountWithdrawalScreen.push(context),
                      isDanger: true,
                    ),
                    MenuItem(
                      icon: FontAwesomeIcons.rightFromBracket,
                      title: Lo.of(context)!.logoutTitle,
                      onTap: _handleLogout,
                      isDanger: true,
                    ),
                  ],
                ),
                SizedBox(height: sp.s16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
