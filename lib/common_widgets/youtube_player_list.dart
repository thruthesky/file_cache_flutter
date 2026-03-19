import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omni_video_player/omni_video_player.dart';

import '../youtube/youtube.model.dart';

/// YouTube 영상 목록을 OmniVideoPlayer로 재생하는 범용 위젯
///
/// [youtubeInfos]를 받아 각 영상을 Shorts(9:16) / 일반(16:9) 비율로 자동 구분하여 표시.
/// 게시글 상세보기, 댓글, 업소록 등 YouTube 영상 재생이 필요한 곳에서 범용적으로 사용.
class YoutubePlayerList extends StatefulWidget {
  final List<YoutubeUrlInfo> youtubeInfos;

  const YoutubePlayerList({super.key, required this.youtubeInfos});

  @override
  State<YoutubePlayerList> createState() => _YoutubePlayerListState();
}

class _YoutubePlayerListState extends State<YoutubePlayerList> {
  @override
  void dispose() {
    // 풀스크린 이후 세로 방향 복원
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.youtubeInfos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.youtubeInfos.length; i++) ...[
          _buildYoutubePlayer(widget.youtubeInfos[i]),
          if (i < widget.youtubeInfos.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  /// 개별 YouTube 플레이어 위젯 생성
  Widget _buildYoutubePlayer(YoutubeUrlInfo info) {
    // 프로토콜 상대 URL 처리
    final videoUrl = info.originalUrl.startsWith('//')
        ? 'https:${info.originalUrl}'
        : info.originalUrl;

    final videoSourceConfig = VideoSourceConfiguration.youtube(
      videoUrl: Uri.parse(videoUrl),
      preferredQualities: const [
        OmniVideoQuality.high720,
        OmniVideoQuality.medium480,
        OmniVideoQuality.medium360,
        OmniVideoQuality.low144,
      ],
    );

    final playerConfig = VideoPlayerConfiguration(
      videoSourceConfiguration: videoSourceConfig,
    );

    final callbacks = VideoPlayerCallbacks(
      onFullScreenToggled: (isGoingFullScreen) async {
        if (!isGoingFullScreen) {
          await Future.delayed(const Duration(milliseconds: 400));
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
        }
      },
    );

    // Shorts: 9:16 비율, 일반: 16:9 비율
    return AspectRatio(
      aspectRatio: info.isShorts ? 9 / 16 : 16 / 9,
      child: OmniVideoPlayer(
        configuration: playerConfig,
        callbacks: callbacks,
      ),
    );
  }
}
