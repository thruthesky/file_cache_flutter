import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/common_widgets/app_masonry_grid.dart';
import 'package:philgo/common_widgets/masonry_card.dart';
import 'package:philgo/file/file.functions.dart';
import 'package:philgo/post/post.model.dart';

/// 게시글 Masonry 뷰 (회원장터 등에서 사용)
///
/// [AppMasonryGrid]와 [MasonryCard]를 사용하여 게시글을 Masonry 레이아웃으로 표시한다.
/// 미디어 우선순위: YouTube > 동영상 > 이미지 > 제목만(컴팩트)
class PostListMasonryView extends StatelessWidget {
  final PagingController<int, Post> pagingController;
  final void Function(Post) onPostTap;

  const PostListMasonryView({
    super.key,
    required this.pagingController,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppMasonryGrid<Post>(
      pagingController: pagingController,
      itemBuilder: (context, post, index) {
        // 차단된 사용자의 글이면 차단 안내 카드 표시
        if (post.blocked) {
          return _buildBlockedCard(context, scheme, post);
        }
        return MasonryCard(
          title: post.subject,
          youtubeUrl: post.isYoutube ? post.youtubeUrl : null,
          videoUrl: post.videoUrl,
          imageUrl: _getImageUrl(post),
          onTap: () => onPostTap(post),
        );
      },
    );
  }

  /// 게시글에서 이미지 URL을 추출한다.
  /// resolvedThumbnail(600px 썸네일) > imageUrl > files 첫 번째 순서로 우선순위.
  /// 상대 경로(/uploads/...)는 절대 경로로 변환한다.
  String? _getImageUrl(Post post) {
    String? url;
    if (post.resolvedThumbnail != null &&
        post.resolvedThumbnail!.isNotEmpty) {
      url = post.resolvedThumbnail;
    } else if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      url = post.imageUrl;
    } else if (post.files.isNotEmpty) {
      final first = post.files
          .split(',')
          .map((e) => e.trim())
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      if (first.isNotEmpty) url = first;
    }
    return url != null ? toAbsoluteUrl(url) : null;
  }

  Widget _buildBlockedCard(
    BuildContext context,
    ColorScheme scheme,
    Post post,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        onTap: () => onPostTap(post),
        child: SizedBox(
          height: 120,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.lightBan,
                  size: 20,
                  color: scheme.outline,
                ),
                const SizedBox(height: 8),
                Text(
                  '차단된 사용자의 글입니다'.tr(),
                  style: textTheme.bodySmall?.copyWith(color: scheme.outline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
