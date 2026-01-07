// Comprehensive screenshot test for all PhilGo app screens
// This test navigates through all available pages and captures screenshots
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/main.dart' as app;
import 'package:philgo/widgets/home/menu/menu.grid_item.dart';
import 'package:philgo/widgets/home/menu/menu.item.dart';

/// Helper to find Font Awesome icons
Finder findFaIcon(IconData data) {
  return find.byWidgetPredicate(
    (widget) => widget is FaIcon && widget.icon == data,
  );
}

/// Helper to find menu item widgets (MenuItem or MenuGridItem) by icon
Finder findMenuItem(IconData data) {
  final Finder iconFinder = findFaIcon(data);
  final Finder gridItemFinder =
      find.ancestor(of: iconFinder, matching: find.byType(MenuGridItem));
  if (gridItemFinder.evaluate().isNotEmpty) {
    return gridItemFinder;
  }
  return find.ancestor(of: iconFinder, matching: find.byType(MenuItem));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PhilGo All Screens Screenshots', () {
    testWidgets('Complete app screenshot tour', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // ===== Helper Functions =====

      /// Navigate to menu tab
      Future<void> goToMenuTab() async {
        final Finder menuButton = find.byKey(const ValueKey('menuButton'));
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();
        }
      }

      /// Tap a menu item by icon (safely - skip if not found)
      Future<void> tapMenuItemIconSafe(IconData icon) async {
        final Finder menuItemFinder = findMenuItem(icon);
        if (menuItemFinder.evaluate().isEmpty) {
          return; // Skip if menu item not found
        }
        await tester.ensureVisible(menuItemFinder.first);
        await tester.tap(menuItemFinder.first);
        await tester.pumpAndSettle();
      }

      /// Go back using BackButton
      Future<void> tapSystemBack() async {
        // Try BackButton first (Material Design)
        final Finder backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
          return;
        }

        // Try tooltip Back
        final Finder tooltipBack = find.byTooltip('Back');
        if (tooltipBack.evaluate().isNotEmpty) {
          await tester.tap(tooltipBack.first);
          await tester.pumpAndSettle();
          return;
        }

        // Try arrow back icon
        final Finder arrowBack = find.byIcon(Icons.arrow_back);
        if (arrowBack.evaluate().isNotEmpty) {
          await tester.tap(arrowBack.first);
          await tester.pumpAndSettle();
          return;
        }
      }

      /// Close modal by tapping X icon
      Future<void> closeModalByIconSafe(IconData icon) async {
        final Finder closeIcon = findFaIcon(icon);
        if (closeIcon.evaluate().isEmpty) {
          return; // Skip if close icon not found
        }
        await tester.tap(closeIcon.last);
        await tester.pumpAndSettle();
      }

      // ===== Main Bottom Navigation Tabs =====

      /// 1. Home Screen (initial screen)
      await binding.takeScreenshot('01_home_screen');
      await Future.delayed(const Duration(milliseconds: 500));

      /// 2. Chat Tab
      final chatIcon = findFaIcon(FontAwesomeIcons.thinCommentDots);
      if (chatIcon.evaluate().isNotEmpty) {
        await tester.tap(chatIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('02_chat_list_screen');
      }

      /// 3. Forum Tab
      final forumIcon = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon.evaluate().isNotEmpty) {
        await tester.tap(forumIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('03_forum_list_screen');
      }

      /// 4. Company Tab
      final companyIcon = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (companyIcon.evaluate().isNotEmpty) {
        await tester.tap(companyIcon);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('04_company_list_screen');
      }

      /// 5. Menu Tab
      final menuButton = find.byKey(const ValueKey('menuButton'));
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('05_menu_screen');
      }

      // ===== Menu - Philippine Life Info (Full-Screen Dialogs) =====
      await goToMenuTab();

      /// 6. Notice Screen
      await tapMenuItemIconSafe(FontAwesomeIcons.bullhorn);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('06_menu_notice');
      await tester.tapAt(const Offset(10, 10)); // Tap barrier to close
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 7. Exchange Rate
      await tapMenuItemIconSafe(FontAwesomeIcons.coins);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('07_menu_exchange_rate');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 8. Weather
      await tapMenuItemIconSafe(FontAwesomeIcons.cloudSun);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('08_menu_weather');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 9. Emergency Contact
      await tapMenuItemIconSafe(FontAwesomeIcons.phoneVolume);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('09_menu_emergency');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 10. Essential Info
      await tapMenuItemIconSafe(FontAwesomeIcons.circleInfo);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('10_menu_essential_info');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 11. Monthly Living
      await tapMenuItemIconSafe(FontAwesomeIcons.calendarDays);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('11_menu_monthly_living');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      /// 12. Travel Info
      await tapMenuItemIconSafe(FontAwesomeIcons.umbrellaBeach);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('12_menu_travel_info');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await goToMenuTab();

      // ===== Menu - Forum Categories (Navigate to Forum Tab) =====

      /// 13. Freetalk Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.comments);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('13_menu_forum_freetalk');
      await goToMenuTab();

      /// 14. QnA Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.circleQuestion);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('14_menu_forum_qna');
      await goToMenuTab();

      /// 15. Greeting Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.handWave);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('15_menu_forum_greeting');
      await goToMenuTab();

      /// 16. Blog Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.blog);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('16_menu_forum_blog');
      await goToMenuTab();

      /// 17. Youtube Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.youtube);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('17_menu_forum_youtube');
      await goToMenuTab();

      /// 18. Buy and Sell Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.cartShopping);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('18_menu_forum_buyandsell');
      await goToMenuTab();

      /// 19. Wanted (Jobs) Forum
      await tapMenuItemIconSafe(FontAwesomeIcons.briefcase);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('19_menu_forum_wanted');
      await goToMenuTab();

      // ===== Menu - My Activity =====

      /// 20. Profile Edit (Route)
      await tapMenuItemIconSafe(FontAwesomeIcons.user);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('20_menu_profile_edit');
      await tapSystemBack();
      await goToMenuTab();

      /// 21. My Posts (Route)
      await tapMenuItemIconSafe(FontAwesomeIcons.clockRotateLeft);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('21_menu_my_posts');
      await tapSystemBack();
      await goToMenuTab();

      /// 22. Write Post (Dialog) - Skip screenshot, just test it opens
      // await tapMenuItemIconSafe(FontAwesomeIcons.penToSquare);
      // await tester.pumpAndSettle();
      // await closeModalByIconSafe(FontAwesomeIcons.xmark);
      // await goToMenuTab();

      /// 23. Blocked Users (Dialog)
      await tapMenuItemIconSafe(FontAwesomeIcons.usersSlash);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('22_menu_blocked_users');
      await closeModalByIconSafe(FontAwesomeIcons.xmark);
      await goToMenuTab();

      // ===== Menu - Business Directory =====

      /// 24. Business Directory (Tab Navigation)
      await tapMenuItemIconSafe(FontAwesomeIcons.building);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      // No screenshot needed - switches to company tab
      await goToMenuTab();

      /// 25. Add My Company (Route)
      await tapMenuItemIconSafe(FontAwesomeIcons.circlePlus);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('23_menu_add_company');
      await tapSystemBack();
      await goToMenuTab();

      // ===== Menu - Support =====

      /// 26. App Guide (Route with animations)
      await tapMenuItemIconSafe(FontAwesomeIcons.circleQuestion);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 5));
      await binding.takeScreenshot('24_menu_app_guide');
      await tapSystemBack();
      await goToMenuTab();

      /// 27. Terms of Service (Dialog with API call)
      await tapMenuItemIconSafe(FontAwesomeIcons.fileLines);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await binding.takeScreenshot('25_menu_terms');
      await closeModalByIconSafe(FontAwesomeIcons.lightXmark);
      await goToMenuTab();

      /// 28. Privacy Policy (Dialog with API call)
      await tapMenuItemIconSafe(FontAwesomeIcons.shieldHalved);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      await binding.takeScreenshot('26_menu_privacy');
      await closeModalByIconSafe(FontAwesomeIcons.lightXmark);
      await goToMenuTab();

      // ===== Menu - App Info =====

      /// 29. Version Screen (Route)
      await tapMenuItemIconSafe(FontAwesomeIcons.circleInfo);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('27_menu_version');
      await tapSystemBack();
      await goToMenuTab();

      // ===== Menu - Account Actions =====

      /// 30. Account Withdrawal (Route with animations)
      await tapMenuItemIconSafe(FontAwesomeIcons.userMinus);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 5));
      await binding.takeScreenshot('28_menu_account_withdrawal');
      await tapSystemBack();
      await goToMenuTab();

      // ===== Menu - Advertising (WebView) =====

      /// 31. Banner Ad WebView
      await tapMenuItemIconSafe(FontAwesomeIcons.rectangleAd);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('29_menu_banner_ad');
      await tapSystemBack();
      await goToMenuTab();

      /// 32. Point Ad WebView
      await tapMenuItemIconSafe(FontAwesomeIcons.dollarSign);
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await binding.takeScreenshot('30_menu_point_ad');
      await tapSystemBack();

      // ===== Post Related Screens =====

      /// 33. Navigate to Forum
      final forumIcon2 = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon2.evaluate().isNotEmpty) {
        await tester.tap(forumIcon2);
        await tester.pumpAndSettle();
      }

      /// 34. Post View Screen
      final Finder postCards = find.byType(InkWell);
      if (postCards.evaluate().isNotEmpty) {
        await tester.tap(postCards.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('31_post_view');
        await tapSystemBack();
      }

      /// 35. Post Create Screen
      final Finder createIcon = findFaIcon(FontAwesomeIcons.penToSquare);
      if (createIcon.evaluate().isNotEmpty) {
        await tester.tap(createIcon.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('32_post_create');
        await tapSystemBack();
      }

      // ===== Company Related Screens =====

      /// 36. Navigate to Company tab
      final companyIcon2 = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (companyIcon2.evaluate().isNotEmpty) {
        await tester.tap(companyIcon2);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
      }

      /// 37. Company View Screen
      final Finder companyCards = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString().contains('CompanyCard'),
      );
      if (companyCards.evaluate().isNotEmpty) {
        await tester.tap(companyCards.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('33_company_view');

        // Scroll down
        final scrollView = find.byType(CustomScrollView);
        if (scrollView.evaluate().isNotEmpty) {
          await tester.drag(scrollView.first, const Offset(0, -300));
          await tester.pumpAndSettle();
          await binding.takeScreenshot('34_company_view_scrolled');
        }

        await tapSystemBack();
      }

      // ===== Return to Home =====

      /// 38. Final Home Screen
      final homeIcon = findFaIcon(FontAwesomeIcons.thinHouse);
      if (homeIcon.evaluate().isNotEmpty) {
        await tester.tap(homeIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('35_home_final');
      }
    });
  });
}
