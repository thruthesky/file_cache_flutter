import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 정보 아이템 데이터 클래스 (Info Item Data Class)
///
/// 아이콘, 제목, 설명을 담는 데이터 클래스입니다.
/// Contains icon, title, and description.
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
/// 테이블에 표시할 항목과 내용을 담는 데이터 클래스입니다.
/// Contains item and content for table display.
class _TableRow {
  /// 항목 (Item)
  final String item;

  /// 내용 (Content)
  final String content;

  const _TableRow({required this.item, required this.content});
}

/// 지역별 유의사항 데이터 클래스 (Regional Notes Data Class)
///
/// 각 지역의 에어비앤비 이용 시 주의점을 담는 데이터 클래스입니다.
/// Contains notes for Airbnb usage in each region.
class _RegionalNote {
  /// 지역 이름 (Region name)
  final String region;

  /// 이모지 (Emoji)
  final String emoji;

  /// 주의사항 (Notes)
  final String notes;

  const _RegionalNote({
    required this.region,
    required this.emoji,
    required this.notes,
  });
}

/// 에어비앤비 정보 화면 (Airbnb Screen)
///
/// 필리핀 에어비앤비 이용 정보를 제공합니다.
/// Provides information about Airbnb in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// AirbnbScreen.push(context);
/// ```
class AirbnbScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Airbnb';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const AirbnbScreen({super.key});

  @override
  State<AirbnbScreen> createState() => _AirbnbScreenState();
}

class _AirbnbScreenState extends State<AirbnbScreen> {
  /// 개요 정보 (Overview Info)
  static const List<_InfoItem> _overviewInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightHouse,
      title: '에어비앤비란?',
      description:
          '필리핀 전역에서 단기 체류, 장기 거주, 한달살기 등 다양한 목적에 활용되는 대표 숙소 중개 플랫폼이다. 메트로 마닐라에서만 2025년 기준 1,600건 이상의 단기 임대 숙소가 운영된다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightThumbsUp,
      title: '인기 이유',
      description:
          '호텔 대비 넓은 공간과 주방·세탁시설, 합리적인 가격 때문에 한국인 여행자와 거주자에게도 인기가 높다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '주의 사항',
      description:
          '지역별 규제와 건물 자체의 관리 규정에 따라 일부 숙소는 사실상 불법 운영인 경우도 있어 사전 확인이 필수적이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightScaleBalanced,
      title: '법규 강화 추세',
      description:
          '필리핀 정부도 2025년 "단기 숙박 임대 규제 및 주거 보호법" 제정을 추진하는 등 플랫폼 숙박에 대한 관리·감독을 강화하고 있다.',
    ),
  ];

  /// 기본 예약 절차 (Basic Booking Steps)
  static const List<_TableRow> _bookingSteps = [
    _TableRow(item: '접속', content: '에어비앤비 웹사이트 또는 앱 실행'),
    _TableRow(item: '검색', content: '목적지, 날짜, 인원 입력 후 검색'),
    _TableRow(item: '필터', content: '숙소 유형, 가격, 편의시설 등 조건 설정'),
    _TableRow(item: '확인', content: '숙소 사진, 편의시설 목록, 후기와 평점 확인'),
    _TableRow(item: '예약', content: "'즉시 예약' 또는 '예약 요청' 진행"),
    _TableRow(item: '결제', content: '등록한 신용카드 등으로 결제 완료'),
  ];

  /// 예약 방식 이해 (Booking Types)
  static const List<_InfoItem> _bookingTypes = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBolt,
      title: '즉시 예약',
      description: '호스트 승인 없이 바로 예약 확정되는 방식. 결제 즉시 확정된다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '예약 요청',
      description: '호스트가 승인해야 확정되는 방식. 호스트가 24시간 내 응답해야 한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCheckDouble,
      title: '사전 승인',
      description: '게스트 문의 후 호스트가 선승인해주는 기능.',
    ),
  ];

  /// 호스트 확인 사항 (Host Confirmation Items)
  static const List<_TableRow> _hostConfirmItems = [
    _TableRow(item: '운영 여부', content: '현재 숙소를 에어비앤비로 제공 중인지 확인'),
    _TableRow(item: '체크인', content: '체크인 시간, 열쇠 전달 또는 키패드 안내 확인'),
    _TableRow(item: '건물 규정', content: '건물 측 단기 임대 허용 여부 (출입 절차 등)'),
    _TableRow(item: '편의시설', content: '수영장·헬스장 등 공용시설 이용 가능 여부'),
    _TableRow(item: '비상 연락', content: '호스트의 비상시 연락 가능한 연락처 확보'),
  ];

  /// 좋은 숙소 선택 기준 (Good Property Selection Criteria)
  static const List<_InfoItem> _selectionCriteria = [
    _InfoItem(
      icon: FontAwesomeIcons.lightStar,
      title: '후기와 평점 분석',
      description:
          '후기 10건 이상을 가진 숙소를 고르되 최근 6개월 내 후기에 주목. 여러 후기에서 반복적으로 지적되는 사항(와이파이 불안정, 소음, 청소 상태 등)이 있는지 살펴봐야 한다. 평점 숫자보다 후기 내용의 반복 패턴에 집중하는 것이 실패 없는 선택의 지름길이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '가격 비교',
      description:
          '일반적으로 1박 요금은 에어비앤비가 저렴하지만, 청소비, 서비스 수수료 등의 추가 비용이 붙으므로 최종 결제금액을 기준으로 따져봐야 한다. 장기 체류(28박 이상)시 월간 할인 요금이 적용되어 1박 단가가 크게 내려간다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightWifi,
      title: '편의시설 확인',
      description:
          '무선인터넷(Wi-Fi) 속도나 품질을 후기에서 확인. 에어컨 방마다 있는지, 온수 공급, 주방 시설 완비 여부, 세탁기 비치 여부 등을 체크한다. 필요 시 호스트에게 직접 확인할 것을 권장.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '안전성',
      description:
          '치안과 보안은 숙소 선택의 최우선 고려사항. 마카티(Makati)나 BGC처럼 비교적 안전한 지역이 있는 반면, 일부 지역은 야간 치안이 불안. 숙소 건물이 24시간 경비와 CCTV를 갖춘 콘도미니엄인지 확인.',
    ),
  ];

  /// 지역별 유의 사항 (Regional Notes)
  static const List<_RegionalNote> _regionalNotes = [
    _RegionalNote(
      region: '마닐라',
      emoji: '🏙️',
      notes:
          '콘도미니엄의 단기 임대 금지 규정을 주의. 일부 아파트는 입주자 회칙상 30일 미만 임대를 불허하며, 이를 어길 시 보안 요원이 에어비앤비 투숙객의 출입을 막는 사례가 있다. 예약 전 호스트에게 해당 건물에서 에어비앤비 허용 여부를 문의하는 것이 안전하다.',
    ),
    _RegionalNote(
      region: '세부',
      emoji: '🏝️',
      notes:
          '리조트형 콘도나 호텔레지던스 형태 숙소가 많다. 일부 리조트 콘도의 경우 투숙객에게 추가 리조트 fee를 부과하거나, 수영장·헬스장 등 부대시설 이용에 제한이 있을 수 있으므로 사전에 규정을 확인해야 한다. 맥탄 섬 리조트 지역에 숙소가 많고, 차량 이동이 필요하므로 위치 선택에 유의.',
    ),
    _RegionalNote(
      region: '보라카이',
      emoji: '🏖️',
      notes:
          '세계적 관광지인 만큼 정부 인가 숙소만 이용이 허가된다. 2018년 재개장 이후 보라카이 입도 시 정부 공인 숙소 바우처 제시가 의무화되어, 에어비앤비로 예약하더라도 해당 숙소가 관광청(DOT) 인증을 받은 곳인지 확인해야 한다. 인증되지 않은 숙소는 섬에 입장 자체가 거부될 수 있다.',
    ),
    _RegionalNote(
      region: '클락(앙헬레스)',
      emoji: '✈️',
      notes:
          '과거 미군기지 영향으로 장기 체류 외국인 수요가 많아, 한 달 단위 콘도 임대가 활발하다. 다만 일부 지역은 유흥가와 인접해 있어 가족 여행 숙소로는 부적합할 수 있다. 장기 임대 시 전기세·수도세 별도 청구 여부 등을 확인하는 것이 좋다.',
    ),
  ];

  /// 필수 준비물 (Essential Preparations)
  static const List<_TableRow> _essentialPreps = [
    _TableRow(
      item: '여권',
      content: '체크인 시 신분 확인을 위해 여권 제시를 요구받을 수 있다. (필요 시 사본 제출)',
    ),
    _TableRow(
      item: '에어비앤비 계정',
      content: '실명과 프로필 정보를 갖춘 계정을 사용해야 신뢰도가 높다. 한국인 프로필이라도 영문 이름 표기가 권장된다.',
    ),
    _TableRow(
      item: '결제 수단',
      content: '해외 결제가 가능한 신용카드/체크카드가 필요하다. (간편결제도 지원되나 국내 카드의 해외사용 설정 확인 요망)',
    ),
    _TableRow(
      item: '통신 수단',
      content:
          '현지에서 호스트와 연락할 수 있도록 필리핀 현지 SIM 구매 또는 로밍을 준비한다. (카카오톡 등 메신저로도 연락 가능)',
    ),
  ];

  /// 체크인 전 준비물 (Pre-Check-in Preparations)
  static const List<_TableRow> _checkinPreps = [
    _TableRow(
      item: '주소 확인',
      content:
          '예약 확정 후 받은 숙소 주소와 지도를 미리 저장하거나 스크린샷 해둔다. (필리핀은 주소 체계가 복잡하므로 구글 지도 링크를 받아 두면 편리)',
    ),
    _TableRow(
      item: '호스트 연락',
      content: '도착 예정 시간을 호스트에게 알리고, 체크인 방법을 재확인한다. 예: 경비실에서 열쇠 수령, 스마트락 비밀번호 등.',
    ),
    _TableRow(
      item: '숙소 규칙',
      content:
          '숙소 안내에 명시된 체크인/체크아웃 시간, 흡연·반려동물 가능 여부, 추가 인원 요금 등을 다시 한번 숙지한다. 필요하면 특이 사항을 호스트와 조율.',
    ),
  ];

  /// 한국인 유리한 점 (Benefits for Koreans)
  static const List<_InfoItem> _koreanBenefits = [
    _InfoItem(
      icon: FontAwesomeIcons.lightPiggyBank,
      title: '비용 절감',
      description:
          '장기 숙박 시 호텔보다 총 비용이 저렴하다. 월 단위 할인 적용으로 한달살기 숙소로 경제적이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCouch,
      title: '넓은 공간',
      description:
          '일반 호텔 객실 대비 거실·주방이 있는 집 전체 숙소는 가족 단위 여행에 쾌적하다. 인원이 늘어날수록 1인당 숙박비가 감소하는 장점도 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightComments,
      title: '의사소통',
      description:
          '기본적으로 영어로 소통하지만, 에어비앤비 플랫폼 내 메시지 번역 기능을 제공한다. 또한 한국어로 된 이용 가이드와 고객지원이 있어 처음 이용자도 비교적 쉽게 적응할 수 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHouseUser,
      title: '현지 생활',
      description:
          '취사 도구를 활용해 한식 조리가 가능하고 세탁기를 써서 빨래를 할 수 있어 장기 체류에 적합하다. 현지 이웃과 같은 환경에서 지내며 생활형 체험을 할 수 있다는 것도 에어비앤비의 매력이다.',
    ),
  ];

  /// 문제 발생 시 대응 방법 (Problem Response Methods)
  static const List<_InfoItem> _problemResponses = [
    _InfoItem(
      icon: FontAwesomeIcons.lightDoorClosed,
      title: '체크인 거부',
      description:
          '호스트나 건물 측에서 입실을 거부하면 즉시 에어비앤비 고객센터에 신고한다. 대안을 제시받거나 환불 조치를 받을 수 있다. (근거 자료로 메시지 기록을 남겨둘 것)',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightImageSlash,
      title: '숙소 불일치',
      description:
          '사진과 다른 시설 상태, 청소 불량, 해충 문제 등이 발견되면 즉시 사진 증거를 촬영하고 호스트에게 알린다. 시정되지 않으면 에어비앤비 측에 분쟁 조정을 신청하여 환불이나 대체 숙소를 요청한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserSlash,
      title: '호스트 불응',
      description:
          '숙박 중 긴급 문의에 호스트가 응답하지 않는다면 에어비앤비 고객센터를 통해 중재를 요청한다. (앱 내 메시지 기록은 증빙이 되므로 전화 등 외부 연락보다 앱 메시지를 우선 사용)',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBillWave,
      title: '추가 요금 요구',
      description:
          '체크인 시 호스트가 현장에서 보증금이나 추가 비용을 요구하는 경우 응하지 말고 에어비앤비에 신고한다. 이는 정책 위반이며, 지불하면 보호를 받기 어렵다.',
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
              FontAwesomeIcons.lightHouse,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.housingAirbnb),
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
            _buildSectionHeader(context, emoji: '📋', title: '개요'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _overviewInfo, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [기본 예약 절차 섹션 - Basic Booking Steps Section]
            _buildSectionHeader(context, emoji: '📝', title: '기본 예약 절차'),
            SizedBox(height: sp.s12),
            _buildTableSection(context, _bookingSteps),

            SizedBox(height: sp.s24),

            /// [예약 방식 섹션 - Booking Types Section]
            _buildSectionHeader(context, emoji: '🔄', title: '예약 방식 이해'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _bookingTypes, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [중요 주의 사항 섹션 - Important Warning Section]
            _buildWarningSection(context),

            SizedBox(height: sp.s24),

            /// [호스트 확인 사항 섹션 - Host Confirmation Section]
            _buildSectionHeader(
              context,
              emoji: '✅',
              title: '반드시 확인해야 할 사항 (메시지 확인 권장)',
            ),
            SizedBox(height: sp.s12),
            _buildTableSection(context, _hostConfirmItems),
            SizedBox(height: sp.s12),
            _buildTipCard(
              context,
              '예약 직후 1회, 체크인 2~3일 전에 1회 이상 호스트와 연락할 것을 권장한다. 만약 호스트 응답이 늦거나 연락이 안 될 경우 에어비앤비 고객센터에 상황을 알려 두는 것도 안전망이 된다.',
            ),

            SizedBox(height: sp.s24),

            /// [좋은 숙소 선택 기준 섹션 - Selection Criteria Section]
            _buildSectionHeader(
              context,
              emoji: '🏆',
              title: '좋은 숙소를 고르는 핵심 기준',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _selectionCriteria,
              scheme.tertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [지역별 유의 사항 섹션 - Regional Notes Section]
            _buildSectionHeader(context, emoji: '🌏', title: '지역별 유의 사항'),
            SizedBox(height: sp.s12),
            _buildRegionalNotes(context),
            SizedBox(height: sp.s12),
            _buildTipCard(
              context,
              '바기오(Baguio)나 타귁/마카티(Taguig/Makati)처럼 현지 조례로 단기 임대에 사업자 등록을 요구하는 사례가 늘고 있다. 게스트도 합법적으로 운영되는 숙소인지 후기와 설명을 통해 확인하는 것이 바람직하다.',
            ),

            SizedBox(height: sp.s24),

            /// [필수 준비 섹션 - Essential Preparations Section]
            _buildSectionHeader(context, emoji: '🎒', title: '필수 준비물'),
            SizedBox(height: sp.s12),
            _buildTableSection(context, _essentialPreps),

            SizedBox(height: sp.s24),

            /// [체크인 전 준비 섹션 - Pre-Check-in Section]
            _buildSectionHeader(context, emoji: '🔑', title: '체크인 전 준비'),
            SizedBox(height: sp.s12),
            _buildTableSection(context, _checkinPreps),
            SizedBox(height: sp.s12),
            _buildTipCard(
              context,
              '필리핀의 경우, 도로 상황이나 교통 체증으로 도착 시간이 변동되기 쉽다. 약속한 시간보다 늦어질 경우 호스트에게 미리 연락하는 예의를 지키도록 한다. 또한 현지에서 택시/그랩(Grab) 기사에게 숙소 위치를 설명해야 하는 경우가 있으므로 주변 랜드마크를 함께 알아두면 유용하다.',
            ),

            SizedBox(height: sp.s24),

            /// [한국인 유리한 점 섹션 - Korean Benefits Section]
            _buildSectionHeader(
              context,
              emoji: '🇰🇷',
              title: '한국인 이용자에게 유리한 점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _koreanBenefits, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [문제 발생 시 대응 섹션 - Problem Response Section]
            _buildSectionHeader(context, emoji: '🚨', title: '문제 발생 시 대응 방법'),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _problemResponses, scheme.errorContainer),
            SizedBox(height: sp.s12),
            _buildImportantNotice(context),

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
  /// 에어비앤비 안내의 상단 히어로 배너를 빌드합니다.
  /// Builds the hero banner at the top of Airbnb guide.
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
              Text('🏠', style: theme.textTheme.headlineMedium),
              SizedBox(width: sp.s8),
              Text('🇵🇭', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀에서\n에어비앤비 이용하기',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '단기 체류, 장기 거주, 한달살기 등 다양한 목적에 활용되는 숙소 중개 플랫폼 완벽 가이드',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: sp.s12),

          /// 주요 특징 칩들 (Feature chips)
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: [
              _buildFeatureChip(context, '넓은 공간'),
              _buildFeatureChip(context, '합리적 가격'),
              _buildFeatureChip(context, '주방/세탁시설'),
            ],
          ),
        ],
      ),
    );
  }

  /// 특징 칩 빌드 (Build feature chip)
  Widget _buildFeatureChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
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
        Text(emoji, style: theme.textTheme.titleLarge),
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

  /// 테이블 섹션 빌드 (Build table section)
  Widget _buildTableSection(BuildContext context, List<_TableRow> rows) {
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
          final isLast = index == rows.length - 1;

          return Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              border: !isLast
                  ? Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    )
                  : null,
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
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    row.item,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    row.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
                      height: 1.5,
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

  /// 경고 섹션 빌드 (Build warning section)
  ///
  /// 호스트와의 사전 메시지 필수에 대한 중요 경고를 표시합니다.
  /// Displays important warning about mandatory pre-messaging with host.
  Widget _buildWarningSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightTriangleExclamation,
                size: 24,
                color: scheme.onErrorContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '중요 주의 사항: 호스트와 사전 메시지 필수',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '에어비앤비 예약을 마친 뒤에도 안심은 금물이다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onErrorContainer,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀에서는 예약 완료 후 현장에 도착했을 때 "에어비앤비 손님을 받을 수 없다"는 이유로 입실이 거부된 사례가 실제로 발생했다. 콘도미니엄 관리 규약으로 단기 임대를 금지하거나, 호스트가 내부 사정으로 운영을 중단했음에도 정보를 업데이트하지 않는 경우다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onErrorContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightMessageDots,
                  size: 16,
                  color: scheme.onErrorContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '반드시 사전에 호스트와 메시지를 주고받으며 확인 절차를 거쳐야 한다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onErrorContainer,
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

  /// 팁 카드 빌드 (Build tip card)
  Widget _buildTipCard(BuildContext context, String tip) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightLightbulb,
            size: 16,
            color: scheme.secondary,
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              tip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSecondaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 지역별 유의사항 빌드 (Build regional notes)
  Widget _buildRegionalNotes(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _regionalNotes.map((note) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s12),
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
                  Text(note.emoji, style: theme.textTheme.titleLarge),
                  SizedBox(width: sp.s8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s12,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      note.region,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: sp.s12),
              Text(
                note.notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 중요 공지 빌드 (Build important notice)
  Widget _buildImportantNotice(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightShieldHalved,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '안전한 거래를 위한 필수 수칙',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '에어비앤비 플랫폼을 이용할 때는 모든 결제와 연락을 반드시 에어비앤비 시스템 내에서 처리해야 안전하다. 플랫폼을 거치지 않고 직접 돈을 주고받는 행위는 사기 피해 발생 시 보상이 어려우므로 주의가 필요하다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimaryContainer,
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '다행히 에어비앤비는 24시간 글로벌 고객지원을 운영하고 있어, 문제가 생기면 한국어 상담을 포함한 도움을 받을 수 있다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '예약 전후 반드시 호스트와 메시지로 운영 여부 확인',
      '후기 10건 이상, 최근 6개월 내 후기에 주목',
      '최종 결제금액(청소비, 수수료 포함) 기준으로 가격 비교',
      '지역별 규제 확인 (마닐라 콘도 규정, 보라카이 DOT 인증 등)',
      '모든 거래는 에어비앤비 플랫폼 내에서만 진행',
      '문제 발생 시 증거 확보 후 즉시 고객센터 연락',
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
              Text('🏠', style: theme.textTheme.titleLarge),
              SizedBox(width: sp.s8),
              Text('✨', style: theme.textTheme.titleLarge),
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
                  Text('✅', style: theme.textTheme.bodyMedium),
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
          SizedBox(height: sp.s8),
          Text(
            '규정을 준수하며 신중하게 예약한다면 필리핀에서의 에어비앤비 체험은 호텔과는 또 다른 만족감을 제공할 것이다.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
