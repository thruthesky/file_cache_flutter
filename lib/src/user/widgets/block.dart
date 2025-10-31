import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

// No state managemer.
// rxdart.
class Blocked extends StatefulWidget {
  const Blocked({
    super.key,
    required this.otherUserUid,
    required this.yes,
    required this.no,
  });

  final String otherUserUid;
  final Widget Function() yes;
  final Widget Function() no;

  @override
  State<Blocked> createState() => _BlockedState();
}

class _BlockedState extends State<Blocked> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<String>>(
      valueListenable: UserService.instance.blockedUsersStream,
      builder: (context, blockedUsers, child) {
        final isBlocked = blockedUsers.contains(widget.otherUserUid);
        return isBlocked ? widget.yes() : widget.no();
      },
    );
  }
}
