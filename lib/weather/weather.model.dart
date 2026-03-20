import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 필리핀 도시 정보
class PhilippineCity {
  final String id;
  final String nameKo;
  final String nameEn;
  final double latitude;
  final double longitude;

  const PhilippineCity({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.latitude,
    required this.longitude,
  });

  /// 5개 필리핀 도시 목록
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

  /// ID로 도시 찾기
  static PhilippineCity? findById(String id) {
    try {
      return cities.firstWhere((city) => city.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 시간별 날씨 데이터
class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: DateTime.parse(json['time'] as String),
      temperature: (json['temperature'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'temperature': temperature,
      'weatherCode': weatherCode,
    };
  }
}

/// 도시별 날씨 데이터
class CityWeatherData {
  final String cityId;
  final List<HourlyWeather> hourlyData;

  const CityWeatherData({required this.cityId, required this.hourlyData});

  factory CityWeatherData.fromJson(Map<String, dynamic> json) {
    final hourlyList = (json['hourlyData'] as List)
        .map((item) => HourlyWeather.fromJson(item as Map<String, dynamic>))
        .toList();
    return CityWeatherData(
      cityId: json['cityId'] as String,
      hourlyData: hourlyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityId': cityId,
      'hourlyData': hourlyData.map((h) => h.toJson()).toList(),
    };
  }
}

/// 전체 날씨 데이터 (캐시용)
class WeatherData {
  final Map<String, CityWeatherData> cities;
  final DateTime fetchedAt;

  const WeatherData({required this.cities, required this.fetchedAt});

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

  Map<String, dynamic> toJson() {
    final citiesJson = <String, dynamic>{};
    for (final entry in cities.entries) {
      citiesJson[entry.key] = entry.value.toJson();
    }
    return {'cities': citiesJson, 'fetchedAt': fetchedAt.toIso8601String()};
  }
}

/// WMO 날씨 코드 헬퍼
class WeatherCodeHelper {
  /// 날씨 코드 → 한글 설명
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

  /// 날씨 코드 → 영문 설명
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

  /// 날씨 코드 → Font Awesome 아이콘
  static IconData getIcon(int code) {
    return switch (code) {
      0 => FontAwesomeIcons.lightSun,
      1 || 2 => FontAwesomeIcons.lightCloudSun,
      3 => FontAwesomeIcons.lightCloud,
      45 || 48 => FontAwesomeIcons.lightSmog,
      51 || 53 || 55 || 56 || 57 => FontAwesomeIcons.lightCloudDrizzle,
      61 || 63 || 65 || 66 || 67 => FontAwesomeIcons.lightCloudRain,
      71 || 73 || 75 || 77 => FontAwesomeIcons.lightSnowflake,
      80 || 81 || 82 => FontAwesomeIcons.lightCloudShowersHeavy,
      85 || 86 => FontAwesomeIcons.lightCloudSnow,
      95 || 96 || 99 => FontAwesomeIcons.lightCloudBolt,
      _ => FontAwesomeIcons.lightQuestion,
    };
  }

  /// 날씨 코드 → 색상
  static Color getColor(int code) {
    return switch (code) {
      0 => Colors.orange,
      1 || 2 => Colors.amber,
      3 => Colors.grey,
      45 || 48 => Colors.blueGrey,
      51 || 53 || 55 || 56 || 57 => Colors.lightBlue,
      61 || 63 || 65 || 66 || 67 => Colors.blue,
      71 || 73 || 75 || 77 => Colors.cyan,
      80 || 81 || 82 => Colors.indigo,
      85 || 86 => Colors.teal,
      95 || 96 || 99 => Colors.purple,
      _ => Colors.grey,
    };
  }
}
