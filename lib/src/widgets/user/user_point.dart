import 'package:flutter/material.dart';
import 'package:philgo_api/src/widgets/user/user_ready.dart';

class UserPoint extends StatelessWidget {
  const UserPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return UserReady(
      builder: (context, user) => Text(user.point?.toString() ?? '0'),
    );
  }
}
