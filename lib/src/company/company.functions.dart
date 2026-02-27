import 'package:philgo_api/philgo_api.dart';

/// Fetch company list from PhilGo v6 API
///
/// API endpoint: get_company_list
/// Authentication: Not required (public API)
///
/// Parameters:
/// - [category] Filter by company category (optional)
/// - [status] Filter by company status, default is STATUS_APPROVE = 'a'
/// - [orderby] Sort order (optional)
/// - [limit] Maximum number of companies to return (optional)
///
/// Returns: CompanyList object with pagination and metadata
///
/// Example:
/// ```dart
/// Get all companies
/// final companyList = await getCompanies();
//// print('Total: ${companyList.company_count}');
///
/// Get companies by category
/// final restaurants = await getCompanies(category: 'restaurant');
///
/// Get active companies with limit
/// final activeCompanies = await getCompanies(status: 'active', limit: 10);
///
/// for (final company in companyList.companies) {
////   print('Company: ${company.name}');
////   print('Category: ${company.category}');
/// }
/// ```
Future<CompanyList> getCompanies({
  String? category,
  String status = STATUS_APPROVE,
  String? orderby,
  int? limit,
}) async {
  final response = await func(
    'get_company_list',
    data: {
      if (category != null) 'category': category,
      'status': status,
      if (orderby != null) 'orderby': orderby,
      if (limit != null) 'limit': limit,
    },
  );

  // API가 List를 직접 반환하는 경우 처리
  if (response is List) {
    final companiesData = {
      'page': 1,
      'company_count': response.length,
      'duration': '',
      'companies': response,
      'config': {},
    };
    return CompanyList.fromJson(companiesData);
  }

  return CompanyList.fromJson(response as Map<String, dynamic>);
}

Future<Company> getCompany(int idx) async {
  final response = await func('get_company', data: {'idx': idx});
  return Company.fromJson(response);
}

Future<Company?> getMyCompany() async {
  final response = await func('get_my_company');

  if (response.containsKey('data')) {
    if (response['data'] == null) {
      return null;
    }
  }

  return Company.fromJson(response);
}

Future<Company> createCompany() async {
  final response = await func('create_my_company');
  return Company.fromJson(response);
}

Future<Company> updateCompany(RecordType data) async {
  final response = await func('update_my_company', data: data);
  return Company.fromJson(response);
}
