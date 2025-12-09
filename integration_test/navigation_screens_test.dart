import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/main.dart' as app;
import 'package:philgo/widgets/home/menu/menu.item.dart';

Finder findFaIcon(IconData data) {
  return find.byWidgetPredicate(
    (widget) => widget is FaIcon && widget.icon == data,
  );
}

Finder findMenuItemIcon(IconData data) {
  return find.descendant(of: find.byType(MenuItem), matching: findFaIcon(data));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('navigation screenshots', () {
    testWidgets('navigate bottom tabs and take screenshots', (tester) async {
      // Start app
      app.main();
      await tester.pump(const Duration(seconds: 3));

      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      Future<void> goToMenuTab() async {
        final Finder menuButton = find.byKey(const ValueKey('menuButton'));
        await tester.tap(menuButton);
        await tester.pump(const Duration(seconds: 2));
      }

      Future<void> tapMenuItemIcon(IconData icon) async {
        final Finder iconFinder = findMenuItemIcon(icon);
        expect(
          iconFinder,
          findsWidgets,
          reason: 'Menu item with icon $icon should exist',
        );
        await tester.ensureVisible(iconFinder.first);
        await tester.tap(iconFinder.first);
      }

      Future<void> tapSystemBack() async {
        final Finder tooltipBack = find.byTooltip('Back');
        if (tooltipBack.evaluate().isNotEmpty) {
          await tester.tap(tooltipBack);
        } else {
          final Finder backButton = find.byType(BackButton);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton.first);
          } else {
            await tester.pageBack();
          }
        }
        await tester.pump(const Duration(seconds: 2));
      }

      Future<void> closeModalByIcon(IconData icon) async {
        final Finder closeIcon = findFaIcon(icon);
        expect(closeIcon, findsWidgets, reason: 'Close icon $icon not found');
        await tester.tap(closeIcon.last);
        await tester.pump(const Duration(seconds: 2));
      }

      // Home tab (initial)
      await binding.takeScreenshot('home_screen');

      // Chat tab
      await tester.tap(findFaIcon(FontAwesomeIcons.thinCommentDots));
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('chat_screen');

      // Forum tab
      await tester.tap(findFaIcon(FontAwesomeIcons.thinNewspaper));
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('forum_screen');

      // Company tab
      await tester.tap(findFaIcon(FontAwesomeIcons.thinBuilding));
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('company_screen');

      // Menu tab (has a key)
      await tester.tap(find.byKey(const ValueKey('menuButton')));
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('menu_screen');

      // Menu items (skip logout)
      await goToMenuTab();

      // Profile edit
      await tapMenuItemIcon(FontAwesomeIcons.user);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_edit_profile');
      await tapSystemBack();
      await goToMenuTab();

      // Language settings
      await tapMenuItemIcon(FontAwesomeIcons.globe);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_language_settings');
      await tapSystemBack();
      await goToMenuTab();

      // Business directory (switches to company tab)
      await tapMenuItemIcon(FontAwesomeIcons.building);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_business_directory');
      await goToMenuTab();

      // Open chat (switches to chat tab)
      await tapMenuItemIcon(FontAwesomeIcons.comments);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_open_chat');
      await goToMenuTab();

      // Blocked users dialog
      await tapMenuItemIcon(FontAwesomeIcons.usersSlash);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_blocked_users_dialog');
      await closeModalByIcon(FontAwesomeIcons.xmark);
      await goToMenuTab();

      // Banner ad web view
      await tapMenuItemIcon(FontAwesomeIcons.rectangleAd);
      await tester.pump(const Duration(seconds: 4));
      await binding.takeScreenshot('menu_banner_ad');
      await tapSystemBack();
      await goToMenuTab();

      // Point ad web view
      await tapMenuItemIcon(FontAwesomeIcons.dollarSign);
      await tester.pump(const Duration(seconds: 4));
      await binding.takeScreenshot('menu_point_ad');
      await tapSystemBack();
      await goToMenuTab();

      // App guide screen
      await tapMenuItemIcon(FontAwesomeIcons.circleQuestion);
      await tester.pump(const Duration(seconds: 3));
      await binding.takeScreenshot('menu_app_guide');
      await tapSystemBack();
      await goToMenuTab();

      // Terms of service modal
      await tapMenuItemIcon(FontAwesomeIcons.fileLines);
      await tester.pump(const Duration(seconds: 4));
      await binding.takeScreenshot('menu_terms_dialog');
      await closeModalByIcon(FontAwesomeIcons.lightXmark);
      await goToMenuTab();

      // Privacy policy modal
      await tapMenuItemIcon(FontAwesomeIcons.shieldHalved);
      await tester.pump(const Duration(seconds: 4));
      await binding.takeScreenshot('menu_privacy_dialog');
      await closeModalByIcon(FontAwesomeIcons.lightXmark);
      await goToMenuTab();

      // Account withdrawal screen
      await tapMenuItemIcon(FontAwesomeIcons.userMinus);
      await tester.pump(const Duration(seconds: 4));
      await binding.takeScreenshot('menu_account_withdrawal');
      await tapSystemBack();
    });
  });
}
