import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 워킹비자 정보 화면 (Working Visa Screen)
///
/// 필리핀 워킹비자(취업비자) 정보를 제공합니다.
/// Provides information about Philippine working visa.
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
      body: const SizedBox.shrink(),
    );
  }
}
