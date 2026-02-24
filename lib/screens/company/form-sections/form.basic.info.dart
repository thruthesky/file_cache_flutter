import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/form-sections/form_field_label.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';

/// Company name field - Comic Design
/// Domain-related fields have been removed (not used in business registration).
class FormBasicInfo extends StatelessWidget {
  const FormBasicInfo({
    super.key,
    required this.nameController,
  });

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Comic Design: Company Name Field
        FormFieldLabel(label: T.companyName, isRequired: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: nameController,
          hintText: T.enterCompanyName,
        ),
      ],
    );
  }
}
