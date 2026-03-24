# PhilGo App: v6 → v7 Feature Gap Analysis Report

**Generated:** 2026-03-24
**Purpose:** Track v6 features and identify what is missing or incomplete in v7

---

## Summary

| Category | v6 Features | v7 Implemented | v7 Missing/Partial | Coverage |
|----------|-------------|----------------|---------------------|----------|
| Home Screen | 15 | 14 | 1 | 93% |
| Post System | 16 | 15 | 1 | 94% |
| Company Module | 10 | 10 | 0 | 100% |
| User/Account | 12 | 11 | 1 | 92% |
| Chat | 3 | 3 | 0 | 100% |
| Event System | 4 | 4 | 0 | 100% |
| Info Screens | 54 | 3 | 51 | 6% |
| Services | 5 | 5 | 0 | 100% |
| Navigation/State | 4 | 4 | 0 | 100% |
| **TOTAL** | **123** | **69** | **54** | **56%** |

> **Key Finding:** Core features (post, company, user, chat, event) are nearly 100% implemented. The major gap is the **50+ individual information/guide screens** that were hardcoded in v6 but need to be migrated as content-based screens in v7.

---

## 1. HOME SCREEN

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Bottom Navigation (5 tabs: Home, Forum, Company, Chat, Menu) | `lib/app/app.screen.dart` |
| 2 | Quick Post Box (fake input → post create) | `lib/home/widgets/home_quick_post_box.dart` |
| 3 | Helper Menu Section (quick-access grid) | `lib/home/widgets/home_helper_menu_section.dart` |
| 4 | Popular Posts Section (top 5 by comments) | `lib/home/widgets/home_popular_post_section.dart` |
| 5 | Notice Section (latest 3 announcements) | `lib/home/widgets/home_notices_section.dart` |
| 6 | Latest Posts Carousel (6 forums, 3 pages, 7s auto-scroll) | `lib/home/widgets/home_latest_posts_section.dart` |
| 7 | Major Forums Section (11 forum chips) | `lib/home/widgets/home_major_forum_section.dart` |
| 8 | Menu Categories (horizontal scroll) | `lib/home/widgets/home_menu_categories.dart` |
| 9 | Top Banners (ad carousel) | `lib/home/widgets/home_top_banners.dart` |
| 10 | Wing Banners (grid ads) | `lib/home/widgets/home_wing_banners.dart` |
| 11 | Debug/Dev Card (admin panel) | `lib/home/widgets/home_dev_mode_banner.dart` |
| 12 | Event Entry FAB (conditional) | `lib/app/app.screen.dart` (FAB section) |
| 13 | Section Headers (reusable) | Implemented inline in home widgets |
| 14 | Profile Menu Item | `lib/home/widgets/home_profile_menu_item.dart` |

### ❌ Missing or Partial in v7

| # | v6 Feature | Status | Notes |
|---|-----------|--------|-------|
| 1 | Photo Grid Section (4×4 buyandsell images) | **MISSING** | v6 had `home_photo_grid_section.dart` showing 16 recent marketplace photos in grid. Not present in v7. |

---

## 2. POST SYSTEM

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Post Create Screen (with category selection) | `lib/post/create/post.create.screen.dart` |
| 2 | Post Update Screen (edit with change detection) | `lib/post/update/post.update.screen.dart` |
| 3 | Post View Screen (detail + comments + interactions) | `lib/post/view/post.view.screen.dart` |
| 4 | Wanted/Hiring Form (9 structured fields) | `lib/post/create/widgets/wanted_hiring_form.dart` |
| 5 | Post Action Buttons (like, reply, share, edit, delete) | `lib/post/view/widgets/post.action.bar.dart` |
| 6 | Comment Input (reply/edit modes) | `lib/post/view/widgets/comment.input.dart` |
| 7 | Comment List (tree-based with thread lines) | `lib/post/view/widgets/comment.list.view.dart` |
| 8 | Post Content Renderer (HTML/Markdown/text) | `lib/post/view/widgets/post.view.content.dart` |
| 9 | Post Files Display (images/videos) | `lib/post/view/widgets/post.view.files.dart` |
| 10 | Forum Screen (infinite scroll + category filter) | `lib/post/list/forum.screen.dart` |
| 11 | Search (Google CSE WebView) | `lib/search/search.screen.dart` |
| 12 | My Posts Screen (user's post list) | `lib/post/my/my.posts.screen.dart` |
| 13 | Post Content Caching (48-hour TTL) | `lib/post/post_content.service.dart` |
| 14 | Category Bottom Sheet (2-level selection) | `lib/post/post_category_bottom_sheet.dart` |
| 15 | Post Blocked User Info | `lib/user/widgets/block.dart` |

### ❌ Missing or Partial in v7

| # | v6 Feature | Status | Notes |
|---|-----------|--------|-------|
| 1 | Quick Post Screen (single-screen category+form) | **MISSING** | v6 had `quick_post.screen.dart` with expandable category groups on same screen. v7 uses bottom sheet category selection instead (different UX, same functionality covered). |

---

## 3. COMPANY MODULE

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Company List (masonry grid + 16 category filters) | `lib/company/list/company.list.screen.dart` |
| 2 | Company View (SliverAppBar + 4 sections) | `lib/company/view/company.view.screen.dart` |
| 3 | Company Form (4-step wizard) | `lib/company/edit/company.edit.screen.dart` |
| 4 | QR Code Display & Share/Download | `lib/company/qr/company.qr_code.screen.dart` |
| 5 | QR Code Scanned Result (triple combo flow) | `lib/company/qr/company.qr_code_scanned.screen.dart` |
| 6 | Revisit Point Result | `lib/company/review/company.revisit_point_result.screen.dart` |
| 7 | Review Point Result | `lib/company/review/company.review_point_result.screen.dart` |
| 8 | Visit Review (photo upload + submission) | `lib/company/review/company.visit_review.screen.dart` |
| 9 | Company API Service (full CRUD + QR + reviews) | `lib/company/company.service.dart` |
| 10 | Company Data Model | `lib/company/company.model.dart` |

---

## 4. USER / ACCOUNT

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Profile Edit (photo, nickname, name) | `lib/user/edit/user.edit.screen.dart` |
| 2 | Profile View (public profile) | `lib/user/other_user/other_user.screen.dart` |
| 3 | Account Withdrawal (5-step guide + email) | `lib/user/account_withdrawal.screen.dart` |
| 4 | Login (social auth: Kakao + Google) | `lib/user/login/user.login.screen.dart` |
| 5 | File Upload Widget (camera/gallery/file + progress) | `lib/file/upload/widgets/file_upload.dart` |
| 6 | File Display Widget (images/videos/docs) | `lib/file/widgets/uploaded_file_preview.dart` |
| 7 | User API (me, get, update, delete, search) | `lib/user/user.service.dart` |
| 8 | Upload API (upload, delete, updateAttached) | `lib/api/api.service.dart` |
| 9 | Block/Unblock Users | `lib/user/widgets/block_user_dialog.dart` |
| 10 | Blocked Users List | `lib/user/widgets/blocked_users_bottom_sheet.dart` |
| 11 | Account Merge (v6→v7) | `lib/user/merge/merge_account.screen.dart` |

### ❌ Missing or Partial in v7

| # | v6 Feature | Status | Notes |
|---|-----------|--------|-------|
| 1 | Birth Date & Gender Selection (profile edit) | **MISSING** | v6 had birth date picker (YYYYMMDD) and gender radio buttons (M/F/N) in profile edit. v7 profile edit only has nickname, name, and photo. |
| 2 | User Activity Screen (paginated user posts) | **REPLACED** | v6 had dedicated `user.activity.screen.dart`. v7 uses `my.posts.screen.dart` for own posts and inline recent posts in `other_user.screen.dart` for others. |
| 3 | Block/Report in Other User Profile | **PARTIAL** | v7 `other_user.screen.dart` shows "준비 중입니다" (In preparation) for both block and report actions in popup menu (lines 170-176). |

---

## 5. CHAT

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Chat Home (pinned rooms + room list) | `lib/chat/chat.screen.dart` |
| 2 | Bookmarked/Favorite Chats Dialog | `lib/chat/widgets/bookmarked_chats_dialog.dart` |
| 3 | Chat Room (messages, input, 1:1) | `lib/chat/room/chat.room.screen.dart` |

### Notes
- v6 had dual bottom nav (standard + chat-specific). v7 uses standard 5-tab nav for all screens.
- v7 has additional features not in v6: search friends dialog, pinned chat rooms list.

---

## 6. EVENT SYSTEM

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Company Event Screen (triple combo guide) | `lib/event/company_event.screen.dart` |
| 2 | QR Scanner (mobile_scanner) | `lib/event/qr_scanner.screen.dart` |
| 3 | Event Entry (spinning wheel game) | `lib/event/event_entry.screen.dart` |
| 4 | Event Coupons (won coupons display) | `lib/event/event_coupon.screen.dart` |

---

## 7. INFORMATION / GUIDE SCREENS ⚠️ MAJOR GAP

This is the largest gap between v6 and v7. v6 had **50+ individual hardcoded information screens** with rich content about Philippines life. v7 has a **generic info framework** (`info_view.screen.dart` with markdown support) but only **3 content screens** implemented.

### ✅ Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | Essential Info Menu (category-based navigation) | `lib/info/essential_info.screen.dart` |
| 2 | Info View Screen (generic markdown viewer) | `lib/info/info_view.screen.dart` |
| 3 | App Guide (onboarding) | `lib/guide/app_guide.screen.dart` |

### ❌ MISSING: Emergency & Contact Screens (6 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Emergency Contact (unified view + quick-dial) | `emergency_contact.screen.dart` | **MISSING** |
| 2 | Embassy Info | `embassy.screen.dart` | **MISSING** |
| 3 | Korean Association | `korean_association.screen.dart` | **MISSING** |
| 4 | Police Station | `police_station.screen.dart` | **MISSING** |
| 5 | Hospital | `hospital.screen.dart` | **MISSING** |
| 6 | Emergency Contact Data | `emergency_contacts.data.dart` | **MISSING** |

### ❌ MISSING: Immigration & Visa Screens (4 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | e-Travel Guide | `e_travel.screen.dart` | **MISSING** |
| 2 | Travel Visa | `travel_visa.screen.dart` | **MISSING** |
| 3 | Working Visa (9G) | `working_visa.screen.dart` | **MISSING** |
| 4 | Retirement Visa (SRRV) | `retirement_visa.screen.dart` | **MISSING** |

### ❌ MISSING: Housing Screens (3 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Monthly Rent | `monthly_rent.screen.dart` | **MISSING** |
| 2 | Airbnb | `airbnb.screen.dart` | **MISSING** |
| 3 | Hotel | `hotel.screen.dart` | **MISSING** |

### ❌ MISSING: Residence Area Screens (3 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Alabang | `alabang.screen.dart` | **MISSING** |
| 2 | BGC | `bgc.screen.dart` | **MISSING** |
| 3 | Ortigas | `ortigas.screen.dart` | **MISSING** |

### ❌ MISSING: Transportation Screens (3 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Grab/Taxi Guide | `grab_taxi.screen.dart` | **MISSING** |
| 2 | Express Bus | `express_bus.screen.dart` | **MISSING** |
| 3 | Regular Taxi | `regular_taxi.screen.dart` | **MISSING** |

### ❌ MISSING: Car Screens (3 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Car Purchase | `car_purchase.screen.dart` | **MISSING** |
| 2 | Car Insurance | `car_insurance.screen.dart` | **MISSING** |
| 3 | OR Renewal | `or_renewal.screen.dart` | **MISSING** |

### ❌ MISSING: Helper Service Screens (3 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Tutor | `tutor.screen.dart` | **MISSING** |
| 2 | House Helper | `house_helper.screen.dart` | **MISSING** |
| 3 | Driver | `driver.screen.dart` | **MISSING** |

### ❌ MISSING: Entertainment Screens (9 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Golf | `golf.screen.dart` | **MISSING** |
| 2 | Massage | `massage.screen.dart` | **MISSING** |
| 3 | Nightlife | `nightlife.screen.dart` | **MISSING** |
| 4 | Market Tour | `market_tour.screen.dart` | **MISSING** |
| 5 | Seafood | `seafood.screen.dart` | **MISSING** |
| 6 | Restaurant Guide | `restaurant.screen.dart` | **MISSING** |
| 7 | Water Sports | `water_sports.screen.dart` | **MISSING** |
| 8 | Island Tour | `island_tour.screen.dart` | **MISSING** |
| 9 | Festival | `festival.screen.dart` | **MISSING** |

### ❌ MISSING: Travel Destination Screens (7 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Manila | `manila.screen.dart` | **MISSING** |
| 2 | Cebu | `cebu.screen.dart` | **MISSING** |
| 3 | Subic | `subic.screen.dart` | **MISSING** |
| 4 | Bohol | `bohol.screen.dart` | **MISSING** |
| 5 | Boracay | `boracay.screen.dart` | **MISSING** |
| 6 | Palawan | `palawan.screen.dart` | **MISSING** |
| 7 | El Nido | `el_nido.screen.dart` | **MISSING** |

### ❌ MISSING: Life Information Screens (7 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Travel Info (comprehensive guide) | `travel_info.screen.dart` | **MISSING** |
| 2 | Monthly Living (month-long stay guide) | `monthly_living.screen.dart` | **MISSING** |
| 3 | Holiday Calendar (2026) | `holiday.screen.dart` | **MISSING** |
| 4 | Food Delivery (Grab Food) | `food_delivery.screen.dart` | **MISSING** |
| 5 | Baedal-K (Korean delivery) | `baedal_k.screen.dart` | **MISSING** |
| 6 | Must Read Screen (aggregated info menu) | `must_read.screen.dart` | **MISSING** |
| 7 | Philippine Life Info Data | `philippine_life_info.data.dart` | **MISSING** |

### ❌ MISSING: Travel Spot System (2 screens)

| # | v6 Screen | v6 File | Status |
|---|-----------|---------|--------|
| 1 | Travel Spots (searchable directory) | `travel_spots.screen.dart` | **MISSING** |
| 2 | Travel Spot View (detail with markdown) | `travel_spot.view.screen.dart` | **MISSING** |

### ❌ MISSING: Menu Data Files (11 data files)

| # | v6 Data File | Status |
|---|-------------|--------|
| 1 | `car_menu.data.dart` | **MISSING** |
| 2 | `emergency_menu.data.dart` | **MISSING** |
| 3 | `entertainment_menu.data.dart` | **MISSING** |
| 4 | `helper_menu.data.dart` | **MISSING** |
| 5 | `housing_menu.data.dart` | **MISSING** |
| 6 | `immigration_menu.data.dart` | **MISSING** |
| 7 | `residence_menu.data.dart` | **MISSING** |
| 8 | `transportation_menu.data.dart` | **MISSING** |
| 9 | `travel_destination_menu.data.dart` | **MISSING** |
| 10 | `post_content_mapping.data.dart` | **MISSING** |
| 11 | `contact_item.model.dart` | **MISSING** |

---

## 8. SERVICES & UTILITIES

### ✅ Fully Implemented in v7

| # | v6 Service | v7 Location |
|---|-----------|-------------|
| 1 | Weather Service (Open-Meteo, 20min cache) | `lib/weather/weather.service.dart` |
| 2 | Currency Service (Frankfurter, 25min cache) | `lib/currency/currency.service.dart` |
| 3 | Chat Sound Service | `lib/chat/chat_sound.service.dart` |
| 4 | V7 API Core (Dio + Firebase token) | `lib/api/api.service.dart` |
| 5 | Settings Service (periodic refresh) | `lib/setting/setting.service.dart` |

### Notes
- v6 `DataService` (MOFA notices) → v7 `notice.service.dart` ✅
- v6 `TravelSpotService` → **MISSING** in v7 (travel spots feature not implemented)
- v6 `MemoryCacheService` → v7 uses inline caching in each service ✅
- v6 `PostContentService` → v7 `post_content.service.dart` ✅

---

## 9. NAVIGATION & STATE

### ✅ Fully Implemented in v7

| # | v6 Feature | v7 Location |
|---|-----------|-------------|
| 1 | GoRouter Configuration | `lib/router.dart` |
| 2 | Navigation State (tab management) | `lib/app/app.navigaton.state.dart` |
| 3 | App State (Provider setup) | `lib/main.dart` |
| 4 | Settings State (ChangeNotifier) | `lib/setting/setting.state.dart` |

---

## 10. ADDITIONAL v7 FEATURES (Not in v6)

These features exist in v7 but were NOT present in v6:

| # | Feature | v7 Location |
|---|---------|-------------|
| 1 | AI Answer Widget (SSE streaming) | `lib/ai/ai.service.dart`, `lib/ai/widgets/ai_answer_widget.dart` |
| 2 | Receive Share (external app sharing) | `lib/receive_share/` |
| 3 | Bookmark System (groups + entities) | `lib/bookmark/` |
| 4 | Account Merge (v6→v7) | `lib/user/merge/` |
| 5 | Point Advertisements (post promotion) | `lib/point/point_advertisement.service.dart` |
| 6 | Push Notification Icon Widget | `lib/messaging/widget/push_notification_icon.dart` |
| 7 | Google Sign-In | `lib/user/login/widgets/google_signin.button.dart` |
| 8 | Kakao Sign-In | `lib/user/login/widgets/kakao_signin.button.dart` |

---

## Priority Recommendations

### 🔴 HIGH PRIORITY (Core UX missing)

1. **Emergency Contact Screen** — Safety-critical feature for users in the Philippines
2. **Immigration/Visa Screens (4)** — Essential for foreign residents (eTravel, Travel Visa, Working Visa, Retirement Visa)
3. **Must Read Screen** — Central hub for all information access
4. **Block/Report in User Profile** — Currently shows "In preparation" message

### 🟡 MEDIUM PRIORITY (Important content)

5. **Travel Destination Screens (7)** — Key tourism content
6. **Housing Screens (3)** — Important for long-term residents
7. **Transportation Screens (3)** — Daily life essential
8. **Travel Spots System (2 screens + service)** — Searchable travel directory
9. **Monthly Living Screen** — Comprehensive guide for newcomers
10. **Birth Date & Gender in Profile Edit** — User profile completeness

### 🟢 LOW PRIORITY (Nice-to-have content)

11. **Entertainment Screens (9)** — Lifestyle content
12. **Helper Service Screens (3)** — Niche but useful
13. **Car Screens (3)** — Specific to car owners
14. **Residence Area Screens (3)** — Area-specific info
15. **Delivery Screens (2)** — Food delivery guides
16. **Photo Grid Section on Home** — Marketplace photo showcase
17. **Menu Data Files (11)** — Navigation data for info screens

---

## Architecture Note for Migration

v6 used **hardcoded Dart screens** for all information content (50+ individual screen files with static text). v7 has a **generic info viewer** (`info_view.screen.dart`) that renders markdown content from the v7 API.

**Recommended Migration Strategy:**
- Instead of recreating 50+ individual Dart screen files, migrate content to the v7 backend as info posts
- Use the existing `InfoViewScreen` + `PostContentService` to display content dynamically
- Use `EssentialInfoScreen` pattern for menu navigation to info content
- Only create custom screens for features requiring special UI (e.g., Emergency Contact with quick-dial, Exchange Rate calculator, Travel Spots search/filter)

---

*End of Report*
