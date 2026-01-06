// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// /// YouTube Shorts player widget (9:16 aspect ratio)
// ///
// /// Displays YouTube Shorts videos in vertical format with fullscreen support.
// /// Uses YoutubePlayerScaffold for proper fullscreen functionality.
// ///
// /// Shorts are displayed in portrait format with 9:16 aspect ratio.
// class PostYoutubeShortsPlayer extends StatelessWidget {
//   const PostYoutubeShortsPlayer({super.key, required this.controller});

//   /// YouTube player controller for this shorts video
//   final YoutubePlayerController controller;

//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerScaffold(
//       enableFullScreenOnVerticalDrag: false,
//       controller: controller,
//       aspectRatio: 9 / 16,
//       // Force portrait orientation after exiting fullscreen
//       defaultOrientations: const [
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ],
//       // Portrait orientation during fullscreen for Shorts
//       fullscreenOrientations: const [
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ],
//       // Lock to portrait when not in fullscreen
//       lockedOrientations: const [
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ],
//       builder: (context, player) {
//         return player;
//       },
//     );
//   }
// }
