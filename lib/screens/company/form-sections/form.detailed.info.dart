import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 회사 상세 정보 폼 섹션 - Comic Design
/// Company title, business type, location, address, and description fields
class FormDetailedInfo extends StatelessWidget {
  const FormDetailedInfo({
    super.key,
    required this.titleController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.locationController,
    required this.onLocationSelected,
    required this.addressController,
    required this.descriptionController,
  });

  final TextEditingController titleController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final TextEditingController locationController;
  final ValueChanged<String> onLocationSelected;
  final TextEditingController addressController;
  final TextEditingController descriptionController;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Comic Design: Company Title Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${T.companyTitle} *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s8),
            ComicTextFormField(
              controller: titleController,
              hintText: T.enterCompanyTitle,
            ),
          ],
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Category Dropdown (using existing widget)
        CategoryDropdownField(
          label: '${T.businessType} *',
          initialValue: selectedCategory,
          onChanged: onCategoryChanged,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Location Selector (using existing widget)
        CompanySelectLocation(
          label: '${T.location} *',
          controller: locationController,
          onLocationSelected: onLocationSelected,
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Address Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${T.address} *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s8),
            ComicTextFormField(
              controller: addressController,
              hintText: T.enterAddress,
            ),
          ],
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Description Field (multi-line)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${T.description} *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s8),
            ComicTextFormField(
              controller: descriptionController,
              hintText: T.enterDescription,
              maxLines: 8,
              minLines: 5,
            ),
          ],
        ),
      ],
    );
  }
}
