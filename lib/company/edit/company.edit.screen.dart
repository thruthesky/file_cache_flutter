import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/company/company.model.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/company/edit/widgets/form/form.basic.info.dart';
import 'package:philgo/company/edit/widgets/form/form.contact.info.dart';
import 'package:philgo/company/edit/widgets/form/form.image.upload.dart';
import 'package:philgo/company/edit/widgets/form/form.review.dart';
import 'package:philgo/company/edit/widgets/form_step_tracker.dart';

/// 업소 정보 수정 멀티 스텝 폼 화면
///
/// 총 4단계로 업소 정보를 입력받아 저장한다.
/// Step 1: 기본 정보
/// Step 2: 위치 및 연락처 (카카오톡 QR 자동 파싱 포함)
/// Step 3: 이미지 업로드 (사업자등록증, 사무실 내부 사진 포함)
/// Step 4: 검토 및 저장
class CompanyEditScreen extends StatefulWidget {
  static const String routeName = '/CompanyEdit';
  static Function(BuildContext ctx, {required CompanyModel company}) push =
      (ctx, {required company}) =>
          ctx.push(routeName, extra: company);

  final CompanyModel company;

  const CompanyEditScreen({super.key, required this.company});

  @override
  State<CompanyEditScreen> createState() => _CompanyEditScreenState();
}

class _CompanyEditScreenState extends State<CompanyEditScreen> {
  int _currentStep = 0;
  static const int _totalSteps = 4;

  bool _isSaving = false;

  // Step 1 controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  String? _selectedCategory;

  // Step 2 controllers
  late final TextEditingController _locationCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _kakaoCtrl;
  late final TextEditingController _telegramCtrl;
  late final TextEditingController _kakaoChannelUrlCtrl;
  String? _kakaoQrCodeUrl;

  // Step 3 image URLs (from existing company)
  String? _logoUrl;
  String? _titleImageUrl;
  String? _photoUrl;
  String? _businessLicenseUrl;

  final _formKey = GlobalKey<FormState>();

  // "Basic Info", "Contact", "Images", "Review"
  static final _stepLabels = ['기본정보'.tr(), '연락처'.tr(), '이미지'.tr(), '검토'.tr()];

  @override
  void initState() {
    super.initState();
    final c = widget.company;
    _nameCtrl = TextEditingController(text: c.name);
    _titleCtrl = TextEditingController(text: c.title);
    _descCtrl = TextEditingController(text: c.description);
    _selectedCategory = c.category.isNotEmpty ? c.category : null;

    _locationCtrl = TextEditingController(text: c.location);
    _addressCtrl = TextEditingController(text: c.address);
    _phoneCtrl = TextEditingController(text: c.phoneNumber);
    _mobileCtrl = TextEditingController(text: c.mobileNumber);
    _kakaoCtrl = TextEditingController(text: c.kakaotalkId);
    _telegramCtrl = TextEditingController(text: c.telegramId);
    _kakaoChannelUrlCtrl = TextEditingController(text: c.kakaotalkQrCode);
    _kakaoQrCodeUrl = c.kakaotalkQrCodeUrl.isNotEmpty ? c.kakaotalkQrCodeUrl : null;

    _logoUrl = c.logoUrl.isNotEmpty ? c.logoUrl : null;
    _titleImageUrl = c.titleImageUrl.isNotEmpty ? c.titleImageUrl : null;
    _photoUrl = c.photoUrl.isNotEmpty ? c.photoUrl : null;
    _businessLicenseUrl = c.businessLicenseUrl.isNotEmpty ? c.businessLicenseUrl : null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _mobileCtrl.dispose();
    _kakaoCtrl.dispose();
    _telegramCtrl.dispose();
    _kakaoChannelUrlCtrl.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _formKey.currentState?.validate() ?? false;
    }
    return true;
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final data = <String, dynamic>{
      'idx': widget.company.idx,
      'name': _nameCtrl.text.trim(),
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'category': _selectedCategory ?? '',
      'location': _locationCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'mobile_number': _mobileCtrl.text.trim(),
      'kakaotalk_id': _kakaoCtrl.text.trim(),
      'telegram_id': _telegramCtrl.text.trim(),
      'kakaotalk_qr_code': _kakaoChannelUrlCtrl.text.trim(),
      'kakaotalk_qr_code_url': _kakaoQrCodeUrl ?? '',
      'logo_url': _logoUrl ?? '',
      'title_image_url': _titleImageUrl ?? '',
      'photo_url': _photoUrl ?? '',
      'business_license_url': _businessLicenseUrl ?? '',
    };

    await CompanyService.update(data);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // "Business info saved. It will be reflected after admin review."
        content: Text('업소 정보가 저장되었습니다. 관리자 검토 후 반영됩니다.'.tr()),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    Navigator.of(context).pop(true); // return true = updated
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _totalSteps - 1;

    return Scaffold(
      appBar: AppBar(
        // "Edit Business Info"
        title: Text('업소 정보 수정'.tr()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Step tracker
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: FormStepTracker(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                labels: _stepLabels,
              ),
            ),
            const Divider(height: 1),

            // Step content
            Expanded(child: _buildStepContent()),

            // Bottom navigation
            _buildBottomBar(isLastStep),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return CompanyBasicInfoForm(
          nameController: _nameCtrl,
          titleController: _titleCtrl,
          descriptionController: _descCtrl,
          selectedCategory: _selectedCategory,
          onCategoryChanged: (v) => setState(() => _selectedCategory = v),
        );
      case 1:
        return CompanyContactInfoForm(
          locationController: _locationCtrl,
          addressController: _addressCtrl,
          phoneController: _phoneCtrl,
          mobileController: _mobileCtrl,
          kakaoController: _kakaoCtrl,
          telegramController: _telegramCtrl,
          kakaoChannelUrlController: _kakaoChannelUrlCtrl,
          kakaoQrCodeUrl: _kakaoQrCodeUrl,
          onKakaoQrCodeUploaded: (url) => setState(() => _kakaoQrCodeUrl = url),
        );
      case 2:
        return CompanyImageUploadForm(
          logoUrl: _logoUrl,
          titleImageUrl: _titleImageUrl,
          photoUrl: _photoUrl,
          businessLicenseUrl: _businessLicenseUrl,
          onLogoUploaded: (url) => setState(() => _logoUrl = url),
          onTitleImageUploaded: (url) => setState(() => _titleImageUrl = url),
          onPhotoUploaded: (url) => setState(() => _photoUrl = url),
          onBusinessLicenseUploaded: (url) => setState(() => _businessLicenseUrl = url),
        );
      case 3:
        return CompanyReviewForm(
          name: _nameCtrl.text,
          category: _selectedCategory ?? '',
          title: _titleCtrl.text,
          description: _descCtrl.text,
          location: _locationCtrl.text,
          address: _addressCtrl.text,
          phone: _phoneCtrl.text,
          mobile: _mobileCtrl.text,
          kakao: _kakaoCtrl.text,
          telegram: _telegramCtrl.text,
          logoUrl: _logoUrl,
          titleImageUrl: _titleImageUrl,
          photoUrl: _photoUrl,
          businessLicenseUrl: _businessLicenseUrl,
          kakaoChannelUrl: _kakaoChannelUrlCtrl.text,
          kakaoQrCodeUrl: _kakaoQrCodeUrl,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(bool isLastStep) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: _isSaving ? null : _goBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(80, 44),
              ),
              // "Cancel", "Previous"
              child: Text(_currentStep == 0 ? '취소'.tr() : '이전'.tr()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving
                    ? null
                    : (isLastStep ? _save : _goNext),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    // "Save", "Next"
                    : Text(isLastStep ? '저장하기'.tr() : '다음'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
