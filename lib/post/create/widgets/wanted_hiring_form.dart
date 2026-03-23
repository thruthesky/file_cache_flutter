import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/api/api.service.dart';
import 'package:philgo/file/upload/file_upload.model.dart';
import 'package:philgo/file/upload/widgets/file_upload.dart';
import 'package:philgo/file/widgets/uploaded_file_preview.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';

/// 구인(hiring) 카테고리 전용 글쓰기/수정 폼 위젯
///
/// wanted 게시판의 hiring 카테고리에서만 사용되는 특수 폼.
/// 일반 PostCreateForm과 달리 구인 정보에 필요한 필드들을 개별적으로 입력받는다.
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
class WantedHiringForm extends StatefulWidget {
  const WantedHiringForm({super.key, this.post});

  /// 수정할 글 (null이면 생성 모드)
  final Post? post;

  /// 수정 모드인지 확인
  bool get isEditMode => post != null;

  @override
  State<WantedHiringForm> createState() => WantedHiringFormState();
}

class WantedHiringFormState extends State<WantedHiringForm> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyIntroController = TextEditingController();
  final _workRangeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  final _workTypeController = TextEditingController();

  bool _isSubmitting = false;
  int _uploadingCount = 0;
  final List<FileUploadModel> _newFiles = [];

  /// 기존 첨부파일 URL 목록 (수정 모드)
  late List<String> _existingUrls;

  @override
  void initState() {
    super.initState();

    _existingUrls = [];

    if (widget.post != null) {
      final post = widget.post!;
      _subjectController.text = post.subject;
      _companyNameController.text = post.varchar4;
      _companyIntroController.text = post.text1;
      _workRangeController.text = post.varchar9;
      _addressController.text = post.varchar5;
      _phoneController.text = post.varchar6;
      _emailController.text = post.varchar8;
      _salaryController.text = post.int1 > 0 ? post.int1.toString() : '';
      _workTypeController.text = post.varchar7;

      if (post.files.isNotEmpty) {
        _existingUrls = post.files
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
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

  /// 구인 전용 필드 Map 생성
  Map<String, dynamic> _buildHiringExtra() {
    final salary = int.tryParse(_salaryController.text.trim()) ?? 0;
    return {
      'varchar_4': _companyNameController.text.trim(),
      'text_1': _companyIntroController.text.trim(),
      'varchar_9': _workRangeController.text.trim(),
      'varchar_5': _addressController.text.trim(),
      'varchar_6': _phoneController.text.trim(),
      'varchar_8': _emailController.text.trim(),
      'int_1': salary,
      'varchar_7': _workTypeController.text.trim(),
    };
  }

  /// 폼 제출 (생성 또는 수정)
  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSubmitting || _uploadingCount > 0) return;

    setState(() => _isSubmitting = true);

    final allFiles = [
      ..._existingUrls,
      ..._newFiles.map((f) => f.path),
    ];

    if (widget.isEditMode) {
      // 수정 모드
      final updated = await PostService.update(
        idx: widget.post!.idx,
        subject: _subjectController.text.trim(),
        content: '',
        files: allFiles,
        extra: _buildHiringExtra(),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(updated);
    } else {
      // 생성 모드
      final created = await PostService.create(
        postId: 'wanted',
        subject: _subjectController.text.trim(),
        content: '',
        category: 'hiring',
        files: allFiles,
        extra: _buildHiringExtra(),
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(created);
    }
  }

  /// 디버그용 기본값 입력
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

  /// 기존 첨부파일 삭제
  Future<void> _deleteExistingFile(String url) async {
    setState(() => _existingUrls = List.from(_existingUrls)..remove(url));
    await ApiService.instance.fileDeleteByUrl(url);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String validationMessage,
    int maxLines = 1,
    int? minLines,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              FaIcon(icon, size: 14, color: color.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: text.labelLarge?.copyWith(
                color: color.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: text.labelLarge?.copyWith(
                color: color.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !_isSubmitting,
          maxLines: maxLines,
          minLines: minLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
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

  @override
  Widget build(BuildContext context) {
    final hasFiles =
        _existingUrls.isNotEmpty || _newFiles.isNotEmpty || _uploadingCount > 0;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 디버그 모드 기본값 입력 버튼
          if (kDebugMode) ...[
            OutlinedButton.icon(
              onPressed: _fillWithDebugData,
              icon: const FaIcon(FontAwesomeIcons.bug, size: 16),
              label: const Text('디버그: 기본값 입력'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color.tertiary,
                side: BorderSide(color: color.tertiary),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 1. 제목
          _buildTextField(
            controller: _subjectController,
            // "Title"
            label: '제목'.tr(),
            // "Enter job posting title"
            hint: '구인 글 제목을 입력하세요'.tr(),
            // "Please enter a title"
            validationMessage: '제목을 입력해주세요'.tr(),
            icon: FontAwesomeIcons.lightPenLine,
          ),
          const SizedBox(height: 16),

          // 2. 회사 이름
          _buildTextField(
            controller: _companyNameController,
            // "Company Name"
            label: '회사 이름'.tr(),
            // "Enter company name"
            hint: '채용 회사명을 입력하세요'.tr(),
            // "Please enter company name"
            validationMessage: '회사 이름을 입력해주세요'.tr(),
            icon: FontAwesomeIcons.lightBuilding,
          ),
          const SizedBox(height: 16),

          // 3. 회사 소개
          _buildTextField(
            controller: _companyIntroController,
            // "Company Introduction"
            label: '회사 소개'.tr(),
            // "Enter company introduction"
            hint: '회사 소개를 입력하세요'.tr(),
            // "Please enter company introduction"
            validationMessage: '회사 소개를 입력해주세요'.tr(),
            maxLines: 4,
            minLines: 3,
            icon: FontAwesomeIcons.lightCircleInfo,
          ),
          const SizedBox(height: 16),

          // 4. 업무 범위
          _buildTextField(
            controller: _workRangeController,
            // "Job Scope"
            label: '업무 범위'.tr(),
            // "e.g. IT, Marketing, Sales"
            hint: '예: IT, 마케팅, 영업'.tr(),
            // "Please enter job scope"
            validationMessage: '업무 범위를 입력해주세요'.tr(),
            icon: FontAwesomeIcons.lightBriefcase,
          ),
          const SizedBox(height: 16),

          // 5. 주소
          _buildTextField(
            controller: _addressController,
            // "Philippines Full Address"
            label: '필리핀 전체 주소'.tr(),
            // "e.g. 123 Sample St., Makati City"
            hint: '예: 123 Sample St., Makati City'.tr(),
            // "Please enter address"
            validationMessage: '주소를 입력해주세요'.tr(),
            icon: FontAwesomeIcons.lightLocationDot,
          ),
          const SizedBox(height: 16),

          // 6. 전화번호
          _buildTextField(
            controller: _phoneController,
            // "Philippines Phone Number"
            label: '필리핀 전화번호'.tr(),
            // "e.g. 09171234567"
            hint: '예: 09171234567'.tr(),
            // "Please enter phone number"
            validationMessage: '전화번호를 입력해주세요'.tr(),
            keyboardType: TextInputType.phone,
            icon: FontAwesomeIcons.lightPhone,
          ),
          const SizedBox(height: 16),

          // 7. 이메일
          _buildTextField(
            controller: _emailController,
            // "Email Address"
            label: '이메일 주소'.tr(),
            // "e.g. hr@company.com"
            hint: '예: hr@company.com'.tr(),
            // "Please enter email"
            validationMessage: '이메일을 입력해주세요'.tr(),
            keyboardType: TextInputType.emailAddress,
            icon: FontAwesomeIcons.lightEnvelope,
          ),
          const SizedBox(height: 16),

          // 8. 급여
          _buildTextField(
            controller: _salaryController,
            // "Salary (Peso)"
            label: '급여 (페소)'.tr(),
            // "e.g. 50000"
            hint: '예: 50000'.tr(),
            // "Please enter salary"
            validationMessage: '급여를 입력해주세요'.tr(),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            icon: FontAwesomeIcons.lightMoneyBill,
          ),
          const SizedBox(height: 16),

          // 9. 근무제
          _buildTextField(
            controller: _workTypeController,
            // "Work Schedule"
            label: '근무제'.tr(),
            // "e.g. 5 days/week, Mon-Fri"
            hint: '예: 주 5일, 월-금'.tr(),
            // "Please enter work schedule"
            validationMessage: '근무제를 입력해주세요'.tr(),
            icon: FontAwesomeIcons.lightClock,
          ),
          const SizedBox(height: 16),

          // 파일 업로드 버튼
          Row(
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    // "Upload failed"
                    SnackBar(content: Text('${'업로드 실패'.tr()}: $e')),
                  );
                },
                child: FaIcon(
                  FontAwesomeIcons.lightCamera,
                  size: 20,
                  color: color.primary,
                ),
              ),
            ],
          ),

          // 파일 미리보기
          if (hasFiles) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._existingUrls.map((url) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: color.surfaceContainerHighest,
                            child: FaIcon(
                              FontAwesomeIcons.lightImage,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _deleteExistingFile(url),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: color.error,
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.xmark,
                              size: 10,
                              color: color.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                ..._newFiles.map((f) {
                  return UploadedFilePreview(
                    file: f,
                    onDelete: () => setState(() => _newFiles.remove(f)),
                  );
                }),
                for (int i = 0; i < _uploadingCount; i++)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.outlineVariant),
                      color: color.surfaceContainerHighest,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
