import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
  }

  @override
  void didUpdateWidget(covariant PostViewYoutubes oldWidget) {
    super.didUpdateWidget(oldWidget);

    // post.content가 변경되었는지 확인
    // (처음에는 빈 content로 시작하고, loadPost() 후 채워짐)
    if (widget.post.content != _lastProcessedContent) {
      // 기존 컨트롤러 해제
      for (final controller in _controllers) {
        controller.dispose();
      }
      _controllers.clear();

      // 새로운 content로 재초기화
      _initializeYoutubeVideos();

      // setState 호출하여 UI 갱신
      setState(() {});
    }
  }

  /// YouTube URL 추출 및 컨트롤러 초기화
  void _initializeYoutubeVideos() {
    // 현재 content를 저장 (변경 감지용)
    _lastProcessedContent = widget.post.content;

    // 게시글 내용에서 YouTube URL 추출
    _youtubeInfos = extractYoutubeUrlInfos(widget.post.content);

    // 각 비디오에 대한 컨트롤러 생성
    for (final info in _youtubeInfos) {
      final controller = YoutubePlayerController(
        initialVideoId: info.videoId,
        flags: YoutubePlayerFlags(
          // 자동 재생 비활성화 (사용자가 직접 재생 버튼 클릭)
          autoPlay: false,
          // 음소거 비활성화
          mute: false,
          // 관련 영상 표시 비활성화
          showLiveFullscreenButton: true,
          // 시작 시간 설정 (URL에 t= 파라미터가 있는 경우)
          startAt: info.startTime ?? 0,
          // 전체 화면 버튼 숨김 (앱 내에서 처리)
          hideControls: false,
          // 반복 재생 비활성화
          loop: false,
          // 제어 버튼 숨김 타이머 비활성화
          controlsVisibleAtStart: true,
          // 자막 비활성화
          enableCaption: true,
          // ForceHD
          forceHD: false,
        ),
      );
      _controllers.add(controller);
    }
  }

  @override
  void dispose() {
    // 모든 컨트롤러 해제
    for (final controller in _controllers) {
      controller.dispose();
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
        for (int i = 0; i < _youtubeInfos.length; i++)
          _buildYoutubePlayer(i, _youtubeInfos[i]),
      ],
    );
  }

  /// 개별 YouTube 플레이어 빌드
  ///
  /// [index] - 비디오 인덱스 (컨트롤러 접근용)
  /// [info] - YouTube URL 정보
  Widget _buildYoutubePlayer(int index, YoutubeUrlInfo info) {
    final controller = _controllers[index];

    // Shorts 여부에 따른 비율 결정
    // - 일반 비디오: 16:9 (aspectRatio = 16/9 ≈ 1.78)
    // - Shorts: 9:16 (aspectRatio = 9/16 ≈ 0.5625)
    // 단, Shorts는 화면 너비 전체를 사용하면 너무 길어지므로
    // maxHeight를 제한하고 중앙 정렬
    if (info.isShorts) {
      return _buildShortsPlayer(controller, info);
    } else {
      return _buildNormalPlayer(controller, info);
    }
  }

  /// 일반 YouTube 비디오 플레이어 (16:9 비율)
  Widget _buildNormalPlayer(
    YoutubePlayerController controller,
    YoutubeUrlInfo info,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: YoutubePlayer(
          controller: controller,
          // 비디오 진행 표시줄 표시
          showVideoProgressIndicator: true,
          // 진행 표시줄 색상 (Theme 기반)
          progressIndicatorColor: Theme.of(context).colorScheme.primary,
          // 버퍼링 진행 색상
          progressColors: ProgressBarColors(
            playedColor: Theme.of(context).colorScheme.primary,
            handleColor: Theme.of(context).colorScheme.primary,
            bufferedColor: Theme.of(context).colorScheme.primary.withAlpha(77),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
          ),
          // 상단 액션 버튼 (비활성화)
          topActions: const [],
          // 하단 액션 버튼 (기본 컨트롤 사용)
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

  /// YouTube Shorts 플레이어 (9:16 비율)
  ///
  /// Shorts는 세로 형식이므로 화면 너비의 일부만 사용하고
  /// 중앙에 배치하여 적절한 크기로 표시
  Widget _buildShortsPlayer(
    YoutubePlayerController controller,
    YoutubeUrlInfo info,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: ConstrainedBox(
          // Shorts 최대 너비 제한 (화면 너비의 60% 또는 300px 중 작은 값)
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: AspectRatio(
            // 9:16 비율 (세로 영상)
            aspectRatio: 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Theme.of(context).colorScheme.primary,
                progressColors: ProgressBarColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  handleColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withAlpha(77),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                ),
                topActions: const [],
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
          ),
        ),
      ),
    );
  }
}
