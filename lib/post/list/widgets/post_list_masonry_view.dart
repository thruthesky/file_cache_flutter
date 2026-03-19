import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:philgo/common_widgets/app_masonry_grid.dart';
import 'package:philgo/common_widgets/masonry_image_card.dart';
import 'package:philgo/post/post.model.dart';

/// 게시글 Masonry 뷰 (회원장터 등에서 사용)
///
/// [AppMasonryGrid]와 [MasonryImageCard]를 사용하여 게시글을 Masonry 레이아웃으로 표시한다.
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
        return MasonryImageCard(
          imageUrl: _getImageUrl(post),
          title: post.subject,
          onTap: () => onPostTap(post),
        );
      },
    );
  }

  /// 게시글에서 이미지 URL을 추출한다.
  /// thumbnail800 > imageUrl > thumbnail400 > files 첫 번째 순서로 우선순위.
  String? _getImageUrl(Post post) {
    if (post.thumbnail800x800 != null && post.thumbnail800x800!.isNotEmpty) {
      return post.thumbnail800x800;
    }
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      return post.imageUrl;
    }
    if (post.thumbnail400x400 != null && post.thumbnail400x400!.isNotEmpty) {
      return post.thumbnail400x400;
    }
    if (post.files.isNotEmpty) {
      final first = post.files
          .split(',')
          .map((e) => e.trim())
          .firstWhere((e) => e.isNotEmpty, orElse: () => '');
      if (first.isNotEmpty) return first;
    }
    return null;
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
