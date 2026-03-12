import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/post/list/widgets/display_thumbnail.dart';
import 'package:philgo/post/post.model.dart';

/// 게시글 리스트 타일
class PostListTile extends StatelessWidget {
  final Post post;
  final ThemeData theme;
  final ColorScheme scheme;
  final VoidCallback onTap;

  const PostListTile({
    super.key,
    required this.post,
    required this.theme,
    required this.scheme,
    required this.onTap,
  });

  /// Determine the best URL to use for the preview thumbnail
  String? get _previewUrl {
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
      return post.imageUrl;
    if (post.videoUrl != null && post.videoUrl!.isNotEmpty)
      return post.videoUrl;
    if (post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty)
      return post.thumbnail400x400;
    if (post.files.isNotEmpty) {
      return post.files.split(',').map((e) => e.trim()).firstWhere(
        (e) => e.isNotEmpty,
        orElse: () => '',
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = _previewUrl;

    // 카드 배경: primaryContainer (연한 파란색 계열)
    // 텍스트/아이콘: onPrimaryContainer (진한 파란색, 가독성 높음)
    // 보조 텍스트/아이콘: tertiary (보조 강조색)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        post.subject,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // 날짜
                      Text(
                        _formatDate(post.stamp),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.tertiary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 통계 (조회수, 댓글, 좋아요)
                      Row(
                        children: [
                          // 조회수: 10 이상일 때만 표시
                          if (post.noOfView >= 10) ...[
                            FaIcon(
                              FontAwesomeIcons.lightEye,
                              size: 12,
                              color: scheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.noOfView}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                              ),
                            ),
                          ],
                          // 댓글수: 1 이상일 때만 표시
                          if (post.noOfComment > 0) ...[
                            if (post.noOfView >= 10) const SizedBox(width: 12),
                            FaIcon(
                              FontAwesomeIcons.lightComment,
                              size: 12,
                              color: scheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.noOfComment}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                              ),
                            ),
                          ],
                          // 좋아요: 1 이상일 때만 표시
                          if (post.good > 0) ...[
                            if (post.noOfView >= 10 || post.noOfComment > 0)
                              const SizedBox(width: 12),
                            FaIcon(
                              FontAwesomeIcons.lightThumbsUp,
                              size: 12,
                              color: scheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post.good}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.tertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // 썸네일 미리보기
                if (previewUrl != null) ...[
                  const SizedBox(width: 12),
                  DisplayThumbnail(url: previewUrl, size: 72),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Unix timestamp → 상대 시간 또는 날짜 문자열
  String _formatDate(int stamp) {
    if (stamp == 0) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(stamp * 1000);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 365) return '${date.month}/${date.day}';
    return '${date.year}/${date.month}/${date.day}';
  }
}
