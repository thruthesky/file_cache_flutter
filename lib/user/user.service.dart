import 'package:firebase_auth/firebase_auth.dart';

/// 사용자 인증 서비스
class UserService {
  UserService._();

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
}
