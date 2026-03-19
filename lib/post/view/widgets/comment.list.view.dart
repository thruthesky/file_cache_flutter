import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/post.model.dart';
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
  final Future<void> Function(Post comment, String content) onEditComment;
  final Future<void> Function(Post comment) onDeleteComment;

  /// 답글 버튼 탭 시 호출 — 화면 레벨에서 하단 바 답글 모드를 활성화한다.
  final void Function(Post comment)? onReplyTap;

  /// 북마크된 댓글 idx 목록
  final Set<int> bookmarkedCommentIdxs;

  /// 댓글 북마크 토글 콜백
  final Future<void> Function(int commentIdx)? onToggleBookmark;

  const CommentListView({
    super.key,
    required this.comments,
    required this.isLoading,
    required this.noOfComment,
    required this.idxRoot,
    required this.onEditComment,
    required this.onDeleteComment,
    this.onReplyTap,
    this.bookmarkedCommentIdxs = const {},
    this.onToggleBookmark,
  });

  @override
  State<CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
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
                '${'댓글'.tr()} ${widget.noOfComment}',
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
              '댓글이 없습니다.'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          )
        else
          _buildCommentTree(),

        const SizedBox(height: 8),
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
          onReply: () {},
          onReplyTap: widget.onReplyTap,
          onEdit: widget.onEditComment,
          onDelete: widget.onDeleteComment,
          bookmarked: widget.bookmarkedCommentIdxs.contains(node.comment.idx),
          onBookmark: widget.onToggleBookmark != null
              ? () => widget.onToggleBookmark!(node.comment.idx)
              : null,
        ),

        // 자식 영역 (세로선 포함)
        if (hasChildren) _buildChildrenArea(node),
      ],
    );
  }

  /// 자식 코멘트 영역 (세로선 + 곡선 연결선 포함)
  ///
  /// 부모 아바타 중앙에서 세로선이 시작되어 마지막 직접 자식까지 연결된다.
  /// paddingLeft를 줄이되, lineXOffset으로 세로선 X 좌표를 보정하여
  /// 부모 아바타 세로선과 정확하게 정렬한다.
  Widget _buildChildrenArea(CommentNode parentNode) {
    final children = parentNode.children;

    // 깊이 1-4: 정상 넓이 (paddingLeft = avatarRadius = 16)
    // 깊이 5+: 좁은 넓이 (paddingLeft = 12) + lineXOffset 보정으로 세로선 정렬 유지
    final paddingLeft = parentNode.depth >= 3 ? 6.0 : _avatarRadius;
    final lineXOffset = _avatarRadius - paddingLeft;

    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 세로선 + L곡선 커넥터 (lineXOffset으로 부모 세로선과 정렬)
                  SizedBox(
                    width: _connectorWidth,
                    child: CustomPaint(
                      painter: ThreadConnectorPainter(
                        isLast: i == children.length - 1,
                        lineColor: _lineColor,
                        lineWidth: 1.5,
                        curveTargetY: _curveTargetY,
                        curveRadius: 8.0,
                        lineXOffset: lineXOffset,
                      ),
                    ),
                  ),

                  // 자식 코멘트 노드 (재귀)
                  Expanded(child: _buildCommentNode(children[i])),
                ],
              ),
            ),
        ],
      ),
    );
  }

}
