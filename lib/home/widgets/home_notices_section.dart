import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/post/post.model.dart';
import 'package:philgo/post/post.service.dart';
import 'package:philgo/post/view/post.view.screen.dart';

/// 홈 공지사항 섹션 - 최신 공지를 표시
///
/// caution 게시판에서 최신 공지 3개를 가져와 표시한다.
class HomeNoticesSection extends StatefulWidget {
  const HomeNoticesSection({super.key});

  @override
  State<HomeNoticesSection> createState() => _HomeNoticesSectionState();
}

class _HomeNoticesSectionState extends State<HomeNoticesSection> {
  List<Post> _notices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotices();
  }

  Future<void> _loadNotices() async {
    try {
      final result = await PostService.list(
        postId: 'caution',
        limit: 3,
      );
      if (!mounted) return;
      setState(() {
        _notices = result.posts;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _notices.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.bullhorn,
                  size: 13,
                  color: color.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  // "Notices"
                  '공지사항'.tr(),
                  style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ..._notices.map(_buildNoticeTile),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeTile(Post post) {
    return InkWell(
      onTap: () => PostViewScreen.push(context, post),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            FaIcon(
              FontAwesomeIcons.circleExclamation,
              size: 10,
              color: color.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                post.subject,
                style: text.bodySmall?.copyWith(color: color.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
