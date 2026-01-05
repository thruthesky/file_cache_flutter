import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Normal YouTube video player widget (16:9 aspect ratio)
///
/// Displays standard YouTube videos without fullscreen support.
/// Embedded player only - users can tap to open in YouTube app if needed.
class PostYoutubeNormalPlayer extends StatelessWidget {
  const PostYoutubeNormalPlayer({super.key, required this.controller});

  /// YouTube player controller for this video
  final YoutubePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: YoutubePlayer(
          controller: controller,
          // Show video progress indicator
          showVideoProgressIndicator: false,
          // Progress indicator color (Theme-based)
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          // Buffering progress colors
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
            bufferedColor: Theme.of(context).colorScheme.primary.withAlpha(77),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          // Top action buttons (disabled)
          topActions: const [],
          // Bottom action buttons (without fullscreen button)
          bottomActions: [
            const SizedBox(width: 14),
            CurrentPosition(),
            const SizedBox(width: 8),
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
            const SizedBox(width: 8),
            RemainingDuration(),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
