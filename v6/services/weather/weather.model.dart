import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 필리핀 도시 정보 (Philippine City Information)
///
/// 날씨 조회 대상 도시의 좌표와 메타데이터를 정의합니다.
/// Open-Meteo API 호출 시 위도/경도를 사용합니다.
///
/// ### 사용 예시 (Usage Example):
/// ```dart
/// for (final city in PhilippineCity.cities) {
/////   print('${city.nameKo}: ${city.latitude}, ${city.longitude}');
/// }
/// ```
class PhilippineCity {
  /// 도시 고유 ID (예: 'manila', 'cebu')
  /// Unique city identifier
  final String id;

  /// 한글 이름 (예: '마닐라', '세부')
  /// Korean name for display
  final String nameKo;

  /// 영문 이름 (예: 'Manila', 'Cebu')
  /// English name for display
  final String nameEn;

  /// 위도 (Latitude)
  /// -90 ~ 90 범위
  final double latitude;

  /// 경도 (Longitude)
  /// -180 ~ 180 범위
  final double longitude;

  /// 생성자 (Constructor)
  const PhilippineCity({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });

  /// 미리 정의된 5개 필리핀 도시 목록 (Predefined 5 Philippine cities)
  ///
  /// 마닐라, 세부, 앙헬레스, 보라카이, 바기오 순서로 정렬
  static const List<PhilippineCity> cities = [
    PhilippineCity(
      id: 'manila',
      nameKo: '마닐라',
      nameEn: 'Manila',
      latitude: 14.5995,
      longitude: 120.9842,
    ),
    PhilippineCity(
      id: 'cebu',
      nameKo: '세부',
      nameEn: 'Cebu',
      latitude: 10.3157,
      longitude: 123.8854,
    ),
    PhilippineCity(
      id: 'angeles',
      nameKo: '앙헬레스',
      nameEn: 'Angeles',
      latitude: 15.1450,
      longitude: 120.5887,
    ),
    PhilippineCity(
      id: 'boracay',
      nameKo: '보라카이',
      nameEn: 'Boracay',
      latitude: 11.9674,
      longitude: 121.9248,
    ),
    PhilippineCity(
      id: 'baguio',
      nameKo: '바기오',
      nameEn: 'Baguio',
      latitude: 16.4023,
      longitude: 120.5960,
    ),
  ];

  /// ID로 도시 찾기 (Find city by ID)
  ///
  /// [id] 도시 ID
  /// 찾지 못하면 null 반환
  static PhilippineCity? findById(String id) {
    try {
      return cities.firstWhere((city) => city.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 시간별 날씨 데이터 (Hourly Weather Data)
///
/// 특정 시간의 온도와 날씨 코드를 저장합니다.
/// Open-Meteo API의 hourly 응답을 파싱하여 생성됩니다.
///
/// ### 사용 예시 (Usage Example):
/// ```dart
/// final weather = HourlyWeather(
///   time: DateTime.now(),
///   temperature: 28.5,
///   weatherCode: 0,  // 맑음
/// );
///// print('${weather.temperature}°C - ${WeatherCodeHelper.getDescription(weather.weatherCode)}');
/// ```
class HourlyWeather {
  /// 시간 (Time)
  /// API 응답의 ISO8601 형식 시간
  final DateTime time;

  /// 온도 (Temperature)
  /// 섭씨 단위 (°C)
  final double temperature;

  /// WMO 날씨 코드 (WMO Weather Code)
  /// 0=맑음, 1-2=대체로 맑음, 3=흐림, 61-67=비 등
  final int weatherCode;

  /// 생성자 (Constructor)
  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  /// JSON에서 HourlyWeather 생성 (Create from JSON)
  ///
  /// [json] API 응답 또는 캐시에서 불러온 JSON
  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
    );
  }

  /// HourlyWeather를 JSON으로 변환 (Convert to JSON)
  ///
  /// 캐시 저장 시 사용됩니다.
  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weatherCode': weatherCode,
    };
  }
}

/// 도시별 날씨 데이터 (City Weather Data)
///
/// 한 도시의 시간별 날씨 목록을 저장합니다.
/// 6일간의 시간별 데이터 (약 144시간)를 포함합니다.
class CityWeatherData {
  /// 도시 ID (City ID)
  /// PhilippineCity.id와 매칭됩니다.
  final String cityId;

  /// 시간별 날씨 데이터 목록 (Hourly weather data list)
  /// 6일간의 시간별 데이터
  final List<HourlyWeather> hourlyData;

  /// 생성자 (Constructor)
  const CityWeatherData({required this.cityId, required this.hourlyData});

  /// JSON에서 CityWeatherData 생성 (Create from JSON)
  factory CityWeatherData.fromJson(Map<String, dynamic> json) {
    final hourlyList = (json['hourlyData'] as List)
        .map((item) => HourlyWeather.fromJson(item as Map<String, dynamic>))
        .toList();

    return CityWeatherData(
      cityId: json['cityId'] as String,
      hourlyData: hourlyList,
    );
  }

  /// CityWeatherData를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'hourlyData': hourlyData.map((h) => h.toJson()).toList(),
    };
  }
}

/// 전체 날씨 데이터 (All Weather Data)
///
/// 모든 도시의 날씨 데이터를 캐시용으로 저장합니다.
/// FileCache에 저장되며 20분 TTL로 관리됩니다.
class WeatherData {
  /// 도시별 날씨 데이터 맵 (City weather data map)
  /// 키: 도시 ID, 값: 도시 날씨 데이터
  final Map<String, CityWeatherData> cities;

  /// 데이터 조회 시간 (Data fetch time)
  /// 캐시 만료 판단에 사용됩니다.
  final DateTime fetchedAt;

  /// 생성자 (Constructor)
  const WeatherData({required this.cities, required this.fetchedAt});

  /// JSON에서 WeatherData 생성 (Create from JSON)
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final citiesMap = <String, CityWeatherData>{};
    final citiesJson = json['cities'] as Map<String, dynamic>;

    for (final entry in citiesJson.entries) {
      citiesMap[entry.key] = CityWeatherData.fromJson(
        entry.value as Map<String, dynamic>,
      );
    }

    return WeatherData(
      cities: citiesMap,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }

  /// WeatherData를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    final citiesJson = <String, dynamic>{};
    for (final entry in cities.entries) {
      citiesJson[entry.key] = entry.value.toJson();
    }

    return {'cities': citiesJson, 'fetchedAt': fetchedAt.toIso8601String()};
  }
}

/// WMO 날씨 코드 헬퍼 (WMO Weather Code Helper)
///
/// WMO 표준 날씨 코드를 한글/영문 텍스트와 아이콘으로 변환합니다.
///
/// ### WMO 코드 범위:
/// - 0: 맑음 (Clear sky)
/// - 1-2: 대체로 맑음 (Mainly clear, Partly cloudy)
/// - 3: 흐림 (Overcast)
/// - 45, 48: 안개 (Fog)
/// - 51, 53, 55: 이슬비 (Drizzle)
/// - 56, 57: 어는 이슬비 (Freezing drizzle)
/// - 61, 63, 65: 비 (Rain)
/// - 66, 67: 어는 비 (Freezing rain)
/// - 71, 73, 75: 눈 (Snow)
/// - 77: 눈 알갱이 (Snow grains)
/// - 80, 81, 82: 소나기 (Rain showers)
/// - 85, 86: 눈 소나기 (Snow showers)
/// - 95: 뇌우 (Thunderstorm)
/// - 96, 99: 우박 뇌우 (Thunderstorm with hail)
///
/// ### 사용 예시 (Usage Example):
/// ```dart
/// final code = 61;  // 약한 비
///// print(WeatherCodeHelper.getDescription(code));  // '비'
/// final icon = WeatherCodeHelper.getIcon(code);    // 비 아이콘
/// ```
class WeatherCodeHelper {
  /// 날씨 코드를 한글 텍스트로 변환 (Convert code to Korean text)
  ///
  /// [code] WMO 날씨 코드
  /// 알 수 없는 코드는 '알 수 없음' 반환
  static String getDescription(int code) {
    return switch (code) {
      0 => '맑음',
      1 || 2 => '대체로 맑음',
      3 => '흐림',
      45 || 48 => '안개',
      51 || 53 || 55 => '이슬비',
      56 || 57 => '어는 이슬비',
      61 || 63 || 65 => '비',
      66 || 67 => '어는 비',
      71 || 73 || 75 => '눈',
      77 => '싸락눈',
      80 || 81 || 82 => '소나기',
      85 || 86 => '눈소나기',
      95 => '뇌우',
      96 || 99 => '우박 뇌우',
      _ => '알 수 없음',
    };
  }

  /// 날씨 코드를 영문 텍스트로 변환 (Convert code to English text)
  ///
  /// [code] WMO 날씨 코드
  static String getDescriptionEn(int code) {
    return switch (code) {
      0 => 'Clear',
      1 || 2 => 'Partly Cloudy',
      3 => 'Cloudy',
      45 || 48 => 'Fog',
      51 || 53 || 55 => 'Drizzle',
      56 || 57 => 'Freezing Drizzle',
      61 || 63 || 65 => 'Rain',
      66 || 67 => 'Freezing Rain',
      71 || 73 || 75 => 'Snow',
      77 => 'Snow Grains',
      80 || 81 || 82 => 'Showers',
      85 || 86 => 'Snow Showers',
      95 => 'Thunderstorm',
      96 || 99 => 'Hail Storm',
      _ => 'Unknown',
    };
  }

  /// 날씨 코드에 해당하는 Font Awesome 아이콘 반환 (Get icon for weather code)
  ///
  /// [code] WMO 날씨 코드
  /// Font Awesome Pro Light 아이콘 사용 (Light > Regular > Solid 우선순위)
  static IconData getIcon(int code) {
    return switch (code) {
      // 맑음 (Clear)
      0 => FontAwesomeIcons.lightSun,
      // 대체로 맑음 (Partly cloudy)
      1 || 2 => FontAwesomeIcons.lightCloudSun,
      // 흐림 (Cloudy)
      3 => FontAwesomeIcons.lightCloud,
      // 안개 (Fog)
      45 || 48 => FontAwesomeIcons.lightSmog,
      // 이슬비 (Drizzle)
      51 || 53 || 55 || 56 || 57 => FontAwesomeIcons.lightCloudDrizzle,
      // 비 (Rain)
      61 || 63 || 65 || 66 || 67 => FontAwesomeIcons.lightCloudRain,
      // 눈 (Snow)
      71 || 73 || 75 || 77 => FontAwesomeIcons.lightSnowflake,
      // 소나기 (Showers)
      80 || 81 || 82 => FontAwesomeIcons.lightCloudShowersHeavy,
      // 눈소나기 (Snow showers)
      85 || 86 => FontAwesomeIcons.lightCloudSnow,
      // 뇌우 (Thunderstorm)
      95 || 96 || 99 => FontAwesomeIcons.lightCloudBolt,
      // 알 수 없음 (Unknown)
      _ => FontAwesomeIcons.lightQuestion,
    };
  }

  /// 날씨 코드에 해당하는 색상 반환 (Get color for weather code)
  ///
  /// [code] WMO 날씨 코드
  /// UI에서 아이콘 색상으로 사용됩니다.
  static Color getColor(int code) {
    return switch (code) {
      // 맑음 - 주황색
      0 => Colors.orange,
      // 대체로 맑음 - 노란색
      1 || 2 => Colors.amber,
      // 흐림 - 회색
      3 => Colors.grey,
      // 안개 - 밝은 회색
      45 || 48 => Colors.blueGrey,
      // 이슬비 - 밝은 파랑
      51 || 53 || 55 || 56 || 57 => Colors.lightBlue,
      // 비 - 파랑
      61 || 63 || 65 || 66 || 67 => Colors.blue,
      // 눈 - 하늘색
      71 || 73 || 75 || 77 => Colors.cyan,
      // 소나기 - 남색
      80 || 81 || 82 => Colors.indigo,
      // 눈소나기 - 청록색
      85 || 86 => Colors.teal,
      // 뇌우 - 보라색
      95 || 96 || 99 => Colors.purple,
      // 알 수 없음 - 회색
      _ => Colors.grey,
    };
  }
}
