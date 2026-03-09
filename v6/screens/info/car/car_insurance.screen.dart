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

/// 보험 비교 아이템 데이터 클래스 (Insurance Comparison Item Data Class)
class _InsuranceCompareItem {
  /// 구분 (Category)
  final String category;

  /// CTPL 값 (CTPL value)
  final String ctplValue;

  /// 종합보험 값 (Comprehensive value)
  final String comprehensiveValue;

  const _InsuranceCompareItem({
    required this.category,
    required this.ctplValue,
    required this.comprehensiveValue,
  });
}

/// 보험사 정보 아이템 데이터 클래스 (Insurance Company Item Data Class)
class _InsuranceCompanyItem {
  /// 보험사 이름 (Company name)
  final String name;

  /// 특징 및 서비스 (Features and services)
  final String features;

  const _InsuranceCompanyItem({
    required this.name,
    required this.features,
  });
}

/// 자동차 보험 정보 화면 (Car Insurance Screen)
///
/// 필리핀 자동차 보험 정보를 제공합니다.
/// Provides information about car insurance in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// CarInsuranceScreen.push(context);
/// ```
class CarInsuranceScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/CarInsurance';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const CarInsuranceScreen({super.key});

  @override
  State<CarInsuranceScreen> createState() => _CarInsuranceScreenState();
}

class _CarInsuranceScreenState extends State<CarInsuranceScreen> {
  /// 보험 비교 데이터 (Insurance comparison data)
  static const List<_InsuranceCompareItem> _insuranceComparison = [
    _InsuranceCompareItem(
      category: '⚖️ 법적 의무',
      ctplValue: '✅ 예 (필수 가입)',
      comprehensiveValue: '❌ 아니오 (선택 사항)',
    ),
    _InsuranceCompareItem(
      category: '🛡️ 보장 범위',
      ctplValue: '제3자의 신체 상해·사망 배상',
      comprehensiveValue: '차량 손상·도난, 화재 등 차량 자체 피해 + 대인·대물 배상',
    ),
    _InsuranceCompareItem(
      category: '💵 보장 한도',
      ctplValue: '약 ₱200,000 내 (제한적)',
      comprehensiveValue: '차량 가치 및 담보에 따라 설정 (수백만 페소까지 가능)',
    ),
    _InsuranceCompareItem(
      category: '💰 연간 보험료',
      ctplValue: '₱500~₱1,000 내외 (저렴)',
      comprehensiveValue: '₱10,000 이상 (차량 가치 등에 비례)',
    ),
  ];

  /// CTPL 보험 특징 (CTPL Insurance Features)
  static const List<_InfoItem> _ctplFeatures = [
    _InfoItem(
      icon: FontAwesomeIcons.lightGavel,
      title: '🚗 정부 의무 보험',
      description:
          '필리핀 정부가 모든 차량에 의무화한 보험으로, 교통사고 시 피보험 차량이 아닌 제3자의 부상이나 사망에 대한 배상만을 보장합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightMoneyBill,
      title: '💸 보상 한도',
      description:
          '인명 피해에 한해 약 10만~20만 페소 수준으로 한정되어 있으며, 차량 자체의 파손이나 운전자 본인·동승자의 부상은 대상이 아닙니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '📋 LTO 등록 필수 요건',
      description:
          'CTPL 가입은 차량 등록(LTO 등록) 및 갱신을 위한 필수 요건이며, 미가입 시 차량 운행이 법적으로 금지됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCoins,
      title: '💵 저렴한 보험료',
      description:
          '보험료는 차량 종류에 따라 연간 수백 페소대로 저렴합니다 (일반 승용차 약 ₱600~₱800 수준).',
    ),
  ];

  /// 종합보험 특징 (Comprehensive Insurance Features)
  static const List<_InfoItem> _comprehensiveFeatures = [
    _InfoItem(
      icon: FontAwesomeIcons.lightShieldHalved,
      title: '🛡️ 폭넓은 보장',
      description:
          '책임보험으로는 부족한 자신의 차량 손해 및 추가 배상책임까지 포괄적으로 보장하는 선택형 보험입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '🚙 차량 손해 보장',
      description:
          '차량 충돌 사고로 인한 자기 차량 수리비, 차량 도난, 화재 피해 등이 보상됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightUserShield,
      title: '👥 추가 보장 옵션',
      description:
          'CTPL을 넘어서는 대인 배상 추가액, 대물(다른 차량/재산 피해) 배상, 탑승자 개인상해보험(PA), 도로 긴급출동 서비스(견인 등)가 포함됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCloudBolt,
      title: '🌊 자연재해 특약',
      description:
          '자연재해 손해(홍수, 지진 등 Acts of God/AON) 등을 특약으로 추가할 수 있어 위험에 폭넓게 대비할 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightHandHoldingDollar,
      title: '💰 보험료 수준',
      description:
          '보험료는 보장 범위와 차량 가치에 따라 연간 수만 페소(예: ₱10,000~₱50,000 이상) 수준입니다.',
    ),
  ];

  /// 필요 서류 준비 정보 (Required Documents)
  static const List<_InfoItem> _requiredDocuments = [
    _InfoItem(
      icon: FontAwesomeIcons.lightCarSide,
      title: '🚗 차량 등록증 (CR) 및 영수증 (OR)',
      description:
          '차량의 소유주 및 등록 정보를 확인하기 위한 자료입니다. 반드시 준비해야 합니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightIdCard,
      title: '🪪 운전면허증 또는 여권',
      description:
          '운전자의 필리핀 면허증 또는 국제운전허가증, 여권 신분증 사본이 신원 확인용으로 요구됩니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightAward,
      title: '📜 무사고 운전 경력 증명서',
      description:
          '전 보험사의 무사고 증명(클레임 내역)을 제출하면 할인 혜택을 받을 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCamera,
      title: '📸 차량 외관 사진',
      description:
          '종합보험 가입 시 차량의 전후좌우 사진과 계기판 주행거리 사진 등을 업로드해야 합니다.',
    ),
  ];

  /// 보험사 목록 (Insurance Companies)
  static const List<_InsuranceCompanyItem> _insuranceCompanies = [
    _InsuranceCompanyItem(
      name: '🏢 AXA 필리핀',
      features: '글로벌 보험사 지사로 신뢰 높음, 온라인 견적 및 가입 지원',
    ),
    _InsuranceCompanyItem(
      name: '🌐 OONA (구 Mapfre)',
      features: '스페인계 보험사, 웹사이트에서 즉시 가입 및 24시간 출동 서비스 제공',
    ),
    _InsuranceCompanyItem(
      name: '🏦 Standard Insurance',
      features: '현지 대형 손해보험사, GCash 등 모바일 앱으로 CTPL 가입 가능',
    ),
    _InsuranceCompanyItem(
      name: '🏛️ Malayan Insurance',
      features: '필리핀 최대 규모 보험사, 광범위한 지점망과 안정된 보상 서비스',
    ),
  ];

  /// 가입 절차 (Application Steps)
  static const List<_StepItem> _applicationSteps = [
    _StepItem(
      step: 1,
      title: '📝 견적 문의 및 신청서 작성',
      description:
          '보험사 웹사이트에서 온라인 견적을 산출하거나 전화/이메일로 차량 정보를 제공합니다. 차량의 제조사, 모델, 연식, 차대번호, 등록번호, 운전자 정보 등을 정확히 기재해야 합니다.',
    ),
    _StepItem(
      step: 2,
      title: '📄 서류 및 사진 제출',
      description:
          '필수 서류 사본(OR/CR, 신분증 등)을 제출합니다. 온라인 가입 시 스캔이나 휴대폰 촬영본을 업로드하면 되며, 종합보험은 차량 사진도 필요합니다.',
    ),
    _StepItem(
      step: 3,
      title: '💳 보험료 납부',
      description:
          '신용카드 결제, 은행 송금, 전자지갑(GCash, Maya 등) 결제 등 다양한 온라인 결제 수단을 지원합니다. 보험사 지점에서 현금 납부도 가능합니다.',
    ),
    _StepItem(
      step: 4,
      title: '📋 증권 발행 및 수령',
      description:
          '결제 완료 후 이메일로 전자 증권(e-policy)과 증명서를 몇 분 내 전송받습니다. CTPL의 경우 LTO 제출용 증명서(COC)를 출력하거나 전자 통보를 확인합니다.',
    ),
    _StepItem(
      step: 5,
      title: '✅ 가입 완료 및 등록',
      description:
          '보험기간(통상 1년) 동안 보장이 유효합니다. 무사고로 1년을 보낸 경우 갱신 시 보험료 할인(No-Claim Bonus)을 받을 수 있습니다.',
    ),
  ];

  /// 유의 사항 및 팁 (Notes and Tips)
  static const List<_InfoItem> _importantNotes = [
    _InfoItem(
      icon: FontAwesomeIcons.lightTriangleExclamation,
      title: '⚠️ 한국과 다른 보상 한도',
      description:
          'CTPL은 보상한도가 낮아 큰 사고 발생 시 충분한 보상이 어려울 수 있습니다. 2024년 대형 사고에서 CTPL로 총 20만 페소만 지급된 사례가 있습니다. 종합보험 가입은 선택이 아닌 필수입니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCarBurst,
      title: '🚨 사고 시 절차',
      description:
          '교통사고 시 경찰 신고(Police Report) 및 보험사 통보가 필수입니다. 현장에서 사진/동영상을 확보하고, 24시간 사고 접수 핫라인에 연락하세요. 현지인과의 현장 금전 합의는 피하고 공식 절차를 따르세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightTrafficLight,
      title: '🚗 현지 교통환경 고려',
      description:
          '필리핀은 교통체증이 심하고 사고 위험이 높습니다. 보험 가입 시 보험사가 피해자 보상 절차를 대행해 주어 외국인으로서의 법적·언어적 어려움을 줄일 수 있습니다.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightFileLines,
      title: '📖 보험 약관 숙지',
      description:
          '음주운전이나 무면허운전 사고는 보상 제외 대상입니다. 자연재해 특약이 없으면 태풍·홍수 피해는 보상되지 않습니다. 자기부담금(Deductible) 조건도 확인하세요.',
    ),
    _InfoItem(
      icon: FontAwesomeIcons.lightCalendarCheck,
      title: '📅 정기적인 갱신',
      description:
          '보험은 보통 1년 단위 계약이며, 만료 전 갱신해야 합니다. 만료 시 무보험 상태가 되므로 스마트폰 알림을 설정해 두세요. 자동 갱신 서비스나 장기계약 할인도 검토해 보세요.',
    ),
  ];

  /// 체크리스트 (Checklist)
  static const List<String> _checklist = [
    '📋 차량 등록증(CR) 및 영수증(OR) 준비',
    '🪪 운전면허증/여권 사본 준비',
    '📸 차량 사진 촬영 (전후좌우 + 계기판)',
    '🏢 신뢰할 수 있는 보험사 선택',
    '💰 여러 보험사 견적 비교',
    '📝 온라인 또는 오프라인 가입 신청',
    '💳 보험료 납부 완료',
    '📄 보험 증권 및 COC 수령 확인',
    '📖 약관 및 예외 사항 숙지',
    '📅 갱신 일정 캘린더에 등록',
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
              FontAwesomeIcons.lightShieldHalved,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text('🇵🇭 ${l10n.carInsurance}'),
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

            /// [보험 종류 섹션 - Insurance Types Section]
            _buildSectionHeader(
              context,
              emoji: '📊',
              title: '필리핀 자동차 보험의 종류',
            ),
            SizedBox(height: sp.s12),
            _buildInsuranceComparison(context),

            SizedBox(height: sp.s24),

            /// [CTPL 보험 섹션 - CTPL Insurance Section]
            _buildSectionHeader(
              context,
              emoji: '🔒',
              title: 'CTPL (책임보험) 특징',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _ctplFeatures, scheme.primaryContainer),

            SizedBox(height: sp.s24),

            /// [종합보험 섹션 - Comprehensive Insurance Section]
            _buildSectionHeader(
              context,
              emoji: '🛡️',
              title: '종합보험 (Comprehensive) 특징',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _comprehensiveFeatures, scheme.secondaryContainer),

            SizedBox(height: sp.s24),

            /// [필요 서류 섹션 - Required Documents Section]
            _buildSectionHeader(
              context,
              emoji: '📁',
              title: '보험 가입을 위한 필요 서류',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(
                context, _requiredDocuments, scheme.tertiaryContainer),

            SizedBox(height: sp.s24),

            /// [보험사 선택 섹션 - Insurance Company Section]
            _buildSectionHeader(
              context,
              emoji: '🏢',
              title: '보험사 및 상품 선택',
            ),
            SizedBox(height: sp.s12),
            _buildInsuranceCompanies(context),

            SizedBox(height: sp.s24),

            /// [가입 절차 섹션 - Application Steps Section]
            _buildSectionHeader(
              context,
              emoji: '📋',
              title: '자동차 보험 가입 절차',
            ),
            SizedBox(height: sp.s12),
            _buildStepGuide(context, _applicationSteps),

            SizedBox(height: sp.s24),

            /// [유의 사항 섹션 - Important Notes Section]
            _buildSectionHeader(
              context,
              emoji: '⚠️',
              title: '유의 사항 및 한국인을 위한 팁',
            ),
            SizedBox(height: sp.s12),
            _buildInfoCards(context, _importantNotes, scheme.errorContainer),

            SizedBox(height: sp.s24),

            /// [체크리스트 섹션 - Checklist Section]
            _buildSectionHeader(
              context,
              emoji: '✅',
              title: '보험 가입 체크리스트',
            ),
            SizedBox(height: sp.s12),
            _buildChecklist(context),

            SizedBox(height: sp.s24),

            /// [요약 섹션 - Summary Section]
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
              Text('🚗', style: theme.textTheme.headlineMedium),
              SizedBox(width: sp.s8),
              Text('🛡️', style: theme.textTheme.headlineMedium),
              SizedBox(width: sp.s8),
              Text('🇵🇭', style: theme.textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: sp.s12),
          Text(
            '필리핀 자동차 보험\n가입 안내 가이드',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onPrimary,
              height: 1.3,
            ),
          ),
          SizedBox(height: sp.s8),
          Text(
            '안전한 운전 생활의 필수 요건! CTPL 의무보험부터 종합보험까지 완벽 정리',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: sp.s12),
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: [
              _buildBannerChip(context, '⚖️ CTPL 필수'),
              _buildBannerChip(context, '🛡️ 종합보험 권장'),
              _buildBannerChip(context, '📱 온라인 가입'),
            ],
          ),
        ],
      ),
    );
  }

  /// 배너 칩 빌드 (Build banner chip)
  Widget _buildBannerChip(BuildContext context, String label) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      /// 배너 칩 텍스트 (Banner Chip Text)
      /// labelSmall → labelMedium으로 변경하여 가독성 향상
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w500,
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

  /// 보험 비교 테이블 빌드 (Build insurance comparison table)
  Widget _buildInsuranceComparison(BuildContext context) {
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
          /// 헤더 (Header)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '📌 구분',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '🔒 책임보험 (CTPL)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '🛡️ 종합보험',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          /// 데이터 행 (Data rows)
          ...List.generate(_insuranceComparison.length, (index) {
            final item = _insuranceComparison[index];
            final isLast = index == _insuranceComparison.length - 1;

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
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    /// 비교 테이블 CTPL 값 (Comparison Table CTPL Value)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.ctplValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    /// 비교 테이블 종합보험 값 (Comparison Table Comprehensive Value)
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item.comprehensiveValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
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

  /// 보험사 목록 빌드 (Build insurance companies list)
  Widget _buildInsuranceCompanies(BuildContext context) {
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
          /// 보험사 목록 헤더 (Insurance Companies Header)
          /// titleSmall → titleMedium으로 변경하여 가독성 향상
          Text(
            '🌟 필리핀 주요 자동차보험사',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),
          ...List.generate(_insuranceCompanies.length, (index) {
            final company = _insuranceCompanies[index];
            final isLast = index == _insuranceCompanies.length - 1;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        company.name,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      flex: 3,
                      /// 보험사 특징 설명 (Insurance Company Features)
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      child: Text(
                        company.features,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) ...[
                  SizedBox(height: sp.s8),
                  Divider(
                    color: scheme.outlineVariant.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  SizedBox(height: sp.s8),
                ],
              ],
            );
          }),
          SizedBox(height: sp.s12),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('💡', style: theme.textTheme.bodyMedium),
                SizedBox(width: sp.s8),
                Expanded(
                  /// 보험사 선정 팁 (Insurance Company Selection Tip)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '보험사 선정 시 보장 범위, 보험료 수준, 고객 지원(사고 시 핫라인, 한국어 가능 직원 여부 등)을 함께 고려하세요.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
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
                    /// 단계별 가이드 제목 (Step Guide Title)
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

  /// 체크리스트 빌드 (Build checklist)
  Widget _buildChecklist(BuildContext context) {
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
        children: _checklist.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: sp.s8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.substring(0, 2), style: const TextStyle(fontSize: 16)),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    item.substring(3),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
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

  /// 마무리 요약 섹션 빌드 (Build summary section)
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    final summaryItems = [
      '🔒 CTPL(책임보험)은 법적 필수, 미가입 시 운행 불가',
      '🛡️ 종합보험으로 충분한 보장 확보 권장',
      '📱 온라인으로 간편하게 견적 비교 및 가입 가능',
      '📄 차량 서류(OR/CR)와 신분증만 있으면 가입 가능',
      '💰 무사고 시 갱신 할인(No-Claim Bonus) 혜택',
      '🚨 사고 시 보험사가 보상 절차 대행으로 안심',
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
              Text('🚗', style: theme.textTheme.titleLarge),
              SizedBox(width: sp.s8),
              Text('🛡️', style: theme.textTheme.titleLarge),
              SizedBox(width: sp.s8),
              Text('🇵🇭', style: theme.textTheme.titleLarge),
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
                  Text(item.substring(0, 2), style: theme.textTheme.bodyMedium),
                  SizedBox(width: sp.s8),
                  Expanded(
                    child: Text(
                      item.substring(3),
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
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text('💡', style: theme.textTheme.bodyLarge),
                SizedBox(width: sp.s8),
                Expanded(
                  /// 요약 섹션 팁 (Summary Section Tip)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '필리핀에서 자동차 보험은 안전한 운전 생활의 기본입니다. 믿을 수 있는 보험사를 통해 충분한 보장을 확보하여 만약의 사태에 대비하세요!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                      height: 1.5,
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
}
