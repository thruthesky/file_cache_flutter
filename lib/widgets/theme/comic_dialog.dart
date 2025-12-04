import 'package:flutter/material.dart';
// import 'package:philgo_app/widgets/theme/comic_button.dart';

/// ComicDialog - Comic style dialog widget
///
/// A reusable dialog widget following Comic design principles:
/// - 2.0px border with outline color
/// - No shadow (elevation: 0)
/// - Rounded corners (borderRadius: 12)
/// - Theme-based colors
/// - Spacing in multiples of 8
///
/// Usage example:
/// ```dart
/// final result = await showDialog<bool>(
///   context: context,
///   builder: (context) => ComicDialog(
///     title: Text(T.confirm),
///     content: Text(T.are_you_sure),
///     actions: [
///       ComicButton(
///         onPressed: () => Navigator.of(context).pop(false),
///         child: Text(T.cancel),
///       ),
///       ComicPrimaryButton(
///         onPressed: () => Navigator.of(context).pop(true),
///         child: Text(T.confirm),
///       ),
///     ],
///   ),
/// );
/// ```
class ComicDialog extends StatelessWidget {
  /// Dialog title widget (typically a Text widget)
  final Widget? title;

  /// Dialog content widget (typically a Text widget)
  final Widget? content;

  /// List of action buttons displayed at the bottom
  final List<Widget>? actions;

  /// Background color of the dialog (defaults to Theme surface color)
  final Color? backgroundColor;

  /// Border color (defaults to Theme outline color)
  final Color? borderColor;

  /// Border width (defaults to 2.0 - Comic style standard)
  final double borderWidth;

  /// Border radius (defaults to 12 - Comic style standard)
  final double borderRadius;

  /// Content padding (defaults to 24.0 - multiples of 8)
  final EdgeInsetsGeometry? contentPadding;

  /// Title padding (defaults to EdgeInsets.fromLTRB(24, 24, 24, 16))
  final EdgeInsetsGeometry? titlePadding;

  /// Actions padding (defaults to EdgeInsets.fromLTRB(24, 16, 24, 24))
  final EdgeInsetsGeometry? actionsPadding;

  const ComicDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12,
    this.contentPadding,
    this.titlePadding,
    this.actionsPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      // Comic design: no shadow
      elevation: 0,
      // Comic design: rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      // Remove default background color to use our Container
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          // Comic design: surface background color
          color: backgroundColor ?? colorScheme.surface,
          // Comic design: 2.0px outline border with rounded corners
          border: Border.all(
            color: borderColor ?? colorScheme.outline,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title section
            if (title != null)
              Padding(
                padding:
                    titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: DefaultTextStyle(
                  style:
                      theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(),
                  child: title!,
                ),
              ),

            // Content section
            if (content != null)
              Flexible(
                child: Padding(
                  padding:
                      contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: DefaultTextStyle(
                    style:
                        theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ) ??
                        const TextStyle(),
                    child: content!,
                  ),
                ),
              ),

            // Actions section
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding:
                    actionsPadding ?? const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Add spacing between buttons
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      actions![i],
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
