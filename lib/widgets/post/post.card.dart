import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Optimized for grid layouts and visual-first content
/// Comic Design: 2.0px border, no shadow, rounded corners
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = post.files.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0, // Comic Design: no shadow
        margin: EdgeInsets.zero,
        color: scheme.surface,
        // Comic Design: 2.0px border with rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: scheme.outline,
            width: 2.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Image Section with dark gradient overlay for text (when image exists)
            /// Text-only section for posts without images
            if (hasImage)
              AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    /// Background Image
                    CachedNetworkImage(
                      imageUrl: post.files[0],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: scheme.surfaceContainerHighest,
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.lightImage,
                            size: 48,
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    ),

                    /// Dark gradient overlay at bottom for text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Post Title
                            Text(
                              post.subject,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            /// User info and date
                            Row(
                              children: [
                                Avatar(
                                  photoUrl: post.photo_url,
                                  size: 18,
                                  radius: 9,
                                ),
                                const SizedBox(width: 4),

                                // User nickname
                                Expanded(
                                  child: Text(
                                    post.nickname.isEmpty
                                        ? PhilgoTr.of(context)!.no_name
                                        : cut(post.nickname, 5),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Date
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.calendar,
                                      size: 11,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formatTimestamp(
                                        context,
                                        post.stamp * 1000,
                                      ),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            fontSize: 11,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              /// Text-only section for posts without images
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Post Title
                    Text(
                      post.subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),

                    /// User info and date
                    Row(
                      children: [
                        Avatar(
                          photoUrl: post.photo_url,
                          size: 18,
                          radius: 9,
                        ),
                        const SizedBox(width: 4),

                        // User nickname
                        Expanded(
                          child: Text(
                            post.nickname.isEmpty
                                ? PhilgoTr.of(context)!.no_name
                                : cut(post.nickname, 5),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.calendar,
                              size: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatTimestamp(context, post.stamp * 1000),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
