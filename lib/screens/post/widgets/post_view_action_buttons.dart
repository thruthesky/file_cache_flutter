import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/widgets/comic_action_button.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 액션 버튼 위젯
///
/// 게시글 상세 화면에서 좋아요, 답글, 차단, 신고, 수정, 삭제 버튼을 표시합니다.
/// 본인 게시글인 경우 수정/삭제 버튼이, 타인 게시글인 경우 차단/신고 버튼이 표시됩니다.
///
/// ### 매개변수:
/// - [isLiked] → 좋아요 눌림 여부
/// - [likeCount] → 좋아요 수 (0 이하면 표시 안함)
/// - [isPostMine] → 본인 게시글인지 여부
/// - [postIdx] → 게시글 인덱스 (신고용)
/// - [post] → 게시글 객체 (신고용)
/// - [firebaseUid] → 작성자 Firebase UID (차단용)
/// - [noOfComment] → 댓글 수 (수정/삭제 가능 여부 확인용)
/// - [onLikePressed] → 좋아요 버튼 콜백
/// - [onReplyPressed] → 답글 버튼 콜백
/// - [onBlockPressed] → 차단 버튼 콜백
/// - [onEditPressed] → 수정 버튼 콜백
/// - [onDeletePressed] → 삭제 버튼 콜백
/// - [padding] → 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
///
/// ### 예시:
/// ```dart
/// PostViewActionButtons(
///   isLiked: false,
///   likeCount: 5,
///   isPostMine: true,
///   postIdx: 123,
///   post: post,
///   firebaseUid: 'abc123',
///   noOfComment: 3,
///   onLikePressed: () { /* 좋아요 로직 */ },
///   onReplyPressed: () { /* 답글 입력창 포커스 */ },
///   onBlockPressed: () { /* 차단 다이얼로그 */ },
///   onEditPressed: () { /* 수정 다이얼로그 */ },
///   onDeletePressed: () { /* 삭제 확인 */ },
/// )
/// ```
class PostViewActionButtons extends StatelessWidget {
  /// 좋아요 눌림 여부
  final bool isLiked;

  /// 좋아요 수 (0 이하면 표시 안함)
  final int? likeCount;

  /// 본인 게시글인지 여부
  final bool isPostMine;

  /// 게시글 인덱스 (신고용)
  final int postIdx;

  /// 게시글 객체 (신고용)
  final Post post;

  /// 작성자 Firebase UID (차단용)
  final String firebaseUid;

  /// 댓글 수 (수정/삭제 가능 여부 확인용)
  final int noOfComment;

  /// 좋아요 버튼 콜백
  final VoidCallback onLikePressed;

  /// 답글 버튼 콜백
  final VoidCallback onReplyPressed;

  /// 차단 버튼 콜백
  final VoidCallback onBlockPressed;

  /// 수정 버튼 콜백
  final VoidCallback onEditPressed;

  /// 삭제 버튼 콜백
  final VoidCallback onDeletePressed;

  /// 패딩 (기본값: EdgeInsets.fromLTRB(16, 16, 16, 0))
  final EdgeInsets padding;

  const PostViewActionButtons({
    super.key,
    required this.isLiked,
    this.likeCount,
    required this.isPostMine,
    required this.postIdx,
    required this.post,
    required this.firebaseUid,
    required this.noOfComment,
    required this.onLikePressed,
    required this.onReplyPressed,
    required this.onBlockPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          /// 좋아요 버튼
          ComicActionButton(
            icon: isLiked
                ? FontAwesomeIcons.solidThumbsUp
                : FontAwesomeIcons.thumbsUp,
            label: likeCount != null && likeCount! > 0 ? '$likeCount' : null,
            color: scheme.primary,
            onPressed: onLikePressed,
          ),

          const SizedBox(width: 8),

          /// 답글 버튼
          ComicActionButton(
            icon: FontAwesomeIcons.reply,
            onPressed: onReplyPressed,
          ),

          const Spacer(),

          /// 타인 게시글인 경우 차단/신고 버튼 표시
          if (!isPostMine) ...[
            ComicActionButton(
              icon: FontAwesomeIcons.ban,
              label: PhilgoTr.of(context)!.block,
              onPressed: onBlockPressed,
            ),
            const SizedBox(width: 8),
            PostReportButton(
              type: 'post',
              idx: postIdx,
              post: post,
            ),
          ],

          /// 본인 게시글인 경우 수정/삭제 버튼 표시
          if (isPostMine) ...[
            ComicActionButton(
              icon: FontAwesomeIcons.penToSquare,
              label: PhilgoTr.of(context)!.edit,
              onPressed: onEditPressed,
            ),
            const SizedBox(width: 8),
            ComicActionButton(
              icon: FontAwesomeIcons.trash,
              label: PhilgoTr.of(context)!.delete,
              color: scheme.error,
              onPressed: onDeletePressed,
            ),
          ],
        ],
      ),
    );
  }
}
