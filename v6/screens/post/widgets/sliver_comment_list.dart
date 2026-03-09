import 'package:flutter/material.dart';
import 'package:philgo/screens/user/profile.view.screen.dart';
import 'package:philgo_api/philgo_api.dart';

/// Sliver 기반 댓글 목록 위젯
///
/// CustomScrollView 내에서 사용할 수 있는 Sliver 버전의 댓글 목록입니다.
/// SliverList를 사용하여 댓글을 lazy loading하여 성능을 최적화합니다.
///
/// ### 매개변수:
/// - [post] → 현재 게시글 데이터 (댓글 목록 포함)
/// - [myComment] → 댓글이 내 댓글인지 확인하는 함수
/// - [onReplied] → 답글 작성 완료 시 콜백
/// - [onUpdated] → 댓글 수정 완료 시 콜백
/// - [onDeleted] → 댓글 삭제 완료 시 콜백
/// - [onReplyClicked] → 답글 버튼 클릭 시 콜백
/// - [onEditClicked] → 수정 버튼 클릭 시 콜백
///
/// ### 예시:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     SliverToBoxAdapter(child: PostContent(...)),
///     SliverCommentList(
///       post: post,
///       myComment: (idx) => idx == myIdx,
///       onReplied: (comment) => ...,
///       ...
///     ),
///   ],
/// )
/// ```
class SliverCommentList extends StatelessWidget {
  /// 현재 게시글 데이터 (댓글 목록 포함)
  final Post? post;

  /// 댓글이 내 댓글인지 확인하는 함수
  final bool Function(int idxMember) myComment;

  /// 답글 작성 완료 시 콜백
  final Function(Comment) onReplied;

  /// 댓글 수정 완료 시 콜백
  final Function(Comment, Comment) onUpdated;

  /// 댓글 삭제 완료 시 콜백
  final Function(Comment) onDeleted;

  /// 답글 버튼 클릭 시 콜백
  final Function(Comment) onReplyClicked;

  /// 수정 버튼 클릭 시 콜백
  final Function(Comment) onEditClicked;

  const SliverCommentList({
    super.key,
    required this.post,
    required this.myComment,
    required this.onReplied,
    required this.onUpdated,
    required this.onDeleted,
    required this.onReplyClicked,
    required this.onEditClicked,
  });

  /// 해당 댓글에 답글이 있는지 확인
  bool _hasReplies(Comment comment) {
    return post?.comments.any((c) => c.idx_parent == comment.idx) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final comments = post?.comments ?? [];

    // 댓글이 없는 경우 "첫 댓글 작성" 메시지 표시
    if (comments.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: Text(
              PhilgoTr.of(context)!.beTheFirstToComment,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    // SliverList를 사용하여 댓글을 lazy loading
    // SliverList.builder는 화면에 보이는 댓글만 빌드하여 성능 최적화
    return SliverList.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentDetail(
          onTapProfile: () {
            ProfileViewScreen.push(
              context,
              idxMember: comment.idx_member,
              nickname: comment.nickname,
              photoUrl: comment.photo_url,
            );
          },
          myComment: myComment(comment.idx_member),
          hasReplies: _hasReplies(comment),
          comment: comment,
          onReplied: onReplied,
          onUpdated: (updatedComment) => onUpdated(comment, updatedComment),
          onDeleted: onDeleted,
          onReplyClicked: onReplyClicked,
          onEditClicked: onEditClicked,
        );
      },
    );
  }
}
