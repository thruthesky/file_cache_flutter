import 'package:flutter/material.dart';
import 'package:philgo_api/src/widgets/user/user_ready.dart';

class UserPoint extends StatelessWidget {
  const UserPoint({super.key, this.builder});

  final Widget Function(int points)? builder;

  @override
  Widget build(BuildContext context) {
    return UserReady(
      builder: (context, user) {
        final points = user.point ?? 0;
        if (builder != null) {
          return builder!(points);
        }
        return Text(points.toString());
      },
    );
  }
}
