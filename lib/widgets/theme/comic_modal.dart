import 'package:flutter/material.dart';

/// ComicModal - Comic style modal bottom sheet widget
///
/// A reusable modal bottom sheet component that implements the Comic design language.
/// It provides a consistent way to display modal content from the bottom of the screen
/// with Comic-style rounded top corners, proper spacing, and an integrated drag handle.
///
/// Design principles:
/// - Border Radius: 12.0 for top-left and top-right corners
/// - Border Width: 2.0 thickness on top, left, and right sides (no border on bottom)
/// - Elevation: 0 (flat design, no shadows)
/// - Colors: Theme-based (surface background, outline border)
/// - Spacing: Consistent padding using multiples of 8
/// - Drag Handle: Custom drag handle integrated inside the container (32px × 4px)
///
/// Usage example:
/// ```dart
/// // Simple modal with content
/// showComicModal(
///   context: context,
///   builder: (context) => Column(
///     children: [
///       Text('Modal Title'),
///       Text('Modal Content'),
///     ],
///   ),
/// );
///
/// // Modal with scrollable content
/// showComicModal(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => ListView(
///     shrinkWrap: true,
///     children: [
///       ListTile(title: Text('Item 1')),
///       ListTile(title: Text('Item 2')),
///     ],
///   ),
/// );
/// ```
class ComicModal extends StatelessWidget {
  /// The content widget to display in the modal
  final Widget child;

  /// Whether to show the drag handle indicator at the top
  /// Defaults to true
  final bool showDragHandle;

  /// Background color of the modal (defaults to Theme surface color)
  final Color? backgroundColor;

  /// Border color (defaults to Theme outline color)
  final Color? borderColor;

  /// Border width (defaults to 2.0 - Comic style standard)
  final double borderWidth;

  /// Border radius for top corners (defaults to 12 - Comic style standard)
  final double borderRadius;

  /// Custom padding around the content (optional)
  /// If not provided, no padding is applied - you control padding in your content
  final EdgeInsetsGeometry? contentPadding;

  /// Maximum height of the modal as a fraction of screen height (0.0 to 1.0)
  /// Defaults to null (auto-sized based on content)
  final double? maxHeightFactor;

  const ComicModal({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12,
    this.contentPadding,
    this.maxHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate max height if maxHeightFactor is provided
    final maxHeight = maxHeightFactor != null
        ? screenHeight * maxHeightFactor!
        : null;

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      decoration: BoxDecoration(
        // Comic design: surface background color
        color: backgroundColor ?? colorScheme.surface,
        // Comic design: rounded top corners
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        // Comic design: 2.0px border on top, left, and right (no bottom border)
        border: Border(
          top: BorderSide(
            color: borderColor ?? colorScheme.outline,
            width: borderWidth,
          ),
          left: BorderSide(
            color: borderColor ?? colorScheme.outline,
            width: borderWidth,
          ),
          right: BorderSide(
            color: borderColor ?? colorScheme.outline,
            width: borderWidth,
          ),
          // No bottom border
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          if (showDragHandle) ...[
            // Comic design: 8px spacing from top
            const SizedBox(height: 8),
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          // Content
          Flexible(
            child: contentPadding != null
                ? Padding(
                    padding: contentPadding!,
                    child: child,
                  )
                : child,
          ),
        ],
      ),
    );
  }
}

/// Helper function to show a Comic-style modal bottom sheet
///
/// This is a convenience function that wraps [showModalBottomSheet] with
/// Comic design defaults (transparent background, no elevation).
///
/// Parameters:
/// - [context]: BuildContext for showing the modal
/// - [builder]: Builder function that returns the modal content (should return ComicModal)
/// - [isScrollControlled]: Whether the modal should expand to fill available space (default: false)
/// - [isDismissible]: Whether the modal can be dismissed by tapping outside (default: true)
/// - [enableDrag]: Whether the modal can be dragged down to dismiss (default: true)
/// - [useSafeArea]: Whether to wrap content in SafeArea (default: true)
///
/// Returns a Future that completes with the value passed to Navigator.pop
///
/// Example:
/// ```dart
/// final result = await showComicModal<bool>(
///   context: context,
///   builder: (context) => ComicModal(
///     child: Column(
///       mainAxisSize: MainAxisSize.min,
///       children: [
///         Padding(
///           padding: EdgeInsets.all(16),
///           child: Text('Select an option'),
///         ),
///         ListTile(
///           title: Text('Option 1'),
///           onTap: () => Navigator.pop(context, true),
///         ),
///         ListTile(
///           title: Text('Option 2'),
///           onTap: () => Navigator.pop(context, false),
///         ),
///       ],
///     ),
///   ),
/// );
/// ```
Future<T?> showComicModal<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    // Comic design: transparent background for custom styling
    backgroundColor: Colors.transparent,
    // Comic design: no shadow
    elevation: 0,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useSafeArea: useSafeArea,
    builder: builder,
  );
}