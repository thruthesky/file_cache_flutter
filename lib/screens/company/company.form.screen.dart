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
  String? _selectedBusinessType;

  // Checkbox state
  bool _useCompanyDomain = false;

  // Radio button state for contact method
  String _mobileContactMethod = 'call'; // 'text' or 'call'

  // Image URLs (for update mode)
  String _logoUrl = '';
  String _titleImageUrl = '';
  String _businessLicenseUrl = '';
  String _kakaotalkQrImageUrl = '';
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

    // Set image URLs
    _logoUrl = widget.company?.logo_url ?? '';
    _titleImageUrl = widget.company?.title_image_url ?? '';
    _businessLicenseUrl = widget.company?.business_license_url ?? '';
    _kakaotalkQrImageUrl = '';
    _officeInteriorUrl = '';
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      showErrorSnackBar(context, T.pleaseSelectCategory);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // TODO: Implement API call to create or update company
      // final result = await createOrUpdateCompany(...);

      if (context.mounted) {
        showSuccessSnackBar(
          context,
          widget.company == null ? T.companyRegistered : T.companyUpdated,
        );
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackBar(context, 'Error: $e');
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
                label: T.companyName,
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
                label: T.companyTitle,
                hintText: T.enterCompanyTitle,
                prefixFaIconData: FontAwesomeIcons.lightHeading,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              // TODO: Add company category
              CompanySelectLocation(label: 'Location'),

              TextFieldSet(
                controller: _addressController,
                label: T.address,
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
                label: T.phoneNumber,
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
                label: T.mobileNumber,
                hintText: T.enterMobileNumber,
                prefixFaIconData: FontAwesomeIcons.lightPhone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),

              SizedBox(height: sp.s8),

              // TODO : Add radio mobile contact method such as 'send text' or 'make call'
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
                imageUrl: _kakaotalkQrImageUrl,
                onImageSelected: (url) {
                  _kakaotalkQrImageUrl = url;
                  setState(() {});
                },
              ),

              TextFieldSet(
                controller: _kakaotalkIdController,
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
                label: T.description,
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

              _ImageUploadField(
                label: "Company Logo",
                imageUrl:
                    _businessLicenseUrl, // TODO: it should be company logo
                onImageSelected: (url) {
                  setState(() {
                    _businessLicenseUrl = url;
                  });
                },
              ),

              _ImageUploadField(
                label: T.businessLicense,
                imageUrl: _businessLicenseUrl,
                onImageSelected: (url) {
                  setState(() {
                    _businessLicenseUrl = url;
                  });
                },
              ),

              // TODO: add info 'Business license scan'
              _ImageUploadField(
                label: 'Company Introduction Image',
                imageUrl:
                    _businessLicenseUrl, // TODO: it should be company introduction image
                onImageSelected: (url) {
                  setState(() {
                    _businessLicenseUrl = url;
                  });
                },
              ),

              // TODO: add guidelines. Image briefly representing company introduction, Include logo and main service items, Text limited to around 100 characters (20 words)
              _ImageUploadField(
                label: 'Office/Store Interior Photo',
                imageUrl:
                    _businessLicenseUrl, // TODO: it should be office/store interior photo
                onImageSelected: (url) {
                  setState(() {
                    _businessLicenseUrl = url;
                  });
                },
              ),

              // TODO: add info 'Office/Store Interior full view photo'
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

/// 이미지 업로드 위젯
class _ImageUploadField extends StatelessWidget {
  const _ImageUploadField({
    required this.label,
    required this.imageUrl,
    required this.onImageSelected,
  });

  final String label;
  final String imageUrl;
  final void Function(String) onImageSelected;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: sp.s8),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outline),
              ),
              child: imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const _ImagePlaceholder();
                        },
                      ),
                    )
                  : const _ImagePlaceholder(),
            ),
          ),
        ],
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
