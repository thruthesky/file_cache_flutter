import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 목록 아이템 위젯
///
/// 게시글의 첨부파일 유무와 차단 상태에 따라 다른 레이아웃을 표시합니다:
/// - **첨부파일 있음**: 왼쪽에 이미지/비디오/파일 썸네일, 오른쪽에 제목과 메타 정보
/// - **첨부파일 없음**: 제목과 메타 정보만 표시
/// - **차단된 사용자**: 차단 메시지와 함께 간소화된 레이아웃
///
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
  });

  /// 표시할 게시글 데이터
  final Post post;

  /// Hero 애니메이션 활성화 여부
  final bool enableHeroTransition;

  /// 작성자 프로필(아바타, 닉네임) 표시 여부
  final bool showProfile;

  @override
  Widget build(BuildContext context) {
    // Blocked 위젯을 사용하여 차단된 사용자 처리
    return Blocked(
      otherUserUid: post.firebase_uid,
      // 차단되지 않은 경우: 일반 게시글 레이아웃
      no: () => _buildContent(context, blocked: false),
      // 차단된 경우: 차단 메시지 레이아웃 + 탭하여 차단 해제
      yes: () => GestureDetector(
        /// TODO: when login-user unblock this user, show content.
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
  /// 첨부파일 유무에 따라 이미지 썸네일 표시 여부 결정
  Widget _buildContent(BuildContext context, {required bool blocked}) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasFiles = post.files.isNotEmpty && !blocked;

    // 제목 위젯 빌드 (차단 여부에 따라 다름)
    final titleWidget = blocked
        ? Text(
            "${PhilgoTr.of(context)!.post_from_blocked_user} ${cut(post.nickname.isEmpty ? PhilgoTr.of(context)!.no_name : post.nickname, 8)}",
            style: theme.textTheme.titleMedium!.copyWith(color: scheme.outline),
            overflow: TextOverflow.ellipsis,
          )
        : enableHeroTransition
        ? Hero(
            tag: 'post-title-${post.idx}',
            child: Material(
              type: MaterialType.transparency,
              child: PostSubject(post: post),
            ),
          )
        : PostSubject(post: post);

    // 제목 + 메타 정보 Column (공통)
    final infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        // 차단되지 않은 경우에만 메타 정보 표시
        if (!blocked) ...[
          const SizedBox(height: 8),
          PostListTileMeta(
            post: post,
            showImageIndicator: hasFiles,
            showProfile: showProfile,
          ),
        ],
      ],
    );

    // 첨부파일이 있는 경우: 이미지 + 정보 Row 레이아웃
    if (hasFiles) {
      final imageWidget = enableHeroTransition
          ? Hero(
              tag: 'post-image-${post.idx}',
              child: PostListTileUploadPreview(post: post),
            )
          : PostListTileUploadPreview(post: post);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 파일 썸네일 (왼쪽)
          Padding(
            padding: const EdgeInsets.all(8), // 8의 배수
            child: imageWidget,
          ),
          const SizedBox(width: 4),
          // 게시글 정보 (오른쪽)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 16, right: 16),
              child: infoColumn,
            ),
          ),
        ],
      );
    }

    // 첨부파일이 없는 경우: 정보만 표시
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: infoColumn,
    );
  }
}
