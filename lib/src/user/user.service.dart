import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:philgo_api/philgo_api.dart';

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

  /// Previous unread count - 이전 읽지 않은 메시지 수
  /// Used to detect new message arrival - 새 메시지 도착 감지를 위해 사용
  int _previousUnreadCount = 0;

  // PINNED CHAT ROOMS
  StreamSubscription<DatabaseEvent>? pinnedChatRoomsSubscription;
  final Set<String> pinnedChatRooms = <String>{};
  final pinnedChatRoomsStream = ValueNotifier<Set<String>>(<String>{});

  // FAVORITE FOLDER
  StreamSubscription<DatabaseEvent>? favoriteFoldersSubscription;
  final List<Map<String, dynamic>> favoriteFolders = [];
  final favoriteFoldersStream = ValueNotifier<List<Map<String, dynamic>>>([]);

  String adminUserUid = PhilgoConfig.chatAdminUid;

  /// Callback when a user taps on user recent post item
  Function(BuildContext context, Post post)? onTapUserRecentPostItem;
  Function(BuildContext context, User user)? onTapViewProfile;

  Function(fa.User? user)? onStateChange;

  /// Callback when new message arrives - 새 메시지 도착 콜백
  /// Called when unread count increases - 읽지 않은 메시지 수가 증가할 때 호출
  Function()? onNewMessageArrived;

  UserService._();
  bool initialized = false;

  /// Initialize the UserService
  Future<void> initialize({
    /// Whether to use user presence
    bool useUserPresence = false,
    Function(BuildContext context, Post post)? onTapUserRecentPostItem,
    Function(BuildContext context, User user)? onTapViewProfile,
    Function(fa.User? user)? onStateChange,
    Function()? onNewMessageArrived,
  }) async {
    if (initialized) return;
    initialized = true;
    this.onTapUserRecentPostItem = onTapUserRecentPostItem;
    this.onTapViewProfile = onTapViewProfile;
    this.onStateChange = onStateChange;
    this.onNewMessageArrived = onNewMessageArrived;

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
      onStateChange?.call(user);
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
      _previousUnreadCount = 0; // Reset on logout - 로그아웃 시 초기화
      unreadCountSubscription?.cancel();
    }
  }

  /// 읽지 않은 메시지 수를 실시간으로 감시합니다.
  /// Monitors unread message count in real-time from Firebase.
  void countUnreadMessages(fa.User user) async {
    unreadCountSubscription?.cancel();
    final unreadCountRef = userChatUnreadCountRef(user.uid);

    // 초기화 시 이전 읽지 않은 메시지 수 초기화
    _previousUnreadCount = 0;

    unreadCountSubscription = unreadCountRef.onValue.listen(
      (event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final count = event.snapshot.value as int;

          // 새 메시지 도착 감지: 현재 값이 이전 값보다 크고, 첫 로드가 아닌 경우
          if (count > _previousUnreadCount && _previousUnreadCount > 0) {
            onNewMessageArrived?.call();
          }

          _previousUnreadCount = count;

          // int 변수 업데이트 - Update int variables
          // home.screen.dart의 onTap에서 이 변수들을 직접 참조함
          unreadCount = count;
          unreadSingleCount = count;

          // ValueNotifier 업데이트 - Update ValueNotifiers
          // Badge 위젯에서 이 stream을 listen함
          unreadCountStream.value = count;
          unreadSingleCountStream.value = count;

          debugPrint('[UserService] 📬 Firebase unread count updated: $count');
          debugPrint('[UserService]   - unreadSingleCount: $unreadSingleCount');
        } else {
          _previousUnreadCount = 0;

          // int 변수 초기화 - Reset int variables
          unreadCount = 0;
          unreadSingleCount = 0;

          // ValueNotifier 초기화 - Reset ValueNotifiers
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

  /// Set unread count for testing - 테스트용 읽지 않은 메시지 수 설정
  ///
  /// This method is for debugging purposes only.
  /// Use it to simulate unread messages without actual Firebase data.
  /// 이 메서드는 디버깅 목적으로만 사용됩니다.
  /// 실제 Firebase 데이터 없이 읽지 않은 메시지를 시뮬레이션하는 데 사용합니다.
  void setUnreadCountForTest(int count) {
    debugPrint('');
    debugPrint('╔════════════════════════════════════════════════════════╗');
    debugPrint('║ [UserService] 🧪 setUnreadCountForTest() called       ║');
    debugPrint('╠════════════════════════════════════════════════════════╣');
    debugPrint('║ Setting unread count to: $count');
    debugPrint('╚════════════════════════════════════════════════════════╝');

    unreadSingleCount = count;
    unreadSingleCountStream.value = count;
    unreadCount = count;
    unreadCountStream.value = count;

    debugPrint('[UserService] ✅ Test unread count set successfully');
    debugPrint('[UserService] 📊 Current values:');
    debugPrint('  - unreadSingleCount: $unreadSingleCount');
    debugPrint(
      '  - unreadSingleCountStream.value: ${unreadSingleCountStream.value}',
    );
    debugPrint('');
  }
}
