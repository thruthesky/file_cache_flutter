import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo/globals.dart';

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

  /// Builder called when user is offline and a lastSeen timestamp exists.
  /// The [lastSeen] is a millisecond epoch timestamp from Firebase.
  final Widget Function(int lastSeen)? lastSeenBuilder;

  @override
  State<OnlineStatus> createState() => _OnlineStatusState();
}

class _OnlineStatusState extends State<OnlineStatus> {
  bool _online = false;
  int? _lastSeen;
  bool _loaded = false;

  StreamSubscription? _onlineSub;
  StreamSubscription? _lastSeenSub;

  @override
  void initState() {
    super.initState();
    _startListeners();
  }

  @override
  void dispose() {
    _stopListeners();
    super.dispose();
  }

  /// Listen to users/{uid}/online and users/{uid}/lastSeen separately,
  /// matching the web startPresenceListener pattern.
  void _startListeners() {
    final db = FirebaseDatabase.instance;

    _onlineSub = db.ref('users/${widget.uid}/online').onValue.listen((event) {
      setState(() {
        _online = event.snapshot.value == true;
        _loaded = true;
      });
    });

    _lastSeenSub =
        db.ref('users/${widget.uid}/lastSeen').onValue.listen((event) {
      setState(() {
        final val = event.snapshot.value;
        _lastSeen = val is int ? val : null;
      });
    });
  }

  void _stopListeners() {
    _onlineSub?.cancel();
    _onlineSub = null;
    _lastSeenSub?.cancel();
    _lastSeenSub = null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return widget.loading ?? const SizedBox.shrink();
    }

    if (_online) {
      return widget.yes ??
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(
                color: color.surface,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
          );
    }

    if (widget.lastSeenBuilder != null && _lastSeen != null) {
      return widget.lastSeenBuilder!(_lastSeen!);
    }

    return widget.no ?? const SizedBox.shrink();
  }
}
