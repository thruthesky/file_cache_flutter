import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 포럼 헤더 위젯 (Forum Header Widget)
///
/// 메뉴 카테고리를 Wrap으로 여러 줄 표시 (서브카테고리 포함)
/// Displays menu categories in multiple rows using Wrap (including subcategories)
class ForumHeader extends StatelessWidget {
  /// 카테고리 선택 콜백 (postId와 subcategory를 함께 전달)
  /// Callback when category is selected (passes postId and subcategory)
  final void Function(String postId, String? category) onCategorySelected;

  /// 글쓰기 버튼 클릭 콜백
  /// Callback when create post button is pressed
  final VoidCallback? onCreatePost;

  /// 외부에서 전달된 선택된 메인 카테고리 ID (UI 동기화용)
  /// Selected main category ID passed from parent (for UI sync)
  final String? selectedPostId;

  /// 외부에서 전달된 선택된 서브카테고리 (UI 동기화용)
  /// Selected subcategory passed from parent (for UI sync)
  final String? selectedCategory;

  const ForumHeader({
    super.key,
    required this.onCategorySelected,
    this.onCreatePost,
    this.selectedPostId,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sp.s8),
        child: Wrap(
          /// 버튼 간 가로 간격
          /// Horizontal spacing between buttons
          spacing: sp.s4,

          /// 줄 간 세로 간격
          /// Vertical spacing between rows
          runSpacing: sp.s4,

          /// 왼쪽 정렬
          /// Align to start
          alignment: WrapAlignment.start,

          children: [
            /// 메뉴 카테고리 버튼 목록 (여러 줄로 표시, 서브카테고리 포함)
            /// Menu category button list (displayed in multiple rows, including subcategories)
            ...PhilgoCategory.menuCategories().map((menuItem) {
              /// 튜플에서 postId와 subcategory 추출
              /// Extract postId and subcategory from tuple
              final (postId, subcategory) = menuItem;

              /// 표시할 이름: 서브카테고리가 있으면 서브카테고리, 없으면 postId 번역
              /// Display name: subcategory if exists, otherwise translated postId
              final localizedName = subcategory ?? philgoTr(context, postId);

              /// 현재 선택된 카테고리 여부 (postId와 subcategory 모두 일치해야 함)
              /// Whether this category is currently selected (both postId and subcategory must match)
              final isSelected =
                  selectedPostId == postId && selectedCategory == subcategory;

              return TextButton(
                onPressed: () {
                  onCategorySelected.call(postId, subcategory);
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
                  visualDensity: VisualDensity.compact,
                ),

                child: Text(
                  localizedName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    /// 선택된 카테고리는 primary 색상, 아니면 기본 색상
                    /// Selected category uses primary color, otherwise default
                    color: isSelected ? scheme.primary : scheme.onSurface,

                    /// 선택된 카테고리는 bold
                    /// Selected category is bold
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }),

            /// 글쓰기 버튼 (Wrap 맨 마지막에 배치)
            /// Create post button (placed at the end of Wrap)
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
      ),
    );
  }
}
