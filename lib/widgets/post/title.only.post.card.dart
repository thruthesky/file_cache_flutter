import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/screens/post/post.view.screen.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

/// Title-only post card widget showing only title with arrow
/// Features:
/// - Shows post title (max 2 lines)
/// - Shows ">" arrow at the end
/// - Optional category indicator dot
/// - Tappable to view post details
class TitleOnlyPostCard extends StatelessWidget {
  final Post post;
  final bool showCategoryDot;

  const TitleOnlyPostCard({
    super.key,
    required this.post,
    this.showCategoryDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await PostViewScreen.push(context, post);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              /// Post title - max 2 lines (게시물 제목 - 최대 2줄)
              Expanded(
                child: Text(
                  post.subject,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 8),

              /// Arrow icon (화살표 아이콘)
              FaIcon(
                FontAwesomeIcons.lightChevronRight,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
