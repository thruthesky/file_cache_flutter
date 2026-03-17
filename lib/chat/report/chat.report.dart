import 'package:flutter/material.dart';
import 'package:philgo/chat/chat.defines.dart';
import 'package:philgo/chat/chat.functions.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/chat/chat.theme.dart';
import 'package:philgo/chat/models/chat.message.dart';
import 'package:philgo/util/util.functions.dart';

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
    return ReportChatDialog(
      path: getReportMessagesPath(roomId),
      onClose: onClose,
    );
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
      showErrorSnackBar(context, "Select report reason.");
      return;
    }

    setState(() => _isSubmitting = true);

    ChatService.instance.createReport(
      path: widget.path,
      reason: _reportReason,
      reportee: widget.reportee,
      success: () {
        if (mounted) {
          showSuccessSnackBar(context, "Report submitted successfully.");
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
                  ? "You have already reported this message."
                  : "You have already reported this room.",
            );
            widget.onClose();
          } else {
            showErrorSnackBar(context, "Failed to submit report.");
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chatTheme = ChatThemeData.of(context);

    return Dialog(
      // Comic design: no shadow
      elevation: chatTheme.dialog.elevation,
      // Comic design: rounded corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius)),
      // Remove default background to use Container decoration
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: chatTheme.dialog.maxWidth),
        decoration: BoxDecoration(
          // Comic design: surface background color
          color: colorScheme.surface,
          // Comic design: outline border with rounded corners
          border: Border.all(color: colorScheme.outline, width: chatTheme.dialog.borderWidth),
          borderRadius: BorderRadius.circular(chatTheme.dialog.borderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header - Comic design spacing
            Padding(
              padding: chatTheme.dialog.titlePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reportType == ROOM
                          ? "Report Chat Room"
                          : "Report Chat Message",
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
                    borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(chatTheme.dialog.closeButtonBorderRadius),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: chatTheme.dialog.closeButtonBorderWidth,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: chatTheme.dialog.headerIconSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider - Comic design
            Container(height: chatTheme.dialog.dividerThickness, color: colorScheme.outline),

            // Content area - Comic design spacing
            Padding(
              padding: chatTheme.dialog.contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Reason Selection label
                  Text(
                    "Select Report Reason",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Report Reason Buttons - Comic design
                  Wrap(
                    spacing: chatTheme.dialog.reportChipSpacing,
                    runSpacing: chatTheme.dialog.reportChipRunSpacing,
                    children: reportReasons.entries.map((entry) {
                      final reason = entry.key;
                      final isSelected = _reportReason == reason;
                      return InkWell(
                        onTap: () => setState(() => _reportReason = reason),
                        borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                        child: Container(
                          padding: chatTheme.dialog.reportChipPadding,
                          decoration: BoxDecoration(
                            // Comic design: primary color when selected
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.surface,
                            // Comic design: border
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: chatTheme.dialog.itemBorderWidth,
                            ),
                            // Comic design: border radius for small elements
                            borderRadius: BorderRadius.circular(chatTheme.dialog.itemBorderRadius),
                          ),
                          child: Text(
                            "{reason, select, spam {Spam} abusive {Abusive} violence {Violence} hate_speech {Hate Speech} inappropriate_content {Inappropriate Content} other {reason}}",
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
              padding: EdgeInsets.fromLTRB(chatTheme.dialog.actionsPadding.left, 0, chatTheme.dialog.actionsPadding.right, chatTheme.dialog.actionsPadding.bottom),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : widget.onClose,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(chatTheme.dialog.actionButtonBorderRadius),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: chatTheme.dialog.actionButtonBorderWidth,
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
                      // Comic design: padding
                      padding: WidgetStateProperty.all(
                        chatTheme.dialog.actionButtonPadding,
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: Text("Cancel"),
                  ),
                  SizedBox(width: chatTheme.dialog.itemSpacing),
                  // Submit button - Comic design primary button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleReportSubmit,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(chatTheme.dialog.actionButtonBorderRadius),
                          side: BorderSide(
                            color: _isSubmitting
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: chatTheme.dialog.actionButtonBorderWidth,
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
                      // Comic design: padding
                      padding: WidgetStateProperty.all(
                        chatTheme.dialog.actionButtonPadding,
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: chatTheme.input.loadingIndicatorSize,
                            height: chatTheme.input.loadingIndicatorSize,
                            child: CircularProgressIndicator(
                              strokeWidth: chatTheme.input.loadingStrokeWidth,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text("Submit"),
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
