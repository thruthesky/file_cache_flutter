import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility functions for PhilGo Chat Flutter Package
///
/// This file contains common utility functions with proper localization support.
/// All user-facing strings use the translation system with argument replacement
/// for better internationalization (i18n) support.
///
/// Translation Usage:
/// - Use 'key'.t for simple translations
/// - Use 'key'.tr(args: {'param': value}) for translations with arguments
/// - All time, date, and count formatting functions use localized strings

/// Formats a timestamp to display relative time (e.g., "3d ago", "2h ago", "5m ago", "Just now")
/// Uses proper localization with argument replacement for better i18n support
String formatTimestamp(BuildContext context, int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return PhilgoTr.of(context)!.time_days_ago(difference.inDays);
  } else if (difference.inHours > 0) {
    return PhilgoTr.of(context)!.time_hours_ago(difference.inHours);
  } else if (difference.inMinutes > 0) {
    return PhilgoTr.of(context)!.time_minutes_ago(difference.inMinutes);
  } else {
    return PhilgoTr.of(context)!.time_just_now;
  }
}

/// Formats a timestamp to YY-MM-DD HH:mm (military time, no seconds)
/// timestamp should be in milliseconds
String formatDateTime(int timestamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  final year = date.year.toString().substring(2); // YY
  final month = date.month.toString().padLeft(2, '0'); // MM
  final day = date.day.toString().padLeft(2, '0'); // DD
  final hour = date.hour.toString().padLeft(2, '0'); // HH (24-hour)
  final minute = date.minute.toString().padLeft(2, '0'); // mm

  return '$year-$month-$day $hour:$minute';
}

/// Format number in compact format (e.g., 1.0K, 10.0K, 1.5M)
String formatCompactNumber(int number) {
  if (number < 1000) {
    return number.toString();
  } else if (number < 1000000) {
    // K (thousands)
    final k = number / 1000;
    return '${k.floorToDouble().toStringAsFixed(1)}K';
  } else if (number < 1000000000) {
    // M (millions)
    final m = number / 1000000;
    return '${m.floorToDouble().toStringAsFixed(1)}M';
  } else {
    // B (billions)
    final b = number / 1000000000;
    return '${b.floorToDouble().toStringAsFixed(1)}B';
  }
}

/// Debug logging function
void debugLog(String message) {
  if (kDebugMode) {
    log('[DEBUG] $message');
  }
}

/// Debug error logging function
void debugError(String title, String message) {
  if (kDebugMode) {
    log('[ERROR] $title: $message');
  }
}

/// Formats a date to a localized string
String formatDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final targetDate = DateTime(date.year, date.month, date.day);

  if (targetDate == today) {
    return PhilgoTr.of(context)!.today;
  } else if (targetDate == yesterday) {
    return PhilgoTr.of(context)!.yesterday;
  } else {
    // For other dates, use a basic format
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Formats member count with proper localization
String formatMemberCount(BuildContext context, int count) {
  return PhilgoTr.of(context)!.member_count_formatted(count);
}

/// Formats unread message count with proper localization
String formatUnreadCount(int count) {
  if (count == 0) return '';
  if (count > 99) {
    return '99+';
  }
  return count.toString();
}

/// Validates and formats phone number for display
String formatPhoneNumber(String phoneNumber) {
  // Remove all non-digit characters
  String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // Add country code if missing (assumes Korean phone numbers)
  if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
    digitsOnly = '82${digitsOnly.substring(1)}';
  } else if (digitsOnly.length == 10) {
    digitsOnly = '82$digitsOnly';
  }

  return '+$digitsOnly';
}

// ========== UI HELPER METHODS ==========

/// Show success snackbar with green background
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      backgroundColor: Colors.green,
      duration: duration,
    ),
  );
}

/// Show error snackbar with red background
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),
      backgroundColor: Colors.red,
      duration: duration,
    ),
  );
}

void showInfoDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(PhilgoTr.of(context)!.ok),
        ),
      ],
    ),
  );
}

void showErrorDialog(BuildContext context, String message, {String? title}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title ?? PhilgoTr.of(context)!.error),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(PhilgoTr.of(context)!.ok),
        ),
      ],
    ),
  );
}

void showSafeErrorDialog(String message, {String? title}) {
  // Navigator가 준비될 때까지 잠시 대기 후 다이얼로그 표시
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final context = PhilgoConfig.globalContext;
      if (context.mounted) {
        showErrorDialog(context, message, title: title);
      } else {
        // context가 마운트되지 않은 경우 콘솔에만 출력
        debugLog('ERROR: Context not mounted - 서버 응답 처리 오류: $message');
      }
    } catch (e) {
      // globalContext가 null인 경우 등 예외 처리
      debugLog('ERROR: Cannot show dialog - 서버 응답 처리 오류: $message');
    }
  });
}

/// Shows an error snackbar to the user using global context
/// This is a less intrusive way to show error messages compared to dialogs
void showSafeErrorSnackBar(String message) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      final context = PhilgoConfig.globalContext;
      if (context.mounted) {
        showErrorSnackBar(context, message);
      } else {
        debugLog('ERROR SNACKBAR: Context not mounted - $message');
      }
    } catch (e) {
      debugLog('ERROR SNACKBAR: Cannot show snackbar - $message');
    }
  });
}

void d(String message) {
  // Placeholder function to avoid empty file issues
  debugLog('-- d(): $message');
}

// JSON 값을 안전하게 int로 변환하는 헬퍼 함수
// String 또는 int 타입 모두 처리 가능
int safeParseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

/// 확인 다이얼로그를 표시하고 사용자의 선택을 반환합니다.
///
/// [message] 다이얼로그에 표시할 메시지
/// [title] 다이얼로그 제목 (선택사항)
///
/// 반환값: 사용자가 "예"를 선택하면 true, "아니오"를 선택하거나 다이얼로그를 닫으면 false
Future<bool> showConfirmDialog({required String message, String? title}) async {
  // globalContext 사용하여 어디서든 호출 가능
  final context = PhilgoConfig.globalContext;

  // context가 유효하지 않으면 false 반환
  if (!context.mounted) {
    debugLog('showConfirmDialog: Context not mounted');
    return false;
  }

  // 다이얼로그 표시하고 결과 대기
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // 다이얼로그 밖을 터치해도 닫히지 않음
    builder: (BuildContext dialogContext) {
      // 번역을 위한 PhilgoTr 인스턴스 가져오기
      final tr = PhilgoTr.of(dialogContext)!;

      return AlertDialog(
        // 제목 (제공되지 않으면 l10n의 "확인" 사용)
        title: Text(title ?? tr.confirm),
        // 메시지 내용
        content: Text(message),
        actions: [
          // 아니오 버튼 - l10n 사용
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr.no),
          ),
          // 예 버튼 - l10n 사용
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(tr.yes),
          ),
        ],
      );
    },
  );

  // null인 경우 (뒤로가기 버튼 등) false 반환
  return result ?? false;
}

/// Launch an external app or URL
///
/// Opens the given [url] using the device's default handler.
/// - If [isExternal] is true, opens in an external application (e.g., browser, messaging app)
/// - If [isExternal] is false, uses the platform's default behavior
///
/// Common use cases:
/// - Phone calls: `launchApp('tel:+1234567890', false)`
/// - Web links: `launchApp('https://example.com', true)`
/// - Messaging apps: `launchApp('https://t.me/username', true)`
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

/// Calculate point cost for advertisement
/// 광고에 필요한 포인트 비용 계산
///
/// Formula: days × advCostPerHour × 24 hours
/// 공식: 일수 × 시간당비용 × 24시간
///
/// Parameters:
/// - [days] - Advertisement duration in days (광고 일수)
/// - [advCostPerHour] - Point cost per hour from settings (시간당 포인트 비용)
///
/// Returns: Total point cost (총 포인트 비용)
///
/// Example:
/// ```dart
/// final setting = PhilgoState.of(context).setting;
/// final cost = calculatePointCost(3, setting.point.advCostPerHour);
/// // If advCostPerHour = 10: cost = 3 × 10 × 24 = 720 points
/// ```
int calculatePointCost(int days, int advCostPerHour) {
  return days * advCostPerHour * 24;
}
