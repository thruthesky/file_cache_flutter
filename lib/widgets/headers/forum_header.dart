import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 포럼 헤더 위젯 (Forum Header Widget)
///
/// 주요 카테고리를 가로 스크롤 가능한 TextButton 목록으로 표시
/// Displays major categories as horizontally scrollable TextButton list
class ForumHeader extends StatelessWidget {
  /// 카테고리 선택 콜백
  /// Callback when category is selected
  final void Function(String postId) onCategorySelected;

  /// 글쓰기 버튼 클릭 콜백
  /// Callback when create post button is pressed
  final VoidCallback? onCreatePost;

  /// 외부에서 전달된 선택된 카테고리 ID (UI 동기화용)
  /// Selected category ID passed from parent (for UI sync)
  final String? selectedPostId;

  const ForumHeader({
    super.key,
    required this.onCategorySelected,
    this.onCreatePost,
    this.selectedPostId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return SafeArea(
      child: Row(
        children: [
          /// 카테고리 목록 (가로 스크롤)
          /// Category list (horizontal scroll)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: sp.s8),
              child: Row(
                children: PhilgoCategory.majorCategories(includeTemp: kDebugMode).map((
                  postId,
                ) {
                  /// 카테고리 다국어 이름 가져오기 (philgoTr 사용)
                  /// Get localized category name (using philgoTr)
                  final localizedName = philgoTr(context, postId);

                  /// 현재 선택된 카테고리 여부 (외부에서 전달된 값 사용)
                  /// Whether this category is currently selected (use value from parent)
                  final isSelected = selectedPostId == postId;

                  return Padding(
                    padding: EdgeInsets.only(right: sp.s4),
                    child: TextButton(
                      onPressed: () {
                        onCategorySelected.call(postId);
                      },
                      style: TextButton.styleFrom(
                        /// 선택된 카테고리는 primary 색상 배경 적용
                        /// Apply primary background for selected category
                        backgroundColor: isSelected
                            ? scheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,

                        /// 패딩 최소화
                        /// Minimize padding
                        padding: EdgeInsets.symmetric(
                          horizontal: sp.s12,
                          vertical: sp.s8,
                        ),

                        /// elevation 0 (Flat Design)
                        elevation: 0,
                      ),
                      child: Text(
                        localizedName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          /// 선택된 카테고리는 primary 색상, 아니면 기본 색상
                          /// Selected category uses primary color, otherwise default
                          color: isSelected ? scheme.primary : scheme.onSurface,

                          /// 선택된 카테고리는 bold
                          /// Selected category is bold
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// 글쓰기 버튼
          /// Create post button
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.lightPlusLarge,
              color: scheme.onSurface,
              size: 20,
            ),
            onPressed: onCreatePost,
          ),
        ],
      ),
    );
  }
}
