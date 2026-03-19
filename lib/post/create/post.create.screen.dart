import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/post/post.service.dart';

/// 게시글 작성 화면
///
/// v6 PostCreateScreen + PostCreateForm 로직 적용.
/// 제목, 내용 입력 후 v7 API로 게시글 생성.
class PostCreateScreen extends StatefulWidget {
  /// 게시판 ID (예: 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (선택)
  final String? category;

  const PostCreateScreen({super.key, required this.postId, this.category});

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  final List<FileUploadModel> _uploadedFiles = [];
  int _uploadingCount = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 게시글 제출
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final post = await PostService.create(
        postId: widget.postId,
        subject: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: widget.category,
        files: _uploadedFiles.map((f) => f.path).toList(),
      );

      if (!mounted) return;
      // 생성된 게시글을 결과로 반환
      Navigator.of(context).pop(post);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${'게시글 작성 실패'.tr()}: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('글쓰기'.tr(), style: theme.textTheme.titleMedium),
        actions: [
          // 제출 버튼
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _isSubmitting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: _submit,
                    icon: FaIcon(
                      FontAwesomeIcons.lightPaperPlaneTop,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 게시판 정보
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightNewspaper,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.category != null
                        ? '${widget.postId} / ${widget.category}'
                        : widget.postId,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              maxLength: 255,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력하세요'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 내용 입력
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              maxLines: 15,
              minLines: 8,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '내용을 입력하세요'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 파일 업로드 버튼 + 미리보기
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FileUpload(
                  module: 'post',
                  code: 'content',
                  camera: true,
                  cameraVideo: true,
                  gallery: true,
                  galleryVideo: true,
                  file: true,
                  onUploadingChanged: (uploading) {
                    setState(() => _uploadingCount += uploading ? 1 : -1);
                  },
                  onUploaded: (FileUploadModel model) {
                    debugPrint(
                      '[PostCreate] 파일 업로드 완료: ${model.path} (${model.name}, ${model.type})',
                    );
                    setState(() => _uploadedFiles.add(model));
                  },
                  onError: (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${'업로드 실패'.tr()}: $e')),
                    );
                  },
                  child: FaIcon(
                    FontAwesomeIcons.lightCamera,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                if (_uploadedFiles.isNotEmpty || _uploadingCount > 0) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._uploadedFiles.map((f) {
                        return UploadedFilePreview(
                          file: f,
                          onDelete: () async {
                            await ApiService.instance.fileDelete(f.idx);
                            setState(() => _uploadedFiles.remove(f));
                          },
                        );
                      }),
                      for (int i = 0; i < _uploadingCount; i++)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: scheme.outlineVariant),
                            color: scheme.surfaceContainerHighest,
                          ),
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
