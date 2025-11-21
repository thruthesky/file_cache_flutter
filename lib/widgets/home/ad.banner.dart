import 'package:flutter/material.dart';

/// 광고 배너 위젯
///
/// 기능:
/// - 광고 배너를 표시
/// - 추후 실제 광고 시스템과 연동 가능하도록 설계
/// - 현재는 플레이스홀더로 구현
class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 120,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.ad_units,
              size: 40,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Advertisement',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
