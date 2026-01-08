import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 팔라완 여행 정보 화면 (Palawan Travel Screen)
///
/// 필리핀 팔라완 여행 정보를 제공합니다.
/// Provides travel information about Palawan in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// PalawanScreen.push(context);
/// ```
class PalawanScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Palawan';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const PalawanScreen({super.key});

  @override
  State<PalawanScreen> createState() => _PalawanScreenState();
}

class _PalawanScreenState extends State<PalawanScreen> {
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
          l10n.travelDestinationPalawan,
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
