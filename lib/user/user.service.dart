import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;

import 'package:philgo/api/api.service.dart';

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
  int _previousUnreadCount = 0;

  // PINNED CHAT ROOMS
  StreamSubscription<DatabaseEvent>? pinnedChatRoomsSubscription;
  final Set<String> pinnedChatRooms = <String>{};
  final pinnedChatRoomsStream = ValueNotifier<Set<String>>(<String>{});

  // FAVORITE FOLDER
  StreamSubscription<DatabaseEvent>? favoriteFoldersSubscription;
  final List<Map<String, dynamic>> favoriteFolders = [];
  final favoriteFoldersStream = ValueNotifier<List<Map<String, dynamic>>>([]);

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

  /// Google 소셜 로그인 + v7 user.socialLogin 등록
  static Future<UserModel> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Google 로그인이 취소되었습니다.');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    final json = await ApiService.v7api(
      'user.socialLogin',
      data: {'login_provider': 'google'},
    );
    return UserModel.fromJson(json);
  }

  /// 카카오톡 소셜 로그인 + Firebase Custom Token + v7 user.socialLogin 등록
  ///
  /// 1. 카카오 SDK로 로그인 (앱 설치 시 앱 로그인, 미설치 시 웹 로그인)
  /// 2. v7 서버에 access_token 전송 → Firebase Custom Token 발급
  /// 3. Firebase signInWithCustomToken()으로 Firebase 로그인
  /// 4. v7 user.socialLogin 호출하여 DB 등록/업데이트
  static Future<UserModel> signInWithKakao() async {
    kakao.OAuthToken token;
    final isInstalled = await kakao.isKakaoTalkInstalled();
    debugPrint('카카오톡 앱 설치 여부: $isInstalled');
    final keyHash = await kakao.KakaoSdk.origin;
    debugPrint('카카오 Android keyHash: $keyHash');
    if (isInstalled) {
      try {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } catch (e) {
        debugPrint('카카오톡 앱 로그인 실패, 웹 로그인으로 폴백: $e');
        if (e is PlatformException && e.code == 'CANCELED') rethrow;
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await kakao.UserApi.instance.loginWithKakaoAccount();
    }

    final customTokenRes = await ApiService.v7api(
      'user.kakaoFirebaseToken',
      data: {'kakao_access_token': token.accessToken},
    );
    final customToken = customTokenRes['custom_token'] as String;

    await FirebaseAuth.instance.signInWithCustomToken(customToken);

    final json = await ApiService.v7api(
      'user.socialLogin',
      data: {'login_provider': 'kakao'},
    );
    return UserModel.fromJson(json);
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
    if (FirebaseAuth.instance.currentUser == null) return null;
    final json = await ApiService.v7api('user.me');
    return UserModel.fromJson(json);
  }

  /// 다른 사용자의 공개 프로필을 조회한다. (user.get)
  ///
  /// [idx] 조회할 사용자의 idx
  static Future<UserModel> getUser({required int idx}) async {
    final json = await ApiService.v7api('user.get', data: {'idx': idx});
    return UserModel.fromJson(json);
  }

  /// 전체 사용자 수를 반환한다. (user.count)
  static Future<int> getUserCount() async {
    final json = await ApiService.v7api('user.count');
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
    final json = await ApiService.v7api('user.update', data: data);
    return UserModel.fromJson(json);
  }

  /// 현재 로그인된 사용자의 계정을 삭제한다. (user.delete)
  static Future<void> deleteAccount() async {
    await ApiService.v7api('user.delete');
    await FirebaseAuth.instance.signOut();
  }

  /// 사용자 목록을 조회한다. (user.list) - 관리자용
  ///
  /// [page] 페이지 번호 (선택, 기본값 1)
  /// [limit] 페이지당 항목 수 (선택)
  static Future<List<UserModel>> getUserList({int? page, int? limit}) async {
    final data = <String, dynamic>{};
    if (page != null) data['page'] = page;
    if (limit != null) data['limit'] = limit;
    final json = await ApiService.v7api('user.list', data: data);
    final list = json['list'] as List<dynamic>? ?? [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
