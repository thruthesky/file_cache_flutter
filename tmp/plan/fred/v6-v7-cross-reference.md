# V6 → V7 Migration Checklist

> Generated: 2026-03-20
> Sources: `tmp/plans/new-version-plan.md` + `tmp/plan/fred/v6-missing-features.md` + v6 code audit

---

## Critical (Legal / Safety / Core)

- [x] Account withdrawal screen — `lib/user/account_withdrawal.screen.dart` (2026-03-20)
- [x] Post report button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Emergency contact screen — `lib/info/essential_info.screen.dart` (integrated into Essential Info with InfoAccessCodes) (2026-03-23)
- [~] Policy acceptance dialogs — Terms/Privacy available as menu WebView items (`lib/menu/menu.screen.dart`), but NOT as login/signup consent dialogs
- [ ] Phone sign-in (OTP) — Phone number login. _Note: v7 uses Google + Kakao instead — clarify if still needed_
- [ ] Build number check / forced update — Force app update when min build number changes
  - v6: `v6/functions/init/build_number_check.dart` (5s first check, 5min interval, calls `settings.get` API)

---

## High Priority (Core UX)

- [x] Post share button — `lib/post/view/widgets/post.action.bar.dart` (2026-03-20)
- [x] Post block user button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Chat sorting/ordering — `lib/chat/chat.screen.dart`
- [x] My company display in menu — `lib/menu/menu.screen.dart`
- [x] Quick post screen — `lib/home/widgets/home_quick_post_box.dart` (widget on home, opens category sheet → PostCreateScreen) (2026-03-23)
- [x] Wanted/hiring special form — Job posting dedicated fields (company, salary, scope, etc.) (2026-03-20)
  - v7: `lib/post/create/widgets/wanted_hiring_form.dart`
- [ ] Settings screen — UI screen (service/state exist but no screen)
  - v6: `v6/v7_api/models/v7_settings.dart`, `v6/v7_api/state/v7_settings_state.dart`
- [x] Notice dedicated screen — `lib/notice/notice.screen.dart`, `lib/notice/notice.service.dart`, `lib/notice/notice.model.dart` (MOFA + PhilGo notices, wired to home helper menu + menu screen) (2026-03-23)
- [ ] User activity screen — View own posts/comments history
  - v6: `v6/screens/user/user.activity.screen.dart`
- [ ] Advertisement view screen — Ad detail viewing with contact card
  - v6: `v6/screens/advertisement/advertisement.view.screen.dart`

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
- [ ] Homepage stats (member/post count)
- [x] Latest comments section on home — `lib/home/widgets/home_latest_comments_section.dart` (2026-03-20)
- [x] User avatar + settings in AppBar — `lib/home/home.screen.dart` SliverAppBar (2026-03-20)
- [x] Collapsible header on scroll — `lib/company/view/company.view.screen.dart` and `lib/post/view/post.view.screen.dart` (SliverAppBar pinned + collapse detection) (2026-03-23)
- [x] Sequential animation on company list — `lib/company/list/company.list.screen.dart` flutter_animate stagger (2026-03-20)
- [ ] Content container (max-width)
  - v6: `v6/widgets/layout/content_container.dart` (ConstrainedBox max 800px)

---

## Infrastructure / Services (Prerequisites for 50+ Info Screens)

- [ ] Post content service — Server-stored content loader with file cache
  - v6: `v6/services/post_content/post_content.service.dart` (48-hour cache via `file_cache_flutter`)
- [x] Post content viewer widget — `lib/post/view/widgets/post.view.content.dart` (supports HTML via flutter_html, Markdown, plain text) (2026-03-23)
- [x] Post content mapping data — `lib/api/constants/info_access_codes.dart` (17 access codes mapping info screens to server content via `info.getByAccessCode` API) (2026-03-23)
- [ ] Memory cache service — LRU in-memory cache (maxEntries=200)
- [x] MOFA notice data service — `lib/notice/notice.service.dart` (MOFA API with 6-hour memory cache, `lib/notice/notice.model.dart`) (2026-03-23)
- [ ] Travel API service — Travel data API service
  - v6: `v6/screens/guide/travel_spots.screen.dart`, `v6/screens/guide/travel_spot.view.screen.dart`
- [x] Chat sound service — `lib/chat/chat_sound.service.dart` (send.mp3, beep_message.mp3 via audioplayers) (2026-03-23)

---

## Profile / User

- [ ] Birth date picker
  - v6: `v6/screens/user/profile.edit.screen.dart` (birthDate int field)
- [ ] Hero animation for profile photo
  - v6: `v6/screens/guide/travel_spot.view.screen.dart` (Hero widget pattern)
- [x] Profile stats (posts, comments, points) — `lib/menu/menu.screen.dart` (noOfPost, noOfComment from UserModel) (2026-03-23)
- [x] Event entry link in menu — `lib/home/widgets/home_helper_menu_section.dart` + `lib/event/event_entry.screen.dart` (2026-03-23)
- [x] Event coupon link in menu — `lib/menu/menu.screen.dart` + `lib/event/event_coupon.screen.dart` (2026-03-23)
- [x] Forum subcategory grid in menu — `lib/menu/menu.screen.dart` (커뮤니티, 회원장터, 기타 sections) (2026-03-23)

---

## Philippines Life Info — Static Content

**Prerequisite:** Post content system (service + viewer + mapping) must be built first.

**v6 data files:** `v6/data/philippine_life_info.data.dart`, `v6/data/emergency_menu.data.dart`, `v6/data/entertainment_menu.data.dart`, `v6/data/housing_menu.data.dart`, `v6/data/immigration_menu.data.dart`, `v6/data/residence_menu.data.dart`, `v6/data/transportation_menu.data.dart`, `v6/data/travel_destination_menu.data.dart`

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
- [ ] Car purchase info — _Not found in v6_
- [ ] Car rental info — _Not found in v6_
- [ ] OR renewal info — _Not found in v6_

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

- [ ] Food delivery info — _Not found in v6_
- [ ] Baedal K info — _Not found in v6_

### Travel / Entertainment

- [ ] Travel spots screen (search, filter, details) — v6: `v6/screens/guide/travel_spots.screen.dart`
- [ ] Travel spot detail view — v6: `v6/screens/guide/travel_spot.view.screen.dart`
- [ ] Festival info — v6: `v6/screens/info/entertainment/festival.screen.dart`
- [ ] Golf info — v6: `v6/screens/info/entertainment/golf.screen.dart`
- [ ] Island tour info — _Not found in v6_
- [ ] Market tour info — _Not found in v6_
- [ ] Massage info — v6: `v6/screens/info/entertainment/massage.screen.dart`
- [ ] Nightlife info — v6: `v6/screens/info/entertainment/nightlife.screen.dart`
- [ ] Restaurant info — v6: `v6/screens/info/entertainment/restaurant.screen.dart`
- [ ] Seafood info — _Not found in v6_
- [ ] Water sports info — _Not found in v6_

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
- [ ] House helper info — _Not found in v6_
- [ ] Tutor info — _Not found in v6_

### Residential Areas

- [ ] Alabang area guide — v6: `v6/screens/info/residence/alabang.screen.dart`
- [ ] BGC area guide — v6: `v6/screens/info/residence/bgc.screen.dart`
- [ ] Ortigas area guide — v6: `v6/screens/info/residence/ortigas.screen.dart`

### Others

- [ ] Holiday info — _Not found in v6_
- [ ] Monthly living info — _Not found in v6_
- [ ] Travel info — v6: `v6/screens/info/travel/travel_info.screen.dart`

---

## Partial Implementations (Screen Exists, Sub-Features Missing)

- [x] Home: quick menu carousel
- [ ] Home: photo grid section
- [ ] Home: shimmer loading effect
- [x] Company view: visit review section (photo thumbnails, review CTA)
- [x] Company form: KakaoTalk QR auto-parse
- [x] Company form: extra image fields (business license, office photos)
- [x] Post view: blocked user info overlay (tap to unblock) — `lib/post/list/forum.screen.dart` (dialog on blocked user post with unblock option) (2026-03-23)
- [x] Post view: earned point badge — `lib/point/widgets/earned_point_badge.dart` (2026-03-20)
- [ ] Chat: unread message badge on nav bar
- [ ] Forum header: notification icons
- [ ] Forum header: subcategory filter tabs
- [x] Menu: point ad item in ad section — `lib/point/widgets/point_advertisements.dart` integrated in forum screen (2026-03-23)
- [x] Menu: life info onTap handlers — Weather, Currency, Essential Info all have working onTap (2026-03-23)
- [x] Home: helper menu onTap handlers — `lib/home/widgets/home_helper_menu_section.dart` (내 정보, 업소이벤트, 이벤트응모, 필수정보, 환율, etc.) (2026-03-23)

---

## System-Level

- [x] Shorebird code push — `shorebird_code_push: ^2.0.5` in pubspec.yaml + shorebird.yaml asset (2026-03-23)
- [ ] Build number forced update — Min build number check with upgrade dialog
  - v6: `v6/functions/init/build_number_check.dart`

---

## Summary

| Category                | Done   | Partial | Remaining |
| ----------------------- | ------ | ------- | --------- |
| Critical                | 3      | 1       | 2         |
| High Priority           | 7      | 0       | 3         |
| QR / Event              | 8      | 0       | 0         |
| Home / UI               | 6      | 0       | 2         |
| Infrastructure          | 4      | 0       | 3         |
| Profile / User          | 4      | 0       | 2         |
| Static Content          | 6      | 0       | 43        |
| Partial Implementations | 9      | 0       | 5         |
| System-Level            | 1      | 0       | 1         |
| **Total**               | **48** | **1**   | **61**    |
