/// UI/UX 관련 함수
/// UI/UX related functions
library;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// 글쓰기 다이얼로그 표시
/// Shows PostCreateForm dialog using showGeneralDialog
///
/// [context] BuildContext for dialog
/// [postId] Main category ID (e.g., 'freetalk', 'buyandsell')
/// [category] Sub-category (optional, null if no sub-category)
/// [onSubmitted] Callback when post is successfully created (optional)
///
/// 사용 예시 / Usage example:
/// ```dart
/// showPostCreateDialog(
///   context,
///   postId: 'freetalk',
///   category: null,
///   onSubmitted: (post) {
///     // 글 생성 후 목록
///     pagingController.refresh();
///   },
/// );
/// ```
void showPostCreateDialog(
  BuildContext context, {
  required String postId,
  String? category,
  void Function(Post post)? onSubmitted,
}) {
  /// Navigator.push를 사용하여 전체 화면으로 표시
  /// Use Navigator.push for full-screen display
  Navigator.of(context).push(
    PageRouteBuilder(
      /// 전체 화면 라우트 설정
      /// Full-screen route configuration
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return _PostCreateScreen(
          postId: postId,
          category: category,
          onSubmitted: onSubmitted,
        );
      },

      /// 슬라이드 애니메이션 (하단에서 위로)
      /// Slide animation (from bottom to top)
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

/// 글쓰기 전체 화면 위젯
/// Full-screen post creation widget
class _PostCreateScreen extends StatefulWidget {
  final String postId;
  final String? category;
  final void Function(Post post)? onSubmitted;

  const _PostCreateScreen({
    required this.postId,
    this.category,
    this.onSubmitted,
  });

  @override
  State<_PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<_PostCreateScreen> {
  /// GlobalKey로 외부에서 폼 상태 접근
  /// Access form state externally via GlobalKey
  final formKey = GlobalKey<PostCreateFormState>();

  /// 선택된 서브 카테고리 (드롭다운에서 변경 가능)
  /// Selected sub-category (changeable via dropdown)
  String? _selectedCategory;

  /// 로딩 및 업로드 상태 추적
  /// Track loading and upload progress
  bool isLoading = false;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();

    /// 전달된 category 값으로 초기화
    /// Initialize with the passed category value
    _selectedCategory = widget.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 메인 카테고리의 다국어 이름 가져오기 (philgoTr 사용)
    /// Get localized name for main category (using philgoTr)
    final localizedMainCategory = philgoTr(context, widget.postId);

    /// 서브 카테고리 존재 여부 확인
    /// Check if sub-categories exist
    final hasSubCategories = PhilgoCategory.hasSubCategories(widget.postId);

    /// 서브 카테고리 목록 가져오기
    /// Get sub-category list
    final subCategories = hasSubCategories
        ? PhilgoCategory.subCategories(widget.postId)
        : <String>[];

    return Scaffold(
      /// AppBar - Comic Design 스타일 적용 (elevation 0)
      /// AppBar with Comic Design style (elevation 0)
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 메인 카테고리 표시
            /// Display main category
            Text(localizedMainCategory),

            /// 서브 카테고리가 있는 경우 드롭다운 표시
            /// Show dropdown if sub-categories exist
            if (hasSubCategories) ...[
              /// 메인카테고리와 서브카테고리 사이 구분 아이콘
              /// Separator icon between main and sub category
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

              /// 서브 카테고리 선택 드롭다운 (강조 표시) - Flexible로 감싸서 overflow 방지
              /// Sub-category selection dropdown (highlighted) - Wrapped in Flexible to prevent overflow
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),

                  /// 배경색과 테두리로 강조 - primary 색상 적용
                  /// Highlight with background and border - primary color applied
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),

                    /// 1px 테두리 추가로 시각적 강조
                    /// Add 1px border for visual emphasis
                    border: Border.all(color: scheme.primary, width: 1),
                  ),
                  child: DropdownButton<String?>(
                    value: _selectedCategory,

                    /// 드롭다운 스타일 - Flat design (underline 제거)
                    /// Dropdown style - Flat design (remove underline)
                    underline: const SizedBox.shrink(),
                    isDense: true,

                    /// isExpanded로 부모 제약을 따르며 텍스트 오버플로우 처리
                    /// isExpanded to follow parent constraints and handle text overflow
                    isExpanded: true,

                    icon: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: FaIcon(
                        FontAwesomeIcons.lightChevronDown,
                        size: 12,
                        color: scheme.primary,
                      ),
                    ),

                    /// 선택된 값 스타일 - primary 색상과 bold로 강조
                    /// Selected value style - highlighted with primary color and bold
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),

                    /// 드롭다운 아이템: null(전체) + 서브카테고리 목록
                    /// Dropdown items: null(All) + sub-category list
                    items: [
                      /// "전체" 옵션 (category = null)
                      /// "All" option (category = null)
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          philgoTr(context, 'all'),
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: scheme.onSurface),
                        ),
                      ),

                      /// 서브 카테고리 목록
                      /// Sub-category list
                      ...subCategories.map(
                        (cat) => DropdownMenuItem<String?>(
                          value: cat,
                          child: Text(
                            philgoTr(context, cat),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: scheme.onSurface),
                          ),
                        ),
                      ),
                    ],

                    /// 카테고리 선택 시 상태 업데이트
                    /// Update state when category is selected
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        ),

        /// 닫기 버튼
        /// Close button
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outline),
        ),
      ),

      /// PostCreateForm - 재사용 가능한 글쓰기 폼
      /// PostCreateForm - reusable post creation form
      body: PostCreateForm(
        key: formKey,
        postId: widget.postId,

        /// 드롭다운에서 선택된 서브 카테고리 전달
        /// Pass the selected sub-category from dropdown
        category: _selectedCategory,

        /// AppBar에서 제출 버튼을 처리하므로 폼 내부 버튼 숨김
        /// Hide form's internal submit button (handled by AppBar)
        showSubmitButton: true,

        /// 로딩 상태 변경 콜백
        /// Loading status change callback
        onLoadingChanged: (loading) {
          setState(() {
            isLoading = loading;
          });
        },

        /// 업로드 상태 변경 콜백
        /// Upload status change callback
        onUploadingChanged: (uploading) {
          setState(() {
            isUploading = uploading;
          });
        },

        /// 제출 성공 시 화면 닫고 PostViewScreen으로 이동
        /// Close screen on successful submission and navigate to PostViewScreen
        onSubmitted: (post) {
          Navigator.pop(context);

          // Navigate to PostViewScreen to show the created post
          PostViewScreen.push(context, post);

          // Call external callback if provided
          widget.onSubmitted?.call(post);
        },
      ),
    );
  }
}

/// 글 수정 다이얼로그 표시
/// Shows PostUpdateScreen using Navigator.push
///
/// [context] BuildContext for navigation
/// [post] The post to update
/// [onUpdated] Callback when post is successfully updated (optional)
///
/// 사용 예시 / Usage example:
/// ```dart
/// showPostUpdateDialog(
///   context,
///   post: myPost,
///   onUpdated: (updatedPost) {
///     // 글 수정 후 처리
///   },
/// );
/// ```
Future<Post?> showPostUpdateDialog(
  BuildContext context, {
  required Post post,
  void Function(Post post)? onUpdated,
}) async {
  /// Navigator.push를 사용하여 전체 화면으로 표시
  /// Use Navigator.push for full-screen display
  final result = await Navigator.of(context).push<Post>(
    PageRouteBuilder(
      /// 전체 화면 라우트 설정
      /// Full-screen route configuration
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return _PostUpdateScreen(post: post, onUpdated: onUpdated);
      },

      /// 슬라이드 애니메이션 (하단에서 위로)
      /// Slide animation (from bottom to top)
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );

  return result;
}

/// 글 수정 전체 화면 위젯
/// Full-screen post update widget
class _PostUpdateScreen extends StatefulWidget {
  final Post post;
  final void Function(Post post)? onUpdated;

  const _PostUpdateScreen({required this.post, this.onUpdated});

  @override
  State<_PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<_PostUpdateScreen> {
  /// GlobalKey로 외부에서 폼 상태 접근
  /// Access form state externally via GlobalKey
  final formKey = GlobalKey<PostUpdateFormState>();

  /// 로딩 및 업로드 상태 추적
  /// Track loading and upload progress
  bool isLoading = false;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 메인 카테고리의 다국어 이름 가져오기
    /// Get localized name for main category
    final localizedMainCategory = philgoTr(context, widget.post.post_id);

    /// 서브 카테고리 존재 여부 확인
    /// Check if the post has a sub-category
    final category = widget.post.category;
    final hasSubCategory = category.isNotEmpty;

    return Scaffold(
      /// AppBar - Comic Design 스타일 적용 (elevation 0)
      /// AppBar with Comic Design style (elevation 0)
      appBar: AppBar(
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 메인 카테고리 표시
            /// Display main category
            Text(localizedMainCategory),

            /// 서브 카테고리가 있는 경우 표시
            /// Show sub-category if exists
            if (hasSubCategory) ...[
              /// 메인카테고리와 서브카테고리 사이 구분 아이콘
              /// Separator icon between main and sub category
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FaIcon(
                  FontAwesomeIcons.lightChevronRight,
                  size: 14,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),

              /// 서브 카테고리 표시 (강조 표시) - Flexible로 감싸서 overflow 방지
              /// Sub-category display (highlighted) - Wrapped in Flexible to prevent overflow
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),

                  /// 배경색과 테두리로 강조 - primary 색상 적용
                  /// Highlight with background and border - primary color applied
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.primary, width: 1),
                  ),
                  child: Text(
                    philgoTr(context, category),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),

        /// 닫기 버튼
        /// Close button
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.lightXmark, color: scheme.onSurface),
          onPressed: () async {
            /// 변경 사항이 있는지 확인
            /// Check if there are changes
            final hasChanges = formKey.currentState?.hasChanges() ?? false;

            if (!hasChanges) {
              Navigator.pop(context);
              return;
            }

            /// 변경 사항이 있으면 확인 다이얼로그 표시
            /// Show confirmation dialog if there are changes
            final confirm = await showConfirmDialog(
              message: PhilgoTr.of(context)!.confirmDiscard,
            );

            if (confirm != true) {
              return;
            }

            /// 새로 업로드된 파일 삭제
            /// Delete newly uploaded files
            await formKey.currentState?.deleteNewFiles();

            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outline),
        ),
      ),

      /// PostUpdateForm - 재사용 가능한 글 수정 폼
      /// PostUpdateForm - reusable post update form
      body: PostUpdateForm(
        key: formKey,
        post: widget.post,

        /// AppBar에서 제출 버튼을 처리하므로 폼 내부 버튼 숨김
        /// Hide form's internal submit button (handled by AppBar)
        showSubmitButton: true,

        /// 로딩 상태 변경 콜백
        /// Loading status change callback
        onLoadingChanged: (loading) {
          setState(() {
            isLoading = loading;
          });
        },

        /// 업로드 상태 변경 콜백
        /// Upload status change callback
        onUploadingChanged: (uploading) {
          setState(() {
            isUploading = uploading;
          });
        },

        /// 제출 성공 시 화면 닫고 PostViewScreen으로 이동
        /// Close screen on successful submission and navigate to PostViewScreen
        onUpdated: (post) {
          Navigator.pop(context, post);

          // Navigate to PostViewScreen to show the updated post
          PostViewScreen.pushReplacement(context, post);

          // Call external callback if provided
          widget.onUpdated?.call(post);
        },
      ),
    );
  }
}
