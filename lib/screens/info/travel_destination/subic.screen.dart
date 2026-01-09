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

/// 관광지 정보 데이터 클래스 (Attraction Info Data Class)
///
/// 관광지의 이름, 위치, 설명, 특징 등을 담습니다.
/// Contains name, location, description, and features for attractions.
class _AttractionInfo {
  /// 명소 이름 (Attraction name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  /// 이동 정보 (Transport info)
  final String transportInfo;

  const _AttractionInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    required this.transportInfo,
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

/// 수빅 여행 정보 화면 (Subic Travel Screen)
///
/// 필리핀 수빅 및 클락 여행 정보를 제공합니다.
/// Provides travel information about Subic and Clark in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// SubicScreen.push(context);
/// ```
class SubicScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Subic';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const SubicScreen({super.key});

  @override
  State<SubicScreen> createState() => _SubicScreenState();
}

class _SubicScreenState extends State<SubicScreen> {
  /// 수빅 개요 정보 (Subic Overview Info)
  ///
  /// 수빅과 클락 지역의 기본 정보를 담고 있습니다.
  static const List<_InfoItem> _overviewInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치',
      description:
          '필리핀 루손 섬 중부에 위치한 수빅 베이(Subic Bay)와 클락(Clark) 자유구역 일대입니다. 과거 미군 해군기지와 공군기지였던 역사로 유명합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCar,
      title: '거리',
      description:
          '수빅과 클락은 고속도로(SCTEX)로 약 1시간 30분 정도 거리에 떨어져 있어 차량을 이용하면 손쉽게 왕복할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPlaneArrival,
      title: '접근성',
      description:
          '마닐라에서 버스로 2~3시간, 클락 국제공항에서 1시간 30분 거리입니다. 다양한 관광명소가 밀집한 인기 지역입니다.',
    ),
  ];

  /// 역사·문화 유적지 정보 (Historical & Cultural Sites)
  ///
  /// 스페인 게이트, 헬쉽 메모리얼, 박물관 등 역사적 명소 정보입니다.
  static const List<_AttractionInfo> _historicalSites = [
    _AttractionInfo(
      name: '스페인 게이트 (Spanish Gate)',
      description:
          '1885년에 건설된 옛 스페인 해군항의 서쪽 관문으로, 수빅의 스페인 식민지 시대 역사를 보여주는 중요 사적입니다. 스페인령 올롱가포 함대 기지의 일부였던 이 석조 게이트에는 당대 사용된 대포 2문이 양옆에 전시되어 있습니다.',
      features: [
        '1885년 건립된 스페인 해군항 유적',
        '양쪽에 대포 2문 전시',
        '무료 개방, 별도 허가 불필요',
      ],
      icon: FontAwesomeIcons.lightLandmark,
      transportInfo: '수빅 시내 중심에서 도보 이동 가능',
    ),
    _AttractionInfo(
      name: '헬쉽 메모리얼 (Hellships Memorial)',
      description:
          '제2차 세계대전 당시 일본군이 "지옥선(Hellships)"이라 불리던 포로 수송선에 태워 희생된 연합군 전쟁포로와 민간인들을 추모하는 기념비입니다. 바탄 전투 및 죽음의 행진과 연관된 역사적 사건도 함께 기리고 있습니다.',
      features: [
        '제2차 세계대전 희생자 추모 기념비',
        '희생자 이름이 새겨진 동판 설치',
        '일몰 경관이 아름다운 저녁 방문지',
      ],
      icon: FontAwesomeIcons.lightMonument,
      transportInfo: '수빅 시내에서 차량 5분 (~2km)',
    ),
    _AttractionInfo(
      name: '올롱가포 시 박물관',
      description:
          '올롱가포 시청 인근에 있는 작은 역사 박물관으로, 올롱가포와 수빅의 지역사 및 미군 주둔 시절 유물을 전시합니다. 도시의 형성과 발전 과정을 보여주는 사진, 유물, 자료를 통해 수빅의 군사기지 역사와 지역 문화를 배울 수 있습니다.',
      features: [
        '올롱가포 지역사 전시',
        '미군 주둔 시절 유물 보유',
        '규모는 작지만 교육적인 공간',
      ],
      icon: FontAwesomeIcons.lightBuildingColumns,
      transportInfo: '시내 중심에서 도보 또는 트라이시클',
    ),
    _AttractionInfo(
      name: '클락 박물관 & 4D 극장',
      description:
          '클락 자유구역 내에 위치한 현대적인 박물관으로, 선사시대부터 미군 공군기지 시절까지 클락 지역의 역사를 다룹니다. 유물과 사진, 디오라마를 통해 클락 비행장의 역할과 피나투보 화산 폭발 등 주요 사건들을 전시합니다.',
      features: [
        '선사시대~미군 기지 역사 전시',
        '4D 영화관에서 역사 다큐 상영',
        '피나투보 화산 폭발 관련 전시',
      ],
      icon: FontAwesomeIcons.lightFilm,
      transportInfo: '수빅에서 차량 약 75km, 1시간 30분 (SCTEX 경유)',
    ),
  ];

  /// 역사 문화 유적지 교통 테이블 (Historical Sites Transport Table)
  static const List<_TableRow> _historicalTransportTable = [
    _TableRow(columns: ['명소', '위치', '교통 방법'], isHeader: true),
    _TableRow(columns: ['스페인 게이트', '수빅 시내', '도보 또는 차량 5분']),
    _TableRow(columns: ['헬쉽 메모리얼', '수빅 해안', '택시/그랩 권장']),
    _TableRow(columns: ['올롱가포 박물관', '수빅 시내', '도보 또는 트라이시클']),
    _TableRow(columns: ['클락 박물관', '클락', '승용차/그랩 (고속도로)']),
  ];

  /// 쇼핑 정보 (Shopping Info)
  ///
  /// 하버 포인트 몰, 로얄 듀티프리, SM 시티 클락 등 쇼핑 명소 정보입니다.
  static const List<_InfoItem> _shoppingInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCartShopping,
      title: '하버 포인트 몰 (Harbor Point Mall)',
      description:
          '수빅 자유구역 중심에 위치한 대형 쇼핑몰로, 아얄라(Ayala) 재단이 운영합니다. 탁 트인 개방형 구조로 바닷바람을 느끼며 쇼핑 가능합니다. 한식당 등 한국인을 위한 음식점도 입점해 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGift,
      title: '로얄 듀티프리 숍 (Royal Duty Free)',
      description:
          '수빅 자유구역을 대표하는 면세형 쇼핑센터입니다. 초콜릿, 주류, 향수, 의류 등 해외 브랜드 상품을 시중보다 저렴한 면세가격으로 판매합니다. "수빅 여행 시 꼭 들러야 할 쇼핑 코스"로 꼽힙니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBagShopping,
      title: 'SM 시티 클락 (SM City Clark)',
      description:
          '클락 자유구역 인근(앙헬레스 시)에 있는 대형 쇼핑몰로, 필리핀 SM그룹이 운영하는 클락 지역 최대의 쇼핑센터입니다. 수백개의 패션 매장과 식당가, 슈퍼마켓, 영화관 등을 갖추고 있습니다.',
    ),
  ];

  /// 쇼핑 교통 테이블 (Shopping Transport Table)
  static const List<_TableRow> _shoppingTransportTable = [
    _TableRow(columns: ['장소', '위치', '교통 편의'], isHeader: true),
    _TableRow(columns: ['하버 포인트 몰', '수빅 중심', '도보 가능, 택시/그랩 용이']),
    _TableRow(columns: ['로얄 듀티프리', '수빅', '택시/그랩 (차로 10분)']),
    _TableRow(columns: ['SM 시티 클락', '클락 인근', '승용차/그랩 (차로 80분)']),
  ];

  /// 자연 및 해변 관광지 정보 (Nature & Beach Info)
  ///
  /// 카마얀 비치, 인플레이터블 아일랜드, 둥가리 해변, 파무락라킨 숲길, 피나투보 화산 정보입니다.
  static const List<_AttractionInfo> _natureSites = [
    _AttractionInfo(
      name: '카마얀 비치 (Camayan Beach)',
      description:
          '수빅 만 서남쪽 이라닌 숲 보호구역 해안에 자리한 아름다운 백사장 해변입니다. 맑고 깨끗한 바다와 흰 모래로 유명해 현지인 휴양객도 많이 찾습니다. 바다거북 서식지 보호 활동으로도 알려져 있습니다.',
      features: [
        '깨끗한 백사장과 맑은 바다',
        '바다 수심이 완만하여 가족에게 적합',
        '스노클링 장비 대여 가능',
        '바다거북 서식지 보호 활동',
      ],
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      transportInfo: '수빅 시내에서 차량 약 15km, 25분 소요',
    ),
    _AttractionInfo(
      name: '인플레이터블 아일랜드 (Inflatable Island)',
      description:
          '올롱가포 시 해변에 조성된 대형 해상 물놀이 공원입니다. 약 4,200㎡ 규모로 아시아 최대 규모의 플로팅 놀이공원으로 알려져 있으며, 바다 위에 떠있는 다양한 에어바운스 미끄럼틀, 다리, 점프대 등이 설치되어 있습니다.',
      features: [
        '아시아 최대 규모 플로팅 놀이공원',
        '유니콘 테마 디자인',
        '인생샷 촬영 명소',
        '인근 비치클럽과 카페',
      ],
      icon: FontAwesomeIcons.lightWater,
      transportInfo: '수빅 시내에서 차량 5km, 10분 소요',
    ),
    _AttractionInfo(
      name: '둥가리 해변 (Dungaree Beach)',
      description:
          '수빅 자유구역 내에 위치한 한적한 해변으로, 미군 시절 "조개 해변"으로 불리던 곳입니다. 에메랄드빛 바다와 곱고 흰 모래사장이 펼쳐져 있고, 열대 분위기의 작은 정자(나무 파빌리온)가 늘어서 있습니다.',
      features: [
        '에메랄드빛 바다와 흰 모래사장',
        '열대 분위기의 파빌리온',
        '한적한 분위기로 휴식에 적합',
        '탈의실, 그늘막 등 편의시설',
      ],
      icon: FontAwesomeIcons.lightSun,
      transportInfo: '시내에서 차량 8km, 15분 (입장료 PHP50~100)',
    ),
    _AttractionInfo(
      name: '파무락라킨 숲길 (Pamulaklakin Forest Trail)',
      description:
          '수빅 비닉티칸 지역에 조성된 열대우림 트레킹 코스입니다. 미군 시절 정글 생존 훈련장으로 사용된 깊은 숲으로, 현지 원주민인 아에타(Aeta)족 가이드와 함께 밀림 속을 걸으며 생존 기술 시연을 관람할 수 있습니다.',
      features: [
        '열대우림 트레킹 코스',
        '아에타족 가이드 동반 에코투어',
        '식생과 약초 학습 가능',
        '30분~3시간 코스 선택 가능',
      ],
      icon: FontAwesomeIcons.lightTree,
      transportInfo: '시내에서 차량 7km, 15분 (가이드 동반 권장)',
    ),
    _AttractionInfo(
      name: '피나투보 화산 (Mt. Pinatubo)',
      description:
          '클락 북서쪽에 위치한 해발 1,486m의 활화산입니다. 1991년 역사적인 대분화를 일으킨 이후 화산 정상 분화구에 에메랄드빛 호수가 형성되어 있습니다. 4x4 지프를 타고 라하르 지대를 달린 뒤 도보로 20~30분 등정하면 분화구 호수에 도착합니다.',
      features: [
        '에메랄드빛 칼데라 호수 경치',
        '4x4 지프 어드벤처',
        '비교적 수월한 산행',
        '전문 투어 이용 권장',
      ],
      icon: FontAwesomeIcons.lightMountain,
      transportInfo: '수빅 출발 시 차량 약 2시간 소요 (클락 경유)',
    ),
  ];

  /// 자연 관광지 교통 테이블 (Nature Sites Transport Table)
  static const List<_TableRow> _natureTransportTable = [
    _TableRow(columns: ['관광지', '이동 시간', '교통 특이사항'], isHeader: true),
    _TableRow(columns: ['카마얀 비치', '약 25분', '택시/그랩, 리조트 입장료']),
    _TableRow(columns: ['인플레이터블 아일랜드', '약 10분', '택시/그랩 또는 지프니']),
    _TableRow(columns: ['둥가리 해변', '약 15분', '택시/그랩, 입장료 있음']),
    _TableRow(columns: ['파무락라킨 숲길', '약 15분', '택시/그랩, 가이드 권장']),
    _TableRow(columns: ['피나투보 화산', '약 2시간', '전문 투어 이용 권장']),
  ];

  /// 가족/어린이 관광지 정보 (Family & Kids Info)
  ///
  /// 주빅 사파리, 오션 어드벤처 등 가족 여행 명소 정보입니다.
  static const List<_AttractionInfo> _familySites = [
    _AttractionInfo(
      name: '주빅 사파리 (Zoobic Safari)',
      description:
          '수빅을 대표하는 대형 야생동물 테마파크로, 필리핀 유일의 호랑이 사파리를 갖추고 있습니다. 25헥타르에 달하는 울창한 정글 속에서 사파리 지프를 타고 백호와 시베리아호랑이 등을 가까이에서 관찰할 수 있습니다.',
      features: [
        '필리핀 유일의 호랑이 사파리',
        '사파리 지프 투어',
        '악어 호수(Croco Loco), 뱀 전시관',
        '동물 먹이주기 체험',
      ],
      icon: FontAwesomeIcons.lightPaw,
      transportInfo: '수빅 시내에서 차량 약 20km, 30분 소요',
    ),
    _AttractionInfo(
      name: '오션 어드벤처 (Ocean Adventure)',
      description:
          '수빅 만 해양공원으로, 동남아시아 최초의 개방형 바다 수족관 테마파크입니다. 돌고래와 바다사자 쇼를 관람할 수 있으며, 열대어 수족관, 바다거북 보호센터, 새공원 등 다양한 해양 생물 체험 시설이 갖춰져 있습니다.',
      features: [
        '돌고래 & 바다사자 쇼',
        '돌고래와 함께 수영 체험',
        '열대어 수족관, 바다거북 보호센터',
        'JEST 캠프 곤충관, 나비농장',
      ],
      icon: FontAwesomeIcons.lightFish,
      transportInfo: '수빅 시내에서 차량 약 18km, 25분 소요',
    ),
    _AttractionInfo(
      name: '판타스틱 공원 (Funtastic Park)',
      description:
          '수빅 Ilanin 숲동지역에 위치한 실내 가족 오락공원입니다. 거울미로, 트릭아트관, 3D 착시의 숲 정원, 과학 체험존 등 어린이들을 위한 체험거리가 다양하게 마련되어 있습니다.',
      features: [
        '거울미로, 트릭아트관',
        '3D 착시의 숲 정원',
        '야외 미로 정원과 잔디 썰매장',
        '날씨와 무관하게 즐길 수 있음',
      ],
      icon: FontAwesomeIcons.lightFerrisWheel,
      transportInfo: '수빅 시내에서 차량 20분 소요',
    ),
    _AttractionInfo(
      name: '클락 사파리 & 어드벤처 파크',
      description:
          '2021년 개장한 클락의 신규 관광지로, 1500마리 이상의 동물을 보유한 대형 야생동물원입니다. 사자, 호랑이, 기린 등 대형 포유류부터 앵무새, 파충류까지 다양한 종을 전시합니다.',
      features: [
        '1500마리 이상의 동물 보유',
        '사자, 호랑이, 기린 등 대형 포유류',
        '먹이주기와 사진 촬영 가능',
        '사파리 투어 차량 운행',
      ],
      icon: FontAwesomeIcons.lightHippo,
      transportInfo: '수빅에서 차량 약 80km, 1시간 30분 소요',
    ),
    _AttractionInfo(
      name: '아쿠아 플래닛 (Aqua Planet)',
      description:
          '클락 자유구역에 위치한 필리핀 최대 규모 워터파크입니다. 10헥타르 부지에 워터슬라이드 38개를 비롯한 각종 물놀이 시설을 갖추고 있어 하루종일 물놀이를 즐길 수 있습니다.',
      features: [
        '필리핀 최대 규모 워터파크',
        '38개 워터슬라이드',
        '파도풀, 유수풀, 키즈풀',
        '토네이도 슬라이드 등 스릴 시설',
      ],
      icon: FontAwesomeIcons.lightPersonSwimming,
      transportInfo: '수빅에서 차량 약 85km, 1시간 40분 소요',
    ),
    _AttractionInfo(
      name: '다이너소어 아일랜드 (Dinosaurs Island)',
      description:
          '클락의 고생물 테마파크로, 실제 크기의 움직이는 공룡 모형들이 전시되어 있습니다. 숲 속 산책로를 따라 티라노사우루스, 트리케라톱스 등 다양한 공룡 로봇이 배치되어 있습니다.',
      features: [
        '실제 크기 움직이는 공룡 모형',
        '숲 속 공룡 산책로',
        '공룡 라이브 쇼',
        '4D 공룡 라이더',
      ],
      icon: FontAwesomeIcons.lightDragon,
      transportInfo: '수빅에서 차량 약 75km, 1시간 30분 소요',
    ),
    _AttractionInfo(
      name: '주코비아 펀 줌 (Zoocobia Fun Zoo)',
      description:
          '클락 인근의 어린이 동물농장 테마파크로, 작은 동물원을 기반으로 각종 놀이시설을 결합한 곳입니다. 토끼, 염소 등의 먹이주기 체험과 그래비티 카트(Zoop Ride) 체험이 인기입니다.',
      features: [
        '토끼, 염소 먹이주기 체험',
        '그래비티 카트(Zoop Ride)',
        '열대조류 쇼',
        '저렴한 입장료',
      ],
      icon: FontAwesomeIcons.lightRabbit,
      transportInfo: '수빅에서 차량 약 80km, 1시간 40분 소요',
    ),
  ];

  /// 가족 관광지 교통 테이블 (Family Sites Transport Table)
  static const List<_TableRow> _familyTransportTable = [
    _TableRow(columns: ['명소', '특징', '교통'], isHeader: true),
    _TableRow(columns: ['주빅 사파리', '호랑이 사파리', '차량 30분, 택시/전세']),
    _TableRow(columns: ['오션 어드벤처', '돌고래 쇼', '차량 25분, 택시/전세']),
    _TableRow(columns: ['판타스틱 공원', '실내 놀이관', '차량 20분, 택시/그랩']),
    _TableRow(columns: ['클락 사파리', '대형 동물원', '차량 90분, 자가용/전세']),
    _TableRow(columns: ['아쿠아 플래닛', '워터파크', '차량 100분, 자가용/전세']),
    _TableRow(columns: ['다이너소어 아일랜드', '공룡 테마', '차량 90분, 자가용/전세']),
  ];

  /// 액티비티 정보 (Activity Info)
  ///
  /// 스쿠버 다이빙, 해양 스포츠, 정글 생존 체험 등 액티비티 정보입니다.
  static const List<_ActivityInfo> _activityInfo = [
    _ActivityInfo(
      name: '스쿠버 다이빙',
      location: '수빅 만',
      note: '난파선 다이빙 명소',
      icon: FontAwesomeIcons.lightMaskSnorkel,
    ),
    _ActivityInfo(
      name: '제트스키',
      location: '수빅 비치',
      note: '즉석 이용 가능',
      icon: FontAwesomeIcons.lightWaterLadder,
    ),
    _ActivityInfo(
      name: '패러세일링',
      location: '수빅 비치',
      note: '기상 영향 있음',
      icon: FontAwesomeIcons.lightCloudArrowUp,
    ),
    _ActivityInfo(
      name: '정글 생존 체험',
      location: 'JEST Camp',
      note: '반나절~3일 코스',
      icon: FontAwesomeIcons.lightCampground,
    ),
    _ActivityInfo(
      name: '승마 체험',
      location: 'El Kabayo',
      note: '초보자 가능',
      icon: FontAwesomeIcons.lightHorse,
    ),
    _ActivityInfo(
      name: '퓨닝 온천',
      location: '클락 인근',
      note: '투어 예약 필수',
      icon: FontAwesomeIcons.lightHotTubPerson,
    ),
    _ActivityInfo(
      name: '요트 크루즈',
      location: '수빅 만',
      note: '선셋 세일링',
      icon: FontAwesomeIcons.lightSailboat,
    ),
    _ActivityInfo(
      name: '열기구 페스티벌',
      location: '클락',
      note: '매년 2월',
      icon: FontAwesomeIcons.lightCloudArrowUp,
    ),
  ];

  /// 액티비티 상세 정보 (Activity Detail Info)
  ///
  /// 주요 액티비티에 대한 상세 설명입니다.
  static const List<_InfoItem> _activityDetailInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMaskSnorkel,
      title: '스쿠버 다이빙',
      description:
          '수빅만은 필리핀 유수의 난파선 다이빙 명소로 유명합니다. 스페인-미국전쟁부터 2차대전, 베트남전 시기의 침몰 군함 등 25개 이상의 난파선 포인트가 산재해 있습니다. 11~5월 건기에 비교적 양호한 시야에서 다이빙을 즐길 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCampground,
      title: '정글 생존 체험 (JEST Camp)',
      description:
          '과거 미군 정글 생존 훈련 과정을 관광객 체험 프로그램으로 운영합니다. 반나절짜리 기본 생존기술 강습부터 3일짜리 부트캠프까지 선택 가능합니다. 밀림에서 식량 구하기, 물 얻기, 함정 설치법 등을 배울 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHorse,
      title: '승마 체험 (El Kabayo)',
      description:
          '엘 카바요 마장에서 숲속 트레일 코스를 말을 타고 둘러보는 승마 체험을 제공합니다. 30분~1시간 코스로 열대 정글 속을 가이드와 함께 산책합니다. 요금은 코스에 따라 ₱350~₱3,000 수준입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHotTubPerson,
      title: '퓨닝 온천 (Puning Hot Spring)',
      description:
          '클락 인근 아라우이산 자락의 라하르 지대에 자리한 이색 온천 스파입니다. 4x4 지프로만 접근 가능한 계곡에서 천연 온천수 풀장과 화산재 머드팩 마사지를 즐길 수 있습니다. 사전 온천+차량 패키지 투어 예약이 필수입니다.',
    ),
  ];

  /// 교통 정보 (Transport Info)
  ///
  /// 그랩 택시, 지프니, 버스, 고속도로 등 교통 정보입니다.
  static const List<_InfoItem> _transportInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMobileScreen,
      title: '그랩 (Grab) 택시',
      description:
          '수빅과 클락 지역 모두 Grab 앱을 통한 차량 호출 서비스가 이용 가능합니다. 수빅 올롱가포 시내에서는 그랩이나 노란색 미터택시를 쉽게 잡을 수 있습니다. 장거리 이동은 전세 차량이나 투어 이용을 권장합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightVanShuttle,
      title: '지프니·버스',
      description:
          '올롱가포 시내에서 파란 지프니가 주요 노선을 운행합니다. 요금은 ₱10~15로 저렴하지만 배차 간격이 일정치 않습니다. 수빅 내부 관광지(SBMA 지역)는 지프니 노선이 없어 택시/그랩이 유일한 대중교통입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBus,
      title: '장거리 버스',
      description:
          '마닐라에서 수빅으로 빅토리 라이너 등이 매일 운행하며 2~3시간 소요됩니다. 올롱가포→클락(도우) 버스는 약 1시간 30분, 요금 ₱150~200입니다. 막차 시간(오후 5~6시)을 유념하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRoad,
      title: '고속도로 (SCTEX)',
      description:
          '자가용이나 전세 차량으로 수빅-클락을 이동할 경우 SCTEX를 이용하면 약 1시간 20분으로 가장 빠릅니다. 톨게이트 비용은 편도 ₱350~400 정도입니다. 국도 이용 시 3시간 이상 걸립니다.',
    ),
  ];

  /// 참고 사항 (Notes)
  ///
  /// 수빅 여행 시 알아두면 좋은 참고 사항입니다.
  static const List<_InfoItem> _notesInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '이동 시간 고려',
      description:
          '클락 소재 관광지는 수빅에서 차량 이동 시 약 1~2시간 소요되므로 일정 계획 시 참고하세요. 당일 왕복 시 이동 시간을 충분히 확보해야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '사전 예약 권장',
      description:
          '피나투보 화산 투어, 퓨닝 온천, 클락 사파리 등 일부 관광지는 사전 예약이 필요합니다. 특히 성수기에는 미리 예약하는 것이 좋습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSunCloud,
      title: '날씨 확인',
      description:
          '해양 스포츠와 야외 액티비티는 기상 영향을 받습니다. 우기(6~10월)에는 일부 투어가 취소될 수 있으니 날씨를 확인하세요.',
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
              FontAwesomeIcons.lightAnchor,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationSubic),
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
              emoji: '⚓',
              title: '수빅 & 클락 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _overviewInfo, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [역사·문화 섹션 - Historical Section]
            _buildSectionHeader(
              context,
              emoji: '🏛️',
              title: '역사·문화 유적지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _historicalSites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '교통 정보'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _historicalTransportTable),

            SizedBox(height: sp.s24),

            /// [쇼핑 섹션 - Shopping Section]
            _buildSectionHeader(
              context,
              emoji: '🛍️',
              title: '쇼핑 및 도심 관광',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _shoppingInfo, scheme.tertiaryContainer),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '쇼핑 교통 정보'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _shoppingTransportTable),

            SizedBox(height: sp.s24),

            /// [자연 섹션 - Nature Section]
            _buildSectionHeader(
              context,
              emoji: '🌴',
              title: '자연 및 해변 관광',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _natureSites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '교통 정보'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _natureTransportTable),

            SizedBox(height: sp.s24),

            /// [가족 섹션 - Family Section]
            _buildSectionHeader(
              context,
              emoji: '🎡',
              title: '가족/어린이 관광',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _familySites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '가족 관광지 교통 정보'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _familyTransportTable),

            SizedBox(height: sp.s24),

            /// [액티비티 섹션 - Activity Section]
            _buildSectionHeader(
              context,
              emoji: '🤿',
              title: '기타 액티비티',
            ),
            SizedBox(height: sp.s12),
            _buildActivityGrid(context),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '액티비티 상세'),
            SizedBox(height: sp.s8),
            _buildInfoCards(
                context, _activityDetailInfo, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [교통 섹션 - Transport Section]
            _buildSectionHeader(
              context,
              emoji: '🚕',
              title: '교통 정보',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _transportInfo, scheme.surfaceContainerHighest),

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

            /// [마무리 요약 섹션 - Summary Section]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  ///
  /// 화면 상단에 표시되는 메인 배너 위젯입니다.
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
                '⚓',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🏝️',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 수빅 & 클락\n여행 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '미군기지 역사와 사파리, 해변, 다양한 액티비티의 천국',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  ///
  /// 각 섹션의 제목을 이모지와 함께 표시합니다.
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
  ///
  /// 섹션 내 하위 제목을 표시합니다.
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
  ///
  /// 아이콘, 제목, 설명이 포함된 정보 카드 목록을 생성합니다.
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
                      style: theme.textTheme.bodySmall?.copyWith(
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

  /// 관광지 카드 빌드 (Build attraction cards)
  ///
  /// 관광지 정보를 포함한 확장 카드 목록을 생성합니다.
  Widget _buildAttractionCards(
      BuildContext context, List<_AttractionInfo> sites) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: sites.map((site) {
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
                        site.icon,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      site.name,
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
                site.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sp.s12),
              ...site.features.map((feature) {
                return Padding(
                  padding: EdgeInsets.only(bottom: sp.s4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(height: sp.s8),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s8,
                  vertical: sp.s4,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightLocationDot,
                      size: 12,
                      color: scheme.onSecondaryContainer,
                    ),
                    SizedBox(width: sp.s4),
                    Flexible(
                      child: Text(
                        site.transportInfo,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSecondaryContainer,
                        ),
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
  ///
  /// 표 형식의 정보를 표시합니다.
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

  /// 액티비티 그리드 빌드 (Build activity grid)
  ///
  /// 액티비티 정보를 그리드 형태로 표시합니다.
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
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                activity.note,
                style: theme.textTheme.bodySmall?.copyWith(
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
  ///
  /// 주의사항 및 참고 정보를 강조하여 표시합니다.
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
                        style: theme.textTheme.bodySmall?.copyWith(
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

  /// 마무리 요약 섹션 빌드 (Build summary section)
  ///
  /// 주요 정보를 요약하여 표시합니다.
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '과거 미군 해군/공군기지였던 역사적 지역',
      '수빅-클락 고속도로(SCTEX)로 1시간 30분 거리',
      '주빅 사파리 - 필리핀 유일의 호랑이 사파리',
      '난파선 스쿠버 다이빙 명소 (25개+ 포인트)',
      '아쿠아 플래닛 - 필리핀 최대 워터파크',
      '피나투보 화산 트레킹 & 퓨닝 온천',
      '그랩/택시로 시내 이동, 클락은 전세 차량 권장',
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
                '⚓',
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
