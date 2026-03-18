import 'package:flutter/material.dart';

/// 획득 포인트 뱃지 위젯
///
/// 글 또는 댓글에서 획득한 포인트를 표시하는 작은 뱃지.
/// `point`가 0 이하이면 아무것도 표시하지 않음.
///
/// 사용 예:
/// ```dart
/// EarnedPointBadge(point: 500)
/// ```
class EarnedPointBadge extends StatelessWidget {
  final int point;

  const EarnedPointBadge({super.key, required this.point});

  @override
  Widget build(BuildContext context) {
    if (point <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '+${_formatPoint(point)}P',
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 포인트 숫자 포맷팅
  /// 1000 이상이면 K 단위로 축약
  String _formatPoint(int point) {
    if (point >= 1000) {
      return '${(point / 1000).toStringAsFixed(point % 1000 == 0 ? 0 : 1)}K';
    }
    return point.toString();
  }
}
