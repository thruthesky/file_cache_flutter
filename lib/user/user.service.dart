import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import 'package:philgo/app.config.dart';

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

  /// v7 API 엔드포인트
  static final String _endpoint = v7ApiEndpoint;

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
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;

    final data = <String, dynamic>{'method': 'user.me'};

    // Firebase ID Token 추가
    try {
      data['id_token'] = await firebaseUser.getIdToken() ?? '';
    } catch (_) {
      data['id_token'] = '';
    }

    final dio = Dio();
    if (kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final httpClient = HttpClient();
        httpClient.badCertificateCallback = (_, _, _) => true;
        return httpClient;
      };
    }

    final response = await dio.post(_endpoint, data: data);

    Map<String, dynamic> json;
    if (response.data is Map<String, dynamic>) {
      json = response.data;
    } else if (response.data is String) {
      json = jsonDecode(response.data) as Map<String, dynamic>;
    } else {
      throw Exception('예상치 못한 응답 타입: ${response.data.runtimeType}');
    }

    if (json['success'] == false) {
      throw Exception(json['message'] ?? '알 수 없는 오류');
    }

    return UserModel.fromJson(json);
  }
}
