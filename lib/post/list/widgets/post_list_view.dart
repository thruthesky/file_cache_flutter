import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/post/list/widgets/empty_post_list.dart';
import 'package:philgo/post/list/widgets/post.list.tile.dart';
import 'package:philgo/post/list/widgets/post_list_error_indicator.dart';
import 'package:philgo/post/post.model.dart';

class PostListView extends StatelessWidget {
  final PagingController<int, Post> pagingController;
  final ThemeData theme;
  final ColorScheme scheme;
  final void Function(Post) onPostTap;
  final VoidCallback onRetry;

  const PostListView({
    super.key,
    required this.pagingController,
    required this.theme,
    required this.scheme,
    required this.onPostTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedListView<int, Post>.separated(
          state: state,
          fetchNextPage: fetchNextPage,
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (_, _) => const SizedBox.shrink(),
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => PostListTile(
              post: post,
              onTap: () => onPostTap(post),
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            noItemsFoundIndicatorBuilder: (_) => EmptyPostList(scheme: scheme),
            firstPageErrorIndicatorBuilder: (context) =>
                PostListErrorIndicator(scheme: scheme, onRetry: onRetry),
          ),
        );
      },
    );
  }
}
