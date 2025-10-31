import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Opinionated comment detail list view for post view screen.
/// It does things as much as it can for the comment listing
class CommentDetailListView extends StatelessWidget {
  const CommentDetailListView({
    super.key,
    required this.noOfComment,
    required this.isLoading,
    required this.postDetails,
    required this.onReplied,
    required this.onUpdated,
  });

  final int noOfComment;
  final bool isLoading;
  final Post? postDetails;
  final Function(Comment) onReplied;
  final Function(Comment, Comment) onUpdated;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            FaIcon(
              FontAwesomeIcons.solidMessageDots,
              size: 24,
              color: Colors.black,
            ),
            SizedBox(width: 16),
            Text(
              LibTr.of(context)!.comment,
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                noOfComment.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        if (isLoading)
          const Center(child: CircularProgressIndicator.adaptive())
        else if (postDetails?.comments.isNotEmpty == true)
          ...postDetails!.comments.map(
            (comment) => CommentDetail(
              comment: comment,
              onReplied: onReplied,
              onUpdated: (updatecomment) => onUpdated(comment, updatecomment),
            ),
          )
        else
          Text(LibTr.of(context)!.beTheFirstToComment),
      ],
    );
  }
}
