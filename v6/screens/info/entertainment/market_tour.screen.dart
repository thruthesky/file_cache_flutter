import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 전통시장 데이터 클래스 (Market Data Class)
///
/// 각 전통시장의 이름, 지역, 핵심 특징, 대표 품목, 결제 방식을 담습니다.
/// Contains name, region, core features, main products, and payment method for each market.
class _MarketItem {
  /// 시장 이름 (Market name)
  final String name;

  /// 지역 (Region)
  final String region;

  /// 핵심 특징 (Core feature)
  final String core;

  /// 대표 품목 (Main products)
  final String products;

  /// 결제 방식 (Payment method)
  final String payment;

  const _MarketItem({
    required this.name,
    required this.region,
    required this.core,
    required this.products,
    required this.payment,
  });
}

/// 이용 절차 아이템 데이터 클래스 (Procedure Item Data Class)
///
/// 이용 절차의 단계, 방법, 메모를 담습니다.
/// Contains step, method, and memo for each procedure item.
class _ProcedureItem {
  /// 단계 (Step)
  final String step;

  /// 방법 (Method)
  final String method;

  /// 메모 (Memo)
  final String memo;

  const _ProcedureItem({
    required this.step,
    required this.method,
    required this.memo,
  });
}

/// 준비물 아이템 데이터 클래스 (Checklist Item Data Class)
///
/// 준비물과 목적을 담습니다.
/// Contains preparation item and its purpose.
class _ChecklistItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 준비물 (Preparation)
  final String item;

  /// 목적 (Purpose)
  final String purpose;

  const _ChecklistItem({
    required this.icon,
    required this.item,
    required this.purpose,
  });
}

/// 안전 수칙 데이터 클래스 (Safety Tip Data Class)
///
/// 안전 관련 항목과 권고사항을 담습니다.
/// Contains safety item and recommendation.
class _SafetyTip {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 항목 (Item)
  final String item;

  /// 권고 (Recommendation)
  final String recommendation;

  const _SafetyTip({
    required this.icon,
    required this.item,
    required this.recommendation,
  });
}

/// 비교 항목 데이터 클래스 (Comparison Item Data Class)
///
/// 전통시장과 쇼핑몰 비교 항목을 담습니다.
/// Contains comparison between traditional market and shopping mall.
class _ComparisonItem {
  /// 항목 (Item)
  final String item;

  /// 전통시장 (Traditional market)
  final String traditional;

  /// 쇼핑몰 (Shopping mall)
  final String mall;

  const _ComparisonItem({
    required this.item,
    required this.traditional,
    required this.mall,
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

/// 시장 투어 정보 화면 (Market Tour Screen)
///
/// 필리핀 전통 로컬 시장(팔렝케) 문화와 이용 가이드를 제공합니다.
/// Provides information about traditional Philippine markets (palengke).
///
/// ### 사용법 (Usage):
/// ```dart
/// MarketTourScreen.push(context);
/// ```
class MarketTourScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/MarketTour';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const MarketTourScreen({super.key});

  @override
  State<MarketTourScreen> createState() => _MarketTourScreenState();
}

class _MarketTourScreenState extends State<MarketTourScreen> {
  /// 지역별 대표 전통시장 10선 데이터 (Top 10 traditional markets data)
  static const List<_MarketItem> _markets = [
    _MarketItem(
      name: '디비소리아(Divisoria)',
      region: '마닐라',
      core: '저가·도매 성격 강한 대형 상권',
      products: '의류/잡화/원단/생활용품',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '키아포(Quiapo)',
      region: '마닐라',
      core: '종교권역 + 생활상권 결합',
      products: '종교용품/약재/전자·부품/잡화',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '바클라란(Baclaran)',
      region: '파라냐케',
      core: '성당 권역 주변 대형 시장권',
      products: '의류/가방/잡화/간식',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '당와(Dangwa) 꽃시장',
      region: '마닐라',
      core: '도매 꽃 중심',
      products: '생화/화환/꽃다발',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '카본(Carbon)',
      region: '세부',
      core: '대규모 공설시장',
      products: '농수산물/생활용품',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '타보안(Tabaoan)',
      region: '세부',
      core: '건어물 특화',
      products: '말린 생선/건해산물',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '바기오 공설시장',
      region: '바기오',
      core: '고랭지 농산·기념품',
      products: '채소/딸기/특산품',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '방케로한(Bankerohan)',
      region: '다바오',
      core: '농산·과일 유통 중심',
      products: '열대과일/채소',
      payment: '현금 중심',
    ),
    _MarketItem(
      name: '카르티마(Cartimar)',
      region: '파사이',
      core: '복합 시장(특히 펫 상권)',
      products: '애완동물/용품/잡화',
      payment: '점포별 상이',
    ),
    _MarketItem(
      name: '파머스(Farmers) 마켓',
      region: '퀘존시티',
      core: '대형 웻마켓',
      products: '해산물/정육/농산물',
      payment: '점포별 상이',
    ),
  ];

  /// 당일 이용 체크리스트 데이터 (Day use checklist data)
  static const List<_ChecklistItem> _checklist = [
    _ChecklistItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      item: '소액 현금(20/50/100페소 등)',
      purpose: '현금 결제 구역 대응',
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightBagShopping,
      item: '에코백/장바구니',
      purpose: '다량 구매 대응',
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightBottleWater,
      item: '물·가벼운 복장',
      purpose: '야외 구역 이동 대비',
    ),
    _ChecklistItem(
      icon: FontAwesomeIcons.lightMobileScreen,
      item: '배송 앱(선택)',
      purpose: '대량 구매 시 당일 발송 보조\n(GrabExpress/Lalamove 등)',
    ),
  ];

  /// 추천 이용 흐름 데이터 (Recommended procedure data)
  static const List<_ProcedureItem> _procedures = [
    _ProcedureItem(
      step: '① 목적 정리',
      method: '품목/수량/예산 메모',
      memo: '"개당/세트/도매" 기준 병기',
    ),
    _ProcedureItem(
      step: '② 이동',
      method: '지도 앱 + 호출 이동(Grab 등)',
      memo: '혼잡 시간대 이동시간 증가 가능',
    ),
    _ProcedureItem(
      step: '③ 구매',
      method: '구역 2~3곳 비교 후 구매',
      memo: '동일 품목도 단가·품질 편차 존재',
    ),
    _ProcedureItem(
      step: '④ 결제',
      method: '현금 중심, 일부 점포 전자결제',
      memo: '거스름돈 확보 필요',
    ),
    _ProcedureItem(
      step: '⑤ 운반/발송',
      method: '직접 운반 또는 즉시 배송',
      memo: '무거운 품목·다량 구매 시 유용',
    ),
  ];

  /// 안전 수칙 데이터 (Safety tips data)
  static const List<_SafetyTip> _safetyTips = [
    _SafetyTip(
      icon: FontAwesomeIcons.lightBagShopping,
      item: '소지품',
      recommendation: '가방은 몸 앞으로 착용, 휴대폰·지갑은 안쪽 보관',
    ),
    _SafetyTip(
      icon: FontAwesomeIcons.lightWallet,
      item: '현금',
      recommendation: '큰 금액 분산 보관, 계산 시 필요한 금액만 꺼내기',
    ),
    _SafetyTip(
      icon: FontAwesomeIcons.lightPersonWalking,
      item: '이동',
      recommendation: '혼잡 구역에서 정지·대화로 주의 분산 시 경계 강화',
    ),
    _SafetyTip(
      icon: FontAwesomeIcons.lightPassport,
      item: '문서',
      recommendation: '여권 원본은 필요 시에만 소지(사본/사진 활용)',
    ),
  ];

  /// 전통시장 vs 쇼핑몰 비교 데이터 (Comparison data)
  static const List<_ComparisonItem> _comparisons = [
    _ComparisonItem(
      item: '가격',
      traditional: '점포별 편차 큼',
      mall: '가격표 기준',
    ),
    _ComparisonItem(
      item: '결제',
      traditional: '현금 중심(점포별 상이)',
      mall: '카드·전자지갑 등 확대',
    ),
    _ComparisonItem(
      item: '환경',
      traditional: '혼잡·개방형 구역 다수',
      mall: '실내형(에어컨)',
    ),
    _ComparisonItem(
      item: '구매 방식',
      traditional: '수량·조건 협의 가능',
      mall: '정가·표준 결제',
    ),
  ];

  /// 참고 URL 데이터 (Reference URLs)
  static const List<_ReferenceUrl> _referenceUrls = [
    _ReferenceUrl(
      title: '디비소리아(상권 개요)',
      url: 'https://en.wikipedia.org/wiki/Divisoria',
    ),
    _ReferenceUrl(
      title: '투투반 센터(168·999 몰 언급)',
      url: 'https://en.wikipedia.org/wiki/Tutuban_Center',
    ),
    _ReferenceUrl(
      title: '디비소리아 연말 혼잡 보도',
      url: 'https://www.abs-cbn.com/news/12/23/23/last-minute-shopping-spawns-traffic-crowds',
    ),
    _ReferenceUrl(
      title: '디비소리아 크리스마스 쇼핑 인파',
      url: 'https://www.gmanetwork.com/news/topstories/photo/485508/crowds-do-some-last-minute-christmas-shopping-in-divisoria/photo/',
    ),
    _ReferenceUrl(
      title: '바클라란 성당(수요일 노베나·미사)',
      url: 'https://www.baclaranchurch.org/home.html',
    ),
    _ReferenceUrl(
      title: '바클라란 수요일(Baclaran Day)',
      url: 'https://www.manilatimes.net/2025/02/04/fast-times/wednesday-baclaran-day/2048585',
    ),
    _ReferenceUrl(
      title: '키아포 성당(공식)',
      url: 'https://quiapochurch.com.ph/',
    ),
    _ReferenceUrl(
      title: '키아포 성당(위키)',
      url: 'https://en.wikipedia.org/wiki/Quiapo_Church',
    ),
    _ReferenceUrl(
      title: '키아포(앙팅앙팅 등) 관련 보도',
      url: 'https://www.abs-cbn.com/business/01/29/23/anting-anting-sellers-find-luck-online',
    ),
    _ReferenceUrl(
      title: '필리핀 안전 권고(캐나다 정부)',
      url: 'https://travel.gc.ca/destinations/philippines?pubDate=20250626',
    ),
    _ReferenceUrl(
      title: '"magkano" 타갈로그 사전',
      url: 'https://www.tagalog-dictionary.com/search?word=magkano',
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
              FontAwesomeIcons.lightStore,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentMarketTour,
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
            /// [헤더 배너] 시장 투어 개요
            _buildHeaderBanner(context),
            SizedBox(height: sp.s24),

            /// [1. 전통시장(팔렝케) 개요]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShop,
              title: '전통시장(팔렝케) 개요',
              emoji: '🏪',
            ),
            SizedBox(height: sp.s12),
            _buildOverviewSection(context),
            SizedBox(height: sp.s24),

            /// [2. 지역별 대표 전통시장 10선]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMapLocationDot,
              title: '지역별 대표 전통시장 10선',
              emoji: '📍',
            ),
            SizedBox(height: sp.s12),
            _buildMarketsSection(context),
            SizedBox(height: sp.s24),

            /// [3. 디비소리아 상세]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCity,
              title: '디비소리아(Divisoria) 상세',
              emoji: '🏙️',
            ),
            SizedBox(height: sp.s12),
            _buildDivisoriaSection(context),
            SizedBox(height: sp.s24),

            /// [4. 키아포·바클라란]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightChurch,
              title: '키아포(Quiapo)·바클라란(Baclaran)',
              emoji: '⛪',
            ),
            SizedBox(height: sp.s12),
            _buildQuiapoSection(context),
            SizedBox(height: sp.s24),

            /// [5. 대형 쇼핑몰 vs 전통시장 비교]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightScaleBalanced,
              title: '대형 쇼핑몰 vs 전통시장',
              emoji: '⚖️',
            ),
            SizedBox(height: sp.s12),
            _buildComparisonSection(context),
            SizedBox(height: sp.s24),

            /// [6. 당일 이용 체크리스트]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightClipboardCheck,
              title: '당일 이용 체크리스트',
              emoji: '✅',
            ),
            SizedBox(height: sp.s12),
            _buildChecklistSection(context),
            SizedBox(height: sp.s24),

            /// [7. 추천 이용 흐름]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightRoute,
              title: '추천 이용 흐름 (모바일 기준)',
              emoji: '📲',
            ),
            SizedBox(height: sp.s12),
            _buildProcedureTimeline(context),
            SizedBox(height: sp.s24),

            /// [8. 안전·거래 유의사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldCheck,
              title: '안전·거래 유의사항',
              emoji: '⚠️',
            ),
            SizedBox(height: sp.s12),
            _buildSafetySection(context),
            SizedBox(height: sp.s24),

            /// [9. 현장 표현]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLanguage,
              title: '현장 표현 (최소)',
              emoji: '✍️',
            ),
            SizedBox(height: sp.s12),
            _buildPhraseSection(context),
            SizedBox(height: sp.s24),

            /// [10. 참고 URL]
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
  ///
  /// 시장 투어의 개요와 목적을 설명하는 상단 배너입니다.
  /// Top banner explaining the overview and purpose of market tour.
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
            Colors.amber.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 제목 행 (Title row)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightStore,
                size: 24,
                color: Colors.orange,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 전통 로컬 시장(팔렝케) 문화',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 설명 (Description)
          Text(
            '한국인이 현지에서 "당일 이용"하기 위한 실무 가이드입니다. '
            '필리핀의 전통 시장 문화와 이용 방법, 주요 시장 정보를 제공합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 주의사항 박스 (Caution box)
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
                    '시장 환경과 운영은 점포·구역별로 달라질 수 있습니다.',
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
  ///
  /// 각 섹션의 제목을 표시하는 헤더 위젯입니다.
  /// Header widget displaying the title of each section.
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

  /// 전통시장 개요 섹션 빌드 (Overview section build)
  ///
  /// 팔렝케(전통시장)의 개요를 설명합니다.
  /// Explains the overview of palengke (traditional market).
  Widget _buildOverviewSection(BuildContext context) {
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
          /// 팔렝케 정의 (Palengke definition)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.lightBasketShopping,
                  size: 20,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '팔렝케 (Palengke)',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      '필리핀의 전통 로컬 시장을 일반적으로 부르는 명칭입니다.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 특징 목록 (Feature list)
          _buildFeatureItem(
            context,
            icon: FontAwesomeIcons.lightFish,
            title: '웻 마켓(Wet Market) 포함',
            description: '신선식품(육류·해산물·채소)과 생활 잡화가 함께 유통되는 상설 시장 형태',
          ),
          SizedBox(height: sp.s8),
          _buildFeatureItem(
            context,
            icon: FontAwesomeIcons.lightScaleUnbalanced,
            title: '가격·품질 편차',
            description: '점포별 가격·품질 편차가 크므로 비교 구매가 실무적으로 유리',
          ),
          SizedBox(height: sp.s8),
          _buildFeatureItem(
            context,
            icon: FontAwesomeIcons.lightMoneyBill,
            title: '현금 결제 중심',
            description: '현금 결제가 기본인 구역이 많은 편으로 소액권 준비 필요',
          ),
        ],
      ),
    );
  }

  /// 개별 특징 아이템 빌드 (Feature item build)
  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, size: 16, color: scheme.primary),
          SizedBox(width: sp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: sp.s4),
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
      ),
    );
  }

  /// 지역별 전통시장 섹션 빌드 (Markets section build)
  ///
  /// 지역별 대표 전통시장 10선을 표시합니다.
  /// Displays top 10 traditional markets by region.
  Widget _buildMarketsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _markets.map((market) {
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
              /// 시장명 및 지역 (Market name and region)
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightLocationDot,
                    size: 14,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      market.name,
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
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      market.region,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s8),

              /// 핵심 특징 (Core feature)
              Text(
                market.core,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 대표 품목 및 결제 (Products and payment)
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightTags,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        SizedBox(width: sp.s4),
                        Expanded(
                          child: Text(
                            market.products,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightCreditCard,
                          size: 10,
                          color: Colors.green,
                        ),
                        SizedBox(width: sp.s4),
                        Text(
                          market.payment,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  /// 디비소리아 상세 섹션 빌드 (Divisoria section build)
  ///
  /// 마닐라 최대급 전통 상권인 디비소리아의 상세 정보를 표시합니다.
  /// Displays detailed information about Divisoria, Manila's largest traditional market district.
  Widget _buildDivisoriaSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 개요 박스 (Overview box)
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.1),
                Colors.orange.withValues(alpha: 0.05),
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
                    FontAwesomeIcons.lightBuildingFlag,
                    size: 20,
                    color: Colors.red,
                  ),
                  SizedBox(width: sp.s12),
                  Expanded(
                    child: Text(
                      '마닐라 최대급 전통 상권',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Text(
                '톤도(Tondo)·비논도(Binondo)·산니콜라스(San Nicolas) 경계에 걸친 상업 지구로, '
                '저가 상품을 대량으로 판매하는 대중형 상권입니다. '
                '단일 건물에 한정되지 않고 여러 도로·블록에 걸쳐 상권이 확장된 형태입니다.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 현장 구조 (Site structure)
        _buildInfoCard(
          context,
          icon: FontAwesomeIcons.lightBuilding,
          title: '현장 구조: 노점 + 바겐 몰 공존',
          iconColor: Colors.blue,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '거리형 시장(노점·점포)뿐 아니라 실내형 쇼핑몰이 함께 분포합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: sp.s8),
              Wrap(
                spacing: sp.s8,
                runSpacing: sp.s4,
                children: [
                  _buildTag(context, '투투반 센터', Colors.blue),
                  _buildTag(context, '168 Shopping Mall', Colors.blue),
                  _buildTag(context, '999 Shopping Mall', Colors.blue),
                ],
              ),
              SizedBox(height: sp.s8),
              Text(
                '실내형 몰은 에어컨 환경에서 소형 점포가 층별로 밀집된 구조입니다. '
                '동일 품목이라도 점포별 단가와 품질이 달라 구역·점포 비교 구매가 유리합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 혼잡도 (Congestion)
        _buildInfoCard(
          context,
          icon: FontAwesomeIcons.lightPeopleGroup,
          title: '혼잡도: 연말(크리스마스) 시즌 주의',
          iconColor: Colors.red,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: scheme.errorContainer.withValues(alpha: 0.3),
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
                        '크리스마스 직전에는 방문객이 대폭 증가합니다.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sp.s8),
              Text(
                '연말 시즌에 저가 선물·장식품 수요가 증가합니다. '
                '혼잡 시에는 동선 확보가 어렵고 이동 시간이 길어질 수 있으므로, '
                '평일 오전 시간대 활용이 실무적으로 유리합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 품목 범위 (Product range)
        _buildInfoCard(
          context,
          icon: FontAwesomeIcons.lightBoxesStacked,
          title: '품목 범위: 의류·잡화 중심',
          iconColor: Colors.purple,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '의류·신발·가방·생활 잡화·원단 등 대량 유통 품목이 집중되며, '
                '구역에 따라 과일·채소 등 식재료와 간식 노점도 함께 형성됩니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: sp.s8),
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightBoxOpen,
                      size: 14,
                      color: Colors.purple,
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        '도매 성격이 강해 복수 구매(묶음) 단가를 적용하는 점포가 존재합니다.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.purple.shade700,
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
        SizedBox(height: sp.s12),

        /// 흥정 운영 방식 (Bargaining)
        _buildInfoCard(
          context,
          icon: FontAwesomeIcons.lightHandshake,
          title: '흥정(가격 협의) 운영 방식',
          iconColor: Colors.green,
          content: Text(
            '전통시장 및 바겐 몰에서는 점포별로 정가표가 없거나 협의 가능한 판매 방식이 존재합니다. '
            '다만 흥정 가능 여부·폭은 품목, 수량, 점포 정책에 따라 달라 '
            '구매 전 단가 기준(개당/세트/도매)을 먼저 확인하는 절차가 필요합니다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌드 (Info card build)
  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required Widget content,
  }) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.s8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(icon, size: 16, color: iconColor),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          content,
        ],
      ),
    );
  }

  /// 태그 빌드 (Tag build)
  Widget _buildTag(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 키아포·바클라란 섹션 빌드 (Quiapo section build)
  ///
  /// 키아포와 바클라란 상권의 정보를 표시합니다.
  /// Displays information about Quiapo and Baclaran market districts.
  Widget _buildQuiapoSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 소개 박스 (Introduction box)
        Container(
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '디비소리아와 함께 마닐라에서 대표적으로 언급되는 전통 상권입니다. '
                  '두 지역은 성당(종교 시설) 권역과 상권이 결합되어 '
                  '특정 요일·시간대에 유동 인구가 증가할 수 있습니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 키아포 (Quiapo)
        _buildMarketDetailCard(
          context,
          name: '키아포 시장(Quiapo Market)',
          subtitle: '종교 용품 + 약재·생활 상권 + 전자·부품',
          icon: FontAwesomeIcons.lightChurch,
          iconColor: Colors.indigo,
          features: [
            '퀴아포 성당(예수 나사레노 성지로 알려진 바실리카) 인접 권역',
            '십자가·묵주 등 종교 용품 외에도 약재 상점 운영',
            '앙팅앙팅(anting-anting) 등 부적·주술적 상징물 판매',
            '전자·부품 상권(라온 일대) 인접',
          ],
        ),
        SizedBox(height: sp.s12),

        /// 바클라란 (Baclaran)
        _buildMarketDetailCard(
          context,
          name: '바클라란 시장(Baclaran Market)',
          subtitle: '성당 권역과 결합된 대형 시장권',
          icon: FontAwesomeIcons.lightPlaceOfWorship,
          iconColor: Colors.teal,
          features: [
            '파라냐케 지역 성당 권역 중심 상권 형성',
            '의류·가방·잡화 등 저가 상품 중심 거리 상권',
            '수요일 노베나(기도)·미사 일정 운영',
            '수요일에 유동 인구가 크게 증가할 수 있음',
          ],
          highlight: '수요일 = "Baclaran Day" 라고 불림',
        ),
      ],
    );
  }

  /// 시장 상세 카드 빌드 (Market detail card build)
  Widget _buildMarketDetailCard(
    BuildContext context, {
    required String name,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required List<String> features,
    String? highlight,
  }) {
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
          /// 헤더 (Header)
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(icon, size: 20, color: iconColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 특징 목록 (Features list)
          ...features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: sp.s8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
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

          /// 하이라이트 (Highlight)
          if (highlight != null) ...[
            SizedBox(height: sp.s8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightStar,
                    size: 14,
                    color: iconColor,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      highlight,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
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

  /// 비교 섹션 빌드 (Comparison section build)
  ///
  /// 전통시장과 쇼핑몰 슈퍼마켓의 비교표를 표시합니다.
  /// Displays comparison table between traditional market and mall supermarket.
  Widget _buildComparisonSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 테이블 헤더 (Table header)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
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
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightStore,
                        size: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                      SizedBox(width: sp.s4),
                      Text(
                        '전통시장',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightBuildingColumns,
                        size: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                      SizedBox(width: sp.s4),
                      Text(
                        '쇼핑몰 슈퍼',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ...List.generate(_comparisons.length, (index) {
            final item = _comparisons[index];
            final isLast = index == _comparisons.length - 1;

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
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.traditional,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.mall,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
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

  /// 체크리스트 섹션 빌드 (Checklist section build)
  ///
  /// 당일 이용 준비물 체크리스트를 표시합니다.
  /// Displays day use preparation checklist.
  Widget _buildChecklistSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _checklist.map((item) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(item.icon, size: 18, color: Colors.green),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      item.purpose,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              FaIcon(
                FontAwesomeIcons.lightSquareCheck,
                size: 20,
                color: Colors.green,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 이용 절차 타임라인 빌드 (Procedure timeline build)
  ///
  /// 추천 이용 흐름을 타임라인 형태로 표시합니다.
  /// Displays recommended procedure flow as timeline.
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: scheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 48,
                      color: scheme.outlineVariant,
                    ),
                ],
              ),
              SizedBox(width: sp.s12),

              /// 절차 내용 (Procedure content)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.step,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        item.method,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.memo,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSecondaryContainer,
                          ),
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
  ///
  /// 안전·거래 유의사항을 표시합니다.
  /// Displays safety and transaction cautions.
  Widget _buildSafetySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 경고 박스 (Warning box)
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
                FontAwesomeIcons.lightTriangleExclamation,
                size: 16,
                color: Colors.amber.shade700,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '일부 국가의 여행 안전 권고에서는 필리핀의 도시 지역에서 소매치기, 가방 날치기 등 경범죄가 발생할 수 있으며, '
                  '특히 혼잡한 장소(대중교통, 시장, 쇼핑몰 등)에서 소지품 관리를 권고합니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.amber.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 안전 수칙 목록 (Safety tips list)
        ..._safetyTips.map((tip) {
          return Container(
            margin: EdgeInsets.only(bottom: sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(tip.icon, size: 18, color: scheme.error),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.item,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        tip.recommendation,
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
        }),
      ],
    );
  }

  /// 현장 표현 섹션 빌드 (Phrase section build)
  ///
  /// 시장에서 사용할 수 있는 간단한 타갈로그 표현을 표시합니다.
  /// Displays simple Tagalog phrases for market use.
  Widget _buildPhraseSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.1),
            Colors.indigo.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 설명 (Description)
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: Colors.blue,
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '시장에서는 영어가 통하는 경우가 많으나, 가격 확인에 다음 표현이 자주 활용됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 표현 카드 (Phrase card)
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 타갈로그 표현 (Tagalog phrase)
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '타갈로그',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s12),
                    Expanded(
                      child: Text(
                        'Magkano po ito?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),

                /// 발음 가이드 (Pronunciation guide)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightVolumeHigh,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '막까노 포 이또?',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),

                /// 의미 (Meaning)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightLanguage,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '"이것은 얼마입니까?" (정중 표현)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
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
  }

  /// 참고 URL 빌드 (Reference URLs build)
  ///
  /// 원문 확인용 참고 URL 목록을 표시합니다.
  /// Displays reference URLs for source verification.
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
  ///
  /// 외부 브라우저에서 URL을 엽니다.
  /// Opens URL in external browser.
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
