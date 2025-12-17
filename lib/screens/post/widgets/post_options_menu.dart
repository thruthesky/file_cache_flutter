import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo_api/philgo_api.dart';

/// Popup menu for post actions (reply, edit, delete, block, report).
class PostOptionsMenu extends StatelessWidget {
  const PostOptionsMenu({
    super.key,
    required this.isPostMine,
    required this.post,
    required this.firebaseUid,
    required this.onReplyTap,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
  });

  final bool isPostMine;
  final Post post;
  final String firebaseUid;
  final VoidCallback onReplyTap;
  final void Function(Post updated) onEditCompleted;
  final VoidCallback onDeleteCompleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_PostMenuAction>(
      tooltip: '',
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) {
        if (isPostMine) {
          return [
            PopupMenuItem(
              value: _PostMenuAction.edit,
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
                  const SizedBox(width: 12),
                  Text(PhilgoTr.of(context)!.edit),
                ],
              ),
            ),
            PopupMenuItem(
              value: _PostMenuAction.delete,
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.trash, size: 16, color: scheme.error),
                  const SizedBox(width: 12),
                  Text(
                    PhilgoTr.of(context)!.delete,
                    style: TextStyle(color: scheme.error),
                  ),
                ],
              ),
            ),
          ];
        }

        return [
          PopupMenuItem(
            value: _PostMenuAction.reply,
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.reply, size: 16),
                const SizedBox(width: 12),
                Text(PhilgoTr.of(context)!.reply),
              ],
            ),
          ),
          PopupMenuItem(
            value: _PostMenuAction.block,
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.ban, size: 16),
                const SizedBox(width: 12),
                Text(PhilgoTr.of(context)!.block),
              ],
            ),
          ),
          PopupMenuItem(
            value: _PostMenuAction.report,
            child: Row(
              children: [
                const FaIcon(FontAwesomeIcons.flag, size: 16),
                const SizedBox(width: 12),
                Text(PhilgoTr.of(context)!.report),
              ],
            ),
          ),
        ];
      },
      icon: const FaIcon(FontAwesomeIcons.bars, size: 20),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    _PostMenuAction action,
  ) async {
    switch (action) {
      case _PostMenuAction.reply:
        onReplyTap();
        break;
      case _PostMenuAction.block:
        showBlockDialog(context: context, otherUserUid: firebaseUid);
        break;
      case _PostMenuAction.report:
        // TODO: implement report flow
        break;
      case _PostMenuAction.edit:
        if (post.no_of_comment >= 1) {
          showInfoDialog(
            context,
            Lo.of(context)!.alert,
            Lo.of(context)!.postWithCommentsCannotBeEdited,
          );
          return;
        }
        await showPostUpdateDialog(
          context,
          post: post,
          onUpdated: (updated) => onEditCompleted(updated),
        );
        break;
      case _PostMenuAction.delete:
        if (post.no_of_comment >= 1) {
          showInfoDialog(
            context,
            Lo.of(context)!.alert,
            Lo.of(context)!.postWithCommentsCannotBeDeleted,
          );
          return;
        }
        final confirm = await showConfirmDialog(
          message: Lo.of(context)!.confirmDeletePost,
        );
        if (confirm) {
          await deletePost(post.idx);
          if (context.mounted) {
            onDeleteCompleted();
          }
        }
        break;
    }
  }
}

enum _PostMenuAction { reply, block, report, edit, delete }
