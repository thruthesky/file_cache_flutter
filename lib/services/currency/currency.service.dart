import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

/// 환율 데이터 모델 (Exchange Rate Data Model)
///
/// Frankfurter API에서 가져온 환율 데이터를 저장합니다.
/// Stores exchange rate data fetched from Frankfurter API.
class ExchangeRateData {
  /// USD 기준 환율 (USD base rates)
  final Map<String, double> usdRates;

  /// PHP 기준 환율 (PHP base rates)
  final Map<String, double> phpRates;

  /// KRW 기준 환율 (KRW base rates)
  final Map<String, double> krwRates;

  /// 데이터 조회 날짜 (Data fetch date)
  final String date;

  /// 캐시 만료 시간 (Cache expiry time)
  final DateTime expiresAt;

  const ExchangeRateData({
    required this.usdRates,
    required this.phpRates,
    required this.krwRates,
    required this.date,
    required this.expiresAt,
  });

  /// JSON에서 ExchangeRateData 객체 생성 (Create from JSON)
  factory ExchangeRateData.fromJson(Map<String, dynamic> json) {
    return ExchangeRateData(
      usdRates: Map<String, double>.from(json['usdRates']),
      phpRates: Map<String, double>.from(json['phpRates']),
      krwRates: Map<String, double>.from(json['krwRates']),
      date: json['date'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  /// ExchangeRateData를 JSON으로 변환 (Convert to JSON)
  Map<String, dynamic> toJson() {
    return {
      'usdRates': usdRates,
      'phpRates': phpRates,
      'krwRates': krwRates,
      'date': date,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  /// 캐시가 만료되었는지 확인 (Check if cache is expired)
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// 환율 서비스 (Currency Exchange Service)
///
/// Frankfurter API를 사용하여 환율 데이터를 가져오고 캐시합니다.
/// 싱글톤 패턴으로 앱 전체에서 동일한 인스턴스를 사용합니다.
///
/// ### 사용법 (Usage):
/// ```dart
/// // 환율 데이터 로드
/// final data = await CurrencyService.instance.loadExchangeRates();
///
/// // PHP → KRW 환율 조회
/// final phpToKrw = data.phpRates['KRW'];
///
/// // 환율 계산
/// final result = CurrencyService.instance.calculateConversion(100, 'USD');
/// ```
class CurrencyService {
  /// 싱글톤 인스턴스 (Singleton instance)
  static CurrencyService? _instance;

  /// 싱글톤 인스턴스 접근자 (Singleton instance accessor)
  static CurrencyService get instance => _instance ??= CurrencyService._();

  /// 비공개 생성자 (Private constructor)
  CurrencyService._();

  /// 지원 통화 목록 (Supported currencies)
  static const List<String> currencies = ['USD', 'PHP', 'KRW'];

  /// 통화 플래그 이모지 (Currency flag emojis)
  static const Map<String, String> currencyFlags = {
    'USD': '🇺🇸',
    'PHP': '🇵🇭',
    'KRW': '🇰🇷',
  };

  /// 통화 이름 (Currency names)
  static const Map<String, String> currencyNames = {
    'USD': '미국 달러',
    'PHP': '필리핀 페소',
    'KRW': '한국 원',
  };

  /// 캐시 파일명 (Cache filename)
  static const String _cacheFileName = 'exchange_rate_cache.json';

  /// 캐시 TTL (25분) (Cache TTL - 25 minutes)
  static const Duration cacheTtl = Duration(minutes: 25);

  /// Frankfurter API 기본 URL (Frankfurter API base URL)
  static const String _apiBaseUrl = 'https://api.frankfurter.dev/v1';

  /// 현재 환율 데이터 (Current exchange rate data)
  ExchangeRateData? _exchangeData;

  /// 환율 데이터 접근자 (Exchange data accessor)
  ExchangeRateData? get exchangeData => _exchangeData;

  /// 캐시 파일 경로 가져오기 (Get cache file path)
  Future<File> _getCacheFile() async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/$_cacheFileName');
  }

  /// 캐시에서 환율 데이터 로드 (Load exchange rate data from cache)
  Future<ExchangeRateData?> _loadFromCache() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final data = ExchangeRateData.fromJson(json);

        /// 캐시가 만료되지 않았으면 반환 (Return if cache is not expired)
        if (!data.isExpired) {
          return data;
        }
      }
    } catch (e) {
      /// 캐시 로드 실패 시 무시 (Ignore cache load failure)
      debugPrint('CurrencyService: 캐시 로드 실패 - $e');
    }
    return null;
  }

  /// 캐시에 환율 데이터 저장 (Save exchange rate data to cache)
  Future<void> _saveToCache(ExchangeRateData data) async {
    try {
      final file = await _getCacheFile();
      await file.writeAsString(jsonEncode(data.toJson()));
    } catch (e) {
      /// 캐시 저장 실패 시 무시 (Ignore cache save failure)
      debugPrint('CurrencyService: 캐시 저장 실패 - $e');
    }
  }

  /// Frankfurter API에서 환율 데이터 가져오기 (Fetch exchange rates from Frankfurter API)
  ///
  /// [base] 기준 통화 코드 (예: USD, PHP, KRW)
  /// [symbols] 대상 통화 코드들 (쉼표로 구분, 예: KRW,PHP)
  Future<Map<String, double>> _fetchRatesFromApi(
    String base,
    String symbols,
  ) async {
    final url = Uri.parse('$_apiBaseUrl/latest?base=$base&symbols=$symbols');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rates = json['rates'] as Map<String, dynamic>;
      return rates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
    } else {
      throw Exception(
        '환율 데이터를 가져오는데 실패했습니다. (Failed to fetch exchange rates)',
      );
    }
  }

  /// 환율 데이터 로드 (Load exchange rates)
  ///
  /// 1. 캐시에서 먼저 로드 시도
  /// 2. 캐시가 없거나 만료되면 API 호출
  /// 3. 새 데이터를 캐시에 저장
  ///
  /// Returns [ExchangeRateData] containing rates for USD, PHP, KRW
  /// Throws [Exception] if API call fails and no cached data available
  Future<ExchangeRateData> loadExchangeRates() async {
    /// 1. 캐시에서 먼저 로드 시도 (Try loading from cache first)
    final cachedData = await _loadFromCache();
    if (cachedData != null) {
      _exchangeData = cachedData;
      return cachedData;
    }

    /// 2. 캐시가 없거나 만료되면 API 호출 (Call API if cache is missing or expired)
    final usdRates = await _fetchRatesFromApi('USD', 'KRW,PHP');
    final phpRates = await _fetchRatesFromApi('PHP', 'KRW,USD');
    final krwRates = await _fetchRatesFromApi('KRW', 'PHP,USD');

    final data = ExchangeRateData(
      usdRates: usdRates,
      phpRates: phpRates,
      krwRates: krwRates,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      expiresAt: DateTime.now().add(cacheTtl),
    );

    /// 3. 캐시에 저장 (Save to cache)
    await _saveToCache(data);

    _exchangeData = data;
    return data;
  }

  /// 선택된 통화 기준 환율 가져오기 (Get rates for selected currency)
  ///
  /// [currency] 기준 통화 코드 (USD, PHP, KRW)
  /// Returns 해당 통화 기준의 환율 맵, 데이터가 없으면 빈 맵 반환
  Map<String, double> getRatesForCurrency(String currency) {
    if (_exchangeData == null) return {};

    switch (currency) {
      case 'USD':
        return _exchangeData!.usdRates;
      case 'PHP':
        return _exchangeData!.phpRates;
      case 'KRW':
        return _exchangeData!.krwRates;
      default:
        return {};
    }
  }

  /// 금액 포맷팅 (Format amount)
  ///
  /// [amount] 포맷할 금액
  /// [currency] 통화 코드
  /// Returns 천단위 구분자가 적용된 문자열 (KRW는 소수점 없이 표시)
  String formatAmount(double amount, String currency) {
    final formatter = NumberFormat('#,##0.00');
    if (currency == 'KRW') {
      /// KRW는 소수점 없이 표시 (KRW displays without decimals)
      return NumberFormat('#,##0').format(amount);
    }
    return formatter.format(amount);
  }

  /// 환율 변환 계산 (Calculate exchange rate conversion)
  ///
  /// [amount] 변환할 금액
  /// [fromCurrency] 기준 통화 코드
  /// Returns 다른 통화로 변환된 금액 맵
  Map<String, double> calculateConversion(double amount, String fromCurrency) {
    final rates = getRatesForCurrency(fromCurrency);
    final result = <String, double>{};

    for (final currency in currencies) {
      if (currency == fromCurrency) continue;
      final rate = rates[currency] ?? 0;
      result[currency] = amount * rate;
    }

    return result;
  }

  /// 캐시 초기화 (Clear cache)
  ///
  /// 테스트 또는 강제 새로고침 시 사용
  Future<void> clearCache() async {
    try {
      final file = await _getCacheFile();
      if (await file.exists()) {
        await file.delete();
      }
      _exchangeData = null;
    } catch (e) {
      debugPrint('CurrencyService: 캐시 삭제 실패 - $e');
    }
  }
}
