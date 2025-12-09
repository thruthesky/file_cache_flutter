import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

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
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }),

            /// 알림 카테고리 필터 버튼
            /// Notification category filter button
            // IconButton(
            //   icon: FaIcon(
            //     FontAwesomeIcons.lightBell,
            //     color: scheme.onSurface,
            //     size: 20,
            //   ),
            //   onPressed: () {
            //     _showCategoryFilterDialog(context);
            //   },
            // ),

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

  /// 카테고리 필터 다이얼로그 표시
  /// Show category filter dialog
  // void _showCategoryFilterDialog(BuildContext context) {
  //   showDialog(context: context, builder: (context) => _CategoryFilterDialog());
  // }
}

/// 카테고리 필터 다이얼로그 (Category Filter Dialog)
///
/// 메인 카테고리와 서브 카테고리를 토글할 수 있는 다이얼로그
/// Dialog for toggling main categories and subcategories
class _CategoryFilterDialog extends StatefulWidget {
  const _CategoryFilterDialog();

  @override
  State<_CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<_CategoryFilterDialog> {
  /// 확장된 메인 카테고리 ID 목록
  /// List of expanded main category IDs
  final Set<String> _expandedCategories = {};

  /// Firebase Database 인스턴스
  /// Firebase Database instance
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// 현재 사용자 UID 가져오기
  /// Get current user UID
  String? get _currentUserUid => fa.FirebaseAuth.instance.currentUser?.uid;

  /// FCM 구독 경로 가져오기
  /// Get FCM subscription path
  String _getFcmPath(String majorId, {String? subCategory}) {
    if (subCategory != null) {
      /// '/'를 '-'로 변환 (Firebase 경로에서 '/'는 사용 불가)
      /// Replace '/' with '-' (Firebase path cannot contain '/')
      final sanitizedSubCategory = subCategory.replaceAll('/', '-');
      return 'fcm-subscriptions/-forum-$majorId-$sanitizedSubCategory';
    }
    return 'fcm-subscriptions/-forum-$majorId';
  }

  /// Firebase에서 구독 상태 토글
  /// Toggle subscription state in Firebase
  Future<void> _toggleSubscription(
    String majorId, {
    String? subCategory,
  }) async {
    if (_currentUserUid == null) return;

    final path = _getFcmPath(majorId, subCategory: subCategory);
    final ref = _database.ref('$path/$_currentUserUid');

    try {
      final snapshot = await ref.get();
      final currentValue = snapshot.value as bool?;

      /// 현재 값의 반대로 설정 (true ↔ false)
      /// Set to opposite of current value (true ↔ false)
      await ref.set(!(currentValue ?? false));
    } catch (e) {
      debugPrint('Error toggling subscription: $e');
    }
  }

  /// Firebase에서 구독 상태 스트림 가져오기
  /// Get subscription state stream from Firebase
  Stream<bool> _getSubscriptionStream(String majorId, {String? subCategory}) {
    if (_currentUserUid == null) {
      return Stream.value(false);
    }

    final path = _getFcmPath(majorId, subCategory: subCategory);
    final ref = _database.ref('$path/$_currentUserUid');

    return ref.onValue.map((event) {
      if (!event.snapshot.exists) return false;
      return event.snapshot.value as bool? ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    return Dialog(
      /// Flat design - elevation 0
      elevation: 0,
      backgroundColor: scheme.surface,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        padding: EdgeInsets.all(sp.s16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 다이얼로그 헤더
            /// Dialog header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  philgoTr(context, 'category_filter'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: FaIcon(
                    FontAwesomeIcons.lightXmark,
                    color: scheme.onSurface,
                    size: 20,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            SizedBox(height: sp.s16),

            /// 카테고리 목록
            /// Category list
            Expanded(
              child: ListView(
                children:
                    PhilgoCategory.majorCategories(includeTemp: kDebugMode).map(
                      (majorId) {
                        return _buildMajorCategoryItem(
                          context,
                          majorId,
                          scheme,
                          sp,
                        );
                      },
                    ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 메인 카테고리 아이템 빌드
  /// Build main category item
  Widget _buildMajorCategoryItem(
    BuildContext context,
    String majorId,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final theme = Theme.of(context);
    final localizedName = philgoTr(context, majorId);
    final hasSubCategories = PhilgoCategory.hasSubCategories(majorId);
    final isExpanded = _expandedCategories.contains(majorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 메인 카테고리 행 (서브 카테고리가 없을 때만 StreamBuilder 사용)
        /// Main category row (use StreamBuilder only if no subcategories)
        if (!hasSubCategories)
          StreamBuilder<bool>(
            stream: _getSubscriptionStream(majorId),
            builder: (context, snapshot) {
              final isSelected = snapshot.data ?? false;

              return InkWell(
                /// 서브 카테고리가 없으면 토글
                /// If no subcategories, toggle selection
                onTap: () => _toggleSubscription(majorId),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sp.s8,
                    vertical: sp.s12,
                  ),
                  child: Row(
                    children: [
                      /// 체크박스 아이콘
                      /// Checkbox icon
                      FaIcon(
                        isSelected
                            ? FontAwesomeIcons.solidSquareCheck
                            : FontAwesomeIcons.lightSquare,
                        color: isSelected
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        size: 20,
                      ),

                      SizedBox(width: sp.s12),

                      /// 카테고리 이름
                      /// Category name
                      Expanded(
                        child: Text(
                          localizedName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isSelected
                                ? scheme.primary
                                : scheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        /// 메인 카테고리 행 (서브 카테고리가 있을 때)
        /// Main category row (when has subcategories)
        if (hasSubCategories)
          InkWell(
            /// 서브 카테고리가 있으면 펼침/접힘만
            /// If has subcategories, only expand/collapse
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCategories.remove(majorId);
                } else {
                  _expandedCategories.add(majorId);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sp.s8,
                vertical: sp.s12,
              ),
              child: Row(
                children: [
                  /// 카테고리 이름
                  /// Category name
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: sp.s8),
                      child: Text(
                        localizedName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  /// 펼침/접힘 아이콘
                  /// Expand/collapse chevron icon
                  FaIcon(
                    isExpanded
                        ? FontAwesomeIcons.lightChevronUp
                        : FontAwesomeIcons.lightChevronDown,
                    color: scheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

        /// 서브 카테고리 목록 (확장되었을 때만 표시)
        /// Subcategory list (only show when expanded)
        if (hasSubCategories && isExpanded)
          Padding(
            padding: EdgeInsets.only(left: sp.s32),
            child: _buildSubCategoryList(context, majorId, scheme, sp),
          ),

        /// 구분선
        /// Divider
        Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ],
    );
  }

  /// 서브 카테고리 목록 빌드
  /// Build subcategory list
  Widget _buildSubCategoryList(
    BuildContext context,
    String majorId,
    ColorScheme scheme,
    AppSpacing sp,
  ) {
    final theme = Theme.of(context);
    final subCategories = PhilgoCategory.subCategories(majorId);

    return Column(
      children: subCategories.map((subCategory) {
        final localizedName = philgoTr(context, subCategory);

        return StreamBuilder<bool>(
          stream: _getSubscriptionStream(majorId, subCategory: subCategory),
          builder: (context, snapshot) {
            final isSelected = snapshot.data ?? false;

            return InkWell(
              onTap: () =>
                  _toggleSubscription(majorId, subCategory: subCategory),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sp.s8,
                  vertical: sp.s8,
                ),
                child: Row(
                  children: [
                    /// 체크박스 아이콘
                    /// Checkbox icon
                    FaIcon(
                      isSelected
                          ? FontAwesomeIcons.solidSquareCheck
                          : FontAwesomeIcons.lightSquare,
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      size: 16,
                    ),

                    SizedBox(width: sp.s12),

                    /// 서브 카테고리 이름
                    /// Subcategory name
                    Expanded(
                      child: Text(
                        localizedName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
