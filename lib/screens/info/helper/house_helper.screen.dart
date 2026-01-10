import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 하우스헬퍼 정보 화면 (House Helper Screen)
///
/// 필리핀 하우스헬퍼(가사도우미) 고용 관련 정보를 제공합니다.
/// Provides information about hiring house helpers (domestic helpers) in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// HouseHelperScreen.push(context);
/// ```
class HouseHelperScreen extends StatelessWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/HouseHelper';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const HouseHelperScreen({super.key});

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
              FontAwesomeIcons.lightBroom,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.helperHouseHelper,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
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
            /// 헤더 섹션 (Header Section) - 애니메이션 적용
            _buildHeaderSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1, end: 0),
            SizedBox(height: sp.s24),

            /// 맨파워 권장 섹션 (Manpower Recommendation Section) - 새로 추가
            _buildManpowerRecommendationSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.05, end: 0),
            SizedBox(height: sp.s16),

            /// 1) 적용 범위 섹션 (Scope Section)
            _buildScopeSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms),
            SizedBox(height: sp.s16),

            /// 2) 채용 방식 비교 섹션 (Hiring Comparison Section)
            _buildHiringComparisonSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            SizedBox(height: sp.s16),

            /// 3) 3대 보험 섹션 (Insurance Section)
            _buildInsuranceSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms),
            SizedBox(height: sp.s16),

            /// 4) 필수 절차 섹션 (Required Procedures Section)
            _buildProceduresSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            SizedBox(height: sp.s16),

            /// 5) 최저임금 섹션 (Minimum Wage Section)
            _buildMinimumWageSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: sp.s16),

            /// 6) 보관 권장 서류 섹션 (Recommended Documents Section)
            _buildDocumentsSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
            SizedBox(height: sp.s16),

            /// 7) 핵심 요약 섹션 (Summary Section)
            _buildSummarySection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 450.ms),
            SizedBox(height: sp.s16),

            /// 참고 URL 섹션 (Reference URLs Section)
            _buildReferencesSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
            SizedBox(height: sp.s32),
          ],
        ),
      ),
    );
  }

  /// 헤더 섹션 빌더 (Header Section Builder) - 그라디언트 적용
  Widget _buildHeaderSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withValues(alpha: 0.8),
            scheme.tertiary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          /// 아이콘 (Icon) - 글래스모피즘 효과
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightBroom,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: sp.s16),

          /// 메인 타이틀 (Main Title)
          Text(
            '필리핀 하우스메이드',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s4),
          Text(
            '고용·관리 핵심 정리',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s12),

          /// 서브 타이틀 (Subtitle)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '가사근로자 · Kasambahay',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 법률 근거 (Legal Basis)
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightScaleBalanced,
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                SizedBox(width: sp.s8),
                Flexible(
                  child: Text(
                    'Republic Act No. 10361 (Batas Kasambahay)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 맨파워 권장 섹션 (Manpower Recommendation Section) - 새로 추가
  Widget _buildManpowerRecommendationSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.tertiary.withValues(alpha: 0.15),
            scheme.primary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.tertiary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 헤더 (Header)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightThumbsUp,
                    size: 20,
                    color: scheme.tertiary,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '적극 권장',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.tertiary,
                      ),
                    ),
                    Text(
                      '맨파워 업체를 통한 서비스 이용',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 메인 메시지 (Main Message)
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: sp.s4),
                      child: FaIcon(
                        FontAwesomeIcons.lightCircleCheck,
                        size: 16,
                        color: scheme.tertiary,
                      ),
                    ),
                    SizedBox(width: sp.s12),
                    Expanded(
                      child: Text(
                        '하우스메이드(가정부) 서비스는 DOLE에 등록된 맨파워 업체를 통해 이용하시는 것을 적극 권장합니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),

                /// 이점 목록 (Benefits List)
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightShieldCheck,
                  text: '법적 리스크 분산 (연대책임 규정)',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightFileContract,
                  text: '계약·서류·보험 관리 체계화',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightArrowsRotate,
                  text: '문제 발생 시 교체/환급 규정 존재',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightUserCheck,
                  text: '신원조회 및 사전검증 완료된 인력',
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s12),

          /// 경고 메시지 (Warning Message)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.errorContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 14,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '직접 고용 시 3대 보험 미가입으로 인한 형사책임 등 법적 문제가 발생할 수 있습니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
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

  /// 이점 아이템 빌더 (Benefit Item Builder)
  Widget _buildBenefitItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: scheme.tertiary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 11,
              color: scheme.tertiary,
            ),
          ),
        ),
        SizedBox(width: sp.s8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
    );
  }

  /// 섹션 타이틀 위젯 빌더 (Section Title Widget Builder)
  Widget _buildSectionTitle(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String number,
    required String title,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (iconColor ?? scheme.primary).withValues(alpha: 0.2),
                (iconColor ?? scheme.primary).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 15,
              color: iconColor ?? scheme.primary,
            ),
          ),
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Text(
            '$number $title',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌더 (Info Card Builder)
  Widget _buildInfoCard(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required Widget child,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: child,
    );
  }

  /// 1) 적용 범위 섹션 (Scope Section)
  Widget _buildScopeSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightUsers,
            number: '1)',
            title: "적용 범위: 'Kasambahay'의 의미",
          ),
          SizedBox(height: sp.s16),
          Text(
            '필리핀 「Batas Kasambahay(가사근로자법)」은 가정 내 가사·돌봄·가정서비스를 '
            '수행하는 근로자를 대상으로 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface,
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 대상자 목록 (Target List)
          Wrap(
            spacing: sp.s8,
            runSpacing: sp.s8,
            children: [
              _buildChip(theme, scheme, sp, '하우스헬퍼'),
              _buildChip(theme, scheme, sp, '야야(Yaya)'),
              _buildChip(theme, scheme, sp, '요리사'),
              _buildChip(theme, scheme, sp, '세탁'),
              _buildChip(theme, scheme, sp, '정원사'),
            ],
          ),
          SizedBox(height: sp.s12),

          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 16,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    '고용주는 가정 내에서 가사근로자의 업무를 고용·통제하고 '
                    '고용계약의 당사자가 되는 자를 의미합니다.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      height: 1.5,
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

  /// 칩 빌더 (Chip Builder)
  Widget _buildChip(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String label,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 2) 채용 방식 비교 섹션 (Hiring Comparison Section)
  Widget _buildHiringComparisonSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightFileContract,
            number: '2)',
            title: '채용 방식 비교',
          ),
          SizedBox(height: sp.s16),

          /// 비교 카드 2개 (Two Comparison Cards)
          Row(
            children: [
              /// 직접 고용 (Direct Hiring)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightUserXmark,
                        size: 24,
                        color: scheme.error,
                      ),
                      SizedBox(height: sp.s8),
                      Text(
                        '직접 고용',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.error,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '리스크 집중',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onErrorContainer,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sp.s12),

              /// 맨파워 이용 (Using Manpower)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.tertiary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightUserCheck,
                            size: 24,
                            color: scheme.tertiary,
                          ),
                          Positioned(
                            right: -8,
                            top: -8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: scheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.solidStar,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sp.s8),
                      Text(
                        '맨파워 이용',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.tertiary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '권장 ✓',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 중요 안내 박스 (Important Notice Box)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.tertiary.withValues(alpha: 0.1),
                  scheme.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: sp.s8,
                        vertical: sp.s4,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.tertiary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'POINT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '맨파워 업체 이용의 핵심 이점',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),
                Text(
                  'PEA(Private Employment Agency)가 임금·법정급여·월 보험료(SSS/PhilHealth/Pag-IBIG) 납부에 대해 '
                  '고용주와 연대책임(joint and solidary liability)을 부담하므로 법적 리스크가 분산됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// 비교 테이블 (Comparison Table)
          _buildComparisonTable(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 비교 테이블 빌더 (Comparison Table Builder)
  Widget _buildComparisonTable(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final headers = ['구분', '직접고용', 'PEA(맨파워)'];
    final rows = [
      ['채용', '고용주가 직접', 'PEA가 알선·배치'],
      ['서류', '고용주가 준비', 'PEA가 체계화'],
      ['책임', '고용주 집중', '연대책임 분산'],
      ['보호', '개별 대응', '교체/환급 가능'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// 헤더 행 (Header Row)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s8,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: headers.asMap().entries.map((e) {
                final isLast = e.key == headers.length - 1;
                return Expanded(
                  flex: e.key == 0 ? 1 : 2,
                  child: Text(
                    e.value,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLast ? scheme.tertiary : scheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ),

          /// 데이터 행 (Data Rows)
          ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;
            final isLast = index == rows.length - 1;

            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: sp.s12,
                vertical: sp.s8,
              ),
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
                children: row.asMap().entries.map((cellEntry) {
                  final cellIndex = cellEntry.key;
                  final cell = cellEntry.value;
                  final isLastCell = cellIndex == row.length - 1;
                  return Expanded(
                    flex: cellIndex == 0 ? 1 : 2,
                    child: Text(
                      cell,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isLastCell
                            ? scheme.tertiary
                            : scheme.onSurface,
                        fontWeight: cellIndex == 0 || isLastCell
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 3) 3대 보험 섹션 (Insurance Section)
  Widget _buildInsuranceSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      borderColor: scheme.error.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightShieldCheck,
            number: '3)',
            title: '3대 보험: 의무·비협상·현금대체 불가',
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s12),

          /// 경고 배너 (Warning Banner)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 16,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  child: Text(
                    '근속 1개월 이상 시 SSS, PhilHealth, Pag-IBIG 의무 가입',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// (1) 거절해도 가입 의무 (Mandatory Even If Refused)
          _buildInsurancePoint(
            theme,
            scheme,
            sp,
            number: '(1)',
            title: '거절해도 가입 의무 유지',
            content: '가사근로자가 가입을 원치 않더라도 SSS·PhilHealth·Pag-IBIG 가입은 '
                '강제(mandatory)이며 협상 불가(non-negotiable)입니다.',
            icon: FontAwesomeIcons.lightBan,
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s12),

          /// (2) 현금 지급 불가 (Cash Payment Not Allowed)
          _buildInsurancePoint(
            theme,
            scheme,
            sp,
            number: '(2)',
            title: '현금 대체 지급 불가',
            content: '"보험료 대신 현금으로 달라"는 합의가 있어도 고용주는 등록·공제·납부 의무를 '
                '이행해야 하며, 불이행 시 형사책임을 포함한 법적 책임이 발생합니다.',
            icon: FontAwesomeIcons.lightMoneyBillTransfer,
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s12),

          /// (3) 부담 주체 (Burden Bearer)
          _buildInsurancePoint(
            theme,
            scheme,
            sp,
            number: '(3)',
            title: '부담 주체',
            content: '기본적으로 고용주 부담이며, 월급 ₱5,000 이상 시 '
                '가사근로자가 법정 비율에 따른 본인 부담분을 분담합니다.',
            icon: FontAwesomeIcons.lightHandHoldingDollar,
            iconColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s16),

          /// 보험 요약 테이블 (Insurance Summary Table)
          _buildInsuranceTable(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 보험 포인트 빌더 (Insurance Point Builder)
  Widget _buildInsurancePoint(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String number,
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: (iconColor ?? scheme.primary).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    size: 12,
                    color: iconColor ?? scheme.primary,
                  ),
                ),
              ),
              SizedBox(width: sp.s8),
              Expanded(
                child: Text(
                  '$number $title',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s8),
          Padding(
            padding: EdgeInsets.only(left: sp.s4),
            child: Text(
              content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 보험 테이블 빌더 (Insurance Table Builder)
  Widget _buildInsuranceTable(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final rows = [
      {'label': '가입 의무', 'value': '강제·비협상', 'icon': FontAwesomeIcons.lightLock},
      {'label': '현금대체', 'value': '불가', 'icon': FontAwesomeIcons.lightBan},
      {'label': '적용 시점', 'value': '근속 1개월↑', 'icon': FontAwesomeIcons.lightCalendar},
      {'label': '부담', 'value': '고용주 (₱5,000↑ 분담)', 'icon': FontAwesomeIcons.lightCoins},
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.errorContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isLast = index == rows.length - 1;

          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s8,
            ),
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
                FaIcon(
                  row['icon'] as IconData,
                  size: 12,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  flex: 1,
                  child: Text(
                    row['label'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.error,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    row['value'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 4) 필수 절차 섹션 (Required Procedures Section)
  Widget _buildProceduresSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightClipboardListCheck,
            number: '4)',
            title: '고용주 필수 절차',
          ),
          SizedBox(height: sp.s16),

          /// 절차 스텝 (Procedure Steps)
          _buildProcedureStep(
            theme,
            scheme,
            sp,
            step: 1,
            title: '서면 고용계약',
            content: '공증 불필수, 바랑가이 책임자 증인 가능',
            icon: FontAwesomeIcons.lightFileSignature,
          ),
          _buildProcedureStep(
            theme,
            scheme,
            sp,
            step: 2,
            title: '바랑가이 등록',
            content: '거주지 바랑가이 가사근로자 등록부 (무료)',
            icon: FontAwesomeIcons.lightBuilding,
          ),
          _buildProcedureStep(
            theme,
            scheme,
            sp,
            step: 3,
            title: '3대 보험 등록',
            content: 'SSS·PhilHealth·Pag-IBIG 고용주 및 근로자 등록',
            icon: FontAwesomeIcons.lightIdCard,
          ),
          _buildProcedureStep(
            theme,
            scheme,
            sp,
            step: 4,
            title: '급여 지급',
            content: '현금 지급 원칙, 최소 월 1회',
            icon: FontAwesomeIcons.lightMoneyBill,
            isLast: true,
          ),
          SizedBox(height: sp.s16),

          /// 사전 서류 목록 (Pre-employment Documents List)
          Text(
            '선택 요구 가능 서류',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildDocumentsList(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 절차 스텝 빌더 (Procedure Step Builder)
  Widget _buildProcedureStep(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required int step,
    required String title,
    required String content,
    required IconData icon,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary,
                    scheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: scheme.primary.withValues(alpha: 0.3),
              ),
          ],
        ),
        SizedBox(width: sp.s12),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                FaIcon(
                  icon,
                  size: 16,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        content,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 사전 서류 목록 빌더 (Documents List Builder)
  Widget _buildDocumentsList(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final documents = [
      '건강/의료 증명',
      '바랑가이·경찰 클리어런스',
      'NBI 클리어런스',
      '출생증명/신분서류',
    ];

    return Wrap(
      spacing: sp.s8,
      runSpacing: sp.s8,
      children: documents.map((doc) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                FontAwesomeIcons.lightFileLines,
                size: 12,
                color: scheme.primary,
              ),
              SizedBox(width: sp.s8),
              Text(
                doc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// 5) 최저임금 섹션 (Minimum Wage Section)
  Widget _buildMinimumWageSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightCoins,
            number: '5)',
            title: '최저임금',
            iconColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s16),

          /// NCR 최저임금 하이라이트 (NCR Minimum Wage Highlight)
          Container(
            padding: EdgeInsets.all(sp.s20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.tertiary.withValues(alpha: 0.15),
                  scheme.tertiary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.tertiary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '₱',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: scheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sp.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.tertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NCR (메트로 마닐라)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: sp.s8),
                      Text(
                        '월 ₱7,000',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: scheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        '2025-01-04 시행',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s12),

          /// 기타 지역 안내 (Other Regions Notice)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLocationDot,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Text(
                    '기타 지역은 RTWPB(지역 임금위원회) 고시를 확인하세요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurface,
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

  /// 6) 보관 권장 서류 섹션 (Recommended Documents Section)
  Widget _buildDocumentsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightFolderTree,
            number: '6)',
            title: '분쟁 대비 보관 서류',
          ),
          SizedBox(height: sp.s16),

          /// 서류 목록 (Documents List)
          _buildRecommendedDocsList(theme, scheme, sp),
        ],
      ),
    );
  }

  /// 권장 서류 목록 빌더 (Recommended Documents List Builder)
  Widget _buildRecommendedDocsList(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final documents = [
      {
        'icon': FontAwesomeIcons.lightFileSignature,
        'title': '고용계약서 (서명본)',
        'desc': '근로조건 입증',
      },
      {
        'icon': FontAwesomeIcons.lightReceipt,
        'title': '급여 지급 내역',
        'desc': '최저임금·지급주기 입증',
      },
      {
        'icon': FontAwesomeIcons.lightShieldCheck,
        'title': '3대 보험 등록·납부 증빙',
        'desc': 'SSS/PhilHealth/Pag-IBIG',
      },
      {
        'icon': FontAwesomeIcons.lightFileContract,
        'title': 'PEA 계약서·영수증',
        'desc': '연대책임/교체·환급 근거',
      },
    ];

    return Column(
      children: documents.asMap().entries.map((entry) {
        final index = entry.key;
        final doc = entry.value;
        final isLast = index == documents.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
          padding: EdgeInsets.all(sp.s12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scheme.primary.withValues(alpha: 0.15),
                      scheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    doc['icon'] as IconData,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['title'] as String,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      doc['desc'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.6),
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

  /// 7) 핵심 요약 섹션 (Summary Section)
  Widget _buildSummarySection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.error.withValues(alpha: 0.15),
            scheme.error.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightTriangleExclamation,
                    size: 18,
                    color: scheme.error,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
              Text(
                '핵심 요약',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 요약 포인트 (Summary Points)
          _buildSummaryPoint(
            theme,
            scheme,
            sp,
            number: '1',
            content: '3대 보험(SSS·PhilHealth·Pag-IBIG)은 강제·비협상이며, '
                '거절해도 고용주 의무는 면제되지 않습니다.',
          ),
          SizedBox(height: sp.s12),
          _buildSummaryPoint(
            theme,
            scheme,
            sp,
            number: '2',
            content: '보험료를 현금으로 대체 지급하는 방식은 불가하며, '
                '불이행 시 형사책임을 포함한 법적 책임이 발생합니다.',
          ),
          SizedBox(height: sp.s12),
          _buildSummaryPoint(
            theme,
            scheme,
            sp,
            number: '3',
            content: '맨파워(PEA) 이용을 적극 권장합니다. '
                '연대책임으로 법적 리스크가 분산되고 체계적 관리가 가능합니다.',
            isHighlighted: true,
          ),
        ],
      ),
    );
  }

  /// 요약 포인트 빌더 (Summary Point Builder)
  Widget _buildSummaryPoint(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String number,
    required String content,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: isHighlighted
            ? scheme.tertiary.withValues(alpha: 0.15)
            : scheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: isHighlighted
            ? Border.all(color: scheme.tertiary.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isHighlighted ? scheme.tertiary : scheme.error,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: sp.s12),
          Expanded(
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isHighlighted ? scheme.tertiary : scheme.onErrorContainer,
                height: 1.5,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 참고 URL 섹션 (Reference URLs Section)
  Widget _buildReferencesSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightLink,
            number: '',
            title: '참고 자료',
          ),
          SizedBox(height: sp.s16),

          /// 공식 자료 (Official Documents)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: '공식 자료',
            links: [
              {
                'title': 'DOLE Q&A on Batas Kasambahay',
                'url': 'https://ntucphl.org/wp-content/uploads/2013/06/Q-A-on-Batas-Kasambahay-RA-No-10361.pdf',
              },
              {
                'title': 'IRR (Implementing Rules)',
                'url': 'https://pcw.gov.ph/assets/files/2019/04/RA-10361_Batas-Kasambahay.pdf',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// 뉴스 보도 (News Reports)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: 'NCR 최저임금 관련 보도',
            links: [
              {
                'title': 'Manila Bulletin',
                'url': 'https://mb.com.ph/2024/12/27/dole-kasambahay-monthly-salary-in-ncr-to-increase-by-p500',
              },
              {
                'title': 'PNA (Philippine News Agency)',
                'url': 'https://www.pna.gov.ph/articles/1240364',
              },
              {
                'title': 'PhilStar',
                'url': 'https://www.philstar.com/nation/2024/12/31/2410855/p500-wage-hike-metro-manila-kasambahay-starts-january-4',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// 필고 참고 글 (PhilGo References)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: '필고 참고 글',
            links: [
              {
                'title': '필고 자유게시판 - 하우스헬퍼',
                'url': 'https://philgo.com/post/view.php?idx=1272991645&post_id=freetalk&page=925',
              },
              {
                'title': '필고 Q&A - 세부 지역',
                'url': 'https://philgo.com/post/view.php?idx=1275689536&idx_comment=1275689656&post_id=qna&page=5&region=%EC%84%B8%EB%B6%80',
              },
              {
                'title': '필고 Q&A - 하우스헬퍼',
                'url': 'https://philgo.com/post/view.php?idx=1275661801&post_id=qna&page=4821',
              },
            ],
          ),
        ],
      ),
    );
  }

  /// 참고 자료 카테고리 빌더 (Reference Category Builder)
  Widget _buildReferenceCategory(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required List<Map<String, String>> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        SizedBox(height: sp.s8),
        ...links.map((link) => _buildReferenceLink(
              theme,
              scheme,
              sp,
              title: link['title']!,
              url: link['url']!,
            )),
      ],
    );
  }

  /// 참고 링크 빌더 (Reference Link Builder)
  Widget _buildReferenceLink(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: EdgeInsets.only(bottom: sp.s8),
        padding: EdgeInsets.symmetric(
          horizontal: sp.s12,
          vertical: sp.s8,
        ),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.lightArrowUpRightFromSquare,
              size: 12,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: scheme.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// URL 열기 함수 (Launch URL Function)
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
