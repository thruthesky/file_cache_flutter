import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:philgo/globals.dart';
import 'package:philgo/user/edit/user.edit.screen.dart';
import 'package:philgo/user/user.state.dart';
import 'package:provider/provider.dart';

/// 홈 헬퍼 메뉴의 프로필 아이템
///
/// 로그인 시 사용자 프로필 사진을 원형으로 표시하고,
/// 비로그인 또는 사진이 없으면 기본 아이콘을 표시한다.
class HomeProfileMenuItem extends StatelessWidget {
  const HomeProfileMenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => UserEditScreen.push(context),
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Selector<UserState, String>(
              selector: (_, state) => state.user?.photoUrl ?? '',
              builder: (context, photoUrl, _) => _buildAvatar(photoUrl),
            ),
            const SizedBox(height: 3),
            Text(
              '내 정보'.tr(),
              style: text.labelSmall?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String photoUrl) {
    const double size = 44;
    const double iconSize = 18;
    const iconColor = Color(0xFF5C6BC0);

    final isValid = photoUrl.isNotEmpty &&
        photoUrl.toLowerCase() != 'null' &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'));

    if (!isValid) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.circleUser, size: iconSize, color: iconColor),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: photoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: (size * 2).toInt(),
        memCacheHeight: (size * 2).toInt(),
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholder: (_, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.circleUser, size: iconSize, color: iconColor),
          ),
        ),
        errorWidget: (_, _, _) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: FaIcon(FontAwesomeIcons.circleUser, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
