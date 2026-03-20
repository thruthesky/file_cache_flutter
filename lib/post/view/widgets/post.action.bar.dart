import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/chat/room/chat.room.screen.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/view/widgets/post.action.button.dart';
import 'package:share_plus/share_plus.dart';

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

        // 공유
        const SizedBox(width: 8),
        PostActionButton(
          icon: FontAwesomeIcons.lightShareNodes,
          label: '',
          color: scheme.onSurfaceVariant,
          onTap: () => _sharePost(context),
        ),

        const Spacer(),

        if (isMine) ...[
          // 수정
          PostActionButton(
            icon: FontAwesomeIcons.lightPenToSquare,
            label: '',
            color: scheme.onSurfaceVariant,
            onTap: onEdit,
          ),
          const SizedBox(width: 8),
          // 삭제
          PostActionButton(
            icon: FontAwesomeIcons.lightTrashCan,
            label: '',
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

  Future<void> _sharePost(BuildContext context) async {
    final postUrl =
        'https://philgo.com/post/view.php?idx=${post.idx}&post_id=${post.postId}';
    final box = context.findRenderObject() as RenderBox?;
    final origin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    await SharePlus.instance.share(
      ShareParams(
        text: '${post.subject}\n$postUrl',
        subject: post.subject,
        sharePositionOrigin: origin,
      ),
    );
  }
}
