import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.size,
    this.padding,
    this.alignment = Alignment.center,
  });
  final User user;
  final double size;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      child: Avatar(
        size: size,
        radius: 75.0,
        photoUrl: user.photoUrl ?? '',
      ),
    );
  }
}
