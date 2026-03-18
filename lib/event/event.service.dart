import 'package:philgo/api/api.service.dart';
import 'package:philgo/event/event_coupon.model.dart';

/// 이벤트 관련 API 호출 서비스
class EventService {
  EventService._();

  /// 내 쿠폰 목록 조회 (페이지네이션)
  ///
  /// API: event.myCoupons
  static Future<EventCouponListResponse> myCoupons({
    int page = 1,
    int limit = 100,
  }) async {
    final response = await ApiService.instance.v7api(
      'event.myCoupons',
      data: {'page': page, 'limit': limit},
    );
    return EventCouponListResponse.fromJson(response);
  }

  /// 쿠폰 QR 코드 확인 (viewed_at 기록)
  ///
  /// API: event.viewCoupon
  static Future<void> viewCoupon({required int idx}) async {
    await ApiService.instance.v7api(
      'event.viewCoupon',
      data: {'idx': idx},
    );
  }
}
