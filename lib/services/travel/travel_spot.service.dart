import 'dart:convert';
import 'dart:isolate';

import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/travel_spot.model.dart';

/// 원격 데이터 업데이트 콜백 타입 (Remote data update callback type)
typedef OnRemoteDataUpdated = void Function(List<TravelSpot> spots);

/// 여행 명소 데이터 서비스 (Travel Spot Data Service)
///
/// 원격 JSON 다운로드, Isolate 디코딩, 12분 캐시를 관리합니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// Manages remote JSON download, Isolate decoding, and 12-minute cache.
/// Uses singleton pattern for consistent instance across the app.
///
/// ### 캐시 전략 (Cache Strategy):
/// 1. 캐시 확인 → 유효한 캐시 사용 (Check cache → use if valid)
/// 2. 캐시 없음 → 번들 파일 먼저 사용 (No cache → use bundle first)
/// 3. 백그라운드에서 원격 다운로드 (Background remote download)
/// 4. 다운로드 완료 시 콜백으로 화면 업데이트 (Callback for UI update on completion)
///
/// ### 사용법 (Usage):
/// ```dart
/// // 여행 명소 데이터 로드 (콜백으로 원격 데이터 수신)
/// final spots = await TravelSpotService.instance.loadTravelSpots(
///   onRemoteDataUpdated: (newSpots) {
///     // 원격 데이터 도착 시 화면 업데이트
///     setState(() => _allSpots = newSpots);
///   },
/// );
///
/// // 캐시 초기화
/// await TravelSpotService.instance.clearCache();
/// ```
class TravelSpotService {
  /// 싱글톤 인스턴스 (Singleton instance)
  static TravelSpotService? _instance;

  /// 싱글톤 인스턴스 접근자 (Singleton instance accessor)
  static TravelSpotService get instance => _instance ??= TravelSpotService._();

  /// 비공개 생성자 (Private constructor)
  TravelSpotService._();

  /// 캐시 TTL (12분) (Cache TTL - 12 minutes)
  static const Duration cacheTtl = Duration(minutes: 12);

  /// 캐시 키 (Cache key)
  static const String _cacheKey = 'travel_spots';

  /// 원격 JSON URL (Remote JSON URL)
  static const String _remoteUrl =
      'https://file.philgo.com/philgo_files/travel/travel_spots.json';

  /// 번들 파일 경로 (Bundle file path)
  static const String _bundlePath =
      'lib/philgo_files/travel/travel_spots.json';

  /// HTTP 요청 타임아웃 (HTTP request timeout)
  static const Duration _httpTimeout = Duration(seconds: 10);

  /// 여행 명소 데이터 전용 캐시 (File cache for travel spots data)
  ///
  /// FileCache 인스턴스를 사용하여 데이터를 캐시합니다.
  /// 12분 TTL로 설정되어 있으며, 메모리+파일 이중 캐싱을 사용합니다.
  /// Uses FileCache instance with 12-minute TTL and memory+file dual caching.
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
  /// 3. 백그라운드에서 원격 다운로드 (Background remote download)
  /// 4. 다운로드 완료 시 콜백으로 화면 업데이트 (Callback for UI update on completion)
  ///
  /// [onRemoteDataUpdated] 원격 데이터 다운로드 완료 시 호출되는 콜백
  /// Callback invoked when remote data download is complete.
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

    /// 3. 백그라운드에서 원격 다운로드 (Background remote download)
    _fetchAndUpdateInBackground(onRemoteDataUpdated);

    return bundleSpots;
  }

  /// 백그라운드에서 원격 데이터 다운로드 및 캐시 업데이트
  /// (Download remote data in background and update cache)
  ///
  /// 비동기로 실행되며, 완료 시 콜백을 통해 화면 업데이트를 알립니다.
  /// Runs asynchronously and notifies UI update via callback on completion.
  void _fetchAndUpdateInBackground(OnRemoteDataUpdated? onRemoteDataUpdated) {
    _fetchFromRemote().then((spots) async {
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
        'TravelSpotService: 원격에서 로드 완료 (Loaded from remote) - ${spots.length}개',
      );

      /// 4. 콜백으로 화면 업데이트 알림 (Notify UI update via callback)
      if (onRemoteDataUpdated != null) {
        onRemoteDataUpdated(spots);
      }
    }).catchError((e) {
      debugPrint(
        'TravelSpotService: 백그라운드 원격 다운로드 실패 (Background remote download failed) - $e',
      );
    });
  }

  /// 원격 JSON 다운로드 및 Isolate 파싱 (Download remote JSON and parse in Isolate)
  ///
  /// HTTP GET 요청으로 원격 JSON을 다운로드하고,
  /// Isolate.run()을 사용하여 메인 스레드 차단 없이 JSON을 디코딩합니다.
  /// Downloads remote JSON via HTTP GET and decodes using Isolate.run()
  /// to avoid blocking the main thread.
  Future<List<TravelSpot>> _fetchFromRemote() async {
    debugPrint('TravelSpotService: 원격 JSON 다운로드 중... (Downloading remote JSON...)');

    /// HTTP GET 요청 (HTTP GET request)
    final response = await http
        .get(Uri.parse(_remoteUrl))
        .timeout(_httpTimeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    /// Isolate에서 JSON 디코딩 (Decode JSON in Isolate)
    return _parseJsonInIsolate(response.body);
  }

  /// Isolate에서 JSON 파싱 (Parse JSON in Isolate)
  ///
  /// 대용량 JSON 디코딩 시 메인 스레드 차단을 방지합니다.
  /// Prevents main thread blocking when decoding large JSON.
  ///
  /// [jsonString] JSON 문자열 (JSON string)
  /// Returns: TravelSpot 리스트 (List of TravelSpot)
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
  /// 캐시가 없고 네트워크 실패 시 최종 폴백으로 사용됩니다.
  /// Used as final fallback when no cache and network failure.
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
  /// Clears both memory and file cache.
  Future<void> clearCache() async {
    await _cache.clear();
    _spots = null;
    debugPrint('TravelSpotService: 캐시 삭제 완료 (Cache cleared)');
  }

  /// 캐시 남은 시간 조회 (Get remaining cache time)
  ///
  /// 캐시가 만료되기까지 남은 시간을 반환합니다.
  /// Returns the remaining time until cache expires.
  Duration? get cacheRemainingTime => _cache.getRemainingTime(_cacheKey);

  /// 강제 새로고침 (Force refresh)
  ///
  /// 캐시를 무시하고 원격에서 데이터를 다시 로드합니다.
  /// Ignores cache and reloads data from remote.
  Future<List<TravelSpot>> forceRefresh() async {
    await clearCache();
    return loadTravelSpots();
  }
}
