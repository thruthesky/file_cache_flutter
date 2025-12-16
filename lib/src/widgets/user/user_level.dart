import 'package:flutter/material.dart';
import 'package:philgo_api/src/widgets/user/user_ready.dart';

class UserLevel extends StatelessWidget {
  const UserLevel({super.key, required this.builder});

  final Widget Function(String) builder;

  @override
  Widget build(BuildContext context) {
    return UserReady(
      builder: (context, user) => builder(user.level?.toString() ?? ''),
    );
  }
}
