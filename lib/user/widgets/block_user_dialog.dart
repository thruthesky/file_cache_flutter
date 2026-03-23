import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:philgo/util/util.functions.dart';
import 'package:philgo/user/user.functions.dart';

/// Dialog for confirming user block action
/// Displays the target user's display name when provided
class BlockUserDialog extends StatefulWidget {
  final String otherUserUid;

  /// Display name of the user to block (shown in the confirmation message)
  final String? displayName;
  final VoidCallback? onBlocked;

  const BlockUserDialog({
    super.key,
    required this.otherUserUid,
    this.displayName,
    this.onBlocked,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isLoading = false;

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
            // Title section - Comic design spacing (multiples of 8)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                '사용자 차단'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Content section - Comic design spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the target user's name if provided
                  if (widget.displayName != null &&
                      widget.displayName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.displayName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  Text(
                    '이 사용자를 차단하시겠습니까?'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '차단하면 이 사용자의 메시지를 받지 않습니다.'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),

            // Actions section - Comic design buttons with spacing
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
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
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: Text('취소'.tr()),
                  ),
                  const SizedBox(width: 8),
                  // Block button - Comic design error button (destructive action)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _blockUser,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isLoading
                                ? colorScheme.outline
                                : colorScheme.error,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: error background for destructive action
                      backgroundColor: WidgetStateProperty.all(
                        _isLoading
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.error,
                      ),
                      // Comic design: onError text color
                      foregroundColor: WidgetStateProperty.all(
                        _isLoading
                            ? colorScheme.onSurface
                            : colorScheme.onError,
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
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text('차단'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _blockUser() async {
    setState(() => _isLoading = true);

    try {
      await toggleBlockUser(widget.otherUserUid);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onBlocked?.call();
        setState(() => _isLoading = false);
        showSuccessSnackBar(context, '사용자가 차단되었습니다'.tr());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e.toString());
      }
    }
  }
}

/// Dialog for confirming user unblock action
class UnblockUserDialog extends StatefulWidget {
  final String otherUserUid;
  final VoidCallback? onUnblocked;

  const UnblockUserDialog({
    super.key,
    required this.otherUserUid,
    this.onUnblocked,
  });
  @override
  State<UnblockUserDialog> createState() => _UnblockUserDialogState();
}

class _UnblockUserDialogState extends State<UnblockUserDialog> {
  bool _isLoading = false;

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
            // Title section - Comic design spacing (multiples of 8)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                '차단 해제'.tr(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Content section - Comic design spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                '이 사용자의 차단을 해제하시겠습니까?'.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Actions section - Comic design buttons with spacing
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button - Comic design neutral button
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
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
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: Text('취소'.tr()),
                  ),
                  const SizedBox(width: 8),
                  // Unblock button - Comic design primary button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _unblockUser,
                    style: ButtonStyle(
                      // Comic design: no shadow
                      elevation: WidgetStateProperty.all(0),
                      // Comic design: 2.0px border with rounded corners
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _isLoading
                                ? colorScheme.outline
                                : colorScheme.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      // Comic design: primary background
                      backgroundColor: WidgetStateProperty.all(
                        _isLoading
                            ? colorScheme.surfaceContainerHighest
                            : colorScheme.primary,
                      ),
                      // Comic design: onPrimary text color
                      foregroundColor: WidgetStateProperty.all(
                        _isLoading
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
                        theme.textTheme.bodyMedium,
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onSurface,
                            ),
                          )
                        : Text('차단 해제'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unblockUser() async {
    setState(() => _isLoading = true);

    try {
      await toggleBlockUser(widget.otherUserUid);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onUnblocked?.call();
        setState(() => _isLoading = false);
        showSuccessSnackBar(context, '사용자 차단이 해제되었습니다'.tr());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e.toString());
      }
    }
  }
}
