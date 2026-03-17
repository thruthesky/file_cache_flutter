import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/post/list/widgets/display_thumbnail.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/util/util.functions.dart';

/// 게시글 수정 화면
///
/// v6 PostUpdateScreen + PostUpdateForm 로직 적용.
/// 기존 게시글의 제목/내용을 수정하고 v7 API로 업데이트.
class PostUpdateScreen extends StatefulWidget {
  static const String routeName = '/post/update';

  /// PostUpdateScreen으로 이동하고 수정된 Post를 반환
  static Future<Post?> push(BuildContext ctx, Post post) async {
    final result = await ctx.push<Post>(routeName, extra: post);
    return result;
  }

  final Post post;

  const PostUpdateScreen({super.key, required this.post});

  @override
  State<PostUpdateScreen> createState() => _PostUpdateScreenState();
}

class _PostUpdateScreenState extends State<PostUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSubmitting = false;

  /// 기존 첨부파일 URL 목록 (서버에서 받아온 것)
  late List<String> _existingUrls;

  /// 새로 업로드한 파일 목록
  final List<FileUploadModel> _newFiles = [];

  late Post _latestPost;
  bool _isDeletingFile = false;

  int _uploadingCount = 0;

  @override
  void initState() {
    super.initState();
    _latestPost = widget.post;
    _titleController = TextEditingController(text: widget.post.subject);
    _contentController = TextEditingController(text: widget.post.content);
    _existingUrls = widget.post.files.isNotEmpty
        ? widget.post.files
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 기존 첨부파일 삭제 후 즉시 포스트 업데이트
  Future<void> _deleteExistingFile(String url) async {
    debugLog('URL: $url');

    if (_isDeletingFile) return;
    setState(() {
      _isDeletingFile = true;
      _existingUrls = List.from(_existingUrls)..remove(url);
    });
    try {
      await ApiService.instance.fileDeleteByUrl(url);
      _latestPost = await PostService.update(
        idx: widget.post.idx,
        files: [..._existingUrls, ..._newFiles.map((f) => f.path)],
      );
    } catch (e) {
      if (!mounted) return;
      // 실패 시 복원
      setState(() => _existingUrls = List.from(_existingUrls)..add(url));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('파일 삭제 실패: $e')));
    } finally {
      if (mounted) setState(() => _isDeletingFile = false);
    }
  }

  /// 게시글 수정 제출
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final allFiles = [..._existingUrls, ..._newFiles.map((f) => f.path)];

      _latestPost = await PostService.update(
        idx: widget.post.idx,
        subject: _titleController.text.trim(),
        content: _contentController.text.trim(),
        files: allFiles,
      );

      if (!mounted) return;
      Navigator.of(context).pop(_latestPost);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('게시글 수정 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasFiles =
        _existingUrls.isNotEmpty || _newFiles.isNotEmpty || _uploadingCount > 0;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_latestPost),
        ),
        title: Text('글 수정', style: theme.textTheme.titleMedium),
        actions: [
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
            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '제목',
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
                  return '제목을 입력하세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 내용 입력
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: '내용을 입력하세요',
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
                  return '내용을 입력하세요';
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
                  file: true,
                  onUploadingChanged: (uploading) {
                    setState(() => _uploadingCount += uploading ? 1 : -1);
                  },
                  onUploaded: (FileUploadModel model) {
                    setState(() => _newFiles.add(model));
                  },
                  onError: (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('업로드 실패: $e')));
                  },
                  child: FaIcon(
                    FontAwesomeIcons.lightCamera,
                    size: 20,
                    color: scheme.primary,
                  ),
                ),
                if (hasFiles) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // 기존 파일 (URL 기반 미리보기)
                      ..._existingUrls.map((url) {
                        return DisplayThumbnail(
                          url: url,
                          size: 80,
                          onDelete: () => _deleteExistingFile(url),
                        );
                      }),
                      // 새로 업로드한 파일
                      ..._newFiles.map((f) {
                        return UploadedFilePreview(
                          file: f,
                          onDelete: () => setState(() => _newFiles.remove(f)),
                        );
                      }),
                      // 업로드 중 로딩 플레이스홀더
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
