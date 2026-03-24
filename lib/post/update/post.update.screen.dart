import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/post/list/widgets/display_thumbnail.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/point/point_advertisement.service.dart';
import 'package:philgo/point/widgets/point_ad_selection_bottom_sheet.dart';
import 'package:philgo/post/create/widgets/wanted_hiring_form.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:provider/provider.dart';

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
  final _hiringFormKey = GlobalKey<WantedHiringFormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSubmitting = false;

  /// 구인(hiring) 폼 모드 여부
  bool get _isHiringMode =>
      widget.post.postId == 'wanted' && widget.post.category == 'hiring';

  /// 기존 첨부파일 URL 목록 (서버에서 받아온 것)
  late List<String> _existingUrls;

  /// 새로 업로드한 파일 목록
  final List<FileUploadModel> _newFiles = [];

  late Post _latestPost;
  bool _isDeletingFile = false;

  int _uploadingCount = 0;

  /// 포인트 광고 설정
  PointAdvertisementConfig? _adConfig;

  /// 선택된 광고 기간 (null이면 광고 안 함)
  int? _advertisementDays;

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
    _loadAdConfig();
  }

  /// 포인트 광고 설정 로드
  Future<void> _loadAdConfig() async {
    try {
      final config = await PointAdvertisementService.getConfig(
        postId: widget.post.postId,
        category: widget.post.category,
      );
      if (mounted) setState(() => _adConfig = config);
    } catch (_) {}
  }

  /// 포인트 광고 선택 바텀시트 표시
  void _showAdSelectionSheet() {
    final config = _adConfig;
    if (config == null || !config.eligible) return;

    final userPoints = context.read<UserState>().point;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PointAdSelectionBottomSheet(
        config: config,
        userPoints: userPoints,
        initialSelectedDays: _advertisementDays,
        onDaysSelected: (days) {
          Navigator.pop(context);
          setState(() => _advertisementDays = days);
        },
      ),
    );
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
      // "Failed to delete file"
      ).showSnackBar(SnackBar(content: Text('${'파일 삭제 실패'.tr()}: $e')));
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

      // 포인트 광고 등록/연장 (선택한 경우)
      if (_advertisementDays != null && _advertisementDays! > 0) {
        try {
          final adResult = await PointAdvertisementService.advertise(
            idx: widget.post.idx,
            days: _advertisementDays!,
          );
          _latestPost = _latestPost.copyWith(adEndTime: adResult.adEndTime);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              // "[NO TRANSLATION: 포인트 광고 등록 실패]"
              SnackBar(content: Text('${'포인트 광고 등록 실패'.tr()}: $e')),
            );
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(_latestPost);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      // "Failed to update post"
      ).showSnackBar(SnackBar(content: Text('${'게시글 수정 실패'.tr()}: $e')));
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
        // "Edit Post"
        title: Text('글 수정'.tr(), style: theme.textTheme.titleMedium),
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
                    onPressed: _isHiringMode
                        ? () => _hiringFormKey.currentState?.submit()
                        : _submit,
                    icon: FaIcon(
                      FontAwesomeIcons.lightPaperPlaneTop,
                      size: 20,
                      color: scheme.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: _isHiringMode
          ? WantedHiringForm(key: _hiringFormKey, post: widget.post)
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 제목 입력
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                // "Title"
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
                  // "Please enter a title"
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
                // "Please enter content"
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
                  // "Please enter content"
                  return '내용을 입력하세요'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 포인트 광고 선택 버튼 (적격 게시판인 경우만)
            if (_adConfig != null && _adConfig!.eligible)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: _isSubmitting ? null : _showAdSelectionSheet,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: (_advertisementDays != null ||
                              widget.post.isAdActive)
                          ? scheme.primaryContainer.withValues(alpha: 0.3)
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      border: (_advertisementDays != null ||
                              widget.post.isAdActive)
                          ? Border.all(color: scheme.primary, width: 1)
                          : Border.all(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.lightBullhorn,
                          size: 14,
                          color: (_advertisementDays != null ||
                                  widget.post.isAdActive)
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _advertisementDays != null
                                ? (widget.post.isAdActive
                                    // "[NO TRANSLATION: 포인트 광고 연장]", "[NO TRANSLATION: 일]"
                                    ? '${'포인트 광고 연장'.tr()}: +$_advertisementDays${'일'.tr()}'
                                    // "Point Ad", "[NO TRANSLATION: 일]"
                                    : '${'포인트 광고'.tr()}: $_advertisementDays${'일'.tr()}')
                                : (widget.post.isAdActive
                                    // "[NO TRANSLATION: 포인트 광고 중]"
                                    ? '${'포인트 광고 중'.tr()} (D-${widget.post.adRemainingDays})'
                                    // "Point Ad"
                                    : '포인트 광고'.tr()),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: (_advertisementDays != null ||
                                      widget.post.isAdActive)
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                              fontWeight: (_advertisementDays != null ||
                                      widget.post.isAdActive)
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.lightChevronDown,
                          size: 12,
                          color: (_advertisementDays != null ||
                                  widget.post.isAdActive)
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

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
                    setState(() => _newFiles.add(model));
                  },
                  onError: (e) {
                    ScaffoldMessenger.of(
                      context,
                    // "Upload failed"
                    ).showSnackBar(SnackBar(content: Text('${'업로드 실패'.tr()}: $e')));
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
