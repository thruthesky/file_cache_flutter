import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 월세 정보 아이템 데이터 클래스 (Monthly Rent Info Item Data Class)
///
/// 각 월세 정보 아이템의 아이콘, 제목, 설명을 담습니다.
/// Contains icon, title, and description for each monthly rent info item.
class _RentInfoItem {
  /// 아이콘 (Icon)
  final IconData icon;

  /// 제목 (Title)
  final String title;

  /// 설명 (Description)
  final String description;

  const _RentInfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// 비교 항목 데이터 클래스 (Comparison Item Data Class)
///
/// 콘도와 주택 비교 테이블용 데이터입니다.
/// Data for condo vs house comparison table.
class _ComparisonItem {
  /// 항목명 (Category name)
  final String category;

  /// 콘도 정보 (Condo info)
  final String condo;

  /// 주택 정보 (House info)
  final String house;

  const _ComparisonItem({
    required this.category,
    required this.condo,
    required this.house,
  });
}

/// 계약 요약 데이터 클래스 (Contract Summary Data Class)
class _ContractSummary {
  /// 항목명 (Item name)
  final String label;

  /// 값 (Value)
  final String value;

  const _ContractSummary({required this.label, required this.value});
}

/// 월세 정보 화면 (Monthly Rent Screen)
///
/// 필리핀 월세/장기 임대 정보를 제공합니다.
/// Provides information about monthly rent in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// MonthlyRentScreen.push(context);
/// ```
class MonthlyRentScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/MonthlyRent';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const MonthlyRentScreen({super.key});

  @override
  State<MonthlyRentScreen> createState() => _MonthlyRentScreenState();
}

class _MonthlyRentScreenState extends State<MonthlyRentScreen> {
  /// 임대 계약 개요 (Rental contract overview)
  static const List<_RentInfoItem> _contractOverview = [
    _RentInfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '임대 기간',
      description: '기본 1년 계약 (6개월 단기 계약도 있으나 드물다)\n필리핀은 전세 제도가 없고 모든 임대가 월세 기반',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightMoneyBillWave,
      title: '보증금 (2+1 조건)',
      description:
          '보증금 2개월치 + 선납 월세 1개월치\n예: 월세 ₱20,000 → 초기비용 ₱60,000\n계약 종료 후 문제 없을 경우 보증금 반환',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightHandshake,
      title: '중개 수수료',
      description:
          '세입자 부담 없음 (한국과 다름)\n집주인이 중개인에게 월세 1개월분 지급\n비용 부담 없이 중개 서비스 이용 가능',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightFileInvoiceDollar,
      title: '월세 납부 방식',
      description:
          '매월 정해진 날짜에 납부\n장기 계약 시 선일자 수표(PDC) 11장 요구 흔함\n외국인은 매월 계좌이체/현금 납부로 대체 가능',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightLightbulb,
      title: '공과금 및 관리비',
      description:
          '전기·수도·인터넷: 월세와 별도로 세입자 부담\n콘도 관리비: 보통 월세에 포함되나 계약 전 확인 필수\n"inclusive of dues" 여부 반드시 확인!',
    ),
  ];

  /// 임대 계약 요약 정보 (Contract summary)
  static const List<_ContractSummary> _contractSummaryList = [
    _ContractSummary(label: '기간', value: '통상 1년 (6개월 단기는 제한적)'),
    _ContractSummary(label: '보증금', value: '월세 2개월분 (계약 종료 시 조건부 환불)'),
    _ContractSummary(label: '선납 임대료', value: '월세 1개월분 (첫 달 또는 마지막 달 월세)'),
    _ContractSummary(label: '월세 납부', value: '매월 지급 (장기 계약 시 선일자 수표 11장 요구)'),
    _ContractSummary(label: '중개 수수료', value: '세입자 부담 없음 (임대인이 중개인에게 지급)'),
  ];

  /// 콘도 vs 주택 비교 (Condo vs House comparison)
  static const List<_ComparisonItem> _comparisonItems = [
    _ComparisonItem(
      category: '🔒 보안',
      condo: '24시간 경비, CCTV\n출입 통제 우수',
      house: '경비 시스템 제한적\n(게이티드 커뮤니티 제외)',
    ),
    _ComparisonItem(
      category: '🏊 편의시설',
      condo: '수영장·헬스장 등 있음\n주차장 건물 내 제공',
      house: '개별 시설 이용\n차량 주차 공간 개별 확보',
    ),
    _ComparisonItem(
      category: '💰 임대료',
      condo: '비교적 높음\n스튜디오 ₱15k~30k/월',
      house: '다양함 (콘도 대비 저렴)\n방2-3개 집 ₱20~28k/월',
    ),
    _ComparisonItem(
      category: '🪑 가구상태',
      condo: '풀퍼니시드 많음\n(가전·가구 포함)',
      house: '빈집(bare) 많음\n(가구 직접 마련)',
    ),
    _ComparisonItem(
      category: '✅ 장점',
      condo: '도심 입지, 관리 편리\n외국인 소유 가능',
      house: '넓은 공간, 독립성\n반려동물 자유',
    ),
    _ComparisonItem(
      category: '⚠️ 유의',
      condo: '관리비 별도 여부 확인\n층간소음 거의 없음',
      house: '치안 주의, 계약 비공식 많음\n수도·전기 설비 점검 필요',
    ),
  ];

  /// 임대 물건 찾는 방법 (How to find rental properties)
  static const List<_RentInfoItem> _findingMethods = [
    _RentInfoItem(
      icon: FontAwesomeIcons.lightUsers,
      title: '한인 커뮤니티 사이트',
      description:
          '필고(PhilGo) 부동산/임대 게시판 활용\n한국어로 콘도·하우스 임대 매물 검색\n필사모, 한인 카페 등 경험담 공유\n초행자도 비교적 안심하고 임대 가능',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightUserTie,
      title: '부동산 중개인(브로커)',
      description:
          '필리핀인 공인중개사 또는 한국인 부동산 업체\n세입자 중개수수료 없음 (비용 부담 없이 서비스 이용)\n계약서 작성 및 공증 절차 안내 가능\nPRC 라이선스 보유 여부 확인 권장',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightGlobe,
      title: '온라인 부동산 플랫폼',
      description:
          'Lamudi, Property24, Facebook Marketplace\n원하는 지역과 예산으로 다양한 매물 검색\n중개인 게시글 많음, 시세보다 높게 책정된 경우 있음\n여러 매물 비교하여 시세 파악 선행 필요',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightPersonWalking,
      title: '직접 발품 팔기',
      description:
          '목표 지역 거리를 직접 돌아다니며 "For Rent" 표지 찾기\n집주인이 담장/1층 게시판에 안내 붙여놓는 경우 흔함\n중개 수수료 없는 직거래 물건 (가성비 좋음)\n기본 영어 회화 또는 현지 지인 도움 필요',
    ),
  ];

  /// 계약 시 유의사항 (Contract precautions)
  static const List<_RentInfoItem> _precautions = [
    _RentInfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '등기부등본(Title) 및 신원 확인',
      description:
          '집주인이 실제 소유주인지 등기부 등본 사본 요구\n소유주 이름이 신분증과 일치하는지 대조\n제3자 임대 사칭 피해 예방\n부동산 중개 통하면 브로커가 대신 확인',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightFileContract,
      title: '계약서 작성 및 공증',
      description:
          '임대차 계약서(Lease Contract) 꼼꼼히 작성\n양측 권리·의무 상세히 문서화\n변호사 사무실 또는 공증인(Notary Public) 통해 공증\n공증된 계약서는 법적 분쟁 시 증거력 높음',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightShieldCheck,
      title: '보증금 반환 조건 명시',
      description:
          '보증금의 용도와 반환 조건 명확히 규정\n정상적 계약 이행 시 전액 반환 내용 포함\n파손 범위의 판단 기준 합의\n중도 계약 해지 시 보증금 처리 약정 필요',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightCalendarXmark,
      title: '단기 임대 조건',
      description:
          '6개월 미만 임대는 월세 높게 책정 또는 거절 가능\n단기 임대 시 임대료 전액 선납 조건 흔함\n레지던스 호텔/서비스드 아파트 이용 고려\n단기 체류 시 일반 임대보다 비용 높음',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightWrench,
      title: '시설 및 하자 점검',
      description:
          '전기 배선, 수도 및 수압, 에어컨 등 작동 여부 확인\n낡은 주택은 수압 문제나 누전 주의\n해충 문제 체크 (열대기후라 개미·바퀴벌레 흔함)\n도배·페인트, 가구 파손 상태 기록 필수',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightHouseLock,
      title: '주변 환경 확인',
      description:
          '치안과 소음 환경 주변 이웃 통해 확인\n심하게 짖는 개나 새벽에 우는 닭 여부 확인\n야간 안전도(치안) 체크\n병원, 편의점, 대중교통 접근성 파악',
    ),
    _RentInfoItem(
      icon: FontAwesomeIcons.lightScrewdriverWrench,
      title: '유지보수 의무 확인',
      description:
          '계약서에 유지보수 책임 범위 숙지\n에어컨 고장, 배관 수리 등 일반적으로 집주인 부담\n경미한 수선은 세입자 부담일 수 있음\n분쟁 시 바랑가이 사무소에서 중재 시도',
    ),
  ];

  /// 참고 자료 (References)
  static const List<String> _references = [
    '📄 필리핀 부동산 주택 콘도 임대하는 방법 – 필사모 (2022.06)',
    '📄 필리핀에서 집구하기: 부동산 중개수수료는? – 필인러브 (2024.08)',
    '📄 필리핀에서 집구하기 (월세, 매매) 주의할 점 – 티스토리 (2021.01)',
    '📄 필리핀 월세 임대 (한국 전세 vs 필리핀 월세 비교) – 티스토리 (2025.05)',
    '📄 필리핀 콘도 임대: 관리비 관련 안내 – 필인러브 (2022.12)',
    '📄 Reddit – Postdated checks for rentals in Philippines',
    '🌐 PhilGo 필고 한인 커뮤니티 – 부동산 임대 게시판',
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
            FaIcon(FontAwesomeIcons.lightHouseBuilding, size: 20, color: scheme.primary),
            SizedBox(width: sp.s8),
            const Text('🇵🇭 필리핀 월세 임대 가이드'),
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
            /// [인트로 배너]
            _buildIntroBanner(context),

            SizedBox(height: sp.s24),

            /// [임대 계약 개요]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightFileSignature,
              title: '임대 계약 개요',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _contractOverview,
              scheme.primaryContainer,
              scheme.onPrimaryContainer,
            ),

            SizedBox(height: sp.s16),

            /// [계약 요약 박스]
            _buildContractSummaryBox(context),

            SizedBox(height: sp.s24),

            /// [임대 형태별 특징]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBuildingCircleArrowRight,
              title: '임대 형태별 특징: 콘도 vs 주택',
            ),
            SizedBox(height: sp.s12),
            _buildComparisonTable(context),

            SizedBox(height: sp.s16),

            /// [추천 팁]
            _buildTipBox(
              context,
              icon: FontAwesomeIcons.lightLightbulbOn,
              title: '어떤 형태를 선택할까?',
              content: '치안과 편의성을 중시하면 콘도, 넓은 공간과 독립성을 원하면 주택을 고려하세요.\n'
                  '필리핀에는 전세가 없고 오로지 월세 임대만 존재하므로, 주택 임대라도 초기 보증금 외에 큰 목돈이 들지 않습니다.',
            ),

            SizedBox(height: sp.s24),

            /// [임대 물건 찾는 방법]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightMagnifyingGlass,
              title: '임대 물건 찾는 방법',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _findingMethods,
              scheme.secondaryContainer,
              scheme.onSecondaryContainer,
            ),

            SizedBox(height: sp.s24),

            /// [계약 시 유의사항]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightTriangleExclamation,
              title: '계약 시 유의사항',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
              context,
              _precautions,
              scheme.errorContainer,
              scheme.onErrorContainer,
            ),

            SizedBox(height: sp.s24),

            /// [핵심 포인트 요약]
            _buildKeyPointsBox(context),

            SizedBox(height: sp.s24),

            /// [참고 자료]
            _buildSectionHeader(
              context,
              icon: FontAwesomeIcons.lightBookOpen,
              title: '참고 자료',
            ),
            SizedBox(height: sp.s12),
            _buildReferencesList(context),

            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 인트로 배너 빌드 (Build intro banner)
  Widget _buildIntroBanner(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primaryContainer,
            scheme.primaryContainer.withValues(alpha: 0.7),
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
                FontAwesomeIcons.lightHouseChimneyWindow,
                size: 24,
                color: scheme.onPrimaryContainer,
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Text(
                  '필리핀 콘도 및 주택 월세 임대',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀에서 거주할 집을 구할 때는 한국과 다른 임대 관행을 이해해야 합니다. '
            '필리핀은 한국처럼 전세 제도가 없고 모든 임대가 월세 기반으로 이루어집니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.onPrimaryContainer,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '외국인은 토지 소유가 불가능하여 콘도 임대 또는 주택 임대를 활용합니다.',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
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

  /// 정보 카드 빌드 (Build info cards)
  Widget _buildInfoCards(
    BuildContext context,
    List<_RentInfoItem> items,
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
                    /// 정보 카드 제목 (Info Card Title)
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

  /// 계약 요약 박스 빌드 (Build contract summary box)
  Widget _buildContractSummaryBox(BuildContext context) {
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
              /// 아이콘 크기 증가 (Icon size increased)
              /// 16 → 18으로 변경하여 가독성 향상
              FaIcon(
                FontAwesomeIcons.lightClipboardList,
                size: 18,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              /// 계약 요약 헤더 (Contract Summary Header)
              /// titleSmall → titleMedium으로 변경하여 가독성 향상
              Text(
                '필리핀 임대 계약 요약 (마닐라 기준)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ..._contractSummaryList.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    /// 계약 요약 라벨 (Contract Summary Label)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    /// 계약 요약 값 (Contract Summary Value)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.value,
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

  /// 비교 테이블 빌드 (Build comparison table)
  Widget _buildComparisonTable(BuildContext context) {
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
            padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s12),
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
                    '구분',
                    style: theme.textTheme.labelLarge?.copyWith(
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
                        FontAwesomeIcons.lightBuilding,
                        size: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                      SizedBox(width: sp.s4),
                      Text(
                        '콘도',
                        style: theme.textTheme.labelLarge?.copyWith(
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
                        FontAwesomeIcons.lightHouse,
                        size: 12,
                        color: scheme.onPrimaryContainer,
                      ),
                      SizedBox(width: sp.s4),
                      Text(
                        '주택',
                        style: theme.textTheme.labelLarge?.copyWith(
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

          /// 테이블 행 (Table rows)
          ..._comparisonItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == _comparisonItems.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s12),
              decoration: BoxDecoration(
                border: isLast
                    ? null
                    : Border(bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.3))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    /// 비교 테이블 카테고리 (Comparison Table Category)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    /// 비교 테이블 콘도 값 (Comparison Table Condo Value)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.condo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    /// 비교 테이블 주택 값 (Comparison Table House Value)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.house,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          /// 단위 설명 (Unit description)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                /// 아이콘 크기 증가 (Icon size increased)
                /// 12 → 14으로 변경하여 가독성 향상
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: sp.s8),
                /// 단위 설명 텍스트 (Unit Description Text)
                /// labelSmall → labelMedium으로 변경하여 가독성 향상
                Text(
                  '단위: ₱=필리핀 페소, 1페소≈24원 기준',
                  style: theme.textTheme.labelMedium?.copyWith(
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

  /// 팁 박스 빌드 (Build tip box)
  Widget _buildTipBox(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              /// 아이콘 크기 증가 (Icon size increased)
              /// 16 → 18으로 변경하여 가독성 향상
              FaIcon(icon, size: 18, color: scheme.onTertiaryContainer),
              SizedBox(width: sp.s8),
              /// 팁 박스 제목 (Tip Box Title)
              /// titleSmall → titleMedium으로 변경하여 가독성 향상
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          /// 팁 박스 내용 (Tip Box Content)
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onTertiaryContainer.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 포인트 박스 빌드 (Build key points box)
  Widget _buildKeyPointsBox(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final keyPoints = [
      '✅ 등기부등본과 신원 확인으로 사기 예방',
      '✅ 계약서 공증으로 법적 보호 강화',
      '✅ 보증금 반환 조건 명확히 명시',
      '✅ 시설 하자 및 주변 환경 꼼꼼히 점검',
      '✅ 필고(PhilGo) 커뮤니티에서 최신 임대 정보 확인',
    ];

    return Container(
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.secondaryContainer,
            scheme.secondaryContainer.withValues(alpha: 0.7),
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
              /// 아이콘 크기 증가 (Icon size increased)
              /// 16 → 18으로 변경하여 가독성 향상
              FaIcon(
                FontAwesomeIcons.lightStar,
                size: 18,
                color: scheme.onSecondaryContainer,
              ),
              SizedBox(width: sp.s8),
              /// 핵심 포인트 헤더 (Key Points Header)
              /// titleSmall → titleMedium으로 변경하여 가독성 향상
              Text(
                '핵심 포인트 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),
          ...keyPoints.map((point) {
            return Padding(
              padding: EdgeInsets.only(bottom: sp.s8),
              /// 핵심 포인트 항목 (Key Point Item)
              /// bodySmall → bodyMedium으로 변경하여 가독성 향상
              child: Text(
                point,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSecondaryContainer,
                  height: 1.4,
                ),
              ),
            );
          }),
          SizedBox(height: sp.s8),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            /// 핵심 포인트 하단 박스 (Key Points Bottom Box)
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              '철저한 사전조사와 꼼꼼한 계약으로 쾌적한 필리핀 거주 생활을 시작하세요!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 참고 자료 목록 빌드 (Build references list)
  Widget _buildReferencesList(BuildContext context) {
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
        children: _references.map((ref) {
          return Padding(
            padding: EdgeInsets.only(bottom: sp.s8),
            /// 참고 자료 항목 (Reference Item)
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              ref,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
