import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/settings/language.screen.dart';
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';

class SettingsScreen extends StatelessWidget {
  static String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              /// Language Settings menu item
              ListTile(
                title: const Text('Language Settings'),
                trailing: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                onTap: () => context.push(LanguageScreen.routeName),
              ),

              /// Terms of Use menu item
              ListTile(
                title: const Text('Terms of Use'),
                trailing: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                onTap: () => showTermsAndConditions(context),
              ),

              /// Privacy Policy menu item
              ListTile(
                title: const Text('Privacy Policy'),
                trailing: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                onTap: () => showPrivacyPolicy(context),
              ),

              /// Member Withdrawal menu item
              ListTile(
                title: const Text('Member Withdrawal'),
                trailing: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                onTap: () => context.push(AccountWithdrawalScreen.routeName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
