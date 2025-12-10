import 'package:flutter/material.dart';

/// Reusable form field label widget with consistent styling
/// Used across all company form sections for uniform appearance
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      isRequired ? '$label *' : label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: scheme.primary,
      ),
    );
  }
}
