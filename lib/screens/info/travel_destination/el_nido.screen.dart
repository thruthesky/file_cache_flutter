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

/// 라군 정보 데이터 클래스 (Lagoon Info Data Class)
///
/// 엘니도의 라군 스팟 정보를 담습니다.
/// Contains lagoon spot information in El Nido.
class _LagoonInfo {
  /// 라군 이름 (Lagoon name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 (Highlight)
  final String highlight;

  /// 아이콘 (Icon)
  final IconData icon;

  const _LagoonInfo({
    required this.name,
    required this.description,
    required this.highlight,
    required this.icon,
  });
}

/// 투어 코스 데이터 클래스 (Tour Course Data Class)
///
/// 엘니도 섬호핑투어 코스 정보를 담습니다.
/// Contains El Nido island hopping tour course information.
class _TourCourse {
  /// 코스명 (Course name)
  final String name;

  /// 주요 목적지 (Main destinations)
  final String destinations;

  /// 특징 (Character)
  final String character;

  /// 아이콘 (Icon)
  final IconData icon;

  const _TourCourse({
    required this.name,
    required this.destinations,
    required this.character,
    required this.icon,
  });
}

/// 요금 정보 데이터 클래스 (Fee Info Data Class)
///
/// 엘니도 입장료 및 환경 관리 요금 정보를 담습니다.
/// Contains El Nido entrance and environmental management fee information.
class _FeeInfo {
  /// 요금 종류 (Fee type)
  final String type;

  /// 금액 (Amount)
  final String amount;

  /// 설명 (Description)
  final String description;

  /// 아이콘 (Icon)
  final IconData icon;

  const _FeeInfo({
    required this.type,
    required this.amount,
    required this.description,
    required this.icon,
  });
}

/// 준비물 정보 데이터 클래스 (Preparation Item Data Class)
class _PrepItem {
  /// 항목명 (Item name)
  final String name;

  /// 용도 (Purpose)
  final String purpose;

  /// 아이콘 (Icon)
  final IconData icon;

  const _PrepItem({
    required this.name,
    required this.purpose,
    required this.icon,
  });
}

/// 일정 아이템 데이터 클래스 (Schedule Item Data Class)
///
/// 1일 플랜의 각 일정 항목 정보를 담습니다.
/// Contains schedule item information for the 1-day plan.
class _ScheduleItem {
  /// 시간대 (Time slot)
  final String time;

  /// 일정 제목 (Schedule title)
  final String title;

  /// 일정 설명 (Schedule description)
  final String description;

  /// 아이콘 (Icon)
  final IconData icon;

  /// 강조 여부 (Is highlight)
  final bool isHighlight;

  const _ScheduleItem({
    required this.time,
    required this.title,
    required this.description,
    required this.icon,
    this.isHighlight = false,
  });
}

/// 이미지 갤러리 아이템 데이터 클래스 (Image Gallery Item Data Class)
class _GalleryImage {
  /// 이미지 URL (Image URL)
  final String url;

  /// 이미지 설명 (Image description)
  final String description;

  const _GalleryImage({
    required this.url,
    required this.description,
  });
}

/// 엘니도 여행 정보 화면 (El Nido Travel Screen)
///
/// 필리핀 팔라완 엘니도 여행 정보를 제공합니다.
/// 라군, 석회암 절벽(카르스트), 섬호핑투어 중심의 심층 여행 가이드입니다.
/// Provides travel information about El Nido, Palawan in the Philippines.
/// In-depth travel guide focusing on lagoons, karst cliffs, and island hopping tours.
///
/// ### 사용법 (Usage):
/// ```dart
/// ElNidoScreen.push(context);
/// ```
class ElNidoScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/ElNido';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ElNidoScreen({super.key});

  @override
  State<ElNidoScreen> createState() => _ElNidoScreenState();
}

class _ElNidoScreenState extends State<ElNidoScreen> {
  /// [카르스트 지형 설명 - Karst Terrain Info]
  ///
  /// 엘니도가 라군과 석회암 절벽으로 유명한 이유입니다.
  /// Why El Nido is famous for lagoons and limestone cliffs.
  static const List<_InfoItem> _karstInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMountain,
      title: '바쿠이트 베이의 카르스트 지형',
      description:
          '엘니도 바쿠이트 베이(Bacuit Bay) 일대는 석회암(라임스톤)이 물·파도·침식에 의해 깎이면서 생긴 카르스트(karst) 지형이 촘촘히 분포한 곳입니다. 칼날처럼 뾰족하고 수직에 가까운 절벽이 바다에서 바로 솟고, 그 사이에 코브(cove)·숨은 해변·라군(내해)이 "미로처럼" 끼어 있는 형태가 만들어집니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightEye,
      title: '엘니도의 진정한 매력',
      description:
          '엘니도의 매력은 "바다 위에서 보는 절벽"도 크지만, 절벽 사이 좁은 수로로 \'들어가야만\' 보이는 내부 공간(라군/시크릿 비치류)에 있습니다. 이 구조 자체가 "보트+카약"을 사실상 표준 경험으로 만든 셈입니다.',
    ),
  ];

  /// [보호구역(ENTMRPA) 정보 - Protected Area Info]
  static const List<_InfoItem> _protectedAreaInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      title: 'ENTMRPA 보호구역',
      description:
          '엘니도 일대는 국가 차원에서 보호구역으로 지정·관리되어 왔고(1998년 Proclamation No. 32), 바쿠이트 베이의 해양 생태뿐 아니라 주변 육상 생태까지 포함하는 관리가 강조됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRulerCombined,
      title: '보호구역 규모',
      description:
          'ENTMRPA는 엘니도와 타이타이 일부를 포괄하며, 총 약 90,312ha 규모(해양 약 54,303ha / 육상 약 36,018ha)입니다. UNESCO 잠정 리스트에도 등재되어 있습니다.',
    ),
  ];

  /// [에메랄드 라군 3대장 - Three Major Lagoons]
  static const List<_LagoonInfo> _lagoons = [
    _LagoonInfo(
      name: 'Big Lagoon (빅 라군)',
      description:
          '엘니도의 대표 이미지급 라군. 수로가 길게 열리고, 절벽 스케일 + 물빛(옥빛/에메랄드)이 가장 "엽서 같은" 구도를 만듭니다. 보통 Tour A의 핵심으로 묶여 소개됩니다.',
      highlight: '"카약이 왜 필수처럼 느껴지는지"를 가장 잘 체감하는 곳',
      icon: FontAwesomeIcons.lightWater,
    ),
    _LagoonInfo(
      name: 'Small Lagoon (스몰 라군)',
      description:
          '상대적으로 입구가 좁고 아늑해서 "숨은 공간에 들어온 느낌"이 강합니다. 카약 만족도가 높다는 후기가 많고, 코스 구성상 Tour D에 자주 묶여 안내됩니다.',
      highlight: '아늑한 분위기와 카약 체험 최적화',
      icon: FontAwesomeIcons.lightDroplet,
    ),
    _LagoonInfo(
      name: 'Secret Lagoon (시크릿 라군)',
      description:
          '바깥에서 잘 보이지 않다가 바위 틈/입구를 통과하면 안쪽이 열리는 형태로 "비밀 지형" 콘셉트를 상징합니다. 파도·조류·혼잡에 따라 체감은 달라질 수 있습니다.',
      highlight: '숨겨진 비밀 공간의 발견 경험',
      icon: FontAwesomeIcons.lightKey,
    ),
  ];

  /// [카약이 필수템이 되는 이유 - Why Kayak is Essential]
  static const List<_InfoItem> _kayakReasons = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShip,
      title: '보트 진입 제한',
      description: '라군 내부는 보트가 마음대로 깊숙이 못 들어가는 경우가 있어, 가까이 보려면 카약/수영이 핵심이 됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightWind,
      title: '잔잔한 내부 환경',
      description:
          '바람/파도 영향이 있는 날에도 라군 안쪽은 비교적 잔잔해 \'물빛+절벽 근접 체감\'이 좋습니다(특히 오전).',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRoute,
      title: '현실적인 접근 방법',
      description:
          '"시내 해변에서 카약만으로 라군까지"는 거리·해상 컨디션·안전 때문에 비현실적이라, 대부분 호핑투어(보트)+라군 카약 대여 조합이 됩니다.',
    ),
  ];

  /// [섬호핑투어 코스 - Island Hopping Tour Courses]
  static const List<_TourCourse> _tourCourses = [
    _TourCourse(
      name: 'Tour A (라군·클래식)',
      destinations: 'Big Lagoon, Secret Lagoon, Shimizu Island, Seven Commandos Beach 등',
      character: '"엘니도 첫 방문"이면 기본값으로 추천되는 편. 라군 체험의 정석.',
      icon: FontAwesomeIcons.lightA,
    ),
    _TourCourse(
      name: 'Tour B (동굴·샌드바)',
      destinations: 'Snake Island, Cudugnon Cave, Cathedral Cave 등',
      character: '"동굴/지형" 테마 중심. 독특한 지질 구조 탐험.',
      icon: FontAwesomeIcons.lightB,
    ),
    _TourCourse(
      name: 'Tour C (스노클·드라마틱 비치)',
      destinations: 'Secret Beach, Hidden Beach, Matinloc Shrine, Helicopter Island 등',
      character: '"라군보다 비치/스노클 비중"을 원할 때. 드라마틱한 해변 경험.',
      icon: FontAwesomeIcons.lightC,
    ),
    _TourCourse(
      name: 'Tour D (스몰 라군 쪽)',
      destinations: 'Small Lagoon, Cadlao Lagoon, Paradise Beach 등',
      character: '"아늑한 라군 카약"을 확실히 하고 싶을 때 후보.',
      icon: FontAwesomeIcons.lightD,
    ),
  ];

  /// [입장료·환경 관리 요금 - Fees and Environmental Management]
  static const List<_FeeInfo> _fees = [
    _FeeInfo(
      type: 'ETDF (Eco-Tourism Development Fee)',
      amount: 'PHP 400',
      description: '엘니도 관광개발·환경재원 수수료. 기존 200페소에서 인상. 거주지별·학생 할인·주민 면제 등 세부 구조 있음.',
      icon: FontAwesomeIcons.lightTicket,
    ),
    _FeeInfo(
      type: 'EUF (Environmental User Fee)',
      amount: 'PHP 200/인',
      description: 'Big Lagoon·Small Lagoon 방문객에게 부과. 보호구역 보전·관리 재원(IPAF)으로 사용.',
      icon: FontAwesomeIcons.lightLeaf,
    ),
  ];

  /// [수용력 관리 정보 - Capacity Management]
  static const _InfoItem _capacityInfo = _InfoItem(
    icon: FontAwesomeIcons.lightUsersGear,
    title: '인원·시간대 수용력 관리',
    description:
        '혼잡/서식지 훼손 문제 때문에 라군 같은 핵심 스팟은 수용력(인원·카약·체류시간) 제한을 시행/강화해 왔습니다. 현장 운영 방식은 시즌·정책에 따라 바뀔 수 있어, "내가 가는 시점 규정"을 전날/당일에 확인하는 게 안전합니다.',
  );

  /// [시즌 정보 - Season Info]
  static const List<_InfoItem> _seasonInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightSun,
      title: 'Amihan (북동계절풍)',
      description: '더 선선·건조한 경향. 해상 투어에 유리한 시기. 물색/카약/호핑에 최적.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCloudRain,
      title: 'Habagat (남서계절풍)',
      description:
          '서쪽 지역에 비·바람이 잦아지는 경향. 팔라완도 영향권. 악천후 시 해경/당국의 항해 제한(no-sail)로 투어 취소/변경 가능.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClockEight,
      title: '최적 시간대',
      description: '체감상 "물색/카약/호핑"은 바람이 잔잔한 날 + 오전 출항이 유리합니다.',
    ),
  ];

  /// [준비물 - Preparation Items]
  static const List<_PrepItem> _prepItems = [
    _PrepItem(
      name: '아쿠아슈즈',
      purpose: '바위·산호·미끄럼 대비',
      icon: FontAwesomeIcons.lightShoePrints,
    ),
    _PrepItem(
      name: '방수팩',
      purpose: '전자기기·귀중품 보호',
      icon: FontAwesomeIcons.lightBagShopping,
    ),
    _PrepItem(
      name: '래시가드',
      purpose: '자외선 차단 및 체온 유지',
      icon: FontAwesomeIcons.lightShirt,
    ),
    _PrepItem(
      name: '멀미약',
      purpose: '보트 이동 중 멀미 대비',
      icon: FontAwesomeIcons.lightPills,
    ),
    _PrepItem(
      name: '개인 스노클 마스크',
      purpose: '위생 및 편의성',
      icon: FontAwesomeIcons.lightMaskSnorkel,
    ),
    _PrepItem(
      name: '리프 세이프 선크림',
      purpose: '산호 보호를 위한 친환경 제품',
      icon: FontAwesomeIcons.lightSunBright,
    ),
  ];

  /// [동선/운영 팁 - Route/Operation Tips]
  static const List<_InfoItem> _operationTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '예약 시 확인 사항',
      description: '라군이 목적이면 예약할 때 "Big Lagoon 포함인지" + "라군 카약 시간"을 먼저 확인하세요(업체마다 순서·정차가 달라요).',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현장 추가 결제',
      description: '현장 추가 결제(ETDF/EUF 등)가 생길 수 있으니 현금/결제수단 여유 있게 준비하세요.',
    ),
  ];

  /// [사진 팁 - Photo Tips]
  static const List<_InfoItem> _photoTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCameraRetro,
      title: '광각 + 낮은 시점',
      description: '카약 앞/수면 가까이에서 촬영하면 절벽 스케일이 가장 크게 살아납니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightImage,
      title: '빅 라군 구도',
      description: '빅 라군은 특히 "수로가 길게 열리는 방향"으로 구도를 잡으면 엘니도 특유의 \'절벽 미로\' 느낌이 강해집니다.',
    ),
  ];

  /// [1일 플랜 - One Day Plan (라군 최우선, 2인)]
  ///
  /// 라군 체험을 최우선으로 하는 2인 기준 1일 일정입니다.
  /// One-day itinerary for 2 people prioritizing lagoon experience.
  static const List<_ScheduleItem> _oneDayPlan = [
    _ScheduleItem(
      time: '07:15–08:10',
      title: '준비 & 체크인 (가장 중요)',
      description:
          '현금 준비 필수:\n• ETDF(에코관광 개발 수수료): 1인 PHP 400\n• 라군 환경이용료(EUF): Big/Small Lagoon 각 1인 PHP 200\n\n팁: 라군 혼잡을 피하려면 일반(9시 출항)보다 1시간 빠른 \'카운터-더-클락(8시쯤 출항)\' 또는 \'리버스(역순)\'가 유리합니다.',
      icon: FontAwesomeIcons.lightClipboardCheck,
    ),
    _ScheduleItem(
      time: '08:10–09:10',
      title: '보트 출항 & 미닐록 방면 이동',
      description:
          '대부분 Tour A는 08:30–09:00 전후 출발로 안내됩니다. 라군 최우선이면 \'빠른 출항(가능 시 8:00)\'을 강력 추천합니다.',
      icon: FontAwesomeIcons.lightShip,
    ),
    _ScheduleItem(
      time: '09:10–10:40',
      title: '1차 하이라이트: Big Lagoon (카약 70–90분)',
      description:
          '오늘 일정의 "승부처". 사람 몰리기 전에 먼저 들어가서 카약 시간을 길게 잡습니다.\n카약 대여(2인 기준): 현장가 변동이 있지만 통상 2인 카약 PHP 300 정도.',
      icon: FontAwesomeIcons.lightWater,
      isHighlight: true,
    ),
    _ScheduleItem(
      time: '10:55–12:00',
      title: '2차 라군: Small Lagoon',
      description:
          '"입구가 좁고 아늑한 라군"으로 카약 만족도가 높다는 평이 많습니다. 라군 전용 콘셉트에 가장 잘 맞는 코스입니다.\n참고: Small Lagoon은 보통 Tour D에서 많이 묶이므로, 확실히 가려면 프라이빗 보트(커스텀)가 유리합니다.',
      icon: FontAwesomeIcons.lightDroplet,
      isHighlight: true,
    ),
    _ScheduleItem(
      time: '12:10–13:00',
      title: '점심(최소 정차) + 휴식',
      description:
          '"라군 전용"이라도 점심/화장실/휴식용 정차는 현실적으로 필요합니다.\nTour A 표준 정차지: Shimizu Island, Seven Commandos Beach 등.\n원하면 "해변 체류 최소화 + 식사만 빠르게" 요청하세요.',
      icon: FontAwesomeIcons.lightUtensils,
    ),
    _ScheduleItem(
      time: '13:05–13:40',
      title: '(선택) Secret Lagoon 짧게',
      description:
          '바깥에서 잘 안 보이다가 바위 틈을 지나 안쪽 공간이 열리는 형태로 "라군 테마"에 잘 맞습니다.\n파도/혼잡에 따라 체감이 달라질 수 있어 짧게 보고 라군(카약) 시간 확보가 만족도가 높습니다.',
      icon: FontAwesomeIcons.lightKey,
    ),
    _ScheduleItem(
      time: '13:50–15:00',
      title: '(가능하면) 라군/카약 추가 타임 or 스노클',
      description:
          '오후로 갈수록 바람/구름이 늘면 물색이 탁해 보일 수 있어 "오전 집중"이 베스트.\n컨디션이 좋으면 Shimizu 인근에서 짧게 스노클(30–40분) 정도만.',
      icon: FontAwesomeIcons.lightMaskSnorkel,
    ),
    _ScheduleItem(
      time: '15:00–16:00',
      title: '귀항 & 샤워/정리',
      description: '투어 종료 후 숙소로 돌아와 휴식합니다.',
      icon: FontAwesomeIcons.lightHouse,
    ),
  ];

  /// [예약 전략 팁 - Booking Strategy Tips]
  static const List<_InfoItem> _bookingTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShip,
      title: '프라이빗 보트(2인 전용) 추천',
      description:
          'Big+Small 라군 우선 커스텀 추천. Tour A 기본 정차(빅 라군 등)는 잘 굴러가지만, Small Lagoon까지 \'확정\'하려면 프라이빗이 유리합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '출항 옵션',
      description: '(1) 8시대 조기 출항 또는 (2) 역순(Reverse)로 혼잡 회피를 추천합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalculator,
      title: '비용 구조 (2인 기준)',
      description:
          '• ETDF: 400×2 = PHP 800\n• 라군 EUF: 200×2×(방문 라군 수) → 빅+스몰이면 PHP 800\n• 카약: 2인 PHP 300~(현장 변동)',
    ),
  ];

  /// [주의사항 - Cautions]
  static const List<_InfoItem> _cautions = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCircleExclamation,
      title: 'EUF 환불 정책',
      description:
          '라군 EUF는 \'기상 악화로 해경(Coast Guard)이 투어 취소\' 같은 불가항력에만 환불 예외가 언급됩니다. 정책/운영은 현장 공지 우선.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUsersGear,
      title: '수용력 제한',
      description: '엘니도는 수용력(캐링 캐퍼시티) 기반 관리를 강화하는 흐름이 있어, 라군 입장/시간 제한이 생길 수 있습니다.',
    ),
  ];

  /// [이미지 갤러리 - Image Gallery]
  ///
  /// 엘니도 라군 관련 이미지들입니다.
  /// Images related to El Nido lagoons.
  static const List<_GalleryImage> _galleryImages = [
    _GalleryImage(
      /// 엘니도 빅 라군 이미지 (Big Lagoon image)
      url: 'https://philgo.com/res/travel/big-lagoon-in-el-nido.jpg',
      description:
          '엘니도(El Nido): 라군 전체가 사진에 들어 오는 장면. 바쿠이트 군도 석회암 절벽과 에메랄드 라군(카약/호핑투어)로 가장 유명합니다.',
    ),
    _GalleryImage(
      /// 엘니도 스몰 라군 이미지 1 (Small Lagoon image 1)
      url: 'https://philgo.com/res/travel/small-lagoon-in-el-nido.jpg',
      description:
          'Small Lagoon (스몰 라군): 카약을 타는 장면. 입구가 비교적 좁고 안쪽이 아늑해서 카약 체험 만족도가 높은 편으로 많이 알려져 있습니다.',
    ),
    _GalleryImage(
      /// 엘니도 스몰 라군 이미지 2 (Small Lagoon image 2)
      url: 'https://philgo.com/res/travel/small-lagoon-in-el-nido-2.jpg',
      description:
          'Small Lagoon (스몰 라군): 작은 보트가 바위 틈을 지나는 장면. 바위 틈을 지나 안쪽으로 들어가면 고요한 물과 아름다운 자연 경관이 펼쳐집니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.travelDestinationElNido),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 섹션 1: 카르스트 지형 (Karst Terrain Section)
            _buildSectionTitle(
              context,
              '1. 엘니도가 \'라군·석회암 절벽(카르스트)\'으로 유명한 진짜 이유',
              FontAwesomeIcons.lightMountainSun,
            ),
            SizedBox(height: sp.s12),
            ..._karstInfo.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s24),

            /// 섹션 2: 보호구역 (Protected Area Section)
            _buildSectionTitle(
              context,
              '2. 보호구역(ENTMRPA) 관점에서 보는 엘니도',
              FontAwesomeIcons.lightShieldHalved,
            ),
            SizedBox(height: sp.s12),
            ..._protectedAreaInfo.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s24),

            /// 섹션 3: 에메랄드 라군 3대장 (Three Major Lagoons Section)
            _buildSectionTitle(
              context,
              '3. "에메랄드 라군" 3대장',
              FontAwesomeIcons.lightWater,
            ),
            SizedBox(height: sp.s12),
            ..._lagoons.map((lagoon) => _buildLagoonCard(context, lagoon)),

            SizedBox(height: sp.s16),

            /// 카약 필수 이유 (Why Kayak is Essential)
            _buildSubSectionTitle(context, '카약이 필수템이 되는 현실적 이유 3가지'),
            SizedBox(height: sp.s8),
            ..._kayakReasons.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s24),

            /// 섹션 4: 섬호핑투어 (Island Hopping Tour Section)
            _buildSectionTitle(
              context,
              '4. 섬호핑투어(Tour A/B/C/D)',
              FontAwesomeIcons.lightShip,
            ),
            SizedBox(height: sp.s12),
            ..._tourCourses.map((course) => _buildTourCard(context, course)),

            SizedBox(height: sp.s24),

            /// 섹션 5: 입장료·환경 관리 (Fees Section)
            _buildSectionTitle(
              context,
              '5. 입장료·환경 관리(요금/규정)',
              FontAwesomeIcons.lightReceipt,
            ),
            SizedBox(height: sp.s12),
            ..._fees.map((fee) => _buildFeeCard(context, fee)),
            SizedBox(height: sp.s8),
            _buildInfoCard(context, _capacityInfo),

            SizedBox(height: sp.s24),

            /// 섹션 6: 시즌 정보 (Season Info Section)
            _buildSectionTitle(
              context,
              '6. 언제 가야 가장 만족도가 높나',
              FontAwesomeIcons.lightCalendarDays,
            ),
            SizedBox(height: sp.s12),
            ..._seasonInfo.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s24),

            /// 섹션 7: 실전 팁 (Practical Tips Section)
            _buildSectionTitle(
              context,
              '7. 더 만족스럽게 즐기는 실전 팁',
              FontAwesomeIcons.lightLightbulb,
            ),
            SizedBox(height: sp.s12),

            /// 준비물 (Preparation Items)
            _buildSubSectionTitle(context, '준비물(체감 효율 높은 것만)'),
            SizedBox(height: sp.s8),
            _buildPrepItemsGrid(context),

            SizedBox(height: sp.s16),

            /// 동선/운영 팁 (Operation Tips)
            _buildSubSectionTitle(context, '동선/운영 팁'),
            SizedBox(height: sp.s8),
            ..._operationTips.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s16),

            /// 사진 팁 (Photo Tips)
            _buildSubSectionTitle(context, '사진 팁(라군에서 잘 먹히는 공식)'),
            SizedBox(height: sp.s8),
            ..._photoTips.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s24),

            /// 섹션 8: 이미지 갤러리 (Image Gallery Section)
            _buildSectionTitle(
              context,
              '8. 엘니도 라군 갤러리',
              FontAwesomeIcons.lightImages,
            ),
            SizedBox(height: sp.s12),
            _buildImageGallery(context),

            SizedBox(height: sp.s24),

            /// 섹션 9: 1일 플랜 (One Day Plan Section)
            _buildSectionTitle(
              context,
              '9. 1일 플랜 (라군 최우선, 2인)',
              FontAwesomeIcons.lightCalendarDay,
            ),
            SizedBox(height: sp.s12),
            ..._oneDayPlan.map((item) => _buildScheduleCard(context, item)),

            SizedBox(height: sp.s16),

            /// 예약 전략 팁 (Booking Strategy Tips)
            _buildSubSectionTitle(context, '"라군 전용"을 진짜로 달성하는 예약 전략'),
            SizedBox(height: sp.s8),
            ..._bookingTips.map((item) => _buildInfoCard(context, item)),

            SizedBox(height: sp.s16),

            /// 주의사항 (Cautions)
            _buildSubSectionTitle(context, '주의사항'),
            SizedBox(height: sp.s8),
            ..._cautions.map((item) => _buildInfoCard(context, item)),

            /// 하단 여백 (Bottom padding)
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 섹션 제목 빌드 (Build section title)
  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(vertical: sp.s12, horizontal: sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(
            icon,
            size: 20,
            color: scheme.onPrimaryContainer,
          ),
          SizedBox(width: sp.s12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 서브 섹션 제목 빌드 (Build sub-section title)
  Widget _buildSubSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.s4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 정보 카드 빌드 (Build info card)
  Widget _buildInfoCard(BuildContext context, _InfoItem item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              item.icon,
              size: 16,
              color: scheme.onPrimaryContainer,
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
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 라군 카드 빌드 (Build lagoon card)
  Widget _buildLagoonCard(BuildContext context, _LagoonInfo lagoon) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: sp.s12),
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                lagoon.icon,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  lagoon.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            lagoon.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondaryContainer,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s8,
            ),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightStar,
                  size: 14,
                  color: scheme.onTertiaryContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    lagoon.highlight,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
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

  /// 투어 카드 빌드 (Build tour card)
  Widget _buildTourCard(BuildContext context, _TourCourse course) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                course.icon,
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
                  course.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  course.destinations,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  course.character,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 요금 카드 빌드 (Build fee card)
  Widget _buildFeeCard(BuildContext context, _FeeInfo fee) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(
              fee.icon,
              size: 16,
              color: scheme.onTertiaryContainer,
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
                        fee.type,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        fee.amount,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s4),
                Text(
                  fee.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 준비물 그리드 빌드 (Build preparation items grid)
  Widget _buildPrepItemsGrid(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Wrap(
      spacing: sp.s8,
      runSpacing: sp.s8,
      children: _prepItems.map((item) {
        return Container(
          width: (MediaQuery.of(context).size.width - sp.s16 * 2 - sp.s8) / 2,
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              FaIcon(
                item.icon,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      item.purpose,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

  /// 일정 카드 빌드 (Build schedule card)
  ///
  /// 1일 플랜의 각 일정 항목을 카드 형태로 표시합니다.
  /// Displays each schedule item of the 1-day plan as a card.
  Widget _buildScheduleCard(BuildContext context, _ScheduleItem item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      margin: EdgeInsets.only(bottom: sp.s12),
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        /// 하이라이트 항목은 secondaryContainer, 일반 항목은 surfaceContainerHighest
        /// Highlight items use secondaryContainer, normal items use surfaceContainerHighest
        color: item.isHighlight
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 시간대 및 아이콘 컬럼 (Time and icon column)
          Column(
            children: [
              /// 아이콘 박스 (Icon box)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.isHighlight
                      ? scheme.tertiaryContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    item.icon,
                    size: 18,
                    color: item.isHighlight
                        ? scheme.onTertiaryContainer
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ),
              SizedBox(height: sp.s8),

              /// 시간대 텍스트 (Time slot text)
              Text(
                item.time,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: item.isHighlight
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(width: sp.s12),

          /// 일정 내용 (Schedule content)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 일정 제목 (Schedule title)
                Text(
                  item.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: item.isHighlight
                        ? scheme.onSecondaryContainer
                        : null,
                  ),
                ),
                SizedBox(height: sp.s8),

                /// 일정 설명 (Schedule description)
                Text(
                  item.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: item.isHighlight
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 갤러리 빌드 (Build image gallery)
  ///
  /// 엘니도 라군 관련 이미지들을 가로 스크롤 갤러리로 표시합니다.
  /// Displays El Nido lagoon images as a horizontal scroll gallery.
  ///
  /// CloudFlare WAF를 우회하기 위해 User-Agent 헤더를 추가합니다.
  /// Adds User-Agent header to bypass CloudFlare WAF.
  Widget _buildImageGallery(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 디버깅: 이미지 갤러리 빌드 시작 로그 (Debug: Image gallery build start log)
    debugPrint('[DEBUG] _buildImageGallery: 이미지 갤러리 빌드 시작');
    debugPrint('[DEBUG] _buildImageGallery: 이미지 개수 = ${_galleryImages.length}');

    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _galleryImages.length,
        separatorBuilder: (context, index) => SizedBox(width: sp.s12),
        itemBuilder: (context, index) {
          final image = _galleryImages[index];

          /// 디버깅: 각 이미지 URL 로그 (Debug: Each image URL log)
          debugPrint('[DEBUG] _buildImageGallery: 이미지[$index] URL = ${image.url}');

          return Container(
            width: 280,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 이미지 (Image)
                /// CloudFlare WAF 우회를 위해 User-Agent 헤더 추가
                /// Added User-Agent header to bypass CloudFlare WAF
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    image.url,
                    height: 180,
                    width: 280,
                    fit: BoxFit.cover,

                    /// CloudFlare WAF 우회를 위한 HTTP 헤더
                    /// HTTP headers to bypass CloudFlare WAF
                    headers: const {
                      'User-Agent':
                          'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        /// 디버깅: 이미지 로딩 완료 (Debug: Image loading complete)
                        debugPrint(
                            '[DEBUG] _buildImageGallery: 이미지[$index] 로딩 완료');
                        return child;
                      }

                      /// 디버깅: 이미지 로딩 진행률 (Debug: Image loading progress)
                      final progress = loadingProgress.expectedTotalBytes != null
                          ? (loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes! *
                                  100)
                              .toStringAsFixed(1)
                          : '알 수 없음';
                      debugPrint(
                          '[DEBUG] _buildImageGallery: 이미지[$index] 로딩 중... $progress%');

                      return Container(
                        height: 180,
                        width: 280,
                        color: scheme.surfaceContainerHigh,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      /// 디버깅: 이미지 로딩 에러 (Debug: Image loading error)
                      debugPrint(
                          '[DEBUG] _buildImageGallery: 이미지[$index] 로딩 에러!');
                      debugPrint('[DEBUG] _buildImageGallery: 에러 = $error');
                      debugPrint(
                          '[DEBUG] _buildImageGallery: 스택트레이스 = $stackTrace');

                      return Container(
                        height: 180,
                        width: 280,
                        color: scheme.surfaceContainerHigh,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.lightImage,
                                size: 32,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 8),

                              /// 에러 메시지 표시 (Display error message)
                              Text(
                                '이미지 로드 실패',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// 이미지 설명 (Image description)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(sp.s12),
                    child: Text(
                      image.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
