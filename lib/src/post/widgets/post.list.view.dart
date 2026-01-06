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
/// 캐시 없음 - 항상 서버에서 데이터를 가져옴
/// No cache - always fetches data from server
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

      if (_totalPostCount != res.post_count && mounted) {
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

      return res.posts;
    },
  );

  @override
  void initState() {
    super.initState();

    /// Attach controller if provided
    /// 컨트롤러가 제공된 경우 연결
    widget.controller.state = this;

    /// 캐시 없음 - PagingController가 자동으로 첫 페이지 fetch
    /// No cache - PagingController automatically fetches first page
  }

  @override
  void didUpdateWidget(covariant PostListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 카테고리 변경 시 목록 새로고침
    /// Refresh list when category changes
    if (oldWidget.postId != widget.postId ||
        oldWidget.category != widget.category) {
      /// 광고 목록 초기화 후 새로고침
      /// Clear ads and refresh
      setState(() {
        _pointAdvertisements = [];
      });

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
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SquareBanners(
                postIdOrCategory: widget.category ?? widget.postId,
                onTap: (url) => widget.onTapBanner(url),
              ),
            ),
            SliverToBoxAdapter(
              child:
                  /// 작은 배너 (Small Banners)
                  SmallBanners(
                    postIdOrCategory: widget.category ?? widget.postId,
                    onTap: (url) => widget.onTapBanner(url),
                  ),
            ),
            SliverToBoxAdapter(
              child:
                  /// 포인트 광고 (Point Advertisements)
                  /// 포인트를 사용하여 상단 노출된 게시글
                  PointAdvertisements(
                    advertisements: _pointAdvertisements,
                    onTap: (url) => widget.onTapBanner(url),
                  ),
            ),
            PagedSliverList.separated(
              // Comic Design: 16px spacing between posts (8의 배수)
              separatorBuilder: (context, index) => Divider(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),

              state: state,
              fetchNextPage: fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<Post>(
                noItemsFoundIndicatorBuilder:
                    widget.noItemsFoundIndicatorBuilder,
                itemBuilder: (context, post, index) {
                  /// Build post tile using custom builder or default PostListTile
                  /// 커스텀 빌더가 있으면 사용하고, 없으면 기본 PostListTile 사용
                  final tile =
                      widget.tileBuilder?.call(
                        post,
                        () => widget.onTap(post),
                      ) ??
                      PostListTileItem(
                        post: post,
                        onTap: () => widget.onTap(post),
                        enableHeroTransition: widget.enableHeroTransition,
                      );

                  return tile;
                },
                firstPageProgressIndicatorBuilder: (context) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                newPageProgressIndicatorBuilder: (context) =>
                    const Center(child: CircularProgressIndicator.adaptive()),
              ),
            ),
          ],
        );
      },
    );
  }
}
