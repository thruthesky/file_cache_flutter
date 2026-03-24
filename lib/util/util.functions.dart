import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:philgo/router.dart';

/// Relative time: "3d ago", "2h ago", "5m ago", "Just now"
String formatTimestamp(BuildContext context, int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return "${difference.inDays}d ago";
  } else if (difference.inHours > 0) {
    return "${difference.inHours}h ago";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes}m ago";
  } else {
    return "Just now";
  }
}

/// Formats to "YY-MM-DD HH:mm". [timestamp] in milliseconds.
String formatDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  final year = date.year.toString().substring(2); // YY
  final month = date.month.toString().padLeft(2, '0'); // MM
  final day = date.day.toString().padLeft(2, '0'); // DD
  final hour = date.hour.toString().padLeft(2, '0'); // HH (24-hour)
  final minute = date.minute.toString().padLeft(2, '0'); // mm

  return '$year-$month-$day $hour:$minute';
}

/// Compact number: 1000 → "1.0K", 1500000 → "1.5M"
String formatCompactNumber(int number) {
  if (number < 1000) {
    return number.toString();
  } else if (number < 1000000) {
    final k = number / 1000;
    return '${k.floorToDouble().toStringAsFixed(1)}K';
  } else if (number < 1000000000) {
    final m = number / 1000000;
    return '${m.floorToDouble().toStringAsFixed(1)}M';
  } else {
    final b = number / 1000000000;
    return '${b.floorToDouble().toStringAsFixed(1)}B';
  }
}

/// Logs "[DEBUG] message" in debug mode only.
void debugLog(String message) {
  if (kDebugMode) {
    log('[DEBUG] $message');
  }
}

/// Logs "[ERROR] title: message" in debug mode only.
void debugError(String title, String message) {
  if (kDebugMode) {
    log('[ERROR] $title: $message');
  }
}

/// Returns "Today", "Yesterday", or "YYYY-MM-DD".
String formatDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) {
    return "Today";
  } else if (targetDate == yesterday) {
    return "Yesterday";
  } else {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Returns "$count members".
String formatMemberCount(BuildContext context, int count) {
  return "$count members";
}

/// Returns "", "5", or "99+" for unread count badges.
String formatUnreadCount(int count) {
  if (count == 0) return '';
  if (count > 99) return '99+';
  return count.toString();
}

/// Normalizes a phone number to international format (e.g., "+821012345678").
/// Assumes Korean numbers if 10–11 digits starting with 010.
String formatPhoneNumber(String phoneNumber) {
  String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
    digitsOnly = '82${digitsOnly.substring(1)}';
  } else if (digitsOnly.length == 10) {
    digitsOnly = '82$digitsOnly';
  }

  return '+$digitsOnly';
}

// ========== UI HELPER METHODS ==========

/// Green floating snackbar. Default duration: 2s.
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.primary,
      duration: duration,
    ),
  );
}

/// Red floating snackbar. Default duration: 3s.
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: duration,
    ),
  );
}

/// Simple info dialog with an OK button.
void showInfoDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          // "OK"
          child: Text('확인'.tr()),
        ),
      ],
    ),
  );
}

/// Error dialog with optional title (defaults to "Error").
void showErrorDialog(BuildContext context, String message, {String? title}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      // "Error"
      title: Text(title ?? '오류'.tr()),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          // "OK"
          child: Text('확인'.tr()),
        ),
      ],
    ),
  );
}

/// Error dialog using [globalContext]. Safe to call outside widget tree.
void showSafeErrorDialog(String message, {String? title}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      if (globalContext.mounted) {
        showErrorDialog(globalContext, message, title: title);
      } else {
        debugLog('ERROR: Context not mounted - $message');
      }
    } catch (e) {
      debugLog('ERROR: Cannot show dialog - $message');
    }
  });
}

/// Error snackbar using [globalContext]. Safe to call outside widget tree.
void showSafeErrorSnackBar(String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      if (globalContext.mounted) {
        showErrorSnackBar(globalContext, message);
      } else {
        debugLog('ERROR SNACKBAR: Context not mounted - $message');
      }
    } catch (e) {
      debugLog('ERROR SNACKBAR: Cannot show snackbar - $message');
    }
  });
}

/// Debug shorthand: logs the message with a "d():" prefix.
void d(String message) {
  debugLog('-- d(): $message');
}

/// Safely parses [value] (int or String) to int. Returns [defaultValue] on failure.
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Confirm dialog with Yes/No buttons. Returns true if user taps Yes.
Future<bool> showConfirmDialog({required String message, String? title}) async {
  if (!globalContext.mounted) {
    debugLog('showConfirmDialog: Context not mounted');
    return false;
  }

  final result = await showDialog<bool>(
    context: globalContext,
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        // "OK"
        title: Text(title ?? '확인'.tr()),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            // "No"
            child: Text('아니오'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            // "Yes"
            child: Text('예'.tr()),
          ),
        ],
      );
    },
  );

  return result ?? false;
}

/// Opens [url] externally (browser, app) if [isExternal] is true, otherwise uses platform default.
/// Example: `launchApp('tel:+1234567890', false)`
Future<void> launchApp(String url, bool isExternal) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: isExternal
          ? LaunchMode.externalApplication
          : LaunchMode.platformDefault,
    );
  }
}

/// Ad point cost = days × advCostPerHour × 24.
/// Example: 3 days × 10/hr = 720 points.
int calculatePointCost(int days, int advCostPerHour) {
  return days * advCostPerHour * 24;
}

/// Smart date from Unix [timestamp] (seconds):
/// - Today → "11:22am"
/// - This year → "1/5"
/// - Older → "2024-12-25"
String formatSmartDate(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute$period';
  } else if (date.year == now.year) {
    return '${date.month}/${date.day}';
  } else {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
