import 'package:flutter/material.dart';

// import 'dart:developer';
import 'package:philgo/screens/post/post.create.screen.dart';
import 'package:v6_apps/v6_apps.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ForumNoItems extends StatelessWidget {
  const ForumNoItems({super.key, required this.onCreated});

  final Future<void> Function(Post) onCreated;

  @override
  Widget build(BuildContext context) {
    return Container(
      // 전체 영역을 채우고 중앙 정렬
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 빈 게시판 아이콘
            FaIcon(
              FontAwesomeIcons.solidFolderOpen,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),

            // 메인 메시지 - 게시글이 없습니다
            Text(
              LibTr.of(context)!.no_posts_in_category,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // 서브 메시지 - 첫 게시글을 작성해보세요
            Text(
              LibTr.of(context)!.be_first_to_post,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 게시글 작성 버튼
            ElevatedButton.icon(
              onPressed: () async {
                final post = await PostCreateScreen.push(context);
                debugLog('post: $post');
                if (post != null) {
                  await onCreated(post);
                }
              },
              icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
              label: Text(
                LibTr.of(context)!.create_post,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                // 버튼 패딩과 크기 조정
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                // Theme의 primary 색상 사용
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
