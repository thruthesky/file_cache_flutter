import 'dart:convert';
import 'dart:isolate';

import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/travel_spot.model.dart';
import '../../v7_api/travel_api.dart';

/// 원격 데이터 업데이트 콜백 타입 (Remote data update callback type)
typedef OnRemoteDataUpdated = void Function(List<TravelSpot> spots);

/// 여행 명소 데이터 서비스 (Travel Spot Data Service)
///
/// v7 API를 통해 여행 명소 데이터를 조회하고 캐싱합니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// ### 캐시 전략 (Cache Strategy):
/// 1. 캐시 확인 → 유효한 캐시 사용 (Check cache → use if valid)
/// 2. 캐시 없음 → 번들 파일 먼저 사용 (No cache → use bundle first)
/// 3. 백그라운드에서 v7 API 호출 (Background v7 API call)
/// 4. API 응답 도착 시 콜백으로 화면 업데이트 (Callback for UI update)
///
/// ### 3일 캐시 TTL:
/// 여행 정보는 변경 빈도가 낮으므로 장기 캐시를 적용합니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// final spots = await TravelSpotService.instance.loadTravelSpots(
///   onRemoteDataUpdated: (newSpots) {
///     setState(() => _allSpots = newSpots);
///   },
/// );
///
/// // 상세 조회 (texts 포함)
/// final detail = await TravelSpotService.instance.getSpotDetail(42);
///
/// // 필터 옵션
/// final filters = await TravelSpotService.instance.getFilters();
/// ```
class TravelSpotService {
  /// 싱글톤 인스턴스 (Singleton instance)
  static TravelSpotService? _instance;

  /// 싱글톤 인스턴스 접근자 (Singleton instance accessor)
  static TravelSpotService get instance => _instance ??= TravelSpotService._();

  /// 비공개 생성자 (Private constructor)
  TravelSpotService._();

  /// 3일 캐시 TTL (여행 정보는 변경 빈도가 낮으므로 장기 캐시 적용)
  static const Duration cacheTtl = Duration(days: 3);

  /// 캐시 키 (Cache key)
  static const String _cacheKey = 'travel_spots';

  /// 번들 파일 경로 (Bundle file path)
  static const String _bundlePath =
      'lib/philgo_files/travel/travel_spots.json';

  /// 여행 명소 데이터 전용 캐시 (File cache for travel spots data)
  ///
  /// 3일 TTL로 설정되어 있으며, 메모리+파일 이중 캐싱을 사용합니다.
  late final FileCache<TravelSpotsData> _cache = FileCache<TravelSpotsData>(
    cacheName: 'travel_spots',
    defaultTtl: cacheTtl,
    fromJson: TravelSpotsData.fromJson,
    toJson: (data) => data.toJson(),
    useMemoryCache: true,
  );

  /// 현재 로드된 데이터 (Currently loaded data)
  List<TravelSpot>? _spots;

  /// 여행 명소 데이터 접근자 (Travel spots data accessor)
  List<TravelSpot>? get spots => _spots;

  /// 여행 명소 데이터 로드 (Load travel spots data)
  ///
  /// 우선순위 (Priority):
  /// 1. 캐시 확인 → 유효한 캐시 사용 (Check cache → use if valid)
  /// 2. 캐시 없음 → 번들 파일 먼저 사용 (No cache → use bundle first)
  /// 3. 백그라운드에서 v7 API 호출 (Background v7 API call)
  /// 4. API 응답 도착 시 콜백으로 화면 업데이트 (Callback for UI update)
  ///
  /// [onRemoteDataUpdated] v7 API 응답 도착 시 호출되는 콜백
  ///
  /// Returns: 여행 명소 리스트 (List of travel spots)
  Future<List<TravelSpot>> loadTravelSpots({
    OnRemoteDataUpdated? onRemoteDataUpdated,
  }) async {
    /// 1. 캐시 확인 (Check cache)
    final cachedData = await _cache.get(_cacheKey);
    if (cachedData != null) {
      debugPrint('TravelSpotService: 캐시에서 로드 완료 (Loaded from cache)');
      _spots = cachedData.spots;
      return cachedData.spots;
    }

    /// 2. 캐시 없음 → 번들 파일 먼저 사용 (No cache → use bundle first)
    final bundleSpots = await _loadFromBundle();

    /// 3. 백그라운드에서 v7 API 호출 (Background v7 API call)
    _fetchAndUpdateInBackground(onRemoteDataUpdated);

    return bundleSpots;
  }

  /// 백그라운드에서 v7 API 호출 및 캐시 업데이트
  /// (Call v7 API in background and update cache)
  void _fetchAndUpdateInBackground(OnRemoteDataUpdated? onRemoteDataUpdated) {
    _fetchFromApi().then((spots) async {
      /// 캐시에 저장 (Save to cache)
      await _cache.set(
        _cacheKey,
        TravelSpotsData(
          spots: spots,
          fetchedAt: DateTime.now(),
        ),
      );
      _spots = spots;
      debugPrint(
        'TravelSpotService: v7 API에서 로드 완료 (Loaded from v7 API) - ${spots.length}개',
      );

      /// 4. 콜백으로 화면 업데이트 알림 (Notify UI update via callback)
      if (onRemoteDataUpdated != null) {
        onRemoteDataUpdated(spots);
      }
    }).catchError((e) {
      debugPrint(
        'TravelSpotService: v7 API 호출 실패 (v7 API call failed) - $e',
      );
    });
  }

  /// v7 API에서 전체 목록 로드 (texts 제외)
  ///
  /// travel.list API를 호출하여 전체 명소 목록을 가져옵니다.
  /// texts 필드는 제외되어 경량화됩니다.
  Future<List<TravelSpot>> _fetchFromApi() async {
    debugPrint('TravelSpotService: v7 API 호출 중... (Calling v7 API...)');

    final response = await TravelApi.list(limit: 9999);

    final items = (response['items'] as List<dynamic>?) ?? [];
    return items
        .map((e) => TravelSpot.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 여행 명소 상세 조회 (texts 포함)
  ///
  /// v7 travel.get API를 호출하여 마크다운 상세 콘텐츠를 로드합니다.
  ///
  /// [index] JSON 배열 인덱스
  /// Returns: 상세 텍스트가 포함된 TravelSpot
  Future<TravelSpot> getSpotDetail(int index) async {
    debugPrint('TravelSpotService: 상세 조회 (Detail) index=$index');

    final response = await TravelApi.get(index: index);
    return TravelSpot.fromJson(response);
  }

  /// 필터 옵션 조회
  ///
  /// v7 travel.filters API를 호출하여 필터 드롭다운 옵션을 가져옵니다.
  ///
  /// Returns: {provinces: [...], cities: [...], categories: [...]}
  Future<Map<String, dynamic>> getFilters() async {
    return await TravelApi.filters();
  }

  /// Isolate에서 JSON 파싱 (Parse JSON in Isolate)
  ///
  /// 대용량 JSON 디코딩 시 메인 스레드 차단을 방지합니다.
  static Future<List<TravelSpot>> _parseJsonInIsolate(String jsonString) {
    return Isolate.run(() {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((e) => TravelSpot.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  /// 번들 파일에서 로드 (Load from bundle file)
  ///
  /// 캐시가 없고 v7 API 호출 전 최초 폴백으로 사용됩니다.
  Future<List<TravelSpot>> _loadFromBundle() async {
    debugPrint('TravelSpotService: 번들 파일에서 로드 (Loading from bundle file)');

    final jsonString = await rootBundle.loadString(_bundlePath);

    /// Isolate에서 JSON 디코딩 (Decode JSON in Isolate)
    final spots = await _parseJsonInIsolate(jsonString);

    _spots = spots;
    debugPrint(
      'TravelSpotService: 번들에서 로드 완료 (Loaded from bundle) - ${spots.length}개',
    );
    return spots;
  }

  /// 캐시 초기화 (Clear cache)
  ///
  /// 메모리 및 파일 캐시를 모두 삭제합니다.
  Future<void> clearCache() async {
    await _cache.clear();
    _spots = null;
    debugPrint('TravelSpotService: 캐시 삭제 완료 (Cache cleared)');
  }

  /// 캐시 남은 시간 조회 (Get remaining cache time)
  Duration? get cacheRemainingTime => _cache.getRemainingTime(_cacheKey);

  /// 강제 새로고침 (Force refresh)
  ///
  /// 캐시를 무시하고 v7 API에서 데이터를 다시 로드합니다.
  Future<List<TravelSpot>> forceRefresh() async {
    await clearCache();
    return loadTravelSpots();
  }
}
