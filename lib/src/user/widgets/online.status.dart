import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OnlineStatus extends StatefulWidget {
  const OnlineStatus({
    super.key,
    required this.uid,
    this.yes,
    this.no,
    this.loading,
  });

  final String uid;
  final Widget? yes;
  final Widget? no;
  final Widget? loading;

  @override
  State<OnlineStatus> createState() => _OnlineStatusState();
}

class _OnlineStatusState extends State<OnlineStatus> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref('status/${widget.uid}').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loading ?? const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final statusData = snapshot.data?.snapshot.value as Map?;
        // final state = statusData?['state'] as String?;

        final connections = statusData?['connections'] as Map?;

        if (connections == null || connections.isEmpty) {
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
