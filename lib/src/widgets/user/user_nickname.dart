import 'package:flutter/material.dart';
import 'package:philgo_api/src/widgets/user/user_ready.dart';

class UserNickname extends StatelessWidget {
  const UserNickname({super.key, this.builder});

  final Widget Function(BuildContext context, String nickname)? builder;

  @override
  Widget build(BuildContext context) {
    return UserReady(
      builder: (context, user) {
        final nickname = user.nickname;
        if (builder != null) {
          return builder!(context, nickname);
        }
        return Text(nickname);
      },
    );
  }
}
