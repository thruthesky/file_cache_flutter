import 'package:flutter/material.dart';
import 'post_ad_expiry_badge.dart';

/// Decorated section that highlights a point advertisement and its expiry date.
class PostAdInfoBanner extends StatelessWidget {
  const PostAdInfoBanner({super.key, required this.expiryTimestamp});

  final int expiryTimestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          // top: BorderSide(color: scheme.outlineVariant),
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: PostAdExpiryBadge(expiryTimestamp: expiryTimestamp),
      ),
    );
  }
}
