import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 사용자 아바타 위젯
///
/// [photoUrl]이 있으면 네트워크 이미지를, 없으면 FontAwesome 사용자 아이콘을 표시한다.
class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    this.photoUrl = '',
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: FaIcon(
        FontAwesomeIcons.lightUser,
        size: radius * 0.9,
        color: scheme.onPrimaryContainer,
      ),
    );
  }
}
