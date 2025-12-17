import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/widgets/post_options_menu.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 상세 화면 AppBar 위젯
///
/// 게시글 상세 화면에서 사용되는 AppBar입니다.
/// 뒤로가기 버튼과 더보기 메뉴 버튼을 포함합니다.
class PostViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostViewAppBar({
    super.key,
    required this.isPostMine,
    required this.post,
    required this.firebaseUid,
    required this.onReplyTap,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
  });

  final bool isPostMine;
  final Post post;
  final String firebaseUid;
  final VoidCallback onReplyTap;
  final void Function(Post updated) onEditCompleted;
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
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: PostOptionsMenu(
            isPostMine: isPostMine,
            post: post,
            firebaseUid: firebaseUid,
            onReplyTap: onReplyTap,
            onEditCompleted: onEditCompleted,
            onDeleteCompleted: onDeleteCompleted,
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
