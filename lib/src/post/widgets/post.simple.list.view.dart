import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Simple List View for Posts (간단한 게시글 리스트 뷰)
/// Displays posts in a vertical list layout with pagination
/// 페이지네이션을 사용하여 수직 리스트 레이아웃으로 게시글 표시
///
/// Cache behavior (캐시 동작):
/// 1. On init, cached first page is loaded and displayed immediately
///    (초기화 시 캐시된 첫 페이지를 즉시 로드하여 표시)
/// 2. Server request is always made to fetch latest data
///    (최신 데이터를 가져오기 위해 항상 서버 요청 수행)
/// 3. Server data replaces cached data and updates the cache
///    (서버 데이터가 캐시 데이터를 대체하고 캐시를 업데이트)
class PostSimpleListView extends StatefulWidget {
  const PostSimpleListView({
    super.key,
    required this.postId,
    this.category,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    this.controller,
  });

  /// 메인 카테고리 ID (Main category ID)
  /// 예: 'freetalk', 'buyandsell', 'qna'
  final String postId;

  /// 서브 카테고리 (Sub category, optional)
  /// 예: 'discussion', '호텔', '렌트카'
  final String? category;

  final void Function(Post post) onTap;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final bool enableHeroTransition;

  /// Optional custom tile builder for rendering individual post items
  /// If null, defaults to PostListTile widget
  final Widget Function(Post post, VoidCallback onTap)? tileBuilder;

  /// Optional controller for external access to refresh and other operations
  /// GlobalKey를 사용하지 않고 외부에서 새로고침 등의 작업을 수행하기 위한 컨트롤러
  final PostListController? controller;

  @override
  State<PostSimpleListView> createState() => PostSimpleListViewState();
}

class PostSimpleListViewState extends State<PostSimpleListView> {
  int? _totalPostCount;

  /// Flag to track if cache has been loaded
  /// 캐시 로드 완료 여부를 추적하는 플래그
  bool _cacheLoaded = false;

  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pagekey) async {
      /// API 호출로 게시글 목록 가져오기
      /// Fetch posts from API
      final res = await postList(
        limit: 20,
        page: pagekey,
        postId: widget.postId,
        category: widget.category,
      );

      if (_totalPostCount != res.post_count) {
        setState(() {
          _totalPostCount = res.post_count;
        });
      }

      /// Save first page to cache (첫 페이지만 캐시에 저장)
      /// This enables fast loading on next visit
      /// 다음 방문 시 빠른 로딩을 위해 저장
      if (pagekey == 1) {
        savePostsToCache(widget.postId, widget.category, res);
      }

      return res.posts;
    },
  );

  @override
  void initState() {
    super.initState();

    /// Attach controller if provided
    /// 컨트롤러가 제공된 경우 연결
    widget.controller?.attach(pagingController);

    _loadCachedFirstPage();
  }

  /// Load cached first page and display immediately, then fetch from server
  /// 캐시된 첫 페이지를 즉시 표시한 후, 서버에서 최신 데이터 가져오기
  ///
  /// This provides instant display of previously loaded posts
  /// while the server request is being made in the background.
  /// After server response, the display is updated with fresh data.
  /// 서버 요청이 백그라운드에서 진행되는 동안
  /// 이전에 로드된 게시글을 즉시 표시합니다.
  /// 서버 응답 후 최신 데이터로 화면을 업데이트합니다.
  Future<void> _loadCachedFirstPage() async {
    if (_cacheLoaded) return;
    _cacheLoaded = true;

    final cached = await getPostsFromCache(widget.postId, widget.category);

    // Only use cache if we have data and controller is still empty
    // 데이터가 있고 컨트롤러가 아직 비어있을 때만 캐시 사용
    if (cached != null && cached.posts.isNotEmpty && mounted) {
      final currentPages = pagingController.value.pages;
      if (currentPages == null || currentPages.isEmpty) {
        // Insert cached data into PagingController
        // 캐시된 데이터를 PagingController에 삽입
        pagingController.value = PagingState<int, Post>(
          pages: [cached.posts],
          keys: [1],
          hasNextPage: cached.posts.length >= 20,
          isLoading: false,
        );
        setState(() => _totalPostCount = cached.post_count);
      }
    }

    // Always fetch from server to get latest data
    // 항상 서버에서 최신 데이터 가져오기
    _fetchAndUpdateFirstPage();
  }

  /// Fetch first page from server and update the display
  /// 서버에서 첫 페이지를 가져와 화면 업데이트
  ///
  /// This ensures the user always sees the latest posts,
  /// even if they were cached previously.
  /// 이전에 캐시되었더라도 사용자가 항상 최신 게시글을 볼 수 있도록 합니다.
  Future<void> _fetchAndUpdateFirstPage() async {
    try {
      final res = await postList(
        limit: 20,
        page: 1,
        postId: widget.postId,
        category: widget.category,
      );

      if (mounted) {
        // Update first page with server data
        // 서버 데이터로 첫 페이지 업데이트
        pagingController.value = PagingState<int, Post>(
          pages: [res.posts],
          keys: [1],
          hasNextPage: res.posts.length >= 20,
          isLoading: false,
        );

        if (_totalPostCount != res.post_count) {
          setState(() => _totalPostCount = res.post_count);
        }

        // Save to cache (캐시에 저장)
        savePostsToCache(widget.postId, widget.category, res);
      }
    } catch (e) {
      // Server request failed, keep cache data
      // 서버 요청 실패 시 캐시 데이터 유지
    }
  }

  @override
  void didUpdateWidget(covariant PostSimpleListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 카테고리 변경 시 목록 새로고침 및 캐시 다시 로드
    /// Refresh list and reload cache when category changes
    if (oldWidget.postId != widget.postId ||
        oldWidget.category != widget.category) {
      _cacheLoaded = false;
      _loadCachedFirstPage();
      pagingController.refresh();
    }
  }

  @override
  void dispose() {
    /// Detach controller before disposing
    /// dispose 전에 컨트롤러 연결 해제
    widget.controller?.detach();

    pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener<int, Post>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedListView.separated(
          // Comic Design: 16px padding on all sides (8의 배수)
          padding: const EdgeInsets.only(top: 0),
          // Comic Design: 16px spacing between posts (8의 배수)
          separatorBuilder: (context, index) => Divider(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),

          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
            itemBuilder: (context, post, index) {
              /// Build post tile using custom builder or default PostListTile
              /// 커스텀 빌더가 있으면 사용하고, 없으면 기본 PostListTile 사용
              final tile =
                  widget.tileBuilder?.call(post, () => widget.onTap(post)) ??
                  PostListTile(
                    post: post,
                    onTap: () => widget.onTap(post),
                    enableHeroTransition: widget.enableHeroTransition,
                  );

              /// 첫 번째 아이템에만 "Hello World" 텍스트를 상단에 표시
              /// Display "Hello World" text only on the first item
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SquareBanners(
                      postIdOrCategory: widget.category ?? widget.postId,
                    ),
                    SmallBanners(
                      postIdOrCategory: widget.category ?? widget.postId,
                    ),
                    tile,
                  ],
                );
              }

              return tile;
            },
            firstPageProgressIndicatorBuilder: (context) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            newPageProgressIndicatorBuilder: (context) =>
                const Center(child: CircularProgressIndicator.adaptive()),
          ),
        );
      },
    );
  }
}
