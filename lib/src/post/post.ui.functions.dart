import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

Future<Post?> showAdvertisementConfirmDialog({
  required BuildContext context,
  required String message,
  required int idx,
  required int days,
}) async {
  return showDialog<Post?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      bool isProcessing = false;
      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          final tr = PhilgoTr.of(modalContext)!;
          final colorScheme = Theme.of(modalContext).colorScheme;

          Future<void> handleConfirm() async {
            setModalState(() {
              isProcessing = true;
            });
            try {
              final updatedPost = await extendPointAdvertisement(
                idx: idx,
                days: days,
              );
              if (modalContext.mounted) {
                Navigator.of(modalContext).pop(updatedPost);
              }
            } catch (e) {
              d('Error extending point advertisement: $e');
              if (modalContext.mounted) {
                setModalState(() {
                  isProcessing = false;
                });
              }
            }
          }

          return AlertDialog(
            title: Text(tr.confirm),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(message)],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing
                    ? null
                    : () => Navigator.of(modalContext).pop(null),
                child: Text(tr.no),
              ),
              TextButton(
                onPressed: isProcessing ? null : handleConfirm,
                child: isProcessing
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      )
                    : Text(tr.yes),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Show report reason bottom sheet modal
///
/// Displays a modal bottom sheet with report reason options based on content type
/// - [context]: BuildContext for showing the modal
/// - [type]: Content type ('post' or 'comment')
/// - [idx]: Unique identifier of the content to report
/// - [onReportSuccess]: Optional callback when report succeeds
///
/// Theme-based styling with Comic Design principles (rounded corners, borders)
Future<void> showReportReasonBottomSheet({
  required BuildContext context,
  required String type,
  required int idx,
  VoidCallback? onReportSuccess,
}) async {
  List<String> getReportReasons(BuildContext context, String type) {
    final tr = PhilgoTr.of(context)!;
    if (type == 'post') {
      return [
        tr.report_reason_category_error,
        tr.report_reason_abuse,
        tr.report_reason_spam,
        tr.report_reason_other,
      ];
    } else if (type == 'comment') {
      return [
        tr.report_reason_abuse,
        tr.report_reason_spam,
        tr.report_reason_other,
      ];
    }
    return [tr.report_reason_other];
  }

  Future<void> handleReport(
    BuildContext context,
    String type,
    int idx,
    String reason,
    VoidCallback? onReportSuccess,
  ) async {
    try {
      final res = await reportPost(type: type, idx: idx, reason: reason);
      if (context.mounted && res['error'] != null && res['message'] != null) {
        showErrorSnackBar(context, res['message']);
        return;
      }
      if (context.mounted &&
          res['message'] != null &&
          res['message']!.isNotEmpty) {
        showSuccessSnackBar(context, PhilgoTr.of(context)!.report_success);
        onReportSuccess?.call();
        return;
      }
    } catch (e) {
      d('Error reporting $type: $e');
      if (context.mounted) {
        showErrorSnackBar(context, PhilgoTr.of(context)!.report_failed);
      }
    }
  }

  final scheme = Theme.of(context).colorScheme;
  final reasons = getReportReasons(context, type);

  await showModalBottomSheet(
    context: context,
    backgroundColor:
        Colors.transparent, // Comic Design: transparent for custom styling
    elevation: 0, // Comic Design: no shadow
    builder: (BuildContext sheetContext) {
      return Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0), // Comic Design: rounded top corners
            topRight: Radius.circular(12.0),
          ),
          border: Border(
            top: BorderSide(
              color: scheme.outline,
              width: 2.0,
            ), // Comic Design: 2.0 border
            left: BorderSide(color: scheme.outline, width: 2.0),
            right: BorderSide(color: scheme.outline, width: 2.0),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Comic Design: drag handle indicator
              const SizedBox(height: 8),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),

              // Header: title and close button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      PhilgoTr.of(context)!.report_select_reason,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        FocusScope.of(sheetContext).unfocus();
                      },
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                    ),
                  ],
                ),
              ),

              // Comic Design: 2.0 border separator
              Container(height: 2, color: scheme.outline),

              // Report reason list
              ...reasons.map(
                (reason) => ListTile(
                  leading: FaIcon(
                    FontAwesomeIcons.hexagonExclamation,
                    size: 20,
                    color: scheme.onSurface,
                  ),
                  title: Text(reason),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await handleReport(
                      context,
                      type,
                      idx,
                      reason,
                      onReportSuccess,
                    );
                  },
                ),
              ),

              // Bottom spacing
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
