import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/point/point_advertisement.model.dart';
import 'package:philgo/point/widgets/point_advertisements.dart';
import 'package:philgo/post/list/widgets/post_list_masonry_view.dart';
import 'package:philgo/post/list/widgets/post_list_view.dart';
import 'package:philgo/post/list/widgets/forum_notification_dialog.dart';
import 'package:philgo/post/list/widgets/post_list_header_categories.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/search/search.screen.dart';
import 'package:philgo/search/search_dialog.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.service.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  /// 포인트 광고 목록 (1페이지에서만 로드)
  List<PointAdvertisement> _pointAdvertisements = [];

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
    // 1페이지일 때 포인트 광고 목록 업데이트
    if (page == 1 && mounted) {
      setState(() {
        _pointAdvertisements = result.pointAdvertisements;
      });
    }
    if (page > 1 && result.posts.isEmpty) return [];
    return result.posts;
  }

  void _onCategoryTap(int index) {
    if (index == _selectedIndex) return;
    final (postId, category, _) = Config.forumCategories[index];
    AppNavigationState.of(context).setSelectedForum(postId, category);
  }

  void _applySelectedForum(String postId, String? category) {
    final index = Config.forumCategories.indexWhere(
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

  /// 검색 다이얼로그 표시 → 검색어 입력 → SearchScreen으로 이동
  void _openSearch(BuildContext context) async {
    final searchTerm = await SearchDialog.show(context);
    if (searchTerm != null && searchTerm.isNotEmpty && mounted) {
      SearchScreen.push(context, searchTerm);
    }
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
    final isMasonryLayout = Config.masonryCategories.contains(
      masonryCategoryOrPostId,
    );

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
                  categories: Config.forumCategories,
                  selectedIndex: _selectedIndex,
                  onCategoryTap: _onCategoryTap,
                  onSearchTap: () => _openSearch(context),
                  onNotificationTap: () =>
                      ForumNotificationDialog.show(context),
                ),
              ),
            ),
            Container(height: 1, color: scheme.outlineVariant),
            // 포인트 광고 (일반 레이아웃에서만 표시)
            if (_pointAdvertisements.isNotEmpty && !isMasonryLayout)
              PointAdvertisements(
                advertisements: _pointAdvertisements,
                onTap: _onAdTap,
              ),
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
      // FAB는 AppScreen에서 통합 관리
    );
  }

  /// 포인트 광고 클릭 시 글 보기 화면으로 이동
  void _onAdTap(PointAdvertisement ad) {
    // 외부 링크가 있으면 브라우저로 열기
    if (ad.link.isNotEmpty) {
      final uri = Uri.tryParse(ad.link);
      if (uri != null) launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    // 내부 글이면 PostViewScreen으로 이동
    PostService.get(ad.idx).then((post) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostViewScreen(post: post)),
        );
      }
    });
  }

  Future<void> _openPostView(Post post) async {
    // 실시간 Firebase 차단 상태 확인 (서버 플래그 대신)
    final isBlocked = post.userFirebaseUid.isNotEmpty
        ? UserService.instance.blockedUsersStream.value.contains(
            post.userFirebaseUid,
          )
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
