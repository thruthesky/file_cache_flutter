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

  const _AttractionInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    this.transportInfo,
  });
}

/// 마닐라 여행 정보 화면 (Manila Travel Screen)
///
/// 필리핀 마닐라 여행 정보를 제공합니다.
/// Provides travel information about Manila in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// ManilaScreen.push(context);
/// ```
class ManilaScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Manila';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ManilaScreen({super.key});

  @override
  State<ManilaScreen> createState() => _ManilaScreenState();
}

class _ManilaScreenState extends State<ManilaScreen> {
  /// 마닐라 개요 정보 (Manila Overview Info)
  ///
  /// 마닐라 도시에 대한 기본 정보를 담은 리스트입니다.
  static const List<_InfoItem> _overviewInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCity,
      title: '수도',
      description:
          '필리핀의 수도이자 정치·경제·문화의 중심지입니다. 스페인 식민시대의 흔적부터 현대적인 도시 매력까지 다양한 관광 명소가 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLandmark,
      title: '역사 유적',
      description:
          '인트라무로스와 리잘 공원 등 스페인 식민 지배부터 독립운동까지 다양한 시대의 역사적 흔적을 만날 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSun,
      title: '마닐라만 일몰',
      description:
          '세계적으로 유명한 마닐라만의 일몰은 여행자에게 잊지 못할 추억을 선사합니다. 베이워크 산책로에서 감상할 수 있습니다.',
    ),
  ];

  /// 역사·문화 유적지 정보 (Historical & Cultural Sites Info)
  ///
  /// 인트라무로스와 리잘 공원 등 역사 유적지 정보입니다.
  static const List<_AttractionInfo> _historicalSites = [
    _AttractionInfo(
      name: '인트라무로스 (Intramuros)',
      description:
          '16세기 후반 스페인에 의해 건설된 성벽 도시로, 마닐라의 구시가지입니다. 4.5km에 달하는 두터운 성벽으로 둘러싸여 있으며, 필리핀의 스페인 식민 통치 중심지였습니다.',
      features: [
        '산티아고 요새 (Fort Santiago) - 국가영웅 호세 리살 수감지',
        '산 아구스틴 교회 - UNESCO 세계유산, 바로크 양식',
        '카사 마닐라 박물관 - 스페인 총독 관저',
        '마닐라 대성당, 플라자 데 로마 등 식민시대 건축물',
        '칼레사(kalesa) 마차 투어 또는 도보 투어 가능',
      ],
      icon: FontAwesomeIcons.lightCastle,
      transportInfo: '시내 중심에서 약 2km, 택시로 5~10분 내외',
    ),
    _AttractionInfo(
      name: '리잘 공원 (Rizal Park)',
      description:
          '마닐라 도심의 대표적인 도시 공원이자 필리핀의 역사적 성지입니다. 1896년 스페인 식민정부에 저항하다 처형된 호세 리살을 기리는 장소로, 58헥타르 면적으로 아시아에서도 손꼽히는 큰 도시공원입니다.',
      features: [
        '호세 리살 기념비 - 공원 중앙에 위치',
        '국립박물관 단지 (미술관, 인류학 박물관, 자연사 박물관) 인접',
        '광활한 잔디와 정원, 분수대',
        '연중무휴 24시간 개방, 입장 무료',
        '마닐라만 노을 감상 가능 (공원 서쪽)',
      ],
      icon: FontAwesomeIcons.lightTree,
      transportInfo: '에르미타(Ermita) 지역 도심 내 위치, 도보 접근 가능',
    ),
  ];

  /// 역사 유적지 정보 테이블 (Historical Sites Info Table)
  static const List<_TableRow> _historicalSitesTable = [
    _TableRow(columns: ['명소', '운영 시간', '요금', '이동'], isHeader: true),
    _TableRow(columns: [
      '인트라무로스',
      '상시 개방\n(Fort Santiago\n08:00~22:00)',
      '무료\n(Fort Santiago\n₱75)',
      '약 2km\n5~10분',
    ]),
    _TableRow(columns: [
      '리잘 공원',
      '24시간 개방',
      '무료',
      '도심 내\n위치',
    ]),
  ];

  /// 쇼핑/도심 관광지 정보 (Shopping & Urban Attractions Info)
  ///
  /// SM 몰 오브 아시아와 BGC 등 쇼핑 및 도심 관광지 정보입니다.
  static const List<_AttractionInfo> _shoppingSites = [
    _AttractionInfo(
      name: 'SM 몰 오브 아시아 (SM Mall of Asia)',
      description:
          'MOA라는 약칭으로 불리며, 필리핀 최대, 동남아 2위, 세계 6위 규모의 복합 쇼핑몰입니다. 2006년 개장 당시 세계에서 세 번째로 큰 쇼핑몰로 화제가 되었습니다.',
      features: [
        '600여 개 매장, 200여 개 음식점',
        '아이맥스 영화관, 올림픽 규격 스케이트장, 볼링장',
        'MOA 아레나 (공연장 겸 체육관)',
        'MOA 아이 - 대형 관람차 (야간 나들이 인기)',
        '마닐라만 해변 인접 - 석양 감상 가능',
      ],
      icon: FontAwesomeIcons.lightBagShopping,
      transportInfo: '시내 중심에서 약 7km, 택시로 20~30분 소요',
    ),
    _AttractionInfo(
      name: '보니파시오 글로벌 시티 (BGC)',
      description:
          '타귁(Taguig)시에 위치한 신흥 현대도시입니다. 과거 미군 기지였던 부지를 개발하여 조성된 계획도시로, 고층 빌딩 숲과 세련된 거리 풍경을 자랑합니다.',
      features: [
        '보니파시오 하이스트리트 - 쇼핑·맛집 중심',
        'SM Aura, Market! Market! 등 대형 쇼핑몰',
        '야외 조각과 스트리트 아트',
        '마인드 뮤지엄 (Mind Museum) - 과학 박물관',
        '루프탑 바, 클럽 등 야경 감상 명소',
      ],
      icon: FontAwesomeIcons.lightBuilding,
      transportInfo: '시내 중심에서 약 10km, 택시로 30~40분 소요',
    ),
  ];

  /// 쇼핑/도심 관광지 테이블 (Shopping Sites Table)
  static const List<_TableRow> _shoppingSitesTable = [
    _TableRow(columns: ['명소', '운영 시간', '특징', '이동'], isHeader: true),
    _TableRow(columns: [
      '몰 오브 아시아',
      '10:00~22:00\n(연중무휴)',
      '필리핀 최대 쇼핑몰\n스케이트장 등',
      '약 7km\n20~30분',
    ]),
    _TableRow(columns: [
      'BGC',
      '상업시설\n대다수 10~22시',
      '현대적 상업지구\n레스토랑·야간문화',
      '약 10km\n30~40분',
    ]),
  ];

  /// 자연/해변 관광지 정보 (Nature & Beach Attractions Info)
  ///
  /// 마닐라만과 코레히도르 섬 등 자연 관광지 정보입니다.
  static const List<_AttractionInfo> _natureSites = [
    _AttractionInfo(
      name: '마닐라만 (Manila Bay)',
      description:
          '루손 섬 서쪽에 자리한 넓은 만으로, 스페인 식민시대부터 항구로 활용되어 온 역사적 공간입니다. "마닐라베이의 노을은 세계 최고"라는 찬사가 있을 정도로 일몰 경치가 장관입니다.',
      features: [
        '베이워크(Baywalk) 해변 산책로',
        '노천 바와 라이브 음악 휴식 공간',
        '돌로미트 백사장 (Dolomite Beach) - 인공 해변',
        '마닐라만 선셋 크루즈 (디너 크루즈) 운영',
        '수영 불가 (항만으로 이용)',
      ],
      icon: FontAwesomeIcons.lightWater,
      transportInfo: '시내 중심에서 1~2km, 택시로 5~10분',
    ),
    _AttractionInfo(
      name: '코레히도르 섬 (Corregidor Island)',
      description:
          '마닐라만 입구에 위치한 전략적 요충지로, 2차 세계대전 당시 일본군에 맞서 미군과 필리핀군이 최후 항전을 벌인 장소입니다. 섬 전체가 거대한 야외 박물관과 같습니다.',
      features: [
        '배터리 웨이, 배터리 하언 - 옛 포대 유적',
        '밀롱 막사(Mile-Long Barracks) 폐허',
        '말린타 터널(Malinta Tunnel) - 지하 구조물',
        '가이드 차량 투어 운영',
        '섬 정상 전망대 - 마닐라만 조망',
      ],
      icon: FontAwesomeIcons.lightIslandTropical,
      transportInfo: '도심에서 약 48km, 투어 전용 페리로 약 1시간',
    ),
  ];

  /// 자연/해변 관광지 테이블 (Nature Sites Table)
  static const List<_TableRow> _natureSitesTable = [
    _TableRow(columns: ['명소', '특징', '이용 정보', '이동'], isHeader: true),
    _TableRow(columns: [
      '마닐라만\n(Baywalk)',
      '세계적 일몰 명소\n해변 산책로',
      '수영 불가\n선셋 크루즈 운영',
      '시내 1~2km\n택시 5~10분',
    ]),
    _TableRow(columns: [
      '코레히도르 섬',
      'WWII 전쟁 유적지\n역사 공원',
      '일일 투어 방문\n페리 약 1시간',
      '도심 48km\n투어 페리',
    ]),
  ];

  /// 가족/어린이 관광지 정보 (Family & Kids Attractions Info)
  ///
  /// 마닐라 오션 파크, 동물원, 스타 시티 등 가족 관광지 정보입니다.
  static const List<_AttractionInfo> _familySites = [
    _AttractionInfo(
      name: '마닐라 오션 파크 (Manila Ocean Park)',
      description:
          '2008년 개장한 필리핀 최초의 대형 해양 테마파크입니다. 리잘 공원 뒤편에 위치하며, 1만여 마리의 해양 생물을 전시한 아쿠아리움이 중심 시설입니다.',
      features: [
        '25m 해저 터널 수족관 - 열대어, 상어 관람',
        '펭귄관, 상어·가오리 풀장, 조류 체험관',
        '바다사자 쇼, 돌고래 체험 프로그램',
        '호텔 H2O - 해양 컨셉 숙박시설',
        '월-금 10:00~18:00, 주말 09:00~18:00',
      ],
      icon: FontAwesomeIcons.lightFish,
      transportInfo: '리잘 공원 인근 0.5km, 도보 10분 또는 택시 5분',
    ),
    _AttractionInfo(
      name: '마닐라 동물원 (Manila Zoo)',
      description:
          '1959년 개장한 필리핀 최초의 동물원입니다. 2019년 환경 문제로 폐쇄 후 대대적인 개보수를 거쳐 2022년 초 재개장하였습니다.',
      features: [
        '아시아 코끼리 말리(Mali) - 동물원의 상징',
        '호랑이, 사자, 표범, 조랑말, 조류, 파충류 등 약 500여 마리',
        '어린이 놀이터, 동물 교감 코너',
        '화-일 09:00~20:00 (월요일 11시 개장)',
        '입장료: 성인 ₱300, 아동 ₱200',
      ],
      icon: FontAwesomeIcons.lightPaw,
      transportInfo: 'Malate 지역, 시내에서 약 4km, 택시로 15~20분',
    ),
    _AttractionInfo(
      name: '스타 시티 (Star City)',
      description:
          '마닐라 도심에 있는 놀이공원으로, 다양한 놀이기구와 어트랙션을 갖추고 있습니다. 2019년 화재 후 시설 복구를 거쳐 2022년 초 재개장하였습니다.',
      features: [
        '20여 종 이상 놀이기구 (회전목마, 롤러코스터, 드롭탑 등)',
        '대부분 에어컨 가동 실내 공간',
        '크리스마스 빛축제, 할로윈 호러하우스 등 특별 이벤트',
        '평일 16:00~22:00, 주말 14:00~22:00',
        '자유이용권 약 ₱700~',
      ],
      icon: FontAwesomeIcons.lightFerrisWheel,
      transportInfo: 'CCP 콤플렉스 인근, 시내에서 약 5km, 택시로 15분',
    ),
  ];

  /// 가족/어린이 관광지 테이블 (Family Sites Table)
  static const List<_TableRow> _familySitesTable = [
    _TableRow(columns: ['명소', '즐길 거리', '운영/요금', '이동'], isHeader: true),
    _TableRow(columns: [
      '마닐라\n오션 파크',
      '아쿠아리움\n해양동물 쇼',
      '월-금 10~18시\n토-일 9~18시\n₱600~',
      '리잘공원 인근\n택시 5분',
    ]),
    _TableRow(columns: [
      '마닐라 동물원',
      '코끼리 Mali\n동물 교감',
      '화-일 9~20시\n성인 ₱300',
      'Malate 4km\n택시 15분',
    ]),
    _TableRow(columns: [
      '스타 시티',
      '놀이기구\n각종 이벤트',
      '평일 16~22시\n주말 14~22시\n₱700~',
      'CCP 인근 5km\n택시 15분',
    ]),
  ];

  /// 참고 사항 (Notes)
  ///
  /// 마닐라 여행 시 참고해야 할 사항들입니다.
  static const List<_InfoItem> _notesInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCar,
      title: '교통 체증',
      description:
          '마닐라는 교통 체증이 심합니다. 특히 출퇴근 시간(7~9시, 17~20시)에는 이동 시간이 2~3배 늘어날 수 있습니다. Grab 앱을 활용하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      title: '안전 주의',
      description:
          '관광지는 비교적 안전하지만, 밤늦게 혼자 다니는 것은 피하세요. 귀중품은 호텔 금고에 보관하고, 소매치기에 주의하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금 준비',
      description:
          '소규모 상점, 지프니, 트라이시클 등에서는 현금만 받습니다. 소액권(₱20, ₱50, ₱100)을 충분히 준비하세요.',
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
              FontAwesomeIcons.lightCity,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationManila),
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
              emoji: '🏙️',
              title: '마닐라 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _overviewInfo, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [역사·문화 유적지 섹션 - Historical Sites Section]
            _buildSectionHeader(
              context,
              emoji: '🏰',
              title: '역사·문화 유적지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _historicalSites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '역사 유적지 정보 요약'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _historicalSitesTable),

            SizedBox(height: sp.s24),

            /// [쇼핑 및 도심 관광지 섹션 - Shopping Section]
            _buildSectionHeader(
              context,
              emoji: '🛍️',
              title: '쇼핑 및 도심 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _shoppingSites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '쇼핑/도심 관광지 정보 요약'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _shoppingSitesTable),

            SizedBox(height: sp.s24),

            /// [자연 및 해변 관광지 섹션 - Nature Section]
            _buildSectionHeader(
              context,
              emoji: '🌅',
              title: '자연 및 해변 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _natureSites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '자연/해변 관광지 정보 요약'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _natureSitesTable),

            SizedBox(height: sp.s24),

            /// [가족·어린이 관광지 섹션 - Family Section]
            _buildSectionHeader(
              context,
              emoji: '🎡',
              title: '가족·어린이 대상 관광지',
            ),
            SizedBox(height: sp.s12),
            _buildAttractionCards(context, _familySites),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '가족 나들이 관광지 정보 요약'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _familySitesTable),

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
  /// Gradient banner displayed at the top of the screen.
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
                '🏙️',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🌅',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 마닐라\n여행 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '역사 유산부터 현대적인 도시 매력까지, 다채로운 경험을 선사하는 필리핀의 수도',
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
  /// Displays section title with emoji.
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
  /// 테이블 등 하위 섹션의 제목을 표시합니다.
  /// Displays sub-section title for tables etc.
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
  /// 기본 정보 아이템을 카드 형태로 표시합니다.
  /// Displays basic info items as cards.
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
  ///
  /// 관광 명소 정보를 상세 카드 형태로 표시합니다.
  /// Displays attraction info as detailed cards.
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
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 데이터 테이블 빌드 (Build data table)
  ///
  /// 정보를 표 형태로 표시합니다.
  /// Displays information in table format.
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

  /// 참고 사항 섹션 빌드 (Build notes section)
  ///
  /// 여행 시 주의사항을 강조하여 표시합니다.
  /// Displays travel notes with emphasis.
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
  ///
  /// 마닐라 여행 핵심 요약을 그라데이션 배경으로 표시합니다.
  /// Displays Manila travel summary with gradient background.
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '인트라무로스 - 스페인 식민시대 성벽 도시, 역사 유적지',
      '리잘 공원 - 58헥타르 도시공원, 24시간 무료 개방',
      'SM 몰 오브 아시아 - 필리핀 최대 쇼핑몰',
      'BGC - 세련된 현대적 상업지구, 루프탑 바 명소',
      '마닐라만 - 세계적 일몰 명소, 베이워크 산책로',
      '코레히도르 섬 - WWII 역사 공원, 일일 투어',
      '마닐라 오션 파크, 동물원, 스타 시티 - 가족 여행지',
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
                '🏙️',
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
