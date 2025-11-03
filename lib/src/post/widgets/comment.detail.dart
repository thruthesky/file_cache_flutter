import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';

class CommentDetail extends StatefulWidget {
  const CommentDetail({
    super.key,
    required this.comment,
    required this.onReplied,
    required this.onUpdated,
  });
  final Comment comment;

  final Function(Comment) onReplied;
  final Function(Comment) onUpdated;

  @override
  State<CommentDetail> createState() => _CommentDetailState();
}

class _CommentDetailState extends State<CommentDetail> {
  bool reply = false;
  bool update = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: 32.0 * (widget.comment.depth - 1)),
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
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => setState(() {
                            reply = !reply;
                            update = false;
                          }),
                          child: Text(LibTr.of(context)!.reply),
                        ),
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
                              showSuccessSnackBar(
                                context,
                                LibTr.of(context)!.successfully_deleted,
                              );
                            }
                          },
                          child: Text(LibTr.of(context)!.delete),
                        ),
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
