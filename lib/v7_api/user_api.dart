import 'v7_api.dart';

/// v7 사용자(User) API 래퍼 클래스
///
/// 사용자 관련 모든 v7 API 호출을 일관된 인터페이스로 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final user = await UserApi.me();
/// print(user['name']); // 홍길동
///
/// final total = await UserApi.count();
/// print(total); // 188186
/// ```
class UserApi {
  UserApi._();

  /// 현재 로그인 사용자 정보 조회
  ///
  /// API 엔드포인트: user.me
  /// 인증: 필수 (Firebase ID Token)
  ///
  /// 반환: Map (idx, id, name, nickname, phone_number, firebase_uid, stamp 등)
  /// 에러: 비로그인 시 Exception throw
  static Future<Map<String, dynamic>> me() async {
    return await v7api('user.me');
  }

  /// 총 사용자 수 조회
  ///
  /// API 엔드포인트: user.count
  /// 인증: 불필요 (공개 API)
  ///
  /// 반환: 총 사용자 수 (int)
  static Future<int> count() async {
    final result = await v7api('user.count');
    return (result['count'] as num?)?.toInt() ?? 0;
  }
}
