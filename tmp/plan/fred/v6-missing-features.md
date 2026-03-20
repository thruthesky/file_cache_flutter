# V6 Features Missing from V7

Generated: 2026-03-20
Updated: 2026-03-20 (cross-referenced with `tmp/plans/new-version-plan.md` + v6 code audit)

---

## 🔴 Critical (Legal / Safety / Core)

1. ~~**Account withdrawal screen** — Account deletion flow (legal requirement)~~ ✅ Completed (2026-03-20)
2. **Emergency contact screen** — Emergency contacts (PNP, embassy, ambulance, etc.)
3. **Policy acceptance dialogs** — Terms of service / privacy policy consent
4. ~~**Post report button** — Report posts (community moderation)~~ ✅ Already in v7 (`lib/post/view/widgets/post.action.bar.dart`)
5. **Phone sign-in (OTP)** — Phone number login (existing user authentication). **Note:** v7 intentionally uses Google + Kakao social login instead. Needs clarification if OTP is still required.
6. **Build number check / forced update** — Force app update when minimum build number changes (`v6/functions/init/build_number_check.dart`) *[NEW — from plan cross-reference]*

---

## 🟠 High Priority (Core UX)

7. ~~**Post share button** — Share posts via OS share sheet~~ ✅ Completed (2026-03-20)
8. ~~**Post block user button** (in post view) — Block user directly from post view~~ ✅ Already in v7 (`lib/post/view/widgets/post.action.bar.dart`)
9. **Quick post screen** — Quick post creation (category selection + inline form)
10. **Wanted/hiring special form** — Dedicated form for job postings (subject, company name, scope, address, phone, email, salary, work type)
11. ~~**Chat sorting/ordering** — Sort and reorder chat rooms~~ ✅ Already in v7 (`lib/chat/chat.screen.dart`)
12. ~~**My company display in menu** — Show user's own company in menu screen~~ ✅ Already in v7 (`lib/menu/menu.screen.dart` with CompanyService.companyNotifier)
13. **Settings screen** — App settings screen (state/service exist but no UI screen)
14. **Follow/unfollow user** — Follow and unfollow users
15. **Notice dedicated screen** — Full notice screen (including MOFA announcements)
16. **User activity screen** — View own posts/comments history (`v6/screens/user/user.activity.screen.dart`) *[NEW — from plan cross-reference]*
17. **Advertisement view screen** — Ad detail viewing (`v6/screens/advertisement/advertisement.view.screen.dart`) *[NEW — from plan cross-reference]*

---

## 🟡 Medium Priority (QR / Event System)

18. ~~**Company QR code display screen** — Display company QR code~~ ✅ Completed (2026-03-20)
19. ~~**Company QR code share/download** — Share or download QR code image~~ ✅ Completed (2026-03-20)
20. ~~**QR scanner screen** — Scan QR codes with camera~~ ✅ Completed (2026-03-20)
21. ~~**QR code scanned result screen** — Show result after scanning QR code~~ ✅ Completed (2026-03-20)
22. ~~**Company visit review screen** — Write visit review with photos~~ ✅ Completed (2026-03-20)
23. ~~**Receipt upload (event)** — Upload receipt for event participation~~ ✅ Completed (2026-03-20) (part of visit review photo upload)
24. ~~**Event audio feedback** — Sound effects for spinning wheel~~ ✅ Already existed in v7 (pangpare.mp3 on coupon win)
25. ~~**Coupon share** — Share won coupons~~ ✅ Completed (2026-03-20)

---

## 🟢 Medium Priority (Home / UI)

26. **Exchange rate widget on home** — Currency exchange rate widget on home screen
27. **Weather widget on home** — Weather widget on home screen
28. **Homepage stats (member/post count)** — Member and post count statistics on home
29. **Latest comments section on home** — Latest comments section on home screen
30. **User avatar + settings in AppBar** — User avatar and settings button in home AppBar
31. **Collapsible header on scroll (forum)** — Collapsible header when scrolling forum list
32. **Sequential animation on company list** — Staggered entry animation on company list load
33. **Content container (max-width)** — Max-width constrained content container

---

## 🟣 Medium Priority (Infrastructure / Services) *[NEW SECTION]*

These are **prerequisites** for the 50+ Philippines life info screens:

34. **Post content service** — Post content rendering service with file cache (`v6/services/post_content/post_content.service.dart`)
35. **Post content viewer widget** — HTML content viewer widget (`v6/widgets/post_content/post_content_viewer.dart`)
36. **Post content mapping data** — Maps each info screen to a server post idx (`v6/data/post_content_mapping.data.dart`)
37. **Memory cache service** — LRU in-memory cache, maxEntries=200 (`v6/services/memory_cache/memory_cache.service.dart`)
38. **MOFA notice data service** — Ministry of Foreign Affairs notice API (`v6/services/data/data.service.dart`)
39. **Travel API service** — Travel data API service (`v6/services/travel/travel_spot.service.dart`)
40. **Chat sound service** — Notification sounds for chat messages (`v6/services/chat_sound/chat_sound.service.dart`) *[NEW — from v6 code audit]*

---

## 🔵 Low Priority (Profile / User)

41. **Birth date picker** — Birth date selection in profile edit
42. **Hero animation for profile photo** — Hero transition animation for profile photo
43. **Profile stats (posts, comments, points)** — Full profile statistics (v7 only shows points/level)
44. **Event entry link in menu** — Direct event entry link in menu screen
45. **Event coupon link in menu** — Direct coupon link in menu screen
46. **Forum subcategory grid in menu** — Forum subcategory grid layout in menu screen

---

## ⚪ Low Priority (Philippines Life Info — Static Content)

**PREREQUISITE:** Items #34-36 (Post content system) must be built first.

### Essential Info
47. **Essential info screen** — Essential information (pre-departure checklist, immigration guide, etc.)
48. **Must read screen** — Must-read information categories

### Emergency Info *[NEW — from v6 code audit]*
49. Embassy info — Korean embassy information
50. Police station info — Police station information
51. Hospital info — Hospital information
52. Korean association info — Korean association information

### Transportation
53. Express bus info — Express bus information
54. Grab taxi info — Grab taxi information
55. Regular taxi info — Regular taxi information

### Vehicles
56. Car insurance info — Car insurance information
57. Car purchase info — Car purchase information
58. Car rental info — Car rental information
59. OR renewal info — Official Receipt renewal information

### Accommodation
60. Airbnb info — Airbnb information
61. Hotel info — Hotel information
62. Monthly rent info — Monthly rent information

### Visa / Immigration
63. eTravel info — eTravel registration information
64. Retirement visa info — Retirement visa (SRRV) information
65. Travel visa info — Tourist visa information
66. Working visa info — Working visa information

### Delivery
67. Food delivery info — Food delivery information
68. Baedal K info — Baedal K (Korean delivery) information

### Travel / Entertainment
69. **Travel spots screen** — Travel destination search, filter, and details
70. **Travel spot detail view** — Individual travel spot detail screen *[NEW]*
71. Festival info — Festival information
72. Golf info — Golf information
73. Island tour info — Island hopping tour information
74. Market tour info — Market tour information
75. Massage info — Massage and spa information
76. Nightlife info — Nightlife information
77. Restaurant info — Restaurant information
78. Seafood info — Seafood information
79. Water sports info — Water sports information

### Travel Destinations *[NEW — 7 screens from v6 code audit]*
80. Manila guide — Manila city guide
81. Cebu guide — Cebu city guide
82. Subic guide — Subic area guide
83. Bohol guide — Bohol island guide
84. Boracay guide — Boracay island guide
85. Palawan guide — Palawan island guide
86. El Nido guide — El Nido area guide

### Helper Services
87. Driver helper info — Driver/chauffeur information
88. House helper info — Housekeeping helper information
89. Tutor info — Tutor information

### Residential Areas
90. Alabang area info — Alabang area guide
91. BGC area info — BGC (Bonifacio Global City) area guide
92. Ortigas area info — Ortigas area guide

### Others
93. Holiday info — Philippine holidays information
94. Monthly living info — Monthly living cost information
95. Travel info — General travel information

---

## 🔘 Partial Implementations (Screen Exists But Sub-Features Missing) *[NEW SECTION]*

96. **Home: quick menu carousel** — Quick access carousel for life info shortcuts
97. **Home: photo grid section** — Photo post grid display
98. **Home: shimmer loading** — Post section shimmer loading effect
99. **Company view: visit review section** — Visit review with photo thumbnails
100. **Company form: KakaoTalk QR auto-parse** — Auto-parse KakaoID from QR photo
101. **Company form: extra image fields** — Business license, office interior photos
102. **Post view: blocked user info overlay** — Tap to unblock option on blocked posts
103. **Post view: earned point badge** — Show points earned from post
104. **Chat: unread message badge** — Badge count on navigation bar icon
105. **Forum header: notification icons** — Alert bell button in forum header
106. **Forum header: subcategory list** — Filter tabs for forum subcategories
107. **Menu: point ad item** — Point advertising link in ad section
108. **Menu: life info onTap handlers** — 11 info items missing onTap (buttons exist but do nothing)
109. **Home: helper menu onTap handlers** — 7+ menu items missing onTap

---

## 🔧 System-Level *[NEW SECTION]*

110. **Shorebird code push** — OTA code push (30s first check, 180s interval)
111. **Build number forced update** — Minimum build number check with upgrade dialog

---

## Total: 95 Remaining Features (16 completed)

| Priority | Remaining | Completed |
|----------|-----------|-----------|
| 🔴 Critical | 4 | 2 |
| 🟠 High Priority | 7 | 4 |
| 🟡 Medium (QR/Event) | 0 | 8 |
| 🟢 Medium (Home/UI) | 8 | 0 |
| 🟣 Medium (Infrastructure) | 7 | 0 |
| 🔵 Low (Profile) | 6 | 0 |
| ⚪ Low (Static Content) | 49 | 0 |
| 🔘 Partial Implementations | 14 | 0 |
| 🔧 System-Level | 2 | 0 |
| **Total** | **97** | **14** |

---

## Cross-Reference Notes

- Full cross-reference with `new-version-plan.md` available in `tmp/plan/fred/v6-v7-cross-reference.md`
- Items marked *[NEW]* were discovered during cross-reference and v6 code audit
- Post report (#4), post block user (#8), chat sorting (#11), my company in menu (#12) were incorrectly listed as missing — they already exist in v7
- Phone sign-in (#5) may be an intentional change (v7 uses social login) — needs owner clarification
