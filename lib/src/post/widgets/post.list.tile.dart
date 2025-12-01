import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.files.isNotEmpty;

    return Blocked(
      otherUserUid: post.firebase_uid,
      no: () {
        return Card(
          elevation: 2, // Subtle shadow for card depth
          margin: EdgeInsets.zero, // No margin (parent controls spacing)
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              12,
            ), // Match card radius for ripple
            child: hasImage
                ? _buildTileWithImage(context)
                : _buildTileWithoutImage(context),
          ),
        );
      },
      yes: () {
        return Card(
          elevation: 2, // Subtle shadow for card depth
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              showUnblockDialog(
                context: context,
                otherUserUid: post.firebase_uid,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: _buildTileWithoutImage(context, blocked: true),
          ),
        );
      },
    );
  }

  Widget _buildTileWithImage(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4,
      children: [
        /// 이미지 (왼쪽) - Flat 2.0 디자인
        Padding(
          padding: const EdgeInsets.all(8), // 16 (8의 배수)
          child: SizedBox(
            width: 81, // 더 큰 이미지 (reference 참고)
            height: 81,
            child: Hero(
              tag: 'post-image-${post.idx}-0',
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
            ),
          ),
        ),

        /// 게시글 정보 (오른쪽)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 게시글 제목 - reference처럼 더 강조
                Text(
                  post.subject,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                /// 사용자 정보 및 날짜 표시
                Row(
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// 날짜
                    FaIcon(
                      FontAwesomeIcons.lightClock,
                      size: 14,
                      color: scheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.timeString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                /// 메타 정보: 조회수, 댓글수, 좋아요수
                _buildMetaInfo(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTileWithoutImage(BuildContext context, {bool blocked = false}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            blocked
                ? "${LibTr.of(context)!.post_from_blocked_user} ${cut(_displayName(context), 8)}"
                : post.subject,
            style: blocked
                ? theme.textTheme.titleMedium!.copyWith(color: scheme.outline)
                : theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
            overflow: TextOverflow.ellipsis,
          ),
          if (blocked == false) ...[
            const SizedBox(height: 8),

            Row(
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
                const SizedBox(width: 8),

                /// 날짜
                FaIcon(
                  FontAwesomeIcons.lightClock,
                  size: 14,
                  color: scheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  post.timeString,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildMetaInfo(context),
          ],
        ],
      ),
    );
  }

  String _displayName(BuildContext context) => post.nickname.isEmpty
      ? LibTr.of(context)!.no_name
      : cut(post.nickname, 8);

  /// 메타 정보 - Flat 2.0 디자인 (reference 스타일)
  Widget _buildMetaInfo(BuildContext context) {
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
