import 'package:flutter/material.dart';
import 'package:philgo/extensions/nav.context.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo/widgets/home/home_post_section.dart';

/// 홈 화면 최근 게시글 섹션 위젯 (Home Latest Posts Section Widget)
///
/// 자유게시판과 질문과 답변 게시판의 최근 글을 2단 레이아웃으로 표시합니다.
/// 왼쪽에 자유게시판, 오른쪽에 질문과 답변 섹션이 표시됩니다.
///
/// Displays latest posts from Freetalk and QnA boards in a 2-column layout.
/// Left: Freetalk section, Right: QnA section.
///
/// ### Parameters:
/// - [limit] → 각 게시판에 표시할 게시글 수 (기본값: 4)
///   Number of posts to display per board (default: 4)
///
/// ### Example:
/// ```dart
/// LatestPostsSection(
///   limit: 4,
/// )
/// ```
class LatestPostsSection extends StatelessWidget {
  /// 각 게시판에 표시할 게시글 수 (기본값: 4)
  /// Number of posts to display per board (default: 4)
  final int limit;

  const LatestPostsSection({
    super.key,
    this.limit = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// [자유게시판 섹션] - 최근 글 표시 (왼쪽)
        /// Freetalk Section - Display latest posts (left)
        Expanded(
          child: HomePostSection(
            postId: 'freetalk',
            limit: limit,
            onMoreTap: () {
              context.openForum('freetalk');
            },
            onPostTap: (post) {
              /// PostViewScreen으로 이동
              /// Navigate to PostViewScreen
              PostViewScreen.push(context, post);
            },
          ),
        ),

        /// [질문과 답변 섹션] - 최근 글 표시 (오른쪽)
        /// QnA Section - Display latest posts (right)
        Expanded(
          child: HomePostSection(
            postId: 'qna',
            limit: limit,
            onMoreTap: () {
              context.openForum('qna');
            },
            onPostTap: (post) {
              /// PostViewScreen으로 이동
              /// Navigate to PostViewScreen
              PostViewScreen.push(context, post);
            },
          ),
        ),
      ],
    );
  }
}
