import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 검색 화면 (Search Screen)
/// Google Custom Search Engine (CSE)을 WebView로 표시
/// 검색어를 받아서 CSE 페이지에 전달
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
    final encodedSearchTerm = Uri.encodeComponent(widget.searchTerm);
    final searchUrl = '$_baseSearchUrl?search_term=$encodedSearchTerm';

    debugPrint('🔍 SearchScreen: 검색어="${widget.searchTerm}"');
    debugPrint('🔍 SearchScreen: URL="$searchUrl"');

    // WebViewController 초기화
    // JavaScript 필수 - CSE 동작에 필요
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
