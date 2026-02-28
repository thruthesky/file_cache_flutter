import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/form-sections/form_field_label.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';

/// 업소록 기본 정보 폼 — 업소명
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
        /// 업소명 필드 (필수)
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
