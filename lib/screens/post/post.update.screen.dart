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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(
          'Update: ${widget.post.subject}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.lightArrowLeft),
          onPressed: () async {
            newUrls = urls
                .where((url) => !widget.post.files.contains(url))
                .toList();

            if (newUrls.isNotEmpty) {
              await Future.wait(newUrls.map((url) => philgoApiFileDelete(url)));
              debugLog(
                "---------------> delete all of the images that is uploaded!",
              );
            }

            final filesChanged = urls.length != widget.post.files.length;

            debugLog(
              '---------------------------------> filesChanged: $filesChanged',
            );

            final result = filesChanged ? await getPost(widget.post.idx) : null;

            if (result != null) {
              debugLog(
                'Returning updated post with ${result.files.length} files',
              );
            } else {
              debugLog('No changes, returning null');
            }

            if (context.mounted) context.pop(result);
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
              const SizedBox(height: 8),
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
                      // 업로드 취소 시 카운트 감소
                      setState(() {
                        uploadingCount--;
                      });
                    },
                  ),
                  Spacer(),
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

                        final updated = await updatePost({
                          'idx': widget.post.idx,
                          'subject': _titleController.text,
                          'content': _contentController.text,
                          'files': urls, // 파일 목록 포함
                        });

                        if (context.mounted) {
                          context.pop(updated);
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
