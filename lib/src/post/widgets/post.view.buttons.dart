import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class PostViewButtons extends StatefulWidget {
  const PostViewButtons({
    super.key,
    required this.post,
    required this.onTapUpdate,
    required this.onTapDelete,
    required this.onLike,
    required this.myPost,
    this.onTapBlock,
  });
  final Post? post;
  final VoidCallback onTapUpdate;
  final VoidCallback onTapDelete;
  final VoidCallback onLike;
  final bool myPost;

  final VoidCallback? onTapBlock;

  @override
  State<PostViewButtons> createState() => _PostViewButtonsState();
}

class _PostViewButtonsState extends State<PostViewButtons> {
  bool _isLiked = false;

  void _handleLike() {
    _isLiked = !_isLiked;
    setState(() {});
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Wrap(
      spacing: 16,
      children: [
        // Like button - Flat design with TextButton.icon
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            foregroundColor: _isLiked ? scheme.primary : null,
          ),
          onPressed: _handleLike,
          icon: FaIcon(
            _isLiked
                ? FontAwesomeIcons.solidThumbsUp
                : FontAwesomeIcons.thumbsUp,
            size: 16,
          ),
          label: Text(
            widget.post?.good != null && widget.post!.good > 0 ? "" : "",
          ),
        ),

        if (!widget.myPost) ...[
          if (widget.onTapBlock != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              ),
              onPressed: widget.onTapBlock,
              icon: const FaIcon(FontAwesomeIcons.ban, size: 16),
              label: Text(PhilgoTr.of(context)!.block),
            ),
          PostReportButton(
            type: 'post',
            idx: widget.post!.idx,
            post: widget.post!,
          ),
        ],
        // 내 게시글인 경우에만 수정/삭제 버튼 표시
        if (widget.myPost) ...[
          // Edit button - Flat design with TextButton.icon
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            ),
            onPressed: widget.onTapUpdate,
            icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
            label: Text(PhilgoTr.of(context)!.edit),
          ),
          // Delete button - Flat design with TextButton.icon
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity(horizontal: -4, vertical: -4),
              foregroundColor: scheme.error,
            ),

            onPressed: widget.onTapDelete,
            icon: const FaIcon(FontAwesomeIcons.trash, size: 16),
            label: Text(PhilgoTr.of(context)!.delete),
          ),
        ],
      ],
    );
  }
}
