import 'package:philgo/api/api.service.dart';
import 'package:philgo/point/point_log_history.model.dart';

/// 포인트 관련 API 호출 서비스
class PointService {
  PointService._();

  /// 회원 현재 포인트 조회
  ///
  /// API: pointLog.memberPoint
  static Future<int> memberPoint() async {
    final response = await ApiService.instance.v7api('pointLog.memberPoint');
    return (response['point'] as num?)?.toInt() ?? 0;
  }

  /// 포인트 히스토리 조회 (페이지네이션)
  ///
  /// API: pointLog.history
  /// [page] 페이지 번호 (1부터 시작)
  /// [limit] 페이지당 항목 수
  /// [module] 모듈 필터 (선택)
  /// [action] 액션 필터 (선택)
  static Future<PointLogHistory> history({
    int page = 1,
    int limit = 20,
    String? module,
    String? action,
  }) async {
    final response = await ApiService.instance.v7api(
      'pointLog.history',
      data: {'page': page, 'limit': limit, ?module: module, ?action: action},
    );
    return PointLogHistory.fromJson(response);
  }
}
