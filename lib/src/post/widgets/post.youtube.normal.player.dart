import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return YoutubePlayerScaffold(
      // Disable auto fullscreen on device rotation
      // User must use the fullscreen button explicitly
      autoFullScreen: false,
      enableFullScreenOnVerticalDrag: false,
      controller: controller,
      aspectRatio: 16 / 9,
      // Keep portrait when not in fullscreen (respects parent screen)
      defaultOrientations: const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      // Landscape orientations when in fullscreen
      fullscreenOrientations: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      // Lock to portrait when not in fullscreen
      lockedOrientations: const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      builder: (context, player) {
        return player;
      },
    );
  }
}
