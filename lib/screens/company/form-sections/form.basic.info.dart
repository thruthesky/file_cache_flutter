import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/themes/app.spacing.dart';
import 'package:philgo/widgets/information.box.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Company name and optional company domain fields
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldSet(
          controller: nameController,
          label: '${T.companyName} *',
          hintText: T.enterCompanyName,
          prefixFaIconData: FontAwesomeIcons.lightBuilding,
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),

        SizedBox(height: sp.s8),

        Row(
          children: [
            Checkbox(
              value: useCompanyDomain,
              onChanged: (bool? value) {
                onUseCompanyDomainChanged(value ?? false);
              },
            ),
            Text(
              T.useCompanyDomain,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),

        InformationBox(message: T.seoFeaturesMessage),

        SizedBox(height: sp.s8),

        if (useCompanyDomain) ...[
          TextFieldSet(
            controller: familySiteDomainController,
            label: T.familySiteDomain,
            hintText: T.companyNameExample,
            prefixFaIconData: FontAwesomeIcons.lightHeading,
            decoration: InputDecoration(
              suffix: Text(
                '.philgo.com',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),

          TextFieldSet(
            controller: familySiteNameController,
            label: T.familySiteName,
            hintText: T.enterFamilySiteName,
            prefixFaIconData: FontAwesomeIcons.lightHeading,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),

          TextFieldSet(
            controller: familySiteDescriptionController,
            label: T.familySiteDescription,
            hintText: T.enterFamilySiteDescription,
            prefixFaIconData: FontAwesomeIcons.lightHeading,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ],
      ],
    );
  }
}
