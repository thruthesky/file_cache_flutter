import 'package:flutter/material.dart';

/// Comic-styled TextField widget following the Comic design principles
///
/// Features:
/// - 1.5px border with outline color (enabled state)
/// - 2.0px border with primary color (focused state)
/// - Zero elevation (no shadow)
/// - Rounded corners (borderRadius: 8)
/// - Theme-based colors
/// - Optional label, hint, and helper text
class ComicTextField extends StatelessWidget {
  const ComicTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // Build default decoration with Comic theme
    final defaultDecoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: scheme.surface,
      // Comic Design: 1.5px border for enabled state
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.outline,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.outline,
          width: 1.5,
        ),
      ),
      // Comic Design: 2.0px border for focused state
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.primary,
          width: 2.0,
        ),
      ),
      // Error border styling
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.error,
          width: 2.0,
        ),
      ),
      // Disabled border styling
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: scheme.outline.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
    );

    // Merge with custom decoration if provided
    final effectiveDecoration = decoration?.copyWith(
          labelText: decoration?.labelText ?? label,
          hintText: decoration?.hintText ?? hintText,
          helperText: decoration?.helperText ?? helperText,
          prefixIcon: decoration?.prefixIcon ?? prefixIcon,
          suffixIcon: decoration?.suffixIcon ?? suffixIcon,
        ) ??
        defaultDecoration;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: effectiveDecoration,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
