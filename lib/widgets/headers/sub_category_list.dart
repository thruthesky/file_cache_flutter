import 'package:flutter/material.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 서브 카테고리 목록 위젯 (Sub Category List Widget)
///
/// 선택된 메인 카테고리의 서브 카테고리들을 가로 스크롤 목록으로 표시합니다.
/// Displays subcategories of selected main category as horizontal scroll list.
///
/// 구성:
/// - "전체" 버튼 (첫 번째 항목, category=null)
/// - 서브 카테고리 버튼들
///
/// Structure:
/// - "All" button (first item, category=null)
/// - Subcategory buttons
class SubCategoryList extends StatelessWidget {
  /// 메인 카테고리 ID
  /// Main category ID (e.g., 'buyandsell')
  final String postId;

  /// 현재 선택된 서브 카테고리 (null이면 "전체" 선택)
  /// Currently selected subcategory (null means "All" selected)
  final String? selectedCategory;

  /// 서브 카테고리 선택 콜백
  /// Callback when subcategory is selected
  final void Function(String? category) onCategorySelected;

  const SubCategoryList({
    super.key,
    required this.postId,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    /// 서브 카테고리 목록 가져오기
    /// Get subcategory list
    final subCategories = PhilgoCategory.subCategories(postId);

    /// 서브 카테고리가 없으면 빈 위젯 반환
    /// Return empty widget if no subcategories
    if (subCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: sp.s8),
      child: Row(
        children: [
          /// "전체" 버튼 (All button)
          /// 첫 번째 항목으로 표시, 선택 시 category=null
          _buildCategoryChip(
            context: context,
            label: philgoTr(context, 'all'), // 다국어 "전체" 텍스트
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),

          SizedBox(width: sp.s4),

          /// 서브 카테고리 버튼들
          /// Subcategory buttons
          ...subCategories.map((category) {
            /// 서브 카테고리 다국어 이름 가져오기
            /// Get localized subcategory name
            final localizedName = philgoTr(context, category);

            /// 현재 선택된 서브 카테고리 여부
            /// Whether this subcategory is currently selected
            final isSelected = selectedCategory == category;

            return Padding(
              padding: EdgeInsets.only(right: sp.s4),
              child: _buildCategoryChip(
                context: context,
                label: localizedName,
                isSelected: isSelected,
                onTap: () => onCategorySelected(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 카테고리 칩 빌더 (Category chip builder)
  ///
  /// ForumHeader보다 조금 더 작고 미묘한 디자인
  /// Slightly smaller and subtler design than ForumHeader
  Widget _buildCategoryChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sp.s12, vertical: sp.s4),
        decoration: BoxDecoration(
          /// 선택된 카테고리는 primary 색상 배경
          /// Selected category has primary color background
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,

          /// 둥근 모서리
          /// Rounded corners
          borderRadius: BorderRadius.circular(sp.s16),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            /// 선택된 카테고리는 primary 색상
            /// Selected category uses primary color
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,

            /// 선택된 카테고리는 bold
            /// Selected category is bold
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
