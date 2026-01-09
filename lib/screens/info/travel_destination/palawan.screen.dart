import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

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

/// 관광지 정보 데이터 클래스 (Spot Info Data Class)
///
/// 관광지의 상세 정보를 담습니다.
/// Contains detailed information about tourist spots.
class _SpotInfo {
  /// 관광지 이름 (Spot name)
  final String name;

  /// 설명 (Description)
  final String description;

  /// 특징 목록 (Features list)
  final List<String> features;

  /// 아이콘 (Icon)
  final IconData icon;

  /// 방문 팁 목록 (Visit tips list)
  final List<String>? tips;

  const _SpotInfo({
    required this.name,
    required this.description,
    required this.features,
    required this.icon,
    this.tips,
  });
}

/// 호핑 투어 코스 데이터 클래스 (Hopping Tour Course Data Class)
///
/// 엘니도 호핑 투어 코스별 정보를 담습니다.
/// Contains information about El Nido hopping tour courses.
class _TourCourse {
  /// 코스명 (Course name)
  final String name;

  /// 대표 성격 (Main character)
  final String character;

  /// 장점 (Pros)
  final String pros;

  /// 단점/리스크 (Cons/Risks)
  final String cons;

  /// 아이콘 (Icon)
  final IconData icon;

  const _TourCourse({
    required this.name,
    required this.character,
    required this.pros,
    required this.cons,
    required this.icon,
  });
}

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

/// 팔라완 여행 정보 화면 (Palawan Travel Screen)
///
/// 필리핀 팔라완 여행 정보를 제공합니다.
/// 푸에르토 프린세사, 엘니도, 코론 중심의 심층 여행 가이드입니다.
/// Provides travel information about Palawan in the Philippines.
/// In-depth travel guide focusing on Puerto Princesa, El Nido, and Coron.
///
/// ### 사용법 (Usage):
/// ```dart
/// PalawanScreen.push(context);
/// ```
class PalawanScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Palawan';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const PalawanScreen({super.key});

  @override
  State<PalawanScreen> createState() => _PalawanScreenState();
}

class _PalawanScreenState extends State<PalawanScreen> {
  /// [시즌 정보 테이블 - Season Info Table]
  ///
  /// 팔라완의 건기/우기 시즌별 운영 경향과 추천 활동 정보입니다.
  /// 핵심 변수는 바다 컨디션(파도·풍향)과 강수입니다.
  static const List<_TableRow> _seasonTable = [
    _TableRow(columns: ['시즌', '기간', '운영 경향', '추천 활동'], isHeader: true),
    _TableRow(columns: ['건기', '12~5월', '해상 투어 결항↓, 가시성↑', '엘니도 호핑, 코론 다이빙']),
    _TableRow(columns: ['우기', '6~11월', '스콜·바람으로 결항↑', '육상 투어, 일정 여유 필요']),
  ];

  /// [시즌 관련 후기 경향 - Season Review Trends]
  static const List<_InfoItem> _seasonTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCloudRain,
      title: '우기 후기 경향',
      description:
          '우기에는 "투어 취소/코스 변경" 사례가 반복적으로 언급됩니다. 특히 엘니도 호핑은 바람·파도에 직접 영향을 받습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '방문 전략',
      description: '우기 방문 시 버퍼(예비일) 1일 이상을 일정에 포함하는 구성이 안전합니다. 투어 취소 시 대체 일정으로 활용할 수 있습니다.',
    ),
  ];

  /// [푸에르토 프린세사 관광지 - Puerto Princesa Spots]
  ///
  /// 지하강 국립공원과 시내 관광지 정보입니다.
  /// 푸에르토 프린세사는 엘니도/코론 대비 거점 도시 기능이 강합니다.
  static const List<_SpotInfo> _puertoPrincesaSpots = [
    _SpotInfo(
      name: '푸에르토 프린세사 지하강 국립공원 (Underground River)',
      description:
          'UNESCO 세계자연유산이자 세계 7대 자연경관 중 하나로, 세계에서 가장 긴 지하 강(약 8.2km)을 보트로 탐험할 수 있습니다. 석회암 동굴 내부의 종유석과 석순이 장관을 이루며, 박쥐와 제비 서식지로도 유명합니다. "예약(슬롯)·퍼밋 기반 운영" 자체가 관리정책이며, 보전 목적상 \'No permit, no entry\'(퍼밋 없으면 입장 불가) 원칙을 적용합니다.',
      features: [
        '운영 특성: 방문객 수 제한 + 사전 퍼밋 필수',
        '후기(장점): 날씨 영향이 해상 투어보다 상대적으로 낮아 "우기 대체 일정"으로 활용',
        '후기(단점): 퍼밋/슬롯 미확보 시 당일 입장 불가 가능성(성수기)',
        '환경 관리: 방문객 수 제한·퍼밋 제도(보전 목적)',
      ],
      icon: FontAwesomeIcons.lightWater,
      tips: [
        '사전 예약/퍼밋 확보가 필수 - 현장 임의 방문은 리스크',
        '성수기(연말·휴가철)에는 슬롯 선점 경쟁이 커져 일정 초반에 배치 권장',
        '사바탄 항구에서 보트로 약 1시간 이동 후 도착',
      ],
    ),
    _SpotInfo(
      name: '시내 역사·도심 관광지',
      description:
          '푸에르토 프린세사는 엘니도/코론 대비 "리조트형 관광지"보다는 거점 도시 기능(이동·준비·대체 일정)이 강합니다. 장거리 투어 전후 편성에 적합한 도심 관광지들이 있습니다.',
      features: [
        'Plaza Cuartel: 2차대전 전쟁 관련 추모·역사 공간(짧은 체류형)',
        'Immaculate Conception Cathedral: 도심 동선 내 포함 용이한 성당',
        'Baywalk: 저녁 시간 산책 동선으로 편성, 석양 감상 명소',
        'Robinsons Mall: 장거리 투어 전후 "보급/식사" 목적 활용',
      ],
      icon: FontAwesomeIcons.lightCity,
      tips: [
        '도심 관광은 반나절 일정으로 충분',
        'Baywalk는 일몰 시간에 맞춰 방문 권장',
        '쇼핑몰에서 투어 준비물(선크림, 방수팩 등) 구매 가능',
      ],
    ),
  ];

  /// [엘니도 호핑 투어 코스 - El Nido Hopping Tour Courses]
  ///
  /// 엘니도는 Bacuit Bay 일대에서 표준화된 4개 코스(Tour A/B/C/D)로 운영됩니다.
  static const List<_TourCourse> _elNidoTours = [
    _TourCourse(
      name: 'Tour A',
      character: '라군 중심',
      pros: '빅 라군·스몰 라군·카약 중심 동선, 포토 포인트 다수',
      cons: '성수기 혼잡·대기 발생, 인기 코스라 붐빔',
      icon: FontAwesomeIcons.lightWaterLadder,
    ),
    _TourCourse(
      name: 'Tour B',
      character: '동굴/코브',
      pros: '비교적 테마가 분명, 동굴·코브 탐험',
      cons: '포인트별 체류시간 제한 체감',
      icon: FontAwesomeIcons.lightMountain,
    ),
    _TourCourse(
      name: 'Tour C',
      character: '비치/스노클',
      pros: '스노클·비치 조합, 시크릿 비치·헬리콥터 아일랜드',
      cons: '파도 영향으로 코스 변경 가능',
      icon: FontAwesomeIcons.lightFish,
    ),
    _TourCourse(
      name: 'Tour D',
      character: '비교적 한적',
      pros: '비교적 혼잡↓ 경향, 여유로운 분위기',
      cons: '"대표 포인트" 선호자에겐 다소 아쉬움',
      icon: FontAwesomeIcons.lightIslandTropical,
    ),
  ];

  /// [엘니도 환경 정책 - El Nido Environmental Policy]
  static const List<_InfoItem> _elNidoPolicy = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBottleWater,
      title: '플라스틱 규제',
      description:
          '팔라완 지역은 일회용 플라스틱 규제 강화 흐름이 있으며, 엘니도·코론이 선도 지자체로 언급됩니다. 투어 참가 시 개인 물병/텀블러·재사용 용기 준비가 운영 규정·현장 분위기 측면에서 안전합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTrashCan,
      title: 'Leave No Trace',
      description: '쓰레기 반출(Leave no trace)은 투어 안내에서 반복되는 기본 원칙입니다. 모든 쓰레기는 되가져가야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '관광 압력 관리',
      description:
          '엘니도 투어는 "대형 그룹 보트 + 동일 시간대 출항" 구조로 인해 라군·비치에서 혼잡/대기가 발생합니다. ADB는 해양 생태 관광지에서 관광 압력 관리(수용량·서비스 인프라·관리체계) 필요성을 강조합니다.',
    ),
  ];

  /// [엘니도 방문 팁 테이블 - El Nido Visit Tips Table]
  static const List<_TableRow> _elNidoTipsTable = [
    _TableRow(columns: ['항목', '팁'], isHeader: true),
    _TableRow(columns: ['출항 시간', '조기 집결 권장 (혼잡 완화 목적)']),
    _TableRow(columns: ['멀미', '라군 외 해역 구간 대비 필요']),
    _TableRow(columns: ['장비', '방수팩, 아쿠아슈즈 필수 (상륙지 다수)']),
    _TableRow(columns: ['카약', '라군 구간 카약 이용 포함/권장, 현장 규칙 확인']),
  ];

  /// [코론 관광지 - Coron Spots]
  ///
  /// 카양안 레이크와 난파선 다이빙 정보입니다.
  static const List<_SpotInfo> _coronSpots = [
    _SpotInfo(
      name: '카양안 레이크 (Kayangan Lake)',
      description:
          '"필리핀에서 가장 깨끗한 호수"로 알려진 카양안 레이크는 관광지이면서 현지 Tagbanwa 공동체 관리 및 문화적 의미가 있는 곳입니다. 전망대(포토 포인트)에서 바라보는 석회암 절벽과 에메랄드빛 호수의 조합이 장관이며, 호수에서 수영/스노클링이 가능합니다.',
      features: [
        '후기(장점): 전망대 + 호수 수영/스노클을 한 동선에 결합 가능',
        '후기(단점): 인기 포인트 특성상 정오 이후 혼잡 발생',
        '문화적 의미: Tagbanwa 원주민 공동체 관리 구역',
        '입장료: 환경관리비 포함 (금액 변동 가능, 현지 확인)',
      ],
      icon: FontAwesomeIcons.lightMountainSun,
      tips: [
        '운영 시간대 내 이른 시간대 도착이 혼잡 완화에 유리',
        '민감 생태/문화 구역이므로 현장 안내(출입 동선·금지 행위) 우선 적용',
        '계단이 많으므로 편한 신발 착용 권장',
      ],
    ),
    _SpotInfo(
      name: '난파선 다이빙 (Shipwreck Diving)',
      description:
          '코론은 2차대전 일본 함대 난파선 다이빙 포인트로 국제적으로 알려져 있습니다. 약 12척의 난파선이 산재해 있으며, 다이버들에게 세계적인 명소로 손꼽힙니다. 난파선 내부 탐험과 주변 산호초·해양 생물 관찰이 가능합니다.',
      features: [
        '포인트: Irako, Okikawa Maru, Kogyo Maru 등 12척 이상',
        '수심: 10~40m 다양 (레벨별 선택 가능)',
        '후기(리스크): 해상 컨디션과 가시성 영향을 크게 받음',
        '추천 시기: 건기(12~5월) - 가시성·운영 안정',
      ],
      icon: FontAwesomeIcons.lightShip,
      tips: [
        '건기 방문 시 가시성이 좋아 난파선 탐험에 적합',
        '다이빙 라이선스 필수 (일부 스노클링 투어도 있음)',
        '다이빙 샵 사전 예약 권장',
      ],
    ),
  ];

  /// [가족/어린이 동선 테이블 - Family/Kids Route Table]
  static const List<_TableRow> _familyRouteTable = [
    _TableRow(columns: ['지역', '추천 성격', '근거(운영 현실)'], isHeader: true),
    _TableRow(columns: ['푸에르토 프린세사', '육상·생태 교육·단거리', '해상 파도 변수↓, 도시 인프라 우수']),
    _TableRow(columns: ['엘니도', '가족 단체 호핑 가능', '다만 혼잡·이동·상륙 반복으로 피로도 변수']),
    _TableRow(columns: ['코론', '호수/석호 + 선택적 다이빙', '다이빙은 연령/안전 조건에 따라 선택']),
  ];

  /// [도시 간 이동 테이블 - Inter-city Transport Table]
  static const List<_TableRow> _interCityTable = [
    _TableRow(columns: ['구간', '수단', '시간', '특징'], isHeader: true),
    _TableRow(columns: ['푸에르토 프린세사 → 엘니도', '밴(셔틀)', '5~6시간', '약 230km, 도로·정차에 따라 변동']),
    _TableRow(columns: ['엘니도 → 코론', '페리', '4~5시간', '파도·기상에 따라 지연/결항 가능']),
    _TableRow(columns: ['푸에르토 프린세사 → 코론', '항공', '약 1시간', '일정 안정성↑, 좌석/시간표 변수']),
  ];

  /// [도시 내 교통 테이블 - Intra-city Transport Table]
  static const List<_TableRow> _intraCityTable = [
    _TableRow(columns: ['수단', '주 사용 지역', '특징', '팁'], isHeader: true),
    _TableRow(columns: ['그랩', '푸에르토 프린세사(일부)', '앱 기반', '호출 가능 범위 확인']),
    _TableRow(columns: ['택시', '푸에르토 프린세사', '비교적 표준', '장거리 이동은 사전 합의']),
    _TableRow(columns: ['트라이시클', '전 지역', '단거리 주력', '요금 협상이 일반적']),
    _TableRow(columns: ['지프니', '일부 구간', '현지 대중교통', '노선/정류장 정보 확인 필요']),
  ];

  /// [시즌별 추천 테이블 - Season Recommendation Table]
  static const List<_TableRow> _seasonRecommendTable = [
    _TableRow(columns: ['목적', '추천 시기', '이유(운영 변수)'], isHeader: true),
    _TableRow(columns: ['엘니도 호핑 "확실히"', '12~5월(건기)', '해상 컨디션 안정, 결항 위험↓']),
    _TableRow(columns: ['코론 다이빙/호수', '12~5월(건기)', '가시성·이동 안정 경향']),
    _TableRow(columns: ['비용/혼잡 완화 목적', '6~11월(우기)', '한산하나 결항/변경 대비 필요']),
    _TableRow(columns: ['"일정 안전" 우선', '건기 + 예비일 1일', '기상 변수 대응(특히 해상 투어)']),
  ];

  /// [핵심 요약 - Summary]
  static const List<String> _summaryItems = [
    '건기(12~5월): 해상 투어 최적, 결항 위험 낮음',
    '지하강: 사전 퍼밋 필수, 우기 대체 일정으로 활용',
    '엘니도 호핑: A/B/C/D 코스 선택, 성수기 혼잡 주의',
    '코론: 카양안 레이크 + 난파선 다이빙 명소',
    '환경 정책: 플라스틱 규제, Leave No Trace 원칙',
    '이동: 푸에르토-엘니도 5~6시간, 엘니도-코론 페리 4~5시간',
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
              FontAwesomeIcons.lightMountainSun,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.travelDestinationPalawan),
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

            /// [시즌 정보 섹션 - Season Info Section]
            _buildSectionHeader(
              context,
              emoji: '🌤️',
              title: '팔라완 시즌(날씨) 기준',
            ),
            SizedBox(height: sp.s8),
            _buildSubtitle(
              context,
              '핵심 변수: 바다 컨디션(파도·풍향)과 강수',
            ),
            SizedBox(height: sp.s12),
            _buildDataTable(context, _seasonTable),
            SizedBox(height: sp.s16),
            _buildInfoCards(context, _seasonTips, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [푸에르토 프린세사 섹션 - Puerto Princesa Section]
            _buildSectionHeader(
              context,
              emoji: '🏛️',
              title: '푸에르토 프린세사 (Puerto Princesa)',
            ),
            SizedBox(height: sp.s8),
            _buildSubtitle(
              context,
              '거점 도시 기능 + 지하강 국립공원',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _puertoPrincesaSpots, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [엘니도 섹션 - El Nido Section]
            _buildSectionHeader(
              context,
              emoji: '🏝️',
              title: '엘니도 (El Nido)',
            ),
            SizedBox(height: sp.s8),
            _buildSubtitle(
              context,
              '석회암·라군 기반 해상 투어의 천국',
            ),
            SizedBox(height: sp.s12),

            /// [호핑 투어 코스 - Hopping Tour Courses]
            _buildSubSectionTitle(context, '아일랜드 호핑 투어 (A/B/C/D)'),
            SizedBox(height: sp.s8),
            _buildTourCourseCards(context),
            SizedBox(height: sp.s16),

            /// [환경 정책 - Environmental Policy]
            _buildSubSectionTitle(context, '환경 보호 정책'),
            SizedBox(height: sp.s8),
            _buildInfoCards(context, _elNidoPolicy, scheme.tertiaryContainer),
            SizedBox(height: sp.s16),

            /// [방문 팁 - Visit Tips]
            _buildSubSectionTitle(context, '방문 팁'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _elNidoTipsTable),

            SizedBox(height: sp.s24),

            /// [코론 섹션 - Coron Section]
            _buildSectionHeader(
              context,
              emoji: '🤿',
              title: '코론 (Coron)',
            ),
            SizedBox(height: sp.s8),
            _buildSubtitle(
              context,
              '호수·석호 + 난파선 다이빙 명소',
            ),
            SizedBox(height: sp.s12),
            _buildSpotCards(context, _coronSpots, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [가족/어린이 동선 섹션 - Family Route Section]
            _buildSectionHeader(
              context,
              emoji: '👨‍👩‍👧‍👦',
              title: '가족/어린이 동선 추천',
            ),
            SizedBox(height: sp.s12),
            _buildDataTable(context, _familyRouteTable),

            SizedBox(height: sp.s24),

            /// [내부 이동 섹션 - Internal Transport Section]
            _buildSectionHeader(
              context,
              emoji: '🚐',
              title: '팔라완 내부 이동',
            ),
            SizedBox(height: sp.s12),
            _buildSubSectionTitle(context, '도시 간 이동'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _interCityTable),
            SizedBox(height: sp.s16),
            _buildTransportWarning(context),
            SizedBox(height: sp.s16),
            _buildSubSectionTitle(context, '도시 내 교통'),
            SizedBox(height: sp.s8),
            _buildDataTable(context, _intraCityTable),

            SizedBox(height: sp.s24),

            /// [시즌별 추천 섹션 - Season Recommendation Section]
            _buildSectionHeader(
              context,
              emoji: '📅',
              title: '시즌별 추천 (목적별)',
            ),
            SizedBox(height: sp.s12),
            _buildDataTable(context, _seasonRecommendTable),

            SizedBox(height: sp.s24),

            /// [핵심 요약 섹션 - Summary Section]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 히어로 배너 빌드 (Build hero banner)
  ///
  /// 팔라완 여행 가이드의 메인 배너를 생성합니다.
  /// Creates the main banner for Palawan travel guide.
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
                '🇵🇭',
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
            '필리핀 팔라완\n심층 여행 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '푸에르토 프린세사 · 엘니도 · 코론',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: sp.s4),
          Text(
            '환경정책 · 방문팁 · 시즌 추천 · 내부 이동',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header with emoji)
  ///
  /// 각 섹션의 제목을 이모지와 함께 표시합니다.
  /// Displays section titles with emojis.
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

  /// 부제목 빌드 (Build subtitle)
  Widget _buildSubtitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
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
                        ? theme.textTheme.labelMedium?.copyWith(
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

  /// 관광지 카드 목록 빌드 (Build spot cards list)
  ///
  /// 관광지 정보를 카드 형태로 표시합니다.
  /// Displays tourist spot information in card format.
  Widget _buildSpotCards(
    BuildContext context,
    List<_SpotInfo> spots,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: spots.map((spot) {
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
              /// [카드 헤더 - Card Header]
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        spot.icon,
                        size: 20,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      spot.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),

              /// [설명 - Description]
              Text(
                spot.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              SizedBox(height: sp.s12),

              /// [특징 목록 - Features List]
              ...spot.features.map((feature) {
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

              /// [방문 팁 - Visit Tips]
              if (spot.tips != null && spot.tips!.isNotEmpty) ...[
                SizedBox(height: sp.s12),
                Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightLightbulb,
                            size: 14,
                            color: scheme.tertiary,
                          ),
                          SizedBox(width: sp.s8),
                          Text(
                            '방문 팁',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s8),
                      ...spot.tips!.map((tip) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: sp.s4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✓',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.tertiary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: sp.s8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: scheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  /// 호핑 투어 코스 카드 빌드 (Build tour course cards)
  Widget _buildTourCourseCards(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _elNidoTours.map((tour) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// [코스 헤더 - Course Header]
              Row(
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
                        tour.icon,
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
                        Text(
                          tour.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          tour.character,
                          style: theme.textTheme.bodySmall?.copyWith(
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

              /// [장점 - Pros]
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '장점',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      tour.pros,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),

              /// [단점 - Cons]
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '주의',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      tour.cons,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 교통 경고 빌드 (Build transport warning)
  Widget _buildTransportWarning(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 16,
            color: scheme.error,
          ),
          SizedBox(width: sp.s12),
          Expanded(
            child: Text(
              '주의: 우기에는 해상(페리·호핑) 일정이 기상 변수에 민감합니다. 예비일 확보를 권장합니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 요약 섹션 빌드 (Build summary section)
  ///
  /// 팔라완 여행의 핵심 요약을 그라데이션 카드로 표시합니다.
  /// Displays key summary of Palawan travel in a gradient card.
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

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
                '팔라완 여행 핵심 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._summaryItems.map((item) {
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
