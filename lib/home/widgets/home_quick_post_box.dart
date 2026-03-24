import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/create/post.create.screen.dart';
import 'package:philgo/post/post_category_bottom_sheet.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 홈 화면 빠른 글쓰기 박스 위젯
///
/// 클릭하면 게시판 선택 바텀시트를 표시하고,
/// 카테고리 선택 후 글 작성 화면으로 이동합니다.
///
/// 사용 예시:
/// ```dart
/// const HomeQuickPostBox()
/// ```
class HomeQuickPostBox extends StatelessWidget {
  const HomeQuickPostBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.outlineVariant, width: 1.5),
            borderRadius: BorderRadius.circular(24),
            color: color.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              /// 카메라 아이콘
              FaIcon(
                FontAwesomeIcons.lightCamera,
                size: 18,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: 10),

              /// 가짜 입력 텍스트
              Expanded(
                child: Text(
                  // "How is your life in the Philippines today?"
                  '오늘, 당신의 필리핀 생활은 어떤가요?'.tr(),
                  style: text.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),

              /// 전송 아이콘
              FaIcon(
                FontAwesomeIcons.lightPaperPlaneTop,
                size: 18,
                color: color.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    /// 로그인 확인
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      // "Login required"
      ).showSnackBar(SnackBar(content: Text('로그인이 필요합니다'.tr())));
      return;
    }

    /// 게시판 선택 바텀시트 표시
    showPostCategoryBottomSheet(
      context,
      onSelected: (postId, category) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PostCreateScreen(
              postId: postId,
              category: category,
            ),
          ),
        );
      },
    );
  }
}
