import 'package:flutter/material.dart';

/// Comic SnackBar Helper Functions
///
/// This file provides helper functions to display SnackBars that follow Comic design principles.
/// Comic SnackBars have:
/// - 2.0px border with semantic colors (green for success, red for error, etc.)
/// - No elevation (flat design)
/// - Rounded corners (borderRadius: 12)
/// - Light background with colored borders for better readability
/// - Proper padding and spacing

/// Shows a success SnackBar with Comic design
///
/// Visual: Light green background with green border
///
/// Usage:
/// ```dart
/// showComicSuccessSnackBar(context, T.profileUpdateSuccess);
/// ```
void showComicSuccessSnackBar(BuildContext context, String message) {
  // Comic Design: Semantic colors - Green for success (lower contrast)
  const successColor = Color(0xFF66BB6A); // Medium green
  const successBackgroundColor = Color(0xFFF1F8F4); // Very light green

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // Comic Design: Medium tone text for lower contrast
          color: const Color(0xFF2E7D32), // Medium dark green text
        ),
      ),
      // Comic Design: Very light green background for success
      backgroundColor: successBackgroundColor,
      // Comic Design: no elevation (flat design)
      elevation: 0,
      // Comic Design: rounded corners with 2.0px green border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: successColor, width: 2.0),
      ),
      behavior: SnackBarBehavior.floating,
      // Comic Design: padding in multiples of 8
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

/// Shows an error SnackBar with Comic design
///
/// Visual: Light red background with red border
///
/// Usage:
/// ```dart
/// showComicErrorSnackBar(context, T.nicknameRequired);
/// ```
void showComicErrorSnackBar(BuildContext context, String message) {
  // Comic Design: Semantic colors - Red for error (lower contrast)
  const errorColor = Color(0xFFEF5350); // Medium red
  const errorBackgroundColor = Color(0xFFFFF5F5); // Very light red

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // Comic Design: Medium tone text for lower contrast
          color: const Color(0xFFC62828), // Medium dark red text
        ),
      ),
      // Comic Design: Very light red background for error
      backgroundColor: errorBackgroundColor,
      // Comic Design: no elevation (flat design)
      elevation: 0,
      // Comic Design: rounded corners with 2.0px red border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: errorColor, width: 2.0),
      ),
      behavior: SnackBarBehavior.floating,
      // Comic Design: padding in multiples of 8
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

/// Shows an info SnackBar with Comic design
///
/// Visual: Light blue background with blue border
///
/// Usage:
/// ```dart
/// showComicInfoSnackBar(context, T.pleaseWait);
/// ```
void showComicInfoSnackBar(BuildContext context, String message) {
  // Comic Design: Semantic colors - Blue for info (lower contrast)
  const infoColor = Color(0xFF42A5F5); // Medium blue
  const infoBackgroundColor = Color(0xFFF3F8FC); // Very light blue

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // Comic Design: Medium tone text for lower contrast
          color: const Color(0xFF1565C0), // Medium dark blue text
        ),
      ),
      // Comic Design: Very light blue background for info
      backgroundColor: infoBackgroundColor,
      // Comic Design: no elevation (flat design)
      elevation: 0,
      // Comic Design: rounded corners with 2.0px blue border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: infoColor, width: 2.0),
      ),
      behavior: SnackBarBehavior.floating,
      // Comic Design: padding in multiples of 8
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}

/// Shows a warning SnackBar with Comic design
///
/// Visual: Light orange background with orange border
///
/// Usage:
/// ```dart
/// showComicWarningSnackBar(context, T.pleaseCheckInput);
/// ```
void showComicWarningSnackBar(BuildContext context, String message) {
  // Comic Design: Semantic colors - Orange for warning (lower contrast)
  const warningColor = Color(0xFFFFA726); // Medium orange
  const warningBackgroundColor = Color(0xFFFFF8F0); // Very light orange

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          // Comic Design: Medium tone text for lower contrast
          color: const Color(0xFFEF6C00), // Medium dark orange text
        ),
      ),
      // Comic Design: Very light orange background for warning
      backgroundColor: warningBackgroundColor,
      // Comic Design: no elevation (flat design)
      elevation: 0,
      // Comic Design: rounded corners with 2.0px orange border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: warningColor, width: 2.0),
      ),
      behavior: SnackBarBehavior.floating,
      // Comic Design: padding in multiples of 8
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
