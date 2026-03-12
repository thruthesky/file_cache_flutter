import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import 'user.model.dart';
import 'user.service.dart';

/// v7 사용자 상태 관리
///
/// FirebaseAuth의 authStateChanges 스트림을 구독하여
/// 로그인/로그아웃 상태 변화를 자동으로 감지하고,
/// 로그인 시 v7 API로 사용자 데이터를 로드한다.
class UserState extends ChangeNotifier {
  static UserState of(BuildContext context) => context.read<UserState>();

  /// FirebaseAuth 상태 변화 구독
  StreamSubscription? _authSubscription;

  /// v7 API에서 가져온 사용자 데이터
  UserModel? _user;
  UserModel? get user => _user;

  /// 사용자 데이터 로딩 중 여부
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
  void listenAuthState() {
    _authSubscription?.cancel();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      firebaseUser,
    ) async {
      if (firebaseUser != null) {
        if (!_socialLoginInProgress) {
          await _loadCurrentUser();
        }
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// Google 소셜 로그인 후 상태를 설정한다.
  Future<bool> signInWithGoogle({bool displayError = false}) async {
    _socialLoginInProgress = true;
    _isLoading = true;
    notifyListeners();
    try {
      _user = await UserService.signInWithGoogle();
      return true;
    } catch (e) {
      _user = null;
      return false;
    } finally {
      _socialLoginInProgress = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 카카오톡 소셜 로그인 후 상태를 설정한다.
  Future<bool> signInWithKakao({bool displayError = false}) async {
    _socialLoginInProgress = true;
    _isLoading = true;
    notifyListeners();
    try {
      _user = await UserService.signInWithKakao();
      return true;
    } catch (e) {
      _user = null;
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
  void setUser(UserModel? userData) {
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
