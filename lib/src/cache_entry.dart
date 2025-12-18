/// 캐시 엔트리 래퍼 클래스 (Cache Entry Wrapper Class)
///
/// 캐시된 데이터를 감싸는 래퍼 클래스입니다.
/// TTL(Time-To-Live) 관리를 위해 만료 시간을 함께 저장합니다.
///
/// ### 예시 (Example):
/// ```dart
/// final entry = CacheEntry<String>(
///   data: 'Hello',
///   expiresAt: DateTime.now().add(Duration(minutes: 30)),
///   createdAt: DateTime.now(),
/// );
///
/// if (entry.isExpired) {
///   print('캐시가 만료되었습니다.');
/// }
/// ```
class CacheEntry<T> {
  /// 실제 캐시된 데이터 (Actual cached data)
  final T data;

  /// 캐시 만료 시간 (Cache expiry time)
  final DateTime expiresAt;

  /// 캐시 생성 시간 (Cache creation time)
  final DateTime createdAt;

  /// 생성자 (Constructor)
  const CacheEntry({
    required this.data,
    required this.expiresAt,
    required this.createdAt,
  });

  /// 캐시가 만료되었는지 확인 (Check if cache is expired)
  ///
  /// 현재 시간이 만료 시간을 지났으면 true 반환
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 캐시 남은 시간 (Remaining time until expiry)
  ///
  /// 이미 만료된 경우 Duration.zero 반환
  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// JSON 직렬화 (Convert to JSON)
  ///
  /// [dataToJson] 실제 데이터를 JSON으로 변환하는 함수
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) dataToJson) {
    return {
      'data': dataToJson(data),
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// JSON 역직렬화 (Create from JSON)
  ///
  /// [json] JSON 맵
  /// [dataFromJson] JSON을 실제 데이터로 변환하는 함수
  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) dataFromJson,
  ) {
    return CacheEntry<T>(
      data: dataFromJson(json['data'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() {
    return 'CacheEntry<$T>(expiresAt: $expiresAt, isExpired: $isExpired)';
  }
}
