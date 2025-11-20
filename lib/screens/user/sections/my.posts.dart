import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyPostsList extends StatelessWidget {
  final PagingController<int, Post> pagingController;
  final Widget Function(BuildContext, String, VoidCallback) errorBuilder;
  final Widget Function(BuildContext, IconData, String) emptyBuilder;

  const MyPostsList({
    super.key,
    required this.pagingController,
    required this.errorBuilder,
    required this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        pagingController.refresh();
      },
      child: PagingListener<int, Post>(
        controller: pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, Post>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: scheme.surfaceContainerHighest),
              builderDelegate: PagedChildBuilderDelegate<Post>(
                itemBuilder: (context, post, index) =>
                    PostListTile(
                          post: post,
                          onTap: () {
                            PostViewScreen.push(context, post);
                          },
                        )
                        .animate()
                        .fadeIn(duration: 100.ms, delay: (30 * index).ms)
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 300.ms,
                          delay: (50 * index).ms,
                        ),
                firstPageErrorIndicatorBuilder: (context) => errorBuilder(
                  context,
                  state.error.toString(),
                  fetchNextPage,
                ),
                noItemsFoundIndicatorBuilder: (context) => emptyBuilder(
                  context,
                  FontAwesomeIcons.lightFileLines,
                  T.noPostsYet,
                ),
                firstPageProgressIndicatorBuilder: (context) =>
                    const Center(child: CircularProgressIndicator()),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
      ),
    );
  }
}
