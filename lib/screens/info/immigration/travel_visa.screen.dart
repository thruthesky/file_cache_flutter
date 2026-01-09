import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// 여행비자 정보 화면 (Travel Visa Screen)
///
/// 필리핀 여행비자(관광비자 9A) 및 무비자 체류 연장에 대한
/// 완전 가이드를 제공합니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// TravelVisaScreen.push(context);
/// ```
class TravelVisaScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/TravelVisa';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const TravelVisaScreen({super.key});

  @override
  State<TravelVisaScreen> createState() => _TravelVisaScreenState();
}

class _TravelVisaScreenState extends State<TravelVisaScreen> {
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
          l10n.immigrationTravelVisa,
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

            /// 핵심 요약 섹션
            _buildQuickSummarySection(context),
            const SizedBox(height: 24),

            /// 무비자 입국 섹션
            _buildVisaFreeEntrySection(context),
            const SizedBox(height: 24),

            /// 비자 연장 흐름 섹션
            _buildExtensionFlowSection(context),
            const SizedBox(height: 24),

            /// ACR I-Card 섹션
            _buildAcrCardSection(context),
            const SizedBox(height: 24),

            /// ECC 섹션
            _buildEccSection(context),
            const SizedBox(height: 24),

            /// 필요 서류 섹션
            _buildRequiredDocumentsSection(context),
            const SizedBox(height: 24),

            /// 온라인 연장 섹션
            _buildOnlineExtensionSection(context),
            const SizedBox(height: 24),

            /// 직접 방문 섹션
            _buildInPersonVisitSection(context),
            const SizedBox(height: 24),

            /// 신청 시점 섹션
            _buildWhenToApplySection(context),
            const SizedBox(height: 24),

            /// 금지 활동 섹션
            _buildProhibitedActivitiesSection(context),
            const SizedBox(height: 24),

            /// BI 사무소 섹션
            _buildBiOfficeSection(context),
            const SizedBox(height: 24),

            /// 실전 팁 섹션
            _buildPracticalTipsSection(context),
            const SizedBox(height: 24),

            /// 요약 정리 섹션
            _buildSummarySection(context),
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
            '필리핀 관광비자(9A)',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '& 무비자 체류 연장 완전 가이드',
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
              '한국인 대상 / 2026년 최신 기준',
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 핵심 요약 섹션 빌더
  Widget _buildQuickSummarySection(BuildContext context) {
    return _buildSection(
      context,
      icon: '📌',
      title: '핵심 요약 — 빠르게 이해하기',
      child: Column(
        children: [
          _buildSummaryItem(
            context,
            emoji: '✈️',
            label: '초기 체류',
            value: '한국인은 30일 무비자 입국 가능\n(여권 유효기간 6개월 이상 필요)',
          ),
          _buildSummaryItem(
            context,
            emoji: '🏢',
            label: '비자 연장 주체',
            value: '필리핀 이민국 (Bureau of Immigration, BI)',
          ),
          _buildSummaryItem(
            context,
            emoji: '🗓️',
            label: '첫 연장',
            value: '30일 → +29일 (총 59일)',
          ),
          _buildSummaryItem(
            context,
            emoji: '🧾',
            label: '59일 이후 연장',
            value: '1개월, 2개월 또는 장기 연장\n(최대 36개월) 가능',
          ),
          _buildSummaryItem(
            context,
            emoji: '🆔',
            label: 'ACR I-Card',
            value: '59일 초과 체류 시 필수 발급',
          ),
          _buildSummaryItem(
            context,
            emoji: '📄',
            label: 'ECC',
            value: '6개월 이상 체류 후 출국 시 필요할 수 있음',
          ),
          _buildSummaryItem(
            context,
            emoji: '🚫',
            label: '금지 활동',
            value: '관광비자로 취업·사업·학업 불가',
          ),
          _buildSummaryItem(
            context,
            emoji: '🌐',
            label: '온라인 연장',
            value: '일부 비자 웨이버 및 ACR-연동 연장은\ne-Services 온라인으로 가능',
          ),
          _buildSummaryItem(
            context,
            emoji: '⏰',
            label: '신청 권장 시점',
            value: '만료 최소 7일 전 신청 권장',
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 요약 아이템 빌더
  Widget _buildSummaryItem(
    BuildContext context, {
    required String emoji,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 무비자 입국 섹션 빌더
  Widget _buildVisaFreeEntrySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🇵🇭',
      title: '무비자 입국과 초기 체류',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '대한민국 여권 소지자는 30일간 비자 없이 필리핀 입국이 가능합니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            items: [
              '입국 시 여권 유효기간이 6개월 이상 남아 있어야 함',
              '항공권 등 출국 예정 증빙을 요구받을 수 있음',
            ],
          ),
        ],
      ),
    );
  }

  /// 비자 연장 흐름 섹션 빌더
  Widget _buildExtensionFlowSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📈',
      title: '관광비자(9A) 연장 흐름',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⛳ 단계별 연장 구조',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildExtensionStep(
            context,
            step: '①',
            title: '무비자 입국',
            days: '30일',
            description: '자동 30일 체류 가능',
          ),
          _buildExtensionStep(
            context,
            step: '②',
            title: '비자 웨이버',
            days: '+29일',
            description: '총 59일 체류',
          ),
          _buildExtensionStep(
            context,
            step: '③',
            title: '59일 이후 연장',
            days: '1~2개월',
            description: '지속해서 반복 가능',
          ),
          _buildExtensionStep(
            context,
            step: '④',
            title: '최대 체류',
            days: '최대 36개월',
            description: '비자 면제 대상(한국 포함) 기준',
            isLast: true,
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
                Text('🧠', style: theme.textTheme.titleLarge),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '59일 초과 시에는 반드시 ACR I-Card 발급이 요구됩니다.',
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

  /// 연장 단계 아이템 빌더
  Widget _buildExtensionStep(
    BuildContext context, {
    required String step,
    required String title,
    required String days,
    required String description,
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: theme.textTheme.titleSmall?.copyWith(
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              days,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
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
      icon: '🧾',
      title: 'ACR I-Card 발급',
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
                  '🔹 ACR I-Card란?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Alien Certificate of Registration Identity Card로 외국인 등록증입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '59일 이상 체류 시 필수로 발급해야 합니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '📌 사용 용도',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(context, '장기 체류 증빙'),
          _buildBulletPoint(context, '현지 은행 계좌 개설 등 각종 신원 확인'),
        ],
      ),
    );
  }

  /// ECC 섹션 빌더
  Widget _buildEccSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📄',
      title: 'ECC (출국허가서)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '6개월 이상 체류 후 출국할 경우 ECC(Emigration Clearance Certificate)가 필요할 수 있습니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '장기 체류자가 출국할 때 체류 기록 및 세금 등 문제 없음을 증명하는 절차입니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필요 서류 섹션 빌더
  Widget _buildRequiredDocumentsSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🛂',
      title: '비자 연장 신청 조건 & 서류',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📌 기본 필요 서류',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(context, '여권 원본 (입국 날짜 및 스탬프 포함)'),
          _buildCheckItem(context, '비자 연장 신청서 (CGAF 등)'),
          _buildCheckItem(context, '현 체류 허가 상태 증빙'),
          _buildCheckItem(context, 'ACR I-Card (59일 초과 시)'),
          const SizedBox(height: 16),
          Text(
            '📌 추가 필요 시',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCheckItem(context, 'ECC (장기 체류 후 출국)'),
          _buildCheckItem(context, 'SPA (대리 신청 시 위임장)'),
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

  /// 온라인 연장 섹션 빌더
  Widget _buildOnlineExtensionSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🌐',
      title: '온라인(e-Services) 비자 연장',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '필리핀 이민국은 온라인 비자 연장 시스템을 운영합니다.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '비자 웨이버(29일) 및 일부 관광비자 연장 신청과 결제가 온라인으로 가능합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '단, ACR I-Card 번호 입력이 필요할 수 있으며, 일부 연장은 오프라인 방문을 요구할 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '📌 온라인 연장 절차 요약',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedStep(context, 1, 'e-Services 계정 등록'),
          _buildNumberedStep(context, 2, '개인 정보 입력'),
          _buildNumberedStep(context, 3, '여권/입국 정보 입력'),
          _buildNumberedStep(context, 4, '연장 기간 선택'),
          _buildNumberedStep(context, 5, '결제 및 확인 메일 수령'),
        ],
      ),
    );
  }

  /// 번호 단계 빌더
  Widget _buildNumberedStep(BuildContext context, int number, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 직접 방문 섹션 빌더
  Widget _buildInPersonVisitSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📍',
      title: '비자 연장 — 직접 방문 방법',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛠️ 실제 방문 연장 절차',
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildNumberedStep(context, 1, '이민국(BI) 사무소 도착'),
          _buildNumberedStep(context, 2, '번호표 수령 및 안내 확인'),
          _buildNumberedStep(context, 3, '연장 신청서 작성 (CGAF)'),
          _buildNumberedStep(context, 4, '여권/서류 제출 → 심사 진행'),
          _buildNumberedStep(context, 5, '수수료 납부'),
          _buildNumberedStep(context, 6, '신청증 또는 접수증 수령'),
          _buildNumberedStep(context, 7, '정해진 날짜에 스탬프된 여권 수령'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '📌 대부분 지점에서 이 과정을 현장 처리할 수 있으며, 특정 단계는 Express(급행) 옵션이 있습니다.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 신청 시점 섹션 빌더
  Widget _buildWhenToApplySection(BuildContext context) {
    return _buildSection(
      context,
      icon: '⏰',
      title: '언제 신청해야 하나?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint(
            context,
            '연장은 현 체류 허가 기간이 만료되기 전에 신청해야 합니다.',
          ),
          _buildBulletPoint(
            context,
            '통상 7일 전부터 준비하는 것이 불이익을 피할 수 있는 권장 타이밍입니다.',
          ),
        ],
      ),
    );
  }

  /// 금지 활동 섹션 빌더
  Widget _buildProhibitedActivitiesSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🚫',
      title: '관광비자로 불가능한 활동',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관광비자(9A) 또는 무비자 체류 상태에서는 아래 활동이 허용되지 않습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildProhibitedItem(context, '필리핀 내 취업'),
          _buildProhibitedItem(context, '사업 운영'),
          _buildProhibitedItem(context, '정규 학업 (일부 단기 허가 제외)'),
          _buildProhibitedItem(context, '상시 수익 활동'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👉', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '해당 활동을 할 경우 정식 취업비자(9G) 또는 학생비자(9F) 등 적합한 비자 취득이 필요합니다.',
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

  /// 금지 아이템 빌더
  Widget _buildProhibitedItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.cancel,
            size: 20,
            color: scheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// BI 사무소 섹션 빌더
  Widget _buildBiOfficeSection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '🏢',
      title: 'BI 사무소 방문',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연장은 필리핀 전역의 BI(Main, Field, Satellite) 지사에서 가능하며, 대부분의 주요 도시(마닐라, 세부, 다바오 등) 및 분점에서 처리할 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('👉', style: theme.textTheme.titleMedium),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '꼭 가까운 지사로 방문하되, 운영시간/절차는 사무소마다 상이할 수 있어 사전 확인이 유리합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
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

  /// 실전 팁 섹션 빌더
  Widget _buildPracticalTipsSection(BuildContext context) {
    return _buildSection(
      context,
      icon: '🧠',
      title: '실전 팁',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipItem(
            context,
            '여권 유효기간은 최소 6개월 이상 남게 준비한다',
          ),
          _buildTipItem(
            context,
            '체류 만료 7~10일 전에 미리 준비한다',
          ),
          _buildTipItem(
            context,
            '가능하면 온라인 신청 + 오프라인 확인 병행하면 편리',
          ),
          _buildTipItem(
            context,
            'ACR I-Card는 반드시 필요한 서류로 예상하고 준비한다',
          ),
        ],
      ),
    );
  }

  /// 팁 아이템 빌더
  Widget _buildTipItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '✔️',
            style: TextStyle(
              fontSize: 16,
              color: scheme.primary,
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

  /// 요약 정리 섹션 빌더
  Widget _buildSummarySection(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return _buildSection(
      context,
      icon: '📚',
      title: '요약 정리',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryBullet(context, '한국인은 필리핀에서 30일 무비자 체류 가능'),
            _buildSummaryBullet(context, '첫 연장은 29일 추가 (총 59일)'),
            _buildSummaryBullet(
                context, '59일 이후엔 정식 관광비자 연장 가능 (최대 36개월)'),
            _buildSummaryBullet(context, 'ACR I-Card는 59일 초과 체류 시 필수'),
            _buildSummaryBullet(context, '온라인과 직접 방문 모두 가능'),
            _buildSummaryBullet(context, '관광비자로 취업 등은 불가'),
          ],
        ),
      ),
    );
  }

  /// 요약 불릿 빌더
  Widget _buildSummaryBullet(BuildContext context, String text) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
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
      icon: '📌',
      title: '참고 자료',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReferenceLink(
            context,
            title: '필리핀 이민국 e-Services',
            subtitle: 'Tourist Visa Extension',
            url: 'https://e-services.immigration.gov.ph/',
          ),
          _buildReferenceLink(
            context,
            title: 'Visa exemption & policy',
            subtitle: 'Wikipedia',
            url: 'https://en.wikipedia.org/wiki/Visa_policy_of_the_Philippines',
          ),
          _buildReferenceLink(
            context,
            title: '9A 연장 절차 가이드',
            subtitle: 'Expats in Manila',
            url:
                'https://expatsinmanila.com/the-new-philippines-tourist-visa-extension-requirements/',
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

  /// 정보 카드 빌더
  Widget _buildInfoCard(BuildContext context, {required List<String> items}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _buildBulletPoint(context, item)).toList(),
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
}
