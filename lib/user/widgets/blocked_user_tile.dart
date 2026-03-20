import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/blocked_user.model.dart';
import 'package:philgo/user/widgets/user_avatar.dart';

class BlockedUserTile extends StatelessWidget {
  final BlockedUserModel user;
  final VoidCallback onUnblock;

  const BlockedUserTile({
    super.key,
    required this.user,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          UserAvatar(photoUrl: user.photoUrl, radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.nickname.isNotEmpty ? user.nickname : '이름없음'.tr(),
              style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton.icon(
            onPressed: onUnblock,
            icon: FaIcon(
              FontAwesomeIcons.lightBan,
              size: 14,
              color: color.error,
            ),
            label: Text(
              '차단 해제'.tr(),
              style: TextStyle(color: color.error, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
