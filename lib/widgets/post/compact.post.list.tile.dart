import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CompactPostListTile extends StatelessWidget {
  const CompactPostListTile({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.files.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: hasImage
          ? _buildTileWithImage(context)
          : _buildTileWithoutImage(context),
    );
  }

  Widget _buildTileWithImage(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: post.files[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: scheme.surfaceContainerHighest,
                  child: Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
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

        /// 게시글 정보
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 게시글 제목
                Text(
                  post.subject,
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                /// 메타 정보: 시간, 조회수, 댓글수, 좋아요수
                _buildMetaInfo(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTileWithoutImage(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 게시글 제목
          Text(
            post.subject,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          /// 메타 정보: 시간, 조회수, 댓글수, 좋아요수
          _buildMetaInfo(context),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        FaIcon(FontAwesomeIcons.lightClock, size: 12, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          post.timeString.split(" ").first,
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 12),

        /// 조회수
        FaIcon(FontAwesomeIcons.lightEye, size: 12, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          '${post.no_of_view}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 8),

        /// 댓글수
        FaIcon(
          FontAwesomeIcons.lightMessageDots,
          size: 12,
          color: scheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          '${post.no_of_comment}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
        const SizedBox(width: 8),

        /// 좋아요수
        FaIcon(FontAwesomeIcons.lightThumbsUp, size: 12, color: scheme.outline),
        const SizedBox(width: 4),
        Text(
          '${post.good}',
          style: theme.textTheme.bodySmall?.copyWith(color: scheme.outline),
        ),
      ],
    );
  }
}
