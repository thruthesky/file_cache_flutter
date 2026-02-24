import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/widgets/post_view_option_menu.dart';
import 'package:philgo_api/philgo_api.dart';
import 'package:share_plus/share_plus.dart';

/// 게시글 상세 화면 AppBar 위젯
/// Post view screen AppBar widget
///
/// 게시글 상세 화면에서 사용되는 AppBar입니다.
/// 뒤로가기 버튼과 더보기 메뉴 버튼을 포함합니다.
///
/// Provides back button and option menu for post view screen.
class PostViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostViewAppBar({
    super.key,
    required this.post,
    required this.onTapReply,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
  });

  /// 게시글 객체
  /// Post object
  final Post post;

  /// 답글 버튼 탭 시 호출되는 콜백
  /// Callback when reply button is tapped
  final VoidCallback onTapReply;

  /// 수정 완료 시 호출되는 콜백
  /// Callback when edit is completed
  final void Function(Post updated) onEditCompleted;

  /// 삭제 완료 시 호출되는 콜백
  /// Callback when delete is completed
  final void Function(BuildContext context) onDeleteCompleted;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  /// Share the post URL via OS native share sheet
  /// 게시글의 필고 URL을 OS 네이티브 공유 시트로 공유합니다.
  ///
  /// URL format: https://philgo.com/post/view.php?idx={idx}&post_id={post_id}
  /// iPad에서는 sharePositionOrigin을 설정하여 팝오버 위치를 지정합니다.
  Future<void> _sharePost(BuildContext context) async {
    try {
      final postUrl =
          'https://philgo.com/post/view.php?idx=${post.idx}&post_id=${post.post_id}';

      final box = context.findRenderObject() as RenderBox?;
      final origin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await SharePlus.instance.share(
        ShareParams(
          text: '${post.subject}\n$postUrl',
          subject: post.subject,
          sharePositionOrigin: origin,
        ),
      );
    } catch (e) {
      debugPrint('Error sharing post: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      leading: BackButton(
        onPressed: () => Navigator.of(context).canPop()
            ? Navigator.of(context).pop()
            : context.go(HomeScreen.routeName),
      ),
      actions: [
        /// Share button - share the post URL via OS native share sheet
        /// 공유 버튼 - OS 네이티브 공유 시트를 통해 게시글 URL 공유
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _sharePost(context),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: FaIcon(
                FontAwesomeIcons.shareNodes,
                size: 16,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),

        /// 점세개 옵션 메뉴 버튼
        /// Three-dot option menu button
        PostViewOptionMenu(
          padding: EdgeInsets.zero,
          post: post,
          firebaseUid: post.firebase_uid,
          onTapReply: onTapReply,
          onEditCompleted: onEditCompleted,
          onDeleteCompleted: onDeleteCompleted,
        ),
        const SizedBox(width: 8),

        /// 닫기 버튼 - 이전 화면으로 돌아가기
        /// Close button - navigate back to previous screen
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => Navigator.of(context).canPop()
                ? Navigator.of(context).pop()
                : context.go(HomeScreen.routeName),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: FaIcon(
                FontAwesomeIcons.xmark,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: scheme.outlineVariant),
      ),
    );
  }
}
