import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_v6_flutter.dart';

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

  // PINNED CHAT ROOMS
  StreamSubscription<DatabaseEvent>? pinnedChatRoomsSubscription;
  final Set<String> pinnedChatRooms = <String>{};
  final pinnedChatRoomsStream = ValueNotifier<Set<String>>(<String>{});

  // FAVORITE FOLDER
  StreamSubscription<DatabaseEvent>? favoriteFoldersSubscription;
  final List<Map<String, dynamic>> favoriteFolders = [];
  final favoriteFoldersStream = ValueNotifier<List<Map<String, dynamic>>>([]);

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

    initAuthStateChanges();

    initAdminUser();
  }

  void initAuthStateChanges() {
    auth.authStateChanges().listen((fa.User? user) {
      // User is signed in
      // log('User signed in: ${user?.uid}');
      initPinnedChatRooms(user);
      initFavoriteFolders(user);
      initBlockedUsers(user);
      initCountUnreadMessage(user);
    });
  }

  /// Initialize admin user by fetching from philgo API
  /// This sets the adminUserUid variable
  /// This will be used in chat room and other places
  Future<void> initAdminUser() async {
    // Get admin user uid from philgo API
    adminUserUid = await philgoApiGetAdminUserUid();
  }

  void initCountUnreadMessage(fa.User? user) {
    if (user != null) {
      countUnreadMessages(user);
    } else {
      unreadSingleCount = 0;
    }
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

  void initBlockedUsers(fa.User? user) {
    if (user != null) {
      blockedUsersSubscription?.cancel();
      final blockedUsersRef = userPrivateBlocksRef(user.uid);
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
  }

  void countUnreadMessages(fa.User user) async {
    unreadCountSubscription?.cancel();
    final unreadCountRef = userChatUnreadCountRef(user.uid);
    unreadCountSubscription = unreadCountRef.onValue.listen(
      (event) {
        // log(event.snapshot.value.toString(), name: "event.snapshot.value::");
        if (event.snapshot.exists && event.snapshot.value != null) {
          final count = event.snapshot.value as int;
          unreadCountStream.value = count;
          unreadSingleCountStream.value = count;
        } else {
          unreadCountStream.value = 0;
          unreadSingleCountStream.value = 0;
        }
      },
      onError: (error) {
        log('-----> Failed to load unread_count: $error');
      },
    );
  }

  void initPinnedChatRooms(fa.User? user) {
    if (user != null) {
      pinnedChatRoomsSubscription?.cancel();
      final pinnedChatRoomsRef = userPinnedChatRoomsRef(user.uid);
      pinnedChatRoomsSubscription = pinnedChatRoomsRef.onValue.listen(
        (event) {
          pinnedChatRooms.clear();

          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            // debugPrint('pinnedChatRoomsRef:: ${data.toString()}');
            data.forEach((key, value) {
              if (value == true) {
                pinnedChatRooms.add(key.toString());
              }
            });
          }
          // debugPrint('pinnedChatRooms:: ${pinnedChatRooms.toString()}');
          pinnedChatRoomsStream.value = {...pinnedChatRooms};
        },
        onError: (error) {
          log('-----> Failed to load pinnedChatRooms: $error');
        },
      );
    } else {
      pinnedChatRooms.clear();
      pinnedChatRoomsSubscription?.cancel();
    }
  }

  void initFavoriteFolders(fa.User? user) {
    if (user != null) {
      favoriteFoldersSubscription?.cancel();
      final favoriteFoldersRef = chatFavoritesFolderListRef(user.uid);
      favoriteFoldersSubscription = favoriteFoldersRef.onValue.listen(
        (event) {
          favoriteFolders.clear();

          if (event.snapshot.exists && event.snapshot.value != null) {
            final data = event.snapshot.value as Map<dynamic, dynamic>;
            // debugPrint('favoriteFoldersRef::data: ${data.toString()}');

            data.forEach((key, value) {
              favoriteFolders.add({
                'folderName': key.toString(),
                'countFavorites': value,
              });
            });
          }
          if (favoriteFolders.isEmpty) {
            favoriteFolders.add({'folderName': 'default', 'countFavorites': 0});
          }
          // debugPrint(
          //   'favoriteFoldersRef::favoriteFolders: ${favoriteFolders.toString()}',
          // );
          favoriteFoldersStream.value = [...favoriteFolders];
        },
        onError: (error) {
          log('-----> Failed to load favoriteFoldersRef: $error');
        },
      );
    } else {
      favoriteFolders.clear();
      favoriteFoldersSubscription?.cancel();
    }
  }
}
