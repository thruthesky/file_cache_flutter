import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// Compact info row: user avatar/name, date-only, comments and likes
class PostListTileMeta extends StatelessWidget {
  const PostListTileMeta({
    super.key,
    required this.post,
    this.showImageIndicator = false,
    this.showProfile = true,
  });

  final Post post;
  final bool showImageIndicator;
  final bool showProfile;
  String _displayName(BuildContext context) => post.nickname.isEmpty
      ? PhilgoTr.of(context)!.no_name
      : cut(post.nickname, 8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasComments = post.no_of_comment > 0;
    final hasLikes = post.good > 0;

    return Row(
      children: [
        if (showProfile) ...[
          /// 사용자 아바타
          Avatar(photoUrl: post.photo_url, size: 18, radius: 9),
          const SizedBox(width: 6),

          /// 사용자 이름
          Flexible(
            flex: 2,
            child: Text(
              _displayName(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
        ],

        /// 날짜 (smart format: today=time, this year=M/D, other=Y-M-D)
        FaIcon(FontAwesomeIcons.lightClock, size: 14, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          formatSmartDate(post.stamp),
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 8),

        if (hasComments) ...[
          /// 댓글수
          FaIcon(
            FontAwesomeIcons.lightMessageDots,
            size: 14,
            color: scheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.no_of_comment}',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
        if (hasComments && hasLikes) const SizedBox(width: 8),

        if (hasLikes) ...[
          /// 좋아요수
          FaIcon(
            FontAwesomeIcons.lightThumbsUp,
            size: 14,
            color: scheme.outline,
          ),
          const SizedBox(width: 4),
          Text(
            '${post.good}',
            style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
          ),
        ],
      ],
    );
  }
}

/// Vertical (two-line) meta info widget for posts without thumbnails
///
/// Layout (right-aligned):
/// - Line 1: Avatar + Name
/// - Line 2: Date + Comments + Likes
///
/// Used when post has no thumbnail/attachment for a more balanced layout
class PostListTileMetaVertical extends StatelessWidget {
  const PostListTileMetaVertical({
    super.key,
    required this.post,
  });

  final Post post;

  String _displayName(BuildContext context) => post.nickname.isEmpty
      ? PhilgoTr.of(context)!.no_name
      : cut(post.nickname, 8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final hasComments = post.no_of_comment > 0;
    final hasLikes = post.good > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Line 1: Avatar + Name (right-aligned)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(photoUrl: post.photo_url, size: 18, radius: 9),
            const SizedBox(width: 6),
            Text(
              _displayName(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        /// Line 2: Date + Comments + Likes (right-aligned)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Date (smart format)
            Text(
              formatSmartDate(post.stamp),
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
            ),

            if (hasComments) ...[
              const SizedBox(width: 8),

              /// Comments count
              FaIcon(
                FontAwesomeIcons.lightMessageDots,
                size: 14,
                color: scheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.no_of_comment}',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],

            if (hasLikes) ...[
              const SizedBox(width: 8),

              /// Likes count
              FaIcon(
                FontAwesomeIcons.lightThumbsUp,
                size: 14,
                color: scheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.good}',
                style:
                    theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
