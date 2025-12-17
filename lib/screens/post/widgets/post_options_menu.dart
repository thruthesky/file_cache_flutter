import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 옵션 메뉴
/// - useComicStyle = false: AppBar용 (심플한 스타일, 테두리 없음)
/// - useComicStyle = true: 액션바용 (Comic 스타일, 둥근 모서리 + 테두리)
class PostOptionsMenu extends StatelessWidget {
  const PostOptionsMenu({
    super.key,
    required this.isPostMine,
    required this.post,
    required this.firebaseUid,
    required this.onReplyTap,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
    required this.onShowPointAds,
    this.useComicStyle = false,
  });

  final bool isPostMine;
  final Post post;
  final String firebaseUid;
  final VoidCallback onReplyTap;
  final void Function(Post updated) onEditCompleted;
  final void Function(BuildContext context) onShowPointAds;
  final void Function(BuildContext context) onDeleteCompleted;
  final bool useComicStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final popupButton = PopupMenuButton<_PostMenuAction>(
      tooltip: '',
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (action) => _handleAction(context, action),
      icon: useComicStyle
          ? null
          : FaIcon(
              FontAwesomeIcons.bars,
              size: 20,
              color: scheme.onSurface,
            ),
      child: useComicStyle
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: FaIcon(
                FontAwesomeIcons.bars,
                size: 16,
                color: scheme.onSurface,
              ),
            )
          : null,
      itemBuilder: (context) {
        if (isPostMine) {
          return [
            // PopupMenuItem(
            //   value: _PostMenuAction.pointads,
            //   child: Row(
            //     children: [
            //       const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
            //       const SizedBox(width: 12),
            //       Text('Points'),
            //     ],
            //   ),
            // ),
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
    );

    // Comic 스타일이면 Container로 감싸서 테두리 추가
    if (useComicStyle) {
      return Container(
        // Comic 스타일: 둥근 모서리 + 테두리 (ComicActionButton과 동일한 디자인)
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline, width: 1.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: popupButton,
      );
    }

    // AppBar용: 일반 스타일 (테두리 없음)
    return popupButton;
  }

  Future<void> _handleAction(
    BuildContext context,
    _PostMenuAction action,
  ) async {
    switch (action) {
      case _PostMenuAction.pointads:
        onShowPointAds(context);
        break;
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
            onDeleteCompleted(context);
          }
        }
        break;
    }
  }
}

enum _PostMenuAction { pointads, reply, block, report, edit, delete }
