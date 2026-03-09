import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 당일 이용 체크리스트 아이템 (Daily Usage Checklist Item)
///
/// 맛집을 당일 방문할 때 필요한 체크 항목을 담습니다.
/// Contains checklist items for visiting restaurants on the same day.
class _ChecklistItem {
  /// 항목 (Item)
  final String item;

  /// 핵심 (Key point)
  final String keyPoint;

  /// 메모 (Memo)
  final String memo;

  const _ChecklistItem({
    required this.item,
    required this.keyPoint,
    required this.memo,
  });
}

/// 인기 메뉴 아이템 (Popular Menu Item)
///
/// 필리핀 인기 메뉴 정보를 담습니다.
/// Contains information about popular Philippine dishes.
class _PopularMenu {
  /// 메뉴명 (Menu name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 주문 팁 (Order tip)
  final String orderTip;

  const _PopularMenu({
    required this.name,
    required this.description,
    required this.orderTip,
  });
}

/// 맛집 아이템 (Restaurant Item)
///
/// 개별 맛집 정보를 담습니다.
/// Contains individual restaurant information.
class _Restaurant {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 식당 이름 (Restaurant name)
  final String name;

  /// 구역 (District)
  final String district;

  /// 형태 (Type)
  final String type;

  /// 대표 메뉴 (Signature dish)
  final String signatureDish;

  /// 예약 필요 여부 (Reservation needed)
  final String reservation;

  /// 지도 검색어 (Map search keyword)
  final String mapSearch;

  const _Restaurant({
    required this.icon,
    required this.name,
    required this.district,
    required this.type,
    required this.signatureDish,
    required this.reservation,
    required this.mapSearch,
  });
}

/// 상황별 추천 아이템 (Situation-based Recommendation Item)
///
/// 상황별 맛집 추천 정보를 담습니다.
/// Contains restaurant recommendations based on situations.
class _SituationRecommend {
  /// 상황 (Situation)
  final String situation;

  /// 마닐라 추천 (Manila recommendation)
  final String manila;

  /// 세부 추천 (Cebu recommendation)
  final String cebu;

  /// 앙헬레스/클락 추천 (Angeles/Clark recommendation)
  final String angelesClark;

  const _SituationRecommend({
    required this.situation,
    required this.manila,
    required this.cebu,
    required this.angelesClark,
  });
}

/// 참고 URL 데이터 클래스 (Reference URL Data Class)
class _ReferenceUrl {
  /// 제목 (Title)
  final String title;

  /// URL
  final String url;

  const _ReferenceUrl({
    required this.title,
    required this.url,
  });
}

/// 맛집 정보 화면 (Restaurant Screen)
///
/// 필리핀 맛집 관련 정보를 제공합니다.
/// Provides information about restaurants in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// RestaurantScreen.push(context);
/// ```
class RestaurantScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Restaurant';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  /// 당일 이용 체크리스트 데이터 (Daily usage checklist data)
  static const List<_ChecklistItem> _checklistItems = [
    _ChecklistItem(
      item: '이동',
      keyPoint: 'Grab',
      memo: '주소+랜드마크 병기 권장',
    ),
    _ChecklistItem(
      item: '예약',
      keyPoint: 'Eatigo/공식 채널',
      memo: '예약형 매장 우선',
    ),
    _ChecklistItem(
      item: '대기',
      keyPoint: '오프피크',
      memo: '라멘·인기점은 대기 발생',
    ),
    _ChecklistItem(
      item: '배달',
      keyPoint: 'GrabFood/foodpanda',
      memo: '호텔·콘도 로비 수령 가능',
    ),
  ];

  /// 필리핀 인기 메뉴 데이터 (Popular Philippine dishes data)
  static const List<_PopularMenu> _popularMenus = [
    _PopularMenu(
      name: '시시그(Sisig)',
      description: '잘게 썬 돼지고기를 철판에 지글지글 제공하는 스타일로 널리 알려져 있다',
      orderTip: '"sizzling" 표기 확인',
    ),
    _PopularMenu(
      name: '파레스(Pares)',
      description: '소고기 스튜/국물류를 밥·면과 함께 먹는 조합으로 소개된다',
      orderTip: '"pares + rice/mami" 조합이 흔하다',
    ),
    _PopularMenu(
      name: '레촌(Lechon)',
      description: '통돼지 바비큐(껍질의 바삭함이 핵심으로 자주 언급)',
      orderTip: '조각 판매/포장 여부 확인',
    ),
    _PopularMenu(
      name: '수투킬(Sutukil)',
      description: '해산물을 구이·국·회/세비체 유사 방식으로 나눠 먹는 방식으로 알려져 있다',
      orderTip: '인원수에 맞춰 해산물 선택',
    ),
    _PopularMenu(
      name: '톡왓 바보이(Tokwa\'t Baboy)',
      description: '두부+돼지고기 조합의 안주/사이드로 널리 쓰인다',
      orderTip: '시시그와 함께 주문되는 경우가 많다',
    ),
    _PopularMenu(
      name: '실로그(Silog)',
      description: '밥(kanin)+계란+메인(토실로그 등) 조합',
      orderTip: '아침·브런치에 활용도가 높다',
    ),
  ];

  /// 마닐라 로컬/필리핀식 맛집 데이터 (Manila local/Filipino restaurants)
  static const List<_Restaurant> _manilaLocalRestaurants = [
    _Restaurant(
      icon: FontAwesomeIcons.lightFire,
      name: 'Manam',
      district: 'Makati 등',
      type: '캐주얼',
      signatureDish: 'House Crispy Sisig',
      reservation: '권장',
      mapSearch: 'Manam Comfort Filipino',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightEgg,
      name: 'Rodic\'s Diner',
      district: '여러 지점',
      type: '캐주얼',
      signatureDish: 'Tosilog(토실로그)',
      reservation: '불필요',
      mapSearch: 'Rodic\'s Diner',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBowlRice,
      name: 'Original Pares Mami House Retiro',
      district: 'QC',
      type: '캐주얼',
      signatureDish: 'Pares, Mami',
      reservation: '불필요',
      mapSearch: 'Pares Mami House Retiro',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightHandHoldingHeart,
      name: 'Gubat',
      district: 'QC',
      type: '캐주얼',
      signatureDish: '카마얀(kamayan) 스타일 식사',
      reservation: '권장',
      mapSearch: 'Gubat Quezon City',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightFireFlameCurved,
      name: 'Mang Larry\'s Isawan',
      district: 'QC',
      type: '캐주얼',
      signatureDish: 'Isaw(이사우), 꼬치구이',
      reservation: '불필요',
      mapSearch: 'Mang Larry\'s Isawan',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightGrill,
      name: 'Palm Grill',
      district: 'Makati',
      type: '캐주얼',
      signatureDish: 'Inihaw(그릴류)',
      reservation: '권장',
      mapSearch: 'Palm Grill Makati',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightDrumstick,
      name: 'JT\'s Manukan Grille',
      district: 'Makati 등',
      type: '캐주얼',
      signatureDish: '그릴 치킨',
      reservation: '권장',
      mapSearch: 'JT\'s Manukan',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightMugSaucer,
      name: 'Café Mary Grace',
      district: '여러 지점',
      type: '카페식',
      signatureDish: '케이크/파스타/브런치',
      reservation: '권장',
      mapSearch: 'Cafe Mary Grace',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBurrito,
      name: 'New Po Heng Lumpia House',
      district: 'Manila',
      type: '캐주얼',
      signatureDish: 'Lumpia(런피아)',
      reservation: '불필요',
      mapSearch: 'New Po Heng Lumpia',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBowlFood,
      name: 'Masuki Mami House',
      district: 'Manila',
      type: '캐주얼',
      signatureDish: 'Mami(국수) 계열',
      reservation: '불필요',
      mapSearch: 'Masuki Mami House',
    ),
  ];

  /// 마닐라 일식/피자/파인다이닝 맛집 데이터 (Manila Japanese/Pizza/Fine dining)
  static const List<_Restaurant> _manilaFineDiningRestaurants = [
    _Restaurant(
      icon: FontAwesomeIcons.lightBowlChopsticksNoodles,
      name: 'Mendokoro Ramenba',
      district: 'Makati',
      type: '라멘',
      signatureDish: '라멘/츠케멘 계열',
      reservation: '대기형',
      mapSearch: 'Mendokoro Ramenba',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightPizzaSlice,
      name: 'Crosta Pizzeria',
      district: 'Makati',
      type: '피자',
      signatureDish: '나폴리 스타일 피자',
      reservation: '권장',
      mapSearch: 'Crosta Pizzeria',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBowlChopsticks,
      name: 'Choi Garden',
      district: 'San Juan',
      type: '중식',
      signatureDish: '라우리앗/딤섬 스타일',
      reservation: '권장',
      mapSearch: 'Choi Garden',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightStar,
      name: 'Toyo Eatery',
      district: 'Makati',
      type: '코스',
      signatureDish: '테이스팅 코스(8코스 등)',
      reservation: '사실상 필수',
      mapSearch: 'Toyo Eatery',
    ),
  ];

  /// 세부 레촌/로컬 맛집 데이터 (Cebu lechon/local restaurants)
  static const List<_Restaurant> _cebuLocalRestaurants = [
    _Restaurant(
      icon: FontAwesomeIcons.lightPiggyBank,
      name: 'Ruthy\'s Lechon',
      district: 'Talisay',
      type: '로컬',
      signatureDish: 'Lechon(1945년부터 이어진 레시피)',
      reservation: '불필요',
      mapSearch: 'Ruthy\'s Lechon Talisay',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBurger,
      name: 'Bebie\'s Special Lechon',
      district: 'Carcar',
      type: '로컬',
      signatureDish: 'Lechon',
      reservation: '불필요',
      mapSearch: 'Bebie\'s Lechon Carcar',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightFish,
      name: 'Parr\'t Ebelle Tinola',
      district: 'Cebu City',
      type: '로컬',
      signatureDish: 'Sutukil(수투킬)',
      reservation: '권장',
      mapSearch: 'Parr\'t Ebelle Tinola',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBowlChopsticks,
      name: 'Majestic',
      district: 'Cebu City',
      type: '중식',
      signatureDish: '딤섬/가족식 중식',
      reservation: '권장',
      mapSearch: 'Majestic Cebu',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightDeer,
      name: 'Cyria\'s Kandingan',
      district: 'Consolacion',
      type: '로컬',
      signatureDish: 'Goat Kaldereta(염소 칼데레타)',
      reservation: '불필요',
      mapSearch: 'Cyria\'s Kandingan',
    ),
  ];

  /// 세부 컨템포러리/코스·바 맛집 데이터 (Cebu contemporary/course/bar)
  static const List<_Restaurant> _cebuFineDiningRestaurants = [
    _Restaurant(
      icon: FontAwesomeIcons.lightLeaf,
      name: 'Abli',
      district: 'Cebu City',
      type: '컨템포러리',
      signatureDish: 'Morta(디저트/스낵) 등 - MICHELIN Guide 추천',
      reservation: '권장',
      mapSearch: 'Abli Cebu',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightWineGlass,
      name: 'The Pig & Palm',
      district: 'Cebu City',
      type: '유럽식',
      signatureDish: '모던 유럽식 공유 메뉴',
      reservation: '권장',
      mapSearch: 'The Pig & Palm Cebu',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightPlateUtensils,
      name: 'Sialo',
      district: 'Cebu City',
      type: '코스',
      signatureDish: '다코스 테이스팅',
      reservation: '필수',
      mapSearch: 'Sialo Cebu',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      name: 'Enye by Chele Gonzalez',
      district: 'Mactan',
      type: '스페인식',
      signatureDish: '해산물·타파스 계열',
      reservation: '권장',
      mapSearch: 'Enye Mactan',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightMartiniGlass,
      name: 'Bell+Amadeus',
      district: 'Cebu City',
      type: '바/다이닝',
      signatureDish: '칵테일+푸드 페어링',
      reservation: '권장',
      mapSearch: 'Bell+Amadeus Cebu',
    ),
  ];

  /// 앙헬레스·클락 맛집 데이터 (Angeles/Clark restaurants)
  static const List<_Restaurant> _angelesClarkRestaurants = [
    _Restaurant(
      icon: FontAwesomeIcons.lightFire,
      name: 'Aling Lucing\'s',
      district: 'Angeles',
      type: '로컬',
      signatureDish: 'Sisig, Tokwa\'t Baboy - "시시그의 원조"로 유명',
      reservation: '불필요',
      mapSearch: 'Aling Lucing Sisig',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBacon,
      name: 'Mila\'s Tokwa\'t Baboy',
      district: 'Angeles',
      type: '로컬',
      signatureDish: 'Tokwa\'t Baboy, Sisig',
      reservation: '불필요',
      mapSearch: 'Mila\'s Tokwa\'t Baboy Angeles',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightCrown,
      name: 'Bale Dutung',
      district: 'Angeles',
      type: '프라이빗',
      signatureDish: '카팜팡안 다코스(예약제)',
      reservation: '필수',
      mapSearch: 'Bale Dutung',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightFlower,
      name: 'Café Fleur',
      district: 'Angeles',
      type: '컨템포러리',
      signatureDish: '카팜팡안/필리핀 요리 "트위스트"',
      reservation: '권장',
      mapSearch: 'Cafe Fleur Angeles',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightBugs,
      name: 'Matam-ih',
      district: 'Clark',
      type: '로컬',
      signatureDish: '카팜팡안 요리, Camaro(귀뚜라미) 등',
      reservation: '권장',
      mapSearch: 'Matam-ih Clark',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightHotel,
      name: 'Maranao Grill (Oasis Hotel)',
      district: 'Angeles',
      type: '호텔',
      signatureDish: '호텔 레스토랑(뷔페/알라카르트)',
      reservation: '권장',
      mapSearch: 'Maranao Grill Oasis Hotel',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightCheese,
      name: 'Swiss Chalet',
      district: 'Angeles',
      type: '유럽식',
      signatureDish: '유럽식+필리핀 메뉴',
      reservation: '권장',
      mapSearch: 'Swiss Chalet Angeles',
    ),
    _Restaurant(
      icon: FontAwesomeIcons.lightPizzaSlice,
      name: 'Amare by Chef Chris',
      district: 'Clark/Angeles',
      type: '이탈리안',
      signatureDish: '피자/파스타(호텔 내 운영)',
      reservation: '권장',
      mapSearch: 'Amare by Chef Chris',
    ),
  ];

  /// 상황별 추천 데이터 (Situation-based recommendations)
  static const List<_SituationRecommend> _situationRecommends = [
    _SituationRecommend(
      situation: '로컬 한 끼',
      manila: 'Manam / Pares Mami',
      cebu: 'Ruthy\'s Lechon / Sutukil',
      angelesClark: 'Aling Lucing\'s',
    ),
    _SituationRecommend(
      situation: '줄 서기 싫음',
      manila: 'Café Mary Grace',
      cebu: 'Majestic',
      angelesClark: 'Swiss Chalet',
    ),
    _SituationRecommend(
      situation: '"예약해서 확실히"',
      manila: 'Toyo Eatery',
      cebu: 'Sialo / The Pig & Palm',
      angelesClark: 'Bale Dutung',
    ),
    _SituationRecommend(
      situation: '이색 메뉴',
      manila: '현지 시장/카린데리아',
      cebu: '로컬 레촌·해산물',
      angelesClark: 'Matam-ih',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'Eatigo (예약/오프피크 할인)',
      url: 'https://eatigo.com/en/regions/24',
    ),
    _ReferenceUrl(
      title: 'Toyo Eatery 예약 (테이스팅)',
      url: 'https://www.exploretock.com/toyoeatery/experience/439892/indoor-dining-area-tasting-menu',
    ),
    _ReferenceUrl(
      title: 'Toyo Eatery (Asia\'s 50 Best 2025)',
      url: 'https://www.theworlds50best.com/asia/en/the-list/Toyo-Eatery.html',
    ),
    _ReferenceUrl(
      title: '마닐라 맛집 가이드 (Infatuation)',
      url: 'https://www.theinfatuation.com/manila/guides/best-restaurants-manila',
    ),
    _ReferenceUrl(
      title: '세부 맛집 가이드 (Infatuation)',
      url: 'https://www.theinfatuation.com/cebu/guides/best-restaurants-cebu',
    ),
    _ReferenceUrl(
      title: 'Abli (MICHELIN Guide)',
      url: 'https://guide.michelin.com/ph/en/central-visayas/cebu-city_2340421/restaurant/abli',
    ),
    _ReferenceUrl(
      title: 'The Pig & Palm (공식)',
      url: 'https://thepigandpalm.ph/',
    ),
    _ReferenceUrl(
      title: 'Aling Lucing (공식)',
      url: 'https://alinglucing.shop/',
    ),
    _ReferenceUrl(
      title: 'Café Fleur 소개',
      url: 'https://primer.com.ph/food/location/philippines/pampanga/cafe-fleur-in-pampanga-serves-filipino-dishes-with-a-twist/',
    ),
    _ReferenceUrl(
      title: 'Matam-ih (공식)',
      url: 'https://matamih.shop/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightUtensils,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentRestaurant,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [헤더 배너]
            _buildHeaderBanner(context),
            SizedBox(height: sp.s24),

            /// [1. 식당 찾아가는 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleCheck,
              title: '식당 찾아가는 방법',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildQuickAccessGuide(context),
            SizedBox(height: sp.s12),
            _buildChecklistTable(context),
            SizedBox(height: sp.s24),

            /// [2. 필리핀 인기 메뉴]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightUtensils,
              title: '필리핀 인기 메뉴 (주문에 자주 쓰는 이름)',
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildPopularMenuSection(context),
            SizedBox(height: sp.s24),

            /// [3. 마닐라 맛집 - 로컬/필리핀식]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCity,
              title: '마닐라 맛집 - 로컬/필리핀식',
              emoji: '🏙️',
            ),
            SizedBox(height: sp.s8),
            _buildSectionSubtitle(context, 'A-1) 실용 동선 중심 10선'),
            SizedBox(height: sp.s12),
            _buildRestaurantList(context, _manilaLocalRestaurants, Colors.orange),
            SizedBox(height: sp.s24),

            /// [4. 마닐라 맛집 - 일식/피자/파인다이닝]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightStar,
              title: '마닐라 맛집 - 일식/피자/파인다이닝',
              emoji: '⭐',
            ),
            SizedBox(height: sp.s8),
            _buildSectionSubtitle(context, 'A-2) 예약·대기 포인트'),
            SizedBox(height: sp.s12),
            _buildRestaurantList(context, _manilaFineDiningRestaurants, Colors.amber),
            SizedBox(height: sp.s24),

            /// [5. 세부 맛집 - 레촌/로컬]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTreePalm,
              title: '세부 맛집 - 레촌/로컬 중심',
              emoji: '🌴',
            ),
            SizedBox(height: sp.s8),
            _buildSectionSubtitle(context, 'B-1) 레촌 성지와 로컬 맛집 5선'),
            SizedBox(height: sp.s12),
            _buildRestaurantList(context, _cebuLocalRestaurants, Colors.green),
            SizedBox(height: sp.s24),

            /// [6. 세부 맛집 - 컨템포러리/코스·바]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWineGlass,
              title: '세부 맛집 - 컨템포러리/코스·바',
              emoji: '🍷',
            ),
            SizedBox(height: sp.s8),
            _buildSectionSubtitle(context, 'B-2) 분위기 있는 식사 5선'),
            SizedBox(height: sp.s12),
            _buildRestaurantList(context, _cebuFineDiningRestaurants, Colors.purple),
            SizedBox(height: sp.s24),

            /// [7. 앙헬레스·클락 맛집]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightPepperHot,
              title: '앙헬레스·클락(팜팡가) 맛집 8선',
              emoji: '🌶️',
            ),
            SizedBox(height: sp.s8),
            _buildSectionSubtitle(context, '시시그(Sisig) 원조 지역 - 카팜팡안(Kapampangan) 음식권'),
            SizedBox(height: sp.s12),
            _buildRestaurantList(context, _angelesClarkRestaurants, Colors.red),
            SizedBox(height: sp.s24),

            /// [8. 상황별 최단 선택]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCompass,
              title: '한국인이 실제로 "쉽게" 이용하는 요약',
              emoji: '🧭',
            ),
            SizedBox(height: sp.s12),
            _buildSituationRecommendTable(context),
            SizedBox(height: sp.s24),

            /// [9. 지도 검색 팁]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMapLocationDot,
              title: '지도에서 실패 확률 낮추는 검색 팁',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildMapSearchTips(context),
            SizedBox(height: sp.s24),

            /// [10. 참고 URL]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '참고 URL (모음)',
              emoji: '🔗',
            ),
            SizedBox(height: sp.s12),
            _buildReferenceUrls(context),
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 헤더 배너 빌드 (Header banner build)
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🇵🇭🍽️',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 맛집 정보',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '마닐라 15곳 / 세부 10곳 / 앙헬레스·클락 8곳을 중심으로, '
            '필리핀 현지에서 "당일 1회 방문"으로 이용하기 쉬운 방식으로 정리했습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 14,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '영업시간·휴무·메뉴·예약 정책은 변동 가능하므로 방문 직전 '
                    'Google Maps/공식 채널에서 최신 정보를 확인하세요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Section header build)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? emoji,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Text(
            emoji != null ? '$emoji $title' : title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 섹션 부제목 빌드 (Section subtitle build)
  Widget _buildSectionSubtitle(BuildContext context, String subtitle) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(left: sp.s4),
      child: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 빠른 접근 가이드 빌드 (Quick access guide build)
  Widget _buildQuickAccessGuide(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStep(
            context,
            icon: FontAwesomeIcons.lightMagnifyingGlass,
            title: '찾기 (1분)',
            content: 'Google Maps → 식당명 검색 → "영업중/혼잡/리뷰/사진" 확인',
          ),
          SizedBox(height: sp.s8),
          _buildQuickStep(
            context,
            icon: FontAwesomeIcons.lightCar,
            title: '이동 (10-40분)',
            content: 'Grab 차량 호출(픽업·도착지 명확)',
          ),
          SizedBox(height: sp.s8),
          _buildQuickStep(
            context,
            icon: FontAwesomeIcons.lightCalendarCheck,
            title: '예약/대기 (0-60분)',
            content: '예약형: Eatigo(즉시 예약/오프피크 할인) 또는 매장 공식 채널\n'
                '대기형: 오픈 직후/오프피크(점심 11시대, 저녁 17시대) 선택',
          ),
          SizedBox(height: sp.s8),
          _buildQuickStep(
            context,
            icon: FontAwesomeIcons.lightBagShopping,
            title: '대체 (0분)',
            content: '좌석 부족 시 GrabFood·foodpanda로 동일 메뉴 배달 주문',
          ),
        ],
      ),
    );
  }

  /// 빠른 단계 빌드 (Quick step build)
  Widget _buildQuickStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: Colors.white),
          ),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: sp.s4),
              Text(
                content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 체크리스트 테이블 빌드 (Checklist table build)
  Widget _buildChecklistTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '항목',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '핵심',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '메모',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ...List.generate(_checklistItems.length, (index) {
            final item = _checklistItems[index];
            final isLast = index == _checklistItems.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.item,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.keyPoint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.memo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 인기 메뉴 섹션 빌드 (Popular menu section build)
  Widget _buildPopularMenuSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _popularMenus.map((menu) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 메뉴 아이콘 (Menu icon)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightBowlFood,
                    size: 18,
                    color: Colors.orange,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      menu.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightLightbulb,
                            size: 12,
                            color: Colors.orange.shade700,
                          ),
                          SizedBox(width: sp.s4),
                          Flexible(
                            child: Text(
                              menu.orderTip,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 맛집 리스트 빌드 (Restaurant list build)
  Widget _buildRestaurantList(
    BuildContext context,
    List<_Restaurant> restaurants,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: restaurants.asMap().entries.map((entry) {
        final index = entry.key;
        final restaurant = entry.value;

        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 번호 및 아이콘 (Number and icon)
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sp.s8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: FaIcon(
                        restaurant.icon,
                        size: 16,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 정보 (Information)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 이름 및 구역 (Name and district)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            restaurant.district,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s8),

                    /// 형태 및 대표 메뉴 (Type and signature dish)
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            restaurant.type,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(width: sp.s8),
                        Expanded(
                          child: Text(
                            restaurant.signatureDish,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s8),

                    /// 예약 및 검색어 (Reservation and search keyword)
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightCalendarCheck,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: sp.s4),
                        Text(
                          '예약: ${restaurant.reservation}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: sp.s12),
                        Expanded(
                          child: Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightMagnifyingGlass,
                                size: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                              SizedBox(width: sp.s4),
                              Flexible(
                                child: Text(
                                  restaurant.mapSearch,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: scheme.outline,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 상황별 추천 테이블 빌드 (Situation recommendation table build)
  Widget _buildSituationRecommendTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '상황',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '마닐라',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '세부',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '앙헬레스',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ...List.generate(_situationRecommends.length, (index) {
            final item = _situationRecommends[index];
            final isLast = index == _situationRecommends.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.situation,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.manila,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.cebu,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.angelesClark,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 지도 검색 팁 빌드 (Map search tips build)
  Widget _buildMapSearchTips(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipItem(
            context,
            icon: FontAwesomeIcons.lightMagnifyingGlassLocation,
            title: '식당명 + 도시명 조합으로 검색',
            content: '예: "Abli Cebu", "Aling Lucing Angeles"',
          ),
          SizedBox(height: sp.s12),
          _buildTipItem(
            context,
            icon: FontAwesomeIcons.lightLocationCrosshairs,
            title: '복수 지점 체인(마닐라)',
            content: '"가장 가까운 지점"을 자동 추천하므로, 목적지(호텔/거주지) 기준으로 선택',
          ),
          SizedBox(height: sp.s12),
          _buildTipItem(
            context,
            icon: FontAwesomeIcons.lightCalendarPlus,
            title: '예약형 매장',
            content: '"Reserve/Book" 링크 유무를 먼저 확인 (예: Toyo Eatery는 예약 플랫폼에서 코스 안내 제공)',
          ),
        ],
      ),
    );
  }

  /// 팁 아이템 빌드 (Tip item build)
  Widget _buildTipItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: Colors.white),
          ),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: sp.s4),
              Text(
                content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 참고 URL 빌드 (Reference URLs build)
  Widget _buildReferenceUrls(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _referenceUrls.map((ref) {
          return InkWell(
            onTap: () => _launchUrl(ref.url),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: sp.s8),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightArrowUpRightFromSquare,
                    size: 14,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      ref.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// URL 실행 함수 (Launch URL function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
