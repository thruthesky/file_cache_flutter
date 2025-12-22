import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:file_cache_flutter/file_cache_flutter.dart';
import 'weather.model.dart';

/// 날씨 서비스 (Weather Service)
///
/// Open-Meteo API를 사용하여 필리핀 날씨 데이터를 가져오고 캐시합니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// ### 캐시 관리 (Cache Management):
/// FileCache<>를 사용하여 캐시를 관리합니다.
/// - TTL: 20분
/// - 메모리 + 파일 이중 캐싱
///
/// ### 사용법 (Usage):
/// ```dart
/// // 날씨 데이터 로드
/// final data = await WeatherService.instance.loadWeatherData();
///
/// // 특정 도시 날씨 조회
/// final manilaWeather = data.cities['manila'];
///
/// // 특정 시간의 날씨 조회
/// final weather = WeatherService.instance.getWeatherAt('manila', DateTime.now());
/// ```
class WeatherService {
  /// 싱글톤 인스턴스 (Singleton instance)
  static WeatherService? _instance;

  /// 싱글톤 인스턴스 접근자 (Singleton instance accessor)
  static WeatherService get instance => _instance ??= WeatherService._();

  /// 비공개 생성자 (Private constructor)
  WeatherService._();

  /// 캐시 TTL (20분) (Cache TTL - 20 minutes)
  static const Duration cacheTtl = Duration(minutes: 20);

  /// 캐시 키 (Cache key)
  static const String _cacheKey = 'philippines_weather';

  /// 마닐라 현재 날씨 캐시 키 (Manila current weather cache key)
  static const String _manilaCacheKey = 'manila_current_weather';

  /// Open-Meteo API 기본 URL (Open-Meteo API base URL)
  static const String _apiBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// 날씨 데이터 전용 캐시 (File cache for weather data)
  ///
  /// FileCache 인스턴스를 사용하여 데이터를 캐시합니다.
  /// 20분 TTL로 설정되어 있으며, 메모리+파일 이중 캐싱을 사용합니다.
  late final FileCache<WeatherData> _cache = FileCache<WeatherData>(
    cacheName: 'weather',
    defaultTtl: cacheTtl,
    fromJson: WeatherData.fromJson,
    toJson: (data) => data.toJson(),
    useMemoryCache: true,
  );

  /// 현재 날씨 데이터 (Current weather data)
  /// loadWeatherData() 호출 후 사용 가능합니다.
  WeatherData? _weatherData;

  /// 날씨 데이터 접근자 (Weather data accessor)
  WeatherData? get weatherData => _weatherData;

  /// 마닐라 현재 날씨 캐시 (Manila current weather cache)
  late final FileCache<HourlyWeather> _manilaCache = FileCache<HourlyWeather>(
    cacheName: 'manila_current',
    defaultTtl: cacheTtl,
    fromJson: HourlyWeather.fromJson,
    toJson: (data) => data.toJson(),
    useMemoryCache: true,
  );

  /// 마닐라 현재 날씨 데이터 (Manila current weather data)
  HourlyWeather? _manilaCurrentWeather;

  /// 마닐라 현재 날씨 접근자 (Manila current weather accessor)
  HourlyWeather? get manilaCurrentWeather => _manilaCurrentWeather;

  /// 특정 도시의 날씨 데이터 API 호출 (Fetch weather data for a city)
  ///
  /// [city] 조회할 도시 정보
  /// Returns 해당 도시의 시간별 날씨 데이터
  ///
  /// ### API 파라미터:
  /// - latitude, longitude: 도시 좌표
  /// - hourly: temperature_2m, weather_code (시간별 온도, 날씨 코드)
  /// - timezone: Asia/Manila (필리핀 시간대)
  /// - forecast_days: 6 (6일 예보)
  Future<CityWeatherData> _fetchCityWeather(PhilippineCity city) async {
    /// API URL 구성 (Build API URL)
    final url = Uri.parse(
      '$_apiBaseUrl?'
      'latitude=${city.latitude}&'
      'longitude=${city.longitude}&'
      'hourly=temperature_2m,weather_code&'
      'timezone=Asia/Manila&'
      'forecast_days=6',
    );

    debugPrint('WeatherService: API 호출 - ${city.nameKo}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = json['hourly'] as Map<String, dynamic>;

      /// API 응답에서 시간, 온도, 날씨 코드 추출
      /// Extract time, temperature, weather code from API response
      final times = (hourly['time'] as List).cast<String>();
      final temperatures = (hourly['temperature_2m'] as List).cast<num>();
      final weatherCodes = (hourly['weather_code'] as List).cast<int>();

      /// 시간별 데이터 파싱 (Parse hourly data)
      final hourlyData = <HourlyWeather>[];
      for (int i = 0; i < times.length; i++) {
        hourlyData.add(
          HourlyWeather(
            time: DateTime.parse(times[i]),
            temperature: temperatures[i].toDouble(),
            weatherCode: weatherCodes[i],
          ),
        );
      }

      return CityWeatherData(cityId: city.id, hourlyData: hourlyData);
    } else {
      throw Exception('날씨 데이터를 가져오는데 실패했습니다: ${city.nameKo}');
    }
  }

  /// 모든 도시의 날씨 데이터 API 호출 (Fetch all cities weather)
  ///
  /// 5개 도시 데이터를 병렬로 조회하여 성능을 최적화합니다.
  Future<WeatherData> _fetchFromApi() async {
    debugPrint('WeatherService: API에서 날씨 데이터 가져오는 중...');

    /// 병렬로 모든 도시 데이터 조회 (Fetch all cities in parallel)
    final futures = PhilippineCity.cities.map(_fetchCityWeather);
    final results = await Future.wait(futures);

    /// 도시별 데이터 맵 구성 (Build city data map)
    final cities = <String, CityWeatherData>{};
    for (final cityData in results) {
      cities[cityData.cityId] = cityData;
    }

    debugPrint('WeatherService: API 호출 완료 - ${cities.length}개 도시');

    return WeatherData(cities: cities, fetchedAt: DateTime.now());
  }

  /// 날씨 데이터 로드 (Load weather data)
  ///
  /// 캐시 우선 전략을 사용합니다:
  /// 1. 캐시에서 먼저 로드 시도
  /// 2. 캐시가 없거나 만료되면 API 호출
  /// 3. 새 데이터를 캐시에 저장
  ///
  /// Returns 날씨 데이터 (캐시 또는 API에서 가져옴)
  Future<WeatherData> loadWeatherData() async {
    /// 1. 캐시에서 먼저 로드 시도 (Try loading from cache first)
    final cachedData = await _cache.get(_cacheKey);
    if (cachedData != null) {
      debugPrint('WeatherService: 캐시에서 날씨 데이터 로드 완료');
      _weatherData = cachedData;
      return cachedData;
    }

    /// 2. 캐시가 없거나 만료되면 API 호출 (Call API if cache miss)
    final data = await _fetchFromApi();

    /// 3. 캐시에 저장 (Save to cache)
    await _cache.set(_cacheKey, data);

    _weatherData = data;
    return data;
  }

  /// 표시할 시간 목록 생성 (Generate display time slots)
  ///
  /// 요구사항에 따라 시간 간격을 다르게 설정합니다:
  /// - 오늘: 현재 시간 이후 2시간 간격
  /// - 내일~5일: 4시간 간격 (0, 4, 8, 12, 16, 20시)
  ///
  /// Returns 표시할 시간 목록
  List<DateTime> getDisplayTimeSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slots = <DateTime>[];

    /// 오늘 시간대 (Today's time slots - 2 hour intervals)
    /// 현재 시간 이후의 짝수 시간부터 시작
    int currentHour = now.hour;

    /// 다음 짝수 시간으로 올림 (Round up to next even hour)
    int startHour = (currentHour % 2 == 0) ? currentHour + 2 : currentHour + 1;
    if (startHour % 2 != 0) startHour += 1;

    for (int hour = startHour; hour < 24; hour += 2) {
      slots.add(today.add(Duration(hours: hour)));
    }

    /// 내일~5일 시간대 (Tomorrow to day 5 - 4 hour intervals)
    /// 0, 4, 8, 12, 16, 20시
    const fixedHours = [0, 4, 8, 12, 16, 20];
    for (int day = 1; day <= 5; day++) {
      final date = today.add(Duration(days: day));
      for (final hour in fixedHours) {
        slots.add(date.add(Duration(hours: hour)));
      }
    }

    return slots;
  }

  /// 특정 시간의 날씨 데이터 조회 (Get weather for specific time)
  ///
  /// [cityId] 도시 ID (예: 'manila', 'cebu')
  /// [time] 조회할 시간
  ///
  /// 정확히 일치하는 시간이 없으면 가장 가까운 시간의 데이터를 반환합니다.
  /// Returns 가장 가까운 시간의 날씨 데이터, 없으면 null
  HourlyWeather? getWeatherAt(String cityId, DateTime time) {
    final cityData = _weatherData?.cities[cityId];
    if (cityData == null) return null;

    /// 정확히 일치하는 시간 찾기 (Find exact time match first)
    for (final hourly in cityData.hourlyData) {
      if (hourly.time.year == time.year &&
          hourly.time.month == time.month &&
          hourly.time.day == time.day &&
          hourly.time.hour == time.hour) {
        return hourly;
      }
    }

    /// 정확한 일치가 없으면 가장 가까운 시간 찾기 (Find closest time)
    HourlyWeather? closest;
    Duration? minDiff;

    for (final hourly in cityData.hourlyData) {
      final diff = hourly.time.difference(time).abs();
      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
        closest = hourly;
      }
    }

    return closest;
  }

  /// 캐시 초기화 (Clear cache)
  ///
  /// 메모리와 파일 캐시를 모두 삭제합니다.
  /// 새로고침 버튼 클릭 시 호출됩니다.
  Future<void> clearCache() async {
    await _cache.clear();
    _weatherData = null;
    debugPrint('WeatherService: 캐시 삭제 완료');
  }

  /// 캐시 남은 시간 조회 (Get remaining cache time)
  ///
  /// 다음 업데이트까지 남은 시간을 반환합니다.
  /// 캐시가 없으면 null 반환
  Duration? get cacheRemainingTime => _cache.getRemainingTime(_cacheKey);

  /// 마닐라 현재 날씨 로드 (Load Manila current weather)
  ///
  /// Open-Meteo API의 current 파라미터를 사용하여 마닐라의 현재 날씨를 가져옵니다.
  /// Entry 화면에서 빠르게 현재 날씨를 표시하기 위해 사용합니다.
  ///
  /// ### API 파라미터:
  /// - latitude, longitude: 마닐라 좌표 (14.5995, 120.9842)
  /// - current: temperature_2m, weather_code (현재 온도, 날씨 코드)
  /// - timezone: Asia/Manila (필리핀 시간대)
  ///
  /// Returns 마닐라 현재 날씨 데이터
  Future<HourlyWeather> loadManilaCurrentWeather() async {
    /// 1. 캐시에서 먼저 로드 시도 (Try loading from cache first)
    final cachedData = await _manilaCache.get(_manilaCacheKey);
    if (cachedData != null) {
      debugPrint('WeatherService: 캐시에서 마닐라 현재 날씨 로드 완료');
      _manilaCurrentWeather = cachedData;
      return cachedData;
    }

    /// 2. 캐시가 없거나 만료되면 API 호출 (Call API if cache miss)
    debugPrint('WeatherService: API에서 마닐라 현재 날씨 가져오는 중...');

    /// 마닐라 좌표 (Manila coordinates)
    const manila = PhilippineCity(
      id: 'manila',
      nameKo: '마닐라',
      nameEn: 'Manila',
      latitude: 14.5995,
      longitude: 120.9842,
    );

    /// API URL 구성 - current 파라미터 사용 (Build API URL with current parameter)
    final url = Uri.parse(
      '$_apiBaseUrl?'
      'latitude=${manila.latitude}&'
      'longitude=${manila.longitude}&'
      'current=temperature_2m,weather_code&'
      'timezone=Asia/Manila',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final current = json['current'] as Map<String, dynamic>;

      /// API 응답에서 현재 온도, 날씨 코드 추출
      /// Extract current temperature, weather code from API response
      final temperature = (current['temperature_2m'] as num).toDouble();
      final weatherCode = current['weather_code'] as int;
      final timeStr = current['time'] as String;

      final weather = HourlyWeather(
        time: DateTime.parse(timeStr),
        temperature: temperature,
        weatherCode: weatherCode,
      );

      /// 3. 캐시에 저장 (Save to cache)
      await _manilaCache.set(_manilaCacheKey, weather);

      _manilaCurrentWeather = weather;
      debugPrint(
        'WeatherService: 마닐라 현재 날씨 - ${temperature.round()}°C, '
        '${WeatherCodeHelper.getDescription(weatherCode)}',
      );

      return weather;
    } else {
      throw Exception('마닐라 현재 날씨를 가져오는데 실패했습니다');
    }
  }
}
