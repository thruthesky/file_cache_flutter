import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// 워킹비자 정보 화면 (Working Visa Screen)
///
/// 필리핀 워킹비자(취업비자 9G) 정보를 제공합니다.
/// Provides information about Philippine working visa (9G).
///
/// ### 사용법 (Usage):
/// ```dart
/// WorkingVisaScreen.push(context);
/// ```
class WorkingVisaScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/WorkingVisa';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const WorkingVisaScreen({super.key});

  @override
  State<WorkingVisaScreen> createState() => _WorkingVisaScreenState();
}

class _WorkingVisaScreenState extends State<WorkingVisaScreen> {
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
          l10n.immigrationWorkingVisa,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 메인 타이틀 섹션
            _buildMainTitle(context),
            const SizedBox(height: 24),

            /// 9G 비자란? 섹션
            _buildWhatIs9GSection(context),
            const SizedBox(height: 24),

            /// 한국 국적자 신청 섹션
            _buildKoreanApplicantSection(context),
            const SizedBox(height: 24),

            /// 9G 비자 신청 절차 요약 섹션
            _buildApplicationProcessSection(context),
            const SizedBox(height: 24),

            /// 1단계: AEP 섹션
            _buildAepSection(context),
            const SizedBox(height: 24),

            /// 2단계: 9G 비자 신청 섹션
            _build9GApplicationSection(context),
            const SizedBox(height: 24),

            /// ACR I-Card 발급 섹션
            _buildAcrCardSection(context),
            const SizedBox(height: 24),

            /// 필수 비용 섹션
            _buildCostSection(context),
            const SizedBox(height: 24),

            /// PWP 임시 허가 섹션
            _buildPwpSection(context),
            const SizedBox(height: 24),

            /// 비자 유지·연장·관리 섹션
            _buildMaintenanceSection(context),
            const SizedBox(height: 24),

            /// 가족 동반 비자 섹션
            _buildDependentVisaSection(context),
            const SizedBox(height: 24),

            /// 9G 비자의 장점 섹션
            _buildBenefitsSection(context),
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

  /// 메인 타이틀 위젯 빌더
  Widget _buildMainTitle(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          /// 필리핀 국기 이모지와 타이틀
          Text(
            '🇵🇭',
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 12),
          Text(
            '필리핀 워킹비자 (9G)',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '완전 가이드',
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '신청 절차 · 필요 서류 · 관리 방법',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '필리핀에서 합법적으로 취업하고 장기 체류하려면,\n필리핀 이민국(Bureau of Immigration, BI)이 발급하는\n워킹비자 9G(Pre-Arranged Employment Visa)가 필요합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 9G 비자란? 섹션 빌더
  Widget _buildWhatIs9GSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📌',
      title: '9G 비자란?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9G 워킹비자는 필리핀에 정식 취업을 목적으로 체류하려는 외국인에게 발급되는 장기 취업 비자입니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '필리핀 내 등록된 회사(고용주)가 스폰서 역할을 하며, 비자 취득 후에는 합법적으로 근무·체류할 수 있는 신분이 주어집니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          /// 9G 비자 개요 테이블
          _buildInfoTable(context, [
            ('공식 명칭', 'Pre-Arranged Employment Visa (9G)'),
            ('목적', '필리핀에서 합법 취업 및 체류'),
            ('발급처', '필리핀 이민국(Bureau of Immigration)'),
            ('필요조건', '필리핀 현지 고용주 스폰서'),
            ('유효기간', '통상 1~3년 (계약 기간에 따라 결정)'),
            ('재입국', '복수 입출국 가능'),
          ]),
        ],
      ),
    );
  }

  /// 한국 국적자 신청 섹션 빌더
  Widget _buildKoreanApplicantSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '👤',
      title: '한국 국적자가 9G 비자를 신청할 때',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text('📌', style: theme.textTheme.titleLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '한국인도 필리핀 법상 일반 외국인과 동일한 조건으로 9G 비자를 신청할 수 있습니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '한국인은 관광 무비자(최대 30일)로 입국이 가능하므로, 입국 후 9G 비자로 전환하는 방식이 흔하게 활용됩니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '💼 한국인 지원자의 적용 예시 직무',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(context, 'IT 개발자'),
          _buildBulletPoint(context, '게임·BPO·콘텐츠 산업 전문직'),
          _buildBulletPoint(context, '제조/무역 관리직'),
          _buildBulletPoint(context, '한국 기업 필리핀 법인 주재원'),
          _buildBulletPoint(context, '기술/전문직 전문가'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '※ 이민청은 외국인이 현지 근로자로 대체할 수 없는 직무일 경우 9G 비자 승인 가능성이 높아진다고 보고 있습니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 9G 비자 신청 절차 요약 섹션 빌더
  Widget _buildApplicationProcessSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🧭',
      title: '9G 비자 신청 절차 요약',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9G 비자 신청은 아래 두 단계로 나뉩니다:',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildProcessStep(
            context,
            step: '1',
            emoji: '🎫',
            title: '외국인 고용 허가서(AEP) 취득',
            description: 'DOLE(노동고용부)에서 발급',
          ),
          const SizedBox(height: 12),
          _buildProcessStep(
            context,
            step: '2',
            emoji: '🛂',
            title: '이민국에 9G 비자 신청',
            description: 'Bureau of Immigration에서 처리',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text('⚠️', style: theme.textTheme.titleLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '이 두 단계는 반드시 순차적으로 진행해야 합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
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

  /// 프로세스 단계 빌더
  Widget _buildProcessStep(
    BuildContext context, {
    required String step,
    required String emoji,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
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

  /// AEP 섹션 빌더
  Widget _buildAepSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📍',
      title: '1단계: 외국인 고용 허가서 (AEP)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AEP는 Labour Department(DOLE)가 발급하는 외국인 고용 허가서입니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '9G 비자 자체를 신청하기 전에 무조건 선행해야 하는 필수 절차입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🧾 AEP 주요 포인트',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoTable(context, [
            ('발급기관', '노동고용부 (DOLE)'),
            ('목적', '외국인 고용의 적법성 확인'),
            ('심사 기준', '해당 직무를 필리핀 사람이 수행할 수 없는지'),
            ('처리 기간', '약 2주~1개월'),
            ('특징', '직무·회사에 귀속됨'),
          ]),
          const SizedBox(height: 16),
          Text(
            '📦 AEP에 필요한 대표 서류',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(context, '외국인 근로자 여권 사본'),
          _buildCheckItem(context, '필리핀 고용주와의 고용계약서'),
          _buildCheckItem(context, '회사 사업자 등록 서류 (SEC / DTI)'),
          _buildCheckItem(context, '직무 설명서'),
          _buildCheckItem(context, '고용 인력 구성 (필리핀인/외국인 비율 증빙)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text('👉', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AEP는 직무 변경/고용주 변경 시 재신청이 필요합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onTertiaryContainer,
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

  /// 9G 비자 신청 섹션 빌더
  Widget _build9GApplicationSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📍',
      title: '2단계: 9G 비자 신청',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AEP가 승인되면, 필리핀 이민국(BI)에 9G 비자 신청을 진행합니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🧾 신청 개요',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoTable(context, [
            ('제출처', '필리핀 이민국(BI)'),
            ('신청자', '고용주 또는 대리인'),
            ('처리 기간', '1~3개월 (서류 완비 시)'),
            ('추가 절차', '생체정보 등록(사진/지문)'),
          ]),
          const SizedBox(height: 16),
          Text(
            '📎 주요 제출 서류',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildDocumentCategory(context, '신분', '여권 원본 + 사본'),
          _buildDocumentCategory(context, '신청서', 'BI 비자 신청서 (CGAF 양식)'),
          _buildDocumentCategory(context, '고용 정보', '고용계약서'),
          _buildDocumentCategory(context, 'AEP', '외국인 고용 허가서'),
          _buildDocumentCategory(context, '기업 자료', 'SEC/DTI, Mayor\'s Permit 등'),
          _buildDocumentCategory(context, '세금', '회사 최신 세금 신고 증빙'),
          _buildDocumentCategory(context, '기타', 'BI 요구 추가 서류'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '📍 결과 확인용 온라인 조회가 가능하여 진행 상황을 확인할 수 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 서류 카테고리 빌더
  Widget _buildDocumentCategory(
      BuildContext context, String category, String content) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ACR I-Card 섹션 빌더
  Widget _buildAcrCardSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🪪',
      title: 'ACR I-Card 발급',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9G 비자가 승인되면 여권에 비자 스탬프가 찍히고, 동시에 ACR I-Card(외국인 등록증)도 발급됩니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '이 카드는 필리핀 외국인의 법적 신분증 역할을 하며 다양한 생활 편의를 제공합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoTable(context, [
            ('역할', '필리핀 체류 외국인 신분증'),
            ('유효기간', '비자 기간과 동일'),
            ('활용', '은행 계좌 개설·임대 계약 등'),
          ]),
        ],
      ),
    );
  }

  /// 비용 섹션 빌더
  Widget _buildCostSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '💸',
      title: '필수 비용 (2025년 기준)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '비용은 세금 및 정부 수수료이며, 경우에 따라 변동될 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildCostItem(context, 'AEP 신청료', '약 ₱9,000 (1년 기준)'),
          _buildCostItem(context, '9G 비자 신청료', '약 ₱8,000~₱12,000 (기간에 따라 다름)'),
          _buildCostItem(context, 'ACR I-Card', '약 ₱3,000'),
          _buildCostItem(context, 'PWP (선택)', '약 ₱4,000 (AEP/비자 승인 전 임시 허가)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '※ 위 금액은 참고용이며, 실제 BI/DOLE에서 공시하는 최신 수수료가 최종 기준입니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 비용 아이템 빌더
  Widget _buildCostItem(BuildContext context, String label, String cost) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cost,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PWP 섹션 빌더
  Widget _buildPwpSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🛠️',
      title: 'Provisional Work Permit (PWP)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '▶ PWP란?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AEP 또는 9G 비자 심사 대기 중에도 합법적으로 일할 수 있도록 발급되는 임시 허가입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(context, 'PWP는 통상 3개월 유효'),
          _buildBulletPoint(context, 'AEP/9G 승인 시 더 이상 필요하지 않음'),
        ],
      ),
    );
  }

  /// 비자 유지·관리 섹션 빌더
  Widget _buildMaintenanceSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🔄',
      title: '비자 유지·연장·관리',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9G 비자는 고용주 및 직무에 귀속된 비자입니다. 따라서 다음 사항을 반드시 관리해야 합니다:',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '📌 주요 관리 포인트',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildManagementItem(context, '고용 종료', '비자 취소/체류 신분 변경 또는 출국'),
          _buildManagementItem(context, '고용주 변경', '새로운 9G 비자 + AEP 재신청'),
          _buildManagementItem(context, '직무 변경', 'AEP 갱신 필요'),
          _buildManagementItem(context, '비자 만료', '연장 신청'),
          _buildManagementItem(context, '연례 보고', 'Annual Report(이민국 의무 신고)'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚠️', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '고용계약 종료 시 9G 비자는 자동으로 효력이 없어집니다. 이 경우 다른 비자로 전환하거나 출국해야 합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 관리 아이템 빌더
  Widget _buildManagementItem(
      BuildContext context, String situation, String action) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              situation,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 가족 동반 비자 섹션 빌더
  Widget _buildDependentVisaSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '👪',
      title: '가족 동반 비자',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9G 비자 소지자는 배우자 및 미성년 자녀(보통 21세 미만)를 Dependents로 신청할 수 있습니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '동반 가족 역시 비자 유효기간 동안 필리핀에서 합법 체류할 수 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 9G 비자 장점 섹션 빌더
  Widget _buildBenefitsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🎯',
      title: '9G 비자의 장점',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBenefitItem(context, '✔️', '합법 취업', '필리핀 법 아래 합법적으로 근무'),
          _buildBenefitItem(
              context, '✔️', '장기 체류', '계약 기간에 따라 최대 3년 비자 발급 가능'),
          _buildBenefitItem(context, '✔️', '복수 입출국', '비자 유효기간 동안 자유롭게 출입국'),
          _buildBenefitItem(context, '✔️', '가족 동반', '배우자·자녀 동반 비자 가능'),
          _buildBenefitItem(
              context, '✔️', '생활 안정성', '은행 계좌, 계약 체결 등 생활 편의'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '※ 단기 체류용 SWP나 관광비자와 달리 장기·안정적 체류가 가능합니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 장점 아이템 빌더
  Widget _buildBenefitItem(
      BuildContext context, String icon, String title, String description) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              icon,
              style: TextStyle(
                fontSize: 18,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
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
    );
  }

  /// FAQ 섹션 빌더
  Widget _buildFaqSection(BuildContext context) {
    return _buildSection(
      context,
      icon: '💡',
      title: '자주 묻는 질문 (FAQ)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFaqItem(
            context,
            question: '관광비자로 입국 후 9G 비자로 전환할 수 있나요?',
            answer:
                '네. 관광비자 또는 무비자 상태라도 현지에서 Conversion 절차로 9G 비자를 신청할 수 있습니다. 다만 입국 신분 유지를 위해 비자 기간 내에 절차를 시작해야 합니다.',
          ),
          _buildFaqItem(
            context,
            question: '9G 비자 기간 중 취업 직무를 변경할 수 있나요?',
            answer:
                '직무 변경은 가능하지만 AEP 갱신 및 BI 신고가 필요합니다. 변경 전까지는 기존 직무에만 합법적으로 근무할 수 있습니다.',
          ),
          _buildFaqItem(
            context,
            question: '고용주가 바뀌면 어떻게 하나요?',
            answer:
                '현재 9G 비자는 고용주에 귀속되므로, 새로운 고용주와 새롭게 AEP + 9G 비자를 다시 신청해야 합니다.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// FAQ 아이템 빌더
  Widget _buildFaqItem(
    BuildContext context, {
    required String question,
    required String answer,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '❓',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 참고 자료 섹션 빌더
  Widget _buildReferencesSection(BuildContext context) {
    return _buildSection(
      context,
      icon: '🔗',
      title: '참고 자료',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReferenceLink(
            context,
            title: '필리핀 이민국 – 9G Visa 안내',
            subtitle: 'Bureau of Immigration Philippines',
            url: 'https://immigration.gov.ph/pre-4-arranged-employment-visa-9g/',
          ),
          _buildReferenceLink(
            context,
            title: '9G Visa Guide',
            subtitle: 'WorkVisaPhilippines',
            url:
                'https://workvisaphilippines.com/pre-arranged-9g-work-visa-guide-philippines-work-visa/',
          ),
          _buildReferenceLink(
            context,
            title: '9G 2025 Guide',
            subtitle: 'WorkVisaPhilippines',
            url:
                'https://workvisaphilippines.com/9g-working-visa-philippines-complete-2025-guide-for-foreign-employees-employers/',
          ),
        ],
      ),
    );
  }

  /// 참고 링크 빌더
  Widget _buildReferenceLink(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String url,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.link,
                size: 20,
                color: scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new,
                size: 16,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// URL 런처 함수
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// 공통 섹션 래퍼 빌더
  Widget _buildSection(
    BuildContext context, {
    required String icon,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),

          /// 섹션 컨텐츠
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  /// 정보 테이블 빌더
  Widget _buildInfoTable(BuildContext context, List<(String, String)> items) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    item.$1,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.$2,
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

  /// 불릿 포인트 빌더
  Widget _buildBulletPoint(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 체크 아이템 빌더
  Widget _buildCheckItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: scheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
