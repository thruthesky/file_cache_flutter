import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Optimized for grid layouts and visual-first content
/// Comic Design: 2.0px border, no shadow, rounded corners
///
/// Masonry Layout Support:
/// - Dynamic height based on image aspect ratio
/// - Min height: 130px, Max height: 300px
/// - Uses CachedNetworkImage for performance
/// - Global cache prevents UI shifting during scrolling
class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  /// Calculate dynamic image height based on aspect ratio
  /// Constrained between 140px (minimum) and 320px (maximum)
  /// Wider range creates more dramatic masonry effect
  static const double minImageHeight = 140.0;
  static const double maxImageHeight = 320.0;

  /// Global cache for image heights (persists across widget rebuilds)
  /// Key: image URL, Value: calculated height
  static final Map<String, double> _heightCache = {};

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  /// Extract YouTube URL info from post
  /// Returns the first YouTube video found, or null if none exists
  /// Uses Post.getAllYoutubeUrlInfos() which checks varchar19 and content fields
  YoutubeUrlInfo? get _youtubeInfo {
    final infos = widget.post.getAllYoutubeUrlInfos();
    return infos.isNotEmpty ? infos.first : null;
  }

  /// Get preview image URL - prioritizes YouTube thumbnail over regular files
  /// Returns YouTube thumbnail if video exists, otherwise first file URL
  String? get _previewImageUrl {
    final youtube = _youtubeInfo;
    if (youtube != null) {
      // YouTube thumbnail has priority
      return youtube.getThumbnailUrl();
    }
    // Fallback to regular image files
    return widget.post.files.firstOrNull;
  }

  /// Calculate height for YouTube video based on aspect ratio
  /// Creates varied heights for masonry effect with more dramatic variation:
  /// - Shorts (vertical 9:16): varies between 240-300px - tall
  /// - Regular videos (horizontal 16:9): varies between 150-250px - medium to tall
  /// - This creates strong visual variety in the masonry grid
  double _calculateYoutubeHeight(BuildContext context) {
    final youtube = _youtubeInfo;
    if (youtube == null) return PostCard.minImageHeight;

    // Use videoId hash to generate consistent but varied heights
    final hash = youtube.videoId.hashCode.abs();

    if (youtube.isShorts) {
      // Shorts are vertical - vary between 240-300px (tall cards)
      final heightVariation = 240.0 + (hash % 61); // Range: 240-300
      return heightVariation.clamp(
        PostCard.maxImageHeight - 60,
        PostCard.maxImageHeight,
      );
    } else {
      // Regular videos - vary between 150-250px (medium to tall cards)
      // Creates more dramatic height differences for better masonry effect
      final heightVariation = 150.0 + (hash % 101); // Range: 150-250
      return heightVariation.clamp(
        PostCard.minImageHeight + 20,
        PostCard.maxImageHeight - 50,
      );
    }
  }

  /// Get cached height for current preview image URL
  /// For YouTube videos, uses calculated height based on aspect ratio
  double? get _cachedHeight {
    final youtube = _youtubeInfo;
    if (youtube != null) {
      // For YouTube, check if we have a cached height
      final cached = PostCard._heightCache[_previewImageUrl];
      if (cached != null) return cached;
      // If not cached, we'll calculate it during build
      return null;
    }
    // For regular images, use the cached height
    return PostCard._heightCache[_previewImageUrl];
  }

  /// Set cached height for current preview image URL
  void _setCachedHeight(double height) {
    final imageUrl = _previewImageUrl;
    if (imageUrl != null) {
      PostCard._heightCache[imageUrl] = height;
    }
  }

  /// Build image container with gradient overlay and post info
  Widget _buildImageContainer(
    ImageProvider imageProvider,
    double height,
    ThemeData theme,
  ) {
    final isYoutube = _youtubeInfo != null;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image (YouTube thumbnail or regular file)
          Image(image: imageProvider, fit: BoxFit.cover),

          /// YouTube play icon overlay (centered)
          if (isYoutube)
            Center(
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
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
                    widget.post.subject,
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
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = _previewImageUrl != null;

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        elevation: 0, // Comic Design: no shadow
        margin: EdgeInsets.zero,
        color: scheme.surface,
        // Comic Design: 2.0px border with rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outline, width: 1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Image Section with dark gradient overlay for text (when image exists)
            /// Dynamic height based on image aspect ratio (130-300px)
            /// Prioritizes YouTube thumbnail over regular files
            /// Text-only section for posts without images
            if (hasImage)
              CachedNetworkImage(
                imageUrl: _previewImageUrl!,
                fit: BoxFit.cover,

                /// Calculate dynamic height based on actual image dimensions
                /// For YouTube: uses aspect ratio (Shorts 9:16, Regular 16:9)
                /// For regular images: uses actual image dimensions
                /// Height is cached to prevent recalculation during scrolling
                imageBuilder: (context, imageProvider) {
                  final youtube = _youtubeInfo;

                  /// For YouTube videos, use calculated height based on video type
                  if (youtube != null) {
                    final height =
                        _cachedHeight ?? _calculateYoutubeHeight(context);

                    // Cache the calculated height
                    if (_cachedHeight == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _setCachedHeight(height);
                        }
                      });
                    }

                    return _buildImageContainer(imageProvider, height, theme);
                  }

                  /// For regular images, use cached height if available
                  if (_cachedHeight != null) {
                    return _buildImageContainer(
                      imageProvider,
                      _cachedHeight!,
                      theme,
                    );
                  }

                  /// Calculate height from actual image dimensions (first time only)
                  return Image(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                          if (frame != null && _cachedHeight == null) {
                            /// Get image from provider to calculate aspect ratio
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              imageProvider
                                  .resolve(const ImageConfiguration())
                                  .addListener(
                                    ImageStreamListener((info, _) {
                                      if (mounted && _cachedHeight == null) {
                                        final aspectRatio =
                                            info.image.width /
                                            info.image.height;
                                        final screenWidth = MediaQuery.of(
                                          context,
                                        ).size.width;
                                        final cardWidth =
                                            (screenWidth - 24) / 2;
                                        final calculatedHeight =
                                            (cardWidth / aspectRatio).clamp(
                                              PostCard.minImageHeight,
                                              PostCard.maxImageHeight,
                                            );

                                        _setCachedHeight(calculatedHeight);
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      }
                                    }),
                                  );
                            });
                          }

                          return SizedBox(
                            height: _cachedHeight ?? PostCard.minImageHeight,
                            width: double.infinity,
                            child: child,
                          );
                        },
                  );
                },
                placeholder: (context, url) {
                  final youtube = _youtubeInfo;
                  final height = youtube != null
                      ? (_cachedHeight ?? _calculateYoutubeHeight(context))
                      : (_cachedHeight ?? PostCard.minImageHeight);

                  return SizedBox(
                    height: height,
                    child: Container(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorWidget: (context, url, error) {
                  final youtube = _youtubeInfo;
                  final height = youtube != null
                      ? (_cachedHeight ?? _calculateYoutubeHeight(context))
                      : (_cachedHeight ?? PostCard.minImageHeight);

                  return SizedBox(
                    height: height,
                    child: Container(
                      color: scheme.surfaceContainerHighest,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              youtube != null
                                  ? FontAwesomeIcons.lightCircleExclamation
                                  : FontAwesomeIcons.lightImage,
                              size: 48,
                              color: scheme.outline,
                            ),
                            if (youtube != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Video unavailable',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
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
                      widget.post.subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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
