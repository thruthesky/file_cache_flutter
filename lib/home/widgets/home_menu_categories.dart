import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/search/search_dialog.dart';
import 'package:philgo/search/search.screen.dart';

/// 홈 메뉴 카테고리 - 가로 스크롤 텍스트 카테고리 + 검색 아이콘
///
/// forumCategories에서 주요 카테고리만 추출하여 텍스트로 표시한다.
/// 탭하면 해당 게시판으로 이동한다. 우측 끝에 검색 아이콘을 표시한다.
class HomeMenuCategories extends StatelessWidget {
  const HomeMenuCategories({super.key});

  @override
  Widget build(BuildContext context) {
    // +1 for the search item at the end
    final totalCount = Config.homeTopCategories.length + 1;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: totalCount,
        separatorBuilder: (_, _) => const SizedBox(width: 0),
        itemBuilder: (context, index) {
          // 마지막 아이템: 검색 버튼
          if (index == totalCount - 1) {
            return GestureDetector(
              onTap: () async {
                final searchTerm = await SearchDialog.show(context);
                if (searchTerm != null && context.mounted) {
                  SearchScreen.push(context, searchTerm);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightMagnifyingGlass,
                      size: 14,
                      color: color.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '검색'.tr(),
                      style: text.labelMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 카테고리 아이템
          final (postId, category, label) =
              Config.homeTopCategories[index];
          return GestureDetector(
            onTap: () {
              AppNavigationState.of(
                context,
              ).openForumScreen(postId: postId, category: category);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
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
