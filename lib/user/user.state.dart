import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'user.service.dart';

/// v7 사용자 상태 관리
///
/// FirebaseAuth의 authStateChanges 스트림을 구독하여
/// 로그인/로그아웃 상태 변화를 자동으로 감지하고,
/// 로그인 시 v7 API로 사용자 데이터를 로드한다.
class UserState extends ChangeNotifier {
  /// FirebaseAuth 상태 변화 구독
  StreamSubscription<User?>? _authSubscription;

  /// v7 API에서 가져온 사용자 데이터 전체
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  /// 사용자 데이터 로딩 중 여부
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 로그인 여부
  bool get isLoggedIn => _user != null;

  /// 사용자 고유 ID
  int? get idx => _user?['idx'] as int?;

  /// 사용자 이름
  String? get name => _user?['name']?.toString();

  /// 사용자 닉네임
  String? get nickname => _user?['nickname']?.toString();

  /// 사용자 전화번호
  String? get phoneNumber => _user?['phone_number']?.toString();

  /// 사용자 포인트
  int get point => (_user?['point'] as num?)?.toInt() ?? 0;

  /// 사용자 레벨
  int get level => (_user?['level'] as num?)?.toInt() ?? 0;

  /// FirebaseAuth authStateChanges 스트림을 구독하여 로그인/로그아웃을 자동 감지한다.
  ///
  /// 앱 시작 시 한 번 호출한다. 스트림은 구독 즉시 현재 상태를 emit하므로
  /// 이미 로그인된 사용자의 데이터도 자동으로 로드된다.
  void listenAuthState() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (firebaseUser) async {
        if (firebaseUser != null) {
          // 로그인 상태 → v7 API로 사용자 데이터 로드
          await _loadCurrentUser();
        } else {
          // 로그아웃 상태 → 사용자 데이터 초기화
          _user = null;
          notifyListeners();
        }
      },
    );
  }

  /// v7 API로 현재 사용자 데이터를 로드한다.
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await UserService.loadCurrentUser();
    } catch (e) {
      debugPrint('UserState._loadCurrentUser 에러: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 데이터 설정 (로그인 성공 후 직접 설정할 때 사용)
  void setUser(Map<String, dynamic>? userData) {
    _user = userData;
    notifyListeners();
  }

  /// 사용자 상태 초기화 (로그아웃 시)
  void clear() {
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
