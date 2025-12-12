import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:philgo/l10n/app_localizations.dart';
import 'package:philgo/functions/ui.functions.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 옵션 바텀 시트 위젯
///
/// 게시글 더보기(⋮) 버튼 클릭 시 표시되는 바텀 시트입니다.
/// Comic 스타일 디자인(둥근 모서리 + 테두리)이 적용되어 있습니다.
///
/// ### 내 게시글인 경우:
/// - 수정 옵션 (댓글이 없는 경우만 가능)
/// - 삭제 옵션 (댓글이 없는 경우만 가능)
///
/// ### 다른 사람의 게시글인 경우:
/// - 답글 옵션
/// - 차단 옵션
/// - 신고 옵션
///
/// ### 매개변수:
/// - [isPostMine] → 게시글이 내 것인지 여부
/// - [post] → 현재 게시글 데이터
/// - [firebaseUid] → 게시글 작성자의 Firebase UID (차단 기능에 필요)
/// - [onReplyTap] → 답글 버튼 탭 시 콜백
/// - [onEditCompleted] → 수정 완료 시 콜백 (업데이트된 게시글 전달)
/// - [onDeleteCompleted] → 삭제 완료 시 콜백
///
/// ### 예시:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   backgroundColor: Colors.transparent,
///   elevation: 0,
///   builder: (context) => PostOptionsBottomSheet(
///     isPostMine: isPostMine(),
///     post: post,
///     firebaseUid: firebaseUid,
///     onReplyTap: () => focusReplyInput(),
///     onEditCompleted: (updated) => setState(() => post = updated),
///     onDeleteCompleted: () => context.pop(),
///   ),
/// );
/// ```
class PostOptionsBottomSheet extends StatelessWidget {
  /// 게시글이 내 것인지 여부
  final bool isPostMine;

  /// 현재 게시글 데이터
  final Post post;

  /// 게시글 작성자의 Firebase UID (차단 기능에 필요)
  final String firebaseUid;

  /// 답글 버튼 탭 시 콜백
  final VoidCallback onReplyTap;

  /// 수정 완료 시 콜백 (업데이트된 게시글 전달)
  final Function(Post) onEditCompleted;

  /// 삭제 완료 시 콜백
  final VoidCallback onDeleteCompleted;

  const PostOptionsBottomSheet({
    super.key,
    required this.isPostMine,
    required this.post,
    required this.firebaseUid,
    required this.onReplyTap,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      // Comic 스타일: 둥근 모서리 + 상단/좌우 테두리
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
            const SizedBox(height: 8),

            // 드래그 핸들 인디케이터
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // 다른 사람의 게시글인 경우: 답글, 차단, 신고 옵션
            if (!isPostMine) ...[
              // 답글 옵션
              ListTile(
                leading: FaIcon(FontAwesomeIcons.reply, size: 20),
                title: Text(PhilgoTr.of(context)!.reply),
                onTap: () {
                  Navigator.pop(context);
                  onReplyTap();
                },
              ),

              // 차단 옵션
              ListTile(
                leading: FaIcon(FontAwesomeIcons.ban, size: 20),
                title: Text(PhilgoTr.of(context)!.block),
                onTap: () {
                  Navigator.pop(context);
                  showBlockDialog(
                    context: context,
                    otherUserUid: firebaseUid,
                  );
                },
              ),

              // 신고 옵션
              ListTile(
                leading: FaIcon(FontAwesomeIcons.flag, size: 20),
                title: Text(PhilgoTr.of(context)!.report),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: 신고 기능 구현
                },
              ),
            ],

            // 내 게시글인 경우: 수정, 삭제 옵션
            if (isPostMine) ...[
              // 수정 옵션
              ListTile(
                leading: FaIcon(FontAwesomeIcons.penToSquare, size: 20),
                title: Text(PhilgoTr.of(context)!.edit),
                onTap: () => _handleEditTap(context, scheme),
              ),

              // 삭제 옵션 (빨간색으로 강조)
              ListTile(
                leading: FaIcon(
                  FontAwesomeIcons.trash,
                  size: 20,
                  color: scheme.error,
                ),
                title: Text(
                  PhilgoTr.of(context)!.delete,
                  style: TextStyle(color: scheme.error),
                ),
                onTap: () => _handleDeleteTap(context),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 수정 버튼 탭 처리
  ///
  /// 댓글이 있는 게시글은 수정할 수 없습니다.
  /// 수정 완료 후 [onEditCompleted] 콜백을 호출합니다.
  Future<void> _handleEditTap(BuildContext context, ColorScheme scheme) async {
    Navigator.pop(context);

    // 댓글이 있으면 수정 불가
    if (post.no_of_comment >= 1) {
      showInfoDialog(
        context,
        Lo.of(context)!.alert,
        Lo.of(context)!.postWithCommentsCannotBeEdited,
      );
      return;
    }

    // 게시글 수정 다이얼로그 표시
    await showPostUpdateDialog(
      context,
      post: post,
      onUpdated: (updated) {
        onEditCompleted(updated);
      },
    );
  }

  /// 삭제 버튼 탭 처리
  ///
  /// 댓글이 있는 게시글은 삭제할 수 없습니다.
  /// 확인 다이얼로그를 표시하고, 확인 시 삭제를 진행합니다.
  Future<void> _handleDeleteTap(BuildContext context) async {
    Navigator.pop(context);

    // 댓글이 있으면 삭제 불가
    if (post.no_of_comment >= 1) {
      showInfoDialog(
        context,
        Lo.of(context)!.alert,
        Lo.of(context)!.postWithCommentsCannotBeDeleted,
      );
      return;
    }

    // 삭제 확인 다이얼로그 표시
    final confirm = await showConfirmDialog(
      message: Lo.of(context)!.confirmDeletePost,
    );

    if (confirm) {
      // 게시글 삭제 API 호출
      await deletePost(post.idx);
      if (context.mounted) {
        onDeleteCompleted();
      }
    }
  }
}
