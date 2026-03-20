# v6 -> v7 마이그레이션 계획: v6에 있지만 v7에 없는 기능 목록

> 분석 날짜: 2026-03-20
> v6 소스: `v6/` 폴더 (레거시 Flutter 앱)
> v7 소스: `lib/` 폴더 (현재 개발 중인 Flutter 앱)

---

## A. 완전히 빠진 화면/기능 (v7에 해당 화면이 없음)

### A1. 필리핀 생활 정보 화면들 (약 45개 화면)

v6에는 필리핀 생활에 필요한 정보 화면들이 대량으로 존재하지만, v7에는 해당 화면이 전혀 없음.
v7 메뉴(`lib/menu/menu.screen.dart`)에 버튼은 있으나 **모든 onTap이 미구현 상태**.

#### 비자/이민 정보 (4개)
- [ ] `ETravelScreen` - e트래블 정보 (`v6/screens/info/immigration/e_travel.screen.dart`)
- [ ] `TravelVisaScreen` - 여행비자 정보 (`v6/screens/info/immigration/travel_visa.screen.dart`)
- [ ] `WorkingVisaScreen` - 워킹비자 정보 (`v6/screens/info/immigration/working_visa.screen.dart`)
- [ ] `RetirementVisaScreen` - 은퇴비자 정보 (`v6/screens/info/immigration/retirement_visa.screen.dart`)

#### 교통 정보 (3개)
- [ ] `GrabTaxiScreen` - 그랩 택시 이용법 (`v6/screens/info/transportation/grab_taxi.screen.dart`)
- [ ] `RegularTaxiScreen` - 일반 택시 이용법 (`v6/screens/info/transportation/regular_taxi.screen.dart`)
- [ ] `ExpressBusScreen` - 고속버스 이용법 (`v6/screens/info/transportation/express_bus.screen.dart`)

#### 숙소 정보 (3개)
- [ ] `MonthlyRentScreen` - 월세 정보 (`v6/screens/info/housing/monthly_rent.screen.dart`)
- [ ] `AirbnbScreen` - 에어비앤비 정보 (`v6/screens/info/housing/airbnb.screen.dart`)
- [ ] `HotelScreen` - 호텔 정보 (`v6/screens/info/housing/hotel.screen.dart`)

#### 자동차 정보 (4개)
- [ ] `CarPurchaseScreen` - 자동차 구매 (`v6/screens/info/car/car_purchase.screen.dart`)
- [ ] `CarInsuranceScreen` - 자동차 보험 (`v6/screens/info/car/car_insurance.screen.dart`)
- [ ] `CarRentalScreen` - 자동차 렌트 (`v6/screens/info/car/car_rental.screen.dart`)
- [ ] `OrRenewalScreen` - OR 리뉴얼 (`v6/screens/info/car/or_renewal.screen.dart`)

#### 거주지 정보 (3개)
- [ ] `BgcScreen` - BGC 거주 정보 (`v6/screens/info/residence/bgc.screen.dart`)
- [ ] `OrtigasScreen` - 올티가스 거주 정보 (`v6/screens/info/residence/ortigas.screen.dart`)
- [ ] `AlabangScreen` - 알라방 거주 정보 (`v6/screens/info/residence/alabang.screen.dart`)

#### 여행지 정보 (7개)
- [ ] `ManilaScreen` - 마닐라 (`v6/screens/info/travel_destination/manila.screen.dart`)
- [ ] `CebuScreen` - 세부 (`v6/screens/info/travel_destination/cebu.screen.dart`)
- [ ] `SubicScreen` - 수빅 (`v6/screens/info/travel_destination/subic.screen.dart`)
- [ ] `BoholScreen` - 보홀 (`v6/screens/info/travel_destination/bohol.screen.dart`)
- [ ] `BoracayScreen` - 보라카이 (`v6/screens/info/travel_destination/boracay.screen.dart`)
- [ ] `PalawanScreen` - 팔라완 (`v6/screens/info/travel_destination/palawan.screen.dart`)
- [ ] `ElNidoScreen` - 엘니도 (`v6/screens/info/travel_destination/el_nido.screen.dart`)

#### 도우미 정보 (3개)
- [ ] `HouseHelperScreen` - 하우스헬퍼 (`v6/screens/info/helper/house_helper.screen.dart`)
- [ ] `DriverScreen` - 운전기사 (`v6/screens/info/helper/driver.screen.dart`)
- [ ] `TutorScreen` - 가정교사 (`v6/screens/info/helper/tutor.screen.dart`)

#### 엔터테인먼트 정보 (9개)
- [ ] `GolfScreen` - 골프 (`v6/screens/info/entertainment/golf.screen.dart`)
- [ ] `MassageScreen` - 마사지 (`v6/screens/info/entertainment/massage.screen.dart`)
- [ ] `NightlifeScreen` - 밤문화 (`v6/screens/info/entertainment/nightlife.screen.dart`)
- [ ] `MarketTourScreen` - 시장투어 (`v6/screens/info/entertainment/market_tour.screen.dart`)
- [ ] `SeafoodScreen` - 해산물 (`v6/screens/info/entertainment/seafood.screen.dart`)
- [ ] `RestaurantScreen` - 맛집 (`v6/screens/info/entertainment/restaurant.screen.dart`)
- [ ] `WaterSportsScreen` - 수상스포츠 (`v6/screens/info/entertainment/water_sports.screen.dart`)
- [ ] `IslandTourScreen` - 섬투어 (`v6/screens/info/entertainment/island_tour.screen.dart`)
- [ ] `FestivalScreen` - 축제 (`v6/screens/info/entertainment/festival.screen.dart`)

#### 긴급 정보 (5개)
- [ ] `EmbassyScreen` - 대사관 정보 (`v6/screens/info/emergency/embassy.screen.dart`)
- [ ] `PoliceStationScreen` - 경찰서 정보 (`v6/screens/info/emergency/police_station.screen.dart`)
- [ ] `HospitalScreen` - 병원 정보 (`v6/screens/info/emergency/hospital.screen.dart`)
- [ ] `KoreanAssociationScreen` - 한인회 정보 (`v6/screens/info/emergency/korean_association.screen.dart`)
- [ ] `EmergencyContactScreen` - 긴급연락처 (`v6/screens/info/emergency/emergency_contact.screen.dart`)

#### 기타 정보 화면 (7개)
- [ ] `NoticeScreen` - 공지사항/MOFA 공지 (`v6/screens/info/notice/notice.screen.dart`)
- [ ] `ExchangeRateScreen` - 환율 정보 (`v6/screens/info/exchange/exchange_rate.screen.dart`)
- [ ] `EssentialInfoScreen` - 필수 정보 (`v6/screens/info/essential/essential_info.screen.dart`)
- [ ] `MonthlyLivingScreen` - 한달살기 정보 (`v6/screens/info/monthly/monthly_living.screen.dart`)
- [ ] `TravelInfoScreen` - 여행 정보 (`v6/screens/info/travel/travel_info.screen.dart`)
- [ ] `FoodDeliveryScreen` - 음식 배달 (Grab) (`v6/screens/info/delivery/food_delivery.screen.dart`)
- [ ] `BaedalKScreen` - 배달K (한국 음식 배달) (`v6/screens/info/delivery/baedal_k.screen.dart`)

#### 정보 관련 데이터/서비스 (v7에 없음)
- [ ] `v6/data/transportation_menu.data.dart` - 교통 메뉴 데이터
- [ ] `v6/data/emergency_menu.data.dart` - 긴급 메뉴 데이터
- [ ] `v6/data/helper_menu.data.dart` - 도우미 메뉴 데이터
- [ ] `v6/data/car_menu.data.dart` - 자동차 메뉴 데이터
- [ ] `v6/data/immigration_menu.data.dart` - 이민 메뉴 데이터
- [ ] `v6/data/entertainment_menu.data.dart` - 엔터테인먼트 메뉴 데이터
- [ ] `v6/data/emergency_contacts.data.dart` - 긴급 연락처 데이터
- [ ] `v6/data/philippine_life_info.data.dart` - 필리핀 생활 정보 데이터
- [ ] `v6/data/residence_menu.data.dart` - 거주지 메뉴 데이터
- [ ] `v6/data/housing_menu.data.dart` - 숙소 메뉴 데이터
- [ ] `v6/data/travel_destination_menu.data.dart` - 여행지 메뉴 데이터
- [ ] `v6/data/models/contact_item.model.dart` - 연락처 아이템 모델

### A2. 가이드/필독 화면들 (3개)

- [ ] `MustReadScreen` - 초보자 필독 정보 (`v6/screens/guide/must_read.screen.dart`)
- [ ] `AppGuideScreen` - 앱 사용 가이드 (`v6/screens/guide/app.guide.screen.dart`)
  - v7 메뉴에 '앱 사용 안내' 버튼이 있지만 onTap 미구현
- [ ] `TravelSpotsScreen` / `TravelSpotViewScreen` - 여행 명소 목록/상세 (`v6/screens/guide/travel_spots.screen.dart`, `travel_spot.view.screen.dart`)

### A3. 날씨 기능

- [ ] `WeatherScreen` - 5개 도시 6일 날씨 예보 (`v6/screens/weather/weather.screen.dart`)
  - 마닐라, 세부, 앙헬레스, 보라카이, 바기오
  - 테이블 형식 (세로/가로 스크롤), 오늘 2시간 간격 / 내일~5일 4시간 간격
  - WMO 날씨 코드별 아이콘+색상+한글설명
- [ ] `WeatherService` - Open-Meteo API 서비스 (`v6/services/weather/weather.service.dart`)
  - 5개 도시 병렬 API 호출, FileCache TTL 20분
  - `loadManilaCurrentWeather()` - Entry 화면용 현재 날씨
- [ ] `WeatherModel` - 날씨 데이터 모델 (`v6/services/weather/weather.model.dart`)
  - PhilippineCity, HourlyWeather, WeatherCodeHelper 클래스

### A4. 검색 기능

- [ ] `SearchScreen` - Google CSE WebView 검색 (`v6/screens/search/search.screen.dart`)
  - CSE ID: d37786943cf92484d
  - URL: `https://philgo.com/page/search/cse.php`
  - **WebView 내 필고 URL 감지**: 검색 결과 클릭 시 PostViewScreen으로 앱 내 이동
- [ ] 검색 다이얼로그 (`v6/widgets/dialogs/search_dialog.dart`)
  - Comic 스타일, 자동 키보드 표시, 검색어 입력 후 SearchScreen으로 이동
  - v6에서는 포럼 헤더에 검색 버튼이 있어 Google CSE로 검색 가능

### A5. 계정 탈퇴 화면

- [ ] `AccountWithdrawalScreen` - 계정 탈퇴 (`v6/screens/account/account.withdrawal.screen.dart`)
  - v7 메뉴에 '계정 삭제' 버튼이 있지만 **TODO 상태** (`lib/menu/menu.screen.dart:209`)
  - v6의 4단계 구조: (1) 삭제될 데이터 안내 (2) 삭제 방법(이메일 요청) (3) 처리 타임라인 (4) 데이터 보관 예외

### A6. QR 코드 / 방문 리뷰 관련 (6개 화면 + 3단계 콤보 시스템)

업소록의 QR 코드 및 방문 리뷰/포인트 시스템이 v7에 없음.

**QR 3단계 콤보 플로우:**
1. QR 스캔 → `company.scanQrCode` API → usage_idx 획득
2. 재방문: `company.reVisitPoint(usage_idx)` → 2~3천P 랜덤 적립
3. 후기 작성: `company.submitVisitReview(usage_idx, content, photoIdxs)` → 추가 포인트

- [ ] `CompanyQrCodeScreen` - 업소 QR 코드 생성/공유/다운로드 (`v6/screens/company/company.qr_code.screen.dart`)
  - qr_flutter 240px, RepaintBoundary→Gal 갤러리 저장, 부정 사용 경고 배너
- [ ] `QrScannerScreen` - mobile_scanner QR 스캐너 (`v6/screens/event/qr_scanner.screen.dart`)
  - URL 파싱: `philgo.com/company/qr-code-scanned.php?code={64자hex}&idx={optional}`
- [ ] `CompanyQrCodeScannedScreen` - 스캔 결과 + 에러 분류 (`v6/screens/company/company.qr_code_scanned.screen.dart`)
  - 에러 분류: 24시간 중복(이전 방문 시간 표시), 만료, 비활성화, 업소 유효성
  - 사용자 정보 + 포인트 표시, 재방문/첫방문 CTA 분기
- [ ] `CompanyVisitReviewScreen` - 방문 후기 작성 (`v6/screens/company/company.visit_review.screen.dart`)
  - 내용 10자 이상 + 사진 1장 이상 필수, V7FileUpload 진행률 표시
- [ ] `CompanyReviewPointResultScreen` - 후기 포인트 결과 (`v6/screens/company/company.review_point_result.screen.dart`)
- [ ] `CompanyRevisitPointResultScreen` - 재방문 포인트 결과 (`v6/screens/company/company.revisit_point_result.screen.dart`)
  - 자동 API 호출 + 파티혼 애니메이션 + 포인트 before→after 표시

### A7. 사용자 활동 화면

- [ ] `UserActivityScreen` - 사용자 활동 (게시글/댓글 목록) (`v6/screens/user/user.activity.screen.dart`)
  - v7에는 `OtherUserScreen`이 있지만, 사용자 활동(내 활동) 화면과는 다른 기능
  - v6에서는 메뉴의 '내 활동'에서 자신의 게시글/댓글 전체 목록을 볼 수 있음

### A8. 광고 관련

- [ ] `AdvertisementViewScreen` - 광고 상세 보기 (`v6/screens/advertisement/advertisement.view.screen.dart`)
  - getPost(idx) + increasePostView(idx) 호출
- [ ] 광고 연락처 위젯 (`v6/widgets/contact/`)
  - 필드 매핑: varchar11(카톡), varchar14(텔레그램), varchar15(전화), varchar16(위챗), text3(라인), varchar10(페북메신저)
  - AdvertisementContactCard 카드 형태 표시

### A9. 퀵 포스트 화면

- [ ] `QuickPostScreen` - 카테고리 선택 + 글쓰기 통합 화면 (`v6/screens/post/quick_post.screen.dart`)
  - v7에서는 HomeQuickPostBox 클릭 시 PostCategoryBottomSheet가 나오지만,
    v6처럼 같은 화면에서 카테고리 선택 후 글쓰기 폼이 나타나는 통합 UX는 없음

### A10. 구인/구직 전용 폼

- [ ] `WantedHiringForm` - 구인(hiring) 카테고리 전용 폼 (`v6/screens/post/widgets/wanted_hiring_form.dart`)
  - 필드: 제목(subject), 회사 이름(varchar_4), 회사 소개(text_1), 업무 범위(varchar_9), 주소(varchar_5), 전화번호(varchar_6), 이메일(varchar_8), 급여/페소(int_1), 근무제(varchar_7)
  - 생성/수정 모드 지원, 파일 업로드, 디버그 모드 기본값 입력
  - v7의 PostCreateScreen에서는 구인 전용 필드가 없음
  - wanted 게시판에서 hiring/looking 서브카테고리 필수 선택

### A11. 환율 서비스

- [ ] `CurrencyService` - Frankfurter API 서비스 (`v6/services/currency/currency.service.dart`)
  - USD/PHP/KRW 3개 통화 환율 조회, FileCache TTL 25분
  - 환율 계산기: 입력값 기준 통화 변환 기능
  - ExchangeRateData 모델: usdRates, phpRates, krwRates 매핑

### A12. 게시글 콘텐츠 뷰어 (정보 화면의 핵심 인프라)

- [ ] `PostContentService` - 게시글 콘텐츠 서비스 (`v6/services/post_content/post_content.service.dart`)
  - 싱글톤 패턴, FileCache 사용, TTL 48시간, 메모리+파일 이중 캐싱
- [ ] `PostContentViewer` - HTML 콘텐츠 뷰어 위젯 (`v6/widgets/post_content/post_content_viewer.dart`)
  - PostContentService로 게시글 로드, RefreshIndicator 지원
- [ ] `post_content_mapping.data.dart` - 게시글 번호 매핑 (`v6/data/post_content_mapping.data.dart`)
  - 각 정보 화면에서 표시할 필고 게시글 번호 중앙 관리
  - 매핑 예: orRenewal=1275694642, eTravel=1275694710, travelVisa=1275694730 등
  - **중요**: A1의 필리핀 생활 정보 화면들은 이 시스템을 통해 서버의 게시글 내용을 표시함

### A13. 홈페이지 통계/MOFA 공지

- [ ] `DataService` - 홈페이지 통계 + MOFA 공지 서비스 (`v6/services/data/data.service.dart`)
  - 공공데이터 포털 API: `apis.data.go.kr/1262000/NoticeService2/getNoticeList2`
  - FileCache TTL 48시간, 최근 5개 공지 조회
  - HTML 엔티티 디코딩 (nbsp, amp, lt, gt, middot 등)
- [ ] `MofaNoticeModel` - MOFA 공지 모델 (`v6/services/data/mofa_notice.model.dart`)
  - id, title, content, writtenDate, fileUrl 필드

### A14. 메모리 캐시 서비스

- [ ] `MemoryCacheService` - LRU 메모리 캐시 (`v6/services/memory_cache/memory_cache.service.dart`)
  - maxEntries=200, LRU 정책 (초과 시 가장 오래된 항목 제거)

### A15. 모델 클래스

- [ ] `FestivalModel` - 축제 모델 (`v6/models/festival.model.dart`)
  - festivals.json 번들, 지역/월/카테고리 필터링
- [ ] `TravelSpotModel` - 여행 명소 모델 (`v6/models/travel_spot.model.dart`)
  - v7 Travel API 연동, Isolate로 대용량 JSON 파싱
  - matchesSearch(): 모든 필드에서 검색
- [ ] `BannerModel` - 배너 모델 (`v6/models/banner.model.dart`)

### A16. 휴일 정보 화면

- [ ] `HolidayScreen` - 필리핀 공휴일 정보 (`v6/screens/info/holiday/holiday.screen.dart`)
  - 정규 공휴일, 특별 비근무일, 특별 근무일 3가지 분류
  - 행정기관 운영 정보, 급여/근무 안내
  - 한국인 대상 팁 (장기 연휴, Holy Week 성수기 등)

### A17. 관리자 전용 기능 (AppInfoScreen)

- [ ] v6 AppInfoScreen에서 `isAdmin`일 때 API 서버 정보 섹션 표시
  - API 엔드포인트, 환경 모드 등 관리자 전용 정보
  - v7 AppInfoScreen에서 이 기능 구현 여부 확인 필요

---

## B. 부분적으로 구현된 기능 (v7에 화면은 있지만 세부 기능 누락)

### B1. Entry/로그인 화면

v6의 `EntryScreen`은 로그인 전 시작 화면으로 다양한 기능 제공:
- [ ] 오늘의 환율(PHP→KRW) 실시간 표시
- [ ] 마닐라 현재 날씨 실시간 표시
- [ ] 회원 수/글 수 통계 표시
- [ ] 최근 공지사항 표시
- [ ] 로그인 없이 접근 가능한 퀵 메뉴 캐러셀 (필독, 여행명소, e트래블, 여행비자, 그랩택시, 월세 등)
- v7의 `UserLoginScreen`은 단순 로그인/회원가입 화면

### B2. 메뉴 화면 - 포인트 광고

- [ ] v6 메뉴에 '포인트 광고' 항목이 있었음 (WebView로 포인트 광고 페이지 연결)
- v7 메뉴의 광고 섹션에는 '배너 광고'만 있고 '포인트 광고' 항목이 없음

### B3. 채팅 전용 하단 네비게이션 바

v6에서는 채팅 탭 진입 시 하단 네비게이션 바가 변경됨:
- [ ] 채팅 전용 네비게이션: 홈 / 게시판 / 운영자채팅 / 1:1채팅 / 메뉴
- [ ] 운영자채팅 버튼 - 운영자와 1:1 채팅방 바로 입장
- v7에서는 채팅 탭에 일반 네비게이션 유지

### B4. 하단 네비게이션 바 - 읽지 않은 메시지 배지

- [ ] v6에서는 채팅 아이콘에 읽지 않은 메시지 수 Badge 표시 + 알림음 재생
- v7 하단 네비게이션 바에 Badge 표시 여부 확인 필요

### B5. 업소록 상세 화면 세부 기능

v6의 `CompanyViewScreen`에 있지만 v7에 없는 것:
- [ ] **방문 후기 섹션** - 사진 썸네일 가로 스크롤 포함 (v7에서 제거됨)
- [ ] 방문 후기 작성 버튼/링크
- [ ] 방문 포인트/재방문 포인트 시스템
- v7에 이미 있는 것: QR 코드 관리자 승인 기능

### B6. 업소록 등록/수정 폼 세부 차이

v7에도 4단계 멀티스텝 폼이 있으나 (기본정보, 연락처, 이미지, 검토), v6와 세부 차이:
- [ ] **위치 셀렉터**: v6의 CompanySelectLocation (모달로 위치 목록 선택) → v7에 있는지 확인
- [ ] **카카오톡 QR 자동 파싱**: v6의 ImageUploadField(isDecodeQr:true) → onQrCodeDecoded
  - QR 코드 사진 업로드 시 자동으로 카카오톡 ID 파싱
- [ ] **연락방법 선택**: v6에 문자/전화 RadioGroup (mobile_number_call_type: T/C)
- [ ] **사업면허/사무실 인테리어 이미지**: v6에는 5개 이미지(로고, 소개, 허가증, 카카오QR, 사무실) → v7에는 3개(로고, 타이틀이미지, 사진)만 있음
- [ ] **카카오톡 채널 URL**: v6에만 있는 필드

### B7. 게시글 뷰 화면 세부 기능

v7에 이미 있는 기능: 블라인드 처리(경고+사유), 만료 구인글 경고(90일), 댓글 트리구조, 좋아요/공유/신고/북마크, 포인트 광고

v6에만 있거나 v7에서 확인 필요한 것들:
- [ ] `post_blocked_user_info.dart` - 차단된 사용자 게시글 표시 (탭 시 차단 해제 옵션)
- [ ] **게시글 메타 정보**: 획득 포인트 뱃지 표시 (post.int_10/earnedPoint)
- [ ] **댓글 제약**: 댓글 1개 이상이면 수정/삭제 불가능 처리 (v7에서 구현 여부 확인)
- [ ] **onPostDeleted 콜백**: 글 삭제 시 목록 화면의 캐시에서 자동 제거

### B8. 사용자 프로필 관련

v6에는 있지만 v7에서 제거된 필드:
- [ ] **생년월일 필드** (birthDate) - v6 ProfileEditScreen에 있었으나 v7 UserEditScreen에서 제거
- [ ] **성별 필드** (gender M/F) - v6에 있었으나 v7에서 제거 (의도적 변경일 수 있음)

v6의 ProfileViewScreen에 있는 세부 기능:
- [ ] `profile_view.stat_item.dart` - 프로필 통계 아이템 위젯
- [ ] `latest.user.posts.dart` - 최근 사용자 게시글 (3~5개 표시, View All 버튼)

### B9. 포럼 헤더 기능

v6의 포럼 헤더 위젯들:
- [ ] `forum_header.notification_icon_button.dart` - 알림 아이콘 버튼
- [ ] `forum_header.notification_menu_item.dart` - 알림 메뉴 아이템
- [ ] `sub_category_list.dart` - 서브 카테고리 목록

---

## C. 초기화/시스템 레벨 기능

### C1. Shorebird 코드 푸시

- [ ] v6에는 Shorebird 코드 푸시가 구현됨 (30초 후 첫 체크, 180초 주기)
- [ ] 업데이트 다이얼로그 표시 + 앱 스토어 열기
- v7에서 Shorebird 코드 푸시 구현 여부 확인 필요

### C2. 최소 빌드 번호 확인

- [ ] v6에는 v7 API로 최소 빌드 번호 체크 기능이 있음 (`v6/functions/init/build_number_check.dart`)
- [ ] 앱 실행 5초 후 첫 체크, 이후 5분마다 주기적 체크
- [ ] 업그레이드 다이얼로그 (Comic 스타일) 표시
- v7에서 빌드 번호 체크 구현 여부 확인 필요

### C3. 딥링크 처리

v6 라우터에서 처리하는 딥링크:
- [ ] 게시글 딥링크 (`parsePhilgoUrl` - isPostView)
- [ ] 포럼 딥링크 (isPostList)
- [ ] 채팅방 딥링크 (isChatRoom)
- [ ] 업소록 딥링크 (query parameter `idx`)
- [ ] Firebase Analytics 화면 추적
- v7에서 딥링크 처리 범위 확인 필요

### C4. 로그인 없이 접근 가능한 공개 라우트

v6에서는 아래 화면들이 로그인 없이 접근 가능:
- [ ] ExchangeRateScreen, WeatherScreen, EmergencyContactScreen
- [ ] EssentialInfoScreen, MonthlyLivingScreen, TravelInfoScreen
- [ ] FoodDeliveryScreen, BaedalKScreen
- [ ] MustReadScreen, TravelSpotsScreen
- [ ] ETravelScreen, TravelVisaScreen, GrabTaxiScreen, MonthlyRentScreen
- v7에서 공개 라우트 설정 확인 필요

---

## D. UI/테마 관련 위젯

### D1. Comic 테마 위젯들

v6에 있는 Comic 디자인 위젯들:
- [ ] `comic_card.dart` - Comic 스타일 카드
- [ ] `comic_modal.dart` - Comic 스타일 모달
- [ ] `comic_fab.dart` - Comic 스타일 FAB
- [ ] `comic_snackbar.dart` - Comic 스타일 스낵바
- [ ] `comic_dialog.dart` - Comic 스타일 다이얼로그
- [ ] `comic_button.dart` - Comic 스타일 버튼
- [ ] `comic_text_form_field.dart` - Comic 스타일 텍스트 폼 필드
- v7에서 이 위젯들의 대체물 존재 여부 확인 필요

### D2. 기타 공통 위젯

- [ ] `information.box.dart` - 정보 박스 위젯
- [ ] `intro.header.dart` - 인트로 헤더 위젯
- [ ] `page.intro.header.dart` - 페이지 인트로 헤더
- [ ] `content_container.dart` - 컨텐츠 컨테이너 레이아웃
- [ ] `unfocus_on_tap.dart` - 터치 시 포커스 해제 위젯
- [ ] `step.progress.indicator.dart` - 단계 진행 인디케이터

### D3. 로고 위젯

- [ ] `PhilGoLogoTriangles` - 필고 로고 삼각형 애니메이션 (`v6/widgets/logo/philgo.logo.triangles.dart`)
- [ ] `PhilGoLogoTriangle` - 필고 로고 삼각형 단일 (`v6/widgets/logo/philgo.logo.triangle.dart`)
- [ ] `Logo` - 로고 위젯 (`v6/widgets/logo/logo.dart`)

### D4. 정책 다이얼로그

- [ ] `policy.dialogs.dart` - 이용약관/개인정보처리방침 다이얼로그 (`v6/widgets/dialogs/policy.dialogs.dart`)
  - v7에서는 WebView로 이용약관/개인정보처리방침 표시 (메뉴에 구현됨)

### B10. 홈 화면 헬퍼 메뉴 - onTap 미구현

v7의 `HomeHelperMenuSection` (`lib/home/widgets/home_helper_menu_section.dart`)에서
대부분의 메뉴 항목에 onTap이 구현되지 않아 터치해도 아무 반응 없음:
- [ ] '내 정보' - onTap 없음 (프로필 편집으로 이동해야 함)
- [ ] '필수정보' - onTap 없음 (EssentialInfoScreen 연결 필요)
- [ ] '공지사항' - onTap 없음 (NoticeScreen 연결 필요)
- [ ] '환율' - onTap 없음 (ExchangeRateScreen 연결 필요)
- [ ] '날씨' - onTap 없음 (WeatherScreen 연결 필요)
- [ ] '긴급연락처' - onTap 없음 (EmergencyContactScreen 연결 필요)
- [ ] '경찰서' - onTap 없음 (PoliceStationScreen 연결 필요)
- 연결된 것들: 대사관(외부URL), 한인회(외부URL), e트래블(외부URL), 업소이벤트(조건부), 이벤트응모(조건부)

### B11. 메뉴 화면 - 필리핀 생활 정보 onTap 미구현

v7의 `MenuScreen` (`lib/menu/menu.screen.dart`)의 `_buildInfoGrid()`에서
모든 필리핀 생활 정보 항목에 onTap이 없음 (11개 항목 전부):
- [ ] '필수 정보', '공지', '환율', '날씨', '긴급연락처', '초보 필독',
      '한달살기', '여행', '여행 명소', '음식 배달', '배달K'

### B12. 메뉴 화면 - 앱 사용 안내 onTap 미구현

- [ ] v7 메뉴의 '앱 사용 안내' 항목에 onTap 없음 (AppGuideScreen 연결 필요)

---

## E. 홈 화면 세부 기능 차이

v6의 홈 화면 위젯 중 v7에 없는 것:
- [ ] `home_photo_grid_section.dart` - 사진 게시판 그리드 표시
- [ ] `home_post_section_shimmer.dart` - 게시글 목록 로딩 시머 효과
- [ ] `home_quick_menu_section.dart` - 퀵 메뉴 캐러셀 (필리핀 생활 정보 바로가기)
- [ ] `carousel_dot_indicator.dart` - 캐러셀 도트 인디케이터

---

## F. v7 설정 관련

### F1. v7 설정 상태 관리 - 마이그레이션 완료

v7에 `SettingsState` + `SettingService`가 구현되어 있음:
- SettingsState: companyQrEventEnabled, eventEntryEnabled 등 토글 포함
- SettingService: 개발 모드 30초, 프로덕션 10분 갱신 주기
- ~~이 항목은 마이그레이션 완료~~ → 추가 확인 불필요

---

## 우선순위 제안

### 높은 우선순위 (사용자 경험에 직접 영향)
1. 계정 탈퇴 화면 구현 (A5) - 앱스토어 심사 필수 요구사항
2. 검색 기능 (A4) - 사용자가 콘텐츠를 찾는 핵심 기능
3. 딥링크 처리 (C3) - 외부 공유/알림에서 앱으로 진입하는 핵심 경로
4. 최소 빌드 번호 확인 (C2) - 앱 업데이트 강제 기능
5. QR 코드/방문 리뷰 (A6) - 업소록 핵심 비즈니스 기능
6. 구인/구직 전용 폼 (A10) - 구인구직 게시판 핵심 기능

### 중간 우선순위
7. 필리핀 생활 정보 화면들 (A1) - 대량이지만 정보성 콘텐츠
8. 가이드/필독 화면들 (A2) - 신규 사용자 온보딩
9. 날씨 기능 (A3) - 실시간 정보
10. 환율 서비스 (A11) - 실시간 정보
11. 사용자 활동 화면 (A7)
12. 채팅 전용 네비게이션 (B3)

### 낮은 우선순위
13. 퀵 포스트 화면 (A9) - UX 개선
14. 홈 화면 세부 기능 (E) - UI 개선
15. Comic 테마 위젯 (D1) - 디자인 일관성
16. 광고 관련 (A8)
17. Shorebird 코드 푸시 (C1)

---

## G. 의도적으로 변경된 기능 (마이그레이션 불필요)

아래 기능들은 v6에서 v7으로 의도적으로 변경/개선된 것이므로 "빠진 기능"이 아님:

- **로그인 방식**: v6 전화번호 로그인(easy_phone_sign_in) → v7 소셜 로그인(Google + 카카오)
- **로그인 화면**: v6 EntryScreen(환율/날씨 표시 포함) → v7 UserLoginScreen(소셜 로그인 전용)
- **상태관리**: v6 PhilgoState(philgo_api 패키지) → v7 UserState(자체 구현)
- **API 서비스**: v6 PhilgoService(philgo_api 패키지) → v7 UserService/PostService 등(v7 API 직접 호출)
- **다국어**: v6 flutter_localizations(자동 생성) → v7 easy_localization(한글 키 기반)
- **인증 흐름**: v6 로그인 필수(publicRoutes 외 redirect) → v7 로그인 선택(로그인 없이 대부분 접근 가능)
- **이용약관/개인정보처리방침**: v6 앱 내 다이얼로그 → v7 WebView로 표시

---

## 참고: v7에만 있는 기능 (v6에 없음)

- `BookmarkScreen` / 북마크 모듈 (lib/bookmark/) - v7에서 새로 추가
- `HomeTopBanners` / `HomeWingBanners` - v7에서 새로 추가된 배너 시스템
- `HomeDevModeBanner` - 개발 모드 API 상태 표시
- `SettingsState` / `SettingsModel` - v7 설정 상태 관리
- `YouTubeService` / `YouTubeModel` - 유튜브 서비스
- `AppFab` - 탭별 FAB 메뉴 시스템
- `PostCategoryBottomSheet` - 게시판 선택 바텀시트
- `FullScreenMediaViewer` - 전체 화면 미디어 뷰어
- `AppMasonryGrid` / `MasonryCard` - Masonry 레이아웃
- 카카오 로그인 (`kakao_signin.button.dart`)
- `PostListMasonryView` - Masonry 형태 게시글 목록
