import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Dialog for confirming user block action
class BlockUserDialog extends StatefulWidget {
  final String otherUserUid;
  final VoidCallback? onBlocked;

  const BlockUserDialog({
    super.key,
    required this.otherUserUid,
    this.onBlocked,
  });

  @override
  State<BlockUserDialog> createState() => _BlockUserDialogState();
}

class _BlockUserDialogState extends State<BlockUserDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LibTr.of(context)!.block_user),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LibTr.of(context)!.block_user_confirmation),
          const SizedBox(height: 8),
          Text(
            LibTr.of(context)!.block_user_warning,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(LibTr.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _blockUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  LibTr.of(context)!.block,
                  style: const TextStyle(color: Colors.red),
                ),
        ),
      ],
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
        showSuccessSnackBar(context, LibTr.of(context)!.success_user_blocked);
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
    return AlertDialog(
      title: Text(LibTr.of(context)!.unblock_user),
      content: Text(LibTr.of(context)!.unblock_user_confirmation),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(LibTr.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _isLoading ? null : _unblockUser,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  LibTr.of(context)!.unblock,
                  style: const TextStyle(color: Colors.blue),
                ),
        ),
      ],
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
        showSuccessSnackBar(context, LibTr.of(context)!.user_unblocked);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(
          context,
          e.toString(),
        ); // 'failed_to_unblock_user'.t);
      }
    }
  }
}
