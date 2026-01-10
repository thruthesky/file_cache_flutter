import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 목록 아이템 위젯
///
/// 게시글의 첨부파일/YouTube 영상 유무와 차단 상태에 따라 다른 레이아웃을 표시합니다:
/// - **첨부파일 있음**: 왼쪽에 이미지/비디오/파일 썸네일, 오른쪽에 제목과 메타 정보
/// - **YouTube 영상 있음**: 왼쪽에 YouTube 썸네일, 오른쪽에 제목과 메타 정보
/// - **첨부파일 없음**: 제목과 메타 정보만 표시
/// - **차단된 사용자**: 차단 메시지와 함께 간소화된 레이아웃
///
/// 우선순위: 첨부파일 > YouTube 썸네일
/// 내부적으로 `Blocked` 위젯을 사용하여 차단된 사용자의 게시글을 자동으로 처리합니다.
///
/// ### 매개변수:
/// - [post] → 표시할 게시글 데이터
/// - [enableHeroTransition] → Hero 애니메이션 활성화 여부. 기본값 `false`
/// - [showProfile] → 작성자 프로필 표시 여부. 기본값 `true`
///
/// ### 예시:
/// ```dart
/// PostListTileItem(
///   post: post,
///   enableHeroTransition: true,
///   showProfile: true,
/// )
/// ```
class PostListTileItem extends StatelessWidget {
  const PostListTileItem({
    super.key,
    required this.post,
    this.enableHeroTransition = false,
    this.showProfile = true,
    required this.onTap,
  });

  /// 표시할 게시글 데이터
  final Post post;

  /// Hero 애니메이션 활성화 여부
  final bool enableHeroTransition;

  /// 작성자 프로필(아바타, 닉네임) 표시 여부
  final bool showProfile;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Blocked 위젯을 사용하여 차단된 사용자 처리
    return Blocked(
      otherUserUid: post.firebase_uid,
      // 차단되지 않은 경우: 일반 게시글 레이아웃 (onTap 사용)
      no: () {
        return InkWell(
          onTap: onTap,
          child: _buildContent(context, blocked: false),
        );
      },
      // 차단된 경우: 차단 메시지 레이아웃 + 탭하여 차단 해제
      yes: () => InkWell(
        onTap: () => showUnblockDialog(
          context: context,
          otherUserUid: post.firebase_uid,
        ),
        child: _buildContent(context, blocked: true),
      ),
    );
  }

  /// 게시글 콘텐츠 빌드 (통합 함수)
  ///
  /// [blocked]가 true이면 차단된 게시글 레이아웃 표시
  /// 블라인드 처리된 글이면 블라인드 메시지 표시
  /// 첨부파일 또는 YouTube 썸네일 유무에 따라 썸네일 표시 여부 결정
  /// 우선순위: 첨부파일 > YouTube 썸네일
  Widget _buildContent(BuildContext context, {required bool blocked}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // 블라인드 처리 여부 확인
    // Check if the post is blinded
    final isBlinded = post.isBlinded;

    // 만료된 구인/구직 글 여부 확인 (90일 규칙)
    // Check if this is an expired job post (90-day rule)
    final isExpiredJob = post.isExpiredJobPost;

    final hasFiles =
        post.files.isNotEmpty && !blocked && !isBlinded && !isExpiredJob;
    final hasYoutubeVideos = post.getAllYoutubeUrlInfos().isNotEmpty &&
        !blocked &&
        !isBlinded &&
        !isExpiredJob;

    // 썸네일 표시 여부: 첨부파일이 있거나 YouTube 영상이 있는 경우
    final hasThumbnail = hasFiles || hasYoutubeVideos;

    // 제목 위젯 빌드 (차단/블라인드 여부에 따라 다름)
    final Widget titleWidget;
    if (blocked) {
      /// 차단된 사용자: 아이콘 + 메시지 (부드러운 onSurfaceVariant 색상)
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightBan,
            size: 16,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "${PhilgoTr.of(context)!.post_from_blocked_user} ${cut(post.nickname.isEmpty ? PhilgoTr.of(context)!.no_name : post.nickname, 8)}",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (isBlinded) {
      /// 블라인드 처리된 글: 경고 아이콘 + 메시지 (error 색상)
      /// Blinded post: warning icon + message (error color)
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightTriangleExclamation,
            size: 16,
            color: scheme.error,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              PhilgoTr.of(context)?.blindedPost ?? '블라인드 처리된 글입니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.error,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (isExpiredJob) {
      /// 만료된 구인/구직 글: 시계 아이콘 + 메시지 (tertiary 색상)
      /// Expired job post: clock icon + message (tertiary color)
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightClock,
            size: 16,
            color: scheme.tertiary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              PhilgoTr.of(context)?.expiredJobPost ?? '오래된 구인/구직 글입니다',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.tertiary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (enableHeroTransition) {
      // Hero 전환
      titleWidget = Hero(
        tag: 'post-title-${post.idx}',
        child: Material(
          type: MaterialType.transparency,
          child: PostSubject(post: post),
        ),
      );
    } else {
      // 일반 제목
      titleWidget = PostSubject(post: post);
    }

    // 제목 + 메타 정보 Column (공통)
    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        // 차단, 블라인드, 만료된 구인글이 아닌 경우에만 메타 정보 표시
        // Only show meta info when not blocked, not blinded, and not expired job
        if (!blocked && !isBlinded && !isExpiredJob) ...[
          const SizedBox(height: 8),
          PostListTileMeta(
            post: post,
            showImageIndicator: hasThumbnail,
            showProfile: showProfile,
          ),
        ],
      ],
    );

    // 썸네일이 있는 경우: 썸네일 + 정보 Row 레이아웃
    if (hasThumbnail) {
      // 썸네일 위젯 결정: 첨부파일 우선, 없으면 YouTube 썸네일
      final Widget thumbnailWidget;
      if (hasFiles) {
        // 첨부파일 썸네일 (우선순위 1)
        thumbnailWidget = enableHeroTransition
            ? Hero(
                tag: 'post-image-${post.idx}',
                child: PostListTileUploadPreview(post: post),
              )
            : PostListTileUploadPreview(post: post);
      } else {
        // YouTube 썸네일 (우선순위 2)
        thumbnailWidget = enableHeroTransition
            ? Hero(
                tag: 'post-youtube-${post.idx}',
                child: PostListTileYoutubePreview(post: post),
              )
            : PostListTileYoutubePreview(post: post);
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 썸네일 (왼쪽) - 8의 배수 패딩 적용
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
            child: thumbnailWidget,
          ),

          /// 8의 배수 간격
          const SizedBox(width: 8),

          /// 게시글 정보 (오른쪽) - 균일한 패딩
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 16, 12),
              child: infoColumn,
            ),
          ),
        ],
      );
    }

    // 썸네일이 없는 경우: 제목 길이에 따라 레이아웃 결정
    // 차단, 블라인드, 만료된 구인글인 경우에는 메타 정보 없이 제목만 표시
    // For blocked, blinded, or expired job posts, only show title without meta info
    if (blocked || isBlinded || isExpiredJob) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: titleWidget,
      );
    }

    // 제목이 30글자 이상: 세로 레이아웃 (제목 위, 메타 정보 아래)
    if (post.subject.length >= 24) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: infoColumn,
      );
    }

    // 제목이 30글자 미만: 가로 레이아웃 (제목 왼쪽, 메타 정보 오른쪽 두 줄)
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 제목 (왼쪽, 확장)
          Expanded(child: titleWidget),
          const SizedBox(width: 8),

          /// 메타 정보 (오른쪽, 두 줄: 이름 위, 날짜/댓글/좋아요 아래)
          PostListTileMetaVertical(post: post),
        ],
      ),
    );
  }
}
