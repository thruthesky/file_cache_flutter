import 'package:philgo/api/api.service.dart';
import 'package:philgo/post/post.model.dart';

/// 포인트 광고 서비스
///
/// 포인트 광고 설정 조회 및 등록/연장 API를 제공한다.
class PointAdvertisementService {
  PointAdvertisementService._();

  /// 포인트 광고 설정 조회
  ///
  /// API: post.advertisementConfig
  /// 반환: eligible(광고 가능 여부), cost_per_hour, days(기간별 비용 목록)
  static Future<PointAdvertisementConfig> getConfig({
    required String postId,
    String? category,
  }) async {
    final result = await ApiService.instance.v7api(
      'post.advertisementConfig',
      data: {
        'post_id': postId,
        if (category != null) 'category': category,
      },
    );
    return PointAdvertisementConfig.fromJson(result);
  }

  /// 포인트 광고 등록/연장
  ///
  /// API: post.advertise (인증 필수)
  /// 기존 광고가 활성이면 연장, 만료면 신규 등록.
  static Future<Post> advertise({
    required int idx,
    required int days,
  }) async {
    final result = await ApiService.instance.v7api(
      'post.advertise',
      data: {'idx': idx, 'days': days},
    );
    return Post.fromJson(result);
  }
}

/// 포인트 광고 설정 모델
class PointAdvertisementConfig {
  final bool eligible;
  final int costPerHour;
  final List<PointAdvertisementDayOption> dayOptions;

  const PointAdvertisementConfig({
    required this.eligible,
    required this.costPerHour,
    required this.dayOptions,
  });

  factory PointAdvertisementConfig.fromJson(Map<String, dynamic> json) {
    final days = (json['days'] as List<dynamic>?) ?? [];
    return PointAdvertisementConfig(
      eligible: json['eligible'] == true,
      costPerHour: ApiService.toInt(json['cost_per_hour']),
      dayOptions: days
          .whereType<Map<String, dynamic>>()
          .map(PointAdvertisementDayOption.fromJson)
          .toList(),
    );
  }
}

/// 광고 기간 옵션 (일수 + 필요 포인트)
class PointAdvertisementDayOption {
  final int days;
  final int points;

  const PointAdvertisementDayOption({
    required this.days,
    required this.points,
  });

  factory PointAdvertisementDayOption.fromJson(Map<String, dynamic> json) {
    return PointAdvertisementDayOption(
      days: ApiService.toInt(json['days']),
      points: ApiService.toInt(json['points']),
    );
  }
}
