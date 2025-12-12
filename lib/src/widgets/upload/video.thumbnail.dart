import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 비디오 썸네일 위젯 (컨트롤 없이 첫 프레임만 표시)
///
/// 작은 크기의 비디오 미리보기에 사용됩니다.
/// video_player를 사용하여 비디오의 첫 프레임을 로드하고,
/// 플레이 버튼 오버레이를 표시합니다.
///
/// ### 매개변수:
/// - [url] → 비디오 URL
/// - [width] → 썸네일 너비
/// - [height] → 썸네일 높이
/// - [borderRadius] → 모서리 둥글기
/// - [onTap] → 탭 시 실행할 콜백 (글 읽기 페이지로 이동 등)
///
/// ### 예시:
/// ```dart
/// VideoThumbnail(
///   url: 'https://example.com/video.mp4',
///   width: 80,
///   height: 80,
///   onTap: () => Navigator.push(...),
/// )
/// ```
class VideoThumbnail extends StatefulWidget {
  /// 비디오 URL
  final String url;

  /// 썸네일 너비
  final double width;

  /// 썸네일 높이
  final double height;

  /// 모서리 둥글기
  final double borderRadius;

  /// 탭 시 실행할 콜백
  final VoidCallback? onTap;

  const VideoThumbnail({
    super.key,
    required this.url,
    this.width = 80,
    this.height = 80,
    this.borderRadius = 8,
    this.onTap,
  });

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  /// video_player 컨트롤러
  VideoPlayerController? _controller;

  /// 초기화 완료 여부
  bool _isInitialized = false;

  /// 에러 발생 여부
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// 비디오 초기화 (첫 프레임만 로드)
  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
      ),
    );

    try {
      await _controller!.initialize();
      // 첫 프레임을 표시하기 위해 잠시 재생 후 정지
      // seekTo(0)으로 첫 프레임 위치로 이동
      await _controller!.seekTo(Duration.zero);
      await _controller!.pause();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 비디오 첫 프레임 또는 플레이스홀더
              _buildVideoFrame(),
              // 플레이 버튼 오버레이
              _buildPlayButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 비디오 첫 프레임 빌드
  Widget _buildVideoFrame() {
    // 에러 발생 시 기본 플레이스홀더
    if (_hasError) {
      return _buildPlaceholder();
    }

    // 초기화 중일 때 로딩 표시
    if (!_isInitialized || _controller == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black87,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }

    // 비디오 첫 프레임 표시 (컨트롤 없음)
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  /// 기본 비디오 플레이스홀더 (로드 실패 시)
  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.black87,
      child: const Icon(
        Icons.videocam,
        color: Colors.white54,
        size: 32,
      ),
    );
  }

  /// 플레이 버튼 오버레이
  Widget _buildPlayButton() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
