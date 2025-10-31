import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.photoUrl,
    this.size = 40.0,
    this.radius = 25.0,
  });

  final String? photoUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
        child: CircleAvatar(child: Icon(Icons.person, size: size / 1.5)),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius)),
      child: CachedNetworkImage(
        imageUrl: photoUrl ?? '',
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(backgroundImage: imageProvider),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) =>
            CircleAvatar(child: Icon(Icons.person, size: size / 1.5)),
      ),
    );
  }
}
