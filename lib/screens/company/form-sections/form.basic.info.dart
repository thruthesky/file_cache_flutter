import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/information.box.dart';
import 'package:philgo/widgets/theme/comic_text_form_field.dart';

/// Company name and optional company domain fields - Comic Design
class FormBasicInfo extends StatelessWidget {
  const FormBasicInfo({
    super.key,
    required this.nameController,
    required this.useCompanyDomain,
    required this.onUseCompanyDomainChanged,
    required this.familySiteDomainController,
    required this.familySiteNameController,
    required this.familySiteDescriptionController,
  });

  final TextEditingController nameController;
  final bool useCompanyDomain;
  final ValueChanged<bool> onUseCompanyDomainChanged;
  final TextEditingController familySiteDomainController;
  final TextEditingController familySiteNameController;
  final TextEditingController familySiteDescriptionController;

  @override
  Widget build(BuildContext context) {
    final sp = Theme.of(context).extension<AppSpacing>()!;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Comic Design: Company Name Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${T.companyName} *',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
            SizedBox(height: sp.s8),
            ComicTextFormField(
              controller: nameController,
              hintText: T.enterCompanyName,
            ),
          ],
        ),

        SizedBox(height: sp.s16),

        /// Comic Design: Checkbox with proper styling
        Row(
          children: [
            Checkbox(
              value: useCompanyDomain,
              onChanged: (bool? value) {
                onUseCompanyDomainChanged(value ?? false);
              },
            ),
            Expanded(
              child: Text(
                T.useCompanyDomain,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),

        SizedBox(height: sp.s8),

        InformationBox(message: T.seoFeaturesMessage),

        SizedBox(height: sp.s16),

        if (useCompanyDomain) ...[
          /// Comic Design: Family Site Domain Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.familySiteDomain,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: sp.s8),
              ComicTextFormField(
                controller: familySiteDomainController,
                hintText: T.companyNameExample,
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    widthFactor: 1.0,
                    child: Text(
                      '.philgo.com',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: sp.s16),

          /// Comic Design: Family Site Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.familySiteName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: sp.s8),
              ComicTextFormField(
                controller: familySiteNameController,
                hintText: T.enterFamilySiteName,
              ),
            ],
          ),

          SizedBox(height: sp.s16),

          /// Comic Design: Family Site Description Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                T.familySiteDescription,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: scheme.primary,
                ),
              ),
              SizedBox(height: sp.s8),
              ComicTextFormField(
                controller: familySiteDescriptionController,
                hintText: T.enterFamilySiteDescription,
                maxLines: 3,
                minLines: 2,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
