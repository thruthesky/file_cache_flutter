/// 배너 모델
/// Banner Model
///
/// PhilGo 광고 API에서 반환하는 배너 데이터 구조
/// API 응답 필드:
/// - idx_banner: 배너 고유 번호
/// - idx_company: 업소(광고주) 고유 번호
/// - imageUrl: 배너 이미지 URL
/// - clickUrl: 클릭 시 이동 URL
/// - target: 링크 타겟 (_blank, _self 등)
/// - type: 배너 타입 (top, wing, square, small)
/// - category: 표시 카테고리
/// - primary: 주요 텍스트 (small 배너용)
/// - secondary: 부가 텍스트 (small 배너용)
/// - ad_end_date: 광고 만료일 (YYYYMMDD)
class BannerModel {
  /// 배너 고유 번호 (idx_banner)
  int idx;

  /// 업소(광고주) 고유 번호 (idx_company)
  int idxCompany;

  /// 배너 이미지 URL (imageUrl)
  String url;

  /// 클릭 시 이동 URL (clickUrl)
  String link;

  /// 링크 타겟 (_blank, _self 등)
  String target;

  /// 배너 타입 (top, wing, square, small)
  String type;

  /// 표시 카테고리
  String category;

  /// 주요 텍스트 (small 배너용)
  String primary;

  /// 부가 텍스트 (small 배너용)
  String secondary;

  /// 광고 만료일 (YYYYMMDD)
  String adEndDate;

  BannerModel({
    required this.idx,
    required this.idxCompany,
    required this.url,
    required this.link,
    required this.target,
    required this.type,
    required this.category,
    required this.primary,
    required this.secondary,
    required this.adEndDate,
  });

  /// JSON에서 BannerModel 생성
  /// Create BannerModel from JSON
  ///
  /// API 응답 필드명 매핑:
  /// - idx_banner → idx
  /// - idx_company → idxCompany
  /// - imageUrl → url (이미지 URL)
  /// - clickUrl → link (클릭 URL)
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      /// idx_banner 필드에서 배너 고유 번호 추출
      idx: int.tryParse(json['idx_banner']?.toString() ?? '0') ?? 0,

      /// idx_company 필드에서 업소 고유 번호 추출
      idxCompany: int.tryParse(json['idx_company']?.toString() ?? '0') ?? 0,

      /// imageUrl 필드에서 이미지 URL 추출
      url: json['imageUrl'] ?? '',

      /// clickUrl 필드에서 클릭 URL 추출
      link: json['clickUrl'] ?? '',

      /// target 필드 (null일 수 있음)
      target: json['target']?.toString() ?? '',

      /// type 필드 (top, wing, square, small)
      type: json['type'] ?? '',

      /// category 필드
      category: json['category'] ?? '',

      /// primary 텍스트 (small 배너용)
      primary: json['primary'] ?? '',

      /// secondary 텍스트 (small 배너용)
      secondary: json['secondary'] ?? '',

      /// ad_end_date 필드 (int 또는 string으로 올 수 있음)
      adEndDate: json['ad_end_date']?.toString() ?? '',
    );
  }

  /// BannerModel을 JSON으로 변환
  /// Convert BannerModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'idx_banner': idx,
      'idx_company': idxCompany,
      'imageUrl': url,
      'clickUrl': link,
      'target': target,
      'type': type,
      'category': category,
      'primary': primary,
      'secondary': secondary,
      'ad_end_date': adEndDate,
    };
  }
}
