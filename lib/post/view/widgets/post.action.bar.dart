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
          icon: FontAwesomeIcons.lightComment,
          label: '${post.noOfComment > 0 ? post.noOfComment : ''}',
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
            label: '수정',
            color: scheme.onSurfaceVariant,
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          // 삭제
          PostActionButton(
            icon: FontAwesomeIcons.lightTrashCan,
            label: '삭제',
            color: scheme.error,
            onTap: onDelete,
          ),
        ] else ...[
          // 신고
          PostActionButton(
            icon: FontAwesomeIcons.lightFlag,
            label: '신고',
            color: scheme.onSurfaceVariant,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          // 차단
          PostActionButton(
            icon: FontAwesomeIcons.lightBan,
            label: '차단',
            color: scheme.onSurfaceVariant,
            onTap: () {},
          ),
        ],
      ],
    );
  }
}
