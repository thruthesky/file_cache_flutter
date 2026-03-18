import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 게시글 상태 배지 위젯 모음
///
/// 게시글의 상태를 시각적으로 표시하는 배지 위젯들:
/// - [PostNewBadge]: 새 댓글이 있는 게시글 표시 (N)
/// - [PostHotBadge]: 인기 게시글 표시 (HOT) - 댓글 10개 이상

/// 새 댓글 배지 (N)
///
/// 게시글에 새로운 댓글이 있을 때 표시
/// errorContainer 색상으로 주목도 향상
class PostNewBadge extends StatelessWidget {
  const PostNewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'N',
        style: TextStyle(
          fontSize: 10,
          color: scheme.onErrorContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 인기글 배지 (HOT)
///
/// 댓글이 10개 이상인 인기 게시글에 표시
/// secondaryContainer 색상으로 구분
class PostHotBadge extends StatelessWidget {
  const PostHotBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            FontAwesomeIcons.lightFire,
            size: 10,
            color: scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 2),
          Text(
            'HOT',
            style: TextStyle(
              fontSize: 10,
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
