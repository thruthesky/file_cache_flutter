import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// 글쓰기 전체 화면 위젯
/// Full-screen post creation widget
///
/// 외부 앱에서 파일 공유 시 사용됩니다.
/// Used when files are shared from external apps.
///
/// [postId] 메인 카테고리 ID (예: 'freetalk', 'buyandsell')
/// [category] 서브 카테고리 (선택적, 없으면 null)
/// [xFiles] 외부에서 공유된 파일 목록
/// [content] 외부에서 공유된 텍스트 컨텐츠
class PostCreateScreen extends StatefulWidget {
  static const String routeName = '/post-create';

  /// 글쓰기 화면으로 이동
  /// Navigate to post create screen with postId and category
  static Future Function(
    BuildContext ctx, {
    required String postId,
    String? category,
    List<XFile>? xFiles,
    String? content,
  })
  push =
      (
        ctx, {
        required String postId,
        String? category,
        List<XFile>? xFiles,
        String? content,
      }) => ctx.push(
        routeName,
        extra: {
          'postId': postId,
          'category': category,
          'xFiles': xFiles,
          'content': content,
        },
      );
  const PostCreateScreen({
    super.key,
    required this.postId,
    this.category,
    this.onSubmitted,
    this.xFiles,
    this.content,
  });

  /// 메인 카테고리 ID (필수)
  /// Main category ID (required)
  final String postId;

  /// 서브 카테고리 (선택적)
  /// Sub-category (optional)
  final String? category;

  final void Function(Post post)? onSubmitted;

  /// 외부에서 공유된 파일 목록
  /// Files shared from external apps
  final List<XFile>? xFiles;

  /// 외부에서 공유된 텍스트 컨텐츠
  /// Text content shared from external apps
  final String? content;

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
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
        actions: [
          /// 파일 업로드 버튼 (camera icon)
          /// File upload button (camera icon)
          /// Note: FileUpload widget is also in the bottom action bar
          /// Both buttons provide the same functionality for user convenience
          FileUpload(
            file: true,
            video: true,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const FaIcon(FontAwesomeIcons.lightCamera, size: 24),
            ),
            onBeforeUpload: () {
              // Set uploading state to disable submit button
              setState(() {
                isUploading = true;
              });
            },
            onUploaded: (url) {
              // Add uploaded file URL to form
              formKey.currentState?.addUploadedFile(url);

              // Upload completed, reset uploading state
              setState(() {
                isUploading = false;
              });
            },
            onCancelled: () {
              // Upload cancelled, reset uploading state
              setState(() {
                isUploading = false;
              });
            },
          ),

          /// 제출 버튼 (send icon)
          /// Submit button (send icon)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    )
                  : FaIcon(
                      FontAwesomeIcons.paperPlane,
                      size: 24,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
              onPressed: (isLoading || isUploading)
                  ? null
                  : () async {
                      /// 폼 제출 실행
                      /// Execute form submission
                      await formKey.currentState?.submit();
                    },
            ),
          ),
        ],
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

        initialContent: widget.content,
        initialFiles: widget.xFiles,

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
