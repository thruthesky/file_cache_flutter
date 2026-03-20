# V6 → V7 Migration Checklist

> Generated: 2026-03-20
> Sources: `tmp/plans/new-version-plan.md` + `tmp/plan/fred/v6-missing-features.md` + v6 code audit

---

## Critical (Legal / Safety / Core)

- [x] Account withdrawal screen — `lib/user/account_withdrawal.screen.dart` (2026-03-20)
- [x] Post report button — `lib/post/view/widgets/post.action.bar.dart`
- [ ] Emergency contact screen — PNP, embassy, ambulance, etc.
  - v6: `v6/screens/info/emergency/emergency_contact.screen.dart`
  - v6 data: `v6/data/emergency_contacts.data.dart`, `v6/data/models/contact_item.model.dart`
- [ ] Policy acceptance dialogs — Terms of service / privacy policy consent
  - v6: `v6/widgets/dialogs/policy.dialogs.dart` (bottom sheet with server-fetched content)
- [ ] Phone sign-in (OTP) — Phone number login. *Note: v7 uses Google + Kakao instead — clarify if still needed*
- [ ] Build number check / forced update — Force app update when min build number changes
  - v6: `v6/functions/init/build_number_check.dart` (5s first check, 5min interval, calls `settings.get` API)

---

## High Priority (Core UX)

- [x] Post share button — `lib/post/view/widgets/post.action.bar.dart` (2026-03-20)
- [x] Post block user button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Chat sorting/ordering — `lib/chat/chat.screen.dart`
- [x] My company display in menu — `lib/menu/menu.screen.dart`
- [ ] Quick post screen — Category selection + inline form
  - v6: `v6/screens/post/quick_post.screen.dart`
- [x] Wanted/hiring special form — Job posting dedicated fields (company, salary, scope, etc.) (2026-03-20)
  - v7: `lib/post/create/widgets/wanted_hiring_form.dart`
- [ ] Settings screen — UI screen (service/state exist but no screen)
  - v6: `v6/v7_api/models/v7_settings.dart`, `v6/v7_api/state/v7_settings_state.dart`
- [ ] Follow/unfollow user — Removed (2026-03-20). *No backend API exists. Code removed from v7. Needs backend API first (`user.toggleFollow`, `user.isFollowing`, `user.followingList`) before Flutter UI can be re-implemented.*
- [ ] Notice dedicated screen — Full notice screen with MOFA announcements
  - v6: `v6/screens/info/notice/notice.screen.dart`, `v6/services/data/mofa_notice.model.dart`, `v6/widgets/home/home_notice_section.dart`
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

- [ ] Exchange rate widget on home
  - v6: `v6/screens/info/exchange/exchange_rate.screen.dart`, `v6/services/currency/currency.service.dart`
- [ ] Weather widget on home
  - v6: `v6/screens/weather/weather.screen.dart`, `v6/services/weather/weather.service.dart`, `v6/services/weather/weather.model.dart`
- [ ] Homepage stats (member/post count)
- [x] Latest comments section on home — `lib/home/widgets/home_latest_comments_section.dart` (2026-03-20)
- [x] User avatar + settings in AppBar — `lib/home/home.screen.dart` SliverAppBar (2026-03-20)
- [ ] Collapsible header on scroll (forum)
  - v6: `v6/screens/guide/travel_spot.view.screen.dart` (SliverAppBar with Hero animation + scroll-based collapse)
- [x] Sequential animation on company list — `lib/company/list/company.list.screen.dart` flutter_animate stagger (2026-03-20)
- [ ] Content container (max-width)
  - v6: `v6/widgets/layout/content_container.dart` (ConstrainedBox max 800px)

---

## Infrastructure / Services (Prerequisites for 50+ Info Screens)

- [ ] Post content service — Server-stored content loader with file cache
  - v6: `v6/services/post_content/post_content.service.dart` (48-hour cache via `file_cache_flutter`)
- [ ] Post content viewer widget — HTML content viewer
  - v6: `v6/widgets/post_content/post_content_viewer.dart`
- [ ] Post content mapping data — Maps each info screen to server post idx
  - v6: `v6/data/post_content_mapping.data.dart`
- [ ] Memory cache service — LRU in-memory cache (maxEntries=200)
- [ ] MOFA notice data service — Ministry of Foreign Affairs notice API
  - v6: `v6/services/data/mofa_notice.model.dart`
- [ ] Travel API service — Travel data API service
  - v6: `v6/screens/guide/travel_spots.screen.dart`, `v6/screens/guide/travel_spot.view.screen.dart`
- [ ] Chat sound service — Notification sounds for chat messages

---

## Profile / User

- [ ] Birth date picker
  - v6: `v6/screens/user/profile.edit.screen.dart` (birthDate int field)
- [ ] Hero animation for profile photo
  - v6: `v6/screens/guide/travel_spot.view.screen.dart` (Hero widget pattern)
- [ ] Profile stats (posts, comments, points)
- [ ] Event entry link in menu
- [ ] Event coupon link in menu
- [ ] Forum subcategory grid in menu

---

## Philippines Life Info — Static Content

**Prerequisite:** Post content system (service + viewer + mapping) must be built first.

**v6 data files:** `v6/data/philippine_life_info.data.dart`, `v6/data/emergency_menu.data.dart`, `v6/data/entertainment_menu.data.dart`, `v6/data/housing_menu.data.dart`, `v6/data/immigration_menu.data.dart`, `v6/data/residence_menu.data.dart`, `v6/data/transportation_menu.data.dart`, `v6/data/travel_destination_menu.data.dart`

### Essential Info
- [ ] Essential info screen
- [ ] Must read screen

### Emergency Info
- [ ] Embassy info — v6: `v6/screens/info/emergency/embassy.screen.dart`
- [ ] Police station info — v6: `v6/screens/info/emergency/police_station.screen.dart`
- [ ] Hospital info — v6: `v6/screens/info/emergency/hospital.screen.dart`
- [ ] Korean association info — v6: `v6/screens/info/emergency/korean_association.screen.dart`

### Transportation
- [ ] Express bus info — v6: `v6/screens/info/transportation/express_bus.screen.dart`
- [ ] Grab taxi info — v6: `v6/screens/info/transportation/grab_taxi.screen.dart`
- [ ] Regular taxi info — v6: `v6/screens/info/transportation/regular_taxi.screen.dart`

### Vehicles
- [ ] Car insurance info — v6: `v6/screens/info/car/car_insurance.screen.dart`
- [ ] Car purchase info — *Not found in v6*
- [ ] Car rental info — *Not found in v6*
- [ ] OR renewal info — *Not found in v6*

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
- [ ] Food delivery info — *Not found in v6*
- [ ] Baedal K info — *Not found in v6*

### Travel / Entertainment
- [ ] Travel spots screen (search, filter, details) — v6: `v6/screens/guide/travel_spots.screen.dart`
- [ ] Travel spot detail view — v6: `v6/screens/guide/travel_spot.view.screen.dart`
- [ ] Festival info — v6: `v6/screens/info/entertainment/festival.screen.dart`
- [ ] Golf info — v6: `v6/screens/info/entertainment/golf.screen.dart`
- [ ] Island tour info — *Not found in v6*
- [ ] Market tour info — *Not found in v6*
- [ ] Massage info — v6: `v6/screens/info/entertainment/massage.screen.dart`
- [ ] Nightlife info — v6: `v6/screens/info/entertainment/nightlife.screen.dart`
- [ ] Restaurant info — v6: `v6/screens/info/entertainment/restaurant.screen.dart`
- [ ] Seafood info — *Not found in v6*
- [ ] Water sports info — *Not found in v6*

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
- [ ] House helper info — *Not found in v6*
- [ ] Tutor info — *Not found in v6*

### Residential Areas
- [ ] Alabang area guide — v6: `v6/screens/info/residence/alabang.screen.dart`
- [ ] BGC area guide — v6: `v6/screens/info/residence/bgc.screen.dart`
- [ ] Ortigas area guide — v6: `v6/screens/info/residence/ortigas.screen.dart`

### Others
- [ ] Holiday info — *Not found in v6*
- [ ] Monthly living info — *Not found in v6*
- [ ] Travel info — v6: `v6/screens/info/travel/travel_info.screen.dart`

---

## Partial Implementations (Screen Exists, Sub-Features Missing)

- [x] Home: quick menu carousel
- [ ] Home: photo grid section
- [ ] Home: shimmer loading effect
- [ ] Company view: visit review section (photo thumbnails, review CTA)
- [ ] Company form: KakaoTalk QR auto-parse
- [ ] Company form: extra image fields (business license, office photos)
- [ ] Post view: blocked user info overlay (tap to unblock)
- [ ] Post view: earned point badge
- [ ] Chat: unread message badge on nav bar
- [ ] Forum header: notification icons
- [ ] Forum header: subcategory filter tabs
- [ ] Menu: point ad item in ad section
- [ ] Menu: life info onTap handlers (11 items have no onTap)
- [ ] Home: helper menu onTap handlers (7+ items have no onTap)

---

## System-Level

- [ ] Shorebird code push — OTA code push (30s first check, 180s interval). *Not found in v6 — not implemented*
- [ ] Build number forced update — Min build number check with upgrade dialog
  - v6: `v6/functions/init/build_number_check.dart`

---

## Summary

| Category | Done | Remaining |
|----------|------|-----------|
| Critical | 2 | 4 |
| High Priority | 5 | 6 |
| QR / Event | 8 | 0 |
| Home / UI | 3 | 5 |
| Infrastructure | 0 | 7 |
| Profile / User | 0 | 6 |
| Static Content | 0 | 49 |
| Partial Implementations | 0 | 14 |
| System-Level | 0 | 2 |
| **Total** | **18** | **93** |
