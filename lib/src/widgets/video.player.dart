import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 네트워크 비디오 플레이어 위젯 (Chewie 사용)
/// Network video player widget using Chewie package
///
/// Chewie는 video_player 위에 구축된 패키지로,
/// 재생/일시정지, 진행 바, 전체화면 등 풍부한 UI 컨트롤을 제공합니다.
/// Chewie is built on top of video_player and provides rich UI controls
/// including play/pause, progress bar, fullscreen, etc.
class VideoNetwork extends StatefulWidget {
  /// 비디오 URL
  /// Video URL
  final String url;

  /// 자동 재생 여부 (기본값: false)
  /// Whether to auto-play the video (default: false)
  final bool autoPlay;

  /// 반복 재생 여부 (기본값: false)
  /// Whether to loop the video (default: false)
  final bool looping;

  /// 전체화면 허용 여부 (기본값: true)
  /// Whether to allow fullscreen mode (default: true)
  final bool allowFullScreen;

  /// 음소거 시작 여부 (기본값: false)
  /// Whether to start muted (default: false)
  final bool startMuted;

  const VideoNetwork({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
    this.allowFullScreen = true,
    this.startMuted = false,
  });

  @override
  State<VideoNetwork> createState() => _VideoNetworkState();
}

class _VideoNetworkState extends State<VideoNetwork> {
  /// video_player 컨트롤러
  /// video_player controller
  late VideoPlayerController _videoPlayerController;

  /// Chewie 컨트롤러
  /// Chewie controller
  ChewieController? _chewieController;

  /// 초기화 에러 메시지
  /// Initialization error message
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// 비디오 플레이어 초기화
  /// Initialize video player
  Future<void> _initializePlayer() async {
    // VideoPlayerController 생성
    // Create VideoPlayerController
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      videoPlayerOptions: VideoPlayerOptions(
        // 믹스 모드 설정 (다른 오디오와 함께 재생 허용)
        // Mix mode setting (allow playback with other audio)
        mixWithOthers: true,
      ),
    );

    try {
      // 비디오 초기화
      // Initialize video
      await _videoPlayerController.initialize();

      // ChewieController 생성
      // Create ChewieController
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        // 자동 재생 설정
        // Auto-play setting
        autoPlay: widget.autoPlay,
        // 반복 재생 설정
        // Looping setting
        looping: widget.looping,
        // 전체화면 허용 설정
        // Fullscreen setting
        allowFullScreen: widget.allowFullScreen,
        // 컨트롤 표시 시간 (3초 후 자동 숨김)
        // Controls hide delay (auto-hide after 3 seconds)
        hideControlsTimer: const Duration(seconds: 3),
        // 재생 속도 옵션
        // Playback speed options
        playbackSpeeds: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0],
        // 플레이스홀더 (로딩 중 표시)
        // Placeholder (shown while loading)
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        // 에러 발생 시 표시할 위젯
        // Widget to show on error
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    // 비디오 로드 실패 메시지
                    // Video load failed message
                    'Failed to load video',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // 음소거 설정 적용
      // Apply muted setting
      if (widget.startMuted) {
        _videoPlayerController.setVolume(0);
      }

      // 상태 업데이트
      // Update state
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // 초기화 실패 시 에러 메시지 저장
      // Save error message on initialization failure
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    // Dispose controllers
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 에러 발생 시 에러 화면 표시
    // Show error screen on error
    if (_errorMessage != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  // 비디오 로드 실패
                  // Failed to load video
                  'Failed to load video',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Chewie 컨트롤러가 초기화되지 않았을 때 로딩 표시
    // Show loading indicator when Chewie controller is not initialized
    if (_chewieController == null ||
        !_videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    // Chewie 플레이어 표시
    // Show Chewie player
    return AspectRatio(
      aspectRatio: _videoPlayerController.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
