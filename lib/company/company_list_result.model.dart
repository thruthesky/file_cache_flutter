import 'package:philgo/api/api.service.dart';

import 'company.model.dart';

/// 업소 목록 조회 결과 모델
class CompanyListResult {
  final List<CompanyModel> items;
  final int total;
  final int page;
  final int limit;

  CompanyListResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory CompanyListResult.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List<dynamic>?) ?? [];
    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .toList();

    return CompanyListResult(
      items: items,
      total: ApiService.toInt(json['total']),
      page: ApiService.toInt(json['page']),
      limit: ApiService.toInt(json['limit']),
    );
  }
}
