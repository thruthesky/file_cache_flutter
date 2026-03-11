import 'package:flutter/material.dart';

const kFormActiveColor = Color(0xFFFF6D00);

/// Shared form field label wrapper
class FormFieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  final Widget child;
  final String? hint;

  const FormFieldLabel({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(
                  color: kFormActiveColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration formInputDecoration(String hint, {String? prefixText}) {
  return InputDecoration(
    hintText: hint,
    prefixText: prefixText,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );
}
