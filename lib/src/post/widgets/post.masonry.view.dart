import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostMasonryViewController {
  late PostMasonryViewState state;
  void add(Post post) {}
}

/// Grid View for Posts (게시글 그리드 뷰)
/// Displays posts in a masonry grid layout with pagination
/// Masonry 그리드 레이아웃으로 게시글을 페이지네이션하여 표시
///
/// 캐시 없음 - 항상 서버에서 데이터를 가져옴
/// No cache - always fetches data from server
class PostMasonryView extends StatefulWidget {
  const PostMasonryView({
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

  final PostMasonryViewController controller;

  final void Function(String url) onTapBanner;

  @override
  State<PostMasonryView> createState() => PostMasonryViewState();
}

class PostMasonryViewState extends State<PostMasonryView> {
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
      /// 디버그: fetchPage 콜백 호출 확인
      d('[PostMasonryView] fetchPage 호출 - page: $pagekey, postId: ${widget.postId}');

      /// API 호출로 게시글 목록 가져오기
      /// Fetch posts from API
      final res = await postList(
        limit: 20,
        page: pagekey,
        postId: widget.postId,
        category: widget.category,
      );

      /// 디버그: fetchPage 응답 확인
      d('[PostMasonryView] fetchPage 응답 - page: $pagekey, posts: ${res.posts.length}, pointAds: ${res.pointAdvertisements.length}');

      if (_totalPostCount != res.post_count) {
        setState(() {
          _totalPostCount = res.post_count;
        });
      }

      /// 첫 페이지에서 포인트 광고 저장
      /// Save point advertisements from first page
      if (pagekey == 1 && mounted) {
        d('[PostMasonryView] fetchPage에서 포인트 광고 업데이트 - ${res.pointAdvertisements.length}개');
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

    d('[PostMasonryView] initState - postId: ${widget.postId}, category: ${widget.category}');

    /// Attach controller if provided
    /// 컨트롤러가 제공된 경우 연결
    widget.controller.state = this;

    /// 캐시 없음 - PagingController가 자동으로 첫 페이지 fetch
    /// No cache - PagingController automatically fetches first page
  }

  @override
  void didUpdateWidget(covariant PostMasonryView oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 카테고리 변경 시 목록 새로고침
    /// Refresh list when category changes
    if (oldWidget.postId != widget.postId ||
        oldWidget.category != widget.category) {
      d('[PostMasonryView] didUpdateWidget - postId 변경: ${oldWidget.postId} -> ${widget.postId}, category 변경: ${oldWidget.category} -> ${widget.category}');

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
        final items = state.items ?? [];

        /// Trigger initial load if needed
        if (items.isEmpty && !state.isLoading && state.error == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            fetchNextPage();
          });
        }

        if (items.isEmpty && state.error == null) {
          return Center(child: CircularProgressIndicator.adaptive());
        }

        if (items.isEmpty && state.error != null) {
          return widget.noItemsFoundIndicatorBuilder?.call(context) ??
              const SizedBox.shrink();
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
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
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(8.0),
              sliver: SliverMasonryGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childCount: items.length,
                itemBuilder: (context, index) {
                  final post = items[index];

                  /// Trigger pagination when near the end (after frame to avoid setState during build)
                  if (index >= items.length - 3 && !state.isLoading) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!state.isLoading) {
                        fetchNextPage();
                      }
                    });
                  }

                  /// Build post tile
                  return widget.tileBuilder?.call(
                        post,
                        () => widget.onTap(post),
                      ) ??
                      PostListTileItem(
                        post: post,
                        onTap: () => widget.onTap(post),
                        enableHeroTransition: widget.enableHeroTransition,
                      );
                },
              ),
            ),

            /// Loading indicator for next page
            if (state.isLoading && items.isNotEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),

            /// Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 8)),
          ],
        );
      },
    );
  }
}
