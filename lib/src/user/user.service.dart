import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';

class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  final fa.FirebaseAuth auth = fa.FirebaseAuth.instance;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  StreamSubscription<DatabaseEvent>? blockedUsersSubscription;
  final Set<String> blockedUsers = <String>{};
  final blockedUsersStream = ValueNotifier<Set<String>>(<String>{});

  StreamSubscription<DatabaseEvent>? unreadCountSubscription;
  int unreadCount = 0;
  final unreadCountStream = ValueNotifier<int>(0);

  int unreadSingleCount = 0;
  final unreadSingleCountStream = ValueNotifier<int>(0);

  String adminUserUid = 'RaHIcr45pvPzYdcDIv6JoW8DnSH2';

  /// Callback when a user taps on user recent post item
  Function(BuildContext context, Post post)? onTapUserRecentPostItem;
  Function(BuildContext context, User user)? onTapViewProfile;

  UserService._();
  bool initialized = false;

  /// Initialize the UserService
  Future<void> initialize({
    /// Whether to use user presence
    bool useUserPresence = false,
    Function(BuildContext context, Post post)? onTapUserRecentPostItem,
    Function(BuildContext context, User user)? onTapViewProfile,
  }) async {
    if (initialized) return;
    initialized = true;
    this.onTapUserRecentPostItem = onTapUserRecentPostItem;
    this.onTapViewProfile = onTapViewProfile;

    if (useUserPresence) {
      initUserPresence();
    }

    initBlockedUsers();
    initAdminUser();
  }

  /// Initialize admin user by fetching from philgo API
  /// This sets the adminUserUid variable
  /// This will be used in chat room and other places
  void initAdminUser() {
    // Get admin user uid from philgo API
    philgoApiGetAdminUserUid()
        .then((String uid) {
          if (uid.isEmpty) return;
          adminUserUid = uid;
          log('Admin user uid: $adminUserUid');
        })
        .catchError((error) {
          log('Failed to get admin user uid: $error');
        });
  }

  void initUserPresence() {
    late StreamSubscription userSubscription;
    userSubscription = fa.FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        DatabaseReference myConnectionsRef = database.ref(
          "status/${user.uid}/connections",
        );
        DatabaseReference lastOnlineRef = database.ref(
          "status/${user.uid}/last_changed",
        );
        DatabaseReference connectedRef = database.ref('.info/connected');

        connectedRef.onValue.listen((event) {
          if (event.snapshot.value == true) {
            // We're connected (or reconnected)! Do anything here that should happen only if online (or on reconnect)
            DatabaseReference con = myConnectionsRef.push();
            // debugPrint('Connected to Firebase Realtime Database:: ${con.key}');
            // When I disconnect, remove this device
            con.onDisconnect().remove();

            // Add this device to my connections list
            // this value could contain info about the device or a timestamp too
            con.set(true);

            // When I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnect().set(ServerValue.timestamp);
          }
        });

        userSubscription.cancel();
      }
    });
  }

  void initBlockedUsers() {
    auth.authStateChanges().listen((fa.User? user) {
      if (user != null) {
        blockedUsersSubscription?.cancel();
        final blockedUsersRef = database.ref('users/${user.uid}/blocked_users');
        blockedUsersSubscription = blockedUsersRef.onValue.listen(
          (event) {
            blockedUsers.clear();

            if (event.snapshot.exists && event.snapshot.value != null) {
              final data = event.snapshot.value as Map<dynamic, dynamic>;
              data.forEach((key, value) {
                if (value == true) {
                  blockedUsers.add(key.toString());
                }
              });
            }
            // blockedUsersStream.value = blockedUsers;
            blockedUsersStream.value = {...blockedUsers};
            countUnreadMessages(user);
            // log('Blocked users updated: ${blockedUsersStream.value}');
            // log(blockedUsersStream.value.toString());
          },
          onError: (error) {
            log('-----> Failed to load blocked users: $error');
          },
        );
      } else {
        blockedUsers.clear();
        blockedUsersSubscription?.cancel();
        unreadCount = 0;
        unreadSingleCount = 0;
        unreadCountSubscription?.cancel();
      }
    });
  }

  void countUnreadMessages(fa.User user) async {
    unreadCountSubscription?.cancel();
    final unreadCountRef = database.ref('chat/joins/${user.uid}');
    unreadCountSubscription = unreadCountRef.onValue.listen(
      (event) {
        unreadCount = 0;
        unreadSingleCount = 0;
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          data.forEach((key, room) {
            if (room['unread_message_count'] != null) {
              if (room['single_order'] != null) {
                if (blockedUsers.contains(getOtherUserUidFromChatRoomId(key))) {
                  room['unread_message_count'] = 0;
                }
                unreadSingleCount += room['unread_message_count'] as int;
              }

              unreadCount += room['unread_message_count'] as int;
            }
          });
        }

        // blockedUsersStream.value = blockedUsers;
        unreadCountStream.value = unreadCount;
        unreadSingleCountStream.value = unreadSingleCount;
        // log('Unread count updated: ${unreadCountStream.value}');
        // log(unreadCountStream.value.toString());
        // log('Unread single count updated: ${unreadSingleCountStream.value}');
        // log(unreadSingleCountStream.value.toString());
      },
      onError: (error) {
        log('-----> Failed to load unread_message_count: $error');
      },
    );
  }
}
