import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// e트래블 정보 화면 (E-Travel Screen)
///
/// 필리핀 전자여행허가(e-Travel) 정보를 제공합니다.
/// Provides information about Philippine e-Travel registration.
///
/// ### 사용법 (Usage):
/// ```dart
/// ETravelScreen.push(context);
/// ```
class ETravelScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/ETravel';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const ETravelScreen({super.key});

  @override
  State<ETravelScreen> createState() => _ETravelScreenState();
}

class _ETravelScreenState extends State<ETravelScreen> {
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
          l10n.immigrationETravel,
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
