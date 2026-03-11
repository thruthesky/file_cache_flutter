import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';

import 'package:philgo/api/api.service.dart';

import 'user.model.dart';
import 'user.service.dart';

/// v7 사용자 상태 관리
///
/// FirebaseAuth의 authStateChanges 스트림을 구독하여
/// 로그인/로그아웃 상태 변화를 자동으로 감지하고,
/// 로그인 시 v7 API로 사용자 데이터를 로드한다.
class UserState extends ChangeNotifier {
  /// FirebaseAuth 상태 변화 구독
  StreamSubscription? _authSubscription;

  /// v7 API에서 가져온 사용자 데이터
  UserModel? _user;
  UserModel? get user => _user;

  /// 사용자 데이터 로딩 중 여부
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 에러 메시지 (로그인/사용자 로드 실패 시)
  String? _error;
  String? get error => _error;

  /// 소셜 로그인 진행 중 여부 (authStateChanges의 중복 호출 방지)
  bool _socialLoginInProgress = false;

  /// 로그인 여부
  bool get isLoggedIn => _user != null;

  /// 사용자 고유 ID
  int? get idx => _user?.idx;

  /// 사용자 이름
  String? get name => _user?.name;

  /// 사용자 닉네임
  String? get nickname => _user?.nickname;

  /// 사용자 전화번호
  String? get phoneNumber => _user?.phoneNumber;

  /// 사용자 포인트
  int get point => _user?.point ?? 0;

  /// 사용자 레벨
  int get level => _user?.level ?? 0;

  /// FirebaseAuth authStateChanges 스트림을 구독하여 로그인/로그아웃을 자동 감지한다.
  ///
  /// 앱 시작 시 한 번 호출한다. 스트림은 구독 즉시 현재 상태를 emit하므로
  /// 이미 로그인된 사용자의 데이터도 자동으로 로드된다.
  void listenAuthState() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (firebaseUser) async {
        if (firebaseUser != null) {
          // 소셜 로그인 진행 중이면 _loadCurrentUser를 호출하지 않는다.
          // signInWithGoogle()에서 user.socialLogin 완료 후 직접 _user를 설정한다.
          if (!_socialLoginInProgress) {
            await _loadCurrentUser();
          }
        } else {
          _user = null;
          _error = null;
          notifyListeners();
        }
      },
    );
  }

  /// Google 소셜 로그인 후 상태를 설정한다.
  /// 성공 시 true, 실패 시 false 반환 (에러는 [error]로 접근).
  Future<bool> signInWithGoogle() async {
    _socialLoginInProgress = true;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await UserService.signInWithGoogle();
      return true;
    } catch (e) {
      _user = null;
      _error = ApiService.friendlyErrorMessage(e);
      return false;
    } finally {
      _socialLoginInProgress = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// v7 API로 현재 사용자 데이터를 로드한다.
  Future<void> _loadCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await UserService.loadCurrentUser();
      _error = null;
    } catch (e) {
      debugPrint('UserState._loadCurrentUser 에러: $e');
      _error = ApiService.friendlyErrorMessage(e);
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 사용자 데이터 설정 (로그인 성공 후 직접 설정할 때 사용)
  void setUser(UserModel? userData) {
    _user = userData;
    _error = null;
    notifyListeners();
  }

  /// 에러 상태 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 사용자 상태 초기화 (로그아웃 시)
  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
