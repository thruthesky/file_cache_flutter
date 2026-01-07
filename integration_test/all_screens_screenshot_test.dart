import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/main.dart' as app;
import 'package:philgo/widgets/post/post.card.dart';
import 'package:philgo_api/philgo_api.dart';

/// Helper function to find FontAwesome icons
Finder findFaIcon(IconData data) {
  return find.byWidgetPredicate(
    (widget) => widget is FaIcon && widget.icon == data,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Main Screens Screenshot Test', () {
    testWidgets('Capture all main tab screenshots', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // 1. HOME SCREEN
      await binding.takeScreenshot('01_home_screen');
      await tester.pump(const Duration(seconds: 1));

      // 2. FORUM SCREEN
      final forumIcon = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon.evaluate().isNotEmpty) {
        await tester.tap(forumIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('02_forum_screen');
        await tester.pump(const Duration(seconds: 1));
      }

      // 3. DIRECTORY (COMPANY) SCREEN
      final directoryIcon = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (directoryIcon.evaluate().isNotEmpty) {
        await tester.tap(directoryIcon);
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('03_directory_screen');
        await tester.pump(const Duration(seconds: 1));
      }

      // 4. CHAT SCREEN
      final chatIcon = findFaIcon(FontAwesomeIcons.thinCommentDots);
      if (chatIcon.evaluate().isNotEmpty) {
        await tester.tap(chatIcon);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('04_chat_screen');
        await tester.pump(const Duration(seconds: 1));
      }

      // 5. MENU SCREEN
      final menuButton = find.byKey(const ValueKey('menuButton'));
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('05_menu_screen');
        await tester.pump(const Duration(seconds: 1));
      }
    });

    testWidgets('Capture home screen interactions', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Go to home tab (in case we're not there)
      final homeIcon = findFaIcon(FontAwesomeIcons.thinHouse);
      if (homeIcon.evaluate().isNotEmpty) {
        await tester.tap(homeIcon);
        await tester.pumpAndSettle();
      }

      // 6. HOME QUICK POST BOX - Click and screenshot the QuickPostScreen
      final quickPostBox = find.text('포인트 이벤트! 글 쓰고 랜덤포인트가 가득~');
      if (quickPostBox.evaluate().isNotEmpty) {
        await tester.tap(quickPostBox);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('06_home_quick_post_screen');
        await tester.pump(const Duration(seconds: 1));

        // Go back using the X button
        final closeButton = findFaIcon(FontAwesomeIcons.xmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 7. FLOATING ACTION BUTTON (FAB) - Click and screenshot
      final fabButton = findFaIcon(FontAwesomeIcons.plus);
      if (fabButton.evaluate().isNotEmpty) {
        await tester.tap(fabButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('07_fab_category_dialog');
        await tester.pump(const Duration(seconds: 1));

        // Close the dialog using 취소 button
        final cancelBtn = find.text('취소');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn);
          await tester.pumpAndSettle();
        }
      }

      // 8. ADVERTISEMENT - Click a WingBanner to open AdvertisementViewScreen
      // Scroll down to find WingBanners
      final scrollView = find.byType(Scrollable).first;
      await tester.drag(scrollView, const Offset(0, -800));
      await tester.pumpAndSettle();

      // Find WingBanners GridView and click first banner
      final wingBanners = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(InkWell),
      );

      if (wingBanners.evaluate().isNotEmpty) {
        // Click the first banner to open AdvertisementViewScreen
        await tester.tap(wingBanners.first);
        await tester.pumpAndSettle();

        // Wait for content to load
        await tester.pump(const Duration(seconds: 2));

        // Screenshot the advertisement detail view
        await binding.takeScreenshot('08_advertisement_detail_view');
        await tester.pump(const Duration(seconds: 1));

        // Go back using the back button
        final backButton = find.text('돌아가기');
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Capture forum screens and post views', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Go to Forum tab
      final forumIcon = findFaIcon(FontAwesomeIcons.thinNewspaper);
      if (forumIcon.evaluate().isNotEmpty) {
        await tester.tap(forumIcon);
        await tester.pumpAndSettle();
      }

      // 9. FORUM LIST VIEW - Default category (uses PostListView)
      await binding.takeScreenshot('09_forum_list_view');
      await tester.pump(const Duration(seconds: 1));

      // 10. CLICK A POST - Open post detail screen from list view
      // Find PostListTileItem widgets in the post list
      final postListItems = find.byType(PostListTileItem);
      if (postListItems.evaluate().isNotEmpty) {
        await tester.tap(postListItems.first);
        await tester.pumpAndSettle();

        // Wait for PostViewScreen to load
        await tester.pump(const Duration(seconds: 2));

        await binding.takeScreenshot('10_post_view_screen');
        await tester.pump(const Duration(seconds: 1));

        // Go back to forum using the back button
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // 11. SWITCH TO MASONRY LAYOUT
      // Try to find masonry categories: Realty, Rent-car, News, Golf
      // Click 'Hide' button if visible to show all categories
      final hideButton = find.text('Hide «');
      if (hideButton.evaluate().isNotEmpty) {
        await tester.tap(hideButton);
        await tester.pumpAndSettle();
      }

      // Try to find masonry category (check both English and Korean)
      Finder? masonryCategory;

      // Try Realty (English/Korean)
      var realtyEn = find.text('Realty');
      var realtyKo = find.text('부동산');
      if (realtyEn.evaluate().isNotEmpty) {
        masonryCategory = realtyEn;
      } else if (realtyKo.evaluate().isNotEmpty) {
        masonryCategory = realtyKo;
      }

      // Try Rent-car if Realty not found
      if (masonryCategory == null) {
        var rentCarEn = find.text('Rent-car');
        var rentCarKo = find.text('렌트카');
        if (rentCarEn.evaluate().isNotEmpty) {
          masonryCategory = rentCarEn;
        } else if (rentCarKo.evaluate().isNotEmpty) {
          masonryCategory = rentCarKo;
        }
      }

      // Tap the masonry category if found
      if (masonryCategory != null) {
        await tester.tap(masonryCategory);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
      }

      // Screenshot masonry view
      await binding.takeScreenshot('11_forum_masonry_view');
      await tester.pump(const Duration(seconds: 1));

      // 12. CLICK A POST IN MASONRY - Open post detail using PostCard
      final postCards = find.byType(PostCard);
      if (postCards.evaluate().isNotEmpty) {
        await tester.tap(postCards.first);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('12_post_view_from_masonry');
        await tester.pump(const Duration(seconds: 1));

        // Go back
        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn);
          await tester.pumpAndSettle();
        }
      }

      // 13. FORUM FAB - Click and screenshot post creation
      final forumFab = findFaIcon(FontAwesomeIcons.plus);
      if (forumFab.evaluate().isNotEmpty) {
        await tester.tap(forumFab);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('13_forum_post_create');
        await tester.pump(const Duration(seconds: 1));

        // 14. CAMERA BUTTON - Click and screenshot, then exit popup
        final cameraButton = findFaIcon(FontAwesomeIcons.camera);
        if (cameraButton.evaluate().isNotEmpty) {
          await tester.tap(cameraButton);
          await tester.pumpAndSettle();
          await binding.takeScreenshot('14_camera_popup');
          await tester.pump(const Duration(seconds: 1));

          // Exit popup - look for cancel or close button
          final cancelButton = find.text('취소');
          if (cancelButton.evaluate().isNotEmpty) {
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
          }
        }

        // 15. POINT ADVERTISEMENT - Click and screenshot popup
        final pointAdButton = find.text('포인트 광고');
        if (pointAdButton.evaluate().isNotEmpty) {
          await tester.tap(pointAdButton);
          await tester.pumpAndSettle();
          await binding.takeScreenshot('15_point_ad_popup');
          await tester.pump(const Duration(seconds: 1));

          // Exit popup
          final cancelBtn2 = find.text('취소');
          if (cancelBtn2.evaluate().isNotEmpty) {
            await tester.tap(cancelBtn2);
            await tester.pumpAndSettle();
          }
        }

        // Close post creation screen
        final closeButton = find.text('취소');
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Capture directory (company) screens', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Go to Directory tab
      final directoryIcon = findFaIcon(FontAwesomeIcons.thinBuilding);
      if (directoryIcon.evaluate().isNotEmpty) {
        await tester.tap(directoryIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
      }

      // 16. DIRECTORY LIST VIEW - Screenshot company list
      await binding.takeScreenshot('16_directory_list_view');
      await tester.pump(const Duration(seconds: 1));

      // 17. CLICK A COMPANY CARD - Open company detail screen
      // Find CompanyCard widgets with images
      final companyCards = find.byType(CompanyCard);
      if (companyCards.evaluate().isNotEmpty) {
        // Tap the first company card
        await tester.tap(companyCards.first);
        await tester.pumpAndSettle();

        // Wait for CompanyViewScreen to load
        await tester.pump(const Duration(seconds: 2));

        await binding.takeScreenshot('17_company_view_screen');
        await tester.pump(const Duration(seconds: 1));

        // Go back to directory list using IconButton with back arrow
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // 18. COMPANY FORM - Click FAB to open company form screen
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pumpAndSettle();

        // Wait for form to load
        await tester.pump(const Duration(seconds: 1));

        await binding.takeScreenshot('18_company_form_screen');
        await tester.pump(const Duration(seconds: 1));

        // Go back to directory
        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
