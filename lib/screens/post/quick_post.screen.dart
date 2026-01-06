import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_api/philgo_api.dart';

/// 빠른 글쓰기 화면 (Quick Post Screen)
///
/// 홈 화면의 가짜 입력 박스를 클릭하면 이 화면으로 이동합니다.
/// This screen is shown when the fake input box on the home screen is tapped.
///
/// 기능 (Features):
/// 1. 카테고리를 그룹별로 펼쳐서 선택할 수 있습니다.
///    Categories are displayed in expandable groups for selection.
/// 2. 카테고리 선택 후 같은 화면에서 글 작성 폼이 나타납니다.
///    After selecting a category, the post creation form appears on the same screen.
/// 3. 서브카테고리가 없는 게시판은 즉시 글쓰기 폼을 표시합니다.
///    Boards without sub-categories show the post creation form immediately.
class QuickPostScreen extends StatefulWidget {
  static const String routeName = '/quick-post';

  const QuickPostScreen({super.key});

  @override
  State<QuickPostScreen> createState() => _QuickPostScreenState();
}

class _QuickPostScreenState extends State<QuickPostScreen> {
  /// 선택된 메인 카테고리 ID
  /// Selected main category ID
  String? _selectedPostId;

  /// 선택된 서브 카테고리
  /// Selected sub-category
  String? _selectedCategory;

  /// 폼 상태 접근을 위한 GlobalKey
  /// GlobalKey for accessing form state
  final _formKey = GlobalKey<PostCreateFormState>();

  /// 로딩 상태
  /// Loading state
  bool _isLoading = false;

  /// 업로드 상태
  /// Upload state
  bool _isUploading = false;

  /// 제목 컨트롤러
  /// Title controller
  final _titleController = TextEditingController();

  /// 내용 컨트롤러
  /// Content controller
  final _contentController = TextEditingController();

  /// 펼쳐진 카테고리 그룹 목록
  /// List of expanded category groups
  final Set<String> _expandedGroups = {};

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 카테고리 선택 시 호출
  /// Called when a category is selected
  void _selectCategory(String postId, String? category) {
    setState(() {
      _selectedPostId = postId;
      _selectedCategory = category;
    });
  }

  /// 카테고리 선택 화면으로 돌아가기
  /// Go back to category selection screen
  void _goBackToCategories() {
    setState(() {
      _selectedPostId = null;
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /// 카테고리가 선택되었는지 여부
    /// Whether a category is selected
    final isCategorySelected = _selectedPostId != null;

    return GestureDetector(
      /// 키보드 외부 터치 시 키보드 숨김
      /// Hide keyboard when tapping outside
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        /// AppBar 구성
        /// AppBar configuration
        appBar: AppBar(
          elevation: 0,

          /// 뒤로 가기 버튼
          /// Back button
          leading: IgnorePointer(
            ignoring: _isLoading || _isUploading,
            child: Opacity(
              opacity: (_isLoading || _isUploading) ? 0.38 : 1.0,
              child: IconButton(
                icon: FaIcon(
                  isCategorySelected
                      ? FontAwesomeIcons.arrowLeft
                      : FontAwesomeIcons.xmark,
                  color: scheme.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  if (isCategorySelected) {
                    /// 카테고리 선택 화면으로 돌아가기
                    /// Go back to category selection
                    _goBackToCategories();
                  } else {
                    /// 화면 닫기
                    /// Close screen
                    context.pop();
                  }
                },
              ),
            ),
          ),

          /// 타이틀
          /// Title
          title: Text(
            isCategorySelected
                ? philgoTr(context, _selectedCategory ?? _selectedPostId!)
                : '글쓰기',
            style: theme.textTheme.titleLarge,
          ),

          /// 액션 버튼들 (카테고리 선택 후에만 표시)
          /// Action buttons (only shown after category selection)
          actions: isCategorySelected
              ? [
                  /// 파일 업로드 버튼
                  /// File upload button
                  IgnorePointer(
                    ignoring: _isLoading || _isUploading,
                    child: Opacity(
                      opacity: (_isLoading || _isUploading) ? 0.38 : 1.0,
                      child: FileUpload(
                        file: true,
                        video: true,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const FaIcon(
                            FontAwesomeIcons.camera,
                            size: 20,
                          ),
                        ),
                        onBeforeUpload: () {
                          setState(() {
                            _isUploading = true;
                          });
                        },
                        onUploaded: (url) {
                          _formKey.currentState?.addUploadedFile(url);
                          setState(() {
                            _isUploading = false;
                          });
                        },
                        onCancelled: () {
                          setState(() {
                            _isUploading = false;
                          });
                        },
                      ),
                    ),
                  ),

                  /// 제출 버튼
                  /// Submit button
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: IconButton(
                      onPressed: (_isLoading || _isUploading)
                          ? null
                          : () async {
                              await _formKey.currentState?.submit();
                            },
                      icon: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: scheme.primary,
                              ),
                            )
                          : FaIcon(
                              FontAwesomeIcons.solidPaperPlane,
                              color: (_isLoading || _isUploading)
                                  ? scheme.onSurface.withValues(alpha: 0.38)
                                  : scheme.primary,
                              size: 20,
                            ),
                    ),
                  ),
                ]
              : null,

          /// AppBar 하단 구분선
          /// AppBar bottom divider
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: scheme.outline),
          ),
        ),

        /// 본문 내용
        /// Body content
        body: isCategorySelected
            ? _buildPostForm(context)
            : _buildCategorySelection(context),
      ),
    );
  }

  /// 카테고리 선택 UI 빌드
  /// Build category selection UI
  Widget _buildCategorySelection(BuildContext context) {
    final theme = Theme.of(context);
    final sp = theme.extension<AppSpacing>()!;

    /// 메뉴 카테고리 가져오기 (개발자 모드 포함 여부)
    /// Get menu categories (include temp based on developer mode)
    final allCategories = PhilgoCategory.menuCategories(
      includeTemp: isDeveloperModeEnabled,
    );

    /// 카테고리를 그룹별로 정리
    /// Group categories by postId
    final Map<String, List<String?>> groupedCategories = {};
    final List<String> groupOrder = [];

    for (final (postId, subcategory) in allCategories) {
      if (!groupedCategories.containsKey(postId)) {
        groupedCategories[postId] = [];
        groupOrder.add(postId);
      }
      if (subcategory != null &&
          !groupedCategories[postId]!.contains(subcategory)) {
        groupedCategories[postId]!.add(subcategory);
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(sp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 안내 문구
          /// Guide text
          Padding(
            padding: EdgeInsets.only(bottom: sp.s16),
            child: Text(
              '게시판을 선택해주세요',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          /// 카테고리 그룹 목록
          /// Category group list
          ...groupOrder.map((postId) {
            final subCategories = groupedCategories[postId] ?? [];
            final hasSubCategories = subCategories.isNotEmpty;
            final isExpanded = _expandedGroups.contains(postId);

            return _buildCategoryGroup(
              context,
              postId: postId,
              subCategories: subCategories,
              hasSubCategories: hasSubCategories,
              isExpanded: isExpanded,
            );
          }),
        ],
      ),
    );
  }

  /// 카테고리 그룹 위젯 빌드
  /// Build category group widget
  Widget _buildCategoryGroup(
    BuildContext context, {
    required String postId,
    required List<String?> subCategories,
    required bool hasSubCategories,
    required bool isExpanded,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sp = theme.extension<AppSpacing>()!;

    /// 카테고리 다국어 이름
    /// Localized category name
    final localizedName = philgoTr(context, postId);

    /// 카테고리 이모지
    /// Category emoji
    final emoji = PhilgoCategory.emoji(postId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 그룹 헤더
        /// Group header
        InkWell(
          onTap: () {
            if (hasSubCategories) {
              /// 서브카테고리가 있으면 펼침/접기 토글
              /// Toggle expand/collapse if has sub-categories
              setState(() {
                if (isExpanded) {
                  _expandedGroups.remove(postId);
                } else {
                  _expandedGroups.add(postId);
                }
              });
            } else {
              /// 서브카테고리가 없으면 즉시 선택
              /// Select immediately if no sub-categories
              _selectCategory(postId, null);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sp.s12,
              vertical: sp.s12,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                /// 이모지
                /// Emoji
                Text(emoji, style: const TextStyle(fontSize: 20)),

                SizedBox(width: sp.s8),

                /// 카테고리 이름
                /// Category name
                Expanded(
                  child: Text(
                    localizedName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                /// 펼침/접기 아이콘 (서브카테고리가 있을 때만)
                /// Expand/collapse icon (only when has sub-categories)
                if (hasSubCategories)
                  FaIcon(
                    isExpanded
                        ? FontAwesomeIcons.chevronUp
                        : FontAwesomeIcons.chevronDown,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),

        /// 서브카테고리 목록 (펼쳐진 경우에만)
        /// Sub-category list (only when expanded)
        if (hasSubCategories && isExpanded)
          Padding(
            padding: EdgeInsets.only(
              left: sp.s16,
              top: sp.s8,
              bottom: sp.s8,
            ),
            child: Wrap(
              spacing: sp.s8,
              runSpacing: sp.s8,
              children: subCategories.map((subcategory) {
                final subName = philgoTr(context, subcategory ?? postId);

                return InkWell(
                  onTap: () => _selectCategory(postId, subcategory),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sp.s12,
                      vertical: sp.s8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      subName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        SizedBox(height: sp.s8),
      ],
    );
  }

  /// 글 작성 폼 빌드
  /// Build post creation form
  Widget _buildPostForm(BuildContext context) {
    return PostCreateForm(
      key: _formKey,
      postId: _selectedPostId!,
      category: _selectedCategory,
      showSubmitButton: true,

      /// 로딩 상태 변경 콜백
      /// Loading status change callback
      onLoadingChanged: (loading) {
        setState(() {
          _isLoading = loading;
        });
      },

      /// 업로드 상태 변경 콜백
      /// Upload status change callback
      onUploadingChanged: (uploading) {
        setState(() {
          _isUploading = uploading;
        });
      },

      /// 제출 성공 시 PostViewScreen으로 이동
      /// Navigate to PostViewScreen on successful submission
      onSubmitted: (post) {
        /// 현재 화면 닫기
        /// Close current screen
        context.pop();

        /// 글 읽기 화면으로 이동
        /// Navigate to post view screen
        PostViewScreen.push(context, post);
      },
    );
  }
}
