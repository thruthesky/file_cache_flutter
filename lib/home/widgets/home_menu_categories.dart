import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/globals.dart';

/// 홈 메뉴 카테고리 - 가로 스크롤 텍스트 카테고리
///
/// forumCategories에서 주요 카테고리만 추출하여 텍스트로 표시한다.
/// 탭하면 해당 게시판으로 이동한다.
class HomeMenuCategories extends StatelessWidget {
  const HomeMenuCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: Config.homeTopCategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          final (postId, category, label) = Config.homeTopCategories[index];
          return GestureDetector(
            onTap: () {
              AppNavigationState.of(
                context,
              ).openForumScreen(postId: postId, category: category);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label.tr(),
                style: text.labelMedium?.copyWith(
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
