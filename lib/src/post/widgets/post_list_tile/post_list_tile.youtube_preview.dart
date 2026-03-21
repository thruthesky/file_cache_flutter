import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// YouTube video thumbnail widget for post list tile
///
/// Displays the first YouTube video thumbnail from the post.
/// Shows a play icon overlay to indicate it's a video.
class PostListTileYoutubePreview extends StatelessWidget {
  const PostListTileYoutubePreview({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    // Get YouTube URL information from post
    final youtubeInfos = post.getAllYoutubeUrlInfos();

    // Return empty widget if no YouTube URLs found
    if (youtubeInfos.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use the first YouTube video
    final firstVideo = youtubeInfos.first;
    final thumbnailUrl = firstVideo.getThumbnailUrl(quality: 'hqdefault');

    return SizedBox(
      width: 81, // Same size as PostListTileUploadPreview
      height: 81,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          16,
        ), // Flat 2.0 - 16 (multiple of 8)
        child: Stack(
          fit: StackFit.expand,
          children: [
            // YouTube thumbnail image
            Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to medium quality if high quality fails
                return Image.network(
                  firstVideo.getThumbnailUrl(quality: 'mqdefault'),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Show gray box if all thumbnails fail
                    return Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                );
              },
            ),
            // Play icon overlay
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
