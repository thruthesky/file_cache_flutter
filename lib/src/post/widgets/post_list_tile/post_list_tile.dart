import 'package:philgo_api/philgo_api.dart';
import 'package:flutter/material.dart';

/// 게시글 목록 타일 위젯
///
/// 게시글을 탭 가능한 타일 형태로 표시합니다.
/// 내부적으로 `PostListTileItem`을 사용하며, 차단된 사용자 처리는
/// `PostListTileItem` 내부에서 자동으로 처리됩니다.
///
/// ### 매개변수:
/// - [post] → 표시할 게시글 데이터
/// - [onTap] → 탭 시 실행할 콜백 (차단되지 않은 게시글에만 적용)
/// - [enableHeroTransition] → Hero 애니메이션 활성화 여부. 기본값 `false`
/// - [showProfile] → 작성자 프로필 표시 여부. 기본값 `true`
///
/// ### 예시:
/// ```dart
/// PostListTile(
///   post: post,
///   onTap: () => Navigator.push(...),
///   enableHeroTransition: true,
/// )
/// ```
class PostListTile extends StatelessWidget {
  const PostListTile({
    super.key,
    required this.post,
    this.onTap,
    this.enableHeroTransition = false,
    this.showProfile = true,
  });

  /// 표시할 게시글 데이터
  final Post post;

  /// 탭 시 실행할 콜백
  final VoidCallback? onTap;

  /// Hero 애니메이션 활성화 여부
  final bool enableHeroTransition;

  /// 작성자 프로필 표시 여부
  final bool showProfile;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12), // Match card radius for ripple
      child: PostListTileItem(
        post: post,
        enableHeroTransition: enableHeroTransition,
        showProfile: showProfile,
      ),
    );
  }
}
