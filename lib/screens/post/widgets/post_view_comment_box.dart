import 'package:flutter/material.dart';

import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 하단 댓글 입력 박스 위젯
///
/// 댓글 작성, 답글 작성, 댓글 수정 기능을 제공합니다.
/// 현재 모드(일반/답글/수정)에 따라 다른 폼을 표시합니다.
///
/// ### 매개변수:
/// - [post] → 현재 게시글 데이터
/// - [replyingToComment] → 답글 작성 중인 댓글 (null이면 일반 댓글 모드)
/// - [editingComment] → 수정 중인 댓글 (null이면 수정 모드 아님)
/// - [commentFocusNode] → 댓글 입력 필드의 FocusNode
/// - [onCancelReplyMode] → 답글 모드 취소 콜백
/// - [onCancelEditMode] → 수정 모드 취소 콜백
/// - [onScrollToBottom] → 하단으로 스크롤 콜백
/// - [onStateChanged] → 상태 변경 시 부모 위젯에 알림
class PostViewCommentBox extends StatefulWidget {
  /// 현재 게시글 데이터
  final Post? post;

  /// 답글 작성 중인 댓글 (null이면 일반 댓글 모드)
  final Comment? replyingToComment;

  /// 수정 중인 댓글 (null이면 수정 모드 아님)
  final Comment? editingComment;

  /// 댓글 입력 필드의 FocusNode
  final FocusNode commentFocusNode;

  /// 답글 모드 취소 콜백
  final VoidCallback onCancelReplyMode;

  /// 수정 모드 취소 콜백
  final VoidCallback onCancelEditMode;

  /// 하단으로 스크롤 콜백
  final VoidCallback onScrollToBottom;

  /// 상태 변경 시 부모 위젯에 알림 (setState 호출용)
  final VoidCallback onStateChanged;

  const PostViewCommentBox({
    super.key,
    required this.post,
    required this.replyingToComment,
    required this.editingComment,
    required this.commentFocusNode,
    required this.onCancelReplyMode,
    required this.onCancelEditMode,
    required this.onScrollToBottom,
    required this.onStateChanged,
  });

  @override
  State<PostViewCommentBox> createState() => _PostViewCommentBoxState();
}

class _PostViewCommentBoxState extends State<PostViewCommentBox> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // 키보드 높이 가져오기 (키보드가 올라올 때 패딩 추가용)
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 1.0),
        ),
      ),
      // 키보드가 올라올 때 하단 패딩 추가하여 입력 박스가 키보드 위에 표시되도록 함
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Context header (답글 또는 수정 모드일 때 표시)
          if (widget.replyingToComment != null || widget.editingComment != null)
            Container(
              decoration: BoxDecoration(color: scheme.surface),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 모드 표시 텍스트 (수정 중 / 답글 작성 중)
                        Text(
                          widget.editingComment != null
                              ? Lo.of(context)!.editing_comment
                              : '${Lo.of(context)!.replying_to} ${widget.replyingToComment!.nickname}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        /// 댓글 내용 미리보기
                        Text(
                          widget.editingComment != null
                              ? widget.editingComment!.content
                              : widget.replyingToComment!.content,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 취소 버튼
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: widget.editingComment != null
                        ? widget.onCancelEditMode
                        : widget.onCancelReplyMode,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

          // 입력 필드 (CommentCreateForm, ReplyToComment, CommentUpdate 중 하나)
          Padding(
            padding: const EdgeInsets.all(16),
            child: widget.editingComment != null
                // 수정 모드: CommentUpdate 폼
                ? CommentUpdate(
                    comment: widget.editingComment!,
                    onUpdated: (updatedComment) {
                      // 댓글 목록에서 해당 댓글 찾아 업데이트
                      final index = widget.post?.comments.indexWhere(
                        (c) => c.idx == updatedComment.idx,
                      );
                      if (index != null && index >= 0) {
                        widget.post?.comments[index].content =
                            updatedComment.content;
                        widget.post?.comments[index].files =
                            updatedComment.files;
                      }

                      // 수정 모드 종료 및 성공 메시지 표시
                      widget.onCancelEditMode();

                      if (mounted) {
                        widget.onStateChanged();
                        showSuccessSnackBar(
                          context,
                          Lo.of(context)!.commentUpdated,
                        );
                      }
                    },
                  )
                : widget.replyingToComment != null
                // 답글 모드: ReplyToComment 폼
                ? ReplyToComment(
                    parent: widget.replyingToComment!,
                    onReplied: (createdComment) {
                      // 부모 댓글 바로 아래에 답글 삽입
                      int? where = widget.post?.comments.indexWhere(
                        (comment) => comment.idx == createdComment.idx_parent,
                      );

                      if (where != null) {
                        widget.post?.comments.insert(where + 1, createdComment);
                      }

                      widget.post!.no_of_comment += 1;

                      // 답글 모드 종료 및 성공 메시지 표시
                      widget.onCancelReplyMode();

                      if (mounted) {
                        widget.onStateChanged();
                        showSuccessSnackBar(
                          context,
                          Lo.of(context)!.commentReplied,
                        );
                      }
                    },
                  )
                // 일반 모드: CommentCreateForm 폼
                : CommentCreateForm(
                    post: widget.post!,
                    focusNode: widget.commentFocusNode,
                    onCreated: (createdComment) {
                      // 댓글 목록 끝에 새 댓글 추가
                      widget.post?.comments.add(createdComment);
                      widget.post!.no_of_comment += 1;

                      if (mounted) {
                        widget.onStateChanged();
                        showSuccessSnackBar(
                          context,
                          Lo.of(context)!.commentCreated,
                        );
                        // 새 댓글이 보이도록 하단으로 스크롤
                        widget.onScrollToBottom();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
