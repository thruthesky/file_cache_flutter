import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 음식 배달 정보 아이템 데이터 클래스 (Food Delivery Info Item Data Class)
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
  /// 비용 항목명 (Fee name)
  final String name;

  /// 내용 및 부과 기준 (Content and criteria)
  final String content;

  /// 강조 표시 여부 (Highlight flag)
  final bool isHighlighted;

  const _FeeItem({
    required this.name,
    required this.content,
    this.isHighlighted = false,
  });
}

/// 필리핀 GrabFood 음식 배달 서비스 안내 화면 (GrabFood Delivery Guide Screen)
///
/// 필리핀에서 Grab 앱을 이용한 음식 배달 정보를 상세히 제공합니다.
/// Provides detailed information about food delivery using Grab app in the Philippines.
class FoodDeliveryScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/FoodDelivery';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const FoodDeliveryScreen({super.key});

  @override
  State<FoodDeliveryScreen> createState() => _FoodDeliveryScreenState();
}

class _FoodDeliveryScreenState extends State<FoodDeliveryScreen> {
  /// GrabFood 소개 정보 (GrabFood Introduction Info)
  static const List<_InfoItem> _grabFoodIntro = [
    _InfoItem(
      icon: FontAwesomeIcons.lightMobileScreenButton,
      title: '슈퍼앱 Grab',
      description:
          'Grab은 택시 호출부터 음식 배달까지 다양한 서비스를 제공하는 동남아시아 대표 슈퍼앱입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightRocket,
      title: '빠른 성장',
      description:
          '2018년 후반 필리핀 출시 후 불과 반년 만에 마닐라 지역 1위 음식 배달 플랫폼으로 성장했습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '광범위한 서비스 지역',
      description:
          '메트로 마닐라, 세부를 비롯해 Bulacan, Rizal, Cavite, Laguna, Pampanga, Bacolod, Davao 등에서 이용 가능합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '24시간 운영',
      description:
          '메트로 마닐라와 세부 등 일부 지역에서는 24시간 음식 배달 서비스를 제공합니다. 일반적으로 오전 7시부터 새벽 2시까지 이용 가능합니다.',
    ),
  ];

  /// 음식 주문 절차 (Order Process Steps)
  static const List<_StepItem> _orderSteps = [
    _StepItem(
      step: 1,
      title: 'Grab 앱 실행',
      description:
          '스마트폰에서 Grab 앱을 열고 홈 화면에서 "Food" 메뉴를 선택합니다. 처음 사용 시 앱 다운로드 및 회원가입이 필요합니다.',
    ),
    _StepItem(
      step: 2,
      title: '배달 주소 설정',
      description:
          'GPS로 현재 위치를 자동 인식하지만, 정확한 배달을 위해 건물 이름, 동/호수 등 상세 주소를 입력합니다.',
    ),
    _StepItem(
      step: 3,
      title: '음식점 및 메뉴 선택',
      description:
          '카테고리별로 음식점을 탐색하거나 원하는 식당/메뉴를 검색합니다. 한식, 현지식, 패스트푸드 등 다양한 선택이 가능합니다.',
    ),
    _StepItem(
      step: 4,
      title: '장바구니 담기',
      description:
          '원하는 메뉴를 장바구니에 담습니다. 주문 최소 금액(₱150) 미만 시 소액 주문 수수료가 발생합니다.',
    ),
    _StepItem(
      step: 5,
      title: '결제 및 주문 확인',
      description:
          '배달 주소와 연락처를 확인하고 결제 수단을 선택합니다. 신용카드, GrabPay, 현금, PayPal 등 다양한 결제 방법을 지원합니다.',
    ),
    _StepItem(
      step: 6,
      title: '실시간 배달 추적',
      description:
          '주문이 접수되면 앱에서 실시간 진행 상황을 확인할 수 있습니다. 지도상에 배달원의 위치와 예상 도착 시간이 표시됩니다.',
    ),
    _StepItem(
      step: 7,
      title: '음식 수령',
      description:
          '배달원이 도착하면 음식을 받습니다. 현금 결제 시 이때 지불하고, 카드/GrabPay는 추가 지불 없이 바로 수령합니다.',
    ),
  ];

  /// 배달 요금 정보 (Delivery Fee Info)
  static const List<_FeeItem> _feeInfo = [
    _FeeItem(
      name: '배달료 (Delivery Fee)',
      content: '거리 및 실시간 수요에 따라 책정\n보통 ₱40~₱150 수준\n피크시간대에는 더 높아질 수 있음',
    ),
    _FeeItem(
      name: '소액 주문 수수료',
      content: '주문 금액 ₱150 미만 시 ₱20 부과\n₱150 이상 주문 시 면제',
      isHighlighted: true,
    ),
    _FeeItem(
      name: '플랫폼 서비스 수수료',
      content: '주문 금액의 약 10~15%\n결제 단계에서 자동 합산',
    ),
    _FeeItem(
      name: '팁 (선택사항)',
      content: '배달원에게 자발적 제공\n일반적으로 ₱20~₱50 정도\n현금 또는 앱으로 지급 가능',
    ),
  ];

  /// 절약 팁 정보 (Saving Tips)
  static const List<_InfoItem> _savingTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightPiggyBank,
      title: 'Saver Delivery',
      description:
          '약간 더 긴 배달 시간을 감수하면 배달료가 ₱28까지 저렴해질 수 있습니다. 최대 45분 이내 배달 조건입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCrown,
      title: 'GrabUnlimited',
      description:
          '월 ₱49의 멤버십으로 매일 무료 배달 혜택과 제휴 식당 할인 등 회원 전용 프로모션을 제공합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '프로모션 쿠폰',
      description: '앱 내 Offers/프로모션 탭에서 무료 배달 코드나 할인 쿠폰을 수시로 제공합니다.',
    ),
  ];

  /// 한국인 장점 정보 (Benefits for Koreans)
  static const List<_InfoItem> _koreanBenefits = [
    _InfoItem(
      icon: FontAwesomeIcons.lightLanguage,
      title: '낮은 언어 장벽',
      description:
          '앱 인터페이스가 영어로 제공되어 기본 영어만 알아도 이용 가능합니다. 필리핀어(Tagalog)를 몰라도 주문할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '안전하고 신뢰할 수 있는 서비스',
      description:
          'Grab은 동남아 전역에서 운영되는 대형 플랫폼으로, 고객 지원 체계가 갖춰져 있고 결제 안전성이 보장됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightBowlRice,
      title: '한국 음식 선택지',
      description:
          '필리핀 내 한인타운이나 도심에는 한국 음식점들도 GrabFood에 다수 입점해 있어 한식 배달이 가능합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightArrowsRotate,
      title: '익숙한 사용 경험',
      description:
          '배달의민족, 요기요 등 한국 배달앱과 유사한 방식으로 쉽게 적응할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHouseChimney,
      title: '안전한 식사 해결',
      description:
          '밤늦게 외출이 부담스럽거나, 무더운 날씨나 교통체증이 심할 때도 편리하게 음식을 받아볼 수 있습니다.',
    ),
  ];

  /// 알아두면 좋은 팁 (Useful Tips)
  static const List<_InfoItem> _usefulTips = [
    _InfoItem(
      icon: FontAwesomeIcons.lightLocationDot,
      title: '정확한 주소 입력',
      description:
          '필리핀은 주소 체계가 복잡하므로, 지도 핀과 상세 주소(건물명, 층/호 등)를 정확히 입력하세요. 배달 메모로 안내를 추가하면 좋습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightSimCard,
      title: '현지 유심칩 사용 권장',
      description:
          '회원가입 및 주문 확인을 위해 현지 휴대전화 번호가 있으면 편리합니다. 배달원 연락 수신에도 유용합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCoins,
      title: '현금 결제 시 잔돈 준비',
      description:
          '큰 지폐 사용 시 사전에 앱 채팅으로 알려주세요. 배달원이 잔돈을 가지고 다니지만 준비해 두면 좋습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightStar,
      title: '배달원 평점 남기기',
      description:
          '음식 수령 후 앱을 통해 배달원에 대한 평점 및 후기를 남길 수 있습니다. 서비스 개선에 반영됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHeadset,
      title: '고객지원 활용',
      description:
          '주문에 문제가 생긴 경우 앱 내 Help Center를 통해 채팅 또는 전화로 지원을 받을 수 있습니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
              FontAwesomeIcons.lightBurger,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            const Text('GrabFood 가이드'),
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

            /// [GrabFood란? 섹션 - What is GrabFood Section]
            _buildSectionHeader(
              context,
              emoji: '🥡',
              title: 'GrabFood란 무엇인가?',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _grabFoodIntro, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [주문 절차 섹션 - Order Process Section]
            _buildSectionHeader(
              context,
              emoji: '📝',
              title: '음식 주문 절차',
            ),
            SizedBox(height: sp.s12),
            _buildStepGuide(context, _orderSteps),

            SizedBox(height: sp.s24),

            /// [배달 요금 섹션 - Delivery Fee Section]
            _buildSectionHeader(
              context,
              emoji: '💸',
              title: '배달 요금과 수수료',
            ),
            SizedBox(height: sp.s12),
            _buildFeeTable(context),
            SizedBox(height: sp.s16),
            _buildSavingTipsSection(context),

            SizedBox(height: sp.s24),

            /// [배달 시간 섹션 - Delivery Time Section]
            _buildSectionHeader(
              context,
              emoji: '⏱',
              title: '평균 배달 소요 시간',
            ),
            SizedBox(height: sp.s12),
            _buildDeliveryTimeSection(context),

            SizedBox(height: sp.s24),

            /// [한국인 장점 섹션 - Korean Benefits Section]
            _buildSectionHeader(
              context,
              emoji: '🌏',
              title: '한국인이 이용할 때의 장점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _koreanBenefits,
              scheme.secondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [알아두면 좋은 팁 섹션 - Useful Tips Section]
            _buildSectionHeader(
              context,
              emoji: '💡',
              title: '알아두면 좋은 팁',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _usefulTips, scheme.tertiaryContainer),

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
                '📱',
                style: theme.textTheme.headlineMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🍴',
                style: theme.textTheme.headlineMedium,
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 GrabFood\n음식 배달 서비스 안내',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            'Grab 앱으로 간편하게 음식을 주문하고 배달받으세요',
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
              color: fee.isHighlighted
                  ? scheme.primaryContainer.withValues(alpha: 0.3)
                  : null,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    fee.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: fee.isHighlighted
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  flex: 3,
                  child: Text(
                    fee.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
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

  /// 절약 팁 섹션 빌드 (Build saving tips section)
  Widget _buildSavingTipsSection(BuildContext context) {
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
              Text(
                '🎁',
                style: theme.textTheme.titleMedium,
              ),
              SizedBox(width: sp.s8),
              Text(
                '배달료 절약 방법',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._savingTips.map((tip) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FaIcon(
                    tip.icon,
                    size: 16,
                    color: scheme.secondary,
                  ),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        SizedBox(height: sp.s4),
                        Text(
                          tip.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondaryContainer
                                .withValues(alpha: 0.8),
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
      ),
    );
  }

  /// 배달 시간 섹션 빌드 (Build delivery time section)
  Widget _buildDeliveryTimeSection(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 메인 시간 표시 (Main time display)
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s16,
                  vertical: sp.s12,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightStopwatch,
                      size: 24,
                      color: scheme.onPrimaryContainer,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '약 30분',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '도심 지역 기준\n평균 30~40분 소요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 추가 정보 (Additional info)
          _buildTimeInfoRow(
            context,
            icon: FontAwesomeIcons.lightClockRotateLeft,
            title: 'Saver Delivery',
            description: '표준 배달보다 15~20분 더 소요되지만 배달료 절감',
          ),
          SizedBox(height: sp.s8),
          _buildTimeInfoRow(
            context,
            icon: FontAwesomeIcons.lightBolt,
            title: 'Instant Delivery',
            description: '가능한 한 빠른 배달 진행',
          ),
          SizedBox(height: sp.s8),
          _buildTimeInfoRow(
            context,
            icon: FontAwesomeIcons.lightTriangleExclamation,
            title: '피크타임 주의',
            description: '점심/저녁 시간대나 교통 정체 시 대기 시간 증가',
          ),
        ],
      ),
    );
  }

  /// 시간 정보 행 빌드 (Build time info row)
  Widget _buildTimeInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaIcon(
          icon,
          size: 14,
          color: scheme.primary,
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      'Grab 앱 하나로 음식 배달, 택시, 쇼핑까지 가능',
      '메트로 마닐라, 세부 등 주요 도시 24시간 운영',
      '평균 배달 시간 약 30분 (도심 기준)',
      '현금, 카드, GrabPay 등 다양한 결제 수단 지원',
      '한국 음식점도 다수 입점되어 한식 배달 가능',
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
                '🍽️',
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(width: sp.s8),
              Text(
                '🚚',
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
