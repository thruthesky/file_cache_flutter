import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PostListErrorIndicator extends StatelessWidget {
  final ColorScheme scheme;
  final VoidCallback onRetry;
  const PostListErrorIndicator({
    super.key,
    required this.scheme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.lightCircleExclamation,
            size: 48,
            color: scheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            // "Failed to load posts"
            '게시글을 불러올 수 없습니다'.tr(),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const FaIcon(
              FontAwesomeIcons.lightArrowRotateRight,
              size: 14,
            ),
            // "Try Again"
            label: Text('다시 시도'.tr()),
          ),
        ],
      ),
    );
  }
}
