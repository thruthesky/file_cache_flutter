import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 해산물 정보 화면 (Seafood Screen)
///
/// 필리핀 해산물 관련 정보를 제공합니다.
/// Provides information about seafood in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// SeafoodScreen.push(context);
/// ```
class SeafoodScreen extends StatelessWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Seafood';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const SeafoodScreen({super.key});

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
              FontAwesomeIcons.lightShrimp,
              size: 20,
              color: scheme.primary,
            ),
            SizedBox(width: sp.s8),
            Text(
              l10n.entertainmentSeafood,
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 아이콘 (Icon)
            FaIcon(
              FontAwesomeIcons.lightShrimp,
              size: 64,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
            SizedBox(height: sp.s16),

            /// 준비 중 메시지 (Coming Soon Message)
            Text(
              l10n.comingSoon,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
