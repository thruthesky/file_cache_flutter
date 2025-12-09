import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/post/compact.post.list.tile.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Reusable widget to display a list of posts for any user
/// Can be used for the current user or any other user
class UserPostsList extends StatelessWidget {
  final PagingController<int, Post> pagingController;
  final Widget Function(BuildContext, String, VoidCallback) errorBuilder;
  final Widget Function(BuildContext, IconData, String) emptyBuilder;

  const UserPostsList({
    super.key,
    required this.pagingController,
    required this.errorBuilder,
    required this.emptyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        pagingController.refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: PagingListener<int, Post>(
          controller: pagingController,
          builder: (context, state, fetchNextPage) => PagedListView<int, Post>(
            state: state,
            fetchNextPage: fetchNextPage,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            builderDelegate: PagedChildBuilderDelegate<Post>(
              itemBuilder: (context, post, index) =>
                  Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: CompactPostListTile(
                            post: post,
                            onTap: () {
                              PostViewScreen.push(context, post);
                            },
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 100.ms, delay: (30 * index).ms)
                      .slideY(
                        begin: 0.1,
                        end: 0,
                        duration: 300.ms,
                        delay: (50 * index).ms,
                      ),
              firstPageErrorIndicatorBuilder: (context) =>
                  errorBuilder(context, state.error.toString(), fetchNextPage),
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
      ),
    );
  }
}
