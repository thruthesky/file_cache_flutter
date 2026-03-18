/// 이벤트 쿠폰 데이터 모델
///
/// event_coupons 테이블의 한 행을 나타내는 모델 클래스.
class EventCoupon {
  final int idx;
  final String couponType;
  final String title;
  final String status;
  final int wonAt;
  final int sentAt;
  final int viewedAt;
  final String displayImageUrl;

  bool get isViewed => viewedAt != 0;
  bool get isSent => status == 'sent';

  const EventCoupon({
    required this.idx,
    required this.couponType,
    required this.title,
    required this.status,
    required this.wonAt,
    required this.sentAt,
    required this.viewedAt,
    required this.displayImageUrl,
  });

  factory EventCoupon.fromJson(Map<String, dynamic> json) {
    return EventCoupon(
      idx: _toInt(json['idx']),
      couponType: json['coupon_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      wonAt: _toInt(json['won_at']),
      sentAt: _toInt(json['sent_at']),
      viewedAt: _toInt(json['viewed_at']),
      displayImageUrl: json['display_image_url']?.toString() ?? '',
    );
  }

  EventCoupon copyWith({int? viewedAt}) {
    return EventCoupon(
      idx: idx,
      couponType: couponType,
      title: title,
      status: status,
      wonAt: wonAt,
      sentAt: sentAt,
      viewedAt: viewedAt ?? this.viewedAt,
      displayImageUrl: displayImageUrl,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

/// event.myCoupons API 응답 래퍼
class EventCouponListResponse {
  final int total;
  final int page;
  final int limit;
  final List<EventCoupon> items;

  const EventCouponListResponse({
    required this.total,
    required this.page,
    required this.limit,
    required this.items,
  });

  factory EventCouponListResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return EventCouponListResponse(
      total: EventCoupon._toInt(json['total']),
      page: EventCoupon._toInt(json['page']),
      limit: EventCoupon._toInt(json['limit']),
      items: itemsList
          .whereType<Map<String, dynamic>>()
          .map((e) => EventCoupon.fromJson(e))
          .toList(),
    );
  }
}
