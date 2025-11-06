import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/state/forum.state.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo/globals.dart';

class PostCreateScreen extends StatefulWidget {
  static const String routeName = '/post-create';

  //
  static Future Function(BuildContext ctx) push = (ctx) => ctx.push(routeName);
  //
  static Function(BuildContext ctx) go = (ctx) => ctx.go(routeName);

  const PostCreateScreen({super.key});

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
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          '${T.writeIn} ${HomePostCategory.label}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.lightArrowLeft),
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
              message: LibTr.of(context)!.confirmDiscard,
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
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.lightTag,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      HomePostCategory.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: T.title,
                  hintText: T.postTitleHint,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: T.content,
                  hintText: T.postContentHint,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return T.contentRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              if (urls.isNotEmpty || uploadingCount > 0)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...urls.map(
                      (url) => UploadPreview(
                        url: url,
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
                      (index) => const LoadingBox(),
                    ),
                  ],
                ),

              if (urls.isNotEmpty || uploadingCount > 0)
                const SizedBox(height: 16),

              Row(
                children: [
                  FileUpload(
                    file: true,
                    video: true,
                    child: const FaIcon(FontAwesomeIcons.lightCamera),
                    onBeforeUpload: () {
                      // 업로드 시작 시 카운트 증가
                      setState(() {
                        uploadingCount++;
                      });
                    },
                    onUploaded: (url) {
                      debugLog('url: $url');
                      urls.add(url);
                      // 업로드 완료 시 카운트 감소
                      setState(() {
                        uploadingCount--;
                      });
                    },
                    onCancelled: () {
                      uploadingCount--;
                      setState(() {});
                    },
                  ),
                  const Spacer(),
                  SubmitButton(
                    isLoading: isLoading,
                    onPressed: () async {
                      // 업로드가 진행 중인지 확인
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
                        // 파일 URL 목록 디버그 로그
                        debugLog('업로드된 파일 개수: ${urls.length}');
                        debugLog('파일 URL 목록: $urls');

                        final created = await philgoApiCreatePost({
                          'post_id': HomePostCategory.postId,
                          'category': HomePostCategory.category,
                          'subject': _titleController.text,
                          'content': _contentController.text,
                          'files': urls,
                        });

                        if (context.mounted) {
                          PostViewScreen.pushReplacement(context, created);
                        }
                      } finally {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: Text(T.submit),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightInfo,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Writing Guide',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Posts that defame others may be deleted'),
                    const SizedBox(height: 4),
                    const Text(
                      '• Advertisements and spam will be deleted immediately',
                    ),
                    const SizedBox(height: 4),
                    const Text('• Do not include personal information'),
                    const SizedBox(height: 4),
                    const Text(
                      '• Copyright infringing content cannot be posted',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
