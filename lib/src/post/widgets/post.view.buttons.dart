import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class PostViewButtons extends StatelessWidget {
  const PostViewButtons({
    super.key,
    required this.post,
    required this.onTapUpdate,
  });

  final Post? post;
  final VoidCallback onTapUpdate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 좋아요 버튼 - TextButton.icon으로 Flat 디자인 구현
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            // 좋아요 기능 구현 예정
          },
          icon: const FaIcon(FontAwesomeIcons.thumbsUp, size: 16),
          label: Text(LibTr.of(context)!.like),
        ),
        // SizedBox(width: 4),
        // ElevatedButton.icon(
        //   style: ElevatedButton.styleFrom(
        //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   ),
        //   onPressed: () {
        //     // Implement comment functionality
        //   },
        //   icon: const FaIcon(FontAwesomeIcons.comment, size: 16),
        //   label: Text(
        //     LibTr.of(context)!.comment,
        //     style: Theme.of(context).textTheme.bodyMedium,
        //   ),
        // ),
        SizedBox(width: 8),
        // 공유 버튼 - TextButton.icon으로 Flat 디자인 구현
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            // 공유 기능 구현 예정
          },
          icon: const FaIcon(FontAwesomeIcons.share, size: 16),
          label: Text(LibTr.of(context)!.share),
        ),
        Spacer(),
        // 수정 버튼 - TextButton.icon으로 Flat 디자인 구현
        TextButton.icon(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onTapUpdate,
          icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
          label: Text(LibTr.of(context)!.edit),
        ),
      ],
    );
  }
}
