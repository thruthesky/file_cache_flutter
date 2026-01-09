import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/post_content_mapping.data.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/post_content/post_content_viewer.dart';

/// 그랩 택시 정보 화면 (Grab Taxi Screen)
///
/// 필리핀 그랩 택시 이용 정보를 제공합니다.
/// Provides information about Grab taxi service in the Philippines.
///
/// ### 사용법 (Usage):
/// ```dart
/// GrabTaxiScreen.push(context);
/// ```
class GrabTaxiScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/GrabTaxi';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const GrabTaxiScreen({super.key});

  @override
  State<GrabTaxiScreen> createState() => _GrabTaxiScreenState();
}

class _GrabTaxiScreenState extends State<GrabTaxiScreen> {
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
          l10n.transportationGrabTaxi,
          style: theme.textTheme.titleLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      /// PostContentViewer를 사용하여 필고 게시글 내용 표시
      /// Display PhilGo forum post content using PostContentViewer
      body: const PostContentViewer(
        postId: PostContentMapping.grabTaxi,
        showImages: true,
      ),
    );
  }
}
