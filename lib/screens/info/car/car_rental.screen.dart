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

/// 단계별 가이드 아이템 데이터 클래스 (Step Guide Item Data Class)
class _StepItem {
  /// 단계 번호 (Step number)
  final int step;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
  });
}

/// 요금 정보 아이템 데이터 클래스 (Fee Info Item Data Class)
class _FeeItem {
  /// 차량 종류 (Vehicle type)
  final String type;

  /// 가격 범위 (Price range)
  final String price;

  /// 한화 환산 (KRW equivalent)
  final String krw;

  /// 비고 (Note)
  final String note;

  const _FeeItem({
    required this.type,
    required this.price,
    required this.krw,
    required this.note,
  });
}

/// 자동차 렌트 정보 화면 (Car Rental Screen)
///
/// 필리핀 자동차 렌트 정보를 제공합니다.
/// Provides information about car rental in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// CarRentalScreen.push(context);
/// ```
class CarRentalScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/CarRental';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CarRentalScreen({super.key});

  @override
  State<CarRentalScreen> createState() => _CarRentalScreenState();
}

class _CarRentalScreenState extends State<CarRentalScreen> {
  /// 렌트카 이용 이유 정보 (Reasons to use car rental)
  static const List<_InfoItem> _whyRentCar = [
    _InfoItem(
      icon: FontAwesomeIcons.lightIslandTropical,
      title: '7,000여 개 섬으로 이루어진 나라',
      description:
          '대중교통만으로 이동하기 어려운 지역이 많아, 렌트카는 시간과 노력을 절약하는 효율적인 이동 수단입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '가족 여행에 최적',
      description:
          '가족 단위 여행이나 짐이 많은 경우 여러 대의 택시나 그랩을 부르는 것보다 기사 포함 렌트카 한 대를 이용하는 것이 편리하고 경제적입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserTie,
      title: '기사 포함 렌트카',
      description:
          '현지 운전사가 함께하면 운전 부담 없이 편안하게 이동할 수 있고, 휴식 장소나 경로를 세심하게 안내받을 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '교통 체증 주의',
      description:
          '마닐라, 세부 등 대도시는 교통 체증이 매우 심하므로 피크 시간대에는 정체를 피하기 어렵습니다. SUV나 밴 등 지형에 맞는 차량을 선택하는 것이 좋습니다.',
    ),
  ];

  /// 예약 및 업체 선택 정보 (Booking and company selection)
  static const List<_InfoItem> _bookingTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '사전 예약 필수',
      description:
          '성수기나 연휴 기간에는 차량 수요가 급증하므로 미리 예약하여 차량을 확보하는 것이 좋습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMagnifyingGlass,
      title: '가격 비교 사이트 활용',
      description:
          '스카이스캐너, 부킹닷컴, 가이드투더필리핀 등 비교 사이트를 활용하면 지역별 렌트카 가격을 한눈에 비교할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBuilding,
      title: '다양한 업체 선택',
      description:
          'Hertz, Avis, Europcar 등 국제 업체부터 Saferide, LXV Cars 같은 현지 업체까지 후기 평판, 가격, 차량 종류를 꼼꼼히 비교하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: '대여 약관 검토',
      description:
          '운행 거리 제한, 추가 운전자 등록 비용, 공항 픽업 추가요금, 반납 지연 시 요금 등을 반드시 확인하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '보험 확인',
      description:
          '종합 보험(CDW) 가입 여부, 자차 손해 면책금, 제3자 책임보험 적용 범위를 확인하여 만약의 사고에 대비해야 합니다.',
    ),
  ];

  /// 운전기사 포함 렌트카 장점 (Benefits of driver-included rental)
  static const List<_InfoItem> _driverBenefits = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '현지 지리에 밝은 운전사',
      description:
          '기사가 주행 경로와 교통 상황을 잘 알고 있어 이동 시간이 단축되고, 휴게 장소나 관광 포인트를 추천받을 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHandHoldingHeart,
      title: '편의성 및 안전',
      description:
          '여러 명이 함께 이동할 경우 승합차 한 대로 모두 이동하니 그랩을 여러 대 부르는 번거로움이 없고 비용도 절약됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBellConcierge,
      title: '추가 서비스',
      description:
          '일부 기사들은 여행 가이드처럼 현지 정보 제공이나 짐 운반 도움 등을 해주어 만족도가 높습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightReceipt,
      title: '별도 비용 확인 필요',
      description:
          '기사 식비와 팁, 유류비, 톨게이트 비용 등은 보통 대여료에 포함되지 않아 이용자가 별도로 부담해야 합니다.',
    ),
  ];

  /// 이용 절차 (Rental Process Steps)
  static const List<_StepItem> _rentalSteps = [
    _StepItem(
      step: 1,
      title: '국제운전면허증 준비',
      description:
          '영문 표기가 된 한국 운전면허증이 기본이며, 입국 후 90일간은 이것만으로 운전이 가능합니다. 업체에 따라 국제운전면허증(IDP)을 요구하므로 미리 발급받아 지참하세요.',
    ),
    _StepItem(
      step: 2,
      title: '여권 및 보증',
      description:
          '렌트카 계약 시 여권 제시는 필수입니다. 신뢰도가 낮은 업체가 여권 원본을 보관하려고 하면 절대 허용하지 마세요. 결제는 주로 신용카드로 이루어지며 보증금 목적으로 카드에 홀드됩니다.',
    ),
    _StepItem(
      step: 3,
      title: '차량 인수',
      description:
          '예약한 날짜와 장소에서 계약서와 차량 상태 점검표를 작성합니다. 차량 외부와 내부를 꼼꼼히 살피고 흠집이나 손상 부위를 사진/동영상으로 기록해 두세요.',
    ),
    _StepItem(
      step: 4,
      title: '연료 규정 확인',
      description:
          '대부분 만땅 인수-만땅 반납(Full-to-Full) 정책입니다. 인수 시 연료 게이지를 확인하고 반납 시 같은 수준으로 채워야 합니다.',
    ),
    _StepItem(
      step: 5,
      title: '보험 확인',
      description:
          '기본 대인 배상책임 보험(CTPL)은 상대방 피해만 보상합니다. 자차 손상 면책(CDW), 도난 보험(THW), 개인 상해 보험(PAI) 등의 가입 여부를 확인하세요.',
    ),
  ];

  /// 교통 법규 정보 (Traffic Rules)
  static const List<_InfoItem> _trafficRules = [
    _InfoItem(
      icon: FontAwesomeIcons.lightArrowRight,
      title: '우측 통행',
      description:
          '필리핀은 한국과 동일하게 우측 통행이며 좌측에 운전석이 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightGauge,
      title: '제한 속도',
      description:
          '도심부 약 40km/h, 일반 도로 60km/h, 고속도로 80~100km/h입니다. 실제로는 제한 속도를 엄격히 지키지 않는 편이므로 방어 운전이 필요합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserShield,
      title: '안전벨트 필수',
      description:
          '모든 좌석의 안전벨트 착용이 법규화되어 있고 위반 시 현장 벌금이 부과됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBan,
      title: '음주 운전 금지',
      description:
          '혈중 알코올 0.05% 초과 시 중범죄로 간주되어 즉각 구금 또는 고액의 벌금형에 처해집니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMobileScreenButton,
      title: '휴대전화 사용 금지',
      description:
          '운전 중 휴대전화 사용은 금지이며, 통화가 필요하면 블루투스 핸즈프리를 사용해야 합니다.',
    ),
  ];

  /// 운전 환경 정보 (Driving Environment)
  static const List<_InfoItem> _drivingEnvironment = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '혼잡한 교통',
      description:
          '경적 사용이 빈번하고 차선 변경이나 끼어들기가 수시로 일어납니다. 교통신호 무시나 급정거하는 차량도 있으니 항상 주의하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMotorcycle,
      title: '다양한 교통수단 혼재',
      description:
          '지프니, 트라이시클, 오토바이, 자전거 등 다양한 교통수단이 혼재하기 때문에 방어운전과 양보 운전이 필수입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightLocationCrosshairs,
      title: '네비게이션 앱 활용',
      description:
          'Waze나 구글 지도 앱을 활용하면 실시간 교통 상황을 파악하여 막히는 구간을 피해 다닐 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: 'RFID 전자태그',
      description:
          '일부 고속도로는 RFID 전자태그 사전 장착 차량만 통행을 허용하므로, 렌트 차량에 해당 장치가 있는지 확인해야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSquareParking,
      title: '유료 주차장 이용',
      description:
          '도시 내 주차는 유료 주차장을 이용하는 것이 안전하며, 불법 주차 시 견인 및 벌금에 처해질 수 있습니다.',
    ),
  ];

  /// 요금 정보 (Fee Information)
  static const List<_FeeItem> _feeInfo = [
    _FeeItem(
      type: '소형~중형 승용차 (Sedan)',
      price: '약 3,000~4,000페소',
      krw: '약 8~12만 원',
      note: '4인승 승용차 12시간 기준',
    ),
    _FeeItem(
      type: 'SUV 및 7~9인승 밴',
      price: '약 4,000~5,000페소',
      krw: '약 12~15만 원',
      note: '현대 스타렉스급 9인승',
    ),
    _FeeItem(
      type: '대형 승합차 (12~15인승)',
      price: '약 5,000~6,500페소',
      krw: '약 15~19만 원',
      note: '단체 여행용 미니버스',
    ),
    _FeeItem(
      type: '고급 차량/특수 서비스',
      price: '약 12,000~15,000페소',
      krw: '약 35~45만 원',
      note: '알파드급 VIP 밴 기준',
    ),
  ];

  /// 추가 팁 정보 (Additional Tips)
  static const List<_InfoItem> _additionalTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightBuildingCircleCheck,
      title: '평판 좋은 업체 이용',
      description:
          '무허가 개인 소개나 매우 싼 가격을 내세우는 비공식 렌트는 피하세요. 공식 등록된 업체 또는 신뢰할 수 있는 한인업체를 이용하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCameraRetro,
      title: '차량 상태 확인 철저',
      description:
          '인수 시 차량 상태 점검을 꼼꼼히 하고, 계약서에 모든 흠집을 기록해 두세요. 타이어 공기압, 비상등/라이트, 에어컨 작동 여부를 체크하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFileLines,
      title: '약관 숙지',
      description:
          '연료 규정, 주행거리 제한, 연장 시 요금 등을 숙지해야 추후 불필요한 추가 비용을 피할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMapLocation,
      title: '지역별 특성 고려',
      description:
          '세부나 보홀에서는 시내 이동에 택시나 그랩이 저렴할 수 있지만, 교외 이동이나 관광지 투어에는 렌트카가 유리합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '장기 체류 시 면허 전환',
      description:
          '90일을 초과하여 운전할 계획이라면 LTO(필리핀 교통부)에서 현지 면허증을 취득하거나 한국 면허를 공증 번역하여 인정받는 절차가 필요합니다.',
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
              FontAwesomeIcons.lightCar,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(l10n.carRental),
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

            /// [렌트카 이용 이유 섹션 - Why Rent Car Section]
            _buildSectionHeader(
              context,
              emoji: '🚗',
              title: '필리핀에서 렌트카를 이용해야 하는 이유',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _whyRentCar, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [예약 및 업체 선택 섹션 - Booking Section]
            _buildSectionHeader(
              context,
              emoji: '📝',
              title: '렌트카 예약 및 업체 선택',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _bookingTips, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [운전기사 포함 렌트카 섹션 - Driver Benefits Section]
            _buildSectionHeader(
              context,
              emoji: '👨‍✈️',
              title: '운전기사 포함 렌트카의 특징과 장점',
            ),
            SizedBox(height: sp.s12),
            _buildDriverBenefitsSection(context),

            SizedBox(height: sp.s24),

            /// [이용 절차 섹션 - Rental Process Section]
            _buildSectionHeader(
              context,
              emoji: '📄',
              title: '렌트카 이용 절차와 필요 서류',
            ),
            SizedBox(height: sp.s12),
            _buildStepGuide(context, _rentalSteps),

            SizedBox(height: sp.s24),

            /// [교통 법규 섹션 - Traffic Rules Section]
            _buildSectionHeader(
              context,
              emoji: '🚦',
              title: '현지 교통 법규',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _trafficRules, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [운전 환경 섹션 - Driving Environment Section]
            _buildSectionHeader(
              context,
              emoji: '🛣️',
              title: '운전 환경',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _drivingEnvironment, scheme.surfaceContainerHighest),

            SizedBox(height: sp.s24),

            /// [요금 정보 섹션 - Fee Section]
            _buildSectionHeader(
              context,
              emoji: '💰',
              title: '렌트카 비용 및 평균 가격대',
            ),
            SizedBox(height: sp.s12),
            _buildFeeTable(context),
            SizedBox(height: sp.s12),
            _buildFeeNote(context),

            SizedBox(height: sp.s24),

            /// [추가 팁 섹션 - Additional Tips Section]
            _buildSectionHeader(
              context,
              emoji: '⚠️',
              title: '렌트카 이용 시 추가 팁 및 주의사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _additionalTips, scheme.errorContainer),

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
                '🚗',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 렌트카\n이용 방법 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '기사 포함 렌트카로 편리하고 안전하게 여행하세요',
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

  /// 운전기사 포함 렌트카 섹션 빌드 (Build driver benefits section)
  Widget _buildDriverBenefitsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: [
        /// 가격 예시 카드 (Price example card)
        Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sp.s12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  FontAwesomeIcons.lightVanShuttle,
                  size: 24,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '12시간 기준 승합차 (그랜드 스타렉스)',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      '약 4,000~5,000페소 (기사 포함)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      '※ 연료비, 톨비, 주차비, 기사 식사비는 별도',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sp.s12),

        /// 장점 목록 (Benefits list)
        _buildInfoCards(context, _driverBenefits, scheme.secondaryContainer),
      ],
    );
  }

  /// 단계별 가이드 빌드 (Build step guide)
  Widget _buildStepGuide(BuildContext context, List<_StepItem> steps) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: steps.map((step) {
        final isLast = step == steps.last;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 단계 번호 원형 배지 (Step number badge)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      step.description,
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

  /// 요금 테이블 빌드 (Build fee table)
  Widget _buildFeeTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: _feeInfo.asMap().entries.map((entry) {
          final index = entry.key;
          final fee = entry.value;
          final isFirst = index == 0;
          final isLast = index == _feeInfo.length - 1;

          return Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fee.type,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      fee.price,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fee.note,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      fee.krw,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 요금 참고 사항 빌드 (Build fee note)
  Widget _buildFeeNote(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleInfo,
            size: 16,
            color: scheme.tertiary,
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Text(
              '위 요금에는 운전기사 인건비와 차량 비용, 연료와 통행료 등이 포함된 경우가 많지만, 기사 팁, 식사비, 주차비 등은 별도입니다. 예약 전에 포함/불포함 항목을 확인하세요.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '기사 포함 렌트카로 편안하고 안전하게 이동',
      '성수기에는 반드시 사전 예약 필수',
      '차량 인수 시 상태 점검 및 사진 촬영 권장',
      '국제운전면허증 지참 (90일 이내)',
      '보험 가입 여부 및 포함/불포함 항목 확인 필수',
      '대도시 교통 체증 감안하여 일정 계획',
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
                '🚘',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🇵🇭',
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
