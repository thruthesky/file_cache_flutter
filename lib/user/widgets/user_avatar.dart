import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 사용자 아바타 위젯
///
/// [photoUrl]이 유효한 http(s) URL이면 CachedNetworkImage로 표시하고,
/// 그렇지 않으면 FontAwesome 사용자 아이콘을 표시한다.
class UserAvatar extends StatelessWidget {
  final String photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    this.photoUrl = '',
    this.radius = 16,
  });

  bool get _isValidUrl {
    if (photoUrl.isEmpty || photoUrl.trim().isEmpty) return false;
    if (photoUrl.toLowerCase() == 'null') return false;
    return photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = radius * 2;

    Widget fallback = CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: FaIcon(
        FontAwesomeIcons.lightUser,
        size: radius * 0.9,
        color: scheme.onPrimaryContainer,
      ),
    );

    if (!_isValidUrl) return fallback;

    return CachedNetworkImage(
      imageUrl: photoUrl,
      memCacheWidth: size.toInt() * 2,
      memCacheHeight: size.toInt() * 2,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      imageBuilder: (_, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: scheme.primaryContainer,
        backgroundImage: imageProvider,
      ),
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}
