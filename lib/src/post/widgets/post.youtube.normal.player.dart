// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:youtube_player_iframe/youtube_player_iframe.dart';

// <<<<<<< HEAD
// // /// Normal YouTube video player widget (16:9 aspect ratio)
// // ///
// // /// Displays standard YouTube videos with fullscreen support.
// // /// Uses YoutubePlayerScaffold for proper fullscreen functionality.
// // class PostYoutubeNormalPlayer extends StatelessWidget {
// //   const PostYoutubeNormalPlayer({super.key, required this.controller});
// =======
// /// Normal YouTube video player widget (16:9 aspect ratio)
// ///
// /// Displays standard YouTube videos with fullscreen support.
// /// Uses YoutubePlayerScaffold for proper fullscreen functionality.
// ///
// /// Orientation behavior:
// /// - Normal mode: Portrait only (respects parent screen lock)
// /// - Fullscreen mode: Landscape (both left and right)
// class PostYoutubeNormalPlayer extends StatelessWidget {
//   const PostYoutubeNormalPlayer({super.key, required this.controller});
// >>>>>>> 501d5fe27c837b1898dbace39eb23b18c556fd08

// //   /// YouTube player controller for this video
// //   final YoutubePlayerController controller;

// <<<<<<< HEAD
// //   @override
// //   Widget build(BuildContext context) {
// //     return YoutubePlayerScaffold(
// //       // Disable auto fullscreen on device rotation
// //       // User must use the fullscreen button explicitly
// //       enableFullScreenOnVerticalDrag: false,
// //       controller: controller,
// //       aspectRatio: 16 / 9,
// //       // Landscape orientation during fullscreen for 16:9 videos
// //       fullscreenOrientations: const [
// //         DeviceOrientation.landscapeLeft,
// //         DeviceOrientation.landscapeRight,
// //       ],
// //       // Lock to portrait after exiting fullscreen
// //       lockedOrientations: const [
// //         DeviceOrientation.portraitUp,
// //         DeviceOrientation.portraitDown,
// //       ],
// //       builder: (context, player) {
// //         return player;
// //       },
// //     );
// //   }
// // }
// =======
//   @override
//   Widget build(BuildContext context) {
//     return YoutubePlayerScaffold(
//       // Disable auto fullscreen on device rotation
//       // User must use the fullscreen button explicitly
//       autoFullScreen: false,
//       enableFullScreenOnVerticalDrag: false,
//       controller: controller,
//       aspectRatio: 16 / 9,
//       // Keep portrait when not in fullscreen (respects parent screen)
//       defaultOrientations: const [
//         DeviceOrientation.portraitUp,
//         DeviceOrientation.portraitDown,
//       ],
//       // Landscape orientations when in fullscreen
//       fullscreenOrientations: const [
//         DeviceOrientation.landscapeLeft,
//         DeviceOrientation.landscapeRight,
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
// >>>>>>> 501d5fe27c837b1898dbace39eb23b18c556fd08
