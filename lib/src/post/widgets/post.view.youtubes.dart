import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// YouTube 동영상 목록 표시 위젯
///
/// 게시글 내용(content)에서 YouTube URL을 자동으로 추출하여
/// 플레이어로 표시합니다.
///
/// 지원 URL 형식:
/// - https://www.youtube.com/watch?v=VIDEO_ID
/// - https://youtu.be/VIDEO_ID
/// - https://www.youtube.com/shorts/VIDEO_ID
/// - https://m.youtube.com/watch?v=VIDEO_ID
/// - https://www.youtube.com/embed/VIDEO_ID
///
/// Shorts와 일반 비디오의 비율:
/// - 일반 비디오: 16:9 (가로)
/// - Shorts: 9:16 (세로)
class PostViewYoutubes extends StatefulWidget {
  const PostViewYoutubes({super.key, required this.post});

  /// 게시글 데이터
  final Post post;

  @override
  State<PostViewYoutubes> createState() => _PostViewYoutubesState();
}

class _PostViewYoutubesState extends State<PostViewYoutubes> {
  /// YouTube URL 정보 리스트
  List<YoutubeUrlInfo> _youtubeInfos = [];

  /// YouTube 플레이어 컨트롤러 리스트
  /// 각 비디오마다 별도의 컨트롤러가 필요함
  final List<YoutubePlayerController> _controllers = [];

  /// 마지막으로 처리한 content (변경 감지용)
  String _lastProcessedContent = '';

  @override
  void initState() {
    super.initState();
    _initializeYoutubeVideos();
    _lastProcessedContent = widget.post.content;
  }

  @override
  void didUpdateWidget(covariant PostViewYoutubes oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if content changed
    if (widget.post.content != _lastProcessedContent) {
      // Content changed - need to re-extract YouTube URLs
      final newYoutubeInfos = widget.post.getAllYoutubeUrlInfos();

      // Only reinitialize if the actual videos changed
      if (_controllers.isEmpty || _youtubeInfosChanged(newYoutubeInfos)) {
        // Dispose old controllers if they exist
        // Store old controllers to dispose later (after frame)
        final oldControllers = List<YoutubePlayerController>.from(_controllers);
        _controllers.clear();

        // Re-initialize with new content
        _initializeYoutubeVideos();

        // Dispose old controllers after the frame completes
        // This prevents "used after disposed" errors during gestures
        if (oldControllers.isNotEmpty && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            for (final controller in oldControllers) {
              controller.close();
            }
          });
        }

        // Trigger rebuild
        if (mounted) {
          setState(() {});
        }
      }

      _lastProcessedContent = widget.post.content;
    }
  }

  /// Check if YouTube video list has changed
  bool _youtubeInfosChanged(List<YoutubeUrlInfo> newInfos) {
    if (_youtubeInfos.length != newInfos.length) return true;

    for (int i = 0; i < _youtubeInfos.length; i++) {
      if (_youtubeInfos[i].videoId != newInfos[i].videoId) {
        return true;
      }
    }

    return false;
  }

  /// YouTube URL 추출 및 컨트롤러 초기화
  void _initializeYoutubeVideos() {
    // Get all YouTube URLs from post (varchar19 + content, deduplicated)
    // varchar19 URL is prioritized and displayed first
    _youtubeInfos = widget.post.getAllYoutubeUrlInfos();

    // 각 비디오에 대한 컨트롤러 생성
    for (final info in _youtubeInfos) {
      final controller = YoutubePlayerController.fromVideoId(
        videoId: info.videoId,
        // 자동 재생 비활성화 (사용자가 직접 재생 버튼 클릭)
        autoPlay: false,
        // 시작 시간 설정 (URL에 t= 파라미터가 있는 경우)
        startSeconds: info.startTime?.toDouble() ?? 0,
        params: const YoutubePlayerParams(
          origin: 'https://www.youtube-nocookie.com',
          // 음소거 비활성화
          mute: false,
          // 제어 버튼 표시
          showControls: true,
          // 전체 화면 버튼 표시
          showFullscreenButton: true,
          // 반복 재생 비활성화
          loop: false,
          // 자막 활성화
          enableCaption: true,
          // 관련 영상 표시 비활성화
          enableJavaScript: true,
          // 재생 품질은 자동으로 조정
          strictRelatedVideos: true,
          showVideoAnnotations: false,
          

        ),
      );
      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    // 모든 컨트롤러 해제
    for (final controller in _controllers) {
      controller.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // YouTube 비디오가 없으면 빈 위젯 반환
    if (_youtubeInfos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 각 YouTube 비디오를 순서대로 표시
        // 비디오 사이 및 마지막 비디오 다음에 16px 간격 추가 (8의 배수)
        for (int i = 0; i < _youtubeInfos.length; i++) ...[
          _buildYoutubePlayer(i, _youtubeInfos[i]),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 개별 YouTube 플레이어 빌드
  ///
  /// [index] - 비디오 인덱스 (컨트롤러 접근용)
  /// [info] - YouTube URL 정보
  Widget _buildYoutubePlayer(int index, YoutubeUrlInfo info) {
    final controller = _controllers[index];

    // Shorts 여부에 따라 적절한 플레이어 위젯 반환
    // - 일반 비디오: 16:9 aspect ratio (PostYoutubeNormalPlayer)
    // - Shorts: 9:16 aspect ratio (PostYoutubeShortsPlayer)
    //
    // IMPORTANT: Use ValueKey to ensure proper widget lifecycle
    // When controllers are recreated, the key changes and Flutter
    // properly disposes old widget tree before creating new one
    if (info.isShorts) {
      return PostYoutubeShortsPlayer(
        key: ValueKey('shorts_${info.videoId}_${controller.hashCode}'),
        controller: controller,
      );
    } else {
      return PostYoutubeNormalPlayer(
        key: ValueKey('normal_${info.videoId}_${controller.hashCode}'),
        controller: controller,
      );
    }
  }
}
