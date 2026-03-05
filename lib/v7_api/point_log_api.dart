import 'v7_api.dart';

/// v7 포인트 로그(PointLog) API 래퍼 클래스
///
/// 포인트 관련 모든 v7 API 호출을 일관된 인터페이스로 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final point = await PointLogApi.memberPoint();
/// final history = await PointLogApi.history(page: 1, limit: 20);
/// ```
class PointLogApi {
  PointLogApi._();

  /// 회원 현재 포인트 조회
  ///
  /// API 엔드포인트: pointLog.memberPoint
  /// 인증: 필수
  ///
  /// 반환: 현재 포인트 (int)
  static Future<int> memberPoint() async {
    final response = await v7api('pointLog.memberPoint');
    return (response['point'] as num?)?.toInt() ?? 0;
  }

  /// 포인트 히스토리 조회 (페이지네이션)
  ///
  /// API 엔드포인트: pointLog.history
  /// 인증: 필수
  ///
  /// [page] 페이지 번호 (기본 1)
  /// [limit] 페이지당 항목 수 (기본 20)
  /// [module] 모듈 필터 (선택)
  /// [action] 액션 필터 (선택)
  ///
  /// 반환: {total, page, limit, items[]}
  static Future<Map<String, dynamic>> history({
    int page = 1,
    int limit = 20,
    String? module,
    String? action,
  }) async {
    return await v7api('pointLog.history', data: {
      'page': page,
      'limit': limit,
      if (module != null) 'module': module,
      if (action != null) 'action': action,
    });
  }
}
