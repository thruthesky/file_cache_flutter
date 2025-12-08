import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
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
  /// Constrained between 130px (minimum) and 300px (maximum)
  static const double minImageHeight = 130.0;
  static const double maxImageHeight = 300.0;

  /// Global cache for image heights (persists across widget rebuilds)
  /// Key: image URL, Value: calculated height
  static final Map<String, double> _heightCache = {};

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  /// Get cached height for current image URL
  double? get _cachedHeight =>
      PostCard._heightCache[widget.post.files.firstOrNull];

  /// Set cached height for current image URL
  void _setCachedHeight(double height) {
    final imageUrl = widget.post.files.firstOrNull;
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
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// Background Image
          Image(image: imageProvider, fit: BoxFit.cover),

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
                  const SizedBox(height: 6),

                  /// User info and date
                  Row(
                    children: [
                      Avatar(
                        photoUrl: widget.post.photo_url,
                        size: 18,
                        radius: 9,
                      ),
                      const SizedBox(width: 4),

                      // User nickname
                      Expanded(
                        child: Text(
                          widget.post.nickname.isEmpty
                              ? PhilgoTr.of(context)!.no_name
                              : cut(widget.post.nickname, 5),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
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
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatTimestamp(context, widget.post.stamp * 1000),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasImage = widget.post.files.isNotEmpty;

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
            /// Text-only section for posts without images
            if (hasImage)
              CachedNetworkImage(
                imageUrl: widget.post.files[0],
                fit: BoxFit.cover,

                /// Calculate dynamic height based on actual image dimensions
                /// Height is cached to prevent recalculation during scrolling
                imageBuilder: (context, imageProvider) {
                  /// Use cached height if available
                  if (_cachedHeight != null) {
                    return _buildImageContainer(
                      imageProvider,
                      _cachedHeight!,
                      theme,
                    );
                  }

                  /// Calculate height only once and cache it
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
                placeholder: (context, url) => SizedBox(
                  height: _cachedHeight ?? PostCard.minImageHeight,
                  child: Container(
                    color: scheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => SizedBox(
                  height: _cachedHeight ?? PostCard.minImageHeight,
                  child: Container(
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
                    const SizedBox(height: 8),

                    /// User info and date
                    Row(
                      children: [
                        Avatar(
                          photoUrl: widget.post.photo_url,
                          size: 18,
                          radius: 9,
                        ),
                        const SizedBox(width: 4),

                        // User nickname
                        Expanded(
                          child: Text(
                            widget.post.nickname.isEmpty
                                ? PhilgoTr.of(context)!.no_name
                                : cut(widget.post.nickname, 5),
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
                              formatTimestamp(
                                context,
                                widget.post.stamp * 1000,
                              ),
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
