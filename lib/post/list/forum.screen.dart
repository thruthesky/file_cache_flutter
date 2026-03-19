import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/list/widgets/post_list_masonry_view.dart';
import 'package:philgo/post/list/widgets/post_list_view.dart';
import 'package:philgo/post/list/widgets/post_list_header_categories.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:provider/provider.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  int _selectedIndex = 0;
  bool _showHeader = true;
  static const _headerHideThreshold = 48.0;
  static const _pageSize = 20;

  late final PagingController<int, Post> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Post>(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        final keys = state.keys;
        if (keys == null || keys.isEmpty) return 1;
        return keys.last + 1;
      },
      fetchPage: _fetchPage,
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<List<Post>> _fetchPage(int page) async {
    final nav = AppNavigationState.of(context);
    final result = await PostService.list(
      postId: nav.selectedPostId,
      category: nav.selectedCategory,
      limit: _pageSize,
      page: page,
    );
    if (page > 1 && result.posts.isEmpty) return [];
    return result.posts;
  }

  void _onCategoryTap(int index) {
    if (index == _selectedIndex) return;
    final (postId, category, _) = forumCategories[index];
    AppNavigationState.of(context).setSelectedForum(postId, category);
  }

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

    // PHP Config::masonryCategories()와 동일한 로직: category ?? postId 로 판별
    final masonryCategoryOrPostId = category ?? postId;
    final isMasonryLayout = masonryCategories.contains(masonryCategoryOrPostId);

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
                child: isMasonryLayout
                    ? PostListMasonryView(
                        pagingController: _pagingController,
                        onPostTap: _openPostView,
                      )
                    : PostListView(
                        pagingController: _pagingController,
                        theme: theme,
                        scheme: scheme,
                        onPostTap: _openPostView,
                        onRetry: () => _pagingController.refresh(),
                      ),
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
      _pagingController.refresh();
      _openPostView(result);
    }
  }

  Future<void> _openPostView(Post post) async {
    // 실시간 Firebase 차단 상태 확인 (서버 플래그 대신)
    final isBlocked = post.userFirebaseUid.isNotEmpty
        ? UserService.instance.blockedUsersStream.value
              .contains(post.userFirebaseUid)
        : post.blocked;
    if (isBlocked) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('차단된 사용자'),
          content: const Text('차단된 사용자입니다. 차단을 해제하고 글을 보시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('차단 해제'),
            ),
          ],
        ),
      );
      if (confirm != true || !mounted) return;

      try {
        await toggleBlockUserByIdx(post.idxMember);
      } catch (e) {
        if (mounted) showErrorSnackBar(context, '$e');
        return;
      }
      // 차단 해제 후 목록 새로고침하여 정상 타일로 표시
      if (!mounted) return;
      _pagingController.refresh();
      return;
    }

    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(builder: (_) => PostViewScreen(post: post)),
    );

    if ((result == 'deleted' || result == 'blocked' || result is Post) &&
        mounted) {
      _pagingController.refresh();
    }
  }
}
