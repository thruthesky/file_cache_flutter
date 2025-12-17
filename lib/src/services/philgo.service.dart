import 'package:philgo_api/philgo_api.dart';

/// 홈페이지 통계 데이터 모델 (Homepage Stats Data Model)
///
/// get_homepage_stats API 응답 데이터를 담는 모델입니다.
/// Holds response data from get_homepage_stats API.
class HomepageStats {
  /// 총 회원 수 (Total user count)
  final int totalUserCount;

  /// 총 글 수 (Total post count)
  final int totalPostCount;

  /// 캐시 남은 시간 (초) - 캐시 히트 시에만 포함 (TTL in seconds - only included on cache hit)
  final int? ttl;

  const HomepageStats({
    required this.totalUserCount,
    required this.totalPostCount,
    this.ttl,
  });

  /// JSON에서 HomepageStats 객체 생성 (Create from JSON)
  factory HomepageStats.fromJson(Map<String, dynamic> json) {
    return HomepageStats(
      totalUserCount: json['total_user_count'] as int? ?? 0,
      totalPostCount: json['total_post_count'] as int? ?? 0,
      ttl: json['ttl'] as int?,
    );
  }

  /// HomepageStats를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'total_user_count': totalUserCount,
      'total_post_count': totalPostCount,
      if (ttl != null) 'ttl': ttl,
    };
  }
}

class PhilgoService {
  static PhilgoService? _instance;
  static PhilgoService get instance => _instance ??= PhilgoService._();

  PhilgoService._();

  /// PhilGo 설정 정보 로드
  ///
  /// API에서 설정 정보를 가져와 PhilgoSetting 모델로 파싱하여 저장
  Future<PhilgoSetting> loadSetting() async {
    final json = await apiCall('setting', apiServerUrl: PhilgoConfig.phpApiUrl);
    final setting = PhilgoSetting.fromJson(json);

    return setting;
  }

  /// 홈페이지 통계 조회 (Get homepage stats)
  ///
  /// 총 회원 수, 총 글 수 등의 통계 정보를 반환합니다.
  /// 서버에서 1시간 동안 캐시됩니다.
  ///
  /// Returns statistics including total user count and total post count.
  /// Data is cached on server for 1 hour.
  ///
  /// ### 사용법 (Usage):
  /// ```dart
  /// final stats = await PhilgoService.instance.getHomepageStats();
  /// print('회원 수: ${stats.totalUserCount}');
  /// print('글 수: ${stats.totalPostCount}');
  /// ```
  Future<HomepageStats> getHomepageStats() async {
    // 디버그: API URL 확인 (Debug: Check API URL)
    print('[PhilgoService] getHomepageStats 호출, URL: ${PhilgoConfig.phpApiUrl}');

    final json = await apiCall(
      'get_homepage_stats',
      apiServerUrl: PhilgoConfig.phpApiUrl,
      debug: true, // 디버그 모드 활성화 (Enable debug mode)
    );

    // 디버그: API 응답 확인 (Debug: Check API response)
    print('[PhilgoService] getHomepageStats 응답: $json');

    return HomepageStats.fromJson(json);
  }
}
