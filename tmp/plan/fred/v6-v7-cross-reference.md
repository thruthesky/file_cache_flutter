# V6 → V7 Migration Checklist

> Generated: 2026-03-20
> Sources: `tmp/plans/new-version-plan.md` + `tmp/plan/fred/v6-missing-features.md` + v6 code audit

---

## Critical (Legal / Safety / Core)

- [x] Account withdrawal screen — `lib/user/account_withdrawal.screen.dart` (2026-03-20)
- [x] Post report button — `lib/post/view/widgets/post.action.bar.dart`
- [ ] Emergency contact screen — PNP, embassy, ambulance, etc.
- [ ] Policy acceptance dialogs — Terms of service / privacy policy consent
- [ ] Phone sign-in (OTP) — Phone number login. *Note: v7 uses Google + Kakao instead — clarify if still needed*
- [ ] Build number check / forced update — Force app update when min build number changes

---

## High Priority (Core UX)

- [x] Post share button — `lib/post/view/widgets/post.action.bar.dart` (2026-03-20)
- [x] Post block user button — `lib/post/view/widgets/post.action.bar.dart`
- [x] Chat sorting/ordering — `lib/chat/chat.screen.dart`
- [x] My company display in menu — `lib/menu/menu.screen.dart`
- [ ] Quick post screen — Category selection + inline form
- [ ] Wanted/hiring special form — Job posting dedicated fields (company, salary, scope, etc.)
- [ ] Settings screen — UI screen (service/state exist but no screen)
- [ ] Follow/unfollow user — Removed (2026-03-20). *No backend API exists. Code removed from v7. Needs backend API first (`user.toggleFollow`, `user.isFollowing`, `user.followingList`) before Flutter UI can be re-implemented.*
- [ ] Notice dedicated screen — Full notice screen with MOFA announcements
- [ ] User activity screen — View own posts/comments history
- [ ] Advertisement view screen — Ad detail viewing with contact card

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
- [ ] Weather widget on home
- [ ] Homepage stats (member/post count)
- [ ] Latest comments section on home
- [ ] User avatar + settings in AppBar
- [ ] Collapsible header on scroll (forum)
- [ ] Sequential animation on company list
- [ ] Content container (max-width)

---

## Infrastructure / Services (Prerequisites for 50+ Info Screens)

- [ ] Post content service — Server-stored content loader with file cache
- [ ] Post content viewer widget — HTML content viewer
- [ ] Post content mapping data — Maps each info screen to server post idx
- [ ] Memory cache service — LRU in-memory cache (maxEntries=200)
- [ ] MOFA notice data service — Ministry of Foreign Affairs notice API
- [ ] Travel API service — Travel data API service
- [ ] Chat sound service — Notification sounds for chat messages

---

## Profile / User

- [ ] Birth date picker
- [ ] Hero animation for profile photo
- [ ] Profile stats (posts, comments, points)
- [ ] Event entry link in menu
- [ ] Event coupon link in menu
- [ ] Forum subcategory grid in menu

---

## Philippines Life Info — Static Content

**Prerequisite:** Post content system (service + viewer + mapping) must be built first.

### Essential Info
- [ ] Essential info screen
- [ ] Must read screen

### Emergency Info
- [ ] Embassy info
- [ ] Police station info
- [ ] Hospital info
- [ ] Korean association info

### Transportation
- [ ] Express bus info
- [ ] Grab taxi info
- [ ] Regular taxi info

### Vehicles
- [ ] Car insurance info
- [ ] Car purchase info
- [ ] Car rental info
- [ ] OR renewal info

### Accommodation
- [ ] Airbnb info
- [ ] Hotel info
- [ ] Monthly rent info

### Visa / Immigration
- [ ] eTravel info
- [ ] Retirement visa info
- [ ] Travel visa info
- [ ] Working visa info

### Delivery
- [ ] Food delivery info
- [ ] Baedal K info

### Travel / Entertainment
- [ ] Travel spots screen (search, filter, details)
- [ ] Travel spot detail view
- [ ] Festival info
- [ ] Golf info
- [ ] Island tour info
- [ ] Market tour info
- [ ] Massage info
- [ ] Nightlife info
- [ ] Restaurant info
- [ ] Seafood info
- [ ] Water sports info

### Travel Destinations (7 city/area guides)
- [ ] Manila guide
- [ ] Cebu guide
- [ ] Subic guide
- [ ] Bohol guide
- [ ] Boracay guide
- [ ] Palawan guide
- [ ] El Nido guide

### Helper Services
- [ ] Driver helper info
- [ ] House helper info
- [ ] Tutor info

### Residential Areas
- [ ] Alabang area guide
- [ ] BGC area guide
- [ ] Ortigas area guide

### Others
- [ ] Holiday info
- [ ] Monthly living info
- [ ] Travel info

---

## Partial Implementations (Screen Exists, Sub-Features Missing)

- [ ] Home: quick menu carousel
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

- [ ] Shorebird code push — OTA code push (30s first check, 180s interval)
- [ ] Build number forced update — Min build number check with upgrade dialog

---

## Summary

| Category | Done | Remaining |
|----------|------|-----------|
| Critical | 2 | 4 |
| High Priority | 4 | 7 |
| QR / Event | 8 | 0 |
| Home / UI | 0 | 8 |
| Infrastructure | 0 | 7 |
| Profile / User | 0 | 6 |
| Static Content | 0 | 49 |
| Partial Implementations | 0 | 14 |
| System-Level | 0 | 2 |
| **Total** | **14** | **97** |
