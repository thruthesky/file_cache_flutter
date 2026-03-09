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

/// 명소 정보 데이터 클래스 (Attraction Info Data Class)
///
/// 각 관광 명소의 상세 정보를 담습니다.
/// Contains detailed information for each tourist attraction.
class _AttractionInfo {
  /// 명소 이름 (Attraction name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  /// 교통 정보 (Transportation info)
  final String? transportInfo;

  /// 입장료 정보 (Admission fee info)
  final String? admissionInfo;

  const _AttractionInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    this.transportInfo,
    this.admissionInfo,
  });
}

/// 일정 아이템 데이터 클래스 (Schedule Item Data Class)
///
/// 추천 일정의 각 단계를 담습니다.
/// Contains each step of the recommended itinerary.
class _ScheduleItem {
  /// 시간 (Time)
  final String time;

  /// 활동 내용 (Activity)
  final String activity;

  /// 아이콘 (Icon)
  final IconData icon;

  const _ScheduleItem({
    required this.time,
    required this.activity,
    required this.icon,
  });
}

/// 보홀 여행 정보 화면 (Bohol Travel Screen)
///
/// 세부에서 보홀 당일치기 여행 가이드를 제공합니다.
/// Provides a day-trip travel guide from Cebu to Bohol.
///
/// ### 사용법 (Usage):
/// ```dart
/// BoholScreen.push(context);
/// ```
class BoholScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Bohol';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const BoholScreen({super.key});

  @override
  State<BoholScreen> createState() => _BoholScreenState();
}

class _BoholScreenState extends State<BoholScreen> {
  /// 세부→보홀 이동 개요 정보 (Cebu to Bohol Transportation Overview)
  ///
  /// 페리 이동에 대한 기본 정보입니다.
  static const List<_InfoItem> _transportOverview = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShip,
      title: '고속 페리',
      description:
          '세부 Pier 1에서 보홀 탁빌라란항까지 약 2시간 소요. 오션젯(OceanJet) 첫배 06:00, 막배 17:40. 매일 10편 이상 운항하여 당일치기 일정에 적합합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '운임 및 예약',
      description:
          '투어리스트 클래스 편도 ₱800, 비즈니스 클래스 ₱1,200. 성수기에는 사전 예약을 권장하며, 온라인 예매 시 대기줄 생략 가능합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCircleInfo,
      title: '탑승 수속',
      description:
          '출발 30분~1시간 전 터미널 도착 권장. 터미널 이용료 세부 ₱25, 보홀 ₱20 현금 납부. 수화물 15kg까지 무료, 24인치 이상 가방은 추가 요금 약 ₱100.',
    ),
  ];

  /// 세부-보홀 교통편 요금 테이블 (Transportation Fee Table)
  static const List<_TableRow> _transportTable = [
    _TableRow(
        columns: ['교통편', '소요시간', '요금(편도)', '비고'], isHeader: true),
    _TableRow(columns: [
      '오션젯\n고속페리',
      '약 2시간',
      '₱800 투어리스트\n₱1,200 비즈니스',
      '첫배 06:00\n막배 17:40',
    ]),
    _TableRow(columns: [
      '수퍼캣\n페리',
      '약 2시간',
      '₱900 투어리스트\n₱1,350 비즈니스',
      '첫배 08:00\n막배 17:00',
    ]),
    _TableRow(columns: [
      '라이트페리\n(RORO)',
      '약 4시간',
      '₱370 이코노미\n₱520 투어리스트',
      '차량동반 가능\n일부시간대 운항',
    ]),
    _TableRow(columns: [
      '터미널\n이용료',
      '-',
      '세부 ₱25\n보홀 ₱20',
      '현금 납부\n12세 이하 무료',
    ]),
  ];

  /// 역사/문화 유적지 정보 (Historical & Cultural Sites)
  static const List<_AttractionInfo> _historicalSites = [
    _AttractionInfo(
      name: '바클라욘 교회 (Baclayon Church)',
      description:
          '1596년 예수회 선교사들에 의해 설립되고 1727년에 완공된 필리핀에서 손꼽히게 오래된 스페인식 석조 성당입니다. 두께 1미터가 넘는 산호석 벽과 고풍스러운 종탑 등 원형이 잘 보존되어 1994년 필리핀 국가문화재로 지정되었습니다.',
      features: [
        '18세기 파이프 오르간과 금박 제단',
        '성인(聖人)들의 유물 전시',
        '부속 박물관에서 식민시대 유물 관람 가능',
        '미사 시간 외 자유 관람',
      ],
      icon: FontAwesomeIcons.lightChurch,
      transportInfo: '탁빌라란 시내에서 남동쪽 약 6km, 차량 15분 내외',
      admissionInfo: '입장 무료 (박물관 관람 시 ₱50)',
    ),
    _AttractionInfo(
      name: '혈맹 기념비 (Blood Compact Shrine)',
      description:
          '1565년 스페인 미겔 로페스 데 레가스피 장군과 보홀 다투 시카투나가 피를 나누며 동맹을 맺은 필리핀 최초의 국제조약(혈맹)을 기념한 동상입니다. 스페인과 필리핀 원주민 간의 우호를 상징하는 역사적 장소입니다.',
      features: [
        '다섯 명의 인물이 잔을 높이 든 청동 조각상',
        '바다를 배경으로 한 포토존',
        '주변 노점상에서 기념품과 간식 판매',
        '바클라욘 교회 방향 도로변 위치',
      ],
      icon: FontAwesomeIcons.lightHandshake,
      transportInfo: '탁빌라란항에서 약 3km, 차량 10분 이내',
      admissionInfo: '입장 무료',
    ),
  ];

  /// 자연/해변 관광지 정보 (Nature & Beach Attractions)
  static const List<_AttractionInfo> _natureSites = [
    _AttractionInfo(
      name: '초콜릿 힐 (Chocolate Hills)',
      description:
          '보홀 여행의 백미로 꼽히는 경이로운 자연 풍경입니다. 보홀 내륙에 무려 1,268개 이상의 원형 언덕들이 끝없이 펼쳐지며, 건기(1~5월)에 잔디가 말라 갈색으로 변해 거대한 초콜릿을 연상시킵니다. 필리핀 국가지질기념물로 지정된 보홀의 상징입니다.',
      features: [
        '높이 30~50m 규모의 1,268개 석회암 언덕',
        '카르멘(Carmen) 지역 전망대에서 파노라마 조망',
        'ATV 사륜오토바이 투어 인기',
        '건기에는 초콜릿색, 우기에는 녹색',
      ],
      icon: FontAwesomeIcons.lightMountain,
      transportInfo: '탁빌라란에서 동북쪽 약 50km, 차량 1시간~1시간 30분 소요',
      admissionInfo: '전망대 입장료 ₱150 (2025년 인상)',
    ),
    _AttractionInfo(
      name: '팡라오 섬 & 알로나 비치 (Panglao Island)',
      description:
          '보홀 본섬 남서쪽에 다리로 연결된 작은 섬으로, 에메랄드빛 바다와 백사장 해변이 펼쳐진 휴양지입니다. 알로나 비치는 약 1.5km 길이의 하얀 모래사장이 야자수와 어우러져 이국적인 정취를 자아냅니다.',
      features: [
        '리조트, 레스토랑, 다이빙 숍 밀집',
        '저녁 해변가 노천 식당과 라이브 음악',
        '두말루안 비치, 돌조 비치 등 한적한 해변도 인근',
        '호핑투어, 스노클링, 다이빙 출발지',
      ],
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      transportInfo: '탁빌라란항에서 약 20km, 차량 30~40분 소요',
      admissionInfo: '해변 입장 무료',
    ),
    _AttractionInfo(
      name: '히나그다난 동굴 (Hinagdanan Cave)',
      description:
          '팡라오 섬 다우이스(Dauis) 지역에 위치한 자연 석회암 동굴입니다. 천장 틈 사이로 햇빛이 들어와 에메랄드빛 지하 호수를 환하게 비추는 비경으로 유명합니다. 동굴 이름은 세부어로 "사다리로 내려가는"이라는 뜻입니다.',
      features: [
        '종유석(stalactite)과 석순(stalagmite) 지형',
        '맑은 지하 호수에서 수영 가능',
        '가이드 동행 안내',
        '동굴 밖 기념품 상점과 카페',
      ],
      icon: FontAwesomeIcons.lightWater,
      transportInfo: '알로나 비치에서 약 12km, 차량 20분 (탁빌라란에서 30분)',
      admissionInfo: '입장료 ₱50, 수영 이용료 추가 ₱75',
    ),
  ];

  /// 쇼핑/시내 관광지 정보 (Shopping & City Attractions)
  static const List<_AttractionInfo> _shoppingSites = [
    _AttractionInfo(
      name: '탁빌라란 시장 (Tagbilaran Central Public Market)',
      description:
          '보홀 주민들의 일상 생활을 느낄 수 있는 전통 재래시장입니다. 각종 신선한 농산물과 해산물, 건어물부터 남국 과일, 향신료 등이 가득하며 현지 간식과 기념품도 구매할 수 있습니다.',
      features: [
        '칼라마이(Kalamay) - 코코넛과 쌀로 만든 달콤한 엿',
        '피넛 키세스(Peanut Kisses) - 초콜릿 힐 모양 땅콩과자',
        'Broas - 행운을 기원하는 생쥐모양 쿠키',
        '채소·수산·잡화 코너 구분, 비교적 깨끗하게 관리',
      ],
      icon: FontAwesomeIcons.lightStore,
      transportInfo: '탁빌라란항에서 차량 5~10분, 트라이시클로 접근 용이',
      admissionInfo: '입장 무료 (현금 준비 필요)',
    ),
  ];

  /// 가족/어린이 관광지 정보 (Family & Kids Attractions)
  static const List<_AttractionInfo> _familySites = [
    _AttractionInfo(
      name: '로복 강 선상뷔페 (Loboc River Cruise)',
      description:
          '보홀 여행에서 가족 단위로 인기가 높은 선상 뷔페 크루즈입니다. 잔잔한 강 위에서 대형 방카선을 타고 열대 우림 경관을 감상하며 현지식 뷔페 식사를 즐길 수 있습니다.',
      features: [
        '약 1시간 동안 현지 라이브 밴드 음악 공연',
        '원주민 마을 전통 대나무댄스 공연 관람',
        '어린이부터 어르신까지 함께 즐기기 좋음',
        '11시~14시 사이 런치 크루즈 집중',
      ],
      icon: FontAwesomeIcons.lightSailboat,
      transportInfo: '탁빌라란에서 동쪽 약 25km, 차량 40분 (초콜릿 힐 방면 경유)',
      admissionInfo: '1인 ₱1,000 내외 (점심 식사 포함)',
    ),
    _AttractionInfo(
      name: '안경원숭이 보호구역 (Tarsier Sanctuary)',
      description:
          '세계에서 가장 작은 영장류 중 하나인 필리핀 안경원숭이(타르시어)를 가까이에서 관찰할 수 있는 곳입니다. 몸길이 10cm 남짓에 큰 눈과 긴 꼬리가 특징이며 야행성이어서 낮에는 나뭇가지에 붙어 졸고 있습니다.',
      features: [
        '자연에 가까운 환경에서 타르시어 보호',
        '지정된 산책로를 따라 숲속 관람',
        '입장 전 영상 교육으로 관람 수칙 안내',
        '플래시·큰소리·접촉 금지 (스트레스에 민감)',
      ],
      icon: FontAwesomeIcons.lightMonkey,
      transportInfo: '탁빌라란에서 약 20km, 차량 30~40분 (로복~초콜릿힐 경유)',
      admissionInfo: '입장료 ₱80 (12세 이하 무료 또는 할인)',
    ),
  ];

  /// 기타 액티비티 정보 (Other Activities)
  static const List<_AttractionInfo> _activities = [
    _AttractionInfo(
      name: '스노클링 & 아일랜드 호핑',
      description:
          '보홀 인근 바다는 해양 생태계가 풍부하여 스노클링이나 다이빙을 하기에 좋습니다. 팡라오 섬 앞바다의 발리카삭 섬(Balicasag)은 산호 정원과 바다거북 서식지로 유명합니다.',
      features: [
        '새벽 돌핀 와칭 + 발리카삭 스노클링 + 버진아일랜드 코스',
        '호핑투어 1인 ₱1,000~1,500 (장비 대여 별도)',
        '체험 다이빙 1인 ₱3,500~5,000 (장비 포함)',
        '당일치기로 다이빙까지 소화하려면 일정 빠듯함',
      ],
      icon: FontAwesomeIcons.lightMaskSnorkel,
      transportInfo: '알로나 비치에서 보트로 출발',
    ),
    _AttractionInfo(
      name: 'ATV 투어 & 어드벤처',
      description:
          '초콜릿 힐 주변에서 즐기는 ATV(All-Terrain Vehicle) 사륜 오토바이 체험은 젊은 여행자들 사이에 인기만점입니다. 울퉁불퉁한 오프로드를 달리며 초콜릿 힐의 장관을 색다르게 감상할 수 있습니다.',
      features: [
        'ATV 1시간 코스 약 ₱900~1,000',
        '2인용 버기카 ₱1,500 (2인 합계)',
        '집라인, 케이블카 체험 (로복 강 상공)',
        '초콜릿 힐 어드벤처 파크(CHAP) - 스카이 바이크, 인공벽 등반',
      ],
      icon: FontAwesomeIcons.lightCarSide,
      transportInfo: '초콜릿 힐 전망대 인근',
    ),
  ];

  /// 주요 관광지 입장료 테이블 (Admission Fee Table)
  static const List<_TableRow> _admissionTable = [
    _TableRow(columns: ['관광지/투어', '비용(성인 1인)', '비고'], isHeader: true),
    _TableRow(columns: ['바클라욘 교회', '무료 / 박물관 ₱50', '성당 무료']),
    _TableRow(columns: ['혈맹 기념비', '무료', '-']),
    _TableRow(columns: ['초콜릿 힐 전망대', '₱150', '2025년 인상']),
    _TableRow(columns: ['안경원숭이 보호구역', '₱80', '12세 이하 할인']),
    _TableRow(columns: ['로복 강 선상뷔페', '₱1,000 내외', '중식 포함']),
    _TableRow(columns: ['히나그다난 동굴', '₱50 + 수영 ₱75', '주차료 별도']),
    _TableRow(columns: ['호핑투어', '₱1,000~1,500', '장비 대여 ₱150~']),
    _TableRow(columns: ['ATV 체험 (1시간)', '₱900~1,000', '2인 버기 ₱1,500']),
  ];

  /// 추천 일정 (Recommended Itinerary)
  static const List<_ScheduleItem> _itinerary = [
    _ScheduleItem(
      time: '05:00',
      activity: '세부 시내 출발 → 택시로 세부 Pier 1 터미널 이동',
      icon: FontAwesomeIcons.lightTaxi,
    ),
    _ScheduleItem(
      time: '06:00',
      activity: '세부항에서 보홀행 오션젯 고속페리 승선',
      icon: FontAwesomeIcons.lightShip,
    ),
    _ScheduleItem(
      time: '08:00',
      activity: '보홀 탁빌라란 항구 도착 → 예약 차량으로 이동 시작',
      icon: FontAwesomeIcons.lightLocationDot,
    ),
    _ScheduleItem(
      time: '08:30',
      activity: '혈맹 기념비 방문 (10분) → 바클라욘 교회 관람 (30분)',
      icon: FontAwesomeIcons.lightChurch,
    ),
    _ScheduleItem(
      time: '10:00',
      activity: '안경원숭이 보호구역 도착 및 견학 (30분)',
      icon: FontAwesomeIcons.lightMonkey,
    ),
    _ScheduleItem(
      time: '11:30',
      activity: '로복 강 선상뷔페 크루즈 탑승 (1시간, 점심 식사)',
      icon: FontAwesomeIcons.lightSailboat,
    ),
    _ScheduleItem(
      time: '13:00',
      activity: '로복 출발 → 비lar 인공림 드라이브 통과',
      icon: FontAwesomeIcons.lightTree,
    ),
    _ScheduleItem(
      time: '14:00',
      activity: '초콜릿 힐 전망대 도착, 언덕 전망 감상 (30분)',
      icon: FontAwesomeIcons.lightMountain,
    ),
    _ScheduleItem(
      time: '15:00',
      activity: 'ATV 체험 (옵션) 또는 휴식 후 복귀 출발',
      icon: FontAwesomeIcons.lightCarSide,
    ),
    _ScheduleItem(
      time: '16:30',
      activity: '탁빌라란 시내 → 기념품 쇼핑 (칼라마이, 땅콩과자)',
      icon: FontAwesomeIcons.lightBagShopping,
    ),
    _ScheduleItem(
      time: '17:30',
      activity: '탁빌라란 항구 도착, 페리 체크인',
      icon: FontAwesomeIcons.lightTicket,
    ),
    _ScheduleItem(
      time: '17:40',
      activity: '보홀 출발 마지막 페리 승선 → 세부로 이동',
      icon: FontAwesomeIcons.lightShip,
    ),
    _ScheduleItem(
      time: '19:40',
      activity: '세부 Pier 1 도착, 여행 종료',
      icon: FontAwesomeIcons.lightFlagCheckered,
    ),
  ];

  /// 참고 사항 (Notes)
  static const List<_InfoItem> _notesInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCar,
      title: '전용 차량 이용 권장',
      description:
          'Grab이 보홀에서 제한적이므로 전용 차량 픽업이나 프라이빗 투어를 사전 예약하면 편리합니다. 차량 대절 하루 약 ₱2,500~3,500 (기사 및 유류 포함).',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '시간 관리',
      description:
          '당일치기 일정은 아침 일찍부터 이동하느라 피로할 수 있습니다. 해변/해양 액티비티까지 원한다면 1박 연장을 권장합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금 준비',
      description:
          '보홀 내 소규모 상점, 트라이시클 등은 현금만 받습니다. 소액권 페소를 충분히 준비하세요.',
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
              FontAwesomeIcons.lightIslandTropical,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationBohol),
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

            /// [세부→보홀 이동 안내 섹션 - Transportation Section]
            _buildSectionHeader(
              context,
              emoji: '🚢',
              title: '세부 → 보홀 이동 안내',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _transportOverview, scheme.primaryContainer),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '교통편 요금 정리'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _transportTable),

            SizedBox(height: sp.s24),

            /// [역사·문화 유적지 섹션 - Historical Sites Section]
            _buildSectionHeader(
              context,
              emoji: '🏛️',
              title: '역사 · 문화 유적지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _historicalSites),

            SizedBox(height: sp.s24),

            /// [자연·해변 관광지 섹션 - Nature Section]
            _buildSectionHeader(
              context,
              emoji: '🏝️',
              title: '자연 · 해변 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _natureSites),

            SizedBox(height: sp.s24),

            /// [쇼핑·시내 관광지 섹션 - Shopping Section]
            _buildSectionHeader(
              context,
              emoji: '🛍️',
              title: '쇼핑 · 시내 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _shoppingSites),

            SizedBox(height: sp.s24),

            /// [가족·어린이 관광지 섹션 - Family Section]
            _buildSectionHeader(
              context,
              emoji: '👪',
              title: '가족 · 어린이 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _familySites),

            SizedBox(height: sp.s24),

            /// [기타 액티비티 섹션 - Activities Section]
            _buildSectionHeader(
              context,
              emoji: '🤿',
              title: '기타 액티비티',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _activities),

            SizedBox(height: sp.s24),

            /// [입장료 및 비용 섹션 - Admission Fee Section]
            _buildSectionHeader(
              context,
              emoji: '💰',
              title: '주요 관광지 입장료 및 비용',
            ),
            SizedBox(height: sp.s12),
            _buildDataTable(context, _admissionTable),

            SizedBox(height: sp.s24),

            /// [추천 일정 섹션 - Itinerary Section]
            _buildSectionHeader(
              context,
              emoji: '📋',
              title: '당일 여행 추천 일정',
            ),
            SizedBox(height: sp.s12),
            _buildItinerarySection(context),

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
  /// 화면 상단에 표시되는 그라데이션 배너입니다.
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
                '🏝️',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🍫',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '세부에서 보홀\n당일치기 여행 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '아침에 세부를 출발해 초콜릿 힐, 타르시어, 로복 강을 둘러보고 저녁에 돌아오는 알찬 하루 코스',
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

  /// 명소 카드 빌드 (Build attraction cards)
  Widget _buildAttractionCards(
    BuildContext context,
    List<_AttractionInfo> attractions,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: attractions.map((attraction) {
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
              /// 명소 헤더 (Attraction header)
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
                        attraction.icon,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      attraction.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),

              /// 설명 (Description)
              Text(
                attraction.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              SizedBox(height: sp.s12),

              /// 특징 목록 (Features list)
              ...attraction.features.map((feature) {
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

              /// 교통 정보 (Transportation info)
              if (attraction.transportInfo != null) ...[
                SizedBox(height: sp.s12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s12,
                    vertical: sp.s8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightLocationDot,
                        size: 14,
                        color: scheme.secondary,
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          attraction.transportInfo!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              /// 입장료 정보 (Admission info)
              if (attraction.admissionInfo != null) ...[
                SizedBox(height: sp.s8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s12,
                    vertical: sp.s8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightTicket,
                        size: 14,
                        color: scheme.tertiary,
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          attraction.admissionInfo!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                  flex: isFirstCol ? 2 : 2,
                  child: Text(
                    colValue,
                    style: row.isHeader
                        ? theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onPrimaryContainer,
                          )
                        : theme.textTheme.bodySmall?.copyWith(
                            color: isFirstCol
                                ? scheme.onSurface
                                : scheme.onSurfaceVariant,
                            fontWeight:
                                isFirstCol ? FontWeight.w500 : FontWeight.normal,
                            fontSize: 11,
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

  /// 추천 일정 섹션 빌드 (Build itinerary section)
  Widget _buildItinerarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _itinerary.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _itinerary.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 타임라인 아이콘 (Timeline icon)
              Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: FaIcon(
                        item.icon,
                        size: 14,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 일정 내용 (Schedule content)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.time,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.activity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
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

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '세부 Pier 1 → 오션젯 페리 2시간 → 탁빌라란 도착',
      '바클라욘 교회 & 혈맹 기념비 - 스페인 식민시대 유적',
      '안경원숭이 보호구역 - 세계 최소 영장류 관찰',
      '로복 강 크루즈 - 열대 우림 속 선상 뷔페 점심',
      '초콜릿 힐 - 1,268개 언덕의 장관 (ATV 체험 옵션)',
      '탁빌라란 시장 - 칼라마이, 피넛 키세스 기념품',
      '17:40 막배로 세부 복귀 → 19:40 도착',
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
                '당일치기 핵심 요약',
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
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '세부와 또 다른 매력을 지닌 보홀은 당일치기로 다녀와도 좋지만 여유가 된다면 1~2일 더 머무르길 추천합니다. 맑은 바다와 풍요로운 자연 속에서 힐링할 수 있는 보홀에서의 하루 여행이 알차고 뜻깊은 추억이 되길 바랍니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
