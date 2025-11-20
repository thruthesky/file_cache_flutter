import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
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
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              builderDelegate: PagedChildBuilderDelegate<Comment>(
                itemBuilder: (context, comment, index) =>
                    _CommentCard(comment: comment, index: index),
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

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final int index;

  const _CommentCard({required this.comment, required this.index});

  String _formatTimeAgo(int timestamp) {
    final now = DateTime.now();
    final postTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final difference = now.difference(postTime);

    if (difference.inSeconds < 60) {
      return T.justNow;
    } else if (difference.inMinutes < 60) {
      return T.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return T.hoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return T.daysAgo(difference.inDays);
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return T.weeksAgo(weeks);
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return T.monthsAgo(months);
    } else {
      final years = (difference.inDays / 365).floor();
      return T.yearsAgo(years);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GestureDetector(
          onTap: () {
            // Navigate to the parent post using idx_root
            if (comment.idx_root > 0) {
              final parentPost = Post.fromJson({'idx': comment.idx_root});
              PostViewScreen.push(context, parentPost);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightHeart,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${comment.good}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),

                    Text(
                      _formatTimeAgo(comment.stamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 100.ms, delay: (50 * index).ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: (50 * index).ms);
  }
}
