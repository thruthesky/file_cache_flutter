import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({
    super.key,
    required this.post,
    this.onTap,
    this.enableHeroTransition = false,
  });

  final Post post;
  final VoidCallback? onTap;
  final bool enableHeroTransition;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.files.isNotEmpty;

    return Blocked(
      otherUserUid: post.firebase_uid,
      no: () {
        return Card(
          elevation: 0, // Comic Design: no shadow
          margin: EdgeInsets.zero, // No margin (parent controls spacing)
          color: Theme.of(context).colorScheme.surface,
          // Comic Design: 2.0px border with rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              12,
            ), // Match card radius for ripple
            child: hasImage
                ? PostListTileWithImage(
                    post: post,
                    enableHeroTransition: enableHeroTransition,
                  )
                : PostListTileWithoutImage(post: post),
          ),
        );
      },
      yes: () {
        return Card(
          elevation: 0, // Comic Design: no shadow
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surface,
          // Comic Design: 2.0px border with rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 2.0,
            ),
          ),
          child: InkWell(
            onTap: () {
              showUnblockDialog(
                context: context,
                otherUserUid: post.firebase_uid,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: PostListTileWithoutImage(post: post, blocked: true),
          ),
        );
      },
    );
  }
}

/// Post list tile with image widget
class PostListTileWithImage extends StatelessWidget {
  const PostListTileWithImage({
    super.key,
    required this.post,
    required this.enableHeroTransition,
  });

  final Post post;
  final bool enableHeroTransition;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.files.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        /// 이미지 (왼쪽) - Flat 2.0 디자인 with conditional Hero transition
        Padding(
          padding: const EdgeInsets.all(8), // 16 (8의 배수)
          child: enableHeroTransition
              ? Hero(
                  tag: 'post-image-${post.idx}',
                  child: PostImageWidget(post: post),
                )
              : PostImageWidget(post: post),
        ),

        /// 게시글 정보 (오른쪽)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 게시글 제목 - reference처럼 더 강조 with conditional Hero transition
                enableHeroTransition
                    ? Hero(
                        tag: 'post-title-${post.idx}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: PostTitleText(post: post),
                        ),
                      )
                    : PostTitleText(post: post),
                const SizedBox(height: 8),

                /// Compact info: user, date, comments, likes (single line)
                PostInfoCompactRow(post: post, showImageIndicator: hasImage),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Post list tile without image widget
class PostListTileWithoutImage extends StatelessWidget {
  const PostListTileWithoutImage({
    super.key,
    required this.post,
    this.blocked = false,
  });

  final Post post;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Post title with conditional Hero transition for non-blocked posts
          blocked
              ? Text(
                  "${LibTr.of(context)!.post_from_blocked_user} ${cut(post.nickname.isEmpty ? LibTr.of(context)!.no_name : post.nickname, 8)}",
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: scheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                )
              : PostTitleText(post: post),
          if (blocked == false) ...[
            const SizedBox(height: 8),

            /// Compact info: user, date, comments, likes (single line)
            PostInfoCompactRow(post: post),
          ],
        ],
      ),
    );
  }
}

/// Post title text widget
class PostTitleText extends StatelessWidget {
  const PostTitleText({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Text(
      post.subject,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Post image widget
class PostImageWidget extends StatelessWidget {
  const PostImageWidget({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 81, // 더 큰 이미지 (reference 참고)
      height: 81,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Flat 2.0 - 16 (8의 배수)
        child: CachedNetworkImage(
          imageUrl: post.files[0],
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: scheme.surfaceContainerHighest,
            child: const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: scheme.surfaceContainerHighest,
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.lightImage,
                size: 20,
                color: scheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Post user info row widget (avatar, name, date)
class PostUserInfoRow extends StatelessWidget {
  const PostUserInfoRow({super.key, required this.post});

  final Post post;

  String _displayName(BuildContext context) => post.nickname.isEmpty
      ? LibTr.of(context)!.no_name
      : cut(post.nickname, 8);

  String _dateOnly() {
    final parts = post.timeString.split(' ');
    return parts.isNotEmpty ? parts.first : post.timeString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        /// 사용자 아바타
        Avatar(photoUrl: post.photo_url, size: 20, radius: 10),
        const SizedBox(width: 6),

        /// 사용자 이름
        Flexible(
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

        /// 구분자
        Text(
          '•',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 8),

        /// 날짜
        FaIcon(FontAwesomeIcons.lightClock, size: 14, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          _dateOnly(),
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

/// Post meta info widget (views, comments, likes)
class PostMetaInfo extends StatelessWidget {
  const PostMetaInfo({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        /// 조회수 (reference: 눈 아이콘)
        FaIcon(FontAwesomeIcons.lightEye, size: 16, color: scheme.outline),
        const SizedBox(width: 4), // 4 (8의 배수)
        Text(
          '${post.no_of_view}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 16), // 16 (8의 배수)
        /// 댓글수 (reference: 메시지 아이콘)
        FaIcon(
          FontAwesomeIcons.lightMessageDots,
          size: 16,
          color: scheme.outline,
        ),
        const SizedBox(width: 4), // 4 (8의 배수)
        Text(
          '${post.no_of_comment}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 16), // 16 (8의 배수)
        /// 좋아요수 (reference: 하트 아이콘)
        FaIcon(FontAwesomeIcons.lightThumbsUp, size: 16, color: scheme.outline),
        const SizedBox(width: 4), // 4 (8의 배수)
        Text(
          '${post.good}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}

/// Compact info row: user avatar/name, date-only, comments and likes
class PostInfoCompactRow extends StatelessWidget {
  const PostInfoCompactRow({
    super.key,
    required this.post,
    this.showImageIndicator = false,
  });

  final Post post;
  final bool showImageIndicator;

  String _displayName(BuildContext context) => post.nickname.isEmpty
      ? LibTr.of(context)!.no_name
      : cut(post.nickname, 8);

  String _dateOnly() {
    final parts = post.timeString.split(' ');
    return parts.isNotEmpty ? parts.first : post.timeString;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
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

        /// 날짜 (date only)
        FaIcon(FontAwesomeIcons.lightClock, size: 14, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          _dateOnly(),
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 8),

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
        const SizedBox(width: 8),

        /// 좋아요수
        FaIcon(FontAwesomeIcons.lightThumbsUp, size: 14, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          '${post.good}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}
