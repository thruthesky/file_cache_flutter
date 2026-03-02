import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart' show Lo;
import 'package:philgo/screens/event/qr_scanner.screen.dart';

/// 업소 이벤트 화면 (Company Event Screen)
///
/// 필고 업소록의 업소를 방문하여 QR 코드를 스캔하면
/// 랜덤 포인트가 지급되는 "삼단콤보" 이벤트 안내 화면.
/// 3단계 포인트 획득 방법을 컴팩트하게 표시하고,
/// QR 코드 스캔 버튼과 이벤트 응모 안내를 제공한다.
class CompanyEventScreen extends StatelessWidget {
  static const String routeName = '/company-event';

  /// 화면 이동 헬퍼
  static Future<dynamic> push(BuildContext context) =>
      context.push(routeName);

  const CompanyEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = Lo.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.quickMenuCompanyEvent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 안내 문구: 업소 방문 및 QR 코드 요청 안내
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightCircleInfo,
                    size: 20,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.companyEventGuide,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// 헤더 섹션: 삼단콤보 이벤트 제목 + 부제목
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightStar,
                    size: 48,
                    color: scheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.companyEventInfoTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.companyEventInfoSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// 3단계 컴팩트 스텝 (한 컨테이너 안에 3줄)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildCompactStep(
                    theme: theme,
                    scheme: scheme,
                    icon: FontAwesomeIcons.lightQrcode,
                    title: l10n.companyEventStep1Title,
                    desc: l10n.companyEventStep1Desc,
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                  _buildCompactStep(
                    theme: theme,
                    scheme: scheme,
                    icon: FontAwesomeIcons.lightRotate,
                    title: l10n.companyEventStep2Title,
                    desc: l10n.companyEventStep2Desc,
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: scheme.outlineVariant,
                  ),
                  _buildCompactStep(
                    theme: theme,
                    scheme: scheme,
                    icon: FontAwesomeIcons.lightPenToSquare,
                    title: l10n.companyEventStep3Title,
                    desc: l10n.companyEventStep3Desc,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),

            /// QR 코드 스캔하기 버튼
            FilledButton.icon(
              onPressed: () => QrScannerScreen.push(context),
              icon: const FaIcon(FontAwesomeIcons.lightQrcode, size: 20),
              label: Text(l10n.companyEventScanButton),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  /// 컴팩트 스텝 한 줄: 아이콘 + 제목 + 설명
  Widget _buildCompactStep({
    required ThemeData theme,
    required ColorScheme scheme,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          FaIcon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
