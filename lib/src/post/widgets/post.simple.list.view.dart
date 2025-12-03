import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Simple List View for Posts
/// Displays posts in a vertical list layout with pagination
class PostSimpleListView extends StatefulWidget {
  const PostSimpleListView({
    super.key,
    required this.postCategory,
    required this.onTap,
    this.noItemsFoundIndicatorBuilder,
    this.enableHeroTransition = false,
    this.tileBuilder,
  });

  final PostCategoryItem postCategory;
  final void Function(Post post) onTap;
  final WidgetBuilder? noItemsFoundIndicatorBuilder;
  final bool enableHeroTransition;

  /// Optional custom tile builder for rendering individual post items
  /// If null, defaults to PostListTile widget
  final Widget Function(Post post, VoidCallback onTap)? tileBuilder;

  @override
  State<PostSimpleListView> createState() => PostSimpleListViewState();
}

class PostSimpleListViewState extends State<PostSimpleListView> {
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
  void didUpdateWidget(covariant PostSimpleListView oldWidget) {
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
        return PagedListView.separated(
          // Comic Design: 16px spacing between posts (8의 배수)
          separatorBuilder: (context, index) => const SizedBox(height: 16),

          // Comic Design: 16px padding on all sides (8의 배수)
          padding: const EdgeInsets.all(16),
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
