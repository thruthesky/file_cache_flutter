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

/// 요금 정보 아이템 데이터 클래스 (Fare Info Item Data Class)
///
/// 노선별 요금 정보를 담는 데이터 클래스입니다.
/// Contains fare info for each route.
class _FareItem {
  /// 노선 (Route)
  final String route;

  /// 소요 시간 (Duration)
  final String duration;

  /// 요금 (Fare)
  final String fare;

  /// 특징 (Features)
  final String features;

  const _FareItem({
    required this.route,
    required this.duration,
    required this.fare,
    required this.features,
  });
}

/// 고속 버스 정보 화면 (Express Bus Screen)
///
/// 필리핀 고속 버스 이용 정보를 제공합니다.
/// Provides information about express bus service in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// ExpressBusScreen.push(context);
/// ```
class ExpressBusScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/ExpressBus';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ExpressBusScreen({super.key});

  @override
  State<ExpressBusScreen> createState() => _ExpressBusScreenState();
}

class _ExpressBusScreenState extends State<ExpressBusScreen> {
  /// 길거리 버스 탑승 팁 (Street Bus Boarding Tips)
  static const List<_InfoItem> _streetBusTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '정류장 위치 확인',
      description:
          '구글 지도 등에서 버스 정류장이 정확하지 않게 표시되는 경우가 있다. 현지에서 확인된 버스정류장이나 터미널을 이용하고, 필요시 주변 사람들에게 위치를 문의하는 것이 안전하다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSignsPost,
      title: '행선지 표시 확인',
      description:
          '필리핀 버스는 전면에 주요 행선지가 표시되어 있으므로, 길에서 탈 때 버스 전면 행선지 안내판을 꼭 확인해야 한다. 원하는 목적지가 적힌 버스가 올 때 손을 흔들어 승차 의사를 표시하면 정차한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightChair,
      title: '좌석 확보 어려움',
      description:
          '도로변에서 타는 경우 이미 많은 승객이 탄 상태일 수 있어 좌석이 없을 가능성이 있다. 장거리 여행이라면 가급적 터미널에서 출발하여 좌석을 확보하는 편이 좋다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '시간 여유 두기',
      description:
          '버스 운행간격은 노선마다 다르지만 보통 1시간 간격이다. 교통상황에 따라 지연될 수 있으므로 여유를 가지고 기다려야 한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRocket,
      title: '대안 활용',
      description:
          '주요 도시에서는 정류장에서 기다리지 않고 승객이 많은 터미널로 직접 가는 것이 편리하다. 예를 들어 마닐라 알라방 스타몰에서 매 정시에 Lawton행 급행 버스(요금 ₱100)가 출발하여 약 40~50분만에 도심에 도착한다.',
    ),
  ];

  /// 주요 노선별 요금 정보 (Fare Info by Route)
  static const List<_FareItem> _fareInfo = [
    _FareItem(
      route: '마닐라(Pasay) ~ 바기오',
      duration: '5~6시간',
      fare: '₱741 / ₱999',
      features: 'Deluxe / First Class',
    ),
    _FareItem(
      route: '마닐라(NAIA T3) ~ 클락',
      duration: '2~3시간',
      fare: '₱430',
      features: 'P2P 공항버스',
    ),
    _FareItem(
      route: '마닐라(Pasay) ~ 투게가라오',
      duration: '12~13시간',
      fare: '₱1,431',
      features: '익스프레스(직행)',
    ),
    _FareItem(
      route: '마닐라(Cubao) ~ 라왁',
      duration: '9~10시간',
      fare: '₱1,176 / ₱1,392',
      features: 'Deluxe / First Class',
    ),
  ];

  /// 결제 방식 정보 (Payment Methods Info)
  static const List<_InfoItem> _paymentInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금 결제 (기본)',
      description:
          '필리핀 고속버스는 전통적으로 현금 결제가 일반적이다. 버스에 올라타면 안내 승무원(차장)이 직접 요금을 받고 탑승 구간에 해당하는 표를 찢어서 준다. 500페소 이하의 지폐나 잔돈을 갖고 있는 것이 편리하다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '사전 승차권 구입',
      description:
          '일부 노선이나 고급 좌석제 버스의 경우 터미널 매표소에서 사전에 승차권을 구입하기도 한다. Victory Liner의 First Class나 Royal Class 좌석은 예약 시 좌석번호까지 지정된다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMobileScreenButton,
      title: '온라인 예약',
      description:
          'Klook 등 온라인 예약을 통해 모바일 바우처를 제시하면 터미널 창구에서 실물 티켓으로 교환해주는 방식도 있다. 출발 45분 전까지 창구에서 표로 바꾸면 된다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '카드 및 전자결제',
      description:
          'Victory Liner의 경우 터미널 창구에서 현금, 카드, GCash 등 전자지갑 결제까지 지원한다. 다만 대부분의 지방 노선에서는 현금 결제를 예상하는 것이 안전하다.',
    ),
  ];

  /// 지역별 운행 현황 (Regional Operations)
  static const List<_InfoItem> _regionalInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMountain,
      title: '루손(Luzon) 섬',
      description:
          '가장 발달된 버스 노선망이 있다. 메트로 마닐라를 기점으로 북부 바기오·일로코스 지방부터 남부 비콜 지역까지 다양한 노선이 있다. 대표 버스회사로 Victory Liner, Five Star, Genesis, Partas 등이 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightIslandTropical,
      title: '비사야(Visayas) 섬',
      description:
          '세부 섬에서는 Ceres Liner 같은 현지 대형사가 세부시티 ~ 모알보알, 오슬롭 등 관광지를 연결하고 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCompass,
      title: '민다나오(Mindanao) 섬',
      description:
          'RTMI(Rural Transit), Bachelor Express 등의 업체가 도시 간 버스를 운행한다. 섬과 섬 사이 이동의 경우 버스가 페리에 승선하여 운행하는 RORO 버스도 일부 노선에서 찾아볼 수 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '터미널 환경 차이',
      description:
          '마닐라 및 대도시 터미널은 규모가 크고 출발 편수가 많아 대체로 매시간 버스가 출발하지만, 소도시에서는 하루 몇 차례만 운행하는 노선도 있다.',
    ),
  ];

  /// 안전 관련 유의사항 (Safety Notes)
  static const List<_InfoItem> _safetyInfo = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBuildingColumns,
      title: '터미널 선택',
      description:
          '항상 목적지에 운행하는 회사의 공식 터미널을 이용해야 한다. 터미널 주변이나 길거리에서 호객행위를 하는 비공식 차량(무허가 밴 등)은 피하는 것이 좋다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '기사 정보 확인',
      description:
          '버스 내부에 운전자 이름이나 면허증 사본이 부착된 경우가 있으므로 운전자 및 차량번호를 메모해 두면 유사시 대비에 도움이 된다. 승차 전 차량 번호판과 노선 표시를 사진으로 찍어 두는 것도 방법이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLocationCrosshairs,
      title: '실시간 위치 공유',
      description:
          '탑승 후 가족이나 지인에게 버스 노선, 출발 시각, 예상 도착시각 등을 알려두자. 특히 야간 이동 시에는 스마트폰을 통해 실시간 위치를 공유해두면 더욱 안심할 수 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBagShopping,
      title: '치안 및 소지품',
      description:
          '대형 터미널에는 보안요원이 배치되어 비교적 안전하지만, 사람이 매우 혼잡하다. 짐이나 소지품을 항상 곁에 두고 주시해야 하며, 낯선 이가 도움을 핑계로 접근할 경우 경계할 필요가 있다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '신뢰할 만한 회사 이용',
      description:
          '가능하면 오랜 기간 운행해 온 대형 버스회사를 이용하는 것이 안전하다. Victory Liner, Genesis 등은 운전자 교육과 차량 정비가 체계적이라고 알려져 있다.',
    ),
  ];

  /// 터미널 이용 및 야간 이동 팁 (Terminal & Night Travel Tips)
  static const List<_InfoItem> _terminalTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMagnifyingGlass,
      title: '보안 검사',
      description:
          '대규모 터미널(예: Paranaque PITX 등)에서는 가방 X-ray 검사, 금속 탐지기 검색 등을 실시하기도 한다. 터미널 입장 시 보안요원의 지시에 따르면 되며, 위험품 소지는 금물이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCouch,
      title: '대합실 & 시설',
      description:
          '필리핀 터미널은 의자가 부족하고 실내 온도나 위생 상태가 열악할 수 있다. 일부 터미널에는 간이 매점과 유료 화장실(보통 5페소)이 있다. 출발까지 시간이 있다면 주변 편의점에서 물과 간식을 사두는 것이 좋다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '좌석 지정 및 줄서기',
      description:
          '자유석 버스의 경우 줄 서서 선착순으로 탑승하며, 먼저 탄 사람이 좋은 좌석을 차지한다. 인기 노선은 출발 10~15분 전에 미리 줄이 생기니 일찍 줄 서는 것이 안전하다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSuitcase,
      title: '수하물 보관',
      description:
          '큰 짐은 버스 아래 화물칸(trunk)에 보관한다. 貴重品이 들어 있는 짐은 분실 위험을 줄이기 위해 가능하면 직접 들고 타거나, 최소한 노선 끝까지 내려다볼 수 있도록 한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoon,
      title: '야간 이동 주의',
      description:
          '심야 시간대 도로가 한산하여 이동시간이 단축되는 장점이 있지만, 도착지가 새벽 시간대일 경우 교통 연결에 유의해야 한다. 새벽에 도착한다면 터미널에서 해가 뜰 때까지 기다리거나 휴게실 이용을 고려해야 한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSnowflake,
      title: '복장 및 체온',
      description:
          '필리핀 버스는 에어컨이 매우 강하게 나오는 경우가 흔하다. 현지인들도 장거리 탈 때 얇은 겉옷이나 담요를 준비하는 것을 권한다. 특히 밤 시간 이동 시 체온 유지에 유의한다.',
    ),
  ];

  /// 한국인을 위한 팁 (Tips for Koreans)
  static const List<_InfoItem> _koreanTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBuildingFlag,
      title: '터미널 구조 이해',
      description:
          '한국처럼 하나의 종합버스터미널에 여러 회사 버스가 모이는 체계가 아니므로, 가고자 하는 지역에 운행하는 특정 버스회사를 찾아가야 함을 기억하자. 예컨대 Victory Liner의 파사이 터미널인지 Genesis의 쿠바오 터미널인지 등 회사와 위치를 정확히 파악해야 한다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLanguage,
      title: '언어 및 커뮤니케이션',
      description:
          '버스터미널 창구 직원이나 차장은 대부분 영어를 사용한다. 간단한 영어로 목적지와 인원, 시간을 말하면 표를 구매하거나 문의할 수 있다. 버스 내 방송은 거의 없으므로, 내릴 곳을 놓치지 않도록 GPS 지도로 경로를 확인하는 것이 좋다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '예약 및 좌석 선택',
      description:
          '성수기나 주말에는 인기 노선은 매진되는 경우도 있다. 사전에 온라인 예약이 가능한 노선은 미리 예약하면 마음이 편하다. 멀미가 있다면 앞자리 확보를 위해 일찍 줄서자.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '시간 계획',
      description:
          '필리핀의 교통 체증은 심각하다. 특히 마닐라를 출발하거나 진입하는 버스는 러시아워에 지연되기 쉽다. 이른 아침이나 심야 시간대 이동은 도로가 비교적 원활하다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBackpack,
      title: '편의 용품',
      description:
          '장시간 이동을 대비해 귀마개, 목베개, 휴대폰 보조배터리, 티슈/물티슈, 손 세정제 등을 준비하면 유용하다. 버스에 USB 충전 포트가 있는 경우도 있지만 불확실하므로 배터리를 충분히 확보하는 게 좋다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightPersonWalkingLuggage,
      title: '현지인 따라하기',
      description:
          '필리핀 사람들은 내릴 때가 가까워지면 미리 자리에서 일어나 출구 근처로 이동한다. 내릴 때는 차장에게 미리 알려 정확한 정류장에 내려달라고 확인받는 것도 방법이다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBaby,
      title: '유아 동반 시',
      description:
          '필리핀 버스도 만 4세 이하 유아는 부모 동반 무릎 동승 시 무료 등 정책이 있으니 가족 단위 이용자는 참고한다.',
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
              FontAwesomeIcons.lightBus,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.transportationExpressBus),
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

            /// [길거리 버스 탑승 섹션 - Street Bus Boarding Section]
            _buildSectionHeader(
              context,
              emoji: '🏙️',
              title: '길거리에서 버스 잡기 – 알아둘 점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _streetBusTips, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [요금 정보 섹션 - Fare Info Section]
            _buildSectionHeader(
              context,
              emoji: '💰',
              title: '요금 구조 및 예상 요금',
            ),
            SizedBox(height: sp.s12),
            _buildFareDescription(context),
            SizedBox(height: sp.s12),
            _buildFareTable(context),

            SizedBox(height: sp.s24),

            /// [결제 방식 섹션 - Payment Methods Section]
            _buildSectionHeader(
              context,
              emoji: '💳',
              title: '결제 방식 – 현금, 카드, 전자결제',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _paymentInfo,
              scheme.secondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [지역별 운행 현황 섹션 - Regional Operations Section]
            _buildSectionHeader(
              context,
              emoji: '🌏',
              title: '지역별 버스 운행 현황',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _regionalInfo, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [안전 관련 섹션 - Safety Section]
            _buildSectionHeader(
              context,
              emoji: '🔒',
              title: '안전 관련 기능 및 유의사항',
            ),
            SizedBox(height: sp.s12),
            _buildSafetyIntro(context),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _safetyInfo, scheme.errorContainer),

            SizedBox(height: sp.s24),

            /// [터미널 이용 팁 섹션 - Terminal Tips Section]
            _buildSectionHeader(
              context,
              emoji: '🌙',
              title: '터미널 이용 및 야간 이동 팁',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _terminalTips,
              scheme.surfaceContainerHighest,
            ),

            SizedBox(height: sp.s24),

            /// [한국인 팁 섹션 - Korean Tips Section]
            _buildSectionHeader(
              context,
              emoji: '🇰🇷',
              title: '한국인이 알아두면 좋은 팁',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _koreanTips, scheme.primaryContainer),

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
  /// 고속버스 안내의 상단 히어로 배너를 빌드합니다.
  /// Builds the hero banner at the top of express bus guide.
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
                '🚌',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🛣️',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 고속버스\n이용 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '기차 등 장거리 교통수단이 제한적인 필리핀에서 도시 간 이동의 주요 수단인 고속버스 이용 방법',
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
              _buildFeatureChip(context, '24시간 운행'),
              _buildFeatureChip(context, '합리적 요금'),
              _buildFeatureChip(context, '주요 도시 연결'),
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
        style: theme.textTheme.labelMedium?.copyWith(
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

  /// 요금 설명 빌드 (Build fare description)
  Widget _buildFareDescription(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 16,
                color: scheme.secondary,
              ),
              SizedBox(width: sp.s8),
              Text(
                '요금 책정 기준',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Text(
            '필리핀 고속버스의 요금은 노선 거리와 버스 등급에 따라 결정된다. 비슷한 거리라도 직행(익스프레스) 여부나 차량 등급(좌석 편의, 시설)에 따라 차등 요금을 책정한다. 에어컨이 없는 구형 버스가 저렴하고, 화장실·리클라이닝 좌석 등의 편의시설을 갖춘 고급 버스일수록 요금이 높다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSecondaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 요금 테이블 빌드 (Build fare table)
  Widget _buildFareTable(BuildContext context) {
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
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '노선',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '시간',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '요금',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 바디 (Table body)
          ..._fareInfo.asMap().entries.map((entry) {
            final index = entry.key;
            final fare = entry.value;
            final isLast = index == _fareInfo.length - 1;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          fare.route,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          fare.duration,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          fare.fare,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sp.s4),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s8,
                      vertical: sp.s4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.tertiaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      fare.features,
                      style: theme.textTheme.labelMedium?.copyWith(
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
    );
  }

  /// 안전 소개 빌드 (Build safety intro)
  Widget _buildSafetyIntro(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          FaIcon(
            FontAwesomeIcons.lightShieldHalved,
            size: 24,
            color: scheme.primary,
          ),
          SizedBox(width: sp.s12),
          Expanded(
            child: Text(
              '공식 고속버스는 정부 인가를 받은 합법 운송수단으로 비교적 안전하게 이용할 수 있다. 차량 점검과 운전자 자격 등이 관리되므로, 등록된 대형 버스회사 이용 자체는 안전도 면에서 큰 걱정이 없다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                height: 1.5,
              ),
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
      '필리핀에서 도시 간 이동 시 고속버스(시외버스)가 주요 수단',
      '대형 버스 회사들이 메트로 마닐라와 주요 지방 도시 연결',
      '승객 수요가 많은 노선은 24시간 운행',
      '한국과 비교하면 저렴한 요금 수준',
      '현금 결제가 기본이나, 주요 터미널에선 카드/QR결제 가능',
      '버스회사별 개별 터미널 체계 – 목적지 회사 터미널 확인 필수',
      '에어컨이 강하므로 얇은 겉옷 준비 권장',
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
                '🚌',
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
          SizedBox(height: sp.s8),
          Text(
            '필리핀 고속버스를 통해 경제적이고 색다른 현지 이동 경험을 할 수 있다. 현지 교통 시스템의 특성을 이해하고 대비하여 안전하고 쾌적한 여행이 되길 바란다.',
            style: theme.textTheme.bodyMedium?.copyWith(
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
