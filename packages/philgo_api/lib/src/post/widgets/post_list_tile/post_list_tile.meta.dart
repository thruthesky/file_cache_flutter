import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 숫자에 따른 강조 색상 반환
/// - 10개 이상: error (빨간색)
/// - 5개 이상: amber (진한 오렌지색)
/// - 그 외: 기본 색상
Color _getCountColor(int count, ColorScheme scheme, Color defaultColor) {
  if (count >= 10) return scheme.error;
  if (count >= 5) return Colors.amber.shade700;
  return defaultColor;
}

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

          /// 사용자 이름 - primary 색상으로 작성자 강조
          Flexible(
            flex: 2,
            child: Text(
              _displayName(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
        ],

        /// 날짜 (smart format: today=time, this year=M/D, other=Y-M-D)
        /// onSurfaceVariant로 가독성 향상
        FaIcon(
          FontAwesomeIcons.lightClock,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          formatSmartDate(post.stamp),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),

        if (hasComments) ...[
          /// 댓글수 - 5개 이상 파란색, 10개 이상 빨간색
          FaIcon(
            FontAwesomeIcons.lightMessageDots,
            size: 14,
            color: _getCountColor(
              post.no_of_comment,
              scheme,
              scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${post.no_of_comment}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getCountColor(
                post.no_of_comment,
                scheme,
                scheme.onSurfaceVariant,
              ),
              fontWeight:
                  post.no_of_comment >= 5 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
        if (hasComments && hasLikes) const SizedBox(width: 8),

        if (hasLikes) ...[
          /// 좋아요수 - 5개 이상 파란색, 10개 이상 빨간색
          FaIcon(
            FontAwesomeIcons.lightThumbsUp,
            size: 14,
            color: _getCountColor(post.good, scheme, scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 4),
          Text(
            '${post.good}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _getCountColor(post.good, scheme, scheme.onSurfaceVariant),
              fontWeight: post.good >= 5 ? FontWeight.w600 : FontWeight.normal,
            ),
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
        /// 닉네임은 primary 색상으로 작성자 강조
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Avatar(photoUrl: post.photo_url, size: 18, radius: 9),
            const SizedBox(width: 6),
            Text(
              _displayName(context),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        /// Line 2: Date + Comments + Likes (right-aligned)
        /// onSurfaceVariant로 가독성 향상
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Date (smart format)
            Text(
              formatSmartDate(post.stamp),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),

            if (hasComments) ...[
              const SizedBox(width: 8),

              /// Comments count - 5개 이상 파란색, 10개 이상 빨간색
              FaIcon(
                FontAwesomeIcons.lightMessageDots,
                size: 14,
                color: _getCountColor(
                  post.no_of_comment,
                  scheme,
                  scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${post.no_of_comment}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getCountColor(
                    post.no_of_comment,
                    scheme,
                    scheme.onSurfaceVariant,
                  ),
                  fontWeight: post.no_of_comment >= 5
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],

            if (hasLikes) ...[
              const SizedBox(width: 8),

              /// Likes count - 5개 이상 파란색, 10개 이상 빨간색
              FaIcon(
                FontAwesomeIcons.lightThumbsUp,
                size: 14,
                color:
                    _getCountColor(post.good, scheme, scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 4),
              Text(
                '${post.good}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getCountColor(
                    post.good,
                    scheme,
                    scheme.onSurfaceVariant,
                  ),
                  fontWeight:
                      post.good >= 5 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
