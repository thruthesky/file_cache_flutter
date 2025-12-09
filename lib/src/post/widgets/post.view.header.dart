import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo_api/philgo_api.dart';

class PostViewHeader extends StatelessWidget {
  const PostViewHeader({
    super.key,
    required this.subject,
    required this.nickname,
    required this.stamp,
    required this.noOfView,
    this.photoUrl,
    this.onTapNickname,
  });

  final String subject;
  final String nickname;
  final int stamp;
  final String noOfView;

  final String? photoUrl;

  /// Callback function to run when nickname clicks (go to profile screen)
  final VoidCallback? onTapNickname;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subject,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 프로필 이미지 또는 기본 아이콘
                GestureDetector(
                  onTap: onTapNickname,
                  child: Row(
                    children: [
                      photoUrl != null && photoUrl!.isNotEmpty
                          ? CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(photoUrl!),
                              backgroundColor: Colors.grey[300],
                            )
                          : FaIcon(
                              FontAwesomeIcons.lightUser,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                      const SizedBox(width: 8),
                      Text(
                        cut(nickname, 15),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            FaIcon(
              FontAwesomeIcons.lightClock,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              formatDateTime(stamp * 1000),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            FaIcon(
              FontAwesomeIcons.lightEye,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              noOfView,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
