import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/widgets/company/category_dropdown_field.dart';
import 'package:philgo/widgets/company/company.select.location.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company Form Screen
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
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _addressController;
  late TextEditingController _landlineController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _kakaotalkIdController;
  late TextEditingController _kakaotalkQrUrlController;
  late TextEditingController _telegramIdController;

  // Category and Business Type selection
  String? _selectedCategory;

  // Checkbox state
  bool _useCompanyDomain = false;

  // Radio button state for contact method
  String? _mobileContactMethod; // 'text' or 'call', null if not selected

  // Image URLs (for update mode)
  String _logoUrl = '';
  String _companyIntroImageUrl = '';
  String _businessLicenseUrl = '';
  String _kakaoTalkQrCode = '';
  String _officeInteriorUrl = '';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if updating
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
    _kakaotalkQrUrlController = TextEditingController(text: '');
    _telegramIdController = TextEditingController(
      text: widget.company?.telegram_id ?? '',
    );

    // Set category (convert empty string to null)
    final category = widget.company?.category;
    _selectedCategory = (category == null || category.isEmpty)
        ? null
        : category;

    // Set mobile contact method from mobile_number_call_type
    final callType = widget.company?.mobile_number_call_type;
    if (callType == 'T') {
      _mobileContactMethod = 'text';
    } else if (callType == 'C') {
      _mobileContactMethod = 'call';
    }

    // Set image URLs
    _logoUrl = widget.company?.logo_url ?? '';
    _kakaoTalkQrCode = widget.company?.kakaotalk_qr_code ?? '';
    _companyIntroImageUrl = widget.company?.title_image_url ?? '';
    _businessLicenseUrl = widget.company?.business_license_url ?? '';
    _officeInteriorUrl = widget.company?.photo_url ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _landlineController.dispose();
    _mobileNumberController.dispose();
    _kakaotalkIdController.dispose();
    _kakaotalkQrUrlController.dispose();
    _telegramIdController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    // Validate mandatory fields
    if (_nameController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter company name');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter company title');
      return;
    }
    if (_selectedCategory == null) {
      showErrorSnackBar(context, T.pleaseSelectCategory);
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please select location');
      return;
    }
    if (_addressController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter address');
      return;
    }
    if (_landlineController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter landline number');
      return;
    }
    if (_mobileNumberController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter mobile number');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      showErrorSnackBar(context, 'Please enter company description');
      return;
    }
    if (_logoUrl.isEmpty) {
      showErrorSnackBar(context, 'Please upload company logo');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare company data for API
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
        'kakaotalk_qr_code_url': _kakaotalkQrUrlController.text.trim(),
        'telegram_id': _telegramIdController.text.trim(),
        'logo_url': _logoUrl,
      };

      // Add mobile contact method if selected
      if (_mobileContactMethod != null) {
        companyData['mobile_number_call_type'] = _mobileContactMethod == 'text'
            ? 'T'
            : 'C';
      }

      // Add optional image URLs if provided
      if (_companyIntroImageUrl.isNotEmpty) {
        companyData['title_image_url'] = _companyIntroImageUrl;
      }
      if (_businessLicenseUrl.isNotEmpty) {
        companyData['business_license_url'] = _businessLicenseUrl;
      }
      if (_kakaoTalkQrCode.isNotEmpty) {
        companyData['kakaotalk_qr_code'] = _kakaoTalkQrCode;
      }
      if (_officeInteriorUrl.isNotEmpty) {
        companyData['photo_url'] = _officeInteriorUrl;
      }

      // Call API to update company
      final updatedCompany = await updateCompany(companyData);

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        widget.company == null ? T.companyRegistered : T.companyUpdated,
      );
      // Return the updated company to the previous screen
      if (!mounted) return;
      context.pop(updatedCompany);
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.company == null ? T.registerCompany : T.updateCompany,
        ),
        backgroundColor: scheme.primaryContainer,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: sp.s16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: T.basicInformation,
                ),
              ),
              SizedBox(height: sp.s8),

              TextFieldSet(
                controller: _nameController,
                label: '${T.companyName} *',
                hintText: T.enterCompanyName,
                prefixFaIconData: FontAwesomeIcons.lightBuilding,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              SizedBox(height: sp.s16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: 'Detailed Information',
                ),
              ),
              SizedBox(height: sp.s8),

              TextFieldSet(
                controller: _titleController,
                label: '${T.companyTitle} *',
                hintText: T.enterCompanyTitle,
                prefixFaIconData: FontAwesomeIcons.lightHeading,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: CategoryDropdownField(
                  label: 'Business Type *',
                  initialValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),

              CompanySelectLocation(
                label: '${T.location} *',
                controller: _locationController,
                onLocationSelected: (location) {
                  setState(() {
                    _locationController.text = location;
                  });
                },
              ),

              TextFieldSet(
                controller: _addressController,
                label: '${T.address} *',
                hintText: T.enterAddress,
                prefixFaIconData: FontAwesomeIcons.lightMapLocationDot,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: 'Contact Information',
                ),
              ),
              SizedBox(height: sp.s8),

              // Landline
              TextFieldSet(
                controller: _landlineController,
                label: '${T.phoneNumber} *',
                hintText: T.enterPhoneNumber,
                prefixFaIconData: FontAwesomeIcons.lightPhone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              TextFieldSet(
                controller: _mobileNumberController,
                label: '${T.mobileNumber} *',
                hintText: T.enterMobileNumber,
                prefixFaIconData: FontAwesomeIcons.lightPhone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.mobileContactMethod,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                    RadioGroup<String>(
                      groupValue: _mobileContactMethod,
                      onChanged: (value) {
                        setState(() {
                          _mobileContactMethod = value!;
                        });
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(T.sendText),
                              value: 'text',
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(T.makeCall),
                              value: 'call',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: sp.s8),

              TextFieldSet(
                controller: _kakaotalkIdController,
                label: 'KakaoID',
                hintText: 'Enter kakaotalk ID',
                prefixFaIconData: FontAwesomeIcons.message,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              _ImageUploadField(
                label: 'Upload Kakao QR Code',
                imageUrl: _kakaoTalkQrCode,
                isDecodeQr: true,
                onImageSelected: (url) {
                  setState(() {
                    _kakaoTalkQrCode = url;
                  });
                },
              ),

              TextFieldSet(
                controller: _kakaotalkQrUrlController,
                label: 'Kakao Channel URL',
                hintText: 'https://pf.kakao.com/...',
                prefixFaIconData: FontAwesomeIcons.message,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              TextFieldSet(
                controller: _telegramIdController,
                label: 'Telegram ID',
                hintText: "Enter Telegram ID",
                prefixFaIconData: FontAwesomeIcons.message,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: 'Company Introduction',
                ),
              ),

              TextFieldSet(
                controller: _descriptionController,
                label: '${T.description} *',
                hintText: T.enterDescription,
                prefixFaIconData: FontAwesomeIcons.lightAlignLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                maxLines: 5,
              ),

              SizedBox(height: sp.s8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: 'Image Upload',
                ),
              ),
              SizedBox(height: sp.s8),

              /// 회사 로고 업로드
              _ImageUploadField(
                label: "Company Logo *",
                imageUrl: _logoUrl,
                onImageSelected: (url) {
                  setState(() {
                    _logoUrl = url;
                  });
                },
              ),

              /// 사업자 등록증 업로드 (Business license scan)
              _ImageUploadField(
                label: T.businessLicense,
                imageUrl: _businessLicenseUrl,
                onImageSelected: (url) {
                  setState(() {
                    _businessLicenseUrl = url;
                  });
                },
              ),

              /// 회사 소개 이미지 업로드
              _ImageUploadField(
                label: 'Company Introduction Image',
                imageUrl: _companyIntroImageUrl,
                onImageSelected: (url) {
                  setState(() {
                    _companyIntroImageUrl = url;
                  });
                },
              ),

              /// 가이드라인 안내
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: EdgeInsets.all(sp.s8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightCircleInfo,
                        size: 14,
                        color: scheme.primary,
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          'Image briefly representing company introduction. Include logo and main service items. Text limited to around 100 characters (20 words).',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: sp.s8),

              /// 사무실/매장 내부 사진 업로드
              _ImageUploadField(
                label: 'Office/Store Interior Photo',
                imageUrl: _officeInteriorUrl,
                onImageSelected: (url) {
                  setState(() {
                    _officeInteriorUrl = url;
                  });
                },
              ),

              /// 가이드라인 안내
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: EdgeInsets.all(sp.s8),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.lightCircleInfo,
                        size: 14,
                        color: scheme.primary,
                      ),
                      SizedBox(width: sp.s8),
                      Expanded(
                        child: Text(
                          'Office/Store Interior full view photo',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: sp.s16),

              SubmitButton.icon(
                context: context,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                alignment: Alignment.center,
                onPressed: _isSubmitting ? null : _handleSubmit,
                isLoading: _isSubmitting,
                icon: FaIcon(
                  widget.company == null
                      ? FontAwesomeIcons.lightPlus
                      : FontAwesomeIcons.lightFloppyDisk,
                ),
                label: Text(
                  widget.company == null ? T.registerCompany : T.updateCompany,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(sp.s8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FaIcon(icon, size: 20, color: scheme.primary),
        ),
        SizedBox(width: sp.s12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// 이미지 업로드 필드 (FileUpload 통합)
class _ImageUploadField extends StatefulWidget {
  const _ImageUploadField({
    required this.label,
    required this.imageUrl,
    required this.onImageSelected,
    this.isDecodeQr = false,
  });

  final String label;
  final String imageUrl;
  final void Function(String) onImageSelected;
  final bool isDecodeQr;

  @override
  State<_ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<_ImageUploadField> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return FileUpload(
      isDecodeQr: true,
      onBeforeUpload: () {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0.0;
        });
      },
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
      onUploaded: (url) {
        setState(() {
          _isUploading = false;
        });
        widget.onImageSelected(url);
      },
      onCancelled: () {
        setState(() {
          _isUploading = false;
        });
      },
      image: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            SizedBox(height: sp.s8),
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline),
              ),
              child: Stack(
                children: [
                  /// 이미지 표시
                  if (widget.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImagePlaceholder();
                        },
                      ),
                    )
                  else
                    const _ImagePlaceholder(),

                  if (widget.imageUrl.isNotEmpty && !_isUploading)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          widget.onImageSelected('');
                        },
                        child: Container(
                          padding: EdgeInsets.all(sp.s8),
                          decoration: BoxDecoration(
                            color: scheme.errorContainer,
                            shape: BoxShape.circle,
                          ),
                          child: FaIcon(
                            FontAwesomeIcons.solidTrash,
                            size: 16,
                            color: scheme.error,
                          ),
                        ),
                      ),
                    ),

                  if (_isUploading)
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: _uploadProgress,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: sp.s16),
                            Text(
                              '${(_uploadProgress * 100).toInt()}%',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                            SizedBox(height: sp.s4),
                            Text(
                              'Uploading...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightImage,
            size: 32,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(height: sp.s8),
          Text(
            T.tapToUploadImage,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
