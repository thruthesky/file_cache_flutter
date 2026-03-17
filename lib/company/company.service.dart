import 'package:philgo/api/api.service.dart';

import 'company.model.dart';

/// 업소록 API 서비스
///
/// 업소록 관련 모든 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final companies = await CompanyService.list(category: 'food');
/// final company = await CompanyService.get(1025);
/// final mine = await CompanyService.mine();
/// final updated = await CompanyService.update({'name': '새 이름'});
/// ```
class CompanyService {
  CompanyService._();

  /// 업소 목록 조회
  ///
  /// API: company.list (인증 불필요)
  ///
  /// [category] 카테고리 필터 (선택)
  /// [page] 페이지 번호 (기본 1)
  /// [limit] 최대 조회 수 (기본 20, 최대 100)
  ///
  /// 반환: CompanyModel 목록
  static Future<List<CompanyModel>> list({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiService.instance.v7api(
      'company.list',
      data: {
        if (category != null) 'category': category,
        'page': page,
        'limit': limit,
      },
      debug: true,
    );

    final raw = result['items'];
    if (raw == null || raw is! List) return [];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(CompanyModel.fromJson)
        .toList();
  }

  /// 업소 단건 조회
  ///
  /// API: company.get (인증 불필요)
  ///
  /// [idx] 업소 고유번호
  /// 반환: CompanyModel 또는 null (업소가 없을 경우)
  static Future<CompanyModel?> get(int idx) async {
    final result = await ApiService.instance.v7api(
      'company.get',
      data: {'idx': idx},
    );
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 내 업소 조회
  ///
  /// API: company.mine (인증 필수)
  ///
  /// 업소가 없으면 서버에서 자동 생성된다 (status='').
  /// 반환: CompanyModel 또는 null
  static Future<CompanyModel?> mine() async {
    final result = await ApiService.instance.v7api('company.mine');
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 업소 생성 (최초 등록)
  ///
  /// API: company.create (인증 필수)
  ///
  /// 반환: 생성된 CompanyModel 또는 null
  static Future<CompanyModel?> create() async {
    final result = await ApiService.instance.v7api('company.create');
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }

  /// 업소 정보 수정
  ///
  /// API: company.update (인증 필수, 소유자 또는 관리자)
  ///
  /// [data] 수정할 필드 맵 (예: {'name': '새 이름', 'description': '새 설명'})
  ///
  /// description, title_image_url, photo_url 변경 시 status가 'p'(심사중)로
  /// 자동 전환된다.
  ///
  /// 반환: 수정된 CompanyModel 또는 null
  static Future<CompanyModel?> update(Map<String, dynamic> data) async {
    final result = await ApiService.instance.v7api(
      'company.update',
      data: data,
    );
    if (result.isEmpty) return null;
    return CompanyModel.fromJson(result);
  }
}
