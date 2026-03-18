import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

class UserPhoto extends StatelessWidget {
  const UserPhoto({super.key, this.builder});

  final Widget Function(BuildContext context, User user)? builder;

  @override
  Widget build(BuildContext context) {
    return UserReady(
      login: (context, user) {
        if (builder != null) {
          return builder!(context, user);
        }

        final hasPhoto = user.photoUrl?.isNotEmpty == true;
        return CircleAvatar(
          backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
          child: hasPhoto ? null : const Icon(Icons.person),
        );
      },
    );
  }
}
