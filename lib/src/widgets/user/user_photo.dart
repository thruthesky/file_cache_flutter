import 'package:flutter/material.dart';
import 'package:philgo_api/src/widgets/user/user_ready.dart';

class UserPhoto extends StatelessWidget {
  const UserPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return UserReady(builder: (context, user) => Text(user.photoUrl ?? ''));
  }
}
