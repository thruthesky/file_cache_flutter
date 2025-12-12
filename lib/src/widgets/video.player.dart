import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:video_player/video_player.dart';

/// A reusable video player widget with simple tap-to-play/pause controls
///
/// This widget provides a simple video player with:
/// - Tap anywhere to play/pause
/// - Always-visible play/pause icon overlay
/// - Error handling and loading states
/// - Customizable dimensions and border radius
///
/// ### Parameters:
/// - [url] → The URL of the video to play
/// - [width] → The width of the video player. Defaults to `120`
/// - [height] → The height of the video player. Defaults to `120`
/// - [borderRadius] → The roundness of the player corners. Defaults to `6`
/// - [showPlaceholderOnError] → Whether to show placeholder when video fails to load. Defaults to `true`
/// - [autoPlay] → Whether to automatically start playing the video when loaded. Defaults to `false`
///
/// ### Example:
/// ```dart
/// VideoNetwork(
///   url: 'https://example.com/video.mp4',
///   width: 300,
///   height: 200,
///   borderRadius: 12,
///   autoPlay: true,
/// )
/// ```
class VideoNetwork extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final bool showPlaceholderOnError;
  final bool autoPlay;

  const VideoNetwork({
    super.key,
    required this.url,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 6.0,
    this.showPlaceholderOnError = true,
    this.autoPlay = false,
  });

  @override
  State<VideoNetwork> createState() => _VideoNetworkState();
}

class _VideoNetworkState extends State<VideoNetwork> {
  /// Video player controller for video playback
  VideoPlayerController? _videoController;

  /// Flag to track if video player initialization failed
  bool _videoInitFailed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    // Dispose video controller when widget is disposed
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VideoNetwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize video player if URL changes
    if (oldWidget.url != widget.url) {
      _videoController?.dispose();
      _videoInitFailed = false;
      _initializeVideoPlayer();
    }
  }

  /// Initializes the video player controller
  void _initializeVideoPlayer() {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize()
            .then((_) {
              // Ensure the first frame is shown and update state
              if (mounted) {
                setState(() {
                  _videoInitFailed = false;
                });

                // Auto-play if enabled
                if (widget.autoPlay) {
                  _videoController!.play();
                }
              }
            })
            .catchError((error) {
              // Handle video initialization errors
              debugLog('Video player initialization error: $error');
              if (mounted) {
                setState(() {
                  _videoInitFailed = true;
                });
              }
            });
    } catch (e) {
      // Catch any synchronous errors during initialization
      debugLog('Video player setup error: $e');
      if (mounted) {
        setState(() {
          _videoInitFailed = true;
        });
      }
    }
  }

  /// Toggles video play/pause
  void _togglePlayPause() {
    if (_videoController == null) return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  /// Builds placeholder for video files when player is not ready
  Widget _buildVideoPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.video,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'VIDEO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show placeholder if video failed to initialize
    if (_videoInitFailed && widget.showPlaceholderOnError) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: _buildVideoPlaceholder(),
          ),
          // Play icon overlay
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.play,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          // Error indicator
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Preview only',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Show loading placeholder while video is initializing
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          width: widget.width,
          height: widget.height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    // Show video player when initialized
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        children: [
          // Video player
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            ),
          ),
          // Play/Pause button overlay (always visible)
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2.0,
                ),
              ),
              child: Center(
                child: FaIcon(
                  _videoController!.value.isPlaying
                      ? FontAwesomeIcons.pause
                      : FontAwesomeIcons.play,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
