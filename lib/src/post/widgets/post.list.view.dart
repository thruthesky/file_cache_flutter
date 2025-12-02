import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class PostListViewController {
  late final PostListViewState state;
}

class PostListView extends StatefulWidget {
  const PostListView({
    super.key,
    required this.controller,
    required this.postCategory,
    required this.headerBuilder,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    this.gridColumns,
  });

  final PostListViewController controller;

  final PostCategoryItem postCategory;
  final void Function(Post post) onTap;
  final Widget Function(BuildContext context, int? totalPostCount)
  headerBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final bool enableHeroTransition;

  /// Optional custom tile builder for rendering individual post items
  /// If null, defaults to PostListTile widget
  final Widget Function(Post post, VoidCallback onTap)? tileBuilder;

  /// Number of columns for grid layout
  /// If null or 1, displays as a list. If 2 or more, displays as a grid
  final int? gridColumns;

  @override
  State<PostListView> createState() => PostListViewState();
}

class PostListViewState extends State<PostListView> {
  int? _totalPostCount;

  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pagekey) async {
      // d('Fetching page: $pagekey, category: ${widget.selectedCategory}');
      final res = await getPosts(
        limit: 20,
        page: pagekey,
        postId: widget.postCategory.postId,
        category: widget.postCategory.category,
      );

      if (_totalPostCount != res.post_count) {
        setState(() {
          _totalPostCount = res.post_count;
        });
      }

      return res.posts;
    },
  );

  @override
  void initState() {
    super.initState();
    widget.controller.state = this;
  }

  @override
  void didUpdateWidget(covariant PostListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postCategory.postId != widget.postCategory.postId ||
        oldWidget.postCategory.category != widget.postCategory.category) {
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
    final isGridLayout = widget.gridColumns != null && widget.gridColumns! > 1;

    return PagingListener<int, Post>(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        /// Render as Masonry Grid Layout
        if (isGridLayout) {
          final items = state.items ?? [];

          /// Trigger initial load if needed
          if (items.isEmpty && !state.isLoading && state.error == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              fetchNextPage();
            });
          }

          return CustomScrollView(
            slivers: [
              /// Header section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: widget.headerBuilder(context, _totalPostCount),
                ),
              ),

              /// Masonry grid for posts
              if (items.isEmpty && state.error == null)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                )
              else if (items.isEmpty && state.error != null)
                SliverToBoxAdapter(
                  child: widget.noItemsFoundIndicatorBuilder?.call(context) ??
                      const SizedBox.shrink(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: widget.gridColumns!,
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
                      return widget.tileBuilder?.call(post, () => widget.onTap(post)) ??
                          PostListTile(
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
        }

        /// Render as List Layout (default)
        return PagedListView.separated(
          // 게시글 사이에 간격 추가
          separatorBuilder: (context, index) => const SizedBox(height: 8),

          padding: const EdgeInsets.all(8.0),
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            noItemsFoundIndicatorBuilder: widget.noItemsFoundIndicatorBuilder,
            itemBuilder: (context, post, index) {
              /// Build post tile using custom builder or default PostListTile
              final tile =
                  widget.tileBuilder?.call(post, () => widget.onTap(post)) ??
                      PostListTile(
                        post: post,
                        onTap: () => widget.onTap(post),
                        enableHeroTransition: widget.enableHeroTransition,
                      );

              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.headerBuilder(context, _totalPostCount),
                    SizedBox(height: 8),
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
