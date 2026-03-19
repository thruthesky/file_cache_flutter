import 'package:philgo/api/api.service.dart';
import 'advertisement.model.dart';

/// v7 광고(Advertisement) API 서비스
///
/// 배너 조회 관련 v7 API 호출을 제공한다.
/// 모든 메서드는 static이므로 인스턴스 생성 없이 사용 가능.
class AdvertisementService {
  AdvertisementService._();

  /// 상단 배너 조회
  ///
  /// API: advertisement.topBanners (인증 불필요)
  ///
  /// [category] 게시판/카테고리 코드 (선택, 예: 'qna', 'freetalk')
  /// 반환: 좌/우 배너 목록 + 고정 여부
  static Future<TopBannersResult> topBanners({String? category}) async {
    final result = await ApiService.instance.v7api(
      'advertisement.topBanners',
      data: {if (category != null) 'category': category},
    );
    return TopBannersResult.fromJson(result);
  }

  /// 날개 배너 조회
  ///
  /// API: advertisement.wingBanners (인증 불필요)
  ///
  /// [category] 게시판/카테고리 코드 (선택)
  /// 반환: 좌/우 배너 목록
  static Future<WingBannersResult> wingBanners({String? category}) async {
    final result = await ApiService.instance.v7api(
      'advertisement.wingBanners',
      data: {if (category != null) 'category': category},
    );
    return WingBannersResult.fromJson(result);
  }
}
