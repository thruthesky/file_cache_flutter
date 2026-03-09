import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:url_launcher/url_launcher.dart';

/// 가정교사 정보 화면 (Tutor Screen)
///
/// 필리핀 가정교사(홈 튜터) 고용·관리 관련 정보를 제공합니다.
/// Provides information about hiring and managing home tutors in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// TutorScreen.push(context);
/// ```
class TutorScreen extends StatelessWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Tutor';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const TutorScreen({super.key});

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
              FontAwesomeIcons.lightChalkboardUser,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.helperTutor,
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
            SizedBox(height: sp.s32),

            /// 주의사항 섹션 (Disclaimer Section)
            _buildDisclaimerSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.05, end: 0),
            SizedBox(height: sp.s24),

            /// 1) 적용 범위와 고용 형태 구분 섹션
            _buildEmploymentTypeSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms),
            SizedBox(height: sp.s24),

            /// 2) 카삼바하이 제도 핵심 섹션
            _buildKasambahaySection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            SizedBox(height: sp.s24),

            /// 3) 채용 절차 섹션
            _buildHiringProcessSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms),
            SizedBox(height: sp.s24),

            /// 4) 계약서 필수 항목 섹션
            _buildContractItemsSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            SizedBox(height: sp.s24),

            /// 5) 사회보험 등록 섹션
            _buildSocialInsuranceSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms),
            SizedBox(height: sp.s24),

            /// 6) 월별 운영 관리 섹션
            _buildMonthlyManagementSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
            SizedBox(height: sp.s24),

            /// 7) 운전기사 고용 권장 섹션
            _buildDriverRecommendationSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 450.ms),
            SizedBox(height: sp.s24),

            /// 튜터/맨파워 업체 찾는 방법 섹션 (Find Tutor/Manpower Section)
            _buildFindTutorSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 475.ms)
                .slideX(begin: -0.05, end: 0),
            SizedBox(height: sp.s24),

            /// 8) 외국인 튜터 고용 섹션
            _buildForeignTutorSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
            SizedBox(height: sp.s24),

            /// 9) 분쟁 처리 섹션
            _buildDisputeResolutionSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 550.ms),
            SizedBox(height: sp.s24),

            /// 참고 URL 섹션
            _buildReferencesSection(context, theme, scheme, sp)
                .animate()
                .fadeIn(duration: 400.ms, delay: 600.ms),
            SizedBox(height: sp.s48),
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
                FontAwesomeIcons.lightChalkboardUser,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: sp.s16),

          /// 메인 타이틀 (Main Title)
          Text(
            '필리핀 가정 교사(홈 튜터)',
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

          /// 서브 타이틀 (Subtitle) - 📌 배지
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '자녀 영어 교육 목적',
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

  /// 주의사항 섹션 (Disclaimer Section)
  Widget _buildDisclaimerSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.tertiary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 18,
            color: scheme.tertiary,
          ),
          SizedBox(width: sp.s12),
          Expanded(
            /// 주의사항 텍스트 (Disclaimer Text)
            /// bodySmall → bodyMedium으로 변경하여 가독성 향상
            child: Text(
              '본 문서는 공적 자료를 기반으로 한 정보 정리이며, 개별 사례(사고·분쟁·세무·비자)는 관할기관/전문가 확인이 필요합니다.',
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

  /// 섹션 타이틀 위젯 빌더 (Section Title Widget Builder)
  /// - 아이콘 박스 크기 증가 (36 → 44)
  /// - 타이틀 스타일 강화 (titleMedium → titleLarge)
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (iconColor ?? scheme.primary).withValues(alpha: 0.25),
                (iconColor ?? scheme.primary).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 18,
              color: iconColor ?? scheme.primary,
            ),
          ),
        ),
        SizedBox(width: sp.s16),
        Expanded(
          child: Text(
            number.isNotEmpty ? '$number $title' : title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 카드 빌더 (Info Card Builder)
  /// - 패딩을 sp.s20으로 증가하여 내부 여백 확보
  /// - borderRadius를 20으로 증가하여 더 부드러운 느낌
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
      padding: EdgeInsets.all(sp.s20),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null
            ? Border.all(color: borderColor, width: 1)
            : null,
      ),
      child: child,
    );
  }

  /// 테이블 행 빌더 (Table Row Builder)
  /// - 패딩을 증가하여 가독성 향상
  /// - 헤더와 본문 스타일 차이를 명확히
  Widget _buildTableRow(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    List<String> cells, {
    bool isHeader = false,
    List<int>? flexValues,
  }) {
    final defaultFlex = List.generate(cells.length, (_) => 1);
    final flex = flexValues ?? defaultFlex;

    return Container(
      padding: EdgeInsets.symmetric(vertical: sp.s16, horizontal: sp.s16),
      decoration: BoxDecoration(
        color: isHeader
            ? scheme.primaryContainer.withValues(alpha: 0.4)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: List.generate(cells.length, (index) {
          return Expanded(
            flex: flex[index],
            child: Text(
              cells[index],
              style: isHeader
                  ? theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: scheme.primary,
                    )
                  : theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
            ),
          );
        }),
      ),
    );
  }

  /// 체크 아이템 빌더 (Check Item Builder)
  /// - 아이콘 크기 증가 (20 → 24)
  /// - 텍스트 스타일 개선 (bodySmall → bodyMedium)
  Widget _buildCheckItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String text,
    String? subText,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: FaIcon(
                icon ?? FontAwesomeIcons.lightCheck,
                size: 12,
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
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                if (subText != null) ...[
                  SizedBox(height: sp.s4),

                  /// 체크 항목 부가 설명 (Check Item Sub Text)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Text(
                    subText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1) 적용 범위와 고용 형태 구분 섹션
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
            title: '적용 범위와 고용 형태 구분',
          ),
          SizedBox(height: sp.s16),
          Text(
            "필리핀에서 '가정 교사(튜터)'는 고용 구조에 따라 크게 세 가지로 나뉩니다. "
            '고용 형태에 따라 의무 가입(SSS·PhilHealth·Pag-IBIG), 계약서 필수 항목, '
            '분쟁 처리 절차가 달라질 수 있으므로 최초에 형태를 명확히 구분해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// 고용 형태 3가지 카드 (Three Employment Type Cards)
          Column(
            children: [
              /// 개인 튜터
              _buildEmploymentTypeCard(
                theme,
                scheme,
                sp,
                icon: FontAwesomeIcons.lightUser,
                title: '개인 튜터',
                subtitle: '개인과 직접 계약',
                control: '통제: 높음',
                keyPoint: '근로자성 판단 이슈',
                color: scheme.primary,
              ),
              SizedBox(height: sp.s12),

              /// 학원·에이전시
              _buildEmploymentTypeCard(
                theme,
                scheme,
                sp,
                icon: FontAwesomeIcons.lightBuilding,
                title: '학원·에이전시',
                subtitle: '업체와 계약',
                control: '통제: 중간',
                keyPoint: '업체 자격·책임 확인',
                color: scheme.secondary,
              ),
              SizedBox(height: sp.s12),

              /// 돌봄 겸임
              _buildEmploymentTypeCard(
                theme,
                scheme,
                sp,
                icon: FontAwesomeIcons.lightHouseUser,
                title: '돌봄 겸임',
                subtitle: '가사·돌봄 + 교육',
                control: '통제: 높음',
                keyPoint: '카삼바하이 기준 검토',
                color: scheme.tertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 고용 형태 카드 빌더 (Employment Type Card Builder)
  Widget _buildEmploymentTypeCard(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String control,
    required String keyPoint,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(sp.s12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: FaIcon(icon, size: 20, color: color),
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
                    color: color,
                  ),
                ),
                SizedBox(height: sp.s4),

                /// 고용 형태 설명 (Employment Type Description)
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '$subtitle · $control',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          /// 핵심 포인트 배지 (Key Point Badge)
          /// labelSmall → labelMedium으로 변경하여 가독성 향상
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              keyPoint,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2) 카삼바하이 제도 핵심 섹션
  Widget _buildKasambahaySection(
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
            title: "필리핀 '가사근로자(카삼바하이)' 제도 핵심",
          ),
          SizedBox(height: sp.s16),
          Text(
            '가정 내에서 상시·반복적으로 근무하는 형태(돌봄/가사 겸임 등)는 카삼바하이 제도 기준을 '
            '관리 표준으로 삼는 것이 일반적으로 안전합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// 제도 핵심 항목 테이블 (Core Items Table)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  /// 테이블 헤더 - flexValues [1, 2, 2]로 항목:요지:메모 비율 조정
                  /// "항목"은 짧은 텍스트이므로 20%, "요지"와 "메모"는 각각 40%
                  _buildTableRow(
                    theme,
                    scheme,
                    sp,
                    ['항목', '요지', '메모'],
                    isHeader: true,
                    flexValues: [1, 2, 2],
                  ),
                  _buildTableRow(theme, scheme, sp, ['계약', '서면 고용계약 권장', '업무·시간·급여 명시'], flexValues: [1, 2, 2]),
                  _buildTableRow(theme, scheme, sp, ['휴식', '일일·주간 휴식', '휴무일 합의'], flexValues: [1, 2, 2]),
                  _buildTableRow(theme, scheme, sp, ['휴가', '유급 휴가(조건 충족 시)', '누적/현금화 제한'], flexValues: [1, 2, 2]),
                  _buildTableRow(theme, scheme, sp, ['13월 급여', '13th month pay', '지급 시점 규정'], flexValues: [1, 2, 2]),
                  _buildTableRow(theme, scheme, sp, ['사회보험', 'SSS·PhilHealth·Pag-IBIG', '등록·납부 의무'], flexValues: [1, 2, 2]),
                  _buildTableRow(theme, scheme, sp, ['등록', '바랑가이 등록(지역별)', '현지 절차 상이'], flexValues: [1, 2, 2]),
                ],
              ),
            ),
          ),
          SizedBox(height: sp.s16),

          /// 최저임금 중요 안내 (Minimum Wage Important Notice)
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.error.withValues(alpha: 0.1),
                  scheme.tertiary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: scheme.error.withValues(alpha: 0.3),
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
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      /// 중요 배지 텍스트 (Important Badge Text)
                      /// labelSmall → labelMedium으로 변경하여 가독성 향상
                      child: Text(
                        '중요',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: sp.s8),
                    Expanded(
                      child: Text(
                        '최저임금은 지역별 임금명령으로 조정됨',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),

                /// 최저임금 안내 텍스트 (Minimum Wage Info Text)
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '가사근로자 최저임금은 전국 단일이 아니라 지역별 임금위원회(RTWPB) 임금명령으로 조정됩니다. '
                  '따라서 거주 지역의 최신 임금명령을 확인한 뒤 계약서에 반영해야 합니다.',
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

  /// 3) 채용 절차 섹션
  Widget _buildHiringProcessSection(
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
            number: '3)',
            title: '자녀 영어 홈 튜터 채용 절차',
          ),
          SizedBox(height: sp.s16),
          Text(
            "홈 튜터는 통상 '교육 서비스' 성격이 강하지만, 실제 운영에서는 가정 내 출입·아동 접촉·현금 지급·일정 통제가 "
            '결합되므로 최소한 아래 수준의 검증·문서화를 권장합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// 채용 절차 단계별 카드 (Hiring Process Steps)
          _buildProcessStep(theme, scheme, sp, '1', '채용경로', '개인/기관/소개 구분', '소개자 정보'),
          _buildProcessStep(theme, scheme, sp, '2', '신원확인', '정부 발급 ID 확인', 'ID 사본'),
          _buildProcessStep(theme, scheme, sp, '3', '범죄경력', 'NBI Clearance 확인', 'NBI Clearance'),
          _buildProcessStep(theme, scheme, sp, '4', '경력검증', '레퍼런스 2곳 이상', '추천인 연락처'),
          _buildProcessStep(theme, scheme, sp, '5', '시범수업', '1~2회 평가', '수업기록'),
          _buildProcessStep(theme, scheme, sp, '6', '계약체결', '범위·보수·해지 명시', '계약서 서명본'),
          _buildProcessStep(theme, scheme, sp, '7', '출입관리', '출입시간·동선', '방문기록'),
          SizedBox(height: sp.s12),

          /// NBI Clearance 안내
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightCircleInfo,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// NBI Clearance 안내 텍스트 (NBI Clearance Info Text)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    'NBI Clearance는 취업 목적 등으로 발급되는 공식 증명서이므로, 가정 출입 인력 검증 서류로 실무상 활용도가 높습니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
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

  /// 채용 절차 단계 빌더 (Process Step Builder)
  /// - 스텝 번호 크기 증가 (28 → 32)
  /// - 패딩 및 텍스트 스타일 개선
  Widget _buildProcessStep(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String step,
    String title,
    String check,
    String document,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: sp.s12),
      padding: EdgeInsets.all(sp.s16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                step,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: sp.s16),
          Expanded(
            flex: 2,
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

                /// 채용 절차 확인 사항 (Process Step Check Item)
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  check,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          /// 필요 서류 배지 (Document Badge)
          /// labelSmall → labelMedium으로 변경하여 가독성 향상
          Container(
            padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              document,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4) 계약서 필수 항목 섹션
  Widget _buildContractItemsSection(
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
            icon: FontAwesomeIcons.lightFileSignature,
            number: '4)',
            title: '튜터 계약서에 반드시 넣어야 할 항목',
          ),
          SizedBox(height: sp.s16),
          Text(
            '계약서는 길게 쓰기보다 분쟁 가능성이 큰 항목을 짧고 명확하게 두는 것이 효과적입니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// 계약서 필수 항목 목록
          _buildContractItem(theme, scheme, sp, '업무', '영어 회화/독해/작문, 숙제 지도 범위'),
          _buildContractItem(theme, scheme, sp, '시간', '요일·시작/종료·지각 처리'),
          _buildContractItem(theme, scheme, sp, '장소', '거주지 내 수업 공간 지정'),
          _buildContractItem(theme, scheme, sp, '보수', '회당/월 단가, 지급일, 현금/이체'),
          _buildContractItem(theme, scheme, sp, '취소', '당일 취소 시 처리 기준'),
          _buildContractItem(theme, scheme, sp, '대체', '튜터 결근 시 보강/환불'),
          _buildContractItem(theme, scheme, sp, '자료', '교재·프린트 비용 부담'),
          _buildContractItem(theme, scheme, sp, '보안', '사진·영상 촬영 금지, 정보 보호'),
          _buildContractItem(theme, scheme, sp, '해지', '통보 기간, 즉시 해지 사유'),
          SizedBox(height: sp.s12),

          /// 아동 대상 수업 주의사항
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
                  FontAwesomeIcons.lightTriangleExclamation,
                  size: 14,
                  color: scheme.tertiary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// 아동 대상 수업 안내 (Child Lesson Info)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '아동 대상 수업은 수업 장소(거실 등 개방 공간), 보호자 동선, 촬영·녹음 정책을 '
                    '계약서 또는 가정 규칙으로 문서화하는 방식이 관리에 유리합니다.',
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

  /// 계약서 항목 빌더 (Contract Item Builder)
  /// - 패딩 및 스타일 개선
  Widget _buildContractItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String title,
    String description,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: sp.s12),
      padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s8),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: sp.s16),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5) 사회보험 등록 섹션
  Widget _buildSocialInsuranceSection(
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
            icon: FontAwesomeIcons.lightShieldCheck,
            number: '5)',
            title: '사회보험(SSS·PhilHealth·Pag-IBIG) 등록·납부',
          ),
          SizedBox(height: sp.s16),
          Text(
            "튜터가 가정에 상시적으로 고정 일정으로 출근하고, 가정이 업무 방식·시간을 실질적으로 "
            "지휘·감독하는 구조라면, 실무상 '고용 관계'로 판단될 여지가 커집니다. "
            '이 경우 카삼바하이 제도 기준에 따라 사회보험 등록·납부를 검토해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// KURS 안내
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
                      FontAwesomeIcons.lightFileLines,
                      size: 16,
                      color: scheme.primary,
                    ),
                    SizedBox(width: sp.s8),
                    Text(
                      '통합등록(KURS) 개요',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s8),

                /// KURS 안내 텍스트 (KURS Info Text)
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '가사근로자 및 고용주 등록은 Kasambahay Unified Registration System(KURS) 체계가 운영됩니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: sp.s12),

                /// 양식 목록
                _buildFormItem(theme, scheme, sp, 'PPS-HEUR1', '가정 고용주 등록'),
                _buildFormItem(theme, scheme, sp, 'PPS-HEUR2', '고용 보고/변경'),
                _buildFormItem(theme, scheme, sp, 'PPS-KUR', '근로자 등록'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 양식 항목 빌더 (Form Item Builder)
  Widget _buildFormItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
    String code,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: sp.s8),
      child: Row(
        children: [
          /// 양식 코드 배지 (Form Code Badge)
          /// labelSmall → labelMedium으로 변경하여 가독성 향상
          Container(
            width: 90,
            padding: EdgeInsets.symmetric(horizontal: sp.s8, vertical: sp.s4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: sp.s8),

          /// 양식 설명 텍스트 (Form Description Text)
          /// bodySmall → bodyMedium으로 변경하여 가독성 향상
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// 6) 월별 운영 관리 섹션
  Widget _buildMonthlyManagementSection(
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
            icon: FontAwesomeIcons.lightCalendarCheck,
            number: '6)',
            title: '월별 운영 관리 (분쟁 예방용)',
          ),
          SizedBox(height: sp.s16),
          Text(
            "가정 내 인력은 '관계'로 운영되기 쉬우나, 분쟁은 대부분 급여·시간·업무범위에서 발생합니다. "
            '최소한 아래 기록을 유지해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s20),

          /// 관리 항목 테이블
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  _buildTableRow(
                    theme,
                    scheme,
                    sp,
                    ['항목', '주기', '방식'],
                    isHeader: true,
                  ),
                  _buildTableRow(theme, scheme, sp, ['수업/근무 기록', '매회', '날짜·시간·내용']),
                  _buildTableRow(theme, scheme, sp, ['지급 기록', '매월', '영수증/이체증']),
                  _buildTableRow(theme, scheme, sp, ['변경 합의', '수시', '메시지→문서화']),
                  _buildTableRow(theme, scheme, sp, ['출입 기록', '매회', '방문 로그']),
                  _buildTableRow(theme, scheme, sp, ['불만·사고', '즉시', '사실관계 메모']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 7) 운전기사 고용 권장 섹션
  Widget _buildDriverRecommendationSection(
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
                    FontAwesomeIcons.lightCarSide,
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
                      /// 강조 배지 텍스트 (Emphasis Badge Text)
                      /// labelSmall → labelMedium으로 변경하여 가독성 향상
                      child: Text(
                        '강조',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: sp.s4),
                    /// 운전기사 섹션 타이틀 (Driver Section Title)
                    /// titleSmall → titleMedium으로 변경하여 가독성 향상
                    Text(
                      '7) 운전기사 고용은 맨파워 업체 경유 권장',
                      style: theme.textTheme.titleMedium?.copyWith(
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
                  '자녀 영어 교육을 위해 튜터를 고용하는 가정은 통상 이동(통학·학원·외부활동)이 함께 증가하며, '
                  '이때 운전기사 고용 수요가 동반되는 경우가 많습니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: sp.s12),

                /// 가정 운전기사 안내 (Family Driver Info)
                /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                Text(
                  '필리핀에서 가정 운전기사(family driver)는 법 적용이 단순하지 않으며, 임금·책임·분쟁 리스크가 '
                  '상대적으로 큽니다. 또한 교통사고는 민사·형사·보험 문제가 동시에 발생할 수 있습니다.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: sp.s12),
                Container(
                  padding: EdgeInsets.all(sp.s12),
                  decoration: BoxDecoration(
                    color: scheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '"운전기사는 반드시(필수로) 맨파워 업체(인가된 PEA 등)를 통해 고용하는 것을 권장합니다."',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: sp.s16),

          /// 맨파워 업체 선정 체크리스트
          Text(
            '맨파워 업체 선정 체크리스트',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),
          _buildCheckItem(theme, scheme, sp, text: '인가: DOLE 면허(라이선스) 보유'),
          _buildCheckItem(theme, scheme, sp, text: '문서: 파견/알선 계약서 제공'),
          _buildCheckItem(theme, scheme, sp, text: '검증: 신원·경력·레퍼런스 절차'),
          _buildCheckItem(theme, scheme, sp, text: '대체: 결근/부적합 시 교체 규정'),
          _buildCheckItem(theme, scheme, sp, text: '책임: 사고·분쟁 시 대응 창구'),
          _buildCheckItem(theme, scheme, sp, text: '비용: 수수료·급여 구조 투명성'),
        ],
      ),
    );
  }

  /// 8) 외국인 튜터 고용 섹션
  Widget _buildForeignTutorSection(
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
            icon: FontAwesomeIcons.lightPassport,
            number: '8)',
            title: '외국인(비필리핀 국적) 튜터 고용 시',
          ),
          SizedBox(height: sp.s16),
          Text(
            '외국인이 필리핀에서 임금·보수를 받고 근무하는 경우, 통상 이민국(예: 9G 취업비자 등) 및 '
            '노동부(DOLE) 취업허가(AEP 등) 체계를 검토해야 합니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s16),
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
                  /// 외국인 튜터 안내 (Foreign Tutor Info)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    "가정이 개인이라 하더라도, 실제로 '고용'이 성립하면 위 요건이 문제될 수 있습니다. "
                    '따라서 외국인 튜터는 신분(체류자격)과 취업 가능 범위를 서류로 확인한 뒤 계약해야 합니다.',
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

  /// 9) 분쟁 처리 섹션
  Widget _buildDisputeResolutionSection(
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
            number: '9)',
            title: '분쟁 발생 시 처리 (기본 흐름)',
          ),
          SizedBox(height: sp.s16),
          Text(
            '가사근로자 관련 분쟁은 DOLE 관할 사무소를 통한 조정·중재 절차가 규정되어 있으며, '
            '범죄(폭행·절도 등)는 별도로 사법기관 절차가 적용됩니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              height: 1.6,
            ),
          ),
          SizedBox(height: sp.s16),
          Container(
            padding: EdgeInsets.all(sp.s12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightLightbulb,
                  size: 14,
                  color: scheme.primary,
                ),
                SizedBox(width: sp.s8),
                Expanded(
                  /// 분쟁 처리 팁 (Dispute Resolution Tip)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  child: Text(
                    '실무에서는 기록(근무·급여·합의) 유무가 분쟁 결과에 큰 영향을 줍니다.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
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

  /// 참고 URL 섹션 빌더 (References Section Builder)
  Widget _buildReferencesSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final references = [
      {
        'title': 'RA 10361 Batas Kasambahay (IRR)',
        'description': '가사근로자법 시행규칙',
        'url': 'https://pcw.gov.ph/assets/files/2019/04/RA-10361_Batas-Kasambahay.pdf',
      },
      {
        'title': 'SSS Household Employer',
        'description': 'SSS 가정 고용주 안내',
        'url': 'https://www.sss.gov.ph/household-employer/',
      },
      {
        'title': 'SSS Kasambahay',
        'description': 'SSS 카삼바하이 안내',
        'url': 'https://www.sss.gov.ph/kasambahay/',
      },
      {
        'title': 'PhilHealth Employer Registration',
        'description': '카삼바하이 고용주 제출서류',
        'url': 'https://www.philhealth.gov.ph/partners/employers/registration.php',
      },
      {
        'title': 'NWPC Resolution No. 03 (2020)',
        'description': '가족 운전기사 관련 결의',
        'url': 'https://law.upd.edu.ph/wp-content/uploads/2020/11/NWPC-Resolution-No-03-Series-of-2020.pdf',
      },
      {
        'title': 'Bureau of Immigration 9G Visa',
        'description': '취업비자 안내',
        'url': 'https://immigration.gov.ph/pre-4-arranged-employment-visa-9g/',
      },
      {
        'title': 'NBI Clearance',
        'description': 'NBI Clearance 안내',
        'url': 'https://nbi.gov.ph/nbi-clearance-first-time-job-seekers/',
      },
    ];

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
          ...references.map((ref) => _buildReferenceItem(
                theme,
                scheme,
                sp,
                title: ref['title']!,
                description: ref['description']!,
                url: ref['url']!,
              )),
        ],
      ),
    );
  }

  /// 참고 URL 항목 빌더 (Reference Item Builder)
  /// - 패딩 및 아이콘 크기 증가
  /// - 텍스트 스타일 개선
  Widget _buildReferenceItem(
    ThemeData theme,
    ColorScheme scheme,
    AppSpacing sp, {
    required String title,
    required String description,
    required String url,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: sp.s12),
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(sp.s16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.lightArrowUpRightFromSquare,
                    size: 16,
                    color: scheme.primary,
                  ),
                ),
              ),
              SizedBox(width: sp.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(height: sp.s4),

                    /// 참고 URL 설명 (Reference URL Description)
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
              FaIcon(
                FontAwesomeIcons.lightChevronRight,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
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

  /// 튜터/맨파워 업체 찾는 방법 섹션 빌더 (Find Tutor Section Builder)
  ///
  /// 튜터를 찾는 4가지 방법과 주요 플랫폼 연락처, 체크리스트를 제공합니다.
  /// Provides 4 methods to find tutors, major platform contacts, and checklist.
  Widget _buildFindTutorSection(
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
          /// 섹션 타이틀 (Section Title)
          _buildSectionTitle(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightMagnifyingGlass,
            number: '',
            title: '튜터/맨파워 업체 찾는 방법',
            iconColor: scheme.tertiary,
          ),
          SizedBox(height: sp.s16),

          /// 맨파워 업체 권장 안내 (Manpower Agency Recommendation)
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
                        'DOLE 인가 맨파워 업체 권장',
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

                      /// DOLE 안내 텍스트 (DOLE Info Text)
                      /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                      Text(
                        '튜터 채용도 Kasambahay Law 적용 시 DOLE 등록 업체 이용이 안전합니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface.withValues(alpha: 0.8),
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
            '튜터 검색 방법',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),

          /// (1) 튜터 전문 플랫폼 (Tutor Platforms)
          _buildTutorSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightDesktop,
            title: '튜터 전문 플랫폼',
            content:
                'MyPrivateTutor.com.ph, TUTOROO, TutorHunt.ph 등 튜터 전문 플랫폼에서 과목별, 지역별 튜터 검색',
          ),
          SizedBox(height: sp.s8),

          /// (2) 구인 사이트 (Job Sites)
          _buildTutorSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightBriefcase,
            title: '구인 사이트',
            content:
                'Jobstreet, Indeed, Jooble에서 "private tutor", "home tutor" 검색. 요구 자격 및 경력 확인 필수',
          ),
          SizedBox(height: sp.s8),

          /// (3) Facebook 그룹 (Facebook Groups)
          _buildTutorSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.facebook,
            title: 'Facebook 그룹',
            content:
                '"Tutor hiring Philippines", "Home tutor Metro Manila" 검색. 개인거래는 신원 확인이 어려우므로 주의 필요',
            isWarning: true,
          ),
          SizedBox(height: sp.s8),

          /// (4) 맨파워 에이전시 (Manpower Agencies)
          _buildTutorSearchMethodCard(
            theme,
            scheme,
            sp,
            icon: FontAwesomeIcons.lightBuilding,
            title: '맨파워 에이전시',
            content:
                'DOLE 인가 맨파워 업체(MaidProvider.ph 등)에서 가정교사 포함 서비스 제공. 계약/보험 등 법적 지원 가능',
          ),
          SizedBox(height: sp.s20),

          /// 주요 튜터 플랫폼 (Major Tutor Platforms)
          Text(
            '주요 튜터 플랫폼',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s12),

          /// 플랫폼 카드들 (Platform Cards)
          _buildTutorAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'MyPrivateTutor.com.ph',
            feature: '필리핀 최대 튜터 플랫폼',
            description: '5만명+ 학생 이용, 48시간 내 튜터 매칭',
            url: 'https://www.myprivatetutor.com.ph/',
          ),
          SizedBox(height: sp.s8),
          _buildTutorAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'TUTOROO',
            feature: '네이티브 튜터 전문',
            description: '시간당 ₱500부터, 영어/한국어/일본어 등',
            url: 'https://www.tutoroo.co/english-tutor-manila',
          ),
          SizedBox(height: sp.s8),
          _buildTutorAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'Tutor Hunt Philippines',
            feature: 'DBS 인증 튜터',
            description: '157명+ 마닐라 기반 튜터, 시간당 PHP17부터',
            url: 'https://www.tutorhunt.ph/locations/manila/',
          ),
          SizedBox(height: sp.s8),
          _buildTutorAgencyCard(
            context,
            theme,
            scheme,
            sp,
            name: 'Apprentus',
            feature: '글로벌 튜터 플랫폼',
            description: '언어, 음악, 학과목 등 다양한 분야',
            url: 'https://www.apprentus.com/en/private-lessons/Manila-Philippines',
          ),
          SizedBox(height: sp.s20),

          /// 튜터 선정 체크리스트 (Tutor Selection Checklist)
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
                      '튜터 선정 체크리스트',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sp.s12),
                _buildTutorChecklistItem(
                    theme, scheme, sp, '학력 및 전공 확인 (교육학, 해당 과목 전공)'),
                SizedBox(height: sp.s4),
                _buildTutorChecklistItem(
                    theme, scheme, sp, 'NBI Clearance (무범죄 증명) 확인'),
                SizedBox(height: sp.s4),
                _buildTutorChecklistItem(
                    theme, scheme, sp, '교육 경력 및 레퍼런스 확인'),
                SizedBox(height: sp.s4),
                _buildTutorChecklistItem(
                    theme, scheme, sp, '과목별 수업 샘플/데모 요청'),
                SizedBox(height: sp.s4),
                _buildTutorChecklistItem(
                    theme, scheme, sp, '플랫폼 리뷰 및 평점 확인'),
                SizedBox(height: sp.s4),
                _buildTutorChecklistItem(
                    theme, scheme, sp, '수업 방식(대면/온라인) 및 시간당 요금 협의'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 튜터 검색 방법 카드 빌더 (Tutor Search Method Card Builder)
  Widget _buildTutorSearchMethodCard(
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

                /// 튜터 검색 방법 내용 (Tutor Search Method Content)
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

  /// 튜터 플랫폼 카드 빌더 (Tutor Agency Card Builder)
  Widget _buildTutorAgencyCard(
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
                  FontAwesomeIcons.lightChalkboardUser,
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

                  /// 튜터 플랫폼 특징 (Tutor Platform Feature)
                  /// bodySmall → bodyMedium으로 변경하여 가독성 향상
                  Text(
                    feature,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  /// 튜터 플랫폼 설명 (Tutor Platform Description)
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

  /// 튜터 체크리스트 항목 빌더 (Tutor Checklist Item Builder)
  Widget _buildTutorChecklistItem(
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
          /// 체크리스트 항목 텍스트 (Checklist Item Text)
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
