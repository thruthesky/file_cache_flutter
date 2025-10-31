import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class CommentListView extends StatefulWidget {
  final Post post;

  const CommentListView({super.key, required this.post});

  @override
  State<StatefulWidget> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<CommentListView> {
  @override
  Widget build(BuildContext context) {
    final hasComments = widget.post.comments.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          TextField(
            minLines: 1,
            maxLines: 2,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "Enter your comment...",
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const FaIcon(FontAwesomeIcons.paperPlaneTop),
              ),
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              FaIcon(
                FontAwesomeIcons.solidMessageDots,
                size: 24,
                color: Colors.black,
              ),
              SizedBox(width: 16),
              Text(
                "Comments",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.post.no_of_comment.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (hasComments)
            Text("This post has comments")
          else
            Text("Be the first to comment!"),
        ],
      ),
    );
  }
}
