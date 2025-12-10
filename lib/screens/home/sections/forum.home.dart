import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:philgo/extensions/text_theme.extension.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo/models/forum_selection.dart';
import 'package:philgo/widgets/empty.post.list.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/headers/forum_header.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:philgo/widgets/post/post.card.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:provider/provider.dart';

/// 게시판 홈 화면 (Forum Home Screen)
///
/// 로컬 상태로 현재 선택된 카테고리를 관리합니다.
/// Manages currently selected category with local state.
///
/// 딥링크 처리:
/// - NavigationState.initialPostId와 initialCategory가 설정되면
/// - 해당 카테고리로 자동 이동합니다.
class ForumHome extends StatefulWidget {
  const ForumHome({super.key});

  @override
  State<ForumHome> createState() => _ForumHomeState();
}

class _ForumHomeState extends State<ForumHome> {
  /// 현재 선택된 카테고리 상태 (메인 + 서브 카테고리)
  /// Currently selected category state (main + subcategory)
  late ForumSelection _currentSelection;

  /// 마지막으로 처리한 딥링크 선택 상태 (중복 처리 방지)
  /// Last processed deep link selection (prevent duplicate processing)
  ForumSelection? _lastProcessedDeepLink;

  /// 리스트 뷰용 컨트롤러 (비그리드 레이아웃에 사용)
  /// Controller for list view (used for non-grid layouts)
  final PostListController _listViewController = PostListController();

  /// 그리드 뷰용 컨트롤러 (buyandsell 같은 그리드 레이아웃에 사용)
  /// Controller for grid view (used for grid layouts like buyandsell)
  final PostListController _gridViewController = PostListController();

  /// 헤더 표시 여부 (스크롤에 따라 변경)
  /// Whether to show header (changes based on scroll)
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();

    /// 기본값: 첫 번째 메인 카테고리 (서브 카테고리 없음)
    /// Default: first major category (no subcategory)
    _currentSelection = ForumSelection(
      postId: PhilgoCategory.majorCategories(includeTemp: kDebugMode).first,
    );
  }

  /// 카테고리 변경 핸들러 (ForumHeader에서 콜백으로 사용)
  /// Category change handler (used as callback from ForumHeader)
  void _onCategoryChanged(String postId, String? category) {
    final newSelection = ForumSelection(postId: postId, category: category);

    if (_currentSelection == newSelection) {
      return;
    }

    setState(() {
      _currentSelection = newSelection;
    });
  }

  /// 딥링크 데이터 처리 (NavigationState에서 전달된 카테고리로 이동)
  /// Process deep link data (navigate to category from NavigationState)
  ///
  /// 빌드 중에 호출되므로 setState 대신 직접 상태 변수를 업데이트합니다.
  /// Called during build, so update state variables directly instead of setState.
  void _processDeepLinkIfNeeded(NavigationState navState) {
    /// 딥링크 데이터가 없으면 무시
    /// Ignore if no deep link data
    if (navState.initialPostId == null) {
      return;
    }

    /// 딥링크로 전달된 선택 상태 생성
    /// Create selection from deep link data
    final deepLinkSelection = ForumSelection(
      postId: navState.initialPostId!,
      category: navState.initialCategory,
    );

    /// 이미 처리한 딥링크면 무시 (중복 처리 방지)
    /// Ignore if already processed (prevent duplicate processing)
    if (deepLinkSelection == _lastProcessedDeepLink) {
      return;
    }

    debugLog('ForumHome: 딥링크 처리 - $deepLinkSelection');
    _lastProcessedDeepLink = deepLinkSelection;

    /// 현재 선택 상태 업데이트 (빌드 중이므로 직접 업데이트)
    /// Update current selection (direct update since we're in build)
    _currentSelection = deepLinkSelection;

    /// 딥링크 데이터 클리어 (다음 네비게이션에 영향 없도록)
    /// Clear deep link data (to avoid affecting next navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearDeepLinkData();
    });
  }

  /// NavigationState의 딥링크 데이터 클리어
  /// Clear deep link data from NavigationState
  void _clearDeepLinkData() {
    final navState = NavigationState.of(context, listen: false);
    navState.initialPostId = null;
    navState.initialCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// Selector를 사용하여 딥링크 데이터 변경 감지
    /// Use Selector to detect deep link data changes
    ///
    /// (initialPostId, initialCategory) 튜플을 감시하여
    /// 둘 중 하나라도 변경되면 리빌드됩니다.
    return Selector<NavigationState, (String?, String?)>(
      selector: (context, state) =>
          (state.initialPostId, state.initialCategory),
      builder: (context, deepLinkData, child) {
        /// 딥링크 처리: NavigationState에서 카테고리 데이터가 있으면 적용
        /// Process deep link: apply category data from NavigationState if present
        final navState = NavigationState.of(context, listen: false);
        _processDeepLinkIfNeeded(navState);

        return NotificationListener<ScrollNotification>(
          onNotification: _handleScrollNotification,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 헤더 영역 (스크롤 시 숨김/표시 애니메이션)
              /// Header area (hide/show animation on scroll)
              _buildAnimatedHeader(scheme),

              /// 본문: 게시글 목록
              /// Body: post list
              _buildPostList(),
            ],
          ),
        );
      },
    );
  }

  /// 애니메이션 헤더 빌드 (스크롤 시 숨김/표시)
  /// Build animated header (hide/show on scroll)
  Widget _buildAnimatedHeader(ColorScheme scheme) {
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: _showHeader ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              bottom: BorderSide(color: scheme.outlineVariant, width: 1.0),
            ),
          ),
          child: ForumHeader(
            selectedPostId: _currentSelection.postId,
            selectedCategory: _currentSelection.category,
            onCategorySelected: _onCategoryChanged,
            onCreatePost: _showPostCreateDialog,
          ),
        ),
      ),
    );
  }

  /// 게시글 목록 빌드
  /// Build post list
  Widget _buildPostList() {
    final isBuyAndSell = _currentSelection.postId == 'buyandsell';

    return Expanded(
      child: Theme(
        data: context.postTitleTheme,
        child: PostListView(
          listViewController: isBuyAndSell ? null : _listViewController,
          gridViewController: isBuyAndSell ? _gridViewController : null,
          postId: _currentSelection.postId,
          category: _currentSelection.category,
          enableHeroTransition: true,
          gridColumns: isBuyAndSell ? 2 : null,
          tileBuilder: isBuyAndSell
              ? (post, onTap) => PostCard(post: post, onTap: onTap)
              : null,
          onTap: _onPostTapped,
          noItemsFoundIndicatorBuilder: (context) {
            return const Center(child: EmptyPostList());
          },
        ),
      ),
    );
  }

  /// 글쓰기 다이얼로그 표시
  /// Show post create dialog
  void _showPostCreateDialog() {
    showPostCreateDialog(
      context,
      postId: _currentSelection.postId,
      category: _currentSelection.category,
      onSubmitted: (post) {
        _listViewController.refresh();
        _gridViewController.refresh();
      },
    );
  }

  /// 게시물 탭 시 상세 화면으로 이동
  /// Navigate to post detail screen when tapped
  Future<void> _onPostTapped(Post post) async {
    await PostViewScreen.push(context, post);

    /// 돌아왔을 때 UI 업데이트 (수정된 내용 반영)
    /// Update UI when returned (reflect edited content)
    if (mounted) {
      setState(() {});
    }
  }

  /// 스크롤 알림 처리 - 스크롤 방향에 따라 헤더 표시/숨김
  /// Handle scroll notification - show/hide header based on scroll direction
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final currentOffset = notification.metrics.pixels;
      final delta = notification.scrollDelta ?? 0;

      /// 스크롤 업 (위로 스와이프) - 헤더 숨기기
      /// Scroll up (swipe up) - hide header
      if (delta > 0 && currentOffset > 50) {
        if (_showHeader) {
          setState(() => _showHeader = false);
        }
      }
      /// 스크롤 다운 (아래로 스와이프) - 헤더 표시
      /// Scroll down (swipe down) - show header
      else if (delta < 0) {
        if (!_showHeader) {
          setState(() => _showHeader = true);
        }
      }
    }

    return false;
  }

  /// 새 글 생성 후 목록 새로고침 (외부에서 호출용)
  /// Refresh list after new post created (for external call)
  void onNewPostCreated(Post newPost) {
    _listViewController.refresh();
    _gridViewController.refresh();
  }
}
