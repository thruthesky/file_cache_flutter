import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 올티가스 정보 화면 (Ortigas Screen)
///
/// 필리핀 올티가스 거주 정보를 제공합니다.
/// Provides information about living in Ortigas in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// OrtigasScreen.push(context);
/// ```
class OrtigasScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Ortigas';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const OrtigasScreen({super.key});

  @override
  State<OrtigasScreen> createState() => _OrtigasScreenState();
}

class _OrtigasScreenState extends State<OrtigasScreen> {
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
          l10n.residenceOrtigas,
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
