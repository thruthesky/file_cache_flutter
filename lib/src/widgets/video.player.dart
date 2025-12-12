import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:video_player/video_player.dart';

/// A reusable video player widget with interactive controls
///
/// This widget provides a fully-featured video player with:
/// - Play/Pause controls
/// - Progress indicator
/// - Auto-hide controls during playback
/// - Error handling and loading states
/// - Customizable dimensions and border radius
///
/// ### Parameters:
/// - [url] → The URL of the video to play
/// - [width] → The width of the video player. Defaults to `120`
/// - [height] → The height of the video player. Defaults to `120`
/// - [borderRadius] → The roundness of the player corners. Defaults to `6`
/// - [showPlaceholderOnError] → Whether to show placeholder when video fails to load. Defaults to `true`
///
/// ### Example:
/// ```dart
/// PhilgoVideoPlayer(
///   url: 'https://example.com/video.mp4',
///   width: 300,
///   height: 200,
///   borderRadius: 12,
/// )
/// ```
class PhilgoVideoPlayer extends StatefulWidget {
  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final bool showPlaceholderOnError;

  const PhilgoVideoPlayer({
    super.key,
    required this.url,
    this.width = 120.0,
    this.height = 120.0,
    this.borderRadius = 6.0,
    this.showPlaceholderOnError = true,
  });

  @override
  State<PhilgoVideoPlayer> createState() => _PhilgoVideoPlayerState();
}

class _PhilgoVideoPlayerState extends State<PhilgoVideoPlayer> {
  /// Video player controller for video playback
  VideoPlayerController? _videoController;

  /// Flag to track if user tapped on video to show controls
  bool _showControls = false;

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
  void didUpdateWidget(PhilgoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize video player if URL changes
    if (oldWidget.url != widget.url) {
      _videoController?.dispose();
      _videoInitFailed = false;
      _showControls = false;
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

      // Listen to playback position changes
      _videoController?.addListener(() {
        if (mounted && !_videoInitFailed) {
          // Rebuild to update progress indicator
          setState(() {});

          // Auto-hide controls when video is playing
          if (_videoController!.value.isPlaying && _showControls) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _videoController!.value.isPlaying) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          }
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
        _showControls = true;
      } else {
        _videoController!.play();
        _showControls = true;
      }
    });
  }

  /// Shows/hides video controls
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
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
      onTap: _toggleControls,
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
          // Play/Pause button overlay (shown when controls are visible or video is paused)
          if (_showControls || !_videoController!.value.isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
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
            ),
          // Video progress indicator at bottom
          if (_showControls && _videoController!.value.isPlaying)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: LinearProgressIndicator(
                  value: _videoController!.value.duration.inMilliseconds > 0
                      ? _videoController!.value.position.inMilliseconds /
                            _videoController!.value.duration.inMilliseconds
                      : 0.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
