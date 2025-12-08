import 'package:flutter/material.dart';

import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyPostList extends StatelessWidget {
  const EmptyPostList({super.key});

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
              size: 40,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),

            // 메인 메시지 - 게시글이 없습니다
            Text(
              PhilgoTr.of(context)!.no_posts_in_category,
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
              PhilgoTr.of(context)!.be_first_to_post,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
