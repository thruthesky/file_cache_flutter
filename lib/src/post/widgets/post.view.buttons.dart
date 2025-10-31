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
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            // Implement like functionality
          },
          icon: const FaIcon(FontAwesomeIcons.thumbsUp, size: 16),
          label: Text(
            LibTr.of(context)!.like,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
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
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: () {
            // Implement share functionality
          },
          icon: const FaIcon(FontAwesomeIcons.share, size: 16),
          label: Text(
            LibTr.of(context)!.share,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Spacer(),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          onPressed: onTapUpdate,
          icon: const FaIcon(FontAwesomeIcons.penToSquare, size: 16),
          label: Text(
            LibTr.of(context)!.edit,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
