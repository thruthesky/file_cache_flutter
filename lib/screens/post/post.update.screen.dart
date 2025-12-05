import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostUpdateScreen extends StatefulWidget {
  static const String routeName = '/post-update';

  // push 메서드 - 수정된 Post를 반환
  static Future<Post?> push(BuildContext ctx, {required Post post}) async {
    final result = await ctx.push(routeName, extra: {'post': post});
    return result as Post?;
  }

  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  final Post post;

  const PostUpdateScreen({super.key, required this.post});

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  int uploadingCount = 0; // 업로드 진행 중인 파일 개수 추적
  List<String> urls = [];
  List<String> newUrls = [];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.post.subject;
    _contentController.text = widget.post.content;
    urls = List<String>.from(widget.post.files);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Submit update handler
  Future<void> _handleUpdate() async {
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

      final updated = await updatePost({
        'idx': widget.post.idx,
        'subject': _titleController.text,
        'content': _contentController.text,
        'files': urls,
      });

      if (mounted) {
        context.pop(updated);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // Comic Design: no shadow
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, size: 20),
          onPressed: () async {
            // Check if content has changed
            final hasChanges = _titleController.text != widget.post.subject ||
                _contentController.text != widget.post.content ||
                urls.length != widget.post.files.length;

            // If no changes, just exit
            if (!hasChanges) {
              context.pop();
              return;
            }

            // Show confirmation dialog if there are changes
            final confirm = await showConfirmDialog(
              message: LibTr.of(context)!.confirmDiscard,
            );

            // User cancelled - don't exit
            if (confirm != true) {
              return;
            }

            // Delete new uploaded files from server if any
            newUrls = urls
                .where((url) => !widget.post.files.contains(url))
                .toList();

            if (newUrls.isNotEmpty) {
              await Future.wait(newUrls.map((url) => philgoApiFileDelete(url)));
              debugLog('All new file deletions completed');
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
                        color: scheme.primary,
                      ),
                    )
                  : const FaIcon(FontAwesomeIcons.check, size: 20),
              onPressed: isLoading || uploadingCount > 0 ? null : _handleUpdate,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 2,
            color: scheme.outline,
          ), // Comic Design: 2.0 border
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Title Input Field (Comic Design)
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: T.postTitleHint,
                  filled: true,
                  fillColor: scheme.surface,
                  // Comic Design: 2.0px border with rounded corners
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.outline,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Content Input Field (Comic Design)
              TextFormField(
                controller: _contentController,
                maxLines: 12,
                minLines: 6,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: T.postContentHint,
                  filled: true,
                  fillColor: scheme.surface,
                  // Comic Design: 2.0px border with rounded corners
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.outline,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.primary,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: 2.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: scheme.error,
                      width: 2.0,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              if (urls.isNotEmpty || uploadingCount > 0)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final imageWidth = (constraints.maxWidth - 8) / 2;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...urls.map(
                          (url) => UploadPreview(
                            url: url,
                            width: imageWidth,
                            height: imageWidth,
                            borderRadius: 8,
                            onDelete: () async {
                              // 삭제 확인 다이얼로그 표시
                              final confirm = await showConfirmDialog(
                                message: Lo.of(context)!.confirmDeleteImage,
                              );

                              if (confirm != true) return;

                              try {
                                debugLog("삭제 시작: $url");

                                await philgoApiFileDelete(url);
                                urls.remove(url);
                                setState(() {});

                                await updatePost({
                                  'idx': widget.post.idx,
                                  'files': urls,
                                });

                                debugLog("삭제 완료: $url");

                                if (context.mounted) {
                                  showSuccessSnackBar(
                                    context,
                                    Lo.of(context)!.imageDeletedSuccess,
                                  );
                                }
                              } catch (e) {
                                debugLog("파일 삭제 실패: $e");
                                showSafeErrorDialog("파일 삭제에 실패했습니다.");
                              }
                            },
                          ),
                        ),
                        ...List.generate(
                          uploadingCount,
                          (index) => LoadingBox(
                            width: imageWidth,
                            height: imageWidth,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    );
                  },
                ),

              if (urls.isNotEmpty || uploadingCount > 0)
                const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Bottom navigation bar as part of body Column
          // Comic Design: 2.0px top border
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                top: BorderSide(
                  // Comic Design: 2.0px border with outline color
                  color: scheme.outline,
                  width: 2.0,
                ),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: Row(
                children: [
                  FileUpload(
                    file: true,
                    video: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
