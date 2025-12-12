import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 네트워크 비디오 플레이어 위젯
/// Network video player widget with built-in controls
class VideoNetwork extends StatefulWidget {
  /// 비디오 URL
  /// Video URL
  final String url;

  const VideoNetwork({super.key, required this.url});

  @override
  State<VideoNetwork> createState() => _VideoNetworkState();
}

class _VideoNetworkState extends State<VideoNetwork> {
  /// 비디오 플레이어 컨트롤러
  /// Video player controller
  late VideoPlayerController _controller;

  /// 컨트롤러 표시 여부
  /// Whether to show controls overlay
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  /// 비디오 초기화
  /// Initialize video
  void _initializeVideo() {
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      viewType: VideoViewType.platformView,
    )..initialize().then((_) {
        // 비디오 초기화 완료 후 첫 프레임 표시
        // Show first frame after video is initialized
        setState(() {});
      });

    // 비디오 상태 변경 리스너 추가
    // Add listener for video state changes
    _controller.addListener(_videoListener);
  }

  /// 비디오 상태 변경 리스너
  /// Video state change listener
  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // 리스너 제거 및 컨트롤러 해제
    // Remove listener and dispose controller
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  /// 재생/일시정지 토글
  /// Toggle play/pause
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  /// 컨트롤러 표시/숨김 토글
  /// Toggle controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  /// 시간 포맷팅 (mm:ss)
  /// Format duration (mm:ss)
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // 비디오가 초기화되지 않았을 때 로딩 표시
    // Show loading indicator when video is not initialized
    if (!_controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: GestureDetector(
        // 탭하면 컨트롤러 표시/숨김
        // Tap to show/hide controls
        onTap: _toggleControls,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 비디오 플레이어
            // Video player
            VideoPlayer(_controller),

            // 컨트롤러 오버레이
            // Controls overlay
            if (_showControls)
              Container(
                // 반투명 배경
                // Semi-transparent background
                color: Colors.black.withValues(alpha: 0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 중앙 재생/일시정지 버튼
                    // Center play/pause button
                    Expanded(
                      child: Center(
                        child: IconButton(
                          iconSize: 64,
                          color: Colors.white,
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                    ),

                    // 하단 컨트롤 바
                    // Bottom control bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // 현재 재생 시간
                          // Current position
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 진행 바 (video_player 기본 제공)
                          // Progress bar (provided by video_player)
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              colors: VideoProgressColors(
                                playedColor: Theme.of(context).colorScheme.primary,
                                bufferedColor: Colors.white.withValues(alpha: 0.5),
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 전체 시간
                          // Total duration
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // 버퍼링 표시
            // Buffering indicator
            if (_controller.value.isBuffering)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
