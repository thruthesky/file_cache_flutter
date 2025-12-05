import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Opinionated comment detail list view for post view screen.
/// It does things as much as it can for the comment listing
class CommentDetailListView extends StatelessWidget {
  const CommentDetailListView({
    super.key,
    required this.noOfComment,
    required this.isLoading,
    required this.post,
    required this.onReplied,
    required this.onUpdated,
    required this.onDeleted,
    required this.myComment,
    required this.onReplyClicked,
    required this.onEditClicked,
  });

  final int noOfComment;
  final bool isLoading;
  final Post? post;
  final Function(Comment) onReplied;
  final Function(Comment, Comment) onUpdated;
  final Function(Comment) onDeleted;
  final bool Function(int idxMember) myComment;
  final Function(Comment) onReplyClicked;
  final Function(Comment) onEditClicked;

  bool hasReplies(Comment comment) {
    return post!.comments.any(
      (c) => c.idx_parent == comment.idx,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator.adaptive())
        else if (post?.comments.isNotEmpty == true)
          ...post!.comments.map(
            (comment) => CommentDetail(
              myComment: myComment(comment.idx_member),
              hasReplies: hasReplies(comment),
              comment: comment,
              onReplied: onReplied,
              onUpdated: (updatecomment) => onUpdated(comment, updatecomment),
              onDeleted: onDeleted,
              onReplyClicked: onReplyClicked,
              onEditClicked: onEditClicked,
            ),
          )
        else
          Text(LibTr.of(context)!.beTheFirstToComment),
      ],
    );
  }
}
