import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class PostViewButtons extends StatelessWidget {
  const PostViewButtons({
    super.key,
    required this.post,
    required this.onTapUpdate,
    required this.onTapDelete,
    required this.onLike,
    required this.myPost,
  });
  final Post? post;
  final VoidCallback onTapUpdate;
  final VoidCallback onTapDelete;
  final VoidCallback onLike;
  final bool myPost;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like button - Flat design with TextButton.icon
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onLike,
          icon: const FaIcon(FontAwesomeIcons.thumbsUp, size: 16),
          label: Text(
            post?.good != null && post!.good > 0
                ? "${LibTr.of(context)!.like} ${post!.good}"
                : LibTr.of(context)!.like,
          ),
        ),
        Spacer(),
        // 내 게시글인 경우에만 수정/삭제 버튼 표시
        if (myPost) ...[
          // Edit button - Flat design with TextButton.icon
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: onTapUpdate,
            icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
            label: Text(LibTr.of(context)!.edit),
          ),
          SizedBox(width: 8),
          // Delete button - Flat design with TextButton.icon
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: onTapDelete,
            icon: const FaIcon(FontAwesomeIcons.trash, size: 16),
            label: Text(LibTr.of(context)!.delete),
          ),
        ],
      ],
    );
  }
}
