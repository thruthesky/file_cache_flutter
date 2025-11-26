import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

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
      showErrorSnackBar(context, LibTr.of(context)!.report_select_reason);
      return;
    }

    setState(() => _isSubmitting = true);

    createReport(
      path: widget.path,
      reason: _reportReason,
      reportee: widget.reportee,
      success: () {
        if (mounted) {
          showSuccessSnackBar(context, LibTr.of(context)!.report_success);
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
                  ? LibTr.of(context)!.report_message_already_reported
                  : LibTr.of(context)!.report_room_already_reported,
            );
            widget.onClose();
          } else {
            showErrorSnackBar(
              context,
              LibTr.of(context)!.report_submission_failed,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reportType == ROOM
                      ? LibTr.of(context)!.report_chat_room
                      : LibTr.of(context)!.report_chat_message,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                  tooltip: LibTr.of(context)!.close,
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 8),

            // Report Reason Selection
            Text(
              LibTr.of(context)!.report_select_reason,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),

            // Report Reason Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: reportReasons.map((reason) {
                final isSelected = _reportReason == reason;
                return InkWell(
                  onTap: () => setState(() => _reportReason = reason),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      LibTr.of(context)!.get_report_reason(reason),
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : widget.onClose,
                  child: Text(LibTr.of(context)!.cancel),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleReportSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(LibTr.of(context)!.report_submit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
