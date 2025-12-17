import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentDetail extends StatefulWidget {
  const CommentDetail({
    super.key,
    required this.comment,
    required this.myComment,
    required this.hasReplies,
    required this.onReplied,
    required this.onUpdated,
    required this.onDeleted,
    required this.onReplyClicked,
    required this.onEditClicked,
  });
  final Comment comment;
  final bool myComment;
  final bool hasReplies;
  final Function(Comment) onReplied;
  final Function(Comment) onUpdated;
  final Function(Comment) onDeleted;
  final Function(Comment) onReplyClicked;
  final Function(Comment) onEditClicked;

  @override
  State<CommentDetail> createState() => _CommentDetailState();
}

class _CommentDetailState extends State<CommentDetail> {
  bool _isLiked = false;

  double getDepthMargin(int depth) {
    return switch (depth) {
      1 => 0,
      2 => 32.0,
      3 => 48.0,
      _ => 64.0, // depth >= 4
    };
  }

  /// Build Comic-styled action button widget with border
  Widget _buildComicActionButton({
    required BuildContext context,
    required IconData icon,
    String? label, // Make label optional
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color ?? scheme.outline,
          width: 1.0, // Comic Design: 2.0 border
        ),
        borderRadius: BorderRadius.circular(8), // Comic Design: rounded corners
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color ?? scheme.onSurface),
              if (label != null && label.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color ?? scheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Blocked(
      otherUserUid: widget.comment.firebase_uid,
      yes: () => buildBlockComment(),
      no: () => buildComment(),
    );
  }

  Widget buildBlockComment() {
    return GestureDetector(
      onTap: () {
        showUnblockDialog(
          context: context,
          otherUserUid: widget.comment.firebase_uid,
        );
      },
      child: Container(
        margin: EdgeInsets.only(left: getDepthMargin(widget.comment.depth)),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Avatar(photoUrl: widget.comment.photo_url),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${PhilgoTr.of(context)!.comment_blocked_message} ${widget.comment.nickname}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildComment() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(left: getDepthMargin(widget.comment.depth)),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                          widget.comment.nickname.isEmpty
                              ? 'No Name'
                              : cut(widget.comment.nickname, 15),
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
                    Linkify(
                      onOpen: (link) async {
                        final uri = Uri.parse(link.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                      text: widget.comment.content,
                      style: Theme.of(context).textTheme.bodyLarge,
                      linkStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(
                            height: 1.6,
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),

                    /// Show files (images, videos, and other files) attached to comments
                    if (widget.comment.files.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      PostViewFiles(
                        files: widget.comment.files,
                        postIdx: widget.comment.idx,
                      ),
                    ],

                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        /// Like button for comments with Comic design (icon only when 0)
                        _buildComicActionButton(
                          context: context,
                          icon: _isLiked
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          label: widget.comment.good > 0
                              ? '${widget.comment.good}'
                              : null,
                          color: Theme.of(context).colorScheme.primary,
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

                              _isLiked = !_isLiked;
                              setState(() {});

                              if (mounted) {
                                showSuccessSnackBar(context, 'Comment liked');
                              }
                            } catch (e) {
                              d('Error liking comment: $e');

                              // Handle already-liked error
                              if (e.toString().contains('already-liked')) {
                                if (mounted) {
                                  showErrorSnackBar(
                                    context,
                                    'Already liked this comment',
                                  );
                                }
                              }
                            }
                          },
                        ),

                        /// 답글 버튼 - 항상 표시 (Comic design, icon only)
                        _buildComicActionButton(
                          context: context,
                          icon: FontAwesomeIcons.reply,
                          label: null, // Show icon only
                          onPressed: () {
                            // Trigger reply mode in parent (PostViewScreen)
                            widget.onReplyClicked(widget.comment);
                          },
                        ),

                        /// 수정 버튼 - 내 댓글인 경우에만 표시 (Comic design)
                        if (!widget.hasReplies && widget.myComment) ...[
                          _buildComicActionButton(
                            context: context,
                            icon: FontAwesomeIcons.penToSquare,
                            onPressed: () {
                              // Trigger edit mode in parent (PostViewScreen)
                              widget.onEditClicked(widget.comment);
                            },
                          ),
                          _buildComicActionButton(
                            context: context,
                            icon: Icons.delete,
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              final confirmed = await showConfirmDialog(
                                message: PhilgoTr.of(
                                  context,
                                )!.delete_comment_confirmation,
                              );
                              if (confirmed) {
                                await func(
                                  'delete_comment_func',
                                  data: {'idx': widget.comment.idx},
                                );
                                if (mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    PhilgoTr.of(context)!.successfully_deleted,
                                  );
                                  // Notify parent widget to remove this comment from the list
                                  widget.onDeleted(widget.comment);
                                }
                              }
                            },
                          ),
                        ],
                        if (!widget.myComment) ...[
                          _buildComicActionButton(
                            context: context,
                            icon: FontAwesomeIcons.ban,
                            label: PhilgoTr.of(context)!.block,
                            onPressed: () {
                              showBlockDialog(
                                context: context,
                                otherUserUid: widget.comment.firebase_uid,
                                popOnBlocked: false,
                              );
                            },
                          ),
                          PostReportButton(
                            type: 'comment',
                            idx: widget.comment.idx,
                            comment: widget.comment,
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
      ],
    );
  }
}
