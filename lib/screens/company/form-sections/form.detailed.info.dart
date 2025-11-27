import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 회사 상세 정보 폼 섹션
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldSet(
          controller: titleController,
          label: '${T.companyTitle} *',
          hintText: T.enterCompanyTitle,
          prefixFaIconData: FontAwesomeIcons.lightHeading,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CategoryDropdownField(
            label: 'Business Type *',
            initialValue: selectedCategory,
            onChanged: onCategoryChanged,
          ),
        ),

        SizedBox(height: sp.s8),

        CompanySelectLocation(
          label: '${T.location} *',
          controller: locationController,
          onLocationSelected: onLocationSelected,
        ),

        SizedBox(height: sp.s8),

        TextFieldSet(
          controller: addressController,
          label: '${T.address} *',
          hintText: T.enterAddress,
          prefixFaIconData: FontAwesomeIcons.lightMapLocationDot,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        /// 회사 설명 입력
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${T.description} *',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              TextField(
                controller: descriptionController,
                maxLines: 8,
                minLines: 5,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: T.enterDescription,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
