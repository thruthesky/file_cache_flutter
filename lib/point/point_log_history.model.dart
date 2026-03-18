import 'package:philgo/point/point_log.model.dart';

/// v7 포인트 로그 히스토리 응답 모델
class PointLogHistory {
  final int total;
  final int page;
  final int limit;
  final List<PointLog> items;

  const PointLogHistory({
    required this.total,
    required this.page,
    required this.limit,
    required this.items,
  });

  factory PointLogHistory.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>?) ?? [];
    return PointLogHistory(
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      items: items
          .whereType<Map<String, dynamic>>()
          .map(PointLog.fromJson)
          .toList(),
    );
  }
}
