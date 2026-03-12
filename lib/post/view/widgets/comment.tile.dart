import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/widgets/post.action.button.dart';
import 'package:philgo/post/view/widgets/post.view.files.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 세로선 색상 (Reddit 스타일)
const kThreadLineColor = Color(0xFF94A3B8);

/// 댓글 단일 타일
///
/// 댓글 표시, 좋아요, 대댓글, 수정, 삭제 기능을 제공한다.
/// [showThreadLine]이 true이면 아바타 아래에서 세로선이 시작되어
/// 코멘트 하단까지 연결된다. (자식 코멘트가 있는 경우)
class CommentTile extends StatefulWidget {
  final Post comment;
  final List<Post> allComments;
  final VoidCallback onReply;
  final Future<void> Function(Post comment, String content) onEdit;
  final Future<void> Function(Post comment) onDelete;

  /// 자식 존재 여부 (외부에서 트리 구조 기반으로 전달)
  final bool hasChildren;

  /// 아바타 아래 세로선 표시 여부 (자식이 있는 노드에서 true)
  final bool showThreadLine;

  const CommentTile({
    super.key,
    required this.comment,
    required this.allComments,
    required this.onReply,
    required this.onEdit,
    required this.onDelete,
    this.hasChildren = false,
    this.showThreadLine = false,
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

  @override
  Widget build(BuildContext context) {
    final comment = widget.comment;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final userState = Provider.of<UserState>(context, listen: false);
    final isMine = userState.isLoggedIn && userState.idx == comment.idxMember;
    final hasChildren = widget.hasChildren;

    // 아바타 이니셜 (사진 없을 때 fallback)
    final initial =
        comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : '?';

    // 세로선 표시 여부에 따라 레이아웃 분기
    if (widget.showThreadLine) {
      return _buildWithThreadLine(
        context,
        comment: comment,
        theme: theme,
        scheme: scheme,
        isMine: isMine,
        hasChildren: hasChildren,
        initial: initial,
      );
    }

    return _buildNormal(
      context,
      comment: comment,
      theme: theme,
      scheme: scheme,
      isMine: isMine,
      hasChildren: hasChildren,
      initial: initial,
    );
  }

  /// 세로선 포함 레이아웃 (자식 있는 노드)
  ///
  /// IntrinsicHeight > Row 구조로 아바타 아래에서 코멘트 하단까지
  /// 세로선이 연결된다.
  Widget _buildWithThreadLine(
    BuildContext context, {
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
    required String initial,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타 + 세로선 컬럼
          SizedBox(
            width: 32,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildAvatar(comment, initial, theme, scheme),
                // 세로선: 아바타 하단에서 코멘트 하단까지 (중앙 정렬, 아바타와 붙어있음)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      width: 1.5,
                      color: kThreadLineColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 내용 컬럼
          Expanded(
            child: _buildContentColumn(
              comment: comment,
              theme: theme,
              scheme: scheme,
              isMine: isMine,
              hasChildren: hasChildren,
            ),
          ),
        ],
      ),
    );
  }

  /// 기본 레이아웃 (자식 없는 노드)
  Widget _buildNormal(
    BuildContext context, {
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
    required String initial,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(comment, initial, theme, scheme),
          const SizedBox(width: 8),
          Expanded(
            child: _buildContentColumn(
              comment: comment,
              theme: theme,
              scheme: scheme,
              isMine: isMine,
              hasChildren: hasChildren,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(Post comment, String initial, ThemeData theme, ColorScheme scheme) {
    if (comment.userPhotoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: CachedNetworkImageProvider(comment.userPhotoUrl),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// 내용 컬럼 (작성자, 날짜, 내용, 첨부파일, 액션바)
  Widget _buildContentColumn({
    required Post comment,
    required ThemeData theme,
    required ColorScheme scheme,
    required bool isMine,
    required bool hasChildren,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showThreadLine) const SizedBox(height: 8),

        // 작성자 + 날짜
        Row(
          children: [
            if (comment.userName.isNotEmpty) ...[
              Flexible(
                child: Text(
                  comment.userName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
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

        // 첨부 파일
        if (comment.imageUrl != null || comment.videoUrl != null)
          PostViewFiles(post: comment),

        // 액션 바
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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

              const SizedBox(width: 12),

              if (isMine) ...[
                if (!hasChildren)
                  PostActionButton(
                    icon: FontAwesomeIcons.lightPenToSquare,
                    label: '수정',
                    color: scheme.onSurfaceVariant,
                    onTap: () => _showEditDialog(context),
                  ),
                if (!hasChildren) const SizedBox(width: 8),
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
