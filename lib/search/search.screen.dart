import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 검색 화면 - Google CSE WebView
/// philgo.com 검색 결과를 WebView로 표시하고,
/// 검색 결과 클릭 시 필고 URL이면 앱 내 PostViewScreen으로 이동
class SearchScreen extends StatefulWidget {
  static const String routeName = '/search';

  static Future push(BuildContext ctx, String searchTerm) =>
      ctx.push(routeName, extra: searchTerm);

  final String searchTerm;

  const SearchScreen({super.key, required this.searchTerm});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final WebViewController _controller;

  /// Google CSE 검색 페이지 URL
  static const String _baseSearchUrl =
      'https://philgo.com/page/search/cse.php';

  @override
  void initState() {
    super.initState();

    final encodedSearchTerm = Uri.encodeComponent(widget.searchTerm);
    final searchUrl =
        '$_baseSearchUrl?search_term=$encodedSearchTerm&view_mode=webview&device=mobile';

    debugPrint('SearchScreen: 검색어="${widget.searchTerm}", URL="$searchUrl"');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('SearchScreen: 링크 클릭 URL="$url"');

            final parsed = _parsePhilgoUrl(url);
            if (parsed != null && parsed.isPostView && parsed.idx != null) {
              debugPrint(
                'SearchScreen: 게시글 감지 idx=${parsed.idx}, postId=${parsed.postId}',
              );

              final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
              final post = Post(
                idx: parsed.idx!,
                idxMember: 0,
                postId: parsed.postId ?? '',
                subject: '',
                content: '',
                stamp: now,
                stampUpdate: now,
                depth: 0,
                noOfComment: 0,
                noOfView: 0,
                good: 0,
                category: parsed.category ?? '',
                earnedPoint: 0,
                secret: '',
                checked: '',
                blind: '',
                hasImage: '',
                hasVideo: '',
              );

              PostViewScreen.push(context, post);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 120,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, color: color.onSurface, size: 28),
                Text(
                  // "Back"
                  '돌아가기'.tr(),
                  style: text.bodyMedium?.copyWith(color: color.onSurface),
                ),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: color.scrim,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: WebViewWidget(
        controller: _controller,
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
        },
      ),
    );
  }
}

/// PhilGo URL 파싱 결과
typedef _PhilgoUrlResult = ({
  String? postId,
  int? idx,
  String? category,
  bool isPostView,
});

/// PhilGo URL을 파싱하여 게시글 정보 추출
_PhilgoUrlResult? _parsePhilgoUrl(String url) {
  try {
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;
    final postId = queryParams['post_id'];

    int? idx;
    final idxStr = queryParams['idx'];
    if (idxStr != null) {
      idx = int.tryParse(idxStr);
    } else if (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) {
      idx = int.tryParse(uri.query);
    }

    final category = queryParams['category'];
    final path = uri.path;

    final isPostView = path.contains('/post/view.php') ||
        (uri.query.isNotEmpty && RegExp(r'^\d+$').hasMatch(uri.query)) ||
        (queryParams['module'] == 'post' &&
            queryParams['action'] == 'view' &&
            idx != null);

    return (
      postId: postId,
      idx: idx,
      category: category,
      isPostView: isPostView,
    );
  } catch (e) {
    return null;
  }
}
