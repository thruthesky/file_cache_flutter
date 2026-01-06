import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube Shorts player widget (9:16 aspect ratio)
///
/// Displays YouTube Shorts videos in vertical format with fullscreen support.
/// Uses YoutubePlayerScaffold for proper fullscreen functionality.
///
/// Shorts are displayed in portrait format with 9:16 aspect ratio.
class PostYoutubeShortsPlayer extends StatelessWidget {
  const PostYoutubeShortsPlayer({super.key, required this.controller});

  /// YouTube player controller for this shorts video
  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      enableFullScreenOnVerticalDrag: false,
      controller: controller,
      aspectRatio: 9 / 16,
    );
  }
}
