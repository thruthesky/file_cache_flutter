import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/comment.input.dart';
import 'package:philgo/post/view/widgets/comment.tile.dart';
import 'package:philgo/post/view/widgets/comment_thread_painter.dart';

/// 댓글 목록 위젯
///
/// Reddit 스타일 세로선(thread line)을 포함한 트리 기반 코멘트 렌더링.
/// 플랫 리스트를 트리 구조로 변환하여 부모-자식 관계를 시각적으로 표현한다.
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

  /// 세로선 색상
  static const _lineColor = Color(0xFF94A3B8);

  /// 아바타 반지름
  static const _avatarRadius = 16.0;

  /// 코멘트 행 상단 패딩
  static const _commentTopPadding = 8.0;

  /// 커넥터 너비 (곡선 수평 길이)
  static const _connectorWidth = 16.0;

  /// 곡선 타겟 Y (자식 아바타 중앙 = topPadding + avatarRadius)
  static const _curveTargetY = _commentTopPadding + _avatarRadius;

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
          _buildCommentTree(),

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

  /// 트리 기반 코멘트 렌더링
  Widget _buildCommentTree() {
    final treeRoots = buildCommentTree(widget.comments);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < treeRoots.length; i++) ...[
            // 최상위 코멘트 간 구분선
            if (i > 0)
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                height: 8,
              ),
            _buildCommentNode(treeRoots[i]),
          ],
        ],
      ),
    );
  }

  /// 재귀적 코멘트 노드 렌더링 (세로선 포함)
  Widget _buildCommentNode(CommentNode node) {
    final hasChildren = node.children.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 코멘트 타일
        CommentTile(
          comment: node.comment,
          allComments: widget.comments,
          hasChildren: hasChildren,
          showThreadLine: hasChildren,
          onReply: () {
            setState(() {
              _replyToIdx = _replyToIdx == node.comment.idx
                  ? null
                  : node.comment.idx;
            });
          },
          onEdit: widget.onEditComment,
          onDelete: widget.onDeleteComment,
        ),

        // 대댓글 입력 폼
        if (_replyToIdx == node.comment.idx)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildReplyInput(node.comment),
          ),

        // 자식 영역 (세로선 포함)
        if (hasChildren) _buildChildrenArea(node),
      ],
    );
  }

  /// 자식 코멘트 영역 (세로선 + 곡선 연결선 포함)
  ///
  /// 부모 아바타 중앙에서 세로선이 시작되어 마지막 직접 자식까지 연결된다.
  /// 깊이가 5를 초과하면 패딩을 줄여서 화면 폭을 확보한다.
  Widget _buildChildrenArea(CommentNode parentNode) {
    final children = parentNode.children;

    // 깊이 5 이상일 때 패딩을 줄임 (8px 대신 16px)
    // 이렇게 하면 깊이가 깊어져도 코멘트가 화면을 넘어가지 않음
    final paddingLeft = parentNode.depth >= 5 ? 8.0 : _avatarRadius;

    return Padding(
      // 부모 아바타 중앙 기준 들여쓰기 (깊이에 따라 조정)
      padding: EdgeInsets.only(left: paddingLeft),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 세로선 + L곡선 커넥터
                  SizedBox(
                    width: _connectorWidth,
                    child: CustomPaint(
                      painter: ThreadConnectorPainter(
                        isLast: i == children.length - 1,
                        lineColor: _lineColor,
                        lineWidth: 1.5,
                        curveTargetY: _curveTargetY,
                        curveRadius: 8.0,
                      ),
                    ),
                  ),

                  // 자식 코멘트 노드 (재귀)
                  Expanded(
                    child: _buildCommentNode(children[i]),
                  ),
                ],
              ),
            ),
        ],
      ),
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
