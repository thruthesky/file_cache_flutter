import 'package:flutter/material.dart';

class PostViewContent extends StatelessWidget {
  const PostViewContent({
    super.key,
    required this.isLoading,
    required this.content,
  });

  final bool isLoading;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator.adaptive())
        else
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    );
  }
}
