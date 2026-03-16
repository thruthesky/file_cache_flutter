import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/post/list/widgets/post_masonry_card.dart';
import 'package:philgo/post/post.model.dart';

class PostListMasonryView extends StatelessWidget {
  final PagingController<int, Post> pagingController;
  final ThemeData theme;
  final ColorScheme scheme;
  final void Function(Post) onPostTap;

  const PostListMasonryView({
    super.key,
    required this.pagingController,
    required this.theme,
    required this.scheme,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) {
        return PagedMasonryGridView<int, Post>.count(
          state: state,
          fetchNextPage: fetchNextPage,
          crossAxisCount: 2,
          padding: const EdgeInsets.all(8),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          builderDelegate: PagedChildBuilderDelegate<Post>(
            itemBuilder: (context, post, index) => PostMasonryCard(
              post: post,
              theme: theme,
              scheme: scheme,
              onTap: () => onPostTap(post),
            ),
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
        );
      },
    );
  }
}
