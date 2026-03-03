import 'v7_api.dart';

/// v7 여행 명소(Travel) API 래퍼 클래스
///
/// 여행 명소 관련 모든 v7 API 호출을 일관된 인터페이스로 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
/// 인증 불필요 (공개 API).
///
/// 사용 예시:
/// ```dart
/// final result = await TravelApi.list(province: '세부', category: '폭포');
/// final spot = await TravelApi.get(index: 42);
/// final filters = await TravelApi.filters();
/// ```
class TravelApi {
  TravelApi._();

  /// 여행 명소 목록 조회 (texts 제외, 경량화)
  ///
  /// API 엔드포인트: travel.list
  /// 인증: 불필요 (공개 API)
  ///
  /// [province] 주(Province) 필터 (선택)
  /// [city] 도시(City) 필터 (선택)
  /// [category] 분류(Category) 필터 (선택)
  /// [search] 검색어 (선택)
  /// [page] 페이지 번호 (기본값: 1)
  /// [limit] 페이지당 항목 수 (기본값: 9999 - 전체 로드)
  ///
  /// 반환: {items: [...], pagination: {page, limit, total, total_pages}}
  static Future<Map<String, dynamic>> list({
    String? province,
    String? city,
    String? category,
    String? search,
    int page = 1,
    int limit = 9999,
  }) async {
    return await v7api('travel.list', data: {
      if (province != null) 'province': province,
      if (city != null) 'city': city,
      if (category != null) 'category': category,
      if (search != null) 'search': search,
      'page': page,
      'limit': limit,
    });
  }

  /// 여행 명소 상세 조회 (texts 포함)
  ///
  /// API 엔드포인트: travel.get
  /// 인증: 불필요 (공개 API)
  ///
  /// [index] JSON 배열 인덱스 (필수)
  ///
  /// 반환: 여행 명소 전체 데이터 (texts 마크다운 포함)
  static Future<Map<String, dynamic>> get({required int index}) async {
    return await v7api('travel.get', data: {'index': index});
  }

  /// 필터 옵션 목록 조회
  ///
  /// API 엔드포인트: travel.filters
  /// 인증: 불필요 (공개 API)
  ///
  /// 반환: {provinces: [...], cities: [...], categories: [...]}
  static Future<Map<String, dynamic>> filters() async {
    return await v7api('travel.filters');
  }
}
