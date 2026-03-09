import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 정보 아이템 데이터 클래스 (Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _InfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 테이블 행 데이터 클래스 (Table Row Data Class)
///
/// 테이블 형태의 정보 표시에 사용됩니다.
/// Used for displaying tabular information.
class _TableRow {
  /// 열 데이터 목록 (Column data list)
  final List<String> columns;

  /// 헤더 여부 (Is header row)
  final bool isHeader;

  const _TableRow({
    required this.columns,
    this.isHeader = false,
  });
}

/// 해변 정보 데이터 클래스 (Beach Info Data Class)
class _BeachInfo {
  /// 해변 이름 (Beach name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  const _BeachInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
  });
}

/// 액티비티 정보 데이터 클래스 (Activity Info Data Class)
class _ActivityInfo {
  /// 액티비티 이름 (Activity name)
  final String name;

  /// 장소 (Location)
  final String location;

  /// 비고 (Note)
  final String note;

  /// 아이콘 (Icon)
  final IconData icon;

  const _ActivityInfo({
    required this.name,
    required this.location,
    required this.note,
    required this.icon,
  });
}

/// 음식점/맛집 정보 데이터 클래스 (Restaurant Info Data Class)
///
/// 보라카이 섬 내 추천 음식점 및 먹거리 정보를 담습니다.
/// Contains recommended restaurant and food information in Boracay.
class _RestaurantInfo {
  /// 음식점/음식 이름 (Restaurant/Food name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 설명 (Description)
  final String description;

  /// 가격 정보 (Price info)
  final String? price;

  /// 아이콘 (Icon)
  final IconData icon;

  const _RestaurantInfo({
    required this.name,
    required this.location,
    required this.description,
    this.price,
    required this.icon,
  });
}

/// 스파/마사지 정보 데이터 클래스 (Spa Info Data Class)
///
/// 보라카이 섬 내 스파 및 마사지 시설 정보를 담습니다.
/// Contains spa and massage facility information in Boracay.
class _SpaInfo {
  /// 스파 이름 (Spa name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 설명 (Description)
  final String description;

  /// 가격대 (Price range)
  final String priceRange;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  const _SpaInfo({
    required this.name,
    required this.location,
    required this.description,
    required this.priceRange,
    required this.features,
    required this.icon,
  });
}

/// 응급/안전 연락처 데이터 클래스 (Emergency Contact Data Class)
///
/// 보라카이 섬 내 응급 연락처 및 안전 관련 정보를 담습니다.
/// Contains emergency contact and safety information in Boracay.
class _EmergencyContact {
  /// 기관명 (Organization name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 전화번호 (Phone number)
  final String phone;

  /// 운영시간/비고 (Operating hours/Note)
  final String note;

  /// 아이콘 (Icon)
  final IconData icon;

  const _EmergencyContact({
    required this.name,
    required this.location,
    required this.phone,
    required this.note,
    required this.icon,
  });
}

/// 월별 날씨 정보 데이터 클래스 (Monthly Weather Data Class)
///
/// 보라카이의 월별 기후 정보를 담습니다.
/// Contains monthly climate information for Boracay.
class _MonthlyWeather {
  /// 월 (Month)
  final String month;

  /// 기온 범위 (Temperature range)
  final String temperature;

  /// 강수량 (Precipitation)
  final String rainfall;

  /// 특징 (Characteristics)
  final String characteristics;

  /// 계절 구분 (Season type: dry/wet)
  final bool isDrySeason;

  const _MonthlyWeather({
    required this.month,
    required this.temperature,
    required this.rainfall,
    required this.characteristics,
    required this.isDrySeason,
  });
}

/// 편의시설 정보 데이터 클래스 (Facility Info Data Class)
///
/// 보라카이 섬 내 편의시설 정보를 담습니다.
/// Contains facility information in Boracay.
class _FacilityInfo {
  /// 시설 종류 (Facility type)
  final String type;

  /// 이름/위치 (Name/Location)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 팁/비고 (Tips/Note)
  final String? tip;

  /// 아이콘 (Icon)
  final IconData icon;

  const _FacilityInfo({
    required this.type,
    required this.name,
    required this.description,
    this.tip,
    required this.icon,
  });
}

/// 보라카이 여행 정보 화면 (Boracay Travel Screen)
///
/// 필리핀 보라카이 여행 정보를 제공합니다.
/// Provides travel information about Boracay in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// BoracayScreen.push(context);
/// ```
class BoracayScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Boracay';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const BoracayScreen({super.key});

  @override
  State<BoracayScreen> createState() => _BoracayScreenState();
}

class _BoracayScreenState extends State<BoracayScreen> {
  /// 보라카이 개요 정보 (Boracay Overview Info)
  static const List<_InfoItem> _overviewInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치',
      description:
          '필리핀 중부 비사야(Visayas) 지역 아클란(Aklan) 주에 위치한 소형 섬 휴양지입니다. 행정적으로는 파나이(Panay) 섬에 속합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRulerCombined,
      title: '규모',
      description: '섬 길이 약 7km, 폭 약 1km 내외의 작은 섬이지만, 해변·리조트·액티비티·상업시설이 밀집된 국제적 관광지입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPlaneArrival,
      title: '접근성',
      description: '외국인 관광객 접근성이 높으며, 한국에서 직항 및 경유 항공편으로 쉽게 방문할 수 있습니다.',
    ),
  ];

  /// 항공 이동 경로 테이블 (Flight Route Table)
  static const List<_TableRow> _flightRouteTable = [
    _TableRow(columns: ['구분', '내용'], isHeader: true),
    _TableRow(columns: ['출발', '인천(ICN) / 부산(PUS)']),
    _TableRow(columns: ['도착 공항', '칼리보(KLO) 또는 카티클란(MPH)']),
    _TableRow(columns: ['소요', '약 4시간 30분~5시간']),
    _TableRow(columns: ['항공', '대한항공, 아시아나, 세부퍼시픽, 에어아시아 등']),
  ];

  /// 공항에서 보라카이 이동 테이블 (Airport to Boracay Table)
  static const List<_TableRow> _airportTransferTable = [
    _TableRow(columns: ['경로', '이동수단', '시간'], isHeader: true),
    _TableRow(columns: ['카티클란 공항 → 항구', '밴', '5~10분']),
    _TableRow(columns: ['카티클란 항구 → 보라카이', '보트', '10~15분']),
    _TableRow(columns: ['칼리보 공항 → 항구', '버스/밴', '약 1시간 30분']),
    _TableRow(columns: ['항구 → 보라카이', '보트', '10~15분']),
  ];

  /// 해변 정보 (Beach Info)
  static const List<_BeachInfo> _beachInfo = [
    _BeachInfo(
      name: '화이트 비치 (White Beach)',
      description: '보라카이의 대표 해변으로 섬 서쪽에 위치합니다. 총 4km 길이로 스테이션 1~3으로 구분됩니다.',
      features: [
        'Station 1: 고급 리조트, 백사장 넓음',
        'Station 2: 상업 중심, 식당·쇼핑 밀집',
        'Station 3: 비교적 한적, 숙소 밀집',
      ],
      icon: FontAwesomeIcons.lightUmbrellaBeach,
    ),
    _BeachInfo(
      name: '푸카 쉘 비치 (Puka Shell Beach)',
      description: '북쪽에 위치한 자연 해변으로 조개껍질이 많습니다. 상업 시설이 거의 없으며 조용한 환경입니다.',
      features: [
        '위치: 보라카이 북부',
        '이동: 트라이시클 15~20분',
        '특징: 자연 그대로의 해변',
      ],
      icon: FontAwesomeIcons.lightWater,
    ),
    _BeachInfo(
      name: '불라복 비치 (Bulabog Beach)',
      description: '동쪽 해변으로 바람이 강해 카이트서핑과 윈드서핑이 활발합니다.',
      features: [
        '위치: 보라카이 동쪽',
        '특징: 수상 스포츠 명소',
        '시즌: 11월~4월 (건기)',
      ],
      icon: FontAwesomeIcons.lightWind,
    ),
  ];

  /// 역사·문화 정보 (Culture Info)
  static const List<_InfoItem> _cultureInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightChurch,
      title: '홀리 로사리 교회 (Our Lady of the Most Holy Rosary Church)',
      description: 'Station 1에 위치한 가톨릭 교회입니다. 자유롭게 방문할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '아티족(Ati) 원주민 문화',
      description: '아티족은 보라카이 원주민으로, 특정 문화 행사나 축제를 통해 전통 문화를 접할 수 있습니다.',
    ),
  ];

  /// 쇼핑·도심 정보 (Shopping Info)
  static const List<_InfoItem> _shoppingInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBagShopping,
      title: '디몰 (D\'Mall)',
      description:
          '보라카이 최대 상업 지구입니다. Station 2에 위치하며 레스토랑, 카페, 기념품 상점이 밀집되어 있습니다. 상시 운영됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFish,
      title: '디탈리파파 시장 (D\'Talipapa)',
      description: '현지 수산물 시장으로 해산물을 구매한 후 인근 식당에서 조리해서 먹을 수 있습니다.',
    ),
  ];

  /// 가족·어린이 정보 (Family Info)
  static const List<_InfoItem> _familyInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightFerrisWheel,
      title: '보라카이 펀 파크',
      description: '소규모 놀이시설과 액티비티 공간으로 가족 단위 방문이 가능합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightChildren,
      title: '리조트 내 키즈 클럽',
      description: '대형 리조트(샹그릴라, 페어웨이, 헤난 계열 등)는 키즈 프로그램을 운영합니다.',
    ),
  ];

  /// 액티비티 정보 (Activity Info)
  static const List<_ActivityInfo> _activityInfo = [
    _ActivityInfo(
      name: '아일랜드 호핑',
      location: '인근 섬',
      note: '반일/1일 투어',
      icon: FontAwesomeIcons.lightShip,
    ),
    _ActivityInfo(
      name: '스노클링',
      location: '푸카, 크리스탈 코브',
      note: '장비 대여 가능',
      icon: FontAwesomeIcons.lightMaskSnorkel,
    ),
    _ActivityInfo(
      name: '패러세일링',
      location: '화이트 비치',
      note: '기상 영향 있음',
      icon: FontAwesomeIcons.lightCloudArrowUp,
    ),
    _ActivityInfo(
      name: '헬멧 다이빙',
      location: '화이트 비치',
      note: '초보자 가능',
      icon: FontAwesomeIcons.lightMaskSnorkel,
    ),
    _ActivityInfo(
      name: '선셋 세일링',
      location: '화이트 비치',
      note: '일몰 시간대',
      icon: FontAwesomeIcons.lightSailboat,
    ),
    _ActivityInfo(
      name: '스쿠버 다이빙',
      location: '불라복',
      note: '라이선스 코스',
      icon: FontAwesomeIcons.lightWaterLadder,
    ),
  ];

  /// 섬 내부 교통 정보 (Island Transport Info)
  static const List<_InfoItem> _transportInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMotorcycle,
      title: '트라이시클',
      description: '오토바이를 개조한 가장 일반적인 교통수단입니다. 구간별로 요금이 상이합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBolt,
      title: '전동 지프니 (E-Trike)',
      description: '친환경 교통수단으로 일부 노선에서 운영됩니다.',
    ),
  ];

  /// 이동 시간 테이블 (Travel Time Table)
  static const List<_TableRow> _travelTimeTable = [
    _TableRow(columns: ['구간', '거리', '시간'], isHeader: true),
    _TableRow(columns: ['Station 1 → Station 3', '약 3km', '10~15분']),
    _TableRow(columns: ['Station 2 → 푸카 비치', '약 4km', '15~20분']),
    _TableRow(columns: ['Station 2 → 불라복 비치', '약 1km', '5~10분']),
  ];

  /// 참고 사항 (Notes)
  static const List<_InfoItem> _notesInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '입도 제한',
      description: '환경 보호 정책으로 숙소 예약 확인서 없이는 입도 제한이 있습니다. 반드시 숙소 예약 후 방문하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBanSmoking,
      title: '흡연/음주 구역',
      description: '흡연 구역과 음주 제한 구역이 명확히 구분되어 있습니다. 지정 구역 외 흡연 시 벌금이 부과됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightDrone,
      title: '드론 촬영',
      description: '드론 촬영은 사전 허가가 필요합니다. 무허가 촬영 시 장비 압수 및 벌금이 부과될 수 있습니다.',
    ),
  ];

  /// ========================================
  /// 🥘 섬 내 먹거리 정보 (Food Information)
  /// ========================================

  /// 대표 길거리 음식 정보 (Street Food Info)
  static const List<_RestaurantInfo> _streetFoodInfo = [
    _RestaurantInfo(
      name: '초리 버거 (Chori Burger)',
      location: '화이트 비치 노점 (Merly\'s BBQ 등)',
      description:
          '보라카이 대표 길거리 음식. 현지 달콤한 초리소 소시지를 구워 번에 끼워 먹는 간식으로, 현지인과 관광객 모두에게 인기입니다.',
      price: '₱50~100',
      icon: FontAwesomeIcons.lightBurger,
    ),
    _RestaurantInfo(
      name: '칼라만시 머핀',
      location: 'Real Coffee & Tea Cafe (Station 2)',
      description:
          '보라카이 명물 디저트. 1996년 문을 연 리얼 커피가 원조로, 칼라만시 열매로 만든 상큼달콤한 머핀입니다. 여행 선물용으로도 인기가 높습니다.',
      price: '₱80~120',
      icon: FontAwesomeIcons.lightCookie,
    ),
    _RestaurantInfo(
      name: '조나스 과일 쉐이크 (Jonah\'s Fruit Shake)',
      location: 'Station 1 등 해변가',
      description:
          '보라카이에서 가장 유명한 과일 음료. 신선한 망고 등 열대과일로 만든 시원한 쉐이크로, 무더운 날씨에 필수템입니다.',
      price: '₱100~150',
      icon: FontAwesomeIcons.lightBlenderPhone,
    ),
  ];

  /// 해산물 시장 및 식당 정보 (Seafood Market Info)
  static const List<_InfoItem> _seafoodInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightFish,
      title: 'D\'Talipapa 해산물 시장',
      description:
          'Station 2 남쪽에 위치한 재래시장. 활어, 새우, 게 등을 직접 고른 후 인근 식당에서 요리비(500g당 약 ₱150)를 내고 원하는 방식(그릴, 망고소스 볶음 등)으로 조리해 먹을 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUtensils,
      title: 'Plato D\'Boracay',
      description:
          'D\'Talipapa 내 오픈형 레스토랑. 단체 여행객에게 적합하며, 시장에서 구매한 해산물 조리 전문입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMugHot,
      title: 'Blue Jade Cafe',
      description:
          '아담하고 아늑한 분위기의 해산물 레스토랑. 현지 특제 소스와 함께 신선한 해산물 요리를 맛볼 수 있습니다.',
    ),
  ];

  /// 추천 맛집 정보 (Recommended Restaurants)
  static const List<_RestaurantInfo> _recommendedRestaurants = [
    _RestaurantInfo(
      name: '레모니 카페 (Lemoni Cafe)',
      location: 'D\'Mall 초입',
      description: '조식과 수제 케이크로 유명한 카페. 오전 7시~오후 10시 운영.',
      icon: FontAwesomeIcons.lightMugSaucer,
    ),
    _RestaurantInfo(
      name: '싸이마 (Cyma)',
      location: 'D\'Mall 내',
      description: '그리스식 꼬치구이와 불쇼 치즈(사가나키)로 이색적인 즐거움을 주는 레스토랑.',
      icon: FontAwesomeIcons.lightFireFlameCurved,
    ),
    _RestaurantInfo(
      name: '올레 (Ole)',
      location: 'D\'Mall 인근',
      description: '새벽 2시까지 영업하는 스페인 식당. 야식이나 늦은 저녁에 타파스를 즐기기 좋습니다.',
      icon: FontAwesomeIcons.lightWineGlass,
    ),
    _RestaurantInfo(
      name: '망 이나살 (Mang Inasal)',
      location: 'Station 2',
      description: '필리핀식 그릴 치킨 패스트푸드. 저렴하고 간편한 한 끼 식사에 적합합니다.',
      icon: FontAwesomeIcons.lightDrumstickBite,
    ),
    _RestaurantInfo(
      name: 'I Love Backyard BBQ',
      location: 'D\'Mall 내',
      description: '필리핀식 바비큐 전문점. 돼지고기 바비큐가 특히 인기입니다.',
      icon: FontAwesomeIcons.lightGrill,
    ),
    _RestaurantInfo(
      name: 'Los Indios Bravos',
      location: 'Station 1 (화이트하우스 리조트 내)',
      description: '수제 맥주와 유러피언 펍푸드를 즐길 수 있는 가스트로펍.',
      icon: FontAwesomeIcons.lightBeerMugEmpty,
    ),
  ];

  /// 디저트 및 카페 정보 (Dessert & Cafe Info)
  static const List<_InfoItem> _dessertInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightIceCream,
      title: '코코마마 (Coco Mama)',
      description:
          '신선한 코코넛 속에 비건 아이스크림과 다양한 토핑을 담아 제공. 건강하고 달콤한 디저트로 인기가 높습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMugSaucer,
      title: '스타벅스 & 현지 카페',
      description: '해변가 곳곳에 스타벅스와 현지 카페들이 있어 휴식을 취하기 좋습니다.',
    ),
  ];

  /// 야시장 정보 (Night Market Info)
  static const List<_InfoItem> _nightMarketInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMoon,
      title: 'D\'Mall 야시장 분위기',
      description:
          '보라카이에는 상설 대형 야시장은 없지만, 디몰 일대가 밤에는 야시장 분위기로 변모합니다. 노점상들이 필리핀 길거리 음식과 기념품을 판매합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarStar,
      title: '팝업 야시장 & 푸드 페스티벌',
      description:
          '성수기나 축제 기간에는 디몰 광장 앞에서 지역 상인들이 참여하는 팝업 야시장이나 푸드 페스티벌이 열립니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSeedling,
      title: '환경보호 정책',
      description:
          '보라카이는 환경보호 정책으로 거리 음식 노점을 엄격히 관리합니다. 공식 푸드마켓 행사 위주로 참여하는 것이 권장됩니다.',
    ),
  ];

  /// ========================================
  /// 💆 스파 · 마사지 · 힐링 정보 (Spa & Massage)
  /// ========================================

  /// 일반 마사지 정보 (General Massage Info)
  static const List<_InfoItem> _generalMassageInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHandsHoldingHeart,
      title: '해변 마사지',
      description:
          '화이트비치 해변 산책로를 따라 파라솔 아래에서 마사지를 받을 수 있습니다. 일몰 후 간이침대에서 받는 비치 마사지는 색다른 경험을 선사합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '가격 안내',
      description:
          '일반 마사지숍 1시간 전신 마사지 ₱500~600선. 일부 업소는 ₱399 프로모션도 있습니다. 워크인 이용 가능하며 팁은 ₱50~100 정도가 적당합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSpa,
      title: '힐롯 마사지',
      description:
          '필리핀 전통 힐롯(Hilot) 마사지나 스웨디시 마사지 등을 제공합니다. 번화가의 평판 좋은 곳을 이용하는 것이 좋습니다.',
    ),
  ];

  /// 럭셔리 스파 정보 (Luxury Spa Info)
  static const List<_SpaInfo> _luxurySpaInfo = [
    _SpaInfo(
      name: '만달라 스파 & 리조트 (Mandala Spa)',
      location: 'Station 3 언덕',
      description:
          '국제적인 명성의 럭셔리 스파. 야자수 정원 속 개별 빌라에서 오픈에어 발리니즈 스타일 트리트먼트를 받을 수 있습니다.',
      priceRange: '1시간 ₱3,000+',
      features: [
        '국제 어워드 다수 수상',
        '자연 속 프라이빗 빌라',
        '24시간 디톡스·힐링 패키지',
        '예약 필수',
      ],
      icon: FontAwesomeIcons.lightSpa,
    ),
    _SpaInfo(
      name: '티르타 스파 (Tirta Spa)',
      location: 'Manoc-Manoc 지역 (섬 동남쪽 고지대)',
      description:
          '손꼽히는 고급 스파. 전용 빌라에서 커플 마사지, 플라워 배스 등의 패키지를 즐길 수 있습니다.',
      priceRange: '패키지 ₱10,000~₱25,000',
      features: [
        '화려한 정원과 독립 빌라',
        '커플 전용 프로그램',
        '최고급 프라이빗 웰니스',
      ],
      icon: FontAwesomeIcons.lightGem,
    ),
    _SpaInfo(
      name: '벨라 이사 스파 (Bella Isa Spa)',
      location: 'Station 3 해변',
      description:
          '깔끔한 커플 전문 스파. "킹앤퀸 패키지" (4시간 풀코스: 마사지+얼굴관리+선셋 세일링+로맨틱 디너)가 인기입니다.',
      priceRange: '1인 ₱1,500~, 커플패키지 약 \$350',
      features: [
        '한국인에게 인기',
        '킹앤퀸 4시간 풀코스 패키지',
        '선셋 세일링 포함 옵션',
      ],
      icon: FontAwesomeIcons.lightHeart,
    ),
  ];

  /// 호텔 스파 정보 (Hotel Spa Info)
  static const List<_InfoItem> _hotelSpaInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHotel,
      title: '샹그릴라 CHI Spa',
      description:
          '샹그릴라 보라카이 리조트 내 위치. 현대적 시설과 체계적 서비스로 1시간 ₱1,500~2,500 수준.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLeaf,
      title: '디스커버리 쇼어 Terra Wellness Spa',
      description: '전문 테라피스트와 쾌적한 시설. 숙박객 외 방문객도 이용 가능합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStar,
      title: '카바얀 스파 (Kabayan Spa)',
      description: 'Station 2에 위치. 가성비 좋은 현지 마사지숍으로 청결하고 친절한 서비스. 1시간 ₱600 내외.',
    ),
  ];

  /// 스파 이용 팁 (Spa Tips)
  static const List<_InfoItem> _spaTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '사전 예약',
      description:
          '인기 스파는 사전 예약을 권장합니다. 공식 웹사이트, 이메일, 전화 또는 KLOOK/KKday에서 할인 바우처를 구매할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserNurse,
      title: '테라피스트 선택',
      description: '선호하는 성별의 테라피스트 요청, 오일 종류 선택이 가능합니다. 임산부나 의료상 주의사항은 미리 알려주세요.',
    ),
  ];

  /// ========================================
  /// 🛡️ 여행자 안전 정보 (Safety Information)
  /// ========================================

  /// 응급 연락처 정보 (Emergency Contacts)
  static const List<_EmergencyContact> _emergencyContacts = [
    _EmergencyContact(
      name: '전국 공통 긴급번호',
      location: '필리핀 전역',
      phone: '911',
      note: '경찰·소방·응급의료 통합 신고',
      icon: FontAwesomeIcons.lightPhoneVolume,
    ),
    _EmergencyContact(
      name: 'Ciriaco S. Tirol 종합병원',
      location: 'Balabag 지역 (Station 2 인근)',
      phone: '+63 36 288 3041',
      note: '24시간 응급실 운영, 섬 유일 공공의료기관',
      icon: FontAwesomeIcons.lightHospital,
    ),
    _EmergencyContact(
      name: '보라카이 관광경찰',
      location: 'Station 2 D\'Mall 옆',
      phone: '+63 36 288 3000',
      note: '24시간 관광객 지원, 분실물 신고',
      icon: FontAwesomeIcons.lightShieldHalved,
    ),
    _EmergencyContact(
      name: '필리핀 해안경비대 Boracay',
      location: '카티클란 항구',
      phone: '+63 36 288 3042',
      note: '해양 활동 중 사고 시 호출',
      icon: FontAwesomeIcons.lightLifeRing,
    ),
    _EmergencyContact(
      name: '보라카이 해변 라이프가드',
      location: '화이트 비치 주요 지점',
      phone: '(036) 288-3609',
      note: '해변 순찰, 구명 장비 배치',
      icon: FontAwesomeIcons.lightPersonSwimming,
    ),
  ];

  /// 의료시설 정보 (Medical Facilities)
  static const List<_InfoItem> _medicalInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHouseChimneyMedical,
      title: '보라카이 얼럿 메디컬 클리닉 (AMC)',
      description:
          'Station 2 메인로드(아잘레아 호텔 근처) 24시간 개인의원. X-ray, 혈액검사 가능. ☎ +63 (036) 288-1278',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStethoscope,
      title: 'MedExpress 클리닉',
      description: 'Balabag, Nirvana Resort 부근. 24시간 운영. 경증 질환 치료.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPrescriptionBottle,
      title: 'Watsons 약국',
      description: 'CityMall 내 위치. 09:00~21:00 영업. 의약품과 생활용품 구비.',
    ),
  ];

  /// 안전 팁 (Safety Tips)
  static const List<_InfoItem> _safetyTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightPassport,
      title: '여권 분실 시',
      description:
          '경찰서에서 분실신고서 작성 후, 주필리핀 한국대사관 영사부에 연락하여 여행증명서를 발급받으세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTruckMedical,
      title: '중증 환자 이송',
      description: '중증 환자나 복잡한 수술의 경우 본토인 파나이섬의 칼리보 Aklan 주립병원으로 이송됩니다.',
    ),
  ];

  /// ========================================
  /// ☀️ 계절별 날씨 정보 (Weather Information)
  /// ========================================

  /// 계절 개요 정보 (Season Overview)
  static const List<_InfoItem> _seasonOverview = [
    _InfoItem(
      icon: FontAwesomeIcons.lightSun,
      title: '건기 (아미한, 11~5월)',
      description:
          '북동풍 계절풍 시기. 쾌적하고 맑은 날씨. 평균 29~32°C. 서쪽 화이트비치 바다가 잔잔하여 해수욕과 스노클링에 최적입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCloudRain,
      title: '우기 (하바갓, 6~10월)',
      description:
          '남서풍 계절풍 시기. 스콜성 폭우가 잦고 습도가 높음. 태풍 시즌과 겹쳐 해상교통이 통제될 수 있습니다. 숙소 요금이 저렴한 비수기입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTemperatureHalf,
      title: '연중 기후',
      description:
          '열대 기후로 연평균 기온 약 30°C, 평균 습도 75%. 가장 시원한 달은 12월, 가장 무더운 달은 5월입니다.',
    ),
  ];

  /// 월별 날씨 정보 (Monthly Weather)
  static const List<_MonthlyWeather> _monthlyWeather = [
    _MonthlyWeather(
      month: '1월',
      temperature: '25~29°C',
      rainfall: '114mm',
      characteristics: '건기 초입, 쾌적',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '2월',
      temperature: '25~29°C',
      rainfall: '55mm',
      characteristics: '연중 최건조',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '3월',
      temperature: '26~31°C',
      rainfall: '51mm',
      characteristics: '건조, 더위 상승',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '4월',
      temperature: '26~32°C',
      rainfall: '60mm',
      characteristics: '더움, 약간의 비',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '5월',
      temperature: '27~32°C',
      rainfall: '191mm',
      characteristics: '더운 초여름, 간헐적 스콜',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '6월',
      temperature: '27~31°C',
      rainfall: '350mm',
      characteristics: '우기 시작, 강한 소나기',
      isDrySeason: false,
    ),
    _MonthlyWeather(
      month: '7월',
      temperature: '26~31°C',
      rainfall: '429mm',
      characteristics: '우기, 폭우 잦음',
      isDrySeason: false,
    ),
    _MonthlyWeather(
      month: '8월',
      temperature: '27~31°C',
      rainfall: '460mm',
      characteristics: '연중 최다우기',
      isDrySeason: false,
    ),
    _MonthlyWeather(
      month: '9월',
      temperature: '27~30°C',
      rainfall: '349mm',
      characteristics: '우기 지속',
      isDrySeason: false,
    ),
    _MonthlyWeather(
      month: '10월',
      temperature: '26~31°C',
      rainfall: '356mm',
      characteristics: '우기 후반, 태풍 유의',
      isDrySeason: false,
    ),
    _MonthlyWeather(
      month: '11월',
      temperature: '26~30°C',
      rainfall: '285mm',
      characteristics: '건기로 전환, 강수 감소',
      isDrySeason: true,
    ),
    _MonthlyWeather(
      month: '12월',
      temperature: '25~29°C',
      rainfall: '212mm',
      characteristics: '건기, 서늘한 바람',
      isDrySeason: true,
    ),
  ];

  /// 최적 여행 시기 정보 (Best Time to Visit)
  static const List<_InfoItem> _bestTimeInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '최적 시기: 12월~4월',
      description:
          '날씨가 안정적이고 바다가 깨끗하여 수영·일광욕·다이빙 등에 최적입니다. 특히 2~3월은 비가 거의 없고 습도도 낮아 가장 쾌적합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGem,
      title: '숨은 황금시기: 11월',
      description:
          '우기에서 건기로 넘어가는 시기. 운이 좋으면 맑은 날씨에 성수기 직전이라 비교적 한적합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPiggyBank,
      title: '비수기 장점: 6~10월',
      description:
          '항공권·리조트 요금이 저렴하고 한산합니다. 우산과 우비를 상시 지참하고 일정을 유연하게 조정하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '피해야 할 시기',
      description:
          '7~9월은 태풍 시즌과 겹쳐 해상교통이 통제될 수 있습니다. 일정을 여유있게 잡으세요. 성수기(12월~3월)는 숙소가 붐비고 요금이 높습니다.',
    ),
  ];

  /// ========================================
  /// 🏧 편의시설 정보 (Facilities Information)
  /// ========================================

  /// 환전소 정보 (Money Exchange Info)
  static const List<_FacilityInfo> _exchangeInfo = [
    _FacilityInfo(
      type: '환전소',
      name: 'D\'Mall 환전소들',
      description:
          '디몰 메인로드변에 여러 환전소가 밀집. Queen\'s 환전소 등이 유명합니다. 여러 곳의 환율을 비교해보세요.',
      tip: 'USD \$100 신권일수록 우대율이 좋습니다. 공항 환전소는 환율이 낮으니 최소 금액만 환전하세요.',
      icon: FontAwesomeIcons.lightMoneyBillTransfer,
    ),
    _FacilityInfo(
      type: '환전소',
      name: 'Nikko 환전소',
      description: 'Station 1 Astoria 호텔 인근 골목. 현지에서 환율이 가장 좋다고 알려진 곳 중 하나입니다.',
      icon: FontAwesomeIcons.lightCoins,
    ),
    _FacilityInfo(
      type: '환전소',
      name: 'Station X 환전소',
      description: 'Station 3 지역. 매일 오전 9시~오후 9시 운영.',
      icon: FontAwesomeIcons.lightBuildingColumns,
    ),
  ];

  /// ATM 정보 (ATM Info)
  static const List<_FacilityInfo> _atmInfo = [
    _FacilityInfo(
      type: 'ATM',
      name: 'D\'Mall 주변 ATM',
      description:
          '디몰 입구와 버짓마트 주변에 BPI, BDO, 메트로뱅크 ATM이 모여 있습니다. CityMall에도 RCBC ATM이 있습니다.',
      tip:
          '해외카드 인출 시 건당 ₱250 수수료, 한도 ₱10,000~20,000. 화면에서 "Without Conversion" 선택 필수!',
      icon: FontAwesomeIcons.lightCreditCard,
    ),
  ];

  /// 통신 정보 (Communication Info)
  static const List<_FacilityInfo> _communicationInfo = [
    _FacilityInfo(
      type: 'Wi-Fi',
      name: '무료 Wi-Fi',
      description:
          '주요 리조트, 호텔, 식당에서 제공. Globe는 화이트비치에서 일일 30분 무료 Wi-Fi 서비스 운영 (휴대폰 인증).',
      icon: FontAwesomeIcons.lightWifi,
    ),
    _FacilityInfo(
      type: 'SIM카드',
      name: 'Globe / Smart SIM',
      description:
          'CityMall 내 통신사 직영점이나 디몰 휴대폰 숍에서 구매. SIM ₱40~100, 7일 8GB 패키지 ₱100. 구입 시 여권 필요.',
      tip: '공항보다 현지 매장이 프로모션 종류가 다양하고 저렴합니다.',
      icon: FontAwesomeIcons.lightSimCard,
    ),
    _FacilityInfo(
      type: 'eSIM',
      name: 'eSIM 서비스',
      description: '한국에서 미리 전자심을 개통해 오는 방법도 있습니다. 도착 즉시 데이터 사용 가능.',
      icon: FontAwesomeIcons.lightMobileSignal,
    ),
  ];

  /// 기타 편의시설 정보 (Other Facilities)
  static const List<_FacilityInfo> _otherFacilities = [
    _FacilityInfo(
      type: '쇼핑몰',
      name: 'CityMall Boracay',
      description: '식료품, 생활용품, 약국(Watsons), ATM, 통신사 매장이 모여 있는 로컬 쇼핑몰.',
      icon: FontAwesomeIcons.lightCartShopping,
    ),
    _FacilityInfo(
      type: '편의점',
      name: 'Budget Mart / 7-Eleven',
      description: '디몰 주변에 위치. 간단한 음료, 스낵, 상비약 구매 가능. 24시간 운영 매장도 있습니다.',
      icon: FontAwesomeIcons.lightStore,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              FontAwesomeIcons.lightUmbrellaBeach,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationBoracay),
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
            /// [히어로 배너 섹션 - Hero Banner Section]
            _buildHeroBanner(context),

            SizedBox(height: sp.s24),

            /// [개요 섹션 - Overview Section]
            _buildSectionHeader(
              context,
              emoji: '🏝️',
              title: '보라카이 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _overviewInfo, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [이동 방법 섹션 - Transportation Section]
            _buildSectionHeader(
              context,
              emoji: '✈️',
              title: '한국 → 보라카이 이동 방법',
            ),
            SizedBox(height: sp.s12),
            _buildSubSectionTitle(context, '항공 이동 경로'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _flightRouteTable),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '공항 → 보라카이 섬 이동'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _airportTransferTable),

            SizedBox(height: sp.s24),

            /// [해변 섹션 - Beach Section]
            _buildSectionHeader(
              context,
              emoji: '🌊',
              title: '자연 / 해변형 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildBeachCards(context),

            SizedBox(height: sp.s24),

            /// [역사·문화 섹션 - Culture Section]
            _buildSectionHeader(
              context,
              emoji: '🏛️',
              title: '역사·문화 요소',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _cultureInfo,
              scheme.secondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [쇼핑 섹션 - Shopping Section]
            _buildSectionHeader(
              context,
              emoji: '🛍️',
              title: '쇼핑 / 도심 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _shoppingInfo, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [가족 섹션 - Family Section]
            _buildSectionHeader(
              context,
              emoji: '👨‍👩‍👧‍👦',
              title: '가족 / 어린이 동반 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _familyInfo, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [액티비티 섹션 - Activity Section]
            _buildSectionHeader(
              context,
              emoji: '🏄‍♂️',
              title: '액티비티 / 레저',
            ),
            SizedBox(height: sp.s12),
            _buildActivityGrid(context),

            SizedBox(height: sp.s24),

            /// [섬 내부 교통 섹션 - Island Transport Section]
            _buildSectionHeader(
              context,
              emoji: '🚕',
              title: '섬 내부 교통 정보',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _transportInfo,
              scheme.secondaryContainer,
            ),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '이동 시간 예시'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _travelTimeTable),

            SizedBox(height: sp.s24),

            /// [참고 사항 섹션 - Notes Section]
            _buildSectionHeader(
              context,
              emoji: '⚠️',
              title: '참고 사항',
            ),
            SizedBox(height: sp.s12),
            _buildNotesSection(context),

            SizedBox(height: sp.s24),

            /// ========================================
            /// [🥘 먹거리 정보 섹션 - Food Section]
            /// ========================================
            _buildSectionHeader(
              context,
              emoji: '🥘',
              title: '섬 내 먹거리 정보',
            ),
            SizedBox(height: sp.s12),

            /// 대표 길거리 음식 (Street Food)
            _buildSubSectionTitle(context, '대표 길거리 음식'),
            SizedBox(height: sp.s8),
            _buildRestaurantCards(context, _streetFoodInfo),

            SizedBox(height: sp.s16),

            /// 해산물 시장 (Seafood Market)
            _buildSubSectionTitle(context, '해산물 시장 & 식당'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _seafoodInfo, scheme.primaryContainer),

            SizedBox(height: sp.s16),

            /// 추천 맛집 (Recommended Restaurants)
            _buildSubSectionTitle(context, '추천 맛집'),
            SizedBox(height: sp.s8),
            _buildRestaurantCards(context, _recommendedRestaurants),

            SizedBox(height: sp.s16),

            /// 디저트 & 카페 (Dessert & Cafe)
            _buildSubSectionTitle(context, '디저트 & 카페'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _dessertInfo, scheme.tertiaryContainer),

            SizedBox(height: sp.s16),

            /// 야시장 정보 (Night Market)
            _buildSubSectionTitle(context, '야시장 정보'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _nightMarketInfo, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// ========================================
            /// [💆 스파/마사지 섹션 - Spa Section]
            /// ========================================
            _buildSectionHeader(
              context,
              emoji: '💆',
              title: '스파 · 마사지 · 힐링',
            ),
            SizedBox(height: sp.s12),

            /// 일반 마사지 (General Massage)
            _buildSubSectionTitle(context, '일반 마사지'),
            SizedBox(height: sp.s8),
            _buildInfoCards(
                context, _generalMassageInfo, scheme.primaryContainer),

            SizedBox(height: sp.s16),

            /// 럭셔리 스파 (Luxury Spa)
            _buildSubSectionTitle(context, '럭셔리 스파'),
            SizedBox(height: sp.s8),
            _buildSpaCards(context),

            SizedBox(height: sp.s16),

            /// 호텔 스파 (Hotel Spa)
            _buildSubSectionTitle(context, '호텔 스파 & 가성비 스파'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _hotelSpaInfo, scheme.secondaryContainer),

            SizedBox(height: sp.s16),

            /// 스파 이용 팁 (Spa Tips)
            _buildSubSectionTitle(context, '스파 이용 팁'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _spaTips, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// ========================================
            /// [🛡️ 안전 정보 섹션 - Safety Section]
            /// ========================================
            _buildSectionHeader(
              context,
              emoji: '🛡️',
              title: '여행자 안전 정보',
            ),
            SizedBox(height: sp.s12),

            /// 응급 연락처 (Emergency Contacts)
            _buildSubSectionTitle(context, '응급 연락처'),
            SizedBox(height: sp.s8),
            _buildEmergencyContactCards(context),

            SizedBox(height: sp.s16),

            /// 의료시설 (Medical Facilities)
            _buildSubSectionTitle(context, '의료시설'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _medicalInfo, scheme.primaryContainer),

            SizedBox(height: sp.s16),

            /// 안전 팁 (Safety Tips)
            _buildSubSectionTitle(context, '안전 팁'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _safetyTips, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// ========================================
            /// [☀️ 날씨/계절 섹션 - Weather Section]
            /// ========================================
            _buildSectionHeader(
              context,
              emoji: '☀️',
              title: '계절별 날씨 및 최적 여행 시기',
            ),
            SizedBox(height: sp.s12),

            /// 계절 개요 (Season Overview)
            _buildSubSectionTitle(context, '계절 개요'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _seasonOverview, scheme.primaryContainer),

            SizedBox(height: sp.s16),

            /// 월별 날씨 (Monthly Weather)
            _buildSubSectionTitle(context, '월별 평균 기후'),
            SizedBox(height: sp.s8),
            _buildWeatherTable(context),

            SizedBox(height: sp.s16),

            /// 최적 여행 시기 (Best Time to Visit)
            _buildSubSectionTitle(context, '최적 여행 시기'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _bestTimeInfo, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// ========================================
            /// [🏧 편의시설 섹션 - Facilities Section]
            /// ========================================
            _buildSectionHeader(
              context,
              emoji: '🏧',
              title: '편의시설 정보',
            ),
            SizedBox(height: sp.s12),

            /// 환전소 (Money Exchange)
            _buildSubSectionTitle(context, '환전소'),
            SizedBox(height: sp.s8),
            _buildFacilityCards(context, _exchangeInfo),

            SizedBox(height: sp.s16),

            /// ATM
            _buildSubSectionTitle(context, 'ATM'),
            SizedBox(height: sp.s8),
            _buildFacilityCards(context, _atmInfo),

            SizedBox(height: sp.s16),

            /// 통신 (Communication)
            _buildSubSectionTitle(context, 'Wi-Fi & SIM카드'),
            SizedBox(height: sp.s8),
            _buildFacilityCards(context, _communicationInfo),

            SizedBox(height: sp.s16),

            /// 기타 편의시설 (Other Facilities)
            _buildSubSectionTitle(context, '기타 편의시설'),
            SizedBox(height: sp.s8),
            _buildFacilityCards(context, _otherFacilities),

            SizedBox(height: sp.s24),

            /// [마무리 요약 섹션 - Summary Section]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  Widget _buildHeroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.7),
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
                '🏖️',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🌴',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 보라카이\n여행 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '세계적인 화이트 비치와 다양한 액티비티를 즐겨보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  Widget _buildSectionHeader(
    BuildContext context, {
    required String emoji,
    required String title,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      children: [
        Text(
          emoji,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 서브 섹션 타이틀 빌드 (Build sub section title)
  Widget _buildSubSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.primary,
      ),
    );
  }

  /// 정보 카드 목록 빌드 (Build info cards list)
  Widget _buildInfoCards(
    BuildContext context,
    List<_InfoItem> items,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.map((item) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
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

  /// 데이터 테이블 빌드 (Build data table)
  Widget _buildDataTable(BuildContext context, List<_TableRow> rows) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isFirst = index == 0;
          final isLast = index == rows.length - 1;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s8,
            ),
            decoration: BoxDecoration(
              color: row.isHeader ? scheme.primaryContainer : null,
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(12) : Radius.zero,
                bottom: isLast ? const Radius.circular(12) : Radius.zero,
              ),
              border: !isLast
                  ? Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: row.columns.asMap().entries.map((colEntry) {
                final colIndex = colEntry.key;
                final colValue = colEntry.value;
                final isFirstCol = colIndex == 0;

                return Expanded(
                  flex: isFirstCol ? 2 : 3,
                  child: Text(
                    colValue,
                    style: row.isHeader
                        ? theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          )
                        : theme.textTheme.bodySmall?.copyWith(
                            color: isFirstCol
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontWeight:
                                isFirstCol ? FontWeight.w500 : FontWeight.normal,
                          ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 해변 카드 빌드 (Build beach cards)
  Widget _buildBeachCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _beachInfo.map((beach) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        beach.icon,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      beach.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Text(
                beach.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sp.s12),
              ...beach.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
      }).toList(),
    );
  }

  /// 액티비티 그리드 빌드 (Build activity grid)
  Widget _buildActivityGrid(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: sp.s8,
        mainAxisSpacing: sp.s8,
      ),
      itemCount: _activityInfo.length,
      itemBuilder: (context, index) {
        final activity = _activityInfo[index];
        return Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    activity.icon,
                    size: 16,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ),
              SizedBox(height: sp.s8),
              Text(
                activity.name,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: sp.s4),
              Text(
                activity.location,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                activity.note,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.primary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 참고 사항 섹션 빌드 (Build notes section)
  Widget _buildNotesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _notesInfo.map((note) {
          final isLast = note == _notesInfo.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  note.icon,
                  size: 16,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onErrorContainer,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        note.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ========================================
  /// 음식점/맛집 카드 빌드 (Build restaurant cards)
  /// ========================================
  Widget _buildRestaurantCards(
    BuildContext context,
    List<_RestaurantInfo> restaurants,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: restaurants.map((restaurant) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    restaurant.icon,
                    size: 18,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (restaurant.price != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sp.s8,
                              vertical: sp.s4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              restaurant.price!,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onTertiaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      restaurant.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      restaurant.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
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

  /// ========================================
  /// 스파 카드 빌드 (Build spa cards)
  /// ========================================
  Widget _buildSpaCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _luxurySpaInfo.map((spa) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        spa.icon,
                        size: 20,
                        color: scheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spa.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        SizedBox(height: sp.s4),
                        Text(
                          spa.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s12,
                  vertical: sp.s8,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  spa.priceRange,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: sp.s12),
              Text(
                spa.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sp.s12),
              ...spa.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✓',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
      }).toList(),
    );
  }

  /// ========================================
  /// 응급 연락처 카드 빌드 (Build emergency contact cards)
  /// ========================================
  Widget _buildEmergencyContactCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _emergencyContacts.map((contact) {
          final isLast = contact == _emergencyContacts.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(
                      contact.icon,
                      size: 18,
                      color: scheme.onErrorContainer,
                    ),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightPhone,
                            size: 12,
                            color: scheme.primary,
                          ),
                          SizedBox(width: sp.s4),
                          Text(
                            contact.phone,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '${contact.location} · ${contact.note}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// ========================================
  /// 월별 날씨 테이블 빌드 (Build weather table)
  /// ========================================
  Widget _buildWeatherTable(BuildContext context) {
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
          /// 헤더 행 (Header row)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s8,
            ),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '월',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '기온',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '강수량',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '특징',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 데이터 행들 (Data rows)
          ..._monthlyWeather.asMap().entries.map((entry) {
            final index = entry.key;
            final weather = entry.value;
            final isLast = index == _monthlyWeather.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: sp.s12,
                vertical: sp.s8,
              ),
              decoration: BoxDecoration(
                color: weather.isDrySeason
                    ? scheme.primaryContainer.withValues(alpha: 0.2)
                    : scheme.secondaryContainer.withValues(alpha: 0.2),
                borderRadius: isLast
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      )
                    : null,
                border: !isLast
                    ? Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          weather.isDrySeason ? '☀️' : '🌧️',
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(width: sp.s4),
                        Text(
                          weather.month,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      weather.temperature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      weather.rainfall,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      weather.characteristics,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
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

  /// ========================================
  /// 편의시설 카드 빌드 (Build facility cards)
  /// ========================================
  Widget _buildFacilityCards(
    BuildContext context,
    List<_FacilityInfo> facilities,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: facilities.map((facility) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    facility.icon,
                    size: 18,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            facility.type,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: sp.s8),
                        Expanded(
                          child: Text(
                            facility.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s8),
                    Text(
                      facility.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (facility.tip != null) ...[
                      SizedBox(height: sp.s8),
                      Container(
                        padding: EdgeInsets.all(sp.s8),
                        decoration: BoxDecoration(
                          color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡',
                              style: theme.textTheme.bodyMedium,
                            ),
                            SizedBox(width: sp.s8),
                            Expanded(
                              child: Text(
                                facility.tip!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: scheme.onTertiaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '섬 길이 7km, 폭 1km의 아담한 휴양지',
      '화이트 비치 - 세계적으로 유명한 4km 백사장',
      '카티클란/칼리보 공항 이용 후 보트로 입도',
      '트라이시클로 섬 내 이동 (10~20분)',
      '숙소 예약 확인서 필수 (환경 보호 정책)',
      '다양한 수상 액티비티와 아일랜드 호핑',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.5),
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
                '🏝️',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '✨',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '핵심 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...summaryItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅',
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        height: 1.4,
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
}
