import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// 재사용 가능한 댓글 카드 위젯
///
/// 기능:
/// - 댓글 내용 표시 (maxLines 설정 가능)
/// - 좋아요 개수 표시
/// - 작성 시간 표시
/// - 부모 게시글로 이동
/// - 애니메이션 효과
class CommentCard extends StatelessWidget {
  /// 댓글 데이터
  final Comment comment;

  /// 애니메이션을 위한 인덱스
  final int index;

  /// 댓글 내용의 최대 줄 수 (기본값: 2)
  final int maxLines;

  /// 고정 높이 사용 여부 (true일 경우 maxLines만큼의 높이를 항상 유지)
  final bool useFixedHeight;

  const CommentCard({
    super.key,
    required this.comment,
    required this.index,
    this.maxLines = 2,
    this.useFixedHeight = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          /// 부모 게시글로 이동 (idx_root 사용)
          if (comment.idx_root > 0) {
            final parentPost = Post.fromJson({'idx': comment.idx_root});
            PostViewScreen.push(context, parentPost);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 댓글 내용
              _buildCommentContent(theme),
              const SizedBox(height: 12),

              /// 하단 정보 (좋아요, 시간)
              Row(
                children: [
                  /// 좋아요 아이콘 및 개수
                  FaIcon(
                    FontAwesomeIcons.lightHeart,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${comment.good}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  /// 작성 시간
                  Text(
                    formatTimestamp(context, comment.stamp * 1000),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(
          begin: -0.1,
          end: 0,
          duration: 300.ms,
          delay: (index * 50).ms,
        );
  }

  /// 댓글 내용 위젯 빌드
  Widget _buildCommentContent(ThemeData theme) {
    final textWidget = Text(
      comment.content,
      style: theme.textTheme.bodyMedium,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );

    /// 고정 높이 사용 시 SizedBox로 감싸서 항상 일정한 높이 유지
    if (useFixedHeight) {
      return SizedBox(
        height: theme.textTheme.bodyMedium!.fontSize! *
            (theme.textTheme.bodyMedium!.height ?? 1.5) *
            maxLines,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
