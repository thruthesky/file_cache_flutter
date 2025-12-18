import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/widgets/post_view_option_menu.dart';
import 'package:philgo_api/philgo_api.dart';

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
        PostViewOptionMenu(
          padding: EdgeInsets.only(right: 16),
          post: post,
          firebaseUid: post.firebase_uid,
          onTapReply: onTapReply,
          onEditCompleted: onEditCompleted,
          onDeleteCompleted: onDeleteCompleted,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: scheme.outlineVariant),
      ),
    );
  }
}
