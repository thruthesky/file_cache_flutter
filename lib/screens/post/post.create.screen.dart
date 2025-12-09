import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';

/// 글쓰기 화면 (Post Create Screen)
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

  /// 글쓰기 화면으로 이동 (현재 화면 교체)
  /// Navigate to post create screen (replace current screen)
  static Function(BuildContext ctx, {required String postId, String? category})
  go = (ctx, {required String postId, String? category}) => ctx.go(routeName);

  const PostCreateScreen({
    super.key,
    required this.postId,
    this.category,
    this.xFiles,
    this.content,
  });

  /// 메인 카테고리 ID (필수)
  /// Main category ID (required)
  final String postId;

  /// 서브 카테고리 (선택적)
  /// Sub-category (optional)
  final String? category;

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
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int uploadingCount = 0; // Track number of ongoing uploads
  List<String> urls = [];

  @override
  void initState() {
    if (widget.content != null) _contentController.text = widget.content!;
    if (widget.xFiles != null) {
      /// upload xFiles to philgo server
      // log(
      //   widget.xFiles!.map((e) => e.path).toString(),
      //   name: 'received xfiles',
      // );
      for (var file in widget.xFiles!) {
        setState(() {
          uploadingCount++;
        });

        philgoApiFileUpload(file.path)
            .then((uploadedFile) {
              // log(
              //   'Uploaded file URL: ${uploadedFile?.url}',
              //   name: 'file upload',
              // );
              if (uploadedFile != null) {
                urls.add(uploadedFile.url);
              }
            })
            .catchError((error) {
              // log(
              //   'File upload error: $error',
              //   name: 'file upload',
              //   error: error,
              // );
              showSafeErrorDialog('File upload failed: $error');
            })
            .whenComplete(() {
              setState(() {
                uploadingCount--;
              });
            });
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Submit post handler - extracted for reuse in AppBar action
  Future<void> _handleSubmit() async {
    // Check if upload is in progress
    if (uploadingCount > 0) {
      showSafeErrorDialog(
        'Image upload is in progress, please try again in a moment.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugLog('업로드된 파일 개수: ${urls.length}');
      debugLog('파일 URL 목록: $urls');

      final created = await createPost({
        'post_id': widget.postId,
        'category': widget.category,
        'subject': _titleController.text,
        'content': _contentController.text,
        'files': urls,
      });

      if (mounted) {
        PostViewScreen.pushReplacement(context, created);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Comic Design: no shadow
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () async {
            // Check if there's any content (title, content, or uploaded files)
            final hasContent =
                _titleController.text.trim().isNotEmpty ||
                _contentController.text.trim().isNotEmpty ||
                urls.isNotEmpty;

            // If no content, just exit
            if (!hasContent) {
              context.pop();
              return;
            }

            // Show confirmation dialog if there's content
            final confirm = await showConfirmDialog(
              message: PhilgoTr.of(context)!.confirmDiscard,
            );

            // User cancelled - don't exit
            if (confirm != true) {
              return;
            }

            // Delete uploaded files from server if any
            if (urls.isNotEmpty) {
              // Delete all files in parallel for better performance
              await Future.wait(urls.map((url) => philgoApiFileDelete(url)));
              debugLog('All file deletions completed');
            }

            // Exit the screen
            if (context.mounted) {
              context.pop();
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : const FaIcon(FontAwesomeIcons.check, size: 20),
              onPressed: isLoading || uploadingCount > 0 ? null : _handleSubmit,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 2,
            color: Theme.of(context).colorScheme.outline,
          ), // Comic Design: 2.0 border
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(sp.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input Field (Comic Design)
                    TextFieldSet(
                      padding: EdgeInsets.zero,
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: T.postTitleHint,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        // Comic Design: 2.0px border with rounded corners
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(sp.s16),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return T.titleRequired;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: sp.s16),
                    // Content Input Field (Comic Design)
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return T.contentRequired;
                        }
                        return null;
                      },
                      controller: _contentController,
                      maxLines: 12,
                      minLines: 6,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: T.postContentHint,
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        // Comic Design: 2.0px border with rounded corners
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2.0,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                            width: 2.0,
                          ),
                        ),
                        contentPadding: EdgeInsets.all(sp.s16),
                        alignLabelWithHint: true,
                      ),
                    ),
                    SizedBox(height: sp.s16),

                    if (urls.isNotEmpty || uploadingCount > 0)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final imageWidth = (constraints.maxWidth - sp.s8) / 2;
                          return Wrap(
                            spacing: sp.s8,
                            runSpacing: sp.s8,
                            children: [
                              ...urls.map(
                                (url) => UploadPreview(
                                  url: url,
                                  width: imageWidth,
                                  height: imageWidth,
                                  borderRadius: sp.s8,
                                  onDelete: () async {
                                    // 삭제 확인 다이얼로그 표시
                                    final confirm = await showConfirmDialog(
                                      message: Lo.of(
                                        context,
                                      )!.confirmDeleteImage,
                                    );

                                    if (confirm != true) return;

                                    try {
                                      debugLog("삭제 시작: $url");
                                      await philgoApiFileDelete(url);

                                      urls.remove(url);
                                      setState(() {});
                                      debugLog("삭제 완료: $url");

                                      if (context.mounted) {
                                        showSuccessSnackBar(
                                          context,
                                          Lo.of(context)!.imageDeletedSuccess,
                                        );
                                      }
                                    } catch (e) {
                                      debugLog("파일 삭제 실패: $e");
                                      showSafeErrorDialog("파일 삭제에 실패했습니다: $e");
                                    }
                                  },
                                ),
                              ),
                              ...List.generate(
                                uploadingCount,
                                (index) => LoadingBox(
                                  width: imageWidth,
                                  height: imageWidth,
                                  borderRadius: sp.s8,
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    if (urls.isNotEmpty || uploadingCount > 0)
                      SizedBox(height: sp.s16),
                  ],
                ),
              ),
            ),
          ),
          // Bottom navigation bar as part of body Column
          // Comic Design: 2.0px top border
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  // Comic Design: 2.0px border with outline color
                  color: Theme.of(context).colorScheme.outline,
                  width: 2.0,
                ),
              ),
            ),
            padding: EdgeInsets.all(sp.s16),
            child: SafeArea(
              child: Row(
                children: [
                  FileUpload(
                    file: true,
                    video: true,
                    child: Container(
                      padding: EdgeInsets.all(sp.s12),
                      child: const FaIcon(FontAwesomeIcons.lightCamera),
                    ),
                    onBeforeUpload: () {
                      setState(() {
                        uploadingCount++;
                      });
                    },
                    onUploaded: (url) {
                      debugLog('url: $url');
                      urls.add(url);
                      setState(() {
                        uploadingCount--;
                      });
                    },
                    onCancelled: () {
                      uploadingCount--;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
