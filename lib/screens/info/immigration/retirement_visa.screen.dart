import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 은퇴비자 정보 화면 (Retirement Visa Screen)
///
/// 필리핀 은퇴비자(SRRV) 정보를 제공합니다.
/// Provides information about Philippine retirement visa (SRRV).
///
/// ### 사용법 (Usage):
/// ```dart
/// RetirementVisaScreen.push(context);
/// ```
class RetirementVisaScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/RetirementVisa';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const RetirementVisaScreen({super.key});

  @override
  State<RetirementVisaScreen> createState() => _RetirementVisaScreenState();
}

class _RetirementVisaScreenState extends State<RetirementVisaScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = Lo.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.immigrationRetirementVisa,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// 하드코딩된 SRRV 정보 컨텐츠
      /// Hardcoded SRRV information content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 메인 타이틀 섹션
            _buildHeroSection(context),
            const SizedBox(height: 24),

            /// SRRV란 무엇인가 섹션
            _buildWhatIsSrrvSection(context),
            const SizedBox(height: 24),

            /// 신청 자격 및 대상 섹션
            _buildEligibilitySection(context),
            const SizedBox(height: 24),

            /// SRRV 비자 유형 및 예치금 섹션
            _buildVisaTypesSection(context),
            const SizedBox(height: 24),

            /// 주요 비용 구조 섹션
            _buildCostSection(context),
            const SizedBox(height: 24),

            /// 필수 제출 서류 섹션
            _buildDocumentsSection(context),
            const SizedBox(height: 24),

            /// 신청 절차 섹션
            _buildApplicationProcessSection(context),
            const SizedBox(height: 24),

            /// 취득 후 관리 및 유지 조건 섹션
            _buildMaintenanceSection(context),
            const SizedBox(height: 24),

            /// SRRV 혜택 섹션
            _buildBenefitsSection(context),
            const SizedBox(height: 24),

            /// SRRV vs 여행비자 vs 워킹비자 비교 섹션
            _buildVisaComparisonSection(context),
            const SizedBox(height: 24),

            /// FAQ 섹션
            _buildFaqSection(context),
            const SizedBox(height: 24),

            /// 참고 자료 섹션
            _buildReferencesSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 히어로 섹션 - 메인 타이틀 및 소개
  /// Hero section - Main title and introduction
  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🇵🇭',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '필리핀 은퇴비자 SRRV',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Special Resident Retiree\'s Visa',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '2025 완전 정리',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '필리핀 은퇴비자 SRRV는 필리핀 은퇴청(PRA: Philippine Retirement Authority)에서 운영하는 특별 비이민 장기 체류 비자입니다. 은퇴 또는 장기 거주를 원하는 외국인에게 제공되는 제도이며, 비교적 명확한 조건과 혜택으로 많은 외국인들이 신청하고 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.tertiary,
                ),
                const SizedBox(width: 8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Flexible(
                  child: Text(
                    '실제 비자는 필리핀 이민국(BI)에서 발급됩니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
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

  /// SRRV란 무엇인가 섹션
  /// What is SRRV section
  Widget _buildWhatIsSrrvSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightBrain,
      title: 'SRRV란 무엇인가?',
      child: Text(
        'SRRV는 필리핀에서 무기한 체류 및 복수 입출국이 가능한 체류 비자입니다. 비자 보유자는 관광비자처럼 주기적으로 연장할 필요 없이, 일정 요건을 유지하는 한 필리핀에 장기 거주할 수 있습니다.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
          height: 1.6,
        ),
      ),
    );
  }

  /// 신청 자격 및 대상 섹션
  /// Eligibility section
  Widget _buildEligibilitySection(BuildContext context) {
    final requirements = [
      {'label': '최소 연령', 'value': '만 40세 이상 (2025년 9월 기준 변경)'},
      {'label': '신분', 'value': '본인 유효 여권 + 필리핀 내 유효 관광비자(또는 입국 기록)'},
      {'label': '건강', 'value': '의학적 검사 결과 제출 (최근 6개월 이내)'},
      {'label': '범죄기록', 'value': '경찰 신원조회서 제출 (최근 6개월 이내)'},
      {'label': '예치금 요건', 'value': 'PRA 지정 은행에 일정 금액 예치'},
      {'label': '동반가족', 'value': '배우자 + 미혼 자녀(21세 미만) 포함 가능'},
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightUsers,
      title: '신청 자격 및 대상',
      subtitle: '한국인 포함 외국인',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionTitle(context, '📌 기본 자격'),
          const SizedBox(height: 12),
          ...requirements.map((req) => _buildRequirementRow(
                context,
                label: req['label']!,
                value: req['value']!,
              )),
          const SizedBox(height: 16),
          _buildInfoBox(
            context,
            '2025년부터는 40~49세 연령층도 SRRV Classic 또는 Courtesy 비자 신청이 가능하며(단 예치금이 더 높게 책정) 원칙적 최소 연령이 완화되었습니다.',
            icon: FontAwesomeIcons.lightArrowRight,
          ),
        ],
      ),
    );
  }

  /// SRRV 비자 유형 및 예치금 섹션
  /// Visa types and deposit section
  Widget _buildVisaTypesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightBriefcase,
      title: 'SRRV 비자 유형 및 예치금',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SRRV에는 여러 유형이 있으며, 가장 중요한 것은 예치금(Deposit)입니다. 이 금액은 필리핀 PRA 인증 은행에 예치해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          /// SRRV Classic 테이블
          _buildSubsectionTitle(context, '💰 SRRV Classic (기본 은퇴 비자)'),
          const SizedBox(height: 12),
          _buildDepositTable(
            context,
            headers: ['연령구간', '연금 있음', '연금 없음'],
            rows: [
              ['50세 이상', 'USD 15,000', 'USD 30,000'],
              ['40~49세', 'USD 25,000', 'USD 50,000'],
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoBox(
            context,
            '연금 있음 조건은 최소 월 USD 800 이상 연금 수령을 증명하는 경우입니다.',
            icon: FontAwesomeIcons.lightCoins,
          ),
          const SizedBox(height: 24),

          /// SRRV Courtesy 테이블
          _buildSubsectionTitle(context, '🎖️ SRRV Courtesy (특수 대상)'),
          const SizedBox(height: 12),
          _buildDepositTable(
            context,
            headers: ['유형', '연령', '예치금'],
            rows: [
              ['외국인 특별군', '50세 이상', 'USD 1,500'],
              ['외국인 특별군', '40~49세', 'USD 3,000 (연금)\nUSD 6,000 (비연금)'],
              ['전 필리핀 국적자', '50세 이상', 'USD 1,500'],
              ['전 필리핀 국적자', '40~49세', 'USD 3,000'],
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoBox(
            context,
            '이 옵션은 외교관, 국제기구 임직원, 군 경력자 혹은 그 외 특별 사유가 인정된 경우에 적용 가능성이 큽니다.',
            icon: FontAwesomeIcons.lightMedal,
          ),
        ],
      ),
    );
  }

  /// 주요 비용 구조 섹션
  /// Cost structure section
  Widget _buildCostSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightCreditCard,
      title: '주요 비용 구조',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SRRV는 예치금 외에도 몇 가지 필수 비용이 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubsectionTitle(context, '💰 비용 일람표'),
          const SizedBox(height: 12),
          _buildCostTable(context),
          const SizedBox(height: 16),
          _buildInfoBox(
            context,
            '예치금은 비용이 아니라 요건 충족을 위한 예치금이며, 비자 취소 시 환불이 가능합니다(단 투자 전환 시 예치금 규정이 변동될 수 있음).',
            icon: FontAwesomeIcons.lightCircleInfo,
          ),
        ],
      ),
    );
  }

  /// 비용 테이블 빌더
  /// Cost table builder
  Widget _buildCostTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final costs = [
      {
        'item': 'PRA 처리 수수료(본인)',
        'amount': 'USD 1,500',
        'timing': '접수 시',
        'note': '기본 신청 수수료'
      },
      {
        'item': 'PRA 처리 수수료(동반 1인)',
        'amount': 'USD 300',
        'timing': '접수 시',
        'note': '배우자/자녀 등'
      },
      {
        'item': 'PRA 연회비',
        'amount': 'USD 360',
        'timing': '매년',
        'note': '주 신청자 + 동반 2인 기준'
      },
      {
        'item': '연회비 추가(3인 초과)',
        'amount': 'USD 100/1인',
        'timing': '매년',
        'note': ''
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: costs.asMap().entries.map((entry) {
          final index = entry.key;
          final cost = entry.value;
          final isLast = index == costs.length - 1;

          return Container(
            padding: const EdgeInsets.all(16),
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
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cost['item']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (cost['note']!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                        Text(
                          cost['note']!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        cost['amount']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        cost['timing']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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

  /// 필수 제출 서류 섹션
  /// Required documents section
  Widget _buildDocumentsSection(BuildContext context) {
    final documents = [
      {'category': '신분/체류', 'doc': '여권 원본 + 관광비자', 'note': '6개월 이상 유효'},
      {'category': '비자 신청', 'doc': 'SRRV 신청서', 'note': 'PRA 양식'},
      {'category': '건강검진', 'doc': 'Medical Certificate', 'note': '6개월 이내 발급'},
      {'category': '범죄기록', 'doc': 'Police Clearance', 'note': '6개월 이내 발급'},
      {
        'category': '필리핀경찰기록',
        'doc': 'NBI Clearance',
        'note': '필리핀 30일 이상 체류 시'
      },
      {'category': '예치금 증명', 'doc': 'Bank Certificate', 'note': 'PRA 인증 은행 발급'},
      {
        'category': '사진',
        'doc': '2×2 여권 사진 (12매 등)',
        'note': '사무소 요구에 따라 다름'
      },
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightClipboardList,
      title: '필수 제출 서류',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionTitle(context, '✍️ 기본 서류 체크리스트'),
          const SizedBox(height: 12),
          ...documents.map((doc) => _buildDocumentItem(
                context,
                category: doc['category']!,
                document: doc['doc']!,
                note: doc['note']!,
              )),
          const SizedBox(height: 16),
          _buildInfoBox(
            context,
            '모든 해외 발급 서류는 영문 및 아포스티유(Apostille) 또는 영사확인이 필요할 수 있습니다.',
            icon: FontAwesomeIcons.lightFileCheck,
          ),
        ],
      ),
    );
  }

  /// 서류 항목 빌더
  /// Document item builder
  Widget _buildDocumentItem(
    BuildContext context, {
    required String category,
    required String document,
    required String note,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            child: Text(
              category,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  note,
                  style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 신청 절차 섹션
  /// Application process section
  Widget _buildApplicationProcessSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final steps = [
      {
        'step': '1',
        'title': '요건 평가 및 옵션 결정',
        'desc': '예치금, 연금 여부, 동반가족 등 SRRV 유형을 먼저 결정합니다.'
      },
      {
        'step': '2',
        'title': '서류 준비 및 인증',
        'desc': '서류 발급 후 필요한 경우 공증/아포스티유를 준비합니다.'
      },
      {
        'step': '3',
        'title': '예치금 해외 송금 및 은행 인증',
        'desc': 'PRA 인증 은행으로 예치금을 송금하고 은행 인증서(Bank Certificate)를 발급받습니다.'
      },
      {
        'step': '4',
        'title': 'PRA 접수 및 수수료 납부',
        'desc': '서류 일체와 수수료를 PRA 사무소에 제출합니다.'
      },
      {
        'step': '5',
        'title': '심사 및 승인',
        'desc': 'PRA가 서류 및 자격 요건을 검토합니다. 평균 3~6주 정도 소요될 수 있습니다.'
      },
      {
        'step': '6',
        'title': 'BI 비자 스티커 부착 및 SRRV ID 발급',
        'desc': '필리핀 이민국에서 SRRV 비자 스티커를 여권에 부착하고 PRA ID 카드를 발급합니다.'
      },
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightCompass,
      title: 'SRRV 신청 절차',
      subtitle: '일반적 흐름',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SRRV 비자 신청은 대부분 필리핀 현지에서 진행됩니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildSubsectionTitle(context, '⚙️ 단계별 처리 플로우'),
          const SizedBox(height: 12),
          ...steps.map((step) => _buildProcessStep(
                context,
                step: step['step']!,
                title: step['title']!,
                description: step['desc']!,
              )),
        ],
      ),
    );
  }

  /// 프로세스 스텝 빌더
  /// Process step builder
  Widget _buildProcessStep(
    BuildContext context, {
    required String step,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                step,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
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
  }

  /// 취득 후 관리 및 유지 조건 섹션
  /// Maintenance section
  Widget _buildMaintenanceSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final conditions = [
      {'icon': FontAwesomeIcons.lightCheck, 'text': '무기한 체류 가능 — 단 PRA 조건을 유지해야 합니다.'},
      {'icon': FontAwesomeIcons.lightCheck, 'text': '연회비 매년 납부 — PRA 연회비는 필수 요소입니다.'},
      {
        'icon': FontAwesomeIcons.lightCheck,
        'text': '신상 변경 신고 — 주소/여권 변경 시 PRA에 신고가 필요합니다.'
      },
      {
        'icon': FontAwesomeIcons.lightCheck,
        'text':
            '출입국 절차 상 편의 — Annual Report, Exit-Reentry Permit, ACR I-Card 면제 등 일부 이민국 요구사항이 적용되지 않습니다.'
      },
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightFileLines,
      title: '취득 후 관리 및 유지 조건',
      child: Column(
        children: conditions
            .map((condition) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        condition['icon'] as IconData,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          condition['text'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// SRRV 혜택 섹션
  /// Benefits section
  Widget _buildBenefitsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final benefits = [
      {'icon': '📍', 'title': '무기한 체류', 'desc': '조건 유지 시 비자 만료 없음'},
      {'icon': '🔁', 'title': '복수 입·출국', 'desc': '재입국 허가 없이 자유 입출국 가능'},
      {'icon': '🛃', 'title': '행정 절차 면제', 'desc': 'ACR-I 카드, Annual Report, ECC 등 면제'},
      {'icon': '📦', 'title': '관세/세금 혜택', 'desc': '주거용품 반입 시 최대 \$7,000 면제'},
      {
        'icon': '💼',
        'title': '투자/사업',
        'desc': 'SRRV Classic 일 경우 예치금을 승인된 투자로 전환 가능'
      },
      {'icon': '👨‍👩‍👧', 'title': '가족 동반', 'desc': '배우자 및 미성년 자녀 포함 가능'},
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightBullseye,
      title: 'SRRV 보유자의 대표 혜택',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSubsectionTitle(context, '📌 핵심 체류 혜택'),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final benefit = benefits[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      benefit['icon']!,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit['title']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    Flexible(
                      child: Text(
                        benefit['desc']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildInfoBox(
            context,
            '비자 자체는 취업 비자가 아니지만 사업/투자 또는 온라인 업무 등은 별도 허가 없이 가능합니다(단 현지 노동법 및 세금법 준수는 필수).',
            icon: FontAwesomeIcons.lightCircleInfo,
          ),
        ],
      ),
    );
  }

  /// SRRV vs 여행비자 vs 워킹비자 비교 섹션
  /// Visa comparison section - SRRV vs Tourist Visa vs Work Visa
  Widget _buildVisaComparisonSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightScaleBalanced,
      title: 'SRRV vs 여행비자 vs 워킹비자',
      subtitle: '2025년 기준 비교',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SRRV 비자가 여행비자(관광비자)나 워킹비자(취업비자)에 비해 어떤 점에서 더 편리하고 유리한지 비교해 보겠습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          /// 비교표
          _buildSubsectionTitle(context, '📊 비자 유형별 비교표'),
          const SizedBox(height: 12),
          _buildVisaComparisonTable(context),
          const SizedBox(height: 24),

          /// SRRV vs 여행비자
          _buildSubsectionTitle(context, '✨ SRRV가 여행비자보다 편한 점'),
          const SizedBox(height: 12),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightCalendarDays,
            title: '체류 기간이 훨씬 길다',
            description:
                'SRRV 비자는 조건을 유지하는 한 사실상 무기한 체류가 가능합니다. 반면 관광비자는 통상 30~59일이며, 이후 체류하려면 주기적으로 연장해야 합니다.',
            tip: '단순 관광 목적이 아니라 장기 생활 기반을 만들고자 한다면 SRRV가 훨씬 유리합니다.',
          ),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightPlaneDeparture,
            title: '입출국 편의가 뛰어나다',
            description:
                'SRRV 소지자는 복수 입출국이 자유롭고, 재입국 허가를 따로 받을 필요가 없습니다. 관광비자는 입국 시점마다 기간이 정해지고, 만료 시마다 비자 연장 또는 재입국이 필요합니다.',
            tip: '가족 방문, 해외 여행 등으로 자주 출입국할 경우 행정적 부담이 크게 줄어듭니다.',
          ),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightFileLines,
            title: '이민국 절차가 간소화된다',
            description:
                'SRRV 소지자는 BI의 Annual Report 제출, 외국인 등록증(ACR I-Card), ECC(출국 허가) 같은 일부 절차가 면제됩니다. 반면 일반 관광비자 체류자는 비자 연장이나 체류 허가를 위해 이런 프로세스를 자주 경험해야 합니다.',
            tip: '행정 절차 면제는 장기체류자에게 실제 체감으로 큰 이점입니다.',
          ),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightUserGroup,
            title: '가족 동반이 수월하다',
            description:
                'SRRV는 배우자·미성년 자녀를 함께 신청해 동일한 장기체류를 받을 수 있습니다. 관광비자는 각자 별도의 비자 조건을 맞춰야 하며, 체류 기간이 짧아 함께 거주하기 어렵습니다.',
            tip: '가족 기반 장기 생활계획에서는 SRRV가 구조적으로 더 유리합니다.',
          ),
          const SizedBox(height: 24),

          /// SRRV vs 워킹비자
          _buildSubsectionTitle(context, '💼 SRRV가 워킹비자보다 편한 점'),
          const SizedBox(height: 12),
          _buildInfoBox(
            context,
            'SRRV는 취업을 위한 비자가 아닙니다. SRRV 자체로 취업 허가가 포함되지는 않으나, 기본 체류 기반이 안정적이기 때문에 취업·사업·투자는 별도 허가 조건 하에서 더 유연하게 진행할 수 있습니다.',
            icon: FontAwesomeIcons.lightCircleInfo,
          ),
          const SizedBox(height: 12),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightGears,
            title: '취업비자보다 구조가 단순하다',
            description:
                '워킹비자(예: 9G)는 고용주 기준, 근로허가(AEP) 등 여러 규제 조건이 함께 따라옵니다. SRRV는 PRA에서 장기 체류 조건 유지만 하면, 일상 체류 및 비자 관리가 단순합니다.',
            tip: '체류 안정성 측면에서 볼 때는 워킹비자보다 SRRV가 비자 유지 리스크가 적고 간단합니다.',
          ),
          _buildComparisonAdvantage(
            context,
            icon: FontAwesomeIcons.lightCalendarCheck,
            title: '비자 만료 관리가 쉽다',
            description:
                '워킹비자는 고용계약 기간 종료, 직장 변경, 재허가 등으로 비자 관리가 지속적으로 필요합니다. SRRV는 매년 연회비만 납부하며 다른 조건만 유지하면 특별한 재승인 없이 체류 자격이 유지됩니다.',
            tip: '일상 유지 부담이 단순화된 체류 권한을 제공합니다.',
          ),
          const SizedBox(height: 24),

          /// 정리 요약
          _buildSubsectionTitle(context, '🧠 정리: SRRV가 왜 더 편리한가?'),
          const SizedBox(height: 12),
          _buildSrrvSummaryPoints(context),
          const SizedBox(height: 16),
          _buildInfoBox(
            context,
            'SRRV는 본질적으로 은퇴·장기 거주 목적의 비자이므로, 취업 목적 비자와는 구조가 다릅니다. 취업을 목적으로 한다면 워킹비자를 별도 취득해야 할 수 있으므로, 이를 반드시 참고하시기 바랍니다.',
            icon: FontAwesomeIcons.lightTriangleExclamation,
          ),
        ],
      ),
    );
  }

  /// 비자 비교표 빌더
  /// Visa comparison table builder
  Widget _buildVisaComparisonTable(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final comparisons = [
      {
        'category': '📍 체류 기간',
        'srrv': '무기한\n(조건 유지 시)',
        'tourist': '30~59일\n(연장 필요)',
        'work': '1~3년\n(계약 기간)',
      },
      {
        'category': '🔁 입출국',
        'srrv': '무제한\n복수 입출국',
        'tourist': '조건부\n(연장 필요)',
        'work': '가능\n(조건 있음)',
      },
      {
        'category': '👨‍👩‍👧 가족 동반',
        'srrv': '가능\n(배우자·자녀)',
        'tourist': '불가/별도',
        'work': '조건 따름',
      },
      {
        'category': '🗂 비자 관리',
        'srrv': '단순\n(연회비 납부)',
        'tourist': '복잡\n(자주 연장)',
        'work': '복잡\n(고용 조건)',
      },
      {
        'category': '🛂 출입국 보고',
        'srrv': 'ACR/연례보고\n면제',
        'tourist': '연장 시\n필요',
        'work': '일반 규정\n적용',
      },
      {
        'category': '🏡 체류 안정성',
        'srrv': '높음\n(정주 기반)',
        'tourist': '낮음\n(단기 목적)',
        'work': '중간\n(조건 복잡)',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
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
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SRRV',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '관광비자',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '워킹비자',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          /// 데이터 행
          ...comparisons.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == comparisons.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item['category']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      child: Text(
                        item['srrv']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item['tourist']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      item['work']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
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

  /// 비교 장점 항목 빌더
  /// Comparison advantage item builder
  Widget _buildComparisonAdvantage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String tip,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  icon,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLightbulb,
                  size: 14,
                  color: scheme.secondary,
                ),
                const SizedBox(width: 8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Expanded(
                  child: Text(
                    tip,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
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

  /// SRRV 장점 요약 포인트 빌더
  /// SRRV summary points builder
  Widget _buildSrrvSummaryPoints(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final points = [
      '장기(무기한) 체류가 가능하다',
      '입출국 자유가 높고 재입국 조건이 간단하다',
      '여행비자처럼 자주 연장할 필요가 없다',
      '가족 동반과 장기간 정주가 수월하다',
      '행정 절차가 일부 면제돼 체류 관리가 간단하다',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: points
            .map((point) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightCircleCheck,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// FAQ 섹션
  /// FAQ section
  Widget _buildFaqSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final faqs = [
      {
        'q': 'Q1. 관광비자로 SRRV를 신청할 수 있나요?',
        'a':
            '네. 관광비자 상태에서 필리핀에 입국한 후 SRRV를 신청할 수 있습니다. 다만 관광비자는 신청 처리 동안 유효해야 합니다.'
      },
      {
        'q': 'Q2. 예치금은 반드시 현지 은행으로 보내야 하나요?',
        'a': '예. 해외 송금 방식으로 필리핀 PRA 인증 은행에 예치해야 합니다. 국내에서 직접 입금은 인정되지 않습니다.'
      },
      {
        'q': 'Q3. SRRV로 취업이 가능한가요?',
        'a':
            'SRRV는 취업 비자는 아니지만, 필리핀에서 사업, 투자 또는 원격 근무 등은 가능합니다. 다만 현지 노동 관련 허가가 필요할 수 있습니다.'
      },
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightCircleQuestion,
      title: 'FAQ',
      subtitle: '한국인 신청자 입장에서 자주 묻는 질문',
      child: Column(
        children: faqs
            .map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq['q']!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        faq['a']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// 참고 자료 섹션
  /// References section
  Widget _buildReferencesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final references = [
      {
        'title': 'Philippine Retirement Authority – Official SRRV info',
        'url': 'https://pra.gov.ph/SRRVisa'
      },
      {
        'title': 'Updated SRRV 2025 guide',
        'url':
            'https://livelifethephilippines.com/posts-retirement/srrv-application/srrv-application-article.html'
      },
      {
        'title': 'SRRV eligibility update (age 40+)',
        'url': 'https://www.asia-relocation.com/srrv-retirement-visa-age-40-eligibility/'
      },
    ];

    return _buildSection(
      context,
      icon: FontAwesomeIcons.lightBookmark,
      title: '참고 자료',
      child: Column(
        children: references
            .map((ref) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightLink,
                        size: 14,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref['title']!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                            Text(
                              ref['url']!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  /// 공통 섹션 빌더
  /// Common section builder
  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(
                  icon,
                  size: 18,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// 서브섹션 타이틀 빌더
  /// Subsection title builder
  Widget _buildSubsectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// 요건 행 빌더
  /// Requirement row builder
  Widget _buildRequirementRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 박스 빌더
  /// Info box builder
  Widget _buildInfoBox(
    BuildContext context,
    String text, {
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            FaIcon(
              icon,
              size: 14,
              color: scheme.tertiary,
            ),
            const SizedBox(width: 8),
          ],
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 예치금 테이블 빌더
  /// Deposit table builder
  Widget _buildDepositTable(
    BuildContext context, {
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 헤더 행
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: headers
                  .map((header) => Expanded(
                        child: Text(
                          header,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: headers.indexOf(header) == 0
                              ? TextAlign.left
                              : TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
          ),

          /// 데이터 행들
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isLast = index == rows.length - 1;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                children: row
                    .map((cell) => Expanded(
                          child: Text(
                            cell,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: row.indexOf(cell) == 0
                                  ? scheme.onSurface
                                  : scheme.primary,
                              fontWeight: row.indexOf(cell) == 0
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                            ),
                            textAlign: row.indexOf(cell) == 0
                                ? TextAlign.left
                                : TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
