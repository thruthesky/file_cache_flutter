import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';

class CommentDetail extends StatefulWidget {
  const CommentDetail({
    super.key,
    required this.comment,
    required this.myComment,
    required this.hasReplies,
    required this.onReplied,
    required this.onUpdated,
    required this.onDeleted,
  });
  final Comment comment;
  final bool myComment;
  final bool hasReplies;
  final Function(Comment) onReplied;
  final Function(Comment) onUpdated;
  final Function(Comment) onDeleted;

  @override
  State<CommentDetail> createState() => _CommentDetailState();
}

class _CommentDetailState extends State<CommentDetail> {
  bool reply = false;
  bool update = false;

  double getDepthMargin(int depth) {
    return switch (depth) {
      1 => 0,
      2 => 32.0,
      3 => 48.0,
      _ => 64.0, // depth >= 4
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: getDepthMargin(widget.comment.depth)),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(photoUrl: widget.comment.photo_url),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.comment.nickname,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatTimestamp(context, widget.comment.stamp * 1000),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.comment.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    /// Show files (images) attached to comments
                    if (widget.comment.files.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      PostViewImages(files: widget.comment.files),
                    ],
                    Row(
                      children: [
                        /// Like button for comments
                        TextButton(
                          onPressed: () async {
                            try {
                              final updatedGood = await likePost(
                                widget.comment.idx,
                              );
                              debugLog(
                                'Comment liked, new good count: $updatedGood',
                              );

                              // Update the good count in the comment

                              widget.comment.good = updatedGood;
                              setState(() {});

                              if (context.mounted) {
                                showSuccessSnackBar(context, 'Comment liked');
                              }
                            } catch (e) {
                              d('Error liking comment: $e');

                              // Handle already-liked error
                              if (e.toString().contains('already-liked')) {
                                if (context.mounted) {
                                  showErrorSnackBar(
                                    context,
                                    'Already liked this comment',
                                  );
                                }
                              }
                            }
                          },
                          child: Text(
                            widget.comment.good > 0
                                ? "${LibTr.of(context)!.like} ${widget.comment.good}"
                                : LibTr.of(context)!.like,
                          ),
                        ),

                        /// 답글 버튼 - 항상 표시
                        TextButton(
                          onPressed: () => setState(() {
                            reply = !reply;
                            update = false;
                          }),
                          child: Text(LibTr.of(context)!.reply),
                        ),

                        /// 수정 버튼 - 내 댓글인 경우에만 표시
                        if (!widget.hasReplies && widget.myComment) ...[
                          TextButton(
                            onPressed: () => setState(() {
                              update = !update;
                              reply = false;
                            }),
                            child: Text(LibTr.of(context)!.edit),
                          ),

                          TextButton(
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                message: LibTr.of(
                                  context,
                                )!.delete_comment_confirmation,
                              );
                              if (confirmed) {
                                await func(
                                  'delete_comment_func',
                                  data: {'idx': widget.comment.idx},
                                );
                                if (context.mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    LibTr.of(context)!.successfully_deleted,
                                  );
                                  // Notify parent widget to remove this comment from the list
                                  widget.onDeleted(widget.comment);
                                }
                              }
                            },
                            child: Text(LibTr.of(context)!.delete),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (reply)
          ReplyToComment(
            parent: widget.comment,
            onReplied: (c) {
              widget.onReplied(c);

              reply = false;
              setState(() {});
            },
          ),
        if (update)
          CommentUpdate(
            comment: widget.comment,
            onUpdated: (c) {
              widget.onUpdated(c);
              update = false;
              setState(() {});
            },
          ),
      ],
    );
  }
}
