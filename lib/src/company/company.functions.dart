import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'package:philgo_v6_flutter/src/constants.dart';

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
/// print('Total: ${companyList.company_count}');
///
/// Get companies by category
/// final restaurants = await getCompanies(category: 'restaurant');
///
/// Get active companies with limit
/// final activeCompanies = await getCompanies(status: 'active', limit: 10);
///
/// for (final company in companyList.companies) {
///   print('Company: ${company.name}');
///   print('Category: ${company.category}');
/// }
/// ```
Future<CompanyList> getCompanies({
  String? category,
  String status = STATUS_APPROVE,
  String? orderby,
  int? limit,
}) async {
  debugLog('Fetching company list');

  final response = await func(
    'get_company_list',
    data: {
      if (category != null) 'category': category,
      'status': status,
      if (orderby != null) 'orderby': orderby,
      if (limit != null) 'limit': limit,
    },
    debug: true,
  );

  debugLog('getCompanies response type: ${response.runtimeType}');
  debugLog('getCompanies response: $response');

  // PHP returns object with numeric keys like {0: {...}, 1: {...}}
  // Convert to List format
  if (response is Map) {
    // Check if it's a numeric-keyed map (PHP array) vs metadata object
    final hasNumericKeys = response.keys.any(
      (key) => int.tryParse(key.toString()) != null,
    );

    if (hasNumericKeys) {
      // Convert Map to List, ensuring each item is a Map<String, dynamic>
      final companiesList = response.values.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          debugLog('Unexpected item type: ${item.runtimeType}');
          return <String, dynamic>{};
        }
      }).toList();

      return CompanyList.fromJson({
        'page': 1,
        'company_count': companiesList.length,
        'duration': '',
        'companies': companiesList,
        'config': {},
      });
    }
  }

  throw Exception('Unexpected response format: ${response.runtimeType}');
}
