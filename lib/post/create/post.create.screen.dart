import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/app.config.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/point/point_advertisement.service.dart';
import 'package:philgo/point/widgets/point_ad_selection_bottom_sheet.dart';
import 'package:philgo/post/create/widgets/wanted_hiring_form.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 게시글 작성 화면
///
/// v6 PostCreateScreen + PostCreateForm 로직 적용.
/// 제목, 내용 입력 후 v7 API로 게시글 생성.
class PostCreateScreen extends StatefulWidget {
  static const String routeName = '/post-create';

  /// 게시판 ID (예: 'freetalk', 'qna')
  final String postId;

  /// 서브 카테고리 (선택)
  final String? category;

  /// Navigate to post create screen with postId and category
  static Function(
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

  /// 외부에서 공유된 파일 목록
  /// Files shared from external apps
  final List<XFile>? xFiles;

  /// 외부에서 공유된 텍스트 컨텐츠
  /// Text content shared from external apps
  final String? content;

  const PostCreateScreen({
    super.key,
    required this.postId,
    this.category,
    this.xFiles,
    this.content,
  });

  @override
  State<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends State<PostCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hiringFormKey = GlobalKey<WantedHiringFormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  final List<FileUploadModel> _uploadedFiles = [];
  int _uploadingCount = 0;

  /// 현재 구인(hiring) 폼을 표시 중인지 여부
  bool get _isHiringMode =>
      _selectedPostId == 'wanted' && _selectedCategory == 'hiring';

  /// 선택된 게시판 ID (드롭다운으로 변경 가능)
  late String _selectedPostId;

  /// 선택된 서브 카테고리 (드롭다운으로 변경 가능)
  String? _selectedCategory;

  /// 포인트 광고 설정 (null이면 로딩 중 또는 미지원)
  PointAdvertisementConfig? _adConfig;

  /// 선택된 광고 기간 (null이면 광고 안 함)
  int? _advertisementDays;

  @override
  void initState() {
    super.initState();
    _selectedPostId = widget.postId;
    _selectedCategory = widget.category;
    _loadAdConfig();
  }

  /// 포인트 광고 설정 로드
  Future<void> _loadAdConfig() async {
    try {
      final config = await PointAdvertisementService.getConfig(
        postId: _selectedPostId,
        category: _selectedCategory,
      );
      if (mounted) setState(() => _adConfig = config);
    } catch (_) {
      // 광고 설정 로드 실패 시 무시 (광고 버튼 숨김)
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 게시판 라벨 가져오기
  String _getPostLabel(String postId) {
    final found = Config.forumCategories.where((c) => c.$1 == postId && c.$2 == null);
    if (found.isNotEmpty) return found.first.$3;
    return postId;
  }

  /// 해당 postId의 서브 카테고리 목록
  List<(String, String)> _getSubCategories(String postId) {
    return Config.forumCategories
        .where((c) => c.$1 == postId && c.$2 != null)
        .map((c) => (c.$2!, c.$3))
        .toList();
  }

  /// 카테고리 라벨 가져오기
  String _getCategoryLabel(String? category) {
    // "[NO TRANSLATION: 카테고리 선택]"
    if (category == null) return '카테고리 선택'.tr();
    final found = Config.forumCategories.where(
      (c) => c.$1 == _selectedPostId && c.$2 == category,
    );
    if (found.isNotEmpty) return found.first.$3;
    return category;
  }

  /// POST_ID 선택 바텀시트
  void _showPostIdSelector() {
    final categories = Config.majorForumCategories(
      includeTemp: isDeveloperModeEnabled,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    // "[NO TRANSLATION: 게시판을 선택해주세요]"
                    '게시판을 선택해주세요'.tr(),
                    style: text.titleMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: categories.length,
                    itemBuilder: (_, index) {
                      final postId = categories[index];
                      final label = _getPostLabel(postId);
                      final isSelected = postId == _selectedPostId;

                      return ListTile(
                        title: Text(
                          label.tr(),
                          style: isSelected
                              ? TextStyle(
                                  color: color.primary,
                                  fontWeight: FontWeight.w600,
                                )
                              : null,
                        ),
                        trailing: isSelected
                            ? FaIcon(
                                FontAwesomeIcons.check,
                                size: 14,
                                color: color.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedPostId = postId;
                            _selectedCategory = null;
                            _advertisementDays = null;
                            _adConfig = null;
                          });
                          _loadAdConfig();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 카테고리 선택 바텀시트
  void _showCategorySelector() {
    final subCategories = _getSubCategories(_selectedPostId);
    if (subCategories.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 8,
                  ),
                  child: Text(
                    // "[NO TRANSLATION: 카테고리를 선택해주세요]"
                    '카테고리를 선택해주세요'.tr(),
                    style: text.titleMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: subCategories.length + 1,
                    itemBuilder: (_, index) {
                      // 첫 번째 항목: 카테고리 없음
                      if (index == 0) {
                        final isSelected = _selectedCategory == null;
                        return ListTile(
                          title: Text(
                            // "All"
                            '전체'.tr(),
                            style: isSelected
                                ? TextStyle(
                                    color: color.primary,
                                    fontWeight: FontWeight.w600,
                                  )
                                : null,
                          ),
                          trailing: isSelected
                              ? FaIcon(
                                  FontAwesomeIcons.check,
                                  size: 14,
                                  color: color.primary,
                                )
                              : null,
                          onTap: () {
                            Navigator.pop(ctx);
                            setState(() => _selectedCategory = null);
                          },
                        );
                      }

                      final (categoryId, categoryLabel) =
                          subCategories[index - 1];
                      final isSelected = categoryId == _selectedCategory;

                      return ListTile(
                        title: Text(
                          categoryLabel.tr(),
                          style: isSelected
                              ? TextStyle(
                                  color: color.primary,
                                  fontWeight: FontWeight.w600,
                                )
                              : null,
                        ),
                        trailing: isSelected
                            ? FaIcon(
                                FontAwesomeIcons.check,
                                size: 14,
                                color: color.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() => _selectedCategory = categoryId);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 포인트 광고 선택 바텀시트 표시
  void _showAdSelectionSheet() {
    final config = _adConfig;
    if (config == null || !config.eligible) return;

    final userPoints =
        context.read<UserState>().user?.point ?? 0;

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

  /// 게시글 제출
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final post = await PostService.create(
        postId: _selectedPostId,
        subject: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        files: _uploadedFiles.map((f) => f.path).toList(),
      );

      // 포인트 광고 등록 (선택한 경우)
      if (_advertisementDays != null && _advertisementDays! > 0) {
        try {
          await PointAdvertisementService.advertise(
            idx: post.idx,
            days: _advertisementDays!,
          );
        } catch (e) {
          // 광고 등록 실패해도 글 작성은 성공이므로 알림만 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              // "[NO TRANSLATION: 포인트 광고 등록 실패]"
              SnackBar(content: Text('${'포인트 광고 등록 실패'.tr()}: $e')),
            );
          }
        }
      }

      if (!mounted) return;
      // 글 작성 화면을 닫고 글 보기 화면으로 이동
      Navigator.of(context).pop();
      PostViewScreen.push(context, post);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      // "Failed to create post"
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
        // "Write"
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
          ? WantedHiringForm(key: _hiringFormKey)
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 게시판 / 카테고리 드롭다운 선택 버튼
            Row(
              children: [
                // POST_ID 선택 드롭다운
                Expanded(
                  child: InkWell(
                    onTap: _showPostIdSelector,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
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
                          Expanded(
                            child: Text(
                              _getPostLabel(_selectedPostId).tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          FaIcon(
                            FontAwesomeIcons.lightChevronDown,
                            size: 12,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // 카테고리 선택 드롭다운 (서브카테고리가 있을 때만)
                if (_getSubCategories(_selectedPostId).isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: _showCategorySelector,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedCategory != null
                              ? scheme.primaryContainer.withValues(alpha: 0.3)
                              : scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.5,
                                ),
                          borderRadius: BorderRadius.circular(8),
                          border: _selectedCategory == null
                              ? Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.lightTag,
                              size: 14,
                              color: _selectedCategory != null
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getCategoryLabel(_selectedCategory),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: _selectedCategory != null
                                      ? scheme.primary
                                      : scheme.onSurfaceVariant,
                                  fontWeight: _selectedCategory != null
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            FaIcon(
                              FontAwesomeIcons.lightChevronDown,
                              size: 12,
                              color: _selectedCategory != null
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

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
              maxLines: 32,
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

            // 포인트 광고 선택 버튼 (적격 게시판인 경우만 표시)
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
                      color: _advertisementDays != null
                          ? scheme.primaryContainer.withValues(alpha: 0.3)
                          : scheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                      borderRadius: BorderRadius.circular(8),
                      border: _advertisementDays != null
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
                          color: _advertisementDays != null
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _advertisementDays != null
                              // "Point Ad", "[NO TRANSLATION: 일]"
                              ? '${'포인트 광고'.tr()}: $_advertisementDays${'일'.tr()}'
                              // "Point Ad"
                              : '포인트 광고'.tr(),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _advertisementDays != null
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: _advertisementDays != null
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        const Spacer(),
                        FaIcon(
                          FontAwesomeIcons.lightChevronDown,
                          size: 12,
                          color: _advertisementDays != null
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 파일 업로드 버튼 + 전송 버튼 + 미리보기
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          // "Upload failed"
                          SnackBar(content: Text('${'업로드 실패'.tr()}: $e')),
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.lightCamera,
                        size: 20,
                        color: scheme.primary,
                      ),
                    ),
                    // 전송 버튼
                    _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            onPressed: _submit,
                            icon: FaIcon(
                              FontAwesomeIcons.lightPaperPlaneTop,
                              size: 20,
                              color: scheme.primary,
                            ),
                          ),
                  ],
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
