import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Normal YouTube video player widget (16:9 aspect ratio)
///
/// Displays standard YouTube videos with fullscreen support.
/// Uses YoutubePlayerScaffold for proper fullscreen functionality.
///
/// Orientation behavior:
/// - Normal mode: Portrait only (respects parent screen lock)
/// - Fullscreen mode: Landscape (both left and right)
class PostYoutubeNormalPlayer extends StatelessWidget {
  const PostYoutubeNormalPlayer({super.key, required this.controller});

  /// YouTube player controller for this video
  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      // Disable auto fullscreen on device rotation
      // User must use the fullscreen button to enter fullscreen mode
      enableFullScreenOnVerticalDrag: false,
      controller: controller,
      aspectRatio: 16 / 9,
    );
  }
}
