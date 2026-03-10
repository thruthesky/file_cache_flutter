import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// v7 사용자 상태 관리
///
/// Firebase Auth 로그인 상태를 확인하고,
/// 로그인된 경우 v7 API(user.me)로 사용자 데이터를 로드하여 보관한다.
class UserState extends ChangeNotifier {
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

  /// v7 API 엔드포인트
  static const String _endpoint = String.fromEnvironment(
    'V7_API_ENDPOINT',
    defaultValue: 'https://philgo.com/api.php',
  );

  /// Firebase Auth 로그인 상태를 확인하고, 로그인된 경우 v7 API로 사용자 데이터를 로드한다.
  ///
  /// 앱 시작 시 호출하여 이미 로그인된 사용자의 데이터를 복원한다.
  Future<void> loadCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      _user = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
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

      _user = json;
    } catch (e) {
      debugPrint('UserState.loadCurrentUser 에러: $e');
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
}
