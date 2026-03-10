import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:philgo/messaging/messaging.defines.dart';
import 'package:philgo/user/widgets/login.dart';
import 'package:philgo/util/util.functions.dart';

/// PushNotificationIcon widget for toggling notifications in chat rooms
class PushNotificationIcon extends StatefulWidget {
  final String subscriptionId;
  final bool reverse;

  const PushNotificationIcon({
    super.key,
    required this.subscriptionId,
    this.reverse = false,
  });

  @override
  State<PushNotificationIcon> createState() => _PushNotificationIconState();
}

class _PushNotificationIconState extends State<PushNotificationIcon> {
  Future<void> toggleNotification(bool isSubscribed) async {
    debugLog('Toggling notification. Currently subscribed: $isSubscribed');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final ref = FirebaseDatabase.instance.ref(
        '${MessagingConfig.subscribePath}/${widget.subscriptionId}/$uid',
      );

      if (widget.reverse) {
        // Reverse logic for chat rooms:
        // When _isSubscribed = true (notifications ON), we want to turn OFF -> set true in DB
        // When _isSubscribed = false (notifications OFF), we want to turn ON -> remove from DB
        if (isSubscribed) {
          // Turn off notifications - set true in database
          await ref.set(true);
        } else {
          // Turn on notifications - remove from database
          await ref.remove();
        }
      } else {
        // Normal logic:
        // When _isSubscribed = true, we want to turn OFF -> remove from DB
        // When _isSubscribed = false, we want to turn ON -> set true in DB
        if (isSubscribed) {
          // Turn off notifications - remove from database
          await ref.remove();
        } else {
          // Turn on notifications - set true in database
          await ref.set(true);
        }
      }
    } catch (e) {
      debugPrint('Error toggling notification: $e');
      if (mounted) {
        showErrorSnackBar(context, "Error: ${e.toString()}");
      }
    }
  }

  Widget OnIcon() {
    return Icon(Icons.notifications, color: Colors.blue);
  }

  Widget OffIconIcon() {
    return Icon(Icons.notifications_off, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Login(
      builder: (uid) => StreamBuilder(
        stream: FirebaseDatabase.instance
            .ref(
              '${MessagingConfig.subscribePath}/${widget.subscriptionId}/$uid',
            )
            .onValue,
        builder: (context, event) {
          // Show loading indicator only on initial load (no data yet)
          // Don't show loading on rebuilds when we already have data
          if (event.connectionState == ConnectionState.waiting &&
              !event.hasData) {
            return const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            );
          }

          if (event.hasError) {
            debugLog('snapshot error: ${event.error}');
            return OffIconIcon();
          }

          bool isSubscribed;
          if (widget.reverse) {
            // Reverse logic: `true` if  data not exist or data not equal to true otherwise `false`
            isSubscribed =
                (event.data == null || event.data!.snapshot.value != true);
          } else {
            // Normal logic: true = notifications ON, false/null = notifications OFF
            isSubscribed =
                event.data != null && event.data!.snapshot.value == true;
          }

          return IconButton(
            onPressed: () => toggleNotification(isSubscribed),
            icon: isSubscribed ? OnIcon() : OffIconIcon(),
            tooltip: isSubscribed
                ? "Turn off notifications"
                : "Turn on notifications",
          );
        },
      ),
      notLoggedIn: OffIconIcon(),
    );
  }
}
