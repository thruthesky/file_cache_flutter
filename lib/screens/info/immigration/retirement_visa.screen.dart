import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

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
      body: const SizedBox.shrink(),
    );
  }
}
