import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/list/widgets/empty_post_list.dart';
import 'package:philgo/post/list/widgets/post.list.tile.dart';
import 'package:philgo/post/list/widgets/post_list_error_indicator.dart';
import 'package:philgo/post/list/widgets/post_list_header_categories.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  /// 현재 선택된 카테고리 인덱스
  int _selectedIndex = 0;

  /// 헤더 표시 여부 (스크롤 시 숨김)
  bool _showHeader = true;

  static const _headerHideThreshold = 48.0;

  /// 페이지당 게시글 수
  static const _pageSize = 20;

  /// 무한 스크롤 페이지네이션 컨트롤러
  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Post>(
      getNextPageKey: (state) {
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 0;
        return keys.last + _pageSize;
      },
      fetchPage: _fetchPage,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  /// 게시글 페이지 로드
  Future<List<Post>> _fetchPage(int offset) async {
    final nav = AppNavigationState.of(context);
    final result = await PostService.list(
      postId: nav.selectedPostId,
      category: nav.selectedCategory,
      limit: _pageSize,
      offset: offset,
    );
    return result.posts;
  }

  /// 카테고리 변경 시 목록 리프레시
  void _onCategoryTap(int index) {
    if (index == _selectedIndex) return;
    final (postId, category, _) = forumCategories[index];
    AppNavigationState.of(context).setSelectedForum(postId, category);
  }

  /// 전역 선택 포럼을 현재 화면 상태에 반영
  void _applySelectedForum(String postId, String? category) {
    final index = forumCategories.indexWhere(
      (item) => item.$1 == postId && item.$2 == category,
    );
    if (index < 0 || index == _selectedIndex) return;

    _selectedIndex = index;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pagingController.refresh();
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      final offset = notification.metrics.pixels;
      if (delta > 0 && offset > _headerHideThreshold) {
        if (_showHeader) setState(() => _showHeader = false);
      } else if (delta < 0) {
        if (!_showHeader) setState(() => _showHeader = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (postId, category) = context
        .select<AppNavigationState, (String, String?)>(
          (state) => (state.selectedPostId, state.selectedCategory),
        );
    _applySelectedForum(postId, category);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            ClipRect(
              child: AnimatedAlign(
                alignment: Alignment.topCenter,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                heightFactor: _showHeader ? 1.0 : 0.0,
                child: PostListHeaderCategories(
                  categories: forumCategories,
                  selectedIndex: _selectedIndex,
                  onCategoryTap: _onCategoryTap,
                ),
              ),
            ),
            Container(height: 1, color: scheme.outlineVariant),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: _handleScrollNotification,
                child: _buildPostList(theme, scheme),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPostCreate,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        child: const FaIcon(FontAwesomeIcons.lightPen, size: 20),
      ),
    );
  }

  /// 게시글 무한 스크롤 목록
  Widget _buildPostList(ThemeData theme, ColorScheme scheme) {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedListView<int, Post>.separated(
          state: state,
          fetchNextPage: fetchNextPage,
          separatorBuilder: (_, _) => const SizedBox.shrink(),
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => PostListTile(
              post: post,
              theme: theme,
              scheme: scheme,
              onTap: () => _openPostView(post),
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            noItemsFoundIndicatorBuilder: (_) => EmptyPostList(scheme: scheme),
            firstPageErrorIndicatorBuilder: (context) => PostListErrorIndicator(
              scheme: scheme,
              onRetry: () => _pagingController.refresh(),
            ),
          ),
        );
      },
    );
  }

  /// 게시글 작성 화면 열기
  Future<void> _openPostCreate() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다')));
      return;
    }

    final nav = AppNavigationState.of(context);
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => PostCreateScreen(
          postId: nav.selectedPostId,
          category: nav.selectedCategory,
        ),
      ),
    );

    if (result is Post && mounted) {
      // 목록 새로고침 (새 게시글이 서버에서 첫 번째로 반환됨)
      _pagingController.refresh();
      // 새 게시글 상세 화면 열기
      _openPostView(result);
    }
  }

  /// 게시글 상세 화면 열기
  Future<void> _openPostView(Post post) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => PostViewScreen(post: post)),
    );

    // 삭제 또는 수정 시 목록 새로고침
    if ((result == 'deleted' || result is Post) && mounted) {
      _pagingController.refresh();
    }
  }
}
