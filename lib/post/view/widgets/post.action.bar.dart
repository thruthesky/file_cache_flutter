import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/post.action.button.dart';

class PostActionBar extends StatelessWidget {
  final Post post;
  final bool isMine;
  final bool liked;
  final int goodCount;
  final VoidCallback onLike;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool bookmarked;
  final VoidCallback? onBookmark;
  final bool reported;
  final VoidCallback? onReport;
  final bool blocked;
  final VoidCallback? onBlock;

  const PostActionBar({
    super.key,
    required this.post,
    required this.isMine,
    required this.liked,
    required this.goodCount,
    required this.onLike,
    required this.onEdit,
    required this.onDelete,
    this.bookmarked = false,
    this.onBookmark,
    this.reported = false,
    this.onReport,
    this.blocked = false,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // 좋아요 — liked 상태 반영
        PostActionButton(
          icon: liked
              ? FontAwesomeIcons.solidThumbsUp
              : FontAwesomeIcons.lightThumbsUp,
          label: '${goodCount > 0 ? goodCount : ''}',
          color: liked ? scheme.primary : scheme.onSurfaceVariant,
          onTap: onLike,
        ),
        const SizedBox(width: 8),
        // 댓글
        PostActionButton(
          icon: FontAwesomeIcons.message,
          label: '',
          color: scheme.onSurfaceVariant,
          onTap: () {
            ChatRoomScreen.push(context, post.userFirebaseUid);
          },
        ),

        // 북마크
        if (onBookmark != null) ...[
          const SizedBox(width: 8),
          PostActionButton(
            icon: bookmarked
                ? FontAwesomeIcons.solidBookmark
                : FontAwesomeIcons.lightBookmark,
            label: '',
            color: bookmarked ? scheme.primary : scheme.onSurfaceVariant,
            onTap: onBookmark!,
          ),
        ],

        const Spacer(),

        if (isMine) ...[
          // 수정
          PostActionButton(
            icon: FontAwesomeIcons.lightPenToSquare,
            label: '수정'.tr(),
            color: scheme.onSurfaceVariant,
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          // 삭제
          PostActionButton(
            icon: FontAwesomeIcons.lightTrashCan,
            label: '삭제'.tr(),
            color: scheme.error,
            onTap: onDelete,
          ),
        ] else ...[
          // 신고 (아이콘만 표시)
          PostActionButton(
            icon: reported
                ? FontAwesomeIcons.solidFlag
                : FontAwesomeIcons.lightFlag,
            label: '',
            color: reported ? scheme.error : scheme.onSurfaceVariant,
            onTap: onReport ?? () {},
          ),
          const SizedBox(width: 8),
          // 차단 (아이콘만 표시)
          PostActionButton(
            icon: blocked
                ? FontAwesomeIcons.solidBan
                : FontAwesomeIcons.lightBan,
            label: '',
            color: blocked ? scheme.error : scheme.onSurfaceVariant,
            onTap: onBlock ?? () {},
          ),
        ],
      ],
    );
  }
}
