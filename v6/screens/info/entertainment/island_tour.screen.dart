import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 섬투어 정보 아이템 데이터 클래스 (Island Tour Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _IslandTourInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _IslandTourInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 체크리스트 아이템 데이터 클래스 (Checklist Item Data Class)
///
/// 당일 이용 체크리스트의 항목과 핵심 내용을 담습니다.
/// Contains item and key info for day-use checklist.
class _ChecklistItem {
  /// 항목 (Item)
  final String item;

  /// 핵심 (Key info)
  final String keyInfo;

  const _ChecklistItem({
    required this.item,
    required this.keyInfo,
  });
}

/// 예약 채널 데이터 클래스 (Booking Channel Data Class)
///
/// 예약 채널의 장점과 주의사항을 담습니다.
/// Contains advantages and cautions for booking channels.
class _BookingChannel {
  /// 채널명 (Channel name)
  final String channel;

  /// 장점 (Advantage)
  final String advantage;

  /// 주의사항 (Caution)
  final String caution;

  const _BookingChannel({
    required this.channel,
    required this.advantage,
    required this.caution,
  });
}

/// 확인 체크포인트 데이터 클래스 (Check Point Data Class)
///
/// 좋은 상품 판별을 위한 체크포인트 정보를 담습니다.
/// Contains check points for identifying good products.
class _CheckPoint {
  /// 항목 (Item)
  final String item;

  /// 확인 기준 (Check criteria)
  final String criteria;

  const _CheckPoint({
    required this.item,
    required this.criteria,
  });
}

/// 지역별 코스 데이터 클래스 (Regional Course Data Class)
///
/// 각 지역의 섬투어 코스 정보를 담습니다.
/// Contains island tour course info for each region.
class _RegionalCourse {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 지역명 (Region name)
  final String region;

  /// 주요 코스 (Main courses)
  final List<String> courses;

  /// 특징 (Features)
  final List<String> features;

  /// 참고사항 (Notes)
  final String? note;

  const _RegionalCourse({
    required this.icon,
    required this.region,
    required this.courses,
    required this.features,
    this.note,
  });
}

/// 절차 아이템 데이터 클래스 (Procedure Item Data Class)
///
/// 예약 절차의 순서와 설명을 담습니다.
/// Contains order and description for booking procedure.
class _ProcedureItem {
  /// 내용 (Content)
  final String content;

  /// 포인트 (Point)
  final String point;

  const _ProcedureItem({
    required this.content,
    required this.point,
  });
}

/// 현금 항목 데이터 클래스 (Cash Item Data Class)
///
/// 현장에서 발생하는 현금 항목 정보를 담습니다.
/// Contains cash payment items at the site.
class _CashItem {
  /// 항목 (Item)
  final String item;

  /// 설명 (Description)
  final String description;

  const _CashItem({
    required this.item,
    required this.description,
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

/// 섬투어 정보 화면 (Island Tour Screen)
///
/// 필리핀 섬투어(아일랜드 호핑) 관련 정보를 제공합니다.
/// Provides information about island tours (island hopping) in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// IslandTourScreen.push(context);
/// ```
class IslandTourScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/IslandTour';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const IslandTourScreen({super.key});

  @override
  State<IslandTourScreen> createState() => _IslandTourScreenState();
}

class _IslandTourScreenState extends State<IslandTourScreen> {
  /// 당일 이용 체크리스트 데이터 (Day use checklist data)
  static const List<_ChecklistItem> _checklistItems = [
    _ChecklistItem(item: '신분', keyInfo: '여권/유효 ID, 예약바우처(모바일)'),
    _ChecklistItem(item: '복장', keyInfo: '수영복, 래시가드, 아쿠아슈즈(권장)'),
    _ChecklistItem(item: '보호', keyInfo: '자외선 차단제, 방수팩, 멀미약(필요 시)'),
    _ChecklistItem(item: '현금', keyInfo: '입장료/환경세, 장비 추가대여, 팁(선택)'),
    _ChecklistItem(item: '기기', keyInfo: '휴대폰 방수케이스, 보조배터리'),
  ];

  /// 예약 채널 데이터 (Booking channel data)
  static const List<_BookingChannel> _bookingChannels = [
    _BookingChannel(
      channel: '글로벌/로컬 예약 플랫폼',
      advantage: '일정·포함사항·취소규정이 명시되는 경우가 많다',
      caution: '성수기에는 조기 마감 가능',
    ),
    _BookingChannel(
      channel: '리조트/호텔 투어 데스크',
      advantage: '숙소 픽업 연계가 쉽다',
      caution: '상품 구성이 제한될 수 있다',
    ),
    _BookingChannel(
      channel: '현지 해변/항구의 투어 판매처',
      advantage: '당일 즉시 예약이 가능하다',
      caution: '포함사항·안전장비·환불 규정 확인이 중요하다',
    ),
    _BookingChannel(
      channel: '현지 업체 공식 페이지/메신저',
      advantage: '맞춤형(프라이빗) 조율이 쉽다',
      caution: '결제 방식·영수증·환불 기준을 문서로 남기는 것이 안전하다',
    ),
  ];

  /// 좋은 상품 판별 체크포인트 데이터 (Good product check points)
  static const List<_CheckPoint> _checkPoints = [
    _CheckPoint(item: '포함', criteria: '보트·승무원, 구명조끼, 점심/물, 스노클링 장비 포함 여부'),
    _CheckPoint(item: '비용', criteria: '입장료/환경세/터미널비 포함인지, 현장 추가 결제 항목이 무엇인지'),
    _CheckPoint(item: '집결', criteria: '집결지(항구/해변), 픽업 포함 범위, 출발/복귀 시각'),
    _CheckPoint(item: '안전', criteria: '구명조끼 착용 원칙, 안전 브리핑, 기상 악화 시 운영 기준'),
    _CheckPoint(item: '변경', criteria: '기상으로 코스 변경 가능 여부, 취소/환불 규정'),
  ];

  /// 예약 절차 데이터 (Booking procedure data)
  static const List<_ProcedureItem> _procedures = [
    _ProcedureItem(content: '지역·코스 선택', point: '세부(막탄), 보라카이, 수빅/잠발레스 등'),
    _ProcedureItem(content: '형태 선택', point: '조인(그룹) / 프라이빗(단독 보트)'),
    _ProcedureItem(content: '포함·불포함 확인', point: '입장료/환경세, 장비(마스크·핀), 점심, 픽업'),
    _ProcedureItem(content: '예약 확정', point: '날짜·집결·인원·연락처(메신저 포함)'),
    _ProcedureItem(content: '결제', point: '온라인 결제 또는 현장 결제(영수증/메시지 기록 유지)'),
    _ProcedureItem(content: '투어 전날/당일 확인', point: '기상·집결·준비물·현지 추가 비용 재확인'),
  ];

  /// 현금 준비 항목 데이터 (Cash items data)
  static const List<_CashItem> _cashItems = [
    _CashItem(item: '환경세/입장료', description: '해양보호구역·섬별로 징수 가능'),
    _CashItem(item: '터미널비', description: '항구/선착장 시설 이용료 형태'),
    _CashItem(item: '장비 대여', description: '핀/방수팩/추가 스노클링 장비 등'),
    _CashItem(item: '기타', description: '섬 내 시설 이용료, 선택 액티비티'),
  ];

  /// 세부(막탄) 코스 데이터 (Cebu/Mactan course data)
  static const _RegionalCourse _cebuCourse = _RegionalCourse(
    icon: FontAwesomeIcons.lightFish,
    region: '세부(Cebu) — 막탄(Mactan) 인근',
    courses: [
      '날루수안(Nalusuan)',
      '힐루뚱안·길루뚱안(Hilutungan/Gilutungan)',
      '카오하간(Caohagan)',
    ],
    features: [
      '스노클링+섬 체류+점심 포함 구성 다수',
      '보트·연료·승무원, 구명조끼 포함',
      '호텔 픽업/드롭(상품별 상이)',
    ],
    note: '세부/막탄권은 입장료가 섬별로 분리되어 안내되는 경우가 있어, '
        '"투어비에 포함인지/현장 납부인지"를 예약 단계에서 문서로 확인하는 것이 중요하다.',
  );

  /// 보라카이 코스 데이터 (Boracay course data)
  static const _RegionalCourse _boracayCourse = _RegionalCourse(
    icon: FontAwesomeIcons.lightUmbrellaBeach,
    region: '보라카이(Boracay) — 반일(4~6시간)',
    courses: [
      'Crocodile Island (스노클링)',
      'Puka Beach (해변 체류)',
      'Crystal Cove (섬/동굴·트레일)',
      'Magic Island (클리프 다이빙, 선택)',
    ],
    features: [
      '비치+스노클링 중심 구성',
      '터미널/환경 관련 비용 별도 가능',
      '앱/온라인 등록 방식 안내 사례 있음',
    ],
    note: '보라카이는 입도/항구 절차(등록·수수료)가 함께 거론되는 경우가 있으므로, '
        '섬 투어 예약과 별개로 "입도 비용/등록 절차"를 최신 안내로 확인하는 것이 안전하다.',
  );

  /// 수빅/잠발레스 코스 데이터 (Subic/Zambales course data)
  static const _RegionalCourse _subicCourse = _RegionalCourse(
    icon: FontAwesomeIcons.lightMountainSun,
    region: '수빅(Subic) — 잠발레스(Zambales) 근교',
    courses: [
      '아나왕인 코브(Anawangin Cove)',
      '카포네스 섬(Capones Island)',
    ],
    features: [
      '푼다퀴트(Pundaquit) 출발 약 4시간 코스',
      '보트 이동, 현지 가이드, 구명조끼 포함(상품별)',
      '식사 미포함(조리도구 제공형 상품 존재)',
    ],
    note: null,
  );

  /// 기타 인기 지역 데이터 (Other popular regions data)
  static const List<_IslandTourInfoItem> _otherRegions = [
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightWater,
      title: '팔라완(엘니도/코론)',
      description: '라군·아일랜드 투어(코스 A/B/C/D 등으로 분류되는 경우가 많다)',
    ),
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightFish,
      title: '보홀(팡라오)',
      description: '발리카삭 등 스노클링/다이빙 포인트 중심',
    ),
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightIslandTropical,
      title: '팡가시난(헌드레드 아일랜즈)',
      description: '공원 등록비+보트 렌탈 요금 체계가 안내되는 경우가 많다',
    ),
  ];

  /// 한국인용 간추림 전략 데이터 (Korean user strategy data)
  static const List<_IslandTourInfoItem> _strategies = [
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightRoute,
      title: '코스가 표준화된 지역을 선택',
      description:
          '세부(막탄 3섬), 보라카이(크로커다일·푸카·크리스탈코브), 수빅 근교(푼다퀴트 출발 아나왕인·카포네스)',
    ),
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: '포함/불포함이 명시된 채널 우선',
      description: '일정·취소규정·포함사항 확인이 쉽다',
    ),
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금은 현장 비용 대비로 준비',
      description: '환경세/입장료/장비 대여가 대표적이다',
    ),
    _IslandTourInfoItem(
      icon: FontAwesomeIcons.lightLifeRing,
      title: '구명조끼 착용 원칙 준수',
      description: '안전 공지에 따라 코스 변경/취소 가능성이 있다',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'Guide to the Philippines - Boracay Island Hopping',
      url: 'https://guidetothephilippines.ph/articles/what-to-experience/boracay-island-hopping',
    ),
    _ReferenceUrl(
      title: 'GetYourGuide - Boracay Island Hopping Tour',
      url: 'https://www.getyourguide.com/boracay-l499/boracay-island-and-beach-hopping-boat-tour-with-snorkeling-t233152/',
    ),
    _ReferenceUrl(
      title: 'Klook - Cebu 3 Island Hopping Day Tour',
      url: 'https://www.klook.com/en-PH/activity/144372-3-island-hopping-day-tour-with-lunch-on-cebu-island/',
    ),
    _ReferenceUrl(
      title: 'TripAdvisor - Mactan Cebu Island Hopping',
      url: 'https://www.tripadvisor.com/AttractionProductReview-g667507-d18911264-Mactan_Cebu_Island_Hopping_with_Lunch_Gilutungan_Caohagan_Nalusuan-Mactan_Island_C.html',
    ),
    _ReferenceUrl(
      title: 'Cebu Travel Agency - Nalusuan Island Hopping',
      url: 'https://www.cebutravelagency.com/book-now/nalusuan-island-hopping/',
    ),
    _ReferenceUrl(
      title: 'Guide to PH - Anawangin Cove & Capones Island',
      url: 'https://guidetothephilippines.ph/trips-and-experiences/tours-by-destination/anawangin-cove-capones-island-zambales-private-tour',
    ),
    _ReferenceUrl(
      title: 'MARINA - 해상 안전 규정 (MC123)',
      url: 'https://marina.gov.ph/wp-content/uploads/2018/07/mc123.pdf',
    ),
    _ReferenceUrl(
      title: 'Hundred Islands Pangasinan Guide',
      url: 'https://chillandtravel.com/hundred-islands-pangasinan-guide/',
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
              FontAwesomeIcons.lightIslandTropical,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentIslandTour,
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

            /// [1. 빠른 요약]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBolt,
              title: '빠른 요약 (한국어 이용자 기준)',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildQuickSummary(context),
            SizedBox(height: sp.s24),

            /// [2. 당일 이용 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '당일 이용 체크리스트 (필수)',
              emoji: '🧾',
            ),
            SizedBox(height: sp.s12),
            _buildChecklistTable(context),
            SizedBox(height: sp.s24),

            /// [3. 아일랜드 호핑 정의]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleInfo,
              title: '아일랜드 호핑 정의와 기본 구조',
              emoji: '🚤',
            ),
            SizedBox(height: sp.s12),
            _buildDefinitionSection(context),
            SizedBox(height: sp.s24),

            /// [4. 업체 찾는 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMagnifyingGlass,
              title: '섬 투어 업체 찾는 방법 (인터넷 중심)',
              emoji: '🔍',
            ),
            SizedBox(height: sp.s12),
            _buildBookingChannelTable(context),
            SizedBox(height: sp.s16),
            _buildCheckPointsSection(context),
            SizedBox(height: sp.s24),

            /// [5. 예약 절차]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightListCheck,
              title: '예약 절차 (당일/단기 이용 기준)',
              emoji: '📋',
            ),
            SizedBox(height: sp.s12),
            _buildProcedureTimeline(context),
            SizedBox(height: sp.s24),

            /// [6. 준비물·복장·유의사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldCheck,
              title: '준비물·복장·현장 유의사항',
              emoji: '⚠️',
            ),
            SizedBox(height: sp.s12),
            _buildSafetySection(context),
            SizedBox(height: sp.s16),
            _buildSeasonSection(context),
            SizedBox(height: sp.s16),
            _buildCashSection(context),
            SizedBox(height: sp.s24),

            /// [7. 세부(막탄) 코스]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFish,
              title: '세부(Cebu) — 막탄(Mactan) 인근',
              emoji: '🐠',
            ),
            SizedBox(height: sp.s12),
            _buildRegionalCourseCard(context, _cebuCourse, Colors.cyan),
            SizedBox(height: sp.s24),

            /// [8. 보라카이 코스]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightUmbrellaBeach,
              title: '보라카이(Boracay)',
              emoji: '🏖️',
            ),
            SizedBox(height: sp.s12),
            _buildRegionalCourseCard(context, _boracayCourse, Colors.orange),
            SizedBox(height: sp.s24),

            /// [9. 수빅/잠발레스 코스]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMountainSun,
              title: '수빅(Subic) — 잠발레스(Zambales) 근교',
              emoji: '🏝️',
            ),
            SizedBox(height: sp.s12),
            _buildRegionalCourseCard(context, _subicCourse, Colors.green),
            SizedBox(height: sp.s24),

            /// [10. 기타 인기 지역]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '다른 인기 섬 투어 지역',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _otherRegions,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),
            SizedBox(height: sp.s24),

            /// [11. 한국인용 전략]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLightbulb,
              title: "한국인이 '쉽게 이용'하기 위한 최소 전략",
              emoji: '📌',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _strategies,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),
            SizedBox(height: sp.s24),

            /// [12. 참고 URL]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '참고 URL',
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
            Colors.cyan.withValues(alpha: 0.2),
            Colors.blue.withValues(alpha: 0.1),
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
              FaIcon(
                FontAwesomeIcons.lightIslandTropical,
                size: 24,
                color: Colors.cyan,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 섬 투어(아일랜드 호핑) 이용 안내',
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
            '아일랜드 호핑은 보트(대개 방카/아웃리거 보트)로 여러 섬·스노클링 포인트를 '
            '당일(4~8시간)에 순회하는 해양 액티비티입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLocationDot,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '대표 권역: 세부(막탄), 보라카이, 수빅/잠발레스',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
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

  /// 빠른 요약 빌드 (Quick summary build)
  Widget _buildQuickSummary(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBullet(
            context,
            '아일랜드 호핑은 보트로 여러 섬·스노클링 포인트를 당일(4~8시간)에 순회하는 해양 액티비티',
          ),
          SizedBox(height: sp.s8),
          Text(
            '현지(필리핀)에서 당일 이용 기준:',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: sp.s4),
          _buildSummaryStep(context, '1', '지역 선택'),
          _buildSummaryStep(context, '2', '업체/상품 비교'),
          _buildSummaryStep(context, '3', '예약·결제'),
          _buildSummaryStep(context, '4', '집결·탑승'),
          _buildSummaryStep(context, '5', '입장료/환경세 정산'),
          _buildSummaryStep(context, '6', '투어 진행'),
        ],
      ),
    );
  }

  /// 요약 불릿 빌드 (Summary bullet build)
  Widget _buildSummaryBullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(
          FontAwesomeIcons.lightCircleCheck,
          size: 14,
          color: Colors.cyan,
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 요약 단계 빌드 (Summary step build)
  Widget _buildSummaryStep(BuildContext context, String number, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.only(left: sp.s16, bottom: sp.s4),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.cyan,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
              color: Colors.cyan.withValues(alpha: 0.2),
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
                      color: Colors.cyan.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    '핵심',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan.shade800,
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
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s12),
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
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(
                      item.keyInfo,
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

  /// 정의 섹션 빌드 (Definition section build)
  Widget _buildDefinitionSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '하루 일정으로 보트를 타고 여러 섬/해양 포인트를 이동하며, 보통 다음 요소로 구성됩니다:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          _buildDefinitionItem(
            context,
            FontAwesomeIcons.lightRoute,
            '이동',
            '출발 항구(또는 해변 집결지) → 섬/포인트 A → 섬/포인트 B → 점심(섬 또는 선상) → 복귀',
          ),
          SizedBox(height: sp.s8),
          _buildDefinitionItem(
            context,
            FontAwesomeIcons.lightPersonSwimming,
            '활동',
            '스노클링(마스크·스노클), 수영, 해변 체류, 일부 지역은 클리프 다이빙(선택)',
          ),
          SizedBox(height: sp.s8),
          _buildDefinitionItem(
            context,
            FontAwesomeIcons.lightMoneyBill,
            '요금 구성',
            '투어비(보트·승무원·점심 등) + 현지 입장료/환경세/터미널비(지역별 상이) + 장비 대여/추가 옵션',
          ),
        ],
      ),
    );
  }

  /// 정의 아이템 빌드 (Definition item build)
  Widget _buildDefinitionItem(
    BuildContext context,
    IconData icon,
    String label,
    String description,
  ) {
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
            color: Colors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: FaIcon(icon, size: 14, color: Colors.cyan),
          ),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              Text(
                description,
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

  /// 예약 채널 테이블 빌드 (Booking channel table build)
  Widget _buildBookingChannelTable(BuildContext context) {
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
                  flex: 3,
                  child: Text(
                    '채널',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '장점',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    '주의',
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
          ...List.generate(_bookingChannels.length, (index) {
            final item = _bookingChannels[index];
            final isLast = index == _bookingChannels.length - 1;

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
                    flex: 3,
                    child: Text(
                      item.channel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.advantage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      item.caution,
                      style: theme.textTheme.bodySmall?.copyWith(
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

  /// 체크포인트 섹션 빌드 (Check points section build)
  Widget _buildCheckPointsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightClipboardCheck,
                size: 16,
                color: Colors.amber.shade700,
              ),
              SizedBox(width: sp.s8),
              Text(
                "💡 '좋은 상품' 판별 체크포인트 (문서로 확인 권장)",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._checkPoints.map((point) => Padding(
                padding: EdgeInsets.only(bottom: sp.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        point.item,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        point.criteria,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 이용 절차 타임라인 빌드 (Procedure timeline build)
  Widget _buildProcedureTimeline(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _procedures.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _procedures.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 타임라인 인디케이터 (Timeline indicator)
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.cyan,
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
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 32,
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 절차 내용 (Procedure content)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.content,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.point,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
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

  /// 안전 섹션 빌드 (Safety section build)
  Widget _buildSafetySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightLifeRing,
                size: 16,
                color: scheme.error,
              ),
              SizedBox(width: sp.s8),
              Text(
                '⚠️ 구명조끼 착용 원칙',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onErrorContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀 해상 안전 규정(공개 문서)에는 개방형 갑판(오픈덱) 승객선에서 승객의 '
            '구명조끼 착용을 탑승 전부터 항해 중 계속 요구하도록 한 내용이 포함되어 있습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s8),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 섬 투어에서 구명조끼 제공이 있더라도, 착용 지시가 있을 경우 반드시 착용하는 것이 기본입니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시즌 섹션 빌드 (Season section build)
  Widget _buildSeasonSection(BuildContext context) {
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
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCloudSun,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🌦️ 날씨·시즌 (운영에 직접 영향)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Row(
            children: [
              /// 아미한 (Amihan)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아미한(Amihan)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      Text(
                        '북동계절풍',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.blue.shade600,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '10~11월경 시작~3월 전후',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sp.s8),

              /// 하바갓 (Habagat)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '하바갓(Habagat)',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      Text(
                        '남서계절풍',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.orange.shade600,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '5~6월경 시작~10월 전후',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            '⚠️ 섬 투어는 풍랑·강우에 민감하므로 당일 아침 공지(집결지 변경, 출항 통제 등)를 확인해야 합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 현금 준비 섹션 빌드 (Cash section build)
  Widget _buildCashSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightMoneyBill,
                size: 16,
                color: Colors.green,
              ),
              SizedBox(width: sp.s8),
              Text(
                '💵 현금 준비 (자주 발생하는 항목)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._cashItems.map((item) => Padding(
                padding: EdgeInsets.only(bottom: sp.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.item,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        item.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 지역별 코스 카드 빌드 (Regional course card build)
  Widget _buildRegionalCourseCard(
    BuildContext context,
    _RegionalCourse course,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 코스 헤더 (Course header)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(course.icon, size: 20, color: accentColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '주요 방문지',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Wrap(
                      spacing: sp.s4,
                      runSpacing: sp.s4,
                      children: course.courses.map((c) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: accentColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 특징 (Features)
          Text(
            '포함사항 (일반 구성 예시)',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          ...course.features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: sp.s4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightCircleCheck,
                      size: 12,
                      color: accentColor,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        feature,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          /// 참고사항 (Note)
          if (course.note != null) ...[
            SizedBox(height: sp.s12),
            Container(
              padding: EdgeInsets.all(sp.s12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightLightbulb,
                    size: 14,
                    color: accentColor,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      '💡 ${course.note}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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
    );
  }

  /// 정보 카드 빌드 (Info cards build)
  Widget _buildInfoCards(
    BuildContext context,
    List<_IslandTourInfoItem> items,
    Color iconBgColor,
    Color iconColor,
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
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: FaIcon(item.icon, size: 18, color: iconColor)),
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
