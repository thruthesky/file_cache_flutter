import 'package:philgo_v6_flutter/philgo_v6_flutter.dart';
import 'dart:developer';

/// 필고 광고 배너 API 클래스
/// PhilGo Advertisement Banner API Class
///
/// 4가지 타입의 배너를 조회할 수 있습니다:
/// - Top Banners: 페이지 상단 배너 (좌/우 분리)
/// - Wing Banners: 윙 배너 (좌/우 분리)
/// - Square Banners: 사각 배너 (리스트)
/// - Small Banners: 작은 배너 (리스트)
class BannerApi {
  /// Top 배너 조회
  /// Fetch Top Banners
  ///
  /// [category]: 게시판/카테고리 ID (옵션)
  /// Returns: {'left': [...], 'right': [...]} 형식의 배너 목록
  static Future<Map<String, List<BannerModel>>> getTopBanners({
    String? category,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (category != null) {
        data['category'] = category;
      }

      final response = await func('get_top_banners', data: data);

      if (response is Map) {
        final leftList =
            (response['left'] as List?)
                ?.map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];
        final rightList =
            (response['right'] as List?)
                ?.map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];

        return {'left': leftList, 'right': rightList};
      }
      return {'left': [], 'right': []};
    } catch (e) {
      // log('Error getting top banners: $e', name: 'BannerApi');
      return {'left': [], 'right': []};
    }
  }

  /// Wing 배너 조회
  /// Fetch Wing Banners
  ///
  /// [category]: 게시판/카테고리 ID (옵션)
  /// Returns: {'left': [...], 'right': [...]} 형식의 배너 목록
  static Future<Map<String, List<BannerModel>>> getWingBanners({
    String? category,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (category != null) {
        data['category'] = category;
      }

      final response = await func('get_wing_banners', data: data);

      if (response is Map) {
        final leftList =
            (response['left'] as List?)
                ?.map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];
        final rightList =
            (response['right'] as List?)
                ?.map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            [];

        return {'left': leftList, 'right': rightList};
      }
      return {'left': [], 'right': []};
    } catch (e) {
      // log('Error getting wing banners: $e', name: 'BannerApi');
      return {'left': [], 'right': []};
    }
  }

  /// Square 배너 조회 (사각 배너)
  /// Fetch Square Banners
  ///
  /// [category]: 게시판/카테고리 ID (옵션)
  /// - null인 경우: 전체 페이지 배너 표시 (all_page='y')
  /// - 지정된 경우: 해당 카테고리 배너 + 전체 페이지 배너 표시
  /// Returns: BannerModel 리스트
  static Future<List<BannerModel>> getSquareBanners({String? category}) async {
    try {
      final Map<String, dynamic> data = {};
      if (category != null) {
        data['category'] = category;
      }

      final response = await func('get_square_banners', data: data);

      if (response is List) {
        return response
            .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      // log('Error getting square banners: $e', name: 'BannerApi');
      return [];
    }
  }

  /// Small 배너 조회 (작은 배너, 텍스트 포함 가능)
  /// Fetch Small Banners
  ///
  /// [category]: 게시판/카테고리 ID (필수)
  /// Returns: BannerModel 리스트
  static Future<List<BannerModel>> getSmallBanners({
    required String category,
  }) async {
    try {
      final response = await func(
        'get_small_banners',
        data: {'category': category},
      );

      if (response is List) {
        return response
            .map((e) => BannerModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e) {
      // log('Error getting small banners: $e', name: 'BannerApi');
      return [];
    }
  }
}
