// ignore: dangling_library_doc_comments
/// 구인(hiring) 카테고리 전용 글쓰기 폼
///
/// wanted 게시판의 hiring 카테고리에서만 사용되는 특수 폼입니다.
/// 일반 PostCreateForm과 달리 구인 정보에 필요한 필드들을 개별적으로 입력받습니다.
///
/// 필드 목록 (모두 필수):
/// - 제목 (subject)
/// - 회사 이름 (varchar_4)
/// - 회사 소개 (text_1)
/// - 업무 범위 (varchar_9)
/// - 주소 (varchar_5)
/// - 전화번호 (varchar_6)
/// - 이메일 (varchar_8)
/// - 급여 (int_1)
/// - 근무제 (varchar_7)

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 구인(hiring) 카테고리 전용 글쓰기/수정 폼 위젯
///
/// 생성 모드와 수정 모드를 모두 지원합니다.
/// - 생성 모드: post 파라미터가 null일 때
/// - 수정 모드: post 파라미터가 제공될 때
class WantedHiringForm extends StatefulWidget {
  const WantedHiringForm({
    super.key,
    this.post,
    this.onSubmitted,
    this.onLoadingChanged,
    this.onUploadingChanged,
    this.showSubmitButton = true,
    this.padding,
  });

  /// 수정할 글 (null이면 생성 모드)
  /// Post to edit (null means create mode)
  final Post? post;

  /// 수정 모드인지 확인
  /// Check if in edit mode
  bool get isEditMode => post != null;

  /// 제출 성공 시 콜백
  final void Function(Post createdPost)? onSubmitted;

  /// 로딩 상태 변경 시 콜백
  final void Function(bool isLoading)? onLoadingChanged;

  /// 파일 업로드 상태 변경 시 콜백
  final void Function(bool isUploading)? onUploadingChanged;

  /// 제출 버튼 표시 여부
  final bool showSubmitButton;

  /// 폼 전체 패딩
  final EdgeInsetsGeometry? padding;

  @override
  State<WantedHiringForm> createState() => WantedHiringFormState();
}

/// WantedHiringForm의 State 클래스
///
/// GlobalKey를 통해 외부에서 submit() 메서드 호출 가능:
/// ```dart
/// final formKey = GlobalKey<WantedHiringFormState>();
/// WantedHiringForm(key: formKey)
/// formKey.currentState?.submit();
/// ```
class WantedHiringFormState extends State<WantedHiringForm> {
  // 폼 유효성 검사 키
  final _formKey = GlobalKey<FormState>();

  // 텍스트 입력 컨트롤러 (9개 필드)
  final _subjectController = TextEditingController(); // 제목
  final _companyNameController = TextEditingController(); // 회사 이름 (varchar_4)
  final _companyIntroController = TextEditingController(); // 회사 소개 (text_1)
  final _workRangeController = TextEditingController(); // 업무 범위 (varchar_9)
  final _addressController = TextEditingController(); // 주소 (varchar_5)
  final _phoneController = TextEditingController(); // 전화번호 (varchar_6)
  final _emailController = TextEditingController(); // 이메일 (varchar_8)
  final _salaryController = TextEditingController(); // 급여 (int_1)
  final _workTypeController = TextEditingController(); // 근무제 (varchar_7)

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

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 기존 데이터로 필드 초기화
    // Initialize fields with existing data in edit mode
    if (widget.post != null) {
      final post = widget.post!;
      _subjectController.text = post.subject;
      _companyNameController.text = post.varchar4 ?? '';
      // text1 필드는 Post 모델에 없으므로 content에서 추출하거나 비워둠
      // text1 field is not in Post model, extract from content or leave empty
      _companyIntroController.text = '';
      _workRangeController.text = post.varchar9 ?? '';
      _addressController.text = post.varchar5 ?? '';
      _phoneController.text = post.varchar6 ?? '';
      _emailController.text = post.varchar8 ?? '';
      _salaryController.text = (post.int1 ?? 0).toString();
      _workTypeController.text = post.varchar7 ?? '';

      // 기존 파일 목록 복사
      // Copy existing file list
      _urls.addAll(post.files);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _companyNameController.dispose();
    _companyIntroController.dispose();
    _workRangeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _salaryController.dispose();
    _workTypeController.dispose();
    super.dispose();
  }

  /// 업로드 카운트 증가 (콜백 호출)
  void _incrementUploadingCount() {
    if (!mounted) return;
    setState(() {
      _uploadingCount++;
    });
    scheduleMicrotask(() {
      widget.onUploadingChanged?.call(true);
    });
  }

  /// 업로드 카운트 감소 (콜백 호출)
  void _decrementUploadingCount() {
    if (!mounted) return;
    setState(() {
      if (_uploadingCount > 0) {
        _uploadingCount--;
      }
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

  /// 디버그용 기본값 입력
  ///
  /// 개발자 모드에서 테스트를 위해 모든 필드에 기본값 채우기
  /// Fill all fields with default values for testing in developer mode
  void _fillWithDebugData() {
    _subjectController.text = '[테스트] IT 개발자 채용합니다';
    _companyNameController.text = '테스트 회사';
    _companyIntroController.text =
        '저희 회사는 IT 솔루션을 제공하는 기업입니다. 2020년 설립되어 필리핀 마닐라에 본사를 두고 있습니다.';
    _workRangeController.text = 'IT, 웹 개발, 모바일 앱 개발';
    _addressController.text = '123 Test Street, Makati City, Philippines';
    _phoneController.text = '09171234567';
    _emailController.text = 'hr@testcompany.com';
    _salaryController.text = '50000';
    _workTypeController.text = '주 5일, 월-금 09:00-18:00';
  }

  /// 외부에서 파일 업로드 완료 후 URL 추가
  ///
  /// AppBar의 FileUpload 버튼에서 사용됨
  void addUploadedFile(String url) {
    if (mounted) {
      setState(() {
        _urls.add(url);
      });
      log('파일 추가됨: $url', name: 'WantedHiringForm');
    }
  }

  /// 업로드된 파일 삭제 (서버에서도 삭제)
  Future<void> deleteUploadedFile(String url) async {
    try {
      log('파일 삭제 시작: $url', name: 'WantedHiringForm');
      await philgoApiFileDelete(url);

      if (mounted) {
        setState(() {
          _urls.remove(url);
        });
        log('파일 삭제 성공: $url', name: 'WantedHiringForm');
      }
    } catch (e) {
      log('파일 삭제 실패: $e', name: 'WantedHiringForm', error: e);
      showSafeErrorDialog('파일 삭제 실패: $e');
    }
  }

  /// 폼 제출 (생성 또는 수정)
  ///
  /// 외부에서 GlobalKey를 통해 호출 가능:
  /// ```dart
  /// formKey.currentState?.submit();
  /// ```
  ///
  /// widget.post가 있으면 수정 모드, 없으면 생성 모드
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
      // 급여를 int로 변환
      final salary = int.tryParse(_salaryController.text.trim()) ?? 0;

      // 수정 모드 또는 생성 모드 분기
      // Branch for edit mode or create mode
      if (widget.post != null) {
        // 수정 모드 (Edit mode)
        log('구인 글 수정 시작 - idx: ${widget.post!.idx}', name: 'WantedHiringForm');

        final updated = await updatePost({
          'idx': widget.post!.idx,
          'subject': _subjectController.text.trim(),
          'content': '', // 구인 폼에서는 content 불필요
          // 구인 필드들
          'varchar_4': _companyNameController.text.trim(), // 회사 이름
          'text_1': _companyIntroController.text.trim(), // 회사 소개
          'varchar_9': _workRangeController.text.trim(), // 업무 범위
          'varchar_5': _addressController.text.trim(), // 주소
          'varchar_6': _phoneController.text.trim(), // 전화번호
          'varchar_8': _emailController.text.trim(), // 이메일
          'int_1': salary, // 급여
          'varchar_7': _workTypeController.text.trim(), // 근무제
          'files': _urls,
        });

        log('구인 글 수정 성공 - idx: ${updated.idx}', name: 'WantedHiringForm');

        // 성공 콜백 호출
        widget.onSubmitted?.call(updated);
      } else {
        // 생성 모드 (Create mode)
        log('구인 글 작성 시작', name: 'WantedHiringForm');

        final created = await createPost({
          'post_id': 'wanted',
          'category': 'hiring',
          'subject': _subjectController.text.trim(),
          'content': '', // 구인 폼에서는 content 불필요 (API 필수 필드)
          // 구인 필드들 (모두 필수)
          'varchar_4': _companyNameController.text.trim(), // 회사 이름
          'text_1': _companyIntroController.text.trim(), // 회사 소개
          'varchar_9': _workRangeController.text.trim(), // 업무 범위
          'varchar_5': _addressController.text.trim(), // 주소
          'varchar_6': _phoneController.text.trim(), // 전화번호
          'varchar_8': _emailController.text.trim(), // 이메일
          'int_1': salary, // 급여
          'varchar_7': _workTypeController.text.trim(), // 근무제
          'files': _urls,
        });

        log('구인 글 작성 성공 - idx: ${created.idx}', name: 'WantedHiringForm');

        // 성공 콜백 호출
        widget.onSubmitted?.call(created);
      }

      return true;
    } catch (e) {
      final action = widget.post != null ? '수정' : '작성';
      log('구인 글 $action 실패: $e', name: 'WantedHiringForm', error: e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 텍스트 입력 필드 빌드 (공통)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validationMessage,
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨 (필수 표시 포함)
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 입력 필드
        TextFormField(
          controller: controller,
          enabled: !_isLoading,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.5),
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validationMessage;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 업로드 미리보기 빌드
  Widget _buildUploadPreview(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final columns = constraints.maxWidth >= 360 ? 4 : 3;
        final totalSpacing = spacing * (columns - 1);
        final filePreviewSize = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            // 업로드 완료된 이미지들
            ..._urls.map(
              (url) => IgnorePointer(
                ignoring: _isLoading,
                child: UploadPreview(
                  url: url,
                  width: filePreviewSize,
                  height: filePreviewSize,
                  borderRadius: 8,
                  onDelete: () async {
                    if (_isLoading) return;

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
            ),
            // 업로드 중인 플레이스홀더들
            ...List.generate(
              _uploadingCount,
              (index) => LoadingBox(
                width: filePreviewSize,
                height: filePreviewSize,
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
        IgnorePointer(
          ignoring: _isLoading || _uploadingCount > 0,
          child: Opacity(
            opacity: (_isLoading || _uploadingCount > 0) ? 0.38 : 1.0,
            child: FileUpload(
              file: true,
              video: true,
              onBeforeUpload: _incrementUploadingCount,
              onUploaded: (url) {
                log('파일 업로드 완료: $url', name: 'WantedHiringForm');

                _urls.add(url);
                if (!mounted) return;
                setState(() {});

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
                    FontAwesomeIcons.solidPaperPlane,
                    size: 24,
                    color: (_isLoading || _uploadingCount > 0)
                        ? colorScheme.onSurface.withValues(alpha: 0.38)
                        : colorScheme.primary,
                  ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);

    return Form(
      key: _formKey,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const SizedBox(height: 16),

          /// 디버그 모드일 때만 기본값 입력 버튼 표시
          /// Show debug fill button only in developer mode
          if (kDebugMode)
            Padding(
              padding: padding,
              child: OutlinedButton.icon(
                onPressed: _fillWithDebugData,
                icon: const FaIcon(FontAwesomeIcons.bug, size: 16),
                label: const Text('디버그: 기본값 입력'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.tertiary,
                  side: BorderSide(color: colorScheme.tertiary),
                ),
              ),
            ),

          /// 디버그 버튼과 제목 필드 사이 간격
          /// Spacing between debug button and title field
          if (kDebugMode) const SizedBox(height: 16),

          // 1. 제목
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _subjectController,
              label: '제목',
              hint: '구인 글 제목을 입력하세요',
              validationMessage: '제목을 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 2. 회사 이름
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _companyNameController,
              label: '회사 이름',
              hint: '채용 회사명을 입력하세요',
              validationMessage: '회사 이름을 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 3. 회사 소개
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _companyIntroController,
              label: '회사 소개',
              hint: '회사 소개를 입력하세요 (구인 정보 제외)',
              validationMessage: '회사 소개를 입력해주세요',
              maxLines: 4,
              minLines: 3,
            ),
          ),
          const SizedBox(height: 16),

          // 4. 업무 범위
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _workRangeController,
              label: '업무 범위',
              hint: '예: IT, 마케팅, 영업',
              validationMessage: '업무 범위를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 5. 주소
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _addressController,
              label: '필리핀 전체 주소',
              hint: '예: 123 Sample St., Makati City, Philippines',
              validationMessage: '주소를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 6. 전화번호
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _phoneController,
              label: '필리핀 전화번호',
              hint: '예: 09171234567',
              validationMessage: '전화번호를 입력해주세요',
              keyboardType: TextInputType.phone,
            ),
          ),
          const SizedBox(height: 16),

          // 7. 이메일
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _emailController,
              label: '이메일 주소',
              hint: '예: hr@company.com',
              validationMessage: '이메일을 입력해주세요',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),

          // 8. 급여
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _salaryController,
              label: '급여 (페소)',
              hint: '예: 50000',
              validationMessage: '급여를 입력해주세요',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
          const SizedBox(height: 16),

          // 9. 근무제
          Padding(
            padding: padding,
            child: _buildTextField(
              controller: _workTypeController,
              label: '근무제',
              hint: '예: 주 5일, 월-금',
              validationMessage: '근무제를 입력해주세요',
            ),
          ),
          const SizedBox(height: 16),

          // 액션 바 (파일 업로드 + 제출 버튼)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildActionBar(context),
          ),

          // 업로드 미리보기
          if (_urls.isNotEmpty || _uploadingCount > 0) ...[
            const SizedBox(height: 16),
            Padding(
              padding: padding,
              child: _buildUploadPreview(context),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
