import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/comment.input.dart';
import 'package:philgo/post/view/widgets/comment.tile.dart';

/// 댓글 목록 위젯
///
/// 댓글 목록 표시, 댓글 생성 폼, 대댓글 폼을 포함한다.
class CommentListView extends StatefulWidget {
  final List<Post> comments;
  final bool isLoading;
  final int noOfComment;
  final int idxRoot;
  final Future<void> Function(String content, {int? idxParent}) onCreateComment;
  final Future<void> Function(Post comment, String content) onEditComment;
  final Future<void> Function(Post comment) onDeleteComment;

  const CommentListView({
    super.key,
    required this.comments,
    required this.isLoading,
    required this.noOfComment,
    required this.idxRoot,
    required this.onCreateComment,
    required this.onEditComment,
    required this.onDeleteComment,
  });

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  /// 대댓글 대상 댓글 idx (null이면 최상위 댓글 입력 모드)
  int? _replyToIdx;

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
                '댓글 ${widget.noOfComment}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // 댓글 목록
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.comments.isEmpty)
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
          for (final comment in widget.comments) ...[
            CommentTile(
              comment: comment,
              allComments: widget.comments,
              onReply: () {
                setState(() {
                  // 토글: 같은 댓글 클릭 시 대댓글 폼 닫기
                  _replyToIdx =
                      _replyToIdx == comment.idx ? null : comment.idx;
                });
              },
              onEdit: widget.onEditComment,
              onDelete: widget.onDeleteComment,
            ),
            // 대댓글 입력 폼 (해당 댓글 아래에 표시)
            if (_replyToIdx == comment.idx)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16 + ((comment.depth) * 20.0).clamp(0.0, 60.0),
                  0,
                  16,
                  8,
                ),
                child: _buildReplyInput(comment),
              ),
          ],

        const SizedBox(height: 8),

        // 최상위 댓글 입력 폼
        CommentInput(
          idxRoot: widget.idxRoot,
          onSubmit: (content) async {
            await widget.onCreateComment(content);
          },
        ),
      ],
    );
  }

  /// 대댓글 입력 위젯
  Widget _buildReplyInput(Post parentComment) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 대댓글 대상 표시
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.downRight,
                size: 12,
                color: scheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${parentComment.userName}님에게 답글',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // 닫기 버튼
              GestureDetector(
                onTap: () => setState(() => _replyToIdx = null),
                child: FaIcon(
                  FontAwesomeIcons.lightXmark,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        CommentInput(
          idxRoot: widget.idxRoot,
          idxParent: parentComment.idx,
          autofocus: true,
          hintText: '답글을 입력하세요',
          onSubmit: (content) async {
            await widget.onCreateComment(
              content,
              idxParent: parentComment.idx,
            );
            if (mounted) setState(() => _replyToIdx = null);
          },
        ),
      ],
    );
  }
}
