import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/state/forum.state.dart';

class ForumCategoryHeader extends StatelessWidget {
  const ForumCategoryHeader({super.key, this.totalPostCount});

  final int? totalPostCount;

  String get label => HomePostCategory.label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: RichText(
        text: TextSpan(
          children: [
            // 카테고리 레이블 - titleMedium 스타일 적용
            TextSpan(
              text: label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            // 띄어쓰기 추가
            const TextSpan(text: ' '),
            // 게시글 수 - bodyMedium 스타일 사용
            TextSpan(
              text: T.noOfPosts(totalPostCount ?? 0),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                // 게시글 수를 약간 다른 색상으로 표시하여 구분
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
