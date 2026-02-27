import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/screens/company/form-sections/form_field_label.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';

/// 업소록 기본 정보 폼 — 업소명 + 영수증 표시 업소명
class FormBasicInfo extends StatelessWidget {
  const FormBasicInfo({
    super.key,
    required this.nameController,
    required this.receiptNameController,
  });

  final TextEditingController nameController;
  final TextEditingController receiptNameController;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final theme = Theme.of(context);

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

        SizedBox(height: sp.s24),

        /// 영수증 표시 업소명 필드 (선택)
        FormFieldLabel(label: T.receiptDisplayName, isOptional: true),
        SizedBox(height: sp.s8),
        ComicTextFormField(
          controller: receiptNameController,
          hintText: T.receiptDisplayNameHint,
        ),
        SizedBox(height: sp.s8),

        /// 설명 문구
        Text(
          T.receiptDisplayNameDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
