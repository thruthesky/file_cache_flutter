import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostListTile extends StatelessWidget {
  const PostListTile({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  String displayName(BuildContext context) =>
      post.nickname.isEmpty ? LibTr.of(context)!.no_name : post.nickname;

  @override
  Widget build(BuildContext context) {
    final hasImage = post.files.isNotEmpty ? true : false;

    return Blocked(
      otherUserUid: post.firebase_uid,
      no: () {
        return InkWell(
          onTap: onTap,
          child: hasImage
              ? _buildTileWithImage(context)
              : _buildTileWithoutImage(context),
        );
      },
      yes: () {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => UnblockUserDialog(
                user: User.fromJson({'uid': post.firebase_uid}),
                onUnblocked: () {
                  // Optionally refresh or show success message
                },
              ),
            );
          },
          child: _buildTileWithoutImage(context, blocked: true),
        );
      },
    );
  }

  Widget _buildTileWithImage(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: 120,
            height: 90,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: post.files[0],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12, right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.subject,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Avatar(photoUrl: post.photo_url),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayName(context),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.thinClock,
                      size: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.timeString.split(" ").first,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FaIcon(
                      FontAwesomeIcons.lightEye,
                      size: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCompactNumber(post.no_of_view),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FaIcon(
                      FontAwesomeIcons.lightMessageDots,
                      size: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCompactNumber(post.no_of_comment),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FaIcon(
                      FontAwesomeIcons.lightThumbsUp,
                      size: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCompactNumber(post.good),
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTileWithoutImage(BuildContext context, {bool blocked = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Avatar(photoUrl: post.photo_url),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blocked
                      ? "${LibTr.of(context)!.post_from_blocked_user} ${cut(displayName(context), 8)}"
                      : post.subject,
                  style: blocked
                      ? Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        )
                      : Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (blocked == false) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        cut(displayName(context), 8),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(width: 16),
                      FaIcon(
                        FontAwesomeIcons.thinClock,
                        size: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.timeString.split(" ").first,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      FaIcon(
                        FontAwesomeIcons.lightEye,
                        size: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatCompactNumber(post.no_of_view),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.lightMessageDots,
                        size: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.no_of_comment}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FaIcon(
                        FontAwesomeIcons.lightThumbsUp,
                        size: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.good}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
