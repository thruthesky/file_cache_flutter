import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/unfocus_on_tap.dart';
import 'package:philgo_api/philgo_api.dart';

/// 글 수정 전체 화면 위젯
/// Full-screen post update widget
class PostUpdateScreen extends StatefulWidget {
  final Post post;
  final void Function(Post post)? onUpdated;

  const PostUpdateScreen({super.key, required this.post, this.onUpdated});

  @override
  State<PostUpdateScreen> createState() => PostUpdateScreenState();
}

class PostUpdateScreenState extends State<PostUpdateScreen> {
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

    return UnfocusOnTap(
      child: Scaffold(
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
                onPressed: (isLoading || isUploading)
                    ? null
                    : () async {
                        /// 폼 제출 실행
                        /// Execute form submission
                        await formKey.currentState?.submit();
                      },
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
                        FontAwesomeIcons.solidPaperPlane,
                        color: (isLoading || isUploading)
                            ? scheme.onSurface.withValues(alpha: 0.38)
                            : scheme.primary,
                      ),
              ),
            ),
          ],
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
      ),
    );
  }
}
