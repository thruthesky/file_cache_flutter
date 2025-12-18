import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 옵션 메뉴
/// - useComicStyle = false: AppBar용 (심플한 스타일, 테두리 없음)
/// - useComicStyle = true: 액션바용 (Comic 스타일, 둥근 모서리 + 테두리)
class PostViewOptionMenu extends StatelessWidget {
  const PostViewOptionMenu({
    super.key,
    required this.post,
    required this.firebaseUid,
    required this.onTapReply,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
    // required this.onShowPointAds,
    this.useComicStyle = false,
  });

  final Post post;
  final String firebaseUid;
  final VoidCallback onTapReply;
  final void Function(Post updated) onEditCompleted;
  // final void Function(BuildContext context) onShowPointAds;
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
          : FaIcon(FontAwesomeIcons.bars, size: 20, color: scheme.onSurface),
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
        if (post.isMine(context)) {
          return [
            PopupMenuItem(
              value: _PostMenuAction.pointads,
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.bullhorn, size: 16),
                  const SizedBox(width: 12),
                  Text(PhilgoTr.of(context)!.pointAdvertisement),
                ],
              ),
            ),
            const PopupMenuDivider(),

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
        // 1. Get state and setting
        final state = PhilgoState.of(context, listen: false);
        final setting = state.setting;

        if (setting == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(PhilgoTr.of(context)!.pointAdvertisement)),
          );
          return;
        }

        final userPoints = state.user?.point ?? 0;

        // 2. Show bottom sheet and get selected days
        int? selectedDays = await showModalBottomSheet<int?>(
          context: context,
          backgroundColor: Colors.transparent,
          elevation: 0,
          isScrollControlled: true,
          builder: (sheetContext) {
            return PointSelectionBottomSheet(
              pointSetting: setting.point,
              userPoints: userPoints,
              onDaysSelected: (days) {
                Navigator.of(sheetContext).pop(days); // Close the bottom sheet
              },
            );
          },
        );

        if (selectedDays == null || !context.mounted) return; // User cancelled

        // 3. 포인트 비용 계산 (Calculate point cost)
        final pointCost = calculatePointCost(
          selectedDays,
          setting.point.advCostPerHour,
        );

        // 4. Check if post has existing active advertisement
        final hasActiveAd =
            post.int5 != null &&
            post.int5! > DateTime.now().millisecondsSinceEpoch ~/ 1000;

        // 5. Use different message for extending vs new ad
        final confirmationMessage = hasActiveAd
            ? PhilgoTr.of(
                context,
              )!.pointAdvertisementExtendMessage(selectedDays, pointCost)
            : PhilgoTr.of(
                context,
              )!.pointAdvertisementConfirmMessage(selectedDays, pointCost);

        final updatedPost = await showAdvertisementConfirmDialog(
          context: context,
          message: confirmationMessage,
          idx: post.idx,
          days: selectedDays,
        );

        if (updatedPost == null || !context.mounted) return;

        // 7. 로컬 상태에서 포인트 차감 (서버에서 이미 차감됨, UI 동기화)
        final newPoints = userPoints - pointCost;
        state.setUserPoints(newPoints);

        // 8. 부모 컴포넌트에 업데이트된 게시글 전달
        onEditCompleted(updatedPost);

        // 9. 성공 메시지 표시
        if (context.mounted) {
          showSuccessSnackBar(
            context,
            PhilgoTr.of(context)!.pointAdvertisementSuccess,
          );
        }
        break;
      case _PostMenuAction.reply:
        onTapReply();
        break;
      case _PostMenuAction.block:
        showBlockDialog(context: context, otherUserUid: firebaseUid);
        break;
      case _PostMenuAction.report:
        await showReportReasonBottomSheet(
          context: context,
          type: 'post',
          idx: post.idx,
        );
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
