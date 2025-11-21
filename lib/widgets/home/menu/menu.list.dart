import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/account/account.withdrawal.screen.dart';
import 'package:philgo/screens/entry/entry.screen.dart';
import 'package:philgo/screens/guide/app.guide.screen.dart';
import 'package:philgo/screens/home/home.globals.dart';
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
      title: 'Logout',
      message: 'Are you sure you want to logout?',
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
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => ProfileEditScreen.push(context),
          index: 0,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Company Directory
        MenuTile(
          icon: FontAwesomeIcons.lightBuilding,
          title: 'Company Directory',
          subtitle: 'View company members and contacts',
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            if (context.mounted) {
              NavigationState.of(
                context,
                listen: false,
              ).setHomeNavigation(HomeNavigationItem.company);
            }
          },
          index: 1,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Open Chat room
        MenuTile(
          icon: FontAwesomeIcons.lightComments,
          title: 'Open Chat Room',
          subtitle: 'Join public chat rooms',
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 150));
            if (context.mounted) {
              NavigationState.of(
                context,
                listen: false,
              ).setHomeNavigation(HomeNavigationItem.chat);
            }
          },
          index: 2,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Banner Ads
        MenuTile(
          icon: FontAwesomeIcons.lightRectangleAd,
          title: 'Banner Ads',
          subtitle: 'Manage your banner advertisements',
          onTap: () {
            WebViewScreen.push(context, bannerPageUrl(), title: 'Banner Ads');
          },
          index: 3,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Point Ads
        MenuTile(
          icon: FontAwesomeIcons.lightCoins,
          title: 'Point Ads',
          subtitle: 'Earn points by watching ads',
          onTap: () {
            WebViewScreen.push(context, pointPageUrl(), title: 'Point Ads');
          },
          index: 4,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// App Guide
        MenuTile(
          icon: FontAwesomeIcons.lightCircleQuestion,
          title: 'App Guide',
          subtitle: 'Learn how to use the app',
          onTap: () => AppGuideScreen.push(context),
          index: 5,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Terms of Users
        MenuTile(
          icon: FontAwesomeIcons.lightFileLines,
          title: 'Terms of Users',
          subtitle: 'Read our terms and conditions',
          onTap: () {
            showTermsAndConditions(context);
          },
          index: 6,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Privacy Policy
        MenuTile(
          icon: FontAwesomeIcons.lightShieldHalved,
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          onTap: () {
            showPrivacyPolicy(context);
          },
          index: 7,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Member Withdrawal
        MenuTile(
          icon: FontAwesomeIcons.lightUserMinus,
          title: 'Member Withdrawal',
          subtitle: 'Delete your account permanently',
          onTap: () {
            AccountWithdrawalScreen.push(context);
          },
          index: 8,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),

        /// Logout Button
        MenuTile(
          icon: FontAwesomeIcons.lightRightFromBracket,
          title: 'Logout',
          subtitle: 'Sign out from your account',
          onTap: _handleLogout,
          index: 9,
          isAnimated: _isAnimated,
        ),

        SizedBox(height: widget.spacing),
      ],
    );
  }
}
