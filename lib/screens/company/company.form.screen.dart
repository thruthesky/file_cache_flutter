import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/globals.dart';
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
  late TextEditingController _phoneNumberController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _kakaotalkIdController;
  late TextEditingController _telegramIdController;

  // Category selection
  String? _selectedCategory;

  // Image URLs (for update mode)
  String _logoUrl = '';
  String _titleImageUrl = '';
  String _businessLicenseUrl = '';

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
    _phoneNumberController = TextEditingController(
      text: widget.company?.phone_number ?? '',
    );
    _mobileNumberController = TextEditingController(
      text: widget.company?.mobile_number ?? '',
    );
    _kakaotalkIdController = TextEditingController(
      text: widget.company?.kakaotalk_id ?? '',
    );
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _mobileNumberController.dispose();
    _kakaotalkIdController.dispose();
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
    final theme = Theme.of(context);

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

              /// 기본 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightCircleInfo,
                  title: T.basicInformation,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 회사명
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

              /// 회사 타이틀
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
              SizedBox(height: sp.s16),

              /// 카테고리
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                // TODO : Add Category dropdown here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      T.category,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    SizedBox(height: sp.s8),
                  ],
                ),
              ),
              SizedBox(height: sp.s8),

              /// 회사 설명
              TextFieldSet(
                controller: _descriptionController,
                label: T.description,
                hintText: T.enterDescription,
                prefixFaIconData: FontAwesomeIcons.lightAlignLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                maxLines: 5,
              ),
              SizedBox(height: sp.s24),

              /// 위치 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightLocationDot,
                  title: T.locationInformation,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 위치
              TextFieldSet(
                controller: _locationController,
                label: T.location,
                hintText: T.enterLocation,
                prefixFaIconData: FontAwesomeIcons.lightMapPin,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              SizedBox(height: sp.s16),

              /// 주소
              TextFieldSet(
                controller: _addressController,
                label: T.address,
                hintText: T.enterAddress,
                prefixFaIconData: FontAwesomeIcons.lightMapLocationDot,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                maxLines: 2,
              ),
              SizedBox(height: sp.s24),

              /// 연락처 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightPhone,
                  title: T.contactInformation,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 전화번호
              TextFieldSet(
                controller: _phoneNumberController,
                label: T.phoneNumber,
                hintText: T.enterPhoneNumber,
                prefixFaIconData: FontAwesomeIcons.lightPhone,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: sp.s16),

              /// 모바일 번호
              TextFieldSet(
                controller: _mobileNumberController,
                label: T.mobileNumber,
                hintText: T.enterMobileNumber,
                prefixFaIconData: FontAwesomeIcons.lightMobileScreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: sp.s16),

              /// 카카오톡 ID
              TextFieldSet(
                controller: _kakaotalkIdController,
                label: 'KakaoTalk ID',
                hintText: 'Enter KakaoTalk ID',
                prefixFaIconData: FontAwesomeIcons.comment,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              SizedBox(height: sp.s16),

              /// 텔레그램 ID
              TextFieldSet(
                controller: _telegramIdController,
                label: 'Telegram ID',
                hintText: 'Enter Telegram ID',
                prefixFaIconData: FontAwesomeIcons.telegram,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
              ),
              SizedBox(height: sp.s24),

              /// 이미지 정보
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _SectionHeader(
                  icon: FontAwesomeIcons.lightImages,
                  title: T.images,
                ),
              ),
              SizedBox(height: sp.s8),

              /// 로고 이미지
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: _ImageUploadField(
                  label: T.logoImage,
                  imageUrl: _logoUrl,
                  onImageSelected: (url) {
                    setState(() {
                      _logoUrl = url;
                    });
                  },
                ),
              ),

              /// 타이틀 이미지
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: _ImageUploadField(
                  label: T.titleImage,
                  imageUrl: _titleImageUrl,
                  onImageSelected: (url) {
                    setState(() {
                      _titleImageUrl = url;
                    });
                  },
                ),
              ),

              /// 사업자 등록증
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: _ImageUploadField(
                  label: T.businessLicense,
                  imageUrl: _businessLicenseUrl,
                  onImageSelected: (url) {
                    setState(() {
                      _businessLicenseUrl = url;
                    });
                  },
                ),
              ),

              /// 제출 버튼
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

    return Column(
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
          onTap: () {
            // TODO: Implement image selection and upload
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload coming soon'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
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
    );
  }
}

/// 이미지 플레이스홀더 위젯
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
