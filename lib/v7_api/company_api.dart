import 'package:philgo_api/philgo_api.dart';

import 'v7_api.dart';

/// v7 업소(Company) API 래퍼 클래스
///
/// 업소 관련 모든 v7 API 호출을 일관된 인터페이스로 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final companies = await CompanyApi.list(category: 'food');
/// final company = await CompanyApi.get(123);
/// final myCompany = await CompanyApi.mine();
/// final created = await CompanyApi.create();
/// final updated = await CompanyApi.update({'idx': 123, 'name': '새 이름'});
/// ```
class CompanyApi {
  CompanyApi._();

  /// 업소 목록 조회
  ///
  /// API 엔드포인트: company.list
  /// 인증: 불필요 (공개 API)
  ///
  /// [category] 카테고리 필터 (선택)
  /// [status] 상태 필터, 기본값 STATUS_APPROVE = 'a'
  /// [orderby] 정렬 순서 (선택)
  /// [limit] 최대 조회 수 (선택)
  ///
  /// 반환: CompanyList 객체
  static Future<CompanyList> list({
    String? category,
    String status = STATUS_APPROVE,
    String? orderby,
    int? limit,
  }) async {
    final response = await v7api(
      'company.list',
      data: {
        if (category != null) 'category': category,
        'status': status,
        if (orderby != null) 'orderby': orderby,
        if (limit != null) 'limit': limit,
      },
    );

    /// v7 company.list 응답: { items: [...] }
    /// CompanyList.fromJson()은 'companies' 키를 기대하므로 호환 변환
    final items = (response['items'] as List<dynamic>?) ?? [];
    return CompanyList.fromJson({
      'page': 1,
      'company_count': items.length,
      'duration': '',
      'companies': items,
      'config': {},
    });
  }

  /// 업소 단건 조회
  ///
  /// API 엔드포인트: company.get
  /// 인증: 불필요 (공개 API)
  ///
  /// [idx] 업소 고유번호
  /// 반환: Company 객체
  static Future<Company> get(int idx) async {
    final response = await v7api('company.get', data: {'idx': idx});
    /// v7 응답: { success: true, data: {...} } 또는 직접 company 데이터
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Company.fromJson(data);
  }

  /// 내 업소 조회
  ///
  /// API 엔드포인트: company.mine
  /// 인증: 필수
  /// 업소가 없으면 서버에서 자동 생성
  ///
  /// 반환: Company 객체 (v7에서는 항상 업소가 반환됨)
  static Future<Company> mine() async {
    final response = await v7api('company.mine');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Company.fromJson(data);
  }

  /// 업소 생성
  ///
  /// API 엔드포인트: company.create
  /// 인증: 필수
  ///
  /// 반환: Company 객체
  static Future<Company> create() async {
    final response = await v7api('company.create');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Company.fromJson(data);
  }

  /// 업소 정보 수정
  ///
  /// API 엔드포인트: company.update
  /// 인증: 필수 (소유자 또는 관리자)
  /// description, title_image_url, photo_url 변경 시 status='p'(심사중)로 자동 전환
  ///
  /// [data] 수정할 필드 데이터
  /// 반환: Company 객체
  static Future<Company> update(Map<String, dynamic> data) async {
    final response = await v7api('company.update', data: data);
    final responseData =
        response['data'] as Map<String, dynamic>? ?? response;
    return Company.fromJson(responseData);
  }

}
