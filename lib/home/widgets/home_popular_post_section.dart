import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/app/app.navigaton.state.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';

/// 홈 인기글 섹션 - 댓글 많은 게시글 표시
///
/// no_of_comment DESC로 정렬하여 인기글을 표시한다.
class HomePopularPostSection extends StatefulWidget {
  const HomePopularPostSection({super.key});

  @override
  State<HomePopularPostSection> createState() => _HomePopularPostSectionState();
}

class _HomePopularPostSectionState extends State<HomePopularPostSection> {
  List<Post> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final result = await PostService.list(
        orderby: 'no_of_comment DESC',
        limit: 5,
      );
      if (!mounted) return;
      setState(() {
        _posts = result.posts;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (_posts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FaIcon(FontAwesomeIcons.fire, size: 14, color: color.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  // "Popular Posts"
                  '인기글'.tr(),
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  AppNavigationState.of(context).openForumScreen();
                },
                child: Text(
                  // "More"
                  '더보기'.tr(),
                  style: text.labelSmall?.copyWith(color: color.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ..._posts.map(_buildPopularPostTile),
        ],
      ),
    );
  }

  Widget _buildPopularPostTile(Post post) {
    return InkWell(
      onTap: () => PostViewScreen.push(context, post),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('• ', style: text.bodySmall?.copyWith(color: color.outline)),
            Expanded(
              child: Text(
                post.subject,
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (post.noOfComment > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 4),
                  FaIcon(
                    FontAwesomeIcons.comment,
                    size: 10,
                    color: post.noOfComment >= 20 ? color.error : color.outline,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${post.noOfComment}',
                    style: text.labelSmall?.copyWith(
                      color:
                          post.noOfComment >= 20 ? color.error : color.outline,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
