import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// Post title text widget
class PostSubject extends StatelessWidget {
  const PostSubject({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 제목을 진한 검정색으로 표시
    /// normal 폰트 무게로 깔끔한 느낌
    return Text(
      post.subject,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.normal,
        color: scheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
