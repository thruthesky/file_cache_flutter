/// Screen이나 Dialog에서 재사용 가능한 글 수정 폼입니다.
/// 제목, 내용, 파일 업로드 기능을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// // Screen에서 사용
/// PostUpdateForm(
///   post: existingPost,
///   onUpdated: (post) => Navigator.pop(context, post),
///   onCancelled: () => Navigator.pop(context),
/// )
///
/// // Dialog에서 사용
/// showDialog(
///   context: context,
///   builder: (context) => Dialog(
///     child: PostUpdateForm(
///       post: existingPost,
///       onUpdated: (post) => Navigator.pop(context, post),
///     ),
///   ),
/// )
/// ```
library;

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 글 수정 폼 위젯
///
/// [post] 수정할 Post 객체 (필수)
/// [onUpdated] 수정 성공 시 콜백 (수정된 Post 객체 전달)
/// [onCancelled] 취소 시 콜백
/// [onLoadingChanged] 로딩 상태 변경 시 콜백
/// [onUploadingChanged] 파일 업로드 상태 변경 시 콜백
/// [showSubmitButton] 제출 버튼 표시 여부 (false면 외부에서 submit() 호출)
/// [padding] 폼 전체 패딩
class PostUpdateForm extends StatefulWidget {
  const PostUpdateForm({
    super.key,
    required this.post,
    this.onUpdated,
    this.onCancelled,
    this.onLoadingChanged,
    this.onUploadingChanged,
    this.showSubmitButton = true,
    this.padding,
  });

  /// 수정할 Post 객체
  final Post post;

  /// 수정 성공 시 콜백
  final void Function(Post updatedPost)? onUpdated;

  /// 취소 시 콜백
  final VoidCallback? onCancelled;

  /// 로딩 상태 변경 시 콜백
  final void Function(bool isLoading)? onLoadingChanged;

  /// 파일 업로드 상태 변경 시 콜백
  final void Function(bool isUploading)? onUploadingChanged;

  /// 제출 버튼 표시 여부
  final bool showSubmitButton;

  /// 폼 전체 패딩
  final EdgeInsetsGeometry? padding;

  @override
  State<PostUpdateForm> createState() => PostUpdateFormState();
}

/// PostUpdateForm의 State 클래스
///
/// GlobalKey를 통해 외부에서 submit(), hasChanges(), deleteNewFiles() 등의 메서드 호출 가능:
/// ```dart
/// final formKey = GlobalKey<PostUpdateFormState>();
///
/// PostUpdateForm(key: formKey, post: myPost)
///
/// // 외부에서 제출
/// formKey.currentState?.submit();
///
/// // 변경사항 확인
/// if (formKey.currentState?.hasChanges() ?? false) {
///   // ...
/// }
/// ```
class PostUpdateFormState extends State<PostUpdateForm> {
  // 텍스트 입력 컨트롤러
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 폼 유효성 검사 키
  final _formKey = GlobalKey<FormState>();

  // 로딩 상태
  bool _isLoading = false;

  // 파일 업로드 상태
  int _uploadingCount = 0;

  // 업로드된 파일 URL 목록
  final List<String> _urls = [];

  // 초기 파일 URL 목록 (변경 감지용)
  final List<String> _initialUrls = [];

  /// 현재 로딩 중인지 여부
  bool get isLoading => _isLoading;

  /// 현재 파일 업로드 중인지 여부
  bool get isUploading => _uploadingCount > 0;

  /// 업로드된 파일 URL 목록
  List<String> get uploadedUrls => List.unmodifiable(_urls);

  /// 변경사항이 있는지 확인
  bool hasChanges() {
    return _titleController.text != widget.post.subject ||
        _contentController.text != widget.post.content ||
        _urls.length != widget.post.files.length;
  }

  /// 새로 업로드된 파일 삭제
  Future<void> deleteNewFiles() async {
    final newUrls = _urls.where((url) => !_initialUrls.contains(url)).toList();

    if (newUrls.isNotEmpty) {
      await Future.wait(newUrls.map((url) => philgoApiFileDelete(url)));
      log('Deleted ${newUrls.length} new files', name: 'PostUpdateForm');
    }
  }

  /// 외부에서 파일 업로드 완료 후 URL 추가
  ///
  /// AppBar의 FileUpload 버튼에서 사용됨
  void addUploadedFile(String url) {
    if (mounted) {
      setState(() {
        _urls.add(url);
      });
      log('파일 추가됨: $url', name: 'PostUpdateForm');
    }
  }

  @override
  void initState() {
    super.initState();

    // 초기값 설정
    _titleController.text = widget.post.subject;
    _contentController.text = widget.post.content;
    _urls.addAll(widget.post.files);
    _initialUrls.addAll(widget.post.files);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 업로드 카운트 증가 (콜백 호출)
  void _incrementUploadingCount() {
    setState(() {
      _uploadingCount++;
    });
    widget.onUploadingChanged?.call(true);
  }

  /// 업로드 카운트 감소 (콜백 호출)
  void _decrementUploadingCount() {
    setState(() {
      _uploadingCount--;
    });
    if (_uploadingCount == 0) {
      widget.onUploadingChanged?.call(false);
    }
  }

  /// 로딩 상태 설정 (콜백 호출)
  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
    widget.onLoadingChanged?.call(value);
  }

  /// 폼 제출
  ///
  /// 외부에서 GlobalKey를 통해 호출 가능:
  /// ```dart
  /// formKey.currentState?.submit();
  /// ```
  ///
  /// 반환값:
  /// - true: 제출 성공
  /// - false: 제출 실패 (유효성 검사 실패 또는 API 오류)
  Future<bool> submit() async {
    // 업로드 진행 중이면 차단
    if (_uploadingCount > 0) {
      showSafeErrorDialog('이미지 업로드 중입니다. 잠시 후 다시 시도해주세요.');
      return false;
    }

    // 폼 유효성 검사
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    _setLoading(true);

    try {
      log('글 수정 시작 - idx: ${widget.post.idx}', name: 'PostUpdateForm');
      log('업로드된 파일 개수: ${_urls.length}', name: 'PostUpdateForm');

      // API 호출하여 글 수정
      final updated = await updatePost({
        'idx': widget.post.idx,
        'subject': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'files': _urls,
      });

      log('글 수정 성공 - idx: ${updated.idx}', name: 'PostUpdateForm');

      // 성공 콜백 호출
      widget.onUpdated?.call(updated);
      return true;
    } catch (e) {
      log('글 수정 실패: $e', name: 'PostUpdateForm', error: e);
      // updatePost 내부에서 에러 다이얼로그 표시됨
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: widget.padding ?? const EdgeInsets.all(16),
        shrinkWrap: true,
        children: [
          _buildTitleField(context),
          const SizedBox(height: 16),
          _buildContentField(context),
          const SizedBox(height: 16),
          if (_urls.isNotEmpty || _uploadingCount > 0)
            _buildFilePreview(context),
          if (_urls.isNotEmpty || _uploadingCount > 0)
            const SizedBox(height: 16),
          _buildActionBar(context),
        ],
      ),
    );
  }

  /// 제목 입력 필드 빌드
  Widget _buildTitleField(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        hintText: '제목을 입력하세요',
        filled: true,
        fillColor: scheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2.0),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '제목을 입력해주세요';
        }
        return null;
      },
    );
  }

  /// 내용 입력 필드 빌드
  Widget _buildContentField(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return TextFormField(
      controller: _contentController,
      maxLines: 32,
      minLines: 16,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: '내용을 입력하세요',
        filled: true,
        fillColor: scheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 2.0),
        ),
        contentPadding: const EdgeInsets.all(16),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '내용을 입력해주세요';
        }
        return null;
      },
    );
  }

  /// 파일 미리보기 빌드
  Widget _buildFilePreview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._urls.map(
              (url) => UploadPreview(
                url: url,
                width: imageWidth,
                height: imageWidth,
                borderRadius: 8,
                onDelete: () async {
                  final confirm = await showConfirmDialog(
                    message: '이 이미지를 삭제하시겠습니까?',
                  );

                  if (confirm != true) return;

                  try {
                    await philgoApiFileDelete(url);
                    _urls.remove(url);
                    setState(() {});

                    // 서버에 즉시 반영
                    await updatePost({'idx': widget.post.idx, 'files': _urls});

                    if (context.mounted) {
                      showSuccessSnackBar(context, '이미지가 삭제되었습니다');
                    }
                  } catch (e) {
                    log('파일 삭제 실패: $e', name: 'PostUpdateForm', error: e);
                    showSafeErrorDialog('파일 삭제에 실패했습니다.');
                  }
                },
              ),
            ),
            ...List.generate(
              _uploadingCount,
              (index) => LoadingBox(
                width: imageWidth,
                height: imageWidth,
                borderRadius: 8,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 하단 액션 바 빌드 (파일 업로드 버튼)
  Widget _buildActionBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        // 파일 업로드 버튼
        FileUpload(
          file: true,
          video: true,
          onBeforeUpload: _incrementUploadingCount,
          onUploaded: (url) {
            log('파일 업로드 완료: $url', name: 'PostUpdateForm');
            setState(() {
              _urls.add(url);
            });
            _decrementUploadingCount();
          },
          onCancelled: _decrementUploadingCount,
          child: Container(
            padding: const EdgeInsets.only(
              left: 0,
              right: 12,
              bottom: 12,
              top: 12,
            ),
            child: FaIcon(
              FontAwesomeIcons.lightCamera,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        const Spacer(),

        // 제출 버튼 (showSubmitButton이 true일 때만)
        if (widget.showSubmitButton)
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: (_isLoading || _uploadingCount > 0) ? null : submit,
            icon: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : FaIcon(
                    FontAwesomeIcons.paperPlane,
                    size: 24,
                    color: Theme.of(
                      context,
                    ).iconTheme.color!.withValues(alpha: 0.55),
                  ),
          ),
      ],
    );
  }
}
