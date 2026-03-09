import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 배달K 정보 아이템 데이터 클래스 (Baedal K Info Item Data Class)
///
/// 각 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each info item.
class _BaedalKInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _BaedalKInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 단계별 가이드 아이템 데이터 클래스 (Step Guide Item Data Class)
class _StepGuideItem {
  /// 단계 번호 (Step number)
  final int step;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _StepGuideItem({
    required this.step,
    required this.title,
    required this.description,
  });
}

/// 비교 테이블 아이템 데이터 클래스 (Comparison Table Item Data Class)
class _ComparisonItem {
  /// 항목명 (Item name)
  final String item;

  /// 배달K 값 (Baedal K value)
  final String baedalK;

  /// 글로벌 앱 값 (Global app value)
  final String globalApp;

  const _ComparisonItem({
    required this.item,
    required this.baedalK,
    required this.globalApp,
  });
}

/// 배달K 정보 화면 (Baedal K Screen)
///
/// 필리핀에서 배달K 앱을 이용한 한국 음식 배달 정보를 제공합니다.
/// 배달K는 필리핀 현지에서 운영되는 한국인 대상 음식 배달 플랫폼으로,
/// 한국어 지원, 한인 상권 특화, 카카오톡·한국식 결제 환경에 익숙한 사용자 인터페이스를 강점으로 합니다.
class BaedalKScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/BaedalK';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const BaedalKScreen({super.key});

  @override
  State<BaedalKScreen> createState() => _BaedalKScreenState();
}

class _BaedalKScreenState extends State<BaedalKScreen> {
  /// 배달K 앱 소개 - 개요 (Baedal K Overview)
  /// 필리핀 체류 한국인을 주요 이용자로 설정하며, 한식당 및 한인 업소 중심의 배달 서비스를 제공합니다.
  static const List<_BaedalKInfoItem> _baedalKIntro = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightMobileScreenButton,
      title: '배달K(Delivery K)란?',
      description:
          '필리핀 현지에서 운영되는 한국인 대상 음식 배달 플랫폼\n한국 음식점 및 한인 업소 중심의 배달 서비스 제공\n한국어 지원, 한인 상권 특화 서비스',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightMapLocationDot,
      title: '서비스 지역',
      description:
          '국가: 필리핀\n주요 지역: 마닐라, 마카티, BGC, 파사이 등\n대상: 필리핀 체류 한국인\n※ 지역별로 서비스 가능 여부는 상이할 수 있음',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightGift,
      title: '추가 서비스',
      description:
          '음식 배달 외에도 일부 지역에서\n생활 편의 서비스 및\n프로모션 바우처 제공 기능 함께 제공',
    ),
  ];

  /// 배달K 주요 특징 (Baedal K Main Features)
  /// 한국어 기반 서비스 환경, 한식 및 한인 업소 중심 구성, 필리핀 현지 상황에 맞춘 배달 운영
  static const List<_BaedalKInfoItem> _mainFeatures = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightLanguage,
      title: '한국어 기반 서비스 환경',
      description:
          '앱 및 웹 서비스 전반 한국어 제공\n주문 과정, 메뉴 설명, 결제 안내 한국어 확인 가능\n영어 사용이 어려운 이용자도 수월하게 주문 가능',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightBowlRice,
      title: '한식 및 한인 업소 중심 구성',
      description:
          '김치찌개, 삼겹살, 치킨, 분식 등 한국 음식 메뉴 비중 높음\n필리핀 현지 한인 식당, 한국 프랜차이즈 입점 비율 높음\n일부 지역에서는 한국 마트 상품 주문도 가능',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightTruck,
      title: '필리핀 현지 상황에 맞춘 배달 운영',
      description:
          '필리핀 도로 사정과 배달 환경을 고려한 운영 구조\n주문 후 배달 지연, 품절 등 발생 시 한국어 안내 제공',
    ),
  ];

  /// 주문 절차 (Order Steps)
  /// 6단계 주문 절차 요약
  static const List<_StepGuideItem> _orderSteps = [
    _StepGuideItem(
      step: 1,
      title: '배달K 접속',
      description: '배달K 웹 또는 앱 접속',
    ),
    _StepGuideItem(step: 2, title: '배달 지역 설정', description: '배달 받을 지역 설정'),
    _StepGuideItem(
      step: 3,
      title: '음식점 및 메뉴 선택',
      description: '원하는 음식점과 메뉴를 선택',
    ),
    _StepGuideItem(
      step: 4,
      title: '주문 정보 입력',
      description: '배달 주소, 연락처 등 주문 정보 입력',
    ),
    _StepGuideItem(step: 5, title: '결제 진행', description: '원하는 결제 수단으로 결제'),
    _StepGuideItem(step: 6, title: '배달 수령', description: '배달 도착 후 음식 수령'),
  ];

  /// 결제 수단 정보 (Payment Methods)
  /// 한국인 이용자 편의를 고려한 다양한 결제 방식 제공
  static const List<_BaedalKInfoItem> _paymentMethods = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightCreditCard,
      title: '카드 결제',
      description: '가능\n앱 내 카드 등록 후 결제',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '현금 결제',
      description: '지역별 상이\n배달원에게 직접 현금 지불',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '바우처',
      description: '가능\n공식 채널을 통해 할인 바우처 발급',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '온라인 결제',
      description: '가능\n※ 결제 수단은 지역 및 가맹점별로 차이 있음',
    ),
  ];

  /// 바우처(쿠폰) 제도 (Voucher System)
  /// 공식 채널을 통해 할인 바우처 발급, 특정 이벤트, 신규 가입, 제휴 프로모션 등을 통해 제공
  static const List<_BaedalKInfoItem> _voucherInfo = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightGift,
      title: '바우처 발급',
      description: '배달K 공식 채널을 통해 발급\n특정 이벤트, 신규 가입, 제휴 프로모션 등',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightReceipt,
      title: '바우처 사용',
      description: '주문 시 적용\n최소 주문 금액 등 조건 확인 필요',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '유효 기간',
      description: '기간 제한 있음\n배달K 공식 안내 페이지에서 확인 가능',
    ),
  ];

  /// 한국인에게 가지는 실질적 장점 (Practical Benefits for Koreans)
  static const List<_BaedalKInfoItem> _koreanBenefits = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightComments,
      title: '언어 장벽 최소화',
      description:
          '필리핀 체류 초기 단계의 한국인에게 가장 큰 어려움인 언어 문제 해결\n주문 전 과정이 한국어로 제공되어 언어 부담 없이 이용 가능',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightUtensils,
      title: '한국 음식 접근성 향상',
      description:
          '장기 체류 시 한국 음식에 대한 수요가 높아지는 경향\n한식 전문점 중심으로 구성되어 현지에서도 한국식 식생활 유지 가능',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightCircleInfo,
      title: '현지 정보 이해도 불필요',
      description:
          '일반 글로벌 배달 앱은 가맹점 정보, 리뷰, 메뉴 설명이 영어 또는 현지어\n배달K는 한국인 기준으로 정리된 정보 제공으로 추가 정보 탐색 부담 감소',
    ),
  ];

  /// 글로벌 배달 앱과의 비교 (Comparison with Global Apps)
  static const List<_ComparisonItem> _comparison = [
    _ComparisonItem(item: '언어', baedalK: '한국어', globalApp: '영어/현지어'),
    _ComparisonItem(item: '음식 구성', baedalK: '한식 중심', globalApp: '현지 음식 중심'),
    _ComparisonItem(item: '대상', baedalK: '한국인', globalApp: '전체 사용자'),
    _ComparisonItem(item: '고객 안내', baedalK: '한국어', globalApp: '영어 중심'),
  ];

  /// 이용 시 유의사항 (Important Notes)
  static const List<_BaedalKInfoItem> _notes = [
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightStore,
      title: '입점 음식점',
      description: '지역에 따라 입점 음식점 수가 제한적일 수 있음',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightClock,
      title: '배달 가능 시간',
      description: '가맹점 운영 시간에 따라 다름',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightCloudRain,
      title: '배달 지연',
      description: '필리핀 현지 공휴일, 기상 상황에 따라 배달이 지연될 수 있음',
    ),
    _BaedalKInfoItem(
      icon: FontAwesomeIcons.lightTicket,
      title: '바우처 조건',
      description: '바우처는 조건 미충족 시 적용되지 않음',
    ),
  ];

  /// 공식 참고 링크 (Official Reference Links)
  static const List<Map<String, String>> _officialLinks = [
    {
      'title': '바우처 발급 및 사용 안내',
      'url':
          'https://welcome.deliveryk.com/ko/post-partners-detail/%EB%B0%94%EC%9A%B0%EC%B2%98-%EB%B0%9C%EA%B8%89-%EB%B0%9C%EC%86%A1-%EB%B0%A9%EB%B2%95/',
    },
    {
      'title': '배달K 관련 검색 정보',
      'url':
          'https://www.google.com/search?q=%ED%95%84%EB%A6%AC%ED%95%80+%EB%B0%B0%EB%8B%ACk+%EC%95%B1+%EC%A3%BC%EB%AC%B8',
    },
  ];

  /// URL 열기 함수 (Open URL function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
              FontAwesomeIcons.lightBowlRice,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            const Text('배달K 가이드'),
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
            /// [배달K 소개 배너]
            _buildBanner(context),

            SizedBox(height: sp.s24),

            /// [배달K 개요 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCircleInfo,
              title: '배달K 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _baedalKIntro,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [배달K 주요 특징 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightStar,
              title: '주요 특징',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _mainFeatures,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [이용 방식 - 주문 절차 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBagShopping,
              title: '이용 방식 - 주문 절차',
            ),
            SizedBox(height: sp.s12),
            _buildStepGuide(context, _orderSteps),

            SizedBox(height: sp.s24),

            /// [결제 수단 정보 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightCreditCard,
              title: '결제 수단 정보',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _paymentMethods,
              scheme.tertiaryContainer,
              scheme.onTertiaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [바우처(쿠폰) 제도 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTicket,
              title: '바우처(쿠폰) 제도',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _voucherInfo,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [한국인에게 가지는 실질적 장점 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightThumbsUp,
              title: '한국인에게 가지는 실질적 장점',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _koreanBenefits,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [글로벌 배달 앱과의 비교 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightScaleBalanced,
              title: '글로벌 배달 앱과의 비교',
            ),
            SizedBox(height: sp.s12),
            _buildComparisonTable(context),

            SizedBox(height: sp.s24),

            /// [이용 시 유의사항 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTriangleExclamation,
              title: '이용 시 유의사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _notes,
              scheme.surfaceContainerHigh,
              scheme.onSurface,
            ),

            SizedBox(height: sp.s24),

            /// [공식 참고 링크 섹션]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightLink,
              title: '공식 참고 링크',
            ),
            SizedBox(height: sp.s12),
            _buildOfficialLinks(context),

            SizedBox(height: sp.s24),

            /// [마무리 요약]
            _buildSummarySection(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 상단 배너 빌드 (Build top banner)
  Widget _buildBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '배달K (Delivery K)',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: sp.s4),
                Text(
                  '필리핀 한인을 위한\n한국 음식 전문 배달 플랫폼',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sp.s8),
                Wrap(
                  spacing: sp.s8,
                  runSpacing: sp.s4,
                  children: [
                    _buildBadge(context, '한국어 100% 지원'),
                    _buildBadge(context, '한인 상권 특화'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: sp.s16),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightBowlRice,
                size: 32,
                color: scheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 배지 빌드 (Build badge)
  Widget _buildBadge(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      /// 배지 텍스트 (Badge Text)
      /// labelSmall → labelMedium으로 변경하여 가독성 향상
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
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
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_BaedalKInfoItem> items,
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
                child: Center(
                  child: FaIcon(item.icon, size: 18, color: iconColor),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 정보 카드 타이틀 (Info Card Title)
                    /// titleSmall → titleMedium으로 변경하여 가독성 향상
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),

                    /// 정보 카드 설명 (Info Card Description)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    Text(
                      item.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 단계별 가이드 빌드 (Build step guide)
  Widget _buildStepGuide(BuildContext context, List<_StepGuideItem> steps) {
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
                    /// 단계별 가이드 타이틀 (Step Guide Title)
                    /// titleSmall → titleMedium으로 변경하여 가독성 향상
                    Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),

                    /// 단계별 가이드 설명 (Step Guide Description)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    Text(
                      step.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 비교 테이블 빌드 (Build comparison table)
  Widget _buildComparisonTable(BuildContext context) {
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
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                  flex: 2,
                  child: Text(
                    '배달K',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '글로벌 앱',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 테이블 행 (Table rows)
          ..._comparison.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _comparison.length - 1;

            return Container(
              padding: EdgeInsets.all(sp.s12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(
                        bottom: BorderSide(
                          color: scheme.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
              ),
              child: Row(
                children: [
                  /// 비교 항목명 (Comparison Item Name)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),

                  /// 배달K 값 (Baedal K Value)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.baedalK,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  /// 글로벌 앱 값 (Global App Value)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.globalApp,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 공식 참고 링크 빌드 (Build official links)
  Widget _buildOfficialLinks(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Column(
      children: _officialLinks.map((link) {
        return Container(
          margin: EdgeInsets.only(bottom: sp.s8),
          child: Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => _launchUrl(link['url']!),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(sp.s12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: FaIcon(
                          FontAwesomeIcons.lightArrowUpRightFromSquare,
                          size: 18,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s12),
                    Expanded(
                      /// 공식 링크 타이틀 (Official Link Title)
                      /// titleSmall → titleMedium으로 변경하여 가독성 향상
                      child: Text(
                        link['title']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    FaIcon(
                      FontAwesomeIcons.lightChevronRight,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 마무리 요약 항목 (Summary items)
    final summaryItems = [
      '배달K는 필리핀 현지에서 운영되는 한국인 대상 음식 배달 플랫폼',
      '앱 전체 한국어 지원 - 주문 과정, 메뉴 설명, 결제 안내',
      '한식 및 한인 업소 중심 구성 (김치찌개, 삼겹살, 치킨, 분식 등)',
      '카드, 현금, 바우처, 온라인 결제 가능',
      '언어 장벽 최소화로 필리핀 체류 초기 한국인에게 유용',
      '지역별로 서비스 가능 여부 및 입점 음식점 수 상이',
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
                FontAwesomeIcons.lightLightbulb,
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
