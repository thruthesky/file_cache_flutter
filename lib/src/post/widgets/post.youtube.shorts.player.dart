import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// YouTube Shorts player widget (9:16 aspect ratio)
///
/// Displays YouTube Shorts videos in vertical format without fullscreen support.
/// Embedded player only - users can tap to open in YouTube app if needed.
///
/// Shorts are displayed in portrait format with size constraints:
/// - Maximum width: 60% of screen width
/// - Maximum height: 60% of screen height
/// - Aspect ratio: 9:16 (vertical video)
class PostYoutubeShortsPlayer extends StatelessWidget {
  const PostYoutubeShortsPlayer({super.key, required this.controller});

  /// YouTube player controller for this shorts video
  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayer(
          controller: controller,
          aspectRatio: 9 / 16,
          showVideoProgressIndicator: false,
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
            bufferedColor: Theme.of(context).colorScheme.primary.withAlpha(77),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          topActions: const [],
          // Bottom action buttons (without fullscreen button)
          bottomActions: [
            const SizedBox(width: 8),
            CurrentPosition(),
            const SizedBox(width: 4),
            ProgressBar(
              isExpanded: true,
              colors: ProgressBarColors(
                playedColor: Theme.of(context).colorScheme.primary,
                handleColor: Theme.of(context).colorScheme.primary,
                bufferedColor: Theme.of(
                  context,
                ).colorScheme.primary.withAlpha(77),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(width: 4),
            RemainingDuration(),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
