import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:philgo/api/api.service.dart';
import 'package:philgo/bookmark/bookmark.service.dart';
import 'package:philgo/chat/chat.service.dart';
import 'package:philgo/company/company.service.dart';
import 'package:philgo/user/user.functions.dart';
import 'package:philgo/user/user.state.dart';
import 'package:philgo/util/util.functions.dart';

import 'blocked_user.model.dart';
import 'user.model.dart';

/// 사용자 인증 및 v7 API 서비스
class UserService {
  static UserService? _instance;
  static UserService get instance {
    _instance ??= UserService._();
    return _instance!;
  }

  UserService._();

  final FirebaseAuth auth = FirebaseAuth.instance;
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
  // int _previousUnreadCount = 0;

  /// This is needed for the reviewers, testers, and even unit test with claude code
  /// 이메일/비밀번호로 로그인
  ///
  /// Firebase Auth의 signInWithEmailAndPassword를 사용한다.
  /// 계정이 없으면 자동으로 생성한다.
  ///
  /// [email] 이메일 주소
  /// [password] 비밀번호
  /// 반환: Firebase User 객체
  static Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = FirebaseAuth.instance;
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      // 계정이 없으면 자동 생성
      if (e.code == 'user-not-found') {
        final credential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return credential.user!;
      }
      rethrow;
    }
  }

  /// 로그아웃
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// 현재 로그인된 사용자
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  /// 로그인 여부
  static bool get isLoggedIn => currentUser != null;

  /// 현재 Firebase 로그인 사용자의 v7 데이터를 로드한다.
  ///
  /// Firebase Auth에 로그인된 상태이면 v7 API(user.me)를 호출하여
  /// UserModel을 반환한다. 미로그인이면 null을 반환한다.
  static Future<UserModel?> loadCurrentUser() async {
    final json = await ApiService.instance.v7api('user.me');
    return UserModel.fromJson(json);
  }

  /// 다른 사용자의 공개 프로필을 조회한다. (user.get)
  ///
  /// [idx] 조회할 사용자의 idx
  static Future<UserModel> getUser({required int idx}) async {
    final json = await ApiService.instance.v7api(
      'user.get',
      data: {'idx': idx},
    );
    return UserModel.fromJson(json);
  }

  /// 전체 사용자 수를 반환한다. (user.count)
  static Future<int> getUserCount() async {
    final json = await ApiService.instance.v7api('user.count');
    final count = json['count'];
    if (count is int) return count;
    return int.tryParse(count.toString()) ?? 0;
  }

  /// 현재 로그인된 사용자의 프로필을 업데이트한다. (user.update)
  ///
  /// [nickname] 닉네임 (선택)
  /// [name] 이름 (선택)
  /// [photoUrl] 프로필 사진 URL (선택)
  static Future<UserModel> updateProfile({
    required int idx,
    String? nickname,
    String? name,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{'idx': idx};
    if (nickname != null) data['nickname'] = nickname;
    if (name != null) data['name'] = name;
    if (photoUrl != null) data['photo_url'] = photoUrl;
    final json = await ApiService.instance.v7api('user.update', data: data);
    return UserModel.fromJson(json);
  }

  /// 현재 로그인된 사용자의 계정을 삭제한다. (user.delete)
  static Future<void> deleteAccount() async {
    await ApiService.instance.v7api('user.delete');
    await FirebaseAuth.instance.signOut();
  }

  /// 닉네임으로 사용자를 검색한다. (user.search)
  ///
  /// 접두사 매칭(LIKE 'keyword%')으로 최대 20명을 반환한다.
  /// 로그인 상태이면 현재 사용자는 결과에서 제외된다.
  ///
  /// [nickname] 검색할 닉네임 키워드
  static Future<List<UserModel>> search({required String nickname}) async {
    final items = await ApiService.instance.v7api<List>(
      'user.search',
      data: {'nickname': nickname},
      debug: true,
    );
    return items
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .toList();
  }

  /// 차단된 사용자 목록을 가져온다. (user.blockedList)
  static Future<List<BlockedUserModel>> getBlockedList() async {
    final items = await ApiService.instance.v7api<List>(
      'user.blockedList',
      debug: true,
    );
    return items
        .whereType<Map<String, dynamic>>()
        .map(BlockedUserModel.fromJson)
        .toList();
  }

  /// 사용자 차단을 해제한다. (user.unblock)
  static Future<void> unblock({required int idxBlockee}) async {
    await ApiService.instance.v7api(
      'user.unblock',
      data: {'idx_blockee': idxBlockee},
    );
  }

  /// Firebase UID로 사용자를 조회한다. (user.getByFirebaseUid)
  ///
  /// [firebaseUid] 조회할 사용자의 Firebase UID
  static Future<UserModel> getByFirebaseUid({
    required String firebaseUid,
  }) async {
    final json = await ApiService.instance.v7api(
      'user.getByFirebaseUid',
      data: {'firebase_uid': firebaseUid},
    );
    return UserModel.fromJson(json);
  }

  void initialize(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        cancelBlockedUsersListener();
        ChatService.instance.cancelPinnedChatRoomsListener();
        CompanyService.instance.clear();
        BookmarkService.instance.clear();
        if (context.mounted) {
          UserState.of(context).clear();
        }

        FirebaseCrashlytics.instance.setUserIdentifier('');
      } else {
        try {
          log(
            'UserService.initialize() ->Firebase user logged in: ${firebaseUser.uid}',
          );
          final user = await UserService.loadCurrentUser();

          ChatService.instance.initPinnedChatRooms(firebaseUser.uid);
          listenBlockedUsers(firebaseUser.uid);
          initUserPresence(firebaseUser.uid);

          CompanyService.instance.loadMyCompany();
          BookmarkService.instance.loadMyFolderBookmarks();

          if (context.mounted) {
            UserState.of(context).setUser(user);
          }

          FirebaseCrashlytics.instance.setUserIdentifier(firebaseUser.uid);
        } catch (e) {
          // v7 API 호출 실패 시에도 Firebase 로그인 상태는 유지하므로, 사용자에게 알리고 로그아웃 처리
          if (context.mounted) {
            showErrorDialog(
              context,
              'Code: 182, Login fails on backend. If this persists, please report it to admin',
            );
          }
          log(
            'Code: 182, Login fails on backend. If this persists, please report it to admin',
          );
          await UserService.signOut();

          rethrow;
        }
      }
    });
  }

  /// Listen to blocked users from Firebase: user-private/{uid}/blocks
  void listenBlockedUsers(String uid) {
    blockedUsersSubscription?.cancel();
    final ref = userPrivateBlocksRef(uid);
    blockedUsersSubscription = ref.onValue.listen((event) {
      final newSet = <String>{};
      if (event.snapshot.exists && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        newSet.addAll(data.keys.cast<String>());
      }
      blockedUsersStream.value = newSet;
    });
  }

  /// Cancel blocked users listener and clear state
  void cancelBlockedUsersListener() {
    blockedUsersSubscription?.cancel();
    blockedUsersSubscription = null;
    blockedUsers.clear();
    blockedUsersStream.value = <String>{};
  }

  void initUserPresence(String firebaseUid) {
    DatabaseReference myConnectionsRef = database.ref(
      "status/$firebaseUid/connections",
    );
    DatabaseReference lastOnlineRef = database.ref(
      "status/$firebaseUid/last_changed",
    );
    DatabaseReference connectedRef = database.ref('.info/connected');

    connectedRef.onValue.listen((event) {
      // If we're not currently connected, don't do anything.
      // true - connected, false - not connected
      if (event.snapshot.value == false) {
        return;
      }
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
    });
  }
}
