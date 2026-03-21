import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required this.onPressed,
    this.style,
    this.focusNode,
    this.autofocus = false,
    required this.child,
    this.isLoading = false,
    this.padding,
    this.alignment,
  });

  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget child;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment ?? Alignment.center,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              : child,
        ),
      ),
    );
  }

  static Widget icon({
    Key? key,
    required BuildContext context,
    required VoidCallback? onPressed,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool? autofocus,
    Widget? icon,
    required Widget label,
    IconAlignment? iconAlignment,
    bool isLoading = false,
    padding = const EdgeInsets.all(8.0),
    alignment = Alignment.center,
  }) {
    if (icon == null) {
      return SubmitButton(
        key: key,
        onPressed: onPressed,
        style: style,
        focusNode: focusNode,
        autofocus: autofocus ?? false,
        padding: padding,
        alignment: alignment,
        child: label,
      );
    }
    return Padding(
      padding: padding ?? const EdgeInsets.all(8.0),
      child: Align(
        alignment: alignment ?? Alignment.center,
        child: ElevatedButton.icon(
          key: key,
          onPressed: isLoading ? null : onPressed,
          style: style,
          focusNode: focusNode,
          autofocus: autofocus ?? false,
          icon: isLoading ? null : icon,
          label: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              : label,
          iconAlignment: iconAlignment,
        ),
      ),
    );
  }
}
