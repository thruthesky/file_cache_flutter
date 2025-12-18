import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// 게시글 리스트 뷰 컨트롤러
/// Controller for PostListView to manage posts externally
class PostListViewController {
  late PostListViewState state;

  /// 게시글을 리스트 맨 위에 추가
  /// Add a post to the top of the list
  ///
  /// [post] 추가할 게시글 객체
  /// [post] The post object to add
  ///
  /// 새 게시글 작성 후 목록에 즉시 반영할 때 사용
  /// Used to immediately reflect a new post in the list after creation
  void add(Post post) {
    final controller = state.pagingController;
    final currentState = controller.value;

    // 현재 페이지 데이터가 없으면 새 페이지 생성
    // Create new page if no pages exist
    if (currentState.pages == null || currentState.pages!.isEmpty) {
      controller.value = PagingState<int, Post>(
        pages: [
          [post],
        ],
        keys: [1],
        hasNextPage: false,
        isLoading: false,
      );
      return;
    }

    // 첫 번째 페이지 복사 후 맨 앞에 새 게시글 추가
    // Copy first page and prepend new post
    final updatedFirstPage = [post, ...currentState.pages!.first];

    // 나머지 페이지들은 그대로 유지
    // Keep remaining pages as-is
    final updatedPages = [updatedFirstPage, ...currentState.pages!.skip(1)];

    // 업데이트된 상태로 컨트롤러 갱신
    // Update controller with new state
    controller.value = PagingState<int, Post>(
      pages: updatedPages,
      keys: currentState.keys,
      hasNextPage: currentState.hasNextPage,
      isLoading: false,
    );
  }
}

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
class PostListView extends StatefulWidget {
  const PostListView({
    super.key,
    required this.postId,
    this.category,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    required this.controller,
    required this.onTapBanner,
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
  final PostListViewController controller;

  final Function(String url) onTapBanner;

  @override
  State<PostListView> createState() => PostListViewState();
}

class PostListViewState extends State<PostListView> {
  int? _totalPostCount;

  /// Flag to track if cache has been loaded
  /// 캐시 로드 완료 여부를 추적하는 플래그
  bool _cacheLoaded = false;

  /// 포인트 광고 목록
  /// Point advertisements list
  ///
  /// 첫 페이지 로드 시 API 응답에서 파싱되어 저장됩니다.
  /// 게시글 목록 상단 (SmallBanners 아래)에 표시됩니다.
  List<PointAdvertisement> _pointAdvertisements = [];

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

      /// 첫 페이지에서 포인트 광고 저장
      /// Save point advertisements from first page
      if (pagekey == 1 && mounted) {
        setState(() {
          _pointAdvertisements = res.pointAdvertisements;
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
    widget.controller.state = this;

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

        /// 포인트 광고 업데이트
        /// Update point advertisements
        setState(() {
          _pointAdvertisements = res.pointAdvertisements;
        });

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
  void didUpdateWidget(covariant PostListView oldWidget) {
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
                  PostListTileItem(
                    post: post,
                    onTap: () => widget.onTap(post),
                    enableHeroTransition: widget.enableHeroTransition,
                  );

              /// 첫 번째 아이템에 배너 및 포인트 광고 표시
              /// Display banners and point advertisements on first item
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 사각 배너 (Square Banners)
                    SquareBanners(
                      postIdOrCategory: widget.category ?? widget.postId,
                      onTap: (url) => widget.onTapBanner(url),
                    ),

                    /// 작은 배너 (Small Banners)
                    SmallBanners(
                      postIdOrCategory: widget.category ?? widget.postId,
                      onTap: (url) => widget.onTapBanner(url),
                    ),

                    /// 포인트 광고 (Point Advertisements)
                    /// 포인트를 사용하여 상단 노출된 게시글
                    PointAdvertisements(
                      advertisements: _pointAdvertisements,
                      onTap: (url) => widget.onTapBanner(url),
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
