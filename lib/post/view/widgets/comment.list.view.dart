import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.action.bar.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 댓글 목록 위젯
///
/// 게시글의 댓글 목록을 표시하며, 각 댓글은 [_CommentTile]로 렌더링된다.
class CommentListView extends StatelessWidget {
  final List<Post> comments;
  final bool isLoading;
  final int noOfComment;

  const CommentListView({
    super.key,
    required this.comments,
    required this.isLoading,
    required this.noOfComment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 댓글 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.lightComments,
                size: 14,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '댓글 $noOfComment',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 댓글 목록
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (comments.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              '댓글이 없습니다.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (final comment in comments) _CommentTile(comment: comment),
      ],
    );
  }
}

/// 댓글 타일 — 파일 상단 → 메타/내용 → 액션 바
class _CommentTile extends StatefulWidget {
  final Post comment;

  const _CommentTile({required this.comment});

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _liked = false;
  late int _goodCount;

  @override
  void initState() {
    super.initState();
    _goodCount = widget.comment.good;
  }

  Future<void> _toggleLike() async {
    try {
      final result = await PostService.like(widget.comment.idx);
      if (!mounted) return;
      setState(() {
        _liked = result.liked;
        _goodCount = result.good;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userState = Provider.of<UserState>(context, listen: false);
    final isMine =
        userState.isLoggedIn && userState.idx == comment.idxMember;

    // depth 1 = 댓글, depth 2+ = 대댓글 (들여쓰기)
    final indent = ((comment.depth - 1) * 20.0).clamp(0.0, 60.0);
    final isReply = comment.depth > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16 + indent, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 대댓글 표시
              if (isReply)
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.downRight,
                      size: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '답글',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

              // 메타 (작성자, 날짜)
              Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightUser,
                    size: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  if (comment.userName.isNotEmpty) ...[
                    Text(
                      comment.userName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _formatDate(comment.stamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // 내용
              Text(
                comment.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        // 첨부 파일
        if (comment.imageUrl != null || comment.videoUrl != null)
          Padding(
            padding: EdgeInsets.only(left: indent),
            child: PostViewFiles(post: comment),
          ),

        // 액션 바
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: PostActionBar(
            post: comment,
            isMine: isMine,
            liked: _liked,
            goodCount: _goodCount,
            onLike: _toggleLike,
            onEdit: () {},
            onDelete: () {},
          ),
        ),

        Divider(
          color: scheme.outlineVariant,
          height: 24,
          indent: 16 + indent,
          endIndent: 16,
        ),
      ],
    );
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
