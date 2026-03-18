import 'package:easy_localization/easy_localization.dart';
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
      showErrorSnackBar(context, '신고 사유를 선택하세요.'.tr());
      return;
    }

    setState(() => _isSubmitting = true);

    ChatService.instance.createReport(
      path: widget.path,
      reason: _reportReason,
      reportee: widget.reportee,
      success: () {
        if (mounted) {
          showSuccessSnackBar(context, '신고가 접수되었습니다.'.tr());
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
                  ? '이미 이 메시지를 신고하셨습니다.'.tr()
                  : '이미 이 채팅방을 신고하셨습니다.'.tr(),
            );
            widget.onClose();
          } else {
            showErrorSnackBar(context, '신고 접수에 실패했습니다.'.tr());
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
      elevation: dialogElevation,
      // Comic design: rounded corners
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dialogBorderRadius),
      ),
      // Remove default background to use Container decoration
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: dialogMaxWidth),
        decoration: BoxDecoration(
          // Comic design: surface background color
          color: colorScheme.surface,
          // Comic design: outline border with rounded corners
          border: Border.all(
            color: colorScheme.outline,
            width: dialogBorderWidth,
          ),
          borderRadius: BorderRadius.circular(dialogBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header - Comic design spacing
            Padding(
              padding: dialogTitlePadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      reportType == ROOM
                          ? '채팅방 신고'.tr()
                          : '채팅 메시지 신고'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(width: dialogItemSpacing),
                  // Close button - Comic design
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(
                      closeButtonBorderRadius,
                    ),
                    child: Container(
                      padding: dialogCloseButtonPadding,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          closeButtonBorderRadius,
                        ),
                        border: Border.all(
                          color: colorScheme.outline,
                          width: closeButtonBorderWidth,
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        size: dialogHeaderIconSize,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider - Comic design
            Container(
              height: dialogDividerThickness,
              color: colorScheme.outline,
            ),

            // Content area - Comic design spacing
            Padding(
              padding: dialogContentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Report Reason Selection label
                  Text(
                    '신고 사유 선택'.tr(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: dialogContentSpacing),

                  // Report Reason Buttons - Comic design
                  Wrap(
                    spacing: reportChipSpacing,
                    runSpacing: reportChipRunSpacing,
                    children: reportReasons.entries.map((entry) {
                      final reason = entry.key;
                      final isSelected = _reportReason == reason;
                      return InkWell(
                        onTap: () => setState(() => _reportReason = reason),
                        borderRadius: BorderRadius.circular(
                          dialogItemBorderRadius,
                        ),
                        child: Container(
                          padding: reportChipPadding,
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
                              width: dialogItemBorderWidth,
                            ),
                            // Comic design: border radius for small elements
                            borderRadius: BorderRadius.circular(
                              dialogItemBorderRadius,
                            ),
                          ),
                          child: Text(
                            entry.value,
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
              padding: EdgeInsets.fromLTRB(
                dialogActionsPadding.left,
                0,
                dialogActionsPadding.right,
                dialogActionsPadding.bottom,
              ),
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
                          borderRadius: BorderRadius.circular(
                            actionButtonBorderRadius,
                          ),
                          side: BorderSide(
                            color: colorScheme.outline,
                            width: actionButtonBorderWidth,
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
                        actionButtonPadding,
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: Text('취소'.tr()),
                  ),
                  SizedBox(width: dialogItemSpacing),
                  // Submit button - Comic design primary button
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleReportSubmit,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            actionButtonBorderRadius,
                          ),
                          side: BorderSide(
                            color: _isSubmitting
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: actionButtonBorderWidth,
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
                        actionButtonPadding,
                      ),
                      // Comic design: text style from Theme
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodySmall,
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: loadingIndicatorSize,
                            height: loadingIndicatorSize,
                            child: CircularProgressIndicator(
                              strokeWidth: loadingStrokeWidth,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text('제출'.tr()),
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
