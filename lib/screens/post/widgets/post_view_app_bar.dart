import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:philgo/screens/home/home.screen.dart';
import 'package:philgo/screens/post/widgets/post_options_bottom_sheet.dart';
import 'package:philgo_api/philgo_api.dart';

/// 게시글 상세 화면 AppBar 위젯
///
/// 게시글 상세 화면에서 사용되는 AppBar입니다.
/// 뒤로가기 버튼과 더보기 메뉴 버튼을 포함합니다.
/// 더보기 메뉴 버튼 클릭 시 PostOptionsBottomSheet를 표시합니다.
///
/// ### 매개변수:
/// - [isPostMine] → 본인 게시글인지 여부
/// - [post] → 게시글 객체
/// - [firebaseUid] → 작성자 Firebase UID
/// - [onReplyTap] → 답글 버튼 클릭 콜백
/// - [onEditCompleted] → 수정 완료 콜백
/// - [onDeleteCompleted] → 삭제 완료 콜백
///
/// ### 예시:
/// ```dart
/// PostViewAppBar(
///   isPostMine: true,
///   post: post,
///   firebaseUid: 'abc123',
///   onReplyTap: () { /* 답글 입력창 포커스 */ },
///   onEditCompleted: (updated) { /* 수정된 게시글 처리 */ },
///   onDeleteCompleted: () { /* 삭제 후 처리 */ },
/// )
/// ```
class PostViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 본인 게시글인지 여부
  final bool isPostMine;

  /// 게시글 객체
  final Post post;

  /// 작성자 Firebase UID
  final String firebaseUid;

  /// 답글 버튼 클릭 콜백
  final VoidCallback onReplyTap;

  /// 수정 완료 콜백
  final void Function(Post updated) onEditCompleted;

  /// 삭제 완료 콜백
  final VoidCallback onDeleteCompleted;

  const PostViewAppBar({
    super.key,
    required this.isPostMine,
    required this.post,
    required this.firebaseUid,
    required this.onReplyTap,
    required this.onEditCompleted,
    required this.onDeleteCompleted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  /// 게시글 옵션 바텀 시트 표시
  ///
  /// PostOptionsBottomSheet 위젯을 사용하여 게시글 옵션 바텀 시트를 표시합니다.
  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (sheetContext) {
        return PostOptionsBottomSheet(
          isPostMine: isPostMine,
          post: post,
          firebaseUid: firebaseUid,
          onReplyTap: onReplyTap,
          onEditCompleted: onEditCompleted,
          onDeleteCompleted: onDeleteCompleted,
        );
      },
    );
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
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            icon: FaIcon(FontAwesomeIcons.bars, size: 20),
            onPressed: () => _showPostOptions(context),
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
