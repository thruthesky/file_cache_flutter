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
    // required this.onShowPointAds,
    this.useComicStyle = false,
  });

  final bool isPostMine;
  final Post post;
  final String firebaseUid;
  final VoidCallback onReplyTap;
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
        if (isPostMine) {
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
        int? selectedDays;
        await showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          elevation: 0,
          isScrollControlled: true,
          builder: (sheetContext) {
            return PointSelectionBottomSheet(
              pointSetting: setting.point,
              userPoints: userPoints,
              onDaysSelected: (days) {
                selectedDays = days;
                Navigator.of(sheetContext).pop(); // Close the bottom sheet
              },
            );
          },
        );

        if (selectedDays == null || !context.mounted) return; // User cancelled

        // 3. Calculate cost
        final pointCost = calculatePointCost(
          selectedDays!,
          setting.point.advCostPerHour,
        );

        final confirm = await showConfirmDialog(
          message: PhilgoTr.of(
            context,
          )!.pointAdvertisementConfirmMessage(selectedDays!, pointCost),
        );
        if (!confirm || !context.mounted) return;

        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          },
        );

        try {
          // 6. Update post (only point_advertisement_days)
          final updatedPost = await updatePost({
            'idx': post.idx,
            'point_advertisement_days': selectedDays!,
          });

          // 7. Deduct points from user
          final newPoints = userPoints - pointCost;
          state.setUserPoints(newPoints);

          // 8. Update parent component with new post
          onEditCompleted(updatedPost);

          // Close loading dialog
          if (context.mounted) Navigator.of(context).pop();

          // 9. Show success message
          if (context.mounted) {
            showSuccessSnackBar(
              context,
              PhilgoTr.of(context)!.pointAdvertisementSuccess,
            );
          }
        } catch (e) {
          // Close loading dialog
          if (context.mounted) Navigator.of(context).pop();
          // Error is already shown by updatePost function
          d('Error updating point advertisement: $e');
        }
        break;
      case _PostMenuAction.reply:
        onReplyTap();
        break;
      case _PostMenuAction.block:
        showBlockDialog(context: context, otherUserUid: firebaseUid);
        break;
      case _PostMenuAction.report:
        _showReportReasonBottomSheet(context);
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

  /// Get report reasons based on type
  List<String> _getReportReason(BuildContext context) {
    final tr = PhilgoTr.of(context)!;
    return [
      tr.report_reason_category_error,
      tr.report_reason_abuse,
      tr.report_reason_spam,
      tr.report_reason_other,
    ];
  }

  /// Handle report submission
  Future<void> _handleReport(BuildContext context, String reason) async {
    try {
      final res = await reportPost(type: 'post', idx: post.idx, reason: reason);
      if (context.mounted && res['error'] != null && res['message'] != null) {
        showErrorSnackBar(context, res['message']);
        return;
      }
      if (context.mounted &&
          res['message'] != null &&
          res['message']!.isNotEmpty) {
        showSuccessSnackBar(context, PhilgoTr.of(context)!.report_success);
        return;
      }
    } catch (e) {
      d('Error reporting post: $e');
      if (context.mounted) {
        showErrorSnackBar(context, PhilgoTr.of(context)!.report_failed);
      }
    }
  }

  /// Show report reason bottom sheet
  void _showReportReasonBottomSheet(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reasons = _getReportReason(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            border: Border(
              top: BorderSide(color: scheme.outline, width: 2.0),
              left: BorderSide(color: scheme.outline, width: 2.0),
              right: BorderSide(color: scheme.outline, width: 2.0),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle indicator
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
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const FaIcon(FontAwesomeIcons.xmark, size: 20),
                      ),
                    ],
                  ),
                ),

                // Separator
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
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _handleReport(context, reason);
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
}

enum _PostMenuAction { pointads, reply, block, report, edit, delete }
