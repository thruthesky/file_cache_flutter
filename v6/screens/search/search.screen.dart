import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// 검색 화면 (Search Screen)
/// Google Custom Search Engine (CSE)을 WebView로 표시
/// 검색어를 받아서 CSE 페이지에 전달
///
/// 웹뷰에서 링크 클릭 시:
/// - philgo.com 게시글 URL인 경우 → PostViewScreen으로 이동
/// - 그 외의 경우 → 웹뷰 내에서 로딩
class SearchScreen extends StatefulWidget {
  /// 라우트 이름
  static const String routeName = '/search';

  /// 검색어
  final String searchTerm;

  /// 화면 이동 메서드 - 검색어 파라미터 필수
  /// SearchDialog에서 입력받은 검색어를 전달
  static Function(BuildContext ctx, String searchTerm) push =
      (ctx, searchTerm) => ctx.push(routeName, extra: searchTerm);

  const SearchScreen({super.key, required this.searchTerm});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// WebView 컨트롤러
  late final WebViewController _controller;

  /// Google CSE 검색 페이지 기본 URL
  /// CSE ID: d37786943cf92484d
  /// philgo.com 도메인 전체를 검색 대상으로 설정
  static const String _baseSearchUrl =
      'https://philgo.com/page/search/cse.php';

  @override
  void initState() {
    super.initState();

    /// 검색어를 URL 인코딩하여 검색 URL 생성
    /// CSE 페이지에서 JavaScript로 해시 URL로 변환
    ///
    /// URL 파라미터:
    /// - search_term: 검색어 (URL 인코딩)
    /// - view_mode=webview: 웹뷰 전용 모드 (불필요한 UI 숨김)
    /// - device=mobile: 모바일 최적화 레이아웃
    final encodedSearchTerm = Uri.encodeComponent(widget.searchTerm);
    final searchUrl = '$_baseSearchUrl?search_term=$encodedSearchTerm&view_mode=webview&device=mobile';

    debugPrint('🔍 SearchScreen: 검색어="${widget.searchTerm}"');
    debugPrint('🔍 SearchScreen: URL="$searchUrl"');

    // WebViewController 초기화
    // JavaScript 필수 - CSE 동작에 필요
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          /// 링크 클릭 시 URL 검사하여 게시글이면 앱 내 화면으로 이동
          /// Intercept link clicks and navigate to app screen for post URLs
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('🔍 SearchScreen: 링크 클릭 감지 URL="$url"');

            /// philgo URL 파싱
            /// Parse philgo URL to check if it's a post view
            final parsed = parsePhilgoUrl(url);

            /// 게시글 상세 보기 URL인 경우 앱 내 PostViewScreen으로 이동
            /// If it's a post view URL, navigate to PostViewScreen
            if (parsed != null && parsed.isPostView && parsed.idx != null) {
              debugPrint('🔍 SearchScreen: 게시글 감지 idx=${parsed.idx}, postId=${parsed.postId}');

              /// Post 객체 생성 (최소 필수 정보만 포함)
              /// Create Post object with minimum required info
              /// PostViewScreen에서 idx로 전체 게시글 정보를 로드함
              /// PostViewScreen loads full post info using idx
              final post = Post.fromJson({
                'idx': parsed.idx,
                'post_id': parsed.postId ?? '',
                'category': parsed.category ?? '',
              });

              /// PostViewScreen으로 이동
              /// Navigate to PostViewScreen
              PostViewScreen.push(context, post);

              /// 웹뷰 내 네비게이션 차단 (앱 내 화면으로 이동했으므로)
              /// Prevent webview navigation (already navigated to app screen)
              return NavigationDecision.prevent;
            }

            /// 그 외의 URL은 웹뷰 내에서 로딩
            /// For other URLs, load within webview
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        /// "< 돌아가기" - leading 커스터마이즈하여 터치 영역 확대
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
                Icon(
                  Icons.chevron_left,
                  color: scheme.onSurface,
                  size: 28,
                ),
                Text(
                  '돌아가기',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        title: const SizedBox.shrink(),
        elevation: 0,

        /// 오른쪽 액션 버튼 - 원형 닫기 버튼 (surfaceDim 배경)
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceDim,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: scheme.scrim,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      /// WebView - Google CSE 검색 결과 표시
      body: WebViewWidget(controller: _controller),
    );
  }
}
