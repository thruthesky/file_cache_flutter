# V6 → V7 Migration Checklist

> Generated: 2026-03-20
> Last audited: 2026-03-23 (iteration 3 — full v6/v7 feature inventory re-audit)
> Sources: `tmp/plans/new-version-plan.md` + `tmp/plan/fred/v6-missing-features.md` + v6 code audit

---

## Critical (Legal / Safety / Core)

- [x] Account withdrawal screen — `lib/user/account_withdrawal.screen.dart` (2026-03-20)
- [x] Post report button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Emergency contact screen — `lib/info/essential_info.screen.dart` (integrated into Essential Info with InfoAccessCodes) (2026-03-23)
- [x] Policy acceptance links — Terms/Privacy links on login screen (`lib/user/login/user.login.screen.dart`) with FA icons + url_launcher, plus menu WebView items (2026-03-23)
- [ ] Phone sign-in (OTP) — Phone number login. _Note: v7 uses Google + Kakao instead — clarify if still needed_
- [x] Build number check / forced update — `lib/setting/build_number_check.dart` (checks on every settings.get refresh, non-dismissible upgrade dialog with store links) (2026-03-23)

---

## High Priority (Core UX)

- [x] Post share button — `lib/post/view/widgets/post.action.bar.dart` (2026-03-20)
- [x] Post block user button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Chat sorting/ordering — `lib/chat/chat.screen.dart`
- [x] My company display in menu — `lib/menu/menu.screen.dart`
- [x] Quick post screen — `lib/home/widgets/home_quick_post_box.dart` (widget on home, opens category sheet → PostCreateScreen) (2026-03-23)
- [x] Wanted/hiring special form — Job posting dedicated fields (company, salary, scope, etc.) (2026-03-20)
  - v7: `lib/post/create/widgets/wanted_hiring_form.dart`
- [x] ~~Settings screen~~ — REMOVED: v6 has no user-facing settings screen either (only app-level config model/state). v7 has equivalent `setting.service.dart` + `setting.state.dart` + `setting.model.dart`. No screen needed. (2026-03-23)
- [x] Notice dedicated screen — `lib/notice/notice.screen.dart`, `lib/notice/notice.service.dart`, `lib/notice/notice.model.dart` (MOFA + PhilGo notices, wired to home helper menu + menu screen) (2026-03-23)
- [~] User activity screen — `lib/post/my/my.posts.screen.dart` (own posts with infinite scroll), but NO "my comments" history screen yet
  - v6: `v6/screens/user/user.activity.screen.dart` (has both posts + comments tabs)
- [x] Advertisement view screen — `lib/advertisement/advertisement.view.screen.dart` (post content + contact cards + YouTube, wired from banner tap via idx detection, contact card labels localized with .tr()) (2026-03-23)

---

## QR / Event System

- [x] Company QR code display screen — `lib/company/qr/company.qr_code.screen.dart` (2026-03-20)
- [x] Company QR code share/download — (2026-03-20)
- [x] QR scanner screen — `lib/event/qr_scanner.screen.dart` (2026-03-20)
- [x] QR code scanned result screen — `lib/company/qr/company.qr_code_scanned.screen.dart` (2026-03-20)
- [x] Company visit review screen — `lib/company/review/company.visit_review.screen.dart` (2026-03-20)
- [x] Receipt upload (event) — Part of visit review photo upload (2026-03-20)
- [x] Event audio feedback — pangpare.mp3 on coupon win
- [x] Coupon share — `lib/event/event_coupon.screen.dart` (2026-03-20)

---

## Home / UI

- [x] Exchange rate widget on home — `lib/currency/currency.screen.dart`, `lib/currency/currency.service.dart`, linked from home helper menu (2026-03-23)
- [x] Weather widget on home — `lib/weather/weather.screen.dart`, `lib/weather/weather.service.dart`, 5 cities + 6-day forecast, linked from home helper menu (2026-03-23)
- [x] ~~Homepage stats (member/post count)~~ — REMOVED: v6 has no global homepage stats either; only per-user stats on profile/menu, which v7 already has in `menu.screen.dart` (2026-03-23)
- [ ] Latest comments section on home — ⚠️ CORRECTION: `home_latest_comments_section.dart` does NOT exist in v7 (previously marked [x] in error)
  - v6: `v6/widgets/home/home_notice_section.dart` (shows latest comments)
- [x] User avatar + settings in AppBar — `lib/home/home.screen.dart` SliverAppBar (2026-03-20)
- [x] Collapsible header on scroll — `lib/company/view/company.view.screen.dart` and `lib/post/view/post.view.screen.dart` (SliverAppBar pinned + collapse detection) (2026-03-23)
- [x] Sequential animation on company list — `lib/company/list/company.list.screen.dart` flutter_animate stagger (2026-03-20)
- [x] ~~Content container (max-width)~~ — REMOVED per user request. v7 uses ad-hoc BoxConstraints where needed (2026-03-23)

---

## Infrastructure / Services (Prerequisites for 50+ Info Screens)

- [x] Post content service — `lib/post/post_content.service.dart` (memory + file dual cache, 48-hour TTL, loads Post by idx and InfoPost by access_code; InfoViewScreen wired to use cache) (2026-03-23)
- [x] Post content viewer widget — `lib/post/view/widgets/post.view.content.dart` (supports HTML via flutter_html, Markdown, plain text) (2026-03-23)
- [x] Post content mapping data — `lib/api/constants/info_access_codes.dart` (17 access codes mapping info screens to server content via `info.getByAccessCode` API) (2026-03-23)
- [x] ~~Memory cache service~~ — REMOVED: v6's MemoryCache class is unused legacy code (all v6 caching uses FileCache with `useMemoryCache: true`). v7 has equivalent caching in CurrencyService (TTL) and PostContentService (dual cache) (2026-03-23)
- [x] MOFA notice data service — `lib/notice/notice.service.dart` (MOFA API with 6-hour memory cache, `lib/notice/notice.model.dart`) (2026-03-23)
- [ ] Travel API service — Travel data API service
  - v6: `v6/services/travel/travel_spot.service.dart`, `v6/screens/guide/travel_spots.screen.dart`, `v6/screens/guide/travel_spot.view.screen.dart`
- [x] Chat sound service — `lib/chat/chat_sound.service.dart` (send.mp3, beep_message.mp3 via audioplayers) (2026-03-23)

---

## Profile / User

- [x] ~~Birth date picker~~ — REMOVED per user request: app will be rejected if birthday is collected (2026-03-23)
- [ ] Hero animation for profile photo
  - v6: `v6/screens/guide/travel_spot.view.screen.dart` (Hero widget pattern)
- [x] Profile stats (posts, comments, points) — `lib/menu/menu.screen.dart` (noOfPost, noOfComment from UserModel) (2026-03-23)
- [x] Event entry link in menu — `lib/home/widgets/home_helper_menu_section.dart` + `lib/event/event_entry.screen.dart` (2026-03-23)
- [x] Event coupon link in menu — `lib/menu/menu.screen.dart` + `lib/event/event_coupon.screen.dart` (2026-03-23)
- [x] Forum subcategory grid in menu — `lib/menu/menu.screen.dart` (커뮤니티, 회원장터, 기타 sections) (2026-03-23)

---

## Philippines Life Info — Static Content

**Prerequisite:** Post content system (service + viewer + mapping) must be built first.

**v6 data files:** `v6/data/philippine_life_info.data.dart`, `v6/data/emergency_menu.data.dart`, `v6/data/entertainment_menu.data.dart`, `v6/data/housing_menu.data.dart`, `v6/data/immigration_menu.data.dart`, `v6/data/residence_menu.data.dart`, `v6/data/transportation_menu.data.dart`, `v6/data/travel_destination_menu.data.dart`, `v6/data/car_menu.data.dart`, `v6/data/helper_menu.data.dart`

### Essential Info

- [x] Essential info screen — `lib/info/essential_info.screen.dart` (10-section icon grid with InfoAccessCodes) (2026-03-23)
- [x] Must read screen — integrated into essential info screen (2026-03-23)

### Emergency Info

- [x] Embassy info — `lib/info/essential_info.screen.dart` via InfoAccessCodes.embassy (2026-03-23)
- [x] Police station info — `lib/info/essential_info.screen.dart` via InfoAccessCodes.policeStations (2026-03-23)
- [x] Hospital info — `lib/info/essential_info.screen.dart` via InfoAccessCodes.hospitals (2026-03-23)
- [x] Korean association info — `lib/info/essential_info.screen.dart` via InfoAccessCodes.koreanAssociation (2026-03-23)

### Transportation

- [ ] Express bus info — v6: `v6/screens/info/transportation/express_bus.screen.dart`
- [ ] Grab taxi info — v6: `v6/screens/info/transportation/grab_taxi.screen.dart`
- [ ] Regular taxi info — v6: `v6/screens/info/transportation/regular_taxi.screen.dart`

### Vehicles

- [ ] Car insurance info — v6: `v6/screens/info/car/car_insurance.screen.dart`
- [ ] Car purchase info — v6: `v6/screens/info/car/car_purchase.screen.dart`
- [ ] Car rental info — v6: `v6/screens/info/car/car_rental.screen.dart`
- [ ] OR renewal info — v6: `v6/screens/info/car/or_renewal.screen.dart`

### Accommodation

- [ ] Airbnb info — v6: `v6/screens/info/housing/airbnb.screen.dart`
- [ ] Hotel info — v6: `v6/screens/info/housing/hotel.screen.dart`
- [ ] Monthly rent info — v6: `v6/screens/info/housing/monthly_rent.screen.dart`

### Visa / Immigration

- [ ] eTravel info — v6: `v6/screens/info/immigration/e_travel.screen.dart`
- [ ] Retirement visa info — v6: `v6/screens/info/immigration/retirement_visa.screen.dart`
- [ ] Travel visa info — v6: `v6/screens/info/immigration/travel_visa.screen.dart`
- [ ] Working visa info — v6: `v6/screens/info/immigration/working_visa.screen.dart`

### Delivery

- [ ] Food delivery info — v6: `v6/screens/info/delivery/food_delivery.screen.dart`
- [ ] Baedal K info — v6: `v6/screens/info/delivery/baedal_k.screen.dart`

### Travel / Entertainment

- [ ] Travel spots screen (search, filter, details) — v6: `v6/screens/guide/travel_spots.screen.dart`
- [ ] Travel spot detail view — v6: `v6/screens/guide/travel_spot.view.screen.dart`
- [ ] Festival info — v6: `v6/screens/info/entertainment/festival.screen.dart`
- [ ] Golf info — v6: `v6/screens/info/entertainment/golf.screen.dart`
- [ ] Island tour info — v6: `v6/screens/info/entertainment/island_tour.screen.dart`
- [ ] Market tour info — v6: `v6/screens/info/entertainment/market_tour.screen.dart`
- [ ] Massage info — v6: `v6/screens/info/entertainment/massage.screen.dart`
- [ ] Nightlife info — v6: `v6/screens/info/entertainment/nightlife.screen.dart`
- [ ] Restaurant info — v6: `v6/screens/info/entertainment/restaurant.screen.dart`
- [ ] Seafood info — v6: `v6/screens/info/entertainment/seafood.screen.dart`
- [ ] Water sports info — v6: `v6/screens/info/entertainment/water_sports.screen.dart`

### Travel Destinations (7 city/area guides)

- [ ] Manila guide — v6: `v6/screens/info/travel_destination/manila.screen.dart`
- [ ] Cebu guide — v6: `v6/screens/info/travel_destination/cebu.screen.dart`
- [ ] Subic guide — v6: `v6/screens/info/travel_destination/subic.screen.dart`
- [ ] Bohol guide — v6: `v6/screens/info/travel_destination/bohol.screen.dart`
- [ ] Boracay guide — v6: `v6/screens/info/travel_destination/boracay.screen.dart`
- [ ] Palawan guide — v6: `v6/screens/info/travel_destination/palawan.screen.dart`
- [ ] El Nido guide — v6: `v6/screens/info/travel_destination/el_nido.screen.dart`

### Helper Services

- [ ] Driver helper info — v6: `v6/screens/info/helper/driver.screen.dart`
- [ ] House helper info — v6: `v6/screens/info/helper/house_helper.screen.dart`
- [ ] Tutor info — v6: `v6/screens/info/helper/tutor.screen.dart`

### Residential Areas

- [ ] Alabang area guide — v6: `v6/screens/info/residence/alabang.screen.dart`
- [ ] BGC area guide — v6: `v6/screens/info/residence/bgc.screen.dart`
- [ ] Ortigas area guide — v6: `v6/screens/info/residence/ortigas.screen.dart`

### Others

- [ ] Holiday info — v6: `v6/screens/info/holiday/holiday.screen.dart`
- [ ] Monthly living info — v6: `v6/screens/info/monthly/monthly_living.screen.dart`
- [ ] Travel info — v6: `v6/screens/info/travel/travel_info.screen.dart`

---

## Partial Implementations (Screen Exists, Sub-Features Missing)

- [x] Home: quick menu carousel
- [ ] Home: photo grid section
  - v6: `v6/widgets/home/home_photo_grid_section.dart`
- [~] Home: shimmer loading effect — flutter_animate `.shimmer()` used on accent elements (FAB, QR scan) but NOT on home loading state
  - v6: `v6/widgets/home/home_post_section_shimmer.dart` (dedicated loading placeholders)
- [x] Company view: visit review section (photo thumbnails, review CTA)
- [x] Company form: KakaoTalk QR auto-parse
- [x] Company form: extra image fields (business license, office photos)
- [x] Post view: blocked user info overlay (tap to unblock) — `lib/post/list/forum.screen.dart` (dialog on blocked user post with unblock option) (2026-03-23)
- [x] Post view: earned point badge — `lib/point/widgets/earned_point_badge.dart` (2026-03-20)
- [x] Chat: unread message badge on nav bar — `lib/app/app.screen.dart` (ChatService.instance.unreadCountStream with Badge widget) (2026-03-23 audit confirmed)
- [x] Forum header: notification icons — `lib/post/list/widgets/forum_notification_dialog.dart` (bell icon in category header, opens per-category FCM subscription dialog via Firebase RTDB) (2026-03-23)
- [x] Forum header: subcategory filter tabs — `lib/post/list/widgets/post_list_header_categories.dart` (expandable Wrap with 12 default + "더보기/접기" toggle, chip background styling, search + notification as first items) (2026-03-23)
- [x] Menu: point ad item in ad section — `lib/point/widgets/point_advertisements.dart` integrated in forum screen (2026-03-23)
- [x] Menu: life info onTap handlers — Weather, Currency, Essential Info all have working onTap (2026-03-23)
- [x] Home: helper menu onTap handlers — `lib/home/widgets/home_helper_menu_section.dart` (내 정보, 업소이벤트, 이벤트응모, 필수정보, 환율, etc.) (2026-03-23)

---

## v6 Widgets / Components Not Yet in v7

- [x] ~~Comic theme widgets~~ — Not needed in v7; v7 uses Material 3 + flutter_animate instead (2026-03-23)
- [x] ~~Step progress indicator~~ — Not needed in v7 (2026-03-23)
- [x] ~~Information box widget~~ — Not needed in v7 (2026-03-23)
- [x] Spinning wheel (standalone) — `lib/event/widgets/spinning_wheel.dart` (CustomPainter-based, equivalent to v6) (2026-03-23)
- [ ] Logo widgets — v6: `v6/widgets/logo/logo.dart`, `philgo.logo.triangle.dart`, `philgo.logo.triangles.dart`
- [x] ~~Carousel dot indicator~~ — Not needed in v7 (2026-03-23)

---

## v6 Features Not Previously Tracked (NEW in this audit)

- [x] Company event screen — `lib/event/company_event.screen.dart` (QR-based point event, wired from home helper menu + FAB) (2026-03-23)
- [x] App info screen — `lib/app_info/app_info.screen.dart` (version display + admin features)
- [x] Bookmark system — `lib/bookmark/bookmark.service.dart`, `lib/bookmark/bookmark.screen.dart` (groups, CRUD, multi-type)
- [x] AI answer service — `lib/ai/ai.service.dart` (SSE streaming AI answers, new in v7)
- [x] Deep link service — `lib/deeplink/deeplink.service.dart` (v4/v6/v7 URL backward compatibility)
- [x] Receive share service — `lib/receive_share/` (share target support)
- [x] Point history screen — `lib/point/point_history.screen.dart`
- [x] Company review point result — `lib/company/review/company.review_point_result.screen.dart`
- [x] Company revisit point result — `lib/company/review/company.revisit_point_result.screen.dart`
- [x] Version screen — `lib/version/version.screen.dart` (device info, app version, wired from menu) (2026-03-23)
- [x] Search screen — `lib/search/search.screen.dart` + `lib/search/search_dialog.dart` (Google CSE WebView + SearchDialog) (2026-03-23)
- [x] WebView screen — `lib/webview/webview.screen.dart` (generic webview for external content) (2026-03-23)
- [x] App guide screen — `lib/guide/app_guide.screen.dart` (in-app guide/tutorial, wired from menu) (2026-03-23)
- [x] Other user profile screen — `lib/user/other_user/other_user.screen.dart` (view other users' public profiles) (2026-03-23)
- [x] Chat: pinned chat rooms — `lib/chat/widgets/pinned_chat_rooms_list.dart` (Firebase-based pinned rooms) (2026-03-23)
- [x] Chat: bookmarked chats dialog — `lib/chat/widgets/bookmarked_chats_dialog.dart` (v7 API bookmark system) (2026-03-23)
- [x] Chat: search friends dialog — `lib/chat/widgets/search_friends_dialog.dart` (2026-03-23)
- [x] Chat: report user — `lib/chat/report/chat.report.dart` (2026-03-23)
- [x] YouTube player integration — `lib/common_widgets/youtube_player_list.dart`, `lib/common_widgets/youtube_thumbnail.dart` (2026-03-23)
- [x] Full screen media viewer — `lib/common_widgets/full_screen_media_viewer.dart` (image/video viewer) (2026-03-23)
- [x] Masonry grid layout — `lib/common_widgets/app_masonry_grid.dart`, `lib/common_widgets/masonry_card.dart` (2026-03-23)
- [x] Blocked users management — `lib/user/widgets/blocked_users_bottom_sheet.dart`, `lib/user/widgets/block_user_dialog.dart` (2026-03-23)
- [x] Push notification icon — `lib/messaging/widget/push_notification_icon.dart` (2026-03-23)
- [x] Post comment threading — `lib/post/view/widgets/comment.list.view.dart`, `lib/post/view/widgets/comment.tile.dart` (nested comments with visual painter) (2026-03-23)
- [x] FAB menu — `lib/common_widgets/app_fab.dart` (floating action button with login check, event/QR shortcuts) (2026-03-23)
- [x] ~~v6 `data.service.dart`~~ — Not needed in v7; v7 uses individual module services instead (2026-03-23)
- [x] ~~v6 `ui.functions.dart`~~ — Not needed in v7 (2026-03-23)
- [x] ~~v6 `init.functions.dart`~~ — Not needed in v7; covered by `lib/init/` (2026-03-23)

---

## System-Level

- [x] Shorebird code push — `shorebird_code_push: ^2.0.5` in pubspec.yaml + shorebird.yaml asset (2026-03-23)
- [x] Build number forced update — `lib/setting/build_number_check.dart` (2026-03-23)

---

## Summary

| Category                | Done   | Partial | Remaining |
| ----------------------- | ------ | ------- | --------- |
| Critical                | 5      | 0       | 1         |
| High Priority           | 9      | 1       | 0         |
| QR / Event              | 8      | 0       | 0         |
| Home / UI               | 7      | 0       | 1         |
| Infrastructure          | 6      | 0       | 1         |
| Profile / User          | 5      | 0       | 1         |
| Static Content          | 6      | 0       | 43        |
| Partial Implementations | 12     | 1       | 1         |
| Widgets/Components      | 5      | 0       | 1         |
| New in This Audit       | 20     | 0       | 0         |
| System-Level            | 2      | 0       | 0         |
| **Total**               | **85** | **2**   | **49**    |

---

## Audit Log

- **2026-03-23 (Ralph Loop iteration 1):** Full file-by-file audit of v6 (218 files) vs v7 (203 files). Corrections:
  - FIXED: `home_latest_comments_section.dart` marked [x] but file does NOT exist → changed to [ ]
  - FIXED: `Chat: unread message badge on nav bar` marked [ ] but IS implemented in `app.screen.dart` → changed to [x]
  - FIXED: Several static content items marked "Not found in v6" but DO exist (delivery, holiday, monthly living, car purchase/rental/OR renewal, house helper, tutor, island tour, market tour, seafood, water sports)
  - ADDED: v6 Widgets/Components section (comic theme, step indicator, info box, logo, carousel dots)
  - ADDED: v6 Features Not Previously Tracked section (app info, bookmark, AI, deep link, etc.)
  - ADDED: v6 data file references (`car_menu.data.dart`, `helper_menu.data.dart`)
  - Updated summary counts
- **2026-03-23 (iteration 2):** Re-audit after adding TOS/Privacy links to login screen.
  - FIXED: Policy acceptance [~] → [x] — now has tappable links with FA icons on login screen (`lib/user/login/user.login.screen.dart`)
  - CONFIRMED: Chat unread badge, settings state/service, deep link service all present
  - CONFIRMED: No birth date picker, no shimmer loading, no content container, no forced update dialog in v7
  - Updated summary counts (Critical: 4 done / 0 partial / 2 remaining)
- **2026-03-23 (iteration 3):** Full v6/v7 feature inventory with comprehensive agent-based exploration.
  - FIXED: `Company event screen` marked [ ] with "EXISTS" note → changed to [x] (fully wired from home helper menu + FAB)
  - FIXED: `Spinning wheel (standalone)` marked [ ] → changed to [x] (v7 has `lib/event/widgets/spinning_wheel.dart`)
  - ADDED 16 previously untracked v6 features now confirmed in v7: Version screen, Search screen, WebView screen, App guide screen, Other user profile, Chat pinned rooms, Chat bookmarked dialog, Chat search friends, Chat report user, YouTube player, Full screen media viewer, Masonry grid, Blocked users management, Push notification icon, Post comment threading, FAB menu
  - CONFIRMED STILL MISSING: Settings screen (no .screen.dart), Travel API service, Post content service, Memory cache service, Build number check, Content container, Birth date picker, Hero animation, Photo grid section, Latest comments section, all 43 remaining static info content screens
  - Updated summary counts (78 done / 2 partial / 62 remaining — note: Static Content remaining was miscounted as 49 but correct is 43)
- **2026-03-23 (iteration 4):** Full re-verification of all unchecked items via parallel agent-based code searches.
  - FIXED: Static Content remaining count 49 → 43 (section has 49 total items: 6 done + 43 remaining; previous count incorrectly used total as remaining)
  - FIXED: Total remaining 62 → 56
  - CONFIRMED ALL REMAINING ITEMS STILL MISSING:
    - Settings screen: service/state/model exist but NO .screen.dart, no navigation route
    - Build number check: version fields exist in SettingsModel but no comparison logic or forced update dialog
    - Phone sign-in (OTP): only Google + Kakao OAuth; phoneNumber field exists in UserModel but only for storage
    - Latest comments on home: translation key '최근 댓글' defined but unused; no widget exists
    - Homepage stats: no global member/post count on home (only per-user stats on profile)
    - Content container: no reusable max-width wrapper; ad-hoc BoxConstraints used in dialogs
    - Memory cache service: no standalone LRU cache; CurrencyService has TTL cache, PostContentService has dual cache, but no generic shared service
    - Travel API service: 'travel' exists as forum category but no dedicated TravelSpot API service/model
    - Birth date picker: UserModel has no birthdate fields; commented-out birthdate code in user.firebase_model.dart
    - Hero animation: no Hero widget usage for profile/avatar photos
    - Logo widgets: assets exist (philgo_wide_logo.png etc.) but no reusable LogoWidget class
    - Photo grid on home: masonry grid exists for forums (11 categories) but not wired to home screen
    - Shimmer loading on home: all home sections use CircularProgressIndicator; .shimmer() only on FAB accent
    - My comments screen: only MyPostsScreen exists; no comment history screen
    - All 43 static info content screens (transportation, vehicles, accommodation, visa, delivery, entertainment, destinations, helpers, residential, others)
  - NO STATUS CHANGES from iteration 3 — all done/partial/remaining items verified accurate
- **2026-03-23 (iteration 5):** Deep v6 source analysis + user-directed removals.
  - REMOVED: `Birth date picker` — per user: app will be rejected if birthday is collected
  - REMOVED: `Content container (max-width)` — per user request; v7 uses ad-hoc BoxConstraints
  - REMOVED: `Homepage stats (member/post count)` — v6 audit confirmed no global homepage stats exist in v6 either; only per-user stats on profile/menu, which v7 already has
  - REMOVED: `Settings screen` — v6 audit confirmed no user-facing settings screen exists in v6; only app-level config model/state, which v7 already has
  - REMOVED: `Memory cache service` — v6 audit confirmed MemoryCache class is unused legacy code; all v6 caching uses FileCache with `useMemoryCache: true`; v7 has equivalent caching in CurrencyService and PostContentService
  - CONFIRMED: Build number forced update still needed — v6 has full implementation (5s initial + 5min periodic check, non-dismissible dialog, store links); v7 has version fields in SettingsModel but no comparison logic or dialog
  - Updated summary counts: 83 done / 2 partial / 51 remaining (was 78/2/56)
