import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 택시 정보 아이템 데이터 클래스 (Taxi Info Item Data Class)
///
/// 각 택시 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each taxi info item.
class _TaxiInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  /// 경고 여부 (Warning flag)
  final bool isWarning;

  const _TaxiInfoItem({
    required this.icon,
    required this.title,
    required this.description,
    this.isWarning = false,
  });
}

/// 지역별 택시 이용 정보 데이터 클래스 (Region Taxi Info Data Class)
///
/// 각 지역의 택시 이용 가능 여부와 특징을 담습니다.
/// Contains taxi availability and characteristics for each region.
class _RegionTaxiInfo {
  /// 지역명 (Region name)
  final String region;

  /// 이용 가능 여부 (Availability)
  /// true: 있음, false: 없음, null: 드물음
  final bool? isAvailable;

  /// 비고 (Note)
  final String note;

  const _RegionTaxiInfo({
    required this.region,
    required this.isAvailable,
    required this.note,
  });
}

/// 요금 정보 데이터 클래스 (Fare Info Data Class)
class _FareInfo {
  /// 항목명 (Item name)
  final String item;

  /// 요금 (Fare)
  final String fare;

  const _FareInfo({required this.item, required this.fare});
}

/// 팁 아이템 데이터 클래스 (Tip Item Data Class)
class _TipItem {
  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _TipItem({required this.title, required this.description});
}

/// 일반 택시 정보 화면 (Regular Taxi Screen)
///
/// 필리핀 일반 택시 이용 정보를 제공합니다.
/// Provides information about regular taxi service in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// RegularTaxiScreen.push(context);
/// ```
class RegularTaxiScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/RegularTaxi';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const RegularTaxiScreen({super.key});

  @override
  State<RegularTaxiScreen> createState() => _RegularTaxiScreenState();
}

class _RegularTaxiScreenState extends State<RegularTaxiScreen> {
  /// [섹션 1] 길거리에서 택시 잡을 때 유의점
  /// Section 1: Tips for catching a taxi on the street
  static const List<_TaxiInfoItem> _streetTaxiTips = [
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightCarSide,
      title: '공식 택시 확인',
      description:
          '차체에 택시 회사명과 번호가 표기된 백색 택시(White Taxi)가 합법 택시입니다.\n차량 상단에 TAXI 표시등과 측면에 등록 번호를 확인하세요.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightGauge,
      title: '미터기 사용 확인',
      description:
          '승차 전 반드시 미터기 사용을 확인하세요.\n러시아워나 폭우 시에는 별도 요금을 요구하거나 승차를 거부하는 경우가 있습니다.',
      isWarning: true,
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '목적지 소통',
      description:
          '현지 발음으로 지명을 정확히 말하거나 지도를 보여주세요.\n주요 랜드마크(쇼핑몰, 호텔 등)를 기준으로 설명하면 좋습니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightSnowflake,
      title: '에어컨 확인',
      description:
          '대부분 택시는 에어컨을 켜주지만, 간혹 고장 등을 이유로 창문을 열고 운행하는 경우도 있습니다.',
    ),
  ];

  /// [섹션 2] 요금 구조 정보
  /// Section 2: Fare structure information
  static const List<_FareInfo> _fareStructure = [
    _FareInfo(item: '기본요금', fare: '₱50 (500m까지)'),
    _FareInfo(item: '거리요금', fare: '약 ₱13.5/km'),
    _FareInfo(item: '시간요금', fare: '약 ₱2.0/분 (정체 시)'),
  ];

  static const List<_TaxiInfoItem> _fareDetails = [
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightCalculator,
      title: '예상 요금 계산',
      description:
          '5km 이동: 약 ₱150~₱170\n10km 이동: 약 ₱300 안팎\n1km당 약 ₱20 정도로 계산하면 실제 요금과 비슷합니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightPlane,
      title: '공항 택시',
      description:
          '옐로 택시(공항 전용)는 기본요금이 더 높습니다.\n세부 막탄공항: 기본요금 ₱70\n마닐라 공항: 쿠폰택시(정액제) 이용 가능',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightTrafficLight,
      title: '교통 체증 주의',
      description:
          '교통 체증이 심하면 시간요금 때문에 최종 금액이 올라갑니다.\n교통량이 적은 시간대에 이동하면 저렴합니다.',
    ),
  ];

  /// [섹션 3] 결제 방식
  /// Section 3: Payment methods
  static const List<_TaxiInfoItem> _paymentInfo = [
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금만 가능',
      description:
          '신용카드나 모바일 결제는 불가합니다.\n반드시 필리핀 페소 현금을 준비하세요.',
      isWarning: true,
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightCoins,
      title: '소액권 필수',
      description:
          '₱20, ₱50, ₱100 등 소액권을 충분히 준비하세요.\n기사가 거스름돈이 없다고 하는 경우가 많습니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightHandHoldingDollar,
      title: '팁 (선택사항)',
      description:
          '팁은 의무가 아닙니다.\n거스름돈 몇 페소를 팁으로 주거나 받지 않고 두고 내리는 경우도 있습니다.',
    ),
  ];

  /// [섹션 4] 지역별 택시 이용 가능 여부
  /// Section 4: Regional taxi availability
  static const List<_RegionTaxiInfo> _regionInfo = [
    _RegionTaxiInfo(
      region: '메트로 마닐라 (수도권)',
      isAvailable: true,
      note: '가장 택시가 많음. 24시간 이용 가능, Grab도 보편적',
    ),
    _RegionTaxiInfo(
      region: '세부 시티 (Cebu City)',
      isAvailable: true,
      note: '세부 시내 및 공항에서 활발. 옐로 택시(공항전용) 존재',
    ),
    _RegionTaxiInfo(
      region: '다바오 시 (Davao City)',
      isAvailable: true,
      note: '택시 이용 가능. 기사들의 규칙 준수율이 비교적 높음',
    ),
    _RegionTaxiInfo(
      region: '보라카이 섬 (Boracay)',
      isAvailable: false,
      note: '택시 없음. 트라이시클(삼륜 오토바이) 이용',
    ),
    _RegionTaxiInfo(
      region: '그 외 지방 중소도시',
      isAvailable: null,
      note: '대부분 택시 없음. 지프니, 트라이시클, 하발하발 이용',
    ),
  ];

  /// [섹션 5] 안전 관련 사항
  /// Section 5: Safety information
  static const List<_TaxiInfoItem> _safetyInfo = [
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightLock,
      title: '문 잠금',
      description:
          '승차 후 문은 바로 잠그세요.\n창문도 필요 이상으로 열지 않는 것이 안전합니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '기사 정보 확인',
      description:
          '계기판에 기사 신원증명(ID) 카드가 부착되어 있는지 확인하세요.\n차량 번호, 기사 정보를 메모하거나 사진으로 찍어 두세요.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '위치 공유',
      description:
          '택시 번호판이나 차량 식별번호를 지인에게 알려두세요.\n스마트폰 지도 앱으로 이동 경로를 모니터링하면 좋습니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightPhone,
      title: '긴급 연락',
      description: '필리핀 긴급신고 번호: 911\n위급 상황에서는 주저 말고 신고하세요.',
      isWarning: true,
    ),
  ];

  /// [섹션 6] 문제 대처 요령
  /// Section 6: Handling problematic drivers
  static const List<_TaxiInfoItem> _troubleshooting = [
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightBan,
      title: '미터기 거부 시',
      description:
          '흥정 요금은 미터 요금보다 훨씬 높게 부르는 경향이 있습니다.\n안전한 장소에서 하차 후 다른 택시를 잡으세요.',
      isWarning: true,
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightHandshake,
      title: '협상이 필요한 경우',
      description:
          '밤늦게 다른 교통수단이 없다면 "미터 요금 + ₱50 추가" 등으로 제안할 수 있습니다.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '위험 운전 시',
      description:
          '"천천히 가 주세요(Please slow down)"라고 요청하세요.\n음주 운전이 의심되면 즉시 하차하세요.',
    ),
    _TaxiInfoItem(
      icon: FontAwesomeIcons.lightFileLines,
      title: '요금 분쟁 시',
      description:
          '차량 번호를 메모해 두세요.\nLTFRB 택시 민원 신고 핫라인: ☎ 1342\n과도한 언쟁은 피하고 사후에 신고하세요.',
    ),
  ];

  /// [섹션 7] 한국인을 위한 팁
  /// Section 7: Tips for Korean travelers
  static const List<_TipItem> _koreanTips = [
    _TipItem(
      title: '언어 소통',
      description:
          '기사들은 영어를 사용합니다. 목적지 이름을 영어 발음으로 준비하거나 스마트폰 지도 화면을 보여주세요.',
    ),
    _TipItem(
      title: '잔돈 마련',
      description:
          '₱20~₱100권 지폐와 동전을 챙기세요. 고액권은 편의점 등에서 미리 바꿔두세요.',
    ),
    _TipItem(
      title: '교통상황 이해',
      description:
          '마닐라 출퇴근 시간대는 평소보다 2배 이상 시간이 걸릴 수 있습니다. 구글 지도로 예상 시간을 확인하세요.',
    ),
    _TipItem(
      title: '경로 파악',
      description:
          '출발 전 주요 도로 경로를 머릿속에 넣어두면 우회 등을 예방할 수 있습니다.',
    ),
    _TipItem(
      title: 'Grab 앱 활용',
      description:
          'Grab은 예상 요금, 차량 번호, 기사 프로필을 미리 확인할 수 있어 안전합니다. 심야 시간대에 유용합니다.',
    ),
    _TipItem(
      title: '현지 관습 존중',
      description:
          'Sir/Ma\'am 등 존칭을 사용하면 친절한 대응을 받습니다. 하차 시 "Thank you(살라맛)"라고 인사하세요.',
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
              FontAwesomeIcons.lightTaxi,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.transportationRegularTaxi,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// [섹션 1] 길거리에서 택시 잡기
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightHandPointUp,
              title: '길거리에서 택시 잡을 때 유의점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _streetTaxiTips),

            SizedBox(height: sp.s24),

            /// [섹션 2] 요금 구조
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMoneyBill,
              title: '요금 구조 및 예상 요금',
            ),
            SizedBox(height: sp.s12),
            _buildFareTable(context),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _fareDetails),

            SizedBox(height: sp.s24),

            /// [섹션 3] 결제 방식
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCreditCard,
              title: '결제 방식: 현금만 가능',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _paymentInfo),

            SizedBox(height: sp.s24),

            /// [섹션 4] 지역별 택시 이용 가능 여부
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightGlobe,
              title: '지역별 택시 이용 가능 여부',
            ),
            SizedBox(height: sp.s12),
            _buildRegionTable(context),

            SizedBox(height: sp.s24),

            /// [섹션 5] 안전 관련 사항
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightShieldHalved,
              title: '안전 관련 사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _safetyInfo),

            SizedBox(height: sp.s24),

            /// [섹션 6] 문제 대처 요령
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTriangleExclamation,
              title: '문제가 있는 택시 기사를 만났을 때',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _troubleshooting),

            SizedBox(height: sp.s24),

            /// [섹션 7] 한국인을 위한 팁
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLightbulb,
              title: '한국인을 위한 추가 팁',
            ),
            SizedBox(height: sp.s12),
            _buildTipSection(context),

            SizedBox(height: sp.s24),

            /// [마무리 요약]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 빌드 (Build section header)
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
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

  /// 정보 카드 목록 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_TaxiInfoItem> items,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: items.map((item) {
        /// 경고 아이템은 다른 색상 사용 (Use different colors for warning items)
        final bgColor = item.isWarning
            ? scheme.errorContainer.withValues(alpha: 0.3)
            : scheme.surfaceContainerLow;
        final iconBgColor = item.isWarning
            ? scheme.error
            : scheme.primaryContainer;
        final iconColor = item.isWarning
            ? scheme.onError
            : scheme.onPrimaryContainer;

        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: bgColor,
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
                child: Center(
                  child: FaIcon(item.icon, size: 18, color: iconColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: item.isWarning
                                  ? scheme.error
                                  : scheme.onSurface,
                            ),
                          ),
                        ),
                        if (item.isWarning) ...[
                          SizedBox(width: sp.s4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: sp.s4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '중요',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onError,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  /// 요금표 빌드 (Build fare table)
  Widget _buildFareTable(BuildContext context) {
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
        children: _fareStructure.asMap().entries.map((entry) {
          final isLast = entry.key == _fareStructure.length - 1;
          final item = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.item,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.fare,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 지역별 택시 표 빌드 (Build region table)
  Widget _buildRegionTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _regionInfo.map((region) {
        /// 이용 가능 여부에 따른 색상 및 아이콘 결정
        /// Determine color and icon based on availability
        final IconData statusIcon;
        final Color statusColor;
        final String statusText;

        if (region.isAvailable == true) {
          statusIcon = FontAwesomeIcons.solidCircleCheck;
          statusColor = Colors.green;
          statusText = '있음';
        } else if (region.isAvailable == false) {
          statusIcon = FontAwesomeIcons.solidCircleXmark;
          statusColor = scheme.error;
          statusText = '없음';
        } else {
          statusIcon = FontAwesomeIcons.solidCircleMinus;
          statusColor = Colors.orange;
          statusText = '드물음';
        }

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
              /// 상태 아이콘 (Status icon)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(statusIcon, size: 16, color: statusColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            region.region,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: sp.s8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      region.note,
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

  /// 한국인 팁 섹션 빌드 (Build Korean tips section)
  Widget _buildTipSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.tertiaryContainer,
            scheme.tertiaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _koreanTips.asMap().entries.map((entry) {
          final isLast = entry.key == _koreanTips.length - 1;
          final tip = entry.value;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCheck,
                  size: 14,
                  color: scheme.onTertiaryContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        tip.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer.withValues(
                            alpha: 0.8,
                          ),
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
      '필리핀 일반 택시는 한국보다 저렴하지만 서비스 품질은 천차만별',
      '미터기 사용 확인과 소액 현금 준비가 핵심',
      '공항에서는 옐로 택시 또는 쿠폰택시 이용 가능',
      '안전을 위해 기사 정보 확인 및 위치 공유 권장',
      'Grab 앱을 병행하면 더욱 편리하게 이동 가능',
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
              FaIcon(
                FontAwesomeIcons.lightCircleInfo,
                size: 18,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s8),
              Text(
                '마무리 요약',
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
                  FaIcon(
                    FontAwesomeIcons.lightCheck,
                    size: 14,
                    color: scheme.onPrimaryContainer,
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
