import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Normal YouTube video player widget (16:9 aspect ratio)
///
/// Displays standard YouTube videos with fullscreen support.
/// Uses YoutubePlayerScaffold for proper fullscreen functionality.
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
      // Allow all orientations when not in fullscreen
      defaultOrientations: DeviceOrientation.values,
      // Landscape orientation during fullscreen for 16:9 videos
      fullscreenOrientations: const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      // Lock to portrait after exiting fullscreen
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
