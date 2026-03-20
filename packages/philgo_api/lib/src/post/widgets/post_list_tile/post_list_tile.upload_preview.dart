import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

/// Post file thumbnail widget (supports images, videos, and files)
class PostListTileUploadPreview extends StatelessWidget {
  const PostListTileUploadPreview({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 81, // 더 큰 이미지 (reference 참고)
      height: 81,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16), // Flat 2.0 - 16 (8의 배수)
        child: DisplayUpload(url: post.files[0], borderRadius: 16),
      ),
    );
  }
}
