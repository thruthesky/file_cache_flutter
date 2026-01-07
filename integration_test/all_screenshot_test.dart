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

    testWidgets('Capture chat room interactions', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Go to Chat tab
      final chatIcon = findFaIcon(FontAwesomeIcons.thinCommentDots);
      if (chatIcon.evaluate().isNotEmpty) {
        await tester.tap(chatIcon);
        await tester.pumpAndSettle();
      }

      // Favorite folders dialog
      final favoriteFoldersButton = findFaIcon(FontAwesomeIcons.sharpSolidStar);
      if (favoriteFoldersButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteFoldersButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('19_chat_favorite_folders_dialog');
        await tester.pump(const Duration(seconds: 1));

        final closeButtons = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButtons.evaluate().isNotEmpty) {
          await tester.tap(closeButtons.first);
          await tester.pumpAndSettle();
        }
      }

      // User search dialog
      final userSearchButton = findFaIcon(
        FontAwesomeIcons.lightUserMagnifyingGlass,
      );
      if (userSearchButton.evaluate().isNotEmpty) {
        await tester.tap(userSearchButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('20_chat_user_search_dialog');
        await tester.pump(const Duration(seconds: 1));

        final closeButtons = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButtons.evaluate().isNotEmpty) {
          await tester.tap(closeButtons.first);
          await tester.pumpAndSettle();
        }
      }

      // Open a chat room (prefer Fred/Selrahc, fallback to first tile)
      Finder? chatTarget;
      final fredText = find.text('Fred');
      final selrahcText = find.text('Selrahc');
      final selrachcText = find.text('Selrachc');

      if (fredText.evaluate().isNotEmpty) {
        chatTarget = fredText;
      } else if (selrahcText.evaluate().isNotEmpty) {
        chatTarget = selrahcText;
      } else if (selrachcText.evaluate().isNotEmpty) {
        chatTarget = selrachcText;
      }

      if (chatTarget != null) {
        await tester.tap(chatTarget);
        await tester.pumpAndSettle();
      } else {
        final chatTiles = find.byType(ChatRoomListTile);
        if (chatTiles.evaluate().isNotEmpty) {
          await tester.tap(chatTiles.first);
          await tester.pumpAndSettle();
        }
      }

      // Wait for chat room to finish loading
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('21_chat_room_screen');
      await tester.pump(const Duration(seconds: 1));

      // Favorite icon button -> screenshot modal
      Finder favoriteButton = find.byIcon(Icons.star);
      if (favoriteButton.evaluate().isEmpty) {
        favoriteButton = find.byIcon(Icons.star_border);
      }
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('22_chat_favorite_modal');
        await tester.pump(const Duration(seconds: 1));

        final closeButtons = find.byIcon(Icons.close);
        if (closeButtons.evaluate().isNotEmpty) {
          await tester.tap(closeButtons.first);
          await tester.pumpAndSettle();
        }
      }

      // Gear menu button -> screenshot modal
      final settingsButton = find.byIcon(Icons.settings);
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        await binding.takeScreenshot('23_chat_settings_menu');
        await tester.pump(const Duration(seconds: 1));

        // Close settings menu
        final closeButtons = find.byIcon(Icons.close);
        if (closeButtons.evaluate().isNotEmpty) {
          await tester.tap(closeButtons.first);
          await tester.pumpAndSettle();
        }
      }

      // Go back to home from chat room (uses IconButton with arrow_back icon)
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Capture menu screen sections', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Go to Menu tab using the bottom navigation bar
      final menuButton = find.byKey(const ValueKey('menuButton'));
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }

      // === PHILIPPINE LIFE INFO SECTION ===

      // 24. NOTICE - Click Notice menu item by icon
      final noticeIcon = findFaIcon(FontAwesomeIcons.bullhorn);
      if (noticeIcon.evaluate().isNotEmpty) {
        await tester.tap(noticeIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('24_menu_notice_screen');

        // Close using X button (FontAwesomeIcons.lightXmark)
        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 25. EXCHANGE RATE - Click Exchange menu item by icon (wait 15 seconds)
      final exchangeIcon = findFaIcon(FontAwesomeIcons.coins);
      if (exchangeIcon.evaluate().isNotEmpty) {
        await tester.tap(exchangeIcon);
        await tester.pumpAndSettle();

        // Wait 15 seconds for exchange rate data to load
        await tester.pump(const Duration(seconds: 15));
        await binding.takeScreenshot('25_menu_exchange_rate_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 26. WEATHER - Click Weather menu item by icon (API loading)
      final weatherIcon = findFaIcon(FontAwesomeIcons.cloudSun);
      if (weatherIcon.evaluate().isNotEmpty) {
        await tester.tap(weatherIcon);
        await tester.pumpAndSettle();

        // Wait longer for weather API to load (5 cities)
        await tester.pump(const Duration(seconds: 5));
        await binding.takeScreenshot('26_menu_weather_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 27. EMERGENCY - Click Emergency menu item by icon
      final emergencyIcon = findFaIcon(FontAwesomeIcons.phoneVolume);
      if (emergencyIcon.evaluate().isNotEmpty) {
        await tester.tap(emergencyIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('27_menu_emergency_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 28. ESSENTIAL INFO - Click Essential menu item by icon (first circleInfo)
      final essentialIcons = findFaIcon(FontAwesomeIcons.circleInfo);
      if (essentialIcons.evaluate().isNotEmpty) {
        // Tap the first circleInfo icon (Essential Info)
        await tester.tap(essentialIcons.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('28_menu_essential_info_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 29. MONTHLY LIVING - Click Monthly menu item by icon
      final monthlyIcon = findFaIcon(FontAwesomeIcons.calendarDays);
      if (monthlyIcon.evaluate().isNotEmpty) {
        await tester.tap(monthlyIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('29_menu_monthly_living_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 30. TRAVEL INFO - Click Travel menu item by icon (umbrellaBeach)
      final travelIcon = findFaIcon(FontAwesomeIcons.umbrellaBeach);
      if (travelIcon.evaluate().isNotEmpty) {
        await tester.tap(travelIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('30_menu_travel_info_screen');

        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // === MY ACTIVITY SECTION ===
      // Scroll down to reveal My Activity section items

      // 31. EDIT PROFILE - Scroll to and click Edit Profile by icon (wait for animations)
      final editProfileIcon = findFaIcon(FontAwesomeIcons.user);
      await tester.ensureVisible(editProfileIcon);
      await tester.pumpAndSettle();

      if (editProfileIcon.evaluate().isNotEmpty) {
        await tester.tap(editProfileIcon);
        await tester.pumpAndSettle();

        // Wait for animations to complete
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('31_menu_edit_profile_screen');

        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // 32. MY POSTS - Scroll to and click My Posts by icon (wait for animations)
      final myPostsIcon = findFaIcon(FontAwesomeIcons.clockRotateLeft);
      await tester.ensureVisible(myPostsIcon);
      await tester.pumpAndSettle();

      if (myPostsIcon.evaluate().isNotEmpty) {
        await tester.tap(myPostsIcon);
        await tester.pumpAndSettle();

        // Wait for animations to complete
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('32_menu_my_posts_screen');

        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // 33. SEARCH FRIENDS - Scroll to and click Search Friends by icon
      final searchFriendsIcon = findFaIcon(FontAwesomeIcons.magnifyingGlass);
      await tester.ensureVisible(searchFriendsIcon);
      await tester.pumpAndSettle();

      if (searchFriendsIcon.evaluate().isNotEmpty) {
        await tester.tap(searchFriendsIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('33_menu_search_friends_dialog');

        // Close dialog using lightXmark icon
        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 34. BLOCKED USERS - Scroll to and click Blocked Users by icon
      final blockedUsersIcon = findFaIcon(FontAwesomeIcons.usersSlash);
      await tester.ensureVisible(blockedUsersIcon);
      await tester.pumpAndSettle();

      if (blockedUsersIcon.evaluate().isNotEmpty) {
        await tester.tap(blockedUsersIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('34_menu_blocked_users_dialog');

        // Close dialog - No close button in blocked users list, tap outside or use barrier
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
      }

      // === SUPPORT SECTION ===

      // 35. APP GUIDE - Scroll to and click App Guide by icon (wait for animations)
      final appGuideIcon = findFaIcon(FontAwesomeIcons.circleQuestion);
      await tester.ensureVisible(appGuideIcon);
      await tester.pumpAndSettle();

      if (appGuideIcon.evaluate().isNotEmpty) {
        await tester.tap(appGuideIcon);
        await tester.pumpAndSettle();

        // Wait for animations to complete
        await tester.pump(const Duration(seconds: 2));
        await binding.takeScreenshot('35_menu_app_guide_screen');

        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // 36. TERMS OF SERVICE - Scroll to and click Terms of Service by icon
      final termsIcon = findFaIcon(FontAwesomeIcons.fileLines);
      await tester.ensureVisible(termsIcon);
      await tester.pumpAndSettle();

      if (termsIcon.evaluate().isNotEmpty) {
        await tester.tap(termsIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        await binding.takeScreenshot('36_menu_terms_of_service_dialog');

        // Close dialog
        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // 37. PRIVACY POLICY - Scroll to and click Privacy Policy by icon
      final privacyIcon = findFaIcon(FontAwesomeIcons.shieldHalved);
      await tester.ensureVisible(privacyIcon);
      await tester.pumpAndSettle();

      if (privacyIcon.evaluate().isNotEmpty) {
        await tester.tap(privacyIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 5));
        await binding.takeScreenshot('37_menu_privacy_policy_dialog');

        // Close dialog
        final closeButton = findFaIcon(FontAwesomeIcons.lightXmark);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton);
          await tester.pumpAndSettle();
        }
      }

      // === APP INFO SECTION ===

      // 38. VERSION INFO - Scroll to and click Version by icon
      // Note: Uses same circleInfo icon as Essential Info, need to find the second one
      final versionIcons = findFaIcon(FontAwesomeIcons.circleInfo);
      if (versionIcons.evaluate().length > 1) {
        // Ensure the last circleInfo icon (Version) is visible
        await tester.ensureVisible(versionIcons.last);
        await tester.pumpAndSettle();

        // Tap the last circleInfo icon (Version)
        await tester.tap(versionIcons.last);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('38_menu_version_info_screen');

        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }

      // === ACCOUNT ACTIONS SECTION ===

      // 39. ACCOUNT WITHDRAWAL - Scroll to and click Withdraw by icon
      final withdrawIcon = findFaIcon(FontAwesomeIcons.userMinus);
      await tester.ensureVisible(withdrawIcon);
      await tester.pumpAndSettle();

      if (withdrawIcon.evaluate().isNotEmpty) {
        await tester.tap(withdrawIcon);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        await binding.takeScreenshot('39_menu_account_withdrawal_screen');

        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
