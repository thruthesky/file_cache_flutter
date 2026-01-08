import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 고속 버스 정보 화면 (Express Bus Screen)
///
/// 필리핀 고속 버스 이용 정보를 제공합니다.
/// Provides information about express bus service in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// ExpressBusScreen.push(context);
/// ```
class ExpressBusScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/ExpressBus';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ExpressBusScreen({super.key});

  @override
  State<ExpressBusScreen> createState() => _ExpressBusScreenState();
}

class _ExpressBusScreenState extends State<ExpressBusScreen> {
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
          l10n.transportationExpressBus,
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
