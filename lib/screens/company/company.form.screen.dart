import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/screens/company/form-sections/form.basic.info.dart';
import 'package:philgo/screens/company/form-sections/form.contact.info.dart';
import 'package:philgo/screens/company/form-sections/form.detailed.info.dart';
import 'package:philgo/screens/company/form-sections/form.image.upload.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/step.progress.indicator.dart';
import 'package:philgo/widgets/theme/comic_button.dart';
import 'package:philgo/widgets/theme/comic_snackbar.dart';
import 'package:philgo_api/philgo_api.dart';

/// 회사 정보 입력 폼 화면 - 멀티스텝
/// Multi-step company form screen with transitions
class CompanyFormScreen extends StatefulWidget {
  static const String routeName = '/company-form';

  static Future<Company?> Function(BuildContext ctx, {Company? company}) push =
      (ctx, {company}) => ctx.push(routeName, extra: company);

  const CompanyFormScreen({super.key, this.company});

  final Company? company;

  @override
  State<CompanyFormScreen> createState() => _CompanyFormScreenState();
}

class _CompanyFormScreenState extends State<CompanyFormScreen> {
  // 폼 필드 컨트롤러
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _landlineController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _kakaotalkIdController;
  late TextEditingController _kakaotalkQrCodeController;
  late TextEditingController _telegramIdController;
  late TextEditingController _familySiteDomainController;
  late TextEditingController _familySiteNameController;
  late TextEditingController _familySiteDescriptionController;

  // 카테고리 및 비즈니스 타입 선택
  String? _selectedCategory;

  // 체크박스 상태
  bool _useCompanyDomain = false;

  // 모바일 연락 방법 (문자/전화)
  String? _mobileContactMethod;

  // 이미지 URL
  String _logoUrl = '';
  String _companyIntroImageUrl = '';
  String _businessLicenseUrl = '';
  String _kakaoTalkQrCodeUrl = '';
  String _officeInteriorUrl = '';

  // 스텝 관리
  int _currentStep = 0;
  final int _totalSteps = 4;
  late PageController _pageController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // 기존 데이터로 컨트롤러 초기화
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _titleController = TextEditingController(text: widget.company?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.company?.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.company?.location ?? '',
    );
    _addressController = TextEditingController(
      text: widget.company?.address ?? '',
    );
    _landlineController = TextEditingController(
      text: widget.company?.phone_number ?? '',
    );
    _mobileNumberController = TextEditingController(
      text: widget.company?.mobile_number ?? '',
    );
    _kakaotalkIdController = TextEditingController(
      text: widget.company?.kakaotalk_id ?? '',
    );
    _kakaotalkQrCodeController = TextEditingController(
      text: widget.company?.kakaotalk_qr_code ?? '',
    );

    _telegramIdController = TextEditingController(
      text: widget.company?.telegram_id ?? '',
    );

    _familySiteDomainController = TextEditingController(
      text: widget.company?.family_site_domain ?? '',
    );

    _familySiteNameController = TextEditingController(
      text: widget.company?.family_site_name ?? '',
    );

    _familySiteDescriptionController = TextEditingController(
      text: widget.company?.family_site_description ?? '',
    );

    // 카테고리 설정
    final category = widget.company?.category;
    _selectedCategory = (category == null || category.isEmpty)
        ? null
        : category;

    // 모바일 연락 방법 설정
    final callType = widget.company?.mobile_number_call_type;
    if (callType == 'T') {
      _mobileContactMethod = 'text';
    } else if (callType == 'C') {
      _mobileContactMethod = 'call';
    }

    // 이미지 URL 설정
    _logoUrl = widget.company?.logo_url ?? '';
    _kakaoTalkQrCodeUrl = widget.company?.kakaotalk_qr_code_url ?? '';
    _companyIntroImageUrl = widget.company?.title_image_url ?? '';
    _businessLicenseUrl = widget.company?.business_license_url ?? '';
    _officeInteriorUrl = widget.company?.photo_url ?? '';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _landlineController.dispose();
    _mobileNumberController.dispose();
    _kakaotalkIdController.dispose();
    _kakaotalkQrCodeController.dispose();
    _telegramIdController.dispose();
    _familySiteDescriptionController.dispose();
    _familySiteDomainController.dispose();
    _familySiteNameController.dispose();
    super.dispose();
  }

  /// 다음 스텝으로 이동
  void _nextStep() {
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  /// 이전 스텝으로 이동
  void _backStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: 300.ms,
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic Info
        if (_nameController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.companyNameRequired);
          return false;
        }
        return true;

      case 1: // Detailed Info
        if (_titleController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.companyTitleRequired);
          return false;
        }
        if (_selectedCategory == null) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, T.pleaseSelectCategory);
          return false;
        }
        if (_locationController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.locationRequired);
          return false;
        }
        if (_addressController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.addressRequired);
          return false;
        }
        if (_descriptionController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.descriptionRequired);
          return false;
        }
        return true;

      case 2: // Contact Info
        if (_landlineController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.landlineRequired);
          return false;
        }
        if (_mobileNumberController.text.trim().isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.mobileNumberRequired);
          return false;
        }
        return true;

      case 3: // Image Upload
        if (_logoUrl.isEmpty) {
          // Comic Design: Use Comic SnackBar for validation errors
          showComicErrorSnackBar(context, Lo.of(context)!.logoRequired);
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _handleSubmit() async {
    if (!_validateCurrentStep()) {
      return;
    }

    _isSubmitting = true;
    setState(() {});

    try {
      // API 전송용 회사 데이터 준비
      final companyData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory!,
        'location': _locationController.text.trim(),
        'address': _addressController.text.trim(),
        'phone_number': _landlineController.text.trim(),
        'mobile_number': _mobileNumberController.text.trim(),
        'kakaotalk_id': _kakaotalkIdController.text.trim(),
        'kakaotalk_qr_code': _kakaotalkQrCodeController.text.trim(),
        'telegram_id': _telegramIdController.text.trim(),
        'logo_url': _logoUrl,
        'family_site_domain': _familySiteDomainController.text.trim(),
        'family_site_name': _familySiteNameController.text.trim(),
        'family_site_description': _familySiteDescriptionController.text.trim(),
      };

      if (_mobileContactMethod != null) {
        companyData['mobile_number_call_type'] = _mobileContactMethod == 'text'
            ? 'T'
            : 'C';
      }

      companyData['title_image_url'] = _companyIntroImageUrl;
      companyData['business_license_url'] = _businessLicenseUrl;
      companyData['kakaotalk_qr_code_url'] = _kakaoTalkQrCodeUrl;
      companyData['photo_url'] = _officeInteriorUrl;

      final updatedCompany = await updateCompany(companyData);

      if (!mounted) return;

      // Comic Design: Use Comic SnackBar for success message
      showComicSuccessSnackBar(
        context,
        widget.company == null ? T.companyRegistered : T.companyUpdated,
      );

      if (!mounted) return;
      context.pop(updatedCompany);
    } catch (e) {
      if (!mounted) return;
      // Comic Design: Use Comic SnackBar for error message
      showComicErrorSnackBar(context, 'Error: $e');
    } finally {
      if (mounted) {
        _isSubmitting = false;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      // Comic Design: AppBar with 1.0px bottom border (matches bottom nav)
      appBar: AppBar(
        title: Text(
          widget.company == null ? T.registerCompany : T.updateCompany,
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: scheme.surfaceContainerLow,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: scheme.outlineVariant),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(sp.s16),
            color: scheme.surfaceContainerLow,
            child: Column(
              children: [
                StepProgressIndicator(
                  totalSteps: _totalSteps,
                  currentStep: _currentStep,
                  height: 8,
                  activeColor: scheme.primary,
                  inactiveColor: scheme.secondary,
                ),
              ],
            ),
          ),

          /// 폼 컨텐츠 (PageView)
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentStep = page);
              },
              children: [
                /// Step 0: 기본 정보
                _buildStepContent(
                  FormBasicInfo(
                    nameController: _nameController,
                    useCompanyDomain: _useCompanyDomain,
                    onUseCompanyDomainChanged: (value) {
                      setState(() => _useCompanyDomain = value);
                    },
                    familySiteDomainController: _familySiteDomainController,
                    familySiteNameController: _familySiteNameController,
                    familySiteDescriptionController:
                        _familySiteDescriptionController,
                  ),
                ),

                /// Step 1: 상세 정보
                _buildStepContent(
                  FormDetailedInfo(
                    titleController: _titleController,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                    locationController: _locationController,
                    onLocationSelected: (location) {
                      setState(() => _locationController.text = location);
                    },
                    addressController: _addressController,
                    descriptionController: _descriptionController,
                  ),
                ),

                /// Step 2: 연락처 정보
                _buildStepContent(
                  FormContactInfo(
                    landlineController: _landlineController,
                    mobileNumberController: _mobileNumberController,
                    mobileContactMethod: _mobileContactMethod,
                    onMobileContactMethodChanged: (value) {
                      setState(() => _mobileContactMethod = value);
                    },
                    kakaotalkIdController: _kakaotalkIdController,
                    kakaotalkQrCodeController: _kakaotalkQrCodeController,
                    kakaoTalkQrCodeUrl: _kakaoTalkQrCodeUrl,
                    onKakaoQrCodeSelected: (url) async {
                      try {
                        await updateCompany({'kakaotalk_qr_code_url': url});
                        setState(() => _kakaoTalkQrCodeUrl = url);
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            'Failed to upload QR code: $e',
                          );
                        }
                      }
                    },
                    onKakaoQrCodeDelete: () async {
                      try {
                        await philgoApiFileDelete(_kakaoTalkQrCodeUrl);
                        await updateCompany({'kakaotalk_qr_code_url': ''});
                        setState(() => _kakaoTalkQrCodeUrl = '');
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for success message
                          showComicSuccessSnackBar(
                            context,
                            Lo.of(context)!.kakaoQrCodeDeleted,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            Lo.of(context)!.failedToDelete,
                          );
                        }
                      }
                    },
                    onQrCodeDecoded: (qrCode) {
                      if (qrCode != null && qrCode.isNotEmpty) {
                        setState(
                          () => _kakaotalkQrCodeController.text = qrCode,
                        );
                      }
                    },
                    telegramIdController: _telegramIdController,
                  ),
                ),

                /// Step 3: 이미지 업로드
                _buildStepContent(
                  FormImageUpload(
                    logoUrl: _logoUrl,
                    onLogoSelected: (url) async {
                      try {
                        await updateCompany({'logo_url': url});
                        setState(() => _logoUrl = url);
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            'Failed to upload photo: $e',
                          );
                        }
                      }
                    },
                    onLogoDelete: () async {
                      try {
                        await philgoApiFileDelete(_logoUrl);
                        await updateCompany({'logo_url': ''});
                        setState(() => _logoUrl = '');
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for success message
                          showComicSuccessSnackBar(
                            context,
                            Lo.of(context)!.companyLogoDeleted,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            Lo.of(context)!.failedToDeletePhoto,
                          );
                        }
                      }
                    },
                    businessLicenseUrl: _businessLicenseUrl,
                    onBusinessLicenseSelected: (url) async {
                      try {
                        await updateCompany({'business_license_url': url});
                        setState(() => _businessLicenseUrl = url);
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            'Failed to upload license: $e',
                          );
                        }
                      }
                    },
                    onBusinessLicenseDelete: () async {
                      try {
                        await philgoApiFileDelete(_businessLicenseUrl);
                        await updateCompany({'business_license_url': ''});
                        setState(() => _businessLicenseUrl = '');
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for success message
                          showComicSuccessSnackBar(
                            context,
                            Lo.of(context)!.businessLicenseDeleted,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            Lo.of(context)!.failedToDeleteLicense,
                          );
                        }
                      }
                    },
                    companyIntroImageUrl: _companyIntroImageUrl,
                    onCompanyIntroImageSelected: (url) async {
                      try {
                        await updateCompany({'title_image_url': url});
                        setState(() => _companyIntroImageUrl = url);
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            'Failed to upload image: $e',
                          );
                        }
                      }
                    },
                    onCompanyIntroImageDelete: () async {
                      try {
                        await philgoApiFileDelete(_companyIntroImageUrl);
                        await updateCompany({'title_image_url': ''});
                        setState(() => _companyIntroImageUrl = '');
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for success message
                          showComicSuccessSnackBar(
                            context,
                            Lo.of(context)!.companyIntroImageDeleted,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            Lo.of(context)!.failedToDeleteImage,
                          );
                        }
                      }
                    },
                    officeInteriorUrl: _officeInteriorUrl,
                    onOfficeInteriorSelected: (url) async {
                      try {
                        await updateCompany({'photo_url': url});
                        setState(() => _officeInteriorUrl = url);
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            'Failed to upload photo: $e',
                          );
                        }
                      }
                    },
                    onOfficeInteriorDelete: () async {
                      try {
                        await philgoApiFileDelete(_officeInteriorUrl);
                        await updateCompany({'photo_url': ''});
                        setState(() => _officeInteriorUrl = '');
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for success message
                          showComicSuccessSnackBar(
                            context,
                            Lo.of(context)!.officeInteriorDeleted,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Comic Design: Use Comic SnackBar for error message
                          showComicErrorSnackBar(
                            context,
                            Lo.of(context)!.failedToDeletePhoto,
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sp.s16, vertical: sp.s16),
          decoration: BoxDecoration(color: scheme.surfaceContainerLow),
          child: Row(
            children: [
              /// Comic Design: Back button with ComicButton
              if (_currentStep > 0)
                Expanded(
                  child: ComicButton(
                    onPressed: _backStep,
                    rounded: ComicButtonRounded.normal,
                    padding: ComicButtonPadding.medium,
                    textSize: ComicButtonTextSize.medium,
                    child: Text(Lo.of(context)!.back),
                  ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.1),
                ),

              if (_currentStep > 0) SizedBox(width: sp.s12),

              /// Comic Design: Next/Submit button with ComicButton
              Expanded(
                flex: _currentStep == 0 ? 1 : 1,
                child: _currentStep < _totalSteps - 1
                    ? ComicButton(
                        onPressed: _nextStep,
                        rounded: ComicButtonRounded.normal,
                        padding: ComicButtonPadding.medium,
                        textSize: ComicButtonTextSize.medium,
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        borderColor: scheme.primary,
                        child: Text(Lo.of(context)!.next),
                      ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.2)
                    : ComicButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            rounded: ComicButtonRounded.normal,
                            padding: ComicButtonPadding.medium,
                            textSize: ComicButtonTextSize.medium,
                            backgroundColor: scheme.primary,
                            foregroundColor: scheme.onPrimary,
                            borderColor: scheme.primary,
                            child: _isSubmitting
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        scheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    widget.company == null
                                        ? T.registerCompany
                                        : T.updateCompany,
                                  ),
                          )
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .scale(begin: const Offset(0.95, 0.95)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(Widget content) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          content
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }
}
