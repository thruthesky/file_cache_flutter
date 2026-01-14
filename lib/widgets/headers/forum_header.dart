import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/widgets/headers/forum_header.notification_icon_button.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:philgo/screens/search/search.screen.dart';
import 'package:philgo/widgets/dialogs/search_dialog.dart';

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

    /// 확장 상태에 따른 조건부 스타일 변수 (컴팩트 + 현대적)
    /// Conditional style variables based on expansion state (compact + modern)
    ///
    /// 확장 시: 미세한 증가만 + 배경색 레이어링으로 현대적 chip 스타일
    /// When expanded: Minimal increase + background layering for modern chip style
    ///
    /// 축소 시: 완전히 컴팩트한 디자인 유지
    /// When collapsed: Keep fully compact design
    final buttonSpacing = _isExpanded ? 3.0 : 2.0; // 1만 증가
    final buttonPadding = _isExpanded
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) // 미세한 증가
        : const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
    final buttonRadius = _isExpanded ? 8.0 : 4.0; // 더 현대적인 모서리

    return SafeArea(
      /// 좌/우/하단 safe area 여백 비활성화 (가장자리에 붙이기 위함)
      /// Disable left/right/bottom safe area padding (to stick to edges)
      left: false,
      right: false,
      bottom: false,
      child: Wrap(
        /// 버튼 간 가로 간격 (확장 시: 3, 축소 시: 2)
        /// Horizontal spacing between buttons (expanded: 3, collapsed: 2)
        spacing: buttonSpacing,

        /// 줄 간 세로 간격 (확장 시: 3, 축소 시: 2)
        /// Vertical spacing between rows (expanded: 3, collapsed: 2)
        runSpacing: buttonSpacing,

        /// 왼쪽 정렬
        /// Align to start
        alignment: WrapAlignment.start,

        /// 세로 정렬 (중앙)
        /// Vertical alignment (center)
        crossAxisAlignment: WrapCrossAlignment.center,

        children: [
          /// 검색 항목 (Search item)
          /// 카테고리 목록 맨 앞에 배치
          /// 클릭 시 검색 다이얼로그 오픈 → 검색어 입력 → 검색 화면 이동
          InkWell(
            onTap: () async {
              final searchTerm = await SearchDialog.show(context);
              if (searchTerm != null && searchTerm.isNotEmpty && context.mounted) {
                SearchScreen.push(context, searchTerm);
              }
            },
            borderRadius: BorderRadius.circular(buttonRadius),
            child: Container(
              decoration: BoxDecoration(
                color: _isExpanded
                    ? scheme.surfaceContainerLowest
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              padding: buttonPadding,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// 검색 아이콘 (카테고리와 동일한 스타일)
                  /// Search icon (same style as categories)
                  FaIcon(
                    FontAwesomeIcons.lightMagnifyingGlass,
                    size: 12,
                    color: scheme.onSurface,
                  ),
                  const SizedBox(width: 4),

                  /// 검색 텍스트 (카테고리와 동일한 스타일)
                  /// Search text (same style as categories)
                  Text(
                    lo.searchHint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),

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

            /// InkWell + Container로 컴팩트하면서 현대적인 버튼 구현
            /// Compact yet modern button using InkWell + Container
            ///
            /// 확장 시: 모든 항목에 배경색 적용 (chip 스타일)
            /// When expanded: Apply background to all items (chip style)
            return InkWell(
              onTap: () {
                widget.onCategorySelected.call(postId, subcategory);
              },

              /// 터치 피드백 영역을 Container와 동일한 borderRadius로 맞춤
              /// Match touch feedback area to Container's borderRadius
              borderRadius: BorderRadius.circular(buttonRadius),

              child: Container(
                /// 배경색 로직 (핵심!)
                /// Background color logic (core!)
                ///
                /// 확장 시: 모든 항목에 배경 적용 (선택 시 진한 primary, 비선택 시 미세한 배경)
                /// When expanded: Apply background to all (selected: darker primary, unselected: subtle bg)
                ///
                /// 축소 시: 선택된 항목만 배경 적용
                /// When collapsed: Apply background only to selected items
                decoration: BoxDecoration(
                  color: _isExpanded
                      ? (isSelected
                          ? scheme.primary
                              .withValues(alpha: 0.12) // 확장 시 선택: 약간 더 진하게
                          : scheme
                              .surfaceContainerLowest) // 확장 시 비선택: 미세한 배경
                      : (isSelected
                          ? scheme.primary
                              .withValues(alpha: 0.1) // 축소 시 선택: 현재 그대로
                          : Colors.transparent), // 축소 시 비선택: 투명
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),

                /// 확장 상태에 따른 패딩 (확장 시: 미세하게 증가)
                /// Padding based on expansion state (expanded: slightly increased)
                padding: buttonPadding,

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

          ForumHeaderNotificationIconButton(),

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
          // InkWell(
          //   onTap: widget.onCreatePost,
          //   borderRadius: BorderRadius.circular(4),
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          //     child: RichText(
          //       text: TextSpan(
          //         /// 기본 스타일: onSurface 색상 + bold 강조
          //         /// Base style: onSurface color + bold emphasis
          //         style: theme.textTheme.bodyMedium?.copyWith(
          //           color: scheme.onSurface,
          //           fontWeight: FontWeight.bold,
          //         ),
          //         children: [
          //           /// 플러스 아이콘 (FaIcon 사용)
          //           /// Plus icon (using FaIcon)
          //           WidgetSpan(
          //             alignment: PlaceholderAlignment.middle,
          //             child: FaIcon(
          //               FontAwesomeIcons.plus,
          //               size: 12,
          //               color: scheme.onSurface,
          //             ),
          //           ),

          //           /// 공백 + 텍스트 "글 쓰기"
          //           /// Space + text "글 쓰기"
          //           TextSpan(text: ' ${lo.writePost}'),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
