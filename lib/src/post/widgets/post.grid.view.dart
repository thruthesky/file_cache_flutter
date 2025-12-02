import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Grid View for Posts
/// Displays posts in a masonry grid layout with pagination
class PostGridView extends StatefulWidget {
  const PostGridView({
    super.key,
    required this.postCategory,
    required this.headerBuilder,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
    required this.gridColumns,
  });

  final PostCategoryItem postCategory;
  final void Function(Post post) onTap;
  final Widget Function(BuildContext context, int? totalPostCount) headerBuilder;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final bool enableHeroTransition;

  /// Optional custom tile builder for rendering individual post items
  /// If null, defaults to PostListTile widget
  final Widget Function(Post post, VoidCallback onTap)? tileBuilder;

  /// Number of columns for grid layout
  final int gridColumns;

  @override
  State<PostGridView> createState() => PostGridViewState();
}

class PostGridViewState extends State<PostGridView> {
  int? _totalPostCount;

  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pagekey) async {
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
  void didUpdateWidget(covariant PostGridView oldWidget) {
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
                child:
                    widget.noItemsFoundIndicatorBuilder?.call(context) ??
                    const SizedBox.shrink(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(8.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: widget.gridColumns,
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
      },
    );
  }
}
