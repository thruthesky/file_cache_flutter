import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player.dart';
import 'package:philgo_api/philgo_api.dart';

/// Display YouTube videos using omni_video_player
///
/// This widget extracts YouTube URLs from the post content and displays them
/// using the omni_video_player package which supports both normal videos
/// and YouTube Shorts with automatic WebView fallback.
///
/// Features:
/// - Supports normal YouTube videos (16:9 aspect ratio)
/// - Supports YouTube Shorts (9:16 aspect ratio)
/// - Automatic quality selection with fallback
/// - WebView fallback for rate-limited scenarios
class PostViewDisplayYouTubes extends StatefulWidget {
  final Post post;
  const PostViewDisplayYouTubes({super.key, required this.post});

  @override
  State<PostViewDisplayYouTubes> createState() =>
      _PostViewDisplayYouTubesState();
}

class _PostViewDisplayYouTubesState extends State<PostViewDisplayYouTubes> {
  /// List of YouTube URL information extracted from the post
  List<YoutubeUrlInfo> _youtubeInfos = [];

  @override
  void initState() {
    super.initState();
    _extractYoutubeUrls();
  }

  @override
  void didUpdateWidget(covariant PostViewDisplayYouTubes oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-extract URLs if post content changed
    if (oldWidget.post.content != widget.post.content ||
        oldWidget.post.varchar19 != widget.post.varchar19) {
      _extractYoutubeUrls();
    }
  }

  /// Extract YouTube URLs from post content and varchar19 field
  void _extractYoutubeUrls() {
    _youtubeInfos = widget.post.getAllYoutubeUrlInfos();
  }

  @override
  Widget build(BuildContext context) {
    // Return empty widget if no YouTube URLs found
    if (_youtubeInfos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Display each YouTube video
        for (int i = 0; i < _youtubeInfos.length; i++) ...[
          _buildYoutubePlayer(_youtubeInfos[i]),
          // Add spacing between videos except for the last one
          if (i < _youtubeInfos.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// Build individual YouTube player widget
  ///
  /// Uses different aspect ratios based on video type:
  /// - Normal videos: 16:9
  /// - Shorts: 9:16 (displayed in a constrained height container)
  Widget _buildYoutubePlayer(YoutubeUrlInfo info) {
    // Build the YouTube URL for omni_video_player
    // Use the original URL or construct from video ID
    final videoUrl = info.originalUrl.startsWith('//')
        ? 'https:${info.originalUrl}'
        : info.originalUrl;

    // Create video source configuration for YouTube
    final videoSourceConfig = VideoSourceConfiguration.youtube(
      videoUrl: Uri.parse(videoUrl),
      preferredQualities: const [
        OmniVideoQuality.high720,
        OmniVideoQuality.medium480,
        OmniVideoQuality.medium360,
        OmniVideoQuality.low144,
      ],
    );

    // Create player configuration wrapping the video source
    final playerConfig = VideoPlayerConfiguration(
      videoSourceConfiguration: videoSourceConfig,
    );

    // Create empty callbacks (required parameter)
    const callbacks = VideoPlayerCallbacks();

    // For Shorts, use a constrained height with 9:16 aspect ratio
    // No border radius, no padding - edge to edge display
    if (info.isShorts) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: OmniVideoPlayer(
              configuration: playerConfig,
              callbacks: callbacks,
            ),
          ),
        ),
      );
    }

    // For normal videos, use 16:9 aspect ratio
    // No border radius, no padding - edge to edge display
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: OmniVideoPlayer(
        configuration: playerConfig,
        callbacks: callbacks,
      ),
    );
  }
}
