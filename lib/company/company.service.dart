import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:philgo/api/api.service.dart';

import 'company.model.dart';
import 'company_list_result.model.dart';

/// 업소록 API 서비스
///
/// 업소록 관련 모든 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
///
/// 사용 예시:
/// ```dart
/// final result = await CompanyService.list(category: 'food');
/// final companies = result.items;
/// final company = await CompanyService.get(1025);
/// final mine = await CompanyService.mine();
/// final updated = await CompanyService.update({'name': '새 이름'});
/// ```
class CompanyService {
  static final CompanyService instance = CompanyService._();

  CompanyService._();

  final ValueNotifier<CompanyModel?> _companyListenable =
      ValueNotifier<CompanyModel?>(null);

  ValueNotifier<CompanyModel?> get companyNotifier => _companyListenable;
  CompanyModel? get company => _companyListenable.value;

  void clear() => _companyListenable.value = null;

  /// 업소 목록 조회
  ///
  /// API: company.list (인증 불필요)
  ///
  /// [category] 카테고리 필터 (선택)
  /// [status] 업소 상태 필터 (선택, 예: 'a' = 승인됨)
  /// [page] 페이지 번호 (기본 1)
  /// [limit] 최대 조회 수 (기본 20, 최대 100)
  ///
  /// 반환: CompanyListResult (items, total, page, limit)
  static Future<CompanyListResult> list({
    String? category,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await ApiService.instance.v7api(
      'company.list',
      data: {
        if (category != null) 'category': category,
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
      debug: true,
    );

    return CompanyListResult.fromJson(result);
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
  Future<void> loadMyCompany() async {
    final result = await ApiService.instance.v7api('company.mine');
    if (result.isEmpty) return;

    _companyListenable.value = CompanyModel.fromJson(result);

    log('[loadMyCompany func] Company is loaded : $result');
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
    final company = CompanyModel.fromJson(result);
    instance._companyListenable.value = company;
    return company;
  }

  /// QR 코드 스캔 검증
  ///
  /// API: company.scanQrCode (인증 필수)
  ///
  /// [code] QR 코드에 포함된 64자 hex 검증 ID
  /// 반환: { success, usage_idx, idx_company, company_name, reward_points,
  ///         point_before, point_after, is_revisit }
  static Future<Map<String, dynamic>> scanQrCode(String code) async {
    return await ApiService.instance.v7api(
      'company.scanQrCode',
      data: {'code': code},
    );
  }

  /// 재방문 포인트 추첨
  ///
  /// API: company.reVisitPoint (인증 필수)
  ///
  /// [usageIdx] QR 코드 사용 기록 ID
  /// 반환: { reward_points, point_before, point_after }
  static Future<Map<String, dynamic>> reVisitPoint(int usageIdx) async {
    return await ApiService.instance.v7api(
      'company.reVisitPoint',
      data: {'usage_idx': usageIdx},
    );
  }

  /// 방문 후기 제출
  ///
  /// API: company.submitVisitReview (인증 필수)
  ///
  /// [usageIdx] QR 코드 사용 기록 ID
  /// [content] 후기 내용 (10자 이상)
  /// [photoIdxs] 업로드된 사진 idx 목록 (1개 이상)
  /// 반환: { reward_points, point_before, point_after }
  static Future<Map<String, dynamic>> submitVisitReview({
    required int usageIdx,
    required String content,
    required List<int> photoIdxs,
  }) async {
    return await ApiService.instance.v7api(
      'company.submitVisitReview',
      data: {
        'usage_idx': usageIdx,
        'content': content,
        'photo_idxs': photoIdxs,
      },
    );
  }
}
