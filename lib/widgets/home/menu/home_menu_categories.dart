import 'package:flutter/material.dart';
import 'package:philgo/screens/home/home.globals.dart';
import 'package:philgo/state/navigation.state.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 홈 메뉴 카테고리 위젯 (Home Menu Categories Widget)
///
/// PhilgoCategory.homeMenuCategories()를 Wrap으로 표시하는 위젯입니다.
/// Widget that displays PhilgoCategory.homeMenuCategories() using Wrap.
///
/// 각 카테고리를 클릭하면 ForumHome으로 이동하면서 해당 카테고리를 선택합니다.
/// Clicking each category navigates to ForumHome with that category selected.
///
/// 사용 예시:
/// ```dart
/// HomeMenuCategories()
/// ```
class HomeMenuCategories extends StatelessWidget {
  const HomeMenuCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: sp.s4),

      /// 가로 스크롤 가능한 SingleChildScrollView
      /// Horizontally scrollable SingleChildScrollView
      child: SingleChildScrollView(
        /// 가로 스크롤 방향 설정
        /// Set horizontal scroll direction
        scrollDirection: Axis.horizontal,

        /// 좌우 패딩 적용
        /// Apply left and right padding
        padding: EdgeInsets.symmetric(horizontal: sp.s8),

        child: Row(
          /// 자식 위젯들을 왼쪽부터 배치
          /// Align children from the start (left)
          mainAxisAlignment: MainAxisAlignment.start,

          /// 세로 방향 중앙 정렬
          /// Center align vertically
          crossAxisAlignment: CrossAxisAlignment.center,

          children: PhilgoCategory.homeMenuCategories().map((menuItem) {
            /// 튜플에서 postId와 subcategory 추출
            /// Extract postId and subcategory from tuple
            final (postId, subcategory) = menuItem;

            /// 표시할 이름: 서브카테고리가 있으면 서브카테고리 번역, 없으면 postId 번역
            /// Display name: translated subcategory if exists, otherwise translated postId
            final localizedName = philgoTr(context, subcategory ?? postId);

            /// InkWell + Text로 완전히 콤팩트한 버튼 구현
            /// Fully compact button using InkWell + Text (no padding/margin)
            return InkWell(
              onTap: () {
                /// ForumHome으로 이동하면서 해당 카테고리 선택
                /// Navigate to ForumHome with selected category
                final navState = NavigationState.of(context, listen: false);
                navState.data = {
                  'initialPostId': postId,
                  if (subcategory != null) 'initialCategory': subcategory,
                };
                navState.setHomeNavigation(HomeNavigationItem.forum);
              },

              /// 터치 피드백 영역을 텍스트에 맞춤
              /// Fit touch feedback area to text
              borderRadius: BorderRadius.circular(4),

              child: Container(
                /// 최소한의 패딩 (터치 영역 확보)
                /// Minimal padding (for touch area)
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                child: Text(
                  localizedName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
