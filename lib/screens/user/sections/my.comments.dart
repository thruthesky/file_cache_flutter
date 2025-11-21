import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/comment.card.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class MyCommentsList extends StatelessWidget {
  final PagingController<int, Comment> pagingController;
  final Widget Function(BuildContext, String, VoidCallback) errorBuilder;
  final Widget Function(BuildContext, IconData, String) emptyBuilder;

  const MyCommentsList({
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
      child: PagingListener<int, Comment>(
        controller: pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, Comment>.separated(
              state: state,
              fetchNextPage: fetchNextPage,
              padding: const EdgeInsets.all(16),
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              builderDelegate: PagedChildBuilderDelegate<Comment>(
                itemBuilder: (context, comment, index) => CommentCard(
                  comment: comment,
                  index: index,
                  maxLines: 2,
                  useFixedHeight: true,
                ),
                firstPageErrorIndicatorBuilder: (context) => errorBuilder(
                  context,
                  state.error.toString(),
                  fetchNextPage,
                ),
                noItemsFoundIndicatorBuilder: (context) => emptyBuilder(
                  context,
                  FontAwesomeIcons.lightComments,
                  T.noCommentsYet,
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
