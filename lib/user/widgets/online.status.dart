import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineStatus extends StatefulWidget {
  const OnlineStatus({
    super.key,
    required this.uid,
    this.yes,
    this.no,
    this.loading,
    this.lastSeenBuilder,
  });

  final String uid;
  final Widget? yes;
  final Widget? no;
  final Widget? loading;

  /// Builder called when user is offline and a last_changed timestamp exists.
  /// The [lastChanged] is a millisecond epoch timestamp from Firebase.
  final Widget Function(int lastChanged)? lastSeenBuilder;

  @override
  State<OnlineStatus> createState() => _OnlineStatusState();
}

class _OnlineStatusState extends State<OnlineStatus> {
  @override
  Widget build(BuildContext context) {
    // Read from users/{uid} to match web v7ChatSetupPresence pattern
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('users/${widget.uid}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ?? const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final statusData = snapshot.data?.snapshot.value as Map?;
        final isOnline = statusData?['online'] == true;

        if (!isOnline) {
          if (widget.lastSeenBuilder != null) {
            final lastSeen = statusData?['lastSeen'];
            if (lastSeen is int) {
              return widget.lastSeenBuilder!(lastSeen);
            }
          }
          return widget.no ?? const SizedBox.shrink();
        }

        return widget.yes ??
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            );
      },
    );
  }
}
