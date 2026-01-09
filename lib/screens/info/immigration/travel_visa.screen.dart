import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/data/post_content_mapping.data.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/post_content/post_content_viewer.dart';

/// 여행비자 정보 화면 (Travel Visa Screen)
///
/// 필리핀 여행비자(관광비자) 정보를 제공합니다.
/// Provides information about Philippine travel/tourist visa.
///
/// ### 사용법 (Usage):
/// ```dart
/// TravelVisaScreen.push(context);
/// ```
class TravelVisaScreen extends StatefulWidget {
  /// 라우트 이름 (Route name)
  static const String routeName = '/TravelVisa';

  /// push 네비게이션 함수 (Push navigation function)
  static Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);

  /// go 네비게이션 함수 (Go navigation function)
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const TravelVisaScreen({super.key});

  @override
  State<TravelVisaScreen> createState() => _TravelVisaScreenState();
}

class _TravelVisaScreenState extends State<TravelVisaScreen> {
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
          l10n.immigrationTravelVisa,
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
        postId: PostContentMapping.travelVisa,
        showImages: true,
      ),
    );
  }
}
