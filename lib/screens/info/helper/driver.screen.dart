import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 운전기사 정보 화면 (Driver Screen)
///
/// 필리핀 운전기사 고용·관리 관련 정보를 제공합니다.
/// Provides information about hiring and managing drivers in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// DriverScreen.push(context);
/// ```
class DriverScreen extends StatelessWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Driver';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const DriverScreen({super.key});

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
              FontAwesomeIcons.lightCarSide,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.helperDriver,
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

            /// 맨파워 필수 권장 섹션 (Manpower Mandatory Recommendation Section)
            _buildManpowerRecommendationSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.05, end: 0),
            SizedBox(height: sp.s16),

            /// 1) 고용 형태 분류 섹션 (Employment Type Section)
            _buildEmploymentTypeSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms),
            SizedBox(height: sp.s16),

            /// 2) 직접고용 vs 맨파워 비교 섹션 (Hiring Comparison Section)
            _buildHiringComparisonSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            SizedBox(height: sp.s16),

            /// 3) 맨파워 업체 선정 섹션 (Manpower Agency Selection Section)
            _buildManpowerSelectionSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms),
            SizedBox(height: sp.s16),

            /// 맨파워 업체 찾는 방법 섹션 (Find Manpower Section)
            _buildFindManpowerSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 275.ms)
                .slideX(begin: -0.05, end: 0),
            SizedBox(height: sp.s16),

            /// 4) 채용 전 필수 서류 섹션 (Required Documents Section)
            _buildRequiredDocumentsSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            SizedBox(height: sp.s16),

            /// 5) 최저임금 섹션 (Minimum Wage Section)
            _buildMinimumWageSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: sp.s16),

            /// 6) 사회보장 섹션 (Social Security Section)
            _buildSocialSecuritySection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
            SizedBox(height: sp.s16),

            /// 7) 근로계약 필수 조항 섹션 (Contract Clauses Section)
            _buildContractClausesSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 450.ms),
            SizedBox(height: sp.s16),

            /// 8) 차량·사고 리스크 섹션 (Vehicle & Accident Risk Section)
            _buildVehicleRiskSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
            SizedBox(height: sp.s16),

            /// 9) 근무 기록 관리 섹션 (Work Record Management Section)
            _buildWorkRecordSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 550.ms),
            SizedBox(height: sp.s16),

            /// 10) 개인정보 준수 섹션 (Data Privacy Section)
            _buildDataPrivacySection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms),
            SizedBox(height: sp.s16),

            /// 11) 계약 종료 섹션 (Contract Termination Section)
            _buildTerminationSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 650.ms),
            SizedBox(height: sp.s16),

            /// 참고 URL 섹션 (Reference URLs Section)
            _buildReferencesSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 700.ms),
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
                FontAwesomeIcons.lightCarSide,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: sp.s16),

          /// 메인 타이틀 (Main Title)
          Text(
            '필리핀 운전 기사',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: sp.s4),
          Text(
            '고용·관리 가이드',
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
              '가정/기업 공통',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// 맨파워 필수 권장 섹션 (Manpower Mandatory Recommendation Section)
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
            scheme.error.withValues(alpha: 0.15),
            scheme.tertiary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.error.withValues(alpha: 0.4),
          width: 2,
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
                  color: scheme.error.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightTriangleExclamation,
                    size: 20,
                    color: scheme.error,
                  ),
                ),
              ),
              SizedBox(width: sp.s12),
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
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '필수 권고',
                        /// labelSmall → labelMedium으로 변경하여 가독성 향상
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    Text(
                      'DOLE 인가 맨파워 업체 이용 강력 권장',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.error,
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
                Text(
                  '운전 기사는 사고 책임·차량 손해·가정/회사 정보 접근 리스크가 결합되는 직무입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: sp.s12),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '고용과 동시에 계약·검증·사회보장 등록·기록관리가 따라야 하며, 맨파워 업체는 이 체계를 표준화해 누락을 줄이는 데 유리합니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            number.isNotEmpty ? '$number $title' : title,
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

  /// 1) 고용 형태 분류 섹션 (Employment Type Section)
  Widget _buildEmploymentTypeSection(
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
            icon: FontAwesomeIcons.lightUsersGear,
            number: '1)',
            title: '고용 형태 먼저 분류하기',
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '운전 기사라도 "가정 전속"인지 "업무 수행"인지에 따라 관리 기준이 달라질 수 있습니다. '
            '계약서에 분류를 명확히 적는 것이 필요합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 고용 형태 비교 카드 (Employment Type Comparison Cards)
          Row(
            children: [
              /// 가정 전속 (Personal/Family)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightHouseUser,
                        size: 24,
                        color: scheme.primary,
                      ),
                      SizedBox(height: sp.s8),
                      Text(
                        '가정 전속',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.primary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '가족 이동, 자녀 픽업 등',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: sp.s8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        /// labelSmall → labelMedium으로 변경하여 가독성 향상
                        child: Text(
                          'Kasambahay 체계',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: sp.s12),

              /// 업무용 (Business)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightBriefcase,
                        size: 24,
                        color: scheme.tertiary,
                      ),
                      SizedBox(height: sp.s8),
                      Text(
                        '업무용',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.tertiary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '회사 업무/영업/물류',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onTertiaryContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: sp.s8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s8,
                          vertical: sp.s4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        /// labelSmall → labelMedium으로 변경하여 가독성 향상
                        child: Text(
                          '사업장 규정 중심',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s12),

          /// 팁 박스 (Tip Box)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '실무에서는 가정 전속 기사를 가사근로자 기준으로 계약·등록하는 방식이 가장 정합적입니다.',
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

  /// 2) 직접고용 vs 맨파워 비교 섹션 (Hiring Comparison Section)
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
            icon: FontAwesomeIcons.lightScaleBalanced,
            number: '2)',
            title: '"직접고용 vs 맨파워(PEA)" 비교',
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
                        '직접고용',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.error,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '△ 조건부 권장',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onErrorContainer,
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
                        '맨파워 경유',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.tertiary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '◎ 적극 권장',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sp.s16),

          /// 비교 테이블 (Comparison Table)
          _buildComparisonTable(theme, scheme, sp),
          SizedBox(height: sp.s16),

          /// 맨파워 이점 목록 (Manpower Benefits List)
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
                      /// labelSmall → labelMedium으로 변경하여 가독성 향상
                      child: Text(
                        '맨파워 이용 실무 사유',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightUserCheck,
                  text: '신원·경력 검증: 면허, 거주지, 조회서류, 레퍼런스 확인',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightFileContract,
                  text: '서면 계약 필수화: 표준 계약(업무·시간·휴무·해지) 반영',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightShieldCheck,
                  text: '사회보장(KURS 포함) 안내·동행: SSS/PhilHealth/Pag-IBIG',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightArrowsRotate,
                  text: '결근·교체·대체 인력 옵션: 운영 리스크 분산',
                ),
                SizedBox(height: sp.s8),
                _buildBenefitItem(
                  theme,
                  scheme,
                  sp,
                  icon: FontAwesomeIcons.lightClipboardList,
                  text: '사고·규율 이슈의 절차 확보: 경고·시정·종료 문서화',
                ),
              ],
            ),
          ),
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
      ['장점', '비용 단순\n운영 자유도', '검증·계약·기록\n등록 표준화'],
      ['취약점', '검증·서류 누락 시\n책임 집중', '비인가 업체 시\n불법중개 위험'],
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
                    /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                    child: Text(
                      cell,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isLastCell ? scheme.tertiary : scheme.onSurface,
                        fontWeight:
                            cellIndex == 0 || isLastCell ? FontWeight.w600 : FontWeight.normal,
                        height: 1.4,
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

  /// 이점 아이템 빌더 (Benefit Item Builder)
  Widget _buildBenefitItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 3) 맨파워 업체 선정 섹션 (Manpower Agency Selection Section)
  Widget _buildManpowerSelectionSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      borderColor: scheme.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightBuildingCircleCheck,
            number: '3)',
            title: '맨파워 업체 선정: DOLE 인가 확인',
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
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '"맨파워"라는 상호만으로는 안전이 보장되지 않습니다. '
                    'DOLE(주로 BLE) 라이선스 확인이 필수입니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// 확인 항목 목록 (Check Items List)
          Text(
            '확인 필수 항목',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildCheckItem(theme, scheme, sp, 'DOLE 라이선스/유효기간', '만료 여부 확인'),
          _buildCheckItem(theme, scheme, sp, 'Authorized 지점·리크루터', '지점 단위 권한 확인'),
          _buildCheckItem(theme, scheme, sp, '배치·교체·수수료·책임 계약', '구두 합의 지양'),
          _buildCheckItem(theme, scheme, sp, '면허/조회/검진/계약 패키지', '"가능"이 아닌 "제공" 확인'),
          _buildCheckItem(theme, scheme, sp, '사고·징계·해지 절차', '보고 체계 문서 보유 여부'),
          SizedBox(height: sp.s16),

          /// 인가 업체 확인 방법 (How to Verify)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightMagnifyingGlass,
                      size: 14,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '인가 업체 확인 방법',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  'DOLE(BLE) 공개 "Licensed Private Employment Agencies" 목록(PDF)에서 '
                  '① 업체명 ② 지역 ③ 본사/지점 ④ 리크루터 정보를 대조합니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: sp.s8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '목록에 없거나 라이선스·리크루터 권한을 제시하지 못하면 이용하지 않는 것이 원칙입니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 확인 항목 빌더 (Check Item Builder)
  Widget _buildCheckItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightCheck,
                size: 10,
                color: scheme.primary,
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4) 채용 전 필수 서류 섹션 (Required Documents Section)
  Widget _buildRequiredDocumentsSection(
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
            icon: FontAwesomeIcons.lightFileLines,
            number: '4)',
            title: '채용 전 필수 서류 (권장 최소 세트)',
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '운전 기사는 "운전 자격"과 "신원 확인"을 분리해 검증해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 서류 목록 (Documents List)
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightIdCard,
            title: '운전면허',
            description: '자격·코드 확인, 만료/제한 확인',
          ),
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightAddressCard,
            title: '정부 ID',
            description: '본인 확인, 유효기간 확인',
          ),
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightLocationDot,
            title: '주소증빙',
            description: '거주지 확인 (필요 시)',
          ),
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightUserShield,
            title: '신원조회',
            description: '범죄·사고 리스크, 범위·유효기간 규정',
          ),
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightHeartPulse,
            title: '건강검진',
            description: '기본 적합성, 비용 부담 주체 명시',
          ),
          _buildDocumentItem(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightUserCheck,
            title: '레퍼런스',
            description: '과거 근무 확인, 연락처 실재 확인',
            isLast: true,
          ),
          SizedBox(height: sp.s12),

          /// 개인정보 안내 (Privacy Notice)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightShieldHalved,
                  size: 14,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '위 서류는 개인정보에 해당할 수 있으므로 수집 목적·보관 기간·접근 권한을 '
                    '서면으로 고지·동의받는 체계가 필요합니다.',
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

  /// 서류 항목 빌더 (Document Item Builder)
  Widget _buildDocumentItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                icon,
                size: 14,
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
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: sp.s4),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            title: '임금·최저임금: "지역별 상이"',
            iconColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '가사근로자/가정 전속 기사로 운영하는 경우에도 지역별 최저임금(가사근로자 임금) 준수가 중요합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
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
                        /// labelSmall → labelMedium으로 변경하여 가독성 향상
                        child: Text(
                          'NCR (메트로 마닐라)',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '2025-01-04 시행',
                        style: theme.textTheme.bodyMedium?.copyWith(
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

          /// 기타 지역 및 실무 권장 (Other Regions & Tips)
          Container(
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
                    FaIcon(
                      FontAwesomeIcons.lightLocationDot,
                      size: 14,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '기타 지역',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '지역별 임금명령(Wage Order)로 상이합니다. '
                  '거주 지역(또는 근무 지역)의 RTWPB/NWPC 공지를 기준으로 임금표를 최신화하세요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sp.s8),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '임금 분쟁은 통상 "최저임금 미달(underpayment)"로 발생하므로, '
                  '계약서·급여대장에 근거를 남기세요.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w500,
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

  /// 6) 사회보장 섹션 (Social Security Section)
  Widget _buildSocialSecuritySection(
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
            number: '6)',
            title: '사회보장 (SSS/PhilHealth/Pag-IBIG)',
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '가사근로자 체계(가정 전속)로 운영하는 경우, 고용주는 사회보장 가입·납부 의무를 부담할 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 3대 보험 카드 (Insurance Cards)
          _buildInsuranceCard(
            theme,
            scheme,
            sp,
            title: 'SSS',
            description: '하우스홀드 고용주 등록 및 납부',
            note: '2025년부터 기여금 스케줄 변경 공지 존재',
          ),
          SizedBox(height: sp.s8),
          _buildInsuranceCard(
            theme,
            scheme,
            sp,
            title: 'PhilHealth',
            description: '하우스홀드 고용주·근로자 등록',
            note: 'KURS/특별 납부 방식 안내 존재',
          ),
          SizedBox(height: sp.s8),
          _buildInsuranceCard(
            theme,
            scheme,
            sp,
            title: 'Pag-IBIG',
            description: '가사근로자/고용주 등록',
            note: '온라인 원스톱 등록 창구 제공',
          ),
          SizedBox(height: sp.s16),

          /// 경고 박스 (Warning Box)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 16,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '납부 누락은 분쟁 시 고용주 책임으로 확장될 수 있으므로, '
                    '맨파워 업체를 통한 등록·납부 캘린더 운영을 권장합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w500,
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

  /// 보험 카드 빌더 (Insurance Card Builder)
  Widget _buildInsuranceCard(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String description,
    required String note,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                title.substring(0, 1),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: scheme.error,
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
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: sp.s4),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: sp.s4),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  note,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 7) 근로계약 필수 조항 섹션 (Contract Clauses Section)
  Widget _buildContractClausesSection(
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
            number: '7)',
            title: '운전기사 전용 근로계약 필수 조항',
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '운전 기사는 업무 범위가 쉽게 확장됩니다. 아래 항목을 계약 본문에 직접 기재해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 계약 조항 목록 (Contract Clauses List)
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '업무',
            content: '운전 외 업무(세차/정비 동행/심부름/물품 운반) 포함 여부',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '시간',
            content: '출퇴근, 대기시간(standby) 정의, 야간·장거리 기준',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '휴무',
            content: '주휴, 휴가, 긴급 호출 예외',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '급여',
            content: '기본급, 수당(야간/장거리), 현금대체 제공 여부',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '비용',
            content: '유류/통행/주차/정비 결재·영수증 규칙',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '차량',
            content: '개인용도 금지, 동승자 제한, 주차·보관 규정',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '사고',
            content: '즉시 보고, 경찰리포트, 보험처리 협조 의무',
            isWarning: true,
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '징계',
            content: '경고→서면통지→시정기회→종료 절차',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '보안',
            content: '이동경로·가정/회사 정보 비밀유지',
          ),
          _buildContractClause(
            theme,
            scheme,
            sp,
            title: '개인정보',
            content: '서류 보관·파기·제3자 제공 범위 동의',
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 계약 조항 빌더 (Contract Clause Builder)
  Widget _buildContractClause(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String content,
    bool isWarning = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: isWarning
            ? scheme.errorContainer.withValues(alpha: 0.2)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: isWarning
            ? Border.all(color: scheme.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            padding: EdgeInsets.symmetric(
              horizontal: sp.s8,
              vertical: sp.s4,
            ),
            decoration: BoxDecoration(
              color: isWarning
                  ? scheme.error.withValues(alpha: 0.2)
                  : scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWarning ? scheme.error : scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: sp.s12),
          Expanded(
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWarning ? scheme.error : scheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 8) 차량·사고 리스크 섹션 (Vehicle & Accident Risk Section)
  Widget _buildVehicleRiskSection(
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
            icon: FontAwesomeIcons.lightCarBurst,
            number: '8)',
            title: '차량·사고 리스크: 보험과 보고 체계',
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '운전기사 고용에서 가장 큰 리스크는 "사고"입니다. 보험은 최소·추가를 구분해 설계해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 보험 유형 (Insurance Types)
          Text(
            '보험 유형',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildInsuranceTypeCard(
            theme,
            scheme,
            sp,
            title: 'CTPL/CMVLI',
            description: '의무(기본): 제3자 인명 피해 중심',
            tag: '필수',
            tagColor: scheme.error,
          ),
          SizedBox(height: sp.s8),
          _buildInsuranceTypeCard(
            theme,
            scheme,
            sp,
            title: '종합보험',
            description: '자기차량 손해·도난·자연재해 등 확장',
            tag: '권장',
            tagColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s8),
          _buildInsuranceTypeCard(
            theme,
            scheme,
            sp,
            title: '개인상해/운전자 특약',
            description: '운전자·동승자 위험 보완',
            tag: '선택',
            tagColor: scheme.primary,
          ),
          SizedBox(height: sp.s16),

          /// 사고 발생 시 절차 (Accident Procedure)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightSiren,
                      size: 16,
                      color: scheme.error,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '사고 발생 시 표준 절차',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),
                _buildAccidentStep(theme, scheme, sp, 1, '인명 안전 확보, 즉시 신고'),
                _buildAccidentStep(theme, scheme, sp, 2, '현장 사진·블랙박스 확보'),
                _buildAccidentStep(theme, scheme, sp, 3, '고용주/맨파워 업체에 즉시 보고'),
                _buildAccidentStep(theme, scheme, sp, 4, '보험사·경찰 리포트 절차 진행'),
                _buildAccidentStep(
                    theme, scheme, sp, 5, '사건 기록(시간·장소·상황·조치) 문서화',
                    isLast: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 보험 유형 카드 빌더 (Insurance Type Card Builder)
  Widget _buildInsuranceTypeCard(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String description,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: sp.s4),
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s8,
              vertical: sp.s4,
            ),
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            child: Text(
              tag,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 사고 절차 단계 빌더 (Accident Step Builder)
  Widget _buildAccidentStep(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    int step,
    String content, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: scheme.error,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              /// labelSmall → labelMedium으로 변경하여 가독성 향상
              child: Text(
                '$step',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: sp.s8),
          Expanded(
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 9) 근무 기록 관리 섹션 (Work Record Management Section)
  Widget _buildWorkRecordSection(
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
            icon: FontAwesomeIcons.lightClipboardList,
            number: '9)',
            title: '근무 중 "기록"으로 관리하기',
          ),
          SizedBox(height: sp.s12),
          Text(
            '감시가 아니라 기록이 분쟁을 줄입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 운행일지 (Driving Log)
          Text(
            '운행일지 (권장)',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildLogTable(theme, scheme, sp),
          SizedBox(height: sp.s16),

          /// 금지·제한 규정 (Prohibited/Limited Rules)
          Text(
            '금지·제한 규정 (권장)',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          _buildProhibitionItem(
            theme,
            scheme,
            sp,
            title: '현금',
            content: '원칙 금지 (예외 시 영수증·서면지시)',
          ),
          _buildProhibitionItem(
            theme,
            scheme,
            sp,
            title: '임의운행',
            content: '개인용도 운행 금지',
          ),
          _buildProhibitionItem(
            theme,
            scheme,
            sp,
            title: '동승',
            content: '승인 인원만',
          ),
          _buildProhibitionItem(
            theme,
            scheme,
            sp,
            title: '음주/약물',
            content: '위반 시 즉시 조치 (계약 조항화)',
            isWarning: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  /// 운행일지 테이블 빌더 (Driving Log Table Builder)
  Widget _buildLogTable(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final items = [
      {'항목': '날짜', '내용': 'YYYY-MM-DD'},
      {'항목': '출/퇴근', '내용': '시간'},
      {'항목': '운행', '내용': '출발/도착/목적'},
      {'항목': 'km', '내용': '시작/종료'},
      {'항목': '비용', '내용': '유류/통행/주차'},
      {'항목': '이슈', '내용': '사고/위반/특이사항'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

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
                Container(
                  width: 60,
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  /// labelSmall → labelMedium으로 변경하여 가독성 향상
                  child: Text(
                    item['항목']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    item['내용']!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.8),
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

  /// 금지 항목 빌더 (Prohibition Item Builder)
  Widget _buildProhibitionItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String content,
    bool isWarning = false,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: isWarning
            ? scheme.errorContainer.withValues(alpha: 0.2)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          FaIcon(
            isWarning
                ? FontAwesomeIcons.lightTriangleExclamation
                : FontAwesomeIcons.lightBan,
            size: 14,
            color: isWarning ? scheme.error : scheme.onSurface.withValues(alpha: 0.5),
          ),
          SizedBox(width: sp.s12),
          SizedBox(
            width: 60,
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isWarning ? scheme.error : scheme.onSurface,
              ),
            ),
          ),
          Expanded(
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isWarning ? scheme.error : scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 10) 개인정보 준수 섹션 (Data Privacy Section)
  Widget _buildDataPrivacySection(
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
            icon: FontAwesomeIcons.lightShieldHalved,
            number: '10)',
            title: '개인정보(데이터프라이버시) 준수',
          ),
          SizedBox(height: sp.s12),
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            '운전기사 채용 시 수집하는 신원조회·건강정보 등은 개인정보(일부는 민감정보)가 될 수 있습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: sp.s16),

          /// 준수 항목 (Compliance Items)
          _buildPrivacyItem(
            theme,
            scheme,
            sp,
            title: '고지',
            content: '수집 목적·항목·보관기간·제공처 명시',
          ),
          _buildPrivacyItem(
            theme,
            scheme,
            sp,
            title: '동의',
            content: '서면/전자 등 증빙 가능한 형태',
          ),
          _buildPrivacyItem(
            theme,
            scheme,
            sp,
            title: '제한',
            content: '필요 최소 항목만 수집',
          ),
          _buildPrivacyItem(
            theme,
            scheme,
            sp,
            title: '보안',
            content: '접근권한 제한, 보관·파기 규칙',
          ),
          _buildPrivacyItem(
            theme,
            scheme,
            sp,
            title: '기록',
            content: '누가/언제/왜 열람했는지 로그화 (권장)',
            isLast: true,
          ),
          SizedBox(height: sp.s12),

          /// 팁 박스 (Tip Box)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '블랙박스·GPS 등은 목적과 범위를 명확히 하여 '
                    '정책(내규)+동의서로 관리하는 편이 안전합니다.',
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

  /// 개인정보 항목 빌더 (Privacy Item Builder)
  Widget _buildPrivacyItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String content,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : sp.s8),
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: EdgeInsets.symmetric(
              horizontal: sp.s8,
              vertical: sp.s4,
            ),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            /// labelSmall → labelMedium으로 변경하여 가독성 향상
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: sp.s12),
          Expanded(
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 11) 계약 종료 섹션 (Contract Termination Section)
  Widget _buildTerminationSection(
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
            icon: FontAwesomeIcons.lightFileCircleXmark,
            number: '11)',
            title: '계약 종료(해지) 시 문서 4종 세트',
            iconColor: scheme.error,
          ),
          SizedBox(height: sp.s16),

          /// 문서 단계 (Document Steps)
          _buildTerminationStep(
            theme,
            scheme,
            sp,
            step: 1,
            title: '사실기록',
            content: '일지/사고보고/경고장',
            icon: FontAwesomeIcons.lightFileLines,
          ),
          _buildTerminationStep(
            theme,
            scheme,
            sp,
            step: 2,
            title: '서면 통지',
            content: '시정기회 포함',
            icon: FontAwesomeIcons.lightEnvelope,
          ),
          _buildTerminationStep(
            theme,
            scheme,
            sp,
            step: 3,
            title: '최종 종료 통지·정산서',
            content: '해지 확정 및 급여 정산',
            icon: FontAwesomeIcons.lightFileInvoiceDollar,
          ),
          _buildTerminationStep(
            theme,
            scheme,
            sp,
            step: 4,
            title: '반납 확인',
            content: '차키/ID/유류카드 등',
            icon: FontAwesomeIcons.lightKey,
            isLast: true,
          ),
          SizedBox(height: sp.s16),

          /// 경고 박스 (Warning Box)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 16,
                  color: scheme.error,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '직접고용은 위 문서 체계를 고용주가 직접 구축해야 합니다. '
                    '따라서 DOLE 인가 맨파워 업체를 통한 고용을 다시 한 번 강하게 권장합니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w500,
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

  /// 종료 절차 단계 빌더 (Termination Step Builder)
  Widget _buildTerminationStep(
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
                    scheme.error,
                    scheme.error.withValues(alpha: 0.8),
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
                color: scheme.error.withValues(alpha: 0.3),
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
                  color: scheme.error,
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

                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        content,
                        style: theme.textTheme.bodyMedium?.copyWith(
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
            title: '참고 URL',
          ),
          SizedBox(height: sp.s16),

          /// SSS 관련 (SSS Related)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: 'SSS (Social Security System)',
            links: [
              {
                'title': 'SSS Household Employer 안내',
                'url': 'https://www.sss.gov.ph/household-employer/',
              },
              {
                'title': 'SSS 2025 기여금 스케줄 (PDF)',
                'url':
                    'https://www.sss.gov.ph/wp-content/uploads/2024/12/CI-2024-007-Publication.pdf',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// PhilHealth 관련 (PhilHealth Related)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: 'PhilHealth',
            links: [
              {
                'title': 'Kasambahay 안내 (PDF)',
                'url': 'https://www.philhealth.gov.ph/circulars/2015/TS_circ016-2015.pdf',
              },
              {
                'title': 'Household Employer 통합등록 양식 (PDF)',
                'url':
                    'https://www.philhealth.gov.ph/downloads/kasambahay/Household_Employer_Unified_Registration_Form.pdf',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// Pag-IBIG 관련 (Pag-IBIG Related)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: 'Pag-IBIG',
            links: [
              {
                'title': 'Pag-IBIG 온라인 서비스',
                'url': 'https://www.pagibigfundservices.com/Views/HomePage.aspx',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// DOLE 관련 (DOLE Related)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: 'DOLE (노동부)',
            links: [
              {
                'title': 'DOLE PEA FAQ (PDF)',
                'url': 'https://www.ble.dole.gov.ph/wp-content/uploads/2022/06/2022-PEA-FAQs.pdf',
              },
              {
                'title': 'Licensed PEA 목록 (2025년, PDF)',
                'url':
                    'https://www.ble.dole.gov.ph/wp-content/uploads/2025/01/LIST-OF-LICENSED-PRIVATE-EMPLOYMENT-AGENCIES.pdf',
              },
              {
                'title': 'Dept. Order 217 - 가사근로자 모집·배치 규정 (PDF)',
                'url':
                    'https://batangmalaya.ph/wp-content/uploads/2023/01/DOLE-Department-Order-No.-217-Series-of-2020-min.pdf',
              },
            ],
          ),
          SizedBox(height: sp.s16),

          /// 법률 관련 (Legal Related)
          _buildReferenceCategory(
            theme,
            scheme,
            sp,
            title: '법률 및 규정',
            links: [
              {
                'title': 'Batas Kasambahay IRR (PDF)',
                'url': 'https://pcw.gov.ph/assets/files/2022/07/IRR-RA-10361-Batas-Kasambahay.pdf',
              },
              {
                'title': 'Data Privacy Act (RA 10173)',
                'url': 'https://privacy.gov.ph/data-privacy-act/',
              },
              {
                'title': '보험위원회 - 제3자 책임 보장 한도 상향 (PDF)',
                'url':
                    'https://www.insurance.gov.ph/wp-content/uploads/2024/04/PR-IC-doubles-third-party-liability-insurance.pdf',
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
            /// 아이콘 크기 12 → 14로 변경하여 가독성 향상
            FaIcon(
              FontAwesomeIcons.lightArrowUpRightFromSquare,
              size: 14,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s12),
            Expanded(
              /// bodySmall → bodyMedium으로 변경하여 가독성 향상
              child: Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
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

  /// 맨파워 업체 찾는 방법 섹션 빌더 (Find Manpower Section Builder)
  ///
  /// 운전기사 맨파워 업체를 찾는 4가지 방법과 주요 업체 연락처, 체크리스트를 제공합니다.
  /// Provides 4 methods to find driver manpower agencies, major agency contacts, and checklist.
  Widget _buildFindManpowerSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return _buildInfoCard(
      theme,
      scheme,
      sp,
      borderColor: scheme.tertiary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 섹션 타이틀 (Section Title)
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightMagnifyingGlass,
            number: '',
            title: '맨파워 업체 찾는 방법',
            iconColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s16),

          /// DOLE 등록 확인 안내 (DOLE Verification Notice)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightPhoneVolume,
                  size: 16,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOLE 라이센스 확인',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.tertiary,
                        ),
                      ),
                      SizedBox(height: sp.s4),
                      Text(
                        'DOLE 핫라인: 1349 (24시간)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: sp.s4),

                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        'POEA 불법채용 신고: 722-1144 / 722-1155',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: sp.s4),

                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '라이센스 없이 운영하는 업체는 불법입니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// 4가지 검색 방법 (4 Search Methods)
          Text(
            '업체 검색 방법',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),

          /// (1) 웹 검색 (Web Search)
          _buildDriverSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightGlobe,
            title: '웹 검색',
            content:
                'Google에서 "private driver agency Philippines", "family driver Metro Manila" 등으로 검색 후 DOLE 등록 여부 확인',
          ),
          SizedBox(height: sp.s8),

          /// (2) 구인 사이트 (Job Sites)
          _buildDriverSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightBriefcase,
            title: '구인 사이트',
            content:
                'Jobstreet (ph.jobstreet.com), Indeed (ph.indeed.com), Jooble에서 "family driver", "personal driver" 검색',
          ),
          SizedBox(height: sp.s8),

          /// (3) Facebook 그룹 (Facebook Groups)
          _buildDriverSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.facebook,
            title: 'Facebook 그룹',
            content:
                '"Driver hiring Philippines", "Family driver Metro Manila" 검색. 단, 개인거래는 리스크가 높으므로 DOLE 등록 업체 우선 이용 권장',
            isWarning: true,
          ),
          SizedBox(height: sp.s8),

          /// (4) 전문 에이전시 (Specialized Agencies)
          _buildDriverSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightBuilding,
            title: '전문 에이전시',
            content:
                'Luxury Philippines D.S. Agency (lpds.agency), Personal Drivers For Hire (personaldriversforhire.com) 등 운전기사 전문 에이전시 직접 문의',
          ),
          SizedBox(height: sp.s20),

          /// 주요 구인 플랫폼 (Major Job Platforms)
          Text(
            '주요 구인 플랫폼',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 플랫폼 카드들 (Platform Cards)
          _buildDriverAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'Jobstreet Philippines',
            feature: '필리핀 최대 구인 플랫폼',
            description: '"Family Driver", "Personal Driver" 검색',
            url: 'https://ph.jobstreet.com/driver-jobs',
          ),
          SizedBox(height: sp.s8),
          _buildDriverAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'Indeed Philippines',
            feature: '글로벌 구인 플랫폼',
            description: '경력 2년 이상 운전기사 다수 등록',
            url: 'https://ph.indeed.com/q-family-driver-jobs.html',
          ),
          SizedBox(height: sp.s8),
          _buildDriverAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'Luxury Philippines D.S.',
            feature: '운전기사 전문 에이전시',
            description: '가정/기업용 프라이빗 드라이버 서비스',
            url: 'https://lpds.agency/philippine-private-driver/',
          ),
          SizedBox(height: sp.s20),

          /// 업체 선정 체크리스트 (Agency Selection Checklist)
          Container(
            padding: EdgeInsets.all(sp.s16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightClipboardCheck,
                      size: 16,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '운전기사 선정 체크리스트',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),
                _buildDriverChecklistItem(
                    theme, scheme, sp, 'Professional Driver\'s License 유효기간 확인'),
                SizedBox(height: sp.s4),
                _buildDriverChecklistItem(
                    theme, scheme, sp, 'NBI Clearance (무범죄 증명) 확인'),
                SizedBox(height: sp.s4),
                _buildDriverChecklistItem(
                    theme, scheme, sp, '운전 경력 최소 2-5년 이상 확인'),
                SizedBox(height: sp.s4),
                _buildDriverChecklistItem(
                    theme, scheme, sp, 'Metro Manila 및 인근 지역 숙지 여부'),
                SizedBox(height: sp.s4),
                _buildDriverChecklistItem(
                    theme, scheme, sp, '이전 고용주 레퍼런스 체크'),
                SizedBox(height: sp.s4),
                _buildDriverChecklistItem(
                    theme, scheme, sp, '건강검진서 (의료 적합성) 확인'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 운전기사 검색 방법 카드 빌더 (Driver Search Method Card Builder)
  Widget _buildDriverSearchMethodCard(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String title,
    required String content,
    bool isWarning = false,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: isWarning
            ? scheme.errorContainer.withValues(alpha: 0.15)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: isWarning
            ? Border.all(color: scheme.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWarning
                  ? scheme.error.withValues(alpha: 0.15)
                  : scheme.tertiary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: FaIcon(
                icon,
                size: 14,
                color: isWarning ? scheme.error : scheme.tertiary,
              ),
            ),
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
                    color: isWarning ? scheme.error : scheme.onSurface,
                  ),
                ),
                SizedBox(height: sp.s4),

                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.8),
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

  /// 운전기사 에이전시 카드 빌더 (Driver Agency Card Builder)
  Widget _buildDriverAgencyCard(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String name,
    required String feature,
    required String description,
    required String url,
  }) {
    return InkWell(
      onTap: () => _launchUrl(url),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(sp.s12),
        decoration: BoxDecoration(
          color: scheme.primaryContainer.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.lightCarSide,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      FaIcon(
                        FontAwesomeIcons.lightArrowUpRightFromSquare,
                        size: 12,
                        color: scheme.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: sp.s4),

                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Text(
                    feature,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
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

  /// 운전기사 체크리스트 항목 빌더 (Driver Checklist Item Builder)
  Widget _buildDriverChecklistItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String text,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          /// 아이콘 크기 10 → 12로 변경하여 가독성 향상
          child: Center(
            child: FaIcon(
              FontAwesomeIcons.lightCheck,
              size: 12,
              color: scheme.primary,
            ),
          ),
        ),
        SizedBox(width: sp.s8),
        Expanded(
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
