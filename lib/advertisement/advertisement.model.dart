import 'package:philgo/api/api.service.dart';

/// v7 BannerEntity 기반 배너 모델
class BannerModel {
  final int idx;
  final int idxCompany;
  final String type;
  final String category;
  final String imageUrl;
  final String clickUrl;
  final String? target;
  final String primary;
  final String secondary;
  final String allPage;
  final String adEndDate;
  final String key;

  const BannerModel({
    required this.idx,
    required this.idxCompany,
    required this.type,
    required this.category,
    required this.imageUrl,
    required this.clickUrl,
    this.target,
    required this.primary,
    required this.secondary,
    required this.allPage,
    required this.adEndDate,
    required this.key,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      idx: ApiService.toInt(json['idx']),
      idxCompany: ApiService.toInt(json['idx_company']),
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      clickUrl: json['click_url']?.toString() ?? '',
      target: json['target']?.toString(),
      primary: json['primary']?.toString() ?? '',
      secondary: json['secondary']?.toString() ?? '',
      allPage: json['all_page']?.toString() ?? '',
      adEndDate: json['ad_end_date']?.toString() ?? '',
      key: json['key']?.toString() ?? '',
    );
  }
}

/// advertisement.topBanners 응답 모델
class TopBannersResult {
  final List<BannerModel> left;
  final List<BannerModel> right;
  final bool leftFixed;
  final bool rightFixed;

  const TopBannersResult({
    required this.left,
    required this.right,
    required this.leftFixed,
    required this.rightFixed,
  });

  factory TopBannersResult.fromJson(Map<String, dynamic> json) {
    return TopBannersResult(
      left: _parseBannerList(json['left']),
      right: _parseBannerList(json['right']),
      leftFixed: json['left_fixed'] == true,
      rightFixed: json['right_fixed'] == true,
    );
  }

  static List<BannerModel> _parseBannerList(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(BannerModel.fromJson)
        .toList();
  }
}

/// advertisement.wingBanners 응답 모델
class WingBannersResult {
  final List<BannerModel> left;
  final List<BannerModel> right;

  const WingBannersResult({
    required this.left,
    required this.right,
  });

  factory WingBannersResult.fromJson(Map<String, dynamic> json) {
    return WingBannersResult(
      left: TopBannersResult._parseBannerList(json['left']),
      right: TopBannersResult._parseBannerList(json['right']),
    );
  }

  /// 좌우 배너를 하나의 리스트로 합침
  List<BannerModel> get all => [...left, ...right];
}
