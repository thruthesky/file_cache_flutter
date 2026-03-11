import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.action.button.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 댓글 단일 타일
///
/// 댓글 표시, 좋아요, 대댓글, 수정, 삭제 기능을 제공한다.
class CommentTile extends StatefulWidget {
  final Post comment;
  final List<Post> allComments;
  final VoidCallback onReply;
  final Future<void> Function(Post comment, String content) onEdit;
  final Future<void> Function(Post comment) onDelete;

  const CommentTile({
    super.key,
    required this.comment,
    required this.allComments,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
  });

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

  /// 현재 댓글에 자식 댓글이 있는지 확인
  bool _hasChildren() {
    return widget.allComments.any((c) => c.idxParent == widget.comment.idx);
  }

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userState = Provider.of<UserState>(context, listen: false);
    final isMine = userState.isLoggedIn && userState.idx == comment.idxMember;
    final hasChildren = _hasChildren();

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
          padding: EdgeInsets.fromLTRB(8 + indent, 0, 8, 0),
          child: Row(
            children: [
              // 좋아요
              PostActionButton(
                icon: _liked
                    ? FontAwesomeIcons.solidThumbsUp
                    : FontAwesomeIcons.lightThumbsUp,
                label: '${_goodCount > 0 ? _goodCount : ''}',
                color: _liked ? scheme.primary : scheme.onSurfaceVariant,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 8),
              // 답글
              PostActionButton(
                icon: FontAwesomeIcons.lightReply,
                label: '답글',
                color: scheme.onSurfaceVariant,
                onTap: widget.onReply,
              ),

              const Spacer(),

              if (isMine) ...[
                // 수정 (자식 댓글 없을 때만)
                if (!hasChildren)
                  PostActionButton(
                    icon: FontAwesomeIcons.lightPenToSquare,
                    label: '수정',
                    color: scheme.onSurfaceVariant,
                    onTap: () => _showEditDialog(context),
                  ),
                if (!hasChildren) const SizedBox(width: 8),
                // 삭제 (자식 댓글 없을 때만)
                if (!hasChildren)
                  PostActionButton(
                    icon: FontAwesomeIcons.lightTrashCan,
                    label: '삭제',
                    color: scheme.error,
                    onTap: () => _confirmDelete(context),
                  ),
              ],
            ],
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

  /// 수정 다이얼로그
  Future<void> _showEditDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.comment.content);
    final content = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 수정'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '댓글 내용을 입력하세요',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx, text);
            },
            child: const Text('수정'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (content != null) {
      await widget.onEdit(widget.comment, content);
    }
  }

  /// 삭제 확인 다이얼로그
  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('정말 이 댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.onDelete(widget.comment);
    }
  }

  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
