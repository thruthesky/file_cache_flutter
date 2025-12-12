import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// Post title text widget
class PostSubject extends StatelessWidget {
  const PostSubject({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      post.subject,
      style: theme.textTheme.titleLarge,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
