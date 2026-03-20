import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:philgo/weather/weather.model.dart';

/// 날씨 서비스
///
/// Open-Meteo API를 사용하여 필리핀 날씨 데이터를 가져오고 캐시합니다.
/// 메모리 캐시 (TTL 20분) 사용.
class WeatherService {
  static WeatherService? _instance;
  static WeatherService get instance => _instance ??= WeatherService._();
  WeatherService._();

  static const Duration cacheTtl = Duration(minutes: 20);
  static const String _apiBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;
  DateTime? _weatherDataFetchedAt;

  HourlyWeather? _manilaCurrentWeather;
  HourlyWeather? get manilaCurrentWeather => _manilaCurrentWeather;
  DateTime? _manilaFetchedAt;

  /// 캐시가 유효한지 확인
  bool _isCacheValid(DateTime? fetchedAt) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt) < cacheTtl;
  }

  /// 특정 도시의 날씨 데이터 API 호출
  Future<CityWeatherData> _fetchCityWeather(PhilippineCity city) async {
    final url = Uri.parse(
      '$_apiBaseUrl?'
      'latitude=${city.latitude}&'
      'longitude=${city.longitude}&'
      'hourly=temperature_2m,weather_code&'
      'timezone=Asia/Manila&'
      'forecast_days=6',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final hourly = json['hourly'] as Map<String, dynamic>;

      final times = (hourly['time'] as List).cast<String>();
      final temperatures = (hourly['temperature_2m'] as List).cast<num>();
      final weatherCodes = (hourly['weather_code'] as List).cast<int>();

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

  /// 모든 도시의 날씨 데이터 병렬 API 호출
  Future<WeatherData> _fetchFromApi() async {
    final futures = PhilippineCity.cities.map(_fetchCityWeather);
    final results = await Future.wait(futures);

    final cities = <String, CityWeatherData>{};
    for (final cityData in results) {
      cities[cityData.cityId] = cityData;
    }

    return WeatherData(cities: cities, fetchedAt: DateTime.now());
  }

  /// 날씨 데이터 로드 (메모리 캐시 우선, TTL 20분)
  Future<WeatherData> loadWeatherData() async {
    if (_weatherData != null && _isCacheValid(_weatherDataFetchedAt)) {
      return _weatherData!;
    }

    final data = await _fetchFromApi();
    _weatherData = data;
    _weatherDataFetchedAt = DateTime.now();
    return data;
  }

  /// 표시할 시간 목록 생성
  /// 오늘: 현재 시간 이후 2시간 간격
  /// 내일~5일: 4시간 간격 (0, 4, 8, 12, 16, 20시)
  List<DateTime> getDisplayTimeSlots() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slots = <DateTime>[];

    // 오늘 시간대 (2시간 간격)
    int currentHour = now.hour;
    int startHour = (currentHour % 2 == 0) ? currentHour + 2 : currentHour + 1;
    if (startHour % 2 != 0) startHour += 1;

    for (int hour = startHour; hour < 24; hour += 2) {
      slots.add(today.add(Duration(hours: hour)));
    }

    // 내일~5일 시간대 (4시간 간격)
    const fixedHours = [0, 4, 8, 12, 16, 20];
    for (int day = 1; day <= 5; day++) {
      final date = today.add(Duration(days: day));
      for (final hour in fixedHours) {
        slots.add(date.add(Duration(hours: hour)));
      }
    }

    return slots;
  }

  /// 특정 시간의 날씨 데이터 조회
  HourlyWeather? getWeatherAt(String cityId, DateTime time) {
    final cityData = _weatherData?.cities[cityId];
    if (cityData == null) return null;

    // 정확히 일치하는 시간 찾기
    for (final hourly in cityData.hourlyData) {
      if (hourly.time.year == time.year &&
          hourly.time.month == time.month &&
          hourly.time.day == time.day &&
          hourly.time.hour == time.hour) {
        return hourly;
      }
    }

    // 가장 가까운 시간 찾기
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

  /// 캐시 초기화
  Future<void> clearCache() async {
    _weatherData = null;
    _weatherDataFetchedAt = null;
    _manilaCurrentWeather = null;
    _manilaFetchedAt = null;
  }

  /// 캐시 남은 시간
  Duration? get cacheRemainingTime {
    if (_weatherDataFetchedAt == null) return null;
    final elapsed = DateTime.now().difference(_weatherDataFetchedAt!);
    if (elapsed >= cacheTtl) return null;
    return cacheTtl - elapsed;
  }

  /// 마닐라 현재 날씨 로드 (Entry 화면용)
  Future<HourlyWeather> loadManilaCurrentWeather() async {
    if (_manilaCurrentWeather != null && _isCacheValid(_manilaFetchedAt)) {
      return _manilaCurrentWeather!;
    }

    const manila = PhilippineCity(
      id: 'manila',
      nameKo: '마닐라',
      nameEn: 'Manila',
      latitude: 14.5995,
      longitude: 120.9842,
    );

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

      final temperature = (current['temperature_2m'] as num).toDouble();
      final weatherCode = current['weather_code'] as int;
      final timeStr = current['time'] as String;

      final weather = HourlyWeather(
        time: DateTime.parse(timeStr),
        temperature: temperature,
        weatherCode: weatherCode,
      );

      _manilaCurrentWeather = weather;
      _manilaFetchedAt = DateTime.now();
      return weather;
    } else {
      throw Exception('마닐라 현재 날씨를 가져오는데 실패했습니다');
    }
  }
}
