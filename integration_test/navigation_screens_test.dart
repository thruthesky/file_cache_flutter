import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/main.dart' as app;
import 'package:philgo/widgets/home/menu/menu.item.dart';
import 'package:philgo_api/src/company/widgets/company.card.dart';

Finder findFaIcon(IconData data) {
  return find.byWidgetPredicate(
    (widget) => widget is FaIcon && widget.icon == data,
  );
}

Finder findMenuItemIcon(IconData data) {
  return find.descendant(of: find.byType(MenuItem), matching: findFaIcon(data));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('navigation screenshots', () {
    testWidgets('navigate bottom tabs and take screenshots', (tester) async {
      // Start app for this test
      app.main();
      await tester.pumpAndSettle();

      // Home tab (initial)
      await binding.takeScreenshot('home_screen');

      // Chat tab
      final chatIcon = findFaIcon(FontAwesomeIcons.thinCommentDots);
      if (chatIcon.evaluate().isNotEmpty) {
        await tester.tap(chatIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('chat_screen');
      }

      // Forum tab
      final forumIcon = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon.evaluate().isNotEmpty) {
        await tester.tap(forumIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('forum_screen');
      }

      // Company tab - use pump with timeout to handle slow loading
      final companyIcon = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (companyIcon.evaluate().isNotEmpty) {
        await tester.tap(companyIcon);
        // Wait for initial frame
        await tester.pump();
        // Wait for a reasonable time but don't wait for all animations
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('company_screen');
      }

      // Menu tab (has a key)
      final menuButton = find.byKey(const ValueKey('menuButton'));
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('menu_screen');
      }
    });

    testWidgets('navigating the post related pages', (tester) async {
      // Start app for this test
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Forum tab
      final forumIcon = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon.evaluate().isNotEmpty) {
        await tester.tap(forumIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('forum_post_list');
      }

      // Try to find and tap the first post in the list
      final Finder postCards = find.byType(InkWell);
      if (postCards.evaluate().isNotEmpty) {
        await tester.tap(postCards.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('post_view_screen');

        // Go back to forum list
        final Finder backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Navigate to post create screen (if create button exists)
      final Finder createButton = find.byTooltip('Create Post');
      if (createButton.evaluate().isEmpty) {
        // Try finding by icon instead
        final Finder createIcon = findFaIcon(FontAwesomeIcons.penToSquare);
        if (createIcon.evaluate().isNotEmpty) {
          await tester.tap(createIcon.first);
          await tester.pumpAndSettle();
          await binding.takeScreenshot('post_create_screen');

          // Close the create screen
          final Finder backBtn = find.byType(BackButton);
          if (backBtn.evaluate().isNotEmpty) {
            await tester.tap(backBtn.first);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('navigating the company pages', (tester) async {
      // Start app for this test
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Company tab - use pump with timeout to handle slow loading
      final companyIcon = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (companyIcon.evaluate().isNotEmpty) {
        await tester.tap(companyIcon);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('company_list_screen');
      }

      // Try to find and tap the first company card
      final Finder companyCards = find.byType(CompanyCard);
      if (companyCards.evaluate().isNotEmpty) {
        await tester.tap(companyCards.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('company_view_screen');

        // Scroll down to see more content
        final scrollView = find.byType(CustomScrollView);
        if (scrollView.evaluate().isNotEmpty) {
          await tester.drag(scrollView.first, const Offset(0, -300));
          await tester.pumpAndSettle();
          await binding.takeScreenshot('company_view_scrolled');
        }

        // Go back to company list
        final Finder backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Try to access company form/create screen if available
      final Finder addButton = find.byTooltip('Add Company');
      if (addButton.evaluate().isNotEmpty) {
        await tester.tap(addButton.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('company_form_screen');

        // Close the form screen
        final Finder backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('navigating the menu items', (tester) async {
      // Start app for this test
      app.main();
      await tester.pumpAndSettle();

      Future<void> goToMenuTab() async {
        final Finder menuButton = find.byKey(const ValueKey('menuButton'));
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();
        }
      }

      Future<void> tapMenuItemIconSafe(IconData icon) async {
        final Finder iconFinder = findMenuItemIcon(icon);
        if (iconFinder.evaluate().isEmpty) {
          return; // Skip if menu item not found
        }
        await tester.ensureVisible(iconFinder.first);
        await tester.tap(iconFinder.first);
      }

      Future<void> tapSystemBack() async {
        // Try multiple ways to go back
        final Finder backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton.first);
          await tester.pumpAndSettle();
          return;
        }

        final Finder tooltipBack = find.byTooltip('Back');
        if (tooltipBack.evaluate().isNotEmpty) {
          await tester.tap(tooltipBack.first);
          await tester.pumpAndSettle();
          return;
        }

        final Finder arrowBack = find.byIcon(Icons.arrow_back);
        if (arrowBack.evaluate().isNotEmpty) {
          await tester.tap(arrowBack.first);
          await tester.pumpAndSettle();
          return;
        }

        // Last resort: use system back
        await tester.pageBack();
        await tester.pumpAndSettle();
      }

      Future<void> closeModalByIconSafe(IconData icon) async {
        final Finder closeIcon = findFaIcon(icon);
        if (closeIcon.evaluate().isEmpty) {
          return; // Skip if close icon not found
        }
        await tester.tap(closeIcon.last);
        await tester.pumpAndSettle();
      }

      // Navigate to menu tab
      await goToMenuTab();

      // Profile edit
      await tapMenuItemIconSafe(FontAwesomeIcons.user);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('menu_edit_profile');
      await tapSystemBack();
      await goToMenuTab();

      // Language settings
      await tapMenuItemIconSafe(FontAwesomeIcons.globe);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('menu_language_settings');
      await tapSystemBack();
      await goToMenuTab();

      // Business directory (switches to company tab)
      await tapMenuItemIconSafe(FontAwesomeIcons.building);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      // await binding.takeScreenshot('menu_business_directory');
      await goToMenuTab();

      // Open chat (switches to chat tab)
      await tapMenuItemIconSafe(FontAwesomeIcons.comments);
      await tester.pumpAndSettle();
      // await binding.takeScreenshot('menu_open_chat');
      await goToMenuTab();

      // Blocked users dialog
      await tapMenuItemIconSafe(FontAwesomeIcons.usersSlash);
      await tester.pumpAndSettle();
      await binding.takeScreenshot('menu_blocked_users_dialog');
      await closeModalByIconSafe(FontAwesomeIcons.xmark);
      await goToMenuTab();

      // Banner ad web view - just take a quick screenshot, don't wait for full load
      // (webviews may have Cloudflare or other security checks that block automation)
      final bannerAdIcon = findMenuItemIcon(FontAwesomeIcons.rectangleAd);
      if (bannerAdIcon.evaluate().isNotEmpty) {
        await tester.ensureVisible(bannerAdIcon.first);
        await tester.tap(bannerAdIcon.first);
        await tester.pump(); // Initial render
        await tester.pump(
          const Duration(seconds: 2),
        ); // Brief wait for webview to start
        await binding.takeScreenshot('menu_banner_ad');
        // Go back immediately
        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
        await goToMenuTab();
      }

      // Point ad web view - just take a quick screenshot, don't wait for full load
      final pointAdIcon = findMenuItemIcon(FontAwesomeIcons.dollarSign);
      if (pointAdIcon.evaluate().isNotEmpty) {
        await tester.ensureVisible(pointAdIcon.first);
        await tester.tap(pointAdIcon.first);
        await tester.pump(); // Initial render
        await tester.pump(
          const Duration(seconds: 2),
        ); // Brief wait for webview to start
        await binding.takeScreenshot('menu_point_ad');
        // Go back immediately
        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
        await goToMenuTab();
      }

      // App guide screen - has animations with postFrameCallback
      await tapMenuItemIconSafe(FontAwesomeIcons.circleQuestion);
      await tester.pump(); // Initial render
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Wait for postFrameCallback
      await tester.pump(const Duration(seconds: 5)); // Wait for animations
      await binding.takeScreenshot('menu_app_guide');

      // Go back to menu
      final backBtn = find.byType(BackButton);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn.first);
        await tester.pumpAndSettle();
      }
      await goToMenuTab();

      // Terms of service modal - fetches data from API with loading dialog
      await tapMenuItemIconSafe(FontAwesomeIcons.fileLines);
      await tester.pump(); // Initial tap
      await tester.pump(const Duration(seconds: 1)); // Wait for loading dialog
      await tester.pump(const Duration(seconds: 3)); // Wait for API call
      await tester.pump(); // Render modal
      await binding.takeScreenshot('menu_terms_dialog');
      // Close the modal - look for X button
      final termsCloseBtn = findFaIcon(FontAwesomeIcons.lightXmark);
      if (termsCloseBtn.evaluate().isNotEmpty) {
        await tester.tap(termsCloseBtn.last);
        await tester.pumpAndSettle();
      }
      await goToMenuTab();

      // Privacy policy modal - fetches data from API with loading dialog
      await tapMenuItemIconSafe(FontAwesomeIcons.shieldHalved);
      await tester.pump(); // Initial tap
      await tester.pump(const Duration(seconds: 1)); // Wait for loading dialog
      await tester.pump(const Duration(seconds: 3)); // Wait for API call
      await tester.pump(); // Render modal
      await binding.takeScreenshot('menu_privacy_dialog');
      // Close the modal - look for X button
      final privacyCloseBtn = findFaIcon(FontAwesomeIcons.lightXmark);
      if (privacyCloseBtn.evaluate().isNotEmpty) {
        await tester.tap(privacyCloseBtn.last);
        await tester.pumpAndSettle();
      }
      await goToMenuTab();

      // Account withdrawal screen - has animations with postFrameCallback
      await tapMenuItemIconSafe(FontAwesomeIcons.userMinus);
      await tester.pump(); // Initial render
      await tester.pump(
        const Duration(milliseconds: 500),
      ); // Wait for postFrameCallback
      await tester.pump(const Duration(seconds: 5)); // Wait for animations
      await binding.takeScreenshot('menu_account_withdrawal');

      // Go back to menu
      final backBtn2 = find.byType(BackButton);
      if (backBtn2.evaluate().isNotEmpty) {
        await tester.tap(backBtn2.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
