import 'package:philgo_api/philgo_v6_flutter.dart';

/// Company List Model
///
/// Represents a paginated list of companies with metadata.
class CompanyList {
  int page = 1; // Current page number
  int company_count = 0; // Total number of companies
  String duration = ""; // API response time
  List<Company> companies = []; // List of companies
  Map<String, dynamic> config = {}; // Metadata information

  CompanyList.fromJson(Map<String, dynamic> json) {
    page = json['page'] as int? ?? 1;
    if (json['companies'] != null) {
      companies = (json['companies'] as List<dynamic>)
          .map((e) => Company.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    duration = json['duration'] as String? ?? '';
    company_count = json['company_count'] as int? ?? 0;
    config = Map<String, dynamic>.from((json['config'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'company_count': company_count,
      'duration': duration,
      'companies': companies.map((e) => e.toJson()).toList(),
      'config': config,
    };
  }

  @override
  String toString() {
    return 'CompanyList{page: $page, company_count: $company_count, duration: $duration, companies: $companies, config: $config}';
  }
}
