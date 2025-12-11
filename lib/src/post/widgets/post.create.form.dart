// ignore: dangling_library_doc_comments
///
/// Screen이나 Dialog에서 재사용 가능한 글 쓰기 폼입니다.
/// 제목, 내용, 파일 업로드, 카테고리 선택 기능을 제공합니다.
///
/// 사용 예시:
/// ```dart
/// // Screen에서 사용
/// PostCreateForm(
///   postId: 'freetalk',
///   category: '취미',
///   onSubmitted: (post) => Navigator.pop(context, post),
///   onCancelled: () => Navigator.pop(context),
/// )
///
/// // Dialog에서 사용
/// showDialog(
///   context: context,
///   builder: (context) => Dialog(
///     child: PostCreateForm(
///       postId: 'qna',
///       showCategorySelector: true,
///       onSubmitted: (post) => Navigator.pop(context, post),
///     ),
///   ),
/// )
/// ```

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:philgo_api/philgo_api.dart';

/// 글 쓰기 폼 위젯
///
/// [postId] 메인 카테고리 (필수) - freetalk, qna, buyandsell 등
/// [category] 서브 카테고리 (옵션) - 취미, 백과, 여권/비자 등
/// [initialTitle] 초기 제목 값
/// [initialContent] 초기 내용 값
/// [initialFiles] 초기 파일 목록 (자동 업로드됨)
/// [onSubmitted] 제출 성공 시 콜백 (생성된 Post 객체 전달)
/// [onCancelled] 취소 시 콜백
/// [onLoadingChanged] 로딩 상태 변경 시 콜백
/// [onUploadingChanged] 파일 업로드 상태 변경 시 콜백
/// [showCategorySelector] 카테고리 선택 UI 표시 여부
/// [showSubmitButton] 제출 버튼 표시 여부 (false면 외부에서 submit() 호출)
/// [padding] 폼 전체 패딩
class PostCreateForm extends StatefulWidget {
  const PostCreateForm({
    super.key,
    required this.postId,
    this.category,
    this.initialTitle,
    this.initialContent,
    this.initialFiles,
    this.onSubmitted,
    this.onCancelled,
    this.onLoadingChanged,
    this.onUploadingChanged,
    this.showCategorySelector = false,
    this.showSubmitButton = true,
    this.padding,
  });

  /// 메인 카테고리 (post_id) - 필수
  final String postId;

  /// 서브 카테고리 - 옵션
  final String? category;

  /// 초기 제목 값
  final String? initialTitle;

  /// 초기 내용 값
  final String? initialContent;

  /// 초기 파일 목록 (XFile) - 자동 업로드됨
  final List<XFile>? initialFiles;

  /// 제출 성공 시 콜백
  final void Function(Post createdPost)? onSubmitted;

  /// 취소 시 콜백
  final VoidCallback? onCancelled;

  /// 로딩 상태 변경 시 콜백
  final void Function(bool isLoading)? onLoadingChanged;

  /// 파일 업로드 상태 변경 시 콜백
  final void Function(bool isUploading)? onUploadingChanged;

  /// 카테고리 선택 UI 표시 여부
  final bool showCategorySelector;

  /// 제출 버튼 표시 여부
  final bool showSubmitButton;

  /// 폼 전체 패딩
  final EdgeInsetsGeometry? padding;

  @override
  State<PostCreateForm> createState() => PostCreateFormState();
}

/// PostCreateForm의 State 클래스
///
/// GlobalKey를 통해 외부에서 submit(), reset() 등의 메서드 호출 가능:
/// ```dart
/// final formKey = GlobalKey<PostCreateFormState>();
///
/// PostCreateForm(key: formKey, postId: 'freetalk')
///
/// // 외부에서 제출
/// formKey.currentState?.submit();
/// ```
class PostCreateFormState extends State<PostCreateForm> {
  // 텍스트 입력 컨트롤러
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  // 폼 유효성 검사 키
  final _formKey = GlobalKey<FormState>();

  // 현재 선택된 카테고리
  late String _selectedPostId;
  String? _selectedCategory;

  // 로딩 상태
  bool _isLoading = false;

  // 파일 업로드 상태
  int _uploadingCount = 0;

  // 업로드된 파일 URL 목록
  final List<String> _urls = [];

  /// 현재 로딩 중인지 여부
  bool get isLoading => _isLoading;

  /// 현재 파일 업로드 중인지 여부
  bool get isUploading => _uploadingCount > 0;

  /// 입력된 내용이 있는지 여부
  bool get hasContent =>
      _titleController.text.trim().isNotEmpty ||
      _contentController.text.trim().isNotEmpty ||
      _urls.isNotEmpty;

  /// 현재 선택된 메인 카테고리
  String get selectedPostId => _selectedPostId;

  /// 현재 선택된 서브 카테고리
  String? get selectedCategory => _selectedCategory;

  /// 업로드된 파일 URL 목록
  List<String> get uploadedUrls => List.unmodifiable(_urls);

  @override
  void initState() {
    super.initState();

    // 초기 카테고리 설정
    _selectedPostId = widget.postId;
    _selectedCategory = widget.category;

    // 초기 제목/내용 설정
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialContent != null) {
      _contentController.text = widget.initialContent!;
    }

    // 초기 파일 업로드
    if (widget.initialFiles != null && widget.initialFiles!.isNotEmpty) {
      _uploadInitialFiles();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 초기 파일들을 서버에 업로드
  Future<void> _uploadInitialFiles() async {
    for (final file in widget.initialFiles!) {
      _incrementUploadingCount();

      try {
        log('파일 업로드 시작: ${file.path}', name: 'PostCreateForm');
        final uploadedFile = await philgoApiFileUpload(file.path);

        if (uploadedFile != null) {
          log('파일 업로드 성공: ${uploadedFile.url}', name: 'PostCreateForm');
          if (mounted) {
            setState(() {
              _urls.add(uploadedFile.url);
            });
          }
        }
      } catch (e) {
        log('파일 업로드 실패: $e', name: 'PostCreateForm', error: e);
        if (mounted) {
          showSafeErrorDialog('파일 업로드 실패: $e');
        }
      } finally {
        _decrementUploadingCount();
      }
    }
  }

  /// 업로드 카운트 증가 (콜백 호출)
  void _incrementUploadingCount() {
    setState(() {
      _uploadingCount++;
    });
    scheduleMicrotask(() {
      widget.onUploadingChanged?.call(true);
    });
  }

  /// 업로드 카운트 감소 (콜백 호출)
  void _decrementUploadingCount() {
    setState(() {
      _uploadingCount--;
    });
    if (_uploadingCount == 0) {
      scheduleMicrotask(() {
        widget.onUploadingChanged?.call(false);
      });
    }
  }

  /// 로딩 상태 설정 (콜백 호출)
  void _setLoading(bool value) {
    if (mounted) {
      setState(() {
        _isLoading = value;
      });
      widget.onLoadingChanged?.call(value);
    }
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
      log(
        '글 작성 시작 - postId: $_selectedPostId, category: $_selectedCategory',
        name: 'PostCreateForm',
      );
      log('업로드된 파일 개수: ${_urls.length}', name: 'PostCreateForm');

      // API 호출하여 글 작성
      final created = await createPost({
        'post_id': _selectedPostId,
        if (_selectedCategory != null) 'category': _selectedCategory,
        'subject': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'files': _urls,
      });

      log('글 작성 성공 - idx: ${created.idx}', name: 'PostCreateForm');

      // 성공 콜백 호출
      widget.onSubmitted?.call(created);
      return true;
    } catch (e) {
      log('글 작성 실패: $e', name: 'PostCreateForm', error: e);
      // createPost 내부에서 에러 다이얼로그 표시됨
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 폼 초기화
  // void reset() {
  //   _titleController.clear();
  //   _contentController.clear();
  //   setState(() {
  //     _selectedPostId = widget.postId;
  //     _selectedCategory = widget.category;
  //     _urls.clear();
  //     _isLoading = false;
  //     _uploadingCount = 0;
  //   });
  // }

  /// 업로드된 파일 삭제 (서버에서도 삭제)
  Future<void> deleteUploadedFile(String url) async {
    try {
      log('파일 삭제 시작: $url', name: 'PostCreateForm');
      await philgoApiFileDelete(url);

      if (mounted) {
        setState(() {
          _urls.remove(url);
        });
        log('파일 삭제 성공: $url', name: 'PostCreateForm');
      }
    } catch (e) {
      log('파일 삭제 실패: $e', name: 'PostCreateForm', error: e);
      showSafeErrorDialog('파일 삭제 실패: $e');
    }
  }

  /// 취소 처리 (업로드된 파일 삭제 후 콜백 호출)
  Future<void> cancel() async {
    // 업로드된 파일들 서버에서 삭제
    if (_urls.isNotEmpty) {
      await Future.wait(_urls.map((url) => philgoApiFileDelete(url)));
      log('모든 파일 삭제 완료', name: 'PostCreateForm');
    }

    // 취소 콜백 호출
    widget.onCancelled?.call();
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
          if (widget.showCategorySelector) ...[
            _buildCategorySelector(context),
            const SizedBox(height: 16),
          ],
          _buildTitleField(context),
          const SizedBox(height: 16),
          if (_urls.isNotEmpty || _uploadingCount > 0) ...[
            _buildUploadPreview(context),
            const SizedBox(height: 16),
          ],
          _buildContentField(context),
          const SizedBox(height: 16),

          _buildActionBar(context),
        ],
      ),
    );
  }

  /// 카테고리 선택 UI 빌드
  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final subCategories = PhilgoCategory.subCategories(_selectedPostId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 메인 카테고리 드롭다운
        Text(
          '게시판 선택',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline,
              width: 2.0, // Comic Design: 2.0px 테두리
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPostId,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(12),
              items: PhilgoCategory.mainCategories().map((postId) {
                return DropdownMenuItem(value: postId, child: Text(postId));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPostId = value;
                    // 메인 카테고리 변경 시 서브 카테고리 초기화
                    _selectedCategory = null;
                  });
                }
              },
            ),
          ),
        ),

        // 서브 카테고리 드롭다운 (서브 카테고리가 있는 경우에만)
        if (subCategories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '카테고리 선택 (선택사항)',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline,
                width: 2.0, // Comic Design: 2.0px 테두리
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _selectedCategory,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                borderRadius: BorderRadius.circular(12),
                hint: const Text('전체'),
                items: [
                  // 전체 옵션 (null)
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('전체'),
                  ),
                  // 서브 카테고리 목록
                  ...subCategories.map((category) {
                    return DropdownMenuItem<String?>(
                      value: category,
                      child: Text(category),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 제목 입력 필드 빌드
  Widget _buildTitleField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFieldSet(
      padding: EdgeInsets.zero,
      controller: _titleController,
      decoration: InputDecoration(
        hintText: '제목을 입력하세요',
        filled: true,
        fillColor: colorScheme.surface,
        // Comic Design: 2.0px 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
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
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: _contentController,
      maxLines: 32,
      minLines: 16,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: '내용을 입력하세요',
        filled: true,
        fillColor: colorScheme.surface,
        // Comic Design: 2.0px 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
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

  /// 업로드 미리보기 빌드
  Widget _buildUploadPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 2열 그리드 레이아웃
        final imageWidth = (constraints.maxWidth - 8) / 2;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 업로드 완료된 이미지들
            ..._urls.map(
              (url) => UploadPreview(
                url: url,
                width: imageWidth,
                height: imageWidth,
                borderRadius: 8,
                onDelete: () async {
                  // 삭제 확인 다이얼로그 표시
                  final confirm = await showConfirmDialog(
                    message: '이 이미지를 삭제하시겠습니까?',
                  );

                  if (confirm == true) {
                    await deleteUploadedFile(url);
                  }
                },
              ),
            ),
            // 업로드 중인 플레이스홀더들
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

  /// 하단 액션 바 빌드
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
            log('파일 업로드 완료: $url', name: 'PostCreateForm');
            setState(() {
              _urls.add(url);
            });
            _decrementUploadingCount();
          },
          onCancelled: _decrementUploadingCount,
          child: Container(
            padding: const EdgeInsets.all(12),
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
                    ).iconTheme.color!.withValues(alpha: 0.35),
                  ),
          ),
      ],
    );
  }
}
