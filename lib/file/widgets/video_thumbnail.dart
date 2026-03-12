import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

/// 비디오 첫 프레임 썸네일 위젯
///
/// video_player를 사용해 첫 프레임을 로드하고 플레이 버튼 오버레이를 표시한다.
class VideoThumbnail extends StatefulWidget {
  final String url;
  final double size;
  final double borderRadius;

  const VideoThumbnail({
    super.key,
    required this.url,
    this.size = 80,
    this.borderRadius = 8,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    try {
      await _controller!.initialize();
      await _controller!.seekTo(Duration.zero);
      await _controller!.pause();
      if (mounted) setState(() => _isInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            _buildFrame(),
            Center(
              child: FaIcon(
                FontAwesomeIcons.solidCirclePlay,
                size: widget.size * 0.35,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrame() {
    if (_hasError) return Container(color: Colors.black54);

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
          ),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: _controller!.value.size.width,
        height: _controller!.value.size.height,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}
