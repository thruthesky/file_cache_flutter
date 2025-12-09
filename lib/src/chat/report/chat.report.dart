import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';

/// Helper widget to report a room
class ReportChatRoom extends StatelessWidget {
  final String roomId;
  final VoidCallback onClose;

  const ReportChatRoom({
    super.key,
    required this.roomId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ReportChatDialog(path: getReportRoomPath(roomId), onClose: onClose);
  }
}

/// Helper widget to report a message
class ReportChatMessage extends StatelessWidget {
  final ChatMessage message;
  final String roomId;
  final VoidCallback onClose;

  const ReportChatMessage({
    super.key,
    required this.message,
    required this.roomId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ReportChatDialog(
      path: getReportMessagePath(message.id ?? '', roomId),
      reportee: message.senderUid,
      onClose: onClose,
    );
  }
}

/// Main report dialog widget
class ReportChatDialog extends StatefulWidget {
  final String path;
  final String? reportee;
  final VoidCallback onClose;

  const ReportChatDialog({
    super.key,
    required this.path,
    this.reportee,
    required this.onClose,
  });

  @override
  State<ReportChatDialog> createState() => _ReportChatDialogState();
}

class _ReportChatDialogState extends State<ReportChatDialog> {
  String _reportReason = '';
  bool _isSubmitting = false;

  /// Determine report type based on path
  String get reportType {
    return widget.path.startsWith('chat/room') ? ROOM : MESSAGE;
  }

  /// Handle report submission
  Future<void> _handleReportSubmit() async {
    if (_reportReason.isEmpty) {
      showErrorSnackBar(context, PhilgoTr.of(context)!.report_select_reason);
      return;
    }

    setState(() => _isSubmitting = true);

    createReport(
      path: widget.path,
      reason: _reportReason,
      reportee: widget.reportee,
      success: () {
        if (mounted) {
          showSuccessSnackBar(context, PhilgoTr.of(context)!.report_success);
          widget.onClose();
          setState(() => _isSubmitting = false);
        }
      },
      error: (e) {
        if (mounted) {
          final errorMessage = e.toString();
          if (errorMessage.contains('already have reported')) {
            showErrorSnackBar(
              context,
              reportType == MESSAGE
                  ? PhilgoTr.of(context)!.report_message_already_reported
                  : PhilgoTr.of(context)!.report_room_already_reported,
            );
            widget.onClose();
          } else {
            showErrorSnackBar(
              context,
              PhilgoTr.of(context)!.report_submission_failed,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      // Comic design: no shadow
      elevation: 0,
      // Comic design: rounded corners (borderRadius: 12)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Remove default background to use Container decoration
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          // Comic design: surface background color
          color: colorScheme.surface,
          // Comic design: 2.0px outline border with rounded corners
          border: Border.all(color: colorScheme.outline, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header - Comic design spacing (multiples of 8)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reportType == ROOM
                          ? PhilgoTr.of(context)!.report_chat_room
                          : PhilgoTr.of(context)!.report_chat_message,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Close button - Comic design
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider - Comic design
            Container(height: 2, color: colorScheme.outline),

            // Content area - Comic design spacing
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Reason Selection label
                  Text(
                    PhilgoTr.of(context)!.report_select_reason,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Report Reason Buttons - Comic design
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: reportReasons.map((reason) {
                      final isSelected = _reportReason == reason;
                      return InkWell(
                        onTap: () => setState(() => _reportReason = reason),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            // Comic design: primary color when selected
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            // Comic design: 2.0px border
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: 2.0,
                            ),
                            // Comic design: border radius 8 for small elements
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            PhilgoTr.of(context)!.get_report_reason(reason),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            // Action Buttons - Comic design
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : widget.onClose,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: surface background
                      backgroundColor: WidgetStateProperty.all(
                        colorScheme.surface,
                      ),
                      // Comic design: onSurface text color
                      foregroundColor: WidgetStateProperty.all(
                        colorScheme.onSurface,
                      ),
                      // Comic design: padding in multiples of 8
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: Text(PhilgoTr.of(context)!.cancel),
                  ),
                  const SizedBox(width: 8),
                  // Submit button - Comic design primary button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleReportSubmit,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isSubmitting
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: primary background
                      backgroundColor: WidgetStateProperty.all(
                        _isSubmitting
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.primary,
                      ),
                      // Comic design: onPrimary text color
                      foregroundColor: WidgetStateProperty.all(
                        _isSubmitting
                            ? colorScheme.onSurface
                            : colorScheme.onPrimary,
                      ),
                      // Comic design: padding in multiples of 8
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text(PhilgoTr.of(context)!.report_submit),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
