import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/l10n/app_localizations.dart';

/// 에어비앤비 정보 화면 (Airbnb Screen)
///
/// 필리핀 에어비앤비 이용 정보를 제공합니다.
/// Provides information about Airbnb in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// AirbnbScreen.push(context);
/// ```
class AirbnbScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/Airbnb';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const AirbnbScreen({super.key});

  @override
  State<AirbnbScreen> createState() => _AirbnbScreenState();
}

class _AirbnbScreenState extends State<AirbnbScreen> {
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
          l10n.housingAirbnb,
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
