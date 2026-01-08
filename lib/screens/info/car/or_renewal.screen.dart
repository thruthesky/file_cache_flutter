import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/post_content_mapping.data.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/post_content/post_content_viewer.dart';

/// OR 리뉴얼 정보 화면 (OR Renewal Screen)
///
/// 필리핀 OR(Official Receipt) 리뉴얼 정보를 제공합니다.
/// Provides information about OR renewal in the Philippines.
///
/// 필고 게시글에서 내용을 가져와 표시합니다.
/// Fetches and displays content from PhilGo forum post.
///
/// ### 사용법 (Usage):
/// ```dart
/// OrRenewalScreen.push(context);
/// ```
class OrRenewalScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/OrRenewal';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const OrRenewalScreen({super.key});

  @override
  State<OrRenewalScreen> createState() => _OrRenewalScreenState();
}

class _OrRenewalScreenState extends State<OrRenewalScreen> {
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
          l10n.carOrRenewal,
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
        postId: PostContentMapping.orRenewal,
        showImages: true,
      ),
    );
  }
}
