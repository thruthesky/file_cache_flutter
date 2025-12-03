import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Grid layout for user's latest posts and comments
/// Clean minimal design with 2-column grid
class LatestUserActivity extends StatefulWidget {
  const LatestUserActivity({
    super.key,
    required this.firebase_uid,
    this.postLimit = 3,
    this.commentLimit = 3,
  });

  final String firebase_uid;
  final int postLimit;
  final int commentLimit;

  @override
  State<LatestUserActivity> createState() => _LatestUserActivityState();
}

class _LatestUserActivityState extends State<LatestUserActivity> {
  bool _isLoadingPosts = true;
  bool _isLoadingComments = true;
  List<Post> _posts = [];
  List<Comment> _comments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadPosts(), _loadComments()]);
  }

  Future<void> _loadPosts() async {
    try {
      setState(() => _isLoadingPosts = true);
      final posts = await getLatestByUser(
        firebase_uid: widget.firebase_uid,
        limit: widget.postLimit,
      );
      if (mounted) {
        setState(() {
          _posts = posts;
          _isLoadingPosts = false;
        });
      }
    } catch (e) {
      debugLog('Error loading posts: $e');
      if (mounted) setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _loadComments() async {
    try {
      setState(() => _isLoadingComments = true);
      final comments = await getMyComments(limit: widget.commentLimit);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      debugLog('Error loading comments: $e');
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;

    if (_isLoadingPosts && _isLoadingComments) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Posts section
          if (_posts.isNotEmpty) ...[
            _SectionHeader(title: T.latestPosts),
            SizedBox(height: sp.s12),
            _GridView(
              items: _posts.map((post) => _GridPostItem(post: post)).toList(),
            ),
            SizedBox(height: sp.s32),
          ],

          /// Comments section
          if (_comments.isNotEmpty) ...[
            _SectionHeader(title: T.latestComments),
            SizedBox(height: sp.s12),
            _GridView(
              items: _comments
                  .map((comment) => _GridCommentItem(comment: comment))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Simple section header
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

/// 2-column grid view
class _GridView extends StatelessWidget {
  const _GridView({required this.items});
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: sp.s12,
        mainAxisSpacing: sp.s12,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index]
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 100).ms)
            .scale(
              begin: const Offset(0.9, 0.9),
              duration: 300.ms,
              delay: (index * 100).ms,
            );
      },
    );
  }
}

/// Grid item for post
class _GridPostItem extends StatelessWidget {
  const _GridPostItem({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return GestureDetector(
      onTap: () => PostViewScreen.push(context, post),
      child: Container(
        padding: EdgeInsets.all(sp.s12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              post.subject,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            /// Stats row
            Row(
              children: [
                Text(
                  '${post.no_of_view}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  ' · ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${post.no_of_comment}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid item for comment
class _GridCommentItem extends StatelessWidget {
  const _GridCommentItem({required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return GestureDetector(
      onTap: () {
        if (comment.idx_root > 0) {
          final parentPost = Post.fromJson({'idx': comment.idx_root});
          PostViewScreen.push(context, parentPost);
        }
      },
      child: Container(
        padding: EdgeInsets.all(sp.s12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Content
            Text(
              comment.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const Spacer(),

            /// Likes count
            Text(
              '${comment.good}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
