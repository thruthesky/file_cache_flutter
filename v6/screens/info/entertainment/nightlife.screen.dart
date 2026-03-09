import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 안전 규정 아이템 데이터 클래스 (Safety Rule Item Data Class)
///
/// 기본 규정 및 안전 기준 정보를 담습니다.
/// Contains basic regulation and safety standard information.
class _SafetyRule {
  /// 항목 (Item)
  final String item;

  /// 핵심 내용 (Core content)
  final String content;

  const _SafetyRule({
    required this.item,
    required this.content,
  });
}

/// 지역 권역 데이터 클래스 (Region Area Data Class)
///
/// 지역별 밤문화 권역 정보를 담습니다.
/// Contains regional nightlife area information.
class _RegionArea {
  /// 도시 (City)
  final String city;

  /// 권역 (Area)
  final String area;

  /// 성격 (Character)
  final String character;

  /// 이동 수단 (Transport)
  final String transport;

  const _RegionArea({
    required this.city,
    required this.area,
    required this.character,
    required this.transport,
  });
}

/// 업장 정보 데이터 클래스 (Venue Info Data Class)
///
/// 대표 업장 및 장소 정보를 담습니다.
/// Contains representative venue and place information.
class _VenueInfo {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 타입 (Type)
  final String type;

  /// 장소명 (Place name)
  final String name;

  /// 위치 (Location)
  final String location;

  /// 비고 (Notes)
  final String notes;

  const _VenueInfo({
    required this.icon,
    required this.type,
    required this.name,
    required this.location,
    required this.notes,
  });
}

/// 체크리스트 아이템 데이터 클래스 (Checklist Item Data Class)
class _ChecklistItem {
  /// 항목 (Item)
  final String item;

  /// 체크 내용 (Check content)
  final String content;

  const _ChecklistItem({
    required this.item,
    required this.content,
  });
}

/// 빠른 요약 아이템 데이터 클래스 (Quick Summary Item Data Class)
class _QuickSummaryItem {
  /// 목적 (Purpose)
  final String purpose;

  /// 추천 (Recommendation)
  final String recommendation;

  const _QuickSummaryItem({
    required this.purpose,
    required this.recommendation,
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

/// 밤문화 정보 화면 (Nightlife Screen)
///
/// 필리핀 밤문화 관련 정보를 제공합니다.
/// Provides information about nightlife in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// NightlifeScreen.push(context);
/// ```
class NightlifeScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Nightlife';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const NightlifeScreen({super.key});

  @override
  State<NightlifeScreen> createState() => _NightlifeScreenState();
}

class _NightlifeScreenState extends State<NightlifeScreen> {
  /// 기본 규정·안전 기준 데이터 (Basic regulations and safety standards data)
  static const List<_SafetyRule> _safetyRules = [
    _SafetyRule(
      item: '연령',
      content: '필리핀의 법정 음주 가능 최소 연령은 18세로 알려져 있다.',
    ),
    _SafetyRule(
      item: '신분증',
      content: '입장 심사가 있는 업장은 여권(원본) 또는 필리핀 체류증(예: ACR I-Card) 제시를 요구할 수 있다.',
    ),
    _SafetyRule(
      item: '결제',
      content: '바·클럽은 카드 결제가 가능한 곳이 많으나, 입장료/보증금/팁 등은 현금이 더 편리한 경우가 있어 소액 현금을 준비하는 편이 안전하다.',
    ),
    _SafetyRule(
      item: '귀가',
      content: '심야 이동은 도보보다 Grab(차량 호출) 등 호출형 이동을 우선 고려하는 편이 안전하다.',
    ),
    _SafetyRule(
      item: '음료 안전',
      content: '음료는 가능하면 직접 수령·관리하고, 모르는 사람이 건네는 음료는 피하는 것이 일반적 안전수칙이다.',
    ),
    _SafetyRule(
      item: '법·질서',
      content: '업장 내외에서 불법 행위(마약 등)는 중대 범죄로 취급된다. 합법적 범위의 오락(노래, 음료, 공연)만 이용하는 것이 안전하다.',
    ),
  ];

  /// 지역별 밤문화 권역 데이터 (Regional nightlife areas data)
  static const List<_RegionArea> _regionAreas = [
    _RegionArea(
      city: '마카티',
      area: '포블라시온(Poblacion)',
      character: '바 호핑·루프탑·칵테일 중심, 도보 이동 동선 구성 가능',
      transport: 'Grab/도보',
    ),
    _RegionArea(
      city: 'BGC(타기그)',
      area: 'Uptown Bonifacio',
      character: '대형 복합 클럽 단지 및 바 이용 가능(예: The Palace)',
      transport: 'Grab',
    ),
    _RegionArea(
      city: '세부',
      area: 'IT Park',
      character: '비교적 정돈된 상권으로 소개되며 바·라운지 이용 가능',
      transport: 'Grab/택시',
    ),
    _RegionArea(
      city: '세부(막탄)',
      area: 'Punta Engaño 일대',
      character: '리조트·비치클럽 기반(예: Ibiza)',
      transport: 'Grab/택시',
    ),
    _RegionArea(
      city: '마닐라',
      area: 'Manila Baywalk(Roxas Blvd)',
      character: '해안 산책로·노을·공연/버스킹 언급 사례 존재',
      transport: 'Grab',
    ),
  ];

  /// 마카티 업장 데이터 (Makati venues data)
  static const List<_VenueInfo> _makatiVenues = [
    _VenueInfo(
      icon: FontAwesomeIcons.lightMartiniGlass,
      type: '칵테일/바',
      name: 'Agimat at Ugat',
      location: '포블라시온, 마카티',
      notes: '운영시간 5pm~2am 안내 (공식 페이지)',
    ),
    _VenueInfo(
      icon: FontAwesomeIcons.lightBuilding,
      type: '루프탑',
      name: 'Firefly Roofdeck',
      location: 'City Garden Grand Hotel, 마카티',
      notes: '호텔 공식 소개',
    ),
    _VenueInfo(
      icon: FontAwesomeIcons.lightMugHot,
      type: '커피+칵테일',
      name: 'The Curator',
      location: '레가스피 빌리지, 마카티',
      notes: '커피/칵테일 복합 콘셉트',
    ),
  ];

  /// BGC 업장 데이터 (BGC venues data)
  static const List<_VenueInfo> _bgcVenues = [
    _VenueInfo(
      icon: FontAwesomeIcons.lightBuildingColumns,
      type: '복합 클럽',
      name: 'The Palace Manila',
      location: 'Uptown Bonifacio, Taguig(BGC)',
      notes: '복합 베뉴 구성 (공식 사이트)',
    ),
    _VenueInfo(
      icon: FontAwesomeIcons.lightMusic,
      type: '클럽(단지 내)',
      name: 'Xylo',
      location: 'The Palace 단지 내',
      notes: 'BGC 가이드형 소개',
    ),
  ];

  /// 세부 업장 데이터 (Cebu venues data)
  static const List<_VenueInfo> _cebuVenues = [
    _VenueInfo(
      icon: FontAwesomeIcons.lightUmbrellaBeach,
      type: '비치클럽',
      name: 'Ibiza (Mövenpick)',
      location: 'Punta Engaño, Mactan',
      notes: '호텔 공식 소개',
    ),
    _VenueInfo(
      icon: FontAwesomeIcons.lightCity,
      type: '상권(권역)',
      name: 'Cebu IT Park',
      location: '세부 시티',
      notes: 'IT Park가 야간 상권으로 소개',
    ),
  ];

  /// 마닐라 베이 데이터 (Manila Bay data)
  static const List<_VenueInfo> _manilaBayVenues = [
    _VenueInfo(
      icon: FontAwesomeIcons.lightWater,
      type: '해안 산책',
      name: 'Manila Baywalk',
      location: 'Roxas Boulevard 일대(2km 산책로)',
      notes: 'Baywalk 정의/구간 안내',
    ),
    _VenueInfo(
      icon: FontAwesomeIcons.lightSun,
      type: '야간 분위기',
      name: 'Baywalk 주변',
      location: '야간 버스킹·공연·노점 언급 사례',
      notes: '관광 안내 성격 자료',
    ),
  ];

  /// 당일 체크리스트 데이터 (Day checklist data)
  static const List<_ChecklistItem> _checklist = [
    _ChecklistItem(
      item: '이동',
      content: '출발/귀가 모두 Grab 기준으로 계획한다.',
    ),
    _ChecklistItem(
      item: '신분증',
      content: '여권(원본) 또는 체류증을 준비한다.',
    ),
    _ChecklistItem(
      item: '예산',
      content: '입장료·보증금·팁 등 변수 대비 소액 현금을 포함한다.',
    ),
    _ChecklistItem(
      item: '복장',
      content: '클럽은 스마트 캐주얼을 기본으로 준비한다.',
    ),
    _ChecklistItem(
      item: '커뮤니케이션',
      content: '영어로 주문/결제가 가능하며, 메뉴/영수증 기반 결제를 원칙으로 한다.',
    ),
    _ChecklistItem(
      item: '일정',
      content: '1차(식사) → 2차(칵테일/루프탑) → 3차(클럽/라이브) 순서가 일반적이다.',
    ),
  ];

  /// 간추림 데이터 (Quick summary data)
  static const List<_QuickSummaryItem> _quickSummary = [
    _QuickSummaryItem(
      purpose: '바 호핑',
      recommendation: '마카티 포블라시온에서 2~3곳 이동',
    ),
    _QuickSummaryItem(
      purpose: '대형 클럽',
      recommendation: 'BGC The Palace Manila 단지',
    ),
    _QuickSummaryItem(
      purpose: '선셋+한잔',
      recommendation: '마닐라 Baywalk 또는 막탄 Ibiza',
    ),
    _QuickSummaryItem(
      purpose: '라이브뮤직',
      recommendation: '메트로 마닐라 공연장(SaGuijo, 19 East 등) 라인업 사전 확인',
    ),
    _QuickSummaryItem(
      purpose: 'JTV/KTV',
      recommendation: '"KTV/JTV" 검색 → 룸요금/최소주문 확인 → 영수증 결제',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs data)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: 'The Palace Manila (공식)',
      url: 'https://www.thepalacemanila.com/',
    ),
    _ReferenceUrl(
      title: 'Agimat at Ugat (공식)',
      url: 'https://www.destileriabarako.com/agimatatugat',
    ),
    _ReferenceUrl(
      title: 'Firefly Roofdeck (호텔 공식)',
      url: 'https://www.citygardengrandhotel.com/firefly.html',
    ),
    _ReferenceUrl(
      title: 'The Curator (매체 소개)',
      url: 'https://philstarlife.com/100list/748953-the-curator',
    ),
    _ReferenceUrl(
      title: 'Mövenpick Cebu - Ibiza (공식)',
      url: 'https://movenpick.accor.com/en/asia/philippines/cebu/hotel-mactan-island-cebu/restaurants/ibiza.html',
    ),
    _ReferenceUrl(
      title: 'Manila Baywalk (개요)',
      url: 'https://en.wikipedia.org/wiki/Baywalk',
    ),
    _ReferenceUrl(
      title: 'Songkick (마닐라 공연 일정)',
      url: 'https://www.songkick.com/metro-areas/31573-philippines-manila',
    ),
    _ReferenceUrl(
      title: 'Bandsintown (마닐라 공연/이벤트)',
      url: 'https://www.bandsintown.com/c/manila-philippines',
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
              FontAwesomeIcons.lightMartiniGlass,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentNightlife,
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
            /// [헤더 배너 - 범위와 전제]
            _buildHeaderBanner(context),
            SizedBox(height: sp.s24),

            /// [1. 기본 규정·안전 기준]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldCheck,
              title: '기본 규정·안전 기준',
              emoji: '🛡️',
            ),
            SizedBox(height: sp.s12),
            _buildSafetyRulesTable(context),
            SizedBox(height: sp.s24),

            /// [2. 바 호핑]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightWineGlass,
              title: '바 호핑 (Bar Hopping)',
              emoji: '🍷',
            ),
            SizedBox(height: sp.s12),
            _buildBarHoppingSection(context),
            SizedBox(height: sp.s24),

            /// [3. 나이트클럽]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCompactDisc,
              title: '나이트클럽 (Nightclub)',
              emoji: '🎵',
            ),
            SizedBox(height: sp.s12),
            _buildNightclubSection(context),
            SizedBox(height: sp.s24),

            /// [4. 칵테일 바·루프탑 바]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightGlassWaterDroplet,
              title: '칵테일 바·루프탑 바',
              emoji: '🍸',
            ),
            SizedBox(height: sp.s12),
            _buildCocktailBarSection(context),
            SizedBox(height: sp.s24),

            /// [5. 라이브 뮤직]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightGuitar,
              title: '라이브 뮤직 (밴드·재즈·공연)',
              emoji: '🎸',
            ),
            SizedBox(height: sp.s12),
            _buildLiveMusicSection(context),
            SizedBox(height: sp.s24),

            /// [6. 선셋 바]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightSunrise,
              title: '바닷가 선셋 + 한잔',
              emoji: '🌅',
            ),
            SizedBox(height: sp.s12),
            _buildSunsetBarSection(context),
            SizedBox(height: sp.s24),

            /// [7. JTV/KTV]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMicrophone,
              title: 'JTV/KTV (룸 카라오케)',
              emoji: '🎤',
            ),
            SizedBox(height: sp.s12),
            _buildKtvSection(context),
            SizedBox(height: sp.s24),

            /// [8. 지역별 밤문화 권역 요약]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMapLocationDot,
              title: '지역별 밤문화 권역 요약',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildRegionAreasTable(context),
            SizedBox(height: sp.s24),

            /// [9. 대표 업장·장소 예시 - 마카티]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '마카티(포블라시온 중심)',
              emoji: '🏙️',
            ),
            SizedBox(height: sp.s12),
            _buildVenueCards(context, _makatiVenues),
            SizedBox(height: sp.s24),

            /// [10. 대표 업장·장소 예시 - BGC]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: 'BGC (업타운 중심)',
              emoji: '🌃',
            ),
            SizedBox(height: sp.s12),
            _buildVenueCards(context, _bgcVenues),
            SizedBox(height: sp.s24),

            /// [11. 대표 업장·장소 예시 - 세부]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '세부 (IT Park · 막탄)',
              emoji: '🏝️',
            ),
            SizedBox(height: sp.s12),
            _buildVenueCards(context, _cebuVenues),
            SizedBox(height: sp.s24),

            /// [12. 대표 업장·장소 예시 - 마닐라 베이]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLocationDot,
              title: '마닐라 베이 (노을·야간 산책)',
              emoji: '🌊',
            ),
            SizedBox(height: sp.s12),
            _buildVenueCards(context, _manilaBayVenues),
            SizedBox(height: sp.s24),

            /// [13. 당일 실행 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardListCheck,
              title: '당일(1회) 실행 체크리스트',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildChecklistSection(context),
            SizedBox(height: sp.s24),

            /// [14. 한국인 편리한 포인트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFaceSmile,
              title: '한국인이 특히 편리한 포인트',
              emoji: '🇰🇷',
            ),
            SizedBox(height: sp.s12),
            _buildKoreanConvenienceSection(context),
            SizedBox(height: sp.s24),

            /// [15. 간추림 (모바일용 초압축)]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBolt,
              title: "간추림 (모바일용 초압축)",
              emoji: '📱',
            ),
            SizedBox(height: sp.s12),
            _buildQuickSummarySection(context),
            SizedBox(height: sp.s24),

            /// [16. 참고 URL]
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
  /// 범위와 전제 설명을 포함합니다.
  Widget _buildHeaderBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.2),
            Colors.indigo.withValues(alpha: 0.1),
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
                FontAwesomeIcons.lightMartiniGlass,
                size: 24,
                color: Colors.purple,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 밤문화 안내서',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),

          /// 태그 라인 (Tagline)
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s4,
            children: [
              _buildTag(context, '바 호핑'),
              _buildTag(context, '나이트클럽'),
              _buildTag(context, 'JTV/KTV'),
              _buildTag(context, '라이브뮤직'),
              _buildTag(context, '선셋 바'),
            ],
          ),
          SizedBox(height: sp.s12),

          Text(
            '필리핀 현지(필리핀 내)에서 당일 또는 1회성으로 밤문화를 이용하는 방법을 사실 기반으로 정리한 자료입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '한국에서 예약·출국 패키지를 전제로 하지 않으며, 현지에서 바로 찾고 이용하는 방식(지도 앱, 현장 입장, 당일 예약)을 중심으로 구성했습니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// 태그 위젯 빌드 (Tag widget build)
  Widget _buildTag(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
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

  /// 안전 규정 테이블 빌드 (Safety rules table build)
  Widget _buildSafetyRulesTable(BuildContext context) {
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
                  flex: 5,
                  child: Text(
                    '핵심',
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
          ...List.generate(_safetyRules.length, (index) {
            final rule = _safetyRules[index];
            final isLast = index == _safetyRules.length - 1;

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
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rule.item,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    flex: 5,
                    child: Text(
                      rule.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
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

  /// 바 호핑 섹션 빌드 (Bar hopping section build)
  Widget _buildBarHoppingSection(BuildContext context) {
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
          /// 정의 (Definition)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightCircleInfo,
            title: '정의',
            content: '한 지역(골목/거리)에서 여러 바를 짧은 간격으로 이동하며 음료를 즐기는 방식이다.',
          ),
          SizedBox(height: sp.s12),

          /// 대표 권역 (Representative region)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightLocationDot,
            title: '대표 권역',
            content: '마카티 포블라시온(Poblacion) 일대는 바·펍·스피크이지가 밀집해 바 호핑 동선이 형성되기 쉽다.',
          ),
          SizedBox(height: sp.s16),

          /// 이용 절차 (Procedure)
          Text(
            '📋 바 호핑 1회 이용 절차 (현지 당일 기준)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildProcedureList(context, [
            'Google Maps에서 "Poblacion Makati bars" 등으로 권역을 먼저 지정한다.',
            '1차(식사 겸), 2차(칵테일), 3차(클럽/라이브) 순으로 3곳 내외를 고른다.',
            '인기 업장은 대기 가능성이 있어, 공식 웹/SNS로 당일 예약 또는 오픈 시간대(이른 저녁) 방문을 고려한다.',
          ]),
        ],
      ),
    );
  }

  /// 정보 행 빌드 (Info row build)
  Widget _buildInfoRow(
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
          padding: EdgeInsets.all(sp.s4),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(6),
          ),
          child: FaIcon(icon, size: 12, color: scheme.primary),
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
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

  /// 절차 리스트 빌드 (Procedure list build)
  Widget _buildProcedureList(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return Padding(
          padding: EdgeInsets.only(bottom: sp.s4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 나이트클럽 섹션 빌드 (Nightclub section build)
  Widget _buildNightclubSection(BuildContext context) {
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
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightLocationDot,
            title: '대표 권역',
            content: 'BGC(보니파시오 글로벌 시티)는 대형 복합 클럽이 있는 편이며, 대표 사례로 The Palace Manila 복합 단지가 운영 정보를 공개하고 있다.',
          ),
          SizedBox(height: sp.s12),

          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightDoorOpen,
            title: '입장 흐름(일반)',
            content: '보안 검색 → 신분증 확인 → 입장료(또는 테이블 예약 확인) → 내부 바/테이블 이용',
          ),
          SizedBox(height: sp.s12),

          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightShirt,
            title: '복장(일반)',
            content: '스마트 캐주얼을 요구하는 클럽이 많아 슬리퍼·반바지·과도한 캐주얼은 제한될 수 있다(업장별 상이).',
          ),
        ],
      ),
    );
  }

  /// 칵테일 바 섹션 빌드 (Cocktail bar section build)
  Widget _buildCocktailBarSection(BuildContext context) {
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
            '마카티는 오피스·주거가 혼재해 루프탑/칵테일 바가 발달해 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 대표 업장 리스트 (Representative venues list)
          _buildHighlightCard(
            context,
            icon: FontAwesomeIcons.lightBuilding,
            title: 'Firefly Roofdeck',
            subtitle: '마카티, City Garden Grand Hotel',
            description: '호텔 공식 채널에서 루프탑 바로 안내',
          ),
          SizedBox(height: sp.s8),
          _buildHighlightCard(
            context,
            icon: FontAwesomeIcons.lightMugHot,
            title: 'The Curator',
            subtitle: '마카티 레가스피 빌리지',
            description: '커피/칵테일 복합 콘셉트로 매체에 위치·운영 콘셉트가 소개',
          ),
        ],
      ),
    );
  }

  /// 하이라이트 카드 빌드 (Highlight card build)
  Widget _buildHighlightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
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
            child: FaIcon(icon, size: 16, color: scheme.onPrimaryContainer),
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
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  description,
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

  /// 라이브 뮤직 섹션 빌드 (Live music section build)
  Widget _buildLiveMusicSection(BuildContext context) {
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
            '메트로 마닐라에는 라이브 공연을 상시/정기적으로 운영하는 바·공연장이 다수 존재합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 대표 공연장 (Representative venues)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightMusic,
                  size: 20,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '대표 공연장 예시',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.tertiary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        'SaGuijo, Mow\'s, 19 East 등',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s12),

          /// 팁 (Tips)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLightbulb,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '일정은 변동 가능성이 높으므로, 실제 방문 전에는 공식 SNS/예매 페이지로 당일 라인업을 확인하는 방식이 일반적입니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
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

  /// 선셋 바 섹션 빌드 (Sunset bar section build)
  Widget _buildSunsetBarSection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.15),
            Colors.pink.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 세부 막탄 (Cebu Mactan)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightUmbrellaBeach,
            title: '세부 막탄(Mactan, Lapu-Lapu)',
            content: '리조트/비치클럽 중심의 야간 이용이 가능하며, Mövenpick Hotel Mactan Island Cebu의 Ibiza는 다이닝·엔터테인먼트 베뉴로 안내됩니다.',
          ),
          SizedBox(height: sp.s12),

          /// 마닐라 베이 (Manila Bay)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightWater,
            title: '마닐라 베이(Baywalk, Roxas Blvd)',
            content: '해안 산책로로 알려져 있으며, 산책·노을 감상과 함께 노점/공연(버스킹 등)이 언급되는 관광 안내 자료가 존재합니다.',
          ),
        ],
      ),
    );
  }

  /// KTV 섹션 빌드 (KTV section build)
  Widget _buildKtvSection(BuildContext context) {
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
          /// KTV 정의 (KTV Definition)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightMicrophone,
            title: 'KTV',
            content: '일반적으로 룸(개별실)에서 노래를 부르고 음료/안주를 주문하는 형태를 의미합니다.',
          ),
          SizedBox(height: sp.s12),

          /// JTV 정의 (JTV Definition)
          _buildInfoRow(
            context,
            icon: FontAwesomeIcons.lightMicrophoneStand,
            title: 'JTV',
            content: '현지에서 "JTV" 명칭을 사용하는 업장들이 존재하며, 일부 안내 자료·리뷰에서 JTV 라운지/클럽 형태의 업장이 소개됩니다(예: Malate 지역).',
          ),
          SizedBox(height: sp.s16),

          /// 주의 사항 (Caution)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 16,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ 주의 사항',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.error,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '업장 성격은 매우 다양하며, 일부 업장은 불법 행위와 연결될 소지가 있습니다. 이용 시에는 합법적 범위(노래·음료·공연)를 벗어나는 제안은 즉시 거절하고, 영수증·메뉴 기반으로 결제하는 방식이 안전합니다.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// JTV/KTV 이용 절차 (Procedure)
          Text(
            '📋 JTV/KTV 1회 이용 기본 절차',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildKtvProcedureTable(context),
        ],
      ),
    );
  }

  /// KTV 절차 테이블 빌드 (KTV procedure table build)
  Widget _buildKtvProcedureTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final procedures = [
      {'step': '1', 'content': 'Google Maps에서 "KTV", "JTV", "Karaoke room" 등으로 검색 후 리뷰·위치를 확인한다.'},
      {'step': '2', 'content': '입장 시 룸 요금/최소 주문(최소 소비금액) 여부를 먼저 확인한다(메뉴/요금표 확인).'},
      {'step': '3', 'content': '결제는 가능하면 카운터 결제 + 영수증 수령을 원칙으로 한다.'},
      {'step': '4', 'content': '동행 인원·이용 시간은 사전에 합의하고, 분쟁 소지가 있으면 즉시 퇴장한다.'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: procedures.map((proc) {
          return Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              border: proc != procedures.last
                  ? Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      proc['step']!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    proc['content']!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 지역별 권역 테이블 빌드 (Region areas table build)
  Widget _buildRegionAreasTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _regionAreas.map((area) {
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
              /// 도시 태그 (City tag)
              Container(
                width: 70,
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s8,
                  vertical: sp.s4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  area.city,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: sp.s12),

              /// 내용 (Content)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.area,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      area.character,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightCar,
                          size: 10,
                          color: scheme.primary,
                        ),
                        SizedBox(width: sp.s4),
                        Text(
                          area.transport,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w500,
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

  /// 업장 카드 빌드 (Venue cards build)
  Widget _buildVenueCards(BuildContext context, List<_VenueInfo> venues) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: venues.map((venue) {
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(venue.icon, size: 18, color: Colors.purple),
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
                            horizontal: sp.s4,
                            vertical: sp.s4,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            venue.type,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      venue.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightLocationDot,
                          size: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: sp.s4),
                        Expanded(
                          child: Text(
                            venue.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      venue.notes,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontStyle: FontStyle.italic,
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

  /// 체크리스트 섹션 빌드 (Checklist section build)
  Widget _buildChecklistSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _checklist.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightSquareCheck,
                  size: 16,
                  color: Colors.green,
                ),
                SizedBox(width: sp.s8),
                Container(
                  width: 80,
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.item,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    item.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 한국인 편리한 포인트 섹션 빌드 (Korean convenience section build)
  Widget _buildKoreanConvenienceSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final points = [
      '필리핀 주요 도시는 영어 사용 비중이 높아 기본 주문·결제·이동이 비교적 수월한 편이다.',
      '마카티·BGC·세부(IT Park/막탄) 등은 Grab 호출 기반 이동이 가능해, 당일 동선 운영이 용이하다.',
      '라이브 공연은 날짜별 라인업 변동이 잦아, Songkick/Bandsintown 등 이벤트 캘린더 또는 업장 공식 SNS로 당일 확인하는 방식이 일반적이다.',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: points.map((point) {
          return Padding(
            padding: EdgeInsets.only(bottom: sp.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleCheck,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    point,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 빠른 요약 섹션 빌드 (Quick summary section build)
  Widget _buildQuickSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _quickSummary.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.purpose,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    item.recommendation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 참고 URL 섹션 빌드 (Reference URLs section build)
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
