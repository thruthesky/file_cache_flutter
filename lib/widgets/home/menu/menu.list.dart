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
import 'package:philgo/widgets/dialogs/policy.dialogs.dart';
import 'package:philgo/widgets/home/menu/menu.tile.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MenuList extends StatefulWidget {
  final double spacing;
  const MenuList({super.key, this.spacing = 16});

  @override
  State<MenuList> createState() => _MenuListState();
}

class _MenuListState extends State<MenuList> {
  bool _isAnimated = false;
  @override
  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        _isAnimated = true;
      });
    }
  }

  /// 로그아웃 처리
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
    return Column(
      children: [
        /// Edit Profile
        MenuTile(
          icon: FontAwesomeIcons.lightUser,
          title: Lo.of(context)!.editProfileTitle,
          subtitle: Lo.of(context)!.editProfileSubtitle,
          onTap: () => ProfileEditScreen.push(context),
          index: 0,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Language Settings
        MenuTile(
          icon: FontAwesomeIcons.lightLanguage,
          title: Lo.of(context)!.languageTitle,
          subtitle: Lo.of(context)!.languageSubtitle,
          onTap: () => LanguageScreen.push(context),
          index: 1,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Company Directory
        MenuTile(
          icon: FontAwesomeIcons.lightBuilding,
          title: Lo.of(context)!.businessDirectoryTitle,
          subtitle: Lo.of(context)!.businessDirectorySubtitle,
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            if (context.mounted) {
              NavigationState.of(
                context,
                listen: false,
              ).setHomeNavigation(HomeNavigationItem.company);
            }
          },
          index: 2,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Open Chat room
        MenuTile(
          icon: FontAwesomeIcons.lightComments,
          title: Lo.of(context)!.openChatTitle,
          subtitle: Lo.of(context)!.openChatSubtitle,
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            if (context.mounted) {
              NavigationState.of(
                context,
                listen: false,
              ).setHomeNavigation(HomeNavigationItem.chat);
            }
          },
          index: 3,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Banner Ads
        MenuTile(
          icon: FontAwesomeIcons.lightRectangleAd,
          title: Lo.of(context)!.bannerAdTitle,
          subtitle: Lo.of(context)!.bannerAdSubtitle,
          onTap: () {
            WebViewScreen.push(
              context,
              bannerPageUrl(),
              title: Lo.of(context)!.bannerAdTitle,
            );
          },
          index: 4,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Point Ads
        MenuTile(
          icon: FontAwesomeIcons.lightCoins,
          title: Lo.of(context)!.pointAdTitle,
          subtitle: Lo.of(context)!.pointAdSubtitle,
          onTap: () {
            WebViewScreen.push(
              context,
              pointPageUrl(),
              title: Lo.of(context)!.pointAdTitle,
            );
          },
          index: 5,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// App Guide
        MenuTile(
          icon: FontAwesomeIcons.lightCircleQuestion,
          title: Lo.of(context)!.appGuideTitle,
          subtitle: Lo.of(context)!.appGuideSubtitle,
          onTap: () => AppGuideScreen.push(context),
          index: 6,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Terms of Users
        MenuTile(
          icon: FontAwesomeIcons.lightFileLines,
          title: Lo.of(context)!.termsOfServiceTitle,
          subtitle: Lo.of(context)!.termsOfServiceSubtitle,
          onTap: () {
            showTermsAndConditions(context);
          },
          index: 7,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Privacy Policy
        MenuTile(
          icon: FontAwesomeIcons.lightShieldHalved,
          title: Lo.of(context)!.privacyPolicyTitle,
          subtitle: Lo.of(context)!.privacyPolicySubtitle,
          onTap: () {
            showPrivacyPolicy(context);
          },
          index: 8,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Member Withdrawal
        MenuTile(
          icon: FontAwesomeIcons.lightUserMinus,
          title: Lo.of(context)!.withdrawTitle,
          subtitle: Lo.of(context)!.withdrawSubtitle,
          onTap: () {
            AccountWithdrawalScreen.push(context);
          },
          index: 9,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Logout Button
        MenuTile(
          icon: FontAwesomeIcons.lightRightFromBracket,
          title: Lo.of(context)!.logoutTitle,
          subtitle: Lo.of(context)!.logoutSubtitle,
          onTap: _handleLogout,
          index: 10,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),
      ],
    );
  }
}
