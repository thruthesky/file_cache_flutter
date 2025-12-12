import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo_api/philgo_api.dart';

/// 포럼 헤더 위젯 (Forum Header Widget)
///
/// 메뉴 카테고리를 Wrap으로 여러 줄 표시 (서브카테고리 포함)
/// Displays menu categories in multiple rows using Wrap (including subcategories)
///
/// 더보기/숨기기 토글 기능 포함
/// Includes show more/hide toggle functionality
class ForumHeader extends StatefulWidget {
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
  State<ForumHeader> createState() => _ForumHeaderState();
}

class _ForumHeaderState extends State<ForumHeader> {
  /// 카테고리 목록 확장 상태 (false: 12개만 표시, true: 전체 표시)
  /// Category list expansion state (false: show 12 only, true: show all)
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lo = Lo.of(context)!;

    /// 전체 카테고리 목록 가져오기
    /// Get all categories list
    final allCategories = PhilgoCategory.menuCategories(
      includeTemp: isDeveloperModeEnabled,
    );

    /// 확장 상태에 따라 표시할 카테고리 결정 (축소: 12개, 확장: 전체)
    /// Determine categories to show based on expansion state (collapsed: 12, expanded: all)
    final categoriesToShow = _isExpanded
        ? allCategories
        : allCategories.take(12);

    return SafeArea(
      /// 좌/우/하단 safe area 여백 비활성화 (가장자리에 붙이기 위함)
      /// Disable left/right/bottom safe area padding (to stick to edges)
      left: false,
      right: false,
      bottom: false,
      child: Wrap(
        /// 버튼 간 가로 간격 (최소화)
        /// Horizontal spacing between buttons (minimized)
        spacing: 2,

        /// 줄 간 세로 간격 (최소화)
        /// Vertical spacing between rows (minimized)
        runSpacing: 2,

        /// 왼쪽 정렬
        /// Align to start
        alignment: WrapAlignment.start,

        /// 세로 정렬 (중앙)
        /// Vertical alignment (center)
        crossAxisAlignment: WrapCrossAlignment.center,

        children: [
          /// 메뉴 카테고리 버튼 목록 (여러 줄로 표시, 서브카테고리 포함)
          /// Menu category button list (displayed in multiple rows, including subcategories)
          ...categoriesToShow.map((menuItem) {
            /// 튜플에서 postId와 subcategory 추출
            /// Extract postId and subcategory from tuple
            final (postId, subcategory) = menuItem;

            /// 표시할 이름: 서브카테고리가 있으면 서브카테고리 번역, 없으면 postId 번역
            /// Display name: translated subcategory if exists, otherwise translated postId
            final localizedName = philgoTr(context, subcategory ?? postId);

            /// 현재 선택된 카테고리 여부 (postId와 subcategory 모두 일치해야 함)
            /// Whether this category is currently selected (both postId and subcategory must match)
            final isSelected =
                widget.selectedPostId == postId &&
                widget.selectedCategory == subcategory;

            /// InkWell + Text로 완전히 콤팩트한 버튼 구현
            /// Fully compact button using InkWell + Text (no padding/margin)
            return InkWell(
              onTap: () {
                widget.onCategorySelected.call(postId, subcategory);
              },

              /// 터치 피드백 영역을 텍스트에 맞춤
              /// Fit touch feedback area to text
              borderRadius: BorderRadius.circular(4),

              child: Container(
                /// 선택된 카테고리는 primary 색상 배경 적용
                /// Apply primary background for selected category
                decoration: BoxDecoration(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),

                /// 최소한의 패딩 (터치 영역 확보)
                /// Minimal padding (for touch area)
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

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
          }),

          /// 더보기/숨기기 토글 버튼
          /// Show more/Hide toggle button
          ///
          /// 클릭 시 카테고리 목록 확장/축소 상태 토글
          /// Toggle category list expansion/collapse state on click
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: RichText(
                text: TextSpan(
                  /// 기본 스타일: primary 색상 + bold 강조
                  /// Base style: primary color + bold emphasis
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    /// 텍스트: 확장 시 "숨기기", 축소 시 "더보기"
                    /// Text: "Hide" when expanded, "View More" when collapsed
                    TextSpan(text: _isExpanded ? lo.showLess : lo.viewMore),

                    /// 공백 추가 (아이콘 앞 여백)
                    /// Add space (margin before icon)
                    const TextSpan(text: ' '),

                    /// 화살표 아이콘: 확장 시 "<<", 축소 시 ">>"
                    /// Arrow icon: "<<" when expanded, ">>" when collapsed
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: FaIcon(
                        _isExpanded
                            ? FontAwesomeIcons.anglesLeft
                            : FontAwesomeIcons.anglesRight,
                        size: 12,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 글쓰기 버튼 (Wrap 맨 마지막에 배치, 콤팩트)
          /// Create post button (placed at the end of Wrap, compact)
          ///
          /// FaIcon + RichText로 "[+] 글 쓰기" 형태로 표시
          /// Display as "[+] 글 쓰기" format using FaIcon + RichText
          InkWell(
            onTap: widget.onCreatePost,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: RichText(
                text: TextSpan(
                  /// 기본 스타일: onSurface 색상 + bold 강조
                  /// Base style: onSurface color + bold emphasis
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    /// 플러스 아이콘 (FaIcon 사용)
                    /// Plus icon (using FaIcon)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: FaIcon(
                        FontAwesomeIcons.plus,
                        size: 12,
                        color: scheme.onSurface,
                      ),
                    ),

                    /// 공백 + 텍스트 "글 쓰기"
                    /// Space + text "글 쓰기"
                    TextSpan(text: ' ${lo.writePost}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 카테고리 필터 다이얼로그 표시
  /// Show category filter dialog
  // void _showCategoryFilterDialog(BuildContext context) {
  //   showDialog(context: context, builder: (context) => _CategoryFilterDialog());
  // }
}
