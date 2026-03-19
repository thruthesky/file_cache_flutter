import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/common_widgets/youtube_thumbnail.dart';
import 'package:philgo/post/list/widgets/display_thumbnail.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/widgets/block.dart';
import 'package:philgo/router.dart';
import 'package:philgo/user/widgets/user_avatar.dart';
import 'package:philgo/util/util.functions.dart';

/// 게시글 리스트 타일
class PostListTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const PostListTile({
    super.key,
    required this.post,
    required this.onTap,
  });

  /// Determine the best URL to use for the preview thumbnail
  String? get _previewUrl {
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return post.imageUrl;
    }
    if (post.videoUrl != null && post.videoUrl!.isNotEmpty) {
      return post.videoUrl;
    }
    if (post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty) {
      return post.thumbnail400x400;
    }
    if (post.files.isNotEmpty) {
      return post.files
          .split(',')
          .map((e) => e.trim())
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Firebase 실시간 차단 상태 반영 (채팅 등에서 차단 시 즉시 반영)
    if (post.userFirebaseUid.isNotEmpty) {
      return Blocked(
        otherUserUid: post.userFirebaseUid,
        yes: () => _buildBlockedTile(),
        no: () => _buildNormalTile(),
      );
    }

    // userFirebaseUid가 없으면 서버 플래그로 폴백
    if (post.blocked) {
      return _buildBlockedTile();
    }

    return _buildNormalTile();
  }

  Widget _buildNormalTile() {
    final previewUrl = _previewUrl;

    final commentColor = _getCountColor(post.noOfComment);
    final commentBold = post.noOfComment >= 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 썸네일 미리보기 (왼쪽)
                  if (previewUrl != null) ...[
                    DisplayThumbnail(url: previewUrl, size: 72),
                    const SizedBox(width: 12),
                  ] else if (post.isYoutube && post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty) ...[
                    YoutubeThumbnail(youtubeUrl: post.youtubeUrl!, size: 72),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Line 1: 제목 (YouTube 포함 시 아이콘 표시)
                        Row(
                          children: [
                            if (post.isYoutube) ...[
                              const FaIcon(
                                FontAwesomeIcons.youtube,
                                size: 14,
                                color: Color(0xFFFF0000),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Expanded(
                              child: Text(
                                post.subject,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleLarge?.copyWith(
                                  color: color.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Line 2: 아바타 + 이름 + 날짜 + 통계
                        Row(
                          children: [
                            // 아바타
                            UserAvatar(photoUrl: post.userPhotoUrl, radius: 12),
                            const SizedBox(width: 6),
                            // 이름 (길면 잘림)
                            Flexible(
                              flex: 0,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 80),
                                child: Text(
                                  post.userName.isNotEmpty ? post.userName : '이름없음'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.bodySmall?.copyWith(
                                    color: color.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 날짜
                            Text(
                              _formatDate(post.stamp),
                              style: text.bodySmall?.copyWith(
                                color: color.outline,
                              ),
                            ),
                            // 통계
                            if (post.noOfView >= 10) ...[
                              const SizedBox(width: 8),
                              FaIcon(
                                FontAwesomeIcons.lightEye,
                                size: 13,
                                color: color.outline,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${post.noOfView}',
                                style: text.bodySmall?.copyWith(
                                  color: color.outline,
                                ),
                              ),
                            ],
                            if (post.noOfComment > 0) ...[
                              const SizedBox(width: 8),
                              FaIcon(
                                FontAwesomeIcons.lightComment,
                                size: 13,
                                color: commentColor,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${post.noOfComment}',
                                style: text.bodySmall?.copyWith(
                                  color: commentColor,
                                  fontWeight: commentBold
                                      ? FontWeight.w600
                                      : null,
                                ),
                              ),
                            ],
                            if (post.good > 0) ...[
                              const SizedBox(width: 8),
                              FaIcon(
                                FontAwesomeIcons.lightThumbsUp,
                                size: 13,
                                color: color.outline,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${post.good}',
                                style: text.bodySmall?.copyWith(
                                  color: color.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 차단된 사용자의 글 타일 — 탭하면 차단 해제 확인
  Widget _buildBlockedTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Material(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () async {
            final context = globalNavigatorKey.currentContext;
            if (context == null) return;
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('차단 해제'.tr()),
                content: Text(
                  '차단된 사용자입니다. 차단을 해제하고 글을 보시겠습니까?'.tr(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('취소'.tr()),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text('차단 해제'.tr()),
                  ),
                ],
              ),
            );
            if (confirm != true || !context.mounted) return;
            try {
              await toggleBlockUserByIdx(post.idxMember);
              if (context.mounted) {
                showSuccessSnackBar(context, '차단이 해제되었습니다'.tr());
              }
            } catch (e) {
              if (context.mounted) showErrorSnackBar(context, '$e');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 72),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.lightBan,
                    size: 16,
                    color: color.outline,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '차단된 사용자의 글입니다'.tr(),
                      style: text.bodyMedium?.copyWith(
                        color: color.outline,
                      ),
                    ),
                  ),
                  FaIcon(
                    FontAwesomeIcons.lightCircleXmark,
                    size: 14,
                    color: color.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 댓글 수에 따른 색상 반환
  Color _getCountColor(int count) {
    if (count >= 10) return color.error;
    if (count >= 5) return Colors.amber.shade700;
    return color.tertiary;
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
