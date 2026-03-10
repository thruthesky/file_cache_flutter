import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.action.bar.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 댓글 단일 타일
class CommentTile extends StatefulWidget {
  final Post comment;

  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
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
    final isMine = userState.isLoggedIn && userState.idx == comment.idxMember;

    // depth 1 = 댓글, depth 2+ = 대댓글 (들여쓰기)
    final indent = ((comment.depth - 1) * 20.0).clamp(0.0, 60.0);
    final isReply = comment.depth > 1;

    // 아바타 이니셜
    final initial =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16 + indent, 8, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아바타
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Text(
                  initial,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
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
                        ],
                      ),

                    // 작성자 + 날짜
                    Row(
                      children: [
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

                    const SizedBox(height: 4),

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
